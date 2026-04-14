import { SetMetadata } from '@nestjs/common';
import { AuditAction } from '@prisma/client';

export const AUDIT_ACTION_KEY = 'audit_action';
export const AUDIT_ENTITY_KEY = 'audit_entity';

/** Decorator để khai báo audit log cho từng route */
export const AuditLog = (action: AuditAction, entityType: string) =>
  (target: any, key: string, descriptor: PropertyDescriptor) => {
    SetMetadata(AUDIT_ACTION_KEY, action)(target, key, descriptor);
    SetMetadata(AUDIT_ENTITY_KEY, entityType)(target, key, descriptor);
    return descriptor;
  };
