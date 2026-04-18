import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';
import { jwtVerify } from 'jose';

// Routes công khai — không cần auth
const PUBLIC_ROUTES = ['/login'];

export default async function proxy(request: NextRequest) {
  const { pathname } = request.nextUrl;

  // Bỏ qua static files, Next.js internals
  if (
    pathname.startsWith('/_next') ||
    pathname.startsWith('/api') ||
    pathname.startsWith('/favicon') ||
    pathname.match(/\.(png|jpe?g|webp|svg|gif|ico|sql|txt)$/i)
  ) {
    return NextResponse.next();
  }

  // Kiểm tra token trong cookie
  const token = request.cookies.get('mf_access_token')?.value;

  const isPublicRoute = PUBLIC_ROUTES.includes(pathname);

  // Kiểm tra tính hợp lệ của JWT
  let isTokenValid = false;
  if (token) {
    try {
      // Mặc định cần khớp với JWT_ACCESS_SECRET bên backend api.
      const secret = new TextEncoder().encode(process.env.JWT_ACCESS_SECRET || 'secretKey');
      await jwtVerify(token, secret);
      isTokenValid = true;
    } catch (e) {
      // Token lỗi/giả mạo/hết hạn
      isTokenValid = false;
    }
  }

  // Nếu JWT hợp lệ mà vào /login → redirect về /
  if (isPublicRoute && isTokenValid) {
    return NextResponse.redirect(new URL('/', request.url));
  }

  // Nếu JWT không có hoặc không hợp lệ mà vào route private → xoá rác và redirect /login
  if (!isPublicRoute && !isTokenValid) {
    const loginUrl = new URL('/login', request.url);
    loginUrl.searchParams.set('from', pathname);
    
    const response = NextResponse.redirect(loginUrl);
    // Nếu token giả, xoá đi để app không nhận diện nhầm
    if (token) {
      response.cookies.delete('mf_access_token');
    }
    return response;
  }

  return NextResponse.next();
}

export const config = {
  // Match tất cả routes trừ _next, api, static files, hình ảnh, tài liệu
  matcher: ['/((?!api|_next/static|_next/image|favicon.ico|.*\\.(?:svg|png|jpg|jpeg|gif|webp|sql|txt)$).*)'],
};
