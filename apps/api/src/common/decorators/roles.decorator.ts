import { SetMetadata } from '@nestjs/common';
import { Role } from '@prisma/client';

export const ROLES_KEY = 'roles';

/** Decorator để khai báo roles được phép truy cập route */
export const Roles = (...roles: Role[]) => SetMetadata(ROLES_KEY, roles);
