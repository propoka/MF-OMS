import * as React from "react"
import { Card, CardHeader, CardTitle, CardContent } from "@/components/ui/card"
import { cn } from "@/lib/utils"

interface GlassCardProps {
  title?: React.ReactNode
  description?: React.ReactNode
  headerAction?: React.ReactNode
  children: React.ReactNode
  className?: string
  contentClassName?: string
  headerClassName?: string
}

export function GlassCard({
  title,
  description,
  headerAction,
  children,
  className,
  contentClassName,
  headerClassName,
}: GlassCardProps) {
  return (
    <Card
      className={cn(
        "border border-border/40 shadow-sm rounded-[32px] bg-white/40 backdrop-blur-lg overflow-hidden",
        className
      )}
    >
      {(title || description || headerAction) && (
        <CardHeader
          className={cn(
            "pb-4 pt-6 px-6 lg:px-8 flex flex-row items-center justify-between gap-4 flex-wrap",
            headerClassName
          )}
        >
          <div className="space-y-1">
            {title && (
              <CardTitle className="text-base font-semibold text-foreground flex items-center">
                {title}
              </CardTitle>
            )}
            {description && (
              <p className="text-xs text-muted-foreground mt-1">{description}</p>
            )}
          </div>
          {headerAction && <div className="shrink-0">{headerAction}</div>}
        </CardHeader>
      )}
      <CardContent className={cn("p-0", contentClassName)}>
        {children}
      </CardContent>
    </Card>
  )
}
