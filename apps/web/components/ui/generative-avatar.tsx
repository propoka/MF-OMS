import React from 'react';

const PALETTES = [
  ['#FFEDD5', '#F97316', '#C2410C'], // Orange/Terra
  ['#F3E8FF', '#A855F7', '#7E22CE'], // Purple/Amethyst
  ['#E0F2FE', '#0EA5E9', '#0369A1'], // Sky/Ocean
  ['#DCFCE7', '#22C55E', '#15803D'], // Green/Forest
  ['#FEF3C7', '#EAB308', '#A16207'], // Yellow/Gold
  ['#FFE4E6', '#F43F5E', '#BE123C'], // Rose/Crimson
  ['#FCE7F3', '#EC4899', '#BE185D'], // Pink/Magenta
];

export function GenerativeAvatar({ 
  name, 
  size = 40 
}: { 
  name: string; 
  size?: number; 
}) {
  // Simple deterministic string hash
  let hash = 0;
  for (let i = 0; i < name.length; i++) {
    hash = name.charCodeAt(i) + ((hash << 5) - hash);
  }
  
  // Pick palette
  const paletteIndex = Math.abs(hash) % PALETTES.length;
  const [bg, blob1, blob2] = PALETTES[paletteIndex];
  
  // Generate deterministic coordinates for the abstract blobs
  const cx1 = 20 + (Math.abs(hash * 2) % 60);
  const cy1 = 20 + (Math.abs(hash * 3) % 60);
  const r1  = 40 + (Math.abs(hash * 7) % 20); // 40-60

  const cx2 = 80 - (Math.abs(hash * 4) % 60);
  const cy2 = 80 - (Math.abs(hash * 5) % 60);
  const r2  = 35 + (Math.abs(hash * 11) % 25); // 35-60

  return (
    <svg 
      width={size} 
      height={size} 
      viewBox="0 0 100 100" 
      fill="none" 
      xmlns="http://www.w3.org/2000/svg" 
      className="rounded-full shadow-[inset_0_2px_4px_rgba(0,0,0,0.1)] shrink-0 transition-transform duration-300 hover:scale-105"
    >
      <mask id={`mask-${name}`}>
        <circle cx="50" cy="50" r="50" fill="white" />
      </mask>
      
      <g mask={`url(#mask-${name})`}>
        {/* Nền xốp nhạt */}
        <rect width="100" height="100" fill={bg} />
        
        {/* Các khối màu nước (Watercolor Blobs) loang lấp lánh */}
        <circle cx={cx1} cy={cy1} r={r1} fill={blob1} opacity="0.85" />
        <circle cx={cx2} cy={cy2} r={r2} fill={blob2} opacity="0.95" />
        
        {/* Khối sáng giả lập kính (Glass highlight) */}
        <path d="M 0 0 L 100 0 L 100 50 L 0 100 Z" fill="white" opacity="0.15" />
      </g>
      
      {/* Ký tự đầu tiên */}
      <text 
        x="50%" 
        y="50%" 
        dy=".05em"
        textAnchor="middle" 
        alignmentBaseline="middle"
        fill="#ffffff"
        fontSize="46"
        fontWeight="800"
        fontFamily="system-ui, sans-serif"
        style={{ 
          textShadow: '0px 2px 6px rgba(0,0,0,0.25)',
          letterSpacing: '-1px'
        }}
      >
        {name.charAt(0).toUpperCase()}
      </text>
    </svg>
  );
}
