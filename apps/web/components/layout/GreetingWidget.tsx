'use client';

import { useEffect, useState } from 'react';
import { useAuth } from '@/lib/auth-context';
import { 
  Sun, 
  CloudSun, 
  CloudFog, 
  CloudDrizzle, 
  CloudRain, 
  Snowflake, 
  CloudLightning, 
  Cloud,
  ThermometerSun
} from 'lucide-react';
import { cn } from '@/lib/utils';

function getWeatherMeta(code: number) {
  if (code === 0) return { Icon: Sun, color: 'text-amber-500', bg: 'bg-amber-500/10' };
  if ([1, 2, 3].includes(code)) return { Icon: CloudSun, color: 'text-orange-400', bg: 'bg-orange-400/10' };
  if ([45, 48].includes(code)) return { Icon: CloudFog, color: 'text-slate-400', bg: 'bg-slate-400/10' };
  if ([51, 53, 55, 56, 57].includes(code)) return { Icon: CloudDrizzle, color: 'text-blue-300', bg: 'bg-blue-300/10' };
  if ([61, 63, 65, 66, 67, 80, 81, 82].includes(code)) return { Icon: CloudRain, color: 'text-blue-500', bg: 'bg-blue-500/10' };
  if ([71, 73, 75, 77, 85, 86].includes(code)) return { Icon: Snowflake, color: 'text-sky-300', bg: 'bg-sky-300/10' };
  if ([95, 96, 99].includes(code)) return { Icon: CloudLightning, color: 'text-purple-500', bg: 'bg-purple-500/10' };
  return { Icon: Cloud, color: 'text-slate-500', bg: 'bg-slate-500/10' };
}

export function GreetingWidget() {
  const { user } = useAuth();
  const [greeting, setGreeting] = useState('Xin chào');
  const [currentDate, setCurrentDate] = useState('');
  const [weather, setWeather] = useState<{ temp: number; code: number } | null>(null);
  
  useEffect(() => {
    // 1. Tính toán câu chào theo giờ
    const now = new Date();
    const hour = now.getHours();
    if (hour >= 0 && hour < 11) setGreeting('Chào buổi sáng');
    else if (hour >= 11 && hour < 17) setGreeting('Chào buổi chiều');
    else setGreeting('Chào buổi tối');

    setCurrentDate(now.toLocaleDateString('vi-VN', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' }));

    // 2. Lấy thời tiết Kon Tum (Latitude: 14.3592, Longitude: 108.0069)
    async function fetchWeather() {
      try {
        // Cache API trong 30 phút để không gọi lại liên tục
        const CACHE_KEY = 'kon_tum_weather';
        const cached = sessionStorage.getItem(CACHE_KEY);
        
        if (cached) {
          const parsed = JSON.parse(cached);
          if (Date.now() - parsed.timestamp < 30 * 60 * 1000) {
            setWeather(parsed.data);
            return;
          }
        }

        const res = await fetch('https://api.open-meteo.com/v1/forecast?latitude=14.3592&longitude=108.0069&current=temperature_2m,weather_code');
        if (!res.ok) return;
        const data = await res.json();
        
        const weatherData = {
          temp: Math.round(data.current.temperature_2m),
          code: data.current.weather_code
        };
        
        setWeather(weatherData);
        sessionStorage.setItem(CACHE_KEY, JSON.stringify({
          data: weatherData,
          timestamp: Date.now()
        }));
      } catch (err) {
        console.error('Không thể lấy thời tiết', err);
      }
    }

    fetchWeather();
  }, []);

  const firstName = user?.fullName?.split(' ').pop() || user?.fullName || 'bạn';
  const meta = weather ? getWeatherMeta(weather.code) : null;
  const WeatherIcon = meta?.Icon || ThermometerSun;

  return (
    <div className="flex items-center gap-3 justify-end text-sm">
      <div className="text-muted-foreground">
        {greeting}, <span className="text-foreground font-semibold">{firstName}</span>!
      </div>
      
      {currentDate && (
        <>
          <div className="w-[1px] h-3.5 bg-border hidden sm:block" />
          <div className="text-muted-foreground hidden sm:block font-medium">
            {currentDate}
          </div>
        </>
      )}
      
      <div className="w-[1px] h-3.5 bg-border" />
      
      {weather ? (
        <div className="flex items-center gap-1.5 text-muted-foreground" title="Thời tiết hiện tại tại Kon Tum">
          <WeatherIcon className={cn("w-4 h-4", meta?.color)} />
          <span>Kon Tum {weather.temp}°C</span>
        </div>
      ) : (
        <div className="flex items-center gap-1.5 text-muted-foreground opacity-50">
          <ThermometerSun className="w-4 h-4" />
          <span className="w-16 h-4 bg-muted rounded animate-pulse inline-block" />
        </div>
      )}
    </div>
  );
}
