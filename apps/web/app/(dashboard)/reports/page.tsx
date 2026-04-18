"use client";

import { useState, useEffect, useCallback } from "react";
import { dashboardApi, settingsApi, Order, CompanySettings } from "@/lib/api";
import { useAuth } from "@/lib/auth-context";
import {
  Card,
  CardContent,
  CardHeader,
  CardTitle,
  CardDescription,
} from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { Badge } from "@/components/ui/badge";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import {
  FileDown,
  Printer,
  Calendar as CalendarIcon,
  Loader2,
  RefreshCw,
  BarChart3,
  TrendingDown,
  Truck,
  Activity,
  Target,
  Percent,
  PackageOpen,
  Award,
  Filter,
  Search,
  ChevronDown,
  ArrowRight,
} from "lucide-react";
import {
  PieChart,
  Pie,
  Cell,
  Tooltip as RechartsTooltip,
  ResponsiveContainer,
  Sector,
} from "recharts";
import { motion } from "framer-motion";
import * as xlsx from "xlsx";
import { toast } from "sonner";
import Link from "next/link";

import { GenerativeAvatar } from "@/components/ui/generative-avatar";
import { ORDER_STATUS_CONFIG, getStatusBadgeVariant, formatStatusText } from "@/lib/constants";
import { OrderStatusBadge } from "@/components/ui/order-status-badge";
import { GlassCard } from "@/components/ui/glass-card";
import { MetricCard } from "@/components/ui/metric-card";

const DONUT_COLORS = [
  "#3b82f6",
  "#10b981",
  "#f59e0b",
  "#8b5cf6",
  "#ef4444",
  "#64748b",
];



const CustomDonutTooltip = ({ active, payload }: any) => {
  if (active && payload && payload.length) {
    const data = payload[0].payload;
    const valueStr = new Intl.NumberFormat("vi-VN", {
      style: "currency",
      currency: "VND",
    }).format(data.value);
    const dotColor = data.fill;
    const name = data.name;

    return (
      <div className="flex items-center gap-2 bg-background/95 backdrop-blur-md border border-border/50 py-1.5 px-3.5 rounded-full shadow-md">
        <span
          className="w-1.5 h-1.5 rounded-full shrink-0"
          style={{ backgroundColor: dotColor }}
        ></span>
        <span className="text-[11px] text-muted-foreground font-medium whitespace-nowrap">
          {name}
        </span>
        <span className="text-[10px] text-muted-foreground/40 font-light mx-0.5">
          —
        </span>
        <span className="text-[13px] font-semibold text-foreground tabular-nums tracking-tight whitespace-nowrap">
          {valueStr}
        </span>
      </div>
    );
  }
  return null;
};

