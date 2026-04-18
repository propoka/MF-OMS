'use client';

import { useState, Suspense } from 'react';
import { useAuth } from '@/lib/auth-context';
import { useRouter, useSearchParams } from 'next/navigation';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Eye, EyeOff, Loader2, LogIn, Check } from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';
import { cn } from '@/lib/utils';

const uiverseStyles = `
.login-btn-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  width: 100%;
}

.fx-layer {
  filter: contrast(3);
}

.uiverse-box {
  z-index: 500;
  position: relative;
  width: var(--w);
  height: var(--h);
  display: flex;
  justify-content: center;
  align-items: center;
  border-radius: 9999px;
  border: 1px double rgba(51, 51, 51, 0.08);
  box-shadow: inset 2px -2px 1px -1px rgba(255, 255, 255, 0.9), inset -2px 2px 1px -1px rgba(255, 255, 255, 0.9), inset 6px -6px 1px -6px rgba(255, 255, 255, 0.55), inset -6px 6px 1px -6px rgba(255, 255, 255, 0.55), inset 0 0 2px rgba(0, 0, 0, 0.8), 0 4px 8px rgba(0, 0, 0, 0.2);
  background: rgba(0, 0, 0, 0.02);
  backdrop-filter: blur(2px);
  cursor: pointer;
  filter: brightness(0.9);
}

.uiverse-box::before {
  content: "";
  position: absolute;
  z-index: 1;
  top: 35%;
  left: 50%;
  transform: translateX(-50%);
  width: calc(var(--w) - 16px);
  height: calc(var(--h) - 16px);
  border-radius: 9999px;
  border: 1px solid rgba(0, 0, 0, 0.9);
  filter: blur(8px);
}

.uiverse-box::after {
  z-index: 501;
  content: "";
  position: absolute;
  width: var(--w);
  height: var(--h);
  border-radius: 9999px;
  filter: blur(7px);
  background: linear-gradient(
    45deg,
    rgba(255, 255, 255, 0.8) 0%,
    transparent var(--tr),
    transparent calc(100% - var(--tr)),
    rgba(255, 255, 255, 0.8) 100%
  );
}

.uiverse-box .circle-overlay {
  position: absolute;
  width: calc(var(--w) - 9px);
  height: calc(var(--h) - 9px);
  border: 1px solid rgba(255, 255, 255, 0.2);
  border-radius: 9999px;
  filter: blur(1px);
}

.uiverse-box.start-btn {
  padding: 0 0.8rem;
  transition: 0.25s;
}

.uiverse-box.start-btn .text {
  font-size: 16px;
  font-weight: 600;
  color: #fff;
  z-index: 510;
  margin-right: 1rem;
}

.uiverse-box.start-btn .btn-icon {
  display: flex;
  justify-content: center;
  align-items: center;
  transition: 0.3s cubic-bezier(0.25, 0.8, 0.25, 1);
  z-index: 510;
}

.uiverse-box.start-btn .btn-icon .svg {
  width: 20px;
  fill: #fff;
}

.uiverse-box.start-btn:hover {
  background: rgba(0, 0, 0, 0);
  transform: translateY(-2px);
}

.uiverse-box.start-btn:hover .btn-icon {
  transform: translateX(4px);
}

.uiverse-box.start-btn:active {
  transform: scale(0.96);
}

.uiverse-box.start-btn:active .btn-icon {
  transform: scale(0.94);
}

/* Gooey Loader */
.loader {
  --c1: #683c14;
  --c2: #a26f48;
  --t: 2s;
  --size: 1.2;
  position: relative;
  width: 100px;
  height: 100px;
  border-radius: 50%;
  transform: scale(var(--size));
  box-shadow:
    0 0 25px 0 #ffbf4780,
    0 20px 50px 0 #bf4a1d80;
  animation: colorize calc(var(--t) * 3) ease-in-out infinite;
  overflow: hidden;
}

.loader::before {
  content: "";
  position: absolute;
  inset: 0;
  border-radius: 50%;
  border-top: 1px solid var(--c1);
  border-bottom: 1px solid var(--c2);
  background: linear-gradient(180deg, #ffbf4740, #bf4a1d80);
  box-shadow:
    inset 0 10px 10px 0 #ffbf4780,
    inset 0 -10px 10px 0 #bf4a1d80;
}

.loader-inner {
  position: absolute;
  inset: 0;
  border-radius: 50%;
  overflow: hidden;
  filter: url('data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg"><filter id="g"><feGaussianBlur in="SourceGraphic" stdDeviation="5"/><feColorMatrix values="1 0 0 0 0  0 1 0 0 0  0 0 1 0 0  0 0 0 22 -9"/></filter></svg>#g');
  -webkit-filter: url('data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg"><filter id="g"><feGaussianBlur in="SourceGraphic" stdDeviation="5"/><feColorMatrix values="1 0 0 0 0  0 1 0 0 0  0 0 1 0 0  0 0 0 22 -9"/></filter></svg>#g');
}

.blob {
  position: absolute;
  border-radius: 42%;
  background: linear-gradient(180deg, var(--c1) 30%, var(--c2) 70%);
}

.b1 { width: 44px; height: 44px; top: 12px; left: 28px; transform-origin: 50% 130%; animation: spin var(--t) linear infinite reverse; }
.b2 { width: 40px; height: 40px; top: 18px; left: 30px; transform-origin: 50% -30%; animation: spin var(--t) linear infinite; animation-delay: calc(var(--t) / -3); }
.b3 { width: 30px; height: 30px; top: 28px; left: 35px; transform-origin: -30% -10%; animation: spin var(--t) linear infinite reverse; }
.b4 { width: 28px; height: 28px; top: 30px; left: 36px; transform-origin: -30% -10%; animation: spin var(--t) linear infinite reverse; animation-delay: calc(var(--t) / -2); }
.b5 { width: 30px; height: 30px; top: 28px; left: 35px; transform-origin: 130% -10%; animation: spin var(--t) linear infinite; }
.b6 { width: 28px; height: 28px; top: 30px; left: 36px; transform-origin: 130% -10%; animation: spin var(--t) linear infinite; animation-delay: calc(var(--t) / -1.5); }

@keyframes spin {
  to { transform: rotate(360deg); }
}

@keyframes colorize {
  0% { filter: hue-rotate(0deg); }
  20% { filter: hue-rotate(-30deg); }
  40% { filter: hue-rotate(-60deg); }
  60% { filter: hue-rotate(-90deg); }
  80% { filter: hue-rotate(-45deg); }
  100% { filter: hue-rotate(0deg); }
}
`;

