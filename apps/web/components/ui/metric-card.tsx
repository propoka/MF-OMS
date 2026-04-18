import * as React from "react"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { cn } from "@/lib/utils"

export const METRIC_COLOR_MAP: Record<string, string> = {
  emerald: "bg-emerald-500/10 text-emerald-600",
  blue: "bg-blue-500/10 text-blue-600",
  orange: "bg-orange-500/10 text-orange-600",
  red: "bg-red-500/10 text-red-600",
  indigo: "bg-indigo-500/10 text-indigo-600",
  rose: "bg-rose-500/10 text-rose-600",
  yellow: "bg-yellow-500/10 text-yellow-600",
  violet: "bg-violet-500/10 text-violet-600",
  slate: "bg-slate-500/10 text-slate-600",
  primary: "bg-primary/10 text-primary",
}

export const METRIC_VALUE_COLOR_MAP: Record<string, string> = {
  emerald: "text-emerald-600",
  red: "text-red-500",
  slate: "text-foreground",
  primary: "text-foreground",
}

interface MetricCardProps {
  title: string
  value: React.ReactNode
  icon: React.ElementType
  color?: keyof typeof METRIC_COLOR_MAP
  className?: string
}

export function MetricCard({
  title,
  value,
  icon: Icon,
  color = "primary",
  className,
}: MetricCardProps) {
  return (
    <Card
      className={cn(
        "transition-all duration-300 hover:shadow-md border-none shadow-sm rounded-2xl bg-white",
        className
      )}
    >
      <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
        <CardTitle className="text-sm font-medium text-muted-foreground">{title}</CardTitle>
        <div
          className={cn(
            "p-[6px] rounded-full shrink-0",
            METRIC_COLOR_MAP[color] || METRIC_COLOR_MAP.primary
          )}
        >
          <Icon className="h-[18px] w-[18px]" strokeWidth={2} />
        </div>
      </CardHeader>
      <CardContent className="pb-6">
        <div className={cn("text-2xl font-bold tabular-nums tracking-tight break-words", METRIC_VALUE_COLOR_MAP[color] || "text-foreground")}>
          {value}
        </div>
      </CardContent>
    </Card>
  )
}
