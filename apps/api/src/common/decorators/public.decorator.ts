import { SetMetadata } from '@nestjs/common';

export const IS_PUBLIC_KEY = 'isPublic';

/**
 * Đánh dấu route là Public — bỏ qua JWT auth guard toàn cục
 * Dùng cho: /auth/login, /auth/refresh
 */
export const Public = () => SetMetadata(IS_PUBLIC_KEY, true);
