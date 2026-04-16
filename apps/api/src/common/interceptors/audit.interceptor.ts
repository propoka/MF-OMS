import {
  CallHandler,
  ExecutionContext,
  Injectable,
  NestInterceptor,
} from '@nestjs/common';
import { Observable, tap } from 'rxjs';
import { PrismaService } from '../../prisma/prisma.service';
import { AuditAction } from '@prisma/client';
import { Reflector } from '@nestjs/core';

export const AUDIT_ACTION_KEY = 'audit_action';
export const AUDIT_ENTITY_KEY = 'audit_entity';

@Injectable()
export class AuditInterceptor implements NestInterceptor {
  constructor(
    private readonly prisma: PrismaService,
    private readonly reflector: Reflector,
  ) {}

  async intercept(
    context: ExecutionContext,
    next: CallHandler,
  ): Promise<Observable<any>> {
    const request = context.switchToHttp().getRequest();
    const method = request.method;

    // Chỉ audit các thao tác write
    const auditMethods = ['POST', 'PUT', 'PATCH', 'DELETE'];
    if (!auditMethods.includes(method)) {
      return next.handle();
    }

    const action = this.reflector.get<AuditAction>(
      AUDIT_ACTION_KEY,
      context.getHandler(),
    );
    const entityType = this.reflector.get<string>(
      AUDIT_ENTITY_KEY,
      context.getHandler(),
    );

    // Nếu không khai báo @AuditLog() thì bỏ qua
    if (!action || !entityType) {
      return next.handle();
    }

    const user = request.user;
    const ipAddress =
      request.headers['x-forwarded-for'] || request.socket?.remoteAddress;

    // Fix #16: Capture oldData TRƯỚC khi handler xử lý (cho UPDATE/DELETE/STATUS_CHANGE)
    let oldData: any = null;
    if (
      ['UPDATE', 'DELETE', 'STATUS_CHANGE'].includes(action) &&
      request.params?.id
    ) {
      try {
        oldData = await this.fetchEntityData(entityType, request.params.id);
      } catch {
        // Không tìm được entity cũ → oldData = null, vẫn tiếp tục
      }
    }

    return next.handle().pipe(
      tap((responseData) => {
        // Fire and forget (bọc promise để xoá cấu trúc lỗi misused-promises của RxJS)
        void (async () => {
          try {
            const entityId =
              responseData?.id || request.params?.id || 'unknown';

            await this.prisma.auditLog.create({
              data: {
                userId: user?.id || null,
                userEmail: user?.email || null,
                action,
                entityType,
                entityId: String(entityId),
                oldData: oldData ? JSON.parse(JSON.stringify(oldData)) : null,
                newData: responseData
                  ? JSON.parse(JSON.stringify(responseData))
                  : null,
                ipAddress: String(ipAddress || ''),
              },
            });
          } catch {
            // Audit log failure không được làm crash request
            console.error('[AuditInterceptor] Failed to write audit log');
          }
        })();
      }),
    );
  }

  /**
   * Fetch entity hiện tại từ DB trước khi bị thay đổi (cho oldData)
   */
  private async fetchEntityData(
    entityType: string,
    entityId: string,
  ): Promise<any> {
    switch (entityType) {
      case 'Order':
        return this.prisma.order.findUnique({
          where: { id: entityId },
          include: { items: true },
        });
      case 'Customer':
        return this.prisma.customer.findUnique({ where: { id: entityId } });
      case 'Product':
        return this.prisma.product.findUnique({ where: { id: entityId } });
      case 'User':
        return this.prisma.user.findUnique({
          where: { id: entityId },
          select: {
            id: true,
            email: true,
            fullName: true,
            role: true,
            isActive: true,
          },
        });
      case 'CompanySettings':
        return this.prisma.companySettings.findFirst();
      case 'CancelReason':
        return this.prisma.cancelReason.findUnique({ where: { id: entityId } });
      case 'CustomerSpecialPrice':
        return null; // Composite key, skip
      default:
        return null;
    }
  }
}