// Thành phần input tùy biến có hiệu ứng trượt cho label và viền
const FloatInput = ({ id, label, type, value, onChange, icon, ...props }: any) => {
  const [isFocused, setIsFocused] = useState(false);
  const isActive = isFocused || value.length > 0;

  return (
    <div className="relative w-full group">
      <motion.div
        animate={{
          y: isActive ? -22 : "-50%",
          scale: isActive ? 0.85 : 1,
          opacity: isActive ? 1 : 0.6,
        }}
        transition={{ duration: 0.2, ease: "easeOut" }}
        className="absolute left-4 top-1/2 pointer-events-none origin-left text-white drop-shadow-md z-10"
      >
        <Label htmlFor={id} className="font-medium cursor-text tracking-wide">{label}</Label>
      </motion.div>
      <div className="relative">
        <Input
          id={id}
          type={type}
          value={value}
          onChange={onChange}
          onFocus={() => setIsFocused(true)}
          onBlur={() => setIsFocused(false)}
          className={cn(
            "h-14 bg-white/5 border border-white/10 hover:bg-white/10 focus-visible:ring-0 focus-visible:bg-white/10 focus-visible:border-white/30 text-white rounded-2xl transition-all pt-5 backdrop-blur-lg shadow-[inset_0_1px_1px_rgba(255,255,255,0.05)]",
            icon && "pr-12"
          )}
          {...props}
        />
        {icon && (
          <div className="absolute right-3 top-1/2 -translate-y-1/2 z-10">
            {icon}
          </div>
        )}
      </div>
    </div>
  );
};

