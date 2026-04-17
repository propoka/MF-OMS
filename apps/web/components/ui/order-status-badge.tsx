import { ORDER_STATUS_CONFIG, getStatusBadgeVariant, formatStatusText } from "@/lib/constants";
import { Badge } from "@/components/ui/badge";

export function OrderStatusBadge({ status, className }: { status: string; className?: string }) {
  const config = ORDER_STATUS_CONFIG[status] || ORDER_STATUS_CONFIG["PENDING"];
  return (
    <Badge
      variant="outline"
      className={`${getStatusBadgeVariant(status)} px-2.5 py-0.5 gap-1.5 font-medium uppercase tracking-wider text-[10px] ${className || ""}`}
    >
      <div
        className="w-1.5 h-1.5 rounded-full shadow-sm shrink-0"
        style={{ backgroundColor: config.color }}
      ></div>
      <span className="translate-y-[1px] leading-none">{formatStatusText(status)}</span>
    </Badge>
  );
}