export default function ReportsPage() {
  const { getToken } = useAuth();

  // Date State
  const [startDate, setStartDate] = useState<string>("");
  const [endDate, setEndDate] = useState<string>("");
  const [statusFilter, setStatusFilter] = useState<string>("ALL");
  const [activePreset, setActivePreset] = useState<string>("30days");

  // Data State
  const [reportData, setReportData] = useState<{
    summary: {
      totalOrders: number;
      completedOrdersCount: number;
      grossRevenue: number;
      netRevenue: number;
      totalShippingFee: number;
      totalDiscount: number;
      aov: number;
      cancelRate: number;
    };
    overview: {
      statusBreakdown: Record<string, { count: number; revenue: number }>;
      topCustomers: {
        name: string;
        phone: string;
        revenue: number;
        orderCount: number;
      }[];
      topProducts: {
        name: string;
        sku: string;
        revenue: number;
        sold: number;
      }[];
    };
    orders: Order[];
  } | null>(null);

  const [pieActiveIndex, setPieActiveIndex] = useState(0);

  const [company, setCompany] = useState<CompanySettings | null>(null);
  const [isLoading, setIsLoading] = useState(false);

  useEffect(() => {
    // init 30 days
    handlePreset("30days");
    fetchCompany();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const fetchCompany = async () => {
    try {
      const token = getToken();
      if (!token) return;
      const res = await settingsApi.getCompanySettings(token).catch(() => null);
      if (res) setCompany(res);
    } catch {}
  };

  const fetchReport = useCallback(
    async (start?: string, end?: string) => {
      try {
        setIsLoading(true);
        const s = start !== undefined ? start : startDate;
        const e = end !== undefined ? end : endDate;

        const token = getToken();
        if (!token) return;
        const res = await dashboardApi.getReport(token, s, e);
        setReportData(res);
      } catch (err: any) {
        toast.error(err.message || "Lỗi tải báo cáo");
      } finally {
        setIsLoading(false);
      }
    },
    [getToken, startDate, endDate],
  );

  const handlePreset = (type: string) => {
    setActivePreset(type);
    const todayDate = new Date();
    let s = new Date();
    let e = new Date();

    switch (type) {
      case "today":
        break; // today already
      case "yesterday":
        s.setDate(todayDate.getDate() - 1);
        e.setDate(todayDate.getDate() - 1);
        break;
      case "7days":
        s.setDate(todayDate.getDate() - 6);
        break;
      case "30days":
        s.setDate(todayDate.getDate() - 29);
        break;
      case "thisMonth":
        s = new Date(todayDate.getFullYear(), todayDate.getMonth(), 1);
        break;
      case "lastMonth":
        s = new Date(todayDate.getFullYear(), todayDate.getMonth() - 1, 1);
        e = new Date(todayDate.getFullYear(), todayDate.getMonth(), 0);
        break;
    }

    const formatLocal = (d: Date) => {
      const y = d.getFullYear();
      const m = String(d.getMonth() + 1).padStart(2, "0");
      const day = String(d.getDate()).padStart(2, "0");
      return `${y}-${m}-${day}`;
    };

    const startStr = formatLocal(s);
    const endStr = formatLocal(e);
    setStartDate(startStr);
    setEndDate(endStr);
    setStatusFilter("ALL");
    fetchReport(startStr, endStr);
  };

  const filteredOrders =
    reportData?.orders.filter(
      (o) => statusFilter === "ALL" || o.deliveryStatus === statusFilter,
    ) || [];

  const filteredSummary = reportData
    ? statusFilter === "ALL"
      ? reportData.summary
      : (() => {
          let gross = 0;
          let net = 0;
          let ship = 0;
          let disc = 0;
          let completed = 0;
          let canceled = 0;
          filteredOrders.forEach((o) => {
            const orderTotal = Number(o.totalAmount || 0);
            const combinedDisc =
              Number(o.discountAmount || 0) +
              (o.items?.reduce(
                (acc, i) => acc + Number(i.lineDiscount || 0),
                0,
              ) || 0);

            if (o.deliveryStatus === "COMPLETED") {
              completed++;
              net += orderTotal;
            }
            if (["CANCELLED", "RETURNED"].includes(o.deliveryStatus)) {
              canceled++;
            } else {
              gross += orderTotal;
              ship += Number(o.shippingFee || 0);
              disc += combinedDisc;
            }
          });
          return {
            totalOrders: filteredOrders.length,
            completedOrdersCount: completed,
            grossRevenue: gross,
            netRevenue: net,
            totalShippingFee: ship,
            totalDiscount: disc,
            aov: completed > 0 ? net / completed : 0,
            cancelRate:
              filteredOrders.length > 0
                ? (canceled / filteredOrders.length) * 100
                : 0,
          };
        })()
    : null;

  const formatMoney = (amount: number) => {
    return new Intl.NumberFormat("vi-VN", {
      style: "currency",
      currency: "VND",
    }).format(amount);
  };

  const exportExcel = () => {
    if (!reportData || !filteredSummary) return;

    // Sheet 1: Summary
    const summaryData = [
      {
        Mục: "Khoảng thời gian",
        "Giá trị": `${startDate || "Tất cả"} đến ${endDate || "Tất cả"}`,
      },
      {
        Mục: "Lọc trạng thái",
        "Giá trị":
          statusFilter === "ALL"
            ? "Tất cả trạng thái"
            : formatStatusText(statusFilter),
      },
      {
        Mục: "Tổng Doanh Thu Gộp (Gross)",
        "Giá trị": Number(filteredSummary.grossRevenue || 0),
      },
      {
        Mục: "Doanh Thu Thực Nhận (Net)",
        "Giá trị": Number(filteredSummary.netRevenue || 0),
      },
      {
        Mục: "Tổng Số Đơn Hàng",
        "Giá trị": Number(filteredSummary.totalOrders || 0),
      },
      {
        Mục: "Giá Trị Tiêu Dùng Trung Bình (AOV)",
        "Giá trị": Number(filteredSummary.aov || 0),
      },
      {
        Mục: "Tỷ Lệ Huỷ / Hoàn (%)",
        "Giá trị": Number((filteredSummary.cancelRate || 0).toFixed(2)),
      },
      {
        Mục: "Tổng Phí Vận Chuyển",
        "Giá trị": Number(filteredSummary.totalShippingFee || 0),
      },
      {
        Mục: "Tổng Chiết Khấu / Giảm giá",
        "Giá trị": Number(filteredSummary.totalDiscount || 0),
      },
    ];

    const statusDataArray = Object.keys(
      reportData.overview?.statusBreakdown || {},
    ).map((k) => ({
      "Trạng thái": formatStatusText(k),
      "Số lượng": Number(reportData.overview.statusBreakdown[k].count || 0),
      "Doanh thu tương ứng": Number(
        reportData.overview.statusBreakdown[k].revenue || 0,
      ),
    }));

    // Sheet 3: Details (Order Lines - Flattened by Products)
    const detailsData: any[] = [];
    filteredOrders.forEach((o) => {
      const phoneStr = o.snapshotCustomerPhone
        ? String(o.snapshotCustomerPhone)
        : "";
      if (!o.items || o.items.length === 0) {
        // Fallback for orders without items
        detailsData.push({
          "Mã Đơn": o.orderNumber,
          "Ngày tạo": new Date(o.createdAt).toLocaleString("vi-VN"),
          "Trạng thái": formatStatusText(o.deliveryStatus),
          "Khách hàng": o.snapshotCustomerName,
          SĐT: phoneStr,
          "Nhóm khách": o.customer?.group?.name || "Khách lẻ",
          SKU: "",
          "Tên SP": "",
          ĐVT: "",
          SL: 0,
          "Đơn giá bán": 0,
          "Chiết khấu dòng": 0,
          "Thành Tiền Dòng": 0,
          "Tổng tiền Hàng (Đơn)": Number(o.subtotal || 0),
          "Chiết khấu Đơn": Number(o.discountAmount || 0),
          "Phí Ship": Number(o.shippingFee || 0),
          "Thực thu": Number(o.totalAmount || 0),
          "Thu ngân": o.createdBy?.fullName || "",
          "Ghi chú": o.notes || "",
        });
      } else {
        o.items.forEach((i) => {
          detailsData.push({
            "Mã Đơn": o.orderNumber,
            "Ngày tạo": new Date(o.createdAt).toLocaleString("vi-VN"),
            "Trạng thái": formatStatusText(o.deliveryStatus),
            "Khách hàng": o.snapshotCustomerName,
            SĐT: phoneStr,
            "Nhóm khách": o.customer?.group?.name || "Khách lẻ",
            SKU: i.snapshotProductSku,
            "Tên SP": i.snapshotProductName,
            ĐVT: i.snapshotProductUnit || "",
            SL: Number(i.quantity || 0),
            "Đơn giá bán": Number(i.snapshotUnitPrice || 0),
            "Chiết khấu dòng": Number(i.lineDiscount || 0),
            "Thành Tiền Dòng": Number(i.lineTotal || 0),
            "Tổng tiền Hàng (Đơn)": Number(o.subtotal || 0),
            "Chiết khấu Đơn": Number(o.discountAmount || 0),
            "Phí Ship": Number(o.shippingFee || 0),
            "Thực thu": Number(o.totalAmount || 0),
            "Thu ngân": o.createdBy?.fullName || "",
            "Ghi chú": o.notes || "",
          });
        });
      }
    });

    const wb = xlsx.utils.book_new();
    const ws1 = xlsx.utils.json_to_sheet(summaryData);
    const ws2 = xlsx.utils.json_to_sheet(statusDataArray);
    const ws3 = xlsx.utils.json_to_sheet(detailsData);

    // Apply auto-width for some columns
    ws3["!cols"] = [
      { wch: 15 },
      { wch: 20 },
      { wch: 15 },
      { wch: 20 },
      { wch: 15 },
      { wch: 15 },
      { wch: 12 },
      { wch: 30 },
    ];

    xlsx.utils.book_append_sheet(wb, ws1, "1. Summary");
    xlsx.utils.book_append_sheet(wb, ws2, "2. Order Overview");
    xlsx.utils.book_append_sheet(wb, ws3, "3. Order Details");

    xlsx.writeFile(wb, `BaoCao_ERP_${startDate}_${endDate}.xlsx`);
    toast.success("Đã tải xuống file Excel phân tích đa chiều.");
  };

  const exportPdf = () => {
    window.print();
  };

  return (
    <div className="w-full">
      {/* =========================================================================
          MAIN APPLICATION LAYOUT (HIDDEN DURING PRINT)
          ========================================================================= */}
      <div className="flex flex-col gap-6 pb-10 print:hidden">
        {/* HEADER SECTION */}
        <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
          <div>
            <h1 className="text-3xl font-bold tracking-tight text-foreground flex items-center gap-2">
              Báo cáo bán hàng
            </h1>
          </div>
        </div>

        {/* KHU VỰC LỌC THÔNG MINH (ACTION DOCK) */}
        <GlassCard className="border border-white/40 shadow-sm shadow-black/5 rounded-[24px] bg-white/40 backdrop-blur-xl print:hidden overflow-hidden mb-6 p-2 flex flex-col xl:flex-row gap-3 items-center justify-between" contentClassName="p-0 flex flex-col xl:flex-row gap-3 items-center justify-between w-full border-none shadow-none bg-transparent">
          <div className="flex flex-col lg:flex-row gap-2 lg:gap-3 items-center w-full xl:w-auto">
            {/* Preset Quick Filters as Pills */}
            <div className="flex items-center bg-white/50 p-1 rounded-xl border border-white/40 shadow-sm shadow-black/5 h-11 w-full lg:w-auto overflow-x-auto custom-scrollbar relative">
              {[
                { id: "today", label: "Hôm nay" },
                { id: "yesterday", label: "Hôm qua" },
                { id: "7days", label: "7 ngày" },
                { id: "30days", label: "30 ngày" },
              ].map((preset) => (
                <button
                  key={preset.id}
                  onClick={() => handlePreset(preset.id)}
                  className={`relative h-full px-3.5 rounded-lg text-[13px] font-semibold tracking-tight transition-colors z-10 whitespace-nowrap ${
                    activePreset === preset.id
                      ? "text-foreground"
                      : "text-muted-foreground hover:text-foreground"
                  }`}
                >
                  {activePreset === preset.id && (
                    <motion.div
                      layoutId="activeFilterTab"
                      className="absolute inset-0 bg-white rounded-lg shadow-sm shadow-black/10"
                      transition={{
                        type: "spring",
                        stiffness: 400,
                        damping: 30,
                      }}
                      style={{ zIndex: -1 }}
                    />
                  )}
                  {preset.label}
                </button>
              ))}
            </div>

            {/* Date Range & Status - Pill Shape Integration */}
            <div className="flex items-center gap-2 lg:gap-3">
              {/* Unified Date Pill */}
              <div className="flex items-center bg-white/50 border border-white/40 rounded-xl shadow-sm shadow-black/5 h-11 divide-x divide-white/40 relative">
                <Input
                  type="date"
                  value={startDate}
                  onChange={(e) => {
                    setStartDate(e.target.value);
                    setActivePreset("custom");
                  }}
                  className="h-full px-3 w-[125px] md:w-[135px] lg:w-[140px] border-none bg-transparent shadow-none focus-visible:ring-0 text-[13px] font-medium tracking-tight text-foreground pr-1"
                />
                <div className="h-full px-2 text-muted-foreground/40 hidden md:flex items-center bg-transparent shrink-0">
                  <ChevronDown className="h-3 w-3 -rotate-90" />
                </div>
                <Input
                  type="date"
                  value={endDate}
                  onChange={(e) => {
                    setEndDate(e.target.value);
                    setActivePreset("custom");
                  }}
                  className="h-full px-3 w-[125px] md:w-[135px] lg:w-[140px] border-none bg-transparent shadow-none focus-visible:ring-0 text-[13px] font-medium tracking-tight text-foreground pl-1"
                />
              </div>

              <Select value={statusFilter} onValueChange={(val) => setStatusFilter(val || "ALL")}>
                <SelectTrigger className="w-[160px] md:w-[175px] lg:w-[185px] !h-11 bg-white/50 border-white/40 rounded-xl text-[13px] tracking-tight font-medium focus:ring-1 focus:ring-black/10 transition-all shadow-sm shadow-black/5">
                  <SelectValue placeholder="Trạng thái">
                    <div className="flex items-center gap-2">
                      {statusFilter === "ALL" ? (
                        <div className="w-2 h-2 rounded-full border border-muted-foreground/30 flex items-center justify-center">
                          <div className="w-1 h-1 rounded-full bg-muted-foreground/30"></div>
                        </div>
                      ) : (
                        <div
                          className={`w-2 h-2 rounded-full shadow-sm ${ORDER_STATUS_CONFIG[statusFilter]?.dot || "bg-gray-500"}`}
                        ></div>
                      )}
                      <span>
                        {ORDER_STATUS_CONFIG[statusFilter]?.label ||
                          "Tất cả trạng thái"}
                      </span>
                    </div>
                  </SelectValue>
                </SelectTrigger>
                <SelectContent className="rounded-[16px] p-2 shadow-2xl border-white/60 backdrop-blur-3xl bg-white/70">
                  {Object.keys(ORDER_STATUS_CONFIG).map((key) => (
                    <SelectItem
                      key={key}
                      value={key}
                      className="rounded-xl py-2.5 px-3 mb-1 focus:bg-white/80 focus:text-foreground last:mb-0 transition-all cursor-pointer data-[state=checked]:bg-white data-[state=checked]:shadow-sm data-[state=checked]:shadow-black/5 border border-transparent data-[state=checked]:border-white/60"
                    >
                      <div className="flex items-center gap-2.5">
                        {key === "ALL" ? (
                          <div className="w-2.5 h-2.5 rounded-full border border-muted-foreground/30 flex items-center justify-center">
                            <div className="w-1.5 h-1.5 rounded-full bg-muted-foreground/30"></div>
                          </div>
                        ) : (
                          <div
                            className={`w-2.5 h-2.5 rounded-full shadow-sm ${ORDER_STATUS_CONFIG[key].dot}`}
                          ></div>
                        )}
                        <span className="text-[13px] font-semibold tracking-tight text-foreground/80">
                          {ORDER_STATUS_CONFIG[key].label}
                        </span>
                      </div>
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>

              {/* Run Filter Action */}
              <Button
                onClick={() => fetchReport()}
                disabled={isLoading}
                className="h-11 w-11 p-0 rounded-xl bg-white/50 hover:bg-white backdrop-blur-md border border-white/40 text-foreground/70 hover:text-foreground shadow-sm shadow-black/5 transition-all hover:shadow-md hover:-translate-y-0.5 ml-1 flex-shrink-0"
              >
                {isLoading ? (
                  <Loader2 className="h-4 w-4 animate-spin" />
                ) : (
                  <Search className="h-4 w-4" strokeWidth={2} />
                )}
              </Button>
            </div>
          </div>

          {/* Ext Actions Dock */}
          <div className="flex items-center gap-1 p-1 flex-shrink-0 bg-white/50 border border-white/40 rounded-xl shadow-sm shadow-black/5 h-11 self-end xl:self-auto">
            <Button
              variant="ghost"
              size="sm"
              onClick={exportExcel}
              disabled={isLoading || !reportData}
              className="h-full px-2.5 rounded-lg text-muted-foreground hover:bg-white hover:text-emerald-600 transition-all group"
              title="Xuất Excel"
            >
              <FileDown
                className="h-4 w-4 group-hover:-translate-y-0.5 transition-transform"
                strokeWidth={2}
              />
            </Button>
            <div className="w-[1px] h-4 bg-white/50"></div>
            <Button
              variant="ghost"
              size="sm"
              onClick={() => window.print()}
              disabled={isLoading || !reportData}
              className="h-full px-2.5 rounded-lg text-muted-foreground hover:bg-white hover:text-blue-600 transition-all group"
              title="In Báo cáo"
            >
              <Printer
                className="h-4 w-4 group-hover:-translate-y-0.5 transition-transform"
                strokeWidth={2}
              />
            </Button>
          </div>
        </GlassCard>

        {/* KPI METRICS (Minimalist like Dashboard) */}
        {filteredSummary && (
          <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4 print:hidden mb-6">
            <MetricCard title="Tổng doanh thu" value={formatMoney(filteredSummary.grossRevenue || 0)} icon={Activity} color="primary" />
            <MetricCard title="Chiết khấu bán hàng" value={`-${formatMoney(filteredSummary.totalDiscount)}`} icon={TrendingDown} color="primary" />
            <MetricCard title="Doanh thu vận chuyển" value={`+${formatMoney(filteredSummary.totalShippingFee)}`} icon={Truck} color="primary" />
            <MetricCard title="Doanh thu thuần" value={formatMoney(filteredSummary.netRevenue || 0)} icon={Target} color="primary" />
            <MetricCard title="Tổng đơn khởi tạo" value={`${filteredSummary.totalOrders} đơn`} icon={PackageOpen} color="primary" />
            <MetricCard title="Đơn giao thành công" value={`${filteredSummary.completedOrdersCount} đơn`} icon={Award} color="emerald" />
            <MetricCard title="Tỷ lệ hoàn huỷ" value={`${(filteredSummary.cancelRate || 0).toFixed(1)}%`} icon={TrendingDown} color="red" />
            <MetricCard title="Giá trị trung bình đơn" value={formatMoney(filteredSummary.aov || 0)} icon={Percent} color="primary" />
          </div>
        )}

        {/* OVERVIEW SECTION (Organic Redesign) */}
        {reportData && (
          <GlassCard
            className="print:hidden mb-6"
            title={<>Tổng quan & Phân bổ kịch bản</>}
            description="Thống kê khối lượng giao dịch"
          >
            <div className="grid grid-cols-1 lg:grid-cols-4 divide-y lg:divide-y-0 lg:divide-x divide-border/40">
                {/* Cột 1: Recharts Donut */}
                <div className="p-6 flex flex-col lg:col-span-2">
                  <div className="space-y-1 mb-4 flex-shrink-0">
                    <h3 className="text-sm font-semibold tracking-tight flex items-center gap-2 text-foreground">
                      Tỷ trọng trạng thái
                    </h3>
                    <p className="text-[11px] text-muted-foreground">
                      Phân bổ doanh thu theo tiến độ đơn hàng
                    </p>
                  </div>
                  <div className="flex-1 flex items-center gap-8">
                    {/* Left: Shrinked Donut */}
                    <div className="relative w-[248px] h-[248px] shrink-0">
                      <ResponsiveContainer width="100%" height="100%">
                        <PieChart>
                          <Pie
                            data={Object.keys(
                              reportData.overview?.statusBreakdown || {},
                            )
                              .filter(
                                (k) =>
                                  reportData.overview.statusBreakdown[k].count >
                                  0,
                              )
                              .map((k) => ({
                                name: formatStatusText(k),
                                value:
                                  reportData.overview.statusBreakdown[k]
                                    .revenue,
                                count:
                                  reportData.overview.statusBreakdown[k].count,
                                rawStatus: k,
                                fill:
                                  ORDER_STATUS_CONFIG[k]?.color || "#6b7280",
                              }))}
                            cx="50%"
                            cy="50%"
                            innerRadius={82}
                            outerRadius={117}
                            paddingAngle={2}
                            dataKey="value"
                            stroke="none"
                            cornerRadius={4}
                            onMouseEnter={(_, index) =>
                              setPieActiveIndex(index)
                            }
                            activeShape={(props: any) => {
                              const {
                                cx,
                                cy,
                                innerRadius,
                                outerRadius,
                                startAngle,
                                endAngle,
                                fill,
                              } = props;
                              return (
                                <Sector
                                  cx={cx}
                                  cy={cy}
                                  innerRadius={innerRadius - 2}
                                  outerRadius={outerRadius + 6}
                                  startAngle={startAngle}
                                  endAngle={endAngle}
                                  fill={fill}
                                  cornerRadius={4}
                                />
                              );
                            }}
                          >
                            {Object.keys(
                              reportData.overview?.statusBreakdown || {},
                            ).map((entry, index) => (
                              <Cell key={`cell-${index}`} />
                            ))}
                          </Pie>
                          <RechartsTooltip
                            content={<CustomDonutTooltip />}
                            cursor={{ fill: "transparent" }}
                            wrapperStyle={{ zIndex: 100 }}
                          />
                        </PieChart>
                      </ResponsiveContainer>
                      <div className="absolute inset-0 flex flex-col items-center justify-center pointer-events-none mt-1 z-0">
                        <span className="text-[11px] font-semibold text-muted-foreground uppercase tracking-widest mb-0.5">
                          Tổng thu
                        </span>
                        <span className="text-lg font-black text-foreground">
                          {(() => {
                            const val = filteredSummary?.grossRevenue || 0;
                            if (val >= 1000000000)
                              return (val / 1000000000).toFixed(1) + " Tỏi";
                            if (val >= 1000000)
                              return (val / 1000000).toFixed(1) + " Tr";
                            return formatMoney(val);
                          })()}
                        </span>
                      </div>
                    </div>

                    {/* Right: Asymmetric Data Stack */}
                    <div className="flex-1 flex flex-col justify-center gap-1.5 pr-4">
                      {Object.keys(reportData.overview?.statusBreakdown || {})
                        .filter(
                          (k) =>
                            reportData.overview.statusBreakdown[k].count > 0,
                        )
                        .map((k) => {
                          const item = reportData.overview?.statusBreakdown[k];
                          if (!item) return null;
                          const total = filteredSummary?.grossRevenue || 1;
                          const pct = ((item.revenue / total) * 100).toFixed(1);
                          return (
                            <div
                              key={k}
                              className="flex justify-between items-center text-sm py-2 border-b border-border/20 last:border-0 group"
                            >
                              <div className="flex items-center gap-3">
                                <div
                                  className="w-2.5 h-2.5 rounded-[3px] shrink-0"
                                  style={{
                                    backgroundColor:
                                      ORDER_STATUS_CONFIG[k]?.color,
                                  }}
                                ></div>
                                <span className="text-[12px] font-medium text-foreground">
                                  {formatStatusText(k)}
                                </span>
                                <span className="text-[10px] text-muted-foreground bg-muted/60 px-1.5 py-[1px] rounded-md font-semibold">
                                  {item.count}
                                </span>
                              </div>
                              <div className="flex items-center gap-3 text-right">
                                <span className="text-[12px] font-bold text-foreground tabular-nums tracking-tight">
                                  {formatMoney(item.revenue)}
                                </span>
                                <span className="text-[11px] font-semibold w-10 text-right text-muted-foreground bg-muted/30 py-0.5 px-1 rounded-sm">
                                  {pct}%
                                </span>
                              </div>
                            </div>
                          );
                        })}
                    </div>
                  </div>
                </div>

                {/* Cột 2: Top 5 Đại lý */}
                <div className="p-6 flex flex-col items-stretch overflow-hidden lg:col-span-1">
                  <div className="space-y-1 mb-4 flex-shrink-0">
                    <h3 className="text-sm font-semibold tracking-tight flex items-center gap-2 text-foreground">
                      Top 5 Đại lý
                    </h3>
                    <p className="text-[11px] text-muted-foreground">
                      Khách hàng đóng góp cao nhất
                    </p>
                  </div>
                  <div className="flex-1 overflow-y-auto custom-scrollbar">
                    {!reportData.overview?.topCustomers ||
                    reportData.overview.topCustomers.length === 0 ? (
                      <p className="text-sm text-muted-foreground px-3">
                        Chưa có dữ liệu
                      </p>
                    ) : null}
                    <ul className="flex flex-col gap-1">
                      {(reportData.overview?.topCustomers || [])
                        .slice(0, 5)
                        .map((c, idx) => {
                          const maxVal = Math.max(
                            ...reportData.overview.topCustomers
                              .slice(0, 5)
                              .map((x) => x.revenue),
                            1,
                          );
                          const pct = (c.revenue / maxVal) * 100;
                          return (
                            <li
                              key={`top-customer-${idx}`}
                              className="p-2.5 rounded-xl flex gap-3 items-center"
                            >
                              <div className="relative shrink-0">
                                <GenerativeAvatar
                                  name={c.name || "User"}
                                  size={40}
                                />
                                <div className="absolute -left-1.5 -top-1.5 w-[18px] h-[18px] bg-background font-bold text-[9px] rounded-full flex items-center justify-center border border-border/80 shadow-sm text-muted-foreground">
                                  #{idx + 1}
                                </div>
                              </div>
                              <div className="flex flex-col flex-1 min-w-0">
                                <div className="flex justify-between items-center mb-1">
                                  <span className="font-semibold text-[13px] text-foreground truncate pr-2 leading-tight">
                                    {c.name}
                                  </span>
                                  <span className="font-bold text-[oklch(0.40_0.06_45)] text-[13px] tabular-nums tracking-tight whitespace-nowrap">
                                    {formatMoney(c.revenue)}
                                  </span>
                                </div>
                                <div className="flex items-center gap-2">
                                  <span className="px-1.5 py-0.5 bg-muted text-muted-foreground rounded text-[9px] font-semibold">
                                    {c.orderCount
                                      ? `${c.orderCount} đơn`
                                      : c.phone || ""}
                                  </span>
                                  <div className="flex-1 h-1.5 bg-muted/60 rounded-full overflow-hidden">
                                    <div
                                      className="h-full bg-[oklch(0.40_0.06_45)]/80 rounded-full"
                                      style={{ width: `${pct}%` }}
                                    />
                                  </div>
                                </div>
                              </div>
                            </li>
                          );
                        })}
                    </ul>
                  </div>
                </div>

                {/* Cột 3: Top 5 Sản phẩm */}
                <div className="p-6 flex flex-col items-stretch overflow-hidden lg:col-span-1">
                  <div className="space-y-1 mb-4 flex-shrink-0">
                    <h3 className="text-sm font-semibold tracking-tight flex items-center gap-2 text-foreground">
                      Top 5 Sản phẩm bán chạy
                    </h3>
                    <p className="text-[11px] text-muted-foreground">
                      Mặt hàng dẫn đầu doanh thu
                    </p>
                  </div>
                  <div className="flex-1 overflow-y-auto custom-scrollbar">
                    {!reportData.overview?.topProducts ||
                    reportData.overview.topProducts.length === 0 ? (
                      <p className="text-sm text-muted-foreground px-3">
                        Chưa có dữ liệu
                      </p>
                    ) : null}
                    <ul className="flex flex-col gap-1">
                      {(reportData.overview?.topProducts || [])
                        .slice(0, 5)
                        .map((p, idx) => {
                          const maxVal = Math.max(
                            ...reportData.overview.topProducts
                              .slice(0, 5)
                              .map((x) => x.revenue),
                            1,
                          );
                          const pct = (p.revenue / maxVal) * 100;
                          return (
                            <li
                              key={`top-product-${idx}`}
                              className="p-2.5 rounded-xl flex gap-3 items-center"
                            >
                              <div className="relative shrink-0">
                                <GenerativeAvatar name={p.name} size={40} />
                                <div className="absolute -left-1.5 -top-1.5 w-[18px] h-[18px] bg-background font-bold text-[9px] rounded-full flex items-center justify-center border border-border/80 shadow-sm text-muted-foreground">
                                  #{idx + 1}
                                </div>
                              </div>
                              <div className="flex flex-col flex-1 min-w-0">
                                <div className="flex justify-between items-center mb-1">
                                  <span className="font-semibold text-[13px] text-foreground truncate pr-2 leading-tight">
                                    {p.name}
                                  </span>
                                  <span className="font-bold text-[oklch(0.40_0.06_45)] text-[13px] tabular-nums tracking-tight whitespace-nowrap">
                                    {formatMoney(p.revenue)}
                                  </span>
                                </div>
                                <div className="flex items-center gap-2">
                                  <span className="px-1.5 py-0.5 bg-muted text-muted-foreground rounded text-[9px] font-semibold">
                                    {p.sold} đã bán
                                  </span>
                                  <div className="flex-1 h-1.5 bg-muted/60 rounded-full overflow-hidden">
                                    <div
                                      className="h-full bg-[oklch(0.40_0.06_45)]/80 rounded-full"
                                      style={{ width: `${pct}%` }}
                                    />
                                  </div>
                                </div>
                              </div>
                            </li>
                          );
                        })}
                    </ul>
                  </div>
                </div>
              </div>
          </GlassCard>
        )}
      </div>

      {/* DATATABLE STANDARD */}
      {reportData && (
        <GlassCard
          className="print:hidden mb-10"
          title={<>Lịch sử đơn hàng
            {statusFilter !== "ALL" && (
              <Badge variant="outline" className="ml-3 font-medium text-muted-foreground bg-white/50 pb-0.5 border-border/40 rounded-full">
                {formatStatusText(statusFilter)}
              </Badge>
            )}</>}
          description={`Chi tiết ${filteredOrders.length} đơn hàng`}
          contentClassName="pb-4"
        >
            {filteredOrders.length === 0 ? (
              <div className="text-center py-16 text-muted-foreground text-[13px] font-medium">
                Không có giao dịch nào khớp với bộ lọc.
              </div>
            ) : (
              <div className="overflow-x-auto w-full custom-scrollbar">
                <Table className="w-full min-w-[900px]">
                  <TableHeader>
                    <TableRow className="hover:bg-transparent border-b border-border/30">
                      <TableHead className="w-[140px] text-[10px] font-medium uppercase tracking-widest text-muted-foreground pl-6 lg:pl-8 h-12 bg-muted/20">
                        THỜI GIAN
                      </TableHead>
                      <TableHead className="text-[10px] font-medium uppercase tracking-widest text-muted-foreground h-12 bg-muted/20">
                        MĐ
                      </TableHead>
                      <TableHead className="text-[10px] font-medium uppercase tracking-widest text-muted-foreground h-12 bg-muted/20">
                        KHÁCH HÀNG
                      </TableHead>
                      <TableHead className="text-[10px] font-medium uppercase tracking-widest text-muted-foreground min-w-[220px] h-12 bg-muted/20">
                        SẢN PHẨM
                      </TableHead>
                      <TableHead className="text-center text-[10px] font-medium uppercase tracking-widest text-muted-foreground h-12 bg-muted/20">
                        TRẠNG THÁI
                      </TableHead>
                      <TableHead className="text-right text-[10px] font-medium uppercase tracking-widest text-muted-foreground pr-6 lg:pr-8 h-12 bg-muted/20">
                        THỰC NHẬN
                      </TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {filteredOrders.map((o) => (
                      <TableRow
                        key={o.id}
                        className="cursor-pointer hover:bg-muted/40 transition-colors border-border/30 group"
                      >
                        <TableCell className="pl-6 lg:pl-8 py-4 align-top">
                          <div className="flex flex-col gap-1">
                            <span className="font-medium text-[13px] text-foreground tracking-tight whitespace-nowrap">
                              {new Date(o.createdAt).toLocaleDateString(
                                "vi-VN",
                                {
                                  day: "2-digit",
                                  month: "short",
                                  year: "numeric",
                                },
                              )}
                            </span>
                            <span className="text-[11px] text-muted-foreground font-medium">
                              {new Date(o.createdAt).toLocaleTimeString(
                                "vi-VN",
                                { hour: "2-digit", minute: "2-digit" },
                              )}
                            </span>
                          </div>
                        </TableCell>
                        <TableCell className="align-top py-4">
                          <Link href={`/orders/${o.id}`} className="group/link flex items-center gap-1 font-medium text-[13px] text-foreground hover:text-primary transition-colors whitespace-nowrap w-fit">
                            <span>
                              {o.orderNumber?.replace("ORD-", "") ||
                                o.orderNumber}
                            </span>
                            <ArrowRight className="w-3.5 h-3.5 opacity-0 -translate-x-2 group-hover/link:opacity-100 group-hover/link:translate-x-0 transition-all duration-300" />
                          </Link>
                        </TableCell>
                        <TableCell className="align-top py-4 max-w-[200px]">
                          <div className="flex flex-col gap-1">
                            <span className="font-medium text-[13px] text-foreground truncate pr-2">
                              {o.snapshotCustomerName}
                            </span>
                            <span className="text-[11px] text-muted-foreground font-medium">
                              {o.snapshotCustomerPhone ||
                                o.customer?.phone ||
                                "Khách lẻ"}
                            </span>
                          </div>
                        </TableCell>
                        <TableCell className="align-top py-4">
                          <div className="flex flex-col min-w-[220px] max-w-[250px] pr-4">
                            {o.items?.slice(0, 1).map((i) => (
                              <div
                                key={i.id}
                                className="flex justify-between items-center text-xs"
                              >
                                <span className="pr-3 font-medium text-foreground truncate">
                                  {i.snapshotProductName}
                                </span>
                                <span className="bg-muted text-muted-foreground px-1.5 py-0.5 rounded text-[10px] font-medium shrink-0">
                                  x{i.quantity}
                                </span>
                              </div>
                            ))}
                            {(o.items?.length || 0) > 1 && (
                              <span className="text-muted-foreground text-[10px] italic font-medium hover:text-primary transition-colors cursor-default mt-1">
                                (+ {o.items!.length - 1} mặt hàng khác)
                              </span>
                            )}
                          </div>
                        </TableCell>
                        <TableCell className="text-center align-top py-4">
                          <OrderStatusBadge status={o.deliveryStatus} className="mx-auto" />
                        </TableCell>
                        <TableCell className="text-right align-top py-4 pr-6 lg:pr-8">
                          <span className="font-bold text-[14px] text-[oklch(0.40_0.06_45)] tracking-tight whitespace-nowrap">
                            {formatMoney(o.totalAmount || 0)}
                          </span>
                        </TableCell>
                      </TableRow>
                    ))}
                  </TableBody>
                </Table>
              </div>
            )}
        </GlassCard>
      )}

      {/* =========================================================================
          HIDDEN PRINT LAYOUT (A4 OPTIMIZED - ENTERPRISE GRADE)
          ========================================================================= */}
      {reportData && (
        <div
          id="print-report"
          className="hidden print:block w-[210mm] text-black bg-white mx-auto print:absolute print:top-0 print:left-0"
          style={{ fontFamily: '"Inter", sans-serif', color: "black" }}
        >
          <style
            dangerouslySetInnerHTML={{
              __html: `
            @media print {
              @page { size: A4 portrait; margin: 15mm; }
              /* Force overflow visibility so multiple pages are created */
              html, body, #root, main, .overflow-hidden, .overflow-y-auto { 
                height: auto !important; 
                max-height: none !important; 
                overflow: visible !important; 
              }
              body { background: white !important; font-family: "Inter", sans-serif; -webkit-print-color-adjust: exact; print-color-adjust: exact; margin: 0; padding: 0; }
              
              /* Hide all components recursively globally up to html, except print-report */
              /* In Tailwind + Next.js, we rely on print:hidden classes added above */
              
              #print-report { 
                position: relative !important; 
                display: block !important;
                visibility: visible !important;
                width: 100% !important; 
              }
              .page-break { page-break-before: always; }
              table { border-collapse: collapse; width: 100%; border: 1px solid #111; }
              th, td { border: 1px solid #111; padding: 4px 6px; text-align: left; }
              th { background-color: #f3f4f6 !important; font-weight: bold; }
            }
          `,
            }}
          />

          {/* Header */}
          <div className="border-b-2 border-black pb-3 mb-4 flex justify-between items-start">
            <div className="w-1/2">
              <h2 className="text-sm font-black uppercase tracking-tight">
                {company?.name || "CỬA HÀNG MINH PHƯƠNG"}
              </h2>
              <p className="text-[10px] mt-0.5">
                ĐC: {company?.address || "Chưa cập nhật"}
              </p>
              <p className="text-[10px]">
                Hotline: {company?.phone || "Chưa cập nhật"}
              </p>
              <p className="text-[10px]">
                MST: {company?.taxCode || "Chưa cập nhật"}
              </p>
            </div>
            <div className="w-1/2 text-right">
              <h1 className="text-lg font-black uppercase tracking-widest text-black mb-0.5">
                Báo Cáo Quản Trị
              </h1>
              <p className="text-[12px] font-semibold">Doanh Thu & Giao Nhận</p>
              <p className="text-[9px] font-medium mt-1 uppercase text-gray-700">
                KỲ BÁO CÁO:{" "}
                {startDate
                  ? new Date(startDate).toLocaleDateString("vi-VN")
                  : "TẤT CẢ"}{" "}
                -{" "}
                {endDate
                  ? new Date(endDate).toLocaleDateString("vi-VN")
                  : "TẤT CẢ"}
              </p>
              {statusFilter !== "ALL" && (
                <p className="text-[9px] font-bold mt-0.5 uppercase text-black">
                  TRẠNG THÁI: {formatStatusText(statusFilter)}
                </p>
              )}
              <p className="text-[8px] mt-0.5">
                Ngày trích xuất: {new Date().toLocaleString("vi-VN")}
              </p>
            </div>
          </div>

          {/* PART 1: KPI SUMMARY */}
          {filteredSummary && (
            <div className="mb-5">
              <h3 className="font-bold text-[12px] mb-1.5 uppercase border-l-4 border-black pl-2">
                I. Tổng quan Chỉ số KPI{" "}
                {statusFilter !== "ALL" &&
                  `(Đã lọc theo: ${formatStatusText(statusFilter)})`}
              </h3>
              <table className="text-[11px]">
                <tbody>
                  <tr>
                    <td className="font-bold bg-gray-100" width="25%">
                      Doanh Thu Gộp (Gross)
                    </td>
                    <td className="font-black text-[13px]" width="25%">
                      {formatMoney(filteredSummary.grossRevenue || 0)}
                    </td>
                    <td className="font-bold bg-gray-100" width="25%">
                      Doanh Thu Thực Nhận (Net)
                    </td>
                    <td className="font-black text-[13px]" width="25%">
                      {formatMoney(filteredSummary.netRevenue || 0)}
                    </td>
                  </tr>
                  <tr>
                    <td className="font-semibold bg-gray-100">
                      Tổng Số Đơn Khởi Tạo
                    </td>
                    <td className="font-bold">
                      {filteredSummary.totalOrders} đơn
                    </td>
                    <td className="font-semibold bg-gray-100">
                      Số Đơn Hoạt Động Kín
                    </td>
                    <td className="font-bold">
                      {filteredSummary.completedOrdersCount} đơn
                    </td>
                  </tr>
                  <tr>
                    <td className="font-semibold bg-gray-100">
                      AOV (Trung bình / Đơn)
                    </td>
                    <td className="font-bold">
                      {formatMoney(filteredSummary.aov || 0)}
                    </td>
                    <td className="font-semibold bg-gray-100">
                      Tỷ lệ Huỷ / Hoàn
                    </td>
                    <td className="font-bold">
                      {(filteredSummary.cancelRate || 0).toFixed(2)}%
                    </td>
                  </tr>
                  <tr>
                    <td className="font-semibold bg-gray-100">
                      Tổng Phí Thu Hộ (Ship)
                    </td>
                    <td className="font-bold">
                      {formatMoney(filteredSummary.totalShippingFee)}
                    </td>
                    <td className="font-semibold bg-gray-100">
                      Tổng Chiết Khấu / Giảm giá
                    </td>
                    <td className="font-bold">
                      {formatMoney(filteredSummary.totalDiscount)}
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
          )}

          {/* PART 2: ORDER OVERVIEW */}
          <div className="mb-5 flex gap-6">
            <div className="w-1/2">
              <h3 className="font-bold text-[12px] mb-1.5 uppercase border-l-4 border-black pl-2">
                II. Phân bổ theo Trạng thái
              </h3>
              <table className="text-[10px]">
                <thead>
                  <tr>
                    <th className="w-[40%]">Trạng thái</th>
                    <th className="text-center w-[20%]">Số lượng</th>
                    <th className="text-right w-[40%]">Doanh Thu Tạm Tính</th>
                  </tr>
                </thead>
                <tbody>
                  {Object.keys(reportData.overview?.statusBreakdown || {}).map(
                    (k) => {
                      const d = reportData.overview.statusBreakdown[k];
                      return (
                        <tr key={k}>
                          <td className="font-semibold uppercase">
                            {formatStatusText(k)}
                          </td>
                          <td className="text-center">{d.count}</td>
                          <td className="text-right font-bold">
                            {formatMoney(d.revenue)}
                          </td>
                        </tr>
                      );
                    },
                  )}
                </tbody>
              </table>
            </div>

            <div className="w-1/2">
              <h3 className="font-bold text-[12px] mb-1.5 uppercase border-l-4 border-black pl-2">
                III. Top Đại Lý Trong Kỳ
              </h3>
              <table className="text-[10px]">
                <thead>
                  <tr>
                    <th className="w-[10%] text-center">Top</th>
                    <th className="w-[50%]">Khách Hàng</th>
                    <th className="text-right w-[40%]">Đóng Góp (Net)</th>
                  </tr>
                </thead>
                <tbody>
                  {!reportData.overview?.topCustomers ||
                    (reportData.overview.topCustomers.length === 0 && (
                      <tr>
                        <td colSpan={3} className="text-center">
                          Trống
                        </td>
                      </tr>
                    ))}
                  {(reportData.overview?.topCustomers || [])
                    .slice(0, 6)
                    .map((c, idx) => (
                      <tr key={`print-customer-${idx}`}>
                        <td className="text-center font-bold text-[10px]">
                          {idx + 1}
                        </td>
                        <td className="font-semibold leading-tight">
                          {c.name}
                          <br />
                          <span className="text-[9px] font-normal text-gray-600">
                            {c.phone}
                          </span>
                        </td>
                        <td className="text-right font-bold text-[11px]">
                          {formatMoney(c.revenue)}
                        </td>
                      </tr>
                    ))}
                </tbody>
              </table>
            </div>
          </div>

          {/* PART 3: ORDER DETAILS (PAGE BREAK) */}
          <div className="page-break">
            <h3 className="font-bold text-[12px] mb-1.5 uppercase border-l-4 border-black pl-2">
              IV. Bảng kê Chi Tiết Đơn Hàng
            </h3>
            <table className="w-full text-[9px]">
              <thead>
                <tr>
                  <th className="text-center w-[5%] font-bold">STT</th>
                  <th className="text-left w-[12%] font-bold">Mã / Ngày</th>
                  <th className="text-left w-[20%] font-bold">
                    Khách Hàng (SĐT)
                  </th>
                  <th className="text-left w-[36%] font-bold">
                    Tóm tắt Sản Phẩm
                  </th>
                  <th className="text-center w-[12%] font-bold">Trạng thái</th>
                  <th className="text-right w-[15%] font-bold">
                    Tổng Thanh Toán
                  </th>
                </tr>
              </thead>
              <tbody>
                {filteredOrders.length === 0 && (
                  <tr>
                    <td colSpan={6} className="text-center py-2">
                      Không có đơn hàng nào.
                    </td>
                  </tr>
                )}
                {filteredOrders.map((o, idx) => (
                  <tr key={o.id}>
                    <td className="text-center font-bold">{idx + 1}</td>
                    <td>
                      <div className="font-bold">{o.orderNumber}</div>
                      <div className="text-[9px]">
                        {new Date(o.createdAt).toLocaleDateString("vi-VN")}
                      </div>
                    </td>
                    <td>
                      <div className="font-bold">{o.snapshotCustomerName}</div>
                      <div className="text-[9px]">
                        {o.snapshotCustomerPhone}
                      </div>
                    </td>
                    <td className="leading-[1.4]">
                      {o.items?.map((i, iIdx) => (
                        <div key={i.id} className="mb-[2px]">
                          {iIdx + 1}. {i.snapshotProductName}{" "}
                          <span className="font-bold">x{i.quantity}</span>
                        </div>
                      ))}
                    </td>
                    <td className="text-center font-bold">
                      {formatStatusText(o.deliveryStatus)}
                    </td>
                    <td className="text-right font-black">
                      {formatMoney(o.totalAmount)}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>

          {/* SIGNATURES */}
          <div className="flex justify-between text-center pt-10 px-16 text-sm mb-6 avoid-break mt-6">
            <div>
              <p className="font-bold uppercase mb-14 text-[11px]">
                Lập bảng (Người xuất)
              </p>
              <p className="italic text-[9px] text-gray-500">
                (Ký & ghi rõ họ tên)
              </p>
            </div>
            <div>
              <p className="font-bold uppercase mb-14 text-[11px]">
                Giám đốc / Kế Toán Trưởng
              </p>
              <p className="italic text-[9px] text-gray-500">(Ký & đóng dấu)</p>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
