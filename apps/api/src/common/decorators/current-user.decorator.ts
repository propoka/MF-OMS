import { createParamDecorator, ExecutionContext } from '@nestjs/common';

/** Lấy user hiện tại từ JWT payload trong request */
export const CurrentUser = createParamDecorator(
  (data: string | undefined, ctx: ExecutionContext) => {
    const request = ctx.switchToHttp().getRequest();
    const user = request.user;
    return data ? user?.[data] : user;
  },
);
