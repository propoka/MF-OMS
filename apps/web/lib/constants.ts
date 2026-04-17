export const ORDER_STATUS_CONFIG: Record<
  string,
  { label: string; badge: string; dot: string; color: string }
> = {
  ALL: {
    label: "Tất cả trạng thái",
    badge: "bg-gray-500/10 text-gray-600 border-gray-500/20",
    dot: "bg-gray-800",
    color: "#1f2937",
  },
  PENDING: {
    label: "Chờ xác nhận",
    badge: "bg-gray-500/10 text-gray-600 border-gray-500/20",
    dot: "bg-gray-500",
    color: "#6b7280",
  },
  PROCESSING: {
    label: "Đang xử lý",
    badge: "bg-indigo-500/10 text-indigo-600 border-indigo-500/20",
    dot: "bg-indigo-500",
    color: "#6366f1",
  },
  SHIPPING: {
    label: "Đang giao",
    badge: "bg-blue-500/10 text-blue-600 border-blue-500/20",
    dot: "bg-blue-500",
    color: "#3b82f6",
  },
  COMPLETED: {
    label: "Hoàn thành",
    badge: "bg-emerald-500/10 text-emerald-700 border-emerald-500/20",
    dot: "bg-emerald-500",
    color: "#10b981",
  },
  RETURNED: {
    label: "Hoàn trả",
    badge: "bg-orange-500/10 text-orange-700 border-orange-500/20",
    dot: "bg-orange-500",
    color: "#f97316",
  },
  CANCELLED: {
    label: "Đã Huỷ",
    badge: "bg-red-500/10 text-red-700 border-red-500/20",
    dot: "bg-red-500",
    color: "#ef4444",
  },
};

export const getStatusBadgeVariant = (status: string) =>
  ORDER_STATUS_CONFIG[status]?.badge || ORDER_STATUS_CONFIG["PENDING"].badge;

export const formatStatusText = (status: string) =>
  ORDER_STATUS_CONFIG[status]?.label || ORDER_STATUS_CONFIG["PENDING"].label;
