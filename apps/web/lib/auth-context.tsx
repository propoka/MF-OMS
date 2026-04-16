'use client';

import {
  createContext,
  useContext,
  useEffect,
  useState,
  useCallback,
  useRef,
  ReactNode,
} from 'react';
import { useRouter } from 'next/navigation';
import { authApi, User } from './api';

interface AuthState {
  user: User | null;
  accessToken: string | null;
  isLoading: boolean;     // true khi đang khởi tạo từ localStorage
  isAuthenticated: boolean;
}

interface AuthContextType extends AuthState {
  login: (email: string, password: string) => Promise<void>;
  logout: () => void;
  getToken: () => string | null;
}

const AuthContext = createContext<AuthContextType | null>(null);

const TOKEN_KEY = 'mf_access_token';
const REFRESH_KEY = 'mf_refresh_token';
const USER_KEY = 'mf_user';

// Decode JWT payload để lấy expiry (không verify, chỉ để schedule refresh)
function getTokenExpiry(token: string): number | null {
  try {
    const payload = JSON.parse(atob(token.split('.')[1]));
    return payload.exp ? payload.exp * 1000 : null;
  } catch {
    return null;
  }
}

export function AuthProvider({ children }: { children: ReactNode }) {
  const router = useRouter();
  const refreshTimerRef = useRef<ReturnType<typeof setTimeout> | null>(null);
  // Dùng ref để tránh stale closure trong scheduleTokenRefresh
  const routerRef = useRef(router);
  routerRef.current = router;

  const [state, setState] = useState<AuthState>({
    user: null,
    accessToken: null,
    isLoading: true, // Bắt đầu với isLoading=true cho đến khi đọc xong localStorage
    isAuthenticated: false,
  });

  // ── Auto Refresh ──────────────────────────────────────────────────────────
  const scheduleTokenRefresh = useCallback(function refreshAction(token: string) {
    // Clear timer cũ
    if (refreshTimerRef.current) {
      clearTimeout(refreshTimerRef.current);
      refreshTimerRef.current = null;
    }

    const expiry = getTokenExpiry(token);
    if (!expiry) return;

    // Refresh 60 giây trước khi hết hạn
    const delay = expiry - Date.now() - 60_000;

    const doRefresh = async () => {
      const storedRefresh = localStorage.getItem(REFRESH_KEY);
      if (!storedRefresh) return;
      try {
        const data = await authApi.refresh(storedRefresh);
        localStorage.setItem(TOKEN_KEY, data.accessToken);
        localStorage.setItem(REFRESH_KEY, data.refreshToken);
        document.cookie = `${TOKEN_KEY}=${data.accessToken}; path=/; max-age=604800; SameSite=Lax`;
        setState(prev => ({ ...prev, accessToken: data.accessToken }));
        // Schedule lần tiếp theo
        refreshAction(data.accessToken);
      } catch {
        // Refresh thất bại → clear session và về login
        localStorage.removeItem(TOKEN_KEY);
        localStorage.removeItem(REFRESH_KEY);
        localStorage.removeItem(USER_KEY);
        document.cookie = `${TOKEN_KEY}=; path=/; expires=Thu, 01 Jan 1970 00:00:00 GMT; SameSite=Lax`;
        setState({ user: null, accessToken: null, isLoading: false, isAuthenticated: false });
        routerRef.current.push('/login');
      }
    };

    if (delay <= 0) {
      // Đã hết hạn/sắp hết hạn → refresh ngay
      doRefresh();
    } else {
      refreshTimerRef.current = setTimeout(doRefresh, delay);
    }
  }, []);

  // ── Restore session khi mount ─────────────────────────────────────────────
  useEffect(() => {
    const token = localStorage.getItem(TOKEN_KEY);
    const userStr = localStorage.getItem(USER_KEY);

    if (token && userStr) {
      try {
        const user = JSON.parse(userStr) as User;
        setState({
          user,
          accessToken: token,
          isLoading: false,
          isAuthenticated: true,
        });
        // Schedule auto-refresh nếu token còn hạn
        scheduleTokenRefresh(token);
        return;
      } catch {
        // Data bị corrupt, clear đi
        localStorage.removeItem(TOKEN_KEY);
        localStorage.removeItem(REFRESH_KEY);
        localStorage.removeItem(USER_KEY);
      }
    }

    // Không có session hợp lệ
    setState(s => ({ ...s, isLoading: false }));
  }, []); // Chỉ chạy 1 lần khi mount — KHÔNG có dependencies

  // Cleanup timer khi unmount / Global 401 handler
  useEffect(() => {
    const handleUnauthorized = () => {
      if (refreshTimerRef.current) {
        clearTimeout(refreshTimerRef.current);
        refreshTimerRef.current = null;
      }
      localStorage.removeItem(TOKEN_KEY);
      localStorage.removeItem(REFRESH_KEY);
      localStorage.removeItem(USER_KEY);
      document.cookie = `${TOKEN_KEY}=; path=/; expires=Thu, 01 Jan 1970 00:00:00 GMT; SameSite=Lax`;
      setState({ user: null, accessToken: null, isLoading: false, isAuthenticated: false });
      routerRef.current.push('/login');
    };

    window.addEventListener('mf_unauthorized', handleUnauthorized);
    
    return () => {
      if (refreshTimerRef.current) clearTimeout(refreshTimerRef.current);
      window.removeEventListener('mf_unauthorized', handleUnauthorized);
    };
  }, []);

  // ── Login ─────────────────────────────────────────────────────────────────
  // Không router.push ở đây — để LoginPage tự handle redirect
  const login = useCallback(async (email: string, password: string) => {
    const data = await authApi.login(email, password);

    localStorage.setItem(TOKEN_KEY, data.accessToken);
    localStorage.setItem(REFRESH_KEY, data.refreshToken);
    localStorage.setItem(USER_KEY, JSON.stringify(data.user));
    document.cookie = `${TOKEN_KEY}=${data.accessToken}; path=/; max-age=604800; SameSite=Lax`;

    setState({
      user: data.user,
      accessToken: data.accessToken,
      isLoading: false,
      isAuthenticated: true,
    });

    scheduleTokenRefresh(data.accessToken);
  }, [scheduleTokenRefresh]); 

  // ── Logout ────────────────────────────────────────────────────────────────
  const logout = useCallback(async () => {
    if (refreshTimerRef.current) {
      clearTimeout(refreshTimerRef.current);
      refreshTimerRef.current = null;
    }

    // Call backend to revoke refresh token
    const currentToken = state.accessToken || localStorage.getItem(TOKEN_KEY);
    if (currentToken) {
      try {
        await authApi.logout(currentToken);
      } catch {
        // Ignore API error on logout
      }
    }

    localStorage.removeItem(TOKEN_KEY);
    localStorage.removeItem(REFRESH_KEY);
    localStorage.removeItem(USER_KEY);
    document.cookie = `${TOKEN_KEY}=; path=/; expires=Thu, 01 Jan 1970 00:00:00 GMT; SameSite=Lax`;

    setState({
      user: null,
      accessToken: null,
      isLoading: false,
      isAuthenticated: false,
    });

    routerRef.current.push('/login');
  }, [state.accessToken]); // Thêm dependency để lấy token hiện tại

  // ── getToken ──────────────────────────────────────────────────────────────
  const getToken = useCallback(() => {
    return state.accessToken || localStorage.getItem(TOKEN_KEY);
  }, [state.accessToken]);

  return (
    <AuthContext.Provider value={{ ...state, login, logout, getToken }}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const ctx = useContext(AuthContext);
  if (!ctx) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return ctx;
}
