# Data Verification Checklist

## 1. Seed va Du Lieu Nen
- [ ] Co it nhat 1 `ADMIN`, 1 `STAFF`, 1 user inactive.
- [ ] Co `customer_group` mac dinh (`isDefault = true`).
- [ ] Co it nhat 1 nhom `FIXED` va 1 nhom `PERCENTAGE`.
- [ ] Co it nhat 1 customer co `special price`.
- [ ] Co it nhat 1 `cancel_reason` dang active.
- [ ] Co `company_settings` duy nhat va hop le.

## 2. Customer / CRM
- [ ] `customers.groupId` luon tro toi `customer_groups.id` hop le.
- [ ] Khong co `phone` trung lap ngoai tru gia tri `NULL`.
- [ ] Khong co `code` trung lap.
- [ ] Customer da co order thi khong bi xoa cung.
- [ ] Tong doanh thu customer trong UI = tong `orders.totalAmount` khong tinh `CANCELLED`, `RETURNED`.

### SQL doi chieu goi y
```sql
select c.id, c.full_name, coalesce(sum(o.total_amount), 0) as expected_revenue
from customers c
left join orders o on o.customer_id = c.id
  and o.delivery_status not in ('CANCELLED', 'RETURNED')
group by c.id, c.full_name
order by expected_revenue desc;
```

## 3. Product / Pricing
- [ ] Khong co `products.sku` trung lap.
- [ ] Product co `categoryId` hop le neu khong null.
- [ ] `product_group_prices` khong co duplicate `(productId, groupId)`.
- [ ] `customer_special_prices` khong co duplicate `(customerId, productId)`.
- [ ] Preview pricing phan anh dung uu tien `SPECIAL > GROUP > RETAIL`.
- [ ] Neu `treatBlankAsZero = false`, gia 0 trong bang gia khong duoc override gia retail.

### SQL doi chieu goi y
```sql
select p.sku, p.name, gp.group_id, gp.fixed_price
from product_group_prices gp
join products p on p.id = gp.product_id
order by p.sku, gp.group_id;
```

## 4. Orders
- [ ] Moi order co it nhat 1 `order_item`.
- [ ] `subtotal = sum(order_items.line_total)`.
- [ ] `totalAmount = subtotal - discountAmount + shippingFee`.
- [ ] Snapshot tren order/item khong doi khi sua master data customer/product.
- [ ] Status transition chi theo state machine da thiet ke.
- [ ] Order chi sua duoc khi `deliveryStatus = PENDING`.

### SQL doi chieu goi y
```sql
select
  o.id,
  o.order_number,
  o.subtotal,
  coalesce(sum(oi.line_total), 0) as recomputed_subtotal,
  o.discount_amount,
  o.shipping_fee,
  o.total_amount,
  coalesce(sum(oi.line_total), 0) - o.discount_amount + o.shipping_fee as recomputed_total
from orders o
left join order_items oi on oi.order_id = o.id
group by o.id
order by o.created_at desc;
```

## 5. Dashboard / Report
- [ ] `dashboard.kpis.revenue.total` = tong `orders.totalAmount` voi `COMPLETED`.
- [ ] `dashboard.kpis.orders.active` = dem `PENDING`, `PROCESSING`, `SHIPPING`.
- [ ] `report.summary.netRevenue` = tong `COMPLETED`.
- [ ] `report.summary.grossRevenue` khong tinh `CANCELLED`, `RETURNED`.
- [ ] `topCustomers` va `topProducts` chi tinh tren don `COMPLETED`.
- [ ] Filter ngay theo mui gio `+07:00` duoc doi chieu bang query DB.

### SQL doi chieu goi y
```sql
select coalesce(sum(total_amount), 0) as completed_revenue
from orders
where delivery_status = 'COMPLETED';
```

## 6. Audit Log
- [ ] Moi thao tac `POST/PATCH/DELETE` quan trong co ban ghi `audit_logs`.
- [ ] `entityType`, `entityId`, `action`, `userId`, `createdAt` khop request.
- [ ] `oldData` ton tai cho `UPDATE`, `DELETE`, `STATUS_CHANGE` khi co entity cu.
- [ ] `newData` phan anh ket qua sau thao tac.

### SQL doi chieu goi y
```sql
select action, entity_type, entity_id, user_email, created_at
from audit_logs
order by created_at desc
limit 50;
```

## 7. Import / Batch
- [ ] Import customers bo qua duplicate theo rule da thiet ke.
- [ ] Import products fallback category khi category code khong ton tai.
- [ ] Import orders bo qua dong loi va khong lam fail ca lo batch.
- [ ] So ban ghi duoc tao moi khop `successCount`/`importedCount`.
- [ ] Ghi chu, dia chi, shipping fee, discount duoc map dung sau import.
