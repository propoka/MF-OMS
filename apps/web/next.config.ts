import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  // Bản build độc lập — Docker image nhỏ ~150MB thay vì 1.5GB
  output: "standalone",

  // Ẩn header X-Powered-By (bảo mật)
  poweredByHeader: false,

  // Tối ưu tree-shaking cho các thư viện nặng
  experimental: {
    optimizePackageImports: [
      "@tabler/icons-react",
      "lucide-react",
      "recharts",
      "framer-motion",
    ],
  },

  // Tối ưu hình ảnh — tự động chuyển sang WebP/AVIF
  images: {
    formats: ["image/avif", "image/webp"],
  },
};

export default nextConfig;
