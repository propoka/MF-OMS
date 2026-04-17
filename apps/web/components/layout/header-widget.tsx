'use client';

import { motion } from 'framer-motion';

export const HeaderWidget = ({ growthRate }: { growthRate?: number }) => {
  const isPositive = (growthRate ?? 0) >= 0;
  const formattedRate = growthRate !== undefined 
    ? `${isPositive ? '+' : ''}${growthRate.toFixed(1)}%` 
    : 'N/A';
    
  return (
    <div className="relative hidden md:flex flex-col items-end pr-0 py-1 select-none">
      {/* 1. Tọa độ thực của Kon Tum - Cảm giác Mission Control */}
      <div className="flex items-center gap-2 text-[10px] font-light tracking-[0.2em] text-muted-foreground/50 uppercase">
        14.3456° N • 107.9745° E • Alt: 780m
      </div>

      {/* 2. Nhịp thở doanh thu (SVG Line) */}
      <div className="relative h-8 w-56 mt-0.5 overflow-hidden">
        <svg viewBox="0 0 200 40" className="absolute inset-0 w-full h-full" preserveAspectRatio="none">
          <motion.path
            d="M -50 20 Q -25 5, 0 20 T 50 20 T 100 20 T 150 20 T 200 20 T 250 20" 
            fill="none"
            stroke="url(#mountainGradient)"
            strokeWidth="1.5"
            strokeLinecap="round"
            initial={{ pathLength: 0, opacity: 0 }}
            animate={{ 
              pathLength: 1, 
              opacity: 1,
              x: [0, -40, 0] // Sóng di chuyển qua lại nhẹ nhàng
            }}
            transition={{ duration: 6, repeat: Infinity, ease: "easeInOut" }}
          />
          <defs>
            <linearGradient id="mountainGradient" x1="0%" y1="0%" x2="100%" y2="0%">
              <stop offset="0%" stopColor="transparent" />
              <stop offset="50%" stopColor="oklch(0.40 0.06 45)" /> {/* Tông màu Primary Đất của dự án */}
              <stop offset="100%" stopColor="transparent" />
            </linearGradient>
          </defs>
        </svg>
        
        {/* 3. Lớp sương mù che 2 viền (Glassmorphism Overlay) */}
        <div className="absolute inset-0 bg-gradient-to-r from-[#faf9f8] via-transparent to-[#faf9f8] pointer-events-none" />
      </div>

      {/* 4. Text ẩn hiện (Metadata) */}
      <motion.span 
        initial={{ opacity: 0, y: 5 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.5, duration: 1 }}
        className="relative z-10 text-[10px] text-muted-foreground font-medium mt-[-6px]"
      >
        So với hôm qua: <span className={isPositive ? "text-emerald-600 font-semibold" : "text-rose-500 font-semibold"}>{formattedRate}</span>
      </motion.span>
    </div>
  );
};
