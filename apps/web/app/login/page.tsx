'use client';

import { useState, Suspense } from 'react';
import { useAuth } from '@/lib/auth-context';
import { useRouter, useSearchParams } from 'next/navigation';
import { Card, CardContent, CardFooter } from '@/components/ui/card';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Button } from '@/components/ui/button';
import { Eye, EyeOff, Loader2, LogIn } from 'lucide-react';

// BUG-07: Tách component để dùng useSearchParams (Next.js yêu cầu Suspense boundary)
function LoginForm() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const { login } = useAuth();
  const router = useRouter();
  const searchParams = useSearchParams();

  // BUG-07: Đọc `from` param để redirect về đúng trang sau login
  const from = searchParams.get('from') || '/customers';

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setLoading(true);

    try {
      // BUG-01: login() không còn tự push nữa — ta tự xử lý redirect
      await login(email, password);
      router.push(from);
    } catch (err: any) {
      setError(err.message || 'Đăng nhập thất bại. Vui lòng thử lại.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <main className="min-h-screen flex items-center justify-center relative overflow-hidden">
      {/* Full-screen background image */}
      <div 
        className="absolute inset-0 bg-cover bg-center bg-no-repeat"
        style={{ backgroundImage: 'url("/login-bg.webp")' }}
      >
        <div className="absolute inset-0 bg-black/20 backdrop-blur-md" />
      </div>

      <div className="w-full max-w-[440px] relative z-10 px-4">
        {/* Logo above card */}
        <div className="flex flex-col items-center justify-center mb-8 w-full text-center">
          <div className="relative flex justify-center items-center w-full">
            <div className="absolute inset-0 bg-primary/20 rounded-full blur-2xl scale-150" />
            <img 
              src="/Logo-Moutain-Farmers.png" 
              alt="Mountain Farmers Logo" 
              className="h-24 w-auto object-contain relative z-10 drop-shadow-xl"
            />
          </div>
        </div>

        <Card className="glass bg-white/40 border border-white/40 shadow-2xl backdrop-blur-2xl rounded-2xl overflow-hidden">
          {/* Gradient accent bar at top */}
          <div className="h-1 bg-gradient-to-r from-primary/60 via-primary to-primary/60" />

          <CardContent className="pt-8 pb-6 px-8">
            {/* Header text */}
            <div className="flex flex-col items-center justify-center text-center mb-7 w-full">
              <h1 className="text-xl font-bold text-foreground tracking-tight">Đăng nhập</h1>
              <p className="text-sm text-muted-foreground mt-1.5 max-w-[260px] mx-auto text-balance leading-relaxed font-medium">
                Hệ thống quản lý nội bộ <br />
                Mountain Farmer
              </p>
            </div>

            <form onSubmit={handleLogin} className="space-y-5">
              {error && (
                <div className="p-3 bg-destructive/10 text-destructive text-sm rounded-lg flex items-center gap-2 border border-destructive/20 animate-in fade-in slide-in-from-top-1 duration-300">
                  <div className="h-2 w-2 rounded-full bg-destructive shrink-0" />
                  {error}
                </div>
              )}

              <div className="space-y-2">
                <Label htmlFor="email" className="text-foreground font-medium">Email</Label>
                <Input
                  id="email"
                  type="email"
                  placeholder="Email của bạn"
                  className="h-12 bg-background/60 border-border/60 focus-visible:border-primary focus-visible:ring-primary/20 transition-all duration-200 rounded-xl text-base"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  disabled={loading}
                  required
                />
              </div>

              <div className="space-y-2">
                <Label htmlFor="password" className="text-foreground font-medium">Mật khẩu</Label>
                <div className="relative">
                  <Input
                    id="password"
                    type={showPassword ? 'text' : 'password'}
                    placeholder="••••••••"
                    className="h-12 bg-background/60 border-border/60 focus-visible:border-primary focus-visible:ring-primary/20 transition-all duration-200 pr-12 rounded-xl text-base"
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                    disabled={loading}
                    required
                  />
                  <button
                    type="button"
                    className="absolute right-3 top-1/2 -translate-y-1/2 text-muted-foreground hover:text-foreground p-1 rounded-md transition-colors"
                    onClick={() => setShowPassword(!showPassword)}
                  >
                    {showPassword ? <EyeOff size={18} /> : <Eye size={18} />}
                  </button>
                </div>
              </div>

              <Button 
                type="submit" 
                className="w-full h-12 text-base font-semibold rounded-xl shadow-md hover:shadow-lg transition-all duration-300 group"
                disabled={loading}
              >
                {loading ? (
                  <Loader2 className="animate-spin w-5 h-5 mr-2" />
                ) : (
                  <LogIn className="w-5 h-5 mr-2 transition-transform group-hover:translate-x-0.5" />
                )}
                Đăng nhập
              </Button>
            </form>
          </CardContent>

          <CardFooter className="flex justify-center py-6 w-full">
            <p className="text-xs text-muted-foreground/70 text-center w-full">
              Phát triển bởi the. Poka Lab © {new Date().getFullYear()}
            </p>
          </CardFooter>
        </Card>
      </div>
    </main>
  );
}

export default function LoginPage() {
  return (
    <Suspense fallback={
      <div 
        className="min-h-screen flex items-center justify-center bg-cover bg-center bg-no-repeat relative"
        style={{ backgroundImage: 'url("/login-bg.webp")' }}
      >
        <div className="absolute inset-0 bg-black/20 backdrop-blur-md" />
        <Loader2 className="animate-spin text-white w-8 h-8 relative z-10" />
      </div>
    }>
      <LoginForm />
    </Suspense>
  );
}