function LoginForm() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);

  // buttonState: 'idle' | 'loading' | 'success'
  const [buttonState, setButtonState] = useState<'idle' | 'loading' | 'success'>('idle');
  const [error, setError] = useState('');

  const { login } = useAuth();
  const router = useRouter();
  const searchParams = useSearchParams();

  const from = searchParams.get('from') || '/customers';

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    if (buttonState !== 'idle') return;

    setError('');
    setButtonState('loading');

    try {
      await login(email, password);
      setButtonState('success');
      
      router.push('/dashboard');
      
    } catch (err: any) {
      setError(err.message || 'Đăng nhập thất bại. Vui lòng thử lại.');
      setButtonState('idle');
    }
  };

  return (
    <main className="min-h-screen flex items-center justify-center relative overflow-hidden bg-black selection:bg-white/30">
      <style dangerouslySetInnerHTML={{ __html: uiverseStyles }} />

      {/* Nền hình ảnh (Cinematic Glass + Minimalist) */}
      <div
        className="absolute inset-0 bg-cover bg-center bg-no-repeat"
        style={{ backgroundImage: 'url("/bg-dang-nhap.webp")' }}
      >
      </div>

      {/* Ánh sáng Spotlight lờ mờ chiếu khu vực form */}
      <div className="absolute top-0 inset-x-0 h-[60%] w-full bg-[radial-gradient(ellipse_at_top,rgba(255,255,255,0.05),transparent_70%)] pointer-events-none" />

      <div className="w-full max-w-[420px] relative z-10 px-4 flex flex-col items-center">

        {/* Nhãn hiệu mượt mà */}
        <motion.div
          initial={{ opacity: 0, y: -20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6, delay: 0.1 }}
          className="flex flex-col items-center justify-center mb-8"
        >
          <img
            src="/Logo-Moutain-Farmers.png"
            alt="Mountain Farmers Logo"
            className="h-20 w-auto object-contain relative z-10 drop-shadow-[0_0_15px_rgba(255,255,255,0.1)]"
          />
        </motion.div>

        {/* Khối Form Glassmorphism Nhiều Lớp */}
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ duration: 0.8, delay: 0.1 }}
          className="relative w-full max-w-[420px] rounded-[2rem] transform-gpu"
        >
          {/* Lớp Kính Đáy (Tạo hiệu ứng vệt bóng dài và độ mờ nền sâu) */}
          <div className="absolute -inset-1 bg-white/5 backdrop-blur-3xl rounded-[2.2rem] border border-white/5 shadow-[0_16px_40px_0_rgba(0,0,0,0.2)] transform-gpu translate-y-2" />
          
          {/* Lớp Kính Giữa (Tạo độ dày hắt sáng ở viền trên/trái) */}
          <div className="absolute -inset-0.5 bg-gradient-to-br from-white/10 to-transparent backdrop-blur-xl rounded-[2.1rem] border border-t-white/30 border-l-white/20 border-r-white/5 border-b-white/5 transform-gpu" />

          {/* Lớp Form Kính Cuối Cùng */}
          <div className="relative bg-black/10 backdrop-blur-2xl rounded-[2rem] w-full h-full px-8 py-10 z-10 border border-white/10 shadow-[0_8px_32px_0_rgba(0,0,0,0.1)] overflow-hidden transform-gpu">
            
            {/* Phản quang mặt kính (Inner Glare) */}
            <div className="absolute top-0 left-0 right-0 h-1/2 bg-gradient-to-b from-white/10 to-transparent opacity-30 pointer-events-none" />

            <div className="mb-8 text-center space-y-2">
              <h1 className="text-2xl font-bold text-[#683c14] tracking-tight">Đăng nhập</h1>
              <p className="text-sm text-foreground/50 text-balance">Vui lòng đăng nhập để <br/>truy cập Mountain Farmer OMS</p>
            </div>

            <form onSubmit={handleLogin} className="space-y-6 flex flex-col items-center">
              <AnimatePresence mode="wait">
                {error && (
                  <motion.div
                    initial={{ opacity: 0, height: 0, scale: 0.95 }}
                    animate={{ opacity: 1, height: 'auto', scale: 1 }}
                    exit={{ opacity: 0, height: 0, scale: 0.95 }}
                    className="w-full"
                  >
                    <div className="p-3 bg-red-500/10 text-red-400 text-sm rounded-lg flex items-center gap-2 border border-red-500/20">
                      <div className="h-2 w-2 rounded-full bg-red-400 shrink-0" />
                      {error}
                    </div>
                  </motion.div>
                )}
              </AnimatePresence>

              <FloatInput
                id="email"
                type="email"
                label="Địa chỉ email"
                value={email}
                onChange={(e: any) => setEmail(e.target.value)}
                disabled={buttonState !== 'idle'}
                required
              />

              <FloatInput
                id="password"
                type={showPassword ? 'text' : 'password'}
                label="Mật khẩu"
                value={password}
                onChange={(e: any) => setPassword(e.target.value)}
                disabled={buttonState !== 'idle'}
                required
                icon={
                  <button
                    type="button"
                    className="text-white/40 hover:text-white transition-colors p-1"
                    onClick={() => setShowPassword(!showPassword)}
                    disabled={buttonState !== 'idle'}
                  >
                    {/* Reveal Password Animation */}
                    <AnimatePresence mode="popLayout" initial={false}>
                      <motion.div
                        key={showPassword ? 'eye-off' : 'eye'}
                        initial={{ opacity: 0, scale: 0.5, rotate: -45, y: -10 }}
                        animate={{ opacity: 1, scale: 1, rotate: 0, y: 0 }}
                        exit={{ opacity: 0, scale: 0.5, rotate: 45, y: 10 }}
                        transition={{ duration: 0.2, ease: "backOut" }}
                      >
                        {showPassword ? <EyeOff size={18} /> : <Eye size={18} />}
                      </motion.div>
                    </AnimatePresence>
                  </button>
                }
              />

              {/* Nút Đăng nhập Uiverse */}
              <div className="login-btn-container fx-layer mt-6">
                <button
                  type="submit"
                  disabled={buttonState !== 'idle'}
                  className="uiverse-box start-btn"
                  style={{ '--w': '100%', '--h': '60px', '--tr': '15%' } as any}
                >
                  <span className="text">
                    {buttonState === 'loading' ? 'Đang xử lý...' : 'Đăng nhập'}
                  </span>
                  <div className="btn-icon">
                    {buttonState === 'loading' ? (
                      <Loader2 className="w-5 h-5 animate-spin text-white" />
                    ) : (
                      <svg className="svg" viewBox="0 0 1024 1024" version="1.1" xmlns="http://www.w3.org/2000/svg">
                        <path d="M779.180132 473.232045 322.354755 16.406668c-21.413706-21.413706-56.121182-21.413706-77.534887 0-21.413706 21.413706-21.413706 56.122205 0 77.534887l418.057421 418.057421L244.819868 930.057421c-21.413706 21.413706-21.413706 56.122205 0 77.534887 10.706853 10.706853 24.759917 16.059767 38.767955 16.059767s28.061103-5.353938 38.767955-16.059767L779.180132 550.767955C800.593837 529.35425 800.593837 494.64575 779.180132 473.232045z"></path>
                      </svg>
                    )}
                  </div>
                  <div className="circle-overlay"></div>
                </button>
              </div>
            </form>

            <div className="mt-8 pt-6 border-t border-white/5 text-center">
              <p className="text-xs text-[#683c14] text-center w-full font-medium">
                Hệ thống phát triển bởi © {new Date().getFullYear()} the. POKALAB
              </p>
            </div>
          </div>
        </motion.div>
      </div>

    </main>
  );
}

// Bọc vào Suspense boundary vì dùng useSearchParams
export default function LoginPage() {
  return (
    <Suspense fallback={
      <div
        className="min-h-screen flex items-center justify-center bg-cover bg-center bg-no-repeat relative bg-black"
        style={{ backgroundImage: 'url("/bg-dang-nhap.webp")' }}
      >
        <Loader2 className="animate-spin text-white/50 w-8 h-8 relative z-10" />
      </div>
    }>
      <LoginForm />
    </Suspense>
  );
}
