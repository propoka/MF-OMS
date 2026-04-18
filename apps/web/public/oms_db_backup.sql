--
-- PostgreSQL database dump
--

\restrict kc0mcub5i8OsoZTAKOMDeSG3MkgZbehVhNc2wVO6VVVdQ7TjqfYKBmaq9Xx1sFD

-- Dumped from database version 16.13
-- Dumped by pg_dump version 16.13

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: public; Type: SCHEMA; Schema: -; Owner: oms_user
--

-- *not* creating schema, since initdb creates it


ALTER SCHEMA public OWNER TO oms_user;

--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: oms_user
--

COMMENT ON SCHEMA public IS '';


--
-- Name: shadow; Type: SCHEMA; Schema: -; Owner: oms_user
--

CREATE SCHEMA shadow;


ALTER SCHEMA shadow OWNER TO oms_user;

--
-- Name: AuditAction; Type: TYPE; Schema: public; Owner: oms_user
--

CREATE TYPE public."AuditAction" AS ENUM (
    'CREATE',
    'UPDATE',
    'DELETE',
    'STATUS_CHANGE'
);


ALTER TYPE public."AuditAction" OWNER TO oms_user;

--
-- Name: GroupPriceType; Type: TYPE; Schema: public; Owner: oms_user
--

CREATE TYPE public."GroupPriceType" AS ENUM (
    'PERCENTAGE',
    'FIXED'
);


ALTER TYPE public."GroupPriceType" OWNER TO oms_user;

--
-- Name: OrderDeliveryStatus; Type: TYPE; Schema: public; Owner: oms_user
--

CREATE TYPE public."OrderDeliveryStatus" AS ENUM (
    'PENDING',
    'PROCESSING',
    'SHIPPING',
    'COMPLETED',
    'RETURNED',
    'CANCELLED'
);


ALTER TYPE public."OrderDeliveryStatus" OWNER TO oms_user;

--
-- Name: PriceSource; Type: TYPE; Schema: public; Owner: oms_user
--

CREATE TYPE public."PriceSource" AS ENUM (
    'SPECIAL',
    'GROUP',
    'RETAIL'
);


ALTER TYPE public."PriceSource" OWNER TO oms_user;

--
-- Name: Role; Type: TYPE; Schema: public; Owner: oms_user
--

CREATE TYPE public."Role" AS ENUM (
    'ADMIN',
    'STAFF'
);


ALTER TYPE public."Role" OWNER TO oms_user;

--
-- Name: AuditAction; Type: TYPE; Schema: shadow; Owner: oms_user
--

CREATE TYPE shadow."AuditAction" AS ENUM (
    'CREATE',
    'UPDATE',
    'DELETE',
    'STATUS_CHANGE'
);


ALTER TYPE shadow."AuditAction" OWNER TO oms_user;

--
-- Name: GroupPriceType; Type: TYPE; Schema: shadow; Owner: oms_user
--

CREATE TYPE shadow."GroupPriceType" AS ENUM (
    'PERCENTAGE',
    'FIXED'
);


ALTER TYPE shadow."GroupPriceType" OWNER TO oms_user;

--
-- Name: OrderDeliveryStatus; Type: TYPE; Schema: shadow; Owner: oms_user
--

CREATE TYPE shadow."OrderDeliveryStatus" AS ENUM (
    'PENDING',
    'PROCESSING',
    'SHIPPING',
    'COMPLETED',
    'RETURNED',
    'CANCELLED'
);


ALTER TYPE shadow."OrderDeliveryStatus" OWNER TO oms_user;

--
-- Name: PriceSource; Type: TYPE; Schema: shadow; Owner: oms_user
--

CREATE TYPE shadow."PriceSource" AS ENUM (
    'SPECIAL',
    'GROUP',
    'RETAIL'
);


ALTER TYPE shadow."PriceSource" OWNER TO oms_user;

--
-- Name: Role; Type: TYPE; Schema: shadow; Owner: oms_user
--

CREATE TYPE shadow."Role" AS ENUM (
    'ADMIN',
    'STAFF'
);


ALTER TYPE shadow."Role" OWNER TO oms_user;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: _prisma_migrations; Type: TABLE; Schema: public; Owner: oms_user
--

CREATE TABLE public._prisma_migrations (
    id character varying(36) NOT NULL,
    checksum character varying(64) NOT NULL,
    finished_at timestamp with time zone,
    migration_name character varying(255) NOT NULL,
    logs text,
    rolled_back_at timestamp with time zone,
    started_at timestamp with time zone DEFAULT now() NOT NULL,
    applied_steps_count integer DEFAULT 0 NOT NULL
);


ALTER TABLE public._prisma_migrations OWNER TO oms_user;

--
-- Name: audit_logs; Type: TABLE; Schema: public; Owner: oms_user
--

CREATE TABLE public.audit_logs (
    id text NOT NULL,
    "userId" text,
    "userEmail" text,
    action public."AuditAction" NOT NULL,
    "entityType" text NOT NULL,
    "entityId" text NOT NULL,
    "oldData" jsonb,
    "newData" jsonb,
    "ipAddress" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.audit_logs OWNER TO oms_user;

--
-- Name: cancel_reasons; Type: TABLE; Schema: public; Owner: oms_user
--

CREATE TABLE public.cancel_reasons (
    id text NOT NULL,
    label text NOT NULL,
    "isActive" boolean DEFAULT true NOT NULL,
    "sortOrder" integer DEFAULT 0 NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.cancel_reasons OWNER TO oms_user;

--
-- Name: company_settings; Type: TABLE; Schema: public; Owner: oms_user
--

CREATE TABLE public.company_settings (
    id text NOT NULL,
    name text NOT NULL,
    address text,
    phone text,
    email text,
    "taxCode" text,
    "logoUrl" text,
    "bankInfo" text,
    "invoiceFooter" text,
    "treatBlankAsZero" boolean DEFAULT false NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.company_settings OWNER TO oms_user;

--
-- Name: customer_groups; Type: TABLE; Schema: public; Owner: oms_user
--

CREATE TABLE public.customer_groups (
    id text NOT NULL,
    name text NOT NULL,
    description text,
    "priceType" public."GroupPriceType" DEFAULT 'PERCENTAGE'::public."GroupPriceType" NOT NULL,
    "discountPercent" double precision DEFAULT 0,
    "isDefault" boolean DEFAULT false NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.customer_groups OWNER TO oms_user;

--
-- Name: customer_special_prices; Type: TABLE; Schema: public; Owner: oms_user
--

CREATE TABLE public.customer_special_prices (
    id text NOT NULL,
    "customerId" text NOT NULL,
    "productId" text NOT NULL,
    price numeric(15,0) NOT NULL,
    notes text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.customer_special_prices OWNER TO oms_user;

--
-- Name: customers; Type: TABLE; Schema: public; Owner: oms_user
--

CREATE TABLE public.customers (
    id text NOT NULL,
    code text,
    phone text,
    "fullName" text NOT NULL,
    "groupId" text NOT NULL,
    "provinceCode" text,
    "provinceName" text,
    "wardCode" text,
    "wardName" text,
    "addressDetail" text,
    notes text,
    "isActive" boolean DEFAULT true NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.customers OWNER TO oms_user;

--
-- Name: order_items; Type: TABLE; Schema: public; Owner: oms_user
--

CREATE TABLE public.order_items (
    id text NOT NULL,
    "orderId" text NOT NULL,
    "productId" text NOT NULL,
    "snapshotProductName" text NOT NULL,
    "snapshotProductSku" text NOT NULL,
    "snapshotProductUnit" text NOT NULL,
    "snapshotUnitPrice" numeric(15,0) NOT NULL,
    "priceSource" public."PriceSource" NOT NULL,
    "pricingNote" text,
    quantity double precision NOT NULL,
    "lineDiscount" numeric(15,0) DEFAULT 0 NOT NULL,
    "lineTotal" numeric(15,0) NOT NULL
);


ALTER TABLE public.order_items OWNER TO oms_user;

--
-- Name: orders; Type: TABLE; Schema: public; Owner: oms_user
--

CREATE TABLE public.orders (
    id text NOT NULL,
    "orderNumber" text NOT NULL,
    "customerId" text NOT NULL,
    "snapshotCustomerName" text NOT NULL,
    "snapshotCustomerPhone" text,
    "createdById" text NOT NULL,
    "deliveryStatus" public."OrderDeliveryStatus" DEFAULT 'PENDING'::public."OrderDeliveryStatus" NOT NULL,
    subtotal numeric(15,0) NOT NULL,
    "discountAmount" numeric(15,0) DEFAULT 0 NOT NULL,
    "shippingFee" numeric(15,0) DEFAULT 0 NOT NULL,
    "totalAmount" numeric(15,0) NOT NULL,
    "cancelReasonId" text,
    "cancelNotes" text,
    notes text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.orders OWNER TO oms_user;

--
-- Name: product_categories; Type: TABLE; Schema: public; Owner: oms_user
--

CREATE TABLE public.product_categories (
    id text NOT NULL,
    name text NOT NULL,
    code text NOT NULL,
    description text,
    "isActive" boolean DEFAULT true NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.product_categories OWNER TO oms_user;

--
-- Name: product_group_prices; Type: TABLE; Schema: public; Owner: oms_user
--

CREATE TABLE public.product_group_prices (
    id text NOT NULL,
    "productId" text NOT NULL,
    "groupId" text NOT NULL,
    "fixedPrice" numeric(15,0),
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.product_group_prices OWNER TO oms_user;

--
-- Name: products; Type: TABLE; Schema: public; Owner: oms_user
--

CREATE TABLE public.products (
    id text NOT NULL,
    name text NOT NULL,
    sku text NOT NULL,
    "categoryId" text,
    unit text NOT NULL,
    "retailPrice" numeric(15,0) NOT NULL,
    "costPrice" numeric(15,0),
    weight double precision,
    dimensions text,
    "isActive" boolean DEFAULT true NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.products OWNER TO oms_user;

--
-- Name: users; Type: TABLE; Schema: public; Owner: oms_user
--

CREATE TABLE public.users (
    id text NOT NULL,
    email text NOT NULL,
    "passwordHash" text NOT NULL,
    "fullName" text NOT NULL,
    role public."Role" DEFAULT 'STAFF'::public."Role" NOT NULL,
    "isActive" boolean DEFAULT true NOT NULL,
    "refreshTokenHash" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.users OWNER TO oms_user;

--
-- Name: audit_logs; Type: TABLE; Schema: shadow; Owner: oms_user
--

CREATE TABLE shadow.audit_logs (
    id text NOT NULL,
    "userId" text,
    "userEmail" text,
    action shadow."AuditAction" NOT NULL,
    "entityType" text NOT NULL,
    "entityId" text NOT NULL,
    "oldData" jsonb,
    "newData" jsonb,
    "ipAddress" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE shadow.audit_logs OWNER TO oms_user;

--
-- Name: cancel_reasons; Type: TABLE; Schema: shadow; Owner: oms_user
--

CREATE TABLE shadow.cancel_reasons (
    id text NOT NULL,
    label text NOT NULL,
    "isActive" boolean DEFAULT true NOT NULL,
    "sortOrder" integer DEFAULT 0 NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE shadow.cancel_reasons OWNER TO oms_user;

--
-- Name: company_settings; Type: TABLE; Schema: shadow; Owner: oms_user
--

CREATE TABLE shadow.company_settings (
    id text NOT NULL,
    name text NOT NULL,
    address text,
    phone text,
    email text,
    "taxCode" text,
    "logoUrl" text,
    "bankInfo" text,
    "invoiceFooter" text,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE shadow.company_settings OWNER TO oms_user;

--
-- Name: customer_groups; Type: TABLE; Schema: shadow; Owner: oms_user
--

CREATE TABLE shadow.customer_groups (
    id text NOT NULL,
    name text NOT NULL,
    description text,
    "priceType" shadow."GroupPriceType" DEFAULT 'PERCENTAGE'::shadow."GroupPriceType" NOT NULL,
    "discountPercent" double precision DEFAULT 0,
    "isDefault" boolean DEFAULT false NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE shadow.customer_groups OWNER TO oms_user;

--
-- Name: customer_special_prices; Type: TABLE; Schema: shadow; Owner: oms_user
--

CREATE TABLE shadow.customer_special_prices (
    id text NOT NULL,
    "customerId" text NOT NULL,
    "productId" text NOT NULL,
    price numeric(15,0) NOT NULL,
    notes text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE shadow.customer_special_prices OWNER TO oms_user;

--
-- Name: customers; Type: TABLE; Schema: shadow; Owner: oms_user
--

CREATE TABLE shadow.customers (
    id text NOT NULL,
    phone text NOT NULL,
    "fullName" text NOT NULL,
    "groupId" text NOT NULL,
    "provinceCode" text,
    "provinceName" text,
    "wardCode" text,
    "wardName" text,
    "addressDetail" text,
    notes text,
    "isActive" boolean DEFAULT true NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE shadow.customers OWNER TO oms_user;

--
-- Name: order_items; Type: TABLE; Schema: shadow; Owner: oms_user
--

CREATE TABLE shadow.order_items (
    id text NOT NULL,
    "orderId" text NOT NULL,
    "productId" text NOT NULL,
    "snapshotProductName" text NOT NULL,
    "snapshotProductSku" text NOT NULL,
    "snapshotProductUnit" text NOT NULL,
    "snapshotUnitPrice" numeric(15,0) NOT NULL,
    "priceSource" shadow."PriceSource" NOT NULL,
    "pricingNote" text,
    quantity double precision NOT NULL,
    "lineDiscount" numeric(15,0) DEFAULT 0 NOT NULL,
    "lineTotal" numeric(15,0) NOT NULL
);


ALTER TABLE shadow.order_items OWNER TO oms_user;

--
-- Name: orders; Type: TABLE; Schema: shadow; Owner: oms_user
--

CREATE TABLE shadow.orders (
    id text NOT NULL,
    "orderNumber" text NOT NULL,
    "customerId" text NOT NULL,
    "snapshotCustomerName" text NOT NULL,
    "snapshotCustomerPhone" text NOT NULL,
    "createdById" text NOT NULL,
    "deliveryStatus" shadow."OrderDeliveryStatus" DEFAULT 'PENDING'::shadow."OrderDeliveryStatus" NOT NULL,
    subtotal numeric(15,0) NOT NULL,
    "discountAmount" numeric(15,0) DEFAULT 0 NOT NULL,
    "shippingFee" numeric(15,0) DEFAULT 0 NOT NULL,
    "totalAmount" numeric(15,0) NOT NULL,
    "cancelReasonId" text,
    "cancelNotes" text,
    notes text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE shadow.orders OWNER TO oms_user;

--
-- Name: product_group_prices; Type: TABLE; Schema: shadow; Owner: oms_user
--

CREATE TABLE shadow.product_group_prices (
    id text NOT NULL,
    "productId" text NOT NULL,
    "groupId" text NOT NULL,
    "fixedPrice" numeric(15,0),
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE shadow.product_group_prices OWNER TO oms_user;

--
-- Name: products; Type: TABLE; Schema: shadow; Owner: oms_user
--

CREATE TABLE shadow.products (
    id text NOT NULL,
    name text NOT NULL,
    sku text NOT NULL,
    unit text NOT NULL,
    "retailPrice" numeric(15,0) NOT NULL,
    "costPrice" numeric(15,0),
    stock double precision,
    weight double precision,
    dimensions text,
    "isActive" boolean DEFAULT true NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE shadow.products OWNER TO oms_user;

--
-- Name: users; Type: TABLE; Schema: shadow; Owner: oms_user
--

CREATE TABLE shadow.users (
    id text NOT NULL,
    email text NOT NULL,
    "passwordHash" text NOT NULL,
    "fullName" text NOT NULL,
    role shadow."Role" DEFAULT 'STAFF'::shadow."Role" NOT NULL,
    "isActive" boolean DEFAULT true NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "refreshTokenHash" text
);


ALTER TABLE shadow.users OWNER TO oms_user;

--
-- Data for Name: _prisma_migrations; Type: TABLE DATA; Schema: public; Owner: oms_user
--

COPY public._prisma_migrations (id, checksum, finished_at, migration_name, logs, rolled_back_at, started_at, applied_steps_count) FROM stdin;
ee26123f-c5e7-4b63-95be-5ca61b840e3d	e1551ba1e875aff01f82d5b8d9feb5e44d628b536718f9d1fc72efb241b2ad48	2026-04-16 18:51:10.168612+00	20260416185109_init_schema_sync	\N	\N	2026-04-16 18:51:09.721189+00	1
\.


--
-- Data for Name: audit_logs; Type: TABLE DATA; Schema: public; Owner: oms_user
--

COPY public.audit_logs (id, "userId", "userEmail", action, "entityType", "entityId", "oldData", "newData", "ipAddress", "createdAt") FROM stdin;
cmo1vuqhu000nvxmgtlas0xk2	cmo1u51iy0000vxgku42az9lu	poka@poka.us	UPDATE	CustomerGroup	cmo1u51km0006vxgkynb9di8i	null	{"id": "cmo1u51km0006vxgkynb9di8i", "name": "NAMAN", "createdAt": "2026-04-16T18:51:16.150Z", "isDefault": false, "priceType": "FIXED", "updatedAt": "2026-04-16T19:39:14.415Z", "description": "Nhóm khách NAMAN", "discountPercent": 0}	::1	2026-04-16 19:39:14.464
cmo1vv20y000uvxmglmrn8jaa	cmo1u51iy0000vxgku42az9lu	poka@poka.us	UPDATE	Product	cmo1u52j8006ovxgkqzaml6u2	{"id": "cmo1u52j8006ovxgkqzaml6u2", "sku": "MF-1019", "name": "Ớt hiểm sấy khô", "unit": "Gói", "weight": null, "isActive": true, "costPrice": "22800", "createdAt": "2026-04-16T18:51:17.397Z", "updatedAt": "2026-04-16T18:51:17.397Z", "categoryId": "cmo1u51lt000avxgkzpnjh5a8", "dimensions": null, "retailPrice": "38000"}	{"id": "cmo1u52j8006ovxgkqzaml6u2", "sku": "MF-1019", "name": "Ớt hiểm sấy khô", "unit": "Gói", "weight": null, "category": {"id": "cmo1u51lt000avxgkzpnjh5a8", "code": "RCT", "name": "Rau Củ Tươi", "isActive": true, "createdAt": "2026-04-16T18:51:16.193Z", "updatedAt": "2026-04-16T18:51:16.193Z", "description": "Rau củ quả tươi sạch"}, "isActive": true, "costPrice": "22800", "createdAt": "2026-04-16T18:51:17.397Z", "updatedAt": "2026-04-16T19:39:29.348Z", "categoryId": "cmo1u51lt000avxgkzpnjh5a8", "dimensions": null, "groupPrices": [{"id": "cmo1vv1zw000ovxmgovxjuohc", "groupId": "cmo1u51jp0002vxgkzecuf039", "createdAt": "2026-04-16T19:39:29.372Z", "productId": "cmo1u52j8006ovxgkqzaml6u2", "updatedAt": "2026-04-16T19:39:29.372Z", "fixedPrice": "31400"}, {"id": "cmo1vv1zw000pvxmg2jgcuw1l", "groupId": "cmo1u51jx0003vxgkhh5ypyjt", "createdAt": "2026-04-16T19:39:29.372Z", "productId": "cmo1u52j8006ovxgkqzaml6u2", "updatedAt": "2026-04-16T19:39:29.372Z", "fixedPrice": "30400"}, {"id": "cmo1vv1zw000qvxmg5t7ognbw", "groupId": "cmo1u51k50004vxgkrmtbswd7", "createdAt": "2026-04-16T19:39:29.372Z", "productId": "cmo1u52j8006ovxgkqzaml6u2", "updatedAt": "2026-04-16T19:39:29.372Z", "fixedPrice": "30400"}, {"id": "cmo1vv1zw000rvxmg06jb6vhg", "groupId": "cmo1u51ke0005vxgkoauhbzy6", "createdAt": "2026-04-16T19:39:29.372Z", "productId": "cmo1u52j8006ovxgkqzaml6u2", "updatedAt": "2026-04-16T19:39:29.372Z", "fixedPrice": "30400"}, {"id": "cmo1vv1zw000svxmg4zkj8z63", "groupId": "cmo1u51km0006vxgkynb9di8i", "createdAt": "2026-04-16T19:39:29.372Z", "productId": "cmo1u52j8006ovxgkqzaml6u2", "updatedAt": "2026-04-16T19:39:29.372Z", "fixedPrice": "30400"}], "retailPrice": "38000"}	::1	2026-04-16 19:39:29.41
cmo1vvgke000wvxmgnljkkc3d	cmo1u51iy0000vxgku42az9lu	poka@poka.us	UPDATE	ProductCategory	cmo1u51l90008vxgkwyzl8a2i	null	{"id": "cmo1u51l90008vxgkwyzl8a2i", "code": "HNCL", "name": "Hạt Ngũ Cốc", "isActive": true, "createdAt": "2026-04-16T18:51:16.173Z", "updatedAt": "2026-04-16T19:39:48.237Z", "description": "Các loại hạt dinh dưỡng"}	::1	2026-04-16 19:39:48.254
cmo1vvotl0014vxmg1x5q4i5s	cmo1u51iy0000vxgku42az9lu	poka@poka.us	CREATE	Order	cmo1vvorb000yvxmgjdcjhicn	null	{"id": "cmo1vvorb000yvxmgjdcjhicn", "items": [{"id": "cmo1vvorc0010vxmgp4ut5zf1", "orderId": "cmo1vvorb000yvxmgjdcjhicn", "quantity": 1, "lineTotal": "30400", "productId": "cmo1u52j8006ovxgkqzaml6u2", "priceSource": "GROUP", "pricingNote": "Áp dụng bảng giá tĩnh nhóm: VITA", "lineDiscount": "0", "snapshotUnitPrice": "30400", "snapshotProductSku": "MF-1019", "snapshotProductName": "Ớt hiểm sấy khô", "snapshotProductUnit": "Gói"}, {"id": "cmo1vvorc0011vxmg9j8ekt9r", "orderId": "cmo1vvorb000yvxmgjdcjhicn", "quantity": 1, "lineTotal": "20000", "productId": "cmo1u52hj006cvxgkvm4aadrm", "priceSource": "GROUP", "pricingNote": "Áp dụng bảng giá tĩnh nhóm: VITA", "lineDiscount": "0", "snapshotUnitPrice": "20000", "snapshotProductSku": "MF-1018", "snapshotProductName": "Tỏi Lý Sơn", "snapshotProductUnit": "Gói"}, {"id": "cmo1vvorc0012vxmgw04d1xyu", "orderId": "cmo1vvorb000yvxmgjdcjhicn", "quantity": 1, "lineTotal": "66400", "productId": "cmo1u52g10060vxgkkfs3fo3j", "priceSource": "GROUP", "pricingNote": "Áp dụng bảng giá tĩnh nhóm: VITA", "lineDiscount": "0", "snapshotUnitPrice": "66400", "snapshotProductSku": "MF-1017", "snapshotProductName": "Hành lá sấy", "snapshotProductUnit": "Gói"}], "notes": "", "customer": {"id": "cmo1u52nf0081vxgkrffd0xct", "code": "cmo1u52nf0082vxgk9n7hyo9i", "notes": null, "phone": "0901000009", "groupId": "cmo1u51k50004vxgkrmtbswd7", "fullName": "Lý Thị Kim", "isActive": true, "wardCode": null, "wardName": null, "createdAt": "2026-04-16T18:51:17.547Z", "updatedAt": "2026-04-16T18:51:17.547Z", "provinceCode": null, "provinceName": null, "addressDetail": null}, "subtotal": "116800", "createdAt": "2026-04-16T19:39:58.868Z", "updatedAt": "2026-04-16T19:39:58.868Z", "customerId": "cmo1u52nf0081vxgkrffd0xct", "cancelNotes": null, "createdById": "cmo1u51iy0000vxgku42az9lu", "orderNumber": "ORD-20260416-0001", "shippingFee": "0", "totalAmount": "116800", "cancelReasonId": null, "deliveryStatus": "PENDING", "discountAmount": "0", "snapshotCustomerName": "Lý Thị Kim", "snapshotCustomerPhone": "0901000009"}	::1	2026-04-16 19:39:58.953
cmo1wmujo0001vx20zcoclki0	cmo1u51iy0000vxgku42az9lu	poka@poka.us	UPDATE	Customer	cmo1u52nf0081vxgkrffd0xct	{"id": "cmo1u52nf0081vxgkrffd0xct", "code": "cmo1u52nf0082vxgk9n7hyo9i", "notes": null, "phone": "0901000009", "groupId": "cmo1u51k50004vxgkrmtbswd7", "fullName": "Lý Thị Kim", "isActive": true, "wardCode": null, "wardName": null, "createdAt": "2026-04-16T18:51:17.547Z", "updatedAt": "2026-04-16T18:51:17.547Z", "provinceCode": null, "provinceName": null, "addressDetail": null}	{"id": "cmo1u52nf0081vxgkrffd0xct", "code": "cmo1u52nf0082vxgk9n7hyo9i", "notes": null, "phone": "0901000009", "groupId": "cmo1u51jd0001vxgk5bl8jyb6", "fullName": "Lý Thị Kim ", "isActive": true, "wardCode": "", "wardName": null, "createdAt": "2026-04-16T18:51:17.547Z", "updatedAt": "2026-04-16T20:01:06.058Z", "provinceCode": "", "provinceName": null, "addressDetail": ""}	::1	2026-04-16 20:01:06.084
cmo1wnbsh0003vx20lxao0xzj	cmo1u51iy0000vxgku42az9lu	poka@poka.us	UPDATE	Customer	cmo1u52nf0081vxgkrffd0xct	{"id": "cmo1u52nf0081vxgkrffd0xct", "code": "cmo1u52nf0082vxgk9n7hyo9i", "notes": null, "phone": "0901000009", "groupId": "cmo1u51jd0001vxgk5bl8jyb6", "fullName": "Lý Thị Kim ", "isActive": true, "wardCode": "", "wardName": null, "createdAt": "2026-04-16T18:51:17.547Z", "updatedAt": "2026-04-16T20:01:06.058Z", "provinceCode": "", "provinceName": null, "addressDetail": ""}	{"id": "cmo1u52nf0081vxgkrffd0xct", "code": "cmo1u52nf0082vxgk9n7hyo9i", "notes": null, "phone": "0901000009", "groupId": "cmo1u51jd0001vxgk5bl8jyb6", "fullName": "Lý Thị Kim MODIFIED", "isActive": true, "wardCode": "", "wardName": null, "createdAt": "2026-04-16T18:51:17.547Z", "updatedAt": "2026-04-16T20:01:28.414Z", "provinceCode": "", "provinceName": null, "addressDetail": ""}	::1	2026-04-16 20:01:28.433
cmo1wp61v0005vx20kp7d9b6w	cmo1u51iy0000vxgku42az9lu	poka@poka.us	UPDATE	Customer	cmo1u52nf0081vxgkrffd0xct	{"id": "cmo1u52nf0081vxgkrffd0xct", "code": "cmo1u52nf0082vxgk9n7hyo9i", "notes": null, "phone": "0901000009", "groupId": "cmo1u51jd0001vxgk5bl8jyb6", "fullName": "Lý Thị Kim MODIFIED", "isActive": true, "wardCode": "", "wardName": null, "createdAt": "2026-04-16T18:51:17.547Z", "updatedAt": "2026-04-16T20:01:28.414Z", "provinceCode": "", "provinceName": null, "addressDetail": ""}	{"id": "cmo1u52nf0081vxgkrffd0xct", "code": "cmo1u52nf0082vxgk9n7hyo9i", "notes": null, "phone": "0901000009", "groupId": "cmo1u51jd0001vxgk5bl8jyb6", "fullName": "L", "isActive": true, "wardCode": "", "wardName": null, "createdAt": "2026-04-16T18:51:17.547Z", "updatedAt": "2026-04-16T20:02:54.225Z", "provinceCode": "", "provinceName": null, "addressDetail": ""}	::1	2026-04-16 20:02:54.308
cmo1wpmol0007vx200tohvvfh	cmo1u51iy0000vxgku42az9lu	poka@poka.us	UPDATE	Customer	cmo1u52nf0081vxgkrffd0xct	{"id": "cmo1u52nf0081vxgkrffd0xct", "code": "cmo1u52nf0082vxgk9n7hyo9i", "notes": null, "phone": "0901000009", "groupId": "cmo1u51jd0001vxgk5bl8jyb6", "fullName": "L", "isActive": true, "wardCode": "", "wardName": null, "createdAt": "2026-04-16T18:51:17.547Z", "updatedAt": "2026-04-16T20:02:54.225Z", "provinceCode": "", "provinceName": null, "addressDetail": ""}	{"id": "cmo1u52nf0081vxgkrffd0xct", "code": "cmo1u52nf0082vxgk9n7hyo9i", "notes": null, "phone": "0901000009", "groupId": "cmo1u51jd0001vxgk5bl8jyb6", "fullName": "L", "isActive": true, "wardCode": "", "wardName": null, "createdAt": "2026-04-16T18:51:17.547Z", "updatedAt": "2026-04-16T20:03:15.848Z", "provinceCode": "", "provinceName": null, "addressDetail": ""}	::1	2026-04-16 20:03:15.861
cmo1wpv800009vx20qz2arh0i	cmo1u51iy0000vxgku42az9lu	poka@poka.us	UPDATE	Customer	cmo1u52nf0081vxgkrffd0xct	{"id": "cmo1u52nf0081vxgkrffd0xct", "code": "cmo1u52nf0082vxgk9n7hyo9i", "notes": null, "phone": "0901000009", "groupId": "cmo1u51jd0001vxgk5bl8jyb6", "fullName": "L", "isActive": true, "wardCode": "", "wardName": null, "createdAt": "2026-04-16T18:51:17.547Z", "updatedAt": "2026-04-16T20:03:15.848Z", "provinceCode": "", "provinceName": null, "addressDetail": ""}	{"id": "cmo1u52nf0081vxgkrffd0xct", "code": "cmo1u52nf0082vxgk9n7hyo9i", "notes": null, "phone": "0901000009", "groupId": "cmo1u51jd0001vxgk5bl8jyb6", "fullName": "L", "isActive": true, "wardCode": "", "wardName": null, "createdAt": "2026-04-16T18:51:17.547Z", "updatedAt": "2026-04-16T20:03:26.798Z", "provinceCode": "", "provinceName": null, "addressDetail": ""}	::1	2026-04-16 20:03:26.928
cmo1xiyty000zvxv8ibt01p7z	cmo1u51iy0000vxgku42az9lu	poka@poka.us	DELETE	CustomerGroup	cmo1xc0zz000dvxp047ksszhi	null	{"id": "cmo1xc0zz000dvxp047ksszhi", "name": "HOA", "createdAt": "2026-04-16T20:20:40.848Z", "isDefault": false, "priceType": "FIXED", "updatedAt": "2026-04-16T20:20:40.848Z", "description": null, "discountPercent": 0}	::1	2026-04-16 20:26:04.63
cmo1wq5ju000bvx20v0eb0mxb	cmo1u51iy0000vxgku42az9lu	poka@poka.us	UPDATE	Customer	cmo1u52nf0081vxgkrffd0xct	{"id": "cmo1u52nf0081vxgkrffd0xct", "code": "cmo1u52nf0082vxgk9n7hyo9i", "notes": null, "phone": "0901000009", "groupId": "cmo1u51jd0001vxgk5bl8jyb6", "fullName": "L", "isActive": true, "wardCode": "", "wardName": null, "createdAt": "2026-04-16T18:51:17.547Z", "updatedAt": "2026-04-16T20:03:26.798Z", "provinceCode": "", "provinceName": null, "addressDetail": ""}	{"id": "cmo1u52nf0081vxgkrffd0xct", "code": "cmo1u52nf0082vxgk9n7hyo9i", "notes": null, "phone": "0901000009", "groupId": "cmo1u51jd0001vxgk5bl8jyb6", "fullName": "Lý Thị Kim", "isActive": true, "wardCode": "", "wardName": null, "createdAt": "2026-04-16T18:51:17.547Z", "updatedAt": "2026-04-16T20:03:40.273Z", "provinceCode": "", "provinceName": null, "addressDetail": ""}	::1	2026-04-16 20:03:40.314
cmo1wrqta000dvx20ux8pgwc8	cmo1u51iy0000vxgku42az9lu	poka@poka.us	UPDATE	Customer	cmo1u52nf0081vxgkrffd0xct	{"id": "cmo1u52nf0081vxgkrffd0xct", "code": "cmo1u52nf0082vxgk9n7hyo9i", "notes": null, "phone": "0901000009", "groupId": "cmo1u51jd0001vxgk5bl8jyb6", "fullName": "Lý Thị Kim", "isActive": true, "wardCode": "", "wardName": null, "createdAt": "2026-04-16T18:51:17.547Z", "updatedAt": "2026-04-16T20:03:40.273Z", "provinceCode": "", "provinceName": null, "addressDetail": ""}	{"id": "cmo1u52nf0081vxgkrffd0xct", "code": "cmo1u52nf0082vxgk9n7hyo9i", "notes": null, "phone": "0901000009", "groupId": "cmo1u51jd0001vxgk5bl8jyb6", "fullName": "Lý Thị Kim", "isActive": true, "wardCode": "", "wardName": null, "createdAt": "2026-04-16T18:51:17.547Z", "updatedAt": "2026-04-16T20:04:54.475Z", "provinceCode": "", "provinceName": null, "addressDetail": ""}	::1	2026-04-16 20:04:54.526
cmo1x1gl3000fvx20sveufitf	cmo1u51iy0000vxgku42az9lu	poka@poka.us	DELETE	AllOrders	unknown	null	{"message": "All orders have been deleted.", "success": true}	::1	2026-04-16 20:12:27.831
cmo1x6z4a0001vxv84j0jr2t2	cmo1u51iy0000vxgku42az9lu	poka@poka.us	DELETE	AllProducts	unknown	null	{"message": "All products and their prices have been deleted.", "success": true}	::1	2026-04-16 20:16:45.106
cmo1x77i80003vxv82nrymw4a	cmo1u51iy0000vxgku42az9lu	poka@poka.us	DELETE	AllCustomers	unknown	null	{"message": "All customers have been deleted.", "success": true}	::1	2026-04-16 20:16:56.001
cmo1x7ax30005vxv8ock39f7x	cmo1u51iy0000vxgku42az9lu	poka@poka.us	DELETE	AllOrders	unknown	null	{"message": "All orders have been deleted.", "success": true}	::1	2026-04-16 20:17:00.423
cmo1x7cl20007vxv8l4blxcst	cmo1u51iy0000vxgku42az9lu	poka@poka.us	DELETE	AllCustomerGroups	unknown	null	{"message": "All non-default customer groups have been deleted.", "success": true}	::1	2026-04-16 20:17:02.582
cmo1x7ee90009vxv881l2zlg9	cmo1u51iy0000vxgku42az9lu	poka@poka.us	DELETE	AllProductCategories	unknown	null	{"message": "All product categories have been deleted.", "success": true}	::1	2026-04-16 20:17:04.929
cmo1xe54y000bvxv8j7xlu5xn	cmo1u51iy0000vxgku42az9lu	poka@poka.us	UPDATE	ProductCategory	cmo1xc0ux0001vxp0gekkc5lr	null	{"id": "cmo1xc0ux0001vxp0gekkc5lr", "code": "MOUNTAIN", "name": "Mountain Farmer", "isActive": true, "createdAt": "2026-04-16T20:20:40.666Z", "updatedAt": "2026-04-16T20:22:19.507Z", "description": null}	::1	2026-04-16 20:22:19.522
cmo1xffwr000dvxv8m0u3ksf3	cmo1u51iy0000vxgku42az9lu	poka@poka.us	UPDATE	ProductCategory	cmo1xc0vw0004vxp0uzuqvrgw	null	{"id": "cmo1xc0vw0004vxp0uzuqvrgw", "code": "MFKHD", "name": "MOUNTAINKHD", "isActive": true, "createdAt": "2026-04-16T20:20:40.701Z", "updatedAt": "2026-04-16T20:23:20.127Z", "description": null}	::1	2026-04-16 20:23:20.139
cmo1xfone000fvxv8lm8xucfc	cmo1u51iy0000vxgku42az9lu	poka@poka.us	UPDATE	ProductCategory	cmo1xc0vw0004vxp0uzuqvrgw	null	{"id": "cmo1xc0vw0004vxp0uzuqvrgw", "code": "MOUNTAINKH", "name": "Moutain Farmer KHD", "isActive": true, "createdAt": "2026-04-16T20:20:40.701Z", "updatedAt": "2026-04-16T20:23:31.457Z", "description": null}	::1	2026-04-16 20:23:31.466
cmo1xhmyt000hvxv8jne8x18i	cmo1u51iy0000vxgku42az9lu	poka@poka.us	DELETE	CustomerGroup	cmo1xc110000ivxp0c4hxwvwr	null	{"id": "cmo1xc110000ivxp0c4hxwvwr", "name": "LOYAL", "createdAt": "2026-04-16T20:20:40.885Z", "isDefault": false, "priceType": "FIXED", "updatedAt": "2026-04-16T20:20:40.885Z", "description": null, "discountPercent": 0}	::1	2026-04-16 20:25:02.597
cmo1xhutq000jvxv88kso48on	cmo1u51iy0000vxgku42az9lu	poka@poka.us	DELETE	CustomerGroup	cmo1xc10n000gvxp0jtcmlo1p	null	{"id": "cmo1xc10n000gvxp0jtcmlo1p", "name": "GREENTECH", "createdAt": "2026-04-16T20:20:40.871Z", "isDefault": false, "priceType": "FIXED", "updatedAt": "2026-04-16T20:20:40.871Z", "description": null, "discountPercent": 0}	::1	2026-04-16 20:25:12.783
cmo1xihnd000lvxv8iuj7wnci	cmo1u51iy0000vxgku42az9lu	poka@poka.us	DELETE	CustomerGroup	cmo1xc0yl0007vxp0cg7j4tc3	null	{"id": "cmo1xc0yl0007vxp0cg7j4tc3", "name": "KHOADL", "createdAt": "2026-04-16T20:20:40.797Z", "isDefault": false, "priceType": "FIXED", "updatedAt": "2026-04-16T20:20:40.797Z", "description": null, "discountPercent": 0}	::1	2026-04-16 20:25:42.361
cmo1xil1y000nvxv817047mac	cmo1u51iy0000vxgku42az9lu	poka@poka.us	DELETE	CustomerGroup	cmo1xc0yt0008vxp0uodwi7kb	null	{"id": "cmo1xc0yt0008vxp0uodwi7kb", "name": "VITA", "createdAt": "2026-04-16T20:20:40.805Z", "isDefault": false, "priceType": "FIXED", "updatedAt": "2026-04-16T20:20:40.805Z", "description": null, "discountPercent": 0}	::1	2026-04-16 20:25:46.774
cmo1xiod6000pvxv8sjis8hrf	cmo1u51iy0000vxgku42az9lu	poka@poka.us	DELETE	CustomerGroup	cmo1xc0z20009vxp05l7if003	null	{"id": "cmo1xc0z20009vxp05l7if003", "name": "VYQN", "createdAt": "2026-04-16T20:20:40.815Z", "isDefault": false, "priceType": "FIXED", "updatedAt": "2026-04-16T20:20:40.815Z", "description": null, "discountPercent": 0}	::1	2026-04-16 20:25:51.066
cmo1xiqyp000rvxv8p1fcxi3k	cmo1u51iy0000vxgku42az9lu	poka@poka.us	DELETE	CustomerGroup	cmo1xc0yb0006vxp0nsoau966	null	{"id": "cmo1xc0yb0006vxp0nsoau966", "name": "Giá sỉ", "createdAt": "2026-04-16T20:20:40.787Z", "isDefault": false, "priceType": "FIXED", "updatedAt": "2026-04-16T20:20:40.787Z", "description": null, "discountPercent": 0}	::1	2026-04-16 20:25:54.433
cmo1xit7h000tvxv8jv17o7k9	cmo1u51iy0000vxgku42az9lu	poka@poka.us	DELETE	CustomerGroup	cmo1xc0zj000bvxp075oyg6au	null	{"id": "cmo1xc0zj000bvxp075oyg6au", "name": "TRAMQ10", "createdAt": "2026-04-16T20:20:40.832Z", "isDefault": false, "priceType": "FIXED", "updatedAt": "2026-04-16T20:20:40.832Z", "description": null, "discountPercent": 0}	::1	2026-04-16 20:25:57.341
cmo1xiv5g000vvxv8hh56q2cq	cmo1u51iy0000vxgku42az9lu	poka@poka.us	DELETE	CustomerGroup	cmo1xc0zc000avxp0zrnthjz9	null	{"id": "cmo1xc0zc000avxp0zrnthjz9", "name": "NAMAN", "createdAt": "2026-04-16T20:20:40.824Z", "isDefault": false, "priceType": "FIXED", "updatedAt": "2026-04-16T20:20:40.824Z", "description": null, "discountPercent": 0}	::1	2026-04-16 20:25:59.861
cmo1xix07000xvxv8ogs9h7dx	cmo1u51iy0000vxgku42az9lu	poka@poka.us	DELETE	CustomerGroup	cmo1xc0zr000cvxp0n3j2dqaq	null	{"id": "cmo1xc0zr000cvxp0n3j2dqaq", "name": "TUANTHUY", "createdAt": "2026-04-16T20:20:40.839Z", "isDefault": false, "priceType": "FIXED", "updatedAt": "2026-04-16T20:20:40.839Z", "description": null, "discountPercent": 0}	::1	2026-04-16 20:26:02.263
cmo1xj1fr0011vxv8dgddms9g	cmo1u51iy0000vxgku42az9lu	poka@poka.us	DELETE	CustomerGroup	cmo1xc10f000fvxp03ekw3pak	null	{"id": "cmo1xc10f000fvxp03ekw3pak", "name": "ANHPR", "createdAt": "2026-04-16T20:20:40.863Z", "isDefault": false, "priceType": "FIXED", "updatedAt": "2026-04-16T20:20:40.863Z", "description": null, "discountPercent": 0}	::1	2026-04-16 20:26:08.007
cmo1xj3v60013vxv8drfpifmf	cmo1u51iy0000vxgku42az9lu	poka@poka.us	DELETE	CustomerGroup	cmo1xc107000evxp0av0t9e2s	null	{"id": "cmo1xc107000evxp0av0t9e2s", "name": "TUANH", "createdAt": "2026-04-16T20:20:40.855Z", "isDefault": false, "priceType": "FIXED", "updatedAt": "2026-04-16T20:20:40.855Z", "description": null, "discountPercent": 0}	::1	2026-04-16 20:26:11.154
cmo1xl9gb0017vxv8zplyb3y2	cmo1u51iy0000vxgku42az9lu	poka@poka.us	CREATE	Customer	cmo1xl9fu0015vxv8nto782ga	null	{"id": "cmo1xl9fu0015vxv8nto782ga", "code": "KH677691", "notes": null, "phone": null, "groupId": "cmo1u51jd0001vxgk5bl8jyb6", "fullName": "Poka P.", "isActive": true, "wardCode": "", "wardName": null, "createdAt": "2026-04-16T20:27:51.690Z", "updatedAt": "2026-04-16T20:27:51.690Z", "provinceCode": "", "provinceName": null, "addressDetail": ""}	::1	2026-04-16 20:27:51.707
cmo1xlj2l0019vxv8o76xwlu9	cmo1u51iy0000vxgku42az9lu	poka@poka.us	DELETE	Customer	cmo1xl9fu0015vxv8nto782ga	{"id": "cmo1xl9fu0015vxv8nto782ga", "code": "KH677691", "notes": null, "phone": null, "groupId": "cmo1u51jd0001vxgk5bl8jyb6", "fullName": "Poka P.", "isActive": true, "wardCode": "", "wardName": null, "createdAt": "2026-04-16T20:27:51.690Z", "updatedAt": "2026-04-16T20:27:51.690Z", "provinceCode": "", "provinceName": null, "addressDetail": ""}	{"id": "cmo1xl9fu0015vxv8nto782ga", "code": "KH677691", "notes": null, "phone": null, "groupId": "cmo1u51jd0001vxgk5bl8jyb6", "fullName": "Poka P.", "isActive": true, "wardCode": "", "wardName": null, "createdAt": "2026-04-16T20:27:51.690Z", "updatedAt": "2026-04-16T20:27:51.690Z", "provinceCode": "", "provinceName": null, "addressDetail": ""}	::1	2026-04-16 20:28:04.173
cmo1xno6q001bvxv87a1qnyaz	cmo1u51iy0000vxgku42az9lu	poka@poka.us	UPDATE	CompanySettings	cmo1u52p70087vxgktmei8jmo	null	{"id": "cmo1u52p70087vxgktmei8jmo", "name": "Công ty TNHH Mountain Farmers", "email": null, "phone": "0906 454 379", "address": "Thôn Kon Jri, Xã Đăk Rơ Wa, Tỉnh Quảng Ngãi", "logoUrl": null, "taxCode": null, "bankInfo": null, "updatedAt": "2026-04-16T20:29:44.104Z", "invoiceFooter": "Cảm ơn quý khách đã tin tưởng!", "treatBlankAsZero": false}	::1	2026-04-16 20:29:44.114
cmo1xnp3h001dvxv89sle9huv	cmo1u51iy0000vxgku42az9lu	poka@poka.us	UPDATE	CompanySettings	cmo1u52p70087vxgktmei8jmo	null	{"id": "cmo1u52p70087vxgktmei8jmo", "name": "Công ty TNHH Mountain Farmers", "email": null, "phone": "0906 454 379", "address": "Thôn Kon Jri, Xã Đăk Rơ Wa, Tỉnh Quảng Ngãi", "logoUrl": null, "taxCode": null, "bankInfo": null, "updatedAt": "2026-04-16T20:29:45.284Z", "invoiceFooter": "Cảm ơn quý khách đã tin tưởng!", "treatBlankAsZero": false}	::1	2026-04-16 20:29:45.293
cmo1xo850001fvxv8ncte97fk	cmo1u51iy0000vxgku42az9lu	poka@poka.us	UPDATE	ProductCategory	cmo1xc0vw0004vxp0uzuqvrgw	null	{"id": "cmo1xc0vw0004vxp0uzuqvrgw", "code": "MFKHD", "name": "Moutain Farmer KHD", "isActive": true, "createdAt": "2026-04-16T20:20:40.701Z", "updatedAt": "2026-04-16T20:30:09.963Z", "description": null}	::1	2026-04-16 20:30:09.972
cmo1xqykt001hvxv8no1lf2wf	cmo1u51iy0000vxgku42az9lu	poka@poka.us	UPDATE	CustomerGroup	cmo1xc13o000tvxp0alok8jeb	null	{"id": "cmo1xc13o000tvxp0alok8jeb", "name": "TUANH", "createdAt": "2026-04-16T20:20:40.980Z", "isDefault": false, "priceType": "FIXED", "updatedAt": "2026-04-16T20:32:17.538Z", "description": "", "discountPercent": 0}	::1	2026-04-16 20:32:17.549
cmo1xr4w7001jvxv8vy9nkff5	cmo1u51iy0000vxgku42az9lu	poka@poka.us	UPDATE	CustomerGroup	cmo1xc13g000svxp0tbndc1wg	null	{"id": "cmo1xc13g000svxp0tbndc1wg", "name": "VYQN", "createdAt": "2026-04-16T20:20:40.972Z", "isDefault": false, "priceType": "FIXED", "updatedAt": "2026-04-16T20:32:25.725Z", "description": "", "discountPercent": 0}	::1	2026-04-16 20:32:25.735
cmo1xr7ky001lvxv8ik7kqvu1	cmo1u51iy0000vxgku42az9lu	poka@poka.us	UPDATE	CustomerGroup	cmo1xc138000rvxp0r16wi1bz	null	{"id": "cmo1xc138000rvxp0r16wi1bz", "name": "TUANTHUY", "createdAt": "2026-04-16T20:20:40.964Z", "isDefault": false, "priceType": "FIXED", "updatedAt": "2026-04-16T20:32:29.208Z", "description": "", "discountPercent": 0}	::1	2026-04-16 20:32:29.218
cmo1xra98001nvxv8t7t228jf	cmo1u51iy0000vxgku42az9lu	poka@poka.us	UPDATE	CustomerGroup	cmo1xc12y000qvxp0uqc7d8d8	null	{"id": "cmo1xc12y000qvxp0uqc7d8d8", "name": "VITA", "createdAt": "2026-04-16T20:20:40.954Z", "isDefault": false, "priceType": "FIXED", "updatedAt": "2026-04-16T20:32:32.660Z", "description": "", "discountPercent": 0}	::1	2026-04-16 20:32:32.684
cmo1xrl1y001pvxv8bgz0vpko	cmo1u51iy0000vxgku42az9lu	poka@poka.us	UPDATE	CustomerGroup	cmo1xc12q000pvxp0kun82k4l	null	{"id": "cmo1xc12q000pvxp0kun82k4l", "name": "TRAMQ10", "createdAt": "2026-04-16T20:20:40.947Z", "isDefault": false, "priceType": "FIXED", "updatedAt": "2026-04-16T20:32:46.601Z", "description": "", "discountPercent": 0}	::1	2026-04-16 20:32:46.678
cmo1xrpnj001rvxv8kq36b98u	cmo1u51iy0000vxgku42az9lu	poka@poka.us	UPDATE	CustomerGroup	cmo1xc12i000ovxp01nisgvnu	null	{"id": "cmo1xc12i000ovxp01nisgvnu", "name": "HOA", "createdAt": "2026-04-16T20:20:40.939Z", "isDefault": false, "priceType": "FIXED", "updatedAt": "2026-04-16T20:32:52.505Z", "description": "", "discountPercent": 0}	::1	2026-04-16 20:32:52.639
cmo1xrtqk001tvxv8dhc5yyr8	cmo1u51iy0000vxgku42az9lu	poka@poka.us	UPDATE	CustomerGroup	cmo1xc123000mvxp0ul7pkio2	null	{"id": "cmo1xc123000mvxp0ul7pkio2", "name": "ANHPR", "createdAt": "2026-04-16T20:20:40.923Z", "isDefault": false, "priceType": "FIXED", "updatedAt": "2026-04-16T20:32:57.604Z", "description": "", "discountPercent": 0}	::1	2026-04-16 20:32:57.932
cmo1xrx3x001vvxv8upv9qgur	cmo1u51iy0000vxgku42az9lu	poka@poka.us	UPDATE	CustomerGroup	cmo1xc12a000nvxp0f1zf3aqg	null	{"id": "cmo1xc12a000nvxp0f1zf3aqg", "name": "NAMAN", "createdAt": "2026-04-16T20:20:40.931Z", "isDefault": false, "priceType": "FIXED", "updatedAt": "2026-04-16T20:33:02.257Z", "description": "", "discountPercent": 0}	::1	2026-04-16 20:33:02.302
cmo1xs1fp001xvxv8to746pup	cmo1u51iy0000vxgku42az9lu	poka@poka.us	UPDATE	CustomerGroup	cmo1xc11v000lvxp07r6uljko	null	{"id": "cmo1xc11v000lvxp07r6uljko", "name": "KHOADL", "createdAt": "2026-04-16T20:20:40.915Z", "isDefault": false, "priceType": "FIXED", "updatedAt": "2026-04-16T20:33:07.883Z", "description": "", "discountPercent": 0}	::1	2026-04-16 20:33:07.909
cmo1xs6ii001zvxv8hpxd2rsb	cmo1u51iy0000vxgku42az9lu	poka@poka.us	UPDATE	CustomerGroup	cmo1xc11n000kvxp0g32oj3wx	null	{"id": "cmo1xc11n000kvxp0g32oj3wx", "name": "GREENTECH", "createdAt": "2026-04-16T20:20:40.908Z", "isDefault": false, "priceType": "FIXED", "updatedAt": "2026-04-16T20:33:14.481Z", "description": "", "discountPercent": 0}	::1	2026-04-16 20:33:14.491
cmo1xs9m50021vxv84pj5ycr9	cmo1u51iy0000vxgku42az9lu	poka@poka.us	UPDATE	CustomerGroup	cmo1xc119000jvxp01snwxzoa	null	{"id": "cmo1xc119000jvxp01snwxzoa", "name": "LOYAL", "createdAt": "2026-04-16T20:20:40.893Z", "isDefault": false, "priceType": "FIXED", "updatedAt": "2026-04-16T20:33:18.465Z", "description": "", "discountPercent": 0}	::1	2026-04-16 20:33:18.509
cmo1xsgs90024vxv8l5qkd1hm	cmo1u51iy0000vxgku42az9lu	poka@poka.us	CREATE	CustomerGroup	cmo1xsgrt0022vxv8sd7cckj7	null	{"id": "cmo1xsgrt0022vxv8sd7cckj7", "name": "Giá sỉ", "createdAt": "2026-04-16T20:33:27.786Z", "isDefault": false, "priceType": "FIXED", "updatedAt": "2026-04-16T20:33:27.786Z", "description": "", "discountPercent": 0}	::1	2026-04-16 20:33:27.802
cmo1xt4e50026vxv8soh1a9ds	cmo1u51iy0000vxgku42az9lu	poka@poka.us	DELETE	AllProducts	unknown	null	{"message": "All products and their prices have been deleted.", "success": true}	::1	2026-04-16 20:33:58.397
cmo1xybhd0002vxi4p1stz67c	cmo1u51iy0000vxgku42az9lu	poka@poka.us	CREATE	ProductCategory	cmo1xybh10000vxi4nigilgz5	null	{"id": "cmo1xybh10000vxi4nigilgz5", "code": "XLKHD", "name": "Xuân Lộc KHD", "isActive": true, "createdAt": "2026-04-16T20:38:00.854Z", "updatedAt": "2026-04-16T20:38:00.854Z", "description": null}	::1	2026-04-16 20:38:00.865
cmo1xyqiy0007vxi4dkr79g33	cmo1u51iy0000vxgku42az9lu	poka@poka.us	UPDATE	Product	cmo1xvy8t02vvvxvo89mnql98	{"id": "cmo1xvy8t02vvvxvo89mnql98", "sku": "MFKHD12", "name": "Gạo thơm xát trắng - túi 5kg (Hàng chương trình 15/1-25/1)", "unit": "Túi", "weight": null, "isActive": true, "costPrice": null, "createdAt": "2026-04-16T20:36:10.397Z", "updatedAt": "2026-04-16T20:36:10.397Z", "categoryId": null, "dimensions": null, "retailPrice": "170000"}	{"id": "cmo1xvy8t02vvvxvo89mnql98", "sku": "MFKHD12", "name": "Gạo thơm xát trắng - túi 5kg (Hàng chương trình 15/1-25/1)", "unit": "Túi", "weight": null, "category": {"id": "cmo1xc0vw0004vxp0uzuqvrgw", "code": "MFKHD", "name": "Moutain Farmer KHD", "isActive": true, "createdAt": "2026-04-16T20:20:40.701Z", "updatedAt": "2026-04-16T20:30:09.963Z", "description": null}, "isActive": true, "costPrice": null, "createdAt": "2026-04-16T20:36:10.397Z", "updatedAt": "2026-04-16T20:38:20.279Z", "categoryId": "cmo1xc0vw0004vxp0uzuqvrgw", "dimensions": null, "groupPrices": [{"id": "cmo1xyqhg0004vxi4xinoyje9", "groupId": "cmo1xc10u000hvxp0dapryn3r", "createdAt": "2026-04-16T20:38:20.308Z", "productId": "cmo1xvy8t02vvvxvo89mnql98", "updatedAt": "2026-04-16T20:38:20.308Z", "fixedPrice": "120000"}, {"id": "cmo1xyqhg0005vxi4211vyeg0", "groupId": "cmo1xc11v000lvxp07r6uljko", "createdAt": "2026-04-16T20:38:20.308Z", "productId": "cmo1xvy8t02vvvxvo89mnql98", "updatedAt": "2026-04-16T20:38:20.308Z", "fixedPrice": "120000"}, {"id": "cmo1xyqhg0003vxi4b4m7wie5", "groupId": "cmo1xsgrt0022vxv8sd7cckj7", "createdAt": "2026-04-16T20:38:20.308Z", "productId": "cmo1xvy8t02vvvxvo89mnql98", "updatedAt": "2026-04-16T20:38:20.308Z", "fixedPrice": "120000"}], "retailPrice": "170000"}	::1	2026-04-16 20:38:20.362
cmo1xz0q0000dvxi4buybr8g1	cmo1u51iy0000vxgku42az9lu	poka@poka.us	UPDATE	Product	cmo1xvork0097vxvoci6opqbl	{"id": "cmo1xvork0097vxvoci6opqbl", "sku": "MFKHD1", "name": "Khoai lang (cạp)", "unit": "Kg", "weight": null, "isActive": true, "costPrice": null, "createdAt": "2026-04-16T20:35:58.112Z", "updatedAt": "2026-04-16T20:35:58.112Z", "categoryId": null, "dimensions": null, "retailPrice": "48000"}	{"id": "cmo1xvork0097vxvoci6opqbl", "sku": "MFKHD1", "name": "Khoai lang (cạp)", "unit": "Kg", "weight": null, "category": {"id": "cmo1xc0vw0004vxp0uzuqvrgw", "code": "MFKHD", "name": "Moutain Farmer KHD", "isActive": true, "createdAt": "2026-04-16T20:20:40.701Z", "updatedAt": "2026-04-16T20:30:09.963Z", "description": null}, "isActive": true, "costPrice": null, "createdAt": "2026-04-16T20:35:58.112Z", "updatedAt": "2026-04-16T20:38:33.548Z", "categoryId": "cmo1xc0vw0004vxp0uzuqvrgw", "dimensions": null, "groupPrices": [{"id": "cmo1xz0pf0009vxi4txjxp9n1", "groupId": "cmo1xc10u000hvxp0dapryn3r", "createdAt": "2026-04-16T20:38:33.555Z", "productId": "cmo1xvork0097vxvoci6opqbl", "updatedAt": "2026-04-16T20:38:33.555Z", "fixedPrice": "33600"}, {"id": "cmo1xz0pf000avxi43sphj8hi", "groupId": "cmo1xc11v000lvxp07r6uljko", "createdAt": "2026-04-16T20:38:33.555Z", "productId": "cmo1xvork0097vxvoci6opqbl", "updatedAt": "2026-04-16T20:38:33.555Z", "fixedPrice": "33600"}, {"id": "cmo1xz0pf000bvxi4e3zxl0ax", "groupId": "cmo1xc13o000tvxp0alok8jeb", "createdAt": "2026-04-16T20:38:33.555Z", "productId": "cmo1xvork0097vxvoci6opqbl", "updatedAt": "2026-04-16T20:38:33.555Z", "fixedPrice": "33600"}, {"id": "cmo1xz0pf0008vxi499bnb396", "groupId": "cmo1xsgrt0022vxv8sd7cckj7", "createdAt": "2026-04-16T20:38:33.555Z", "productId": "cmo1xvork0097vxvoci6opqbl", "updatedAt": "2026-04-16T20:38:33.555Z", "fixedPrice": "33600"}], "retailPrice": "48000"}	::1	2026-04-16 20:38:33.577
cmo1xzflc000gvxi4jinpaz25	cmo1u51iy0000vxgku42az9lu	poka@poka.us	UPDATE	Product	cmo1xvoqf0093vxvoko7o6lv1	{"id": "cmo1xvoqf0093vxvoko7o6lv1", "sku": "MFKHD2", "name": "Khoai lang (nhỏ)", "unit": "Kg", "weight": null, "isActive": true, "costPrice": null, "createdAt": "2026-04-16T20:35:58.071Z", "updatedAt": "2026-04-16T20:35:58.071Z", "categoryId": null, "dimensions": null, "retailPrice": "0"}	{"id": "cmo1xvoqf0093vxvoko7o6lv1", "sku": "MFKHD2", "name": "Khoai lang (nhỏ)", "unit": "Kg", "weight": null, "category": {"id": "cmo1xc0vw0004vxp0uzuqvrgw", "code": "MFKHD", "name": "Moutain Farmer KHD", "isActive": true, "createdAt": "2026-04-16T20:20:40.701Z", "updatedAt": "2026-04-16T20:30:09.963Z", "description": null}, "isActive": true, "costPrice": null, "createdAt": "2026-04-16T20:35:58.071Z", "updatedAt": "2026-04-16T20:38:52.820Z", "categoryId": "cmo1xc0vw0004vxp0uzuqvrgw", "dimensions": null, "groupPrices": [{"id": "cmo1xzfku000evxi4nu1ke34y", "groupId": "cmo1xsgrt0022vxv8sd7cckj7", "createdAt": "2026-04-16T20:38:52.831Z", "productId": "cmo1xvoqf0093vxvoko7o6lv1", "updatedAt": "2026-04-16T20:38:52.831Z", "fixedPrice": "42000"}], "retailPrice": "0"}	::1	2026-04-16 20:38:52.848
cmo1xzog7000ivxi44yrhyc1c	cmo1u51iy0000vxgku42az9lu	poka@poka.us	UPDATE	Product	cmo1xvopu0091vxvo2vgq5ipd	{"id": "cmo1xvopu0091vxvo2vgq5ipd", "sku": "MFKHD3", "name": "Trứng gà (tặng)", "unit": "Cái", "weight": null, "isActive": true, "costPrice": null, "createdAt": "2026-04-16T20:35:58.050Z", "updatedAt": "2026-04-16T20:35:58.050Z", "categoryId": null, "dimensions": null, "retailPrice": "0"}	{"id": "cmo1xvopu0091vxvo2vgq5ipd", "sku": "MFKHD3", "name": "Trứng gà (tặng)", "unit": "Cái", "weight": null, "category": {"id": "cmo1xc0vw0004vxp0uzuqvrgw", "code": "MFKHD", "name": "Moutain Farmer KHD", "isActive": true, "createdAt": "2026-04-16T20:20:40.701Z", "updatedAt": "2026-04-16T20:30:09.963Z", "description": null}, "isActive": true, "costPrice": null, "createdAt": "2026-04-16T20:35:58.050Z", "updatedAt": "2026-04-16T20:39:04.302Z", "categoryId": "cmo1xc0vw0004vxp0uzuqvrgw", "dimensions": null, "groupPrices": [], "retailPrice": "0"}	::1	2026-04-16 20:39:04.327
cmo1xzxxv000kvxi48oekcph0	cmo1u51iy0000vxgku42az9lu	poka@poka.us	UPDATE	Product	cmo1xvoos008vvxvoywu5pk43	{"id": "cmo1xvoos008vvxvoywu5pk43", "sku": "MFKHD4", "name": "Cám", "unit": "Kg", "weight": null, "isActive": true, "costPrice": null, "createdAt": "2026-04-16T20:35:58.012Z", "updatedAt": "2026-04-16T20:35:58.012Z", "categoryId": null, "dimensions": null, "retailPrice": "15000"}	{"id": "cmo1xvoos008vvxvoywu5pk43", "sku": "MFKHD4", "name": "Cám", "unit": "Kg", "weight": null, "category": {"id": "cmo1xc0vw0004vxp0uzuqvrgw", "code": "MFKHD", "name": "Moutain Farmer KHD", "isActive": true, "createdAt": "2026-04-16T20:20:40.701Z", "updatedAt": "2026-04-16T20:30:09.963Z", "description": null}, "isActive": true, "costPrice": null, "createdAt": "2026-04-16T20:35:58.012Z", "updatedAt": "2026-04-16T20:39:16.606Z", "categoryId": "cmo1xc0vw0004vxp0uzuqvrgw", "dimensions": null, "groupPrices": [], "retailPrice": "15000"}	::1	2026-04-16 20:39:16.627
cmo1y0ekv000mvxi47vtge3h5	cmo1u51iy0000vxgku42az9lu	poka@poka.us	UPDATE	Product	cmo1xvoo7008tvxvo5rsmw0i6	{"id": "cmo1xvoo7008tvxvo5rsmw0i6", "sku": "MFKHD5", "name": "Đậu ve  (tặng)", "unit": "Kg", "weight": null, "isActive": true, "costPrice": null, "createdAt": "2026-04-16T20:35:57.991Z", "updatedAt": "2026-04-16T20:35:57.991Z", "categoryId": null, "dimensions": null, "retailPrice": "0"}	{"id": "cmo1xvoo7008tvxvo5rsmw0i6", "sku": "MFKHD5", "name": "Đậu ve  (tặng)", "unit": "Kg", "weight": null, "category": {"id": "cmo1xc0vw0004vxp0uzuqvrgw", "code": "MFKHD", "name": "Moutain Farmer KHD", "isActive": true, "createdAt": "2026-04-16T20:20:40.701Z", "updatedAt": "2026-04-16T20:30:09.963Z", "description": null}, "isActive": true, "costPrice": null, "createdAt": "2026-04-16T20:35:57.991Z", "updatedAt": "2026-04-16T20:39:38.170Z", "categoryId": "cmo1xc0vw0004vxp0uzuqvrgw", "dimensions": null, "groupPrices": [], "retailPrice": "0"}	::1	2026-04-16 20:39:38.191
cmo1y0pgu000ovxi42c5zazqc	cmo1u51iy0000vxgku42az9lu	poka@poka.us	UPDATE	Product	cmo1xvonm008rvxvoq0mrktpw	{"id": "cmo1xvonm008rvxvoq0mrktpw", "sku": "MFKHD6", "name": "Dưa leo (tặng)", "unit": "Kg", "weight": null, "isActive": true, "costPrice": null, "createdAt": "2026-04-16T20:35:57.970Z", "updatedAt": "2026-04-16T20:35:57.970Z", "categoryId": null, "dimensions": null, "retailPrice": "0"}	{"id": "cmo1xvonm008rvxvoq0mrktpw", "sku": "MFKHD6", "name": "Dưa leo (tặng)", "unit": "Kg", "weight": null, "category": {"id": "cmo1xc0vw0004vxp0uzuqvrgw", "code": "MFKHD", "name": "Moutain Farmer KHD", "isActive": true, "createdAt": "2026-04-16T20:20:40.701Z", "updatedAt": "2026-04-16T20:30:09.963Z", "description": null}, "isActive": true, "costPrice": null, "createdAt": "2026-04-16T20:35:57.970Z", "updatedAt": "2026-04-16T20:39:52.271Z", "categoryId": "cmo1xc0vw0004vxp0uzuqvrgw", "dimensions": null, "groupPrices": [], "retailPrice": "0"}	::1	2026-04-16 20:39:52.302
cmo1y1cxc000tvxi4taa9ai86	cmo1u51iy0000vxgku42az9lu	poka@poka.us	UPDATE	Product	cmo1xvpd000etvxvovtu1an49	{"id": "cmo1xvpd000etvxvovtu1an49", "sku": "XUANLOCKHD1", "name": "Gói xông", "unit": "Gói", "weight": null, "isActive": true, "costPrice": null, "createdAt": "2026-04-16T20:35:58.885Z", "updatedAt": "2026-04-16T20:35:58.885Z", "categoryId": "cmo1xc0tk0000vxp0m1od0byy", "dimensions": null, "retailPrice": "22000"}	{"id": "cmo1xvpd000etvxvovtu1an49", "sku": "XUANLOCKHD1", "name": "Gói xông", "unit": "Gói", "weight": null, "category": {"id": "cmo1xybh10000vxi4nigilgz5", "code": "XLKHD", "name": "Xuân Lộc KHD", "isActive": true, "createdAt": "2026-04-16T20:38:00.854Z", "updatedAt": "2026-04-16T20:38:00.854Z", "description": null}, "isActive": true, "costPrice": null, "createdAt": "2026-04-16T20:35:58.885Z", "updatedAt": "2026-04-16T20:40:22.670Z", "categoryId": "cmo1xybh10000vxi4nigilgz5", "dimensions": null, "groupPrices": [{"id": "cmo1y1cwr000qvxi4r5q03v87", "groupId": "cmo1xc10u000hvxp0dapryn3r", "createdAt": "2026-04-16T20:40:22.684Z", "productId": "cmo1xvpd000etvxvovtu1an49", "updatedAt": "2026-04-16T20:40:22.684Z", "fixedPrice": "15000"}, {"id": "cmo1y1cwr000rvxi4086qw4y2", "groupId": "cmo1xc11v000lvxp07r6uljko", "createdAt": "2026-04-16T20:40:22.684Z", "productId": "cmo1xvpd000etvxvovtu1an49", "updatedAt": "2026-04-16T20:40:22.684Z", "fixedPrice": "15000"}, {"id": "cmo1y1cwr000pvxi4vplsp9p3", "groupId": "cmo1xsgrt0022vxv8sd7cckj7", "createdAt": "2026-04-16T20:40:22.684Z", "productId": "cmo1xvpd000etvxvovtu1an49", "updatedAt": "2026-04-16T20:40:22.684Z", "fixedPrice": "15000"}], "retailPrice": "22000"}	::1	2026-04-16 20:40:22.704
cmo1y1m27000yvxi4fnubvtt4	cmo1u51iy0000vxgku42az9lu	poka@poka.us	UPDATE	Product	cmo1xvojj007rvxvo06bi43g4	{"id": "cmo1xvojj007rvxvo06bi43g4", "sku": "XUANLOCKHD13", "name": "Gói xông nhà", "unit": "Gói", "weight": null, "isActive": true, "costPrice": null, "createdAt": "2026-04-16T20:35:57.824Z", "updatedAt": "2026-04-16T20:35:57.824Z", "categoryId": "cmo1xc0tk0000vxp0m1od0byy", "dimensions": null, "retailPrice": "22000"}	{"id": "cmo1xvojj007rvxvo06bi43g4", "sku": "XUANLOCKHD13", "name": "Gói xông nhà", "unit": "Gói", "weight": null, "category": {"id": "cmo1xybh10000vxi4nigilgz5", "code": "XLKHD", "name": "Xuân Lộc KHD", "isActive": true, "createdAt": "2026-04-16T20:38:00.854Z", "updatedAt": "2026-04-16T20:38:00.854Z", "description": null}, "isActive": true, "costPrice": null, "createdAt": "2026-04-16T20:35:57.824Z", "updatedAt": "2026-04-16T20:40:34.516Z", "categoryId": "cmo1xybh10000vxi4nigilgz5", "dimensions": null, "groupPrices": [{"id": "cmo1y1m1l000vvxi46udw7moo", "groupId": "cmo1xc10u000hvxp0dapryn3r", "createdAt": "2026-04-16T20:40:34.521Z", "productId": "cmo1xvojj007rvxvo06bi43g4", "updatedAt": "2026-04-16T20:40:34.521Z", "fixedPrice": "15000"}, {"id": "cmo1y1m1l000wvxi49dmu6ncr", "groupId": "cmo1xc11v000lvxp07r6uljko", "createdAt": "2026-04-16T20:40:34.521Z", "productId": "cmo1xvojj007rvxvo06bi43g4", "updatedAt": "2026-04-16T20:40:34.521Z", "fixedPrice": "15000"}, {"id": "cmo1y1m1l000uvxi4vvuo68hf", "groupId": "cmo1xsgrt0022vxv8sd7cckj7", "createdAt": "2026-04-16T20:40:34.521Z", "productId": "cmo1xvojj007rvxvo06bi43g4", "updatedAt": "2026-04-16T20:40:34.521Z", "fixedPrice": "15000"}], "retailPrice": "22000"}	::1	2026-04-16 20:40:34.544
cmo1y1ul4001bvxi4gxewj66q	cmo1u51iy0000vxgku42az9lu	poka@poka.us	UPDATE	Product	cmo1xvosw009hvxvoxk195tqm	{"id": "cmo1xvosw009hvxvoxk195tqm", "sku": "XUANLOCKHD12", "name": "Rượu nếp cẩm vắt", "unit": "Lít", "weight": null, "isActive": true, "costPrice": null, "createdAt": "2026-04-16T20:35:58.160Z", "updatedAt": "2026-04-16T20:35:58.160Z", "categoryId": "cmo1xc0tk0000vxp0m1od0byy", "dimensions": null, "retailPrice": "258000"}	{"id": "cmo1xvosw009hvxvoxk195tqm", "sku": "XUANLOCKHD12", "name": "Rượu nếp cẩm vắt", "unit": "Lít", "weight": null, "category": {"id": "cmo1xybh10000vxi4nigilgz5", "code": "XLKHD", "name": "Xuân Lộc KHD", "isActive": true, "createdAt": "2026-04-16T20:38:00.854Z", "updatedAt": "2026-04-16T20:38:00.854Z", "description": null}, "isActive": true, "costPrice": null, "createdAt": "2026-04-16T20:35:58.160Z", "updatedAt": "2026-04-16T20:40:45.563Z", "categoryId": "cmo1xybh10000vxi4nigilgz5", "dimensions": null, "groupPrices": [{"id": "cmo1y1ukg0010vxi4zat1i8qv", "groupId": "cmo1xc10u000hvxp0dapryn3r", "createdAt": "2026-04-16T20:40:45.569Z", "productId": "cmo1xvosw009hvxvoxk195tqm", "updatedAt": "2026-04-16T20:40:45.569Z", "fixedPrice": "180000"}, {"id": "cmo1y1ukg0011vxi45z06d37w", "groupId": "cmo1xc119000jvxp01snwxzoa", "createdAt": "2026-04-16T20:40:45.569Z", "productId": "cmo1xvosw009hvxvoxk195tqm", "updatedAt": "2026-04-16T20:40:45.569Z", "fixedPrice": "180000"}, {"id": "cmo1y1ukg0012vxi4qxl82988", "groupId": "cmo1xc11n000kvxp0g32oj3wx", "createdAt": "2026-04-16T20:40:45.569Z", "productId": "cmo1xvosw009hvxvoxk195tqm", "updatedAt": "2026-04-16T20:40:45.569Z", "fixedPrice": "180000"}, {"id": "cmo1y1ukg0013vxi42prtoya6", "groupId": "cmo1xc11v000lvxp07r6uljko", "createdAt": "2026-04-16T20:40:45.569Z", "productId": "cmo1xvosw009hvxvoxk195tqm", "updatedAt": "2026-04-16T20:40:45.569Z", "fixedPrice": "180000"}, {"id": "cmo1y1ukg0014vxi45jzrjjtv", "groupId": "cmo1xc12i000ovxp01nisgvnu", "createdAt": "2026-04-16T20:40:45.569Z", "productId": "cmo1xvosw009hvxvoxk195tqm", "updatedAt": "2026-04-16T20:40:45.569Z", "fixedPrice": "180000"}, {"id": "cmo1y1ukg0015vxi4abwn14ph", "groupId": "cmo1xc12q000pvxp0kun82k4l", "createdAt": "2026-04-16T20:40:45.569Z", "productId": "cmo1xvosw009hvxvoxk195tqm", "updatedAt": "2026-04-16T20:40:45.569Z", "fixedPrice": "180000"}, {"id": "cmo1y1ukg0016vxi42mm86m7k", "groupId": "cmo1xc12y000qvxp0uqc7d8d8", "createdAt": "2026-04-16T20:40:45.569Z", "productId": "cmo1xvosw009hvxvoxk195tqm", "updatedAt": "2026-04-16T20:40:45.569Z", "fixedPrice": "180000"}, {"id": "cmo1y1ukg0017vxi4kkphlspl", "groupId": "cmo1xc138000rvxp0r16wi1bz", "createdAt": "2026-04-16T20:40:45.569Z", "productId": "cmo1xvosw009hvxvoxk195tqm", "updatedAt": "2026-04-16T20:40:45.569Z", "fixedPrice": "180000"}, {"id": "cmo1y1ukg0018vxi4r8a6d4ek", "groupId": "cmo1xc13g000svxp0tbndc1wg", "createdAt": "2026-04-16T20:40:45.569Z", "productId": "cmo1xvosw009hvxvoxk195tqm", "updatedAt": "2026-04-16T20:40:45.569Z", "fixedPrice": "180000"}, {"id": "cmo1y1ukg0019vxi428hkhqdo", "groupId": "cmo1xc13o000tvxp0alok8jeb", "createdAt": "2026-04-16T20:40:45.569Z", "productId": "cmo1xvosw009hvxvoxk195tqm", "updatedAt": "2026-04-16T20:40:45.569Z", "fixedPrice": "180000"}, {"id": "cmo1y1ukg000zvxi4gyc7iy01", "groupId": "cmo1xsgrt0022vxv8sd7cckj7", "createdAt": "2026-04-16T20:40:45.569Z", "productId": "cmo1xvosw009hvxvoxk195tqm", "updatedAt": "2026-04-16T20:40:45.569Z", "fixedPrice": "180000"}], "retailPrice": "258000"}	::1	2026-04-16 20:40:45.592
cmo1y3af4001wvxi4g4bs17n9	cmo1u51iy0000vxgku42az9lu	poka@poka.us	UPDATE	Product	cmo1xvp3100cbvxvoyq2k7bf6	{"id": "cmo1xvp3100cbvxvoyq2k7bf6", "sku": "XUANLOCKHD7", "name": "Rượu trắng 35 độ", "unit": "Kg", "weight": null, "isActive": true, "costPrice": null, "createdAt": "2026-04-16T20:35:58.525Z", "updatedAt": "2026-04-16T20:35:58.525Z", "categoryId": "cmo1xc0tk0000vxp0m1od0byy", "dimensions": null, "retailPrice": "45000"}	{"id": "cmo1xvp3100cbvxvoyq2k7bf6", "sku": "XUANLOCKHD7", "name": "Rượu trắng 35 độ", "unit": "Kg", "weight": null, "category": {"id": "cmo1xybh10000vxi4nigilgz5", "code": "XLKHD", "name": "Xuân Lộc KHD", "isActive": true, "createdAt": "2026-04-16T20:38:00.854Z", "updatedAt": "2026-04-16T20:38:00.854Z", "description": null}, "isActive": true, "costPrice": null, "createdAt": "2026-04-16T20:35:58.525Z", "updatedAt": "2026-04-16T20:41:52.743Z", "categoryId": "cmo1xybh10000vxi4nigilgz5", "dimensions": null, "groupPrices": [], "retailPrice": "45000"}	::1	2026-04-16 20:41:52.768
cmo1y23fg001ovxi4qqu2vbte	cmo1u51iy0000vxgku42az9lu	poka@poka.us	UPDATE	Product	cmo1xvovh00a5vxvoqy6q6jvq	{"id": "cmo1xvovh00a5vxvoqy6q6jvq", "sku": "XUANLOCKHD11", "name": "Rượu nếp trắng vắt (chai nhựa 500ml)", "unit": "Lít", "weight": null, "isActive": true, "costPrice": null, "createdAt": "2026-04-16T20:35:58.253Z", "updatedAt": "2026-04-16T20:35:58.253Z", "categoryId": "cmo1xc0tk0000vxp0m1od0byy", "dimensions": null, "retailPrice": "229000"}	{"id": "cmo1xvovh00a5vxvoqy6q6jvq", "sku": "XUANLOCKHD11", "name": "Rượu nếp trắng vắt (chai nhựa 500ml)", "unit": "Lít", "weight": null, "category": {"id": "cmo1xybh10000vxi4nigilgz5", "code": "XLKHD", "name": "Xuân Lộc KHD", "isActive": true, "createdAt": "2026-04-16T20:38:00.854Z", "updatedAt": "2026-04-16T20:38:00.854Z", "description": null}, "isActive": true, "costPrice": null, "createdAt": "2026-04-16T20:35:58.253Z", "updatedAt": "2026-04-16T20:40:57.008Z", "categoryId": "cmo1xybh10000vxi4nigilgz5", "dimensions": null, "groupPrices": [{"id": "cmo1y23eg001dvxi4frrbn01n", "groupId": "cmo1xc10u000hvxp0dapryn3r", "createdAt": "2026-04-16T20:40:57.016Z", "productId": "cmo1xvovh00a5vxvoqy6q6jvq", "updatedAt": "2026-04-16T20:40:57.016Z", "fixedPrice": "160000"}, {"id": "cmo1y23eg001evxi43hlj0xcn", "groupId": "cmo1xc119000jvxp01snwxzoa", "createdAt": "2026-04-16T20:40:57.016Z", "productId": "cmo1xvovh00a5vxvoqy6q6jvq", "updatedAt": "2026-04-16T20:40:57.016Z", "fixedPrice": "160000"}, {"id": "cmo1y23eg001fvxi4nid7aq25", "groupId": "cmo1xc11n000kvxp0g32oj3wx", "createdAt": "2026-04-16T20:40:57.016Z", "productId": "cmo1xvovh00a5vxvoqy6q6jvq", "updatedAt": "2026-04-16T20:40:57.016Z", "fixedPrice": "160000"}, {"id": "cmo1y23eg001gvxi4z0w2rtfw", "groupId": "cmo1xc11v000lvxp07r6uljko", "createdAt": "2026-04-16T20:40:57.016Z", "productId": "cmo1xvovh00a5vxvoqy6q6jvq", "updatedAt": "2026-04-16T20:40:57.016Z", "fixedPrice": "160000"}, {"id": "cmo1y23eg001hvxi4hf5lw6vn", "groupId": "cmo1xc12i000ovxp01nisgvnu", "createdAt": "2026-04-16T20:40:57.016Z", "productId": "cmo1xvovh00a5vxvoqy6q6jvq", "updatedAt": "2026-04-16T20:40:57.016Z", "fixedPrice": "160000"}, {"id": "cmo1y23eg001ivxi4za8299h9", "groupId": "cmo1xc12q000pvxp0kun82k4l", "createdAt": "2026-04-16T20:40:57.016Z", "productId": "cmo1xvovh00a5vxvoqy6q6jvq", "updatedAt": "2026-04-16T20:40:57.016Z", "fixedPrice": "160000"}, {"id": "cmo1y23eg001jvxi48e5xug2o", "groupId": "cmo1xc12y000qvxp0uqc7d8d8", "createdAt": "2026-04-16T20:40:57.016Z", "productId": "cmo1xvovh00a5vxvoqy6q6jvq", "updatedAt": "2026-04-16T20:40:57.016Z", "fixedPrice": "160000"}, {"id": "cmo1y23eg001kvxi4xsddjub8", "groupId": "cmo1xc138000rvxp0r16wi1bz", "createdAt": "2026-04-16T20:40:57.016Z", "productId": "cmo1xvovh00a5vxvoqy6q6jvq", "updatedAt": "2026-04-16T20:40:57.016Z", "fixedPrice": "160000"}, {"id": "cmo1y23eg001lvxi4linqoiv7", "groupId": "cmo1xc13g000svxp0tbndc1wg", "createdAt": "2026-04-16T20:40:57.016Z", "productId": "cmo1xvovh00a5vxvoqy6q6jvq", "updatedAt": "2026-04-16T20:40:57.016Z", "fixedPrice": "160000"}, {"id": "cmo1y23eg001mvxi4lnc4b3nl", "groupId": "cmo1xc13o000tvxp0alok8jeb", "createdAt": "2026-04-16T20:40:57.016Z", "productId": "cmo1xvovh00a5vxvoqy6q6jvq", "updatedAt": "2026-04-16T20:40:57.016Z", "fixedPrice": "160000"}, {"id": "cmo1y23eg001cvxi4whmitzef", "groupId": "cmo1xsgrt0022vxv8sd7cckj7", "createdAt": "2026-04-16T20:40:57.016Z", "productId": "cmo1xvovh00a5vxvoqy6q6jvq", "updatedAt": "2026-04-16T20:40:57.016Z", "fixedPrice": "160000"}], "retailPrice": "229000"}	::1	2026-04-16 20:40:57.052
cmo1y2hpw001qvxi4boxc6jl3	cmo1u51iy0000vxgku42az9lu	poka@poka.us	UPDATE	Product	cmo1xvoy000atvxvon6jnen5l	{"id": "cmo1xvoy000atvxvon6jnen5l", "sku": "XUANLOCKHD10", "name": "Bánh chưng", "unit": "cây", "weight": null, "isActive": true, "costPrice": null, "createdAt": "2026-04-16T20:35:58.344Z", "updatedAt": "2026-04-16T20:35:58.344Z", "categoryId": "cmo1xc0tk0000vxp0m1od0byy", "dimensions": null, "retailPrice": "0"}	{"id": "cmo1xvoy000atvxvon6jnen5l", "sku": "XUANLOCKHD10", "name": "Bánh chưng", "unit": "cây", "weight": null, "category": {"id": "cmo1xybh10000vxi4nigilgz5", "code": "XLKHD", "name": "Xuân Lộc KHD", "isActive": true, "createdAt": "2026-04-16T20:38:00.854Z", "updatedAt": "2026-04-16T20:38:00.854Z", "description": null}, "isActive": true, "costPrice": null, "createdAt": "2026-04-16T20:35:58.344Z", "updatedAt": "2026-04-16T20:41:15.541Z", "categoryId": "cmo1xybh10000vxi4nigilgz5", "dimensions": null, "groupPrices": [], "retailPrice": "0"}	::1	2026-04-16 20:41:15.572
cmo1y2rro001svxi4ziizlnk5	cmo1u51iy0000vxgku42az9lu	poka@poka.us	UPDATE	Product	cmo1xvoym00avvxvoh0mmx9ij	{"id": "cmo1xvoym00avvxvoh0mmx9ij", "sku": "XUANLOCKHD9", "name": "Rượu nếp trắng", "unit": "Lít", "weight": null, "isActive": true, "costPrice": null, "createdAt": "2026-04-16T20:35:58.366Z", "updatedAt": "2026-04-16T20:35:58.366Z", "categoryId": "cmo1xc0tk0000vxp0m1od0byy", "dimensions": null, "retailPrice": "70000"}	{"id": "cmo1xvoym00avvxvoh0mmx9ij", "sku": "XUANLOCKHD9", "name": "Rượu nếp trắng", "unit": "Lít", "weight": null, "category": {"id": "cmo1xybh10000vxi4nigilgz5", "code": "XLKHD", "name": "Xuân Lộc KHD", "isActive": true, "createdAt": "2026-04-16T20:38:00.854Z", "updatedAt": "2026-04-16T20:38:00.854Z", "description": null}, "isActive": true, "costPrice": null, "createdAt": "2026-04-16T20:35:58.366Z", "updatedAt": "2026-04-16T20:41:28.557Z", "categoryId": "cmo1xybh10000vxi4nigilgz5", "dimensions": null, "groupPrices": [], "retailPrice": "70000"}	::1	2026-04-16 20:41:28.596
cmo1y31pl001uvxi4wzxqiu72	cmo1u51iy0000vxgku42az9lu	poka@poka.us	UPDATE	Product	cmo1xvp0n00bjvxvoeweqgumf	{"id": "cmo1xvp0n00bjvxvoeweqgumf", "sku": "XUANLOCKHD8", "name": "Rượu trắng 40 độ", "unit": "Kg", "weight": null, "isActive": true, "costPrice": null, "createdAt": "2026-04-16T20:35:58.439Z", "updatedAt": "2026-04-16T20:35:58.439Z", "categoryId": "cmo1xc0tk0000vxp0m1od0byy", "dimensions": null, "retailPrice": "55000"}	{"id": "cmo1xvp0n00bjvxvoeweqgumf", "sku": "XUANLOCKHD8", "name": "Rượu trắng 40 độ", "unit": "Kg", "weight": null, "category": {"id": "cmo1xybh10000vxi4nigilgz5", "code": "XLKHD", "name": "Xuân Lộc KHD", "isActive": true, "createdAt": "2026-04-16T20:38:00.854Z", "updatedAt": "2026-04-16T20:38:00.854Z", "description": null}, "isActive": true, "costPrice": null, "createdAt": "2026-04-16T20:35:58.439Z", "updatedAt": "2026-04-16T20:41:41.455Z", "categoryId": "cmo1xybh10000vxi4nigilgz5", "dimensions": null, "groupPrices": [], "retailPrice": "55000"}	::1	2026-04-16 20:41:41.481
cmo1y3l24001yvxi4vypuh5yy	cmo1u51iy0000vxgku42az9lu	poka@poka.us	UPDATE	Product	cmo1xvp5q00d3vxvotpf1yp6m	{"id": "cmo1xvp5q00d3vxvotpf1yp6m", "sku": "XUANLOCKHD6", "name": "Rượu nếp trắng 40 độ", "unit": "Kg", "weight": null, "isActive": true, "costPrice": null, "createdAt": "2026-04-16T20:35:58.622Z", "updatedAt": "2026-04-16T20:35:58.622Z", "categoryId": "cmo1xc0tk0000vxp0m1od0byy", "dimensions": null, "retailPrice": "65000"}	{"id": "cmo1xvp5q00d3vxvotpf1yp6m", "sku": "XUANLOCKHD6", "name": "Rượu nếp trắng 40 độ", "unit": "Kg", "weight": null, "category": {"id": "cmo1xybh10000vxi4nigilgz5", "code": "XLKHD", "name": "Xuân Lộc KHD", "isActive": true, "createdAt": "2026-04-16T20:38:00.854Z", "updatedAt": "2026-04-16T20:38:00.854Z", "description": null}, "isActive": true, "costPrice": null, "createdAt": "2026-04-16T20:35:58.622Z", "updatedAt": "2026-04-16T20:42:06.503Z", "categoryId": "cmo1xybh10000vxi4nigilgz5", "dimensions": null, "groupPrices": [], "retailPrice": "65000"}	::1	2026-04-16 20:42:06.556
cmo1y7ibo0020vxi4mo5oq2rk	cmo1u51iy0000vxgku42az9lu	poka@poka.us	DELETE	AllProducts	unknown	null	{"message": "All products and their prices have been deleted.", "success": true}	::1	2026-04-16 20:45:09.636
cmo1yamf60004vxu05refmi0n	cmo1u51iy0000vxgku42az9lu	poka@poka.us	UPDATE	Product	cmo1y94xh02vvvxt0ag84ao9n	{"id": "cmo1y94xh02vvvxt0ag84ao9n", "sku": "MFKHD12", "name": "Gạo thơm xát trắng - túi 5kg (Hàng chương trình 15/1-25/1)", "unit": "Túi", "weight": null, "isActive": true, "costPrice": null, "createdAt": "2026-04-16T20:46:25.590Z", "updatedAt": "2026-04-16T20:46:25.590Z", "categoryId": null, "dimensions": null, "retailPrice": "170000"}	{"id": "cmo1y94xh02vvvxt0ag84ao9n", "sku": "MFKHD12", "name": "Gạo thơm xát trắng - túi 5kg (Hàng chương trình 15/1-25/1)", "unit": "Túi", "weight": null, "category": {"id": "cmo1xc0vw0004vxp0uzuqvrgw", "code": "MFKHD", "name": "Moutain Farmer KHD", "isActive": true, "createdAt": "2026-04-16T20:20:40.701Z", "updatedAt": "2026-04-16T20:30:09.963Z", "description": null}, "isActive": true, "costPrice": null, "createdAt": "2026-04-16T20:46:25.590Z", "updatedAt": "2026-04-16T20:47:34.869Z", "categoryId": "cmo1xc0vw0004vxp0uzuqvrgw", "dimensions": null, "groupPrices": [{"id": "cmo1yameg0001vxu0uu8fwhqd", "groupId": "cmo1xc10u000hvxp0dapryn3r", "createdAt": "2026-04-16T20:47:34.889Z", "productId": "cmo1y94xh02vvvxt0ag84ao9n", "updatedAt": "2026-04-16T20:47:34.889Z", "fixedPrice": "120000"}, {"id": "cmo1yameg0002vxu0vg3i9wcq", "groupId": "cmo1xc11v000lvxp07r6uljko", "createdAt": "2026-04-16T20:47:34.889Z", "productId": "cmo1y94xh02vvvxt0ag84ao9n", "updatedAt": "2026-04-16T20:47:34.889Z", "fixedPrice": "120000"}, {"id": "cmo1yameg0000vxu0w2npup46", "groupId": "cmo1xsgrt0022vxv8sd7cckj7", "createdAt": "2026-04-16T20:47:34.889Z", "productId": "cmo1y94xh02vvvxt0ag84ao9n", "updatedAt": "2026-04-16T20:47:34.889Z", "fixedPrice": "120000"}], "retailPrice": "170000"}	::1	2026-04-16 20:47:34.914
cmo1yb1nh000avxu0rz1ooe0s	cmo1u51iy0000vxgku42az9lu	poka@poka.us	UPDATE	Product	cmo1y8urr0097vxt0o8a2z4m2	{"id": "cmo1y8urr0097vxt0o8a2z4m2", "sku": "MFKHD1", "name": "Khoai lang (cạp)", "unit": "Kg", "weight": null, "isActive": true, "costPrice": null, "createdAt": "2026-04-16T20:46:12.424Z", "updatedAt": "2026-04-16T20:46:12.424Z", "categoryId": null, "dimensions": null, "retailPrice": "48000"}	{"id": "cmo1y8urr0097vxt0o8a2z4m2", "sku": "MFKHD1", "name": "Khoai lang (cạp)", "unit": "Kg", "weight": null, "category": {"id": "cmo1xc0vw0004vxp0uzuqvrgw", "code": "MFKHD", "name": "Moutain Farmer KHD", "isActive": true, "createdAt": "2026-04-16T20:20:40.701Z", "updatedAt": "2026-04-16T20:30:09.963Z", "description": null}, "isActive": true, "costPrice": null, "createdAt": "2026-04-16T20:46:12.424Z", "updatedAt": "2026-04-16T20:47:54.625Z", "categoryId": "cmo1xc0vw0004vxp0uzuqvrgw", "dimensions": null, "groupPrices": [{"id": "cmo1yb1my0006vxu0fwlhsnc3", "groupId": "cmo1xc10u000hvxp0dapryn3r", "createdAt": "2026-04-16T20:47:54.634Z", "productId": "cmo1y8urr0097vxt0o8a2z4m2", "updatedAt": "2026-04-16T20:47:54.634Z", "fixedPrice": "33600"}, {"id": "cmo1yb1my0007vxu0zrd34iih", "groupId": "cmo1xc11v000lvxp07r6uljko", "createdAt": "2026-04-16T20:47:54.634Z", "productId": "cmo1y8urr0097vxt0o8a2z4m2", "updatedAt": "2026-04-16T20:47:54.634Z", "fixedPrice": "33600"}, {"id": "cmo1yb1my0008vxu0oly9cizj", "groupId": "cmo1xc13o000tvxp0alok8jeb", "createdAt": "2026-04-16T20:47:54.634Z", "productId": "cmo1y8urr0097vxt0o8a2z4m2", "updatedAt": "2026-04-16T20:47:54.634Z", "fixedPrice": "33600"}, {"id": "cmo1yb1my0005vxu0kxhs068a", "groupId": "cmo1xsgrt0022vxv8sd7cckj7", "createdAt": "2026-04-16T20:47:54.634Z", "productId": "cmo1y8urr0097vxt0o8a2z4m2", "updatedAt": "2026-04-16T20:47:54.634Z", "fixedPrice": "33600"}], "retailPrice": "48000"}	::1	2026-04-16 20:47:54.653
cmo1ybcr6000dvxu06kg22rep	cmo1u51iy0000vxgku42az9lu	poka@poka.us	UPDATE	Product	cmo1y8ur40093vxt06xl2rkss	{"id": "cmo1y8ur40093vxt06xl2rkss", "sku": "MFKHD2", "name": "Khoai lang (nhỏ)", "unit": "Kg", "weight": null, "isActive": true, "costPrice": null, "createdAt": "2026-04-16T20:46:12.400Z", "updatedAt": "2026-04-16T20:46:12.400Z", "categoryId": null, "dimensions": null, "retailPrice": "0"}	{"id": "cmo1y8ur40093vxt06xl2rkss", "sku": "MFKHD2", "name": "Khoai lang (nhỏ)", "unit": "Kg", "weight": null, "category": {"id": "cmo1xc0vw0004vxp0uzuqvrgw", "code": "MFKHD", "name": "Moutain Farmer KHD", "isActive": true, "createdAt": "2026-04-16T20:20:40.701Z", "updatedAt": "2026-04-16T20:30:09.963Z", "description": null}, "isActive": true, "costPrice": null, "createdAt": "2026-04-16T20:46:12.400Z", "updatedAt": "2026-04-16T20:48:09.007Z", "categoryId": "cmo1xc0vw0004vxp0uzuqvrgw", "dimensions": null, "groupPrices": [{"id": "cmo1ybcqh000bvxu0ph5qnku4", "groupId": "cmo1xsgrt0022vxv8sd7cckj7", "createdAt": "2026-04-16T20:48:09.017Z", "productId": "cmo1y8ur40093vxt06xl2rkss", "updatedAt": "2026-04-16T20:48:09.017Z", "fixedPrice": "42000"}], "retailPrice": "0"}	::1	2026-04-16 20:48:09.042
cmo1ybm30000fvxu0jvo1w6xt	cmo1u51iy0000vxgku42az9lu	poka@poka.us	UPDATE	Product	cmo1y8uqj0091vxt0mdhz294w	{"id": "cmo1y8uqj0091vxt0mdhz294w", "sku": "MFKHD3", "name": "Trứng gà (tặng)", "unit": "Cái", "weight": null, "isActive": true, "costPrice": null, "createdAt": "2026-04-16T20:46:12.379Z", "updatedAt": "2026-04-16T20:46:12.379Z", "categoryId": null, "dimensions": null, "retailPrice": "0"}	{"id": "cmo1y8uqj0091vxt0mdhz294w", "sku": "MFKHD3", "name": "Trứng gà (tặng)", "unit": "Cái", "weight": null, "category": {"id": "cmo1xc0vw0004vxp0uzuqvrgw", "code": "MFKHD", "name": "Moutain Farmer KHD", "isActive": true, "createdAt": "2026-04-16T20:20:40.701Z", "updatedAt": "2026-04-16T20:30:09.963Z", "description": null}, "isActive": true, "costPrice": null, "createdAt": "2026-04-16T20:46:12.379Z", "updatedAt": "2026-04-16T20:48:21.113Z", "categoryId": "cmo1xc0vw0004vxp0uzuqvrgw", "dimensions": null, "groupPrices": [], "retailPrice": "0"}	::1	2026-04-16 20:48:21.132
cmo1yc1hw000hvxu03whrapl9	cmo1u51iy0000vxgku42az9lu	poka@poka.us	UPDATE	Product	cmo1y8upt008vvxt0pcsob2i7	{"id": "cmo1y8upt008vvxt0pcsob2i7", "sku": "MFKHD4", "name": "Cám", "unit": "Kg", "weight": null, "isActive": true, "costPrice": null, "createdAt": "2026-04-16T20:46:12.353Z", "updatedAt": "2026-04-16T20:46:12.353Z", "categoryId": null, "dimensions": null, "retailPrice": "15000"}	{"id": "cmo1y8upt008vvxt0pcsob2i7", "sku": "MFKHD4", "name": "Cám", "unit": "Kg", "weight": null, "category": {"id": "cmo1xc0vw0004vxp0uzuqvrgw", "code": "MFKHD", "name": "Moutain Farmer KHD", "isActive": true, "createdAt": "2026-04-16T20:20:40.701Z", "updatedAt": "2026-04-16T20:30:09.963Z", "description": null}, "isActive": true, "costPrice": null, "createdAt": "2026-04-16T20:46:12.353Z", "updatedAt": "2026-04-16T20:48:41.084Z", "categoryId": "cmo1xc0vw0004vxp0uzuqvrgw", "dimensions": null, "groupPrices": [], "retailPrice": "15000"}	::1	2026-04-16 20:48:41.108
cmo1ycf5c000jvxu04lxilwjx	cmo1u51iy0000vxgku42az9lu	poka@poka.us	UPDATE	Product	cmo1y8upa008tvxt0c7jllzme	{"id": "cmo1y8upa008tvxt0c7jllzme", "sku": "MFKHD5", "name": "Đậu ve  (tặng)", "unit": "Kg", "weight": null, "isActive": true, "costPrice": null, "createdAt": "2026-04-16T20:46:12.335Z", "updatedAt": "2026-04-16T20:46:12.335Z", "categoryId": null, "dimensions": null, "retailPrice": "0"}	{"id": "cmo1y8upa008tvxt0c7jllzme", "sku": "MFKHD5", "name": "Đậu ve  (tặng)", "unit": "Kg", "weight": null, "category": {"id": "cmo1xc0vw0004vxp0uzuqvrgw", "code": "MFKHD", "name": "Moutain Farmer KHD", "isActive": true, "createdAt": "2026-04-16T20:20:40.701Z", "updatedAt": "2026-04-16T20:30:09.963Z", "description": null}, "isActive": true, "costPrice": null, "createdAt": "2026-04-16T20:46:12.335Z", "updatedAt": "2026-04-16T20:48:58.766Z", "categoryId": "cmo1xc0vw0004vxp0uzuqvrgw", "dimensions": null, "groupPrices": [], "retailPrice": "0"}	::1	2026-04-16 20:48:58.8
cmo1ycn4w000lvxu08v25cc2o	cmo1u51iy0000vxgku42az9lu	poka@poka.us	UPDATE	Product	cmo1y8uos008rvxt08zc3am4g	{"id": "cmo1y8uos008rvxt08zc3am4g", "sku": "MFKHD6", "name": "Dưa leo (tặng)", "unit": "Kg", "weight": null, "isActive": true, "costPrice": null, "createdAt": "2026-04-16T20:46:12.317Z", "updatedAt": "2026-04-16T20:46:12.317Z", "categoryId": null, "dimensions": null, "retailPrice": "0"}	{"id": "cmo1y8uos008rvxt08zc3am4g", "sku": "MFKHD6", "name": "Dưa leo (tặng)", "unit": "Kg", "weight": null, "category": {"id": "cmo1xc0vw0004vxp0uzuqvrgw", "code": "MFKHD", "name": "Moutain Farmer KHD", "isActive": true, "createdAt": "2026-04-16T20:20:40.701Z", "updatedAt": "2026-04-16T20:30:09.963Z", "description": null}, "isActive": true, "costPrice": null, "createdAt": "2026-04-16T20:46:12.317Z", "updatedAt": "2026-04-16T20:49:09.118Z", "categoryId": "cmo1xc0vw0004vxp0uzuqvrgw", "dimensions": null, "groupPrices": [], "retailPrice": "0"}	::1	2026-04-16 20:49:09.152
cmo1z5e2f0001vx7s7s3a9io6	cmo1u51iy0000vxgku42az9lu	poka@poka.us	CREATE	System	unknown	null	{"message": "Tiến trình Phục hồi thành công tuyệt đối! Đã bọc Transaction an toàn 100%.", "success": true}	::1	2026-04-16 21:11:30.423
cmo1z8lt20003vx7s39w20kcd	cmo1u51iy0000vxgku42az9lu	poka@poka.us	UPDATE	ProductCategory	cmo1xc0ux0001vxp0gekkc5lr	null	{"id": "cmo1xc0ux0001vxp0gekkc5lr", "code": "MOUNTAIN", "name": "Mountain Farmers", "isActive": true, "createdAt": "2026-04-16T20:20:40.666Z", "updatedAt": "2026-04-16T21:14:00.406Z", "description": null}	::1	2026-04-16 21:14:00.423
cmo1z8qsv0005vx7spnpf4ti9	cmo1u51iy0000vxgku42az9lu	poka@poka.us	UPDATE	ProductCategory	cmo1xc0vw0004vxp0uzuqvrgw	null	{"id": "cmo1xc0vw0004vxp0uzuqvrgw", "code": "MFKHD", "name": "Moutain Farmers KHD", "isActive": true, "createdAt": "2026-04-16T20:20:40.701Z", "updatedAt": "2026-04-16T21:14:06.887Z", "description": null}	::1	2026-04-16 21:14:06.896
cmo1z8wjb0007vx7soo1pc7zz	cmo1u51iy0000vxgku42az9lu	poka@poka.us	UPDATE	ProductCategory	cmo1xc0vw0004vxp0uzuqvrgw	null	{"id": "cmo1xc0vw0004vxp0uzuqvrgw", "code": "MFKHD", "name": "Mountain Farmers KHD", "isActive": true, "createdAt": "2026-04-16T20:20:40.701Z", "updatedAt": "2026-04-16T21:14:14.319Z", "description": null}	::1	2026-04-16 21:14:14.327
cmo2p89jn0001vxywrrdfkwrd	cmo1u51iy0000vxgku42az9lu	poka@poka.us	DELETE	Order	cmo20jotl0031vxcgh5y8b5c4	{"id": "cmo20jotl0031vxcgh5y8b5c4", "items": [{"id": "cmo20jotl0033vxcgpmeuffo8", "orderId": "cmo20jotl0031vxcgh5y8b5c4", "quantity": 1, "lineTotal": "1228000", "productId": "cmo1y9brx04i9vxt0r83rjz2h", "priceSource": "GROUP", "pricingNote": "Áp dụng giá nhóm", "lineDiscount": "0", "snapshotUnitPrice": "1228000", "snapshotProductSku": "XUANLOC63", "snapshotProductName": "Bơ đậu phộng (hủ 5kg)", "snapshotProductUnit": "Hủ"}, {"id": "cmo20jotl0034vxcgjyjitdf3", "orderId": "cmo20jotl0031vxcgh5y8b5c4", "quantity": 3, "lineTotal": "138000", "productId": "cmo1y8yww01j7vxt0ilppuk7e", "priceSource": "GROUP", "pricingNote": "Áp dụng giá nhóm", "lineDiscount": "0", "snapshotUnitPrice": "46000", "snapshotProductSku": "MOUNTAIN95", "snapshotProductName": "Gạo đỏ xưa xát trắng", "snapshotProductUnit": "Kg"}], "notes": null, "subtotal": "1366000", "createdAt": "2026-04-16T21:50:37.161Z", "updatedAt": "2026-04-16T21:50:37.161Z", "customerId": "cmo1xcrde06j0vxp0jimqyc67", "cancelNotes": null, "createdById": "cmo1u51iy0000vxgku42az9lu", "orderNumber": "ORD-20260417-6247-20", "shippingFee": "16000", "totalAmount": "1338000", "cancelReasonId": null, "deliveryStatus": "SHIPPING", "discountAmount": "44000", "snapshotCustomerName": "Lê Bích Sg", "snapshotCustomerPhone": null}	{"id": "cmo20jotl0031vxcgh5y8b5c4", "notes": null, "subtotal": "1366000", "createdAt": "2026-04-16T21:50:37.161Z", "updatedAt": "2026-04-16T21:50:37.161Z", "customerId": "cmo1xcrde06j0vxp0jimqyc67", "cancelNotes": null, "createdById": "cmo1u51iy0000vxgku42az9lu", "orderNumber": "ORD-20260417-6247-20", "shippingFee": "16000", "totalAmount": "1338000", "cancelReasonId": null, "deliveryStatus": "SHIPPING", "discountAmount": "44000", "snapshotCustomerName": "Lê Bích Sg", "snapshotCustomerPhone": null}	::1	2026-04-17 09:21:34.532
cmo2pq3530003vxywtgpt4wxk	cmo1u51iy0000vxgku42az9lu	poka@poka.us	STATUS_CHANGE	Order	cmo20jos7002mvxcg541hcucp	{"id": "cmo20jos7002mvxcg541hcucp", "items": [{"id": "cmo20jos7002ovxcghae0q197", "orderId": "cmo20jos7002mvxcg541hcucp", "quantity": 3, "lineTotal": "702000", "productId": "cmo1y9ff305a3vxt0cexvwprm", "priceSource": "GROUP", "pricingNote": "Áp dụng giá nhóm", "lineDiscount": "0", "snapshotUnitPrice": "234000", "snapshotProductSku": "HANGTUOI43", "snapshotProductName": "Thịt xay", "snapshotProductUnit": "Kg"}], "notes": null, "subtotal": "702000", "createdAt": "2026-04-16T21:50:37.111Z", "updatedAt": "2026-04-16T21:50:37.111Z", "customerId": "cmo1xcpwj05owvxp0t34hu8qo", "cancelNotes": null, "createdById": "cmo1u51iy0000vxgku42az9lu", "orderNumber": "ORD-20260417-4458-17", "shippingFee": "28000", "totalAmount": "693000", "cancelReasonId": null, "deliveryStatus": "PENDING", "discountAmount": "37000", "snapshotCustomerName": "Linh Mỹ Phạm (fb Chị Ly)", "snapshotCustomerPhone": null}	{"id": "cmo20jos7002mvxcg541hcucp", "notes": null, "subtotal": "702000", "createdAt": "2026-04-16T21:50:37.111Z", "updatedAt": "2026-04-17T09:35:26.036Z", "customerId": "cmo1xcpwj05owvxp0t34hu8qo", "cancelNotes": null, "createdById": "cmo1u51iy0000vxgku42az9lu", "orderNumber": "ORD-20260417-4458-17", "shippingFee": "28000", "totalAmount": "693000", "cancelReasonId": null, "deliveryStatus": "PROCESSING", "discountAmount": "37000", "snapshotCustomerName": "Linh Mỹ Phạm (fb Chị Ly)", "snapshotCustomerPhone": null}	::1	2026-04-17 09:35:26.055
cmo2r5z060011vx2kt21db0xz	cmo1u51iy0000vxgku42az9lu	poka@poka.us	CREATE	Order	cmo2r5yx30001vx2k82buwlj7	null	{"id": "cmo2r5yx30001vx2k82buwlj7", "items": [{"id": "cmo2r5yx30003vx2kwx90vsfl", "orderId": "cmo2r5yx30001vx2k82buwlj7", "quantity": 1, "lineTotal": "0", "productId": "cmo1y9h5d05l7vxt0f7a17q1u", "priceSource": "RETAIL", "pricingNote": "Áp dụng giá bán lẻ", "lineDiscount": "0", "snapshotUnitPrice": "0", "snapshotProductSku": "HANGTUOI1", "snapshotProductName": "Đầu heo", "snapshotProductUnit": "Kg"}, {"id": "cmo2r5yxb0004vx2klrqa5tl8", "orderId": "cmo2r5yx30001vx2k82buwlj7", "quantity": 1, "lineTotal": "0", "productId": "cmo1y9h4i05l5vxt0l3spcmsc", "priceSource": "RETAIL", "pricingNote": "Áp dụng giá bán lẻ", "lineDiscount": "0", "snapshotUnitPrice": "0", "snapshotProductSku": "HANGTUOI2", "snapshotProductName": "Lá xách (lá mía) heo", "snapshotProductUnit": "Kg"}, {"id": "cmo2r5yxb0005vx2kgn5frpzd", "orderId": "cmo2r5yx30001vx2k82buwlj7", "quantity": 1, "lineTotal": "234000", "productId": "cmo1y9h3805ktvxt0ng0y4ffn", "priceSource": "RETAIL", "pricingNote": "Áp dụng giá bán lẻ", "lineDiscount": "0", "snapshotUnitPrice": "234000", "snapshotProductSku": "HANGTUOI3", "snapshotProductName": "Sườn già", "snapshotProductUnit": "Kg"}, {"id": "cmo2r5yxb0006vx2kvrqiusvp", "orderId": "cmo2r5yx30001vx2k82buwlj7", "quantity": 1, "lineTotal": "0", "productId": "cmo1y9h2e05kpvxt0bux83ma7", "priceSource": "RETAIL", "pricingNote": "Áp dụng giá bán lẻ", "lineDiscount": "0", "snapshotUnitPrice": "0", "snapshotProductSku": "HANGTUOI4", "snapshotProductName": "Thăn bò", "snapshotProductUnit": "Kg"}, {"id": "cmo2r5yxb0007vx2klev1bcio", "orderId": "cmo2r5yx30001vx2k82buwlj7", "quantity": 1, "lineTotal": "0", "productId": "cmo1y9h1j05klvxt0dvqcfjo8", "priceSource": "RETAIL", "pricingNote": "Áp dụng giá bán lẻ", "lineDiscount": "0", "snapshotUnitPrice": "0", "snapshotProductSku": "HANGTUOI5", "snapshotProductName": "Xương ống lóc thịt", "snapshotProductUnit": "Kg"}, {"id": "cmo2r5yxb0008vx2kqczt1bu8", "orderId": "cmo2r5yx30001vx2k82buwlj7", "quantity": 1, "lineTotal": "0", "productId": "cmo1y9gzc05kfvxt0i29y35ln", "priceSource": "RETAIL", "pricingNote": "Áp dụng giá bán lẻ", "lineDiscount": "0", "snapshotUnitPrice": "0", "snapshotProductSku": "HANGTUOI7", "snapshotProductName": "Da heo", "snapshotProductUnit": "Kg"}, {"id": "cmo2r5yxb0009vx2kp7bu4f48", "orderId": "cmo2r5yx30001vx2k82buwlj7", "quantity": 1, "lineTotal": "0", "productId": "cmo1y9gyg05kdvxt0owdonlel", "priceSource": "RETAIL", "pricingNote": "Áp dụng giá bán lẻ", "lineDiscount": "0", "snapshotUnitPrice": "0", "snapshotProductSku": "HANGTUOI8", "snapshotProductName": "Má heo", "snapshotProductUnit": "Kg"}, {"id": "cmo2r5yxb000avx2kdxz9g0yf", "orderId": "cmo2r5yx30001vx2k82buwlj7", "quantity": 1, "lineTotal": "0", "productId": "cmo1y9gxk05kbvxt023w07vkw", "priceSource": "RETAIL", "pricingNote": "Áp dụng giá bán lẻ", "lineDiscount": "0", "snapshotUnitPrice": "0", "snapshotProductSku": "HANGTUOI9", "snapshotProductName": "Dạ trường", "snapshotProductUnit": "Kg"}, {"id": "cmo2r5yxc000bvx2k6mmc8q8s", "orderId": "cmo2r5yx30001vx2k82buwlj7", "quantity": 2, "lineTotal": "552000", "productId": "cmo1y9gvu05jzvxt00cl191dv", "priceSource": "RETAIL", "pricingNote": "Áp dụng giá bán lẻ", "lineDiscount": "0", "snapshotUnitPrice": "276000", "snapshotProductSku": "HANGTUOI10", "snapshotProductName": "Gà ác lớn", "snapshotProductUnit": "Con"}, {"id": "cmo2r5yxc000cvx2kx908e93v", "orderId": "cmo2r5yx30001vx2k82buwlj7", "quantity": 1, "lineTotal": "234000", "productId": "cmo1y9gu905jnvxt0931cc8sj", "priceSource": "RETAIL", "pricingNote": "Áp dụng giá bán lẻ", "lineDiscount": "0", "snapshotUnitPrice": "234000", "snapshotProductSku": "HANGTUOI11", "snapshotProductName": "Móng heo", "snapshotProductUnit": "Kg"}, {"id": "cmo2r5yxc000dvx2kynefge8m", "orderId": "cmo2r5yx30001vx2k82buwlj7", "quantity": 1, "lineTotal": "0", "productId": "cmo1y9gte05jlvxt04svy8md6", "priceSource": "RETAIL", "pricingNote": "Áp dụng giá bán lẻ", "lineDiscount": "0", "snapshotUnitPrice": "0", "snapshotProductSku": "HANGTUOI12", "snapshotProductName": "Nạm bò", "snapshotProductUnit": "Kg"}, {"id": "cmo2r5yxc000evx2k2q3jqfbz", "orderId": "cmo2r5yx30001vx2k82buwlj7", "quantity": 1, "lineTotal": "200000", "productId": "cmo1y9gri05j3vxt0fkx3m8xt", "priceSource": "GROUP", "pricingNote": "Áp dụng bảng giá tĩnh nhóm: TUANH", "lineDiscount": "0", "snapshotUnitPrice": "200000", "snapshotProductSku": "HANGTUOI13", "snapshotProductName": "Nạc thăn", "snapshotProductUnit": "Kg"}, {"id": "cmo2r5yxc000fvx2kqd3e0zzb", "orderId": "cmo2r5yx30001vx2k82buwlj7", "quantity": 1, "lineTotal": "0", "productId": "cmo1y9gqr05j1vxt0p45g6qn9", "priceSource": "RETAIL", "pricingNote": "Áp dụng giá bán lẻ", "lineDiscount": "0", "snapshotUnitPrice": "0", "snapshotProductSku": "HANGTUOI14", "snapshotProductName": "Phi lê bò", "snapshotProductUnit": "Kg"}, {"id": "cmo2r5yxc000gvx2koejv0gae", "orderId": "cmo2r5yx30001vx2k82buwlj7", "quantity": 1, "lineTotal": "0", "productId": "cmo1y9gpt05ixvxt0elddv8in", "priceSource": "RETAIL", "pricingNote": "Áp dụng giá bán lẻ", "lineDiscount": "0", "snapshotUnitPrice": "0", "snapshotProductSku": "HANGTUOI15", "snapshotProductName": "Bắp bò", "snapshotProductUnit": "Kg"}, {"id": "cmo2r5yxc000hvx2kn3easq26", "orderId": "cmo2r5yx30001vx2k82buwlj7", "quantity": 1, "lineTotal": "0", "productId": "cmo1y9gos05itvxt0yuubvcin", "priceSource": "RETAIL", "pricingNote": "Áp dụng giá bán lẻ", "lineDiscount": "0", "snapshotUnitPrice": "0", "snapshotProductSku": "HANGTUOI16", "snapshotProductName": "Đùi bò", "snapshotProductUnit": "Kg"}, {"id": "cmo2r5yxc000ivx2k85witef1", "orderId": "cmo2r5yx30001vx2k82buwlj7", "quantity": 1, "lineTotal": "170000", "productId": "cmo1y9gmv05ihvxt0y5t2goii", "priceSource": "RETAIL", "pricingNote": "Áp dụng giá bán lẻ", "lineDiscount": "0", "snapshotUnitPrice": "170000", "snapshotProductSku": "HANGTUOI17", "snapshotProductName": "Lòng tươi", "snapshotProductUnit": "Kg"}, {"id": "cmo2r5yxc000jvx2kojfynbst", "orderId": "cmo2r5yx30001vx2k82buwlj7", "quantity": 1, "lineTotal": "205000", "productId": "cmo1y9gg905h9vxt0xjaba1wb", "priceSource": "RETAIL", "pricingNote": "Áp dụng giá bán lẻ", "lineDiscount": "0", "snapshotUnitPrice": "205000", "snapshotProductSku": "HANGTUOI21", "snapshotProductName": "Mỡ heo + Công cắt, thắng mỡ, đóng hộp", "snapshotProductUnit": "Kg"}, {"id": "cmo2r5yxc000kvx2kbxr0nyy4", "orderId": "cmo2r5yx30001vx2k82buwlj7", "quantity": 1, "lineTotal": "244000", "productId": "cmo1y9gej05gxvxt0n30e1qz9", "priceSource": "RETAIL", "pricingNote": "Áp dụng giá bán lẻ", "lineDiscount": "0", "snapshotUnitPrice": "244000", "snapshotProductSku": "HANGTUOI22", "snapshotProductName": "Sườn cọng", "snapshotProductUnit": "Kg"}, {"id": "cmo2r5yxc000lvx2kz2ulpa71", "orderId": "cmo2r5yx30001vx2k82buwlj7", "quantity": 1, "lineTotal": "0", "productId": "cmo1y9gdm05gtvxt0uveu6b50", "priceSource": "RETAIL", "pricingNote": "Áp dụng giá bán lẻ", "lineDiscount": "0", "snapshotUnitPrice": "0", "snapshotProductSku": "HANGTUOI23", "snapshotProductName": "Công gà", "snapshotProductUnit": "Con"}, {"id": "cmo2r5yxc000mvx2ks5aair9m", "orderId": "cmo2r5yx30001vx2k82buwlj7", "quantity": 1, "lineTotal": "122000", "productId": "cmo1y9gby05ghvxt0kot7y3xw", "priceSource": "RETAIL", "pricingNote": "Áp dụng giá bán lẻ", "lineDiscount": "0", "snapshotUnitPrice": "122000", "snapshotProductSku": "HANGTUOI24", "snapshotProductName": "Chim bồ câu", "snapshotProductUnit": "Con"}, {"id": "cmo2r5yxc000nvx2k8xyyz4zf", "orderId": "cmo2r5yx30001vx2k82buwlj7", "quantity": 1, "lineTotal": "234000", "productId": "cmo1y9ga305g5vxt08e4v806g", "priceSource": "RETAIL", "pricingNote": "Áp dụng giá bán lẻ", "lineDiscount": "0", "snapshotUnitPrice": "234000", "snapshotProductSku": "HANGTUOI25", "snapshotProductName": "Vịt đồng", "snapshotProductUnit": "Con"}, {"id": "cmo2r5yxc000ovx2kj6ha8icn", "orderId": "cmo2r5yx30001vx2k82buwlj7", "quantity": 1, "lineTotal": "43000", "productId": "cmo1y9g2805epvxt0jv1rqp4r", "priceSource": "RETAIL", "pricingNote": "Áp dụng giá bán lẻ", "lineDiscount": "0", "snapshotUnitPrice": "43000", "snapshotProductSku": "HANGTUOI30", "snapshotProductName": "Óc", "snapshotProductUnit": "Bộ"}, {"id": "cmo2r5yxc000pvx2kmuzoe5pm", "orderId": "cmo2r5yx30001vx2k82buwlj7", "quantity": 1, "lineTotal": "234000", "productId": "cmo1y9g3x05f1vxt05i1vbfi2", "priceSource": "RETAIL", "pricingNote": "Áp dụng giá bán lẻ", "lineDiscount": "0", "snapshotUnitPrice": "234000", "snapshotProductSku": "HANGTUOI29", "snapshotProductName": "Gà ta", "snapshotProductUnit": "Kg"}, {"id": "cmo2r5yxc000qvx2kk8dkkhl7", "orderId": "cmo2r5yx30001vx2k82buwlj7", "quantity": 1, "lineTotal": "0", "productId": "cmo1y9g5h05fdvxt0ny4qv458", "priceSource": "RETAIL", "pricingNote": "Áp dụng giá bán lẻ", "lineDiscount": "0", "snapshotUnitPrice": "0", "snapshotProductSku": "HANGTUOI28", "snapshotProductName": "Gà bản", "snapshotProductUnit": "Kg"}, {"id": "cmo2r5yxc000rvx2k229aq52l", "orderId": "cmo2r5yx30001vx2k82buwlj7", "quantity": 1, "lineTotal": "170000", "productId": "cmo1y9fyi05dzvxt0dmjt8j8l", "priceSource": "RETAIL", "pricingNote": "Áp dụng giá bán lẻ", "lineDiscount": "0", "snapshotUnitPrice": "170000", "snapshotProductSku": "HANGTUOI32", "snapshotProductName": "Mỡ heo", "snapshotProductUnit": "Kg"}, {"id": "cmo2r5yxc000svx2ky1lphhre", "orderId": "cmo2r5yx30001vx2k82buwlj7", "quantity": 1, "lineTotal": "202000", "productId": "cmo1y9fm805bjvxt0o0ix17v8", "priceSource": "RETAIL", "pricingNote": "Áp dụng giá bán lẻ", "lineDiscount": "0", "snapshotUnitPrice": "202000", "snapshotProductSku": "HANGTUOI39", "snapshotProductName": "Bao tử", "snapshotProductUnit": "Kg"}, {"id": "cmo2r5yxc000tvx2k5t3w1m9b", "orderId": "cmo2r5yx30001vx2k82buwlj7", "quantity": 1, "lineTotal": "191000", "productId": "cmo1y9fke05b5vxt0lal4ug8f", "priceSource": "RETAIL", "pricingNote": "Áp dụng giá bán lẻ", "lineDiscount": "0", "snapshotUnitPrice": "191000", "snapshotProductSku": "HANGTUOI40", "snapshotProductName": "Dồi huyết", "snapshotProductUnit": "Kg"}, {"id": "cmo2r5yxc000uvx2k5t4z17do", "orderId": "cmo2r5yx30001vx2k82buwlj7", "quantity": 1, "lineTotal": "244000", "productId": "cmo1y9fin05arvxt0bo9wzwfi", "priceSource": "RETAIL", "pricingNote": "Áp dụng giá bán lẻ", "lineDiscount": "0", "snapshotUnitPrice": "244000", "snapshotProductSku": "HANGTUOI41", "snapshotProductName": "Sườn non", "snapshotProductUnit": "Kg"}, {"id": "cmo2r5yxc000vvx2k9j1f6azj", "orderId": "cmo2r5yx30001vx2k82buwlj7", "quantity": 1, "lineTotal": "234000", "productId": "cmo1y9fbe059dvxt04ijh3f89", "priceSource": "RETAIL", "pricingNote": "Áp dụng giá bán lẻ", "lineDiscount": "0", "snapshotUnitPrice": "234000", "snapshotProductSku": "HANGTUOI45", "snapshotProductName": "Đuôi", "snapshotProductUnit": "Kg"}, {"id": "cmo2r5yxc000wvx2klkty6tkf", "orderId": "cmo2r5yx30001vx2k82buwlj7", "quantity": 1, "lineTotal": "234000", "productId": "cmo1y9f9j058zvxt0sc7yz347", "priceSource": "RETAIL", "pricingNote": "Áp dụng giá bán lẻ", "lineDiscount": "0", "snapshotUnitPrice": "234000", "snapshotProductSku": "HANGTUOI46", "snapshotProductName": "Đùi", "snapshotProductUnit": "Kg"}, {"id": "cmo2r5yxc000xvx2kjehpcv7d", "orderId": "cmo2r5yx30001vx2k82buwlj7", "quantity": 1, "lineTotal": "234000", "productId": "cmo1y9f7u058lvxt0ibjm1o4g", "priceSource": "RETAIL", "pricingNote": "Áp dụng giá bán lẻ", "lineDiscount": "0", "snapshotUnitPrice": "234000", "snapshotProductSku": "HANGTUOI47", "snapshotProductName": "Cốt lết", "snapshotProductUnit": "Kg"}, {"id": "cmo2r5yxc000yvx2kr3p6m4yb", "orderId": "cmo2r5yx30001vx2k82buwlj7", "quantity": 1, "lineTotal": "234000", "productId": "cmo1y9f6c0587vxt0ia8x56c5", "priceSource": "RETAIL", "pricingNote": "Áp dụng giá bán lẻ", "lineDiscount": "0", "snapshotUnitPrice": "234000", "snapshotProductSku": "HANGTUOI48", "snapshotProductName": "Ba chỉ rút xương", "snapshotProductUnit": "Kg"}, {"id": "cmo2r5yxc000zvx2ks1o27hea", "orderId": "cmo2r5yx30001vx2k82buwlj7", "quantity": 1, "lineTotal": "0", "productId": "cmo1y9f5o0585vxt05vtsmqsi", "priceSource": "RETAIL", "pricingNote": "Áp dụng giá bán lẻ", "lineDiscount": "0", "snapshotUnitPrice": "0", "snapshotProductSku": "HANGTUOI49", "snapshotProductName": "Cuốn họng", "snapshotProductUnit": "Kg"}], "notes": "", "customer": {"id": "cmo1xcru106rsvxp03qzg9w5d", "code": "cmo1xcru106rtvxp087t73hnu", "notes": null, "phone": null, "groupId": "cmo1xc13o000tvxp0alok8jeb", "fullName": "Tú Anh", "isActive": true, "wardCode": null, "wardName": null, "createdAt": "2026-04-16T20:21:15.626Z", "updatedAt": "2026-04-16T20:21:15.626Z", "provinceCode": null, "provinceName": null, "addressDetail": null}, "subtotal": "4215000", "createdAt": "2026-04-17T10:15:46.679Z", "updatedAt": "2026-04-17T10:15:46.679Z", "customerId": "cmo1xcru106rsvxp03qzg9w5d", "cancelNotes": null, "createdById": "cmo1u51iy0000vxgku42az9lu", "orderNumber": "ORD-20260417-0020", "shippingFee": "0", "totalAmount": "4215000", "cancelReasonId": null, "deliveryStatus": "PENDING", "discountAmount": "0", "snapshotCustomerName": "Tú Anh", "snapshotCustomerPhone": null}	::1	2026-04-17 10:15:46.805
cmo2so1h60017vx2ku5tbh2nz	cmo1u51iy0000vxgku42az9lu	poka@poka.us	CREATE	Order	cmo2so1fz0013vx2kpm7fh9f6	null	{"id": "cmo2so1fz0013vx2kpm7fh9f6", "items": [{"id": "cmo2so1fz0015vx2k4ds901rh", "orderId": "cmo2so1fz0013vx2kpm7fh9f6", "quantity": 1, "lineTotal": "191000", "productId": "cmo1y9gjd05hvvxt0ye4ssip7", "priceSource": "GROUP", "pricingNote": "Áp dụng bảng giá tĩnh nhóm: P50", "lineDiscount": "0", "snapshotUnitPrice": "191000", "snapshotProductSku": "HANGTUOI19", "snapshotProductName": "Cật", "snapshotProductUnit": "Kg"}], "notes": "", "customer": {"id": "cmo1xcru706rwvxp0go180i04", "code": "cmo1xcru706rxvxp07jlwhqh6", "notes": null, "phone": null, "groupId": "cmo1xc10u000hvxp0dapryn3r", "fullName": "Cửa Hàng Rau Mầm", "isActive": true, "wardCode": null, "wardName": null, "createdAt": "2026-04-16T20:21:15.632Z", "updatedAt": "2026-04-16T20:21:15.632Z", "provinceCode": null, "provinceName": null, "addressDetail": null}, "subtotal": "191000", "createdAt": "2026-04-17T10:57:49.391Z", "updatedAt": "2026-04-17T10:57:49.391Z", "customerId": "cmo1xcru706rwvxp0go180i04", "cancelNotes": null, "createdById": "cmo1u51iy0000vxgku42az9lu", "orderNumber": "ORD-20260417-0021", "shippingFee": "0", "totalAmount": "191000", "cancelReasonId": null, "deliveryStatus": "PENDING", "discountAmount": "0", "snapshotCustomerName": "Cửa Hàng Rau Mầm", "snapshotCustomerPhone": null}	::1	2026-04-17 10:57:49.434
cmo2st3xa001evx2kscg3w19a	cmo1u51iy0000vxgku42az9lu	poka@poka.us	CREATE	Order	cmo2st3wj0019vx2kemr3m8jz	null	{"id": "cmo2st3wj0019vx2kemr3m8jz", "items": [{"id": "cmo2st3wj001bvx2k2n71q1bu", "orderId": "cmo2st3wj0019vx2kemr3m8jz", "quantity": 1, "lineTotal": "0", "productId": "cmo1y9h5d05l7vxt0f7a17q1u", "priceSource": "RETAIL", "pricingNote": "Áp dụng giá bán lẻ", "lineDiscount": "0", "snapshotUnitPrice": "0", "snapshotProductSku": "HANGTUOI1", "snapshotProductName": "Đầu heo", "snapshotProductUnit": "Kg"}, {"id": "cmo2st3wj001cvx2kq52tt7vr", "orderId": "cmo2st3wj0019vx2kemr3m8jz", "quantity": 1, "lineTotal": "234000", "productId": "cmo1y9h3805ktvxt0ng0y4ffn", "priceSource": "RETAIL", "pricingNote": "Áp dụng giá bán lẻ", "lineDiscount": "0", "snapshotUnitPrice": "234000", "snapshotProductSku": "HANGTUOI3", "snapshotProductName": "Sườn già", "snapshotProductUnit": "Kg"}], "notes": "", "customer": {"id": "cmo1xcru106rsvxp03qzg9w5d", "code": "cmo1xcru106rtvxp087t73hnu", "notes": null, "phone": null, "groupId": "cmo1xc13o000tvxp0alok8jeb", "fullName": "Tú Anh", "isActive": true, "wardCode": null, "wardName": null, "createdAt": "2026-04-16T20:21:15.626Z", "updatedAt": "2026-04-16T20:21:15.626Z", "provinceCode": null, "provinceName": null, "addressDetail": null}, "subtotal": "234000", "createdAt": "2026-04-17T11:01:45.860Z", "updatedAt": "2026-04-17T11:01:45.860Z", "customerId": "cmo1xcru106rsvxp03qzg9w5d", "cancelNotes": null, "createdById": "cmo1u51iy0000vxgku42az9lu", "orderNumber": "ORD-20260417-0022", "shippingFee": "0", "totalAmount": "234000", "cancelReasonId": null, "deliveryStatus": "PENDING", "discountAmount": "0", "snapshotCustomerName": "Tú Anh", "snapshotCustomerPhone": null}	::1	2026-04-17 11:01:45.887
cmo4hvj050003vxysrgvd1l5c	cmo1u51iy0000vxgku42az9lu	poka@poka.us	CREATE	Customer	cmo4hvizh0001vxyskk192cjq	null	{"id": "cmo4hvizh0001vxyskk192cjq", "code": "KH114231", "notes": null, "phone": null, "groupId": "cmo1u51jd0001vxgk5bl8jyb6", "fullName": "Poka P.", "isActive": true, "wardCode": "", "wardName": null, "createdAt": "2026-04-18T15:31:15.251Z", "updatedAt": "2026-04-18T15:31:15.251Z", "provinceCode": "", "provinceName": null, "addressDetail": ""}	::1	2026-04-18 15:31:15.317
cmo4hvp7g0005vxys4xqxrmpg	cmo1u51iy0000vxgku42az9lu	poka@poka.us	DELETE	Customer	cmo4hvizh0001vxyskk192cjq	{"id": "cmo4hvizh0001vxyskk192cjq", "code": "KH114231", "notes": null, "phone": null, "groupId": "cmo1u51jd0001vxgk5bl8jyb6", "fullName": "Poka P.", "isActive": true, "wardCode": "", "wardName": null, "createdAt": "2026-04-18T15:31:15.251Z", "updatedAt": "2026-04-18T15:31:15.251Z", "provinceCode": "", "provinceName": null, "addressDetail": ""}	{"id": "cmo4hvizh0001vxyskk192cjq", "code": "KH114231", "notes": null, "phone": null, "groupId": "cmo1u51jd0001vxgk5bl8jyb6", "fullName": "Poka P.", "isActive": true, "wardCode": "", "wardName": null, "createdAt": "2026-04-18T15:31:15.251Z", "updatedAt": "2026-04-18T15:31:15.251Z", "provinceCode": "", "provinceName": null, "addressDetail": ""}	::1	2026-04-18 15:31:23.356
cmo4j8ulf0008vxysj0xabx5n	cmo1u51iy0000vxgku42az9lu	poka@poka.us	CREATE	CustomerGroup	cmo4j8ukd0006vxys3u2cpk8y	null	{"id": "cmo4j8ukd0006vxys3u2cpk8y", "name": "khách 1", "createdAt": "2026-04-18T16:09:36.425Z", "isDefault": false, "priceType": "FIXED", "updatedAt": "2026-04-18T16:09:36.425Z", "description": "", "discountPercent": 0}	::1	2026-04-18 16:09:36.484
cmo4j93o2000avxys72g7nshe	cmo1u51iy0000vxgku42az9lu	poka@poka.us	DELETE	CustomerGroup	cmo4j8ukd0006vxys3u2cpk8y	null	{"id": "cmo4j8ukd0006vxys3u2cpk8y", "name": "khách 1", "createdAt": "2026-04-18T16:09:36.425Z", "isDefault": false, "priceType": "FIXED", "updatedAt": "2026-04-18T16:09:36.425Z", "description": "", "discountPercent": 0}	::1	2026-04-18 16:09:48.242
cmo4kci6t000hvxys88o42bzo	cmo1u51iy0000vxgku42az9lu	poka@poka.us	CREATE	Product	cmo4kci3w000cvxysfg5vcidx	null	{"id": "cmo4kci3w000cvxysfg5vcidx", "sku": "XUANLOC168", "name": "Sản phẩm mẫu", "unit": "Cái", "weight": null, "category": {"id": "cmo1xc0tk0000vxp0m1od0byy", "code": "XUANLOC", "name": "Xuân Lộc", "isActive": true, "createdAt": "2026-04-16T20:20:40.616Z", "updatedAt": "2026-04-16T20:20:40.616Z", "description": null}, "isActive": true, "costPrice": null, "createdAt": "2026-04-18T16:40:26.540Z", "updatedAt": "2026-04-18T16:40:26.540Z", "categoryId": "cmo1xc0tk0000vxp0m1od0byy", "dimensions": null, "groupPrices": [{"id": "cmo4kci3w000fvxys6j93az0t", "groupId": "cmo1xc10u000hvxp0dapryn3r", "createdAt": "2026-04-18T16:40:26.540Z", "productId": "cmo4kci3w000cvxysfg5vcidx", "updatedAt": "2026-04-18T16:40:26.540Z", "fixedPrice": "100000"}, {"id": "cmo4kci3w000evxysy2te6bd6", "groupId": "cmo1xsgrt0022vxv8sd7cckj7", "createdAt": "2026-04-18T16:40:26.540Z", "productId": "cmo4kci3w000cvxysfg5vcidx", "updatedAt": "2026-04-18T16:40:26.540Z", "fixedPrice": "200000"}], "retailPrice": "250000"}	::1	2026-04-18 16:40:26.645
cmo4kcqs4000jvxys3xdzkrml	cmo1u51iy0000vxgku42az9lu	poka@poka.us	DELETE	Product	cmo4kci3w000cvxysfg5vcidx	{"id": "cmo4kci3w000cvxysfg5vcidx", "sku": "XUANLOC168", "name": "Sản phẩm mẫu", "unit": "Cái", "weight": null, "isActive": true, "costPrice": null, "createdAt": "2026-04-18T16:40:26.540Z", "updatedAt": "2026-04-18T16:40:26.540Z", "categoryId": "cmo1xc0tk0000vxp0m1od0byy", "dimensions": null, "retailPrice": "250000"}	{"id": "cmo4kci3w000cvxysfg5vcidx", "sku": "XUANLOC168", "name": "Sản phẩm mẫu", "unit": "Cái", "weight": null, "isActive": true, "costPrice": null, "createdAt": "2026-04-18T16:40:26.540Z", "updatedAt": "2026-04-18T16:40:26.540Z", "categoryId": "cmo1xc0tk0000vxp0m1od0byy", "dimensions": null, "retailPrice": "250000"}	::1	2026-04-18 16:40:37.78
cmo4m3ier0001vx2stmuvuxgb	cmo1u51iy0000vxgku42az9lu	poka@poka.us	DELETE	AllOrders	unknown	null	{"message": "All orders have been deleted.", "success": true}	::1	2026-04-18 17:29:26.259
\.


--
-- Data for Name: cancel_reasons; Type: TABLE DATA; Schema: public; Owner: oms_user
--

COPY public.cancel_reasons (id, label, "isActive", "sortOrder", "createdAt") FROM stdin;
cmo1u52np0083vxgkxqcqcwjq	Sai số điện thoại	t	1	2026-04-16 18:51:17.557
cmo1u52od0084vxgkhlz8l4vv	Khách đổi ý	t	2	2026-04-16 18:51:17.581
cmo1u52ol0085vxgk57p8txb7	Hết hàng	t	3	2026-04-16 18:51:17.59
cmo1u52ou0086vxgklcuzwcy5	Lý do khác	t	99	2026-04-16 18:51:17.598
\.


--
-- Data for Name: company_settings; Type: TABLE DATA; Schema: public; Owner: oms_user
--

COPY public.company_settings (id, name, address, phone, email, "taxCode", "logoUrl", "bankInfo", "invoiceFooter", "treatBlankAsZero", "updatedAt") FROM stdin;
cmo1u52p70087vxgktmei8jmo	Công ty TNHH Mountain Farmers	Thôn Kon Jri, Xã Đăk Rơ Wa, Tỉnh Quảng Ngãi	0906 454 379	\N	\N	\N	\N	Cảm ơn quý khách đã tin tưởng!	f	2026-04-16 20:29:45.284
\.


--
-- Data for Name: customer_groups; Type: TABLE DATA; Schema: public; Owner: oms_user
--

COPY public.customer_groups (id, name, description, "priceType", "discountPercent", "isDefault", "createdAt", "updatedAt") FROM stdin;
cmo1u51jd0001vxgk5bl8jyb6	Khách lẻ	Nhóm khách hàng mặc định	PERCENTAGE	0	t	2026-04-16 18:51:16.105	2026-04-16 20:20:40.714
cmo1xc10u000hvxp0dapryn3r	P50	\N	FIXED	0	f	2026-04-16 20:20:40.878	2026-04-16 20:20:40.878
cmo1xc13o000tvxp0alok8jeb	TUANH		FIXED	0	f	2026-04-16 20:20:40.98	2026-04-16 20:32:17.538
cmo1xc13g000svxp0tbndc1wg	VYQN		FIXED	0	f	2026-04-16 20:20:40.972	2026-04-16 20:32:25.725
cmo1xc138000rvxp0r16wi1bz	TUANTHUY		FIXED	0	f	2026-04-16 20:20:40.964	2026-04-16 20:32:29.208
cmo1xc12y000qvxp0uqc7d8d8	VITA		FIXED	0	f	2026-04-16 20:20:40.954	2026-04-16 20:32:32.66
cmo1xc12q000pvxp0kun82k4l	TRAMQ10		FIXED	0	f	2026-04-16 20:20:40.947	2026-04-16 20:32:46.601
cmo1xc12i000ovxp01nisgvnu	HOA		FIXED	0	f	2026-04-16 20:20:40.939	2026-04-16 20:32:52.505
cmo1xc123000mvxp0ul7pkio2	ANHPR		FIXED	0	f	2026-04-16 20:20:40.923	2026-04-16 20:32:57.604
cmo1xc12a000nvxp0f1zf3aqg	NAMAN		FIXED	0	f	2026-04-16 20:20:40.931	2026-04-16 20:33:02.257
cmo1xc11v000lvxp07r6uljko	KHOADL		FIXED	0	f	2026-04-16 20:20:40.915	2026-04-16 20:33:07.883
cmo1xc11n000kvxp0g32oj3wx	GREENTECH		FIXED	0	f	2026-04-16 20:20:40.908	2026-04-16 20:33:14.481
cmo1xc119000jvxp01snwxzoa	LOYAL		FIXED	0	f	2026-04-16 20:20:40.893	2026-04-16 20:33:18.465
cmo1xsgrt0022vxv8sd7cckj7	Giá sỉ		FIXED	0	f	2026-04-16 20:33:27.786	2026-04-16 20:33:27.786
\.


--
-- Data for Name: customer_special_prices; Type: TABLE DATA; Schema: public; Owner: oms_user
--

COPY public.customer_special_prices (id, "customerId", "productId", price, notes, "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: customers; Type: TABLE DATA; Schema: public; Owner: oms_user
--

COPY public.customers (id, code, phone, "fullName", "groupId", "provinceCode", "provinceName", "wardCode", "wardName", "addressDetail", notes, "isActive", "createdAt", "updatedAt") FROM stdin;
cmo1xcpri05m4vxp0dabwmc2o	cmo1xcpri05m5vxp0hxy3hniy	\N	Trịnh Nguyệt (zalo 9988)	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:12.943	2026-04-16 20:21:12.943
cmo1xcprv05m8vxp0d24prpe3	cmo1xcprv05m9vxp0koo7fvbl	\N	Nongpro Đà Nẵng	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:12.955	2026-04-16 20:21:12.955
cmo1xcps305mcvxp0fl44zrlg	cmo1xcps305mdvxp0s96oopfo	\N	Hạnh Ninh Bình	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:12.963	2026-04-16 20:21:12.963
cmo1xcpsa05mgvxp0bq6q7cxv	cmo1xcpsa05mhvxp0c0eb6ilu	\N	Cỏ Mùa Hạ (ly)	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:12.97	2026-04-16 20:21:12.97
cmo1xcpsj05mkvxp0qezbvj5k	cmo1xcpsj05mlvxp0m2o05f4o	\N	Xivina (sg)	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:12.978	2026-04-16 20:21:12.978
cmo1xcpsr05movxp0kqh752pf	cmo1xcpsr05mpvxp0rz0jc9mg	\N	Bưu Điện (phương Thảo) - Fb Chị Ly	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:12.987	2026-04-16 20:21:12.987
cmo1xcpt005msvxp05gzguw4y	cmo1xcpt005mtvxp0cone0eow	\N	Nga Bình Thuận	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:12.996	2026-04-16 20:21:12.996
cmo1xcpt605mwvxp00r6jo63a	cmo1xcpt605mxvxp0z4847nsw	\N	Hà Lâm (sg)	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.003	2026-04-16 20:21:13.003
cmo1xcptd05n0vxp0d0ptlp5m	cmo1xcptd05n1vxp0wuvqz0fe	\N	Đỗ Thị Thu Trang (lớp Mầm Non Hoa Cỏ)	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.01	2026-04-16 20:21:13.01
cmo1xcptm05n4vxp0l72duxru	cmo1xcptm05n5vxp02ot2z2io	\N	Nguyễn Huyền Trang - Lào Cai	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.018	2026-04-16 20:21:13.018
cmo1xcpts05n8vxp0ey1z165e	cmo1xcpts05n9vxp05uo4ozhq	\N	Lam Yen Anh (nhóm Zl)	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.025	2026-04-16 20:21:13.025
cmo1xcpty05ncvxp0fxkiiycl	cmo1xcpty05ndvxp0ncoo332c	\N	Phương Hni	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.03	2026-04-16 20:21:13.03
cmo1xcpu405ngvxp07b6iq8zk	cmo1xcpu405nhvxp0y4mzkqbv	\N	Bưu Điện (quyên Nguyễn) - Fb Chị Ly	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.036	2026-04-16 20:21:13.036
cmo1xcpub05nkvxp09oswcwly	cmo1xcpub05nlvxp0xmijzos5	\N	Nhung Vu (fb Chị Ly)	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.043	2026-04-16 20:21:13.043
cmo1xcpui05novxp0vz23glty	cmo1xcpui05npvxp0ojdd5wgr	\N	Anni Sg (zalo 9988)	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.05	2026-04-16 20:21:13.05
cmo1xcpuo05nsvxp06fyj719j	cmo1xcpuo05ntvxp04vhi3u79	\N	Chị Sơn Ca (sg) - Zalo Nhóm	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.057	2026-04-16 20:21:13.057
cmo1xcpuv05nwvxp0cmezlywv	cmo1xcpuv05nxvxp081ljxren	\N	Thủy Tiên Đà Lạt (ly)	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.063	2026-04-16 20:21:13.063
cmo1xcpv105o0vxp0reqyh84f	cmo1xcpv105o1vxp03bbux2zn	\N	Tp Chay Bảo Ngọc Chân Mộc	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.069	2026-04-16 20:21:13.069
cmo1xcpv805o4vxp0f51pw3or	cmo1xcpv805o5vxp0vfu836lf	\N	Hộ Kd Hạnh Approves	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.076	2026-04-16 20:21:13.076
cmo1xcpve05o8vxp0fewehvrw	cmo1xcpve05o9vxp0d1xuvztw	\N	Thanh Nhàn Đà Nẵng	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.083	2026-04-16 20:21:13.083
cmo1xcpvl05ocvxp0df38ie2g	cmo1xcpvl05odvxp08ejl1w47	\N	Mì Tôm (phú Yên) - Zalo 9988	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.09	2026-04-16 20:21:13.09
cmo1xcpvs05ogvxp0gon5x8uo	cmo1xcpvs05ohvxp07l3yqqot	\N	Kim Phụng Đồng Nai	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.096	2026-04-16 20:21:13.096
cmo1xcpvy05okvxp0uw5n2kzm	cmo1xcpvy05olvxp0srdsqcse	\N	Bưu Điện (lê Thị Mỹ Hạnh) - Fb Chị Ly	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.102	2026-04-16 20:21:13.102
cmo1xcpw605oovxp0vgara2cp	cmo1xcpw605opvxp09r539f21	\N	Bưu Điện (bui Truc Quynh) - Fb Ly	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.11	2026-04-16 20:21:13.11
cmo1xcpwd05osvxp0yaf37g1z	cmo1xcpwd05otvxp0di9l67xc	\N	Hạt Cát Metta	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.117	2026-04-16 20:21:13.117
cmo1xcpwj05owvxp0t34hu8qo	cmo1xcpwj05oxvxp0dqgwgcmw	\N	Linh Mỹ Phạm (fb Chị Ly)	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.124	2026-04-16 20:21:13.124
cmo1xcpwq05p0vxp00icwd3ly	cmo1xcpwq05p1vxp03puxwhql	\N	Nam Phương Sg (zl)	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.13	2026-04-16 20:21:13.13
cmo1xcpwx05p4vxp0vwlkbmu0	cmo1xcpwx05p5vxp0q8gay9c4	\N	Hồng Lê (bơ)	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.137	2026-04-16 20:21:13.137
cmo1xcpx305p8vxp060vyvkk0	cmo1xcpx305p9vxp0n64wbe41	\N	Bưu Điện (ngan Hong) - Fb Bơ	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.144	2026-04-16 20:21:13.144
cmo1xcpxa05pcvxp0t4041aan	cmo1xcpxa05pdvxp021t74z9p	\N	Ni Phuong Minh Đn	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.15	2026-04-16 20:21:13.15
cmo1xcpxh05pgvxp0bqphxla1	cmo1xcpxh05phvxp0dxabafks	\N	Bưu Điện (gia Đình Chị Thắm) - Fb Chị Ly	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.157	2026-04-16 20:21:13.157
cmo1xcpxn05pkvxp0xfkbp9cl	cmo1xcpxn05plvxp03h4wr563	\N	Bưu Điện (julia Trịnh) - Fb Chị Ly	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.164	2026-04-16 20:21:13.164
cmo1xcpxu05povxp0sbv8yy58	cmo1xcpxu05ppvxp0d3dgijtt	\N	Bưu Điện (trần Linh) - Fb Chị Ly	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.17	2026-04-16 20:21:13.17
cmo1xcpy105psvxp0xm07f9kc	cmo1xcpy105ptvxp0fuv1kqvm	\N	Bưu Điện (ngọc Liên) - Zalo 9988	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.177	2026-04-16 20:21:13.177
cmo1xcpyb05pwvxp0versj127	cmo1xcpyb05pxvxp0ux7s9yfe	\N	Bưu Điện (nguyễn Quyên) - Fb Chị Ly	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.187	2026-04-16 20:21:13.187
cmo1xcpyi05q0vxp0nsh4mgys	cmo1xcpyi05q1vxp010ldqg9y	\N	Bưu Điện (loan Phạm) - Fb Chị Bơ	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.194	2026-04-16 20:21:13.194
cmo1xcpyp05q4vxp0k7pigk6b	cmo1xcpyp05q5vxp0n3duvkyk	\N	Trâm Phan Bình Phước	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.202	2026-04-16 20:21:13.202
cmo1xcpyw05q8vxp0ajbyfmhi	cmo1xcpyw05q9vxp0fh91h25e	\N	Bưu Điện (hạnh Nguyên) - Fb Chị Ly	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.209	2026-04-16 20:21:13.209
cmo1xcpz205qcvxp0rbaq0gbm	cmo1xcpz205qdvxp0k17celzl	\N	Phạm Thủy - Biên Hòa	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.214	2026-04-16 20:21:13.214
cmo1xcpz805qgvxp0yvm1yq8c	cmo1xcpz805qhvxp03ivg7mce	\N	Thịnh (xl)	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.221	2026-04-16 20:21:13.221
cmo1xcpzf05qkvxp08yz2l7wd	cmo1xcpzf05qlvxp027ueqyn5	\N	Hàn Thu	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.227	2026-04-16 20:21:13.227
cmo1xcpzm05qovxp0q6hc8l84	cmo1xcpzm05qpvxp0wrnrg9sy	\N	Hiếu Phan Rang	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.234	2026-04-16 20:21:13.234
cmo1xcpzs05qsvxp02m2oboua	cmo1xcpzs05qtvxp00spyhvx0	\N	Vân Hương Hà Nội	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.241	2026-04-16 20:21:13.241
cmo1xcpzy05qwvxp0vmt9huf6	cmo1xcpzy05qxvxp0s13urqhz	\N	Thảo Taiyaki (bình Thuận)	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.247	2026-04-16 20:21:13.247
cmo1xcq0505r0vxp0fsrqkub8	cmo1xcq0505r1vxp09gfgckbe	\N	Hương Phạm Vt (bơ)	cmo1xc119000jvxp01snwxzoa	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.254	2026-04-16 20:21:13.254
cmo1xcq0f05r4vxp016g4aw39	cmo1xcq0f05r5vxp0xrevoj00	\N	Nguyễn My (bơ) Hải Dương	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.263	2026-04-16 20:21:13.263
cmo1xcq0l05r8vxp0qd4fy7nw	cmo1xcq0l05r9vxp0xnklx7f9	\N	Huyền Trang Quãng Trị	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.269	2026-04-16 20:21:13.269
cmo1xcq0s05rcvxp00mi4nbwa	cmo1xcq0s05rdvxp0pgiw1r0p	\N	Ngân Tâm Vũ (ly)	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.276	2026-04-16 20:21:13.276
cmo1xcq0y05rgvxp0iloiwflp	cmo1xcq0y05rhvxp0oocxzjwo	\N	Ngô Thùy Bảo Lộc	cmo1xc11n000kvxp0g32oj3wx	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.282	2026-04-16 20:21:13.282
cmo1xcq1405rkvxp0borvk8up	cmo1xcq1405rlvxp021f3ljn8	\N	Trinh Phù Cát Bd	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.289	2026-04-16 20:21:13.289
cmo1xcq1b05rovxp0fwxggppi	cmo1xcq1b05rpvxp0mqhzgyfb	\N	Vi Vt	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.296	2026-04-16 20:21:13.296
cmo1xcq1i05rsvxp0gmq0wi9h	cmo1xcq1i05rtvxp0np35cyz6	\N	Hải Anh Hn	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.303	2026-04-16 20:21:13.303
cmo1xcq1p05rwvxp0fc5cy2rh	cmo1xcq1p05rxvxp076yo0jhb	\N	Nguyễn Cao Nguyen Phương	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.31	2026-04-16 20:21:13.31
cmo1xcq1x05s0vxp0icz9885p	cmo1xcq1x05s1vxp0qxk2qc3o	\N	Dương Dương (bơ)	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.317	2026-04-16 20:21:13.317
cmo1xcq2305s4vxp00w4zuiuj	cmo1xcq2305s5vxp00hzc1cap	\N	Phương Nga (bơ)	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.324	2026-04-16 20:21:13.324
cmo1xcq2a05s8vxp0tgbrpbfr	cmo1xcq2a05s9vxp0m0bdvadr	\N	Chị Vân (bà Đầm)	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.33	2026-04-16 20:21:13.33
cmo1xcq2g05scvxp0btkhcj6x	cmo1xcq2g05sdvxp0eljjczh6	\N	Nguyễn Thị Thu Huyền (ly)	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.337	2026-04-16 20:21:13.337
cmo1xcq2n05sgvxp07i5z0t9p	cmo1xcq2n05shvxp01zgp2p43	\N	Khuê (nv)	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.343	2026-04-16 20:21:13.343
cmo1xcq2v05skvxp0b51roci6	cmo1xcq2v05slvxp0r7o280uc	\N	Hạnh Nguyễn (zalo)	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.351	2026-04-16 20:21:13.351
cmo1xcq3205sovxp00t03wh3z	cmo1xcq3205spvxp09ifzwiz2	\N	Tham Nguyen (bơ)	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.358	2026-04-16 20:21:13.358
cmo1xcq3805ssvxp0cy85ak5q	cmo1xcq3805stvxp0r4xmcx3k	\N	Nguyễn Hồng Ánh (zl 988)	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.364	2026-04-16 20:21:13.364
cmo1xcq3e05swvxp0z95reg7v	cmo1xcq3e05sxvxp00jpfzqgl	\N	Toan Nguyen (ly)	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.37	2026-04-16 20:21:13.37
cmo1xcq3k05t0vxp0cqh56nts	cmo1xcq3k05t1vxp0fld6jedq	\N	Hồng Ánh Bd (ly)	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.377	2026-04-16 20:21:13.377
cmo1xcq3r05t4vxp08y795m7s	cmo1xcq3r05t5vxp0rb42cqgx	\N	Phạm Minh Hằng (bơ)	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.384	2026-04-16 20:21:13.384
cmo1xcq3y05t8vxp0e0s3p3ae	cmo1xcq3y05t9vxp0ronnfgv7	\N	Nguyễn Thị Tuyết Phương (ly)	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.39	2026-04-16 20:21:13.39
cmo1xcq4505tcvxp044n20vik	cmo1xcq4505tdvxp0655ys3pn	\N	Thu Nga Vũng Tàu	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.397	2026-04-16 20:21:13.397
cmo1xcq4b05tgvxp0dxhmwg8u	cmo1xcq4b05thvxp0hz6gc7fu	\N	Kim Thoa (zl 988)	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.403	2026-04-16 20:21:13.403
cmo1xcq4i05tkvxp0nulmyvrs	cmo1xcq4i05tlvxp0buh3ex99	\N	Nhuan Huy (bơ)	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.41	2026-04-16 20:21:13.41
cmo1xcq4q05tovxp034pcm31v	cmo1xcq4q05tpvxp058jltvo7	\N	Mona Trần (ly)	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.418	2026-04-16 20:21:13.418
cmo1xcq4w05tsvxp03mnmbxsg	cmo1xcq4w05ttvxp0bif4zybs	\N	Hoa Tường Vy	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.425	2026-04-16 20:21:13.425
cmo1xcq5205twvxp0y7nzg8ja	cmo1xcq5205txvxp08503of3z	\N	Hồng Phan Rang  (zl Chị Ly)	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.43	2026-04-16 20:21:13.43
cmo1xcq5905u0vxp02u0lydmj	cmo1xcq5905u1vxp07v68la3y	\N	Nguyen Linh (ly) Huế	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.437	2026-04-16 20:21:13.437
cmo1xcq5g05u4vxp0dyr9zehv	cmo1xcq5g05u5vxp0z8q9owxy	\N	Nguyễn Thị Thùy Dung (ly) Qt	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.444	2026-04-16 20:21:13.444
cmo1xcq5n05u8vxp09gd7sl6n	cmo1xcq5n05u9vxp019wolatg	\N	Làng Ăn Thô	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.451	2026-04-16 20:21:13.451
cmo1xcq5t05ucvxp09qa9ce9n	cmo1xcq5t05udvxp0a9ng7orm	\N	Tiểu Ly (zl 988)	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.458	2026-04-16 20:21:13.458
cmo1xcq5z05ugvxp03bfe0dp8	cmo1xcq5z05uhvxp03zgwdqg8	\N	Hương Giang Đn	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.464	2026-04-16 20:21:13.464
cmo1xcq6505ukvxp03z68utkp	cmo1xcq6505ulvxp0qtzf5twm	\N	An Le (mf)	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.469	2026-04-16 20:21:13.469
cmo1xcq6c05uovxp076lko3nq	cmo1xcq6c05upvxp0c4gfx3i5	\N	Tuyet Dang (đồng Tháp)	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.476	2026-04-16 20:21:13.476
cmo1xcq6i05usvxp07laml18s	cmo1xcq6i05utvxp0ot0hywli	\N	Nga Hoàng Huế	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.482	2026-04-16 20:21:13.482
cmo1xcq6q05uwvxp0shj3jlax	cmo1xcq6q05uxvxp0msj5cqrm	\N	Mỹ Minh (ly)	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.491	2026-04-16 20:21:13.491
cmo1xcq6x05v0vxp0ba1jkli2	cmo1xcq6x05v1vxp0opik5toq	\N	Lan Quach (bơ)	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.497	2026-04-16 20:21:13.497
cmo1xcq7405v4vxp0n7xbtfuv	cmo1xcq7405v5vxp0zbczrale	\N	Nông Sản Truyền Thống (bơ)	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.504	2026-04-16 20:21:13.504
cmo1xcq7c05v8vxp0golw0bmp	cmo1xcq7c05v9vxp0jnojxc29	\N	Giang Mỹ Phượng (ly)	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.513	2026-04-16 20:21:13.513
cmo1xcq7j05vcvxp0wo20c4lp	cmo1xcq7j05vdvxp08ckfdu3x	\N	Huyền Lê Hn	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.519	2026-04-16 20:21:13.519
cmo1xcq7q05vgvxp0el1sprnx	cmo1xcq7q05vhvxp0kq4ezclt	\N	Hoài Thương Nguyễn - Đà Nẵng ( Bơ)	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.527	2026-04-16 20:21:13.527
cmo1xcq7y05vkvxp0glefl9kw	cmo1xcq7y05vlvxp0lhi67mvv	\N	Lê Thị Thu Thủy  (bơ)	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.534	2026-04-16 20:21:13.534
cmo1xcq8505vovxp0jdn04my6	cmo1xcq8505vpvxp0cu5mpd90	\N	Hòa Lê (ly)	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.541	2026-04-16 20:21:13.541
cmo1xcq8b05vsvxp0k80b2j7p	cmo1xcq8b05vtvxp0vnmregmm	\N	Bảo Toàn - Đn	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.547	2026-04-16 20:21:13.547
cmo1xcq8i05vwvxp0rs8a7tli	cmo1xcq8i05vxvxp0rxmo5o88	\N	Tuyết Trinh Q2 (nido)	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.554	2026-04-16 20:21:13.554
cmo1xcq8p05w0vxp0zxu9r8lw	cmo1xcq8p05w1vxp05941hqgo	\N	Lucia Tuyết Lệ	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.561	2026-04-16 20:21:13.561
cmo1xcq8x05w4vxp09fjk7grn	cmo1xcq8x05w5vxp0hrzyoor5	\N	Hồng (zalo Ly) Phan Thiết	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.569	2026-04-16 20:21:13.569
cmo1xcq9305w8vxp09afbckyb	cmo1xcq9305w9vxp0j88qblfk	\N	Hoài Loan (zalo Ly)	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.576	2026-04-16 20:21:13.576
cmo1xcq9a05wcvxp0rjpa0643	cmo1xcq9a05wdvxp0lyd9gqdc	\N	Yuuki Farm (quy Nhơn)	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.583	2026-04-16 20:21:13.583
cmo1xcq9h05wgvxp0vq2p2thl	cmo1xcq9h05whvxp04kfe54g5	\N	Tiểu Niệm (zalo Nhóm)	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.589	2026-04-16 20:21:13.589
cmo1xcq9o05wkvxp07s3jw9hl	cmo1xcq9o05wlvxp0ee337vrt	\N	Ngọc Thuyên ( Zalo Bơ)	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.596	2026-04-16 20:21:13.596
cmo1xcq9v05wovxp0l0yl7yw1	cmo1xcq9v05wpvxp01m3nspdj	\N	Mi Tran - Quãng Ngãi ( Ly)	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.603	2026-04-16 20:21:13.603
cmo1xcqa205wsvxp0e0oj5ond	cmo1xcqa205wtvxp0xwx15tc7	\N	Ngô Phượng - Vũng Tàu	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.61	2026-04-16 20:21:13.61
cmo1xcqa905wwvxp0mz31iivg	cmo1xcqa905wxvxp0brnti03p	\N	Phạm Quyên -zalo Nhóm	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.617	2026-04-16 20:21:13.617
cmo1xcqag05x0vxp0smotvry7	cmo1xcqag05x1vxp0768om763	\N	Ngọc Nguyễn - Phú Yên ( Ly)	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.624	2026-04-16 20:21:13.624
cmo1xcqam05x4vxp0w4xma3si	cmo1xcqam05x5vxp02k4sy14g	\N	Huy Hoàng - Nha Trang ( Zalo)	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.631	2026-04-16 20:21:13.631
cmo1xcqau05x8vxp05xzgyg8o	cmo1xcqau05x9vxp0sn3atwnd	\N	Úc Trang - Đăk Lăk ( Ly)	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.638	2026-04-16 20:21:13.638
cmo1xcqb105xcvxp0bpcf04zi	cmo1xcqb105xdvxp0ndkrhjgz	\N	Thiện Phước Vt	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.645	2026-04-16 20:21:13.645
cmo1xcqb805xgvxp0h75esvgm	cmo1xcqb805xhvxp0zgz4vp1y	\N	Vườn Xanh Sg	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.653	2026-04-16 20:21:13.653
cmo1xcqbg05xkvxp06sujx9f9	cmo1xcqbg05xlvxp0f6ia8om5	\N	Trần Diễm My (ly)	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.661	2026-04-16 20:21:13.661
cmo1xcqbo05xovxp0fceyr9cp	cmo1xcqbo05xpvxp0flvv58sh	\N	Dorothy Tran (bơ)	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.668	2026-04-16 20:21:13.668
cmo1xcqbv05xsvxp09spd2atg	cmo1xcqbv05xtvxp0o3tv54ix	\N	Hương Ly (zalo Bơ)	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.675	2026-04-16 20:21:13.675
cmo1xcqc105xwvxp00fw3bset	cmo1xcqc105xxvxp036pysm5q	\N	Sớm Đn	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.681	2026-04-16 20:21:13.681
cmo1xcqc805y0vxp0136wqey6	cmo1xcqc805y1vxp01xb178id	\N	Thanh Hoa Nguyễn (mf)	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.689	2026-04-16 20:21:13.689
cmo1xcqch05y4vxp098khz5ti	cmo1xcqch05y5vxp088xbs448	\N	Bùi Ngọc Việt Đăk Lăk	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.697	2026-04-16 20:21:13.697
cmo1xcqco05y8vxp01dl5ffse	cmo1xcqco05y9vxp0uq9wy7y5	\N	Xuân Trang Hn	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.704	2026-04-16 20:21:13.704
cmo1xcqct05ycvxp0pe0ztzdr	cmo1xcqct05ydvxp0p9bj8pap	\N	Ngô Thị Nhung (ly)	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.71	2026-04-16 20:21:13.71
cmo1xcqd005ygvxp01vrpuwx3	cmo1xcqd005yhvxp0sznhkcvn	\N	Hoai Thu Nguyen	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.717	2026-04-16 20:21:13.717
cmo1xcqd705ykvxp00qvcao31	cmo1xcqd705ylvxp0uc8asjls	\N	Lâm Đăk Lăk	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.723	2026-04-16 20:21:13.723
cmo1xcqdd05yovxp077acsnvw	cmo1xcqdd05ypvxp0605tevej	\N	Hồ Trâm (ly)	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.73	2026-04-16 20:21:13.73
cmo1xcqdk05ysvxp0nsvt4eqi	cmo1xcqdk05ytvxp0izou468x	\N	Maria Ha (ly)	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.736	2026-04-16 20:21:13.736
cmo1xcqdr05ywvxp0rsrwc3or	cmo1xcqdr05yxvxp0om6moalr	\N	Vũ Thị Hiên (ly)	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.743	2026-04-16 20:21:13.743
cmo1xcqdy05z0vxp0yrih6url	cmo1xcqdy05z1vxp0wenv2qky	\N	Tam An (ly)	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.75	2026-04-16 20:21:13.75
cmo1xcqe405z4vxp0d7bsb71z	cmo1xcqe405z5vxp0fwm62t7j	\N	Xù Mộc Hn	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.756	2026-04-16 20:21:13.756
cmo1xcqeb05z8vxp060cnl81z	cmo1xcqeb05z9vxp0n6ya200m	\N	Thiều Mi (zalo Nhóm)	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.764	2026-04-16 20:21:13.764
cmo1xcqek05zcvxp0kqdb1b9e	cmo1xcqek05zdvxp0zwhsryg4	\N	Nga Nhóm Trẻ	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.772	2026-04-16 20:21:13.772
cmo1xcqes05zgvxp0wnru537i	cmo1xcqes05zhvxp08mchq3hq	\N	Trang Đăk Lăk	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.78	2026-04-16 20:21:13.78
cmo1xcqey05zkvxp03jox7qa6	cmo1xcqey05zlvxp0npj55c70	\N	Hằng Kiến Đức ( Đắk Nông)	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.787	2026-04-16 20:21:13.787
cmo1xcqf405zovxp0jk842k2p	cmo1xcqf405zpvxp0hxp8f1ki	\N	Nhung Hn	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.793	2026-04-16 20:21:13.793
cmo1xcqfa05zsvxp02y8aio72	cmo1xcqfa05ztvxp05jsvdis5	\N	Anh Thiêng (zalo Nhóm)	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.798	2026-04-16 20:21:13.798
cmo1xcqfh05zwvxp0qyc3gw07	cmo1xcqfh05zxvxp0k9ky5b94	\N	Trang Trang (ly)	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.805	2026-04-16 20:21:13.805
cmo1xcqfp0600vxp0rhh64ife	cmo1xcqfp0601vxp0f13jsrpx	\N	Dung Nguyen (ly)	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.813	2026-04-16 20:21:13.813
cmo1xcqfw0604vxp0mb9gev5f	cmo1xcqfw0605vxp0z64dls46	\N	Lan Nguyễn Thị Quỳnh (ly)	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.821	2026-04-16 20:21:13.821
cmo1xcqg50608vxp06n5dzfzr	cmo1xcqg50609vxp0y0851qzd	\N	Hoa Lan Sg	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.829	2026-04-16 20:21:13.829
cmo1xcqgc060cvxp0no96m07h	cmo1xcqgc060dvxp05oainfpy	\N	Thúy Quỳnh Đồng Nai	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.836	2026-04-16 20:21:13.836
cmo1xcqgi060gvxp0lj874h9x	cmo1xcqgi060hvxp0t0t8tl4m	\N	Trương Bảo Hoà Sg (zl Nhóm)	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.842	2026-04-16 20:21:13.842
cmo1xcqgn060kvxp0fp8xqicf	cmo1xcqgn060lvxp04nthm6mb	\N	Thanh Xuân (bh)	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.848	2026-04-16 20:21:13.848
cmo1xcqgu060ovxp0cdxxielx	cmo1xcqgu060pvxp08n551o09	\N	Tuyền Tam Kỳ (zalo Nhóm)	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.854	2026-04-16 20:21:13.854
cmo1xcqh2060svxp04yvkt52e	cmo1xcqh3060tvxp034szas4x	\N	Xuân Nguyễn Hà Nội	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.863	2026-04-16 20:21:13.863
cmo1xcqha060wvxp0j54wx40n	cmo1xcqha060xvxp0jh3md5no	\N	Phạm Loan (mf) Đăk Lăk	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.87	2026-04-16 20:21:13.87
cmo1xcqhi0610vxp0z8c9kybz	cmo1xcqhi0611vxp07b9fnjts	\N	Ngọc Nguyễn Nt (bơ)	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.878	2026-04-16 20:21:13.878
cmo1xcqhq0614vxp0ohcbnpw0	cmo1xcqhq0615vxp0u0u3plk7	\N	Thu Nguyệt Phạm - Quãng Nam ( Ly)	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.887	2026-04-16 20:21:13.887
cmo1xcqhz0618vxp0usdvpjlb	cmo1xcqhz0619vxp0jaomysdj	\N	Hảo Nguyễn ( Moutain) Hải Dương	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.895	2026-04-16 20:21:13.895
cmo1xcqi7061cvxp0n70blc11	cmo1xcqi7061dvxp0arjfgfvb	\N	Nguyễn Thảo ( Zalo) - Nghệ An	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.903	2026-04-16 20:21:13.903
cmo1xcqid061gvxp0a0uwk7sk	cmo1xcqid061hvxp05tg2xxk2	\N	Đặng Thuý Hằng Sg ( Ly )	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.909	2026-04-16 20:21:13.909
cmo1xcqim061kvxp0bxrs6t21	cmo1xcqim061lvxp06xpp23zl	\N	Đình Thuyên - Đăk Nông ( Bơ )	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.918	2026-04-16 20:21:13.918
cmo1xcqit061ovxp08giqnjil	cmo1xcqit061pvxp0wlwhvccu	\N	Thu Hương - Giang Thanh	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.926	2026-04-16 20:21:13.926
cmo1xcqj0061svxp07yqytqgo	cmo1xcqj0061tvxp009a56ezc	\N	Imon Sg	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.932	2026-04-16 20:21:13.932
cmo1xcqj6061wvxp05y54a6d4	cmo1xcqj6061xvxp0ppzxc3ps	\N	Huy Sg	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.938	2026-04-16 20:21:13.938
cmo1xcqje0620vxp0gpgwrfcy	cmo1xcqje0621vxp02mi9jv6r	\N	Vịt Búp (ly)	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.946	2026-04-16 20:21:13.946
cmo1xcqjl0624vxp0qdutn2mj	cmo1xcqjl0625vxp02bc3w4gj	\N	Hoa Anhthao (. Bơ)	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.953	2026-04-16 20:21:13.953
cmo1xcqjv0628vxp0xmp8cz6c	cmo1xcqjv0629vxp0r5gmxe3a	\N	Huỳnh Liễu ( Ly)	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.963	2026-04-16 20:21:13.963
cmo1xcqk1062cvxp0r5za48bg	cmo1xcqk1062dvxp0ev51ywi0	\N	Thuỳ An Võ (ly)	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.97	2026-04-16 20:21:13.97
cmo1xcqk8062gvxp059z54jnk	cmo1xcqk8062hvxp0bs5447k2	\N	Born To Go ( Bơ)	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.976	2026-04-16 20:21:13.976
cmo1xcqke062kvxp0kweo9rr5	cmo1xcqke062lvxp0ziz0as6w	\N	Mạnh Đức - Nha Trang (ly)	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.982	2026-04-16 20:21:13.982
cmo1xcqkl062ovxp0fbvpsx0q	cmo1xcqkl062pvxp01gc0h898	\N	Nguyễn Đình Vũ Qn (zalo Nhóm)	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.989	2026-04-16 20:21:13.989
cmo1xcqks062svxp0hu2iej1v	cmo1xcqks062tvxp0dbjsv3n4	\N	Thảo Baria	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:13.996	2026-04-16 20:21:13.996
cmo1xcqkz062wvxp0yz4m3t6e	cmo1xcqkz062xvxp0xwlpyf85	\N	Greentech Đà Nẵng	cmo1xc11n000kvxp0g32oj3wx	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.003	2026-04-16 20:21:14.003
cmo1xcql50630vxp06vz9by0m	cmo1xcql50631vxp03e7ml3nk	\N	Hoàng Hân Food Đn	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.01	2026-04-16 20:21:14.01
cmo1xcqld0634vxp0hlq0peaj	cmo1xcqld0635vxp0ln0lh7th	\N	Thanh Vi An Vị Food	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.018	2026-04-16 20:21:14.018
cmo1xcqll0638vxp0vwj5i9i5	cmo1xcqll0639vxp01e36f6o0	\N	Tâm Nyo (ly)	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.025	2026-04-16 20:21:14.025
cmo1xcqls063cvxp0obod3fkh	cmo1xcqls063dvxp0utulwp5x	\N	Ly Nguyễn	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.032	2026-04-16 20:21:14.032
cmo1xcqly063gvxp0lip2d8o2	cmo1xcqly063hvxp0qwdl7fut	\N	Bơ	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.039	2026-04-16 20:21:14.039
cmo1xcqm6063kvxp03x6ma762	cmo1xcqm6063lvxp0jgfm0lrl	\N	Thảo Lavi (bình Thạnh)	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.047	2026-04-16 20:21:14.047
cmo1xcqmc063ovxp0tk7993lt	cmo1xcqmc063pvxp0qi46ybz7	\N	Trang Trương (bơ)	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.053	2026-04-16 20:21:14.053
cmo1xcqmi063svxp0vhplmv5h	cmo1xcqmi063tvxp0npqstvkl	\N	Lê Thị Hồng Thuỷ (fb Bơ)	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.059	2026-04-16 20:21:14.059
cmo1xcqmo063wvxp08rqwolcv	cmo1xcqmo063xvxp0neg98xh3	\N	Thảo Nguyễn (fb Bơ)	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.065	2026-04-16 20:21:14.065
cmo1xcqmv0640vxp0y28hsx0u	cmo1xcqmv0641vxp0am1w3iqx	\N	Hoài Thanh (fb Bơ)	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.071	2026-04-16 20:21:14.071
cmo1xcqn20644vxp0gs2pv4ka	cmo1xcqn20645vxp044ctvckr	\N	Ai Nguyen (fb Ly)	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.078	2026-04-16 20:21:14.078
cmo1xcqna0648vxp0wvg2nklf	cmo1xcqna0649vxp0taefshhh	\N	Tường Bản	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.086	2026-04-16 20:21:14.086
cmo1xcqnh064cvxp0p6moyjy3	cmo1xcqnh064dvxp0q82ebwp7	\N	Phạm Loan (mf)	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.093	2026-04-16 20:21:14.093
cmo1xcqnn064gvxp0qwjenfuq	cmo1xcqnn064hvxp0j2lg3cxc	\N	Thuong Ho (fb Ly)	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.1	2026-04-16 20:21:14.1
cmo1xcqnu064kvxp0u15l2ogz	cmo1xcqnu064lvxp03uczks7u	\N	Green Food (zalo)	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.106	2026-04-16 20:21:14.106
cmo1xcqo1064ovxp0v5r8c69a	cmo1xcqo1064pvxp0ide41yp6	\N	Ngô Thị Diệu Hy Qn (ly)	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.113	2026-04-16 20:21:14.113
cmo1xcqo7064svxp0kd4hmozt	cmo1xcqo7064tvxp0bvbwyi5i	\N	Anh Phước Sg	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.12	2026-04-16 20:21:14.12
cmo1xcqoe064wvxp0n4hkzm3r	cmo1xcqoe064xvxp0gkk4sadn	\N	Hà Trần (fb Bơ)	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.126	2026-04-16 20:21:14.126
cmo1xcqok0650vxp0ljzt9r3s	cmo1xcqok0651vxp0r6yrih8o	\N	Trang Trang (ly)	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.132	2026-04-16 20:21:14.132
cmo1xcqoq0654vxp03ahzr1vi	cmo1xcqoq0655vxp020r3r6hq	\N	Tạ Thị Dung	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.138	2026-04-16 20:21:14.138
cmo1xcqox0658vxp0hamhfx8i	cmo1xcqox0659vxp0igugyopr	\N	Hà (zalo)	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.146	2026-04-16 20:21:14.146
cmo1xcqp5065cvxp0huj8tinh	cmo1xcqp5065dvxp0qak47tlh	\N	Minh Châu	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.153	2026-04-16 20:21:14.153
cmo1xcqpf065gvxp031j4oeeu	cmo1xcqpf065hvxp0daysygdi	\N	Ngọc Quỳnh Zalo	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.163	2026-04-16 20:21:14.163
cmo1xcqpl065kvxp0p7qhv4gi	cmo1xcqpl065lvxp0qxtkr8o1	\N	Trường Mn Gl	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.17	2026-04-16 20:21:14.17
cmo1xcqpu065ovxp0oaw142ho	cmo1xcqpu065pvxp0lzqxbv27	\N	Trang Nhà Xanh (bơ)	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.179	2026-04-16 20:21:14.179
cmo1xcqq2065svxp0w6j34i6q	cmo1xcqq2065tvxp01zsoenc7	\N	Thảo Nguyễn (ly)	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.186	2026-04-16 20:21:14.186
cmo1xcqq9065wvxp0pktno7sj	cmo1xcqq9065xvxp08uslu88c	\N	Trường Mn Kis	cmo1xc119000jvxp01snwxzoa	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.193	2026-04-16 20:21:14.193
cmo1xcqqm0660vxp0vypv8t2b	cmo1xcqqm0661vxp0vqoycuyd	\N	Linh Đông Nguyễn (bơ)	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.206	2026-04-16 20:21:14.206
cmo1xcqqt0664vxp084ck0rsm	cmo1xcqqt0665vxp0q1jntxg9	\N	Vũ Thị Nhung Vt (ly)	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.213	2026-04-16 20:21:14.213
cmo1xcqr00668vxp0ks4k1cba	cmo1xcqr00669vxp0vswdscv3	\N	Nguyễn Tuệ An (ly)	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.22	2026-04-16 20:21:14.22
cmo1xcqr7066cvxp0g7hczk4i	cmo1xcqr7066dvxp018mrwvq7	\N	Thanh Võ Zalo	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.227	2026-04-16 20:21:14.227
cmo1xcqre066gvxp0sfjq3anj	cmo1xcqre066hvxp084rn36es	\N	Đại Dương Bmt	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.235	2026-04-16 20:21:14.235
cmo1xcqrk066kvxp0wx193nyw	cmo1xcqrk066lvxp0foehqjhq	\N	Thanh Trang Đà Nẵng	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.241	2026-04-16 20:21:14.241
cmo1xcqrq066ovxp0x2xh23iw	cmo1xcqrq066pvxp0gi0kaa9n	\N	Chu Hậu Đà Nẵng	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.247	2026-04-16 20:21:14.247
cmo1xcqry066svxp0hqvvz32s	cmo1xcqry066tvxp0awhckt55	\N	Lê Khiết Lan (ly)	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.254	2026-04-16 20:21:14.254
cmo1xcqs4066wvxp0eext9oxt	cmo1xcqs4066xvxp0wntsfxvo	\N	Thanh Mi Sg	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.26	2026-04-16 20:21:14.26
cmo1xcqsc0670vxp0ccxpy0ch	cmo1xcqsc0671vxp0fllwkk1n	\N	Huân Bình Phước (fb Bơ)	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.268	2026-04-16 20:21:14.268
cmo1xcqsj0674vxp0hi5wewcf	cmo1xcqsj0675vxp028ddjfv1	\N	Mega	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.275	2026-04-16 20:21:14.275
cmo1xcqsp0678vxp0c6ffstv4	cmo1xcqsp0679vxp0fiq3dymg	\N	Phạm Linh Đn	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.281	2026-04-16 20:21:14.281
cmo1xcqsv067cvxp0g2vamfne	cmo1xcqsv067dvxp0j2tg7f1n	\N	Thảo Py	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.288	2026-04-16 20:21:14.288
cmo1xcqt3067gvxp0d9uyk16b	cmo1xcqt3067hvxp0xf14hmry	\N	Nhàn Vĩnh Phúc	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.295	2026-04-16 20:21:14.295
cmo1xcqta067kvxp030d6fbeb	cmo1xcqta067lvxp06quyiy7b	\N	Ánh Nga (fb Ly)	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.302	2026-04-16 20:21:14.302
cmo1xcqtg067ovxp0iz8bxr8l	cmo1xcqtg067pvxp0dxycmz2j	\N	Vy Nt	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.308	2026-04-16 20:21:14.308
cmo1xcqtm067svxp0un17lzcp	cmo1xcqtm067tvxp0lyar6r5g	\N	Xuân Linh Sg	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.314	2026-04-16 20:21:14.314
cmo1xcqts067wvxp0twr28g6n	cmo1xcqts067xvxp0cnol1uyd	\N	Lê Hà Sg	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.321	2026-04-16 20:21:14.321
cmo1xcqu00680vxp0ivms6qke	cmo1xcqu00681vxp03vw66ukq	\N	Linh Đỗ Đl	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.328	2026-04-16 20:21:14.328
cmo1xcqu70684vxp0w7auhp3l	cmo1xcqu70685vxp0ke32diyq	\N	Thu Qn	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.335	2026-04-16 20:21:14.335
cmo1xcque0688vxp01hqklue0	cmo1xcque0689vxp05npfdkbk	\N	Năm Qt	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.342	2026-04-16 20:21:14.342
cmo1xcquk068cvxp08y5wgacc	cmo1xcquk068dvxp04mo3fenf	\N	Huệ Bd	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.349	2026-04-16 20:21:14.349
cmo1xcqus068gvxp0zqnn167n	cmo1xcqus068hvxp09n31fzi1	\N	Trinh Trương	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.356	2026-04-16 20:21:14.356
cmo1xcquz068kvxp0l4lfdhix	cmo1xcquz068lvxp0fdtyw46f	\N	Uyên (pf)	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.364	2026-04-16 20:21:14.364
cmo1xcqv6068ovxp0ilxay2f2	cmo1xcqv6068pvxp0pmafrfs8	\N	Tân Tân Sg	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.371	2026-04-16 20:21:14.371
cmo1xcqvg068svxp08bg8xsn0	cmo1xcqvg068tvxp0bqjosgpd	\N	Nguyệt Đl	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.38	2026-04-16 20:21:14.38
cmo1xcqvm068wvxp065748rbi	cmo1xcqvm068xvxp08ca03akc	\N	Hường Lê Quãng Ngãi (fb Ly)	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.387	2026-04-16 20:21:14.387
cmo1xcqvs0690vxp0iu5c9sn8	cmo1xcqvs0691vxp0az79vd7w	\N	Trần Hà Ngọc Trâm (fb Bơ)	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.393	2026-04-16 20:21:14.393
cmo1xcqvy0694vxp047ntytsf	cmo1xcqvy0695vxp0lrt65ci6	\N	Liên Sg	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.399	2026-04-16 20:21:14.399
cmo1xcqw50698vxp002vmd7ek	cmo1xcqw50699vxp01tinalp4	\N	Huế Mđ	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.406	2026-04-16 20:21:14.406
cmo1xcqwd069cvxp0xxnj61ng	cmo1xcqwd069dvxp0e1mvyqb7	\N	Tân Vũ (fb Bơ)	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.413	2026-04-16 20:21:14.413
cmo1xcqwl069gvxp0xmla6por	cmo1xcqwl069hvxp0cexsndm0	\N	Kiều Vũ	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.421	2026-04-16 20:21:14.421
cmo1xcqwu069kvxp0lzi678p5	cmo1xcqwu069lvxp039burrxe	\N	Thi Bd	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.431	2026-04-16 20:21:14.431
cmo1xcqx1069ovxp0nbwqnqvp	cmo1xcqx1069pvxp0yv130845	\N	Vân Thị Thúy	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.437	2026-04-16 20:21:14.437
cmo1xcqx7069svxp0fp5l5pyl	cmo1xcqx7069tvxp0bp4polya	\N	Dư Vân (fb Ly)	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.443	2026-04-16 20:21:14.443
cmo1xcqxe069wvxp0g4abxzv6	cmo1xcqxe069xvxp0tzisr59y	\N	Jeny Nguyen (fb Ly)	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.451	2026-04-16 20:21:14.451
cmo1xcqxl06a0vxp0pf1wb37g	cmo1xcqxl06a1vxp06q6icvox	\N	Huỳnh Quyên	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.457	2026-04-16 20:21:14.457
cmo1xcqxr06a4vxp01d4cw34v	cmo1xcqxr06a5vxp07zhnzltr	\N	Ty Ty (fb Ly)	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.463	2026-04-16 20:21:14.463
cmo1xcqxz06a8vxp08xt1lw4v	cmo1xcqxz06a9vxp0c0dfow1v	\N	Hoài Nhà Quê	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.471	2026-04-16 20:21:14.471
cmo1xcqy706acvxp0kziue1jc	cmo1xcqy706advxp0awg1sxiy	\N	Tuyết Long An	cmo1xc119000jvxp01snwxzoa	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.48	2026-04-16 20:21:14.48
cmo1xcqyd06agvxp0g8wkoric	cmo1xcqyd06ahvxp0aqn98e5g	\N	Sara Nguyễn	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.486	2026-04-16 20:21:14.486
cmo1xcqyl06akvxp0c2oaq4qf	cmo1xcqyl06alvxp0enz30k24	\N	Huyền Bmt	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.493	2026-04-16 20:21:14.493
cmo1xcqys06aovxp0or82xial	cmo1xcqys06apvxp0etkhq0sf	\N	Đồng Xanh	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.5	2026-04-16 20:21:14.5
cmo1xcqyz06asvxp08ecqeevi	cmo1xcqyz06atvxp0tbcj4hgr	\N	Thật Dưỡng	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.507	2026-04-16 20:21:14.507
cmo1xcqz606awvxp0luji5aad	cmo1xcqz606axvxp07mnqkimp	\N	Trần Thu Thảo Vt	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.514	2026-04-16 20:21:14.514
cmo1xcqzc06b0vxp05506nzrv	cmo1xcqzc06b1vxp0z5bte1u7	\N	Mỹ Chi An Giang	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.52	2026-04-16 20:21:14.52
cmo1xcqzi06b4vxp027a1uz3n	cmo1xcqzi06b5vxp00e8097yk	\N	Vũ Mđ	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.526	2026-04-16 20:21:14.526
cmo1xcqzo06b8vxp089gd43fq	cmo1xcqzo06b9vxp0ghxc0wah	\N	Hường Huế	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.532	2026-04-16 20:21:14.532
cmo1xcqzu06bcvxp063sgczoh	cmo1xcqzu06bdvxp06ta7wv11	\N	Ngọc Mđ	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.538	2026-04-16 20:21:14.538
cmo1xcr0206bgvxp02fi7pwac	cmo1xcr0206bhvxp0qsmtizwn	\N	Lê Thị Thúy	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.545	2026-04-16 20:21:14.545
cmo1xcr0906bkvxp0j5p11uoa	cmo1xcr0906blvxp0x7d149qm	\N	Tiến Nguyễn (fb Ly)	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.553	2026-04-16 20:21:14.553
cmo1xcr0h06bovxp0yn73pe8l	cmo1xcr0h06bpvxp0u9nr38qr	\N	Hồng Danh Đn	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.561	2026-04-16 20:21:14.561
cmo1xcr0p06bsvxp03ba2gkx0	cmo1xcr0p06btvxp0nachudht	\N	Hồng Thái Sg	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.569	2026-04-16 20:21:14.569
cmo1xcr0v06bwvxp09izrr7vj	cmo1xcr0v06bxvxp0zyrzmtuz	\N	Khoa Đl	cmo1xc11v000lvxp07r6uljko	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.575	2026-04-16 20:21:14.575
cmo1xcr1106c0vxp0blyg92av	cmo1xcr1106c1vxp02ax1eo74	\N	Ch Thảo Uyên	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.581	2026-04-16 20:21:14.581
cmo1xcr1806c4vxp0ryhicm6z	cmo1xcr1806c5vxp0ro8bxadn	\N	Ly Đổ	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.588	2026-04-16 20:21:14.588
cmo1xcr1g06c8vxp0afu3viua	cmo1xcr1g06c9vxp0auukt5hm	\N	Glory Lotus	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.596	2026-04-16 20:21:14.596
cmo1xcr1n06ccvxp0jh6bksxm	cmo1xcr1n06cdvxp0b4nydf9h	\N	Linh Nguyễn	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.603	2026-04-16 20:21:14.603
cmo1xcr1t06cgvxp0hhrg4jov	cmo1xcr1t06chvxp0ylmpph01	\N	Thảo Nguyên Đăk Lăk	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.61	2026-04-16 20:21:14.61
cmo1xcr2106ckvxp0vjql2h1i	cmo1xcr2106clvxp0g0h7glvg	\N	Băng Tâm Đl	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.618	2026-04-16 20:21:14.618
cmo1xcr2806covxp056y1ry20	cmo1xcr2806cpvxp0cxqecxdx	\N	Mỹ Hạnh	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.625	2026-04-16 20:21:14.625
cmo1xcr2f06csvxp0tred8dtx	cmo1xcr2f06ctvxp0x2b678xw	\N	Phương Đà Nẵng	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.631	2026-04-16 20:21:14.631
cmo1xcr2l06cwvxp0h05qbdit	cmo1xcr2l06cxvxp0kibmp128	\N	Hương Py	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.638	2026-04-16 20:21:14.638
cmo1xcr2u06d0vxp07p65nn0a	cmo1xcr2u06d1vxp0jyuou7zz	\N	Mẫn Huế	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.646	2026-04-16 20:21:14.646
cmo1xcr3106d4vxp0uct2p9r6	cmo1xcr3106d5vxp0991kck7b	\N	Huyền Nghệ An	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.653	2026-04-16 20:21:14.653
cmo1xcr3706d8vxp0n21zi57d	cmo1xcr3706d9vxp0kyke98nl	\N	Khương Phương	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.659	2026-04-16 20:21:14.659
cmo1xcr3d06dcvxp09oi8k5q8	cmo1xcr3d06ddvxp0ra16nuto	\N	Huân Sg	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.666	2026-04-16 20:21:14.666
cmo1xcr3k06dgvxp0q8sxmgzv	cmo1xcr3k06dhvxp0nnb1yeav	\N	Lai Van	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.672	2026-04-16 20:21:14.672
cmo1xcr3s06dkvxp0lp16v5bm	cmo1xcr3s06dlvxp0t1q46dlt	\N	Fb An Bình	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.68	2026-04-16 20:21:14.68
cmo1xcr3y06dovxp083lrb7k1	cmo1xcr3y06dpvxp0d7bp4ph1	\N	Gd Thi Thi	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.687	2026-04-16 20:21:14.687
cmo1xcr4506dsvxp05ceqevzx	cmo1xcr4506dtvxp05pymus20	\N	Mỹ Hạnh Tam Kỳ	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.693	2026-04-16 20:21:14.693
cmo1xcr4d06dwvxp0elslali1	cmo1xcr4d06dxvxp0wux2jt5x	\N	Ngọc Nha Trang	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.701	2026-04-16 20:21:14.701
cmo1xcr4j06e0vxp0g96thjlv	cmo1xcr4j06e1vxp093uhlxic	\N	Ngân Bh	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.707	2026-04-16 20:21:14.707
cmo1xcr4p06e4vxp0owawkyr0	cmo1xcr4p06e5vxp0l841gfag	\N	Bích Trâm	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.713	2026-04-16 20:21:14.713
cmo1xcr4v06e8vxp0272a1qoc	cmo1xcr4w06e9vxp0iihozi8l	\N	Huyền Quãng Ngãi	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.72	2026-04-16 20:21:14.72
cmo1xcr5206ecvxp00x54sneb	cmo1xcr5206edvxp0wg3z177d	\N	Thanh Nha Trang	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.726	2026-04-16 20:21:14.726
cmo1xcr5a06egvxp05b6mo10y	cmo1xcr5a06ehvxp0iof67vm2	\N	Yến Anh	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.734	2026-04-16 20:21:14.734
cmo1xcr5h06ekvxp01hdlcojq	cmo1xcr5h06elvxp01nrp22ek	\N	Liên Q7	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.742	2026-04-16 20:21:14.742
cmo1xcr5o06eovxp0mjn43p83	cmo1xcr5o06epvxp0djwwjflz	\N	Trần Bích Ngọc	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.748	2026-04-16 20:21:14.748
cmo1xcr5v06esvxp0gp4vdx6o	cmo1xcr5v06etvxp0fumbyi35	\N	Hà Nhật Trần	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.755	2026-04-16 20:21:14.755
cmo1xcr6406ewvxp07lxtqjkx	cmo1xcr6406exvxp0ixluaobj	\N	Phúc Ân	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.764	2026-04-16 20:21:14.764
cmo1xcr6a06f0vxp04zhbf3m6	cmo1xcr6a06f1vxp0ad7u9t7u	\N	Huyền Đăk Hà	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.77	2026-04-16 20:21:14.77
cmo1xcr6g06f4vxp0d4fxun9v	cmo1xcr6g06f5vxp0m4kie21l	\N	Huy Nguyễn	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.776	2026-04-16 20:21:14.776
cmo1xcr6n06f8vxp099vu8ba8	cmo1xcr6n06f9vxp0qck7zllo	\N	Chợ Miền Quê	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.784	2026-04-16 20:21:14.784
cmo1xcr6v06fcvxp036s499sq	cmo1xcr6v06fdvxp09p4b4ol6	\N	Thanh Thảo An Vị Food	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.791	2026-04-16 20:21:14.791
cmo1xcr7106fgvxp0oz634w54	cmo1xcr7106fhvxp00hssv335	\N	Thủy An Vị Food	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.797	2026-04-16 20:21:14.797
cmo1xcr7806fkvxp0vgnb413g	cmo1xcr7806flvxp0917seod5	\N	Bưu Điện	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.804	2026-04-16 20:21:14.804
cmo1xcr7g06fovxp09ok4y19l	cmo1xcr7g06fpvxp0f7wex28w	\N	Ani Huế	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.812	2026-04-16 20:21:14.812
cmo1xcr7n06fsvxp02qz7ynwc	cmo1xcr7n06ftvxp0lrfp77gm	\N	Nương Sg	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.82	2026-04-16 20:21:14.82
cmo1xcr7v06fwvxp0lwhzqceo	cmo1xcr7v06fxvxp0zpzdmp1b	\N	Selly Qn	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.827	2026-04-16 20:21:14.827
cmo1xcr8306g0vxp0gigkc2f9	cmo1xcr8306g1vxp04b24qhmy	\N	Trâm Bùi	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.835	2026-04-16 20:21:14.835
cmo1xcr8a06g4vxp0kfs9nr63	cmo1xcr8a06g5vxp0fd8kqgw3	\N	Thùy Trang Sg	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.842	2026-04-16 20:21:14.842
cmo1xcr8f06g8vxp0h6wya0sv	cmo1xcr8f06g9vxp0yp4k17oh	\N	Nhã Trúc Đl	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.848	2026-04-16 20:21:14.848
cmo1xcr8m06gcvxp02qxlu5pw	cmo1xcr8m06gdvxp0q7pl93ac	\N	Thanh Thảo An Khê	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.854	2026-04-16 20:21:14.854
cmo1xcr8u06ggvxp0kb4wtiuw	cmo1xcr8u06ghvxp0fd1jg753	\N	Nhung Huỳnh	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.862	2026-04-16 20:21:14.862
cmo1xcr9106gkvxp0b8kpkov1	cmo1xcr9106glvxp0jeq4rymw	\N	Mai Phuong Sg	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.869	2026-04-16 20:21:14.869
cmo1xcr9906govxp0dhjqx8qx	cmo1xcr9906gpvxp08bo87let	\N	Hằng Bd	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.877	2026-04-16 20:21:14.877
cmo1xcr9g06gsvxp0scvzimi4	cmo1xcr9g06gtvxp0h9mnifxs	\N	An Gl	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.885	2026-04-16 20:21:14.885
cmo1xcr9o06gwvxp0hsg1btmd	cmo1xcr9o06gxvxp0dr3s2mee	\N	Trần Hồng Thắm	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.892	2026-04-16 20:21:14.892
cmo1xcr9u06h0vxp06qcw5gbn	cmo1xcr9u06h1vxp0hb8vbcvz	\N	Phạm Linh Sg	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.898	2026-04-16 20:21:14.898
cmo1xcra106h4vxp06jmoc07g	cmo1xcra106h5vxp0idiu28kt	\N	Lion Sg	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.905	2026-04-16 20:21:14.905
cmo1xcra906h8vxp0dsjaj1b6	cmo1xcra906h9vxp0wbjwe5zb	\N	Đinh Vân Sg	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.914	2026-04-16 20:21:14.914
cmo1xcrag06hcvxp0nmrz4eqn	cmo1xcrag06hdvxp0z9cxu0n4	\N	Ánh Pr	cmo1xc123000mvxp0ul7pkio2	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.92	2026-04-16 20:21:14.92
cmo1xcram06hgvxp02m0cnsxh	cmo1xcram06hhvxp0g35z7bmn	\N	Hạnh Nhi Sg	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.926	2026-04-16 20:21:14.926
cmo1xcrat06hkvxp01aby1q75	cmo1xcrat06hlvxp0ds7cdvv3	\N	Trang Huế	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.933	2026-04-16 20:21:14.933
cmo1xcraz06hovxp0gc6l55cs	cmo1xcraz06hpvxp0nlh3sxy2	\N	Thủy Tam Kỳ	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.94	2026-04-16 20:21:14.94
cmo1xcrb606hsvxp026iydp7p	cmo1xcrb606htvxp03r5u3mh6	\N	Trang Vũng Tàu	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.947	2026-04-16 20:21:14.947
cmo1xcrbe06hwvxp0cieaxvnh	cmo1xcrbe06hxvxp0p24md1kj	\N	Thừa Sg	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.954	2026-04-16 20:21:14.954
cmo1xcrbl06i0vxp0j5xq4xvd	cmo1xcrbl06i1vxp0aytihk15	\N	Hương Farm	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.961	2026-04-16 20:21:14.961
cmo1xcrbt06i4vxp08mtwumwa	cmo1xcrbt06i5vxp0lu3s6kf5	\N	Oanh Lagi	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.969	2026-04-16 20:21:14.969
cmo1xcrbz06i8vxp0wcyj5y10	cmo1xcrbz06i9vxp0ol9bvbjo	\N	Ý Trương Sg	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.975	2026-04-16 20:21:14.975
cmo1xcrc506icvxp0b8nvgisz	cmo1xcrc506idvxp0bpsdlmsy	\N	Thu Sg	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.981	2026-04-16 20:21:14.981
cmo1xcrcc06igvxp0ol3htnn0	cmo1xcrcc06ihvxp0sftkh82m	\N	Hiếu Vũng Tàu	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.988	2026-04-16 20:21:14.988
cmo1xcrcj06ikvxp0w94z7c2j	cmo1xcrcj06ilvxp0v95itwc1	\N	Nam An (21tđ)	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:14.995	2026-04-16 20:21:14.995
cmo1xcrcq06iovxp0z2gpddcc	cmo1xcrcq06ipvxp0j0ihn1gy	\N	Kim Dung Nghệ An	cmo1xc12a000nvxp0f1zf3aqg	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:15.003	2026-04-16 20:21:15.003
cmo1xcrcz06isvxp0222mus52	cmo1xcrcz06itvxp0oc0nrn63	\N	Nga Nguyễn Đn	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:15.011	2026-04-16 20:21:15.011
cmo1xcrd706iwvxp0febwd4le	cmo1xcrd706ixvxp04tvatd4a	\N	Sương Sg	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:15.019	2026-04-16 20:21:15.019
cmo1xcrde06j0vxp0jimqyc67	cmo1xcrde06j1vxp0ufc0d89w	\N	Lê Bích Sg	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:15.026	2026-04-16 20:21:15.026
cmo1xcrdk06j4vxp0jtsoq0oz	cmo1xcrdk06j5vxp02sepgcrz	\N	Tim Võ	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:15.033	2026-04-16 20:21:15.033
cmo1xcrdr06j8vxp0fovu8s2l	cmo1xcrdr06j9vxp08prx5q08	\N	Thanh Thảo Sg	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:15.04	2026-04-16 20:21:15.04
cmo1xcrdz06jcvxp0qcg62a9n	cmo1xcrdz06jdvxp0llxapycu	\N	Thảo Nguyên Nha Trang	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:15.047	2026-04-16 20:21:15.047
cmo1xcre506jgvxp01w2tai29	cmo1xcre506jhvxp0t3qwm8rz	\N	Thủy Sg	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:15.054	2026-04-16 20:21:15.054
cmo1xcreb06jkvxp0meltei09	cmo1xcreb06jlvxp03odnnubk	\N	Dương Vũng Tàu	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:15.06	2026-04-16 20:21:15.06
cmo1xcrek06jovxp0k2xjyn7r	cmo1xcrek06jpvxp088nsivdj	\N	Phan Nguyệt Mai	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:15.068	2026-04-16 20:21:15.068
cmo1xcrer06jsvxp0a01fgb7q	cmo1xcrer06jtvxp02kh5x827	\N	Dung Vũ	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:15.076	2026-04-16 20:21:15.076
cmo1xcrf106jwvxp00j8mbwc7	cmo1xcrf106jxvxp0ll1ed5lr	\N	Ngọc Vinh	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:15.085	2026-04-16 20:21:15.085
cmo1xcrf806k0vxp0y2b1t7az	cmo1xcrf806k1vxp04phm8jab	\N	Thanh Bắc	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:15.093	2026-04-16 20:21:15.093
cmo1xcrfw06k4vxp0sykf6x9m	cmo1xcrfw06k5vxp0i65ws96b	\N	Nhung Pq	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:15.116	2026-04-16 20:21:15.116
cmo1xcrg406k8vxp0shf4jyp0	cmo1xcrg406k9vxp0zguyvqpd	\N	Phụng Nguyên Đồng Nai	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:15.124	2026-04-16 20:21:15.124
cmo1xcrga06kcvxp0qfagj17s	cmo1xcrga06kdvxp0oople1fg	\N	Liên Nguyễn	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:15.131	2026-04-16 20:21:15.131
cmo1xcrgi06kgvxp0o4548kah	cmo1xcrgi06khvxp0od75t7zh	\N	Ong Thái Phương	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:15.138	2026-04-16 20:21:15.138
cmo1xcrgq06kkvxp05334tslb	cmo1xcrgq06klvxp08gcv4fuz	\N	Hương Huế	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:15.146	2026-04-16 20:21:15.146
cmo1xcrgx06kovxp09nnsfi37	cmo1xcrgx06kpvxp0e16ikmxy	\N	Trang Đồng Xoài	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:15.154	2026-04-16 20:21:15.154
cmo1xcrh706ksvxp0m49c4xpr	cmo1xcrh706ktvxp079yw8sqb	\N	Hoa Sg	cmo1xc12i000ovxp01nisgvnu	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:15.163	2026-04-16 20:21:15.163
cmo1xcrhf06kwvxp0es0ekp9v	cmo1xcrhf06kxvxp0b8qe8c1l	\N	Thủy Tiên Đl	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:15.171	2026-04-16 20:21:15.171
cmo1xcrhp06l0vxp0qhawd1ax	cmo1xcrhp06l1vxp09bsrsudc	\N	Bích Thảo Nt	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:15.181	2026-04-16 20:21:15.181
cmo1xcrhw06l4vxp0p7rfz4yn	cmo1xcrhw06l5vxp0rcjwod2d	\N	Vân Nt	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:15.188	2026-04-16 20:21:15.188
cmo1xcri406l8vxp0klzfhkpw	cmo1xcri406l9vxp0lfyj3x11	\N	Chi Bùi	cmo1xc119000jvxp01snwxzoa	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:15.196	2026-04-16 20:21:15.196
cmo1xcric06lcvxp0hm9w5act	cmo1xcric06ldvxp0mxfw5gyj	\N	Hoàng Nguyên Đn	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:15.204	2026-04-16 20:21:15.204
cmo1xcrim06lgvxp06ucpzvtz	cmo1xcrim06lhvxp09oe6wnk2	\N	Trâm Trần Bd	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:15.214	2026-04-16 20:21:15.214
cmo1xcrit06lkvxp0dscqc5rd	cmo1xcrit06llvxp0zztw4i3k	\N	Gđ Thảo Pq	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:15.221	2026-04-16 20:21:15.221
cmo1xcrj206lovxp0zwdjohxj	cmo1xcrj206lpvxp04bcom3ai	\N	Trà Py	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:15.23	2026-04-16 20:21:15.23
cmo1xcrj906lsvxp09gctg6n1	cmo1xcrj906ltvxp01ecs1kwj	\N	Thanh Hương	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:15.238	2026-04-16 20:21:15.238
cmo1xcrjg06lwvxp0m3m2kmjx	cmo1xcrjg06lxvxp0onnn1brr	\N	Khanh Lê	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:15.244	2026-04-16 20:21:15.244
cmo1xcrjo06m0vxp0a28iyx6h	cmo1xcrjo06m1vxp0sym0osp8	\N	Minh Gl	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:15.252	2026-04-16 20:21:15.252
cmo1xcrjv06m4vxp0c10akwia	cmo1xcrjv06m5vxp01qhy5gum	\N	Hạnh Nhi (fb Chị Ly)	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:15.259	2026-04-16 20:21:15.259
cmo1xcrk406m8vxp0srewa4zn	cmo1xcrk406m9vxp0xfhf5x3d	\N	Uyên Trương	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:15.268	2026-04-16 20:21:15.268
cmo1xcrkc06mcvxp0mi9450i3	cmo1xcrkc06mdvxp0mfcs8v2t	\N	Ngọc Fram	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:15.276	2026-04-16 20:21:15.276
cmo1xcrkl06mgvxp0rronkitc	cmo1xcrkl06mhvxp0l35b7k0d	\N	Mai Linh Py	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:15.285	2026-04-16 20:21:15.285
cmo1xcrks06mkvxp09pv9ppoy	cmo1xcrks06mlvxp06s2txe8m	\N	Đa Thảo Quãng Ngãi	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:15.292	2026-04-16 20:21:15.292
cmo1xcrl106movxp0rj01jv8j	cmo1xcrl106mpvxp03yb9i4x4	\N	Đinh Hồng Sg	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:15.301	2026-04-16 20:21:15.301
cmo1xcrl806msvxp0dpf3ty63	cmo1xcrl806mtvxp0jmvq3ojw	\N	Trang Phạm	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:15.308	2026-04-16 20:21:15.308
cmo1xcrle06mwvxp0zz80y50h	cmo1xcrle06mxvxp0yuom3amn	\N	Nga Ngô	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:15.314	2026-04-16 20:21:15.314
cmo1xcrll06n0vxp0rit8294j	cmo1xcrll06n1vxp0pfzbmrbl	\N	Hiền Trần	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:15.321	2026-04-16 20:21:15.321
cmo1xcrlt06n4vxp084219urn	cmo1xcrlt06n5vxp04x4t75h8	\N	Trâm Q10	cmo1xc12q000pvxp0kun82k4l	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:15.329	2026-04-16 20:21:15.329
cmo1xcrm006n8vxp0logw1j13	cmo1xcrm006n9vxp08scs9azu	\N	Nghĩa Qn	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:15.337	2026-04-16 20:21:15.337
cmo1xcrm606ncvxp0kj4vqpj3	cmo1xcrm706ndvxp0iool3z5u	\N	Thúy Đoàn	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:15.343	2026-04-16 20:21:15.343
cmo1xcrme06ngvxp0f817kp5b	cmo1xcrme06nhvxp0x51b8hoz	\N	Hạnh Nguyên Đn	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:15.35	2026-04-16 20:21:15.35
cmo1xcrml06nkvxp0zqb45g5e	cmo1xcrml06nlvxp0bpzd9rfe	\N	Nghiêm Tuyền (ngân Hà)	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:15.357	2026-04-16 20:21:15.357
cmo1xcrms06novxp0pgxp1a2h	cmo1xcrms06npvxp0sve5j634	\N	Thảo Vũng Tàu	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:15.365	2026-04-16 20:21:15.365
cmo1xcrmz06nsvxp0d3yzyfbh	cmo1xcrmz06ntvxp09gtu30ra	\N	Trúc Dâng Ct	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:15.371	2026-04-16 20:21:15.371
cmo1xcrn906nwvxp0v2awrc9x	cmo1xcrn906nxvxp0aa5arkek	\N	Vy Sg	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:15.381	2026-04-16 20:21:15.381
cmo1xcrng06o0vxp0lue4fyk4	cmo1xcrng06o1vxp0pavwaxd5	\N	Loan Phạm Hp	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:15.388	2026-04-16 20:21:15.388
cmo1xcrnp06o4vxp0ankpamsk	cmo1xcrnp06o5vxp0q6z258oj	\N	Kiều Hn	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:15.397	2026-04-16 20:21:15.397
cmo1xcrny06o8vxp0ha7lyajr	cmo1xcrny06o9vxp0ctb97676	\N	Bảo Anh Đn	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:15.406	2026-04-16 20:21:15.406
cmo1xcro506ocvxp0vjubuija	cmo1xcro506odvxp0x6h0s66m	\N	Lan Bùi Sg (zl)	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:15.414	2026-04-16 20:21:15.414
cmo1xcrob06ogvxp0iwtyxq4y	cmo1xcrob06ohvxp0xce2i1iz	\N	Liên Thủy	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:15.42	2026-04-16 20:21:15.42
cmo1xcroi06okvxp0i70ce98c	cmo1xcroi06olvxp0312cx6y9	\N	Nguyệt Ánh Qn	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:15.426	2026-04-16 20:21:15.426
cmo1xcroo06oovxp0jha5py71	cmo1xcroo06opvxp0x5au3jxh	\N	Uyên Đn	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:15.433	2026-04-16 20:21:15.433
cmo1xcrou06osvxp03e4a8261	cmo1xcrou06otvxp0f7r4x1hd	\N	Vita	cmo1xc12y000qvxp0uqc7d8d8	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:15.439	2026-04-16 20:21:15.439
cmo1xcrp006owvxp069mxeo1t	cmo1xcrp006oxvxp012nqfhgr	\N	Vân Qn	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:15.444	2026-04-16 20:21:15.444
cmo1xcrp706p0vxp0yhn35nsc	cmo1xcrp706p1vxp00o3nt69k	\N	Hippicuc	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:15.452	2026-04-16 20:21:15.452
cmo1xcrpe06p4vxp0z4tnfurt	cmo1xcrpe06p5vxp03de5762k	\N	Uyên Hoàng	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:15.459	2026-04-16 20:21:15.459
cmo1xcrpk06p8vxp03j9lx88y	cmo1xcrpk06p9vxp04k6waz78	\N	Mỹ Thảo	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:15.465	2026-04-16 20:21:15.465
cmo1xcrpr06pcvxp01wdc8ecn	cmo1xcrpr06pdvxp04ksa7b4g	\N	Loan Vinh	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:15.471	2026-04-16 20:21:15.471
cmo1xcrpz06pgvxp0c445f5pv	cmo1xcrpz06phvxp0ampsp8h1	\N	Hưởng Lê	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:15.479	2026-04-16 20:21:15.479
cmo1xcrq606pkvxp0skqw9kjk	cmo1xcrq606plvxp0j4pou2y6	\N	Thảo Lavie	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:15.487	2026-04-16 20:21:15.487
cmo1xcrqd06povxp0xkvscm03	cmo1xcrqd06ppvxp02k4fzmtm	\N	Dạ Vũ	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:15.493	2026-04-16 20:21:15.493
cmo1xcrql06psvxp0vp4zxbge	cmo1xcrql06ptvxp02n5bxani	\N	Tuấn Đl	cmo1xc138000rvxp0r16wi1bz	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:15.501	2026-04-16 20:21:15.501
cmo1xcrqs06pwvxp0h7sl7hoo	cmo1xcrqs06pxvxp0ey6ozayl	\N	Thảo Cella	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:15.509	2026-04-16 20:21:15.509
cmo1xcrqz06q0vxp0dw36i8ty	cmo1xcrqz06q1vxp08exobpg7	\N	Vy Qn	cmo1xc13g000svxp0tbndc1wg	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:15.515	2026-04-16 20:21:15.515
cmo1xcrr506q4vxp0pad0iakr	cmo1xcrr506q5vxp0odjjc5xu	\N	Phương Hpg Zalo	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:15.521	2026-04-16 20:21:15.521
cmo1xcrra06q8vxp0cg9evek7	cmo1xcrra06q9vxp02zllgqm6	\N	Hải Nam (nt)	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:15.527	2026-04-16 20:21:15.527
cmo1xcrri06qcvxp01d4kkc1u	cmo1xcrri06qdvxp064kp87pc	\N	Mỹ An	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:15.534	2026-04-16 20:21:15.534
cmo1xcrrp06qgvxp0vm0lbz9u	cmo1xcrrp06qhvxp0q94mzo2w	\N	Phước Linh	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:15.541	2026-04-16 20:21:15.541
cmo1xcrrv06qkvxp07rs1d8ki	cmo1xcrrv06qlvxp062xk7cqk	\N	Vcm	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:15.548	2026-04-16 20:21:15.548
cmo1xcrs206qovxp0oltqpotp	cmo1xcrs206qpvxp03bwetgz7	\N	Cẩm Thạch	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:15.555	2026-04-16 20:21:15.555
cmo1xcrsc06qsvxp0gkx4oevq	cmo1xcrsc06qtvxp0eg638r4j	\N	Hoàng Hương Nt	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:15.564	2026-04-16 20:21:15.564
cmo1xcrsi06qwvxp09xd9tgdg	cmo1xcrsi06qxvxp0lxrvtz57	\N	Hoài Mộng	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:15.57	2026-04-16 20:21:15.57
cmo1xcrso06r0vxp0qg4mpbo9	cmo1xcrso06r1vxp0iybd44at	\N	Thiện Hảo	cmo1xc119000jvxp01snwxzoa	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:15.576	2026-04-16 20:21:15.576
cmo1xcrsv06r4vxp06tay1nx9	cmo1xcrsv06r5vxp075u0migd	\N	Su Đn	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:15.583	2026-04-16 20:21:15.583
cmo1xcrt206r8vxp0yyxoyddd	cmo1xcrt206r9vxp0zpt28oi9	\N	Yumil	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:15.59	2026-04-16 20:21:15.59
cmo1xcrt806rcvxp0ru53x7po	cmo1xcrt806rdvxp0l2pbkj65	\N	Thúy Đl	cmo1xc138000rvxp0r16wi1bz	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:15.597	2026-04-16 20:21:15.597
cmo1xcrtg06rgvxp0ul51poiu	cmo1xcrtg06rhvxp094a3l3w8	\N	Sương	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:15.604	2026-04-16 20:21:15.604
cmo1xcrto06rkvxp0kkz3qr13	cmo1xcrto06rlvxp0pndvm9wv	\N	Thúy Vi	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:15.612	2026-04-16 20:21:15.612
cmo1xcrtu06rovxp097a2l0e8	cmo1xcrtu06rpvxp0b9bnvul0	\N	Phương Thảo	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:15.619	2026-04-16 20:21:15.619
cmo1xcru106rsvxp03qzg9w5d	cmo1xcru106rtvxp087t73hnu	\N	Tú Anh	cmo1xc13o000tvxp0alok8jeb	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:15.626	2026-04-16 20:21:15.626
cmo1xcru706rwvxp0go180i04	cmo1xcru706rxvxp07jlwhqh6	\N	Cửa Hàng Rau Mầm	cmo1xc10u000hvxp0dapryn3r	\N	\N	\N	\N	\N	\N	t	2026-04-16 20:21:15.632	2026-04-16 20:21:15.632
\.


--
-- Data for Name: order_items; Type: TABLE DATA; Schema: public; Owner: oms_user
--

COPY public.order_items (id, "orderId", "productId", "snapshotProductName", "snapshotProductSku", "snapshotProductUnit", "snapshotUnitPrice", "priceSource", "pricingNote", quantity, "lineDiscount", "lineTotal") FROM stdin;
\.


--
-- Data for Name: orders; Type: TABLE DATA; Schema: public; Owner: oms_user
--

COPY public.orders (id, "orderNumber", "customerId", "snapshotCustomerName", "snapshotCustomerPhone", "createdById", "deliveryStatus", subtotal, "discountAmount", "shippingFee", "totalAmount", "cancelReasonId", "cancelNotes", notes, "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: product_categories; Type: TABLE DATA; Schema: public; Owner: oms_user
--

COPY public.product_categories (id, name, code, description, "isActive", "createdAt", "updatedAt") FROM stdin;
cmo1xc0tk0000vxp0m1od0byy	Xuân Lộc	XUANLOC	\N	t	2026-04-16 20:20:40.616	2026-04-16 20:20:40.616
cmo1xc0vc0002vxp0ro9otvn0	Hàng tươi	HANGTUOI	\N	t	2026-04-16 20:20:40.681	2026-04-16 20:20:40.681
cmo1xc0vm0003vxp0pmlb0lvi	Khác	KHAC	\N	t	2026-04-16 20:20:40.691	2026-04-16 20:20:40.691
cmo1xybh10000vxi4nigilgz5	Xuân Lộc KHD	XLKHD	\N	t	2026-04-16 20:38:00.854	2026-04-16 20:38:00.854
cmo1xc0ux0001vxp0gekkc5lr	Mountain Farmers	MOUNTAIN	\N	t	2026-04-16 20:20:40.666	2026-04-16 21:14:00.406
cmo1xc0vw0004vxp0uzuqvrgw	Mountain Farmers KHD	MFKHD	\N	t	2026-04-16 20:20:40.701	2026-04-16 21:14:14.319
\.


--
-- Data for Name: product_group_prices; Type: TABLE DATA; Schema: public; Owner: oms_user
--

COPY public.product_group_prices (id, "productId", "groupId", "fixedPrice", "createdAt", "updatedAt") FROM stdin;
cmo1y8tv50003vxt07rg6e8ow	cmo1y8tuw0001vxt0dsvpt8f1	cmo1xsgrt0022vxv8sd7cckj7	65000	2026-04-16 20:46:11.249	2026-04-16 20:46:11.249
cmo1y8tvd0005vxt0f66tfufo	cmo1y8tuw0001vxt0dsvpt8f1	cmo1xc11v000lvxp07r6uljko	65000	2026-04-16 20:46:11.257	2026-04-16 20:46:11.257
cmo1y8tvw0007vxt0d5c6pylh	cmo1y8tuw0001vxt0dsvpt8f1	cmo1xc10u000hvxp0dapryn3r	65000	2026-04-16 20:46:11.277	2026-04-16 20:46:11.277
cmo1y8tw9000bvxt0yyhmia33	cmo1y8tw30009vxt0olpvrsao	cmo1xsgrt0022vxv8sd7cckj7	65000	2026-04-16 20:46:11.289	2026-04-16 20:46:11.289
cmo1y8twe000dvxt0234h4wzp	cmo1y8tw30009vxt0olpvrsao	cmo1xc11v000lvxp07r6uljko	65000	2026-04-16 20:46:11.295	2026-04-16 20:46:11.295
cmo1y8twl000fvxt030k8e4mn	cmo1y8tw30009vxt0olpvrsao	cmo1xc12y000qvxp0uqc7d8d8	65000	2026-04-16 20:46:11.302	2026-04-16 20:46:11.302
cmo1y8tws000hvxt043tin1pg	cmo1y8tw30009vxt0olpvrsao	cmo1xc13g000svxp0tbndc1wg	65000	2026-04-16 20:46:11.308	2026-04-16 20:46:11.308
cmo1y8twz000jvxt0o2gmt7ed	cmo1y8tw30009vxt0olpvrsao	cmo1xc12q000pvxp0kun82k4l	65000	2026-04-16 20:46:11.315	2026-04-16 20:46:11.315
cmo1y8tx5000lvxt0v2516ja6	cmo1y8tw30009vxt0olpvrsao	cmo1xc138000rvxp0r16wi1bz	65000	2026-04-16 20:46:11.322	2026-04-16 20:46:11.322
cmo1y8txc000nvxt0by4nx3fe	cmo1y8tw30009vxt0olpvrsao	cmo1xc12i000ovxp01nisgvnu	65000	2026-04-16 20:46:11.328	2026-04-16 20:46:11.328
cmo1y8txj000pvxt0i2hd0kof	cmo1y8tw30009vxt0olpvrsao	cmo1xc13o000tvxp0alok8jeb	65000	2026-04-16 20:46:11.335	2026-04-16 20:46:11.335
cmo1y8txq000rvxt0j90uqlai	cmo1y8tw30009vxt0olpvrsao	cmo1xc11n000kvxp0g32oj3wx	65000	2026-04-16 20:46:11.342	2026-04-16 20:46:11.342
cmo1y8txw000tvxt0idx10423	cmo1y8tw30009vxt0olpvrsao	cmo1xc10u000hvxp0dapryn3r	65000	2026-04-16 20:46:11.348	2026-04-16 20:46:11.348
cmo1y8ty2000vvxt0mzm8ybs6	cmo1y8tw30009vxt0olpvrsao	cmo1xc119000jvxp01snwxzoa	65000	2026-04-16 20:46:11.354	2026-04-16 20:46:11.354
cmo1y8tye000zvxt0hx51wu7n	cmo1y8ty8000xvxt0rxx8s0y8	cmo1xsgrt0022vxv8sd7cckj7	185000	2026-04-16 20:46:11.366	2026-04-16 20:46:11.366
cmo1y8tyk0011vxt0t5ey0u0k	cmo1y8ty8000xvxt0rxx8s0y8	cmo1xc11v000lvxp07r6uljko	185000	2026-04-16 20:46:11.372	2026-04-16 20:46:11.372
cmo1y8tyz0013vxt0iwckw68p	cmo1y8ty8000xvxt0rxx8s0y8	cmo1xc10u000hvxp0dapryn3r	185000	2026-04-16 20:46:11.388	2026-04-16 20:46:11.388
cmo1y8tzd0017vxt036hc1r03	cmo1y8tz70015vxt0h2s7xepy	cmo1xsgrt0022vxv8sd7cckj7	38000	2026-04-16 20:46:11.401	2026-04-16 20:46:11.401
cmo1y8tzi0019vxt03k1izq9q	cmo1y8tz70015vxt0h2s7xepy	cmo1xc11v000lvxp07r6uljko	38000	2026-04-16 20:46:11.407	2026-04-16 20:46:11.407
cmo1y8tzn001bvxt047kepwvr	cmo1y8tz70015vxt0h2s7xepy	cmo1xc12y000qvxp0uqc7d8d8	38000	2026-04-16 20:46:11.412	2026-04-16 20:46:11.412
cmo1y8tzu001dvxt0qjwha3ku	cmo1y8tz70015vxt0h2s7xepy	cmo1xc13g000svxp0tbndc1wg	38000	2026-04-16 20:46:11.418	2026-04-16 20:46:11.418
cmo1y8u00001fvxt0zoi2omiy	cmo1y8tz70015vxt0h2s7xepy	cmo1xc12q000pvxp0kun82k4l	38000	2026-04-16 20:46:11.424	2026-04-16 20:46:11.424
cmo1y8u07001hvxt0gooaby9e	cmo1y8tz70015vxt0h2s7xepy	cmo1xc12i000ovxp01nisgvnu	38000	2026-04-16 20:46:11.431	2026-04-16 20:46:11.431
cmo1y8u0e001jvxt0z8ecmyie	cmo1y8tz70015vxt0h2s7xepy	cmo1xc13o000tvxp0alok8jeb	38000	2026-04-16 20:46:11.438	2026-04-16 20:46:11.438
cmo1y8u0p001lvxt09odkny9s	cmo1y8tz70015vxt0h2s7xepy	cmo1xc10u000hvxp0dapryn3r	38000	2026-04-16 20:46:11.449	2026-04-16 20:46:11.449
cmo1y8u0v001nvxt0ebkdyti7	cmo1y8tz70015vxt0h2s7xepy	cmo1xc119000jvxp01snwxzoa	38000	2026-04-16 20:46:11.455	2026-04-16 20:46:11.455
cmo1y8u18001rvxt0ots40hbh	cmo1y8u11001pvxt0j4rb9sxw	cmo1xsgrt0022vxv8sd7cckj7	95000	2026-04-16 20:46:11.468	2026-04-16 20:46:11.468
cmo1y8u1e001tvxt0kd0bz532	cmo1y8u11001pvxt0j4rb9sxw	cmo1xc11v000lvxp07r6uljko	95000	2026-04-16 20:46:11.475	2026-04-16 20:46:11.475
cmo1y8u1l001vvxt0pcuvn5gh	cmo1y8u11001pvxt0j4rb9sxw	cmo1xc12y000qvxp0uqc7d8d8	95000	2026-04-16 20:46:11.481	2026-04-16 20:46:11.481
cmo1y8u1r001xvxt0h37v4sc5	cmo1y8u11001pvxt0j4rb9sxw	cmo1xc13g000svxp0tbndc1wg	95000	2026-04-16 20:46:11.488	2026-04-16 20:46:11.488
cmo1y8u1y001zvxt0kd8t7jnz	cmo1y8u11001pvxt0j4rb9sxw	cmo1xc12q000pvxp0kun82k4l	95000	2026-04-16 20:46:11.494	2026-04-16 20:46:11.494
cmo1y8u240021vxt0u9hcgsl8	cmo1y8u11001pvxt0j4rb9sxw	cmo1xc138000rvxp0r16wi1bz	90000	2026-04-16 20:46:11.501	2026-04-16 20:46:11.501
cmo1y8u2b0023vxt0o27c9mfg	cmo1y8u11001pvxt0j4rb9sxw	cmo1xc12i000ovxp01nisgvnu	95000	2026-04-16 20:46:11.507	2026-04-16 20:46:11.507
cmo1y8u2h0025vxt097017e70	cmo1y8u11001pvxt0j4rb9sxw	cmo1xc13o000tvxp0alok8jeb	90000	2026-04-16 20:46:11.513	2026-04-16 20:46:11.513
cmo1y8u2n0027vxt0m0zwyxhh	cmo1y8u11001pvxt0j4rb9sxw	cmo1xc123000mvxp0ul7pkio2	90000	2026-04-16 20:46:11.519	2026-04-16 20:46:11.519
cmo1y8u2s0029vxt08fbiynyh	cmo1y8u11001pvxt0j4rb9sxw	cmo1xc11n000kvxp0g32oj3wx	95000	2026-04-16 20:46:11.524	2026-04-16 20:46:11.524
cmo1y8u2x002bvxt0x6ewke3j	cmo1y8u11001pvxt0j4rb9sxw	cmo1xc10u000hvxp0dapryn3r	95000	2026-04-16 20:46:11.529	2026-04-16 20:46:11.529
cmo1y8u33002dvxt0ff6bqooi	cmo1y8u11001pvxt0j4rb9sxw	cmo1xc119000jvxp01snwxzoa	95000	2026-04-16 20:46:11.535	2026-04-16 20:46:11.535
cmo1y8u3e002hvxt06452x8ky	cmo1y8u38002fvxt0n4rymwyf	cmo1xsgrt0022vxv8sd7cckj7	40000	2026-04-16 20:46:11.546	2026-04-16 20:46:11.546
cmo1y8u3k002jvxt0j40qpo2u	cmo1y8u38002fvxt0n4rymwyf	cmo1xc11v000lvxp07r6uljko	40000	2026-04-16 20:46:11.552	2026-04-16 20:46:11.552
cmo1y8u3p002lvxt00ie64ksr	cmo1y8u38002fvxt0n4rymwyf	cmo1xc12y000qvxp0uqc7d8d8	40000	2026-04-16 20:46:11.557	2026-04-16 20:46:11.557
cmo1y8u3u002nvxt0lq141nup	cmo1y8u38002fvxt0n4rymwyf	cmo1xc13g000svxp0tbndc1wg	40000	2026-04-16 20:46:11.562	2026-04-16 20:46:11.562
cmo1y8u41002pvxt0x0lrx5gm	cmo1y8u38002fvxt0n4rymwyf	cmo1xc12q000pvxp0kun82k4l	40000	2026-04-16 20:46:11.569	2026-04-16 20:46:11.569
cmo1y8u47002rvxt0rz79c2zl	cmo1y8u38002fvxt0n4rymwyf	cmo1xc138000rvxp0r16wi1bz	40000	2026-04-16 20:46:11.575	2026-04-16 20:46:11.575
cmo1y8u4d002tvxt0fb40ns4v	cmo1y8u38002fvxt0n4rymwyf	cmo1xc12i000ovxp01nisgvnu	40000	2026-04-16 20:46:11.581	2026-04-16 20:46:11.581
cmo1y8u4i002vvxt0on8tmsu9	cmo1y8u38002fvxt0n4rymwyf	cmo1xc13o000tvxp0alok8jeb	40000	2026-04-16 20:46:11.587	2026-04-16 20:46:11.587
cmo1y8u4n002xvxt0494f30y6	cmo1y8u38002fvxt0n4rymwyf	cmo1xc123000mvxp0ul7pkio2	40000	2026-04-16 20:46:11.592	2026-04-16 20:46:11.592
cmo1y8u4t002zvxt04skll60k	cmo1y8u38002fvxt0n4rymwyf	cmo1xc11n000kvxp0g32oj3wx	43000	2026-04-16 20:46:11.597	2026-04-16 20:46:11.597
cmo1y8u4z0031vxt0u837hxat	cmo1y8u38002fvxt0n4rymwyf	cmo1xc10u000hvxp0dapryn3r	40000	2026-04-16 20:46:11.603	2026-04-16 20:46:11.603
cmo1y8u540033vxt0lw41wg0s	cmo1y8u38002fvxt0n4rymwyf	cmo1xc119000jvxp01snwxzoa	40000	2026-04-16 20:46:11.609	2026-04-16 20:46:11.609
cmo1y8u5g0037vxt0crg4mttk	cmo1y8u5a0035vxt05r79ntvj	cmo1xsgrt0022vxv8sd7cckj7	352000	2026-04-16 20:46:11.62	2026-04-16 20:46:11.62
cmo1y8u5l0039vxt0ytrfkwga	cmo1y8u5a0035vxt05r79ntvj	cmo1xc11v000lvxp07r6uljko	352000	2026-04-16 20:46:11.626	2026-04-16 20:46:11.626
cmo1y8u5s003bvxt0n1320zox	cmo1y8u5a0035vxt05r79ntvj	cmo1xc13g000svxp0tbndc1wg	352000	2026-04-16 20:46:11.632	2026-04-16 20:46:11.632
cmo1y8u60003dvxt014oy8kos	cmo1y8u5a0035vxt05r79ntvj	cmo1xc12q000pvxp0kun82k4l	352000	2026-04-16 20:46:11.64	2026-04-16 20:46:11.64
cmo1y8u66003fvxt0npcjhcb3	cmo1y8u5a0035vxt05r79ntvj	cmo1xc138000rvxp0r16wi1bz	352000	2026-04-16 20:46:11.647	2026-04-16 20:46:11.647
cmo1y8u6d003hvxt0y019hsw5	cmo1y8u5a0035vxt05r79ntvj	cmo1xc12i000ovxp01nisgvnu	352000	2026-04-16 20:46:11.653	2026-04-16 20:46:11.653
cmo1y8u6k003jvxt0v3gu41rj	cmo1y8u5a0035vxt05r79ntvj	cmo1xc13o000tvxp0alok8jeb	352000	2026-04-16 20:46:11.66	2026-04-16 20:46:11.66
cmo1y8u6s003lvxt03kq6gnf3	cmo1y8u5a0035vxt05r79ntvj	cmo1xc11n000kvxp0g32oj3wx	352000	2026-04-16 20:46:11.668	2026-04-16 20:46:11.668
cmo1y8u6z003nvxt0z91x9owz	cmo1y8u5a0035vxt05r79ntvj	cmo1xc10u000hvxp0dapryn3r	352000	2026-04-16 20:46:11.675	2026-04-16 20:46:11.675
cmo1y8u76003pvxt0ntm9zfir	cmo1y8u5a0035vxt05r79ntvj	cmo1xc119000jvxp01snwxzoa	352000	2026-04-16 20:46:11.683	2026-04-16 20:46:11.683
cmo1y8u7q003tvxt0x2lhbb0l	cmo1y8u7d003rvxt05ljfbjw3	cmo1xsgrt0022vxv8sd7cckj7	230000	2026-04-16 20:46:11.702	2026-04-16 20:46:11.702
cmo1y8u80003vvxt0pz7piuf9	cmo1y8u7d003rvxt05ljfbjw3	cmo1xc11v000lvxp07r6uljko	230000	2026-04-16 20:46:11.712	2026-04-16 20:46:11.712
cmo1y8u8m003xvxt0cdjag9oy	cmo1y8u7d003rvxt05ljfbjw3	cmo1xc10u000hvxp0dapryn3r	230000	2026-04-16 20:46:11.734	2026-04-16 20:46:11.734
cmo1y8u8z0041vxt0j71y62r2	cmo1y8u8t003zvxt0takkufpe	cmo1xsgrt0022vxv8sd7cckj7	45000	2026-04-16 20:46:11.748	2026-04-16 20:46:11.748
cmo1y8u950043vxt0y3z4vsq1	cmo1y8u8t003zvxt0takkufpe	cmo1xc11v000lvxp07r6uljko	45000	2026-04-16 20:46:11.753	2026-04-16 20:46:11.753
cmo1y8u9b0045vxt04rzhixay	cmo1y8u8t003zvxt0takkufpe	cmo1xc12y000qvxp0uqc7d8d8	45000	2026-04-16 20:46:11.759	2026-04-16 20:46:11.759
cmo1y8u9h0047vxt0b1peytaa	cmo1y8u8t003zvxt0takkufpe	cmo1xc13g000svxp0tbndc1wg	45000	2026-04-16 20:46:11.765	2026-04-16 20:46:11.765
cmo1y8u9p0049vxt0wi44esm0	cmo1y8u8t003zvxt0takkufpe	cmo1xc12q000pvxp0kun82k4l	45000	2026-04-16 20:46:11.773	2026-04-16 20:46:11.773
cmo1y8u9w004bvxt05d2btqt7	cmo1y8u8t003zvxt0takkufpe	cmo1xc138000rvxp0r16wi1bz	45000	2026-04-16 20:46:11.78	2026-04-16 20:46:11.78
cmo1y8ua2004dvxt0pvwwsqko	cmo1y8u8t003zvxt0takkufpe	cmo1xc12i000ovxp01nisgvnu	45000	2026-04-16 20:46:11.787	2026-04-16 20:46:11.787
cmo1y8ua9004fvxt0i7qpbuxr	cmo1y8u8t003zvxt0takkufpe	cmo1xc13o000tvxp0alok8jeb	45000	2026-04-16 20:46:11.793	2026-04-16 20:46:11.793
cmo1y8uag004hvxt0q58rmdw4	cmo1y8u8t003zvxt0takkufpe	cmo1xc11n000kvxp0g32oj3wx	45000	2026-04-16 20:46:11.8	2026-04-16 20:46:11.8
cmo1y8uam004jvxt0bym2fnfq	cmo1y8u8t003zvxt0takkufpe	cmo1xc10u000hvxp0dapryn3r	45000	2026-04-16 20:46:11.806	2026-04-16 20:46:11.806
cmo1y8uas004lvxt0n5wye3kg	cmo1y8u8t003zvxt0takkufpe	cmo1xc119000jvxp01snwxzoa	45000	2026-04-16 20:46:11.812	2026-04-16 20:46:11.812
cmo1y8ub4004pvxt0qlq1i1w7	cmo1y8uay004nvxt0q8k52q8v	cmo1xsgrt0022vxv8sd7cckj7	202000	2026-04-16 20:46:11.824	2026-04-16 20:46:11.824
cmo1y8uba004rvxt0q3ykut27	cmo1y8uay004nvxt0q8k52q8v	cmo1xc11v000lvxp07r6uljko	202000	2026-04-16 20:46:11.83	2026-04-16 20:46:11.83
cmo1y8ubk004tvxt0107x51ec	cmo1y8uay004nvxt0q8k52q8v	cmo1xc138000rvxp0r16wi1bz	202000	2026-04-16 20:46:11.841	2026-04-16 20:46:11.841
cmo1y8ubv004vvxt06r7n86tg	cmo1y8uay004nvxt0q8k52q8v	cmo1xc10u000hvxp0dapryn3r	202000	2026-04-16 20:46:11.851	2026-04-16 20:46:11.851
cmo1y8uc1004xvxt0xlbgxsy8	cmo1y8uay004nvxt0q8k52q8v	cmo1xc119000jvxp01snwxzoa	170000	2026-04-16 20:46:11.857	2026-04-16 20:46:11.857
cmo1y8ucd0051vxt08h5cu1fp	cmo1y8uc7004zvxt0t85jkibm	cmo1xsgrt0022vxv8sd7cckj7	45000	2026-04-16 20:46:11.87	2026-04-16 20:46:11.87
cmo1y8ucj0053vxt0m8u5un0j	cmo1y8uc7004zvxt0t85jkibm	cmo1xc11v000lvxp07r6uljko	45000	2026-04-16 20:46:11.875	2026-04-16 20:46:11.875
cmo1y8ucp0055vxt0crhfkwkw	cmo1y8uc7004zvxt0t85jkibm	cmo1xc12y000qvxp0uqc7d8d8	48000	2026-04-16 20:46:11.881	2026-04-16 20:46:11.881
cmo1y8ucv0057vxt0rj9v7m6y	cmo1y8uc7004zvxt0t85jkibm	cmo1xc13g000svxp0tbndc1wg	45000	2026-04-16 20:46:11.887	2026-04-16 20:46:11.887
cmo1y8ud20059vxt0y0tueve3	cmo1y8uc7004zvxt0t85jkibm	cmo1xc12q000pvxp0kun82k4l	37000	2026-04-16 20:46:11.895	2026-04-16 20:46:11.895
cmo1y8uda005bvxt051o63cql	cmo1y8uc7004zvxt0t85jkibm	cmo1xc12i000ovxp01nisgvnu	45000	2026-04-16 20:46:11.902	2026-04-16 20:46:11.902
cmo1y8udg005dvxt0cuoed35a	cmo1y8uc7004zvxt0t85jkibm	cmo1xc13o000tvxp0alok8jeb	45000	2026-04-16 20:46:11.908	2026-04-16 20:46:11.908
cmo1y8udo005fvxt0h12t2omz	cmo1y8uc7004zvxt0t85jkibm	cmo1xc11n000kvxp0g32oj3wx	48000	2026-04-16 20:46:11.916	2026-04-16 20:46:11.916
cmo1y8udu005hvxt0ra15r7og	cmo1y8uc7004zvxt0t85jkibm	cmo1xc10u000hvxp0dapryn3r	45000	2026-04-16 20:46:11.922	2026-04-16 20:46:11.922
cmo1y8udz005jvxt0ed4jbbul	cmo1y8uc7004zvxt0t85jkibm	cmo1xc119000jvxp01snwxzoa	45000	2026-04-16 20:46:11.928	2026-04-16 20:46:11.928
cmo1y8uec005nvxt0mje2f0hf	cmo1y8ue6005lvxt0k6ls88dr	cmo1xsgrt0022vxv8sd7cckj7	43000	2026-04-16 20:46:11.94	2026-04-16 20:46:11.94
cmo1y8ueh005pvxt0l7579rzw	cmo1y8ue6005lvxt0k6ls88dr	cmo1xc11v000lvxp07r6uljko	43000	2026-04-16 20:46:11.946	2026-04-16 20:46:11.946
cmo1y8ueo005rvxt0meqkhwzu	cmo1y8ue6005lvxt0k6ls88dr	cmo1xc12y000qvxp0uqc7d8d8	43000	2026-04-16 20:46:11.952	2026-04-16 20:46:11.952
cmo1y8ueu005tvxt0l13bguzl	cmo1y8ue6005lvxt0k6ls88dr	cmo1xc13g000svxp0tbndc1wg	43000	2026-04-16 20:46:11.958	2026-04-16 20:46:11.958
cmo1y8uf1005vvxt04lybkya9	cmo1y8ue6005lvxt0k6ls88dr	cmo1xc12q000pvxp0kun82k4l	43000	2026-04-16 20:46:11.966	2026-04-16 20:46:11.966
cmo1y8uf8005xvxt0h4ivu9bx	cmo1y8ue6005lvxt0k6ls88dr	cmo1xc138000rvxp0r16wi1bz	43000	2026-04-16 20:46:11.972	2026-04-16 20:46:11.972
cmo1y8uff005zvxt0d4r6h8xm	cmo1y8ue6005lvxt0k6ls88dr	cmo1xc12i000ovxp01nisgvnu	43000	2026-04-16 20:46:11.979	2026-04-16 20:46:11.979
cmo1y8ufm0061vxt0meepf2wp	cmo1y8ue6005lvxt0k6ls88dr	cmo1xc13o000tvxp0alok8jeb	43000	2026-04-16 20:46:11.986	2026-04-16 20:46:11.986
cmo1y8uft0063vxt0dyikbnbh	cmo1y8ue6005lvxt0k6ls88dr	cmo1xc11n000kvxp0g32oj3wx	43000	2026-04-16 20:46:11.993	2026-04-16 20:46:11.993
cmo1y8ufy0065vxt0o010pdm2	cmo1y8ue6005lvxt0k6ls88dr	cmo1xc10u000hvxp0dapryn3r	43000	2026-04-16 20:46:11.999	2026-04-16 20:46:11.999
cmo1y8ug40067vxt04l5hpu15	cmo1y8ue6005lvxt0k6ls88dr	cmo1xc119000jvxp01snwxzoa	43000	2026-04-16 20:46:12.004	2026-04-16 20:46:12.004
cmo1y8ugf006bvxt01tq90j8q	cmo1y8ug90069vxt0izlrmf5q	cmo1xsgrt0022vxv8sd7cckj7	99000	2026-04-16 20:46:12.015	2026-04-16 20:46:12.015
cmo1y8ugk006dvxt0lhgzdpk1	cmo1y8ug90069vxt0izlrmf5q	cmo1xc11v000lvxp07r6uljko	99000	2026-04-16 20:46:12.021	2026-04-16 20:46:12.021
cmo1y8ugy006fvxt033zx4v3f	cmo1y8ug90069vxt0izlrmf5q	cmo1xc10u000hvxp0dapryn3r	99000	2026-04-16 20:46:12.035	2026-04-16 20:46:12.035
cmo1y8uhs006lvxt0kuncqwct	cmo1y8uhm006jvxt088h99zp0	cmo1xsgrt0022vxv8sd7cckj7	40000	2026-04-16 20:46:12.064	2026-04-16 20:46:12.064
cmo1y8uhx006nvxt0ovsgerqo	cmo1y8uhm006jvxt088h99zp0	cmo1xc11v000lvxp07r6uljko	40000	2026-04-16 20:46:12.07	2026-04-16 20:46:12.07
cmo1y8ui2006pvxt00r34zm1v	cmo1y8uhm006jvxt088h99zp0	cmo1xc12y000qvxp0uqc7d8d8	40000	2026-04-16 20:46:12.075	2026-04-16 20:46:12.075
cmo1y8ui8006rvxt0g0q4x9re	cmo1y8uhm006jvxt088h99zp0	cmo1xc13g000svxp0tbndc1wg	40000	2026-04-16 20:46:12.08	2026-04-16 20:46:12.08
cmo1y8uie006tvxt0p7rv58dk	cmo1y8uhm006jvxt088h99zp0	cmo1xc12a000nvxp0f1zf3aqg	40000	2026-04-16 20:46:12.086	2026-04-16 20:46:12.086
cmo1y8uik006vvxt0k1qshnfg	cmo1y8uhm006jvxt088h99zp0	cmo1xc12q000pvxp0kun82k4l	40000	2026-04-16 20:46:12.092	2026-04-16 20:46:12.092
cmo1y8uiq006xvxt0oskjw9mc	cmo1y8uhm006jvxt088h99zp0	cmo1xc138000rvxp0r16wi1bz	40000	2026-04-16 20:46:12.098	2026-04-16 20:46:12.098
cmo1y8uiv006zvxt0zrf72l5b	cmo1y8uhm006jvxt088h99zp0	cmo1xc12i000ovxp01nisgvnu	40000	2026-04-16 20:46:12.104	2026-04-16 20:46:12.104
cmo1y8uj00071vxt02ip1lz0s	cmo1y8uhm006jvxt088h99zp0	cmo1xc13o000tvxp0alok8jeb	40000	2026-04-16 20:46:12.109	2026-04-16 20:46:12.109
cmo1y8uj60073vxt08j7vm7cg	cmo1y8uhm006jvxt088h99zp0	cmo1xc123000mvxp0ul7pkio2	40000	2026-04-16 20:46:12.114	2026-04-16 20:46:12.114
cmo1y8ujb0075vxt0w94qos22	cmo1y8uhm006jvxt088h99zp0	cmo1xc11n000kvxp0g32oj3wx	43000	2026-04-16 20:46:12.119	2026-04-16 20:46:12.119
cmo1y8ujg0077vxt0wj1xr9r1	cmo1y8uhm006jvxt088h99zp0	cmo1xc10u000hvxp0dapryn3r	40000	2026-04-16 20:46:12.125	2026-04-16 20:46:12.125
cmo1y8ujm0079vxt0lyn1efia	cmo1y8uhm006jvxt088h99zp0	cmo1xc119000jvxp01snwxzoa	40000	2026-04-16 20:46:12.13	2026-04-16 20:46:12.13
cmo1y8ujx007dvxt0id7ne1pa	cmo1y8ujr007bvxt0g5ais5q9	cmo1xsgrt0022vxv8sd7cckj7	6500	2026-04-16 20:46:12.141	2026-04-16 20:46:12.141
cmo1y8uk3007fvxt0lw2597jz	cmo1y8ujr007bvxt0g5ais5q9	cmo1xc11v000lvxp07r6uljko	6500	2026-04-16 20:46:12.147	2026-04-16 20:46:12.147
cmo1y8ukh007hvxt0qbnotn5h	cmo1y8ujr007bvxt0g5ais5q9	cmo1xc10u000hvxp0dapryn3r	6500	2026-04-16 20:46:12.162	2026-04-16 20:46:12.162
cmo1y8uku007lvxt0y66ry7ds	cmo1y8uko007jvxt0pk3yj90z	cmo1xsgrt0022vxv8sd7cckj7	400000	2026-04-16 20:46:12.174	2026-04-16 20:46:12.174
cmo1y8ul0007nvxt03srgg9ot	cmo1y8uko007jvxt0pk3yj90z	cmo1xc11v000lvxp07r6uljko	400000	2026-04-16 20:46:12.18	2026-04-16 20:46:12.18
cmo1y8ulg007pvxt0pcrbtczb	cmo1y8uko007jvxt0pk3yj90z	cmo1xc10u000hvxp0dapryn3r	400000	2026-04-16 20:46:12.196	2026-04-16 20:46:12.196
cmo1y8uls007tvxt0hxsrtoqa	cmo1y8uln007rvxt01gbjuya8	cmo1xsgrt0022vxv8sd7cckj7	15000	2026-04-16 20:46:12.209	2026-04-16 20:46:12.209
cmo1y8uly007vvxt0c1rjk8iq	cmo1y8uln007rvxt01gbjuya8	cmo1xc11v000lvxp07r6uljko	15000	2026-04-16 20:46:12.214	2026-04-16 20:46:12.214
cmo1y8umh007xvxt04y2g4qar	cmo1y8uln007rvxt01gbjuya8	cmo1xc10u000hvxp0dapryn3r	15000	2026-04-16 20:46:12.233	2026-04-16 20:46:12.233
cmo1y8umt0081vxt0pd911svt	cmo1y8umn007zvxt0r6es0wlg	cmo1xsgrt0022vxv8sd7cckj7	40000	2026-04-16 20:46:12.245	2026-04-16 20:46:12.245
cmo1y8umz0083vxt0e6iv4oc9	cmo1y8umn007zvxt0r6es0wlg	cmo1xc11v000lvxp07r6uljko	40000	2026-04-16 20:46:12.251	2026-04-16 20:46:12.251
cmo1y8un40085vxt0c7fruoc6	cmo1y8umn007zvxt0r6es0wlg	cmo1xc12y000qvxp0uqc7d8d8	40000	2026-04-16 20:46:12.256	2026-04-16 20:46:12.256
cmo1y8un90087vxt0g71yjn3l	cmo1y8umn007zvxt0r6es0wlg	cmo1xc13g000svxp0tbndc1wg	40000	2026-04-16 20:46:12.261	2026-04-16 20:46:12.261
cmo1y8unf0089vxt0fvqunejt	cmo1y8umn007zvxt0r6es0wlg	cmo1xc12a000nvxp0f1zf3aqg	40000	2026-04-16 20:46:12.267	2026-04-16 20:46:12.267
cmo1y8unk008bvxt0x1fxf7un	cmo1y8umn007zvxt0r6es0wlg	cmo1xc12q000pvxp0kun82k4l	40000	2026-04-16 20:46:12.272	2026-04-16 20:46:12.272
cmo1y8unp008dvxt0q9mu6are	cmo1y8umn007zvxt0r6es0wlg	cmo1xc138000rvxp0r16wi1bz	40000	2026-04-16 20:46:12.278	2026-04-16 20:46:12.278
cmo1y8unv008fvxt09hhl85fk	cmo1y8umn007zvxt0r6es0wlg	cmo1xc12i000ovxp01nisgvnu	40000	2026-04-16 20:46:12.284	2026-04-16 20:46:12.284
cmo1y8uo0008hvxt0fg3qyq44	cmo1y8umn007zvxt0r6es0wlg	cmo1xc13o000tvxp0alok8jeb	40000	2026-04-16 20:46:12.289	2026-04-16 20:46:12.289
cmo1y8uo5008jvxt0rpql9jrw	cmo1y8umn007zvxt0r6es0wlg	cmo1xc123000mvxp0ul7pkio2	40000	2026-04-16 20:46:12.294	2026-04-16 20:46:12.294
cmo1y8uob008lvxt0oexf65n5	cmo1y8umn007zvxt0r6es0wlg	cmo1xc11n000kvxp0g32oj3wx	43000	2026-04-16 20:46:12.299	2026-04-16 20:46:12.299
cmo1y8uog008nvxt0kpl5club	cmo1y8umn007zvxt0r6es0wlg	cmo1xc10u000hvxp0dapryn3r	40000	2026-04-16 20:46:12.305	2026-04-16 20:46:12.305
cmo1y8uom008pvxt04wlbn8kx	cmo1y8umn007zvxt0r6es0wlg	cmo1xc119000jvxp01snwxzoa	40000	2026-04-16 20:46:12.31	2026-04-16 20:46:12.31
cmo1y8usw009jvxt091mpvwch	cmo1y8usr009hvxt0o8nm88q7	cmo1xsgrt0022vxv8sd7cckj7	180000	2026-04-16 20:46:12.465	2026-04-16 20:46:12.465
cmo1y8ut2009lvxt0k7qxj2m5	cmo1y8usr009hvxt0o8nm88q7	cmo1xc11v000lvxp07r6uljko	180000	2026-04-16 20:46:12.471	2026-04-16 20:46:12.471
cmo1y8ut9009nvxt0t0dgc4bl	cmo1y8usr009hvxt0o8nm88q7	cmo1xc12y000qvxp0uqc7d8d8	180000	2026-04-16 20:46:12.477	2026-04-16 20:46:12.477
cmo1y8utf009pvxt09s3q897a	cmo1y8usr009hvxt0o8nm88q7	cmo1xc13g000svxp0tbndc1wg	180000	2026-04-16 20:46:12.484	2026-04-16 20:46:12.484
cmo1y8utm009rvxt0tekuhl8w	cmo1y8usr009hvxt0o8nm88q7	cmo1xc12q000pvxp0kun82k4l	180000	2026-04-16 20:46:12.491	2026-04-16 20:46:12.491
cmo1y8uts009tvxt0okyh4rpk	cmo1y8usr009hvxt0o8nm88q7	cmo1xc138000rvxp0r16wi1bz	180000	2026-04-16 20:46:12.496	2026-04-16 20:46:12.496
cmo1y8uty009vvxt07dm4c24a	cmo1y8usr009hvxt0o8nm88q7	cmo1xc12i000ovxp01nisgvnu	180000	2026-04-16 20:46:12.502	2026-04-16 20:46:12.502
cmo1y8uu3009xvxt0c0jru1nq	cmo1y8usr009hvxt0o8nm88q7	cmo1xc13o000tvxp0alok8jeb	180000	2026-04-16 20:46:12.508	2026-04-16 20:46:12.508
cmo1y8uub009zvxt0e6anhr0g	cmo1y8usr009hvxt0o8nm88q7	cmo1xc11n000kvxp0g32oj3wx	180000	2026-04-16 20:46:12.515	2026-04-16 20:46:12.515
cmo1y8uug00a1vxt0v7xctds8	cmo1y8usr009hvxt0o8nm88q7	cmo1xc10u000hvxp0dapryn3r	180000	2026-04-16 20:46:12.52	2026-04-16 20:46:12.52
cmo1y8uul00a3vxt04m8qv7ce	cmo1y8usr009hvxt0o8nm88q7	cmo1xc119000jvxp01snwxzoa	180000	2026-04-16 20:46:12.525	2026-04-16 20:46:12.525
cmo1y8uux00a7vxt00l6bx1n1	cmo1y8uur00a5vxt0m3zxo614	cmo1xsgrt0022vxv8sd7cckj7	160000	2026-04-16 20:46:12.537	2026-04-16 20:46:12.537
cmo1y8uv200a9vxt0cbfwcdc4	cmo1y8uur00a5vxt0m3zxo614	cmo1xc11v000lvxp07r6uljko	160000	2026-04-16 20:46:12.542	2026-04-16 20:46:12.542
cmo1y8uv800abvxt0lter4aaz	cmo1y8uur00a5vxt0m3zxo614	cmo1xc12y000qvxp0uqc7d8d8	160000	2026-04-16 20:46:12.548	2026-04-16 20:46:12.548
cmo1y8uvd00advxt0idp0zy2y	cmo1y8uur00a5vxt0m3zxo614	cmo1xc13g000svxp0tbndc1wg	160000	2026-04-16 20:46:12.554	2026-04-16 20:46:12.554
cmo1y8uvk00afvxt0bq23wqkh	cmo1y8uur00a5vxt0m3zxo614	cmo1xc12q000pvxp0kun82k4l	160000	2026-04-16 20:46:12.56	2026-04-16 20:46:12.56
cmo1y8uvp00ahvxt0mace5zi0	cmo1y8uur00a5vxt0m3zxo614	cmo1xc138000rvxp0r16wi1bz	160000	2026-04-16 20:46:12.566	2026-04-16 20:46:12.566
cmo1y8uvv00ajvxt0y66a6kyd	cmo1y8uur00a5vxt0m3zxo614	cmo1xc12i000ovxp01nisgvnu	160000	2026-04-16 20:46:12.571	2026-04-16 20:46:12.571
cmo1y8uw000alvxt08cge7f6v	cmo1y8uur00a5vxt0m3zxo614	cmo1xc13o000tvxp0alok8jeb	160000	2026-04-16 20:46:12.576	2026-04-16 20:46:12.576
cmo1y8uw700anvxt0r7dprkzq	cmo1y8uur00a5vxt0m3zxo614	cmo1xc11n000kvxp0g32oj3wx	160000	2026-04-16 20:46:12.583	2026-04-16 20:46:12.583
cmo1y8uwc00apvxt0hp0ixlmg	cmo1y8uur00a5vxt0m3zxo614	cmo1xc10u000hvxp0dapryn3r	160000	2026-04-16 20:46:12.588	2026-04-16 20:46:12.588
cmo1y8uwh00arvxt003w070i6	cmo1y8uur00a5vxt0m3zxo614	cmo1xc119000jvxp01snwxzoa	160000	2026-04-16 20:46:12.594	2026-04-16 20:46:12.594
cmo1y8uxb00axvxt0jqsoq63y	cmo1y8ux600avvxt0bgf641ib	cmo1xsgrt0022vxv8sd7cckj7	70000	2026-04-16 20:46:12.624	2026-04-16 20:46:12.624
cmo1y8uxg00azvxt0y86whk80	cmo1y8ux600avvxt0bgf641ib	cmo1xc11v000lvxp07r6uljko	70000	2026-04-16 20:46:12.629	2026-04-16 20:46:12.629
cmo1y8uxm00b1vxt07rszxej4	cmo1y8ux600avvxt0bgf641ib	cmo1xc12y000qvxp0uqc7d8d8	70000	2026-04-16 20:46:12.635	2026-04-16 20:46:12.635
cmo1y8uxs00b3vxt0rub3digr	cmo1y8ux600avvxt0bgf641ib	cmo1xc13g000svxp0tbndc1wg	70000	2026-04-16 20:46:12.64	2026-04-16 20:46:12.64
cmo1y8uxz00b5vxt02i8erwna	cmo1y8ux600avvxt0bgf641ib	cmo1xc12q000pvxp0kun82k4l	70000	2026-04-16 20:46:12.647	2026-04-16 20:46:12.647
cmo1y8uy500b7vxt0ni8ytqst	cmo1y8ux600avvxt0bgf641ib	cmo1xc138000rvxp0r16wi1bz	70000	2026-04-16 20:46:12.653	2026-04-16 20:46:12.653
cmo1y8uya00b9vxt0w4xsxa19	cmo1y8ux600avvxt0bgf641ib	cmo1xc12i000ovxp01nisgvnu	70000	2026-04-16 20:46:12.659	2026-04-16 20:46:12.659
cmo1y8uyg00bbvxt0x54hpgjp	cmo1y8ux600avvxt0bgf641ib	cmo1xc13o000tvxp0alok8jeb	70000	2026-04-16 20:46:12.664	2026-04-16 20:46:12.664
cmo1y8uym00bdvxt09fy8ouc9	cmo1y8ux600avvxt0bgf641ib	cmo1xc11n000kvxp0g32oj3wx	70000	2026-04-16 20:46:12.671	2026-04-16 20:46:12.671
cmo1y8uyr00bfvxt0p1wafvta	cmo1y8ux600avvxt0bgf641ib	cmo1xc10u000hvxp0dapryn3r	70000	2026-04-16 20:46:12.676	2026-04-16 20:46:12.676
cmo1y8uyx00bhvxt06kib5ws6	cmo1y8ux600avvxt0bgf641ib	cmo1xc119000jvxp01snwxzoa	70000	2026-04-16 20:46:12.682	2026-04-16 20:46:12.682
cmo1y8uz900blvxt0q0r26ux3	cmo1y8uz300bjvxt0konvez9s	cmo1xsgrt0022vxv8sd7cckj7	55000	2026-04-16 20:46:12.693	2026-04-16 20:46:12.693
cmo1y8uze00bnvxt01fug4m0r	cmo1y8uz300bjvxt0konvez9s	cmo1xc11v000lvxp07r6uljko	55000	2026-04-16 20:46:12.699	2026-04-16 20:46:12.699
cmo1y8uzk00bpvxt0vsbbx2it	cmo1y8uz300bjvxt0konvez9s	cmo1xc12y000qvxp0uqc7d8d8	55000	2026-04-16 20:46:12.705	2026-04-16 20:46:12.705
cmo1y8uzq00brvxt0e8ltg9q7	cmo1y8uz300bjvxt0konvez9s	cmo1xc13g000svxp0tbndc1wg	55000	2026-04-16 20:46:12.71	2026-04-16 20:46:12.71
cmo1y8uzw00btvxt0vh33tkrs	cmo1y8uz300bjvxt0konvez9s	cmo1xc12a000nvxp0f1zf3aqg	55000	2026-04-16 20:46:12.716	2026-04-16 20:46:12.716
cmo1y8v0200bvvxt0zasvhqil	cmo1y8uz300bjvxt0konvez9s	cmo1xc12q000pvxp0kun82k4l	55000	2026-04-16 20:46:12.722	2026-04-16 20:46:12.722
cmo1y8v0900bxvxt0z8jqrk1k	cmo1y8uz300bjvxt0konvez9s	cmo1xc138000rvxp0r16wi1bz	55000	2026-04-16 20:46:12.729	2026-04-16 20:46:12.729
cmo1y8v0f00bzvxt0sl9vymc0	cmo1y8uz300bjvxt0konvez9s	cmo1xc12i000ovxp01nisgvnu	55000	2026-04-16 20:46:12.735	2026-04-16 20:46:12.735
cmo1y8v0k00c1vxt0jlzxblst	cmo1y8uz300bjvxt0konvez9s	cmo1xc13o000tvxp0alok8jeb	55000	2026-04-16 20:46:12.741	2026-04-16 20:46:12.741
cmo1y8v0q00c3vxt0jhhfpc5e	cmo1y8uz300bjvxt0konvez9s	cmo1xc123000mvxp0ul7pkio2	55000	2026-04-16 20:46:12.746	2026-04-16 20:46:12.746
cmo1y8v0w00c5vxt023ekga72	cmo1y8uz300bjvxt0konvez9s	cmo1xc11n000kvxp0g32oj3wx	55000	2026-04-16 20:46:12.752	2026-04-16 20:46:12.752
cmo1y8v1100c7vxt0an5qm2f8	cmo1y8uz300bjvxt0konvez9s	cmo1xc10u000hvxp0dapryn3r	55000	2026-04-16 20:46:12.757	2026-04-16 20:46:12.757
cmo1y8v1600c9vxt0bjlejenh	cmo1y8uz300bjvxt0konvez9s	cmo1xc119000jvxp01snwxzoa	55000	2026-04-16 20:46:12.763	2026-04-16 20:46:12.763
cmo1y8v1i00cdvxt0m0il1l51	cmo1y8v1c00cbvxt0nc3hpngc	cmo1xsgrt0022vxv8sd7cckj7	45000	2026-04-16 20:46:12.775	2026-04-16 20:46:12.775
cmo1y8v1o00cfvxt0v6ezc871	cmo1y8v1c00cbvxt0nc3hpngc	cmo1xc11v000lvxp07r6uljko	45000	2026-04-16 20:46:12.78	2026-04-16 20:46:12.78
cmo1y8v1t00chvxt0tl10duux	cmo1y8v1c00cbvxt0nc3hpngc	cmo1xc12y000qvxp0uqc7d8d8	45000	2026-04-16 20:46:12.786	2026-04-16 20:46:12.786
cmo1y8v1z00cjvxt0185jk777	cmo1y8v1c00cbvxt0nc3hpngc	cmo1xc13g000svxp0tbndc1wg	45000	2026-04-16 20:46:12.791	2026-04-16 20:46:12.791
cmo1y8v2400clvxt04u0ydggg	cmo1y8v1c00cbvxt0nc3hpngc	cmo1xc12a000nvxp0f1zf3aqg	45000	2026-04-16 20:46:12.796	2026-04-16 20:46:12.796
cmo1y8v2a00cnvxt00p7lgb0i	cmo1y8v1c00cbvxt0nc3hpngc	cmo1xc12q000pvxp0kun82k4l	45000	2026-04-16 20:46:12.802	2026-04-16 20:46:12.802
cmo1y8v2f00cpvxt0rhlegsvp	cmo1y8v1c00cbvxt0nc3hpngc	cmo1xc138000rvxp0r16wi1bz	45000	2026-04-16 20:46:12.807	2026-04-16 20:46:12.807
cmo1y8v2k00crvxt0or36mc69	cmo1y8v1c00cbvxt0nc3hpngc	cmo1xc12i000ovxp01nisgvnu	45000	2026-04-16 20:46:12.812	2026-04-16 20:46:12.812
cmo1y8v2p00ctvxt0fk331xvf	cmo1y8v1c00cbvxt0nc3hpngc	cmo1xc13o000tvxp0alok8jeb	45000	2026-04-16 20:46:12.818	2026-04-16 20:46:12.818
cmo1y8v2u00cvvxt0xc3kgava	cmo1y8v1c00cbvxt0nc3hpngc	cmo1xc123000mvxp0ul7pkio2	45000	2026-04-16 20:46:12.823	2026-04-16 20:46:12.823
cmo1y8v3000cxvxt0soxbpxpn	cmo1y8v1c00cbvxt0nc3hpngc	cmo1xc11n000kvxp0g32oj3wx	45000	2026-04-16 20:46:12.828	2026-04-16 20:46:12.828
cmo1y8v3600czvxt0th0vkjcj	cmo1y8v1c00cbvxt0nc3hpngc	cmo1xc10u000hvxp0dapryn3r	45000	2026-04-16 20:46:12.834	2026-04-16 20:46:12.834
cmo1y8v3b00d1vxt0aai6iw4v	cmo1y8v1c00cbvxt0nc3hpngc	cmo1xc119000jvxp01snwxzoa	45000	2026-04-16 20:46:12.839	2026-04-16 20:46:12.839
cmo1y8v3m00d5vxt0ld57bsx0	cmo1y8v3g00d3vxt09h6p2g5u	cmo1xsgrt0022vxv8sd7cckj7	65000	2026-04-16 20:46:12.85	2026-04-16 20:46:12.85
cmo1y8v3r00d7vxt0qqgn32dt	cmo1y8v3g00d3vxt09h6p2g5u	cmo1xc11v000lvxp07r6uljko	65000	2026-04-16 20:46:12.856	2026-04-16 20:46:12.856
cmo1y8v3x00d9vxt045oeb5rm	cmo1y8v3g00d3vxt09h6p2g5u	cmo1xc12y000qvxp0uqc7d8d8	65000	2026-04-16 20:46:12.861	2026-04-16 20:46:12.861
cmo1y8v4200dbvxt0o4u2ivvf	cmo1y8v3g00d3vxt09h6p2g5u	cmo1xc13g000svxp0tbndc1wg	65000	2026-04-16 20:46:12.866	2026-04-16 20:46:12.866
cmo1y8v4700ddvxt0gp3x5esu	cmo1y8v3g00d3vxt09h6p2g5u	cmo1xc12a000nvxp0f1zf3aqg	65000	2026-04-16 20:46:12.872	2026-04-16 20:46:12.872
cmo1y8v4c00dfvxt0swxzv9sv	cmo1y8v3g00d3vxt09h6p2g5u	cmo1xc12q000pvxp0kun82k4l	65000	2026-04-16 20:46:12.877	2026-04-16 20:46:12.877
cmo1y8v4i00dhvxt0q068cfqu	cmo1y8v3g00d3vxt09h6p2g5u	cmo1xc138000rvxp0r16wi1bz	65000	2026-04-16 20:46:12.882	2026-04-16 20:46:12.882
cmo1y8v4o00djvxt0wer3xtnc	cmo1y8v3g00d3vxt09h6p2g5u	cmo1xc12i000ovxp01nisgvnu	65000	2026-04-16 20:46:12.888	2026-04-16 20:46:12.888
cmo1y8v4u00dlvxt0xa73hr5i	cmo1y8v3g00d3vxt09h6p2g5u	cmo1xc13o000tvxp0alok8jeb	65000	2026-04-16 20:46:12.894	2026-04-16 20:46:12.894
cmo1y8v5000dnvxt08afoghc4	cmo1y8v3g00d3vxt09h6p2g5u	cmo1xc123000mvxp0ul7pkio2	65000	2026-04-16 20:46:12.9	2026-04-16 20:46:12.9
cmo1y8v5500dpvxt07f3ewa5x	cmo1y8v3g00d3vxt09h6p2g5u	cmo1xc11n000kvxp0g32oj3wx	65000	2026-04-16 20:46:12.905	2026-04-16 20:46:12.905
cmo1y8v5a00drvxt0ydg8t0k1	cmo1y8v3g00d3vxt09h6p2g5u	cmo1xc10u000hvxp0dapryn3r	65000	2026-04-16 20:46:12.911	2026-04-16 20:46:12.911
cmo1y8v5f00dtvxt0dn5lp30r	cmo1y8v3g00d3vxt09h6p2g5u	cmo1xc119000jvxp01snwxzoa	65000	2026-04-16 20:46:12.916	2026-04-16 20:46:12.916
cmo1y8v5r00dxvxt0d4qplfpf	cmo1y8v5l00dvvxt0mjjs0s68	cmo1xsgrt0022vxv8sd7cckj7	8000	2026-04-16 20:46:12.927	2026-04-16 20:46:12.927
cmo1y8v5x00dzvxt0q8erjy9e	cmo1y8v5l00dvvxt0mjjs0s68	cmo1xc11v000lvxp07r6uljko	8000	2026-04-16 20:46:12.933	2026-04-16 20:46:12.933
cmo1y8v6b00e1vxt09cygoih6	cmo1y8v5l00dvvxt0mjjs0s68	cmo1xc10u000hvxp0dapryn3r	8000	2026-04-16 20:46:12.947	2026-04-16 20:46:12.947
cmo1y8v6m00e5vxt0vsxvdk60	cmo1y8v6h00e3vxt03shcm5hh	cmo1xsgrt0022vxv8sd7cckj7	12000	2026-04-16 20:46:12.959	2026-04-16 20:46:12.959
cmo1y8v6s00e7vxt0k3natfsf	cmo1y8v6h00e3vxt03shcm5hh	cmo1xc11v000lvxp07r6uljko	12000	2026-04-16 20:46:12.964	2026-04-16 20:46:12.964
cmo1y8v7700e9vxt08b8t25p1	cmo1y8v6h00e3vxt03shcm5hh	cmo1xc10u000hvxp0dapryn3r	12000	2026-04-16 20:46:12.979	2026-04-16 20:46:12.979
cmo1y8v7m00edvxt0eafoolgk	cmo1y8v7f00ebvxt0lsy6dkr7	cmo1xsgrt0022vxv8sd7cckj7	49000	2026-04-16 20:46:12.995	2026-04-16 20:46:12.995
cmo1y8v7t00efvxt0xnu8cmol	cmo1y8v7f00ebvxt0lsy6dkr7	cmo1xc11v000lvxp07r6uljko	49000	2026-04-16 20:46:13.001	2026-04-16 20:46:13.001
cmo1y8v8500ehvxt0qrf3u0nt	cmo1y8v7f00ebvxt0lsy6dkr7	cmo1xc13o000tvxp0alok8jeb	49000	2026-04-16 20:46:13.013	2026-04-16 20:46:13.013
cmo1y8v8c00ejvxt04jbjdwnd	cmo1y8v7f00ebvxt0lsy6dkr7	cmo1xc10u000hvxp0dapryn3r	49000	2026-04-16 20:46:13.021	2026-04-16 20:46:13.021
cmo1y8v8p00envxt0xaq0mfpm	cmo1y8v8j00elvxt0wzt8g1wq	cmo1xsgrt0022vxv8sd7cckj7	37000	2026-04-16 20:46:13.033	2026-04-16 20:46:13.033
cmo1y8v8u00epvxt08yh0560q	cmo1y8v8j00elvxt0wzt8g1wq	cmo1xc11v000lvxp07r6uljko	37000	2026-04-16 20:46:13.039	2026-04-16 20:46:13.039
cmo1y8v9a00ervxt0nlklmr0n	cmo1y8v8j00elvxt0wzt8g1wq	cmo1xc10u000hvxp0dapryn3r	37000	2026-04-16 20:46:13.054	2026-04-16 20:46:13.054
cmo1y8v9y00evvxt039j149c7	cmo1y8v9l00etvxt0h6qk5by0	cmo1xsgrt0022vxv8sd7cckj7	15000	2026-04-16 20:46:13.079	2026-04-16 20:46:13.079
cmo1y8va400exvxt0cydsa4v1	cmo1y8v9l00etvxt0h6qk5by0	cmo1xc11v000lvxp07r6uljko	15000	2026-04-16 20:46:13.085	2026-04-16 20:46:13.085
cmo1y8vak00ezvxt0i85tvyx9	cmo1y8v9l00etvxt0h6qk5by0	cmo1xc10u000hvxp0dapryn3r	15000	2026-04-16 20:46:13.101	2026-04-16 20:46:13.101
cmo1y8vaw00f3vxt0kq4rxx78	cmo1y8vaq00f1vxt0uuecxd2x	cmo1xsgrt0022vxv8sd7cckj7	40000	2026-04-16 20:46:13.112	2026-04-16 20:46:13.112
cmo1y8vb200f5vxt001pjp6gg	cmo1y8vaq00f1vxt0uuecxd2x	cmo1xc11v000lvxp07r6uljko	40000	2026-04-16 20:46:13.118	2026-04-16 20:46:13.118
cmo1y8vb700f7vxt0mlgdumks	cmo1y8vaq00f1vxt0uuecxd2x	cmo1xc12y000qvxp0uqc7d8d8	40000	2026-04-16 20:46:13.123	2026-04-16 20:46:13.123
cmo1y8vbc00f9vxt0q2cynxx5	cmo1y8vaq00f1vxt0uuecxd2x	cmo1xc13g000svxp0tbndc1wg	40000	2026-04-16 20:46:13.128	2026-04-16 20:46:13.128
cmo1y8vbj00fbvxt0vrstq221	cmo1y8vaq00f1vxt0uuecxd2x	cmo1xc12q000pvxp0kun82k4l	40000	2026-04-16 20:46:13.136	2026-04-16 20:46:13.136
cmo1y8vbo00fdvxt08wnd3lo7	cmo1y8vaq00f1vxt0uuecxd2x	cmo1xc138000rvxp0r16wi1bz	40000	2026-04-16 20:46:13.141	2026-04-16 20:46:13.141
cmo1y8vbu00ffvxt0pgctt2z4	cmo1y8vaq00f1vxt0uuecxd2x	cmo1xc12i000ovxp01nisgvnu	40000	2026-04-16 20:46:13.146	2026-04-16 20:46:13.146
cmo1y8vc000fhvxt0zb6mwbj3	cmo1y8vaq00f1vxt0uuecxd2x	cmo1xc13o000tvxp0alok8jeb	40000	2026-04-16 20:46:13.152	2026-04-16 20:46:13.152
cmo1y8vc600fjvxt0s9n9qs6o	cmo1y8vaq00f1vxt0uuecxd2x	cmo1xc11n000kvxp0g32oj3wx	40000	2026-04-16 20:46:13.159	2026-04-16 20:46:13.159
cmo1y8vcd00flvxt0dkplvmut	cmo1y8vaq00f1vxt0uuecxd2x	cmo1xc10u000hvxp0dapryn3r	40000	2026-04-16 20:46:13.165	2026-04-16 20:46:13.165
cmo1y8vci00fnvxt0etgn2f83	cmo1y8vaq00f1vxt0uuecxd2x	cmo1xc119000jvxp01snwxzoa	40000	2026-04-16 20:46:13.17	2026-04-16 20:46:13.17
cmo1y8vct00frvxt0d2zipiah	cmo1y8vcn00fpvxt0w44nr1n6	cmo1xsgrt0022vxv8sd7cckj7	38000	2026-04-16 20:46:13.181	2026-04-16 20:46:13.181
cmo1y8vcy00ftvxt0bl1fho5k	cmo1y8vcn00fpvxt0w44nr1n6	cmo1xc11v000lvxp07r6uljko	38000	2026-04-16 20:46:13.187	2026-04-16 20:46:13.187
cmo1y8vd300fvvxt09bynrb6z	cmo1y8vcn00fpvxt0w44nr1n6	cmo1xc12y000qvxp0uqc7d8d8	38000	2026-04-16 20:46:13.192	2026-04-16 20:46:13.192
cmo1y8vd900fxvxt050503xj1	cmo1y8vcn00fpvxt0w44nr1n6	cmo1xc13g000svxp0tbndc1wg	38000	2026-04-16 20:46:13.197	2026-04-16 20:46:13.197
cmo1y8vdf00fzvxt06obz3814	cmo1y8vcn00fpvxt0w44nr1n6	cmo1xc12q000pvxp0kun82k4l	38000	2026-04-16 20:46:13.204	2026-04-16 20:46:13.204
cmo1y8vdl00g1vxt0t9ezlw5y	cmo1y8vcn00fpvxt0w44nr1n6	cmo1xc138000rvxp0r16wi1bz	38000	2026-04-16 20:46:13.209	2026-04-16 20:46:13.209
cmo1y8vdq00g3vxt0ottgcwcx	cmo1y8vcn00fpvxt0w44nr1n6	cmo1xc12i000ovxp01nisgvnu	38000	2026-04-16 20:46:13.215	2026-04-16 20:46:13.215
cmo1y8vdv00g5vxt0nm35hnbt	cmo1y8vcn00fpvxt0w44nr1n6	cmo1xc13o000tvxp0alok8jeb	38000	2026-04-16 20:46:13.22	2026-04-16 20:46:13.22
cmo1y8ve100g7vxt0v1iyg432	cmo1y8vcn00fpvxt0w44nr1n6	cmo1xc11n000kvxp0g32oj3wx	38000	2026-04-16 20:46:13.226	2026-04-16 20:46:13.226
cmo1y8ve800g9vxt00wyl2ezb	cmo1y8vcn00fpvxt0w44nr1n6	cmo1xc10u000hvxp0dapryn3r	38000	2026-04-16 20:46:13.232	2026-04-16 20:46:13.232
cmo1y8vef00gbvxt0zyvzzg1g	cmo1y8vcn00fpvxt0w44nr1n6	cmo1xc119000jvxp01snwxzoa	38000	2026-04-16 20:46:13.239	2026-04-16 20:46:13.239
cmo1y8ves00gfvxt0rs49yetp	cmo1y8vel00gdvxt0un7jf1zq	cmo1xsgrt0022vxv8sd7cckj7	32000	2026-04-16 20:46:13.252	2026-04-16 20:46:13.252
cmo1y8vex00ghvxt0hb2ikznt	cmo1y8vel00gdvxt0un7jf1zq	cmo1xc11v000lvxp07r6uljko	32000	2026-04-16 20:46:13.258	2026-04-16 20:46:13.258
cmo1y8vf400gjvxt0y9i1uvze	cmo1y8vel00gdvxt0un7jf1zq	cmo1xc12y000qvxp0uqc7d8d8	32000	2026-04-16 20:46:13.264	2026-04-16 20:46:13.264
cmo1y8vf900glvxt03qmdnhim	cmo1y8vel00gdvxt0un7jf1zq	cmo1xc13g000svxp0tbndc1wg	32000	2026-04-16 20:46:13.27	2026-04-16 20:46:13.27
cmo1y8vfg00gnvxt0jev4ulwu	cmo1y8vel00gdvxt0un7jf1zq	cmo1xc12q000pvxp0kun82k4l	32000	2026-04-16 20:46:13.276	2026-04-16 20:46:13.276
cmo1y8vfl00gpvxt003s232v8	cmo1y8vel00gdvxt0un7jf1zq	cmo1xc138000rvxp0r16wi1bz	32000	2026-04-16 20:46:13.282	2026-04-16 20:46:13.282
cmo1y8vfr00grvxt0pjfo2yx8	cmo1y8vel00gdvxt0un7jf1zq	cmo1xc12i000ovxp01nisgvnu	32000	2026-04-16 20:46:13.287	2026-04-16 20:46:13.287
cmo1y8vfw00gtvxt08z2b77op	cmo1y8vel00gdvxt0un7jf1zq	cmo1xc13o000tvxp0alok8jeb	32000	2026-04-16 20:46:13.293	2026-04-16 20:46:13.293
cmo1y8vg300gvvxt0lyutxoq5	cmo1y8vel00gdvxt0un7jf1zq	cmo1xc11n000kvxp0g32oj3wx	32000	2026-04-16 20:46:13.299	2026-04-16 20:46:13.299
cmo1y8vg900gxvxt0danpl0gs	cmo1y8vel00gdvxt0un7jf1zq	cmo1xc10u000hvxp0dapryn3r	32000	2026-04-16 20:46:13.305	2026-04-16 20:46:13.305
cmo1y8vge00gzvxt0ihnckuev	cmo1y8vel00gdvxt0un7jf1zq	cmo1xc119000jvxp01snwxzoa	32000	2026-04-16 20:46:13.311	2026-04-16 20:46:13.311
cmo1y8vgp00h3vxt0u23omkcm	cmo1y8vgk00h1vxt0a3cbpkhp	cmo1xsgrt0022vxv8sd7cckj7	13000	2026-04-16 20:46:13.322	2026-04-16 20:46:13.322
cmo1y8vgu00h5vxt0b0krgdr2	cmo1y8vgk00h1vxt0a3cbpkhp	cmo1xc11v000lvxp07r6uljko	13000	2026-04-16 20:46:13.326	2026-04-16 20:46:13.326
cmo1y8vh000h7vxt0vkr804km	cmo1y8vgk00h1vxt0a3cbpkhp	cmo1xc12y000qvxp0uqc7d8d8	13000	2026-04-16 20:46:13.332	2026-04-16 20:46:13.332
cmo1y8vh500h9vxt0q99d1zfu	cmo1y8vgk00h1vxt0a3cbpkhp	cmo1xc13g000svxp0tbndc1wg	13000	2026-04-16 20:46:13.338	2026-04-16 20:46:13.338
cmo1y8vhb00hbvxt026snu9x7	cmo1y8vgk00h1vxt0a3cbpkhp	cmo1xc12q000pvxp0kun82k4l	13000	2026-04-16 20:46:13.343	2026-04-16 20:46:13.343
cmo1y8vhg00hdvxt0a6p1kr10	cmo1y8vgk00h1vxt0a3cbpkhp	cmo1xc138000rvxp0r16wi1bz	13000	2026-04-16 20:46:13.349	2026-04-16 20:46:13.349
cmo1y8vhl00hfvxt0d6g328eo	cmo1y8vgk00h1vxt0a3cbpkhp	cmo1xc12i000ovxp01nisgvnu	13000	2026-04-16 20:46:13.354	2026-04-16 20:46:13.354
cmo1y8vhq00hhvxt0uxitvzqr	cmo1y8vgk00h1vxt0a3cbpkhp	cmo1xc13o000tvxp0alok8jeb	13000	2026-04-16 20:46:13.359	2026-04-16 20:46:13.359
cmo1y8vhx00hjvxt0z57y7hyh	cmo1y8vgk00h1vxt0a3cbpkhp	cmo1xc11n000kvxp0g32oj3wx	13000	2026-04-16 20:46:13.365	2026-04-16 20:46:13.365
cmo1y8vi200hlvxt0kv7vbk4f	cmo1y8vgk00h1vxt0a3cbpkhp	cmo1xc10u000hvxp0dapryn3r	13000	2026-04-16 20:46:13.371	2026-04-16 20:46:13.371
cmo1y8vi700hnvxt05qs5q0yu	cmo1y8vgk00h1vxt0a3cbpkhp	cmo1xc119000jvxp01snwxzoa	13000	2026-04-16 20:46:13.376	2026-04-16 20:46:13.376
cmo1y8vik00hrvxt0z0pm5hqz	cmo1y8vid00hpvxt086szwghf	cmo1xsgrt0022vxv8sd7cckj7	155000	2026-04-16 20:46:13.388	2026-04-16 20:46:13.388
cmo1y8viq00htvxt0nisjdd8t	cmo1y8vid00hpvxt086szwghf	cmo1xc11v000lvxp07r6uljko	155000	2026-04-16 20:46:13.394	2026-04-16 20:46:13.394
cmo1y8viw00hvvxt0t3e27kdg	cmo1y8vid00hpvxt086szwghf	cmo1xc12y000qvxp0uqc7d8d8	155000	2026-04-16 20:46:13.4	2026-04-16 20:46:13.4
cmo1y8vj100hxvxt0v0rxixf2	cmo1y8vid00hpvxt086szwghf	cmo1xc13g000svxp0tbndc1wg	155000	2026-04-16 20:46:13.405	2026-04-16 20:46:13.405
cmo1y8vj800hzvxt0uxgpl2qo	cmo1y8vid00hpvxt086szwghf	cmo1xc12q000pvxp0kun82k4l	155000	2026-04-16 20:46:13.412	2026-04-16 20:46:13.412
cmo1y8vje00i1vxt0u67z6qoo	cmo1y8vid00hpvxt086szwghf	cmo1xc138000rvxp0r16wi1bz	155000	2026-04-16 20:46:13.418	2026-04-16 20:46:13.418
cmo1y8vjj00i3vxt0gwqb55ob	cmo1y8vid00hpvxt086szwghf	cmo1xc12i000ovxp01nisgvnu	155000	2026-04-16 20:46:13.423	2026-04-16 20:46:13.423
cmo1y8vjo00i5vxt0jvi9uboi	cmo1y8vid00hpvxt086szwghf	cmo1xc13o000tvxp0alok8jeb	155000	2026-04-16 20:46:13.428	2026-04-16 20:46:13.428
cmo1y8vjv00i7vxt02mn0lkwj	cmo1y8vid00hpvxt086szwghf	cmo1xc11n000kvxp0g32oj3wx	155000	2026-04-16 20:46:13.435	2026-04-16 20:46:13.435
cmo1y8vk000i9vxt0xb17vl1d	cmo1y8vid00hpvxt086szwghf	cmo1xc10u000hvxp0dapryn3r	155000	2026-04-16 20:46:13.44	2026-04-16 20:46:13.44
cmo1y8vk500ibvxt0hi90jcqw	cmo1y8vid00hpvxt086szwghf	cmo1xc119000jvxp01snwxzoa	155000	2026-04-16 20:46:13.445	2026-04-16 20:46:13.445
cmo1y8vkg00ifvxt0nqt7sv8b	cmo1y8vkb00idvxt0f9ycjm2s	cmo1xsgrt0022vxv8sd7cckj7	195000	2026-04-16 20:46:13.457	2026-04-16 20:46:13.457
cmo1y8vkl00ihvxt0ch1vga8j	cmo1y8vkb00idvxt0f9ycjm2s	cmo1xc11v000lvxp07r6uljko	195000	2026-04-16 20:46:13.462	2026-04-16 20:46:13.462
cmo1y8vkr00ijvxt0sd41yqon	cmo1y8vkb00idvxt0f9ycjm2s	cmo1xc12y000qvxp0uqc7d8d8	195000	2026-04-16 20:46:13.468	2026-04-16 20:46:13.468
cmo1y8vkw00ilvxt0w6w5ut1y	cmo1y8vkb00idvxt0f9ycjm2s	cmo1xc13g000svxp0tbndc1wg	195000	2026-04-16 20:46:13.473	2026-04-16 20:46:13.473
cmo1y8vl900invxt0gfgjepds	cmo1y8vkb00idvxt0f9ycjm2s	cmo1xc12q000pvxp0kun82k4l	195000	2026-04-16 20:46:13.485	2026-04-16 20:46:13.485
cmo1y8vlf00ipvxt0mj4g48vb	cmo1y8vkb00idvxt0f9ycjm2s	cmo1xc138000rvxp0r16wi1bz	195000	2026-04-16 20:46:13.491	2026-04-16 20:46:13.491
cmo1y8vll00irvxt04d6m0rpi	cmo1y8vkb00idvxt0f9ycjm2s	cmo1xc12i000ovxp01nisgvnu	195000	2026-04-16 20:46:13.498	2026-04-16 20:46:13.498
cmo1y8vlr00itvxt0tltg7foh	cmo1y8vkb00idvxt0f9ycjm2s	cmo1xc13o000tvxp0alok8jeb	195000	2026-04-16 20:46:13.503	2026-04-16 20:46:13.503
cmo1y8vlx00ivvxt0v55t1yyg	cmo1y8vkb00idvxt0f9ycjm2s	cmo1xc11n000kvxp0g32oj3wx	195000	2026-04-16 20:46:13.509	2026-04-16 20:46:13.509
cmo1y8vm200ixvxt07x8gtsgy	cmo1y8vkb00idvxt0f9ycjm2s	cmo1xc10u000hvxp0dapryn3r	195000	2026-04-16 20:46:13.515	2026-04-16 20:46:13.515
cmo1y8vm800izvxt0jmuwww98	cmo1y8vkb00idvxt0f9ycjm2s	cmo1xc119000jvxp01snwxzoa	195000	2026-04-16 20:46:13.52	2026-04-16 20:46:13.52
cmo1y8vmj00j3vxt0ehkt4din	cmo1y8vme00j1vxt05m7koqjf	cmo1xsgrt0022vxv8sd7cckj7	58000	2026-04-16 20:46:13.532	2026-04-16 20:46:13.532
cmo1y8vmp00j5vxt0cfsyk3zl	cmo1y8vme00j1vxt05m7koqjf	cmo1xc11v000lvxp07r6uljko	58000	2026-04-16 20:46:13.537	2026-04-16 20:46:13.537
cmo1y8vmu00j7vxt0ubnbu876	cmo1y8vme00j1vxt05m7koqjf	cmo1xc12y000qvxp0uqc7d8d8	58000	2026-04-16 20:46:13.543	2026-04-16 20:46:13.543
cmo1y8vn000j9vxt00a9jvb2z	cmo1y8vme00j1vxt05m7koqjf	cmo1xc13g000svxp0tbndc1wg	58000	2026-04-16 20:46:13.548	2026-04-16 20:46:13.548
cmo1y8vn700jbvxt0ecx6ihxv	cmo1y8vme00j1vxt05m7koqjf	cmo1xc12q000pvxp0kun82k4l	58000	2026-04-16 20:46:13.555	2026-04-16 20:46:13.555
cmo1y8vnc00jdvxt0eegq81s3	cmo1y8vme00j1vxt05m7koqjf	cmo1xc138000rvxp0r16wi1bz	58000	2026-04-16 20:46:13.561	2026-04-16 20:46:13.561
cmo1y8vni00jfvxt0ov18p0a4	cmo1y8vme00j1vxt05m7koqjf	cmo1xc12i000ovxp01nisgvnu	58000	2026-04-16 20:46:13.566	2026-04-16 20:46:13.566
cmo1y8vno00jhvxt0nb87jhe4	cmo1y8vme00j1vxt05m7koqjf	cmo1xc13o000tvxp0alok8jeb	58000	2026-04-16 20:46:13.572	2026-04-16 20:46:13.572
cmo1y8vnu00jjvxt06ffudidh	cmo1y8vme00j1vxt05m7koqjf	cmo1xc11n000kvxp0g32oj3wx	58000	2026-04-16 20:46:13.579	2026-04-16 20:46:13.579
cmo1y8vo000jlvxt00qmvt73f	cmo1y8vme00j1vxt05m7koqjf	cmo1xc10u000hvxp0dapryn3r	58000	2026-04-16 20:46:13.584	2026-04-16 20:46:13.584
cmo1y8vo600jnvxt0rabsjvvo	cmo1y8vme00j1vxt05m7koqjf	cmo1xc119000jvxp01snwxzoa	58000	2026-04-16 20:46:13.59	2026-04-16 20:46:13.59
cmo1y8voh00jrvxt0igsjmwmw	cmo1y8vob00jpvxt0hi10fdjg	cmo1xsgrt0022vxv8sd7cckj7	19000	2026-04-16 20:46:13.602	2026-04-16 20:46:13.602
cmo1y8vom00jtvxt03h1gwtmb	cmo1y8vob00jpvxt0hi10fdjg	cmo1xc11v000lvxp07r6uljko	19000	2026-04-16 20:46:13.607	2026-04-16 20:46:13.607
cmo1y8vos00jvvxt0jwm9nlv9	cmo1y8vob00jpvxt0hi10fdjg	cmo1xc12y000qvxp0uqc7d8d8	19000	2026-04-16 20:46:13.612	2026-04-16 20:46:13.612
cmo1y8vox00jxvxt0ypxc848k	cmo1y8vob00jpvxt0hi10fdjg	cmo1xc13g000svxp0tbndc1wg	19000	2026-04-16 20:46:13.618	2026-04-16 20:46:13.618
cmo1y8vp300jzvxt0rjp9jeb6	cmo1y8vob00jpvxt0hi10fdjg	cmo1xc12q000pvxp0kun82k4l	19000	2026-04-16 20:46:13.624	2026-04-16 20:46:13.624
cmo1y8vp900k1vxt00jesf1gg	cmo1y8vob00jpvxt0hi10fdjg	cmo1xc138000rvxp0r16wi1bz	19000	2026-04-16 20:46:13.629	2026-04-16 20:46:13.629
cmo1y8vpf00k3vxt0ea5n3iyx	cmo1y8vob00jpvxt0hi10fdjg	cmo1xc12i000ovxp01nisgvnu	19000	2026-04-16 20:46:13.635	2026-04-16 20:46:13.635
cmo1y8vpk00k5vxt0cpph47wq	cmo1y8vob00jpvxt0hi10fdjg	cmo1xc13o000tvxp0alok8jeb	19000	2026-04-16 20:46:13.641	2026-04-16 20:46:13.641
cmo1y8vps00k7vxt082jm30k2	cmo1y8vob00jpvxt0hi10fdjg	cmo1xc11n000kvxp0g32oj3wx	19000	2026-04-16 20:46:13.648	2026-04-16 20:46:13.648
cmo1y8vpx00k9vxt0c7igj1th	cmo1y8vob00jpvxt0hi10fdjg	cmo1xc10u000hvxp0dapryn3r	19000	2026-04-16 20:46:13.654	2026-04-16 20:46:13.654
cmo1y8vq300kbvxt0t87d7ji7	cmo1y8vob00jpvxt0hi10fdjg	cmo1xc119000jvxp01snwxzoa	19000	2026-04-16 20:46:13.659	2026-04-16 20:46:13.659
cmo1y8vqd00kfvxt0tysl5qfp	cmo1y8vq800kdvxt0axs7apif	cmo1xsgrt0022vxv8sd7cckj7	27000	2026-04-16 20:46:13.67	2026-04-16 20:46:13.67
cmo1y8vqi00khvxt0ybj2d48e	cmo1y8vq800kdvxt0axs7apif	cmo1xc11v000lvxp07r6uljko	27000	2026-04-16 20:46:13.675	2026-04-16 20:46:13.675
cmo1y8vqn00kjvxt0nkeboxtj	cmo1y8vq800kdvxt0axs7apif	cmo1xc12y000qvxp0uqc7d8d8	27000	2026-04-16 20:46:13.68	2026-04-16 20:46:13.68
cmo1y8vqt00klvxt0zk3ce9ft	cmo1y8vq800kdvxt0axs7apif	cmo1xc13g000svxp0tbndc1wg	27000	2026-04-16 20:46:13.686	2026-04-16 20:46:13.686
cmo1y8vqz00knvxt0k98pgfqr	cmo1y8vq800kdvxt0axs7apif	cmo1xc12q000pvxp0kun82k4l	27000	2026-04-16 20:46:13.691	2026-04-16 20:46:13.691
cmo1y8vr400kpvxt0vjwi9mzd	cmo1y8vq800kdvxt0axs7apif	cmo1xc138000rvxp0r16wi1bz	27000	2026-04-16 20:46:13.697	2026-04-16 20:46:13.697
cmo1y8vra00krvxt08k8ggik1	cmo1y8vq800kdvxt0axs7apif	cmo1xc12i000ovxp01nisgvnu	27000	2026-04-16 20:46:13.702	2026-04-16 20:46:13.702
cmo1y8vrf00ktvxt0xbpznv9m	cmo1y8vq800kdvxt0axs7apif	cmo1xc13o000tvxp0alok8jeb	27000	2026-04-16 20:46:13.708	2026-04-16 20:46:13.708
cmo1y8vrn00kvvxt0bmdqnrcs	cmo1y8vq800kdvxt0axs7apif	cmo1xc11n000kvxp0g32oj3wx	27000	2026-04-16 20:46:13.715	2026-04-16 20:46:13.715
cmo1y8vrs00kxvxt02f7mgtaj	cmo1y8vq800kdvxt0axs7apif	cmo1xc10u000hvxp0dapryn3r	27000	2026-04-16 20:46:13.72	2026-04-16 20:46:13.72
cmo1y8vrx00kzvxt037g34zzx	cmo1y8vq800kdvxt0axs7apif	cmo1xc119000jvxp01snwxzoa	27000	2026-04-16 20:46:13.726	2026-04-16 20:46:13.726
cmo1y8vs900l3vxt0bpyne1c1	cmo1y8vs300l1vxt0zr62u4pg	cmo1xsgrt0022vxv8sd7cckj7	69000	2026-04-16 20:46:13.737	2026-04-16 20:46:13.737
cmo1y8vsg00l5vxt0npnfb8to	cmo1y8vs300l1vxt0zr62u4pg	cmo1xc11v000lvxp07r6uljko	69000	2026-04-16 20:46:13.744	2026-04-16 20:46:13.744
cmo1y8vsn00l7vxt0a9fyngin	cmo1y8vs300l1vxt0zr62u4pg	cmo1xc12y000qvxp0uqc7d8d8	69000	2026-04-16 20:46:13.752	2026-04-16 20:46:13.752
cmo1y8vst00l9vxt0qoouk0sx	cmo1y8vs300l1vxt0zr62u4pg	cmo1xc13g000svxp0tbndc1wg	69000	2026-04-16 20:46:13.757	2026-04-16 20:46:13.757
cmo1y8vsz00lbvxt0nvexocam	cmo1y8vs300l1vxt0zr62u4pg	cmo1xc12q000pvxp0kun82k4l	69000	2026-04-16 20:46:13.764	2026-04-16 20:46:13.764
cmo1y8vt500ldvxt0jr8zsldy	cmo1y8vs300l1vxt0zr62u4pg	cmo1xc138000rvxp0r16wi1bz	69000	2026-04-16 20:46:13.769	2026-04-16 20:46:13.769
cmo1y8vta00lfvxt0c4it37z3	cmo1y8vs300l1vxt0zr62u4pg	cmo1xc12i000ovxp01nisgvnu	69000	2026-04-16 20:46:13.774	2026-04-16 20:46:13.774
cmo1y8vtf00lhvxt0yvo1tlqg	cmo1y8vs300l1vxt0zr62u4pg	cmo1xc13o000tvxp0alok8jeb	69000	2026-04-16 20:46:13.78	2026-04-16 20:46:13.78
cmo1y8vtn00ljvxt0srtu8k0j	cmo1y8vs300l1vxt0zr62u4pg	cmo1xc11n000kvxp0g32oj3wx	69000	2026-04-16 20:46:13.787	2026-04-16 20:46:13.787
cmo1y8vtt00llvxt0dhg7666n	cmo1y8vs300l1vxt0zr62u4pg	cmo1xc10u000hvxp0dapryn3r	69000	2026-04-16 20:46:13.793	2026-04-16 20:46:13.793
cmo1y8vty00lnvxt04r0zarxo	cmo1y8vs300l1vxt0zr62u4pg	cmo1xc119000jvxp01snwxzoa	69000	2026-04-16 20:46:13.799	2026-04-16 20:46:13.799
cmo1y8vu900lrvxt02hav8nks	cmo1y8vu400lpvxt0befifjlv	cmo1xsgrt0022vxv8sd7cckj7	71000	2026-04-16 20:46:13.81	2026-04-16 20:46:13.81
cmo1y8vuf00ltvxt051ilr73c	cmo1y8vu400lpvxt0befifjlv	cmo1xc11v000lvxp07r6uljko	71000	2026-04-16 20:46:13.815	2026-04-16 20:46:13.815
cmo1y8vuk00lvvxt0uevndocx	cmo1y8vu400lpvxt0befifjlv	cmo1xc12y000qvxp0uqc7d8d8	71000	2026-04-16 20:46:13.821	2026-04-16 20:46:13.821
cmo1y8vuq00lxvxt099zmrxew	cmo1y8vu400lpvxt0befifjlv	cmo1xc13g000svxp0tbndc1wg	71000	2026-04-16 20:46:13.826	2026-04-16 20:46:13.826
cmo1y8vux00lzvxt0mn1wj9xq	cmo1y8vu400lpvxt0befifjlv	cmo1xc12q000pvxp0kun82k4l	71000	2026-04-16 20:46:13.833	2026-04-16 20:46:13.833
cmo1y8vv200m1vxt0890mebvp	cmo1y8vu400lpvxt0befifjlv	cmo1xc138000rvxp0r16wi1bz	71000	2026-04-16 20:46:13.839	2026-04-16 20:46:13.839
cmo1y8vv700m3vxt03ju8vonp	cmo1y8vu400lpvxt0befifjlv	cmo1xc12i000ovxp01nisgvnu	71000	2026-04-16 20:46:13.844	2026-04-16 20:46:13.844
cmo1y8vvd00m5vxt056gl6zpn	cmo1y8vu400lpvxt0befifjlv	cmo1xc13o000tvxp0alok8jeb	71000	2026-04-16 20:46:13.849	2026-04-16 20:46:13.849
cmo1y8vvj00m7vxt0nu29qjae	cmo1y8vu400lpvxt0befifjlv	cmo1xc11n000kvxp0g32oj3wx	71000	2026-04-16 20:46:13.856	2026-04-16 20:46:13.856
cmo1y8vvp00m9vxt0p7vcdymv	cmo1y8vu400lpvxt0befifjlv	cmo1xc10u000hvxp0dapryn3r	71000	2026-04-16 20:46:13.861	2026-04-16 20:46:13.861
cmo1y8vvv00mbvxt079qua4lg	cmo1y8vu400lpvxt0befifjlv	cmo1xc119000jvxp01snwxzoa	71000	2026-04-16 20:46:13.867	2026-04-16 20:46:13.867
cmo1y8vw600mfvxt0jpt9sm5t	cmo1y8vw000mdvxt02h16yow0	cmo1xsgrt0022vxv8sd7cckj7	129000	2026-04-16 20:46:13.878	2026-04-16 20:46:13.878
cmo1y8vwc00mhvxt0eanfgg8f	cmo1y8vw000mdvxt02h16yow0	cmo1xc11v000lvxp07r6uljko	129000	2026-04-16 20:46:13.885	2026-04-16 20:46:13.885
cmo1y8vwi00mjvxt0x1hnpl87	cmo1y8vw000mdvxt02h16yow0	cmo1xc12y000qvxp0uqc7d8d8	129000	2026-04-16 20:46:13.89	2026-04-16 20:46:13.89
cmo1y8vwo00mlvxt028sx6ag5	cmo1y8vw000mdvxt02h16yow0	cmo1xc13g000svxp0tbndc1wg	129000	2026-04-16 20:46:13.896	2026-04-16 20:46:13.896
cmo1y8vwt00mnvxt04c7mq8se	cmo1y8vw000mdvxt02h16yow0	cmo1xc12a000nvxp0f1zf3aqg	134000	2026-04-16 20:46:13.902	2026-04-16 20:46:13.902
cmo1y8vwz00mpvxt07zwyag8j	cmo1y8vw000mdvxt02h16yow0	cmo1xc12q000pvxp0kun82k4l	129000	2026-04-16 20:46:13.907	2026-04-16 20:46:13.907
cmo1y8vx400mrvxt0cm0mt4re	cmo1y8vw000mdvxt02h16yow0	cmo1xc138000rvxp0r16wi1bz	122000	2026-04-16 20:46:13.912	2026-04-16 20:46:13.912
cmo1y8vxa00mtvxt0x4hfv2t2	cmo1y8vw000mdvxt02h16yow0	cmo1xc12i000ovxp01nisgvnu	129000	2026-04-16 20:46:13.918	2026-04-16 20:46:13.918
cmo1y8vxf00mvvxt0wehp900p	cmo1y8vw000mdvxt02h16yow0	cmo1xc13o000tvxp0alok8jeb	129000	2026-04-16 20:46:13.924	2026-04-16 20:46:13.924
cmo1y8vxm00mxvxt04ofz3noe	cmo1y8vw000mdvxt02h16yow0	cmo1xc11n000kvxp0g32oj3wx	129000	2026-04-16 20:46:13.931	2026-04-16 20:46:13.931
cmo1y8vxs00mzvxt06pda2ega	cmo1y8vw000mdvxt02h16yow0	cmo1xc10u000hvxp0dapryn3r	129000	2026-04-16 20:46:13.936	2026-04-16 20:46:13.936
cmo1y8vxx00n1vxt0cq041hs5	cmo1y8vw000mdvxt02h16yow0	cmo1xc119000jvxp01snwxzoa	129000	2026-04-16 20:46:13.941	2026-04-16 20:46:13.941
cmo1y8vyb00n5vxt0id966py8	cmo1y8vy300n3vxt05ses51vu	cmo1xsgrt0022vxv8sd7cckj7	50000	2026-04-16 20:46:13.955	2026-04-16 20:46:13.955
cmo1y8vyi00n7vxt0muqechy4	cmo1y8vy300n3vxt05ses51vu	cmo1xc11v000lvxp07r6uljko	50000	2026-04-16 20:46:13.962	2026-04-16 20:46:13.962
cmo1y8vyq00n9vxt0bfo9d9za	cmo1y8vy300n3vxt05ses51vu	cmo1xc12y000qvxp0uqc7d8d8	50000	2026-04-16 20:46:13.97	2026-04-16 20:46:13.97
cmo1y8vyx00nbvxt0hfx0fwoi	cmo1y8vy300n3vxt05ses51vu	cmo1xc13g000svxp0tbndc1wg	50000	2026-04-16 20:46:13.977	2026-04-16 20:46:13.977
cmo1y8vz600ndvxt0zpyst3kg	cmo1y8vy300n3vxt05ses51vu	cmo1xc12q000pvxp0kun82k4l	50000	2026-04-16 20:46:13.986	2026-04-16 20:46:13.986
cmo1y8vzd00nfvxt0w839st9f	cmo1y8vy300n3vxt05ses51vu	cmo1xc138000rvxp0r16wi1bz	50000	2026-04-16 20:46:13.994	2026-04-16 20:46:13.994
cmo1y8vzo00nhvxt0iy5mdywa	cmo1y8vy300n3vxt05ses51vu	cmo1xc12i000ovxp01nisgvnu	50000	2026-04-16 20:46:14.004	2026-04-16 20:46:14.004
cmo1y8vzu00njvxt0w1guxjx6	cmo1y8vy300n3vxt05ses51vu	cmo1xc13o000tvxp0alok8jeb	50000	2026-04-16 20:46:14.011	2026-04-16 20:46:14.011
cmo1y8w0300nlvxt0d5q5xy4b	cmo1y8vy300n3vxt05ses51vu	cmo1xc11n000kvxp0g32oj3wx	50000	2026-04-16 20:46:14.019	2026-04-16 20:46:14.019
cmo1y8w0900nnvxt0jotfk1oe	cmo1y8vy300n3vxt05ses51vu	cmo1xc10u000hvxp0dapryn3r	50000	2026-04-16 20:46:14.026	2026-04-16 20:46:14.026
cmo1y8w0f00npvxt066pvsl1k	cmo1y8vy300n3vxt05ses51vu	cmo1xc119000jvxp01snwxzoa	50000	2026-04-16 20:46:14.032	2026-04-16 20:46:14.032
cmo1y8w0s00ntvxt0c13s90jp	cmo1y8w0m00nrvxt0x2nvtfbe	cmo1xsgrt0022vxv8sd7cckj7	63000	2026-04-16 20:46:14.044	2026-04-16 20:46:14.044
cmo1y8w0y00nvvxt0buiqmybu	cmo1y8w0m00nrvxt0x2nvtfbe	cmo1xc11v000lvxp07r6uljko	63000	2026-04-16 20:46:14.05	2026-04-16 20:46:14.05
cmo1y8w1300nxvxt03vvpwhuz	cmo1y8w0m00nrvxt0x2nvtfbe	cmo1xc12y000qvxp0uqc7d8d8	63000	2026-04-16 20:46:14.056	2026-04-16 20:46:14.056
cmo1y8w1900nzvxt0qcobtsra	cmo1y8w0m00nrvxt0x2nvtfbe	cmo1xc13g000svxp0tbndc1wg	63000	2026-04-16 20:46:14.062	2026-04-16 20:46:14.062
cmo1y8w1i00o1vxt05dl7wd61	cmo1y8w0m00nrvxt0x2nvtfbe	cmo1xc12q000pvxp0kun82k4l	63000	2026-04-16 20:46:14.071	2026-04-16 20:46:14.071
cmo1y8w1q00o3vxt0hr0utmgr	cmo1y8w0m00nrvxt0x2nvtfbe	cmo1xc138000rvxp0r16wi1bz	63000	2026-04-16 20:46:14.078	2026-04-16 20:46:14.078
cmo1y8w1x00o5vxt0rew787a5	cmo1y8w0m00nrvxt0x2nvtfbe	cmo1xc12i000ovxp01nisgvnu	63000	2026-04-16 20:46:14.086	2026-04-16 20:46:14.086
cmo1y8w2500o7vxt05kj6usis	cmo1y8w0m00nrvxt0x2nvtfbe	cmo1xc13o000tvxp0alok8jeb	63000	2026-04-16 20:46:14.093	2026-04-16 20:46:14.093
cmo1y8w2f00o9vxt0zmx8gq0f	cmo1y8w0m00nrvxt0x2nvtfbe	cmo1xc11n000kvxp0g32oj3wx	63000	2026-04-16 20:46:14.103	2026-04-16 20:46:14.103
cmo1y8w2m00obvxt0ey2z9n1c	cmo1y8w0m00nrvxt0x2nvtfbe	cmo1xc10u000hvxp0dapryn3r	63000	2026-04-16 20:46:14.11	2026-04-16 20:46:14.11
cmo1y8w2u00odvxt04al52r8m	cmo1y8w0m00nrvxt0x2nvtfbe	cmo1xc119000jvxp01snwxzoa	63000	2026-04-16 20:46:14.118	2026-04-16 20:46:14.118
cmo1y8w3900ohvxt039rmj4g3	cmo1y8w3100ofvxt0cmzyx2hx	cmo1xsgrt0022vxv8sd7cckj7	40000	2026-04-16 20:46:14.133	2026-04-16 20:46:14.133
cmo1y8w3g00ojvxt0r1giiwzw	cmo1y8w3100ofvxt0cmzyx2hx	cmo1xc11v000lvxp07r6uljko	40000	2026-04-16 20:46:14.14	2026-04-16 20:46:14.14
cmo1y8w3o00olvxt0yfy63ygo	cmo1y8w3100ofvxt0cmzyx2hx	cmo1xc12y000qvxp0uqc7d8d8	40000	2026-04-16 20:46:14.148	2026-04-16 20:46:14.148
cmo1y8w3v00onvxt0v6qfbmum	cmo1y8w3100ofvxt0cmzyx2hx	cmo1xc13g000svxp0tbndc1wg	40000	2026-04-16 20:46:14.155	2026-04-16 20:46:14.155
cmo1y8w4500opvxt0k0a2kptc	cmo1y8w3100ofvxt0cmzyx2hx	cmo1xc12q000pvxp0kun82k4l	40000	2026-04-16 20:46:14.165	2026-04-16 20:46:14.165
cmo1y8w4c00orvxt0j8krm5mo	cmo1y8w3100ofvxt0cmzyx2hx	cmo1xc138000rvxp0r16wi1bz	40000	2026-04-16 20:46:14.172	2026-04-16 20:46:14.172
cmo1y8w4j00otvxt0hp1oxfl4	cmo1y8w3100ofvxt0cmzyx2hx	cmo1xc12i000ovxp01nisgvnu	40000	2026-04-16 20:46:14.179	2026-04-16 20:46:14.179
cmo1y8w4r00ovvxt03xpvq4un	cmo1y8w3100ofvxt0cmzyx2hx	cmo1xc13o000tvxp0alok8jeb	40000	2026-04-16 20:46:14.187	2026-04-16 20:46:14.187
cmo1y8w5000oxvxt05c0oedoq	cmo1y8w3100ofvxt0cmzyx2hx	cmo1xc11n000kvxp0g32oj3wx	40000	2026-04-16 20:46:14.196	2026-04-16 20:46:14.196
cmo1y8w5700ozvxt00yg9tr9e	cmo1y8w3100ofvxt0cmzyx2hx	cmo1xc10u000hvxp0dapryn3r	40000	2026-04-16 20:46:14.204	2026-04-16 20:46:14.204
cmo1y8w5e00p1vxt03bfyng4y	cmo1y8w3100ofvxt0cmzyx2hx	cmo1xc119000jvxp01snwxzoa	40000	2026-04-16 20:46:14.211	2026-04-16 20:46:14.211
cmo1y8w5u00p5vxt02b8r4phv	cmo1y8w5m00p3vxt0wkv2naqp	cmo1xsgrt0022vxv8sd7cckj7	25000	2026-04-16 20:46:14.226	2026-04-16 20:46:14.226
cmo1y8w6100p7vxt0wgjs3k5t	cmo1y8w5m00p3vxt0wkv2naqp	cmo1xc11v000lvxp07r6uljko	25000	2026-04-16 20:46:14.233	2026-04-16 20:46:14.233
cmo1y8w6800p9vxt0huljox71	cmo1y8w5m00p3vxt0wkv2naqp	cmo1xc12y000qvxp0uqc7d8d8	25000	2026-04-16 20:46:14.24	2026-04-16 20:46:14.24
cmo1y8w6g00pbvxt0j5axuc7v	cmo1y8w5m00p3vxt0wkv2naqp	cmo1xc13g000svxp0tbndc1wg	25000	2026-04-16 20:46:14.248	2026-04-16 20:46:14.248
cmo1y8w6q00pdvxt03egma1y7	cmo1y8w5m00p3vxt0wkv2naqp	cmo1xc12q000pvxp0kun82k4l	25000	2026-04-16 20:46:14.259	2026-04-16 20:46:14.259
cmo1y8w7e00pfvxt0ie4lev80	cmo1y8w5m00p3vxt0wkv2naqp	cmo1xc138000rvxp0r16wi1bz	25000	2026-04-16 20:46:14.283	2026-04-16 20:46:14.283
cmo1y8w7k00phvxt0tmfqdreu	cmo1y8w5m00p3vxt0wkv2naqp	cmo1xc12i000ovxp01nisgvnu	25000	2026-04-16 20:46:14.288	2026-04-16 20:46:14.288
cmo1y8w7p00pjvxt0ioo0j6gj	cmo1y8w5m00p3vxt0wkv2naqp	cmo1xc13o000tvxp0alok8jeb	25000	2026-04-16 20:46:14.294	2026-04-16 20:46:14.294
cmo1y8w7w00plvxt04iyehp4k	cmo1y8w5m00p3vxt0wkv2naqp	cmo1xc11n000kvxp0g32oj3wx	25000	2026-04-16 20:46:14.3	2026-04-16 20:46:14.3
cmo1y8w8100pnvxt0kkcve05p	cmo1y8w5m00p3vxt0wkv2naqp	cmo1xc10u000hvxp0dapryn3r	25000	2026-04-16 20:46:14.306	2026-04-16 20:46:14.306
cmo1y8w8700ppvxt071mch8fk	cmo1y8w5m00p3vxt0wkv2naqp	cmo1xc119000jvxp01snwxzoa	25000	2026-04-16 20:46:14.311	2026-04-16 20:46:14.311
cmo1y8w8i00ptvxt0slx55fnk	cmo1y8w8c00prvxt0yskiftu6	cmo1xsgrt0022vxv8sd7cckj7	120000	2026-04-16 20:46:14.322	2026-04-16 20:46:14.322
cmo1y8w8n00pvvxt0t39w6xsx	cmo1y8w8c00prvxt0yskiftu6	cmo1xc11v000lvxp07r6uljko	120000	2026-04-16 20:46:14.328	2026-04-16 20:46:14.328
cmo1y8w8t00pxvxt0q2gjkqhk	cmo1y8w8c00prvxt0yskiftu6	cmo1xc12y000qvxp0uqc7d8d8	120000	2026-04-16 20:46:14.333	2026-04-16 20:46:14.333
cmo1y8w8y00pzvxt08u7u6042	cmo1y8w8c00prvxt0yskiftu6	cmo1xc13g000svxp0tbndc1wg	120000	2026-04-16 20:46:14.339	2026-04-16 20:46:14.339
cmo1y8w9500q1vxt0uuev4kkw	cmo1y8w8c00prvxt0yskiftu6	cmo1xc12q000pvxp0kun82k4l	120000	2026-04-16 20:46:14.345	2026-04-16 20:46:14.345
cmo1y8w9b00q3vxt0z0tws2xi	cmo1y8w8c00prvxt0yskiftu6	cmo1xc138000rvxp0r16wi1bz	111000	2026-04-16 20:46:14.351	2026-04-16 20:46:14.351
cmo1y8w9g00q5vxt0h75p5h1c	cmo1y8w8c00prvxt0yskiftu6	cmo1xc12i000ovxp01nisgvnu	120000	2026-04-16 20:46:14.357	2026-04-16 20:46:14.357
cmo1y8w9m00q7vxt0waw6k8ah	cmo1y8w8c00prvxt0yskiftu6	cmo1xc13o000tvxp0alok8jeb	120000	2026-04-16 20:46:14.362	2026-04-16 20:46:14.362
cmo1y8w9t00q9vxt0m580e9zi	cmo1y8w8c00prvxt0yskiftu6	cmo1xc11n000kvxp0g32oj3wx	120000	2026-04-16 20:46:14.37	2026-04-16 20:46:14.37
cmo1y8w9z00qbvxt0zli2w8s9	cmo1y8w8c00prvxt0yskiftu6	cmo1xc10u000hvxp0dapryn3r	120000	2026-04-16 20:46:14.375	2026-04-16 20:46:14.375
cmo1y8wa500qdvxt07sov6qzh	cmo1y8w8c00prvxt0yskiftu6	cmo1xc119000jvxp01snwxzoa	120000	2026-04-16 20:46:14.381	2026-04-16 20:46:14.381
cmo1y8wah00qhvxt0s25qz03h	cmo1y8wab00qfvxt03zhcjaup	cmo1xsgrt0022vxv8sd7cckj7	85000	2026-04-16 20:46:14.393	2026-04-16 20:46:14.393
cmo1y8wan00qjvxt0enos10j2	cmo1y8wab00qfvxt03zhcjaup	cmo1xc11v000lvxp07r6uljko	85000	2026-04-16 20:46:14.4	2026-04-16 20:46:14.4
cmo1y8wat00qlvxt0vbp402s0	cmo1y8wab00qfvxt03zhcjaup	cmo1xc12y000qvxp0uqc7d8d8	85000	2026-04-16 20:46:14.405	2026-04-16 20:46:14.405
cmo1y8waz00qnvxt05364k58g	cmo1y8wab00qfvxt03zhcjaup	cmo1xc13g000svxp0tbndc1wg	85000	2026-04-16 20:46:14.411	2026-04-16 20:46:14.411
cmo1y8wb600qpvxt0wsz09vlm	cmo1y8wab00qfvxt03zhcjaup	cmo1xc12q000pvxp0kun82k4l	85000	2026-04-16 20:46:14.418	2026-04-16 20:46:14.418
cmo1y8wbb00qrvxt0thgfzxw7	cmo1y8wab00qfvxt03zhcjaup	cmo1xc138000rvxp0r16wi1bz	85000	2026-04-16 20:46:14.424	2026-04-16 20:46:14.424
cmo1y8wbh00qtvxt00ntfduql	cmo1y8wab00qfvxt03zhcjaup	cmo1xc12i000ovxp01nisgvnu	85000	2026-04-16 20:46:14.43	2026-04-16 20:46:14.43
cmo1y8wbo00qvvxt0cv2r7e58	cmo1y8wab00qfvxt03zhcjaup	cmo1xc13o000tvxp0alok8jeb	85000	2026-04-16 20:46:14.436	2026-04-16 20:46:14.436
cmo1y8wbv00qxvxt0zit2pn2x	cmo1y8wab00qfvxt03zhcjaup	cmo1xc11n000kvxp0g32oj3wx	85000	2026-04-16 20:46:14.443	2026-04-16 20:46:14.443
cmo1y8wc000qzvxt07j9bucuc	cmo1y8wab00qfvxt03zhcjaup	cmo1xc10u000hvxp0dapryn3r	85000	2026-04-16 20:46:14.449	2026-04-16 20:46:14.449
cmo1y8wc600r1vxt0cyz4e5ut	cmo1y8wab00qfvxt03zhcjaup	cmo1xc119000jvxp01snwxzoa	85000	2026-04-16 20:46:14.454	2026-04-16 20:46:14.454
cmo1y8wch00r5vxt0r4nmpkq7	cmo1y8wcb00r3vxt0sjsosf6u	cmo1xsgrt0022vxv8sd7cckj7	50000	2026-04-16 20:46:14.466	2026-04-16 20:46:14.466
cmo1y8wcn00r7vxt0z6944e5e	cmo1y8wcb00r3vxt0sjsosf6u	cmo1xc11v000lvxp07r6uljko	50000	2026-04-16 20:46:14.471	2026-04-16 20:46:14.471
cmo1y8wcs00r9vxt0bvejlzvk	cmo1y8wcb00r3vxt0sjsosf6u	cmo1xc12y000qvxp0uqc7d8d8	50000	2026-04-16 20:46:14.477	2026-04-16 20:46:14.477
cmo1y8wcy00rbvxt0i4aeznsl	cmo1y8wcb00r3vxt0sjsosf6u	cmo1xc13g000svxp0tbndc1wg	50000	2026-04-16 20:46:14.483	2026-04-16 20:46:14.483
cmo1y8wd500rdvxt0spuoyblv	cmo1y8wcb00r3vxt0sjsosf6u	cmo1xc12q000pvxp0kun82k4l	50000	2026-04-16 20:46:14.49	2026-04-16 20:46:14.49
cmo1y8wdb00rfvxt0pggxq7ky	cmo1y8wcb00r3vxt0sjsosf6u	cmo1xc138000rvxp0r16wi1bz	48000	2026-04-16 20:46:14.495	2026-04-16 20:46:14.495
cmo1y8wdh00rhvxt0ore4subd	cmo1y8wcb00r3vxt0sjsosf6u	cmo1xc12i000ovxp01nisgvnu	50000	2026-04-16 20:46:14.501	2026-04-16 20:46:14.501
cmo1y8wdo00rjvxt0pdmpy8to	cmo1y8wcb00r3vxt0sjsosf6u	cmo1xc13o000tvxp0alok8jeb	50000	2026-04-16 20:46:14.509	2026-04-16 20:46:14.509
cmo1y8wdx00rlvxt0gelmvo6i	cmo1y8wcb00r3vxt0sjsosf6u	cmo1xc11n000kvxp0g32oj3wx	50000	2026-04-16 20:46:14.517	2026-04-16 20:46:14.517
cmo1y8we200rnvxt08fos7iy1	cmo1y8wcb00r3vxt0sjsosf6u	cmo1xc10u000hvxp0dapryn3r	50000	2026-04-16 20:46:14.522	2026-04-16 20:46:14.522
cmo1y8we700rpvxt0p11evhtl	cmo1y8wcb00r3vxt0sjsosf6u	cmo1xc119000jvxp01snwxzoa	50000	2026-04-16 20:46:14.528	2026-04-16 20:46:14.528
cmo1y8wej00rtvxt01onf2wu9	cmo1y8wed00rrvxt01tm0werf	cmo1xsgrt0022vxv8sd7cckj7	45000	2026-04-16 20:46:14.539	2026-04-16 20:46:14.539
cmo1y8weo00rvvxt0zydpaqzd	cmo1y8wed00rrvxt01tm0werf	cmo1xc11v000lvxp07r6uljko	45000	2026-04-16 20:46:14.544	2026-04-16 20:46:14.544
cmo1y8wet00rxvxt0wr22kh5b	cmo1y8wed00rrvxt01tm0werf	cmo1xc12y000qvxp0uqc7d8d8	45000	2026-04-16 20:46:14.55	2026-04-16 20:46:14.55
cmo1y8wez00rzvxt0tod1ffsz	cmo1y8wed00rrvxt01tm0werf	cmo1xc13g000svxp0tbndc1wg	45000	2026-04-16 20:46:14.555	2026-04-16 20:46:14.555
cmo1y8wf600s1vxt0klr7oy65	cmo1y8wed00rrvxt01tm0werf	cmo1xc12q000pvxp0kun82k4l	45000	2026-04-16 20:46:14.562	2026-04-16 20:46:14.562
cmo1y8wfc00s3vxt07u70wr2c	cmo1y8wed00rrvxt01tm0werf	cmo1xc138000rvxp0r16wi1bz	43000	2026-04-16 20:46:14.568	2026-04-16 20:46:14.568
cmo1y8wfh00s5vxt0gfjf1ekp	cmo1y8wed00rrvxt01tm0werf	cmo1xc12i000ovxp01nisgvnu	45000	2026-04-16 20:46:14.574	2026-04-16 20:46:14.574
cmo1y8wfn00s7vxt064pb1mxv	cmo1y8wed00rrvxt01tm0werf	cmo1xc13o000tvxp0alok8jeb	45000	2026-04-16 20:46:14.579	2026-04-16 20:46:14.579
cmo1y8wfu00s9vxt09z8bw09f	cmo1y8wed00rrvxt01tm0werf	cmo1xc11n000kvxp0g32oj3wx	45000	2026-04-16 20:46:14.586	2026-04-16 20:46:14.586
cmo1y8wfz00sbvxt0e6b98guu	cmo1y8wed00rrvxt01tm0werf	cmo1xc10u000hvxp0dapryn3r	45000	2026-04-16 20:46:14.592	2026-04-16 20:46:14.592
cmo1y8wg500sdvxt0ej4gzkn2	cmo1y8wed00rrvxt01tm0werf	cmo1xc119000jvxp01snwxzoa	45000	2026-04-16 20:46:14.598	2026-04-16 20:46:14.598
cmo1y8wgh00shvxt048rohsw3	cmo1y8wgb00sfvxt0i44b5v69	cmo1xsgrt0022vxv8sd7cckj7	27000	2026-04-16 20:46:14.609	2026-04-16 20:46:14.609
cmo1y8wgn00sjvxt0j25ga78k	cmo1y8wgb00sfvxt0i44b5v69	cmo1xc11v000lvxp07r6uljko	27000	2026-04-16 20:46:14.615	2026-04-16 20:46:14.615
cmo1y8wgt00slvxt0bpfgjmd6	cmo1y8wgb00sfvxt0i44b5v69	cmo1xc12y000qvxp0uqc7d8d8	27000	2026-04-16 20:46:14.621	2026-04-16 20:46:14.621
cmo1y8wgy00snvxt07650dgxy	cmo1y8wgb00sfvxt0i44b5v69	cmo1xc13g000svxp0tbndc1wg	27000	2026-04-16 20:46:14.626	2026-04-16 20:46:14.626
cmo1y8wh500spvxt0ra4ywhc2	cmo1y8wgb00sfvxt0i44b5v69	cmo1xc12q000pvxp0kun82k4l	27000	2026-04-16 20:46:14.634	2026-04-16 20:46:14.634
cmo1y8whb00srvxt0kpg9jzru	cmo1y8wgb00sfvxt0i44b5v69	cmo1xc138000rvxp0r16wi1bz	25000	2026-04-16 20:46:14.639	2026-04-16 20:46:14.639
cmo1y8whh00stvxt0sd8ev5lg	cmo1y8wgb00sfvxt0i44b5v69	cmo1xc12i000ovxp01nisgvnu	27000	2026-04-16 20:46:14.645	2026-04-16 20:46:14.645
cmo1y8whn00svvxt0dfeon4qz	cmo1y8wgb00sfvxt0i44b5v69	cmo1xc13o000tvxp0alok8jeb	27000	2026-04-16 20:46:14.651	2026-04-16 20:46:14.651
cmo1y8whu00sxvxt0udam11g8	cmo1y8wgb00sfvxt0i44b5v69	cmo1xc11n000kvxp0g32oj3wx	30000	2026-04-16 20:46:14.658	2026-04-16 20:46:14.658
cmo1y8wi000szvxt07j9q3t5s	cmo1y8wgb00sfvxt0i44b5v69	cmo1xc10u000hvxp0dapryn3r	27000	2026-04-16 20:46:14.664	2026-04-16 20:46:14.664
cmo1y8wi600t1vxt0dec1b89q	cmo1y8wgb00sfvxt0i44b5v69	cmo1xc119000jvxp01snwxzoa	27000	2026-04-16 20:46:14.67	2026-04-16 20:46:14.67
cmo1y8wih00t5vxt0b21mpaoy	cmo1y8wib00t3vxt0b6r4ebsb	cmo1xsgrt0022vxv8sd7cckj7	27000	2026-04-16 20:46:14.682	2026-04-16 20:46:14.682
cmo1y8win00t7vxt0r2cw7z01	cmo1y8wib00t3vxt0b6r4ebsb	cmo1xc11v000lvxp07r6uljko	27000	2026-04-16 20:46:14.688	2026-04-16 20:46:14.688
cmo1y8wit00t9vxt0j3skhn88	cmo1y8wib00t3vxt0b6r4ebsb	cmo1xc12y000qvxp0uqc7d8d8	27000	2026-04-16 20:46:14.693	2026-04-16 20:46:14.693
cmo1y8wiy00tbvxt0ol2ajg0o	cmo1y8wib00t3vxt0b6r4ebsb	cmo1xc13g000svxp0tbndc1wg	27000	2026-04-16 20:46:14.699	2026-04-16 20:46:14.699
cmo1y8wj500tdvxt0jxko6351	cmo1y8wib00t3vxt0b6r4ebsb	cmo1xc12q000pvxp0kun82k4l	27000	2026-04-16 20:46:14.706	2026-04-16 20:46:14.706
cmo1y8wjb00tfvxt0hflrnp27	cmo1y8wib00t3vxt0b6r4ebsb	cmo1xc138000rvxp0r16wi1bz	25000	2026-04-16 20:46:14.711	2026-04-16 20:46:14.711
cmo1y8wjh00thvxt0dzqeq3kz	cmo1y8wib00t3vxt0b6r4ebsb	cmo1xc12i000ovxp01nisgvnu	27000	2026-04-16 20:46:14.717	2026-04-16 20:46:14.717
cmo1y8wjm00tjvxt0nmvs7gmq	cmo1y8wib00t3vxt0b6r4ebsb	cmo1xc13o000tvxp0alok8jeb	27000	2026-04-16 20:46:14.722	2026-04-16 20:46:14.722
cmo1y8wjt00tlvxt0k4uu2z2p	cmo1y8wib00t3vxt0b6r4ebsb	cmo1xc11n000kvxp0g32oj3wx	30000	2026-04-16 20:46:14.729	2026-04-16 20:46:14.729
cmo1y8wjz00tnvxt0f46ff24q	cmo1y8wib00t3vxt0b6r4ebsb	cmo1xc10u000hvxp0dapryn3r	27000	2026-04-16 20:46:14.735	2026-04-16 20:46:14.735
cmo1y8wk500tpvxt052rkk9wf	cmo1y8wib00t3vxt0b6r4ebsb	cmo1xc119000jvxp01snwxzoa	27000	2026-04-16 20:46:14.741	2026-04-16 20:46:14.741
cmo1y8wkh00ttvxt0dm1r95xm	cmo1y8wka00trvxt0rqxd6rlw	cmo1xsgrt0022vxv8sd7cckj7	27000	2026-04-16 20:46:14.753	2026-04-16 20:46:14.753
cmo1y8wko00tvvxt037l0wjre	cmo1y8wka00trvxt0rqxd6rlw	cmo1xc11v000lvxp07r6uljko	27000	2026-04-16 20:46:14.761	2026-04-16 20:46:14.761
cmo1y8wkw00txvxt0ptloxjud	cmo1y8wka00trvxt0rqxd6rlw	cmo1xc12y000qvxp0uqc7d8d8	27000	2026-04-16 20:46:14.768	2026-04-16 20:46:14.768
cmo1y8wl200tzvxt04yoekq0s	cmo1y8wka00trvxt0rqxd6rlw	cmo1xc13g000svxp0tbndc1wg	27000	2026-04-16 20:46:14.774	2026-04-16 20:46:14.774
cmo1y8wl900u1vxt0rg6ykoz4	cmo1y8wka00trvxt0rqxd6rlw	cmo1xc12q000pvxp0kun82k4l	27000	2026-04-16 20:46:14.781	2026-04-16 20:46:14.781
cmo1y8wlf00u3vxt0lliurmdq	cmo1y8wka00trvxt0rqxd6rlw	cmo1xc138000rvxp0r16wi1bz	25000	2026-04-16 20:46:14.787	2026-04-16 20:46:14.787
cmo1y8wlk00u5vxt0sfo3vcrm	cmo1y8wka00trvxt0rqxd6rlw	cmo1xc12i000ovxp01nisgvnu	27000	2026-04-16 20:46:14.792	2026-04-16 20:46:14.792
cmo1y8wlp00u7vxt00qdnx4b8	cmo1y8wka00trvxt0rqxd6rlw	cmo1xc13o000tvxp0alok8jeb	27000	2026-04-16 20:46:14.798	2026-04-16 20:46:14.798
cmo1y8wlw00u9vxt0zf0unye7	cmo1y8wka00trvxt0rqxd6rlw	cmo1xc11n000kvxp0g32oj3wx	30000	2026-04-16 20:46:14.805	2026-04-16 20:46:14.805
cmo1y8wm200ubvxt0z4rj3lp2	cmo1y8wka00trvxt0rqxd6rlw	cmo1xc10u000hvxp0dapryn3r	27000	2026-04-16 20:46:14.811	2026-04-16 20:46:14.811
cmo1y8wm800udvxt0gefhyh5s	cmo1y8wka00trvxt0rqxd6rlw	cmo1xc119000jvxp01snwxzoa	27000	2026-04-16 20:46:14.816	2026-04-16 20:46:14.816
cmo1y8wmj00uhvxt0kkjnrynh	cmo1y8wme00ufvxt0em9qyrr6	cmo1xsgrt0022vxv8sd7cckj7	28000	2026-04-16 20:46:14.828	2026-04-16 20:46:14.828
cmo1y8wmp00ujvxt0a14htt5c	cmo1y8wme00ufvxt0em9qyrr6	cmo1xc11v000lvxp07r6uljko	28000	2026-04-16 20:46:14.834	2026-04-16 20:46:14.834
cmo1y8wmw00ulvxt005s6yss0	cmo1y8wme00ufvxt0em9qyrr6	cmo1xc12y000qvxp0uqc7d8d8	31000	2026-04-16 20:46:14.84	2026-04-16 20:46:14.84
cmo1y8wn100unvxt0kqqtdjqy	cmo1y8wme00ufvxt0em9qyrr6	cmo1xc13g000svxp0tbndc1wg	28000	2026-04-16 20:46:14.845	2026-04-16 20:46:14.845
cmo1y8wn800upvxt0vyfn2nub	cmo1y8wme00ufvxt0em9qyrr6	cmo1xc12q000pvxp0kun82k4l	28000	2026-04-16 20:46:14.853	2026-04-16 20:46:14.853
cmo1y8wne00urvxt0v01z3oj5	cmo1y8wme00ufvxt0em9qyrr6	cmo1xc138000rvxp0r16wi1bz	27000	2026-04-16 20:46:14.858	2026-04-16 20:46:14.858
cmo1y8wnj00utvxt0munnoipz	cmo1y8wme00ufvxt0em9qyrr6	cmo1xc12i000ovxp01nisgvnu	28000	2026-04-16 20:46:14.864	2026-04-16 20:46:14.864
cmo1y8wnp00uvvxt00rpy99o3	cmo1y8wme00ufvxt0em9qyrr6	cmo1xc13o000tvxp0alok8jeb	28000	2026-04-16 20:46:14.869	2026-04-16 20:46:14.869
cmo1y8wnw00uxvxt03sic2rcs	cmo1y8wme00ufvxt0em9qyrr6	cmo1xc11n000kvxp0g32oj3wx	31000	2026-04-16 20:46:14.876	2026-04-16 20:46:14.876
cmo1y8wo300uzvxt0k6brnt7o	cmo1y8wme00ufvxt0em9qyrr6	cmo1xc10u000hvxp0dapryn3r	28000	2026-04-16 20:46:14.883	2026-04-16 20:46:14.883
cmo1y8wo900v1vxt0hkslsume	cmo1y8wme00ufvxt0em9qyrr6	cmo1xc119000jvxp01snwxzoa	28000	2026-04-16 20:46:14.889	2026-04-16 20:46:14.889
cmo1y8wol00v5vxt0z4t522of	cmo1y8wof00v3vxt0e3w3u351	cmo1xsgrt0022vxv8sd7cckj7	30000	2026-04-16 20:46:14.902	2026-04-16 20:46:14.902
cmo1y8wor00v7vxt0p3nekhjg	cmo1y8wof00v3vxt0e3w3u351	cmo1xc11v000lvxp07r6uljko	30000	2026-04-16 20:46:14.908	2026-04-16 20:46:14.908
cmo1y8woy00v9vxt0bgi7apvc	cmo1y8wof00v3vxt0e3w3u351	cmo1xc12y000qvxp0uqc7d8d8	30000	2026-04-16 20:46:14.914	2026-04-16 20:46:14.914
cmo1y8wp400vbvxt0xbod9acw	cmo1y8wof00v3vxt0e3w3u351	cmo1xc13g000svxp0tbndc1wg	30000	2026-04-16 20:46:14.92	2026-04-16 20:46:14.92
cmo1y8wpb00vdvxt0hle5u19w	cmo1y8wof00v3vxt0e3w3u351	cmo1xc12q000pvxp0kun82k4l	30000	2026-04-16 20:46:14.927	2026-04-16 20:46:14.927
cmo1y8wpg00vfvxt0wib6ur18	cmo1y8wof00v3vxt0e3w3u351	cmo1xc138000rvxp0r16wi1bz	27000	2026-04-16 20:46:14.933	2026-04-16 20:46:14.933
cmo1y8wpm00vhvxt0mo7gt9uf	cmo1y8wof00v3vxt0e3w3u351	cmo1xc12i000ovxp01nisgvnu	30000	2026-04-16 20:46:14.938	2026-04-16 20:46:14.938
cmo1y8wpr00vjvxt0jtrtqkrl	cmo1y8wof00v3vxt0e3w3u351	cmo1xc13o000tvxp0alok8jeb	30000	2026-04-16 20:46:14.944	2026-04-16 20:46:14.944
cmo1y8wq400vlvxt07egqaczn	cmo1y8wof00v3vxt0e3w3u351	cmo1xc11n000kvxp0g32oj3wx	33000	2026-04-16 20:46:14.956	2026-04-16 20:46:14.956
cmo1y8wq900vnvxt04ko7jt95	cmo1y8wof00v3vxt0e3w3u351	cmo1xc10u000hvxp0dapryn3r	30000	2026-04-16 20:46:14.962	2026-04-16 20:46:14.962
cmo1y8wqg00vpvxt004lhyebf	cmo1y8wof00v3vxt0e3w3u351	cmo1xc119000jvxp01snwxzoa	30000	2026-04-16 20:46:14.968	2026-04-16 20:46:14.968
cmo1y8wqr00vtvxt0exkxm0jk	cmo1y8wql00vrvxt0gwd5bmby	cmo1xsgrt0022vxv8sd7cckj7	33000	2026-04-16 20:46:14.979	2026-04-16 20:46:14.979
cmo1y8wqx00vvvxt0xny6yutb	cmo1y8wql00vrvxt0gwd5bmby	cmo1xc11v000lvxp07r6uljko	33000	2026-04-16 20:46:14.985	2026-04-16 20:46:14.985
cmo1y8wr200vxvxt066g8rb5u	cmo1y8wql00vrvxt0gwd5bmby	cmo1xc12y000qvxp0uqc7d8d8	33000	2026-04-16 20:46:14.991	2026-04-16 20:46:14.991
cmo1y8wr800vzvxt0au1ygado	cmo1y8wql00vrvxt0gwd5bmby	cmo1xc13g000svxp0tbndc1wg	33000	2026-04-16 20:46:14.996	2026-04-16 20:46:14.996
cmo1y8wrg00w1vxt0ie8554yf	cmo1y8wql00vrvxt0gwd5bmby	cmo1xc12q000pvxp0kun82k4l	33000	2026-04-16 20:46:15.004	2026-04-16 20:46:15.004
cmo1y8wrm00w3vxt01qcbgvyi	cmo1y8wql00vrvxt0gwd5bmby	cmo1xc138000rvxp0r16wi1bz	31000	2026-04-16 20:46:15.01	2026-04-16 20:46:15.01
cmo1y8wrt00w5vxt0a8ae5e6i	cmo1y8wql00vrvxt0gwd5bmby	cmo1xc12i000ovxp01nisgvnu	33000	2026-04-16 20:46:15.017	2026-04-16 20:46:15.017
cmo1y8ws000w7vxt025ni09a9	cmo1y8wql00vrvxt0gwd5bmby	cmo1xc13o000tvxp0alok8jeb	33000	2026-04-16 20:46:15.024	2026-04-16 20:46:15.024
cmo1y8ws700w9vxt0dgt0h3se	cmo1y8wql00vrvxt0gwd5bmby	cmo1xc11n000kvxp0g32oj3wx	36000	2026-04-16 20:46:15.032	2026-04-16 20:46:15.032
cmo1y8wsd00wbvxt0esf2yiap	cmo1y8wql00vrvxt0gwd5bmby	cmo1xc10u000hvxp0dapryn3r	33000	2026-04-16 20:46:15.037	2026-04-16 20:46:15.037
cmo1y8wsi00wdvxt0lxvmy4nv	cmo1y8wql00vrvxt0gwd5bmby	cmo1xc119000jvxp01snwxzoa	33000	2026-04-16 20:46:15.042	2026-04-16 20:46:15.042
cmo1y8wst00whvxt0hl5lrtzz	cmo1y8wsn00wfvxt09e5fmfvs	cmo1xsgrt0022vxv8sd7cckj7	33000	2026-04-16 20:46:15.053	2026-04-16 20:46:15.053
cmo1y8wsy00wjvxt0yffehzsm	cmo1y8wsn00wfvxt09e5fmfvs	cmo1xc11v000lvxp07r6uljko	33000	2026-04-16 20:46:15.059	2026-04-16 20:46:15.059
cmo1y8wt400wlvxt0dnzsr8ur	cmo1y8wsn00wfvxt09e5fmfvs	cmo1xc12y000qvxp0uqc7d8d8	33000	2026-04-16 20:46:15.065	2026-04-16 20:46:15.065
cmo1y8wta00wnvxt01813ppeh	cmo1y8wsn00wfvxt09e5fmfvs	cmo1xc13g000svxp0tbndc1wg	33000	2026-04-16 20:46:15.071	2026-04-16 20:46:15.071
cmo1y8wtg00wpvxt0rtxd00pp	cmo1y8wsn00wfvxt09e5fmfvs	cmo1xc12q000pvxp0kun82k4l	33000	2026-04-16 20:46:15.077	2026-04-16 20:46:15.077
cmo1y8wtm00wrvxt0c5jogtsw	cmo1y8wsn00wfvxt09e5fmfvs	cmo1xc138000rvxp0r16wi1bz	31000	2026-04-16 20:46:15.082	2026-04-16 20:46:15.082
cmo1y8wts00wtvxt0xfgxt6cl	cmo1y8wsn00wfvxt09e5fmfvs	cmo1xc12i000ovxp01nisgvnu	33000	2026-04-16 20:46:15.088	2026-04-16 20:46:15.088
cmo1y8wtx00wvvxt06xvra6tl	cmo1y8wsn00wfvxt09e5fmfvs	cmo1xc13o000tvxp0alok8jeb	33000	2026-04-16 20:46:15.093	2026-04-16 20:46:15.093
cmo1y8wu400wxvxt07zk7b2o2	cmo1y8wsn00wfvxt09e5fmfvs	cmo1xc11n000kvxp0g32oj3wx	36000	2026-04-16 20:46:15.1	2026-04-16 20:46:15.1
cmo1y8wu900wzvxt0wn8879dm	cmo1y8wsn00wfvxt09e5fmfvs	cmo1xc10u000hvxp0dapryn3r	33000	2026-04-16 20:46:15.106	2026-04-16 20:46:15.106
cmo1y8wuf00x1vxt0g87t7b1w	cmo1y8wsn00wfvxt09e5fmfvs	cmo1xc119000jvxp01snwxzoa	33000	2026-04-16 20:46:15.111	2026-04-16 20:46:15.111
cmo1y8wuq00x5vxt0ibf4y84f	cmo1y8wuk00x3vxt08v9j8agn	cmo1xsgrt0022vxv8sd7cckj7	25000	2026-04-16 20:46:15.122	2026-04-16 20:46:15.122
cmo1y8wuv00x7vxt0crqzwoy0	cmo1y8wuk00x3vxt08v9j8agn	cmo1xc11v000lvxp07r6uljko	25000	2026-04-16 20:46:15.128	2026-04-16 20:46:15.128
cmo1y8wv100x9vxt0u10xzpkx	cmo1y8wuk00x3vxt08v9j8agn	cmo1xc12y000qvxp0uqc7d8d8	25000	2026-04-16 20:46:15.133	2026-04-16 20:46:15.133
cmo1y8wv700xbvxt0mrclh6t9	cmo1y8wuk00x3vxt08v9j8agn	cmo1xc13g000svxp0tbndc1wg	25000	2026-04-16 20:46:15.139	2026-04-16 20:46:15.139
cmo1y8wvd00xdvxt0fknszrs4	cmo1y8wuk00x3vxt08v9j8agn	cmo1xc12q000pvxp0kun82k4l	25000	2026-04-16 20:46:15.146	2026-04-16 20:46:15.146
cmo1y8wvj00xfvxt0tupdnt62	cmo1y8wuk00x3vxt08v9j8agn	cmo1xc138000rvxp0r16wi1bz	25000	2026-04-16 20:46:15.152	2026-04-16 20:46:15.152
cmo1y8wvp00xhvxt0kxybjg4j	cmo1y8wuk00x3vxt08v9j8agn	cmo1xc12i000ovxp01nisgvnu	25000	2026-04-16 20:46:15.157	2026-04-16 20:46:15.157
cmo1y8wvv00xjvxt0njeeupht	cmo1y8wuk00x3vxt08v9j8agn	cmo1xc13o000tvxp0alok8jeb	25000	2026-04-16 20:46:15.163	2026-04-16 20:46:15.163
cmo1y8ww100xlvxt027kc5obh	cmo1y8wuk00x3vxt08v9j8agn	cmo1xc11n000kvxp0g32oj3wx	28000	2026-04-16 20:46:15.17	2026-04-16 20:46:15.17
cmo1y8ww700xnvxt0sxt30081	cmo1y8wuk00x3vxt08v9j8agn	cmo1xc10u000hvxp0dapryn3r	25000	2026-04-16 20:46:15.176	2026-04-16 20:46:15.176
cmo1y8wwd00xpvxt0y23djccn	cmo1y8wuk00x3vxt08v9j8agn	cmo1xc119000jvxp01snwxzoa	25000	2026-04-16 20:46:15.181	2026-04-16 20:46:15.181
cmo1y8wwo00xtvxt0li22x1zx	cmo1y8wwj00xrvxt0f0i3wr7g	cmo1xsgrt0022vxv8sd7cckj7	22000	2026-04-16 20:46:15.193	2026-04-16 20:46:15.193
cmo1y8wwu00xvvxt0wd73y7wf	cmo1y8wwj00xrvxt0f0i3wr7g	cmo1xc11v000lvxp07r6uljko	22000	2026-04-16 20:46:15.198	2026-04-16 20:46:15.198
cmo1y8wwz00xxvxt00py2644o	cmo1y8wwj00xrvxt0f0i3wr7g	cmo1xc12y000qvxp0uqc7d8d8	22000	2026-04-16 20:46:15.204	2026-04-16 20:46:15.204
cmo1y8wx400xzvxt0k9ryirwh	cmo1y8wwj00xrvxt0f0i3wr7g	cmo1xc13g000svxp0tbndc1wg	22000	2026-04-16 20:46:15.209	2026-04-16 20:46:15.209
cmo1y8wxb00y1vxt05pqbhyae	cmo1y8wwj00xrvxt0f0i3wr7g	cmo1xc12q000pvxp0kun82k4l	22000	2026-04-16 20:46:15.215	2026-04-16 20:46:15.215
cmo1y8wxg00y3vxt0aqeyzxsb	cmo1y8wwj00xrvxt0f0i3wr7g	cmo1xc138000rvxp0r16wi1bz	22000	2026-04-16 20:46:15.221	2026-04-16 20:46:15.221
cmo1y8wxl00y5vxt0uje2jcxx	cmo1y8wwj00xrvxt0f0i3wr7g	cmo1xc12i000ovxp01nisgvnu	22000	2026-04-16 20:46:15.226	2026-04-16 20:46:15.226
cmo1y8wxr00y7vxt09t58cwdm	cmo1y8wwj00xrvxt0f0i3wr7g	cmo1xc13o000tvxp0alok8jeb	22000	2026-04-16 20:46:15.231	2026-04-16 20:46:15.231
cmo1y8wy000y9vxt06n52b5er	cmo1y8wwj00xrvxt0f0i3wr7g	cmo1xc11n000kvxp0g32oj3wx	25000	2026-04-16 20:46:15.24	2026-04-16 20:46:15.24
cmo1y8wy600ybvxt0hf5y1bf1	cmo1y8wwj00xrvxt0f0i3wr7g	cmo1xc10u000hvxp0dapryn3r	22000	2026-04-16 20:46:15.246	2026-04-16 20:46:15.246
cmo1y8wyd00ydvxt0ddlob0ny	cmo1y8wwj00xrvxt0f0i3wr7g	cmo1xc119000jvxp01snwxzoa	22000	2026-04-16 20:46:15.253	2026-04-16 20:46:15.253
cmo1y8wys00yhvxt0lu9wduv1	cmo1y8wyk00yfvxt0ol3d74i9	cmo1xsgrt0022vxv8sd7cckj7	50000	2026-04-16 20:46:15.268	2026-04-16 20:46:15.268
cmo1y8wyz00yjvxt0pfda17xa	cmo1y8wyk00yfvxt0ol3d74i9	cmo1xc11v000lvxp07r6uljko	50000	2026-04-16 20:46:15.275	2026-04-16 20:46:15.275
cmo1y8wz600ylvxt0o78zer5s	cmo1y8wyk00yfvxt0ol3d74i9	cmo1xc12y000qvxp0uqc7d8d8	50000	2026-04-16 20:46:15.282	2026-04-16 20:46:15.282
cmo1y8wzc00ynvxt0y1wjz4j8	cmo1y8wyk00yfvxt0ol3d74i9	cmo1xc13g000svxp0tbndc1wg	50000	2026-04-16 20:46:15.288	2026-04-16 20:46:15.288
cmo1y8wzm00ypvxt0fwmz7kdq	cmo1y8wyk00yfvxt0ol3d74i9	cmo1xc12q000pvxp0kun82k4l	50000	2026-04-16 20:46:15.299	2026-04-16 20:46:15.299
cmo1y8wzs00yrvxt05qs5w8lc	cmo1y8wyk00yfvxt0ol3d74i9	cmo1xc138000rvxp0r16wi1bz	48000	2026-04-16 20:46:15.305	2026-04-16 20:46:15.305
cmo1y8wzy00ytvxt0gvx60h5j	cmo1y8wyk00yfvxt0ol3d74i9	cmo1xc12i000ovxp01nisgvnu	50000	2026-04-16 20:46:15.31	2026-04-16 20:46:15.31
cmo1y8x0300yvvxt0q7bxn9sa	cmo1y8wyk00yfvxt0ol3d74i9	cmo1xc13o000tvxp0alok8jeb	50000	2026-04-16 20:46:15.316	2026-04-16 20:46:15.316
cmo1y8x0c00yxvxt0kax4rees	cmo1y8wyk00yfvxt0ol3d74i9	cmo1xc11n000kvxp0g32oj3wx	53000	2026-04-16 20:46:15.325	2026-04-16 20:46:15.325
cmo1y8x0j00yzvxt0gfc9gz7c	cmo1y8wyk00yfvxt0ol3d74i9	cmo1xc10u000hvxp0dapryn3r	50000	2026-04-16 20:46:15.331	2026-04-16 20:46:15.331
cmo1y8x0o00z1vxt0z8nvxtop	cmo1y8wyk00yfvxt0ol3d74i9	cmo1xc119000jvxp01snwxzoa	50000	2026-04-16 20:46:15.337	2026-04-16 20:46:15.337
cmo1y8x1000z5vxt0xwrpi9ok	cmo1y8x0u00z3vxt0btygbkru	cmo1xsgrt0022vxv8sd7cckj7	44000	2026-04-16 20:46:15.348	2026-04-16 20:46:15.348
cmo1y8x1600z7vxt06mxr44mi	cmo1y8x0u00z3vxt0btygbkru	cmo1xc11v000lvxp07r6uljko	44000	2026-04-16 20:46:15.354	2026-04-16 20:46:15.354
cmo1y8x1b00z9vxt0j32hmwb4	cmo1y8x0u00z3vxt0btygbkru	cmo1xc12y000qvxp0uqc7d8d8	44000	2026-04-16 20:46:15.359	2026-04-16 20:46:15.359
cmo1y8x1h00zbvxt0v64sfw9o	cmo1y8x0u00z3vxt0btygbkru	cmo1xc13g000svxp0tbndc1wg	44000	2026-04-16 20:46:15.365	2026-04-16 20:46:15.365
cmo1y8x1o00zdvxt008ooug11	cmo1y8x0u00z3vxt0btygbkru	cmo1xc12q000pvxp0kun82k4l	44000	2026-04-16 20:46:15.373	2026-04-16 20:46:15.373
cmo1y8x1u00zfvxt043pu5crg	cmo1y8x0u00z3vxt0btygbkru	cmo1xc138000rvxp0r16wi1bz	42000	2026-04-16 20:46:15.378	2026-04-16 20:46:15.378
cmo1y8x2200zhvxt0iqnb3zu4	cmo1y8x0u00z3vxt0btygbkru	cmo1xc12i000ovxp01nisgvnu	44000	2026-04-16 20:46:15.386	2026-04-16 20:46:15.386
cmo1y8x2800zjvxt0hdlgrsyq	cmo1y8x0u00z3vxt0btygbkru	cmo1xc13o000tvxp0alok8jeb	44000	2026-04-16 20:46:15.393	2026-04-16 20:46:15.393
cmo1y8x2g00zlvxt0mdic4dmp	cmo1y8x0u00z3vxt0btygbkru	cmo1xc11n000kvxp0g32oj3wx	47000	2026-04-16 20:46:15.4	2026-04-16 20:46:15.4
cmo1y8x2n00znvxt07dcihscl	cmo1y8x0u00z3vxt0btygbkru	cmo1xc10u000hvxp0dapryn3r	44000	2026-04-16 20:46:15.407	2026-04-16 20:46:15.407
cmo1y8x2u00zpvxt0pfp0lrzr	cmo1y8x0u00z3vxt0btygbkru	cmo1xc119000jvxp01snwxzoa	44000	2026-04-16 20:46:15.414	2026-04-16 20:46:15.414
cmo1y8x3700ztvxt0ncj81jvk	cmo1y8x3100zrvxt07m5qvex6	cmo1xsgrt0022vxv8sd7cckj7	44000	2026-04-16 20:46:15.427	2026-04-16 20:46:15.427
cmo1y8x3d00zvvxt01xeymxfi	cmo1y8x3100zrvxt07m5qvex6	cmo1xc11v000lvxp07r6uljko	44000	2026-04-16 20:46:15.433	2026-04-16 20:46:15.433
cmo1y8x3i00zxvxt0qyf9dep6	cmo1y8x3100zrvxt07m5qvex6	cmo1xc12y000qvxp0uqc7d8d8	44000	2026-04-16 20:46:15.439	2026-04-16 20:46:15.439
cmo1y8x3n00zzvxt0059p8o3q	cmo1y8x3100zrvxt07m5qvex6	cmo1xc13g000svxp0tbndc1wg	44000	2026-04-16 20:46:15.444	2026-04-16 20:46:15.444
cmo1y8x3v0101vxt0z0z5jq2v	cmo1y8x3100zrvxt07m5qvex6	cmo1xc12q000pvxp0kun82k4l	44000	2026-04-16 20:46:15.451	2026-04-16 20:46:15.451
cmo1y8x410103vxt0zkqphv18	cmo1y8x3100zrvxt07m5qvex6	cmo1xc138000rvxp0r16wi1bz	42000	2026-04-16 20:46:15.458	2026-04-16 20:46:15.458
cmo1y8x480105vxt017dl35o3	cmo1y8x3100zrvxt07m5qvex6	cmo1xc12i000ovxp01nisgvnu	44000	2026-04-16 20:46:15.464	2026-04-16 20:46:15.464
cmo1y8x4e0107vxt0vxah2ig1	cmo1y8x3100zrvxt07m5qvex6	cmo1xc13o000tvxp0alok8jeb	44000	2026-04-16 20:46:15.471	2026-04-16 20:46:15.471
cmo1y8x4k0109vxt0nmd0rnz5	cmo1y8x3100zrvxt07m5qvex6	cmo1xc11n000kvxp0g32oj3wx	47000	2026-04-16 20:46:15.477	2026-04-16 20:46:15.477
cmo1y8x4q010bvxt0jzruavcp	cmo1y8x3100zrvxt07m5qvex6	cmo1xc10u000hvxp0dapryn3r	44000	2026-04-16 20:46:15.482	2026-04-16 20:46:15.482
cmo1y8x4w010dvxt0x6jp4vtz	cmo1y8x3100zrvxt07m5qvex6	cmo1xc119000jvxp01snwxzoa	44000	2026-04-16 20:46:15.488	2026-04-16 20:46:15.488
cmo1y8x58010hvxt0v8042lli	cmo1y8x51010fvxt0q8pp70ix	cmo1xsgrt0022vxv8sd7cckj7	42000	2026-04-16 20:46:15.5	2026-04-16 20:46:15.5
cmo1y8x5f010jvxt0esttgbgk	cmo1y8x51010fvxt0q8pp70ix	cmo1xc11v000lvxp07r6uljko	42000	2026-04-16 20:46:15.507	2026-04-16 20:46:15.507
cmo1y8x5n010lvxt05qvz7ujw	cmo1y8x51010fvxt0q8pp70ix	cmo1xc12y000qvxp0uqc7d8d8	42000	2026-04-16 20:46:15.515	2026-04-16 20:46:15.515
cmo1y8x5v010nvxt0om3k3r50	cmo1y8x51010fvxt0q8pp70ix	cmo1xc13g000svxp0tbndc1wg	42000	2026-04-16 20:46:15.523	2026-04-16 20:46:15.523
cmo1y8x64010pvxt0t4pxa0nn	cmo1y8x51010fvxt0q8pp70ix	cmo1xc12q000pvxp0kun82k4l	42000	2026-04-16 20:46:15.532	2026-04-16 20:46:15.532
cmo1y8x6a010rvxt0ccimgf5k	cmo1y8x51010fvxt0q8pp70ix	cmo1xc138000rvxp0r16wi1bz	40000	2026-04-16 20:46:15.538	2026-04-16 20:46:15.538
cmo1y8x6g010tvxt0xe3uylz4	cmo1y8x51010fvxt0q8pp70ix	cmo1xc12i000ovxp01nisgvnu	42000	2026-04-16 20:46:15.544	2026-04-16 20:46:15.544
cmo1y8x6n010vvxt0d7swd5u3	cmo1y8x51010fvxt0q8pp70ix	cmo1xc13o000tvxp0alok8jeb	42000	2026-04-16 20:46:15.551	2026-04-16 20:46:15.551
cmo1y8x6v010xvxt003ig2d6a	cmo1y8x51010fvxt0q8pp70ix	cmo1xc11n000kvxp0g32oj3wx	45000	2026-04-16 20:46:15.559	2026-04-16 20:46:15.559
cmo1y8x71010zvxt0h1fgzo93	cmo1y8x51010fvxt0q8pp70ix	cmo1xc10u000hvxp0dapryn3r	42000	2026-04-16 20:46:15.566	2026-04-16 20:46:15.566
cmo1y8x780111vxt03hgsxvwp	cmo1y8x51010fvxt0q8pp70ix	cmo1xc119000jvxp01snwxzoa	42000	2026-04-16 20:46:15.573	2026-04-16 20:46:15.573
cmo1y8x7m0115vxt0hbx90xim	cmo1y8x7e0113vxt0zl8whfek	cmo1xsgrt0022vxv8sd7cckj7	25000	2026-04-16 20:46:15.586	2026-04-16 20:46:15.586
cmo1y8x7s0117vxt0p5sn1hqf	cmo1y8x7e0113vxt0zl8whfek	cmo1xc11v000lvxp07r6uljko	25000	2026-04-16 20:46:15.592	2026-04-16 20:46:15.592
cmo1y8x7y0119vxt04t92z7uj	cmo1y8x7e0113vxt0zl8whfek	cmo1xc12y000qvxp0uqc7d8d8	25000	2026-04-16 20:46:15.598	2026-04-16 20:46:15.598
cmo1y8x84011bvxt0p879qe2x	cmo1y8x7e0113vxt0zl8whfek	cmo1xc13g000svxp0tbndc1wg	25000	2026-04-16 20:46:15.605	2026-04-16 20:46:15.605
cmo1y8x8a011dvxt03d2ja14l	cmo1y8x7e0113vxt0zl8whfek	cmo1xc12q000pvxp0kun82k4l	25000	2026-04-16 20:46:15.611	2026-04-16 20:46:15.611
cmo1y8x8g011fvxt0azokrjql	cmo1y8x7e0113vxt0zl8whfek	cmo1xc138000rvxp0r16wi1bz	24000	2026-04-16 20:46:15.616	2026-04-16 20:46:15.616
cmo1y8x8m011hvxt0o8jexgy8	cmo1y8x7e0113vxt0zl8whfek	cmo1xc12i000ovxp01nisgvnu	25000	2026-04-16 20:46:15.622	2026-04-16 20:46:15.622
cmo1y8x8r011jvxt0jyie9dnr	cmo1y8x7e0113vxt0zl8whfek	cmo1xc13o000tvxp0alok8jeb	25000	2026-04-16 20:46:15.628	2026-04-16 20:46:15.628
cmo1y8x8y011lvxt074dij9cp	cmo1y8x7e0113vxt0zl8whfek	cmo1xc11n000kvxp0g32oj3wx	28000	2026-04-16 20:46:15.634	2026-04-16 20:46:15.634
cmo1y8x94011nvxt0z3dc7sji	cmo1y8x7e0113vxt0zl8whfek	cmo1xc10u000hvxp0dapryn3r	25000	2026-04-16 20:46:15.64	2026-04-16 20:46:15.64
cmo1y8x99011pvxt0iqgz2o54	cmo1y8x7e0113vxt0zl8whfek	cmo1xc119000jvxp01snwxzoa	25000	2026-04-16 20:46:15.646	2026-04-16 20:46:15.646
cmo1y8x9o011tvxt0iv9dofqj	cmo1y8x9h011rvxt0h5ymd3tk	cmo1xsgrt0022vxv8sd7cckj7	50000	2026-04-16 20:46:15.66	2026-04-16 20:46:15.66
cmo1y8x9w011vvxt0d1x3z98g	cmo1y8x9h011rvxt0h5ymd3tk	cmo1xc11v000lvxp07r6uljko	50000	2026-04-16 20:46:15.668	2026-04-16 20:46:15.668
cmo1y8xa3011xvxt0wko51yau	cmo1y8x9h011rvxt0h5ymd3tk	cmo1xc12y000qvxp0uqc7d8d8	50000	2026-04-16 20:46:15.676	2026-04-16 20:46:15.676
cmo1y8xab011zvxt0t8gvpk2b	cmo1y8x9h011rvxt0h5ymd3tk	cmo1xc13g000svxp0tbndc1wg	50000	2026-04-16 20:46:15.683	2026-04-16 20:46:15.683
cmo1y8xak0121vxt0qlj7am2b	cmo1y8x9h011rvxt0h5ymd3tk	cmo1xc12q000pvxp0kun82k4l	50000	2026-04-16 20:46:15.692	2026-04-16 20:46:15.692
cmo1y8xar0123vxt05p2c3fn2	cmo1y8x9h011rvxt0h5ymd3tk	cmo1xc138000rvxp0r16wi1bz	45000	2026-04-16 20:46:15.699	2026-04-16 20:46:15.699
cmo1y8xay0125vxt0mha1z92q	cmo1y8x9h011rvxt0h5ymd3tk	cmo1xc12i000ovxp01nisgvnu	50000	2026-04-16 20:46:15.706	2026-04-16 20:46:15.706
cmo1y8xb70127vxt0gzqw8q1q	cmo1y8x9h011rvxt0h5ymd3tk	cmo1xc13o000tvxp0alok8jeb	50000	2026-04-16 20:46:15.715	2026-04-16 20:46:15.715
cmo1y8xbl0129vxt062u5gsxs	cmo1y8x9h011rvxt0h5ymd3tk	cmo1xc11n000kvxp0g32oj3wx	53000	2026-04-16 20:46:15.729	2026-04-16 20:46:15.729
cmo1y8xc1012bvxt078l6dypx	cmo1y8x9h011rvxt0h5ymd3tk	cmo1xc10u000hvxp0dapryn3r	50000	2026-04-16 20:46:15.745	2026-04-16 20:46:15.745
cmo1y8xcy012dvxt0th2ahk9t	cmo1y8x9h011rvxt0h5ymd3tk	cmo1xc119000jvxp01snwxzoa	50000	2026-04-16 20:46:15.778	2026-04-16 20:46:15.778
cmo1y8xdn012hvxt00z9ut65p	cmo1y8xd7012fvxt0da1f3l79	cmo1xsgrt0022vxv8sd7cckj7	45000	2026-04-16 20:46:15.803	2026-04-16 20:46:15.803
cmo1y8xdw012jvxt0rrqvnmpi	cmo1y8xd7012fvxt0da1f3l79	cmo1xc11v000lvxp07r6uljko	45000	2026-04-16 20:46:15.812	2026-04-16 20:46:15.812
cmo1y8xe9012lvxt0267oesno	cmo1y8xd7012fvxt0da1f3l79	cmo1xc12y000qvxp0uqc7d8d8	48000	2026-04-16 20:46:15.825	2026-04-16 20:46:15.825
cmo1y8xeg012nvxt059lifz5j	cmo1y8xd7012fvxt0da1f3l79	cmo1xc13g000svxp0tbndc1wg	45000	2026-04-16 20:46:15.833	2026-04-16 20:46:15.833
cmo1y8xeq012pvxt0yqciolu4	cmo1y8xd7012fvxt0da1f3l79	cmo1xc12q000pvxp0kun82k4l	37000	2026-04-16 20:46:15.842	2026-04-16 20:46:15.842
cmo1y8xez012rvxt0tr04ykiy	cmo1y8xd7012fvxt0da1f3l79	cmo1xc12i000ovxp01nisgvnu	45000	2026-04-16 20:46:15.851	2026-04-16 20:46:15.851
cmo1y8xf7012tvxt0zf6hnzei	cmo1y8xd7012fvxt0da1f3l79	cmo1xc13o000tvxp0alok8jeb	45000	2026-04-16 20:46:15.859	2026-04-16 20:46:15.859
cmo1y8xfh012vvxt0hjtvnls1	cmo1y8xd7012fvxt0da1f3l79	cmo1xc11n000kvxp0g32oj3wx	48000	2026-04-16 20:46:15.869	2026-04-16 20:46:15.869
cmo1y8xfw012xvxt05ii8jzrz	cmo1y8xd7012fvxt0da1f3l79	cmo1xc10u000hvxp0dapryn3r	45000	2026-04-16 20:46:15.884	2026-04-16 20:46:15.884
cmo1y8xg7012zvxt0za2n8mrw	cmo1y8xd7012fvxt0da1f3l79	cmo1xc119000jvxp01snwxzoa	45000	2026-04-16 20:46:15.895	2026-04-16 20:46:15.895
cmo1y8xgv0133vxt0f95g4tkx	cmo1y8xgm0131vxt0mnesxbzq	cmo1xsgrt0022vxv8sd7cckj7	45000	2026-04-16 20:46:15.919	2026-04-16 20:46:15.919
cmo1y8xh40135vxt0lbdss3qh	cmo1y8xgm0131vxt0mnesxbzq	cmo1xc11v000lvxp07r6uljko	45000	2026-04-16 20:46:15.928	2026-04-16 20:46:15.928
cmo1y8xhc0137vxt0b9w3kzyr	cmo1y8xgm0131vxt0mnesxbzq	cmo1xc12y000qvxp0uqc7d8d8	48000	2026-04-16 20:46:15.936	2026-04-16 20:46:15.936
cmo1y8xhk0139vxt0n6ibgikd	cmo1y8xgm0131vxt0mnesxbzq	cmo1xc13g000svxp0tbndc1wg	45000	2026-04-16 20:46:15.944	2026-04-16 20:46:15.944
cmo1y8xhx013bvxt0tqq6ui0d	cmo1y8xgm0131vxt0mnesxbzq	cmo1xc12q000pvxp0kun82k4l	37000	2026-04-16 20:46:15.957	2026-04-16 20:46:15.957
cmo1y8xia013dvxt0ywcps379	cmo1y8xgm0131vxt0mnesxbzq	cmo1xc12i000ovxp01nisgvnu	45000	2026-04-16 20:46:15.97	2026-04-16 20:46:15.97
cmo1y8xii013fvxt0msb7s73l	cmo1y8xgm0131vxt0mnesxbzq	cmo1xc13o000tvxp0alok8jeb	45000	2026-04-16 20:46:15.978	2026-04-16 20:46:15.978
cmo1y8xiw013hvxt0qgjyv74t	cmo1y8xgm0131vxt0mnesxbzq	cmo1xc11n000kvxp0g32oj3wx	48000	2026-04-16 20:46:15.993	2026-04-16 20:46:15.993
cmo1y8xj3013jvxt0brbqyttt	cmo1y8xgm0131vxt0mnesxbzq	cmo1xc10u000hvxp0dapryn3r	45000	2026-04-16 20:46:15.999	2026-04-16 20:46:15.999
cmo1y8xjf013lvxt0zicge8b7	cmo1y8xgm0131vxt0mnesxbzq	cmo1xc119000jvxp01snwxzoa	45000	2026-04-16 20:46:16.012	2026-04-16 20:46:16.012
cmo1y8xk8013pvxt0axd1zs2k	cmo1y8xjs013nvxt0xw4wzeyz	cmo1xsgrt0022vxv8sd7cckj7	45000	2026-04-16 20:46:16.041	2026-04-16 20:46:16.041
cmo1y8xkh013rvxt0jav8lcj1	cmo1y8xjs013nvxt0xw4wzeyz	cmo1xc11v000lvxp07r6uljko	45000	2026-04-16 20:46:16.049	2026-04-16 20:46:16.049
cmo1y8xko013tvxt0blctj5cq	cmo1y8xjs013nvxt0xw4wzeyz	cmo1xc12y000qvxp0uqc7d8d8	48000	2026-04-16 20:46:16.056	2026-04-16 20:46:16.056
cmo1y8xkt013vvxt0qx9cxyp2	cmo1y8xjs013nvxt0xw4wzeyz	cmo1xc13g000svxp0tbndc1wg	45000	2026-04-16 20:46:16.062	2026-04-16 20:46:16.062
cmo1y8xl2013xvxt082vuf7dh	cmo1y8xjs013nvxt0xw4wzeyz	cmo1xc12q000pvxp0kun82k4l	37000	2026-04-16 20:46:16.07	2026-04-16 20:46:16.07
cmo1y8xl9013zvxt0xjnoas69	cmo1y8xjs013nvxt0xw4wzeyz	cmo1xc12i000ovxp01nisgvnu	45000	2026-04-16 20:46:16.078	2026-04-16 20:46:16.078
cmo1y8xlh0141vxt0z1xl6df9	cmo1y8xjs013nvxt0xw4wzeyz	cmo1xc13o000tvxp0alok8jeb	45000	2026-04-16 20:46:16.085	2026-04-16 20:46:16.085
cmo1y8xlo0143vxt0t1hmmvv6	cmo1y8xjs013nvxt0xw4wzeyz	cmo1xc11n000kvxp0g32oj3wx	48000	2026-04-16 20:46:16.093	2026-04-16 20:46:16.093
cmo1y8xlv0145vxt0l2yitwim	cmo1y8xjs013nvxt0xw4wzeyz	cmo1xc10u000hvxp0dapryn3r	45000	2026-04-16 20:46:16.1	2026-04-16 20:46:16.1
cmo1y8xm20147vxt03n20q7rj	cmo1y8xjs013nvxt0xw4wzeyz	cmo1xc119000jvxp01snwxzoa	45000	2026-04-16 20:46:16.106	2026-04-16 20:46:16.106
cmo1y8xmg014bvxt0k14yuzqi	cmo1y8xm80149vxt03hh8ej4j	cmo1xsgrt0022vxv8sd7cckj7	45000	2026-04-16 20:46:16.12	2026-04-16 20:46:16.12
cmo1y8xmt014dvxt0u6y9f00i	cmo1y8xm80149vxt03hh8ej4j	cmo1xc11v000lvxp07r6uljko	45000	2026-04-16 20:46:16.134	2026-04-16 20:46:16.134
cmo1y8xn0014fvxt07vxf5aak	cmo1y8xm80149vxt03hh8ej4j	cmo1xc12y000qvxp0uqc7d8d8	48000	2026-04-16 20:46:16.14	2026-04-16 20:46:16.14
cmo1y8xn6014hvxt0yfjfj346	cmo1y8xm80149vxt03hh8ej4j	cmo1xc13g000svxp0tbndc1wg	45000	2026-04-16 20:46:16.146	2026-04-16 20:46:16.146
cmo1y8xne014jvxt072b6408c	cmo1y8xm80149vxt03hh8ej4j	cmo1xc12q000pvxp0kun82k4l	37000	2026-04-16 20:46:16.154	2026-04-16 20:46:16.154
cmo1y8xnk014lvxt0okvd6ahs	cmo1y8xm80149vxt03hh8ej4j	cmo1xc12i000ovxp01nisgvnu	45000	2026-04-16 20:46:16.161	2026-04-16 20:46:16.161
cmo1y8xnr014nvxt0zg9d86ww	cmo1y8xm80149vxt03hh8ej4j	cmo1xc13o000tvxp0alok8jeb	45000	2026-04-16 20:46:16.167	2026-04-16 20:46:16.167
cmo1y8xnz014pvxt06s3bl22v	cmo1y8xm80149vxt03hh8ej4j	cmo1xc11n000kvxp0g32oj3wx	48000	2026-04-16 20:46:16.175	2026-04-16 20:46:16.175
cmo1y8xo5014rvxt0klz5ytrb	cmo1y8xm80149vxt03hh8ej4j	cmo1xc10u000hvxp0dapryn3r	45000	2026-04-16 20:46:16.181	2026-04-16 20:46:16.181
cmo1y8xoa014tvxt0cn6jheep	cmo1y8xm80149vxt03hh8ej4j	cmo1xc119000jvxp01snwxzoa	45000	2026-04-16 20:46:16.186	2026-04-16 20:46:16.186
cmo1y8xoj014xvxt0sakkl4i3	cmo1y8xoe014vvxt0bkay8nc7	cmo1xsgrt0022vxv8sd7cckj7	45000	2026-04-16 20:46:16.196	2026-04-16 20:46:16.196
cmo1y8xoq014zvxt0y6k98ud8	cmo1y8xoe014vvxt0bkay8nc7	cmo1xc11v000lvxp07r6uljko	45000	2026-04-16 20:46:16.202	2026-04-16 20:46:16.202
cmo1y8xov0151vxt02witieom	cmo1y8xoe014vvxt0bkay8nc7	cmo1xc12y000qvxp0uqc7d8d8	48000	2026-04-16 20:46:16.208	2026-04-16 20:46:16.208
cmo1y8xp10153vxt08nk8zcwz	cmo1y8xoe014vvxt0bkay8nc7	cmo1xc13g000svxp0tbndc1wg	45000	2026-04-16 20:46:16.213	2026-04-16 20:46:16.213
cmo1y8xpa0155vxt0s8ta7mmj	cmo1y8xoe014vvxt0bkay8nc7	cmo1xc12q000pvxp0kun82k4l	37000	2026-04-16 20:46:16.222	2026-04-16 20:46:16.222
cmo1y8xph0157vxt0e5nj63ac	cmo1y8xoe014vvxt0bkay8nc7	cmo1xc12i000ovxp01nisgvnu	45000	2026-04-16 20:46:16.23	2026-04-16 20:46:16.23
cmo1y8xpn0159vxt0vi8n1kuh	cmo1y8xoe014vvxt0bkay8nc7	cmo1xc13o000tvxp0alok8jeb	45000	2026-04-16 20:46:16.236	2026-04-16 20:46:16.236
cmo1y8xpt015bvxt0x6gywqbn	cmo1y8xoe014vvxt0bkay8nc7	cmo1xc11n000kvxp0g32oj3wx	48000	2026-04-16 20:46:16.242	2026-04-16 20:46:16.242
cmo1y8xpz015dvxt0j67oe3ss	cmo1y8xoe014vvxt0bkay8nc7	cmo1xc10u000hvxp0dapryn3r	45000	2026-04-16 20:46:16.247	2026-04-16 20:46:16.247
cmo1y8xq4015fvxt0jhyr2ri8	cmo1y8xoe014vvxt0bkay8nc7	cmo1xc119000jvxp01snwxzoa	45000	2026-04-16 20:46:16.252	2026-04-16 20:46:16.252
cmo1y8xqh015jvxt0hftvzqk0	cmo1y8xq9015hvxt07plyla5p	cmo1xsgrt0022vxv8sd7cckj7	45000	2026-04-16 20:46:16.265	2026-04-16 20:46:16.265
cmo1y8xqp015lvxt0uoajmlwp	cmo1y8xq9015hvxt07plyla5p	cmo1xc11v000lvxp07r6uljko	45000	2026-04-16 20:46:16.273	2026-04-16 20:46:16.273
cmo1y8xr9015nvxt04y9zmm7p	cmo1y8xq9015hvxt07plyla5p	cmo1xc12y000qvxp0uqc7d8d8	48000	2026-04-16 20:46:16.293	2026-04-16 20:46:16.293
cmo1y8xrv015pvxt053saujs6	cmo1y8xq9015hvxt07plyla5p	cmo1xc13g000svxp0tbndc1wg	45000	2026-04-16 20:46:16.315	2026-04-16 20:46:16.315
cmo1y8xs6015rvxt0jfsorox3	cmo1y8xq9015hvxt07plyla5p	cmo1xc12q000pvxp0kun82k4l	37000	2026-04-16 20:46:16.326	2026-04-16 20:46:16.326
cmo1y8xsd015tvxt053bx3osu	cmo1y8xq9015hvxt07plyla5p	cmo1xc12i000ovxp01nisgvnu	45000	2026-04-16 20:46:16.333	2026-04-16 20:46:16.333
cmo1y8xsj015vvxt009yq2hno	cmo1y8xq9015hvxt07plyla5p	cmo1xc13o000tvxp0alok8jeb	45000	2026-04-16 20:46:16.339	2026-04-16 20:46:16.339
cmo1y8xsp015xvxt0kd8l2jt0	cmo1y8xq9015hvxt07plyla5p	cmo1xc11n000kvxp0g32oj3wx	48000	2026-04-16 20:46:16.346	2026-04-16 20:46:16.346
cmo1y8xsv015zvxt09ls6l1dq	cmo1y8xq9015hvxt07plyla5p	cmo1xc10u000hvxp0dapryn3r	45000	2026-04-16 20:46:16.351	2026-04-16 20:46:16.351
cmo1y8xt00161vxt0wrny85s1	cmo1y8xq9015hvxt07plyla5p	cmo1xc119000jvxp01snwxzoa	45000	2026-04-16 20:46:16.356	2026-04-16 20:46:16.356
cmo1y8xta0165vxt0ei7wbjzd	cmo1y8xt50163vxt091krdi4l	cmo1xsgrt0022vxv8sd7cckj7	45000	2026-04-16 20:46:16.367	2026-04-16 20:46:16.367
cmo1y8xtf0167vxt01zodczym	cmo1y8xt50163vxt091krdi4l	cmo1xc11v000lvxp07r6uljko	45000	2026-04-16 20:46:16.371	2026-04-16 20:46:16.371
cmo1y8xtk0169vxt0zkv4rumx	cmo1y8xt50163vxt091krdi4l	cmo1xc12y000qvxp0uqc7d8d8	48000	2026-04-16 20:46:16.376	2026-04-16 20:46:16.376
cmo1y8xtp016bvxt0wjbpe5j4	cmo1y8xt50163vxt091krdi4l	cmo1xc13g000svxp0tbndc1wg	45000	2026-04-16 20:46:16.381	2026-04-16 20:46:16.381
cmo1y8xtv016dvxt0tkrto2pf	cmo1y8xt50163vxt091krdi4l	cmo1xc12q000pvxp0kun82k4l	45000	2026-04-16 20:46:16.387	2026-04-16 20:46:16.387
cmo1y8xu1016fvxt0g9iugrck	cmo1y8xt50163vxt091krdi4l	cmo1xc12i000ovxp01nisgvnu	45000	2026-04-16 20:46:16.394	2026-04-16 20:46:16.394
cmo1y8xu7016hvxt08mj5hq5p	cmo1y8xt50163vxt091krdi4l	cmo1xc13o000tvxp0alok8jeb	45000	2026-04-16 20:46:16.399	2026-04-16 20:46:16.399
cmo1y8xuc016jvxt0j2j3jbw5	cmo1y8xt50163vxt091krdi4l	cmo1xc11n000kvxp0g32oj3wx	48000	2026-04-16 20:46:16.405	2026-04-16 20:46:16.405
cmo1y8xuh016lvxt035dunzxp	cmo1y8xt50163vxt091krdi4l	cmo1xc10u000hvxp0dapryn3r	45000	2026-04-16 20:46:16.409	2026-04-16 20:46:16.409
cmo1y8xun016nvxt0qdxuqqvt	cmo1y8xt50163vxt091krdi4l	cmo1xc119000jvxp01snwxzoa	45000	2026-04-16 20:46:16.415	2026-04-16 20:46:16.415
cmo1y8xuy016rvxt0ggnlgay6	cmo1y8xus016pvxt05orr4o7i	cmo1xsgrt0022vxv8sd7cckj7	45000	2026-04-16 20:46:16.426	2026-04-16 20:46:16.426
cmo1y8xv3016tvxt0ds2zeup1	cmo1y8xus016pvxt05orr4o7i	cmo1xc11v000lvxp07r6uljko	45000	2026-04-16 20:46:16.431	2026-04-16 20:46:16.431
cmo1y8xv9016vvxt0rawmfreo	cmo1y8xus016pvxt05orr4o7i	cmo1xc12y000qvxp0uqc7d8d8	48000	2026-04-16 20:46:16.437	2026-04-16 20:46:16.437
cmo1y8xve016xvxt0fw0wpg59	cmo1y8xus016pvxt05orr4o7i	cmo1xc13g000svxp0tbndc1wg	37000	2026-04-16 20:46:16.442	2026-04-16 20:46:16.442
cmo1y8xvl016zvxt0rzuue52f	cmo1y8xus016pvxt05orr4o7i	cmo1xc12q000pvxp0kun82k4l	37000	2026-04-16 20:46:16.45	2026-04-16 20:46:16.45
cmo1y8xvt0171vxt0hacnmsmv	cmo1y8xus016pvxt05orr4o7i	cmo1xc12i000ovxp01nisgvnu	45000	2026-04-16 20:46:16.458	2026-04-16 20:46:16.458
cmo1y8xw00173vxt0bba17pso	cmo1y8xus016pvxt05orr4o7i	cmo1xc13o000tvxp0alok8jeb	45000	2026-04-16 20:46:16.464	2026-04-16 20:46:16.464
cmo1y8xw70175vxt02p3qugqe	cmo1y8xus016pvxt05orr4o7i	cmo1xc11n000kvxp0g32oj3wx	48000	2026-04-16 20:46:16.471	2026-04-16 20:46:16.471
cmo1y8xwd0177vxt0b8fjbpmo	cmo1y8xus016pvxt05orr4o7i	cmo1xc10u000hvxp0dapryn3r	45000	2026-04-16 20:46:16.477	2026-04-16 20:46:16.477
cmo1y8xwi0179vxt0uo3hv5qg	cmo1y8xus016pvxt05orr4o7i	cmo1xc119000jvxp01snwxzoa	45000	2026-04-16 20:46:16.483	2026-04-16 20:46:16.483
cmo1y8xwt017dvxt0u0nv55ga	cmo1y8xwo017bvxt0o96cx10e	cmo1xsgrt0022vxv8sd7cckj7	45000	2026-04-16 20:46:16.493	2026-04-16 20:46:16.493
cmo1y8xwz017fvxt0ovz5duxi	cmo1y8xwo017bvxt0o96cx10e	cmo1xc11v000lvxp07r6uljko	45000	2026-04-16 20:46:16.499	2026-04-16 20:46:16.499
cmo1y8xx4017hvxt03w3yepyl	cmo1y8xwo017bvxt0o96cx10e	cmo1xc12y000qvxp0uqc7d8d8	48000	2026-04-16 20:46:16.504	2026-04-16 20:46:16.504
cmo1y8xx9017jvxt0lng9ipds	cmo1y8xwo017bvxt0o96cx10e	cmo1xc13g000svxp0tbndc1wg	45000	2026-04-16 20:46:16.51	2026-04-16 20:46:16.51
cmo1y8xxh017lvxt0n8q1lxid	cmo1y8xwo017bvxt0o96cx10e	cmo1xc12q000pvxp0kun82k4l	37000	2026-04-16 20:46:16.517	2026-04-16 20:46:16.517
cmo1y8xxp017nvxt0ktuyax90	cmo1y8xwo017bvxt0o96cx10e	cmo1xc12i000ovxp01nisgvnu	45000	2026-04-16 20:46:16.526	2026-04-16 20:46:16.526
cmo1y8xxv017pvxt0amc2ci0e	cmo1y8xwo017bvxt0o96cx10e	cmo1xc13o000tvxp0alok8jeb	45000	2026-04-16 20:46:16.532	2026-04-16 20:46:16.532
cmo1y8xy2017rvxt0tdxm2oku	cmo1y8xwo017bvxt0o96cx10e	cmo1xc11n000kvxp0g32oj3wx	48000	2026-04-16 20:46:16.538	2026-04-16 20:46:16.538
cmo1y8xy7017tvxt0fudd7qhl	cmo1y8xwo017bvxt0o96cx10e	cmo1xc10u000hvxp0dapryn3r	45000	2026-04-16 20:46:16.543	2026-04-16 20:46:16.543
cmo1y8xyc017vvxt0b1gmq0cv	cmo1y8xwo017bvxt0o96cx10e	cmo1xc119000jvxp01snwxzoa	45000	2026-04-16 20:46:16.549	2026-04-16 20:46:16.549
cmo1y8xyn017zvxt0regyie21	cmo1y8xyi017xvxt0h6w860e1	cmo1xsgrt0022vxv8sd7cckj7	45000	2026-04-16 20:46:16.56	2026-04-16 20:46:16.56
cmo1y8xyt0181vxt0ao6nde7m	cmo1y8xyi017xvxt0h6w860e1	cmo1xc11v000lvxp07r6uljko	45000	2026-04-16 20:46:16.565	2026-04-16 20:46:16.565
cmo1y8xyz0183vxt0p8a19u2z	cmo1y8xyi017xvxt0h6w860e1	cmo1xc12y000qvxp0uqc7d8d8	48000	2026-04-16 20:46:16.571	2026-04-16 20:46:16.571
cmo1y8xz40185vxt0l1386602	cmo1y8xyi017xvxt0h6w860e1	cmo1xc13g000svxp0tbndc1wg	45000	2026-04-16 20:46:16.576	2026-04-16 20:46:16.576
cmo1y8xzb0187vxt080nq3qv4	cmo1y8xyi017xvxt0h6w860e1	cmo1xc12q000pvxp0kun82k4l	37000	2026-04-16 20:46:16.583	2026-04-16 20:46:16.583
cmo1y8xzi0189vxt0036uhjtv	cmo1y8xyi017xvxt0h6w860e1	cmo1xc12i000ovxp01nisgvnu	45000	2026-04-16 20:46:16.59	2026-04-16 20:46:16.59
cmo1y8xzn018bvxt02de29rxv	cmo1y8xyi017xvxt0h6w860e1	cmo1xc13o000tvxp0alok8jeb	45000	2026-04-16 20:46:16.595	2026-04-16 20:46:16.595
cmo1y8xzt018dvxt0dywm7akh	cmo1y8xyi017xvxt0h6w860e1	cmo1xc11n000kvxp0g32oj3wx	48000	2026-04-16 20:46:16.602	2026-04-16 20:46:16.602
cmo1y8xzy018fvxt0hk8u0n5i	cmo1y8xyi017xvxt0h6w860e1	cmo1xc10u000hvxp0dapryn3r	45000	2026-04-16 20:46:16.607	2026-04-16 20:46:16.607
cmo1y8y04018hvxt02q88704r	cmo1y8xyi017xvxt0h6w860e1	cmo1xc119000jvxp01snwxzoa	45000	2026-04-16 20:46:16.612	2026-04-16 20:46:16.612
cmo1y8y0f018lvxt0myh76ykm	cmo1y8y09018jvxt02lu075nd	cmo1xsgrt0022vxv8sd7cckj7	60000	2026-04-16 20:46:16.624	2026-04-16 20:46:16.624
cmo1y8y0l018nvxt027rccxff	cmo1y8y09018jvxt02lu075nd	cmo1xc11v000lvxp07r6uljko	60000	2026-04-16 20:46:16.629	2026-04-16 20:46:16.629
cmo1y8y0r018pvxt0n9wxn4n9	cmo1y8y09018jvxt02lu075nd	cmo1xc12y000qvxp0uqc7d8d8	63000	2026-04-16 20:46:16.635	2026-04-16 20:46:16.635
cmo1y8y0w018rvxt0xbvugq61	cmo1y8y09018jvxt02lu075nd	cmo1xc13g000svxp0tbndc1wg	60000	2026-04-16 20:46:16.64	2026-04-16 20:46:16.64
cmo1y8y13018tvxt0mbh6v33x	cmo1y8y09018jvxt02lu075nd	cmo1xc12q000pvxp0kun82k4l	60000	2026-04-16 20:46:16.647	2026-04-16 20:46:16.647
cmo1y8y1a018vvxt0ao2cvyz1	cmo1y8y09018jvxt02lu075nd	cmo1xc12i000ovxp01nisgvnu	60000	2026-04-16 20:46:16.655	2026-04-16 20:46:16.655
cmo1y8y1g018xvxt0ogngmfqt	cmo1y8y09018jvxt02lu075nd	cmo1xc13o000tvxp0alok8jeb	60000	2026-04-16 20:46:16.66	2026-04-16 20:46:16.66
cmo1y8y1n018zvxt0w0isdzr6	cmo1y8y09018jvxt02lu075nd	cmo1xc11n000kvxp0g32oj3wx	63000	2026-04-16 20:46:16.667	2026-04-16 20:46:16.667
cmo1y8y1s0191vxt0bvu4j1ou	cmo1y8y09018jvxt02lu075nd	cmo1xc10u000hvxp0dapryn3r	60000	2026-04-16 20:46:16.672	2026-04-16 20:46:16.672
cmo1y8y1x0193vxt0nbz36adu	cmo1y8y09018jvxt02lu075nd	cmo1xc119000jvxp01snwxzoa	60000	2026-04-16 20:46:16.678	2026-04-16 20:46:16.678
cmo1y8y280197vxt0r8qptbl8	cmo1y8y230195vxt0r5y4nvra	cmo1xsgrt0022vxv8sd7cckj7	60000	2026-04-16 20:46:16.689	2026-04-16 20:46:16.689
cmo1y8y2d0199vxt0why8czng	cmo1y8y230195vxt0r5y4nvra	cmo1xc11v000lvxp07r6uljko	60000	2026-04-16 20:46:16.694	2026-04-16 20:46:16.694
cmo1y8y2j019bvxt0vxob1cze	cmo1y8y230195vxt0r5y4nvra	cmo1xc12y000qvxp0uqc7d8d8	63000	2026-04-16 20:46:16.699	2026-04-16 20:46:16.699
cmo1y8y2o019dvxt0vf3u4yjb	cmo1y8y230195vxt0r5y4nvra	cmo1xc13g000svxp0tbndc1wg	60000	2026-04-16 20:46:16.704	2026-04-16 20:46:16.704
cmo1y8y2u019fvxt0heqd1x5d	cmo1y8y230195vxt0r5y4nvra	cmo1xc12q000pvxp0kun82k4l	43000	2026-04-16 20:46:16.711	2026-04-16 20:46:16.711
cmo1y8y31019hvxt0zqrgqkx7	cmo1y8y230195vxt0r5y4nvra	cmo1xc12i000ovxp01nisgvnu	60000	2026-04-16 20:46:16.718	2026-04-16 20:46:16.718
cmo1y8y36019jvxt0hx220pe4	cmo1y8y230195vxt0r5y4nvra	cmo1xc13o000tvxp0alok8jeb	60000	2026-04-16 20:46:16.723	2026-04-16 20:46:16.723
cmo1y8y3d019lvxt0izl6nuba	cmo1y8y230195vxt0r5y4nvra	cmo1xc11n000kvxp0g32oj3wx	63000	2026-04-16 20:46:16.729	2026-04-16 20:46:16.729
cmo1y8y3j019nvxt0cqx6nu35	cmo1y8y230195vxt0r5y4nvra	cmo1xc10u000hvxp0dapryn3r	60000	2026-04-16 20:46:16.735	2026-04-16 20:46:16.735
cmo1y8y3r019pvxt01yqkozmn	cmo1y8y230195vxt0r5y4nvra	cmo1xc119000jvxp01snwxzoa	60000	2026-04-16 20:46:16.743	2026-04-16 20:46:16.743
cmo1y8y42019tvxt0ren9tjjf	cmo1y8y3x019rvxt05g6rmw49	cmo1xsgrt0022vxv8sd7cckj7	65000	2026-04-16 20:46:16.755	2026-04-16 20:46:16.755
cmo1y8y48019vvxt049u2xeh6	cmo1y8y3x019rvxt05g6rmw49	cmo1xc11v000lvxp07r6uljko	65000	2026-04-16 20:46:16.76	2026-04-16 20:46:16.76
cmo1y8y4e019xvxt0udaj95v0	cmo1y8y3x019rvxt05g6rmw49	cmo1xc12y000qvxp0uqc7d8d8	68000	2026-04-16 20:46:16.766	2026-04-16 20:46:16.766
cmo1y8y4k019zvxt08c6z83et	cmo1y8y3x019rvxt05g6rmw49	cmo1xc13g000svxp0tbndc1wg	65000	2026-04-16 20:46:16.772	2026-04-16 20:46:16.772
cmo1y8y4s01a1vxt0ziajb54t	cmo1y8y3x019rvxt05g6rmw49	cmo1xc12q000pvxp0kun82k4l	60000	2026-04-16 20:46:16.78	2026-04-16 20:46:16.78
cmo1y8y4z01a3vxt06omyg8dz	cmo1y8y3x019rvxt05g6rmw49	cmo1xc12i000ovxp01nisgvnu	65000	2026-04-16 20:46:16.787	2026-04-16 20:46:16.787
cmo1y8y5401a5vxt0s1tzalts	cmo1y8y3x019rvxt05g6rmw49	cmo1xc13o000tvxp0alok8jeb	65000	2026-04-16 20:46:16.793	2026-04-16 20:46:16.793
cmo1y8y5b01a7vxt0lzu1e768	cmo1y8y3x019rvxt05g6rmw49	cmo1xc11n000kvxp0g32oj3wx	68000	2026-04-16 20:46:16.799	2026-04-16 20:46:16.799
cmo1y8y5g01a9vxt0miv5mcoo	cmo1y8y3x019rvxt05g6rmw49	cmo1xc10u000hvxp0dapryn3r	65000	2026-04-16 20:46:16.805	2026-04-16 20:46:16.805
cmo1y8y5l01abvxt0gbhuxosd	cmo1y8y3x019rvxt05g6rmw49	cmo1xc119000jvxp01snwxzoa	65000	2026-04-16 20:46:16.81	2026-04-16 20:46:16.81
cmo1y8y5v01afvxt09kok54od	cmo1y8y5q01advxt0rcpqr6j7	cmo1xsgrt0022vxv8sd7cckj7	70000	2026-04-16 20:46:16.82	2026-04-16 20:46:16.82
cmo1y8y6001ahvxt066mz7xuv	cmo1y8y5q01advxt0rcpqr6j7	cmo1xc11v000lvxp07r6uljko	70000	2026-04-16 20:46:16.825	2026-04-16 20:46:16.825
cmo1y8y6601ajvxt0ldxf3olr	cmo1y8y5q01advxt0rcpqr6j7	cmo1xc12y000qvxp0uqc7d8d8	70000	2026-04-16 20:46:16.831	2026-04-16 20:46:16.831
cmo1y8y6d01alvxt0syhf9oyc	cmo1y8y5q01advxt0rcpqr6j7	cmo1xc13g000svxp0tbndc1wg	70000	2026-04-16 20:46:16.838	2026-04-16 20:46:16.838
cmo1y8y6l01anvxt0tzvufe35	cmo1y8y5q01advxt0rcpqr6j7	cmo1xc12q000pvxp0kun82k4l	70000	2026-04-16 20:46:16.845	2026-04-16 20:46:16.845
cmo1y8y6s01apvxt0kmhvne54	cmo1y8y5q01advxt0rcpqr6j7	cmo1xc138000rvxp0r16wi1bz	70000	2026-04-16 20:46:16.852	2026-04-16 20:46:16.852
cmo1y8y6y01arvxt05vs3b94n	cmo1y8y5q01advxt0rcpqr6j7	cmo1xc12i000ovxp01nisgvnu	70000	2026-04-16 20:46:16.859	2026-04-16 20:46:16.859
cmo1y8y7501atvxt0hddff6om	cmo1y8y5q01advxt0rcpqr6j7	cmo1xc13o000tvxp0alok8jeb	70000	2026-04-16 20:46:16.865	2026-04-16 20:46:16.865
cmo1y8y7c01avvxt0eazvdcjg	cmo1y8y5q01advxt0rcpqr6j7	cmo1xc123000mvxp0ul7pkio2	52000	2026-04-16 20:46:16.872	2026-04-16 20:46:16.872
cmo1y8y7i01axvxt0w3fyixsr	cmo1y8y5q01advxt0rcpqr6j7	cmo1xc11n000kvxp0g32oj3wx	70000	2026-04-16 20:46:16.878	2026-04-16 20:46:16.878
cmo1y8y7o01azvxt0w9q7jo9q	cmo1y8y5q01advxt0rcpqr6j7	cmo1xc10u000hvxp0dapryn3r	70000	2026-04-16 20:46:16.885	2026-04-16 20:46:16.885
cmo1y8y7v01b1vxt0xeuu710d	cmo1y8y5q01advxt0rcpqr6j7	cmo1xc119000jvxp01snwxzoa	70000	2026-04-16 20:46:16.891	2026-04-16 20:46:16.891
cmo1y8y8b01b5vxt06ximsihd	cmo1y8y8201b3vxt007da8tl5	cmo1xsgrt0022vxv8sd7cckj7	70000	2026-04-16 20:46:16.907	2026-04-16 20:46:16.907
cmo1y8y8i01b7vxt04kla5rkr	cmo1y8y8201b3vxt007da8tl5	cmo1xc11v000lvxp07r6uljko	70000	2026-04-16 20:46:16.915	2026-04-16 20:46:16.915
cmo1y8y8p01b9vxt0d1ujttka	cmo1y8y8201b3vxt007da8tl5	cmo1xc12y000qvxp0uqc7d8d8	70000	2026-04-16 20:46:16.922	2026-04-16 20:46:16.922
cmo1y8y8w01bbvxt053h7qk27	cmo1y8y8201b3vxt007da8tl5	cmo1xc13g000svxp0tbndc1wg	70000	2026-04-16 20:46:16.928	2026-04-16 20:46:16.928
cmo1y8y9401bdvxt03lxe2jer	cmo1y8y8201b3vxt007da8tl5	cmo1xc12q000pvxp0kun82k4l	70000	2026-04-16 20:46:16.937	2026-04-16 20:46:16.937
cmo1y8y9a01bfvxt05rijvcw4	cmo1y8y8201b3vxt007da8tl5	cmo1xc138000rvxp0r16wi1bz	70000	2026-04-16 20:46:16.943	2026-04-16 20:46:16.943
cmo1y8y9h01bhvxt0io0tfnm1	cmo1y8y8201b3vxt007da8tl5	cmo1xc12i000ovxp01nisgvnu	70000	2026-04-16 20:46:16.949	2026-04-16 20:46:16.949
cmo1y8y9p01bjvxt0ibnod1up	cmo1y8y8201b3vxt007da8tl5	cmo1xc13o000tvxp0alok8jeb	70000	2026-04-16 20:46:16.957	2026-04-16 20:46:16.957
cmo1y8ya001blvxt0wo3u4fms	cmo1y8y8201b3vxt007da8tl5	cmo1xc123000mvxp0ul7pkio2	52000	2026-04-16 20:46:16.969	2026-04-16 20:46:16.969
cmo1y8ya801bnvxt0fw7p0b9o	cmo1y8y8201b3vxt007da8tl5	cmo1xc11n000kvxp0g32oj3wx	70000	2026-04-16 20:46:16.976	2026-04-16 20:46:16.976
cmo1y8yae01bpvxt0vguuc6ut	cmo1y8y8201b3vxt007da8tl5	cmo1xc10u000hvxp0dapryn3r	70000	2026-04-16 20:46:16.983	2026-04-16 20:46:16.983
cmo1y8yal01brvxt0y72ac5wk	cmo1y8y8201b3vxt007da8tl5	cmo1xc119000jvxp01snwxzoa	70000	2026-04-16 20:46:16.989	2026-04-16 20:46:16.989
cmo1y8yaw01bvvxt05nvuqphp	cmo1y8yaq01btvxt0myy9zubs	cmo1xsgrt0022vxv8sd7cckj7	52000	2026-04-16 20:46:17.001	2026-04-16 20:46:17.001
cmo1y8yb201bxvxt05t1xwoch	cmo1y8yaq01btvxt0myy9zubs	cmo1xc11v000lvxp07r6uljko	52000	2026-04-16 20:46:17.006	2026-04-16 20:46:17.006
cmo1y8yb701bzvxt0xn7f6dkn	cmo1y8yaq01btvxt0myy9zubs	cmo1xc12y000qvxp0uqc7d8d8	52000	2026-04-16 20:46:17.012	2026-04-16 20:46:17.012
cmo1y8ybg01c1vxt01gfblvq2	cmo1y8yaq01btvxt0myy9zubs	cmo1xc12q000pvxp0kun82k4l	52000	2026-04-16 20:46:17.021	2026-04-16 20:46:17.021
cmo1y8ybn01c3vxt0bthizwy2	cmo1y8yaq01btvxt0myy9zubs	cmo1xc138000rvxp0r16wi1bz	52000	2026-04-16 20:46:17.027	2026-04-16 20:46:17.027
cmo1y8ybt01c5vxt02pdde6ro	cmo1y8yaq01btvxt0myy9zubs	cmo1xc12i000ovxp01nisgvnu	52000	2026-04-16 20:46:17.034	2026-04-16 20:46:17.034
cmo1y8yby01c7vxt0uu19bopa	cmo1y8yaq01btvxt0myy9zubs	cmo1xc13o000tvxp0alok8jeb	42000	2026-04-16 20:46:17.039	2026-04-16 20:46:17.039
cmo1y8yc401c9vxt0jfefc33w	cmo1y8yaq01btvxt0myy9zubs	cmo1xc123000mvxp0ul7pkio2	49000	2026-04-16 20:46:17.044	2026-04-16 20:46:17.044
cmo1y8yc901cbvxt04pou3eo3	cmo1y8yaq01btvxt0myy9zubs	cmo1xc11n000kvxp0g32oj3wx	52000	2026-04-16 20:46:17.049	2026-04-16 20:46:17.049
cmo1y8ycf01cdvxt0kdfq5d5k	cmo1y8yaq01btvxt0myy9zubs	cmo1xc10u000hvxp0dapryn3r	52000	2026-04-16 20:46:17.055	2026-04-16 20:46:17.055
cmo1y8yck01cfvxt0dlie88ct	cmo1y8yaq01btvxt0myy9zubs	cmo1xc119000jvxp01snwxzoa	52000	2026-04-16 20:46:17.06	2026-04-16 20:46:17.06
cmo1y8ycv01cjvxt0bk5jvnvg	cmo1y8ycq01chvxt0abcd4945	cmo1xsgrt0022vxv8sd7cckj7	52000	2026-04-16 20:46:17.072	2026-04-16 20:46:17.072
cmo1y8yd101clvxt0pujhyn5x	cmo1y8ycq01chvxt0abcd4945	cmo1xc11v000lvxp07r6uljko	52000	2026-04-16 20:46:17.078	2026-04-16 20:46:17.078
cmo1y8yd701cnvxt08ja6rcnp	cmo1y8ycq01chvxt0abcd4945	cmo1xc12y000qvxp0uqc7d8d8	52000	2026-04-16 20:46:17.084	2026-04-16 20:46:17.084
cmo1y8ydf01cpvxt049cn0zcq	cmo1y8ycq01chvxt0abcd4945	cmo1xc12q000pvxp0kun82k4l	52000	2026-04-16 20:46:17.092	2026-04-16 20:46:17.092
cmo1y8ydl01crvxt0n6p6hw8m	cmo1y8ycq01chvxt0abcd4945	cmo1xc138000rvxp0r16wi1bz	52000	2026-04-16 20:46:17.097	2026-04-16 20:46:17.097
cmo1y8ydr01ctvxt0ysrtap9c	cmo1y8ycq01chvxt0abcd4945	cmo1xc12i000ovxp01nisgvnu	52000	2026-04-16 20:46:17.103	2026-04-16 20:46:17.103
cmo1y8ydw01cvvxt071difdub	cmo1y8ycq01chvxt0abcd4945	cmo1xc13o000tvxp0alok8jeb	42000	2026-04-16 20:46:17.108	2026-04-16 20:46:17.108
cmo1y8ye201cxvxt0clioh43h	cmo1y8ycq01chvxt0abcd4945	cmo1xc123000mvxp0ul7pkio2	49000	2026-04-16 20:46:17.114	2026-04-16 20:46:17.114
cmo1y8ye701czvxt0okomokj2	cmo1y8ycq01chvxt0abcd4945	cmo1xc11n000kvxp0g32oj3wx	52000	2026-04-16 20:46:17.12	2026-04-16 20:46:17.12
cmo1y8yed01d1vxt0eg26eqb6	cmo1y8ycq01chvxt0abcd4945	cmo1xc10u000hvxp0dapryn3r	52000	2026-04-16 20:46:17.125	2026-04-16 20:46:17.125
cmo1y8yei01d3vxt0q47res87	cmo1y8ycq01chvxt0abcd4945	cmo1xc119000jvxp01snwxzoa	52000	2026-04-16 20:46:17.13	2026-04-16 20:46:17.13
cmo1y8yeu01d7vxt0902q16ga	cmo1y8yeo01d5vxt0czhzmndd	cmo1xsgrt0022vxv8sd7cckj7	52000	2026-04-16 20:46:17.142	2026-04-16 20:46:17.142
cmo1y8yez01d9vxt0r5vn3d1a	cmo1y8yeo01d5vxt0czhzmndd	cmo1xc11v000lvxp07r6uljko	52000	2026-04-16 20:46:17.148	2026-04-16 20:46:17.148
cmo1y8yf901dbvxt00aeadcha	cmo1y8yeo01d5vxt0czhzmndd	cmo1xc12y000qvxp0uqc7d8d8	52000	2026-04-16 20:46:17.157	2026-04-16 20:46:17.157
cmo1y8yfe01ddvxt0xooxf0qa	cmo1y8yeo01d5vxt0czhzmndd	cmo1xc13g000svxp0tbndc1wg	45000	2026-04-16 20:46:17.162	2026-04-16 20:46:17.162
cmo1y8yfl01dfvxt00jatwhbb	cmo1y8yeo01d5vxt0czhzmndd	cmo1xc12q000pvxp0kun82k4l	52000	2026-04-16 20:46:17.169	2026-04-16 20:46:17.169
cmo1y8yfq01dhvxt05l603jjo	cmo1y8yeo01d5vxt0czhzmndd	cmo1xc138000rvxp0r16wi1bz	52000	2026-04-16 20:46:17.174	2026-04-16 20:46:17.174
cmo1y8yfv01djvxt09zaq80o8	cmo1y8yeo01d5vxt0czhzmndd	cmo1xc12i000ovxp01nisgvnu	52000	2026-04-16 20:46:17.18	2026-04-16 20:46:17.18
cmo1y8yg101dlvxt0hjnd6191	cmo1y8yeo01d5vxt0czhzmndd	cmo1xc13o000tvxp0alok8jeb	42000	2026-04-16 20:46:17.185	2026-04-16 20:46:17.185
cmo1y8yg701dnvxt0q7jk29lv	cmo1y8yeo01d5vxt0czhzmndd	cmo1xc123000mvxp0ul7pkio2	49000	2026-04-16 20:46:17.192	2026-04-16 20:46:17.192
cmo1y8ygd01dpvxt0an0zejup	cmo1y8yeo01d5vxt0czhzmndd	cmo1xc11n000kvxp0g32oj3wx	52000	2026-04-16 20:46:17.197	2026-04-16 20:46:17.197
cmo1y8ygj01drvxt023ulj7ja	cmo1y8yeo01d5vxt0czhzmndd	cmo1xc10u000hvxp0dapryn3r	52000	2026-04-16 20:46:17.203	2026-04-16 20:46:17.203
cmo1y8ygo01dtvxt0z0evmxxv	cmo1y8yeo01d5vxt0czhzmndd	cmo1xc119000jvxp01snwxzoa	52000	2026-04-16 20:46:17.208	2026-04-16 20:46:17.208
cmo1y8ygz01dxvxt0ryl411x3	cmo1y8ygt01dvvxt0yc4kjbtw	cmo1xsgrt0022vxv8sd7cckj7	47000	2026-04-16 20:46:17.219	2026-04-16 20:46:17.219
cmo1y8yh401dzvxt06gqrrfme	cmo1y8ygt01dvvxt0yc4kjbtw	cmo1xc11v000lvxp07r6uljko	47000	2026-04-16 20:46:17.225	2026-04-16 20:46:17.225
cmo1y8yha01e1vxt09hsd5ok9	cmo1y8ygt01dvvxt0yc4kjbtw	cmo1xc12y000qvxp0uqc7d8d8	47000	2026-04-16 20:46:17.231	2026-04-16 20:46:17.231
cmo1y8yhg01e3vxt0zz0ibsr8	cmo1y8ygt01dvvxt0yc4kjbtw	cmo1xc13g000svxp0tbndc1wg	47000	2026-04-16 20:46:17.236	2026-04-16 20:46:17.236
cmo1y8yhn01e5vxt0988t3k31	cmo1y8ygt01dvvxt0yc4kjbtw	cmo1xc12q000pvxp0kun82k4l	47000	2026-04-16 20:46:17.243	2026-04-16 20:46:17.243
cmo1y8yht01e7vxt0a0wn13yx	cmo1y8ygt01dvvxt0yc4kjbtw	cmo1xc138000rvxp0r16wi1bz	47000	2026-04-16 20:46:17.249	2026-04-16 20:46:17.249
cmo1y8yhz01e9vxt0dwybyq1y	cmo1y8ygt01dvvxt0yc4kjbtw	cmo1xc12i000ovxp01nisgvnu	47000	2026-04-16 20:46:17.255	2026-04-16 20:46:17.255
cmo1y8yi501ebvxt0qri3uv59	cmo1y8ygt01dvvxt0yc4kjbtw	cmo1xc13o000tvxp0alok8jeb	40000	2026-04-16 20:46:17.261	2026-04-16 20:46:17.261
cmo1y8yid01edvxt0b6qjwo53	cmo1y8ygt01dvvxt0yc4kjbtw	cmo1xc11n000kvxp0g32oj3wx	47000	2026-04-16 20:46:17.269	2026-04-16 20:46:17.269
cmo1y8yik01efvxt04xl7yr5x	cmo1y8ygt01dvvxt0yc4kjbtw	cmo1xc10u000hvxp0dapryn3r	47000	2026-04-16 20:46:17.276	2026-04-16 20:46:17.276
cmo1y8yir01ehvxt0xhuiiv7n	cmo1y8ygt01dvvxt0yc4kjbtw	cmo1xc119000jvxp01snwxzoa	47000	2026-04-16 20:46:17.283	2026-04-16 20:46:17.283
cmo1y8yj701elvxt0blx472gq	cmo1y8yiz01ejvxt0dn4hmk98	cmo1xsgrt0022vxv8sd7cckj7	47000	2026-04-16 20:46:17.299	2026-04-16 20:46:17.299
cmo1y8yje01envxt0el67t62a	cmo1y8yiz01ejvxt0dn4hmk98	cmo1xc11v000lvxp07r6uljko	47000	2026-04-16 20:46:17.307	2026-04-16 20:46:17.307
cmo1y8yjm01epvxt0aszszl21	cmo1y8yiz01ejvxt0dn4hmk98	cmo1xc12y000qvxp0uqc7d8d8	47000	2026-04-16 20:46:17.314	2026-04-16 20:46:17.314
cmo1y8yjs01ervxt0ax82qcwh	cmo1y8yiz01ejvxt0dn4hmk98	cmo1xc13g000svxp0tbndc1wg	47000	2026-04-16 20:46:17.321	2026-04-16 20:46:17.321
cmo1y8yjz01etvxt0kscun3a6	cmo1y8yiz01ejvxt0dn4hmk98	cmo1xc12q000pvxp0kun82k4l	47000	2026-04-16 20:46:17.328	2026-04-16 20:46:17.328
cmo1y8yk501evvxt0hqy8b1f8	cmo1y8yiz01ejvxt0dn4hmk98	cmo1xc138000rvxp0r16wi1bz	47000	2026-04-16 20:46:17.333	2026-04-16 20:46:17.333
cmo1y8yka01exvxt0sdcvyrsd	cmo1y8yiz01ejvxt0dn4hmk98	cmo1xc12i000ovxp01nisgvnu	47000	2026-04-16 20:46:17.338	2026-04-16 20:46:17.338
cmo1y8ykg01ezvxt0zdgbnh0g	cmo1y8yiz01ejvxt0dn4hmk98	cmo1xc13o000tvxp0alok8jeb	40000	2026-04-16 20:46:17.345	2026-04-16 20:46:17.345
cmo1y8yko01f1vxt0p2506fod	cmo1y8yiz01ejvxt0dn4hmk98	cmo1xc11n000kvxp0g32oj3wx	47000	2026-04-16 20:46:17.352	2026-04-16 20:46:17.352
cmo1y8ykt01f3vxt070ar8i54	cmo1y8yiz01ejvxt0dn4hmk98	cmo1xc10u000hvxp0dapryn3r	47000	2026-04-16 20:46:17.357	2026-04-16 20:46:17.357
cmo1y8ykx01f5vxt0dj5v8kn8	cmo1y8yiz01ejvxt0dn4hmk98	cmo1xc119000jvxp01snwxzoa	47000	2026-04-16 20:46:17.362	2026-04-16 20:46:17.362
cmo1y8yl901f9vxt0mukqoi8v	cmo1y8yl301f7vxt008720ged	cmo1xsgrt0022vxv8sd7cckj7	47000	2026-04-16 20:46:17.374	2026-04-16 20:46:17.374
cmo1y8ylf01fbvxt0m0ruosjt	cmo1y8yl301f7vxt008720ged	cmo1xc11v000lvxp07r6uljko	47000	2026-04-16 20:46:17.38	2026-04-16 20:46:17.38
cmo1y8ylm01fdvxt0e6gaejrg	cmo1y8yl301f7vxt008720ged	cmo1xc12y000qvxp0uqc7d8d8	47000	2026-04-16 20:46:17.386	2026-04-16 20:46:17.386
cmo1y8ylu01ffvxt0e366iby0	cmo1y8yl301f7vxt008720ged	cmo1xc13g000svxp0tbndc1wg	47000	2026-04-16 20:46:17.395	2026-04-16 20:46:17.395
cmo1y8ym301fhvxt0wvr8p3uv	cmo1y8yl301f7vxt008720ged	cmo1xc12q000pvxp0kun82k4l	47000	2026-04-16 20:46:17.404	2026-04-16 20:46:17.404
cmo1y8ym901fjvxt0yiyaqibs	cmo1y8yl301f7vxt008720ged	cmo1xc138000rvxp0r16wi1bz	47000	2026-04-16 20:46:17.409	2026-04-16 20:46:17.409
cmo1y8ymf01flvxt0oq0d868l	cmo1y8yl301f7vxt008720ged	cmo1xc12i000ovxp01nisgvnu	47000	2026-04-16 20:46:17.415	2026-04-16 20:46:17.415
cmo1y8ymk01fnvxt0rg3tvprd	cmo1y8yl301f7vxt008720ged	cmo1xc13o000tvxp0alok8jeb	40000	2026-04-16 20:46:17.421	2026-04-16 20:46:17.421
cmo1y8ymq01fpvxt0d753pomx	cmo1y8yl301f7vxt008720ged	cmo1xc11n000kvxp0g32oj3wx	47000	2026-04-16 20:46:17.427	2026-04-16 20:46:17.427
cmo1y8ymw01frvxt0paxzil68	cmo1y8yl301f7vxt008720ged	cmo1xc10u000hvxp0dapryn3r	47000	2026-04-16 20:46:17.432	2026-04-16 20:46:17.432
cmo1y8yn101ftvxt0nnmqui53	cmo1y8yl301f7vxt008720ged	cmo1xc119000jvxp01snwxzoa	47000	2026-04-16 20:46:17.437	2026-04-16 20:46:17.437
cmo1y8ync01fxvxt0hdjdkpdr	cmo1y8yn601fvvxt0q1veynrf	cmo1xsgrt0022vxv8sd7cckj7	44000	2026-04-16 20:46:17.448	2026-04-16 20:46:17.448
cmo1y8ynh01fzvxt0e0b16ckp	cmo1y8yn601fvvxt0q1veynrf	cmo1xc11v000lvxp07r6uljko	44000	2026-04-16 20:46:17.453	2026-04-16 20:46:17.453
cmo1y8ynm01g1vxt0xuqfcglm	cmo1y8yn601fvvxt0q1veynrf	cmo1xc12y000qvxp0uqc7d8d8	44000	2026-04-16 20:46:17.458	2026-04-16 20:46:17.458
cmo1y8ynr01g3vxt08ozo7jcu	cmo1y8yn601fvvxt0q1veynrf	cmo1xc13g000svxp0tbndc1wg	44000	2026-04-16 20:46:17.464	2026-04-16 20:46:17.464
cmo1y8ynx01g5vxt0r5aof20m	cmo1y8yn601fvvxt0q1veynrf	cmo1xc12q000pvxp0kun82k4l	44000	2026-04-16 20:46:17.47	2026-04-16 20:46:17.47
cmo1y8yo201g7vxt006vazdg8	cmo1y8yn601fvvxt0q1veynrf	cmo1xc138000rvxp0r16wi1bz	44000	2026-04-16 20:46:17.475	2026-04-16 20:46:17.475
cmo1y8yo801g9vxt07mfc89ko	cmo1y8yn601fvvxt0q1veynrf	cmo1xc12i000ovxp01nisgvnu	44000	2026-04-16 20:46:17.48	2026-04-16 20:46:17.48
cmo1y8yod01gbvxt0vgl7madn	cmo1y8yn601fvvxt0q1veynrf	cmo1xc13o000tvxp0alok8jeb	40000	2026-04-16 20:46:17.486	2026-04-16 20:46:17.486
cmo1y8yok01gdvxt0qr76jp47	cmo1y8yn601fvvxt0q1veynrf	cmo1xc11n000kvxp0g32oj3wx	44000	2026-04-16 20:46:17.492	2026-04-16 20:46:17.492
cmo1y8yop01gfvxt0afzewoqo	cmo1y8yn601fvvxt0q1veynrf	cmo1xc10u000hvxp0dapryn3r	44000	2026-04-16 20:46:17.497	2026-04-16 20:46:17.497
cmo1y8yov01ghvxt0bhj759z2	cmo1y8yn601fvvxt0q1veynrf	cmo1xc119000jvxp01snwxzoa	44000	2026-04-16 20:46:17.503	2026-04-16 20:46:17.503
cmo1y8yp701glvxt0sedi8jq5	cmo1y8yp101gjvxt0pcmprmsf	cmo1xsgrt0022vxv8sd7cckj7	44000	2026-04-16 20:46:17.516	2026-04-16 20:46:17.516
cmo1y8ype01gnvxt0sth284s4	cmo1y8yp101gjvxt0pcmprmsf	cmo1xc11v000lvxp07r6uljko	44000	2026-04-16 20:46:17.522	2026-04-16 20:46:17.522
cmo1y8ypl01gpvxt07szjw8wr	cmo1y8yp101gjvxt0pcmprmsf	cmo1xc12y000qvxp0uqc7d8d8	44000	2026-04-16 20:46:17.529	2026-04-16 20:46:17.529
cmo1y8yps01grvxt0knhrphbc	cmo1y8yp101gjvxt0pcmprmsf	cmo1xc13g000svxp0tbndc1wg	44000	2026-04-16 20:46:17.536	2026-04-16 20:46:17.536
cmo1y8ypy01gtvxt0j30s2yr9	cmo1y8yp101gjvxt0pcmprmsf	cmo1xc12q000pvxp0kun82k4l	44000	2026-04-16 20:46:17.543	2026-04-16 20:46:17.543
cmo1y8yq401gvvxt0uxrzft5u	cmo1y8yp101gjvxt0pcmprmsf	cmo1xc138000rvxp0r16wi1bz	44000	2026-04-16 20:46:17.548	2026-04-16 20:46:17.548
cmo1y8yqa01gxvxt0trrc2nwj	cmo1y8yp101gjvxt0pcmprmsf	cmo1xc12i000ovxp01nisgvnu	44000	2026-04-16 20:46:17.554	2026-04-16 20:46:17.554
cmo1y8yqg01gzvxt0dbn44oyz	cmo1y8yp101gjvxt0pcmprmsf	cmo1xc13o000tvxp0alok8jeb	40000	2026-04-16 20:46:17.56	2026-04-16 20:46:17.56
cmo1y8yqm01h1vxt00inovbb9	cmo1y8yp101gjvxt0pcmprmsf	cmo1xc11n000kvxp0g32oj3wx	44000	2026-04-16 20:46:17.567	2026-04-16 20:46:17.567
cmo1y8yqr01h3vxt0fn6m5vd8	cmo1y8yp101gjvxt0pcmprmsf	cmo1xc10u000hvxp0dapryn3r	44000	2026-04-16 20:46:17.572	2026-04-16 20:46:17.572
cmo1y8yqx01h5vxt0psk69vgv	cmo1y8yp101gjvxt0pcmprmsf	cmo1xc119000jvxp01snwxzoa	44000	2026-04-16 20:46:17.577	2026-04-16 20:46:17.577
cmo1y8yr801h9vxt0gewyn6ga	cmo1y8yr201h7vxt0vx725bdj	cmo1xsgrt0022vxv8sd7cckj7	44000	2026-04-16 20:46:17.589	2026-04-16 20:46:17.589
cmo1y8yre01hbvxt058txnylg	cmo1y8yr201h7vxt0vx725bdj	cmo1xc11v000lvxp07r6uljko	44000	2026-04-16 20:46:17.594	2026-04-16 20:46:17.594
cmo1y8yrj01hdvxt02n60aqn4	cmo1y8yr201h7vxt0vx725bdj	cmo1xc12y000qvxp0uqc7d8d8	44000	2026-04-16 20:46:17.6	2026-04-16 20:46:17.6
cmo1y8yrp01hfvxt0byifmq74	cmo1y8yr201h7vxt0vx725bdj	cmo1xc13g000svxp0tbndc1wg	44000	2026-04-16 20:46:17.605	2026-04-16 20:46:17.605
cmo1y8yrv01hhvxt0qa922tk2	cmo1y8yr201h7vxt0vx725bdj	cmo1xc12q000pvxp0kun82k4l	44000	2026-04-16 20:46:17.611	2026-04-16 20:46:17.611
cmo1y8ys101hjvxt0jw3ksv7l	cmo1y8yr201h7vxt0vx725bdj	cmo1xc138000rvxp0r16wi1bz	44000	2026-04-16 20:46:17.617	2026-04-16 20:46:17.617
cmo1y8ys601hlvxt0pgf8nec3	cmo1y8yr201h7vxt0vx725bdj	cmo1xc12i000ovxp01nisgvnu	44000	2026-04-16 20:46:17.622	2026-04-16 20:46:17.622
cmo1y8ysb01hnvxt0fwn44vhj	cmo1y8yr201h7vxt0vx725bdj	cmo1xc13o000tvxp0alok8jeb	40000	2026-04-16 20:46:17.628	2026-04-16 20:46:17.628
cmo1y8ysj01hpvxt0e77t9414	cmo1y8yr201h7vxt0vx725bdj	cmo1xc11n000kvxp0g32oj3wx	44000	2026-04-16 20:46:17.635	2026-04-16 20:46:17.635
cmo1y8yso01hrvxt09kyj1s5g	cmo1y8yr201h7vxt0vx725bdj	cmo1xc10u000hvxp0dapryn3r	44000	2026-04-16 20:46:17.64	2026-04-16 20:46:17.64
cmo1y8yst01htvxt0pcbld61s	cmo1y8yr201h7vxt0vx725bdj	cmo1xc119000jvxp01snwxzoa	44000	2026-04-16 20:46:17.645	2026-04-16 20:46:17.645
cmo1y8yt401hxvxt0neix8m8d	cmo1y8ysz01hvvxt0gph2wg0b	cmo1xsgrt0022vxv8sd7cckj7	46000	2026-04-16 20:46:17.657	2026-04-16 20:46:17.657
cmo1y8yta01hzvxt0e297f5nj	cmo1y8ysz01hvvxt0gph2wg0b	cmo1xc11v000lvxp07r6uljko	40000	2026-04-16 20:46:17.662	2026-04-16 20:46:17.662
cmo1y8ytg01i1vxt0jgqe0tpc	cmo1y8ysz01hvvxt0gph2wg0b	cmo1xc12y000qvxp0uqc7d8d8	46000	2026-04-16 20:46:17.668	2026-04-16 20:46:17.668
cmo1y8ytl01i3vxt0qpnxhlny	cmo1y8ysz01hvvxt0gph2wg0b	cmo1xc13g000svxp0tbndc1wg	46000	2026-04-16 20:46:17.673	2026-04-16 20:46:17.673
cmo1y8ytr01i5vxt0xi7je43c	cmo1y8ysz01hvvxt0gph2wg0b	cmo1xc12q000pvxp0kun82k4l	46000	2026-04-16 20:46:17.679	2026-04-16 20:46:17.679
cmo1y8yty01i7vxt0pv9fqvup	cmo1y8ysz01hvvxt0gph2wg0b	cmo1xc138000rvxp0r16wi1bz	46000	2026-04-16 20:46:17.686	2026-04-16 20:46:17.686
cmo1y8yu301i9vxt0xqw6g8i4	cmo1y8ysz01hvvxt0gph2wg0b	cmo1xc12i000ovxp01nisgvnu	46000	2026-04-16 20:46:17.691	2026-04-16 20:46:17.691
cmo1y8yu801ibvxt0i6l8ig5c	cmo1y8ysz01hvvxt0gph2wg0b	cmo1xc13o000tvxp0alok8jeb	40000	2026-04-16 20:46:17.696	2026-04-16 20:46:17.696
cmo1y8yuf01idvxt0y9ay9gpc	cmo1y8ysz01hvvxt0gph2wg0b	cmo1xc11n000kvxp0g32oj3wx	46000	2026-04-16 20:46:17.703	2026-04-16 20:46:17.703
cmo1y8yuk01ifvxt0zpic4eue	cmo1y8ysz01hvvxt0gph2wg0b	cmo1xc10u000hvxp0dapryn3r	46000	2026-04-16 20:46:17.708	2026-04-16 20:46:17.708
cmo1y8yuq01ihvxt0qlxws5ig	cmo1y8ysz01hvvxt0gph2wg0b	cmo1xc119000jvxp01snwxzoa	46000	2026-04-16 20:46:17.714	2026-04-16 20:46:17.714
cmo1y8yv101ilvxt0omgeokx4	cmo1y8yuv01ijvxt0v8irnmlo	cmo1xsgrt0022vxv8sd7cckj7	46000	2026-04-16 20:46:17.725	2026-04-16 20:46:17.725
cmo1y8yv701invxt0jxs3otir	cmo1y8yuv01ijvxt0v8irnmlo	cmo1xc11v000lvxp07r6uljko	40000	2026-04-16 20:46:17.731	2026-04-16 20:46:17.731
cmo1y8yvc01ipvxt0h33mcam7	cmo1y8yuv01ijvxt0v8irnmlo	cmo1xc12y000qvxp0uqc7d8d8	46000	2026-04-16 20:46:17.737	2026-04-16 20:46:17.737
cmo1y8yvh01irvxt0iagfef9r	cmo1y8yuv01ijvxt0v8irnmlo	cmo1xc13g000svxp0tbndc1wg	46000	2026-04-16 20:46:17.742	2026-04-16 20:46:17.742
cmo1y8yvo01itvxt0ycgj4ymw	cmo1y8yuv01ijvxt0v8irnmlo	cmo1xc12q000pvxp0kun82k4l	46000	2026-04-16 20:46:17.749	2026-04-16 20:46:17.749
cmo1y8yvt01ivvxt0x7auily1	cmo1y8yuv01ijvxt0v8irnmlo	cmo1xc138000rvxp0r16wi1bz	46000	2026-04-16 20:46:17.754	2026-04-16 20:46:17.754
cmo1y8yvz01ixvxt07kk9nfv4	cmo1y8yuv01ijvxt0v8irnmlo	cmo1xc12i000ovxp01nisgvnu	46000	2026-04-16 20:46:17.759	2026-04-16 20:46:17.759
cmo1y8yw501izvxt0yup8naci	cmo1y8yuv01ijvxt0v8irnmlo	cmo1xc13o000tvxp0alok8jeb	40000	2026-04-16 20:46:17.765	2026-04-16 20:46:17.765
cmo1y8ywd01j1vxt0ddjqjry8	cmo1y8yuv01ijvxt0v8irnmlo	cmo1xc11n000kvxp0g32oj3wx	46000	2026-04-16 20:46:17.774	2026-04-16 20:46:17.774
cmo1y8ywl01j3vxt0gqn7s4ol	cmo1y8yuv01ijvxt0v8irnmlo	cmo1xc10u000hvxp0dapryn3r	46000	2026-04-16 20:46:17.781	2026-04-16 20:46:17.781
cmo1y8ywr01j5vxt0d6g9qfqc	cmo1y8yuv01ijvxt0v8irnmlo	cmo1xc119000jvxp01snwxzoa	46000	2026-04-16 20:46:17.787	2026-04-16 20:46:17.787
cmo1y8yx101j9vxt0ukgs461u	cmo1y8yww01j7vxt0ilppuk7e	cmo1xsgrt0022vxv8sd7cckj7	46000	2026-04-16 20:46:17.798	2026-04-16 20:46:17.798
cmo1y8yx701jbvxt0gbzaqm4f	cmo1y8yww01j7vxt0ilppuk7e	cmo1xc11v000lvxp07r6uljko	40000	2026-04-16 20:46:17.803	2026-04-16 20:46:17.803
cmo1y8yxd01jdvxt0jpfbcu81	cmo1y8yww01j7vxt0ilppuk7e	cmo1xc12y000qvxp0uqc7d8d8	46000	2026-04-16 20:46:17.809	2026-04-16 20:46:17.809
cmo1y8yxi01jfvxt0oltg0xhq	cmo1y8yww01j7vxt0ilppuk7e	cmo1xc13g000svxp0tbndc1wg	46000	2026-04-16 20:46:17.815	2026-04-16 20:46:17.815
cmo1y8yxp01jhvxt0lutslrwg	cmo1y8yww01j7vxt0ilppuk7e	cmo1xc12q000pvxp0kun82k4l	46000	2026-04-16 20:46:17.821	2026-04-16 20:46:17.821
cmo1y8yxu01jjvxt0c4vtw6no	cmo1y8yww01j7vxt0ilppuk7e	cmo1xc138000rvxp0r16wi1bz	46000	2026-04-16 20:46:17.826	2026-04-16 20:46:17.826
cmo1y8yxz01jlvxt04196gr01	cmo1y8yww01j7vxt0ilppuk7e	cmo1xc12i000ovxp01nisgvnu	46000	2026-04-16 20:46:17.831	2026-04-16 20:46:17.831
cmo1y8yy501jnvxt0aepfhyyk	cmo1y8yww01j7vxt0ilppuk7e	cmo1xc13o000tvxp0alok8jeb	40000	2026-04-16 20:46:17.837	2026-04-16 20:46:17.837
cmo1y8yyb01jpvxt01qbt6kxs	cmo1y8yww01j7vxt0ilppuk7e	cmo1xc11n000kvxp0g32oj3wx	46000	2026-04-16 20:46:17.843	2026-04-16 20:46:17.843
cmo1y8yyh01jrvxt0lj1z2y42	cmo1y8yww01j7vxt0ilppuk7e	cmo1xc10u000hvxp0dapryn3r	46000	2026-04-16 20:46:17.849	2026-04-16 20:46:17.849
cmo1y8yym01jtvxt0j5aoltu0	cmo1y8yww01j7vxt0ilppuk7e	cmo1xc119000jvxp01snwxzoa	46000	2026-04-16 20:46:17.855	2026-04-16 20:46:17.855
cmo1y8yyx01jxvxt0wns33gxz	cmo1y8yyr01jvvxt0ig306jns	cmo1xsgrt0022vxv8sd7cckj7	46000	2026-04-16 20:46:17.866	2026-04-16 20:46:17.866
cmo1y8yz301jzvxt0q2soyto3	cmo1y8yyr01jvvxt0ig306jns	cmo1xc11v000lvxp07r6uljko	40000	2026-04-16 20:46:17.871	2026-04-16 20:46:17.871
cmo1y8yz801k1vxt06oy1200e	cmo1y8yyr01jvvxt0ig306jns	cmo1xc12y000qvxp0uqc7d8d8	46000	2026-04-16 20:46:17.876	2026-04-16 20:46:17.876
cmo1y8yzd01k3vxt0dide1za6	cmo1y8yyr01jvvxt0ig306jns	cmo1xc13g000svxp0tbndc1wg	46000	2026-04-16 20:46:17.882	2026-04-16 20:46:17.882
cmo1y8yzl01k5vxt0i83nskb4	cmo1y8yyr01jvvxt0ig306jns	cmo1xc12q000pvxp0kun82k4l	46000	2026-04-16 20:46:17.89	2026-04-16 20:46:17.89
cmo1y8yzr01k7vxt0zaj4bkje	cmo1y8yyr01jvvxt0ig306jns	cmo1xc138000rvxp0r16wi1bz	46000	2026-04-16 20:46:17.895	2026-04-16 20:46:17.895
cmo1y8yzx01k9vxt0ogdoobsn	cmo1y8yyr01jvvxt0ig306jns	cmo1xc12i000ovxp01nisgvnu	46000	2026-04-16 20:46:17.901	2026-04-16 20:46:17.901
cmo1y8z0201kbvxt05l8ivskf	cmo1y8yyr01jvvxt0ig306jns	cmo1xc13o000tvxp0alok8jeb	38000	2026-04-16 20:46:17.906	2026-04-16 20:46:17.906
cmo1y8z0901kdvxt0gviqaluw	cmo1y8yyr01jvvxt0ig306jns	cmo1xc11n000kvxp0g32oj3wx	46000	2026-04-16 20:46:17.913	2026-04-16 20:46:17.913
cmo1y8z0e01kfvxt0678t9b46	cmo1y8yyr01jvvxt0ig306jns	cmo1xc10u000hvxp0dapryn3r	46000	2026-04-16 20:46:17.919	2026-04-16 20:46:17.919
cmo1y8z0k01khvxt0hb01czb9	cmo1y8yyr01jvvxt0ig306jns	cmo1xc119000jvxp01snwxzoa	46000	2026-04-16 20:46:17.924	2026-04-16 20:46:17.924
cmo1y8z0v01klvxt0szwuxxc0	cmo1y8z0p01kjvxt0k7zr13f1	cmo1xsgrt0022vxv8sd7cckj7	46000	2026-04-16 20:46:17.935	2026-04-16 20:46:17.935
cmo1y8z1001knvxt0fzjigcyo	cmo1y8z0p01kjvxt0k7zr13f1	cmo1xc11v000lvxp07r6uljko	40000	2026-04-16 20:46:17.94	2026-04-16 20:46:17.94
cmo1y8z1501kpvxt05700n7cq	cmo1y8z0p01kjvxt0k7zr13f1	cmo1xc12y000qvxp0uqc7d8d8	46000	2026-04-16 20:46:17.946	2026-04-16 20:46:17.946
cmo1y8z1b01krvxt08ol8p200	cmo1y8z0p01kjvxt0k7zr13f1	cmo1xc13g000svxp0tbndc1wg	46000	2026-04-16 20:46:17.951	2026-04-16 20:46:17.951
cmo1y8z1h01ktvxt0g90rk8t2	cmo1y8z0p01kjvxt0k7zr13f1	cmo1xc12q000pvxp0kun82k4l	46000	2026-04-16 20:46:17.958	2026-04-16 20:46:17.958
cmo1y8z1m01kvvxt0ybk2icc2	cmo1y8z0p01kjvxt0k7zr13f1	cmo1xc138000rvxp0r16wi1bz	46000	2026-04-16 20:46:17.963	2026-04-16 20:46:17.963
cmo1y8z1s01kxvxt0td2hk0u7	cmo1y8z0p01kjvxt0k7zr13f1	cmo1xc12i000ovxp01nisgvnu	46000	2026-04-16 20:46:17.968	2026-04-16 20:46:17.968
cmo1y8z1x01kzvxt0aml2zctq	cmo1y8z0p01kjvxt0k7zr13f1	cmo1xc13o000tvxp0alok8jeb	38000	2026-04-16 20:46:17.974	2026-04-16 20:46:17.974
cmo1y8z2401l1vxt0cu3ijzmh	cmo1y8z0p01kjvxt0k7zr13f1	cmo1xc11n000kvxp0g32oj3wx	46000	2026-04-16 20:46:17.98	2026-04-16 20:46:17.98
cmo1y8z2a01l3vxt0q2of11jt	cmo1y8z0p01kjvxt0k7zr13f1	cmo1xc10u000hvxp0dapryn3r	46000	2026-04-16 20:46:17.986	2026-04-16 20:46:17.986
cmo1y8z2f01l5vxt0uhq6t3nt	cmo1y8z0p01kjvxt0k7zr13f1	cmo1xc119000jvxp01snwxzoa	46000	2026-04-16 20:46:17.991	2026-04-16 20:46:17.991
cmo1y8z2r01l9vxt0rgc6pg6u	cmo1y8z2l01l7vxt0vbyiy8z3	cmo1xsgrt0022vxv8sd7cckj7	46000	2026-04-16 20:46:18.003	2026-04-16 20:46:18.003
cmo1y8z2x01lbvxt0cbfnx0rs	cmo1y8z2l01l7vxt0vbyiy8z3	cmo1xc11v000lvxp07r6uljko	40000	2026-04-16 20:46:18.009	2026-04-16 20:46:18.009
cmo1y8z3301ldvxt0zabweba3	cmo1y8z2l01l7vxt0vbyiy8z3	cmo1xc12y000qvxp0uqc7d8d8	46000	2026-04-16 20:46:18.015	2026-04-16 20:46:18.015
cmo1y8z3901lfvxt02mntl8b3	cmo1y8z2l01l7vxt0vbyiy8z3	cmo1xc13g000svxp0tbndc1wg	46000	2026-04-16 20:46:18.021	2026-04-16 20:46:18.021
cmo1y8z3i01lhvxt0y20bmz07	cmo1y8z2l01l7vxt0vbyiy8z3	cmo1xc12q000pvxp0kun82k4l	46000	2026-04-16 20:46:18.03	2026-04-16 20:46:18.03
cmo1y8z3p01ljvxt0m4y0od2z	cmo1y8z2l01l7vxt0vbyiy8z3	cmo1xc138000rvxp0r16wi1bz	46000	2026-04-16 20:46:18.037	2026-04-16 20:46:18.037
cmo1y8z3v01llvxt05aw6ua7m	cmo1y8z2l01l7vxt0vbyiy8z3	cmo1xc12i000ovxp01nisgvnu	46000	2026-04-16 20:46:18.043	2026-04-16 20:46:18.043
cmo1y8z4101lnvxt0sa3ldqze	cmo1y8z2l01l7vxt0vbyiy8z3	cmo1xc13o000tvxp0alok8jeb	38000	2026-04-16 20:46:18.049	2026-04-16 20:46:18.049
cmo1y8z4701lpvxt09yvuansa	cmo1y8z2l01l7vxt0vbyiy8z3	cmo1xc11n000kvxp0g32oj3wx	46000	2026-04-16 20:46:18.056	2026-04-16 20:46:18.056
cmo1y8z4c01lrvxt0o6yu7sp0	cmo1y8z2l01l7vxt0vbyiy8z3	cmo1xc10u000hvxp0dapryn3r	46000	2026-04-16 20:46:18.061	2026-04-16 20:46:18.061
cmo1y8z4i01ltvxt0p44eclhb	cmo1y8z2l01l7vxt0vbyiy8z3	cmo1xc119000jvxp01snwxzoa	46000	2026-04-16 20:46:18.066	2026-04-16 20:46:18.066
cmo1y8z4t01lxvxt0k1n2jwf0	cmo1y8z4o01lvvxt0l02sqgvp	cmo1xsgrt0022vxv8sd7cckj7	46000	2026-04-16 20:46:18.077	2026-04-16 20:46:18.077
cmo1y8z4z01lzvxt0cd9iltbn	cmo1y8z4o01lvvxt0l02sqgvp	cmo1xc11v000lvxp07r6uljko	40000	2026-04-16 20:46:18.084	2026-04-16 20:46:18.084
cmo1y8z5501m1vxt0zbl8m4ow	cmo1y8z4o01lvvxt0l02sqgvp	cmo1xc12y000qvxp0uqc7d8d8	46000	2026-04-16 20:46:18.089	2026-04-16 20:46:18.089
cmo1y8z5a01m3vxt0zyseygkk	cmo1y8z4o01lvvxt0l02sqgvp	cmo1xc13g000svxp0tbndc1wg	46000	2026-04-16 20:46:18.094	2026-04-16 20:46:18.094
cmo1y8z5h01m5vxt05pxw30w6	cmo1y8z4o01lvvxt0l02sqgvp	cmo1xc12q000pvxp0kun82k4l	46000	2026-04-16 20:46:18.101	2026-04-16 20:46:18.101
cmo1y8z5m01m7vxt0xorqizsu	cmo1y8z4o01lvvxt0l02sqgvp	cmo1xc138000rvxp0r16wi1bz	46000	2026-04-16 20:46:18.107	2026-04-16 20:46:18.107
cmo1y8z5s01m9vxt0vjtcr5xs	cmo1y8z4o01lvvxt0l02sqgvp	cmo1xc12i000ovxp01nisgvnu	46000	2026-04-16 20:46:18.112	2026-04-16 20:46:18.112
cmo1y8z5y01mbvxt0hg2pin0o	cmo1y8z4o01lvvxt0l02sqgvp	cmo1xc13o000tvxp0alok8jeb	38000	2026-04-16 20:46:18.118	2026-04-16 20:46:18.118
cmo1y8z6401mdvxt09slxjsok	cmo1y8z4o01lvvxt0l02sqgvp	cmo1xc11n000kvxp0g32oj3wx	46000	2026-04-16 20:46:18.124	2026-04-16 20:46:18.124
cmo1y8z6901mfvxt05l6849ch	cmo1y8z4o01lvvxt0l02sqgvp	cmo1xc10u000hvxp0dapryn3r	46000	2026-04-16 20:46:18.13	2026-04-16 20:46:18.13
cmo1y8z6f01mhvxt0fd3w2gr9	cmo1y8z4o01lvvxt0l02sqgvp	cmo1xc119000jvxp01snwxzoa	46000	2026-04-16 20:46:18.135	2026-04-16 20:46:18.135
cmo1y8z6q01mlvxt03pep35pu	cmo1y8z6k01mjvxt0wmvlblmh	cmo1xsgrt0022vxv8sd7cckj7	46000	2026-04-16 20:46:18.146	2026-04-16 20:46:18.146
cmo1y8z6v01mnvxt0cx6mzt8s	cmo1y8z6k01mjvxt0wmvlblmh	cmo1xc11v000lvxp07r6uljko	40000	2026-04-16 20:46:18.152	2026-04-16 20:46:18.152
cmo1y8z7001mpvxt0tnlvjpy5	cmo1y8z6k01mjvxt0wmvlblmh	cmo1xc12y000qvxp0uqc7d8d8	46000	2026-04-16 20:46:18.157	2026-04-16 20:46:18.157
cmo1y8z7501mrvxt04uhql8ad	cmo1y8z6k01mjvxt0wmvlblmh	cmo1xc13g000svxp0tbndc1wg	46000	2026-04-16 20:46:18.162	2026-04-16 20:46:18.162
cmo1y8z7c01mtvxt0g40eda5v	cmo1y8z6k01mjvxt0wmvlblmh	cmo1xc12q000pvxp0kun82k4l	46000	2026-04-16 20:46:18.169	2026-04-16 20:46:18.169
cmo1y8z7i01mvvxt0j8my59qp	cmo1y8z6k01mjvxt0wmvlblmh	cmo1xc138000rvxp0r16wi1bz	46000	2026-04-16 20:46:18.174	2026-04-16 20:46:18.174
cmo1y8z7n01mxvxt0kzy1pnna	cmo1y8z6k01mjvxt0wmvlblmh	cmo1xc12i000ovxp01nisgvnu	46000	2026-04-16 20:46:18.179	2026-04-16 20:46:18.179
cmo1y8z7t01mzvxt0s5131xga	cmo1y8z6k01mjvxt0wmvlblmh	cmo1xc13o000tvxp0alok8jeb	38000	2026-04-16 20:46:18.185	2026-04-16 20:46:18.185
cmo1y8z7z01n1vxt0d633ynq4	cmo1y8z6k01mjvxt0wmvlblmh	cmo1xc11n000kvxp0g32oj3wx	46000	2026-04-16 20:46:18.192	2026-04-16 20:46:18.192
cmo1y8z8501n3vxt0xdzzzk69	cmo1y8z6k01mjvxt0wmvlblmh	cmo1xc10u000hvxp0dapryn3r	46000	2026-04-16 20:46:18.197	2026-04-16 20:46:18.197
cmo1y8z8a01n5vxt0s10zowoq	cmo1y8z6k01mjvxt0wmvlblmh	cmo1xc119000jvxp01snwxzoa	46000	2026-04-16 20:46:18.202	2026-04-16 20:46:18.202
cmo1y8z8n01n9vxt05o25l6xs	cmo1y8z8g01n7vxt06tfrz69d	cmo1xsgrt0022vxv8sd7cckj7	46000	2026-04-16 20:46:18.215	2026-04-16 20:46:18.215
cmo1y8z8v01nbvxt0nvddgjwr	cmo1y8z8g01n7vxt06tfrz69d	cmo1xc11v000lvxp07r6uljko	40000	2026-04-16 20:46:18.223	2026-04-16 20:46:18.223
cmo1y8z9201ndvxt03terc3c1	cmo1y8z8g01n7vxt06tfrz69d	cmo1xc12y000qvxp0uqc7d8d8	46000	2026-04-16 20:46:18.23	2026-04-16 20:46:18.23
cmo1y8z9901nfvxt0k0je272x	cmo1y8z8g01n7vxt06tfrz69d	cmo1xc13g000svxp0tbndc1wg	46000	2026-04-16 20:46:18.237	2026-04-16 20:46:18.237
cmo1y8z9h01nhvxt0jitm2s4y	cmo1y8z8g01n7vxt06tfrz69d	cmo1xc12q000pvxp0kun82k4l	46000	2026-04-16 20:46:18.245	2026-04-16 20:46:18.245
cmo1y8z9o01njvxt0o04fv8sx	cmo1y8z8g01n7vxt06tfrz69d	cmo1xc138000rvxp0r16wi1bz	46000	2026-04-16 20:46:18.253	2026-04-16 20:46:18.253
cmo1y8z9v01nlvxt0iwg1zm1h	cmo1y8z8g01n7vxt06tfrz69d	cmo1xc12i000ovxp01nisgvnu	46000	2026-04-16 20:46:18.259	2026-04-16 20:46:18.259
cmo1y8za201nnvxt0ott9tr3o	cmo1y8z8g01n7vxt06tfrz69d	cmo1xc13o000tvxp0alok8jeb	38000	2026-04-16 20:46:18.266	2026-04-16 20:46:18.266
cmo1y8zad01npvxt0o9t60qmd	cmo1y8z8g01n7vxt06tfrz69d	cmo1xc11n000kvxp0g32oj3wx	46000	2026-04-16 20:46:18.277	2026-04-16 20:46:18.277
cmo1y8zam01nrvxt0i1ywgayo	cmo1y8z8g01n7vxt06tfrz69d	cmo1xc10u000hvxp0dapryn3r	46000	2026-04-16 20:46:18.286	2026-04-16 20:46:18.286
cmo1y8zat01ntvxt009gvnzep	cmo1y8z8g01n7vxt06tfrz69d	cmo1xc119000jvxp01snwxzoa	46000	2026-04-16 20:46:18.293	2026-04-16 20:46:18.293
cmo1y8zbb01nxvxt0f16v6igd	cmo1y8zb501nvvxt06eyefnot	cmo1xsgrt0022vxv8sd7cckj7	42000	2026-04-16 20:46:18.311	2026-04-16 20:46:18.311
cmo1y8zbh01nzvxt08swxibnp	cmo1y8zb501nvvxt06eyefnot	cmo1xc11v000lvxp07r6uljko	40000	2026-04-16 20:46:18.317	2026-04-16 20:46:18.317
cmo1y8zbm01o1vxt05bfdonsg	cmo1y8zb501nvvxt06eyefnot	cmo1xc12y000qvxp0uqc7d8d8	42000	2026-04-16 20:46:18.322	2026-04-16 20:46:18.322
cmo1y8zbs01o3vxt0gwrxaprh	cmo1y8zb501nvvxt06eyefnot	cmo1xc13g000svxp0tbndc1wg	42000	2026-04-16 20:46:18.328	2026-04-16 20:46:18.328
cmo1y8zbz01o5vxt0sjla928x	cmo1y8zb501nvvxt06eyefnot	cmo1xc12q000pvxp0kun82k4l	42000	2026-04-16 20:46:18.335	2026-04-16 20:46:18.335
cmo1y8zc401o7vxt0qx1cv2o3	cmo1y8zb501nvvxt06eyefnot	cmo1xc138000rvxp0r16wi1bz	42000	2026-04-16 20:46:18.341	2026-04-16 20:46:18.341
cmo1y8zca01o9vxt0fgajfbod	cmo1y8zb501nvvxt06eyefnot	cmo1xc12i000ovxp01nisgvnu	42000	2026-04-16 20:46:18.346	2026-04-16 20:46:18.346
cmo1y8zcg01obvxt0a5qzmyir	cmo1y8zb501nvvxt06eyefnot	cmo1xc13o000tvxp0alok8jeb	38000	2026-04-16 20:46:18.352	2026-04-16 20:46:18.352
cmo1y8zcm01odvxt0v9ixgs8t	cmo1y8zb501nvvxt06eyefnot	cmo1xc11n000kvxp0g32oj3wx	42000	2026-04-16 20:46:18.359	2026-04-16 20:46:18.359
cmo1y8zcs01ofvxt0150gzkru	cmo1y8zb501nvvxt06eyefnot	cmo1xc10u000hvxp0dapryn3r	42000	2026-04-16 20:46:18.365	2026-04-16 20:46:18.365
cmo1y8zcy01ohvxt0lowqxmll	cmo1y8zb501nvvxt06eyefnot	cmo1xc119000jvxp01snwxzoa	42000	2026-04-16 20:46:18.371	2026-04-16 20:46:18.371
cmo1y8zdd01olvxt0lrw1bwqi	cmo1y8zd501ojvxt0kevfhixq	cmo1xsgrt0022vxv8sd7cckj7	42000	2026-04-16 20:46:18.385	2026-04-16 20:46:18.385
cmo1y8zdj01onvxt0thyiz2jg	cmo1y8zd501ojvxt0kevfhixq	cmo1xc11v000lvxp07r6uljko	40000	2026-04-16 20:46:18.392	2026-04-16 20:46:18.392
cmo1y8zdq01opvxt0s26zj7no	cmo1y8zd501ojvxt0kevfhixq	cmo1xc12y000qvxp0uqc7d8d8	42000	2026-04-16 20:46:18.399	2026-04-16 20:46:18.399
cmo1y8ze001orvxt0ye6kkm36	cmo1y8zd501ojvxt0kevfhixq	cmo1xc13g000svxp0tbndc1wg	42000	2026-04-16 20:46:18.409	2026-04-16 20:46:18.409
cmo1y8zea01otvxt0y56ae0hh	cmo1y8zd501ojvxt0kevfhixq	cmo1xc12q000pvxp0kun82k4l	42000	2026-04-16 20:46:18.418	2026-04-16 20:46:18.418
cmo1y8zeh01ovvxt0sczj2l1x	cmo1y8zd501ojvxt0kevfhixq	cmo1xc138000rvxp0r16wi1bz	42000	2026-04-16 20:46:18.425	2026-04-16 20:46:18.425
cmo1y8zen01oxvxt0lbu2igso	cmo1y8zd501ojvxt0kevfhixq	cmo1xc12i000ovxp01nisgvnu	42000	2026-04-16 20:46:18.431	2026-04-16 20:46:18.431
cmo1y8zet01ozvxt0tmg12uxn	cmo1y8zd501ojvxt0kevfhixq	cmo1xc13o000tvxp0alok8jeb	38000	2026-04-16 20:46:18.438	2026-04-16 20:46:18.438
cmo1y8zez01p1vxt05srjjpz0	cmo1y8zd501ojvxt0kevfhixq	cmo1xc11n000kvxp0g32oj3wx	42000	2026-04-16 20:46:18.444	2026-04-16 20:46:18.444
cmo1y8zf501p3vxt0lpo75u6p	cmo1y8zd501ojvxt0kevfhixq	cmo1xc10u000hvxp0dapryn3r	42000	2026-04-16 20:46:18.45	2026-04-16 20:46:18.45
cmo1y8zfb01p5vxt0ymdakn4b	cmo1y8zd501ojvxt0kevfhixq	cmo1xc119000jvxp01snwxzoa	42000	2026-04-16 20:46:18.456	2026-04-16 20:46:18.456
cmo1y8zfn01p9vxt0ou3roq7g	cmo1y8zfh01p7vxt08zci0mcb	cmo1xsgrt0022vxv8sd7cckj7	42000	2026-04-16 20:46:18.467	2026-04-16 20:46:18.467
cmo1y8zft01pbvxt0793teiag	cmo1y8zfh01p7vxt08zci0mcb	cmo1xc11v000lvxp07r6uljko	40000	2026-04-16 20:46:18.474	2026-04-16 20:46:18.474
cmo1y8zfy01pdvxt0h0ev3w8y	cmo1y8zfh01p7vxt08zci0mcb	cmo1xc12y000qvxp0uqc7d8d8	42000	2026-04-16 20:46:18.479	2026-04-16 20:46:18.479
cmo1y8zg501pfvxt0vlt7xigg	cmo1y8zfh01p7vxt08zci0mcb	cmo1xc13g000svxp0tbndc1wg	42000	2026-04-16 20:46:18.485	2026-04-16 20:46:18.485
cmo1y8zgc01phvxt0sppc8g1n	cmo1y8zfh01p7vxt08zci0mcb	cmo1xc12q000pvxp0kun82k4l	42000	2026-04-16 20:46:18.493	2026-04-16 20:46:18.493
cmo1y8zgj01pjvxt0xzoc8cgt	cmo1y8zfh01p7vxt08zci0mcb	cmo1xc138000rvxp0r16wi1bz	42000	2026-04-16 20:46:18.499	2026-04-16 20:46:18.499
cmo1y8zgp01plvxt0hd4pt1lu	cmo1y8zfh01p7vxt08zci0mcb	cmo1xc12i000ovxp01nisgvnu	42000	2026-04-16 20:46:18.505	2026-04-16 20:46:18.505
cmo1y8zgv01pnvxt0152j0og3	cmo1y8zfh01p7vxt08zci0mcb	cmo1xc13o000tvxp0alok8jeb	38000	2026-04-16 20:46:18.511	2026-04-16 20:46:18.511
cmo1y8zh501ppvxt0yga46jaj	cmo1y8zfh01p7vxt08zci0mcb	cmo1xc11n000kvxp0g32oj3wx	42000	2026-04-16 20:46:18.521	2026-04-16 20:46:18.521
cmo1y8zhc01prvxt0zpuvs5oc	cmo1y8zfh01p7vxt08zci0mcb	cmo1xc10u000hvxp0dapryn3r	42000	2026-04-16 20:46:18.528	2026-04-16 20:46:18.528
cmo1y8zhl01ptvxt0pxhcyhmz	cmo1y8zfh01p7vxt08zci0mcb	cmo1xc119000jvxp01snwxzoa	42000	2026-04-16 20:46:18.537	2026-04-16 20:46:18.537
cmo1y8zi001pxvxt0mbuh1n1a	cmo1y8zhu01pvvxt0a8wu8w1n	cmo1xsgrt0022vxv8sd7cckj7	46000	2026-04-16 20:46:18.552	2026-04-16 20:46:18.552
cmo1y8zi701pzvxt0zzjqi7pu	cmo1y8zhu01pvvxt0a8wu8w1n	cmo1xc11v000lvxp07r6uljko	40000	2026-04-16 20:46:18.559	2026-04-16 20:46:18.559
cmo1y8zid01q1vxt081fyu71x	cmo1y8zhu01pvvxt0a8wu8w1n	cmo1xc12y000qvxp0uqc7d8d8	46000	2026-04-16 20:46:18.565	2026-04-16 20:46:18.565
cmo1y8zik01q3vxt0ujqxnjbo	cmo1y8zhu01pvvxt0a8wu8w1n	cmo1xc13g000svxp0tbndc1wg	46000	2026-04-16 20:46:18.572	2026-04-16 20:46:18.572
cmo1y8zis01q5vxt0oiw2t721	cmo1y8zhu01pvvxt0a8wu8w1n	cmo1xc12q000pvxp0kun82k4l	46000	2026-04-16 20:46:18.58	2026-04-16 20:46:18.58
cmo1y8ziy01q7vxt0x1kwqxsf	cmo1y8zhu01pvvxt0a8wu8w1n	cmo1xc138000rvxp0r16wi1bz	46000	2026-04-16 20:46:18.587	2026-04-16 20:46:18.587
cmo1y8zj401q9vxt0168bimgh	cmo1y8zhu01pvvxt0a8wu8w1n	cmo1xc12i000ovxp01nisgvnu	46000	2026-04-16 20:46:18.592	2026-04-16 20:46:18.592
cmo1y8zjb01qbvxt0guac6oyr	cmo1y8zhu01pvvxt0a8wu8w1n	cmo1xc13o000tvxp0alok8jeb	40000	2026-04-16 20:46:18.599	2026-04-16 20:46:18.599
cmo1y8zji01qdvxt0gltj1g66	cmo1y8zhu01pvvxt0a8wu8w1n	cmo1xc11n000kvxp0g32oj3wx	46000	2026-04-16 20:46:18.607	2026-04-16 20:46:18.607
cmo1y8zjp01qfvxt0j40yq2mx	cmo1y8zhu01pvvxt0a8wu8w1n	cmo1xc10u000hvxp0dapryn3r	46000	2026-04-16 20:46:18.613	2026-04-16 20:46:18.613
cmo1y8zjv01qhvxt0jvu345ap	cmo1y8zhu01pvvxt0a8wu8w1n	cmo1xc119000jvxp01snwxzoa	46000	2026-04-16 20:46:18.62	2026-04-16 20:46:18.62
cmo1y8zk901qlvxt0r5czagn5	cmo1y8zk101qjvxt0h6yzvl64	cmo1xsgrt0022vxv8sd7cckj7	46000	2026-04-16 20:46:18.633	2026-04-16 20:46:18.633
cmo1y8zkg01qnvxt0zqir5xj4	cmo1y8zk101qjvxt0h6yzvl64	cmo1xc11v000lvxp07r6uljko	40000	2026-04-16 20:46:18.64	2026-04-16 20:46:18.64
cmo1y8zko01qpvxt0b5woa5ok	cmo1y8zk101qjvxt0h6yzvl64	cmo1xc12y000qvxp0uqc7d8d8	46000	2026-04-16 20:46:18.648	2026-04-16 20:46:18.648
cmo1y8zkv01qrvxt0759dxyej	cmo1y8zk101qjvxt0h6yzvl64	cmo1xc13g000svxp0tbndc1wg	46000	2026-04-16 20:46:18.655	2026-04-16 20:46:18.655
cmo1y8zl501qtvxt0mfhwusx3	cmo1y8zk101qjvxt0h6yzvl64	cmo1xc12q000pvxp0kun82k4l	46000	2026-04-16 20:46:18.665	2026-04-16 20:46:18.665
cmo1y8zlb01qvvxt0i1rmufpu	cmo1y8zk101qjvxt0h6yzvl64	cmo1xc138000rvxp0r16wi1bz	46000	2026-04-16 20:46:18.672	2026-04-16 20:46:18.672
cmo1y8zli01qxvxt0v28u747y	cmo1y8zk101qjvxt0h6yzvl64	cmo1xc12i000ovxp01nisgvnu	46000	2026-04-16 20:46:18.678	2026-04-16 20:46:18.678
cmo1y8zlp01qzvxt0108upbow	cmo1y8zk101qjvxt0h6yzvl64	cmo1xc13o000tvxp0alok8jeb	40000	2026-04-16 20:46:18.685	2026-04-16 20:46:18.685
cmo1y8zly01r1vxt0zlqg979r	cmo1y8zk101qjvxt0h6yzvl64	cmo1xc11n000kvxp0g32oj3wx	46000	2026-04-16 20:46:18.694	2026-04-16 20:46:18.694
cmo1y8zm901r3vxt0m3apt3ag	cmo1y8zk101qjvxt0h6yzvl64	cmo1xc10u000hvxp0dapryn3r	46000	2026-04-16 20:46:18.706	2026-04-16 20:46:18.706
cmo1y8zmg01r5vxt0krr2mmnd	cmo1y8zk101qjvxt0h6yzvl64	cmo1xc119000jvxp01snwxzoa	46000	2026-04-16 20:46:18.712	2026-04-16 20:46:18.712
cmo1y8zn001r9vxt0hw7bjpop	cmo1y8zmq01r7vxt08juzbne2	cmo1xsgrt0022vxv8sd7cckj7	46000	2026-04-16 20:46:18.732	2026-04-16 20:46:18.732
cmo1y8zn701rbvxt0fxrof9m8	cmo1y8zmq01r7vxt08juzbne2	cmo1xc11v000lvxp07r6uljko	40000	2026-04-16 20:46:18.739	2026-04-16 20:46:18.739
cmo1y8znd01rdvxt09eob8n98	cmo1y8zmq01r7vxt08juzbne2	cmo1xc12y000qvxp0uqc7d8d8	46000	2026-04-16 20:46:18.745	2026-04-16 20:46:18.745
cmo1y8znk01rfvxt0nh8jfrg8	cmo1y8zmq01r7vxt08juzbne2	cmo1xc13g000svxp0tbndc1wg	46000	2026-04-16 20:46:18.752	2026-04-16 20:46:18.752
cmo1y8znq01rhvxt0ouetw6zm	cmo1y8zmq01r7vxt08juzbne2	cmo1xc12q000pvxp0kun82k4l	46000	2026-04-16 20:46:18.759	2026-04-16 20:46:18.759
cmo1y8znw01rjvxt0dj322y7d	cmo1y8zmq01r7vxt08juzbne2	cmo1xc138000rvxp0r16wi1bz	46000	2026-04-16 20:46:18.765	2026-04-16 20:46:18.765
cmo1y8zo401rlvxt0lq5t6c9y	cmo1y8zmq01r7vxt08juzbne2	cmo1xc12i000ovxp01nisgvnu	46000	2026-04-16 20:46:18.772	2026-04-16 20:46:18.772
cmo1y8zoc01rnvxt0vloj48mj	cmo1y8zmq01r7vxt08juzbne2	cmo1xc13o000tvxp0alok8jeb	40000	2026-04-16 20:46:18.781	2026-04-16 20:46:18.781
cmo1y8zop01rpvxt05grjfl11	cmo1y8zmq01r7vxt08juzbne2	cmo1xc11n000kvxp0g32oj3wx	46000	2026-04-16 20:46:18.793	2026-04-16 20:46:18.793
cmo1y8zov01rrvxt0yut9bsrn	cmo1y8zmq01r7vxt08juzbne2	cmo1xc10u000hvxp0dapryn3r	46000	2026-04-16 20:46:18.8	2026-04-16 20:46:18.8
cmo1y8zp101rtvxt0f5lwv67b	cmo1y8zmq01r7vxt08juzbne2	cmo1xc119000jvxp01snwxzoa	46000	2026-04-16 20:46:18.805	2026-04-16 20:46:18.805
cmo1y8zpb01rxvxt0qxxv4yym	cmo1y8zp601rvvxt0trpynwpp	cmo1xsgrt0022vxv8sd7cckj7	30000	2026-04-16 20:46:18.815	2026-04-16 20:46:18.815
cmo1y8zpg01rzvxt0fy6uc4w5	cmo1y8zp601rvvxt0trpynwpp	cmo1xc11v000lvxp07r6uljko	30000	2026-04-16 20:46:18.821	2026-04-16 20:46:18.821
cmo1y8zpm01s1vxt0bqz3j4rd	cmo1y8zp601rvvxt0trpynwpp	cmo1xc12y000qvxp0uqc7d8d8	30000	2026-04-16 20:46:18.826	2026-04-16 20:46:18.826
cmo1y8zpr01s3vxt08u9tp1gv	cmo1y8zp601rvvxt0trpynwpp	cmo1xc13g000svxp0tbndc1wg	30000	2026-04-16 20:46:18.831	2026-04-16 20:46:18.831
cmo1y8zpx01s5vxt0oc1rwufl	cmo1y8zp601rvvxt0trpynwpp	cmo1xc12q000pvxp0kun82k4l	30000	2026-04-16 20:46:18.838	2026-04-16 20:46:18.838
cmo1y8zq201s7vxt0fs4mvu1y	cmo1y8zp601rvvxt0trpynwpp	cmo1xc138000rvxp0r16wi1bz	30000	2026-04-16 20:46:18.843	2026-04-16 20:46:18.843
cmo1y8zq801s9vxt09xyb6x6f	cmo1y8zp601rvvxt0trpynwpp	cmo1xc12i000ovxp01nisgvnu	30000	2026-04-16 20:46:18.849	2026-04-16 20:46:18.849
cmo1y8zqd01sbvxt0yx39t1q6	cmo1y8zp601rvvxt0trpynwpp	cmo1xc13o000tvxp0alok8jeb	30000	2026-04-16 20:46:18.854	2026-04-16 20:46:18.854
cmo1y8zqk01sdvxt0xkdwv07b	cmo1y8zp601rvvxt0trpynwpp	cmo1xc11n000kvxp0g32oj3wx	30000	2026-04-16 20:46:18.86	2026-04-16 20:46:18.86
cmo1y8zqp01sfvxt04olpvjcy	cmo1y8zp601rvvxt0trpynwpp	cmo1xc10u000hvxp0dapryn3r	30000	2026-04-16 20:46:18.865	2026-04-16 20:46:18.865
cmo1y8zqu01shvxt0pl5lbrl9	cmo1y8zp601rvvxt0trpynwpp	cmo1xc119000jvxp01snwxzoa	30000	2026-04-16 20:46:18.871	2026-04-16 20:46:18.871
cmo1y8zr501slvxt0iofgbjsl	cmo1y8zqz01sjvxt0isho03ev	cmo1xsgrt0022vxv8sd7cckj7	30000	2026-04-16 20:46:18.881	2026-04-16 20:46:18.881
cmo1y8zra01snvxt01hklz55l	cmo1y8zqz01sjvxt0isho03ev	cmo1xc11v000lvxp07r6uljko	30000	2026-04-16 20:46:18.887	2026-04-16 20:46:18.887
cmo1y8zrf01spvxt0xbxs0a20	cmo1y8zqz01sjvxt0isho03ev	cmo1xc12y000qvxp0uqc7d8d8	30000	2026-04-16 20:46:18.892	2026-04-16 20:46:18.892
cmo1y8zrl01srvxt0o1xmpyi8	cmo1y8zqz01sjvxt0isho03ev	cmo1xc13g000svxp0tbndc1wg	30000	2026-04-16 20:46:18.898	2026-04-16 20:46:18.898
cmo1y8zrt01stvxt00t4dq1n2	cmo1y8zqz01sjvxt0isho03ev	cmo1xc12q000pvxp0kun82k4l	30000	2026-04-16 20:46:18.905	2026-04-16 20:46:18.905
cmo1y8zrz01svvxt037p2lr2u	cmo1y8zqz01sjvxt0isho03ev	cmo1xc138000rvxp0r16wi1bz	30000	2026-04-16 20:46:18.911	2026-04-16 20:46:18.911
cmo1y8zs501sxvxt0cetk44em	cmo1y8zqz01sjvxt0isho03ev	cmo1xc12i000ovxp01nisgvnu	30000	2026-04-16 20:46:18.917	2026-04-16 20:46:18.917
cmo1y8zsa01szvxt0cavsphp2	cmo1y8zqz01sjvxt0isho03ev	cmo1xc13o000tvxp0alok8jeb	30000	2026-04-16 20:46:18.923	2026-04-16 20:46:18.923
cmo1y8zsg01t1vxt0q97b08bw	cmo1y8zqz01sjvxt0isho03ev	cmo1xc11n000kvxp0g32oj3wx	30000	2026-04-16 20:46:18.929	2026-04-16 20:46:18.929
cmo1y8zsm01t3vxt0m51orkar	cmo1y8zqz01sjvxt0isho03ev	cmo1xc10u000hvxp0dapryn3r	30000	2026-04-16 20:46:18.935	2026-04-16 20:46:18.935
cmo1y8zss01t5vxt0gwcrzw8s	cmo1y8zqz01sjvxt0isho03ev	cmo1xc119000jvxp01snwxzoa	30000	2026-04-16 20:46:18.94	2026-04-16 20:46:18.94
cmo1y8zt501t9vxt0xomn3y5m	cmo1y8zsz01t7vxt0wvmvuycc	cmo1xsgrt0022vxv8sd7cckj7	30000	2026-04-16 20:46:18.953	2026-04-16 20:46:18.953
cmo1y8ztb01tbvxt07bt17smp	cmo1y8zsz01t7vxt0wvmvuycc	cmo1xc11v000lvxp07r6uljko	30000	2026-04-16 20:46:18.959	2026-04-16 20:46:18.959
cmo1y8zth01tdvxt0pzd7vmz3	cmo1y8zsz01t7vxt0wvmvuycc	cmo1xc12y000qvxp0uqc7d8d8	30000	2026-04-16 20:46:18.966	2026-04-16 20:46:18.966
cmo1y8ztp01tfvxt0bls9rh1k	cmo1y8zsz01t7vxt0wvmvuycc	cmo1xc13g000svxp0tbndc1wg	30000	2026-04-16 20:46:18.973	2026-04-16 20:46:18.973
cmo1y8zty01thvxt0rgiobzfs	cmo1y8zsz01t7vxt0wvmvuycc	cmo1xc12q000pvxp0kun82k4l	30000	2026-04-16 20:46:18.982	2026-04-16 20:46:18.982
cmo1y8zu501tjvxt0np6fl2im	cmo1y8zsz01t7vxt0wvmvuycc	cmo1xc138000rvxp0r16wi1bz	30000	2026-04-16 20:46:18.989	2026-04-16 20:46:18.989
cmo1y8zud01tlvxt0xorh1xte	cmo1y8zsz01t7vxt0wvmvuycc	cmo1xc12i000ovxp01nisgvnu	30000	2026-04-16 20:46:18.997	2026-04-16 20:46:18.997
cmo1y8zuk01tnvxt0lxaanq40	cmo1y8zsz01t7vxt0wvmvuycc	cmo1xc13o000tvxp0alok8jeb	30000	2026-04-16 20:46:19.004	2026-04-16 20:46:19.004
cmo1y8zus01tpvxt0hxnv4mrk	cmo1y8zsz01t7vxt0wvmvuycc	cmo1xc11n000kvxp0g32oj3wx	30000	2026-04-16 20:46:19.013	2026-04-16 20:46:19.013
cmo1y8zv201trvxt04m9bfiif	cmo1y8zsz01t7vxt0wvmvuycc	cmo1xc10u000hvxp0dapryn3r	30000	2026-04-16 20:46:19.022	2026-04-16 20:46:19.022
cmo1y8zva01ttvxt06ps9bph2	cmo1y8zsz01t7vxt0wvmvuycc	cmo1xc119000jvxp01snwxzoa	30000	2026-04-16 20:46:19.03	2026-04-16 20:46:19.03
cmo1y8zvq01txvxt0eqqfub68	cmo1y8zvj01tvvxt0n2rh99gh	cmo1xsgrt0022vxv8sd7cckj7	40500	2026-04-16 20:46:19.046	2026-04-16 20:46:19.046
cmo1y8zvx01tzvxt05e3h9a4j	cmo1y8zvj01tvvxt0n2rh99gh	cmo1xc11v000lvxp07r6uljko	40500	2026-04-16 20:46:19.053	2026-04-16 20:46:19.053
cmo1y8zw301u1vxt0fyflky5p	cmo1y8zvj01tvvxt0n2rh99gh	cmo1xc12y000qvxp0uqc7d8d8	40500	2026-04-16 20:46:19.059	2026-04-16 20:46:19.059
cmo1y8zw801u3vxt08a7gfwj4	cmo1y8zvj01tvvxt0n2rh99gh	cmo1xc13g000svxp0tbndc1wg	40500	2026-04-16 20:46:19.065	2026-04-16 20:46:19.065
cmo1y8zwg01u5vxt0qhkeph8y	cmo1y8zvj01tvvxt0n2rh99gh	cmo1xc12q000pvxp0kun82k4l	40500	2026-04-16 20:46:19.072	2026-04-16 20:46:19.072
cmo1y8zwl01u7vxt0qypmhy8z	cmo1y8zvj01tvvxt0n2rh99gh	cmo1xc138000rvxp0r16wi1bz	40500	2026-04-16 20:46:19.077	2026-04-16 20:46:19.077
cmo1y8zwq01u9vxt0gy3iqkut	cmo1y8zvj01tvvxt0n2rh99gh	cmo1xc12i000ovxp01nisgvnu	40500	2026-04-16 20:46:19.082	2026-04-16 20:46:19.082
cmo1y8zwv01ubvxt0zw600ihy	cmo1y8zvj01tvvxt0n2rh99gh	cmo1xc13o000tvxp0alok8jeb	40500	2026-04-16 20:46:19.088	2026-04-16 20:46:19.088
cmo1y8zx201udvxt0xzslstdr	cmo1y8zvj01tvvxt0n2rh99gh	cmo1xc11n000kvxp0g32oj3wx	40500	2026-04-16 20:46:19.094	2026-04-16 20:46:19.094
cmo1y8zx701ufvxt08wie72yn	cmo1y8zvj01tvvxt0n2rh99gh	cmo1xc10u000hvxp0dapryn3r	40500	2026-04-16 20:46:19.099	2026-04-16 20:46:19.099
cmo1y8zxc01uhvxt08zv8o2k3	cmo1y8zvj01tvvxt0n2rh99gh	cmo1xc119000jvxp01snwxzoa	40500	2026-04-16 20:46:19.105	2026-04-16 20:46:19.105
cmo1y8zxn01ulvxt0tv13rbhz	cmo1y8zxh01ujvxt0z7cac81f	cmo1xsgrt0022vxv8sd7cckj7	40500	2026-04-16 20:46:19.115	2026-04-16 20:46:19.115
cmo1y8zxt01unvxt0sl0fy3hs	cmo1y8zxh01ujvxt0z7cac81f	cmo1xc11v000lvxp07r6uljko	40500	2026-04-16 20:46:19.122	2026-04-16 20:46:19.122
cmo1y8zxz01upvxt0110zih77	cmo1y8zxh01ujvxt0z7cac81f	cmo1xc12y000qvxp0uqc7d8d8	40500	2026-04-16 20:46:19.127	2026-04-16 20:46:19.127
cmo1y8zy501urvxt0ynzzc2u4	cmo1y8zxh01ujvxt0z7cac81f	cmo1xc13g000svxp0tbndc1wg	40500	2026-04-16 20:46:19.133	2026-04-16 20:46:19.133
cmo1y8zyd01utvxt0yhfnyuzq	cmo1y8zxh01ujvxt0z7cac81f	cmo1xc12q000pvxp0kun82k4l	40500	2026-04-16 20:46:19.141	2026-04-16 20:46:19.141
cmo1y8zyk01uvvxt029jonm4i	cmo1y8zxh01ujvxt0z7cac81f	cmo1xc138000rvxp0r16wi1bz	40500	2026-04-16 20:46:19.148	2026-04-16 20:46:19.148
cmo1y8zyq01uxvxt0kvij9i7k	cmo1y8zxh01ujvxt0z7cac81f	cmo1xc12i000ovxp01nisgvnu	40500	2026-04-16 20:46:19.155	2026-04-16 20:46:19.155
cmo1y8zyw01uzvxt0t6qh0gar	cmo1y8zxh01ujvxt0z7cac81f	cmo1xc13o000tvxp0alok8jeb	40500	2026-04-16 20:46:19.161	2026-04-16 20:46:19.161
cmo1y8zz401v1vxt0cumza5ct	cmo1y8zxh01ujvxt0z7cac81f	cmo1xc11n000kvxp0g32oj3wx	40500	2026-04-16 20:46:19.168	2026-04-16 20:46:19.168
cmo1y8zza01v3vxt08zr1e3n4	cmo1y8zxh01ujvxt0z7cac81f	cmo1xc10u000hvxp0dapryn3r	40500	2026-04-16 20:46:19.174	2026-04-16 20:46:19.174
cmo1y8zzg01v5vxt0es7ccebz	cmo1y8zxh01ujvxt0z7cac81f	cmo1xc119000jvxp01snwxzoa	40500	2026-04-16 20:46:19.181	2026-04-16 20:46:19.181
cmo1y8zzt01v9vxt0q012uc98	cmo1y8zzn01v7vxt0ta2rb6ex	cmo1xsgrt0022vxv8sd7cckj7	40500	2026-04-16 20:46:19.193	2026-04-16 20:46:19.193
cmo1y8zzy01vbvxt04wp7knnl	cmo1y8zzn01v7vxt0ta2rb6ex	cmo1xc11v000lvxp07r6uljko	40500	2026-04-16 20:46:19.198	2026-04-16 20:46:19.198
cmo1y900401vdvxt0l6748she	cmo1y8zzn01v7vxt0ta2rb6ex	cmo1xc12y000qvxp0uqc7d8d8	40500	2026-04-16 20:46:19.205	2026-04-16 20:46:19.205
cmo1y900b01vfvxt0pvaqzb5w	cmo1y8zzn01v7vxt0ta2rb6ex	cmo1xc13g000svxp0tbndc1wg	40500	2026-04-16 20:46:19.211	2026-04-16 20:46:19.211
cmo1y900i01vhvxt0nqmfqdyk	cmo1y8zzn01v7vxt0ta2rb6ex	cmo1xc12q000pvxp0kun82k4l	40500	2026-04-16 20:46:19.219	2026-04-16 20:46:19.219
cmo1y900p01vjvxt0t0pnfcfe	cmo1y8zzn01v7vxt0ta2rb6ex	cmo1xc138000rvxp0r16wi1bz	40500	2026-04-16 20:46:19.225	2026-04-16 20:46:19.225
cmo1y900v01vlvxt02q3djwn6	cmo1y8zzn01v7vxt0ta2rb6ex	cmo1xc12i000ovxp01nisgvnu	40500	2026-04-16 20:46:19.231	2026-04-16 20:46:19.231
cmo1y901101vnvxt0fqb1pr2q	cmo1y8zzn01v7vxt0ta2rb6ex	cmo1xc13o000tvxp0alok8jeb	40500	2026-04-16 20:46:19.238	2026-04-16 20:46:19.238
cmo1y901801vpvxt0t6bb8u9y	cmo1y8zzn01v7vxt0ta2rb6ex	cmo1xc11n000kvxp0g32oj3wx	40500	2026-04-16 20:46:19.244	2026-04-16 20:46:19.244
cmo1y901e01vrvxt00uktp3k3	cmo1y8zzn01v7vxt0ta2rb6ex	cmo1xc10u000hvxp0dapryn3r	40500	2026-04-16 20:46:19.25	2026-04-16 20:46:19.25
cmo1y901k01vtvxt02m6v14b7	cmo1y8zzn01v7vxt0ta2rb6ex	cmo1xc119000jvxp01snwxzoa	40500	2026-04-16 20:46:19.257	2026-04-16 20:46:19.257
cmo1y901z01vxvxt0aq2slt8p	cmo1y901r01vvvxt0bgh9me63	cmo1xsgrt0022vxv8sd7cckj7	89000	2026-04-16 20:46:19.271	2026-04-16 20:46:19.271
cmo1y902801vzvxt0gqjapd1m	cmo1y901r01vvvxt0bgh9me63	cmo1xc11v000lvxp07r6uljko	89000	2026-04-16 20:46:19.28	2026-04-16 20:46:19.28
cmo1y902i01w1vxt002djqggn	cmo1y901r01vvvxt0bgh9me63	cmo1xc12y000qvxp0uqc7d8d8	89000	2026-04-16 20:46:19.291	2026-04-16 20:46:19.291
cmo1y902r01w3vxt0sm74775t	cmo1y901r01vvvxt0bgh9me63	cmo1xc13g000svxp0tbndc1wg	89000	2026-04-16 20:46:19.299	2026-04-16 20:46:19.299
cmo1y902z01w5vxt08nz2j9te	cmo1y901r01vvvxt0bgh9me63	cmo1xc12q000pvxp0kun82k4l	89000	2026-04-16 20:46:19.307	2026-04-16 20:46:19.307
cmo1y903601w7vxt0pa45ti42	cmo1y901r01vvvxt0bgh9me63	cmo1xc138000rvxp0r16wi1bz	82000	2026-04-16 20:46:19.314	2026-04-16 20:46:19.314
cmo1y903e01w9vxt0kocgayuf	cmo1y901r01vvvxt0bgh9me63	cmo1xc12i000ovxp01nisgvnu	89000	2026-04-16 20:46:19.322	2026-04-16 20:46:19.322
cmo1y903k01wbvxt0yw11z1va	cmo1y901r01vvvxt0bgh9me63	cmo1xc13o000tvxp0alok8jeb	82000	2026-04-16 20:46:19.328	2026-04-16 20:46:19.328
cmo1y903q01wdvxt0ezeyfmuv	cmo1y901r01vvvxt0bgh9me63	cmo1xc123000mvxp0ul7pkio2	82000	2026-04-16 20:46:19.335	2026-04-16 20:46:19.335
cmo1y903x01wfvxt0ufa31brp	cmo1y901r01vvvxt0bgh9me63	cmo1xc11n000kvxp0g32oj3wx	89000	2026-04-16 20:46:19.341	2026-04-16 20:46:19.341
cmo1y904301whvxt0jdrosmo6	cmo1y901r01vvvxt0bgh9me63	cmo1xc10u000hvxp0dapryn3r	89000	2026-04-16 20:46:19.348	2026-04-16 20:46:19.348
cmo1y904b01wjvxt04q9vq0gf	cmo1y901r01vvvxt0bgh9me63	cmo1xc119000jvxp01snwxzoa	89000	2026-04-16 20:46:19.355	2026-04-16 20:46:19.355
cmo1y904n01wnvxt0w8ujzt09	cmo1y904h01wlvxt0oooctw2b	cmo1xsgrt0022vxv8sd7cckj7	94000	2026-04-16 20:46:19.367	2026-04-16 20:46:19.367
cmo1y904u01wpvxt00n1ofh34	cmo1y904h01wlvxt0oooctw2b	cmo1xc11v000lvxp07r6uljko	94000	2026-04-16 20:46:19.375	2026-04-16 20:46:19.375
cmo1y905101wrvxt0p2vw29w8	cmo1y904h01wlvxt0oooctw2b	cmo1xc12y000qvxp0uqc7d8d8	94000	2026-04-16 20:46:19.381	2026-04-16 20:46:19.381
cmo1y905901wtvxt0yk4g809z	cmo1y904h01wlvxt0oooctw2b	cmo1xc13g000svxp0tbndc1wg	94000	2026-04-16 20:46:19.389	2026-04-16 20:46:19.389
cmo1y905h01wvvxt0otk860g6	cmo1y904h01wlvxt0oooctw2b	cmo1xc12q000pvxp0kun82k4l	94000	2026-04-16 20:46:19.397	2026-04-16 20:46:19.397
cmo1y905q01wxvxt0u1xauomu	cmo1y904h01wlvxt0oooctw2b	cmo1xc138000rvxp0r16wi1bz	82000	2026-04-16 20:46:19.406	2026-04-16 20:46:19.406
cmo1y905x01wzvxt0vj13q41x	cmo1y904h01wlvxt0oooctw2b	cmo1xc12i000ovxp01nisgvnu	94000	2026-04-16 20:46:19.413	2026-04-16 20:46:19.413
cmo1y906501x1vxt0liehl7bg	cmo1y904h01wlvxt0oooctw2b	cmo1xc13o000tvxp0alok8jeb	82000	2026-04-16 20:46:19.421	2026-04-16 20:46:19.421
cmo1y906b01x3vxt0md7tmob2	cmo1y904h01wlvxt0oooctw2b	cmo1xc123000mvxp0ul7pkio2	82000	2026-04-16 20:46:19.427	2026-04-16 20:46:19.427
cmo1y906g01x5vxt0ehhy0cgt	cmo1y904h01wlvxt0oooctw2b	cmo1xc11n000kvxp0g32oj3wx	94000	2026-04-16 20:46:19.433	2026-04-16 20:46:19.433
cmo1y906m01x7vxt0figo2yxn	cmo1y904h01wlvxt0oooctw2b	cmo1xc10u000hvxp0dapryn3r	94000	2026-04-16 20:46:19.439	2026-04-16 20:46:19.439
cmo1y906s01x9vxt0g58u4jr6	cmo1y904h01wlvxt0oooctw2b	cmo1xc119000jvxp01snwxzoa	94000	2026-04-16 20:46:19.444	2026-04-16 20:46:19.444
cmo1y907401xdvxt060ogie9z	cmo1y906y01xbvxt0l1j904r1	cmo1xsgrt0022vxv8sd7cckj7	100000	2026-04-16 20:46:19.456	2026-04-16 20:46:19.456
cmo1y907901xfvxt0rqepq7oj	cmo1y906y01xbvxt0l1j904r1	cmo1xc11v000lvxp07r6uljko	100000	2026-04-16 20:46:19.461	2026-04-16 20:46:19.461
cmo1y907e01xhvxt0ly97efjo	cmo1y906y01xbvxt0l1j904r1	cmo1xc12y000qvxp0uqc7d8d8	100000	2026-04-16 20:46:19.466	2026-04-16 20:46:19.466
cmo1y907k01xjvxt0foe1k6f9	cmo1y906y01xbvxt0l1j904r1	cmo1xc13g000svxp0tbndc1wg	100000	2026-04-16 20:46:19.472	2026-04-16 20:46:19.472
cmo1y907q01xlvxt0pujwmfa4	cmo1y906y01xbvxt0l1j904r1	cmo1xc12q000pvxp0kun82k4l	100000	2026-04-16 20:46:19.478	2026-04-16 20:46:19.478
cmo1y908201xnvxt0ivbyro1d	cmo1y906y01xbvxt0l1j904r1	cmo1xc12i000ovxp01nisgvnu	100000	2026-04-16 20:46:19.49	2026-04-16 20:46:19.49
cmo1y908d01xpvxt0hzk24p8v	cmo1y906y01xbvxt0l1j904r1	cmo1xc11n000kvxp0g32oj3wx	100000	2026-04-16 20:46:19.501	2026-04-16 20:46:19.501
cmo1y908k01xrvxt0743q597p	cmo1y906y01xbvxt0l1j904r1	cmo1xc10u000hvxp0dapryn3r	100000	2026-04-16 20:46:19.508	2026-04-16 20:46:19.508
cmo1y908x01xtvxt0pf10f1a1	cmo1y906y01xbvxt0l1j904r1	cmo1xc119000jvxp01snwxzoa	100000	2026-04-16 20:46:19.521	2026-04-16 20:46:19.521
cmo1y909s01xxvxt0h0qz1sht	cmo1y909b01xvvxt0ebcbcjyr	cmo1xsgrt0022vxv8sd7cckj7	95000	2026-04-16 20:46:19.553	2026-04-16 20:46:19.553
cmo1y90b101xzvxt037zhqwk6	cmo1y909b01xvvxt0ebcbcjyr	cmo1xc11v000lvxp07r6uljko	95000	2026-04-16 20:46:19.597	2026-04-16 20:46:19.597
cmo1y90bk01y1vxt0h8h97jbe	cmo1y909b01xvvxt0ebcbcjyr	cmo1xc12y000qvxp0uqc7d8d8	95000	2026-04-16 20:46:19.616	2026-04-16 20:46:19.616
cmo1y90by01y3vxt0ksj5i0bv	cmo1y909b01xvvxt0ebcbcjyr	cmo1xc13g000svxp0tbndc1wg	95000	2026-04-16 20:46:19.63	2026-04-16 20:46:19.63
cmo1y90d601y5vxt0g07cshkd	cmo1y909b01xvvxt0ebcbcjyr	cmo1xc12q000pvxp0kun82k4l	95000	2026-04-16 20:46:19.674	2026-04-16 20:46:19.674
cmo1y90dx01y7vxt0pltpjbj8	cmo1y909b01xvvxt0ebcbcjyr	cmo1xc138000rvxp0r16wi1bz	90000	2026-04-16 20:46:19.702	2026-04-16 20:46:19.702
cmo1y90ew01y9vxt00lj7mwc0	cmo1y909b01xvvxt0ebcbcjyr	cmo1xc12i000ovxp01nisgvnu	95000	2026-04-16 20:46:19.736	2026-04-16 20:46:19.736
cmo1y90gz01ybvxt0tacsccm8	cmo1y909b01xvvxt0ebcbcjyr	cmo1xc13o000tvxp0alok8jeb	90000	2026-04-16 20:46:19.811	2026-04-16 20:46:19.811
cmo1y90is01ydvxt07ybjvpxy	cmo1y909b01xvvxt0ebcbcjyr	cmo1xc123000mvxp0ul7pkio2	90000	2026-04-16 20:46:19.876	2026-04-16 20:46:19.876
cmo1y90ja01yfvxt0651yfpv1	cmo1y909b01xvvxt0ebcbcjyr	cmo1xc11n000kvxp0g32oj3wx	95000	2026-04-16 20:46:19.894	2026-04-16 20:46:19.894
cmo1y90jq01yhvxt05g6et7gw	cmo1y909b01xvvxt0ebcbcjyr	cmo1xc10u000hvxp0dapryn3r	95000	2026-04-16 20:46:19.91	2026-04-16 20:46:19.91
cmo1y90k001yjvxt0zmc3nol6	cmo1y909b01xvvxt0ebcbcjyr	cmo1xc119000jvxp01snwxzoa	95000	2026-04-16 20:46:19.92	2026-04-16 20:46:19.92
cmo1y90kg01ynvxt01qnjwgl2	cmo1y90k701ylvxt0yb8cye1f	cmo1xsgrt0022vxv8sd7cckj7	95000	2026-04-16 20:46:19.936	2026-04-16 20:46:19.936
cmo1y90l701ypvxt0tgyscwrc	cmo1y90k701ylvxt0yb8cye1f	cmo1xc11v000lvxp07r6uljko	95000	2026-04-16 20:46:19.963	2026-04-16 20:46:19.963
cmo1y90lq01yrvxt0hx0jk84n	cmo1y90k701ylvxt0yb8cye1f	cmo1xc12y000qvxp0uqc7d8d8	95000	2026-04-16 20:46:19.982	2026-04-16 20:46:19.982
cmo1y90lx01ytvxt04ne3wmir	cmo1y90k701ylvxt0yb8cye1f	cmo1xc13g000svxp0tbndc1wg	95000	2026-04-16 20:46:19.989	2026-04-16 20:46:19.989
cmo1y90m501yvvxt0i7xi8q12	cmo1y90k701ylvxt0yb8cye1f	cmo1xc12q000pvxp0kun82k4l	95000	2026-04-16 20:46:19.998	2026-04-16 20:46:19.998
cmo1y90md01yxvxt0e3nz6mu1	cmo1y90k701ylvxt0yb8cye1f	cmo1xc138000rvxp0r16wi1bz	90000	2026-04-16 20:46:20.005	2026-04-16 20:46:20.005
cmo1y90mq01yzvxt03oepneik	cmo1y90k701ylvxt0yb8cye1f	cmo1xc12i000ovxp01nisgvnu	95000	2026-04-16 20:46:20.019	2026-04-16 20:46:20.019
cmo1y90n201z1vxt0zteshw5h	cmo1y90k701ylvxt0yb8cye1f	cmo1xc13o000tvxp0alok8jeb	90000	2026-04-16 20:46:20.03	2026-04-16 20:46:20.03
cmo1y90o701z3vxt0iu5joa8w	cmo1y90k701ylvxt0yb8cye1f	cmo1xc123000mvxp0ul7pkio2	90000	2026-04-16 20:46:20.071	2026-04-16 20:46:20.071
cmo1y90p901z5vxt0r2cskm3h	cmo1y90k701ylvxt0yb8cye1f	cmo1xc11n000kvxp0g32oj3wx	95000	2026-04-16 20:46:20.11	2026-04-16 20:46:20.11
cmo1y90q801z7vxt0871sjsh8	cmo1y90k701ylvxt0yb8cye1f	cmo1xc10u000hvxp0dapryn3r	95000	2026-04-16 20:46:20.144	2026-04-16 20:46:20.144
cmo1y90se01z9vxt0i7z6ba3v	cmo1y90k701ylvxt0yb8cye1f	cmo1xc119000jvxp01snwxzoa	95000	2026-04-16 20:46:20.222	2026-04-16 20:46:20.222
cmo1y90y401zdvxt0uv5j6uzs	cmo1y90uo01zbvxt0d3m49lb5	cmo1xsgrt0022vxv8sd7cckj7	95000	2026-04-16 20:46:20.428	2026-04-16 20:46:20.428
cmo1y90yi01zfvxt09b6305d1	cmo1y90uo01zbvxt0d3m49lb5	cmo1xc11v000lvxp07r6uljko	95000	2026-04-16 20:46:20.442	2026-04-16 20:46:20.442
cmo1y90ys01zhvxt0835nfnr2	cmo1y90uo01zbvxt0d3m49lb5	cmo1xc12y000qvxp0uqc7d8d8	95000	2026-04-16 20:46:20.452	2026-04-16 20:46:20.452
cmo1y90z501zjvxt03lggqu2k	cmo1y90uo01zbvxt0d3m49lb5	cmo1xc13g000svxp0tbndc1wg	95000	2026-04-16 20:46:20.465	2026-04-16 20:46:20.465
cmo1y90zf01zlvxt0x5li30vj	cmo1y90uo01zbvxt0d3m49lb5	cmo1xc12q000pvxp0kun82k4l	95000	2026-04-16 20:46:20.475	2026-04-16 20:46:20.475
cmo1y90zm01znvxt0p19a1don	cmo1y90uo01zbvxt0d3m49lb5	cmo1xc138000rvxp0r16wi1bz	82000	2026-04-16 20:46:20.482	2026-04-16 20:46:20.482
cmo1y90zz01zpvxt0zkb5k0mi	cmo1y90uo01zbvxt0d3m49lb5	cmo1xc12i000ovxp01nisgvnu	95000	2026-04-16 20:46:20.495	2026-04-16 20:46:20.495
cmo1y911901zrvxt0pwlprd87	cmo1y90uo01zbvxt0d3m49lb5	cmo1xc13o000tvxp0alok8jeb	82000	2026-04-16 20:46:20.541	2026-04-16 20:46:20.541
cmo1y911g01ztvxt0yotej329	cmo1y90uo01zbvxt0d3m49lb5	cmo1xc123000mvxp0ul7pkio2	82000	2026-04-16 20:46:20.549	2026-04-16 20:46:20.549
cmo1y911p01zvvxt0t7c3ra9r	cmo1y90uo01zbvxt0d3m49lb5	cmo1xc11n000kvxp0g32oj3wx	95000	2026-04-16 20:46:20.557	2026-04-16 20:46:20.557
cmo1y911v01zxvxt05oyjikcm	cmo1y90uo01zbvxt0d3m49lb5	cmo1xc10u000hvxp0dapryn3r	95000	2026-04-16 20:46:20.563	2026-04-16 20:46:20.563
cmo1y912201zzvxt01nwm93xg	cmo1y90uo01zbvxt0d3m49lb5	cmo1xc119000jvxp01snwxzoa	95000	2026-04-16 20:46:20.57	2026-04-16 20:46:20.57
cmo1y912j0203vxt0v1b8r4au	cmo1y91290201vxt06zkmipm2	cmo1xsgrt0022vxv8sd7cckj7	84000	2026-04-16 20:46:20.588	2026-04-16 20:46:20.588
cmo1y912q0205vxt0o7vmi0vc	cmo1y91290201vxt06zkmipm2	cmo1xc11v000lvxp07r6uljko	84000	2026-04-16 20:46:20.594	2026-04-16 20:46:20.594
cmo1y91310207vxt0zuo4hxqw	cmo1y91290201vxt06zkmipm2	cmo1xc12y000qvxp0uqc7d8d8	84000	2026-04-16 20:46:20.606	2026-04-16 20:46:20.606
cmo1y913b0209vxt0g1mw9fui	cmo1y91290201vxt06zkmipm2	cmo1xc13g000svxp0tbndc1wg	84000	2026-04-16 20:46:20.616	2026-04-16 20:46:20.616
cmo1y913l020bvxt00pf2nooj	cmo1y91290201vxt06zkmipm2	cmo1xc12q000pvxp0kun82k4l	84000	2026-04-16 20:46:20.626	2026-04-16 20:46:20.626
cmo1y913s020dvxt0w3pvq6oq	cmo1y91290201vxt06zkmipm2	cmo1xc138000rvxp0r16wi1bz	84000	2026-04-16 20:46:20.633	2026-04-16 20:46:20.633
cmo1y913z020fvxt0k6cc2tvu	cmo1y91290201vxt06zkmipm2	cmo1xc12i000ovxp01nisgvnu	84000	2026-04-16 20:46:20.64	2026-04-16 20:46:20.64
cmo1y9145020hvxt01zw716tf	cmo1y91290201vxt06zkmipm2	cmo1xc13o000tvxp0alok8jeb	84000	2026-04-16 20:46:20.645	2026-04-16 20:46:20.645
cmo1y914e020jvxt0pv8es7jl	cmo1y91290201vxt06zkmipm2	cmo1xc123000mvxp0ul7pkio2	84000	2026-04-16 20:46:20.654	2026-04-16 20:46:20.654
cmo1y914l020lvxt0lg42c9r5	cmo1y91290201vxt06zkmipm2	cmo1xc11n000kvxp0g32oj3wx	84000	2026-04-16 20:46:20.661	2026-04-16 20:46:20.661
cmo1y914w020nvxt02n6alevw	cmo1y91290201vxt06zkmipm2	cmo1xc10u000hvxp0dapryn3r	84000	2026-04-16 20:46:20.673	2026-04-16 20:46:20.673
cmo1y9155020pvxt0zzz7vtgi	cmo1y91290201vxt06zkmipm2	cmo1xc119000jvxp01snwxzoa	84000	2026-04-16 20:46:20.682	2026-04-16 20:46:20.682
cmo1y915n020tvxt0shwreh8c	cmo1y915e020rvxt0rnies3mx	cmo1xsgrt0022vxv8sd7cckj7	95000	2026-04-16 20:46:20.699	2026-04-16 20:46:20.699
cmo1y915w020vvxt0sp85l5je	cmo1y915e020rvxt0rnies3mx	cmo1xc11v000lvxp07r6uljko	95000	2026-04-16 20:46:20.709	2026-04-16 20:46:20.709
cmo1y9165020xvxt044n1dl9s	cmo1y915e020rvxt0rnies3mx	cmo1xc12y000qvxp0uqc7d8d8	95000	2026-04-16 20:46:20.717	2026-04-16 20:46:20.717
cmo1y916d020zvxt0lrftlyr1	cmo1y915e020rvxt0rnies3mx	cmo1xc13g000svxp0tbndc1wg	95000	2026-04-16 20:46:20.725	2026-04-16 20:46:20.725
cmo1y916n0211vxt0qc71qrto	cmo1y915e020rvxt0rnies3mx	cmo1xc12q000pvxp0kun82k4l	95000	2026-04-16 20:46:20.735	2026-04-16 20:46:20.735
cmo1y916y0213vxt0wl4nok2h	cmo1y915e020rvxt0rnies3mx	cmo1xc138000rvxp0r16wi1bz	95000	2026-04-16 20:46:20.747	2026-04-16 20:46:20.747
cmo1y91790215vxt0tdgtx7ys	cmo1y915e020rvxt0rnies3mx	cmo1xc12i000ovxp01nisgvnu	95000	2026-04-16 20:46:20.757	2026-04-16 20:46:20.757
cmo1y917j0217vxt0jgt0v08r	cmo1y915e020rvxt0rnies3mx	cmo1xc13o000tvxp0alok8jeb	95000	2026-04-16 20:46:20.768	2026-04-16 20:46:20.768
cmo1y917t0219vxt0e5v9q4ts	cmo1y915e020rvxt0rnies3mx	cmo1xc11n000kvxp0g32oj3wx	95000	2026-04-16 20:46:20.777	2026-04-16 20:46:20.777
cmo1y917y021bvxt0j2ffbtnd	cmo1y915e020rvxt0rnies3mx	cmo1xc10u000hvxp0dapryn3r	95000	2026-04-16 20:46:20.783	2026-04-16 20:46:20.783
cmo1y9185021dvxt0y862eity	cmo1y915e020rvxt0rnies3mx	cmo1xc119000jvxp01snwxzoa	95000	2026-04-16 20:46:20.79	2026-04-16 20:46:20.79
cmo1y918l021hvxt0u369e1z3	cmo1y918d021fvxt06qdfm1x6	cmo1xsgrt0022vxv8sd7cckj7	140000	2026-04-16 20:46:20.805	2026-04-16 20:46:20.805
cmo1y918s021jvxt03qua2dvy	cmo1y918d021fvxt06qdfm1x6	cmo1xc11v000lvxp07r6uljko	140000	2026-04-16 20:46:20.812	2026-04-16 20:46:20.812
cmo1y918z021lvxt0sxashhoy	cmo1y918d021fvxt06qdfm1x6	cmo1xc12y000qvxp0uqc7d8d8	140000	2026-04-16 20:46:20.82	2026-04-16 20:46:20.82
cmo1y9197021nvxt09so9iy8w	cmo1y918d021fvxt06qdfm1x6	cmo1xc13g000svxp0tbndc1wg	140000	2026-04-16 20:46:20.827	2026-04-16 20:46:20.827
cmo1y919e021pvxt0p1u61ki1	cmo1y918d021fvxt06qdfm1x6	cmo1xc12q000pvxp0kun82k4l	140000	2026-04-16 20:46:20.834	2026-04-16 20:46:20.834
cmo1y919l021rvxt0i31xkg1h	cmo1y918d021fvxt06qdfm1x6	cmo1xc138000rvxp0r16wi1bz	140000	2026-04-16 20:46:20.841	2026-04-16 20:46:20.841
cmo1y919s021tvxt0r27qimje	cmo1y918d021fvxt06qdfm1x6	cmo1xc12i000ovxp01nisgvnu	140000	2026-04-16 20:46:20.848	2026-04-16 20:46:20.848
cmo1y919z021vvxt0xh3p0rbf	cmo1y918d021fvxt06qdfm1x6	cmo1xc13o000tvxp0alok8jeb	128000	2026-04-16 20:46:20.855	2026-04-16 20:46:20.855
cmo1y91a8021xvxt09tlres4h	cmo1y918d021fvxt06qdfm1x6	cmo1xc123000mvxp0ul7pkio2	128000	2026-04-16 20:46:20.864	2026-04-16 20:46:20.864
cmo1y91ag021zvxt0gcpm8mob	cmo1y918d021fvxt06qdfm1x6	cmo1xc11n000kvxp0g32oj3wx	140000	2026-04-16 20:46:20.872	2026-04-16 20:46:20.872
cmo1y91ap0221vxt0u0sxhsy0	cmo1y918d021fvxt06qdfm1x6	cmo1xc10u000hvxp0dapryn3r	140000	2026-04-16 20:46:20.882	2026-04-16 20:46:20.882
cmo1y91ax0223vxt00fac3a65	cmo1y918d021fvxt06qdfm1x6	cmo1xc119000jvxp01snwxzoa	140000	2026-04-16 20:46:20.889	2026-04-16 20:46:20.889
cmo1y91be0227vxt0kextnf68	cmo1y91b60225vxt0231a42gg	cmo1xsgrt0022vxv8sd7cckj7	166000	2026-04-16 20:46:20.906	2026-04-16 20:46:20.906
cmo1y91bn0229vxt0sev4ounz	cmo1y91b60225vxt0231a42gg	cmo1xc11v000lvxp07r6uljko	166000	2026-04-16 20:46:20.915	2026-04-16 20:46:20.915
cmo1y91bv022bvxt0uohryzsu	cmo1y91b60225vxt0231a42gg	cmo1xc12y000qvxp0uqc7d8d8	166000	2026-04-16 20:46:20.923	2026-04-16 20:46:20.923
cmo1y91c2022dvxt0u8byoe6f	cmo1y91b60225vxt0231a42gg	cmo1xc13g000svxp0tbndc1wg	166000	2026-04-16 20:46:20.93	2026-04-16 20:46:20.93
cmo1y91cd022fvxt0fgkkyzk3	cmo1y91b60225vxt0231a42gg	cmo1xc12q000pvxp0kun82k4l	166000	2026-04-16 20:46:20.941	2026-04-16 20:46:20.941
cmo1y91ck022hvxt0hupgodhf	cmo1y91b60225vxt0231a42gg	cmo1xc138000rvxp0r16wi1bz	166000	2026-04-16 20:46:20.949	2026-04-16 20:46:20.949
cmo1y91cr022jvxt0icayspcj	cmo1y91b60225vxt0231a42gg	cmo1xc12i000ovxp01nisgvnu	166000	2026-04-16 20:46:20.955	2026-04-16 20:46:20.955
cmo1y91cy022lvxt0mucln27e	cmo1y91b60225vxt0231a42gg	cmo1xc13o000tvxp0alok8jeb	160000	2026-04-16 20:46:20.962	2026-04-16 20:46:20.962
cmo1y91dd022nvxt0v2v2bkk3	cmo1y91b60225vxt0231a42gg	cmo1xc11n000kvxp0g32oj3wx	166000	2026-04-16 20:46:20.977	2026-04-16 20:46:20.977
cmo1y91do022pvxt0fungvo2d	cmo1y91b60225vxt0231a42gg	cmo1xc10u000hvxp0dapryn3r	166000	2026-04-16 20:46:20.988	2026-04-16 20:46:20.988
cmo1y91dy022rvxt054ng6js4	cmo1y91b60225vxt0231a42gg	cmo1xc119000jvxp01snwxzoa	166000	2026-04-16 20:46:20.998	2026-04-16 20:46:20.998
cmo1y91eg022vvxt0za41ee01	cmo1y91e8022tvxt0d5l4c4og	cmo1xsgrt0022vxv8sd7cckj7	61000	2026-04-16 20:46:21.016	2026-04-16 20:46:21.016
cmo1y91ev022xvxt0zmi5ih3x	cmo1y91e8022tvxt0d5l4c4og	cmo1xc11v000lvxp07r6uljko	61000	2026-04-16 20:46:21.032	2026-04-16 20:46:21.032
cmo1y91f3022zvxt06jrrsjza	cmo1y91e8022tvxt0d5l4c4og	cmo1xc12y000qvxp0uqc7d8d8	61000	2026-04-16 20:46:21.039	2026-04-16 20:46:21.039
cmo1y91fh0231vxt0k8lilvcx	cmo1y91e8022tvxt0d5l4c4og	cmo1xc13g000svxp0tbndc1wg	61000	2026-04-16 20:46:21.053	2026-04-16 20:46:21.053
cmo1y91fu0233vxt056fpefa8	cmo1y91e8022tvxt0d5l4c4og	cmo1xc12q000pvxp0kun82k4l	61000	2026-04-16 20:46:21.066	2026-04-16 20:46:21.066
cmo1y91gb0235vxt0h9hqwkf5	cmo1y91e8022tvxt0d5l4c4og	cmo1xc138000rvxp0r16wi1bz	61000	2026-04-16 20:46:21.084	2026-04-16 20:46:21.084
cmo1y91gk0237vxt0umdbe3al	cmo1y91e8022tvxt0d5l4c4og	cmo1xc12i000ovxp01nisgvnu	61000	2026-04-16 20:46:21.092	2026-04-16 20:46:21.092
cmo1y91h20239vxt0bw6nd55d	cmo1y91e8022tvxt0d5l4c4og	cmo1xc11n000kvxp0g32oj3wx	61000	2026-04-16 20:46:21.11	2026-04-16 20:46:21.11
cmo1y91hc023bvxt03onl0rn6	cmo1y91e8022tvxt0d5l4c4og	cmo1xc10u000hvxp0dapryn3r	61000	2026-04-16 20:46:21.12	2026-04-16 20:46:21.12
cmo1y91hj023dvxt0702ov5qj	cmo1y91e8022tvxt0d5l4c4og	cmo1xc119000jvxp01snwxzoa	61000	2026-04-16 20:46:21.127	2026-04-16 20:46:21.127
cmo1y91i5023hvxt06spby5vv	cmo1y91hw023fvxt0s2jwpeor	cmo1xsgrt0022vxv8sd7cckj7	175000	2026-04-16 20:46:21.149	2026-04-16 20:46:21.149
cmo1y91id023jvxt0p6942a9a	cmo1y91hw023fvxt0s2jwpeor	cmo1xc11v000lvxp07r6uljko	175000	2026-04-16 20:46:21.157	2026-04-16 20:46:21.157
cmo1y91in023lvxt0d5zwu5zv	cmo1y91hw023fvxt0s2jwpeor	cmo1xc12y000qvxp0uqc7d8d8	175000	2026-04-16 20:46:21.167	2026-04-16 20:46:21.167
cmo1y91iu023nvxt09tkobmwn	cmo1y91hw023fvxt0s2jwpeor	cmo1xc13g000svxp0tbndc1wg	175000	2026-04-16 20:46:21.175	2026-04-16 20:46:21.175
cmo1y91j3023pvxt0t1dsy18a	cmo1y91hw023fvxt0s2jwpeor	cmo1xc12q000pvxp0kun82k4l	175000	2026-04-16 20:46:21.184	2026-04-16 20:46:21.184
cmo1y91j9023rvxt0wlwqc98i	cmo1y91hw023fvxt0s2jwpeor	cmo1xc138000rvxp0r16wi1bz	175000	2026-04-16 20:46:21.189	2026-04-16 20:46:21.189
cmo1y91je023tvxt0oonlorxz	cmo1y91hw023fvxt0s2jwpeor	cmo1xc12i000ovxp01nisgvnu	175000	2026-04-16 20:46:21.195	2026-04-16 20:46:21.195
cmo1y91jm023vvxt0qew7ia97	cmo1y91hw023fvxt0s2jwpeor	cmo1xc13o000tvxp0alok8jeb	160000	2026-04-16 20:46:21.202	2026-04-16 20:46:21.202
cmo1y91ju023xvxt0bflovde0	cmo1y91hw023fvxt0s2jwpeor	cmo1xc123000mvxp0ul7pkio2	160000	2026-04-16 20:46:21.211	2026-04-16 20:46:21.211
cmo1y91k2023zvxt05m9s4lhw	cmo1y91hw023fvxt0s2jwpeor	cmo1xc11n000kvxp0g32oj3wx	175000	2026-04-16 20:46:21.218	2026-04-16 20:46:21.218
cmo1y91k90241vxt0zibnruu6	cmo1y91hw023fvxt0s2jwpeor	cmo1xc10u000hvxp0dapryn3r	175000	2026-04-16 20:46:21.226	2026-04-16 20:46:21.226
cmo1y91kh0243vxt0cyfggzav	cmo1y91hw023fvxt0s2jwpeor	cmo1xc119000jvxp01snwxzoa	175000	2026-04-16 20:46:21.234	2026-04-16 20:46:21.234
cmo1y91l30247vxt0i9b5jawz	cmo1y91kp0245vxt0nl1pdvl0	cmo1xsgrt0022vxv8sd7cckj7	175000	2026-04-16 20:46:21.255	2026-04-16 20:46:21.255
cmo1y91lf0249vxt0n3qx1qjw	cmo1y91kp0245vxt0nl1pdvl0	cmo1xc11v000lvxp07r6uljko	175000	2026-04-16 20:46:21.267	2026-04-16 20:46:21.267
cmo1y91ln024bvxt0y2fntwbm	cmo1y91kp0245vxt0nl1pdvl0	cmo1xc12y000qvxp0uqc7d8d8	175000	2026-04-16 20:46:21.275	2026-04-16 20:46:21.275
cmo1y91lu024dvxt0xdyb7tdo	cmo1y91kp0245vxt0nl1pdvl0	cmo1xc13g000svxp0tbndc1wg	175000	2026-04-16 20:46:21.283	2026-04-16 20:46:21.283
cmo1y91m5024fvxt0sbztowdj	cmo1y91kp0245vxt0nl1pdvl0	cmo1xc12q000pvxp0kun82k4l	175000	2026-04-16 20:46:21.294	2026-04-16 20:46:21.294
cmo1y91mg024hvxt0tfr01fvd	cmo1y91kp0245vxt0nl1pdvl0	cmo1xc138000rvxp0r16wi1bz	175000	2026-04-16 20:46:21.304	2026-04-16 20:46:21.304
cmo1y91mn024jvxt0x3mwxsq1	cmo1y91kp0245vxt0nl1pdvl0	cmo1xc12i000ovxp01nisgvnu	175000	2026-04-16 20:46:21.311	2026-04-16 20:46:21.311
cmo1y91n0024lvxt0i2i4iv0h	cmo1y91kp0245vxt0nl1pdvl0	cmo1xc13o000tvxp0alok8jeb	160000	2026-04-16 20:46:21.324	2026-04-16 20:46:21.324
cmo1y91na024nvxt02wcx0mrv	cmo1y91kp0245vxt0nl1pdvl0	cmo1xc123000mvxp0ul7pkio2	160000	2026-04-16 20:46:21.334	2026-04-16 20:46:21.334
cmo1y91ni024pvxt00mg780ow	cmo1y91kp0245vxt0nl1pdvl0	cmo1xc11n000kvxp0g32oj3wx	175000	2026-04-16 20:46:21.342	2026-04-16 20:46:21.342
cmo1y91nq024rvxt0v4no1be3	cmo1y91kp0245vxt0nl1pdvl0	cmo1xc10u000hvxp0dapryn3r	175000	2026-04-16 20:46:21.351	2026-04-16 20:46:21.351
cmo1y91nx024tvxt0gjey2wqi	cmo1y91kp0245vxt0nl1pdvl0	cmo1xc119000jvxp01snwxzoa	175000	2026-04-16 20:46:21.358	2026-04-16 20:46:21.358
cmo1y91oh024xvxt0r4xlrz4g	cmo1y91o8024vvxt0fhd1gxoc	cmo1xsgrt0022vxv8sd7cckj7	175000	2026-04-16 20:46:21.377	2026-04-16 20:46:21.377
cmo1y91ot024zvxt0fpq7nqec	cmo1y91o8024vvxt0fhd1gxoc	cmo1xc11v000lvxp07r6uljko	175000	2026-04-16 20:46:21.389	2026-04-16 20:46:21.389
cmo1y91p50251vxt02x7v1dvv	cmo1y91o8024vvxt0fhd1gxoc	cmo1xc12y000qvxp0uqc7d8d8	175000	2026-04-16 20:46:21.401	2026-04-16 20:46:21.401
cmo1y91pd0253vxt0q0wzkrj2	cmo1y91o8024vvxt0fhd1gxoc	cmo1xc13g000svxp0tbndc1wg	175000	2026-04-16 20:46:21.409	2026-04-16 20:46:21.409
cmo1y91pp0255vxt0pedriajh	cmo1y91o8024vvxt0fhd1gxoc	cmo1xc12q000pvxp0kun82k4l	175000	2026-04-16 20:46:21.422	2026-04-16 20:46:21.422
cmo1y91q40257vxt0t6jnmtm1	cmo1y91o8024vvxt0fhd1gxoc	cmo1xc138000rvxp0r16wi1bz	175000	2026-04-16 20:46:21.436	2026-04-16 20:46:21.436
cmo1y91qc0259vxt0zeuuvdwf	cmo1y91o8024vvxt0fhd1gxoc	cmo1xc12i000ovxp01nisgvnu	175000	2026-04-16 20:46:21.444	2026-04-16 20:46:21.444
cmo1y91qm025bvxt036lff8dr	cmo1y91o8024vvxt0fhd1gxoc	cmo1xc13o000tvxp0alok8jeb	160000	2026-04-16 20:46:21.454	2026-04-16 20:46:21.454
cmo1y91qs025dvxt0xe043kc0	cmo1y91o8024vvxt0fhd1gxoc	cmo1xc123000mvxp0ul7pkio2	160000	2026-04-16 20:46:21.461	2026-04-16 20:46:21.461
cmo1y91r1025fvxt0n60n1iev	cmo1y91o8024vvxt0fhd1gxoc	cmo1xc11n000kvxp0g32oj3wx	175000	2026-04-16 20:46:21.47	2026-04-16 20:46:21.47
cmo1y91r9025hvxt03nfe87jx	cmo1y91o8024vvxt0fhd1gxoc	cmo1xc10u000hvxp0dapryn3r	175000	2026-04-16 20:46:21.477	2026-04-16 20:46:21.477
cmo1y91rg025jvxt0wuquefle	cmo1y91o8024vvxt0fhd1gxoc	cmo1xc119000jvxp01snwxzoa	175000	2026-04-16 20:46:21.484	2026-04-16 20:46:21.484
cmo1y91rw025nvxt00w6irqt1	cmo1y91ro025lvxt0rbcqk5bh	cmo1xsgrt0022vxv8sd7cckj7	158000	2026-04-16 20:46:21.501	2026-04-16 20:46:21.501
cmo1y91s3025pvxt0wfmo3oww	cmo1y91ro025lvxt0rbcqk5bh	cmo1xc11v000lvxp07r6uljko	158000	2026-04-16 20:46:21.508	2026-04-16 20:46:21.508
cmo1y91si025rvxt0mt05zspw	cmo1y91ro025lvxt0rbcqk5bh	cmo1xc12y000qvxp0uqc7d8d8	158000	2026-04-16 20:46:21.522	2026-04-16 20:46:21.522
cmo1y91sz025tvxt0504dzl8i	cmo1y91ro025lvxt0rbcqk5bh	cmo1xc13g000svxp0tbndc1wg	158000	2026-04-16 20:46:21.539	2026-04-16 20:46:21.539
cmo1y91tj025vvxt09d0mj4xd	cmo1y91ro025lvxt0rbcqk5bh	cmo1xc12q000pvxp0kun82k4l	158000	2026-04-16 20:46:21.559	2026-04-16 20:46:21.559
cmo1y91ty025xvxt0qdr1lz6s	cmo1y91ro025lvxt0rbcqk5bh	cmo1xc138000rvxp0r16wi1bz	158000	2026-04-16 20:46:21.574	2026-04-16 20:46:21.574
cmo1y91u9025zvxt0prnuv4s9	cmo1y91ro025lvxt0rbcqk5bh	cmo1xc12i000ovxp01nisgvnu	158000	2026-04-16 20:46:21.585	2026-04-16 20:46:21.585
cmo1y91ug0261vxt0scyifww4	cmo1y91ro025lvxt0rbcqk5bh	cmo1xc13o000tvxp0alok8jeb	148000	2026-04-16 20:46:21.592	2026-04-16 20:46:21.592
cmo1y91uo0263vxt0o0f5fsza	cmo1y91ro025lvxt0rbcqk5bh	cmo1xc123000mvxp0ul7pkio2	135000	2026-04-16 20:46:21.601	2026-04-16 20:46:21.601
cmo1y91ux0265vxt0a1eo2ih8	cmo1y91ro025lvxt0rbcqk5bh	cmo1xc11n000kvxp0g32oj3wx	158000	2026-04-16 20:46:21.609	2026-04-16 20:46:21.609
cmo1y91v50267vxt0ihlxlmuc	cmo1y91ro025lvxt0rbcqk5bh	cmo1xc10u000hvxp0dapryn3r	158000	2026-04-16 20:46:21.617	2026-04-16 20:46:21.617
cmo1y91ve0269vxt0lgxomnh1	cmo1y91ro025lvxt0rbcqk5bh	cmo1xc119000jvxp01snwxzoa	158000	2026-04-16 20:46:21.626	2026-04-16 20:46:21.626
cmo1y91vw026dvxt01fnpk13b	cmo1y91vp026bvxt0ss4xi7rz	cmo1xsgrt0022vxv8sd7cckj7	56000	2026-04-16 20:46:21.644	2026-04-16 20:46:21.644
cmo1y91wi026fvxt0k8xn0vgi	cmo1y91vp026bvxt0ss4xi7rz	cmo1xc11v000lvxp07r6uljko	56000	2026-04-16 20:46:21.667	2026-04-16 20:46:21.667
cmo1y91wq026hvxt0y9vow1kn	cmo1y91vp026bvxt0ss4xi7rz	cmo1xc12y000qvxp0uqc7d8d8	56000	2026-04-16 20:46:21.674	2026-04-16 20:46:21.674
cmo1y91wx026jvxt09iktsjv0	cmo1y91vp026bvxt0ss4xi7rz	cmo1xc13g000svxp0tbndc1wg	56000	2026-04-16 20:46:21.681	2026-04-16 20:46:21.681
cmo1y91x7026lvxt052jhtnmm	cmo1y91vp026bvxt0ss4xi7rz	cmo1xc12q000pvxp0kun82k4l	56000	2026-04-16 20:46:21.692	2026-04-16 20:46:21.692
cmo1y91xe026nvxt0ydd58x18	cmo1y91vp026bvxt0ss4xi7rz	cmo1xc138000rvxp0r16wi1bz	56000	2026-04-16 20:46:21.699	2026-04-16 20:46:21.699
cmo1y91xm026pvxt0qfew7ymv	cmo1y91vp026bvxt0ss4xi7rz	cmo1xc12i000ovxp01nisgvnu	56000	2026-04-16 20:46:21.706	2026-04-16 20:46:21.706
cmo1y91xy026rvxt0a8tx9wcv	cmo1y91vp026bvxt0ss4xi7rz	cmo1xc11n000kvxp0g32oj3wx	56000	2026-04-16 20:46:21.718	2026-04-16 20:46:21.718
cmo1y91y5026tvxt08iow9pt5	cmo1y91vp026bvxt0ss4xi7rz	cmo1xc10u000hvxp0dapryn3r	56000	2026-04-16 20:46:21.725	2026-04-16 20:46:21.725
cmo1y91yc026vvxt0a2a5zmy7	cmo1y91vp026bvxt0ss4xi7rz	cmo1xc119000jvxp01snwxzoa	56000	2026-04-16 20:46:21.732	2026-04-16 20:46:21.732
cmo1y91yt026zvxt0bwhirnf5	cmo1y91yk026xvxt0vx7in7pa	cmo1xsgrt0022vxv8sd7cckj7	56000	2026-04-16 20:46:21.749	2026-04-16 20:46:21.749
cmo1y91z10271vxt09nhvaxtv	cmo1y91yk026xvxt0vx7in7pa	cmo1xc11v000lvxp07r6uljko	56000	2026-04-16 20:46:21.757	2026-04-16 20:46:21.757
cmo1y91zc0273vxt0clnwthup	cmo1y91yk026xvxt0vx7in7pa	cmo1xc12y000qvxp0uqc7d8d8	56000	2026-04-16 20:46:21.768	2026-04-16 20:46:21.768
cmo1y91zr0275vxt01cr3z6no	cmo1y91yk026xvxt0vx7in7pa	cmo1xc13g000svxp0tbndc1wg	56000	2026-04-16 20:46:21.783	2026-04-16 20:46:21.783
cmo1y92020277vxt03npf4em1	cmo1y91yk026xvxt0vx7in7pa	cmo1xc12q000pvxp0kun82k4l	56000	2026-04-16 20:46:21.795	2026-04-16 20:46:21.795
cmo1y920b0279vxt0hnz7d6yb	cmo1y91yk026xvxt0vx7in7pa	cmo1xc138000rvxp0r16wi1bz	56000	2026-04-16 20:46:21.804	2026-04-16 20:46:21.804
cmo1y920i027bvxt0dn15qxyn	cmo1y91yk026xvxt0vx7in7pa	cmo1xc12i000ovxp01nisgvnu	56000	2026-04-16 20:46:21.811	2026-04-16 20:46:21.811
cmo1y920r027dvxt0ev3kq1cl	cmo1y91yk026xvxt0vx7in7pa	cmo1xc11n000kvxp0g32oj3wx	56000	2026-04-16 20:46:21.819	2026-04-16 20:46:21.819
cmo1y920y027fvxt053j4nmab	cmo1y91yk026xvxt0vx7in7pa	cmo1xc10u000hvxp0dapryn3r	56000	2026-04-16 20:46:21.827	2026-04-16 20:46:21.827
cmo1y9215027hvxt09flgrqr9	cmo1y91yk026xvxt0vx7in7pa	cmo1xc119000jvxp01snwxzoa	56000	2026-04-16 20:46:21.833	2026-04-16 20:46:21.833
cmo1y921k027lvxt07szfptwh	cmo1y921d027jvxt0htzrsdmb	cmo1xsgrt0022vxv8sd7cckj7	56000	2026-04-16 20:46:21.849	2026-04-16 20:46:21.849
cmo1y921r027nvxt0ia3tm8lm	cmo1y921d027jvxt0htzrsdmb	cmo1xc11v000lvxp07r6uljko	56000	2026-04-16 20:46:21.856	2026-04-16 20:46:21.856
cmo1y921y027pvxt052et07ye	cmo1y921d027jvxt0htzrsdmb	cmo1xc12y000qvxp0uqc7d8d8	56000	2026-04-16 20:46:21.862	2026-04-16 20:46:21.862
cmo1y9228027rvxt0ui48gh02	cmo1y921d027jvxt0htzrsdmb	cmo1xc13g000svxp0tbndc1wg	56000	2026-04-16 20:46:21.872	2026-04-16 20:46:21.872
cmo1y922j027tvxt0yqi3e0cg	cmo1y921d027jvxt0htzrsdmb	cmo1xc12q000pvxp0kun82k4l	56000	2026-04-16 20:46:21.884	2026-04-16 20:46:21.884
cmo1y922q027vvxt0de3zft3c	cmo1y921d027jvxt0htzrsdmb	cmo1xc138000rvxp0r16wi1bz	56000	2026-04-16 20:46:21.89	2026-04-16 20:46:21.89
cmo1y922y027xvxt0ugslqlyg	cmo1y921d027jvxt0htzrsdmb	cmo1xc12i000ovxp01nisgvnu	56000	2026-04-16 20:46:21.898	2026-04-16 20:46:21.898
cmo1y9239027zvxt08hz1d8sy	cmo1y921d027jvxt0htzrsdmb	cmo1xc11n000kvxp0g32oj3wx	56000	2026-04-16 20:46:21.91	2026-04-16 20:46:21.91
cmo1y923g0281vxt0e6jcb9n7	cmo1y921d027jvxt0htzrsdmb	cmo1xc10u000hvxp0dapryn3r	56000	2026-04-16 20:46:21.916	2026-04-16 20:46:21.916
cmo1y923n0283vxt0k3ty2eto	cmo1y921d027jvxt0htzrsdmb	cmo1xc119000jvxp01snwxzoa	56000	2026-04-16 20:46:21.923	2026-04-16 20:46:21.923
cmo1y92440287vxt0sdf09tht	cmo1y923w0285vxt0435oep6e	cmo1xsgrt0022vxv8sd7cckj7	66000	2026-04-16 20:46:21.94	2026-04-16 20:46:21.94
cmo1y924c0289vxt0ixqktr2i	cmo1y923w0285vxt0435oep6e	cmo1xc11v000lvxp07r6uljko	66000	2026-04-16 20:46:21.948	2026-04-16 20:46:21.948
cmo1y924l028bvxt0kzjyx0vd	cmo1y923w0285vxt0435oep6e	cmo1xc12y000qvxp0uqc7d8d8	66000	2026-04-16 20:46:21.957	2026-04-16 20:46:21.957
cmo1y924u028dvxt0th3h77zd	cmo1y923w0285vxt0435oep6e	cmo1xc13g000svxp0tbndc1wg	66000	2026-04-16 20:46:21.967	2026-04-16 20:46:21.967
cmo1y9253028fvxt0md0qunyj	cmo1y923w0285vxt0435oep6e	cmo1xc12q000pvxp0kun82k4l	66000	2026-04-16 20:46:21.975	2026-04-16 20:46:21.975
cmo1y925a028hvxt0ug2z16r1	cmo1y923w0285vxt0435oep6e	cmo1xc138000rvxp0r16wi1bz	66000	2026-04-16 20:46:21.982	2026-04-16 20:46:21.982
cmo1y925h028jvxt0li20umf7	cmo1y923w0285vxt0435oep6e	cmo1xc12i000ovxp01nisgvnu	66000	2026-04-16 20:46:21.99	2026-04-16 20:46:21.99
cmo1y925t028lvxt0386sj1l7	cmo1y923w0285vxt0435oep6e	cmo1xc11n000kvxp0g32oj3wx	66000	2026-04-16 20:46:22.001	2026-04-16 20:46:22.001
cmo1y925z028nvxt0pt0kwihb	cmo1y923w0285vxt0435oep6e	cmo1xc10u000hvxp0dapryn3r	66000	2026-04-16 20:46:22.007	2026-04-16 20:46:22.007
cmo1y9265028pvxt04mhtuh2q	cmo1y923w0285vxt0435oep6e	cmo1xc119000jvxp01snwxzoa	66000	2026-04-16 20:46:22.013	2026-04-16 20:46:22.013
cmo1y926k028tvxt08897qkti	cmo1y926d028rvxt0yzlcemc4	cmo1xsgrt0022vxv8sd7cckj7	66000	2026-04-16 20:46:22.028	2026-04-16 20:46:22.028
cmo1y926s028vvxt06bw0sy69	cmo1y926d028rvxt0yzlcemc4	cmo1xc11v000lvxp07r6uljko	66000	2026-04-16 20:46:22.036	2026-04-16 20:46:22.036
cmo1y9270028xvxt0caoqajvo	cmo1y926d028rvxt0yzlcemc4	cmo1xc12y000qvxp0uqc7d8d8	66000	2026-04-16 20:46:22.045	2026-04-16 20:46:22.045
cmo1y9278028zvxt0ckpemayk	cmo1y926d028rvxt0yzlcemc4	cmo1xc13g000svxp0tbndc1wg	66000	2026-04-16 20:46:22.053	2026-04-16 20:46:22.053
cmo1y927g0291vxt0y0lmfyaj	cmo1y926d028rvxt0yzlcemc4	cmo1xc12q000pvxp0kun82k4l	66000	2026-04-16 20:46:22.06	2026-04-16 20:46:22.06
cmo1y927m0293vxt0x5slaaki	cmo1y926d028rvxt0yzlcemc4	cmo1xc138000rvxp0r16wi1bz	66000	2026-04-16 20:46:22.066	2026-04-16 20:46:22.066
cmo1y927t0295vxt0lrn3ditm	cmo1y926d028rvxt0yzlcemc4	cmo1xc12i000ovxp01nisgvnu	66000	2026-04-16 20:46:22.073	2026-04-16 20:46:22.073
cmo1y92840297vxt0f5u9d92s	cmo1y926d028rvxt0yzlcemc4	cmo1xc11n000kvxp0g32oj3wx	66000	2026-04-16 20:46:22.084	2026-04-16 20:46:22.084
cmo1y928a0299vxt0qpmmtfyc	cmo1y926d028rvxt0yzlcemc4	cmo1xc10u000hvxp0dapryn3r	66000	2026-04-16 20:46:22.091	2026-04-16 20:46:22.091
cmo1y928i029bvxt02efyf1t6	cmo1y926d028rvxt0yzlcemc4	cmo1xc119000jvxp01snwxzoa	66000	2026-04-16 20:46:22.098	2026-04-16 20:46:22.098
cmo1y928y029fvxt0q2rc46ou	cmo1y928q029dvxt0o6rxwsdi	cmo1xsgrt0022vxv8sd7cckj7	66000	2026-04-16 20:46:22.115	2026-04-16 20:46:22.115
cmo1y9295029hvxt0gwthsnoq	cmo1y928q029dvxt0o6rxwsdi	cmo1xc11v000lvxp07r6uljko	66000	2026-04-16 20:46:22.121	2026-04-16 20:46:22.121
cmo1y929a029jvxt0sgn672lc	cmo1y928q029dvxt0o6rxwsdi	cmo1xc12y000qvxp0uqc7d8d8	66000	2026-04-16 20:46:22.127	2026-04-16 20:46:22.127
cmo1y929h029lvxt0it2gxotj	cmo1y928q029dvxt0o6rxwsdi	cmo1xc13g000svxp0tbndc1wg	66000	2026-04-16 20:46:22.133	2026-04-16 20:46:22.133
cmo1y929p029nvxt0b7k6xeao	cmo1y928q029dvxt0o6rxwsdi	cmo1xc12q000pvxp0kun82k4l	66000	2026-04-16 20:46:22.142	2026-04-16 20:46:22.142
cmo1y929w029pvxt0whhu3kem	cmo1y928q029dvxt0o6rxwsdi	cmo1xc138000rvxp0r16wi1bz	66000	2026-04-16 20:46:22.148	2026-04-16 20:46:22.148
cmo1y92a4029rvxt0vm4grufv	cmo1y928q029dvxt0o6rxwsdi	cmo1xc12i000ovxp01nisgvnu	66000	2026-04-16 20:46:22.156	2026-04-16 20:46:22.156
cmo1y92ai029tvxt06ctf4cb2	cmo1y928q029dvxt0o6rxwsdi	cmo1xc11n000kvxp0g32oj3wx	66000	2026-04-16 20:46:22.17	2026-04-16 20:46:22.17
cmo1y92aq029vvxt0jxatpnuc	cmo1y928q029dvxt0o6rxwsdi	cmo1xc10u000hvxp0dapryn3r	66000	2026-04-16 20:46:22.178	2026-04-16 20:46:22.178
cmo1y92b0029xvxt06dmq7lj3	cmo1y928q029dvxt0o6rxwsdi	cmo1xc119000jvxp01snwxzoa	66000	2026-04-16 20:46:22.188	2026-04-16 20:46:22.188
cmo1y92bh02a1vxt0wyz5297w	cmo1y92ba029zvxt0en7wfa6c	cmo1xsgrt0022vxv8sd7cckj7	66000	2026-04-16 20:46:22.205	2026-04-16 20:46:22.205
cmo1y92bn02a3vxt0xx7e9ib8	cmo1y92ba029zvxt0en7wfa6c	cmo1xc11v000lvxp07r6uljko	66000	2026-04-16 20:46:22.212	2026-04-16 20:46:22.212
cmo1y92bw02a5vxt0iogcntjb	cmo1y92ba029zvxt0en7wfa6c	cmo1xc12y000qvxp0uqc7d8d8	66000	2026-04-16 20:46:22.22	2026-04-16 20:46:22.22
cmo1y92c402a7vxt0v1cfebqt	cmo1y92ba029zvxt0en7wfa6c	cmo1xc13g000svxp0tbndc1wg	66000	2026-04-16 20:46:22.228	2026-04-16 20:46:22.228
cmo1y92ce02a9vxt0ks2mi9js	cmo1y92ba029zvxt0en7wfa6c	cmo1xc12q000pvxp0kun82k4l	66000	2026-04-16 20:46:22.238	2026-04-16 20:46:22.238
cmo1y92cj02abvxt0pi8uwzkf	cmo1y92ba029zvxt0en7wfa6c	cmo1xc138000rvxp0r16wi1bz	66000	2026-04-16 20:46:22.243	2026-04-16 20:46:22.243
cmo1y92cq02advxt0l4nb4upm	cmo1y92ba029zvxt0en7wfa6c	cmo1xc12i000ovxp01nisgvnu	66000	2026-04-16 20:46:22.25	2026-04-16 20:46:22.25
cmo1y92d002afvxt03jyszmgm	cmo1y92ba029zvxt0en7wfa6c	cmo1xc11n000kvxp0g32oj3wx	66000	2026-04-16 20:46:22.26	2026-04-16 20:46:22.26
cmo1y92d602ahvxt0yfph8aoz	cmo1y92ba029zvxt0en7wfa6c	cmo1xc10u000hvxp0dapryn3r	66000	2026-04-16 20:46:22.266	2026-04-16 20:46:22.266
cmo1y92de02ajvxt08q3jsn57	cmo1y92ba029zvxt0en7wfa6c	cmo1xc119000jvxp01snwxzoa	66000	2026-04-16 20:46:22.274	2026-04-16 20:46:22.274
cmo1y92du02anvxt0dnp9kcua	cmo1y92dn02alvxt07m8wg0xy	cmo1xsgrt0022vxv8sd7cckj7	66000	2026-04-16 20:46:22.29	2026-04-16 20:46:22.29
cmo1y92e202apvxt0md01pyft	cmo1y92dn02alvxt07m8wg0xy	cmo1xc11v000lvxp07r6uljko	66000	2026-04-16 20:46:22.298	2026-04-16 20:46:22.298
cmo1y92ea02arvxt0uofdvowj	cmo1y92dn02alvxt07m8wg0xy	cmo1xc12y000qvxp0uqc7d8d8	66000	2026-04-16 20:46:22.306	2026-04-16 20:46:22.306
cmo1y92ej02atvxt0d934vsq8	cmo1y92dn02alvxt07m8wg0xy	cmo1xc13g000svxp0tbndc1wg	66000	2026-04-16 20:46:22.315	2026-04-16 20:46:22.315
cmo1y92er02avvxt0knb2phkd	cmo1y92dn02alvxt07m8wg0xy	cmo1xc12q000pvxp0kun82k4l	66000	2026-04-16 20:46:22.323	2026-04-16 20:46:22.323
cmo1y92ex02axvxt0pli0kz52	cmo1y92dn02alvxt07m8wg0xy	cmo1xc138000rvxp0r16wi1bz	66000	2026-04-16 20:46:22.329	2026-04-16 20:46:22.329
cmo1y92f602azvxt0b52kaago	cmo1y92dn02alvxt07m8wg0xy	cmo1xc12i000ovxp01nisgvnu	66000	2026-04-16 20:46:22.338	2026-04-16 20:46:22.338
cmo1y92fi02b1vxt05wj32s3k	cmo1y92dn02alvxt07m8wg0xy	cmo1xc11n000kvxp0g32oj3wx	66000	2026-04-16 20:46:22.35	2026-04-16 20:46:22.35
cmo1y92fq02b3vxt07lyomhw3	cmo1y92dn02alvxt07m8wg0xy	cmo1xc10u000hvxp0dapryn3r	66000	2026-04-16 20:46:22.358	2026-04-16 20:46:22.358
cmo1y92fy02b5vxt0dz33hhv3	cmo1y92dn02alvxt07m8wg0xy	cmo1xc119000jvxp01snwxzoa	66000	2026-04-16 20:46:22.366	2026-04-16 20:46:22.366
cmo1y92gd02b9vxt04sxmxbp0	cmo1y92g402b7vxt0dak56hvv	cmo1xsgrt0022vxv8sd7cckj7	66000	2026-04-16 20:46:22.381	2026-04-16 20:46:22.381
cmo1y92gl02bbvxt090vnqe8h	cmo1y92g402b7vxt0dak56hvv	cmo1xc11v000lvxp07r6uljko	66000	2026-04-16 20:46:22.389	2026-04-16 20:46:22.389
cmo1y92gu02bdvxt09dg9odbo	cmo1y92g402b7vxt0dak56hvv	cmo1xc12y000qvxp0uqc7d8d8	66000	2026-04-16 20:46:22.398	2026-04-16 20:46:22.398
cmo1y92h202bfvxt0smx0wdo5	cmo1y92g402b7vxt0dak56hvv	cmo1xc13g000svxp0tbndc1wg	66000	2026-04-16 20:46:22.406	2026-04-16 20:46:22.406
cmo1y92hd02bhvxt0dzkd2jl6	cmo1y92g402b7vxt0dak56hvv	cmo1xc12q000pvxp0kun82k4l	66000	2026-04-16 20:46:22.417	2026-04-16 20:46:22.417
cmo1y92hk02bjvxt05prwe7an	cmo1y92g402b7vxt0dak56hvv	cmo1xc138000rvxp0r16wi1bz	66000	2026-04-16 20:46:22.424	2026-04-16 20:46:22.424
cmo1y92hs02blvxt0cxefad29	cmo1y92g402b7vxt0dak56hvv	cmo1xc12i000ovxp01nisgvnu	66000	2026-04-16 20:46:22.432	2026-04-16 20:46:22.432
cmo1y92i102bnvxt0kjegqs19	cmo1y92g402b7vxt0dak56hvv	cmo1xc11n000kvxp0g32oj3wx	66000	2026-04-16 20:46:22.441	2026-04-16 20:46:22.441
cmo1y92i802bpvxt0wzryeqvr	cmo1y92g402b7vxt0dak56hvv	cmo1xc10u000hvxp0dapryn3r	66000	2026-04-16 20:46:22.449	2026-04-16 20:46:22.449
cmo1y92ig02brvxt0zkjs2l60	cmo1y92g402b7vxt0dak56hvv	cmo1xc119000jvxp01snwxzoa	66000	2026-04-16 20:46:22.456	2026-04-16 20:46:22.456
cmo1y92ix02bvvxt0f3pw9xsd	cmo1y92ip02btvxt0fup4uwfi	cmo1xsgrt0022vxv8sd7cckj7	35000	2026-04-16 20:46:22.473	2026-04-16 20:46:22.473
cmo1y92j602bxvxt0zwyf7aa6	cmo1y92ip02btvxt0fup4uwfi	cmo1xc11v000lvxp07r6uljko	35000	2026-04-16 20:46:22.482	2026-04-16 20:46:22.482
cmo1y92jd02bzvxt0r1ne1ibj	cmo1y92ip02btvxt0fup4uwfi	cmo1xc12y000qvxp0uqc7d8d8	35000	2026-04-16 20:46:22.489	2026-04-16 20:46:22.489
cmo1y92jm02c1vxt03vbx9n4m	cmo1y92ip02btvxt0fup4uwfi	cmo1xc13g000svxp0tbndc1wg	35000	2026-04-16 20:46:22.498	2026-04-16 20:46:22.498
cmo1y92ju02c3vxt0cujti055	cmo1y92ip02btvxt0fup4uwfi	cmo1xc12q000pvxp0kun82k4l	35000	2026-04-16 20:46:22.506	2026-04-16 20:46:22.506
cmo1y92jz02c5vxt0iz65s6vf	cmo1y92ip02btvxt0fup4uwfi	cmo1xc138000rvxp0r16wi1bz	35000	2026-04-16 20:46:22.512	2026-04-16 20:46:22.512
cmo1y92k902c7vxt0t6egsyta	cmo1y92ip02btvxt0fup4uwfi	cmo1xc12i000ovxp01nisgvnu	35000	2026-04-16 20:46:22.521	2026-04-16 20:46:22.521
cmo1y92kl02c9vxt0wmz0jakt	cmo1y92ip02btvxt0fup4uwfi	cmo1xc11n000kvxp0g32oj3wx	35000	2026-04-16 20:46:22.533	2026-04-16 20:46:22.533
cmo1y92ks02cbvxt0lnqvjmsy	cmo1y92ip02btvxt0fup4uwfi	cmo1xc10u000hvxp0dapryn3r	35000	2026-04-16 20:46:22.541	2026-04-16 20:46:22.541
cmo1y92l002cdvxt0x39tp6kv	cmo1y92ip02btvxt0fup4uwfi	cmo1xc119000jvxp01snwxzoa	35000	2026-04-16 20:46:22.548	2026-04-16 20:46:22.548
cmo1y92lh02chvxt06l059jaa	cmo1y92l702cfvxt0mkjhr4ho	cmo1xsgrt0022vxv8sd7cckj7	35000	2026-04-16 20:46:22.565	2026-04-16 20:46:22.565
cmo1y92lo02cjvxt0ctz0m9x0	cmo1y92l702cfvxt0mkjhr4ho	cmo1xc11v000lvxp07r6uljko	35000	2026-04-16 20:46:22.572	2026-04-16 20:46:22.572
cmo1y92lt02clvxt0emupwhby	cmo1y92l702cfvxt0mkjhr4ho	cmo1xc12y000qvxp0uqc7d8d8	35000	2026-04-16 20:46:22.578	2026-04-16 20:46:22.578
cmo1y92lz02cnvxt0vy6z413w	cmo1y92l702cfvxt0mkjhr4ho	cmo1xc13g000svxp0tbndc1wg	35000	2026-04-16 20:46:22.584	2026-04-16 20:46:22.584
cmo1y92m902cpvxt04niicxpc	cmo1y92l702cfvxt0mkjhr4ho	cmo1xc12q000pvxp0kun82k4l	35000	2026-04-16 20:46:22.593	2026-04-16 20:46:22.593
cmo1y92mf02crvxt0fkf6am5r	cmo1y92l702cfvxt0mkjhr4ho	cmo1xc138000rvxp0r16wi1bz	35000	2026-04-16 20:46:22.6	2026-04-16 20:46:22.6
cmo1y92mn02ctvxt0gcpgt03s	cmo1y92l702cfvxt0mkjhr4ho	cmo1xc12i000ovxp01nisgvnu	35000	2026-04-16 20:46:22.607	2026-04-16 20:46:22.607
cmo1y92my02cvvxt00oocsbor	cmo1y92l702cfvxt0mkjhr4ho	cmo1xc11n000kvxp0g32oj3wx	35000	2026-04-16 20:46:22.619	2026-04-16 20:46:22.619
cmo1y92n502cxvxt0ogu6bk00	cmo1y92l702cfvxt0mkjhr4ho	cmo1xc10u000hvxp0dapryn3r	35000	2026-04-16 20:46:22.626	2026-04-16 20:46:22.626
cmo1y92nd02czvxt0mwb5gt68	cmo1y92l702cfvxt0mkjhr4ho	cmo1xc119000jvxp01snwxzoa	35000	2026-04-16 20:46:22.633	2026-04-16 20:46:22.633
cmo1y92nu02d3vxt0ee0khrxe	cmo1y92nl02d1vxt09yniyjso	cmo1xsgrt0022vxv8sd7cckj7	35000	2026-04-16 20:46:22.65	2026-04-16 20:46:22.65
cmo1y92o102d5vxt0k3eymmix	cmo1y92nl02d1vxt09yniyjso	cmo1xc11v000lvxp07r6uljko	35000	2026-04-16 20:46:22.657	2026-04-16 20:46:22.657
cmo1y92o902d7vxt0ljopo0ai	cmo1y92nl02d1vxt09yniyjso	cmo1xc12y000qvxp0uqc7d8d8	35000	2026-04-16 20:46:22.665	2026-04-16 20:46:22.665
cmo1y92oh02d9vxt0xxbqfc9h	cmo1y92nl02d1vxt09yniyjso	cmo1xc13g000svxp0tbndc1wg	35000	2026-04-16 20:46:22.673	2026-04-16 20:46:22.673
cmo1y92os02dbvxt0fs32emju	cmo1y92nl02d1vxt09yniyjso	cmo1xc12q000pvxp0kun82k4l	35000	2026-04-16 20:46:22.684	2026-04-16 20:46:22.684
cmo1y92oz02ddvxt0tuwxrre8	cmo1y92nl02d1vxt09yniyjso	cmo1xc138000rvxp0r16wi1bz	35000	2026-04-16 20:46:22.691	2026-04-16 20:46:22.691
cmo1y92p702dfvxt0fvh98m11	cmo1y92nl02d1vxt09yniyjso	cmo1xc12i000ovxp01nisgvnu	35000	2026-04-16 20:46:22.699	2026-04-16 20:46:22.699
cmo1y92pg02dhvxt0p1hifmuh	cmo1y92nl02d1vxt09yniyjso	cmo1xc11n000kvxp0g32oj3wx	35000	2026-04-16 20:46:22.708	2026-04-16 20:46:22.708
cmo1y92pn02djvxt0aqdu2m30	cmo1y92nl02d1vxt09yniyjso	cmo1xc10u000hvxp0dapryn3r	35000	2026-04-16 20:46:22.715	2026-04-16 20:46:22.715
cmo1y92pu02dlvxt081q13i4q	cmo1y92nl02d1vxt09yniyjso	cmo1xc119000jvxp01snwxzoa	35000	2026-04-16 20:46:22.722	2026-04-16 20:46:22.722
cmo1y92qh02dpvxt0m6o8xe11	cmo1y92q302dnvxt09cnyquzj	cmo1xc13g000svxp0tbndc1wg	25500	2026-04-16 20:46:22.745	2026-04-16 20:46:22.745
cmo1y92rh02dtvxt0mh0ycv62	cmo1y92ra02drvxt0p44to9ag	cmo1xsgrt0022vxv8sd7cckj7	5500	2026-04-16 20:46:22.781	2026-04-16 20:46:22.781
cmo1y92rt02dvvxt0nf1o8n82	cmo1y92ra02drvxt0p44to9ag	cmo1xc11v000lvxp07r6uljko	5500	2026-04-16 20:46:22.794	2026-04-16 20:46:22.794
cmo1y92rz02dxvxt01bk4ubah	cmo1y92ra02drvxt0p44to9ag	cmo1xc12y000qvxp0uqc7d8d8	5500	2026-04-16 20:46:22.8	2026-04-16 20:46:22.8
cmo1y92s702dzvxt0znxq9r9a	cmo1y92ra02drvxt0p44to9ag	cmo1xc13g000svxp0tbndc1wg	5500	2026-04-16 20:46:22.807	2026-04-16 20:46:22.807
cmo1y92sg02e1vxt0tk17c5wq	cmo1y92ra02drvxt0p44to9ag	cmo1xc12a000nvxp0f1zf3aqg	5500	2026-04-16 20:46:22.816	2026-04-16 20:46:22.816
cmo1y92so02e3vxt0o24tcxf0	cmo1y92ra02drvxt0p44to9ag	cmo1xc12q000pvxp0kun82k4l	5500	2026-04-16 20:46:22.824	2026-04-16 20:46:22.824
cmo1y92sw02e5vxt0j55bykca	cmo1y92ra02drvxt0p44to9ag	cmo1xc138000rvxp0r16wi1bz	5500	2026-04-16 20:46:22.833	2026-04-16 20:46:22.833
cmo1y92t302e7vxt04tabvqh5	cmo1y92ra02drvxt0p44to9ag	cmo1xc12i000ovxp01nisgvnu	5500	2026-04-16 20:46:22.839	2026-04-16 20:46:22.839
cmo1y92t802e9vxt0uc23sjxz	cmo1y92ra02drvxt0p44to9ag	cmo1xc13o000tvxp0alok8jeb	5500	2026-04-16 20:46:22.845	2026-04-16 20:46:22.845
cmo1y92tg02ebvxt070si7l1y	cmo1y92ra02drvxt0p44to9ag	cmo1xc123000mvxp0ul7pkio2	5500	2026-04-16 20:46:22.853	2026-04-16 20:46:22.853
cmo1y92to02edvxt02nem0fe7	cmo1y92ra02drvxt0p44to9ag	cmo1xc11n000kvxp0g32oj3wx	5500	2026-04-16 20:46:22.86	2026-04-16 20:46:22.86
cmo1y92tu02efvxt06bvur6ow	cmo1y92ra02drvxt0p44to9ag	cmo1xc10u000hvxp0dapryn3r	5500	2026-04-16 20:46:22.866	2026-04-16 20:46:22.866
cmo1y92u202ehvxt0rkskczqc	cmo1y92ra02drvxt0p44to9ag	cmo1xc119000jvxp01snwxzoa	5500	2026-04-16 20:46:22.874	2026-04-16 20:46:22.874
cmo1y92uh02elvxt0xk04ua1m	cmo1y92u902ejvxt0iyn7m5dq	cmo1xsgrt0022vxv8sd7cckj7	5500	2026-04-16 20:46:22.89	2026-04-16 20:46:22.89
cmo1y92uq02envxt0qicep1p7	cmo1y92u902ejvxt0iyn7m5dq	cmo1xc11v000lvxp07r6uljko	5500	2026-04-16 20:46:22.899	2026-04-16 20:46:22.899
cmo1y92ux02epvxt0hhx4hf5b	cmo1y92u902ejvxt0iyn7m5dq	cmo1xc12y000qvxp0uqc7d8d8	5500	2026-04-16 20:46:22.905	2026-04-16 20:46:22.905
cmo1y92v302ervxt0xptn48ax	cmo1y92u902ejvxt0iyn7m5dq	cmo1xc13g000svxp0tbndc1wg	5500	2026-04-16 20:46:22.911	2026-04-16 20:46:22.911
cmo1y92vb02etvxt0wcppzelz	cmo1y92u902ejvxt0iyn7m5dq	cmo1xc12a000nvxp0f1zf3aqg	5500	2026-04-16 20:46:22.919	2026-04-16 20:46:22.919
cmo1y92vi02evvxt006qh5jnb	cmo1y92u902ejvxt0iyn7m5dq	cmo1xc12q000pvxp0kun82k4l	5500	2026-04-16 20:46:22.926	2026-04-16 20:46:22.926
cmo1y92vp02exvxt0s7eztyh3	cmo1y92u902ejvxt0iyn7m5dq	cmo1xc138000rvxp0r16wi1bz	5500	2026-04-16 20:46:22.933	2026-04-16 20:46:22.933
cmo1y92vw02ezvxt0kteg5n08	cmo1y92u902ejvxt0iyn7m5dq	cmo1xc12i000ovxp01nisgvnu	5500	2026-04-16 20:46:22.941	2026-04-16 20:46:22.941
cmo1y92w502f1vxt0lobk47vw	cmo1y92u902ejvxt0iyn7m5dq	cmo1xc13o000tvxp0alok8jeb	5500	2026-04-16 20:46:22.949	2026-04-16 20:46:22.949
cmo1y92wc02f3vxt0c2ocfxky	cmo1y92u902ejvxt0iyn7m5dq	cmo1xc123000mvxp0ul7pkio2	5500	2026-04-16 20:46:22.956	2026-04-16 20:46:22.956
cmo1y92wj02f5vxt0nzcutciw	cmo1y92u902ejvxt0iyn7m5dq	cmo1xc11n000kvxp0g32oj3wx	5500	2026-04-16 20:46:22.963	2026-04-16 20:46:22.963
cmo1y92wr02f7vxt0tta2rf8q	cmo1y92u902ejvxt0iyn7m5dq	cmo1xc10u000hvxp0dapryn3r	5500	2026-04-16 20:46:22.971	2026-04-16 20:46:22.971
cmo1y92wz02f9vxt06sm3e2qk	cmo1y92u902ejvxt0iyn7m5dq	cmo1xc119000jvxp01snwxzoa	5500	2026-04-16 20:46:22.979	2026-04-16 20:46:22.979
cmo1y92xf02fdvxt06dp5x9km	cmo1y92x702fbvxt0rmd9fg7f	cmo1xsgrt0022vxv8sd7cckj7	45000	2026-04-16 20:46:22.996	2026-04-16 20:46:22.996
cmo1y92xo02ffvxt0nptcvtnt	cmo1y92x702fbvxt0rmd9fg7f	cmo1xc11v000lvxp07r6uljko	45000	2026-04-16 20:46:23.004	2026-04-16 20:46:23.004
cmo1y92xv02fhvxt0hg2lbwyi	cmo1y92x702fbvxt0rmd9fg7f	cmo1xc12y000qvxp0uqc7d8d8	48000	2026-04-16 20:46:23.012	2026-04-16 20:46:23.012
cmo1y92y202fjvxt04a9f95so	cmo1y92x702fbvxt0rmd9fg7f	cmo1xc13g000svxp0tbndc1wg	37000	2026-04-16 20:46:23.019	2026-04-16 20:46:23.019
cmo1y92ya02flvxt03zknvaow	cmo1y92x702fbvxt0rmd9fg7f	cmo1xc12a000nvxp0f1zf3aqg	45000	2026-04-16 20:46:23.026	2026-04-16 20:46:23.026
cmo1y92yh02fnvxt0rbgb7u4n	cmo1y92x702fbvxt0rmd9fg7f	cmo1xc12q000pvxp0kun82k4l	45000	2026-04-16 20:46:23.033	2026-04-16 20:46:23.033
cmo1y92yn02fpvxt0zbhk7ats	cmo1y92x702fbvxt0rmd9fg7f	cmo1xc138000rvxp0r16wi1bz	45000	2026-04-16 20:46:23.039	2026-04-16 20:46:23.039
cmo1y92ys02frvxt0dmusrlch	cmo1y92x702fbvxt0rmd9fg7f	cmo1xc12i000ovxp01nisgvnu	45000	2026-04-16 20:46:23.044	2026-04-16 20:46:23.044
cmo1y92yz02ftvxt0bbamm6xy	cmo1y92x702fbvxt0rmd9fg7f	cmo1xc13o000tvxp0alok8jeb	45000	2026-04-16 20:46:23.051	2026-04-16 20:46:23.051
cmo1y92z602fvvxt0nwdpq4hc	cmo1y92x702fbvxt0rmd9fg7f	cmo1xc123000mvxp0ul7pkio2	45000	2026-04-16 20:46:23.058	2026-04-16 20:46:23.058
cmo1y92ze02fxvxt0k17em6t2	cmo1y92x702fbvxt0rmd9fg7f	cmo1xc11n000kvxp0g32oj3wx	48000	2026-04-16 20:46:23.066	2026-04-16 20:46:23.066
cmo1y92zl02fzvxt0q3lw8xks	cmo1y92x702fbvxt0rmd9fg7f	cmo1xc10u000hvxp0dapryn3r	45000	2026-04-16 20:46:23.073	2026-04-16 20:46:23.073
cmo1y92zu02g1vxt08dohqlvu	cmo1y92x702fbvxt0rmd9fg7f	cmo1xc119000jvxp01snwxzoa	45000	2026-04-16 20:46:23.082	2026-04-16 20:46:23.082
cmo1y930902g5vxt0wyunar49	cmo1y930102g3vxt01k1pysa2	cmo1xsgrt0022vxv8sd7cckj7	25500	2026-04-16 20:46:23.098	2026-04-16 20:46:23.098
cmo1y930g02g7vxt0uc8rgj55	cmo1y930102g3vxt01k1pysa2	cmo1xc11v000lvxp07r6uljko	25500	2026-04-16 20:46:23.105	2026-04-16 20:46:23.105
cmo1y930m02g9vxt0e357pyjl	cmo1y930102g3vxt01k1pysa2	cmo1xc12y000qvxp0uqc7d8d8	25500	2026-04-16 20:46:23.11	2026-04-16 20:46:23.11
cmo1y930s02gbvxt0m93zroqu	cmo1y930102g3vxt01k1pysa2	cmo1xc13g000svxp0tbndc1wg	25500	2026-04-16 20:46:23.117	2026-04-16 20:46:23.117
cmo1y930z02gdvxt0esa86n51	cmo1y930102g3vxt01k1pysa2	cmo1xc12a000nvxp0f1zf3aqg	25500	2026-04-16 20:46:23.124	2026-04-16 20:46:23.124
cmo1y931702gfvxt0d945ngxb	cmo1y930102g3vxt01k1pysa2	cmo1xc12q000pvxp0kun82k4l	25500	2026-04-16 20:46:23.131	2026-04-16 20:46:23.131
cmo1y931e02ghvxt06gknonk6	cmo1y930102g3vxt01k1pysa2	cmo1xc138000rvxp0r16wi1bz	25500	2026-04-16 20:46:23.138	2026-04-16 20:46:23.138
cmo1y931m02gjvxt09fh4evk4	cmo1y930102g3vxt01k1pysa2	cmo1xc12i000ovxp01nisgvnu	25500	2026-04-16 20:46:23.146	2026-04-16 20:46:23.146
cmo1y931u02glvxt073crrk20	cmo1y930102g3vxt01k1pysa2	cmo1xc13o000tvxp0alok8jeb	25500	2026-04-16 20:46:23.154	2026-04-16 20:46:23.154
cmo1y932202gnvxt0m6641puf	cmo1y930102g3vxt01k1pysa2	cmo1xc123000mvxp0ul7pkio2	25500	2026-04-16 20:46:23.162	2026-04-16 20:46:23.162
cmo1y932a02gpvxt0ti6zf6nk	cmo1y930102g3vxt01k1pysa2	cmo1xc11n000kvxp0g32oj3wx	25500	2026-04-16 20:46:23.17	2026-04-16 20:46:23.17
cmo1y932g02grvxt0ji9jzxpc	cmo1y930102g3vxt01k1pysa2	cmo1xc10u000hvxp0dapryn3r	25500	2026-04-16 20:46:23.176	2026-04-16 20:46:23.176
cmo1y932o02gtvxt09jvd61wq	cmo1y930102g3vxt01k1pysa2	cmo1xc119000jvxp01snwxzoa	25500	2026-04-16 20:46:23.184	2026-04-16 20:46:23.184
cmo1y933302gxvxt0lzjoshh3	cmo1y932v02gvvxt0mqjaxgan	cmo1xsgrt0022vxv8sd7cckj7	18000	2026-04-16 20:46:23.199	2026-04-16 20:46:23.199
cmo1y933902gzvxt0ioh8crlr	cmo1y932v02gvvxt0mqjaxgan	cmo1xc11v000lvxp07r6uljko	18000	2026-04-16 20:46:23.206	2026-04-16 20:46:23.206
cmo1y933i02h1vxt0xzry4f6l	cmo1y932v02gvvxt0mqjaxgan	cmo1xc12y000qvxp0uqc7d8d8	18000	2026-04-16 20:46:23.214	2026-04-16 20:46:23.214
cmo1y933p02h3vxt031wpusws	cmo1y932v02gvvxt0mqjaxgan	cmo1xc13g000svxp0tbndc1wg	18000	2026-04-16 20:46:23.221	2026-04-16 20:46:23.221
cmo1y933v02h5vxt0z6rafwn3	cmo1y932v02gvvxt0mqjaxgan	cmo1xc12a000nvxp0f1zf3aqg	18000	2026-04-16 20:46:23.228	2026-04-16 20:46:23.228
cmo1y934402h7vxt0071oqqqs	cmo1y932v02gvvxt0mqjaxgan	cmo1xc12q000pvxp0kun82k4l	18000	2026-04-16 20:46:23.236	2026-04-16 20:46:23.236
cmo1y934b02h9vxt01gexnm89	cmo1y932v02gvvxt0mqjaxgan	cmo1xc138000rvxp0r16wi1bz	18000	2026-04-16 20:46:23.244	2026-04-16 20:46:23.244
cmo1y934i02hbvxt0k41gi5to	cmo1y932v02gvvxt0mqjaxgan	cmo1xc12i000ovxp01nisgvnu	18000	2026-04-16 20:46:23.25	2026-04-16 20:46:23.25
cmo1y934q02hdvxt0y7r1kt7g	cmo1y932v02gvvxt0mqjaxgan	cmo1xc13o000tvxp0alok8jeb	18000	2026-04-16 20:46:23.258	2026-04-16 20:46:23.258
cmo1y934y02hfvxt070grhs09	cmo1y932v02gvvxt0mqjaxgan	cmo1xc123000mvxp0ul7pkio2	18000	2026-04-16 20:46:23.266	2026-04-16 20:46:23.266
cmo1y935502hhvxt01onu7yj3	cmo1y932v02gvvxt0mqjaxgan	cmo1xc11n000kvxp0g32oj3wx	18000	2026-04-16 20:46:23.274	2026-04-16 20:46:23.274
cmo1y935e02hjvxt0usr20lyu	cmo1y932v02gvvxt0mqjaxgan	cmo1xc10u000hvxp0dapryn3r	18000	2026-04-16 20:46:23.283	2026-04-16 20:46:23.283
cmo1y935l02hlvxt0yx7htqif	cmo1y932v02gvvxt0mqjaxgan	cmo1xc119000jvxp01snwxzoa	18000	2026-04-16 20:46:23.29	2026-04-16 20:46:23.29
cmo1y936102hpvxt0a3nfo550	cmo1y935v02hnvxt0k4coe0ov	cmo1xsgrt0022vxv8sd7cckj7	25500	2026-04-16 20:46:23.305	2026-04-16 20:46:23.305
cmo1y936702hrvxt0jk3gc7ul	cmo1y935v02hnvxt0k4coe0ov	cmo1xc11v000lvxp07r6uljko	25500	2026-04-16 20:46:23.311	2026-04-16 20:46:23.311
cmo1y936d02htvxt0x0b53otv	cmo1y935v02hnvxt0k4coe0ov	cmo1xc12y000qvxp0uqc7d8d8	25500	2026-04-16 20:46:23.317	2026-04-16 20:46:23.317
cmo1y936j02hvvxt000k8ifh5	cmo1y935v02hnvxt0k4coe0ov	cmo1xc13g000svxp0tbndc1wg	25500	2026-04-16 20:46:23.324	2026-04-16 20:46:23.324
cmo1y936r02hxvxt0sfp5kr4o	cmo1y935v02hnvxt0k4coe0ov	cmo1xc12a000nvxp0f1zf3aqg	25500	2026-04-16 20:46:23.331	2026-04-16 20:46:23.331
cmo1y936z02hzvxt0epns84bp	cmo1y935v02hnvxt0k4coe0ov	cmo1xc12q000pvxp0kun82k4l	25500	2026-04-16 20:46:23.34	2026-04-16 20:46:23.34
cmo1y937702i1vxt04qw9qd9c	cmo1y935v02hnvxt0k4coe0ov	cmo1xc138000rvxp0r16wi1bz	25500	2026-04-16 20:46:23.348	2026-04-16 20:46:23.348
cmo1y937f02i3vxt096150wqb	cmo1y935v02hnvxt0k4coe0ov	cmo1xc12i000ovxp01nisgvnu	25500	2026-04-16 20:46:23.356	2026-04-16 20:46:23.356
cmo1y937p02i5vxt0npqbjoqe	cmo1y935v02hnvxt0k4coe0ov	cmo1xc13o000tvxp0alok8jeb	25500	2026-04-16 20:46:23.365	2026-04-16 20:46:23.365
cmo1y937w02i7vxt0nwelc37y	cmo1y935v02hnvxt0k4coe0ov	cmo1xc123000mvxp0ul7pkio2	25500	2026-04-16 20:46:23.372	2026-04-16 20:46:23.372
cmo1y938102i9vxt0tsrcs94t	cmo1y935v02hnvxt0k4coe0ov	cmo1xc11n000kvxp0g32oj3wx	25500	2026-04-16 20:46:23.378	2026-04-16 20:46:23.378
cmo1y938702ibvxt08q474s2j	cmo1y935v02hnvxt0k4coe0ov	cmo1xc10u000hvxp0dapryn3r	25500	2026-04-16 20:46:23.384	2026-04-16 20:46:23.384
cmo1y938e02idvxt0u1mym4ga	cmo1y935v02hnvxt0k4coe0ov	cmo1xc119000jvxp01snwxzoa	25500	2026-04-16 20:46:23.39	2026-04-16 20:46:23.39
cmo1y938u02ihvxt0fdyolwej	cmo1y938m02ifvxt0px8npgb2	cmo1xsgrt0022vxv8sd7cckj7	19000	2026-04-16 20:46:23.406	2026-04-16 20:46:23.406
cmo1y939302ijvxt0bvkgw132	cmo1y938m02ifvxt0px8npgb2	cmo1xc11v000lvxp07r6uljko	19000	2026-04-16 20:46:23.415	2026-04-16 20:46:23.415
cmo1y939b02ilvxt0k7ibr6iz	cmo1y938m02ifvxt0px8npgb2	cmo1xc12y000qvxp0uqc7d8d8	19000	2026-04-16 20:46:23.423	2026-04-16 20:46:23.423
cmo1y939k02invxt0whrfsxh8	cmo1y938m02ifvxt0px8npgb2	cmo1xc13g000svxp0tbndc1wg	19000	2026-04-16 20:46:23.433	2026-04-16 20:46:23.433
cmo1y939r02ipvxt0wr0j7zhu	cmo1y938m02ifvxt0px8npgb2	cmo1xc12a000nvxp0f1zf3aqg	19000	2026-04-16 20:46:23.439	2026-04-16 20:46:23.439
cmo1y939x02irvxt0b3d16rly	cmo1y938m02ifvxt0px8npgb2	cmo1xc12q000pvxp0kun82k4l	19000	2026-04-16 20:46:23.445	2026-04-16 20:46:23.445
cmo1y93a502itvxt0j5bz1rde	cmo1y938m02ifvxt0px8npgb2	cmo1xc138000rvxp0r16wi1bz	19000	2026-04-16 20:46:23.454	2026-04-16 20:46:23.454
cmo1y93ac02ivvxt0b9ejx1wt	cmo1y938m02ifvxt0px8npgb2	cmo1xc12i000ovxp01nisgvnu	19000	2026-04-16 20:46:23.461	2026-04-16 20:46:23.461
cmo1y93ai02ixvxt0one0qren	cmo1y938m02ifvxt0px8npgb2	cmo1xc13o000tvxp0alok8jeb	19000	2026-04-16 20:46:23.467	2026-04-16 20:46:23.467
cmo1y93aq02izvxt0hky4oshw	cmo1y938m02ifvxt0px8npgb2	cmo1xc123000mvxp0ul7pkio2	19000	2026-04-16 20:46:23.474	2026-04-16 20:46:23.474
cmo1y93ay02j1vxt011j93lro	cmo1y938m02ifvxt0px8npgb2	cmo1xc11n000kvxp0g32oj3wx	19000	2026-04-16 20:46:23.482	2026-04-16 20:46:23.482
cmo1y93b502j3vxt06m9xtohp	cmo1y938m02ifvxt0px8npgb2	cmo1xc10u000hvxp0dapryn3r	19000	2026-04-16 20:46:23.49	2026-04-16 20:46:23.49
cmo1y93be02j5vxt056854xu6	cmo1y938m02ifvxt0px8npgb2	cmo1xc119000jvxp01snwxzoa	19000	2026-04-16 20:46:23.499	2026-04-16 20:46:23.499
cmo1y93br02j9vxt0bwss8b9f	cmo1y93bl02j7vxt0oue1506b	cmo1xsgrt0022vxv8sd7cckj7	16000	2026-04-16 20:46:23.512	2026-04-16 20:46:23.512
cmo1y93c402jbvxt0hxs7dvge	cmo1y93bl02j7vxt0oue1506b	cmo1xc11v000lvxp07r6uljko	16000	2026-04-16 20:46:23.524	2026-04-16 20:46:23.524
cmo1y93ce02jdvxt0yxt5t431	cmo1y93bl02j7vxt0oue1506b	cmo1xc12y000qvxp0uqc7d8d8	16000	2026-04-16 20:46:23.534	2026-04-16 20:46:23.534
cmo1y93cl02jfvxt0g2f2yzgn	cmo1y93bl02j7vxt0oue1506b	cmo1xc13g000svxp0tbndc1wg	16000	2026-04-16 20:46:23.541	2026-04-16 20:46:23.541
cmo1y93cu02jhvxt0snxa5m3i	cmo1y93bl02j7vxt0oue1506b	cmo1xc12a000nvxp0f1zf3aqg	16000	2026-04-16 20:46:23.551	2026-04-16 20:46:23.551
cmo1y93d202jjvxt0x2x45ndl	cmo1y93bl02j7vxt0oue1506b	cmo1xc12q000pvxp0kun82k4l	16000	2026-04-16 20:46:23.558	2026-04-16 20:46:23.558
cmo1y93dc02jlvxt005nqhehl	cmo1y93bl02j7vxt0oue1506b	cmo1xc138000rvxp0r16wi1bz	16000	2026-04-16 20:46:23.568	2026-04-16 20:46:23.568
cmo1y93dk02jnvxt0g403omab	cmo1y93bl02j7vxt0oue1506b	cmo1xc12i000ovxp01nisgvnu	16000	2026-04-16 20:46:23.576	2026-04-16 20:46:23.576
cmo1y93dr02jpvxt0tc6l0my7	cmo1y93bl02j7vxt0oue1506b	cmo1xc13o000tvxp0alok8jeb	16000	2026-04-16 20:46:23.584	2026-04-16 20:46:23.584
cmo1y93dy02jrvxt0w6yj89gs	cmo1y93bl02j7vxt0oue1506b	cmo1xc123000mvxp0ul7pkio2	16000	2026-04-16 20:46:23.59	2026-04-16 20:46:23.59
cmo1y93e602jtvxt07xz51356	cmo1y93bl02j7vxt0oue1506b	cmo1xc11n000kvxp0g32oj3wx	16000	2026-04-16 20:46:23.599	2026-04-16 20:46:23.599
cmo1y93ej02jvvxt0ypiykxsl	cmo1y93bl02j7vxt0oue1506b	cmo1xc10u000hvxp0dapryn3r	16000	2026-04-16 20:46:23.611	2026-04-16 20:46:23.611
cmo1y93es02jxvxt0hhchh2da	cmo1y93bl02j7vxt0oue1506b	cmo1xc119000jvxp01snwxzoa	16000	2026-04-16 20:46:23.62	2026-04-16 20:46:23.62
cmo1y93f902k1vxt0twkko7k0	cmo1y93f002jzvxt0y20j87zp	cmo1xsgrt0022vxv8sd7cckj7	21000	2026-04-16 20:46:23.637	2026-04-16 20:46:23.637
cmo1y93ff02k3vxt0t32uj56e	cmo1y93f002jzvxt0y20j87zp	cmo1xc11v000lvxp07r6uljko	21000	2026-04-16 20:46:23.643	2026-04-16 20:46:23.643
cmo1y93fl02k5vxt0ze4p5xsu	cmo1y93f002jzvxt0y20j87zp	cmo1xc12y000qvxp0uqc7d8d8	21000	2026-04-16 20:46:23.65	2026-04-16 20:46:23.65
cmo1y93ft02k7vxt037lmx48i	cmo1y93f002jzvxt0y20j87zp	cmo1xc13g000svxp0tbndc1wg	21000	2026-04-16 20:46:23.657	2026-04-16 20:46:23.657
cmo1y93g102k9vxt0lq4m6ga8	cmo1y93f002jzvxt0y20j87zp	cmo1xc12a000nvxp0f1zf3aqg	21000	2026-04-16 20:46:23.665	2026-04-16 20:46:23.665
cmo1y93g902kbvxt0v5v9zbij	cmo1y93f002jzvxt0y20j87zp	cmo1xc12q000pvxp0kun82k4l	21000	2026-04-16 20:46:23.673	2026-04-16 20:46:23.673
cmo1y93gi02kdvxt0w25nehkh	cmo1y93f002jzvxt0y20j87zp	cmo1xc138000rvxp0r16wi1bz	21000	2026-04-16 20:46:23.682	2026-04-16 20:46:23.682
cmo1y93gq02kfvxt070qrupo2	cmo1y93f002jzvxt0y20j87zp	cmo1xc12i000ovxp01nisgvnu	21000	2026-04-16 20:46:23.69	2026-04-16 20:46:23.69
cmo1y93gz02khvxt0baqfvn9m	cmo1y93f002jzvxt0y20j87zp	cmo1xc13o000tvxp0alok8jeb	21000	2026-04-16 20:46:23.698	2026-04-16 20:46:23.698
cmo1y93h602kjvxt0wof8p1og	cmo1y93f002jzvxt0y20j87zp	cmo1xc123000mvxp0ul7pkio2	21000	2026-04-16 20:46:23.706	2026-04-16 20:46:23.706
cmo1y93hf02klvxt0b8gdu94q	cmo1y93f002jzvxt0y20j87zp	cmo1xc11n000kvxp0g32oj3wx	21000	2026-04-16 20:46:23.715	2026-04-16 20:46:23.715
cmo1y93hm02knvxt05pwrfbgp	cmo1y93f002jzvxt0y20j87zp	cmo1xc10u000hvxp0dapryn3r	21000	2026-04-16 20:46:23.723	2026-04-16 20:46:23.723
cmo1y93hv02kpvxt06yz0cxc9	cmo1y93f002jzvxt0y20j87zp	cmo1xc119000jvxp01snwxzoa	21000	2026-04-16 20:46:23.731	2026-04-16 20:46:23.731
cmo1y93ic02ktvxt0c3vju54j	cmo1y93i302krvxt0xhgoqd9s	cmo1xsgrt0022vxv8sd7cckj7	20000	2026-04-16 20:46:23.748	2026-04-16 20:46:23.748
cmo1y93ik02kvvxt0ecjsgn5h	cmo1y93i302krvxt0xhgoqd9s	cmo1xc11v000lvxp07r6uljko	20000	2026-04-16 20:46:23.756	2026-04-16 20:46:23.756
cmo1y93it02kxvxt0cjt6dhb8	cmo1y93i302krvxt0xhgoqd9s	cmo1xc12y000qvxp0uqc7d8d8	20000	2026-04-16 20:46:23.765	2026-04-16 20:46:23.765
cmo1y93j202kzvxt0rgr5dp0q	cmo1y93i302krvxt0xhgoqd9s	cmo1xc13g000svxp0tbndc1wg	20000	2026-04-16 20:46:23.774	2026-04-16 20:46:23.774
cmo1y93ja02l1vxt04rzij72o	cmo1y93i302krvxt0xhgoqd9s	cmo1xc12a000nvxp0f1zf3aqg	20000	2026-04-16 20:46:23.783	2026-04-16 20:46:23.783
cmo1y93jh02l3vxt0vuxqc25r	cmo1y93i302krvxt0xhgoqd9s	cmo1xc12q000pvxp0kun82k4l	20000	2026-04-16 20:46:23.79	2026-04-16 20:46:23.79
cmo1y93jm02l5vxt0tatiu7sk	cmo1y93i302krvxt0xhgoqd9s	cmo1xc138000rvxp0r16wi1bz	20000	2026-04-16 20:46:23.795	2026-04-16 20:46:23.795
cmo1y93jv02l7vxt0mbzdxjd9	cmo1y93i302krvxt0xhgoqd9s	cmo1xc12i000ovxp01nisgvnu	20000	2026-04-16 20:46:23.803	2026-04-16 20:46:23.803
cmo1y93k202l9vxt0coqd7513	cmo1y93i302krvxt0xhgoqd9s	cmo1xc13o000tvxp0alok8jeb	20000	2026-04-16 20:46:23.81	2026-04-16 20:46:23.81
cmo1y93k902lbvxt0xjwycych	cmo1y93i302krvxt0xhgoqd9s	cmo1xc123000mvxp0ul7pkio2	20000	2026-04-16 20:46:23.817	2026-04-16 20:46:23.817
cmo1y93kg02ldvxt02whdlni5	cmo1y93i302krvxt0xhgoqd9s	cmo1xc11n000kvxp0g32oj3wx	20000	2026-04-16 20:46:23.825	2026-04-16 20:46:23.825
cmo1y93ko02lfvxt0n29b4a6i	cmo1y93i302krvxt0xhgoqd9s	cmo1xc10u000hvxp0dapryn3r	20000	2026-04-16 20:46:23.832	2026-04-16 20:46:23.832
cmo1y93ku02lhvxt0bgv3l0b8	cmo1y93i302krvxt0xhgoqd9s	cmo1xc119000jvxp01snwxzoa	20000	2026-04-16 20:46:23.839	2026-04-16 20:46:23.839
cmo1y93l602llvxt0nymz0era	cmo1y93l002ljvxt0h0e9ep0y	cmo1xsgrt0022vxv8sd7cckj7	40000	2026-04-16 20:46:23.85	2026-04-16 20:46:23.85
cmo1y93ld02lnvxt0vt26wf6p	cmo1y93l002ljvxt0h0e9ep0y	cmo1xc11v000lvxp07r6uljko	40000	2026-04-16 20:46:23.857	2026-04-16 20:46:23.857
cmo1y93ll02lpvxt0jub01uil	cmo1y93l002ljvxt0h0e9ep0y	cmo1xc12y000qvxp0uqc7d8d8	40000	2026-04-16 20:46:23.865	2026-04-16 20:46:23.865
cmo1y93ls02lrvxt0lgu60yus	cmo1y93l002ljvxt0h0e9ep0y	cmo1xc13g000svxp0tbndc1wg	40000	2026-04-16 20:46:23.872	2026-04-16 20:46:23.872
cmo1y93lz02ltvxt0209vv3o9	cmo1y93l002ljvxt0h0e9ep0y	cmo1xc12a000nvxp0f1zf3aqg	40000	2026-04-16 20:46:23.879	2026-04-16 20:46:23.879
cmo1y93m802lvvxt0in5acivp	cmo1y93l002ljvxt0h0e9ep0y	cmo1xc12q000pvxp0kun82k4l	40000	2026-04-16 20:46:23.888	2026-04-16 20:46:23.888
cmo1y93me02lxvxt0mva79mt5	cmo1y93l002ljvxt0h0e9ep0y	cmo1xc138000rvxp0r16wi1bz	40000	2026-04-16 20:46:23.895	2026-04-16 20:46:23.895
cmo1y93mn02lzvxt0lmn8sx4a	cmo1y93l002ljvxt0h0e9ep0y	cmo1xc12i000ovxp01nisgvnu	40000	2026-04-16 20:46:23.904	2026-04-16 20:46:23.904
cmo1y93mv02m1vxt06avx7kas	cmo1y93l002ljvxt0h0e9ep0y	cmo1xc13o000tvxp0alok8jeb	40000	2026-04-16 20:46:23.911	2026-04-16 20:46:23.911
cmo1y93n502m3vxt0kthm8psu	cmo1y93l002ljvxt0h0e9ep0y	cmo1xc123000mvxp0ul7pkio2	40000	2026-04-16 20:46:23.921	2026-04-16 20:46:23.921
cmo1y93nb02m5vxt05zgajgvc	cmo1y93l002ljvxt0h0e9ep0y	cmo1xc11n000kvxp0g32oj3wx	43000	2026-04-16 20:46:23.927	2026-04-16 20:46:23.927
cmo1y93nh02m7vxt0pbymzvn1	cmo1y93l002ljvxt0h0e9ep0y	cmo1xc10u000hvxp0dapryn3r	40000	2026-04-16 20:46:23.933	2026-04-16 20:46:23.933
cmo1y93no02m9vxt0p61dakpr	cmo1y93l002ljvxt0h0e9ep0y	cmo1xc119000jvxp01snwxzoa	40000	2026-04-16 20:46:23.941	2026-04-16 20:46:23.941
cmo1y93o302mdvxt0mxdon9jr	cmo1y93nw02mbvxt0dzqjfdmm	cmo1xsgrt0022vxv8sd7cckj7	25500	2026-04-16 20:46:23.956	2026-04-16 20:46:23.956
cmo1y93ob02mfvxt0umyg4hj3	cmo1y93nw02mbvxt0dzqjfdmm	cmo1xc11v000lvxp07r6uljko	25500	2026-04-16 20:46:23.963	2026-04-16 20:46:23.963
cmo1y93oj02mhvxt0wah3274f	cmo1y93nw02mbvxt0dzqjfdmm	cmo1xc12y000qvxp0uqc7d8d8	25500	2026-04-16 20:46:23.971	2026-04-16 20:46:23.971
cmo1y93op02mjvxt056fu53zu	cmo1y93nw02mbvxt0dzqjfdmm	cmo1xc13g000svxp0tbndc1wg	25500	2026-04-16 20:46:23.977	2026-04-16 20:46:23.977
cmo1y93ou02mlvxt0ir4eazup	cmo1y93nw02mbvxt0dzqjfdmm	cmo1xc12a000nvxp0f1zf3aqg	25500	2026-04-16 20:46:23.983	2026-04-16 20:46:23.983
cmo1y93p202mnvxt0kslkgamr	cmo1y93nw02mbvxt0dzqjfdmm	cmo1xc12q000pvxp0kun82k4l	25500	2026-04-16 20:46:23.99	2026-04-16 20:46:23.99
cmo1y93pa02mpvxt0s3ohxjqi	cmo1y93nw02mbvxt0dzqjfdmm	cmo1xc138000rvxp0r16wi1bz	25500	2026-04-16 20:46:23.999	2026-04-16 20:46:23.999
cmo1y93ph02mrvxt0e0nzqz0b	cmo1y93nw02mbvxt0dzqjfdmm	cmo1xc12i000ovxp01nisgvnu	25500	2026-04-16 20:46:24.006	2026-04-16 20:46:24.006
cmo1y93pq02mtvxt039waykop	cmo1y93nw02mbvxt0dzqjfdmm	cmo1xc13o000tvxp0alok8jeb	25500	2026-04-16 20:46:24.014	2026-04-16 20:46:24.014
cmo1y93py02mvvxt0sefu22be	cmo1y93nw02mbvxt0dzqjfdmm	cmo1xc123000mvxp0ul7pkio2	25500	2026-04-16 20:46:24.022	2026-04-16 20:46:24.022
cmo1y93q702mxvxt05mbt7vtm	cmo1y93nw02mbvxt0dzqjfdmm	cmo1xc11n000kvxp0g32oj3wx	25500	2026-04-16 20:46:24.031	2026-04-16 20:46:24.031
cmo1y93qd02mzvxt04ed33zu3	cmo1y93nw02mbvxt0dzqjfdmm	cmo1xc10u000hvxp0dapryn3r	25500	2026-04-16 20:46:24.038	2026-04-16 20:46:24.038
cmo1y93qj02n1vxt0unzckart	cmo1y93nw02mbvxt0dzqjfdmm	cmo1xc119000jvxp01snwxzoa	25500	2026-04-16 20:46:24.043	2026-04-16 20:46:24.043
cmo1y93qx02n5vxt082ck5mcc	cmo1y93qp02n3vxt0fp56p7rj	cmo1xsgrt0022vxv8sd7cckj7	60000	2026-04-16 20:46:24.057	2026-04-16 20:46:24.057
cmo1y93r402n7vxt0zz2e2mxh	cmo1y93qp02n3vxt0fp56p7rj	cmo1xc11v000lvxp07r6uljko	60000	2026-04-16 20:46:24.064	2026-04-16 20:46:24.064
cmo1y93rc02n9vxt0zcbljgsz	cmo1y93qp02n3vxt0fp56p7rj	cmo1xc12y000qvxp0uqc7d8d8	60000	2026-04-16 20:46:24.072	2026-04-16 20:46:24.072
cmo1y93rj02nbvxt0koh1fepn	cmo1y93qp02n3vxt0fp56p7rj	cmo1xc13g000svxp0tbndc1wg	60000	2026-04-16 20:46:24.079	2026-04-16 20:46:24.079
cmo1y93rr02ndvxt0m5nnoiko	cmo1y93qp02n3vxt0fp56p7rj	cmo1xc12a000nvxp0f1zf3aqg	60000	2026-04-16 20:46:24.087	2026-04-16 20:46:24.087
cmo1y93ry02nfvxt0fjbnznvr	cmo1y93qp02n3vxt0fp56p7rj	cmo1xc12q000pvxp0kun82k4l	60000	2026-04-16 20:46:24.095	2026-04-16 20:46:24.095
cmo1y93s802nhvxt058oap9pu	cmo1y93qp02n3vxt0fp56p7rj	cmo1xc138000rvxp0r16wi1bz	60000	2026-04-16 20:46:24.104	2026-04-16 20:46:24.104
cmo1y93sf02njvxt07s2zibrz	cmo1y93qp02n3vxt0fp56p7rj	cmo1xc12i000ovxp01nisgvnu	60000	2026-04-16 20:46:24.111	2026-04-16 20:46:24.111
cmo1y93so02nlvxt00jl664jq	cmo1y93qp02n3vxt0fp56p7rj	cmo1xc13o000tvxp0alok8jeb	60000	2026-04-16 20:46:24.12	2026-04-16 20:46:24.12
cmo1y93sv02nnvxt0zhun8yip	cmo1y93qp02n3vxt0fp56p7rj	cmo1xc123000mvxp0ul7pkio2	60000	2026-04-16 20:46:24.127	2026-04-16 20:46:24.127
cmo1y93t102npvxt02fr7cn4f	cmo1y93qp02n3vxt0fp56p7rj	cmo1xc11n000kvxp0g32oj3wx	63000	2026-04-16 20:46:24.133	2026-04-16 20:46:24.133
cmo1y93t802nrvxt0d5a1mkyg	cmo1y93qp02n3vxt0fp56p7rj	cmo1xc10u000hvxp0dapryn3r	60000	2026-04-16 20:46:24.141	2026-04-16 20:46:24.141
cmo1y93tg02ntvxt0zhqtfz94	cmo1y93qp02n3vxt0fp56p7rj	cmo1xc119000jvxp01snwxzoa	60000	2026-04-16 20:46:24.148	2026-04-16 20:46:24.148
cmo1y93tv02nxvxt0bz94niq8	cmo1y93tn02nvvxt04ak1nhea	cmo1xsgrt0022vxv8sd7cckj7	40000	2026-04-16 20:46:24.163	2026-04-16 20:46:24.163
cmo1y93u402nzvxt0uu1q7s9f	cmo1y93tn02nvvxt04ak1nhea	cmo1xc11v000lvxp07r6uljko	40000	2026-04-16 20:46:24.172	2026-04-16 20:46:24.172
cmo1y93ub02o1vxt0ei2qrqty	cmo1y93tn02nvvxt04ak1nhea	cmo1xc12y000qvxp0uqc7d8d8	40000	2026-04-16 20:46:24.18	2026-04-16 20:46:24.18
cmo1y93ul02o3vxt08i5rgd2b	cmo1y93tn02nvvxt04ak1nhea	cmo1xc13g000svxp0tbndc1wg	40000	2026-04-16 20:46:24.189	2026-04-16 20:46:24.189
cmo1y93us02o5vxt09dy5uau7	cmo1y93tn02nvvxt04ak1nhea	cmo1xc12a000nvxp0f1zf3aqg	40000	2026-04-16 20:46:24.196	2026-04-16 20:46:24.196
cmo1y93v002o7vxt06yw7utor	cmo1y93tn02nvvxt04ak1nhea	cmo1xc12q000pvxp0kun82k4l	40000	2026-04-16 20:46:24.204	2026-04-16 20:46:24.204
cmo1y93v702o9vxt06gp6th0p	cmo1y93tn02nvvxt04ak1nhea	cmo1xc138000rvxp0r16wi1bz	40000	2026-04-16 20:46:24.212	2026-04-16 20:46:24.212
cmo1y93vf02obvxt06kegjks6	cmo1y93tn02nvvxt04ak1nhea	cmo1xc12i000ovxp01nisgvnu	40000	2026-04-16 20:46:24.219	2026-04-16 20:46:24.219
cmo1y93vn02odvxt03g12cmya	cmo1y93tn02nvvxt04ak1nhea	cmo1xc13o000tvxp0alok8jeb	40000	2026-04-16 20:46:24.227	2026-04-16 20:46:24.227
cmo1y93vt02ofvxt07rug46ww	cmo1y93tn02nvvxt04ak1nhea	cmo1xc123000mvxp0ul7pkio2	40000	2026-04-16 20:46:24.234	2026-04-16 20:46:24.234
cmo1y93vz02ohvxt0gqoxga0n	cmo1y93tn02nvvxt04ak1nhea	cmo1xc11n000kvxp0g32oj3wx	43000	2026-04-16 20:46:24.239	2026-04-16 20:46:24.239
cmo1y93w402ojvxt0ykagltrt	cmo1y93tn02nvvxt04ak1nhea	cmo1xc10u000hvxp0dapryn3r	40000	2026-04-16 20:46:24.245	2026-04-16 20:46:24.245
cmo1y93we02olvxt0ys6j8178	cmo1y93tn02nvvxt04ak1nhea	cmo1xc119000jvxp01snwxzoa	40000	2026-04-16 20:46:24.254	2026-04-16 20:46:24.254
cmo1y93wv02opvxt0bg420d9q	cmo1y93wl02onvxt0bh4kzbpp	cmo1xsgrt0022vxv8sd7cckj7	75000	2026-04-16 20:46:24.271	2026-04-16 20:46:24.271
cmo1y93x602orvxt0bu4ape2y	cmo1y93wl02onvxt0bh4kzbpp	cmo1xc11v000lvxp07r6uljko	75000	2026-04-16 20:46:24.282	2026-04-16 20:46:24.282
cmo1y93xw02otvxt0nr5sc2wr	cmo1y93wl02onvxt0bh4kzbpp	cmo1xc10u000hvxp0dapryn3r	75000	2026-04-16 20:46:24.308	2026-04-16 20:46:24.308
cmo1y93yd02oxvxt0f8nhemr1	cmo1y93y502ovvxt0a2yqm5mw	cmo1xsgrt0022vxv8sd7cckj7	100000	2026-04-16 20:46:24.325	2026-04-16 20:46:24.325
cmo1y93yk02ozvxt08oxill5w	cmo1y93y502ovvxt0a2yqm5mw	cmo1xc11v000lvxp07r6uljko	100000	2026-04-16 20:46:24.332	2026-04-16 20:46:24.332
cmo1y93ys02p1vxt0b20fx0nl	cmo1y93y502ovvxt0a2yqm5mw	cmo1xc12y000qvxp0uqc7d8d8	100000	2026-04-16 20:46:24.34	2026-04-16 20:46:24.34
cmo1y93z002p3vxt04m2lpt9h	cmo1y93y502ovvxt0a2yqm5mw	cmo1xc13g000svxp0tbndc1wg	100000	2026-04-16 20:46:24.348	2026-04-16 20:46:24.348
cmo1y93z702p5vxt0n02khs6d	cmo1y93y502ovvxt0a2yqm5mw	cmo1xc12a000nvxp0f1zf3aqg	100000	2026-04-16 20:46:24.355	2026-04-16 20:46:24.355
cmo1y93zg02p7vxt0h4tpud3d	cmo1y93y502ovvxt0a2yqm5mw	cmo1xc12q000pvxp0kun82k4l	100000	2026-04-16 20:46:24.363	2026-04-16 20:46:24.363
cmo1y93zn02p9vxt09hszdhng	cmo1y93y502ovvxt0a2yqm5mw	cmo1xc138000rvxp0r16wi1bz	100000	2026-04-16 20:46:24.371	2026-04-16 20:46:24.371
cmo1y93zt02pbvxt0ngruwrox	cmo1y93y502ovvxt0a2yqm5mw	cmo1xc12i000ovxp01nisgvnu	100000	2026-04-16 20:46:24.377	2026-04-16 20:46:24.377
cmo1y93zz02pdvxt0ukjorbgd	cmo1y93y502ovvxt0a2yqm5mw	cmo1xc13o000tvxp0alok8jeb	100000	2026-04-16 20:46:24.383	2026-04-16 20:46:24.383
cmo1y940602pfvxt0ynxrlqun	cmo1y93y502ovvxt0a2yqm5mw	cmo1xc123000mvxp0ul7pkio2	100000	2026-04-16 20:46:24.39	2026-04-16 20:46:24.39
cmo1y940e02phvxt0i59o2tc9	cmo1y93y502ovvxt0a2yqm5mw	cmo1xc11n000kvxp0g32oj3wx	100000	2026-04-16 20:46:24.398	2026-04-16 20:46:24.398
cmo1y940l02pjvxt0ursaotq0	cmo1y93y502ovvxt0a2yqm5mw	cmo1xc10u000hvxp0dapryn3r	100000	2026-04-16 20:46:24.405	2026-04-16 20:46:24.405
cmo1y940t02plvxt0smtqqh8g	cmo1y93y502ovvxt0a2yqm5mw	cmo1xc119000jvxp01snwxzoa	100000	2026-04-16 20:46:24.413	2026-04-16 20:46:24.413
cmo1y941902ppvxt0xbibw3fp	cmo1y941102pnvxt09fxom8bo	cmo1xsgrt0022vxv8sd7cckj7	190000	2026-04-16 20:46:24.429	2026-04-16 20:46:24.429
cmo1y941h02prvxt0limg1arv	cmo1y941102pnvxt09fxom8bo	cmo1xc11v000lvxp07r6uljko	190000	2026-04-16 20:46:24.437	2026-04-16 20:46:24.437
cmo1y942202ptvxt093wjxnh7	cmo1y941102pnvxt09fxom8bo	cmo1xc10u000hvxp0dapryn3r	190000	2026-04-16 20:46:24.458	2026-04-16 20:46:24.458
cmo1y942902pvvxt0vlyt9q1k	cmo1y941102pnvxt09fxom8bo	cmo1xc119000jvxp01snwxzoa	190000	2026-04-16 20:46:24.466	2026-04-16 20:46:24.466
cmo1y942p02pzvxt0w5p51ng0	cmo1y942g02pxvxt0goddw81e	cmo1xsgrt0022vxv8sd7cckj7	33000	2026-04-16 20:46:24.481	2026-04-16 20:46:24.481
cmo1y942x02q1vxt0zpsc7soc	cmo1y942g02pxvxt0goddw81e	cmo1xc11v000lvxp07r6uljko	33000	2026-04-16 20:46:24.489	2026-04-16 20:46:24.489
cmo1y943302q3vxt0rq5pb3gd	cmo1y942g02pxvxt0goddw81e	cmo1xc12y000qvxp0uqc7d8d8	33000	2026-04-16 20:46:24.495	2026-04-16 20:46:24.495
cmo1y943c02q5vxt0w3zy07wi	cmo1y942g02pxvxt0goddw81e	cmo1xc13g000svxp0tbndc1wg	33000	2026-04-16 20:46:24.505	2026-04-16 20:46:24.505
cmo1y943k02q7vxt0aqntj62u	cmo1y942g02pxvxt0goddw81e	cmo1xc12a000nvxp0f1zf3aqg	33000	2026-04-16 20:46:24.512	2026-04-16 20:46:24.512
cmo1y943s02q9vxt037qgg8vv	cmo1y942g02pxvxt0goddw81e	cmo1xc12q000pvxp0kun82k4l	33000	2026-04-16 20:46:24.52	2026-04-16 20:46:24.52
cmo1y943z02qbvxt0fmxnezl9	cmo1y942g02pxvxt0goddw81e	cmo1xc138000rvxp0r16wi1bz	33000	2026-04-16 20:46:24.527	2026-04-16 20:46:24.527
cmo1y944502qdvxt0m49hb41g	cmo1y942g02pxvxt0goddw81e	cmo1xc12i000ovxp01nisgvnu	33000	2026-04-16 20:46:24.533	2026-04-16 20:46:24.533
cmo1y944c02qfvxt000jzd47d	cmo1y942g02pxvxt0goddw81e	cmo1xc13o000tvxp0alok8jeb	33000	2026-04-16 20:46:24.54	2026-04-16 20:46:24.54
cmo1y944k02qhvxt0lhueet7p	cmo1y942g02pxvxt0goddw81e	cmo1xc123000mvxp0ul7pkio2	33000	2026-04-16 20:46:24.548	2026-04-16 20:46:24.548
cmo1y944s02qjvxt0o8x9m9jo	cmo1y942g02pxvxt0goddw81e	cmo1xc11n000kvxp0g32oj3wx	33000	2026-04-16 20:46:24.556	2026-04-16 20:46:24.556
cmo1y945102qlvxt0fyltrzah	cmo1y942g02pxvxt0goddw81e	cmo1xc10u000hvxp0dapryn3r	33000	2026-04-16 20:46:24.565	2026-04-16 20:46:24.565
cmo1y945802qnvxt0rdo0wvg1	cmo1y942g02pxvxt0goddw81e	cmo1xc119000jvxp01snwxzoa	33000	2026-04-16 20:46:24.572	2026-04-16 20:46:24.572
cmo1y945l02qrvxt0qwlw7wm6	cmo1y945d02qpvxt0cm577h9n	cmo1xsgrt0022vxv8sd7cckj7	60000	2026-04-16 20:46:24.586	2026-04-16 20:46:24.586
cmo1y945z02qtvxt091jifda2	cmo1y945d02qpvxt0cm577h9n	cmo1xc11v000lvxp07r6uljko	60000	2026-04-16 20:46:24.599	2026-04-16 20:46:24.599
cmo1y946602qvvxt0w969ox77	cmo1y945d02qpvxt0cm577h9n	cmo1xc12y000qvxp0uqc7d8d8	60000	2026-04-16 20:46:24.606	2026-04-16 20:46:24.606
cmo1y946e02qxvxt0wcuj55ov	cmo1y945d02qpvxt0cm577h9n	cmo1xc13g000svxp0tbndc1wg	60000	2026-04-16 20:46:24.614	2026-04-16 20:46:24.614
cmo1y946m02qzvxt0mpw1yxlu	cmo1y945d02qpvxt0cm577h9n	cmo1xc12a000nvxp0f1zf3aqg	60000	2026-04-16 20:46:24.622	2026-04-16 20:46:24.622
cmo1y946v02r1vxt0k6c573hq	cmo1y945d02qpvxt0cm577h9n	cmo1xc12q000pvxp0kun82k4l	60000	2026-04-16 20:46:24.631	2026-04-16 20:46:24.631
cmo1y947202r3vxt0cypfxirr	cmo1y945d02qpvxt0cm577h9n	cmo1xc138000rvxp0r16wi1bz	60000	2026-04-16 20:46:24.638	2026-04-16 20:46:24.638
cmo1y947702r5vxt0pdftrdhb	cmo1y945d02qpvxt0cm577h9n	cmo1xc12i000ovxp01nisgvnu	60000	2026-04-16 20:46:24.643	2026-04-16 20:46:24.643
cmo1y947e02r7vxt0mcrr2ccm	cmo1y945d02qpvxt0cm577h9n	cmo1xc13o000tvxp0alok8jeb	60000	2026-04-16 20:46:24.65	2026-04-16 20:46:24.65
cmo1y947l02r9vxt0g5a7giqn	cmo1y945d02qpvxt0cm577h9n	cmo1xc123000mvxp0ul7pkio2	60000	2026-04-16 20:46:24.658	2026-04-16 20:46:24.658
cmo1y947t02rbvxt0gdbarsfl	cmo1y945d02qpvxt0cm577h9n	cmo1xc11n000kvxp0g32oj3wx	63000	2026-04-16 20:46:24.665	2026-04-16 20:46:24.665
cmo1y948002rdvxt0oik27gm7	cmo1y945d02qpvxt0cm577h9n	cmo1xc10u000hvxp0dapryn3r	60000	2026-04-16 20:46:24.673	2026-04-16 20:46:24.673
cmo1y948802rfvxt0fmaalv1u	cmo1y945d02qpvxt0cm577h9n	cmo1xc119000jvxp01snwxzoa	60000	2026-04-16 20:46:24.679	2026-04-16 20:46:24.679
cmo1y948q02rjvxt0wtmqehpl	cmo1y948g02rhvxt0wbj5ouq4	cmo1xsgrt0022vxv8sd7cckj7	160000	2026-04-16 20:46:24.698	2026-04-16 20:46:24.698
cmo1y948x02rlvxt06ttmxcpz	cmo1y948g02rhvxt0wbj5ouq4	cmo1xc11v000lvxp07r6uljko	160000	2026-04-16 20:46:24.705	2026-04-16 20:46:24.705
cmo1y949i02rnvxt0xze0ytby	cmo1y948g02rhvxt0wbj5ouq4	cmo1xc10u000hvxp0dapryn3r	160000	2026-04-16 20:46:24.727	2026-04-16 20:46:24.727
cmo1y949y02rrvxt0dnaa5mrc	cmo1y949r02rpvxt0tp90r46w	cmo1xsgrt0022vxv8sd7cckj7	160000	2026-04-16 20:46:24.742	2026-04-16 20:46:24.742
cmo1y94a502rtvxt06xh5v3eu	cmo1y949r02rpvxt0tp90r46w	cmo1xc11v000lvxp07r6uljko	160000	2026-04-16 20:46:24.749	2026-04-16 20:46:24.749
cmo1y94au02rvvxt0ajpqzpa4	cmo1y949r02rpvxt0tp90r46w	cmo1xc10u000hvxp0dapryn3r	160000	2026-04-16 20:46:24.775	2026-04-16 20:46:24.775
cmo1y94ba02rzvxt0ksctstrs	cmo1y94b402rxvxt0k8h74jyf	cmo1xsgrt0022vxv8sd7cckj7	50000	2026-04-16 20:46:24.791	2026-04-16 20:46:24.791
cmo1y94bi02s1vxt0q2c2jl10	cmo1y94b402rxvxt0k8h74jyf	cmo1xc11v000lvxp07r6uljko	50000	2026-04-16 20:46:24.798	2026-04-16 20:46:24.798
cmo1y94bq02s3vxt0xd1pakm0	cmo1y94b402rxvxt0k8h74jyf	cmo1xc12y000qvxp0uqc7d8d8	50000	2026-04-16 20:46:24.806	2026-04-16 20:46:24.806
cmo1y94bz02s5vxt0kt9tyfvy	cmo1y94b402rxvxt0k8h74jyf	cmo1xc13g000svxp0tbndc1wg	50000	2026-04-16 20:46:24.815	2026-04-16 20:46:24.815
cmo1y94c602s7vxt0rv78rsvv	cmo1y94b402rxvxt0k8h74jyf	cmo1xc12a000nvxp0f1zf3aqg	50000	2026-04-16 20:46:24.823	2026-04-16 20:46:24.823
cmo1y94cg02s9vxt0cuks2rp8	cmo1y94b402rxvxt0k8h74jyf	cmo1xc12q000pvxp0kun82k4l	50000	2026-04-16 20:46:24.832	2026-04-16 20:46:24.832
cmo1y94cn02sbvxt0okyhbaff	cmo1y94b402rxvxt0k8h74jyf	cmo1xc138000rvxp0r16wi1bz	50000	2026-04-16 20:46:24.839	2026-04-16 20:46:24.839
cmo1y94ct02sdvxt073ymdwm0	cmo1y94b402rxvxt0k8h74jyf	cmo1xc12i000ovxp01nisgvnu	50000	2026-04-16 20:46:24.845	2026-04-16 20:46:24.845
cmo1y94d002sfvxt0edbyws0v	cmo1y94b402rxvxt0k8h74jyf	cmo1xc13o000tvxp0alok8jeb	50000	2026-04-16 20:46:24.852	2026-04-16 20:46:24.852
cmo1y94d802shvxt07f0epgqf	cmo1y94b402rxvxt0k8h74jyf	cmo1xc123000mvxp0ul7pkio2	50000	2026-04-16 20:46:24.86	2026-04-16 20:46:24.86
cmo1y94dy02sjvxt0xyzuzmaf	cmo1y94b402rxvxt0k8h74jyf	cmo1xc11n000kvxp0g32oj3wx	50000	2026-04-16 20:46:24.887	2026-04-16 20:46:24.887
cmo1y94e602slvxt0onaoml0a	cmo1y94b402rxvxt0k8h74jyf	cmo1xc10u000hvxp0dapryn3r	50000	2026-04-16 20:46:24.895	2026-04-16 20:46:24.895
cmo1y94eg02snvxt0qf6f2gcf	cmo1y94b402rxvxt0k8h74jyf	cmo1xc119000jvxp01snwxzoa	50000	2026-04-16 20:46:24.904	2026-04-16 20:46:24.904
cmo1y94es02srvxt0jy7ajwxg	cmo1y94em02spvxt054kk2cpq	cmo1xsgrt0022vxv8sd7cckj7	45000	2026-04-16 20:46:24.917	2026-04-16 20:46:24.917
cmo1y94f002stvxt0vxykvmgk	cmo1y94em02spvxt054kk2cpq	cmo1xc11v000lvxp07r6uljko	45000	2026-04-16 20:46:24.924	2026-04-16 20:46:24.924
cmo1y94f802svvxt0kc1ocol4	cmo1y94em02spvxt054kk2cpq	cmo1xc12y000qvxp0uqc7d8d8	45000	2026-04-16 20:46:24.931	2026-04-16 20:46:24.931
cmo1y94ff02sxvxt07klngev4	cmo1y94em02spvxt054kk2cpq	cmo1xc13g000svxp0tbndc1wg	45000	2026-04-16 20:46:24.939	2026-04-16 20:46:24.939
cmo1y94fq02szvxt04ensjpfe	cmo1y94em02spvxt054kk2cpq	cmo1xc12q000pvxp0kun82k4l	37000	2026-04-16 20:46:24.951	2026-04-16 20:46:24.951
cmo1y94fz02t1vxt0w2td7wk7	cmo1y94em02spvxt054kk2cpq	cmo1xc12i000ovxp01nisgvnu	45000	2026-04-16 20:46:24.959	2026-04-16 20:46:24.959
cmo1y94g602t3vxt032ghy06l	cmo1y94em02spvxt054kk2cpq	cmo1xc13o000tvxp0alok8jeb	45000	2026-04-16 20:46:24.967	2026-04-16 20:46:24.967
cmo1y94ge02t5vxt0uktnii4h	cmo1y94em02spvxt054kk2cpq	cmo1xc11n000kvxp0g32oj3wx	48000	2026-04-16 20:46:24.974	2026-04-16 20:46:24.974
cmo1y94gl02t7vxt0gowa3cy9	cmo1y94em02spvxt054kk2cpq	cmo1xc10u000hvxp0dapryn3r	45000	2026-04-16 20:46:24.981	2026-04-16 20:46:24.981
cmo1y94gt02t9vxt0k0upmea5	cmo1y94em02spvxt054kk2cpq	cmo1xc119000jvxp01snwxzoa	45000	2026-04-16 20:46:24.989	2026-04-16 20:46:24.989
cmo1y94hd02tdvxt02r2i4ovl	cmo1y94h202tbvxt0i6zreh9g	cmo1xc11v000lvxp07r6uljko	40000	2026-04-16 20:46:25.009	2026-04-16 20:46:25.009
cmo1y94i002tfvxt009t298ye	cmo1y94h202tbvxt0i6zreh9g	cmo1xc10u000hvxp0dapryn3r	40000	2026-04-16 20:46:25.033	2026-04-16 20:46:25.033
cmo1y94ig02tjvxt0g42knj5c	cmo1y94i802thvxt0knwkmqgg	cmo1xsgrt0022vxv8sd7cckj7	29500	2026-04-16 20:46:25.048	2026-04-16 20:46:25.048
cmo1y94j702tlvxt00ranfn39	cmo1y94i802thvxt0knwkmqgg	cmo1xc10u000hvxp0dapryn3r	29500	2026-04-16 20:46:25.075	2026-04-16 20:46:25.075
cmo1y94jp02tpvxt0exmn31e2	cmo1y94jg02tnvxt03jxx2whb	cmo1xc11v000lvxp07r6uljko	40000	2026-04-16 20:46:25.093	2026-04-16 20:46:25.093
cmo1y94jv02trvxt0m37khe3q	cmo1y94jg02tnvxt03jxx2whb	cmo1xc12y000qvxp0uqc7d8d8	40000	2026-04-16 20:46:25.099	2026-04-16 20:46:25.099
cmo1y94k102ttvxt0zkue878t	cmo1y94jg02tnvxt03jxx2whb	cmo1xc13g000svxp0tbndc1wg	40000	2026-04-16 20:46:25.106	2026-04-16 20:46:25.106
cmo1y94ka02tvvxt0zicg0rpt	cmo1y94jg02tnvxt03jxx2whb	cmo1xc12q000pvxp0kun82k4l	40000	2026-04-16 20:46:25.114	2026-04-16 20:46:25.114
cmo1y94ki02txvxt0x5nui5rc	cmo1y94jg02tnvxt03jxx2whb	cmo1xc138000rvxp0r16wi1bz	40000	2026-04-16 20:46:25.122	2026-04-16 20:46:25.122
cmo1y94kr02tzvxt01sz4di0e	cmo1y94jg02tnvxt03jxx2whb	cmo1xc12i000ovxp01nisgvnu	40000	2026-04-16 20:46:25.131	2026-04-16 20:46:25.131
cmo1y94kz02u1vxt07k8jgllr	cmo1y94jg02tnvxt03jxx2whb	cmo1xc13o000tvxp0alok8jeb	40000	2026-04-16 20:46:25.139	2026-04-16 20:46:25.139
cmo1y94lb02u3vxt09ov66pmp	cmo1y94jg02tnvxt03jxx2whb	cmo1xc11n000kvxp0g32oj3wx	43000	2026-04-16 20:46:25.151	2026-04-16 20:46:25.151
cmo1y94lj02u5vxt08rvv3abs	cmo1y94jg02tnvxt03jxx2whb	cmo1xc10u000hvxp0dapryn3r	40000	2026-04-16 20:46:25.159	2026-04-16 20:46:25.159
cmo1y94lq02u7vxt0tc8eogul	cmo1y94jg02tnvxt03jxx2whb	cmo1xc119000jvxp01snwxzoa	40000	2026-04-16 20:46:25.166	2026-04-16 20:46:25.166
cmo1y94m302ubvxt0bg704npr	cmo1y94lw02u9vxt0ald4fm4q	cmo1xsgrt0022vxv8sd7cckj7	60000	2026-04-16 20:46:25.179	2026-04-16 20:46:25.179
cmo1y94mb02udvxt0gmnnkkzg	cmo1y94lw02u9vxt0ald4fm4q	cmo1xc11v000lvxp07r6uljko	60000	2026-04-16 20:46:25.187	2026-04-16 20:46:25.187
cmo1y94n002ufvxt0ufu9n7wo	cmo1y94lw02u9vxt0ald4fm4q	cmo1xc10u000hvxp0dapryn3r	60000	2026-04-16 20:46:25.212	2026-04-16 20:46:25.212
cmo1y94nk02ujvxt0wxgca6qo	cmo1y94nc02uhvxt05tww8631	cmo1xsgrt0022vxv8sd7cckj7	40000	2026-04-16 20:46:25.232	2026-04-16 20:46:25.232
cmo1y94o602ulvxt0179rziu1	cmo1y94nc02uhvxt05tww8631	cmo1xc10u000hvxp0dapryn3r	40000	2026-04-16 20:46:25.254	2026-04-16 20:46:25.254
cmo1y94oo02upvxt0mmuzc1fo	cmo1y94oh02unvxt0x9sxf6h0	cmo1xsgrt0022vxv8sd7cckj7	45500	2026-04-16 20:46:25.272	2026-04-16 20:46:25.272
cmo1y94pj02urvxt0l3emcs6j	cmo1y94oh02unvxt0x9sxf6h0	cmo1xc10u000hvxp0dapryn3r	45500	2026-04-16 20:46:25.303	2026-04-16 20:46:25.303
cmo1y94pw02uvvxt036zs29xz	cmo1y94pq02utvxt06g6axnmq	cmo1xsgrt0022vxv8sd7cckj7	29500	2026-04-16 20:46:25.317	2026-04-16 20:46:25.317
cmo1y94qi02uxvxt0ag30u7jg	cmo1y94pq02utvxt06g6axnmq	cmo1xc10u000hvxp0dapryn3r	29500	2026-04-16 20:46:25.338	2026-04-16 20:46:25.338
cmo1y94r202v1vxt0fvnnwwod	cmo1y94qs02uzvxt06qgm3y4g	cmo1xc11v000lvxp07r6uljko	390000	2026-04-16 20:46:25.359	2026-04-16 20:46:25.359
cmo1y94ro02v3vxt020ghi89w	cmo1y94qs02uzvxt06qgm3y4g	cmo1xc10u000hvxp0dapryn3r	390000	2026-04-16 20:46:25.379	2026-04-16 20:46:25.379
cmo1y94s702v7vxt0v9q6ofwh	cmo1y94ry02v5vxt0org2kq4m	cmo1xsgrt0022vxv8sd7cckj7	90000	2026-04-16 20:46:25.399	2026-04-16 20:46:25.399
cmo1y94sg02v9vxt0w7zl95f1	cmo1y94ry02v5vxt0org2kq4m	cmo1xc11v000lvxp07r6uljko	90000	2026-04-16 20:46:25.408	2026-04-16 20:46:25.408
cmo1y94t802vbvxt0t5t2s6pu	cmo1y94ry02v5vxt0org2kq4m	cmo1xc10u000hvxp0dapryn3r	90000	2026-04-16 20:46:25.437	2026-04-16 20:46:25.437
cmo1y94uj02vhvxt0y3uj9l83	cmo1y94ud02vfvxt0kw6mv5s8	cmo1xsgrt0022vxv8sd7cckj7	90000	2026-04-16 20:46:25.484	2026-04-16 20:46:25.484
cmo1y94vh02vlvxt0fuvlgjme	cmo1y94v902vjvxt0r7m7cqit	cmo1xc11v000lvxp07r6uljko	79000	2026-04-16 20:46:25.517	2026-04-16 20:46:25.517
cmo1y94w202vnvxt0gdjd2din	cmo1y94v902vjvxt0r7m7cqit	cmo1xc10u000hvxp0dapryn3r	79000	2026-04-16 20:46:25.538	2026-04-16 20:46:25.538
cmo1y94wk02vrvxt0vwpifrx7	cmo1y94wd02vpvxt0r0gsqb2t	cmo1xsgrt0022vxv8sd7cckj7	40000	2026-04-16 20:46:25.556	2026-04-16 20:46:25.556
cmo1y94x602vtvxt0xq36pbpk	cmo1y94wd02vpvxt0r0gsqb2t	cmo1xc10u000hvxp0dapryn3r	40000	2026-04-16 20:46:25.578	2026-04-16 20:46:25.578
cmo1y94z502w5vxt0u95h9ns5	cmo1y94yz02w3vxt05z8j13f9	cmo1xsgrt0022vxv8sd7cckj7	41000	2026-04-16 20:46:25.65	2026-04-16 20:46:25.65
cmo1y950602w9vxt0w6bfsjmo	cmo1y94zx02w7vxt0u1j63amt	cmo1xsgrt0022vxv8sd7cckj7	33600	2026-04-16 20:46:25.686	2026-04-16 20:46:25.686
cmo1y950c02wbvxt0vj03qvu3	cmo1y94zx02w7vxt0u1j63amt	cmo1xc11v000lvxp07r6uljko	33600	2026-04-16 20:46:25.693	2026-04-16 20:46:25.693
cmo1y950s02wdvxt04lk6i7sn	cmo1y94zx02w7vxt0u1j63amt	cmo1xc13o000tvxp0alok8jeb	33600	2026-04-16 20:46:25.708	2026-04-16 20:46:25.708
cmo1y951102wfvxt0qfztulwl	cmo1y94zx02w7vxt0u1j63amt	cmo1xc10u000hvxp0dapryn3r	33600	2026-04-16 20:46:25.718	2026-04-16 20:46:25.718
cmo1y951h02wjvxt0ey1t5mc5	cmo1y951a02whvxt0rzalumvr	cmo1xsgrt0022vxv8sd7cckj7	45000	2026-04-16 20:46:25.733	2026-04-16 20:46:25.733
cmo1y951o02wlvxt0isf7lcqi	cmo1y951a02whvxt0rzalumvr	cmo1xc11v000lvxp07r6uljko	45000	2026-04-16 20:46:25.74	2026-04-16 20:46:25.74
cmo1y951w02wnvxt0d261v2kq	cmo1y951a02whvxt0rzalumvr	cmo1xc12y000qvxp0uqc7d8d8	48000	2026-04-16 20:46:25.748	2026-04-16 20:46:25.748
cmo1y952302wpvxt0l8gpg7cb	cmo1y951a02whvxt0rzalumvr	cmo1xc13g000svxp0tbndc1wg	45000	2026-04-16 20:46:25.755	2026-04-16 20:46:25.755
cmo1y952d02wrvxt01tgr2pox	cmo1y951a02whvxt0rzalumvr	cmo1xc12q000pvxp0kun82k4l	37000	2026-04-16 20:46:25.765	2026-04-16 20:46:25.765
cmo1y952n02wtvxt0lbfij9hd	cmo1y951a02whvxt0rzalumvr	cmo1xc12i000ovxp01nisgvnu	45000	2026-04-16 20:46:25.776	2026-04-16 20:46:25.776
cmo1y952w02wvvxt0ziftblly	cmo1y951a02whvxt0rzalumvr	cmo1xc13o000tvxp0alok8jeb	45000	2026-04-16 20:46:25.785	2026-04-16 20:46:25.785
cmo1y953402wxvxt0ix91hgv0	cmo1y951a02whvxt0rzalumvr	cmo1xc11n000kvxp0g32oj3wx	48000	2026-04-16 20:46:25.792	2026-04-16 20:46:25.792
cmo1y953b02wzvxt0cogsl405	cmo1y951a02whvxt0rzalumvr	cmo1xc10u000hvxp0dapryn3r	45000	2026-04-16 20:46:25.799	2026-04-16 20:46:25.799
cmo1y953h02x1vxt0fy0xv0fq	cmo1y951a02whvxt0rzalumvr	cmo1xc119000jvxp01snwxzoa	45000	2026-04-16 20:46:25.806	2026-04-16 20:46:25.806
cmo1y953x02x5vxt0hhzondiv	cmo1y953o02x3vxt00tsq763m	cmo1xsgrt0022vxv8sd7cckj7	32000	2026-04-16 20:46:25.821	2026-04-16 20:46:25.821
cmo1y954402x7vxt0o8sxjkp9	cmo1y953o02x3vxt00tsq763m	cmo1xc11v000lvxp07r6uljko	32000	2026-04-16 20:46:25.828	2026-04-16 20:46:25.828
cmo1y954q02x9vxt0jqt32f25	cmo1y953o02x3vxt00tsq763m	cmo1xc10u000hvxp0dapryn3r	32000	2026-04-16 20:46:25.85	2026-04-16 20:46:25.85
cmo1y956102xfvxt0iiupb8lv	cmo1y955s02xdvxt0ehj6imm3	cmo1xsgrt0022vxv8sd7cckj7	40000	2026-04-16 20:46:25.897	2026-04-16 20:46:25.897
cmo1y956802xhvxt0470fnmwv	cmo1y955s02xdvxt0ehj6imm3	cmo1xc11v000lvxp07r6uljko	40000	2026-04-16 20:46:25.904	2026-04-16 20:46:25.904
cmo1y956e02xjvxt00652tbp4	cmo1y955s02xdvxt0ehj6imm3	cmo1xc12y000qvxp0uqc7d8d8	40000	2026-04-16 20:46:25.91	2026-04-16 20:46:25.91
cmo1y956k02xlvxt0jwybwj99	cmo1y955s02xdvxt0ehj6imm3	cmo1xc13g000svxp0tbndc1wg	40000	2026-04-16 20:46:25.916	2026-04-16 20:46:25.916
cmo1y956q02xnvxt002xjxzjs	cmo1y955s02xdvxt0ehj6imm3	cmo1xc12a000nvxp0f1zf3aqg	40000	2026-04-16 20:46:25.923	2026-04-16 20:46:25.923
cmo1y956y02xpvxt0jjde6amm	cmo1y955s02xdvxt0ehj6imm3	cmo1xc12q000pvxp0kun82k4l	40000	2026-04-16 20:46:25.93	2026-04-16 20:46:25.93
cmo1y957602xrvxt0w1we91bi	cmo1y955s02xdvxt0ehj6imm3	cmo1xc138000rvxp0r16wi1bz	40000	2026-04-16 20:46:25.938	2026-04-16 20:46:25.938
cmo1y957d02xtvxt0y6717xz0	cmo1y955s02xdvxt0ehj6imm3	cmo1xc12i000ovxp01nisgvnu	40000	2026-04-16 20:46:25.945	2026-04-16 20:46:25.945
cmo1y957l02xvvxt0qrmp0cfs	cmo1y955s02xdvxt0ehj6imm3	cmo1xc13o000tvxp0alok8jeb	40000	2026-04-16 20:46:25.953	2026-04-16 20:46:25.953
cmo1y957s02xxvxt0s4lv1mhy	cmo1y955s02xdvxt0ehj6imm3	cmo1xc123000mvxp0ul7pkio2	40000	2026-04-16 20:46:25.961	2026-04-16 20:46:25.961
cmo1y958402xzvxt0fuis8uui	cmo1y955s02xdvxt0ehj6imm3	cmo1xc11n000kvxp0g32oj3wx	43000	2026-04-16 20:46:25.972	2026-04-16 20:46:25.972
cmo1y958902y1vxt0wq3xazw1	cmo1y955s02xdvxt0ehj6imm3	cmo1xc10u000hvxp0dapryn3r	40000	2026-04-16 20:46:25.978	2026-04-16 20:46:25.978
cmo1y958h02y3vxt0c3e7prg1	cmo1y955s02xdvxt0ehj6imm3	cmo1xc119000jvxp01snwxzoa	40000	2026-04-16 20:46:25.986	2026-04-16 20:46:25.986
cmo1y958v02y7vxt08pjc10pf	cmo1y958o02y5vxt0mflr37n0	cmo1xsgrt0022vxv8sd7cckj7	43000	2026-04-16 20:46:25.999	2026-04-16 20:46:25.999
cmo1y959202y9vxt05fcwj7l1	cmo1y958o02y5vxt0mflr37n0	cmo1xc11v000lvxp07r6uljko	43000	2026-04-16 20:46:26.006	2026-04-16 20:46:26.006
cmo1y959b02ybvxt0b8e4hb53	cmo1y958o02y5vxt0mflr37n0	cmo1xc12y000qvxp0uqc7d8d8	43000	2026-04-16 20:46:26.014	2026-04-16 20:46:26.014
cmo1y959k02ydvxt0evdr8w4g	cmo1y958o02y5vxt0mflr37n0	cmo1xc13g000svxp0tbndc1wg	43000	2026-04-16 20:46:26.024	2026-04-16 20:46:26.024
cmo1y959v02yfvxt0qhk7tlwq	cmo1y958o02y5vxt0mflr37n0	cmo1xc12q000pvxp0kun82k4l	43000	2026-04-16 20:46:26.035	2026-04-16 20:46:26.035
cmo1y95a302yhvxt0cwznrpj4	cmo1y958o02y5vxt0mflr37n0	cmo1xc12i000ovxp01nisgvnu	43000	2026-04-16 20:46:26.043	2026-04-16 20:46:26.043
cmo1y95aa02yjvxt00uyftqv8	cmo1y958o02y5vxt0mflr37n0	cmo1xc13o000tvxp0alok8jeb	43000	2026-04-16 20:46:26.05	2026-04-16 20:46:26.05
cmo1y95al02ylvxt0td5s4pkw	cmo1y958o02y5vxt0mflr37n0	cmo1xc10u000hvxp0dapryn3r	43000	2026-04-16 20:46:26.062	2026-04-16 20:46:26.062
cmo1y95b602ynvxt051ewy74n	cmo1y958o02y5vxt0mflr37n0	cmo1xc119000jvxp01snwxzoa	43000	2026-04-16 20:46:26.082	2026-04-16 20:46:26.082
cmo1y95bn02yrvxt09gmj7adi	cmo1y95be02ypvxt04po42uwv	cmo1xsgrt0022vxv8sd7cckj7	32000	2026-04-16 20:46:26.099	2026-04-16 20:46:26.099
cmo1y95bu02ytvxt0nbxggs8p	cmo1y95be02ypvxt04po42uwv	cmo1xc11v000lvxp07r6uljko	32000	2026-04-16 20:46:26.106	2026-04-16 20:46:26.106
cmo1y95c302yvvxt0aszkidhb	cmo1y95be02ypvxt04po42uwv	cmo1xc12y000qvxp0uqc7d8d8	32000	2026-04-16 20:46:26.115	2026-04-16 20:46:26.115
cmo1y95ca02yxvxt07x8yj5jj	cmo1y95be02ypvxt04po42uwv	cmo1xc13g000svxp0tbndc1wg	32000	2026-04-16 20:46:26.122	2026-04-16 20:46:26.122
cmo1y95cm02yzvxt0lp4hs8jd	cmo1y95be02ypvxt04po42uwv	cmo1xc12q000pvxp0kun82k4l	32000	2026-04-16 20:46:26.134	2026-04-16 20:46:26.134
cmo1y95cx02z1vxt0voffayvq	cmo1y95be02ypvxt04po42uwv	cmo1xc12i000ovxp01nisgvnu	32000	2026-04-16 20:46:26.145	2026-04-16 20:46:26.145
cmo1y95d802z3vxt0ye8oc3o0	cmo1y95be02ypvxt04po42uwv	cmo1xc13o000tvxp0alok8jeb	32000	2026-04-16 20:46:26.156	2026-04-16 20:46:26.156
cmo1y95dk02z5vxt0zl8heu1a	cmo1y95be02ypvxt04po42uwv	cmo1xc10u000hvxp0dapryn3r	32000	2026-04-16 20:46:26.168	2026-04-16 20:46:26.168
cmo1y95dr02z7vxt0emdrde2b	cmo1y95be02ypvxt04po42uwv	cmo1xc119000jvxp01snwxzoa	32000	2026-04-16 20:46:26.176	2026-04-16 20:46:26.176
cmo1y95e502zbvxt0ogagjaoy	cmo1y95dy02z9vxt0e94984pc	cmo1xsgrt0022vxv8sd7cckj7	40000	2026-04-16 20:46:26.189	2026-04-16 20:46:26.189
cmo1y95ea02zdvxt0x65q77rk	cmo1y95dy02z9vxt0e94984pc	cmo1xc11v000lvxp07r6uljko	40000	2026-04-16 20:46:26.195	2026-04-16 20:46:26.195
cmo1y95ei02zfvxt0zb09tr04	cmo1y95dy02z9vxt0e94984pc	cmo1xc12y000qvxp0uqc7d8d8	40000	2026-04-16 20:46:26.202	2026-04-16 20:46:26.202
cmo1y95ep02zhvxt0b6wki294	cmo1y95dy02z9vxt0e94984pc	cmo1xc13g000svxp0tbndc1wg	40000	2026-04-16 20:46:26.209	2026-04-16 20:46:26.209
cmo1y95ew02zjvxt05if3ho30	cmo1y95dy02z9vxt0e94984pc	cmo1xc12a000nvxp0f1zf3aqg	40000	2026-04-16 20:46:26.216	2026-04-16 20:46:26.216
cmo1y95f302zlvxt0ery3ckhx	cmo1y95dy02z9vxt0e94984pc	cmo1xc12q000pvxp0kun82k4l	40000	2026-04-16 20:46:26.223	2026-04-16 20:46:26.223
cmo1y95fc02znvxt02yzrzhzj	cmo1y95dy02z9vxt0e94984pc	cmo1xc138000rvxp0r16wi1bz	40000	2026-04-16 20:46:26.231	2026-04-16 20:46:26.231
cmo1y95fj02zpvxt0nfvwccvl	cmo1y95dy02z9vxt0e94984pc	cmo1xc12i000ovxp01nisgvnu	40000	2026-04-16 20:46:26.239	2026-04-16 20:46:26.239
cmo1y95fp02zrvxt0b1rnxw2c	cmo1y95dy02z9vxt0e94984pc	cmo1xc13o000tvxp0alok8jeb	40000	2026-04-16 20:46:26.245	2026-04-16 20:46:26.245
cmo1y95fx02ztvxt0yl5vvh6l	cmo1y95dy02z9vxt0e94984pc	cmo1xc123000mvxp0ul7pkio2	40000	2026-04-16 20:46:26.254	2026-04-16 20:46:26.254
cmo1y95g502zvvxt0w9cisyvk	cmo1y95dy02z9vxt0e94984pc	cmo1xc11n000kvxp0g32oj3wx	43000	2026-04-16 20:46:26.261	2026-04-16 20:46:26.261
cmo1y95gc02zxvxt0angdwzxb	cmo1y95dy02z9vxt0e94984pc	cmo1xc10u000hvxp0dapryn3r	40000	2026-04-16 20:46:26.268	2026-04-16 20:46:26.268
cmo1y95gj02zzvxt0b13undd6	cmo1y95dy02z9vxt0e94984pc	cmo1xc119000jvxp01snwxzoa	40000	2026-04-16 20:46:26.275	2026-04-16 20:46:26.275
cmo1y95hv0305vxt0plpejlcl	cmo1y95ho0303vxt0hudbv4lc	cmo1xsgrt0022vxv8sd7cckj7	45000	2026-04-16 20:46:26.323	2026-04-16 20:46:26.323
cmo1y95i30307vxt0yrlbai7j	cmo1y95ho0303vxt0hudbv4lc	cmo1xc11v000lvxp07r6uljko	45000	2026-04-16 20:46:26.332	2026-04-16 20:46:26.332
cmo1y95ib0309vxt0g78rwljr	cmo1y95ho0303vxt0hudbv4lc	cmo1xc12y000qvxp0uqc7d8d8	48000	2026-04-16 20:46:26.339	2026-04-16 20:46:26.339
cmo1y95ik030bvxt0m2k66mm4	cmo1y95ho0303vxt0hudbv4lc	cmo1xc13g000svxp0tbndc1wg	45000	2026-04-16 20:46:26.348	2026-04-16 20:46:26.348
cmo1y95iu030dvxt05mu1abne	cmo1y95ho0303vxt0hudbv4lc	cmo1xc12q000pvxp0kun82k4l	37000	2026-04-16 20:46:26.358	2026-04-16 20:46:26.358
cmo1y95j2030fvxt0ruxtvgex	cmo1y95ho0303vxt0hudbv4lc	cmo1xc12i000ovxp01nisgvnu	45000	2026-04-16 20:46:26.366	2026-04-16 20:46:26.366
cmo1y95j9030hvxt00a4mrk6d	cmo1y95ho0303vxt0hudbv4lc	cmo1xc13o000tvxp0alok8jeb	45000	2026-04-16 20:46:26.373	2026-04-16 20:46:26.373
cmo1y95ji030jvxt09vkbp96f	cmo1y95ho0303vxt0hudbv4lc	cmo1xc11n000kvxp0g32oj3wx	48000	2026-04-16 20:46:26.383	2026-04-16 20:46:26.383
cmo1y95jp030lvxt0p28sr7aj	cmo1y95ho0303vxt0hudbv4lc	cmo1xc10u000hvxp0dapryn3r	45000	2026-04-16 20:46:26.389	2026-04-16 20:46:26.389
cmo1y95jw030nvxt0xpqt1kkf	cmo1y95ho0303vxt0hudbv4lc	cmo1xc119000jvxp01snwxzoa	45000	2026-04-16 20:46:26.396	2026-04-16 20:46:26.396
cmo1y95ka030rvxt0uzqsjdz3	cmo1y95k3030pvxt0xbdxqk2m	cmo1xsgrt0022vxv8sd7cckj7	59000	2026-04-16 20:46:26.411	2026-04-16 20:46:26.411
cmo1y95kg030tvxt0sjugzce7	cmo1y95k3030pvxt0xbdxqk2m	cmo1xc11v000lvxp07r6uljko	59000	2026-04-16 20:46:26.416	2026-04-16 20:46:26.416
cmo1y95kn030vvxt0vfm2n8aq	cmo1y95k3030pvxt0xbdxqk2m	cmo1xc12y000qvxp0uqc7d8d8	59000	2026-04-16 20:46:26.423	2026-04-16 20:46:26.423
cmo1y95kv030xvxt0n843fiu3	cmo1y95k3030pvxt0xbdxqk2m	cmo1xc13g000svxp0tbndc1wg	59000	2026-04-16 20:46:26.431	2026-04-16 20:46:26.431
cmo1y95l2030zvxt0xkdwok07	cmo1y95k3030pvxt0xbdxqk2m	cmo1xc12a000nvxp0f1zf3aqg	59000	2026-04-16 20:46:26.438	2026-04-16 20:46:26.438
cmo1y95l90311vxt0l5193bgf	cmo1y95k3030pvxt0xbdxqk2m	cmo1xc12q000pvxp0kun82k4l	59000	2026-04-16 20:46:26.445	2026-04-16 20:46:26.445
cmo1y95lh0313vxt039q7tood	cmo1y95k3030pvxt0xbdxqk2m	cmo1xc138000rvxp0r16wi1bz	59000	2026-04-16 20:46:26.453	2026-04-16 20:46:26.453
cmo1y95lp0315vxt0vzxzwu2k	cmo1y95k3030pvxt0xbdxqk2m	cmo1xc12i000ovxp01nisgvnu	59000	2026-04-16 20:46:26.461	2026-04-16 20:46:26.461
cmo1y95lv0317vxt09lqy0pf6	cmo1y95k3030pvxt0xbdxqk2m	cmo1xc13o000tvxp0alok8jeb	59000	2026-04-16 20:46:26.467	2026-04-16 20:46:26.467
cmo1y95m20319vxt0woigri55	cmo1y95k3030pvxt0xbdxqk2m	cmo1xc123000mvxp0ul7pkio2	59000	2026-04-16 20:46:26.474	2026-04-16 20:46:26.474
cmo1y95ma031bvxt0d325smqt	cmo1y95k3030pvxt0xbdxqk2m	cmo1xc11n000kvxp0g32oj3wx	59000	2026-04-16 20:46:26.482	2026-04-16 20:46:26.482
cmo1y95mg031dvxt0o7rdnmqa	cmo1y95k3030pvxt0xbdxqk2m	cmo1xc10u000hvxp0dapryn3r	59000	2026-04-16 20:46:26.488	2026-04-16 20:46:26.488
cmo1y95mn031fvxt07m8zq81o	cmo1y95k3030pvxt0xbdxqk2m	cmo1xc119000jvxp01snwxzoa	59000	2026-04-16 20:46:26.495	2026-04-16 20:46:26.495
cmo1y95n3031jvxt0qms5o2tl	cmo1y95mw031hvxt0y6i7hf91	cmo1xsgrt0022vxv8sd7cckj7	70000	2026-04-16 20:46:26.511	2026-04-16 20:46:26.511
cmo1y95na031lvxt0gp9tpude	cmo1y95mw031hvxt0y6i7hf91	cmo1xc11v000lvxp07r6uljko	70000	2026-04-16 20:46:26.518	2026-04-16 20:46:26.518
cmo1y95nh031nvxt0suzznvfo	cmo1y95mw031hvxt0y6i7hf91	cmo1xc12y000qvxp0uqc7d8d8	70000	2026-04-16 20:46:26.525	2026-04-16 20:46:26.525
cmo1y95no031pvxt07kcnwdoe	cmo1y95mw031hvxt0y6i7hf91	cmo1xc13g000svxp0tbndc1wg	70000	2026-04-16 20:46:26.532	2026-04-16 20:46:26.532
cmo1y95nx031rvxt0o2ziy00v	cmo1y95mw031hvxt0y6i7hf91	cmo1xc12q000pvxp0kun82k4l	70000	2026-04-16 20:46:26.542	2026-04-16 20:46:26.542
cmo1y95o4031tvxt0rdr452rd	cmo1y95mw031hvxt0y6i7hf91	cmo1xc138000rvxp0r16wi1bz	70000	2026-04-16 20:46:26.549	2026-04-16 20:46:26.549
cmo1y95oc031vvxt0qt9fi1jd	cmo1y95mw031hvxt0y6i7hf91	cmo1xc12i000ovxp01nisgvnu	70000	2026-04-16 20:46:26.556	2026-04-16 20:46:26.556
cmo1y95ol031xvxt0nna8wzcu	cmo1y95mw031hvxt0y6i7hf91	cmo1xc13o000tvxp0alok8jeb	70000	2026-04-16 20:46:26.565	2026-04-16 20:46:26.565
cmo1y95ou031zvxt0nynu8t66	cmo1y95mw031hvxt0y6i7hf91	cmo1xc11n000kvxp0g32oj3wx	70000	2026-04-16 20:46:26.574	2026-04-16 20:46:26.574
cmo1y95p20321vxt01xwre0ld	cmo1y95mw031hvxt0y6i7hf91	cmo1xc10u000hvxp0dapryn3r	70000	2026-04-16 20:46:26.582	2026-04-16 20:46:26.582
cmo1y95p80323vxt01c96jzee	cmo1y95mw031hvxt0y6i7hf91	cmo1xc119000jvxp01snwxzoa	70000	2026-04-16 20:46:26.589	2026-04-16 20:46:26.589
cmo1y95pp0327vxt07e3xq5n1	cmo1y95pi0325vxt0i4iwd0k7	cmo1xsgrt0022vxv8sd7cckj7	120000	2026-04-16 20:46:26.605	2026-04-16 20:46:26.605
cmo1y95py0329vxt0bvlsgzhd	cmo1y95pi0325vxt0i4iwd0k7	cmo1xc11v000lvxp07r6uljko	120000	2026-04-16 20:46:26.615	2026-04-16 20:46:26.615
cmo1y95q6032bvxt0riaxcra3	cmo1y95pi0325vxt0i4iwd0k7	cmo1xc12y000qvxp0uqc7d8d8	120000	2026-04-16 20:46:26.622	2026-04-16 20:46:26.622
cmo1y95qf032dvxt02at0wbn8	cmo1y95pi0325vxt0i4iwd0k7	cmo1xc13g000svxp0tbndc1wg	120000	2026-04-16 20:46:26.632	2026-04-16 20:46:26.632
cmo1y95qp032fvxt0vy9gktvz	cmo1y95pi0325vxt0i4iwd0k7	cmo1xc12q000pvxp0kun82k4l	120000	2026-04-16 20:46:26.642	2026-04-16 20:46:26.642
cmo1y95qx032hvxt0vtd60o5c	cmo1y95pi0325vxt0i4iwd0k7	cmo1xc138000rvxp0r16wi1bz	120000	2026-04-16 20:46:26.65	2026-04-16 20:46:26.65
cmo1y95r5032jvxt03h3yk183	cmo1y95pi0325vxt0i4iwd0k7	cmo1xc12i000ovxp01nisgvnu	120000	2026-04-16 20:46:26.657	2026-04-16 20:46:26.657
cmo1y95rd032lvxt0vkz5yk7l	cmo1y95pi0325vxt0i4iwd0k7	cmo1xc13o000tvxp0alok8jeb	120000	2026-04-16 20:46:26.665	2026-04-16 20:46:26.665
cmo1y95rn032nvxt0xqc5kxyn	cmo1y95pi0325vxt0i4iwd0k7	cmo1xc11n000kvxp0g32oj3wx	120000	2026-04-16 20:46:26.675	2026-04-16 20:46:26.675
cmo1y95ru032pvxt0sd6omyom	cmo1y95pi0325vxt0i4iwd0k7	cmo1xc10u000hvxp0dapryn3r	120000	2026-04-16 20:46:26.682	2026-04-16 20:46:26.682
cmo1y95s4032rvxt0t2ruc2z8	cmo1y95pi0325vxt0i4iwd0k7	cmo1xc119000jvxp01snwxzoa	120000	2026-04-16 20:46:26.692	2026-04-16 20:46:26.692
cmo1y95si032vvxt0k54nunin	cmo1y95sa032tvxt0241c2wp2	cmo1xsgrt0022vxv8sd7cckj7	16000	2026-04-16 20:46:26.706	2026-04-16 20:46:26.706
cmo1y95sr032xvxt0xdwl5xzj	cmo1y95sa032tvxt0241c2wp2	cmo1xc11v000lvxp07r6uljko	16000	2026-04-16 20:46:26.715	2026-04-16 20:46:26.715
cmo1y95sy032zvxt00jl51ri0	cmo1y95sa032tvxt0241c2wp2	cmo1xc12y000qvxp0uqc7d8d8	16000	2026-04-16 20:46:26.722	2026-04-16 20:46:26.722
cmo1y95t50331vxt0wp1zmck1	cmo1y95sa032tvxt0241c2wp2	cmo1xc13g000svxp0tbndc1wg	16000	2026-04-16 20:46:26.729	2026-04-16 20:46:26.729
cmo1y95tf0333vxt065uvyocj	cmo1y95sa032tvxt0241c2wp2	cmo1xc12q000pvxp0kun82k4l	16000	2026-04-16 20:46:26.74	2026-04-16 20:46:26.74
cmo1y95tp0335vxt0645twaiw	cmo1y95sa032tvxt0241c2wp2	cmo1xc138000rvxp0r16wi1bz	16000	2026-04-16 20:46:26.749	2026-04-16 20:46:26.749
cmo1y95tw0337vxt0sz4ccmi4	cmo1y95sa032tvxt0241c2wp2	cmo1xc12i000ovxp01nisgvnu	16000	2026-04-16 20:46:26.756	2026-04-16 20:46:26.756
cmo1y95u50339vxt0lxjc6gkk	cmo1y95sa032tvxt0241c2wp2	cmo1xc13o000tvxp0alok8jeb	16000	2026-04-16 20:46:26.765	2026-04-16 20:46:26.765
cmo1y95uf033bvxt0wide1ebe	cmo1y95sa032tvxt0241c2wp2	cmo1xc11n000kvxp0g32oj3wx	16000	2026-04-16 20:46:26.775	2026-04-16 20:46:26.775
cmo1y95um033dvxt05krvp5dq	cmo1y95sa032tvxt0241c2wp2	cmo1xc10u000hvxp0dapryn3r	16000	2026-04-16 20:46:26.782	2026-04-16 20:46:26.782
cmo1y95ut033fvxt0vdosqew8	cmo1y95sa032tvxt0241c2wp2	cmo1xc119000jvxp01snwxzoa	16000	2026-04-16 20:46:26.789	2026-04-16 20:46:26.789
cmo1y95v9033jvxt0xp66yfzy	cmo1y95v2033hvxt00lpruj1d	cmo1xsgrt0022vxv8sd7cckj7	25000	2026-04-16 20:46:26.805	2026-04-16 20:46:26.805
cmo1y95vg033lvxt0v2xmsa61	cmo1y95v2033hvxt00lpruj1d	cmo1xc11v000lvxp07r6uljko	25000	2026-04-16 20:46:26.812	2026-04-16 20:46:26.812
cmo1y95vo033nvxt0n73fwi6e	cmo1y95v2033hvxt00lpruj1d	cmo1xc12y000qvxp0uqc7d8d8	25000	2026-04-16 20:46:26.82	2026-04-16 20:46:26.82
cmo1y95vv033pvxt0ecvhtf34	cmo1y95v2033hvxt00lpruj1d	cmo1xc13g000svxp0tbndc1wg	25000	2026-04-16 20:46:26.827	2026-04-16 20:46:26.827
cmo1y95w2033rvxt0kbr1ho73	cmo1y95v2033hvxt00lpruj1d	cmo1xc12q000pvxp0kun82k4l	25000	2026-04-16 20:46:26.834	2026-04-16 20:46:26.834
cmo1y95w9033tvxt0r3hbdaso	cmo1y95v2033hvxt00lpruj1d	cmo1xc138000rvxp0r16wi1bz	25000	2026-04-16 20:46:26.841	2026-04-16 20:46:26.841
cmo1y95wg033vvxt06qidkp4a	cmo1y95v2033hvxt00lpruj1d	cmo1xc12i000ovxp01nisgvnu	25000	2026-04-16 20:46:26.849	2026-04-16 20:46:26.849
cmo1y95wn033xvxt01w9dyseb	cmo1y95v2033hvxt00lpruj1d	cmo1xc13o000tvxp0alok8jeb	25000	2026-04-16 20:46:26.855	2026-04-16 20:46:26.855
cmo1y95wx033zvxt0372svuvw	cmo1y95v2033hvxt00lpruj1d	cmo1xc11n000kvxp0g32oj3wx	25000	2026-04-16 20:46:26.865	2026-04-16 20:46:26.865
cmo1y95x40341vxt0krax27td	cmo1y95v2033hvxt00lpruj1d	cmo1xc10u000hvxp0dapryn3r	25000	2026-04-16 20:46:26.872	2026-04-16 20:46:26.872
cmo1y95xd0343vxt0alck5a0m	cmo1y95v2033hvxt00lpruj1d	cmo1xc119000jvxp01snwxzoa	25000	2026-04-16 20:46:26.881	2026-04-16 20:46:26.881
cmo1y95xr0347vxt0r07ogl7u	cmo1y95xk0345vxt0to38h552	cmo1xsgrt0022vxv8sd7cckj7	19000	2026-04-16 20:46:26.895	2026-04-16 20:46:26.895
cmo1y95xy0349vxt0qet3yh6n	cmo1y95xk0345vxt0to38h552	cmo1xc11v000lvxp07r6uljko	19000	2026-04-16 20:46:26.902	2026-04-16 20:46:26.902
cmo1y95y5034bvxt04jhmyb4x	cmo1y95xk0345vxt0to38h552	cmo1xc12y000qvxp0uqc7d8d8	19000	2026-04-16 20:46:26.909	2026-04-16 20:46:26.909
cmo1y95yb034dvxt0jeku3v4o	cmo1y95xk0345vxt0to38h552	cmo1xc13g000svxp0tbndc1wg	19000	2026-04-16 20:46:26.916	2026-04-16 20:46:26.916
cmo1y95yl034fvxt01862hwir	cmo1y95xk0345vxt0to38h552	cmo1xc12q000pvxp0kun82k4l	19000	2026-04-16 20:46:26.925	2026-04-16 20:46:26.925
cmo1y95ys034hvxt02i4x6bvi	cmo1y95xk0345vxt0to38h552	cmo1xc138000rvxp0r16wi1bz	19000	2026-04-16 20:46:26.932	2026-04-16 20:46:26.932
cmo1y95yz034jvxt0nyvmwok0	cmo1y95xk0345vxt0to38h552	cmo1xc12i000ovxp01nisgvnu	19000	2026-04-16 20:46:26.939	2026-04-16 20:46:26.939
cmo1y95z8034lvxt0q5601blm	cmo1y95xk0345vxt0to38h552	cmo1xc13o000tvxp0alok8jeb	19000	2026-04-16 20:46:26.949	2026-04-16 20:46:26.949
cmo1y95zh034nvxt0vsro151i	cmo1y95xk0345vxt0to38h552	cmo1xc11n000kvxp0g32oj3wx	19000	2026-04-16 20:46:26.958	2026-04-16 20:46:26.958
cmo1y95zp034pvxt0i00w0fy8	cmo1y95xk0345vxt0to38h552	cmo1xc10u000hvxp0dapryn3r	19000	2026-04-16 20:46:26.965	2026-04-16 20:46:26.965
cmo1y95zv034rvxt0vyfaafh6	cmo1y95xk0345vxt0to38h552	cmo1xc119000jvxp01snwxzoa	19000	2026-04-16 20:46:26.971	2026-04-16 20:46:26.971
cmo1y960a034vvxt0o6npvpgq	cmo1y9602034tvxt08duqwml2	cmo1xsgrt0022vxv8sd7cckj7	77000	2026-04-16 20:46:26.986	2026-04-16 20:46:26.986
cmo1y960h034xvxt0bk958uej	cmo1y9602034tvxt08duqwml2	cmo1xc11v000lvxp07r6uljko	77000	2026-04-16 20:46:26.994	2026-04-16 20:46:26.994
cmo1y960n034zvxt0oys7qwc1	cmo1y9602034tvxt08duqwml2	cmo1xc12y000qvxp0uqc7d8d8	77000	2026-04-16 20:46:27	2026-04-16 20:46:27
cmo1y960u0351vxt0j5q07375	cmo1y9602034tvxt08duqwml2	cmo1xc13g000svxp0tbndc1wg	77000	2026-04-16 20:46:27.006	2026-04-16 20:46:27.006
cmo1y96140353vxt0495jo1z3	cmo1y9602034tvxt08duqwml2	cmo1xc12q000pvxp0kun82k4l	77000	2026-04-16 20:46:27.016	2026-04-16 20:46:27.016
cmo1y961b0355vxt0a0ce56d4	cmo1y9602034tvxt08duqwml2	cmo1xc138000rvxp0r16wi1bz	77000	2026-04-16 20:46:27.023	2026-04-16 20:46:27.023
cmo1y961j0357vxt01svuoqfx	cmo1y9602034tvxt08duqwml2	cmo1xc12i000ovxp01nisgvnu	77000	2026-04-16 20:46:27.032	2026-04-16 20:46:27.032
cmo1y961q0359vxt09oa2lyf5	cmo1y9602034tvxt08duqwml2	cmo1xc13o000tvxp0alok8jeb	77000	2026-04-16 20:46:27.038	2026-04-16 20:46:27.038
cmo1y9621035bvxt0zi70ay9p	cmo1y9602034tvxt08duqwml2	cmo1xc11n000kvxp0g32oj3wx	77000	2026-04-16 20:46:27.049	2026-04-16 20:46:27.049
cmo1y9627035dvxt0chlhfhxr	cmo1y9602034tvxt08duqwml2	cmo1xc10u000hvxp0dapryn3r	77000	2026-04-16 20:46:27.055	2026-04-16 20:46:27.055
cmo1y962h035fvxt0jf5godx0	cmo1y9602034tvxt08duqwml2	cmo1xc119000jvxp01snwxzoa	77000	2026-04-16 20:46:27.065	2026-04-16 20:46:27.065
cmo1y962w035jvxt0ppnwsjlh	cmo1y962o035hvxt0djed7qgg	cmo1xsgrt0022vxv8sd7cckj7	140000	2026-04-16 20:46:27.08	2026-04-16 20:46:27.08
cmo1y9633035lvxt05y8yntu9	cmo1y962o035hvxt0djed7qgg	cmo1xc11v000lvxp07r6uljko	140000	2026-04-16 20:46:27.088	2026-04-16 20:46:27.088
cmo1y963b035nvxt0d3guraio	cmo1y962o035hvxt0djed7qgg	cmo1xc12y000qvxp0uqc7d8d8	140000	2026-04-16 20:46:27.095	2026-04-16 20:46:27.095
cmo1y963j035pvxt0lrm5hffx	cmo1y962o035hvxt0djed7qgg	cmo1xc13g000svxp0tbndc1wg	140000	2026-04-16 20:46:27.103	2026-04-16 20:46:27.103
cmo1y963x035rvxt0enrm33ur	cmo1y962o035hvxt0djed7qgg	cmo1xc12q000pvxp0kun82k4l	140000	2026-04-16 20:46:27.117	2026-04-16 20:46:27.117
cmo1y9644035tvxt0ss34msrs	cmo1y962o035hvxt0djed7qgg	cmo1xc138000rvxp0r16wi1bz	140000	2026-04-16 20:46:27.124	2026-04-16 20:46:27.124
cmo1y964c035vvxt0y4nexpbl	cmo1y962o035hvxt0djed7qgg	cmo1xc12i000ovxp01nisgvnu	140000	2026-04-16 20:46:27.132	2026-04-16 20:46:27.132
cmo1y964k035xvxt0tbltx1oc	cmo1y962o035hvxt0djed7qgg	cmo1xc13o000tvxp0alok8jeb	140000	2026-04-16 20:46:27.14	2026-04-16 20:46:27.14
cmo1y964u035zvxt01g844dqy	cmo1y962o035hvxt0djed7qgg	cmo1xc11n000kvxp0g32oj3wx	140000	2026-04-16 20:46:27.15	2026-04-16 20:46:27.15
cmo1y96520361vxt0qpntpfti	cmo1y962o035hvxt0djed7qgg	cmo1xc10u000hvxp0dapryn3r	140000	2026-04-16 20:46:27.158	2026-04-16 20:46:27.158
cmo1y965a0363vxt0rw30htsz	cmo1y962o035hvxt0djed7qgg	cmo1xc119000jvxp01snwxzoa	140000	2026-04-16 20:46:27.166	2026-04-16 20:46:27.166
cmo1y965q0367vxt09kzm58co	cmo1y965i0365vxt0jz6uh2sc	cmo1xsgrt0022vxv8sd7cckj7	73000	2026-04-16 20:46:27.182	2026-04-16 20:46:27.182
cmo1y965x0369vxt0h23pxg7f	cmo1y965i0365vxt0jz6uh2sc	cmo1xc11v000lvxp07r6uljko	73000	2026-04-16 20:46:27.189	2026-04-16 20:46:27.189
cmo1y966r036bvxt00z42z5i7	cmo1y965i0365vxt0jz6uh2sc	cmo1xc10u000hvxp0dapryn3r	73000	2026-04-16 20:46:27.219	2026-04-16 20:46:27.219
cmo1y9677036fvxt02tmhtfts	cmo1y9670036dvxt0e08bzpm7	cmo1xsgrt0022vxv8sd7cckj7	28000	2026-04-16 20:46:27.236	2026-04-16 20:46:27.236
cmo1y967e036hvxt0pwvs3n4j	cmo1y9670036dvxt0e08bzpm7	cmo1xc11v000lvxp07r6uljko	28000	2026-04-16 20:46:27.243	2026-04-16 20:46:27.243
cmo1y967m036jvxt0nqnazr6c	cmo1y9670036dvxt0e08bzpm7	cmo1xc12y000qvxp0uqc7d8d8	28000	2026-04-16 20:46:27.25	2026-04-16 20:46:27.25
cmo1y967u036lvxt05uiedx4k	cmo1y9670036dvxt0e08bzpm7	cmo1xc13g000svxp0tbndc1wg	28000	2026-04-16 20:46:27.258	2026-04-16 20:46:27.258
cmo1y9683036nvxt01103tzoi	cmo1y9670036dvxt0e08bzpm7	cmo1xc12q000pvxp0kun82k4l	28000	2026-04-16 20:46:27.267	2026-04-16 20:46:27.267
cmo1y968a036pvxt028whhctm	cmo1y9670036dvxt0e08bzpm7	cmo1xc138000rvxp0r16wi1bz	28000	2026-04-16 20:46:27.274	2026-04-16 20:46:27.274
cmo1y968i036rvxt0tm48z6kp	cmo1y9670036dvxt0e08bzpm7	cmo1xc12i000ovxp01nisgvnu	28000	2026-04-16 20:46:27.282	2026-04-16 20:46:27.282
cmo1y968p036tvxt09tn77gpc	cmo1y9670036dvxt0e08bzpm7	cmo1xc13o000tvxp0alok8jeb	28000	2026-04-16 20:46:27.289	2026-04-16 20:46:27.289
cmo1y9690036vvxt0tkm7kcs0	cmo1y9670036dvxt0e08bzpm7	cmo1xc11n000kvxp0g32oj3wx	28000	2026-04-16 20:46:27.3	2026-04-16 20:46:27.3
cmo1y9697036xvxt0yrvfqjik	cmo1y9670036dvxt0e08bzpm7	cmo1xc10u000hvxp0dapryn3r	28000	2026-04-16 20:46:27.307	2026-04-16 20:46:27.307
cmo1y969f036zvxt0n7igyp4t	cmo1y9670036dvxt0e08bzpm7	cmo1xc119000jvxp01snwxzoa	28000	2026-04-16 20:46:27.315	2026-04-16 20:46:27.315
cmo1y969w0373vxt0fx7gsm1e	cmo1y969m0371vxt040uhlyky	cmo1xsgrt0022vxv8sd7cckj7	150000	2026-04-16 20:46:27.332	2026-04-16 20:46:27.332
cmo1y96a20375vxt0giwf1oz0	cmo1y969m0371vxt040uhlyky	cmo1xc11v000lvxp07r6uljko	150000	2026-04-16 20:46:27.338	2026-04-16 20:46:27.338
cmo1y96aa0377vxt00gbnq6zz	cmo1y969m0371vxt040uhlyky	cmo1xc12y000qvxp0uqc7d8d8	150000	2026-04-16 20:46:27.346	2026-04-16 20:46:27.346
cmo1y96ai0379vxt07i6e8f80	cmo1y969m0371vxt040uhlyky	cmo1xc13g000svxp0tbndc1wg	150000	2026-04-16 20:46:27.354	2026-04-16 20:46:27.354
cmo1y96ar037bvxt0nezf6nj1	cmo1y969m0371vxt040uhlyky	cmo1xc12q000pvxp0kun82k4l	150000	2026-04-16 20:46:27.363	2026-04-16 20:46:27.363
cmo1y96ay037dvxt0oheiysbt	cmo1y969m0371vxt040uhlyky	cmo1xc138000rvxp0r16wi1bz	150000	2026-04-16 20:46:27.37	2026-04-16 20:46:27.37
cmo1y96b4037fvxt0tlu86lew	cmo1y969m0371vxt040uhlyky	cmo1xc12i000ovxp01nisgvnu	150000	2026-04-16 20:46:27.377	2026-04-16 20:46:27.377
cmo1y96ba037hvxt007pqln4v	cmo1y969m0371vxt040uhlyky	cmo1xc13o000tvxp0alok8jeb	150000	2026-04-16 20:46:27.383	2026-04-16 20:46:27.383
cmo1y96bl037jvxt0i0oxgash	cmo1y969m0371vxt040uhlyky	cmo1xc11n000kvxp0g32oj3wx	150000	2026-04-16 20:46:27.393	2026-04-16 20:46:27.393
cmo1y96br037lvxt0ymjps0c1	cmo1y969m0371vxt040uhlyky	cmo1xc10u000hvxp0dapryn3r	150000	2026-04-16 20:46:27.4	2026-04-16 20:46:27.4
cmo1y96by037nvxt01w84ez5s	cmo1y969m0371vxt040uhlyky	cmo1xc119000jvxp01snwxzoa	150000	2026-04-16 20:46:27.406	2026-04-16 20:46:27.406
cmo1y96d9037tvxt0e7hmgbvb	cmo1y96d1037rvxt0lsw4lwj5	cmo1xsgrt0022vxv8sd7cckj7	38000	2026-04-16 20:46:27.454	2026-04-16 20:46:27.454
cmo1y96dg037vvxt0x66geloq	cmo1y96d1037rvxt0lsw4lwj5	cmo1xc11v000lvxp07r6uljko	38000	2026-04-16 20:46:27.461	2026-04-16 20:46:27.461
cmo1y96dm037xvxt00d32ts5q	cmo1y96d1037rvxt0lsw4lwj5	cmo1xc12y000qvxp0uqc7d8d8	38000	2026-04-16 20:46:27.467	2026-04-16 20:46:27.467
cmo1y96du037zvxt0z3kl9xb1	cmo1y96d1037rvxt0lsw4lwj5	cmo1xc13g000svxp0tbndc1wg	38000	2026-04-16 20:46:27.474	2026-04-16 20:46:27.474
cmo1y96e30381vxt0h606i1z4	cmo1y96d1037rvxt0lsw4lwj5	cmo1xc12q000pvxp0kun82k4l	38000	2026-04-16 20:46:27.483	2026-04-16 20:46:27.483
cmo1y96ea0383vxt0iv4xuh6f	cmo1y96d1037rvxt0lsw4lwj5	cmo1xc138000rvxp0r16wi1bz	38000	2026-04-16 20:46:27.49	2026-04-16 20:46:27.49
cmo1y96ei0385vxt0pqg1bcq1	cmo1y96d1037rvxt0lsw4lwj5	cmo1xc12i000ovxp01nisgvnu	38000	2026-04-16 20:46:27.498	2026-04-16 20:46:27.498
cmo1y96ep0387vxt0lm40unaw	cmo1y96d1037rvxt0lsw4lwj5	cmo1xc13o000tvxp0alok8jeb	38000	2026-04-16 20:46:27.505	2026-04-16 20:46:27.505
cmo1y96ez0389vxt0qmhkaeem	cmo1y96d1037rvxt0lsw4lwj5	cmo1xc11n000kvxp0g32oj3wx	38000	2026-04-16 20:46:27.516	2026-04-16 20:46:27.516
cmo1y96f7038bvxt06dnganam	cmo1y96d1037rvxt0lsw4lwj5	cmo1xc10u000hvxp0dapryn3r	38000	2026-04-16 20:46:27.523	2026-04-16 20:46:27.523
cmo1y96fg038dvxt00os76ixs	cmo1y96d1037rvxt0lsw4lwj5	cmo1xc119000jvxp01snwxzoa	38000	2026-04-16 20:46:27.532	2026-04-16 20:46:27.532
cmo1y96fw038hvxt03gcxp6wg	cmo1y96fn038fvxt0aj5jgxwv	cmo1xsgrt0022vxv8sd7cckj7	38000	2026-04-16 20:46:27.548	2026-04-16 20:46:27.548
cmo1y96g3038jvxt0wvstx1ut	cmo1y96fn038fvxt0aj5jgxwv	cmo1xc11v000lvxp07r6uljko	38000	2026-04-16 20:46:27.555	2026-04-16 20:46:27.555
cmo1y96gb038lvxt0cokuxwmm	cmo1y96fn038fvxt0aj5jgxwv	cmo1xc12y000qvxp0uqc7d8d8	38000	2026-04-16 20:46:27.563	2026-04-16 20:46:27.563
cmo1y96gi038nvxt0zl92e0ym	cmo1y96fn038fvxt0aj5jgxwv	cmo1xc13g000svxp0tbndc1wg	38000	2026-04-16 20:46:27.57	2026-04-16 20:46:27.57
cmo1y96gs038pvxt0tq139yqr	cmo1y96fn038fvxt0aj5jgxwv	cmo1xc12q000pvxp0kun82k4l	38000	2026-04-16 20:46:27.581	2026-04-16 20:46:27.581
cmo1y96gz038rvxt01jkzawm3	cmo1y96fn038fvxt0aj5jgxwv	cmo1xc138000rvxp0r16wi1bz	38000	2026-04-16 20:46:27.588	2026-04-16 20:46:27.588
cmo1y96h6038tvxt06nyvy5aa	cmo1y96fn038fvxt0aj5jgxwv	cmo1xc12i000ovxp01nisgvnu	38000	2026-04-16 20:46:27.595	2026-04-16 20:46:27.595
cmo1y96hh038vvxt0os2ywre2	cmo1y96fn038fvxt0aj5jgxwv	cmo1xc13o000tvxp0alok8jeb	38000	2026-04-16 20:46:27.605	2026-04-16 20:46:27.605
cmo1y96hr038xvxt0zgkcyhb2	cmo1y96fn038fvxt0aj5jgxwv	cmo1xc11n000kvxp0g32oj3wx	38000	2026-04-16 20:46:27.615	2026-04-16 20:46:27.615
cmo1y96hx038zvxt001smvna2	cmo1y96fn038fvxt0aj5jgxwv	cmo1xc10u000hvxp0dapryn3r	38000	2026-04-16 20:46:27.622	2026-04-16 20:46:27.622
cmo1y96i50391vxt0h7x26szn	cmo1y96fn038fvxt0aj5jgxwv	cmo1xc119000jvxp01snwxzoa	38000	2026-04-16 20:46:27.629	2026-04-16 20:46:27.629
cmo1y96im0395vxt0be1u23nl	cmo1y96ie0393vxt0svz5k6sf	cmo1xsgrt0022vxv8sd7cckj7	38000	2026-04-16 20:46:27.646	2026-04-16 20:46:27.646
cmo1y96iv0397vxt0mzk9rcro	cmo1y96ie0393vxt0svz5k6sf	cmo1xc11v000lvxp07r6uljko	38000	2026-04-16 20:46:27.655	2026-04-16 20:46:27.655
cmo1y96j40399vxt04b2dnf2h	cmo1y96ie0393vxt0svz5k6sf	cmo1xc12y000qvxp0uqc7d8d8	38000	2026-04-16 20:46:27.665	2026-04-16 20:46:27.665
cmo1y96jb039bvxt0769iweel	cmo1y96ie0393vxt0svz5k6sf	cmo1xc13g000svxp0tbndc1wg	38000	2026-04-16 20:46:27.671	2026-04-16 20:46:27.671
cmo1y96jl039dvxt0q3qf4t2n	cmo1y96ie0393vxt0svz5k6sf	cmo1xc12q000pvxp0kun82k4l	38000	2026-04-16 20:46:27.681	2026-04-16 20:46:27.681
cmo1y96js039fvxt04zpkf5to	cmo1y96ie0393vxt0svz5k6sf	cmo1xc138000rvxp0r16wi1bz	38000	2026-04-16 20:46:27.688	2026-04-16 20:46:27.688
cmo1y96jz039hvxt0ts58a0br	cmo1y96ie0393vxt0svz5k6sf	cmo1xc12i000ovxp01nisgvnu	38000	2026-04-16 20:46:27.695	2026-04-16 20:46:27.695
cmo1y96k6039jvxt0bjx8fwsq	cmo1y96ie0393vxt0svz5k6sf	cmo1xc13o000tvxp0alok8jeb	38000	2026-04-16 20:46:27.702	2026-04-16 20:46:27.702
cmo1y96ke039lvxt082i0rdss	cmo1y96ie0393vxt0svz5k6sf	cmo1xc11n000kvxp0g32oj3wx	38000	2026-04-16 20:46:27.711	2026-04-16 20:46:27.711
cmo1y96kk039nvxt0t6th0xf3	cmo1y96ie0393vxt0svz5k6sf	cmo1xc10u000hvxp0dapryn3r	38000	2026-04-16 20:46:27.716	2026-04-16 20:46:27.716
cmo1y96kq039pvxt0ze3yodd0	cmo1y96ie0393vxt0svz5k6sf	cmo1xc119000jvxp01snwxzoa	38000	2026-04-16 20:46:27.723	2026-04-16 20:46:27.723
cmo1y96l7039tvxt0c8h1vqhw	cmo1y96kz039rvxt0b1tbdwel	cmo1xsgrt0022vxv8sd7cckj7	58000	2026-04-16 20:46:27.739	2026-04-16 20:46:27.739
cmo1y96lf039vvxt0vbs7s5ug	cmo1y96kz039rvxt0b1tbdwel	cmo1xc11v000lvxp07r6uljko	58000	2026-04-16 20:46:27.747	2026-04-16 20:46:27.747
cmo1y96ln039xvxt0lkoxp9xk	cmo1y96kz039rvxt0b1tbdwel	cmo1xc12y000qvxp0uqc7d8d8	58000	2026-04-16 20:46:27.755	2026-04-16 20:46:27.755
cmo1y96lw039zvxt0yhy39vvk	cmo1y96kz039rvxt0b1tbdwel	cmo1xc13g000svxp0tbndc1wg	58000	2026-04-16 20:46:27.764	2026-04-16 20:46:27.764
cmo1y96m703a1vxt0nl9kpnid	cmo1y96kz039rvxt0b1tbdwel	cmo1xc12q000pvxp0kun82k4l	58000	2026-04-16 20:46:27.776	2026-04-16 20:46:27.776
cmo1y96me03a3vxt0800orgds	cmo1y96kz039rvxt0b1tbdwel	cmo1xc138000rvxp0r16wi1bz	58000	2026-04-16 20:46:27.782	2026-04-16 20:46:27.782
cmo1y96ml03a5vxt05d5wnh6g	cmo1y96kz039rvxt0b1tbdwel	cmo1xc12i000ovxp01nisgvnu	58000	2026-04-16 20:46:27.789	2026-04-16 20:46:27.789
cmo1y96ms03a7vxt0d32eeg2g	cmo1y96kz039rvxt0b1tbdwel	cmo1xc13o000tvxp0alok8jeb	58000	2026-04-16 20:46:27.797	2026-04-16 20:46:27.797
cmo1y96n203a9vxt0rajem1kj	cmo1y96kz039rvxt0b1tbdwel	cmo1xc11n000kvxp0g32oj3wx	58000	2026-04-16 20:46:27.806	2026-04-16 20:46:27.806
cmo1y96na03abvxt0pdi3hv5t	cmo1y96kz039rvxt0b1tbdwel	cmo1xc10u000hvxp0dapryn3r	58000	2026-04-16 20:46:27.814	2026-04-16 20:46:27.814
cmo1y96nh03advxt0v2uz6v3z	cmo1y96kz039rvxt0b1tbdwel	cmo1xc119000jvxp01snwxzoa	58000	2026-04-16 20:46:27.821	2026-04-16 20:46:27.821
cmo1y96nw03ahvxt0it6ww01s	cmo1y96no03afvxt00339co2s	cmo1xsgrt0022vxv8sd7cckj7	700000	2026-04-16 20:46:27.837	2026-04-16 20:46:27.837
cmo1y96o303ajvxt0e91ti7iz	cmo1y96no03afvxt00339co2s	cmo1xc11v000lvxp07r6uljko	700000	2026-04-16 20:46:27.844	2026-04-16 20:46:27.844
cmo1y96oc03alvxt0ohui5kxp	cmo1y96no03afvxt00339co2s	cmo1xc12q000pvxp0kun82k4l	700000	2026-04-16 20:46:27.853	2026-04-16 20:46:27.853
cmo1y96or03anvxt0q4zqf6pj	cmo1y96no03afvxt00339co2s	cmo1xc10u000hvxp0dapryn3r	700000	2026-04-16 20:46:27.868	2026-04-16 20:46:27.868
cmo1y96p903arvxt0iqwnen0q	cmo1y96p103apvxt0xkjnvjst	cmo1xsgrt0022vxv8sd7cckj7	50000	2026-04-16 20:46:27.885	2026-04-16 20:46:27.885
cmo1y96pf03atvxt0y3vtef00	cmo1y96p103apvxt0xkjnvjst	cmo1xc11v000lvxp07r6uljko	50000	2026-04-16 20:46:27.892	2026-04-16 20:46:27.892
cmo1y96pn03avvxt08ehcrvjn	cmo1y96p103apvxt0xkjnvjst	cmo1xc12y000qvxp0uqc7d8d8	50000	2026-04-16 20:46:27.899	2026-04-16 20:46:27.899
cmo1y96pu03axvxt0hxo38nuh	cmo1y96p103apvxt0xkjnvjst	cmo1xc13g000svxp0tbndc1wg	50000	2026-04-16 20:46:27.906	2026-04-16 20:46:27.906
cmo1y96q303azvxt056h9x5bf	cmo1y96p103apvxt0xkjnvjst	cmo1xc12q000pvxp0kun82k4l	50000	2026-04-16 20:46:27.915	2026-04-16 20:46:27.915
cmo1y96q903b1vxt0194q0i7a	cmo1y96p103apvxt0xkjnvjst	cmo1xc138000rvxp0r16wi1bz	50000	2026-04-16 20:46:27.922	2026-04-16 20:46:27.922
cmo1y96qh03b3vxt05rg10dje	cmo1y96p103apvxt0xkjnvjst	cmo1xc12i000ovxp01nisgvnu	50000	2026-04-16 20:46:27.929	2026-04-16 20:46:27.929
cmo1y96qp03b5vxt0r411586h	cmo1y96p103apvxt0xkjnvjst	cmo1xc13o000tvxp0alok8jeb	50000	2026-04-16 20:46:27.937	2026-04-16 20:46:27.937
cmo1y96qy03b7vxt0r9szt5ju	cmo1y96p103apvxt0xkjnvjst	cmo1xc11n000kvxp0g32oj3wx	50000	2026-04-16 20:46:27.946	2026-04-16 20:46:27.946
cmo1y96r503b9vxt0x3njwzjy	cmo1y96p103apvxt0xkjnvjst	cmo1xc10u000hvxp0dapryn3r	50000	2026-04-16 20:46:27.954	2026-04-16 20:46:27.954
cmo1y96rd03bbvxt0vt53wls9	cmo1y96p103apvxt0xkjnvjst	cmo1xc119000jvxp01snwxzoa	50000	2026-04-16 20:46:27.961	2026-04-16 20:46:27.961
cmo1y96rr03bfvxt0n60dho34	cmo1y96rj03bdvxt0ugvmzuzw	cmo1xsgrt0022vxv8sd7cckj7	700000	2026-04-16 20:46:27.975	2026-04-16 20:46:27.975
cmo1y96ry03bhvxt0nikic9ia	cmo1y96rj03bdvxt0ugvmzuzw	cmo1xc11v000lvxp07r6uljko	700000	2026-04-16 20:46:27.982	2026-04-16 20:46:27.982
cmo1y96s503bjvxt0x3f87y7r	cmo1y96rj03bdvxt0ugvmzuzw	cmo1xc12y000qvxp0uqc7d8d8	700000	2026-04-16 20:46:27.99	2026-04-16 20:46:27.99
cmo1y96se03blvxt05l3mhrk5	cmo1y96rj03bdvxt0ugvmzuzw	cmo1xc13g000svxp0tbndc1wg	700000	2026-04-16 20:46:27.999	2026-04-16 20:46:27.999
cmo1y96sp03bnvxt0xqxnbf50	cmo1y96rj03bdvxt0ugvmzuzw	cmo1xc12q000pvxp0kun82k4l	700000	2026-04-16 20:46:28.009	2026-04-16 20:46:28.009
cmo1y96sw03bpvxt0dgy2ffxa	cmo1y96rj03bdvxt0ugvmzuzw	cmo1xc138000rvxp0r16wi1bz	700000	2026-04-16 20:46:28.016	2026-04-16 20:46:28.016
cmo1y96t203brvxt0rha7hhft	cmo1y96rj03bdvxt0ugvmzuzw	cmo1xc12i000ovxp01nisgvnu	700000	2026-04-16 20:46:28.023	2026-04-16 20:46:28.023
cmo1y96tb03btvxt0b1dutv9a	cmo1y96rj03bdvxt0ugvmzuzw	cmo1xc13o000tvxp0alok8jeb	700000	2026-04-16 20:46:28.031	2026-04-16 20:46:28.031
cmo1y96tk03bvvxt0th306zhv	cmo1y96rj03bdvxt0ugvmzuzw	cmo1xc11n000kvxp0g32oj3wx	700000	2026-04-16 20:46:28.04	2026-04-16 20:46:28.04
cmo1y96ts03bxvxt06b1rpu6e	cmo1y96rj03bdvxt0ugvmzuzw	cmo1xc10u000hvxp0dapryn3r	700000	2026-04-16 20:46:28.048	2026-04-16 20:46:28.048
cmo1y96u303bzvxt0zrhagpq4	cmo1y96rj03bdvxt0ugvmzuzw	cmo1xc119000jvxp01snwxzoa	700000	2026-04-16 20:46:28.059	2026-04-16 20:46:28.059
cmo1y96ui03c3vxt0wtp0ki6w	cmo1y96ua03c1vxt006gax5u5	cmo1xsgrt0022vxv8sd7cckj7	79000	2026-04-16 20:46:28.074	2026-04-16 20:46:28.074
cmo1y96up03c5vxt0ew7vjz8n	cmo1y96ua03c1vxt006gax5u5	cmo1xc11v000lvxp07r6uljko	79000	2026-04-16 20:46:28.082	2026-04-16 20:46:28.082
cmo1y96uw03c7vxt0j65k9pgl	cmo1y96ua03c1vxt006gax5u5	cmo1xc12y000qvxp0uqc7d8d8	79000	2026-04-16 20:46:28.088	2026-04-16 20:46:28.088
cmo1y96v303c9vxt0gnmufw83	cmo1y96ua03c1vxt006gax5u5	cmo1xc13g000svxp0tbndc1wg	79000	2026-04-16 20:46:28.096	2026-04-16 20:46:28.096
cmo1y96ve03cbvxt09c8p51pb	cmo1y96ua03c1vxt006gax5u5	cmo1xc12q000pvxp0kun82k4l	79000	2026-04-16 20:46:28.106	2026-04-16 20:46:28.106
cmo1y96vm03cdvxt0selhsxrf	cmo1y96ua03c1vxt006gax5u5	cmo1xc138000rvxp0r16wi1bz	79000	2026-04-16 20:46:28.115	2026-04-16 20:46:28.115
cmo1y96vt03cfvxt0ppkn2i5g	cmo1y96ua03c1vxt006gax5u5	cmo1xc12i000ovxp01nisgvnu	79000	2026-04-16 20:46:28.121	2026-04-16 20:46:28.121
cmo1y96w303chvxt0lqnjkege	cmo1y96ua03c1vxt006gax5u5	cmo1xc13o000tvxp0alok8jeb	79000	2026-04-16 20:46:28.131	2026-04-16 20:46:28.131
cmo1y96wc03cjvxt09mfwpipe	cmo1y96ua03c1vxt006gax5u5	cmo1xc11n000kvxp0g32oj3wx	79000	2026-04-16 20:46:28.141	2026-04-16 20:46:28.141
cmo1y96wk03clvxt0aivyifqw	cmo1y96ua03c1vxt006gax5u5	cmo1xc10u000hvxp0dapryn3r	79000	2026-04-16 20:46:28.149	2026-04-16 20:46:28.149
cmo1y96wr03cnvxt0scniaw3i	cmo1y96ua03c1vxt006gax5u5	cmo1xc119000jvxp01snwxzoa	79000	2026-04-16 20:46:28.156	2026-04-16 20:46:28.156
cmo1y96x703crvxt0d2lg5ldv	cmo1y96wz03cpvxt091vexgl1	cmo1xsgrt0022vxv8sd7cckj7	84000	2026-04-16 20:46:28.171	2026-04-16 20:46:28.171
cmo1y96xf03ctvxt0hd8s88iw	cmo1y96wz03cpvxt091vexgl1	cmo1xc11v000lvxp07r6uljko	84000	2026-04-16 20:46:28.179	2026-04-16 20:46:28.179
cmo1y96xm03cvvxt0k66ocwg7	cmo1y96wz03cpvxt091vexgl1	cmo1xc12y000qvxp0uqc7d8d8	84000	2026-04-16 20:46:28.187	2026-04-16 20:46:28.187
cmo1y96xu03cxvxt0y7ulr50c	cmo1y96wz03cpvxt091vexgl1	cmo1xc13g000svxp0tbndc1wg	84000	2026-04-16 20:46:28.194	2026-04-16 20:46:28.194
cmo1y96y103czvxt0waqtkaqc	cmo1y96wz03cpvxt091vexgl1	cmo1xc12q000pvxp0kun82k4l	84000	2026-04-16 20:46:28.201	2026-04-16 20:46:28.201
cmo1y96y803d1vxt0s31iokc5	cmo1y96wz03cpvxt091vexgl1	cmo1xc138000rvxp0r16wi1bz	84000	2026-04-16 20:46:28.208	2026-04-16 20:46:28.208
cmo1y96yf03d3vxt0ar9k56q4	cmo1y96wz03cpvxt091vexgl1	cmo1xc12i000ovxp01nisgvnu	84000	2026-04-16 20:46:28.215	2026-04-16 20:46:28.215
cmo1y96yl03d5vxt0698xqam4	cmo1y96wz03cpvxt091vexgl1	cmo1xc13o000tvxp0alok8jeb	84000	2026-04-16 20:46:28.222	2026-04-16 20:46:28.222
cmo1y96yv03d7vxt0by5xuurl	cmo1y96wz03cpvxt091vexgl1	cmo1xc11n000kvxp0g32oj3wx	84000	2026-04-16 20:46:28.232	2026-04-16 20:46:28.232
cmo1y96z203d9vxt0bsz1blxg	cmo1y96wz03cpvxt091vexgl1	cmo1xc10u000hvxp0dapryn3r	84000	2026-04-16 20:46:28.239	2026-04-16 20:46:28.239
cmo1y96za03dbvxt0gux9gfk5	cmo1y96wz03cpvxt091vexgl1	cmo1xc119000jvxp01snwxzoa	84000	2026-04-16 20:46:28.246	2026-04-16 20:46:28.246
cmo1y96zt03dfvxt0utt3nk30	cmo1y96zi03ddvxt0xv0kbhd6	cmo1xsgrt0022vxv8sd7cckj7	90000	2026-04-16 20:46:28.265	2026-04-16 20:46:28.265
cmo1y970103dhvxt007finy64	cmo1y96zi03ddvxt0xv0kbhd6	cmo1xc11v000lvxp07r6uljko	90000	2026-04-16 20:46:28.273	2026-04-16 20:46:28.273
cmo1y970a03djvxt08w6gzsd5	cmo1y96zi03ddvxt0xv0kbhd6	cmo1xc12y000qvxp0uqc7d8d8	90000	2026-04-16 20:46:28.282	2026-04-16 20:46:28.282
cmo1y970g03dlvxt0j0tzy9an	cmo1y96zi03ddvxt0xv0kbhd6	cmo1xc13g000svxp0tbndc1wg	90000	2026-04-16 20:46:28.289	2026-04-16 20:46:28.289
cmo1y970r03dnvxt0ye5ikv9l	cmo1y96zi03ddvxt0xv0kbhd6	cmo1xc12q000pvxp0kun82k4l	90000	2026-04-16 20:46:28.299	2026-04-16 20:46:28.299
cmo1y970y03dpvxt004ehj4z8	cmo1y96zi03ddvxt0xv0kbhd6	cmo1xc138000rvxp0r16wi1bz	90000	2026-04-16 20:46:28.306	2026-04-16 20:46:28.306
cmo1y971703drvxt0gem9clih	cmo1y96zi03ddvxt0xv0kbhd6	cmo1xc12i000ovxp01nisgvnu	90000	2026-04-16 20:46:28.315	2026-04-16 20:46:28.315
cmo1y971d03dtvxt0zzbaf7vx	cmo1y96zi03ddvxt0xv0kbhd6	cmo1xc13o000tvxp0alok8jeb	90000	2026-04-16 20:46:28.322	2026-04-16 20:46:28.322
cmo1y971n03dvvxt0p2z0uxmt	cmo1y96zi03ddvxt0xv0kbhd6	cmo1xc11n000kvxp0g32oj3wx	90000	2026-04-16 20:46:28.331	2026-04-16 20:46:28.331
cmo1y971u03dxvxt0zgnfjfau	cmo1y96zi03ddvxt0xv0kbhd6	cmo1xc10u000hvxp0dapryn3r	90000	2026-04-16 20:46:28.338	2026-04-16 20:46:28.338
cmo1y972103dzvxt0rlev3ney	cmo1y96zi03ddvxt0xv0kbhd6	cmo1xc119000jvxp01snwxzoa	90000	2026-04-16 20:46:28.346	2026-04-16 20:46:28.346
cmo1y972i03e3vxt0rrartf2r	cmo1y972903e1vxt037ejb62r	cmo1xsgrt0022vxv8sd7cckj7	90000	2026-04-16 20:46:28.362	2026-04-16 20:46:28.362
cmo1y972r03e5vxt0625hg6t0	cmo1y972903e1vxt037ejb62r	cmo1xc11v000lvxp07r6uljko	90000	2026-04-16 20:46:28.371	2026-04-16 20:46:28.371
cmo1y972y03e7vxt0b6zehbqv	cmo1y972903e1vxt037ejb62r	cmo1xc12y000qvxp0uqc7d8d8	90000	2026-04-16 20:46:28.379	2026-04-16 20:46:28.379
cmo1y973603e9vxt0vev57kwi	cmo1y972903e1vxt037ejb62r	cmo1xc13g000svxp0tbndc1wg	90000	2026-04-16 20:46:28.386	2026-04-16 20:46:28.386
cmo1y973e03ebvxt0nauzxbsk	cmo1y972903e1vxt037ejb62r	cmo1xc12q000pvxp0kun82k4l	90000	2026-04-16 20:46:28.395	2026-04-16 20:46:28.395
cmo1y973m03edvxt0tspwyp0b	cmo1y972903e1vxt037ejb62r	cmo1xc138000rvxp0r16wi1bz	90000	2026-04-16 20:46:28.402	2026-04-16 20:46:28.402
cmo1y973t03efvxt0t6194fkr	cmo1y972903e1vxt037ejb62r	cmo1xc12i000ovxp01nisgvnu	90000	2026-04-16 20:46:28.409	2026-04-16 20:46:28.409
cmo1y973z03ehvxt0bshj50w4	cmo1y972903e1vxt037ejb62r	cmo1xc13o000tvxp0alok8jeb	80000	2026-04-16 20:46:28.416	2026-04-16 20:46:28.416
cmo1y974903ejvxt0mahm70zz	cmo1y972903e1vxt037ejb62r	cmo1xc11n000kvxp0g32oj3wx	90000	2026-04-16 20:46:28.425	2026-04-16 20:46:28.425
cmo1y974g03elvxt0g55j0tw6	cmo1y972903e1vxt037ejb62r	cmo1xc10u000hvxp0dapryn3r	90000	2026-04-16 20:46:28.432	2026-04-16 20:46:28.432
cmo1y974m03envxt0le805yvf	cmo1y972903e1vxt037ejb62r	cmo1xc119000jvxp01snwxzoa	90000	2026-04-16 20:46:28.438	2026-04-16 20:46:28.438
cmo1y975003ervxt0q4777ihr	cmo1y974t03epvxt0twf8er9n	cmo1xsgrt0022vxv8sd7cckj7	90000	2026-04-16 20:46:28.453	2026-04-16 20:46:28.453
cmo1y975803etvxt00vq0jdpl	cmo1y974t03epvxt0twf8er9n	cmo1xc11v000lvxp07r6uljko	90000	2026-04-16 20:46:28.46	2026-04-16 20:46:28.46
cmo1y975e03evvxt0c1sed12x	cmo1y974t03epvxt0twf8er9n	cmo1xc12y000qvxp0uqc7d8d8	90000	2026-04-16 20:46:28.466	2026-04-16 20:46:28.466
cmo1y975l03exvxt077mktete	cmo1y974t03epvxt0twf8er9n	cmo1xc13g000svxp0tbndc1wg	90000	2026-04-16 20:46:28.473	2026-04-16 20:46:28.473
cmo1y975v03ezvxt0z1i64kcu	cmo1y974t03epvxt0twf8er9n	cmo1xc12q000pvxp0kun82k4l	90000	2026-04-16 20:46:28.483	2026-04-16 20:46:28.483
cmo1y976203f1vxt0zc3vwnna	cmo1y974t03epvxt0twf8er9n	cmo1xc138000rvxp0r16wi1bz	90000	2026-04-16 20:46:28.49	2026-04-16 20:46:28.49
cmo1y976a03f3vxt0mmsyvox1	cmo1y974t03epvxt0twf8er9n	cmo1xc12i000ovxp01nisgvnu	90000	2026-04-16 20:46:28.498	2026-04-16 20:46:28.498
cmo1y976h03f5vxt0hsm6dsy5	cmo1y974t03epvxt0twf8er9n	cmo1xc13o000tvxp0alok8jeb	80000	2026-04-16 20:46:28.505	2026-04-16 20:46:28.505
cmo1y976r03f7vxt0fcym9mes	cmo1y974t03epvxt0twf8er9n	cmo1xc11n000kvxp0g32oj3wx	90000	2026-04-16 20:46:28.516	2026-04-16 20:46:28.516
cmo1y976y03f9vxt03bsi7vg5	cmo1y974t03epvxt0twf8er9n	cmo1xc10u000hvxp0dapryn3r	90000	2026-04-16 20:46:28.523	2026-04-16 20:46:28.523
cmo1y977703fbvxt0rvaqae7o	cmo1y974t03epvxt0twf8er9n	cmo1xc119000jvxp01snwxzoa	90000	2026-04-16 20:46:28.532	2026-04-16 20:46:28.532
cmo1y977o03ffvxt0d0zupnt1	cmo1y977f03fdvxt04av0zukh	cmo1xsgrt0022vxv8sd7cckj7	90000	2026-04-16 20:46:28.548	2026-04-16 20:46:28.548
cmo1y977v03fhvxt0a10r4ola	cmo1y977f03fdvxt04av0zukh	cmo1xc11v000lvxp07r6uljko	90000	2026-04-16 20:46:28.555	2026-04-16 20:46:28.555
cmo1y978503fjvxt0ckjwc4fn	cmo1y977f03fdvxt04av0zukh	cmo1xc12y000qvxp0uqc7d8d8	90000	2026-04-16 20:46:28.565	2026-04-16 20:46:28.565
cmo1y978b03flvxt07ptig7pu	cmo1y977f03fdvxt04av0zukh	cmo1xc13g000svxp0tbndc1wg	90000	2026-04-16 20:46:28.571	2026-04-16 20:46:28.571
cmo1y978l03fnvxt01iyqovh1	cmo1y977f03fdvxt04av0zukh	cmo1xc12q000pvxp0kun82k4l	90000	2026-04-16 20:46:28.582	2026-04-16 20:46:28.582
cmo1y978t03fpvxt0hmcfbk75	cmo1y977f03fdvxt04av0zukh	cmo1xc138000rvxp0r16wi1bz	90000	2026-04-16 20:46:28.589	2026-04-16 20:46:28.589
cmo1y979103frvxt0o45pppel	cmo1y977f03fdvxt04av0zukh	cmo1xc12i000ovxp01nisgvnu	90000	2026-04-16 20:46:28.598	2026-04-16 20:46:28.598
cmo1y979903ftvxt07dzhyn2b	cmo1y977f03fdvxt04av0zukh	cmo1xc13o000tvxp0alok8jeb	80000	2026-04-16 20:46:28.605	2026-04-16 20:46:28.605
cmo1y979j03fvvxt0voqpj1w1	cmo1y977f03fdvxt04av0zukh	cmo1xc11n000kvxp0g32oj3wx	90000	2026-04-16 20:46:28.615	2026-04-16 20:46:28.615
cmo1y979p03fxvxt0fr929p8s	cmo1y977f03fdvxt04av0zukh	cmo1xc10u000hvxp0dapryn3r	90000	2026-04-16 20:46:28.621	2026-04-16 20:46:28.621
cmo1y979x03fzvxt0r1v1kwwn	cmo1y977f03fdvxt04av0zukh	cmo1xc119000jvxp01snwxzoa	90000	2026-04-16 20:46:28.629	2026-04-16 20:46:28.629
cmo1y97ac03g3vxt0cldtv4ig	cmo1y97a503g1vxt01hul0r9p	cmo1xsgrt0022vxv8sd7cckj7	90000	2026-04-16 20:46:28.645	2026-04-16 20:46:28.645
cmo1y97al03g5vxt083menwtl	cmo1y97a503g1vxt01hul0r9p	cmo1xc11v000lvxp07r6uljko	90000	2026-04-16 20:46:28.653	2026-04-16 20:46:28.653
cmo1y97at03g7vxt0v06jl8bi	cmo1y97a503g1vxt01hul0r9p	cmo1xc12y000qvxp0uqc7d8d8	90000	2026-04-16 20:46:28.661	2026-04-16 20:46:28.661
cmo1y97az03g9vxt0vsc5n4vd	cmo1y97a503g1vxt01hul0r9p	cmo1xc13g000svxp0tbndc1wg	90000	2026-04-16 20:46:28.667	2026-04-16 20:46:28.667
cmo1y97b903gbvxt0s0r2fdoo	cmo1y97a503g1vxt01hul0r9p	cmo1xc12q000pvxp0kun82k4l	90000	2026-04-16 20:46:28.677	2026-04-16 20:46:28.677
cmo1y97bj03gdvxt03283moh0	cmo1y97a503g1vxt01hul0r9p	cmo1xc138000rvxp0r16wi1bz	90000	2026-04-16 20:46:28.687	2026-04-16 20:46:28.687
cmo1y97bq03gfvxt061cu73p8	cmo1y97a503g1vxt01hul0r9p	cmo1xc12i000ovxp01nisgvnu	90000	2026-04-16 20:46:28.695	2026-04-16 20:46:28.695
cmo1y97bx03ghvxt0cxbss5t6	cmo1y97a503g1vxt01hul0r9p	cmo1xc13o000tvxp0alok8jeb	80000	2026-04-16 20:46:28.702	2026-04-16 20:46:28.702
cmo1y97c703gjvxt0f2b22u2r	cmo1y97a503g1vxt01hul0r9p	cmo1xc11n000kvxp0g32oj3wx	90000	2026-04-16 20:46:28.711	2026-04-16 20:46:28.711
cmo1y97cd03glvxt0tlawobpu	cmo1y97a503g1vxt01hul0r9p	cmo1xc10u000hvxp0dapryn3r	90000	2026-04-16 20:46:28.717	2026-04-16 20:46:28.717
cmo1y97cl03gnvxt07xgiq7k3	cmo1y97a503g1vxt01hul0r9p	cmo1xc119000jvxp01snwxzoa	90000	2026-04-16 20:46:28.725	2026-04-16 20:46:28.725
cmo1y97d103grvxt0ax6b7564	cmo1y97ct03gpvxt06b698a73	cmo1xsgrt0022vxv8sd7cckj7	90000	2026-04-16 20:46:28.741	2026-04-16 20:46:28.741
cmo1y97d903gtvxt01amjatf3	cmo1y97ct03gpvxt06b698a73	cmo1xc11v000lvxp07r6uljko	90000	2026-04-16 20:46:28.75	2026-04-16 20:46:28.75
cmo1y97dj03gvvxt076mzpyft	cmo1y97ct03gpvxt06b698a73	cmo1xc12y000qvxp0uqc7d8d8	90000	2026-04-16 20:46:28.76	2026-04-16 20:46:28.76
cmo1y97dq03gxvxt0jq0p9ha7	cmo1y97ct03gpvxt06b698a73	cmo1xc13g000svxp0tbndc1wg	90000	2026-04-16 20:46:28.766	2026-04-16 20:46:28.766
cmo1y97e203gzvxt0j66w6b97	cmo1y97ct03gpvxt06b698a73	cmo1xc12q000pvxp0kun82k4l	90000	2026-04-16 20:46:28.779	2026-04-16 20:46:28.779
cmo1y97ec03h1vxt06bb6jyl7	cmo1y97ct03gpvxt06b698a73	cmo1xc138000rvxp0r16wi1bz	90000	2026-04-16 20:46:28.788	2026-04-16 20:46:28.788
cmo1y97ei03h3vxt0qfrfukkd	cmo1y97ct03gpvxt06b698a73	cmo1xc12i000ovxp01nisgvnu	90000	2026-04-16 20:46:28.795	2026-04-16 20:46:28.795
cmo1y97eo03h5vxt00w2vh6lb	cmo1y97ct03gpvxt06b698a73	cmo1xc13o000tvxp0alok8jeb	80000	2026-04-16 20:46:28.8	2026-04-16 20:46:28.8
cmo1y97ew03h7vxt0nrj3s914	cmo1y97ct03gpvxt06b698a73	cmo1xc11n000kvxp0g32oj3wx	90000	2026-04-16 20:46:28.809	2026-04-16 20:46:28.809
cmo1y97f303h9vxt0494e788e	cmo1y97ct03gpvxt06b698a73	cmo1xc10u000hvxp0dapryn3r	90000	2026-04-16 20:46:28.815	2026-04-16 20:46:28.815
cmo1y97f803hbvxt0m1oyhiz2	cmo1y97ct03gpvxt06b698a73	cmo1xc119000jvxp01snwxzoa	90000	2026-04-16 20:46:28.821	2026-04-16 20:46:28.821
cmo1y97fl03hfvxt012oa35dm	cmo1y97ff03hdvxt043lnkxpg	cmo1xsgrt0022vxv8sd7cckj7	90000	2026-04-16 20:46:28.834	2026-04-16 20:46:28.834
cmo1y97fs03hhvxt0lpfzx4h6	cmo1y97ff03hdvxt043lnkxpg	cmo1xc11v000lvxp07r6uljko	90000	2026-04-16 20:46:28.84	2026-04-16 20:46:28.84
cmo1y97fy03hjvxt08zfguure	cmo1y97ff03hdvxt043lnkxpg	cmo1xc12y000qvxp0uqc7d8d8	90000	2026-04-16 20:46:28.846	2026-04-16 20:46:28.846
cmo1y97g503hlvxt06y5e84ie	cmo1y97ff03hdvxt043lnkxpg	cmo1xc13g000svxp0tbndc1wg	90000	2026-04-16 20:46:28.853	2026-04-16 20:46:28.853
cmo1y97gc03hnvxt0blev4jon	cmo1y97ff03hdvxt043lnkxpg	cmo1xc12q000pvxp0kun82k4l	90000	2026-04-16 20:46:28.86	2026-04-16 20:46:28.86
cmo1y97gh03hpvxt0m1u4e2iq	cmo1y97ff03hdvxt043lnkxpg	cmo1xc138000rvxp0r16wi1bz	90000	2026-04-16 20:46:28.866	2026-04-16 20:46:28.866
cmo1y97go03hrvxt0092he1te	cmo1y97ff03hdvxt043lnkxpg	cmo1xc12i000ovxp01nisgvnu	90000	2026-04-16 20:46:28.872	2026-04-16 20:46:28.872
cmo1y97gv03htvxt0tuu0m60g	cmo1y97ff03hdvxt043lnkxpg	cmo1xc13o000tvxp0alok8jeb	80000	2026-04-16 20:46:28.879	2026-04-16 20:46:28.879
cmo1y97h503hvvxt0l5pmpf5n	cmo1y97ff03hdvxt043lnkxpg	cmo1xc11n000kvxp0g32oj3wx	90000	2026-04-16 20:46:28.889	2026-04-16 20:46:28.889
cmo1y97he03hxvxt0axhfyvk5	cmo1y97ff03hdvxt043lnkxpg	cmo1xc10u000hvxp0dapryn3r	90000	2026-04-16 20:46:28.898	2026-04-16 20:46:28.898
cmo1y97hl03hzvxt0jzw5i39i	cmo1y97ff03hdvxt043lnkxpg	cmo1xc119000jvxp01snwxzoa	90000	2026-04-16 20:46:28.905	2026-04-16 20:46:28.905
cmo1y97i203i3vxt0vvwvo4tv	cmo1y97hv03i1vxt0t3bpz6hn	cmo1xsgrt0022vxv8sd7cckj7	90000	2026-04-16 20:46:28.922	2026-04-16 20:46:28.922
cmo1y97i803i5vxt0blgkabbh	cmo1y97hv03i1vxt0t3bpz6hn	cmo1xc11v000lvxp07r6uljko	90000	2026-04-16 20:46:28.928	2026-04-16 20:46:28.928
cmo1y97ii03i7vxt0020y3mm7	cmo1y97hv03i1vxt0t3bpz6hn	cmo1xc12y000qvxp0uqc7d8d8	90000	2026-04-16 20:46:28.938	2026-04-16 20:46:28.938
cmo1y97io03i9vxt0xevwk3ha	cmo1y97hv03i1vxt0t3bpz6hn	cmo1xc13g000svxp0tbndc1wg	90000	2026-04-16 20:46:28.944	2026-04-16 20:46:28.944
cmo1y97ix03ibvxt0dgncirb9	cmo1y97hv03i1vxt0t3bpz6hn	cmo1xc12q000pvxp0kun82k4l	90000	2026-04-16 20:46:28.954	2026-04-16 20:46:28.954
cmo1y97j403idvxt0oy5wa319	cmo1y97hv03i1vxt0t3bpz6hn	cmo1xc138000rvxp0r16wi1bz	90000	2026-04-16 20:46:28.96	2026-04-16 20:46:28.96
cmo1y97ja03ifvxt0lrfsn34h	cmo1y97hv03i1vxt0t3bpz6hn	cmo1xc12i000ovxp01nisgvnu	90000	2026-04-16 20:46:28.966	2026-04-16 20:46:28.966
cmo1y97jg03ihvxt0ft6q8por	cmo1y97hv03i1vxt0t3bpz6hn	cmo1xc13o000tvxp0alok8jeb	80000	2026-04-16 20:46:28.973	2026-04-16 20:46:28.973
cmo1y97jq03ijvxt0noa3kna3	cmo1y97hv03i1vxt0t3bpz6hn	cmo1xc11n000kvxp0g32oj3wx	90000	2026-04-16 20:46:28.983	2026-04-16 20:46:28.983
cmo1y97jx03ilvxt04o8gkrz6	cmo1y97hv03i1vxt0t3bpz6hn	cmo1xc10u000hvxp0dapryn3r	90000	2026-04-16 20:46:28.989	2026-04-16 20:46:28.989
cmo1y97k503invxt078w5a5s0	cmo1y97hv03i1vxt0t3bpz6hn	cmo1xc119000jvxp01snwxzoa	90000	2026-04-16 20:46:28.997	2026-04-16 20:46:28.997
cmo1y97km03irvxt0686fa3qj	cmo1y97kd03ipvxt0l744jbjp	cmo1xsgrt0022vxv8sd7cckj7	90000	2026-04-16 20:46:29.014	2026-04-16 20:46:29.014
cmo1y97kt03itvxt0wk7k1tn0	cmo1y97kd03ipvxt0l744jbjp	cmo1xc11v000lvxp07r6uljko	90000	2026-04-16 20:46:29.021	2026-04-16 20:46:29.021
cmo1y97l003ivvxt0rtxem4f4	cmo1y97kd03ipvxt0l744jbjp	cmo1xc12y000qvxp0uqc7d8d8	90000	2026-04-16 20:46:29.028	2026-04-16 20:46:29.028
cmo1y97l703ixvxt0uoht4039	cmo1y97kd03ipvxt0l744jbjp	cmo1xc13g000svxp0tbndc1wg	90000	2026-04-16 20:46:29.036	2026-04-16 20:46:29.036
cmo1y97lg03izvxt0cqqc4krm	cmo1y97kd03ipvxt0l744jbjp	cmo1xc12q000pvxp0kun82k4l	90000	2026-04-16 20:46:29.044	2026-04-16 20:46:29.044
cmo1y97lm03j1vxt0peabhju6	cmo1y97kd03ipvxt0l744jbjp	cmo1xc138000rvxp0r16wi1bz	90000	2026-04-16 20:46:29.05	2026-04-16 20:46:29.05
cmo1y97lt03j3vxt0ae5c3iu5	cmo1y97kd03ipvxt0l744jbjp	cmo1xc12i000ovxp01nisgvnu	90000	2026-04-16 20:46:29.057	2026-04-16 20:46:29.057
cmo1y97m103j5vxt03cd0m280	cmo1y97kd03ipvxt0l744jbjp	cmo1xc13o000tvxp0alok8jeb	80000	2026-04-16 20:46:29.065	2026-04-16 20:46:29.065
cmo1y97ma03j7vxt0rnzbq1hf	cmo1y97kd03ipvxt0l744jbjp	cmo1xc11n000kvxp0g32oj3wx	90000	2026-04-16 20:46:29.075	2026-04-16 20:46:29.075
cmo1y97mi03j9vxt0ujj4u05e	cmo1y97kd03ipvxt0l744jbjp	cmo1xc10u000hvxp0dapryn3r	90000	2026-04-16 20:46:29.082	2026-04-16 20:46:29.082
cmo1y97mo03jbvxt0ebwfjolj	cmo1y97kd03ipvxt0l744jbjp	cmo1xc119000jvxp01snwxzoa	90000	2026-04-16 20:46:29.089	2026-04-16 20:46:29.089
cmo1y97n303jfvxt080rljsmk	cmo1y97mv03jdvxt0g3qmj0av	cmo1xsgrt0022vxv8sd7cckj7	90000	2026-04-16 20:46:29.103	2026-04-16 20:46:29.103
cmo1y97na03jhvxt07f2hhgr6	cmo1y97mv03jdvxt0g3qmj0av	cmo1xc11v000lvxp07r6uljko	90000	2026-04-16 20:46:29.11	2026-04-16 20:46:29.11
cmo1y97ng03jjvxt0k8yl6ezq	cmo1y97mv03jdvxt0g3qmj0av	cmo1xc12y000qvxp0uqc7d8d8	90000	2026-04-16 20:46:29.116	2026-04-16 20:46:29.116
cmo1y97nm03jlvxt013hoszgm	cmo1y97mv03jdvxt0g3qmj0av	cmo1xc13g000svxp0tbndc1wg	90000	2026-04-16 20:46:29.122	2026-04-16 20:46:29.122
cmo1y97nx03jnvxt0bvkm15ro	cmo1y97mv03jdvxt0g3qmj0av	cmo1xc12q000pvxp0kun82k4l	90000	2026-04-16 20:46:29.133	2026-04-16 20:46:29.133
cmo1y97o303jpvxt00fmg4krs	cmo1y97mv03jdvxt0g3qmj0av	cmo1xc138000rvxp0r16wi1bz	90000	2026-04-16 20:46:29.14	2026-04-16 20:46:29.14
cmo1y97ob03jrvxt0ts6odzy3	cmo1y97mv03jdvxt0g3qmj0av	cmo1xc12i000ovxp01nisgvnu	90000	2026-04-16 20:46:29.147	2026-04-16 20:46:29.147
cmo1y97oi03jtvxt0orul5xmi	cmo1y97mv03jdvxt0g3qmj0av	cmo1xc13o000tvxp0alok8jeb	80000	2026-04-16 20:46:29.155	2026-04-16 20:46:29.155
cmo1y97ot03jvvxt0ozq69vmc	cmo1y97mv03jdvxt0g3qmj0av	cmo1xc11n000kvxp0g32oj3wx	90000	2026-04-16 20:46:29.165	2026-04-16 20:46:29.165
cmo1y97oz03jxvxt029uox2h6	cmo1y97mv03jdvxt0g3qmj0av	cmo1xc10u000hvxp0dapryn3r	90000	2026-04-16 20:46:29.171	2026-04-16 20:46:29.171
cmo1y97p603jzvxt0i0mvqwm5	cmo1y97mv03jdvxt0g3qmj0av	cmo1xc119000jvxp01snwxzoa	90000	2026-04-16 20:46:29.179	2026-04-16 20:46:29.179
cmo1y97qc03k5vxt0rssoxuc0	cmo1y97q403k3vxt0jz3hdirb	cmo1xsgrt0022vxv8sd7cckj7	90000	2026-04-16 20:46:29.221	2026-04-16 20:46:29.221
cmo1y97qk03k7vxt0jlpb81vl	cmo1y97q403k3vxt0jz3hdirb	cmo1xc11v000lvxp07r6uljko	90000	2026-04-16 20:46:29.228	2026-04-16 20:46:29.228
cmo1y97qq03k9vxt0ptfxftyf	cmo1y97q403k3vxt0jz3hdirb	cmo1xc12y000qvxp0uqc7d8d8	90000	2026-04-16 20:46:29.234	2026-04-16 20:46:29.234
cmo1y97qy03kbvxt0l1a8mxe8	cmo1y97q403k3vxt0jz3hdirb	cmo1xc13g000svxp0tbndc1wg	90000	2026-04-16 20:46:29.242	2026-04-16 20:46:29.242
cmo1y97r603kdvxt0xkw79e41	cmo1y97q403k3vxt0jz3hdirb	cmo1xc12q000pvxp0kun82k4l	90000	2026-04-16 20:46:29.251	2026-04-16 20:46:29.251
cmo1y97re03kfvxt0qoyyb3q6	cmo1y97q403k3vxt0jz3hdirb	cmo1xc138000rvxp0r16wi1bz	90000	2026-04-16 20:46:29.258	2026-04-16 20:46:29.258
cmo1y97rl03khvxt0p697e36c	cmo1y97q403k3vxt0jz3hdirb	cmo1xc12i000ovxp01nisgvnu	90000	2026-04-16 20:46:29.265	2026-04-16 20:46:29.265
cmo1y97rr03kjvxt06mglq1d4	cmo1y97q403k3vxt0jz3hdirb	cmo1xc13o000tvxp0alok8jeb	80000	2026-04-16 20:46:29.271	2026-04-16 20:46:29.271
cmo1y97ry03klvxt0qmnu6wkd	cmo1y97q403k3vxt0jz3hdirb	cmo1xc11n000kvxp0g32oj3wx	90000	2026-04-16 20:46:29.278	2026-04-16 20:46:29.278
cmo1y97s403knvxt0n7o261vm	cmo1y97q403k3vxt0jz3hdirb	cmo1xc10u000hvxp0dapryn3r	90000	2026-04-16 20:46:29.285	2026-04-16 20:46:29.285
cmo1y97sc03kpvxt0mryuy5a5	cmo1y97q403k3vxt0jz3hdirb	cmo1xc119000jvxp01snwxzoa	90000	2026-04-16 20:46:29.292	2026-04-16 20:46:29.292
cmo1y97sp03ktvxt0svm5n36c	cmo1y97sj03krvxt0i9en0yth	cmo1xsgrt0022vxv8sd7cckj7	90000	2026-04-16 20:46:29.306	2026-04-16 20:46:29.306
cmo1y97sz03kvvxt0mcbm5sxo	cmo1y97sj03krvxt0i9en0yth	cmo1xc11v000lvxp07r6uljko	90000	2026-04-16 20:46:29.315	2026-04-16 20:46:29.315
cmo1y97t503kxvxt0mooo1529	cmo1y97sj03krvxt0i9en0yth	cmo1xc12y000qvxp0uqc7d8d8	90000	2026-04-16 20:46:29.321	2026-04-16 20:46:29.321
cmo1y97tc03kzvxt0bwwcpffr	cmo1y97sj03krvxt0i9en0yth	cmo1xc13g000svxp0tbndc1wg	90000	2026-04-16 20:46:29.329	2026-04-16 20:46:29.329
cmo1y97tm03l1vxt0vi2itm9j	cmo1y97sj03krvxt0i9en0yth	cmo1xc12q000pvxp0kun82k4l	90000	2026-04-16 20:46:29.338	2026-04-16 20:46:29.338
cmo1y97tu03l3vxt0tc3ml15q	cmo1y97sj03krvxt0i9en0yth	cmo1xc138000rvxp0r16wi1bz	90000	2026-04-16 20:46:29.346	2026-04-16 20:46:29.346
cmo1y97u203l5vxt0v7sf8mjt	cmo1y97sj03krvxt0i9en0yth	cmo1xc12i000ovxp01nisgvnu	90000	2026-04-16 20:46:29.354	2026-04-16 20:46:29.354
cmo1y97u903l7vxt0ehyd2xku	cmo1y97sj03krvxt0i9en0yth	cmo1xc13o000tvxp0alok8jeb	80000	2026-04-16 20:46:29.362	2026-04-16 20:46:29.362
cmo1y97ui03l9vxt0yyb5z0f5	cmo1y97sj03krvxt0i9en0yth	cmo1xc11n000kvxp0g32oj3wx	90000	2026-04-16 20:46:29.37	2026-04-16 20:46:29.37
cmo1y97up03lbvxt0q4zmrteg	cmo1y97sj03krvxt0i9en0yth	cmo1xc10u000hvxp0dapryn3r	90000	2026-04-16 20:46:29.378	2026-04-16 20:46:29.378
cmo1y97uw03ldvxt0ae74is7j	cmo1y97sj03krvxt0i9en0yth	cmo1xc119000jvxp01snwxzoa	90000	2026-04-16 20:46:29.385	2026-04-16 20:46:29.385
cmo1y97va03lhvxt0les5qaft	cmo1y97v303lfvxt0ssijpkeu	cmo1xsgrt0022vxv8sd7cckj7	90000	2026-04-16 20:46:29.399	2026-04-16 20:46:29.399
cmo1y97vh03ljvxt007jm8uhw	cmo1y97v303lfvxt0ssijpkeu	cmo1xc11v000lvxp07r6uljko	90000	2026-04-16 20:46:29.405	2026-04-16 20:46:29.405
cmo1y97vq03llvxt0ijjekas7	cmo1y97v303lfvxt0ssijpkeu	cmo1xc12y000qvxp0uqc7d8d8	90000	2026-04-16 20:46:29.414	2026-04-16 20:46:29.414
cmo1y97vx03lnvxt05bkxbnmu	cmo1y97v303lfvxt0ssijpkeu	cmo1xc13g000svxp0tbndc1wg	90000	2026-04-16 20:46:29.421	2026-04-16 20:46:29.421
cmo1y97w603lpvxt0t50rwb2s	cmo1y97v303lfvxt0ssijpkeu	cmo1xc12q000pvxp0kun82k4l	90000	2026-04-16 20:46:29.43	2026-04-16 20:46:29.43
cmo1y97wd03lrvxt05qqehu68	cmo1y97v303lfvxt0ssijpkeu	cmo1xc138000rvxp0r16wi1bz	90000	2026-04-16 20:46:29.438	2026-04-16 20:46:29.438
cmo1y97wl03ltvxt0qskhy8f2	cmo1y97v303lfvxt0ssijpkeu	cmo1xc12i000ovxp01nisgvnu	90000	2026-04-16 20:46:29.445	2026-04-16 20:46:29.445
cmo1y97wt03lvvxt0r0fcepet	cmo1y97v303lfvxt0ssijpkeu	cmo1xc13o000tvxp0alok8jeb	80000	2026-04-16 20:46:29.453	2026-04-16 20:46:29.453
cmo1y97x203lxvxt0z9xivrwf	cmo1y97v303lfvxt0ssijpkeu	cmo1xc11n000kvxp0g32oj3wx	90000	2026-04-16 20:46:29.462	2026-04-16 20:46:29.462
cmo1y97x903lzvxt0cgvjlb7y	cmo1y97v303lfvxt0ssijpkeu	cmo1xc10u000hvxp0dapryn3r	90000	2026-04-16 20:46:29.47	2026-04-16 20:46:29.47
cmo1y97xh03m1vxt0a7bmvj8g	cmo1y97v303lfvxt0ssijpkeu	cmo1xc119000jvxp01snwxzoa	90000	2026-04-16 20:46:29.477	2026-04-16 20:46:29.477
cmo1y97xv03m5vxt068vt1sr7	cmo1y97xn03m3vxt05wvb8dao	cmo1xsgrt0022vxv8sd7cckj7	55000	2026-04-16 20:46:29.491	2026-04-16 20:46:29.491
cmo1y97y303m7vxt0et5ao2ij	cmo1y97xn03m3vxt05wvb8dao	cmo1xc11v000lvxp07r6uljko	55000	2026-04-16 20:46:29.499	2026-04-16 20:46:29.499
cmo1y97ya03m9vxt0c2tshda3	cmo1y97xn03m3vxt05wvb8dao	cmo1xc12y000qvxp0uqc7d8d8	55000	2026-04-16 20:46:29.506	2026-04-16 20:46:29.506
cmo1y97yj03mbvxt0adkb5ip9	cmo1y97xn03m3vxt05wvb8dao	cmo1xc13g000svxp0tbndc1wg	55000	2026-04-16 20:46:29.516	2026-04-16 20:46:29.516
cmo1y97yu03mdvxt0a34ege5a	cmo1y97xn03m3vxt05wvb8dao	cmo1xc12q000pvxp0kun82k4l	55000	2026-04-16 20:46:29.526	2026-04-16 20:46:29.526
cmo1y97z403mfvxt0a8kn1wdn	cmo1y97xn03m3vxt05wvb8dao	cmo1xc138000rvxp0r16wi1bz	55000	2026-04-16 20:46:29.536	2026-04-16 20:46:29.536
cmo1y97zg03mhvxt0e92n6m9l	cmo1y97xn03m3vxt05wvb8dao	cmo1xc12i000ovxp01nisgvnu	55000	2026-04-16 20:46:29.548	2026-04-16 20:46:29.548
cmo1y97zo03mjvxt0u1o9e7g2	cmo1y97xn03m3vxt05wvb8dao	cmo1xc13o000tvxp0alok8jeb	55000	2026-04-16 20:46:29.556	2026-04-16 20:46:29.556
cmo1y97zz03mlvxt02gs818yw	cmo1y97xn03m3vxt05wvb8dao	cmo1xc11n000kvxp0g32oj3wx	55000	2026-04-16 20:46:29.567	2026-04-16 20:46:29.567
cmo1y980703mnvxt0z9xhccyl	cmo1y97xn03m3vxt05wvb8dao	cmo1xc10u000hvxp0dapryn3r	55000	2026-04-16 20:46:29.575	2026-04-16 20:46:29.575
cmo1y980e03mpvxt0cj25zf10	cmo1y97xn03m3vxt05wvb8dao	cmo1xc119000jvxp01snwxzoa	55000	2026-04-16 20:46:29.583	2026-04-16 20:46:29.583
cmo1y980w03mtvxt091uy0htd	cmo1y980n03mrvxt0902dj1ys	cmo1xsgrt0022vxv8sd7cckj7	50000	2026-04-16 20:46:29.6	2026-04-16 20:46:29.6
cmo1y981303mvvxt0qnucxzms	cmo1y980n03mrvxt0902dj1ys	cmo1xc11v000lvxp07r6uljko	50000	2026-04-16 20:46:29.607	2026-04-16 20:46:29.607
cmo1y981c03mxvxt0tatjtiq2	cmo1y980n03mrvxt0902dj1ys	cmo1xc12y000qvxp0uqc7d8d8	50000	2026-04-16 20:46:29.617	2026-04-16 20:46:29.617
cmo1y981k03mzvxt0cwb6mx1w	cmo1y980n03mrvxt0902dj1ys	cmo1xc13g000svxp0tbndc1wg	50000	2026-04-16 20:46:29.624	2026-04-16 20:46:29.624
cmo1y981t03n1vxt0ufhuwux6	cmo1y980n03mrvxt0902dj1ys	cmo1xc12q000pvxp0kun82k4l	50000	2026-04-16 20:46:29.633	2026-04-16 20:46:29.633
cmo1y981z03n3vxt0pdzyz7oj	cmo1y980n03mrvxt0902dj1ys	cmo1xc138000rvxp0r16wi1bz	50000	2026-04-16 20:46:29.639	2026-04-16 20:46:29.639
cmo1y982603n5vxt0gv6actre	cmo1y980n03mrvxt0902dj1ys	cmo1xc12i000ovxp01nisgvnu	50000	2026-04-16 20:46:29.646	2026-04-16 20:46:29.646
cmo1y982d03n7vxt0x9stx29j	cmo1y980n03mrvxt0902dj1ys	cmo1xc13o000tvxp0alok8jeb	50000	2026-04-16 20:46:29.653	2026-04-16 20:46:29.653
cmo1y982n03n9vxt0fp19yac0	cmo1y980n03mrvxt0902dj1ys	cmo1xc11n000kvxp0g32oj3wx	50000	2026-04-16 20:46:29.663	2026-04-16 20:46:29.663
cmo1y982u03nbvxt0i1r0q38e	cmo1y980n03mrvxt0902dj1ys	cmo1xc10u000hvxp0dapryn3r	50000	2026-04-16 20:46:29.67	2026-04-16 20:46:29.67
cmo1y983103ndvxt0djd7ft2c	cmo1y980n03mrvxt0902dj1ys	cmo1xc119000jvxp01snwxzoa	50000	2026-04-16 20:46:29.677	2026-04-16 20:46:29.677
cmo1y983e03nhvxt05b9gaavn	cmo1y983703nfvxt0c8llq8nx	cmo1xsgrt0022vxv8sd7cckj7	45000	2026-04-16 20:46:29.69	2026-04-16 20:46:29.69
cmo1y983m03njvxt07p7wrpiw	cmo1y983703nfvxt0c8llq8nx	cmo1xc11v000lvxp07r6uljko	45000	2026-04-16 20:46:29.698	2026-04-16 20:46:29.698
cmo1y983u03nlvxt0komg3hw4	cmo1y983703nfvxt0c8llq8nx	cmo1xc12y000qvxp0uqc7d8d8	45000	2026-04-16 20:46:29.706	2026-04-16 20:46:29.706
cmo1y984103nnvxt06n7gu5px	cmo1y983703nfvxt0c8llq8nx	cmo1xc13g000svxp0tbndc1wg	45000	2026-04-16 20:46:29.713	2026-04-16 20:46:29.713
cmo1y984c03npvxt0ex90p6jb	cmo1y983703nfvxt0c8llq8nx	cmo1xc12q000pvxp0kun82k4l	45000	2026-04-16 20:46:29.725	2026-04-16 20:46:29.725
cmo1y984k03nrvxt09wzrv5bv	cmo1y983703nfvxt0c8llq8nx	cmo1xc138000rvxp0r16wi1bz	45000	2026-04-16 20:46:29.733	2026-04-16 20:46:29.733
cmo1y984s03ntvxt0o7k3nvbm	cmo1y983703nfvxt0c8llq8nx	cmo1xc12i000ovxp01nisgvnu	45000	2026-04-16 20:46:29.74	2026-04-16 20:46:29.74
cmo1y985103nvvxt01x8mxy7w	cmo1y983703nfvxt0c8llq8nx	cmo1xc13o000tvxp0alok8jeb	45000	2026-04-16 20:46:29.75	2026-04-16 20:46:29.75
cmo1y985c03nxvxt038k5zfoo	cmo1y983703nfvxt0c8llq8nx	cmo1xc11n000kvxp0g32oj3wx	45000	2026-04-16 20:46:29.76	2026-04-16 20:46:29.76
cmo1y985p03nzvxt037tj6fuu	cmo1y983703nfvxt0c8llq8nx	cmo1xc10u000hvxp0dapryn3r	45000	2026-04-16 20:46:29.773	2026-04-16 20:46:29.773
cmo1y985y03o1vxt0xjh0o9bu	cmo1y983703nfvxt0c8llq8nx	cmo1xc119000jvxp01snwxzoa	45000	2026-04-16 20:46:29.782	2026-04-16 20:46:29.782
cmo1y986g03o5vxt0d3b1055n	cmo1y986703o3vxt084le3qqe	cmo1xsgrt0022vxv8sd7cckj7	100000	2026-04-16 20:46:29.8	2026-04-16 20:46:29.8
cmo1y986o03o7vxt0cjj5hq1x	cmo1y986703o3vxt084le3qqe	cmo1xc11v000lvxp07r6uljko	100000	2026-04-16 20:46:29.808	2026-04-16 20:46:29.808
cmo1y986w03o9vxt0tngtu0bf	cmo1y986703o3vxt084le3qqe	cmo1xc12y000qvxp0uqc7d8d8	100000	2026-04-16 20:46:29.816	2026-04-16 20:46:29.816
cmo1y987303obvxt0c3hm6785	cmo1y986703o3vxt084le3qqe	cmo1xc13g000svxp0tbndc1wg	100000	2026-04-16 20:46:29.823	2026-04-16 20:46:29.823
cmo1y987d03odvxt06xoi5atq	cmo1y986703o3vxt084le3qqe	cmo1xc12q000pvxp0kun82k4l	100000	2026-04-16 20:46:29.833	2026-04-16 20:46:29.833
cmo1y987k03ofvxt0coiudx5m	cmo1y986703o3vxt084le3qqe	cmo1xc138000rvxp0r16wi1bz	100000	2026-04-16 20:46:29.841	2026-04-16 20:46:29.841
cmo1y987s03ohvxt0r4bm0w4o	cmo1y986703o3vxt084le3qqe	cmo1xc12i000ovxp01nisgvnu	100000	2026-04-16 20:46:29.848	2026-04-16 20:46:29.848
cmo1y987z03ojvxt053s6ujef	cmo1y986703o3vxt084le3qqe	cmo1xc13o000tvxp0alok8jeb	100000	2026-04-16 20:46:29.855	2026-04-16 20:46:29.855
cmo1y988703olvxt0mktz5fsr	cmo1y986703o3vxt084le3qqe	cmo1xc11n000kvxp0g32oj3wx	100000	2026-04-16 20:46:29.864	2026-04-16 20:46:29.864
cmo1y989103onvxt038161dyd	cmo1y986703o3vxt084le3qqe	cmo1xc10u000hvxp0dapryn3r	100000	2026-04-16 20:46:29.894	2026-04-16 20:46:29.894
cmo1y98aq03opvxt0fwom2zrj	cmo1y986703o3vxt084le3qqe	cmo1xc119000jvxp01snwxzoa	100000	2026-04-16 20:46:29.954	2026-04-16 20:46:29.954
cmo1y98ch03otvxt03wymsrl8	cmo1y98c503orvxt0fgcse4l9	cmo1xsgrt0022vxv8sd7cckj7	90000	2026-04-16 20:46:30.017	2026-04-16 20:46:30.017
cmo1y98cp03ovvxt01m26chfg	cmo1y98c503orvxt0fgcse4l9	cmo1xc11v000lvxp07r6uljko	90000	2026-04-16 20:46:30.026	2026-04-16 20:46:30.026
cmo1y98cx03oxvxt0xh0agc1i	cmo1y98c503orvxt0fgcse4l9	cmo1xc12y000qvxp0uqc7d8d8	90000	2026-04-16 20:46:30.033	2026-04-16 20:46:30.033
cmo1y98ec03ozvxt0k2ox2rih	cmo1y98c503orvxt0fgcse4l9	cmo1xc13g000svxp0tbndc1wg	90000	2026-04-16 20:46:30.084	2026-04-16 20:46:30.084
cmo1y98em03p1vxt0qunypeba	cmo1y98c503orvxt0fgcse4l9	cmo1xc12q000pvxp0kun82k4l	90000	2026-04-16 20:46:30.095	2026-04-16 20:46:30.095
cmo1y98ev03p3vxt03g06fjll	cmo1y98c503orvxt0fgcse4l9	cmo1xc138000rvxp0r16wi1bz	90000	2026-04-16 20:46:30.103	2026-04-16 20:46:30.103
cmo1y98f303p5vxt07g30w5eh	cmo1y98c503orvxt0fgcse4l9	cmo1xc12i000ovxp01nisgvnu	90000	2026-04-16 20:46:30.112	2026-04-16 20:46:30.112
cmo1y98fb03p7vxt0jgxe8rem	cmo1y98c503orvxt0fgcse4l9	cmo1xc13o000tvxp0alok8jeb	90000	2026-04-16 20:46:30.12	2026-04-16 20:46:30.12
cmo1y98fk03p9vxt0knilzqw4	cmo1y98c503orvxt0fgcse4l9	cmo1xc11n000kvxp0g32oj3wx	90000	2026-04-16 20:46:30.128	2026-04-16 20:46:30.128
cmo1y98fr03pbvxt011dcg05q	cmo1y98c503orvxt0fgcse4l9	cmo1xc10u000hvxp0dapryn3r	90000	2026-04-16 20:46:30.136	2026-04-16 20:46:30.136
cmo1y98fz03pdvxt0ctofgvde	cmo1y98c503orvxt0fgcse4l9	cmo1xc119000jvxp01snwxzoa	90000	2026-04-16 20:46:30.143	2026-04-16 20:46:30.143
cmo1y98ge03phvxt0uafduo1n	cmo1y98g603pfvxt053zdiahc	cmo1xsgrt0022vxv8sd7cckj7	90000	2026-04-16 20:46:30.158	2026-04-16 20:46:30.158
cmo1y98gn03pjvxt0bmupo8qz	cmo1y98g603pfvxt053zdiahc	cmo1xc11v000lvxp07r6uljko	90000	2026-04-16 20:46:30.167	2026-04-16 20:46:30.167
cmo1y98gu03plvxt0o91311jr	cmo1y98g603pfvxt053zdiahc	cmo1xc12y000qvxp0uqc7d8d8	90000	2026-04-16 20:46:30.175	2026-04-16 20:46:30.175
cmo1y98h203pnvxt0q12rtdwy	cmo1y98g603pfvxt053zdiahc	cmo1xc13g000svxp0tbndc1wg	90000	2026-04-16 20:46:30.183	2026-04-16 20:46:30.183
cmo1y98hd03ppvxt0hvef5eyu	cmo1y98g603pfvxt053zdiahc	cmo1xc12q000pvxp0kun82k4l	90000	2026-04-16 20:46:30.193	2026-04-16 20:46:30.193
cmo1y98hj03prvxt0tsmzu7il	cmo1y98g603pfvxt053zdiahc	cmo1xc138000rvxp0r16wi1bz	90000	2026-04-16 20:46:30.199	2026-04-16 20:46:30.199
cmo1y98hq03ptvxt0t3fy34e0	cmo1y98g603pfvxt053zdiahc	cmo1xc12i000ovxp01nisgvnu	90000	2026-04-16 20:46:30.206	2026-04-16 20:46:30.206
cmo1y98hz03pvvxt0kf3h4ylt	cmo1y98g603pfvxt053zdiahc	cmo1xc13o000tvxp0alok8jeb	90000	2026-04-16 20:46:30.216	2026-04-16 20:46:30.216
cmo1y98ia03pxvxt0r0cgdxgj	cmo1y98g603pfvxt053zdiahc	cmo1xc11n000kvxp0g32oj3wx	90000	2026-04-16 20:46:30.226	2026-04-16 20:46:30.226
cmo1y98ih03pzvxt0bzfdrbg9	cmo1y98g603pfvxt053zdiahc	cmo1xc10u000hvxp0dapryn3r	90000	2026-04-16 20:46:30.233	2026-04-16 20:46:30.233
cmo1y98io03q1vxt0g3j5rwrl	cmo1y98g603pfvxt053zdiahc	cmo1xc119000jvxp01snwxzoa	90000	2026-04-16 20:46:30.241	2026-04-16 20:46:30.241
cmo1y98j403q5vxt0rcpxedxw	cmo1y98ix03q3vxt0qsnmdmf2	cmo1xsgrt0022vxv8sd7cckj7	100000	2026-04-16 20:46:30.256	2026-04-16 20:46:30.256
cmo1y98jd03q7vxt0700nq80e	cmo1y98ix03q3vxt0qsnmdmf2	cmo1xc11v000lvxp07r6uljko	100000	2026-04-16 20:46:30.265	2026-04-16 20:46:30.265
cmo1y98jl03q9vxt0j48mle6c	cmo1y98ix03q3vxt0qsnmdmf2	cmo1xc12y000qvxp0uqc7d8d8	100000	2026-04-16 20:46:30.273	2026-04-16 20:46:30.273
cmo1y98ju03qbvxt0zxofh1ae	cmo1y98ix03q3vxt0qsnmdmf2	cmo1xc13g000svxp0tbndc1wg	100000	2026-04-16 20:46:30.283	2026-04-16 20:46:30.283
cmo1y98k503qdvxt0uqkhkei5	cmo1y98ix03q3vxt0qsnmdmf2	cmo1xc12q000pvxp0kun82k4l	100000	2026-04-16 20:46:30.293	2026-04-16 20:46:30.293
cmo1y98kc03qfvxt0hp28jbl2	cmo1y98ix03q3vxt0qsnmdmf2	cmo1xc138000rvxp0r16wi1bz	100000	2026-04-16 20:46:30.301	2026-04-16 20:46:30.301
cmo1y98kj03qhvxt0yw8iqa4e	cmo1y98ix03q3vxt0qsnmdmf2	cmo1xc12i000ovxp01nisgvnu	100000	2026-04-16 20:46:30.307	2026-04-16 20:46:30.307
cmo1y98kr03qjvxt0uwjabw45	cmo1y98ix03q3vxt0qsnmdmf2	cmo1xc13o000tvxp0alok8jeb	100000	2026-04-16 20:46:30.316	2026-04-16 20:46:30.316
cmo1y98kz03qlvxt06ivarbit	cmo1y98ix03q3vxt0qsnmdmf2	cmo1xc11n000kvxp0g32oj3wx	100000	2026-04-16 20:46:30.324	2026-04-16 20:46:30.324
cmo1y98l703qnvxt04a5xmjhq	cmo1y98ix03q3vxt0qsnmdmf2	cmo1xc10u000hvxp0dapryn3r	100000	2026-04-16 20:46:30.331	2026-04-16 20:46:30.331
cmo1y98lf03qpvxt0bruiqleq	cmo1y98ix03q3vxt0qsnmdmf2	cmo1xc119000jvxp01snwxzoa	100000	2026-04-16 20:46:30.339	2026-04-16 20:46:30.339
cmo1y98lt03qtvxt0w9gep8en	cmo1y98ll03qrvxt0wdjbpnw4	cmo1xsgrt0022vxv8sd7cckj7	40000	2026-04-16 20:46:30.353	2026-04-16 20:46:30.353
cmo1y98m003qvvxt0ia0fe26a	cmo1y98ll03qrvxt0wdjbpnw4	cmo1xc11v000lvxp07r6uljko	40000	2026-04-16 20:46:30.36	2026-04-16 20:46:30.36
cmo1y98m603qxvxt0u6rf3q0j	cmo1y98ll03qrvxt0wdjbpnw4	cmo1xc12y000qvxp0uqc7d8d8	40000	2026-04-16 20:46:30.366	2026-04-16 20:46:30.366
cmo1y98mc03qzvxt0dd2rb0vd	cmo1y98ll03qrvxt0wdjbpnw4	cmo1xc13g000svxp0tbndc1wg	40000	2026-04-16 20:46:30.373	2026-04-16 20:46:30.373
cmo1y98mm03r1vxt0kwp267ke	cmo1y98ll03qrvxt0wdjbpnw4	cmo1xc12q000pvxp0kun82k4l	40000	2026-04-16 20:46:30.382	2026-04-16 20:46:30.382
cmo1y98mt03r3vxt0qjdc4wto	cmo1y98ll03qrvxt0wdjbpnw4	cmo1xc138000rvxp0r16wi1bz	40000	2026-04-16 20:46:30.389	2026-04-16 20:46:30.389
cmo1y98n003r5vxt04ray5f72	cmo1y98ll03qrvxt0wdjbpnw4	cmo1xc12i000ovxp01nisgvnu	40000	2026-04-16 20:46:30.396	2026-04-16 20:46:30.396
cmo1y98n703r7vxt0wal7mxy7	cmo1y98ll03qrvxt0wdjbpnw4	cmo1xc13o000tvxp0alok8jeb	40000	2026-04-16 20:46:30.403	2026-04-16 20:46:30.403
cmo1y98ne03r9vxt0v82a7qnv	cmo1y98ll03qrvxt0wdjbpnw4	cmo1xc11n000kvxp0g32oj3wx	40000	2026-04-16 20:46:30.41	2026-04-16 20:46:30.41
cmo1y98nj03rbvxt0iqe3j9vt	cmo1y98ll03qrvxt0wdjbpnw4	cmo1xc10u000hvxp0dapryn3r	40000	2026-04-16 20:46:30.416	2026-04-16 20:46:30.416
cmo1y98np03rdvxt0g7ab1t3l	cmo1y98ll03qrvxt0wdjbpnw4	cmo1xc119000jvxp01snwxzoa	40000	2026-04-16 20:46:30.422	2026-04-16 20:46:30.422
cmo1y98o103rhvxt0t6kg76rl	cmo1y98nv03rfvxt01sr6df56	cmo1xsgrt0022vxv8sd7cckj7	105000	2026-04-16 20:46:30.434	2026-04-16 20:46:30.434
cmo1y98o803rjvxt0e32k2cih	cmo1y98nv03rfvxt01sr6df56	cmo1xc11v000lvxp07r6uljko	105000	2026-04-16 20:46:30.44	2026-04-16 20:46:30.44
cmo1y98og03rlvxt0la8fhdfp	cmo1y98nv03rfvxt01sr6df56	cmo1xc12y000qvxp0uqc7d8d8	105000	2026-04-16 20:46:30.448	2026-04-16 20:46:30.448
cmo1y98om03rnvxt0awdek19g	cmo1y98nv03rfvxt01sr6df56	cmo1xc13g000svxp0tbndc1wg	105000	2026-04-16 20:46:30.455	2026-04-16 20:46:30.455
cmo1y98ou03rpvxt03zvj7xcx	cmo1y98nv03rfvxt01sr6df56	cmo1xc12q000pvxp0kun82k4l	105000	2026-04-16 20:46:30.462	2026-04-16 20:46:30.462
cmo1y98p103rrvxt0tjk1u1is	cmo1y98nv03rfvxt01sr6df56	cmo1xc138000rvxp0r16wi1bz	105000	2026-04-16 20:46:30.469	2026-04-16 20:46:30.469
cmo1y98p803rtvxt0orkbqpp0	cmo1y98nv03rfvxt01sr6df56	cmo1xc12i000ovxp01nisgvnu	105000	2026-04-16 20:46:30.477	2026-04-16 20:46:30.477
cmo1y98pe03rvvxt00tnjn436	cmo1y98nv03rfvxt01sr6df56	cmo1xc13o000tvxp0alok8jeb	105000	2026-04-16 20:46:30.483	2026-04-16 20:46:30.483
cmo1y98po03rxvxt0jezt3i6v	cmo1y98nv03rfvxt01sr6df56	cmo1xc11n000kvxp0g32oj3wx	105000	2026-04-16 20:46:30.492	2026-04-16 20:46:30.492
cmo1y98pv03rzvxt0smotv3bd	cmo1y98nv03rfvxt01sr6df56	cmo1xc10u000hvxp0dapryn3r	105000	2026-04-16 20:46:30.499	2026-04-16 20:46:30.499
cmo1y98q103s1vxt0qdlssz9h	cmo1y98nv03rfvxt01sr6df56	cmo1xc119000jvxp01snwxzoa	105000	2026-04-16 20:46:30.506	2026-04-16 20:46:30.506
cmo1y98qh03s5vxt056y8vasd	cmo1y98qb03s3vxt0jvxu8t74	cmo1xsgrt0022vxv8sd7cckj7	28000	2026-04-16 20:46:30.522	2026-04-16 20:46:30.522
cmo1y98qo03s7vxt0at86hsq7	cmo1y98qb03s3vxt0jvxu8t74	cmo1xc11v000lvxp07r6uljko	28000	2026-04-16 20:46:30.529	2026-04-16 20:46:30.529
cmo1y98qw03s9vxt0ry4xulsf	cmo1y98qb03s3vxt0jvxu8t74	cmo1xc12y000qvxp0uqc7d8d8	28000	2026-04-16 20:46:30.536	2026-04-16 20:46:30.536
cmo1y98r303sbvxt0tu1qn1fd	cmo1y98qb03s3vxt0jvxu8t74	cmo1xc13g000svxp0tbndc1wg	28000	2026-04-16 20:46:30.543	2026-04-16 20:46:30.543
cmo1y98ra03sdvxt09bfsgfug	cmo1y98qb03s3vxt0jvxu8t74	cmo1xc12q000pvxp0kun82k4l	28000	2026-04-16 20:46:30.55	2026-04-16 20:46:30.55
cmo1y98rh03sfvxt0jv67vqud	cmo1y98qb03s3vxt0jvxu8t74	cmo1xc138000rvxp0r16wi1bz	28000	2026-04-16 20:46:30.557	2026-04-16 20:46:30.557
cmo1y98rp03shvxt067tnec66	cmo1y98qb03s3vxt0jvxu8t74	cmo1xc12i000ovxp01nisgvnu	28000	2026-04-16 20:46:30.565	2026-04-16 20:46:30.565
cmo1y98rw03sjvxt0i5uj9z0j	cmo1y98qb03s3vxt0jvxu8t74	cmo1xc13o000tvxp0alok8jeb	28000	2026-04-16 20:46:30.572	2026-04-16 20:46:30.572
cmo1y98s703slvxt06dc5rd0h	cmo1y98qb03s3vxt0jvxu8t74	cmo1xc11n000kvxp0g32oj3wx	28000	2026-04-16 20:46:30.583	2026-04-16 20:46:30.583
cmo1y98se03snvxt02vj9gy4q	cmo1y98qb03s3vxt0jvxu8t74	cmo1xc10u000hvxp0dapryn3r	28000	2026-04-16 20:46:30.59	2026-04-16 20:46:30.59
cmo1y98sm03spvxt0g5w8l754	cmo1y98qb03s3vxt0jvxu8t74	cmo1xc119000jvxp01snwxzoa	28000	2026-04-16 20:46:30.598	2026-04-16 20:46:30.598
cmo1y98t403stvxt0tgcnxnho	cmo1y98st03srvxt0yza6an53	cmo1xc11v000lvxp07r6uljko	800000	2026-04-16 20:46:30.616	2026-04-16 20:46:30.616
cmo1y98tw03svvxt05jdf067p	cmo1y98st03srvxt0yza6an53	cmo1xc10u000hvxp0dapryn3r	800000	2026-04-16 20:46:30.644	2026-04-16 20:46:30.644
cmo1y98uc03szvxt0katak9c4	cmo1y98u403sxvxt0md56h59q	cmo1xsgrt0022vxv8sd7cckj7	450000	2026-04-16 20:46:30.661	2026-04-16 20:46:30.661
cmo1y98ul03t1vxt0pr9wkwrh	cmo1y98u403sxvxt0md56h59q	cmo1xc11v000lvxp07r6uljko	450000	2026-04-16 20:46:30.669	2026-04-16 20:46:30.669
cmo1y98ur03t3vxt03z43wsd8	cmo1y98u403sxvxt0md56h59q	cmo1xc12y000qvxp0uqc7d8d8	450000	2026-04-16 20:46:30.676	2026-04-16 20:46:30.676
cmo1y98uy03t5vxt072ed1ygy	cmo1y98u403sxvxt0md56h59q	cmo1xc13g000svxp0tbndc1wg	450000	2026-04-16 20:46:30.682	2026-04-16 20:46:30.682
cmo1y98v803t7vxt0o2esjqi9	cmo1y98u403sxvxt0md56h59q	cmo1xc12q000pvxp0kun82k4l	450000	2026-04-16 20:46:30.692	2026-04-16 20:46:30.692
cmo1y98vf03t9vxt005islrc7	cmo1y98u403sxvxt0md56h59q	cmo1xc138000rvxp0r16wi1bz	450000	2026-04-16 20:46:30.699	2026-04-16 20:46:30.699
cmo1y98vm03tbvxt0cghobkcb	cmo1y98u403sxvxt0md56h59q	cmo1xc12i000ovxp01nisgvnu	450000	2026-04-16 20:46:30.706	2026-04-16 20:46:30.706
cmo1y98vv03tdvxt0lpm2m8jv	cmo1y98u403sxvxt0md56h59q	cmo1xc13o000tvxp0alok8jeb	450000	2026-04-16 20:46:30.715	2026-04-16 20:46:30.715
cmo1y98w503tfvxt02bsng6vn	cmo1y98u403sxvxt0md56h59q	cmo1xc11n000kvxp0g32oj3wx	450000	2026-04-16 20:46:30.725	2026-04-16 20:46:30.725
cmo1y98wc03thvxt0sq6ffzjl	cmo1y98u403sxvxt0md56h59q	cmo1xc10u000hvxp0dapryn3r	450000	2026-04-16 20:46:30.732	2026-04-16 20:46:30.732
cmo1y98wi03tjvxt0jbtpnq00	cmo1y98u403sxvxt0md56h59q	cmo1xc119000jvxp01snwxzoa	450000	2026-04-16 20:46:30.738	2026-04-16 20:46:30.738
cmo1y98wy03tnvxt0x0b9pthj	cmo1y98wq03tlvxt01aj908px	cmo1xsgrt0022vxv8sd7cckj7	100000	2026-04-16 20:46:30.754	2026-04-16 20:46:30.754
cmo1y98x503tpvxt02zkq5f9s	cmo1y98wq03tlvxt01aj908px	cmo1xc11v000lvxp07r6uljko	100000	2026-04-16 20:46:30.761	2026-04-16 20:46:30.761
cmo1y98xb03trvxt02bmm4n1w	cmo1y98wq03tlvxt01aj908px	cmo1xc12y000qvxp0uqc7d8d8	100000	2026-04-16 20:46:30.767	2026-04-16 20:46:30.767
cmo1y98xi03ttvxt0nf7p8298	cmo1y98wq03tlvxt01aj908px	cmo1xc13g000svxp0tbndc1wg	100000	2026-04-16 20:46:30.774	2026-04-16 20:46:30.774
cmo1y98xr03tvvxt0fapuvasi	cmo1y98wq03tlvxt01aj908px	cmo1xc12q000pvxp0kun82k4l	100000	2026-04-16 20:46:30.784	2026-04-16 20:46:30.784
cmo1y98xz03txvxt0vqapqn2k	cmo1y98wq03tlvxt01aj908px	cmo1xc138000rvxp0r16wi1bz	100000	2026-04-16 20:46:30.791	2026-04-16 20:46:30.791
cmo1y98y903tzvxt096doex0k	cmo1y98wq03tlvxt01aj908px	cmo1xc12i000ovxp01nisgvnu	100000	2026-04-16 20:46:30.801	2026-04-16 20:46:30.801
cmo1y98yi03u1vxt033c3dcgg	cmo1y98wq03tlvxt01aj908px	cmo1xc13o000tvxp0alok8jeb	100000	2026-04-16 20:46:30.81	2026-04-16 20:46:30.81
cmo1y98yu03u3vxt0xvlqh2h5	cmo1y98wq03tlvxt01aj908px	cmo1xc11n000kvxp0g32oj3wx	100000	2026-04-16 20:46:30.822	2026-04-16 20:46:30.822
cmo1y98z403u5vxt0saw0491o	cmo1y98wq03tlvxt01aj908px	cmo1xc10u000hvxp0dapryn3r	100000	2026-04-16 20:46:30.832	2026-04-16 20:46:30.832
cmo1y98za03u7vxt0uh2e7ean	cmo1y98wq03tlvxt01aj908px	cmo1xc119000jvxp01snwxzoa	100000	2026-04-16 20:46:30.839	2026-04-16 20:46:30.839
cmo1y98zq03ubvxt0hyhvm0ed	cmo1y98zi03u9vxt0hbcuxpgi	cmo1xsgrt0022vxv8sd7cckj7	55000	2026-04-16 20:46:30.855	2026-04-16 20:46:30.855
cmo1y98zz03udvxt0ho6zfioa	cmo1y98zi03u9vxt0hbcuxpgi	cmo1xc11v000lvxp07r6uljko	55000	2026-04-16 20:46:30.864	2026-04-16 20:46:30.864
cmo1y990803ufvxt0l8fo2bdm	cmo1y98zi03u9vxt0hbcuxpgi	cmo1xc12y000qvxp0uqc7d8d8	55000	2026-04-16 20:46:30.872	2026-04-16 20:46:30.872
cmo1y990g03uhvxt0ivtm8qvu	cmo1y98zi03u9vxt0hbcuxpgi	cmo1xc13g000svxp0tbndc1wg	55000	2026-04-16 20:46:30.88	2026-04-16 20:46:30.88
cmo1y990q03ujvxt0vrxzupt4	cmo1y98zi03u9vxt0hbcuxpgi	cmo1xc12q000pvxp0kun82k4l	55000	2026-04-16 20:46:30.891	2026-04-16 20:46:30.891
cmo1y990y03ulvxt0wmksaej9	cmo1y98zi03u9vxt0hbcuxpgi	cmo1xc138000rvxp0r16wi1bz	55000	2026-04-16 20:46:30.898	2026-04-16 20:46:30.898
cmo1y991403unvxt0ilzeepg8	cmo1y98zi03u9vxt0hbcuxpgi	cmo1xc12i000ovxp01nisgvnu	55000	2026-04-16 20:46:30.905	2026-04-16 20:46:30.905
cmo1y991c03upvxt0fivejy2k	cmo1y98zi03u9vxt0hbcuxpgi	cmo1xc13o000tvxp0alok8jeb	55000	2026-04-16 20:46:30.912	2026-04-16 20:46:30.912
cmo1y991m03urvxt0j3zsdvfc	cmo1y98zi03u9vxt0hbcuxpgi	cmo1xc11n000kvxp0g32oj3wx	55000	2026-04-16 20:46:30.922	2026-04-16 20:46:30.922
cmo1y991t03utvxt0ru5j5x6m	cmo1y98zi03u9vxt0hbcuxpgi	cmo1xc10u000hvxp0dapryn3r	55000	2026-04-16 20:46:30.929	2026-04-16 20:46:30.929
cmo1y992003uvvxt0aan40i2a	cmo1y98zi03u9vxt0hbcuxpgi	cmo1xc119000jvxp01snwxzoa	55000	2026-04-16 20:46:30.936	2026-04-16 20:46:30.936
cmo1y993503v1vxt0szcqd7gs	cmo1y992x03uzvxt0kql0zrz2	cmo1xsgrt0022vxv8sd7cckj7	68000	2026-04-16 20:46:30.977	2026-04-16 20:46:30.977
cmo1y993c03v3vxt0ub868b5o	cmo1y992x03uzvxt0kql0zrz2	cmo1xc11v000lvxp07r6uljko	68000	2026-04-16 20:46:30.984	2026-04-16 20:46:30.984
cmo1y993i03v5vxt0fr7yjlvf	cmo1y992x03uzvxt0kql0zrz2	cmo1xc12y000qvxp0uqc7d8d8	68000	2026-04-16 20:46:30.991	2026-04-16 20:46:30.991
cmo1y993q03v7vxt08cd98i53	cmo1y992x03uzvxt0kql0zrz2	cmo1xc13g000svxp0tbndc1wg	68000	2026-04-16 20:46:30.998	2026-04-16 20:46:30.998
cmo1y993z03v9vxt0xptyszzh	cmo1y992x03uzvxt0kql0zrz2	cmo1xc12q000pvxp0kun82k4l	68000	2026-04-16 20:46:31.008	2026-04-16 20:46:31.008
cmo1y994703vbvxt0b3kvgt3j	cmo1y992x03uzvxt0kql0zrz2	cmo1xc138000rvxp0r16wi1bz	68000	2026-04-16 20:46:31.015	2026-04-16 20:46:31.015
cmo1y994f03vdvxt00qj6ddfk	cmo1y992x03uzvxt0kql0zrz2	cmo1xc12i000ovxp01nisgvnu	68000	2026-04-16 20:46:31.023	2026-04-16 20:46:31.023
cmo1y994o03vfvxt0atj0ovnh	cmo1y992x03uzvxt0kql0zrz2	cmo1xc13o000tvxp0alok8jeb	68000	2026-04-16 20:46:31.032	2026-04-16 20:46:31.032
cmo1y994x03vhvxt0wrmlf3sb	cmo1y992x03uzvxt0kql0zrz2	cmo1xc11n000kvxp0g32oj3wx	68000	2026-04-16 20:46:31.042	2026-04-16 20:46:31.042
cmo1y995403vjvxt0xla09q8a	cmo1y992x03uzvxt0kql0zrz2	cmo1xc10u000hvxp0dapryn3r	68000	2026-04-16 20:46:31.048	2026-04-16 20:46:31.048
cmo1y995b03vlvxt0wj4b9shk	cmo1y992x03uzvxt0kql0zrz2	cmo1xc119000jvxp01snwxzoa	68000	2026-04-16 20:46:31.055	2026-04-16 20:46:31.055
cmo1y995p03vpvxt0zjuljsq9	cmo1y995i03vnvxt05683fmp5	cmo1xsgrt0022vxv8sd7cckj7	78000	2026-04-16 20:46:31.069	2026-04-16 20:46:31.069
cmo1y995x03vrvxt03pwtxvck	cmo1y995i03vnvxt05683fmp5	cmo1xc11v000lvxp07r6uljko	78000	2026-04-16 20:46:31.077	2026-04-16 20:46:31.077
cmo1y996303vtvxt0v8nar0lz	cmo1y995i03vnvxt05683fmp5	cmo1xc12y000qvxp0uqc7d8d8	78000	2026-04-16 20:46:31.083	2026-04-16 20:46:31.083
cmo1y996c03vvvxt0me6zcbze	cmo1y995i03vnvxt05683fmp5	cmo1xc13g000svxp0tbndc1wg	78000	2026-04-16 20:46:31.092	2026-04-16 20:46:31.092
cmo1y996l03vxvxt0wo17thwc	cmo1y995i03vnvxt05683fmp5	cmo1xc12q000pvxp0kun82k4l	78000	2026-04-16 20:46:31.102	2026-04-16 20:46:31.102
cmo1y996t03vzvxt07y4ouvid	cmo1y995i03vnvxt05683fmp5	cmo1xc138000rvxp0r16wi1bz	78000	2026-04-16 20:46:31.109	2026-04-16 20:46:31.109
cmo1y997003w1vxt0syhwt054	cmo1y995i03vnvxt05683fmp5	cmo1xc12i000ovxp01nisgvnu	78000	2026-04-16 20:46:31.116	2026-04-16 20:46:31.116
cmo1y997703w3vxt05k9l2k7p	cmo1y995i03vnvxt05683fmp5	cmo1xc13o000tvxp0alok8jeb	78000	2026-04-16 20:46:31.123	2026-04-16 20:46:31.123
cmo1y997i03w5vxt0cebd5kk3	cmo1y995i03vnvxt05683fmp5	cmo1xc11n000kvxp0g32oj3wx	78000	2026-04-16 20:46:31.134	2026-04-16 20:46:31.134
cmo1y997p03w7vxt043ktcy3h	cmo1y995i03vnvxt05683fmp5	cmo1xc10u000hvxp0dapryn3r	78000	2026-04-16 20:46:31.142	2026-04-16 20:46:31.142
cmo1y997x03w9vxt0bbkhvl3a	cmo1y995i03vnvxt05683fmp5	cmo1xc119000jvxp01snwxzoa	78000	2026-04-16 20:46:31.149	2026-04-16 20:46:31.149
cmo1y998903wdvxt0cgewzce3	cmo1y998303wbvxt0p9u9a5lh	cmo1xsgrt0022vxv8sd7cckj7	108000	2026-04-16 20:46:31.162	2026-04-16 20:46:31.162
cmo1y998h03wfvxt0zyrfbeu7	cmo1y998303wbvxt0p9u9a5lh	cmo1xc11v000lvxp07r6uljko	108000	2026-04-16 20:46:31.17	2026-04-16 20:46:31.17
cmo1y998o03whvxt0ba6830wo	cmo1y998303wbvxt0p9u9a5lh	cmo1xc12y000qvxp0uqc7d8d8	108000	2026-04-16 20:46:31.176	2026-04-16 20:46:31.176
cmo1y998v03wjvxt0bxyu10gs	cmo1y998303wbvxt0p9u9a5lh	cmo1xc13g000svxp0tbndc1wg	108000	2026-04-16 20:46:31.183	2026-04-16 20:46:31.183
cmo1y999403wlvxt0sdxvswd7	cmo1y998303wbvxt0p9u9a5lh	cmo1xc12q000pvxp0kun82k4l	108000	2026-04-16 20:46:31.192	2026-04-16 20:46:31.192
cmo1y999b03wnvxt0css5ovad	cmo1y998303wbvxt0p9u9a5lh	cmo1xc138000rvxp0r16wi1bz	108000	2026-04-16 20:46:31.2	2026-04-16 20:46:31.2
cmo1y999j03wpvxt0yvqkfce4	cmo1y998303wbvxt0p9u9a5lh	cmo1xc12i000ovxp01nisgvnu	108000	2026-04-16 20:46:31.207	2026-04-16 20:46:31.207
cmo1y999r03wrvxt0pqyn9mnw	cmo1y998303wbvxt0p9u9a5lh	cmo1xc13o000tvxp0alok8jeb	108000	2026-04-16 20:46:31.216	2026-04-16 20:46:31.216
cmo1y99a303wtvxt0n4ijvh51	cmo1y998303wbvxt0p9u9a5lh	cmo1xc11n000kvxp0g32oj3wx	108000	2026-04-16 20:46:31.227	2026-04-16 20:46:31.227
cmo1y99aa03wvvxt0tyfza2uk	cmo1y998303wbvxt0p9u9a5lh	cmo1xc10u000hvxp0dapryn3r	108000	2026-04-16 20:46:31.235	2026-04-16 20:46:31.235
cmo1y99ag03wxvxt067tlqqv4	cmo1y998303wbvxt0p9u9a5lh	cmo1xc119000jvxp01snwxzoa	108000	2026-04-16 20:46:31.241	2026-04-16 20:46:31.241
cmo1y99ax03x1vxt04h6q6s65	cmo1y99ap03wzvxt02v7mgk6f	cmo1xsgrt0022vxv8sd7cckj7	98000	2026-04-16 20:46:31.257	2026-04-16 20:46:31.257
cmo1y99b603x3vxt04xz92oj5	cmo1y99ap03wzvxt02v7mgk6f	cmo1xc11v000lvxp07r6uljko	98000	2026-04-16 20:46:31.266	2026-04-16 20:46:31.266
cmo1y99be03x5vxt0vx1hjvs6	cmo1y99ap03wzvxt02v7mgk6f	cmo1xc12y000qvxp0uqc7d8d8	98000	2026-04-16 20:46:31.274	2026-04-16 20:46:31.274
cmo1y99bn03x7vxt0dmkk6prb	cmo1y99ap03wzvxt02v7mgk6f	cmo1xc13g000svxp0tbndc1wg	98000	2026-04-16 20:46:31.283	2026-04-16 20:46:31.283
cmo1y99bu03x9vxt0yzgtq5gw	cmo1y99ap03wzvxt02v7mgk6f	cmo1xc12q000pvxp0kun82k4l	98000	2026-04-16 20:46:31.29	2026-04-16 20:46:31.29
cmo1y99c603xbvxt0g4wr5xog	cmo1y99ap03wzvxt02v7mgk6f	cmo1xc138000rvxp0r16wi1bz	98000	2026-04-16 20:46:31.302	2026-04-16 20:46:31.302
cmo1y99cd03xdvxt0uzi0e3j6	cmo1y99ap03wzvxt02v7mgk6f	cmo1xc12i000ovxp01nisgvnu	98000	2026-04-16 20:46:31.309	2026-04-16 20:46:31.309
cmo1y99ck03xfvxt0fwrknval	cmo1y99ap03wzvxt02v7mgk6f	cmo1xc13o000tvxp0alok8jeb	98000	2026-04-16 20:46:31.316	2026-04-16 20:46:31.316
cmo1y99cw03xhvxt02ta8suqb	cmo1y99ap03wzvxt02v7mgk6f	cmo1xc11n000kvxp0g32oj3wx	98000	2026-04-16 20:46:31.328	2026-04-16 20:46:31.328
cmo1y99d503xjvxt09mns84p6	cmo1y99ap03wzvxt02v7mgk6f	cmo1xc10u000hvxp0dapryn3r	98000	2026-04-16 20:46:31.338	2026-04-16 20:46:31.338
cmo1y99dc03xlvxt0po3wh1a5	cmo1y99ap03wzvxt02v7mgk6f	cmo1xc119000jvxp01snwxzoa	98000	2026-04-16 20:46:31.345	2026-04-16 20:46:31.345
cmo1y99dt03xpvxt0wvqliy4r	cmo1y99dn03xnvxt04us84wpq	cmo1xsgrt0022vxv8sd7cckj7	58000	2026-04-16 20:46:31.362	2026-04-16 20:46:31.362
cmo1y99e303xrvxt0jf2z6piu	cmo1y99dn03xnvxt04us84wpq	cmo1xc11v000lvxp07r6uljko	58000	2026-04-16 20:46:31.371	2026-04-16 20:46:31.371
cmo1y99ee03xtvxt04cn4nhj2	cmo1y99dn03xnvxt04us84wpq	cmo1xc12y000qvxp0uqc7d8d8	58000	2026-04-16 20:46:31.382	2026-04-16 20:46:31.382
cmo1y99el03xvvxt09vx4dfzu	cmo1y99dn03xnvxt04us84wpq	cmo1xc13g000svxp0tbndc1wg	58000	2026-04-16 20:46:31.39	2026-04-16 20:46:31.39
cmo1y99ev03xxvxt0g914p117	cmo1y99dn03xnvxt04us84wpq	cmo1xc12q000pvxp0kun82k4l	58000	2026-04-16 20:46:31.399	2026-04-16 20:46:31.399
cmo1y99f203xzvxt01lccf7o7	cmo1y99dn03xnvxt04us84wpq	cmo1xc138000rvxp0r16wi1bz	58000	2026-04-16 20:46:31.406	2026-04-16 20:46:31.406
cmo1y99f903y1vxt0uwvelf18	cmo1y99dn03xnvxt04us84wpq	cmo1xc12i000ovxp01nisgvnu	58000	2026-04-16 20:46:31.413	2026-04-16 20:46:31.413
cmo1y99fi03y3vxt0ma55cqa2	cmo1y99dn03xnvxt04us84wpq	cmo1xc13o000tvxp0alok8jeb	58000	2026-04-16 20:46:31.422	2026-04-16 20:46:31.422
cmo1y99fv03y5vxt0ayrpa5h3	cmo1y99dn03xnvxt04us84wpq	cmo1xc11n000kvxp0g32oj3wx	58000	2026-04-16 20:46:31.436	2026-04-16 20:46:31.436
cmo1y99g103y7vxt0m4jo12e2	cmo1y99dn03xnvxt04us84wpq	cmo1xc10u000hvxp0dapryn3r	58000	2026-04-16 20:46:31.442	2026-04-16 20:46:31.442
cmo1y99g903y9vxt0u511tyhi	cmo1y99dn03xnvxt04us84wpq	cmo1xc119000jvxp01snwxzoa	58000	2026-04-16 20:46:31.449	2026-04-16 20:46:31.449
cmo1y99gq03ydvxt0jd7lh7oq	cmo1y99gh03ybvxt0y6yx18nt	cmo1xsgrt0022vxv8sd7cckj7	162000	2026-04-16 20:46:31.466	2026-04-16 20:46:31.466
cmo1y99gx03yfvxt0kqkrb98b	cmo1y99gh03ybvxt0y6yx18nt	cmo1xc11v000lvxp07r6uljko	162000	2026-04-16 20:46:31.474	2026-04-16 20:46:31.474
cmo1y99h603yhvxt0z3h75x3r	cmo1y99gh03ybvxt0y6yx18nt	cmo1xc12y000qvxp0uqc7d8d8	162000	2026-04-16 20:46:31.483	2026-04-16 20:46:31.483
cmo1y99he03yjvxt0deiqak03	cmo1y99gh03ybvxt0y6yx18nt	cmo1xc13g000svxp0tbndc1wg	162000	2026-04-16 20:46:31.49	2026-04-16 20:46:31.49
cmo1y99hq03ylvxt02r6oa9on	cmo1y99gh03ybvxt0y6yx18nt	cmo1xc12q000pvxp0kun82k4l	162000	2026-04-16 20:46:31.502	2026-04-16 20:46:31.502
cmo1y99hw03ynvxt088y5i8af	cmo1y99gh03ybvxt0y6yx18nt	cmo1xc138000rvxp0r16wi1bz	162000	2026-04-16 20:46:31.508	2026-04-16 20:46:31.508
cmo1y99i303ypvxt03g6g5wn3	cmo1y99gh03ybvxt0y6yx18nt	cmo1xc12i000ovxp01nisgvnu	162000	2026-04-16 20:46:31.515	2026-04-16 20:46:31.515
cmo1y99ia03yrvxt0v3qm7cab	cmo1y99gh03ybvxt0y6yx18nt	cmo1xc13o000tvxp0alok8jeb	162000	2026-04-16 20:46:31.522	2026-04-16 20:46:31.522
cmo1y99ih03ytvxt0fuwpmhwo	cmo1y99gh03ybvxt0y6yx18nt	cmo1xc11n000kvxp0g32oj3wx	162000	2026-04-16 20:46:31.529	2026-04-16 20:46:31.529
cmo1y99io03yvvxt0vuw73sjc	cmo1y99gh03ybvxt0y6yx18nt	cmo1xc10u000hvxp0dapryn3r	162000	2026-04-16 20:46:31.536	2026-04-16 20:46:31.536
cmo1y99iu03yxvxt0osiwdtsg	cmo1y99gh03ybvxt0y6yx18nt	cmo1xc119000jvxp01snwxzoa	162000	2026-04-16 20:46:31.543	2026-04-16 20:46:31.543
cmo1y99j703z1vxt05gjjeci3	cmo1y99j103yzvxt06a8drz37	cmo1xsgrt0022vxv8sd7cckj7	170000	2026-04-16 20:46:31.555	2026-04-16 20:46:31.555
cmo1y99jf03z3vxt0o123s1w2	cmo1y99j103yzvxt06a8drz37	cmo1xc11v000lvxp07r6uljko	170000	2026-04-16 20:46:31.563	2026-04-16 20:46:31.563
cmo1y99jn03z5vxt09tnthnd3	cmo1y99j103yzvxt06a8drz37	cmo1xc12y000qvxp0uqc7d8d8	170000	2026-04-16 20:46:31.571	2026-04-16 20:46:31.571
cmo1y99jt03z7vxt0927bv7th	cmo1y99j103yzvxt06a8drz37	cmo1xc13g000svxp0tbndc1wg	170000	2026-04-16 20:46:31.577	2026-04-16 20:46:31.577
cmo1y99k003z9vxt0j9rzfqcl	cmo1y99j103yzvxt06a8drz37	cmo1xc12q000pvxp0kun82k4l	170000	2026-04-16 20:46:31.584	2026-04-16 20:46:31.584
cmo1y99k603zbvxt0rnk07rxc	cmo1y99j103yzvxt06a8drz37	cmo1xc138000rvxp0r16wi1bz	170000	2026-04-16 20:46:31.591	2026-04-16 20:46:31.591
cmo1y99ke03zdvxt0w9nfi8nq	cmo1y99j103yzvxt06a8drz37	cmo1xc12i000ovxp01nisgvnu	170000	2026-04-16 20:46:31.598	2026-04-16 20:46:31.598
cmo1y99kl03zfvxt0l4tac1jk	cmo1y99j103yzvxt06a8drz37	cmo1xc13o000tvxp0alok8jeb	170000	2026-04-16 20:46:31.605	2026-04-16 20:46:31.605
cmo1y99ky03zhvxt0ansbkhnq	cmo1y99j103yzvxt06a8drz37	cmo1xc11n000kvxp0g32oj3wx	170000	2026-04-16 20:46:31.618	2026-04-16 20:46:31.618
cmo1y99l503zjvxt0pveldetj	cmo1y99j103yzvxt06a8drz37	cmo1xc10u000hvxp0dapryn3r	170000	2026-04-16 20:46:31.626	2026-04-16 20:46:31.626
cmo1y99ld03zlvxt028lgz55f	cmo1y99j103yzvxt06a8drz37	cmo1xc119000jvxp01snwxzoa	170000	2026-04-16 20:46:31.633	2026-04-16 20:46:31.633
cmo1y99lu03zpvxt03saim7ro	cmo1y99ll03znvxt0uw512c25	cmo1xsgrt0022vxv8sd7cckj7	45000	2026-04-16 20:46:31.651	2026-04-16 20:46:31.651
cmo1y99m403zrvxt0zju9q8y3	cmo1y99ll03znvxt0uw512c25	cmo1xc11v000lvxp07r6uljko	45000	2026-04-16 20:46:31.66	2026-04-16 20:46:31.66
cmo1y99mc03ztvxt0br1wb8t6	cmo1y99ll03znvxt0uw512c25	cmo1xc12y000qvxp0uqc7d8d8	45000	2026-04-16 20:46:31.669	2026-04-16 20:46:31.669
cmo1y99mj03zvvxt0tlgk112r	cmo1y99ll03znvxt0uw512c25	cmo1xc13g000svxp0tbndc1wg	45000	2026-04-16 20:46:31.676	2026-04-16 20:46:31.676
cmo1y99mt03zxvxt083ezy71z	cmo1y99ll03znvxt0uw512c25	cmo1xc12q000pvxp0kun82k4l	45000	2026-04-16 20:46:31.685	2026-04-16 20:46:31.685
cmo1y99my03zzvxt0vceizgai	cmo1y99ll03znvxt0uw512c25	cmo1xc138000rvxp0r16wi1bz	45000	2026-04-16 20:46:31.691	2026-04-16 20:46:31.691
cmo1y99n60401vxt0a46y0gt9	cmo1y99ll03znvxt0uw512c25	cmo1xc12i000ovxp01nisgvnu	45000	2026-04-16 20:46:31.698	2026-04-16 20:46:31.698
cmo1y99nd0403vxt0ocp8ojzz	cmo1y99ll03znvxt0uw512c25	cmo1xc13o000tvxp0alok8jeb	45000	2026-04-16 20:46:31.706	2026-04-16 20:46:31.706
cmo1y99np0405vxt0lokngz7a	cmo1y99ll03znvxt0uw512c25	cmo1xc11n000kvxp0g32oj3wx	45000	2026-04-16 20:46:31.717	2026-04-16 20:46:31.717
cmo1y99ny0407vxt0h035ficw	cmo1y99ll03znvxt0uw512c25	cmo1xc10u000hvxp0dapryn3r	45000	2026-04-16 20:46:31.726	2026-04-16 20:46:31.726
cmo1y99o40409vxt0iwi7c5z9	cmo1y99ll03znvxt0uw512c25	cmo1xc119000jvxp01snwxzoa	45000	2026-04-16 20:46:31.733	2026-04-16 20:46:31.733
cmo1y99oj040dvxt0v0sjg48g	cmo1y99ob040bvxt0m19qlevy	cmo1xsgrt0022vxv8sd7cckj7	105000	2026-04-16 20:46:31.748	2026-04-16 20:46:31.748
cmo1y99oq040fvxt056g6frr5	cmo1y99ob040bvxt0m19qlevy	cmo1xc11v000lvxp07r6uljko	105000	2026-04-16 20:46:31.754	2026-04-16 20:46:31.754
cmo1y99ow040hvxt05gp7gdzr	cmo1y99ob040bvxt0m19qlevy	cmo1xc12y000qvxp0uqc7d8d8	105000	2026-04-16 20:46:31.761	2026-04-16 20:46:31.761
cmo1y99p6040jvxt08bfrsajt	cmo1y99ob040bvxt0m19qlevy	cmo1xc13g000svxp0tbndc1wg	105000	2026-04-16 20:46:31.77	2026-04-16 20:46:31.77
cmo1y99pd040lvxt0yfkj68lo	cmo1y99ob040bvxt0m19qlevy	cmo1xc12q000pvxp0kun82k4l	105000	2026-04-16 20:46:31.777	2026-04-16 20:46:31.777
cmo1y99pi040nvxt089lh91m8	cmo1y99ob040bvxt0m19qlevy	cmo1xc138000rvxp0r16wi1bz	105000	2026-04-16 20:46:31.783	2026-04-16 20:46:31.783
cmo1y99pp040pvxt0xmipai38	cmo1y99ob040bvxt0m19qlevy	cmo1xc12i000ovxp01nisgvnu	96800	2026-04-16 20:46:31.789	2026-04-16 20:46:31.789
cmo1y99py040rvxt0embij35r	cmo1y99ob040bvxt0m19qlevy	cmo1xc13o000tvxp0alok8jeb	105000	2026-04-16 20:46:31.798	2026-04-16 20:46:31.798
cmo1y99q7040tvxt0y0d8dqmq	cmo1y99ob040bvxt0m19qlevy	cmo1xc11n000kvxp0g32oj3wx	105000	2026-04-16 20:46:31.808	2026-04-16 20:46:31.808
cmo1y99qh040vvxt078isek4o	cmo1y99ob040bvxt0m19qlevy	cmo1xc10u000hvxp0dapryn3r	105000	2026-04-16 20:46:31.817	2026-04-16 20:46:31.817
cmo1y99qn040xvxt00t9x6aim	cmo1y99ob040bvxt0m19qlevy	cmo1xc119000jvxp01snwxzoa	105000	2026-04-16 20:46:31.824	2026-04-16 20:46:31.824
cmo1y99r30411vxt0h9dpg67v	cmo1y99qv040zvxt0hkbvqqj5	cmo1xsgrt0022vxv8sd7cckj7	28000	2026-04-16 20:46:31.839	2026-04-16 20:46:31.839
cmo1y99rc0413vxt0ohwat3ku	cmo1y99qv040zvxt0hkbvqqj5	cmo1xc11v000lvxp07r6uljko	28000	2026-04-16 20:46:31.848	2026-04-16 20:46:31.848
cmo1y99rj0415vxt0i7l1viox	cmo1y99qv040zvxt0hkbvqqj5	cmo1xc12y000qvxp0uqc7d8d8	28000	2026-04-16 20:46:31.855	2026-04-16 20:46:31.855
cmo1y99rt0417vxt03qyg5kcn	cmo1y99qv040zvxt0hkbvqqj5	cmo1xc13g000svxp0tbndc1wg	28000	2026-04-16 20:46:31.865	2026-04-16 20:46:31.865
cmo1y99s20419vxt03r62i4n0	cmo1y99qv040zvxt0hkbvqqj5	cmo1xc12q000pvxp0kun82k4l	28000	2026-04-16 20:46:31.874	2026-04-16 20:46:31.874
cmo1y99sc041bvxt01sdx8w1d	cmo1y99qv040zvxt0hkbvqqj5	cmo1xc138000rvxp0r16wi1bz	28000	2026-04-16 20:46:31.884	2026-04-16 20:46:31.884
cmo1y99si041dvxt03toahme9	cmo1y99qv040zvxt0hkbvqqj5	cmo1xc12i000ovxp01nisgvnu	28000	2026-04-16 20:46:31.89	2026-04-16 20:46:31.89
cmo1y99sq041fvxt0rxrmvjx1	cmo1y99qv040zvxt0hkbvqqj5	cmo1xc13o000tvxp0alok8jeb	28000	2026-04-16 20:46:31.898	2026-04-16 20:46:31.898
cmo1y99t0041hvxt0odx5etc3	cmo1y99qv040zvxt0hkbvqqj5	cmo1xc11n000kvxp0g32oj3wx	28000	2026-04-16 20:46:31.909	2026-04-16 20:46:31.909
cmo1y99t8041jvxt0a9gqboma	cmo1y99qv040zvxt0hkbvqqj5	cmo1xc10u000hvxp0dapryn3r	28000	2026-04-16 20:46:31.916	2026-04-16 20:46:31.916
cmo1y99te041lvxt04bwh6mrj	cmo1y99qv040zvxt0hkbvqqj5	cmo1xc119000jvxp01snwxzoa	28000	2026-04-16 20:46:31.922	2026-04-16 20:46:31.922
cmo1y99tv041pvxt04bs837kx	cmo1y99to041nvxt0mwh78vr0	cmo1xsgrt0022vxv8sd7cckj7	187000	2026-04-16 20:46:31.94	2026-04-16 20:46:31.94
cmo1y99u6041rvxt0lm2s673n	cmo1y99to041nvxt0mwh78vr0	cmo1xc11v000lvxp07r6uljko	187000	2026-04-16 20:46:31.95	2026-04-16 20:46:31.95
cmo1y99ud041tvxt0u0zcap92	cmo1y99to041nvxt0mwh78vr0	cmo1xc12y000qvxp0uqc7d8d8	187000	2026-04-16 20:46:31.958	2026-04-16 20:46:31.958
cmo1y99ul041vvxt0uh97hp34	cmo1y99to041nvxt0mwh78vr0	cmo1xc13g000svxp0tbndc1wg	187000	2026-04-16 20:46:31.965	2026-04-16 20:46:31.965
cmo1y99uv041xvxt0h7zxc1pu	cmo1y99to041nvxt0mwh78vr0	cmo1xc12q000pvxp0kun82k4l	187000	2026-04-16 20:46:31.975	2026-04-16 20:46:31.975
cmo1y99v2041zvxt0rk6i3gdy	cmo1y99to041nvxt0mwh78vr0	cmo1xc138000rvxp0r16wi1bz	187000	2026-04-16 20:46:31.983	2026-04-16 20:46:31.983
cmo1y99v90421vxt0emqu9ijz	cmo1y99to041nvxt0mwh78vr0	cmo1xc12i000ovxp01nisgvnu	187000	2026-04-16 20:46:31.99	2026-04-16 20:46:31.99
cmo1y99vi0423vxt0rs4pwqxi	cmo1y99to041nvxt0mwh78vr0	cmo1xc13o000tvxp0alok8jeb	187000	2026-04-16 20:46:31.998	2026-04-16 20:46:31.998
cmo1y99vs0425vxt0rpx43ccy	cmo1y99to041nvxt0mwh78vr0	cmo1xc11n000kvxp0g32oj3wx	187000	2026-04-16 20:46:32.009	2026-04-16 20:46:32.009
cmo1y99w00427vxt0d10zebgl	cmo1y99to041nvxt0mwh78vr0	cmo1xc10u000hvxp0dapryn3r	187000	2026-04-16 20:46:32.017	2026-04-16 20:46:32.017
cmo1y99w80429vxt0utsufayn	cmo1y99to041nvxt0mwh78vr0	cmo1xc119000jvxp01snwxzoa	187000	2026-04-16 20:46:32.024	2026-04-16 20:46:32.024
cmo1y99wo042dvxt0rq2pu4yt	cmo1y99wg042bvxt0z4w9rnv5	cmo1xsgrt0022vxv8sd7cckj7	110000	2026-04-16 20:46:32.04	2026-04-16 20:46:32.04
cmo1y99ww042fvxt0cwud90j1	cmo1y99wg042bvxt0z4w9rnv5	cmo1xc11v000lvxp07r6uljko	110000	2026-04-16 20:46:32.048	2026-04-16 20:46:32.048
cmo1y99x3042hvxt0m3fhigmt	cmo1y99wg042bvxt0z4w9rnv5	cmo1xc12y000qvxp0uqc7d8d8	110000	2026-04-16 20:46:32.055	2026-04-16 20:46:32.055
cmo1y99xb042jvxt0y8kqohi0	cmo1y99wg042bvxt0z4w9rnv5	cmo1xc13g000svxp0tbndc1wg	110000	2026-04-16 20:46:32.062	2026-04-16 20:46:32.062
cmo1y99xm042lvxt078l6sn01	cmo1y99wg042bvxt0z4w9rnv5	cmo1xc12q000pvxp0kun82k4l	110000	2026-04-16 20:46:32.074	2026-04-16 20:46:32.074
cmo1y99xv042nvxt0l6bk52hq	cmo1y99wg042bvxt0z4w9rnv5	cmo1xc138000rvxp0r16wi1bz	110000	2026-04-16 20:46:32.084	2026-04-16 20:46:32.084
cmo1y99y2042pvxt0cozl0nnt	cmo1y99wg042bvxt0z4w9rnv5	cmo1xc12i000ovxp01nisgvnu	110000	2026-04-16 20:46:32.09	2026-04-16 20:46:32.09
cmo1y99ya042rvxt07tdsfxo5	cmo1y99wg042bvxt0z4w9rnv5	cmo1xc13o000tvxp0alok8jeb	110000	2026-04-16 20:46:32.098	2026-04-16 20:46:32.098
cmo1y99yk042tvxt0m84y74nj	cmo1y99wg042bvxt0z4w9rnv5	cmo1xc11n000kvxp0g32oj3wx	110000	2026-04-16 20:46:32.109	2026-04-16 20:46:32.109
cmo1y99ys042vvxt0mkxid8r0	cmo1y99wg042bvxt0z4w9rnv5	cmo1xc10u000hvxp0dapryn3r	110000	2026-04-16 20:46:32.116	2026-04-16 20:46:32.116
cmo1y99yy042xvxt0d78uno2h	cmo1y99wg042bvxt0z4w9rnv5	cmo1xc119000jvxp01snwxzoa	110000	2026-04-16 20:46:32.123	2026-04-16 20:46:32.123
cmo1y9a0a0433vxt0rlh2frcz	cmo1y9a010431vxt02kfcbpk2	cmo1xsgrt0022vxv8sd7cckj7	40000	2026-04-16 20:46:32.17	2026-04-16 20:46:32.17
cmo1y9a0h0435vxt001ovswu7	cmo1y9a010431vxt02kfcbpk2	cmo1xc11v000lvxp07r6uljko	40000	2026-04-16 20:46:32.178	2026-04-16 20:46:32.178
cmo1y9a0q0437vxt01rli7tpf	cmo1y9a010431vxt02kfcbpk2	cmo1xc12y000qvxp0uqc7d8d8	40000	2026-04-16 20:46:32.186	2026-04-16 20:46:32.186
cmo1y9a0x0439vxt0xbirypeo	cmo1y9a010431vxt02kfcbpk2	cmo1xc13g000svxp0tbndc1wg	40000	2026-04-16 20:46:32.193	2026-04-16 20:46:32.193
cmo1y9a15043bvxt03hheuqlz	cmo1y9a010431vxt02kfcbpk2	cmo1xc12q000pvxp0kun82k4l	40000	2026-04-16 20:46:32.202	2026-04-16 20:46:32.202
cmo1y9a1d043dvxt0ezt0fr4g	cmo1y9a010431vxt02kfcbpk2	cmo1xc138000rvxp0r16wi1bz	40000	2026-04-16 20:46:32.209	2026-04-16 20:46:32.209
cmo1y9a1l043fvxt0ggj9qf9t	cmo1y9a010431vxt02kfcbpk2	cmo1xc12i000ovxp01nisgvnu	40000	2026-04-16 20:46:32.218	2026-04-16 20:46:32.218
cmo1y9a1s043hvxt0149kzz6o	cmo1y9a010431vxt02kfcbpk2	cmo1xc13o000tvxp0alok8jeb	40000	2026-04-16 20:46:32.225	2026-04-16 20:46:32.225
cmo1y9a22043jvxt0u1jaeha6	cmo1y9a010431vxt02kfcbpk2	cmo1xc11n000kvxp0g32oj3wx	40000	2026-04-16 20:46:32.234	2026-04-16 20:46:32.234
cmo1y9a29043lvxt0b3ssm3mf	cmo1y9a010431vxt02kfcbpk2	cmo1xc10u000hvxp0dapryn3r	40000	2026-04-16 20:46:32.241	2026-04-16 20:46:32.241
cmo1y9a2h043nvxt0toc37jvk	cmo1y9a010431vxt02kfcbpk2	cmo1xc119000jvxp01snwxzoa	40000	2026-04-16 20:46:32.249	2026-04-16 20:46:32.249
cmo1y9a2x043rvxt0onzgim6y	cmo1y9a2n043pvxt0fqpmml88	cmo1xsgrt0022vxv8sd7cckj7	570000	2026-04-16 20:46:32.265	2026-04-16 20:46:32.265
cmo1y9a34043tvxt0fz3ovwlz	cmo1y9a2n043pvxt0fqpmml88	cmo1xc11v000lvxp07r6uljko	570000	2026-04-16 20:46:32.272	2026-04-16 20:46:32.272
cmo1y9a3d043vvxt0drauivqc	cmo1y9a2n043pvxt0fqpmml88	cmo1xc12y000qvxp0uqc7d8d8	570000	2026-04-16 20:46:32.281	2026-04-16 20:46:32.281
cmo1y9a3l043xvxt0m0kdhgil	cmo1y9a2n043pvxt0fqpmml88	cmo1xc13g000svxp0tbndc1wg	570000	2026-04-16 20:46:32.29	2026-04-16 20:46:32.29
cmo1y9a3y043zvxt0kl1vxjsr	cmo1y9a2n043pvxt0fqpmml88	cmo1xc12q000pvxp0kun82k4l	570000	2026-04-16 20:46:32.302	2026-04-16 20:46:32.302
cmo1y9a440441vxt0js2eqziy	cmo1y9a2n043pvxt0fqpmml88	cmo1xc138000rvxp0r16wi1bz	570000	2026-04-16 20:46:32.308	2026-04-16 20:46:32.308
cmo1y9a4b0443vxt0o16e5ymu	cmo1y9a2n043pvxt0fqpmml88	cmo1xc12i000ovxp01nisgvnu	570000	2026-04-16 20:46:32.316	2026-04-16 20:46:32.316
cmo1y9a4i0445vxt0loo7bfwy	cmo1y9a2n043pvxt0fqpmml88	cmo1xc13o000tvxp0alok8jeb	570000	2026-04-16 20:46:32.322	2026-04-16 20:46:32.322
cmo1y9a4t0447vxt0wtz07wo1	cmo1y9a2n043pvxt0fqpmml88	cmo1xc11n000kvxp0g32oj3wx	570000	2026-04-16 20:46:32.334	2026-04-16 20:46:32.334
cmo1y9a500449vxt03cyab3qk	cmo1y9a2n043pvxt0fqpmml88	cmo1xc10u000hvxp0dapryn3r	570000	2026-04-16 20:46:32.34	2026-04-16 20:46:32.34
cmo1y9a59044bvxt05nxukmrm	cmo1y9a2n043pvxt0fqpmml88	cmo1xc119000jvxp01snwxzoa	570000	2026-04-16 20:46:32.349	2026-04-16 20:46:32.349
cmo1y9a5o044fvxt0z9nlj363	cmo1y9a5g044dvxt0ledph3p8	cmo1xsgrt0022vxv8sd7cckj7	50000	2026-04-16 20:46:32.364	2026-04-16 20:46:32.364
cmo1y9a5w044hvxt0qer3ztfu	cmo1y9a5g044dvxt0ledph3p8	cmo1xc11v000lvxp07r6uljko	50000	2026-04-16 20:46:32.372	2026-04-16 20:46:32.372
cmo1y9a64044jvxt0e7135znq	cmo1y9a5g044dvxt0ledph3p8	cmo1xc12y000qvxp0uqc7d8d8	50000	2026-04-16 20:46:32.38	2026-04-16 20:46:32.38
cmo1y9a6b044lvxt0nwojndlp	cmo1y9a5g044dvxt0ledph3p8	cmo1xc13g000svxp0tbndc1wg	50000	2026-04-16 20:46:32.387	2026-04-16 20:46:32.387
cmo1y9a6m044nvxt0l7b2l3f0	cmo1y9a5g044dvxt0ledph3p8	cmo1xc12q000pvxp0kun82k4l	50000	2026-04-16 20:46:32.398	2026-04-16 20:46:32.398
cmo1y9a6u044pvxt01s9qwm0j	cmo1y9a5g044dvxt0ledph3p8	cmo1xc138000rvxp0r16wi1bz	50000	2026-04-16 20:46:32.406	2026-04-16 20:46:32.406
cmo1y9a75044rvxt062cy3n94	cmo1y9a5g044dvxt0ledph3p8	cmo1xc12i000ovxp01nisgvnu	50000	2026-04-16 20:46:32.417	2026-04-16 20:46:32.417
cmo1y9a7c044tvxt0abnvjrma	cmo1y9a5g044dvxt0ledph3p8	cmo1xc13o000tvxp0alok8jeb	50000	2026-04-16 20:46:32.424	2026-04-16 20:46:32.424
cmo1y9a7l044vvxt0wkmlf174	cmo1y9a5g044dvxt0ledph3p8	cmo1xc11n000kvxp0g32oj3wx	50000	2026-04-16 20:46:32.433	2026-04-16 20:46:32.433
cmo1y9a7s044xvxt00qlv8bny	cmo1y9a5g044dvxt0ledph3p8	cmo1xc10u000hvxp0dapryn3r	50000	2026-04-16 20:46:32.44	2026-04-16 20:46:32.44
cmo1y9a80044zvxt0rmiz7arc	cmo1y9a5g044dvxt0ledph3p8	cmo1xc119000jvxp01snwxzoa	50000	2026-04-16 20:46:32.448	2026-04-16 20:46:32.448
cmo1y9a8e0453vxt0ykh4cwg0	cmo1y9a870451vxt0dia6x5sq	cmo1xsgrt0022vxv8sd7cckj7	58000	2026-04-16 20:46:32.462	2026-04-16 20:46:32.462
cmo1y9a8n0455vxt0l82ibjey	cmo1y9a870451vxt0dia6x5sq	cmo1xc11v000lvxp07r6uljko	58000	2026-04-16 20:46:32.471	2026-04-16 20:46:32.471
cmo1y9a8u0457vxt0smy7cg8j	cmo1y9a870451vxt0dia6x5sq	cmo1xc12y000qvxp0uqc7d8d8	58000	2026-04-16 20:46:32.478	2026-04-16 20:46:32.478
cmo1y9a930459vxt0ny7ctqf2	cmo1y9a870451vxt0dia6x5sq	cmo1xc13g000svxp0tbndc1wg	58000	2026-04-16 20:46:32.488	2026-04-16 20:46:32.488
cmo1y9a9b045bvxt0944ynvut	cmo1y9a870451vxt0dia6x5sq	cmo1xc12q000pvxp0kun82k4l	58000	2026-04-16 20:46:32.495	2026-04-16 20:46:32.495
cmo1y9a9i045dvxt064xa12ke	cmo1y9a870451vxt0dia6x5sq	cmo1xc138000rvxp0r16wi1bz	58000	2026-04-16 20:46:32.502	2026-04-16 20:46:32.502
cmo1y9a9p045fvxt02e5xtad8	cmo1y9a870451vxt0dia6x5sq	cmo1xc12i000ovxp01nisgvnu	58000	2026-04-16 20:46:32.509	2026-04-16 20:46:32.509
cmo1y9a9v045hvxt0pq9e60l3	cmo1y9a870451vxt0dia6x5sq	cmo1xc13o000tvxp0alok8jeb	58000	2026-04-16 20:46:32.516	2026-04-16 20:46:32.516
cmo1y9aa5045jvxt05c69rb2d	cmo1y9a870451vxt0dia6x5sq	cmo1xc11n000kvxp0g32oj3wx	58000	2026-04-16 20:46:32.525	2026-04-16 20:46:32.525
cmo1y9aad045lvxt0ls6xxv9g	cmo1y9a870451vxt0dia6x5sq	cmo1xc10u000hvxp0dapryn3r	58000	2026-04-16 20:46:32.533	2026-04-16 20:46:32.533
cmo1y9aaj045nvxt0cgzbuuve	cmo1y9a870451vxt0dia6x5sq	cmo1xc119000jvxp01snwxzoa	58000	2026-04-16 20:46:32.54	2026-04-16 20:46:32.54
cmo1y9aay045rvxt0pt1zzzyr	cmo1y9aas045pvxt0rmhelf6h	cmo1xsgrt0022vxv8sd7cckj7	400000	2026-04-16 20:46:32.555	2026-04-16 20:46:32.555
cmo1y9ab7045tvxt04cptk05y	cmo1y9aas045pvxt0rmhelf6h	cmo1xc11v000lvxp07r6uljko	400000	2026-04-16 20:46:32.563	2026-04-16 20:46:32.563
cmo1y9abg045vvxt0mn0lmwnu	cmo1y9aas045pvxt0rmhelf6h	cmo1xc12y000qvxp0uqc7d8d8	400000	2026-04-16 20:46:32.572	2026-04-16 20:46:32.572
cmo1y9abm045xvxt03m62vlt3	cmo1y9aas045pvxt0rmhelf6h	cmo1xc13g000svxp0tbndc1wg	400000	2026-04-16 20:46:32.578	2026-04-16 20:46:32.578
cmo1y9abu045zvxt06lxyii8a	cmo1y9aas045pvxt0rmhelf6h	cmo1xc12q000pvxp0kun82k4l	400000	2026-04-16 20:46:32.587	2026-04-16 20:46:32.587
cmo1y9ac10461vxt0p9dgv3dx	cmo1y9aas045pvxt0rmhelf6h	cmo1xc138000rvxp0r16wi1bz	400000	2026-04-16 20:46:32.593	2026-04-16 20:46:32.593
cmo1y9ac70463vxt0bzg12qbw	cmo1y9aas045pvxt0rmhelf6h	cmo1xc12i000ovxp01nisgvnu	400000	2026-04-16 20:46:32.6	2026-04-16 20:46:32.6
cmo1y9ace0465vxt0efebb4tv	cmo1y9aas045pvxt0rmhelf6h	cmo1xc13o000tvxp0alok8jeb	400000	2026-04-16 20:46:32.606	2026-04-16 20:46:32.606
cmo1y9acq0467vxt06ymbla72	cmo1y9aas045pvxt0rmhelf6h	cmo1xc11n000kvxp0g32oj3wx	400000	2026-04-16 20:46:32.618	2026-04-16 20:46:32.618
cmo1y9acw0469vxt0ahdda0kr	cmo1y9aas045pvxt0rmhelf6h	cmo1xc10u000hvxp0dapryn3r	400000	2026-04-16 20:46:32.625	2026-04-16 20:46:32.625
cmo1y9ad4046bvxt05mt09rj5	cmo1y9aas045pvxt0rmhelf6h	cmo1xc119000jvxp01snwxzoa	400000	2026-04-16 20:46:32.632	2026-04-16 20:46:32.632
cmo1y9adl046fvxt0zjcnknyv	cmo1y9adc046dvxt0ee9deme9	cmo1xsgrt0022vxv8sd7cckj7	83000	2026-04-16 20:46:32.649	2026-04-16 20:46:32.649
cmo1y9ads046hvxt0x43nhzmw	cmo1y9adc046dvxt0ee9deme9	cmo1xc11v000lvxp07r6uljko	83000	2026-04-16 20:46:32.656	2026-04-16 20:46:32.656
cmo1y9ae1046jvxt077301db4	cmo1y9adc046dvxt0ee9deme9	cmo1xc12y000qvxp0uqc7d8d8	83000	2026-04-16 20:46:32.665	2026-04-16 20:46:32.665
cmo1y9ae8046lvxt0bj3kyo1b	cmo1y9adc046dvxt0ee9deme9	cmo1xc13g000svxp0tbndc1wg	83000	2026-04-16 20:46:32.672	2026-04-16 20:46:32.672
cmo1y9ael046nvxt01uugzy7j	cmo1y9adc046dvxt0ee9deme9	cmo1xc12q000pvxp0kun82k4l	83000	2026-04-16 20:46:32.685	2026-04-16 20:46:32.685
cmo1y9aer046pvxt0vn23t44l	cmo1y9adc046dvxt0ee9deme9	cmo1xc138000rvxp0r16wi1bz	83000	2026-04-16 20:46:32.691	2026-04-16 20:46:32.691
cmo1y9aey046rvxt0znt48gu9	cmo1y9adc046dvxt0ee9deme9	cmo1xc12i000ovxp01nisgvnu	83000	2026-04-16 20:46:32.698	2026-04-16 20:46:32.698
cmo1y9af5046tvxt0u5ojutct	cmo1y9adc046dvxt0ee9deme9	cmo1xc13o000tvxp0alok8jeb	83000	2026-04-16 20:46:32.706	2026-04-16 20:46:32.706
cmo1y9afh046vvxt05r8ck6d0	cmo1y9adc046dvxt0ee9deme9	cmo1xc11n000kvxp0g32oj3wx	83000	2026-04-16 20:46:32.717	2026-04-16 20:46:32.717
cmo1y9afn046xvxt0myiqv1uc	cmo1y9adc046dvxt0ee9deme9	cmo1xc10u000hvxp0dapryn3r	83000	2026-04-16 20:46:32.723	2026-04-16 20:46:32.723
cmo1y9afw046zvxt0t85ukfld	cmo1y9adc046dvxt0ee9deme9	cmo1xc119000jvxp01snwxzoa	83000	2026-04-16 20:46:32.732	2026-04-16 20:46:32.732
cmo1y9age0473vxt0wcjxwb0i	cmo1y9ag40471vxt0t4hfh1h1	cmo1xsgrt0022vxv8sd7cckj7	25000	2026-04-16 20:46:32.75	2026-04-16 20:46:32.75
cmo1y9agk0475vxt082lvc0mf	cmo1y9ag40471vxt0t4hfh1h1	cmo1xc11v000lvxp07r6uljko	25000	2026-04-16 20:46:32.756	2026-04-16 20:46:32.756
cmo1y9agq0477vxt0k75hlqnu	cmo1y9ag40471vxt0t4hfh1h1	cmo1xc12y000qvxp0uqc7d8d8	25000	2026-04-16 20:46:32.763	2026-04-16 20:46:32.763
cmo1y9agy0479vxt0r5uj0u1v	cmo1y9ag40471vxt0t4hfh1h1	cmo1xc13g000svxp0tbndc1wg	25000	2026-04-16 20:46:32.771	2026-04-16 20:46:32.771
cmo1y9ahd047bvxt0dgoat8y4	cmo1y9ag40471vxt0t4hfh1h1	cmo1xc12q000pvxp0kun82k4l	25000	2026-04-16 20:46:32.785	2026-04-16 20:46:32.785
cmo1y9ahk047dvxt0t3serg40	cmo1y9ag40471vxt0t4hfh1h1	cmo1xc138000rvxp0r16wi1bz	25000	2026-04-16 20:46:32.792	2026-04-16 20:46:32.792
cmo1y9ahr047fvxt047fon53a	cmo1y9ag40471vxt0t4hfh1h1	cmo1xc12i000ovxp01nisgvnu	25000	2026-04-16 20:46:32.799	2026-04-16 20:46:32.799
cmo1y9ahx047hvxt0p1jruk6f	cmo1y9ag40471vxt0t4hfh1h1	cmo1xc13o000tvxp0alok8jeb	25000	2026-04-16 20:46:32.806	2026-04-16 20:46:32.806
cmo1y9aia047jvxt0ixe6hcu1	cmo1y9ag40471vxt0t4hfh1h1	cmo1xc11n000kvxp0g32oj3wx	25000	2026-04-16 20:46:32.819	2026-04-16 20:46:32.819
cmo1y9aig047lvxt0dnp0elfy	cmo1y9ag40471vxt0t4hfh1h1	cmo1xc10u000hvxp0dapryn3r	25000	2026-04-16 20:46:32.825	2026-04-16 20:46:32.825
cmo1y9aio047nvxt01maafndl	cmo1y9ag40471vxt0t4hfh1h1	cmo1xc119000jvxp01snwxzoa	25000	2026-04-16 20:46:32.832	2026-04-16 20:46:32.832
cmo1y9aj4047rvxt0kwxktge8	cmo1y9aiv047pvxt0ueop4aro	cmo1xsgrt0022vxv8sd7cckj7	77000	2026-04-16 20:46:32.848	2026-04-16 20:46:32.848
cmo1y9ajb047tvxt0zw9esely	cmo1y9aiv047pvxt0ueop4aro	cmo1xc11v000lvxp07r6uljko	77000	2026-04-16 20:46:32.855	2026-04-16 20:46:32.855
cmo1y9ajl047vvxt0qjfshkql	cmo1y9aiv047pvxt0ueop4aro	cmo1xc12y000qvxp0uqc7d8d8	77000	2026-04-16 20:46:32.865	2026-04-16 20:46:32.865
cmo1y9ajs047xvxt0ohm0mnj4	cmo1y9aiv047pvxt0ueop4aro	cmo1xc13g000svxp0tbndc1wg	77000	2026-04-16 20:46:32.872	2026-04-16 20:46:32.872
cmo1y9ak4047zvxt0nmt9d5lw	cmo1y9aiv047pvxt0ueop4aro	cmo1xc12q000pvxp0kun82k4l	77000	2026-04-16 20:46:32.884	2026-04-16 20:46:32.884
cmo1y9aka0481vxt0a5rbmxf7	cmo1y9aiv047pvxt0ueop4aro	cmo1xc138000rvxp0r16wi1bz	77000	2026-04-16 20:46:32.891	2026-04-16 20:46:32.891
cmo1y9aki0483vxt0xx4d7ocs	cmo1y9aiv047pvxt0ueop4aro	cmo1xc12i000ovxp01nisgvnu	77000	2026-04-16 20:46:32.898	2026-04-16 20:46:32.898
cmo1y9akq0485vxt0uverghgr	cmo1y9aiv047pvxt0ueop4aro	cmo1xc13o000tvxp0alok8jeb	77000	2026-04-16 20:46:32.906	2026-04-16 20:46:32.906
cmo1y9al10487vxt03fm8rws2	cmo1y9aiv047pvxt0ueop4aro	cmo1xc11n000kvxp0g32oj3wx	77000	2026-04-16 20:46:32.917	2026-04-16 20:46:32.917
cmo1y9al70489vxt0jooj2d8u	cmo1y9aiv047pvxt0ueop4aro	cmo1xc10u000hvxp0dapryn3r	77000	2026-04-16 20:46:32.923	2026-04-16 20:46:32.923
cmo1y9alg048bvxt0bwexrxq6	cmo1y9aiv047pvxt0ueop4aro	cmo1xc119000jvxp01snwxzoa	77000	2026-04-16 20:46:32.932	2026-04-16 20:46:32.932
cmo1y9aly048fvxt0lc109z3u	cmo1y9alo048dvxt0rxvludr9	cmo1xsgrt0022vxv8sd7cckj7	47000	2026-04-16 20:46:32.95	2026-04-16 20:46:32.95
cmo1y9am4048hvxt0n529qk37	cmo1y9alo048dvxt0rxvludr9	cmo1xc11v000lvxp07r6uljko	47000	2026-04-16 20:46:32.957	2026-04-16 20:46:32.957
cmo1y9amd048jvxt09vuz9fvv	cmo1y9alo048dvxt0rxvludr9	cmo1xc12y000qvxp0uqc7d8d8	47000	2026-04-16 20:46:32.965	2026-04-16 20:46:32.965
cmo1y9aml048lvxt06qpedn98	cmo1y9alo048dvxt0rxvludr9	cmo1xc13g000svxp0tbndc1wg	47000	2026-04-16 20:46:32.973	2026-04-16 20:46:32.973
cmo1y9amv048nvxt0wn0bwoud	cmo1y9alo048dvxt0rxvludr9	cmo1xc12q000pvxp0kun82k4l	47000	2026-04-16 20:46:32.984	2026-04-16 20:46:32.984
cmo1y9an2048pvxt0h92vp8qe	cmo1y9alo048dvxt0rxvludr9	cmo1xc138000rvxp0r16wi1bz	47000	2026-04-16 20:46:32.99	2026-04-16 20:46:32.99
cmo1y9ana048rvxt09kwrftwz	cmo1y9alo048dvxt0rxvludr9	cmo1xc12i000ovxp01nisgvnu	47000	2026-04-16 20:46:32.999	2026-04-16 20:46:32.999
cmo1y9anh048tvxt0b3p9clbo	cmo1y9alo048dvxt0rxvludr9	cmo1xc13o000tvxp0alok8jeb	47000	2026-04-16 20:46:33.005	2026-04-16 20:46:33.005
cmo1y9ant048vvxt0rwqimgzr	cmo1y9alo048dvxt0rxvludr9	cmo1xc11n000kvxp0g32oj3wx	47000	2026-04-16 20:46:33.017	2026-04-16 20:46:33.017
cmo1y9anz048xvxt0zzkpoaan	cmo1y9alo048dvxt0rxvludr9	cmo1xc10u000hvxp0dapryn3r	47000	2026-04-16 20:46:33.024	2026-04-16 20:46:33.024
cmo1y9ao7048zvxt09e9l2ian	cmo1y9alo048dvxt0rxvludr9	cmo1xc119000jvxp01snwxzoa	47000	2026-04-16 20:46:33.031	2026-04-16 20:46:33.031
cmo1y9aoo0493vxt005ducs7n	cmo1y9aof0491vxt0ypw0o7o9	cmo1xsgrt0022vxv8sd7cckj7	480000	2026-04-16 20:46:33.048	2026-04-16 20:46:33.048
cmo1y9aow0495vxt08zmf4zg2	cmo1y9aof0491vxt0ypw0o7o9	cmo1xc11v000lvxp07r6uljko	480000	2026-04-16 20:46:33.056	2026-04-16 20:46:33.056
cmo1y9ap50497vxt0ep7fnbgi	cmo1y9aof0491vxt0ypw0o7o9	cmo1xc12y000qvxp0uqc7d8d8	480000	2026-04-16 20:46:33.065	2026-04-16 20:46:33.065
cmo1y9apc0499vxt089nczjot	cmo1y9aof0491vxt0ypw0o7o9	cmo1xc13g000svxp0tbndc1wg	480000	2026-04-16 20:46:33.073	2026-04-16 20:46:33.073
cmo1y9app049bvxt01sglkj6v	cmo1y9aof0491vxt0ypw0o7o9	cmo1xc12q000pvxp0kun82k4l	480000	2026-04-16 20:46:33.085	2026-04-16 20:46:33.085
cmo1y9apv049dvxt0z3q8wgp8	cmo1y9aof0491vxt0ypw0o7o9	cmo1xc138000rvxp0r16wi1bz	480000	2026-04-16 20:46:33.091	2026-04-16 20:46:33.091
cmo1y9aq2049fvxt08wme1oht	cmo1y9aof0491vxt0ypw0o7o9	cmo1xc12i000ovxp01nisgvnu	480000	2026-04-16 20:46:33.098	2026-04-16 20:46:33.098
cmo1y9aqa049hvxt01sgtt898	cmo1y9aof0491vxt0ypw0o7o9	cmo1xc13o000tvxp0alok8jeb	480000	2026-04-16 20:46:33.107	2026-04-16 20:46:33.107
cmo1y9aql049jvxt06po41qzi	cmo1y9aof0491vxt0ypw0o7o9	cmo1xc11n000kvxp0g32oj3wx	480000	2026-04-16 20:46:33.117	2026-04-16 20:46:33.117
cmo1y9aqs049lvxt03k80film	cmo1y9aof0491vxt0ypw0o7o9	cmo1xc10u000hvxp0dapryn3r	480000	2026-04-16 20:46:33.124	2026-04-16 20:46:33.124
cmo1y9ar0049nvxt0wur6l1p9	cmo1y9aof0491vxt0ypw0o7o9	cmo1xc119000jvxp01snwxzoa	480000	2026-04-16 20:46:33.132	2026-04-16 20:46:33.132
cmo1y9arh049rvxt0u3h533ol	cmo1y9ar7049pvxt0vr23gbcm	cmo1xsgrt0022vxv8sd7cckj7	26000	2026-04-16 20:46:33.149	2026-04-16 20:46:33.149
cmo1y9aro049tvxt0qv7suji5	cmo1y9ar7049pvxt0vr23gbcm	cmo1xc11v000lvxp07r6uljko	26000	2026-04-16 20:46:33.156	2026-04-16 20:46:33.156
cmo1y9arw049vvxt0mfv5p3tf	cmo1y9ar7049pvxt0vr23gbcm	cmo1xc12y000qvxp0uqc7d8d8	26000	2026-04-16 20:46:33.164	2026-04-16 20:46:33.164
cmo1y9as4049xvxt0u3a23hax	cmo1y9ar7049pvxt0vr23gbcm	cmo1xc13g000svxp0tbndc1wg	26000	2026-04-16 20:46:33.172	2026-04-16 20:46:33.172
cmo1y9ase049zvxt0gujjqufk	cmo1y9ar7049pvxt0vr23gbcm	cmo1xc12q000pvxp0kun82k4l	26000	2026-04-16 20:46:33.182	2026-04-16 20:46:33.182
cmo1y9asl04a1vxt0d8w6vmdx	cmo1y9ar7049pvxt0vr23gbcm	cmo1xc138000rvxp0r16wi1bz	26000	2026-04-16 20:46:33.189	2026-04-16 20:46:33.189
cmo1y9asv04a3vxt0ep15p9bf	cmo1y9ar7049pvxt0vr23gbcm	cmo1xc12i000ovxp01nisgvnu	26000	2026-04-16 20:46:33.199	2026-04-16 20:46:33.199
cmo1y9at304a5vxt0fohs51ht	cmo1y9ar7049pvxt0vr23gbcm	cmo1xc13o000tvxp0alok8jeb	26000	2026-04-16 20:46:33.207	2026-04-16 20:46:33.207
cmo1y9atg04a7vxt05rwhxq1t	cmo1y9ar7049pvxt0vr23gbcm	cmo1xc11n000kvxp0g32oj3wx	26000	2026-04-16 20:46:33.22	2026-04-16 20:46:33.22
cmo1y9atn04a9vxt0u0kkkozm	cmo1y9ar7049pvxt0vr23gbcm	cmo1xc10u000hvxp0dapryn3r	26000	2026-04-16 20:46:33.227	2026-04-16 20:46:33.227
cmo1y9atx04abvxt09p8a4xyx	cmo1y9ar7049pvxt0vr23gbcm	cmo1xc119000jvxp01snwxzoa	26000	2026-04-16 20:46:33.238	2026-04-16 20:46:33.238
cmo1y9auc04afvxt0r7m3j43g	cmo1y9au404advxt0x4qmwfel	cmo1xsgrt0022vxv8sd7cckj7	30000	2026-04-16 20:46:33.252	2026-04-16 20:46:33.252
cmo1y9auj04ahvxt0rvsyajen	cmo1y9au404advxt0x4qmwfel	cmo1xc11v000lvxp07r6uljko	30000	2026-04-16 20:46:33.259	2026-04-16 20:46:33.259
cmo1y9auq04ajvxt0ky2xweja	cmo1y9au404advxt0x4qmwfel	cmo1xc12y000qvxp0uqc7d8d8	30000	2026-04-16 20:46:33.266	2026-04-16 20:46:33.266
cmo1y9auw04alvxt0hj3ls3gs	cmo1y9au404advxt0x4qmwfel	cmo1xc13g000svxp0tbndc1wg	30000	2026-04-16 20:46:33.272	2026-04-16 20:46:33.272
cmo1y9av704anvxt0rw19scw4	cmo1y9au404advxt0x4qmwfel	cmo1xc12q000pvxp0kun82k4l	30000	2026-04-16 20:46:33.283	2026-04-16 20:46:33.283
cmo1y9ave04apvxt0dmurjm5c	cmo1y9au404advxt0x4qmwfel	cmo1xc138000rvxp0r16wi1bz	30000	2026-04-16 20:46:33.29	2026-04-16 20:46:33.29
cmo1y9avn04arvxt04q7g1pu7	cmo1y9au404advxt0x4qmwfel	cmo1xc12i000ovxp01nisgvnu	30000	2026-04-16 20:46:33.3	2026-04-16 20:46:33.3
cmo1y9avu04atvxt0q171oeo2	cmo1y9au404advxt0x4qmwfel	cmo1xc13o000tvxp0alok8jeb	30000	2026-04-16 20:46:33.306	2026-04-16 20:46:33.306
cmo1y9aw404avvxt0q5rq7rws	cmo1y9au404advxt0x4qmwfel	cmo1xc11n000kvxp0g32oj3wx	30000	2026-04-16 20:46:33.316	2026-04-16 20:46:33.316
cmo1y9awb04axvxt02ad3dpbc	cmo1y9au404advxt0x4qmwfel	cmo1xc10u000hvxp0dapryn3r	30000	2026-04-16 20:46:33.323	2026-04-16 20:46:33.323
cmo1y9awj04azvxt09hxc0xjj	cmo1y9au404advxt0x4qmwfel	cmo1xc119000jvxp01snwxzoa	30000	2026-04-16 20:46:33.331	2026-04-16 20:46:33.331
cmo1y9awy04b3vxt0mgdh6wr5	cmo1y9awq04b1vxt0u63242cb	cmo1xsgrt0022vxv8sd7cckj7	22000	2026-04-16 20:46:33.346	2026-04-16 20:46:33.346
cmo1y9ax704b5vxt0x3yxhjtm	cmo1y9awq04b1vxt0u63242cb	cmo1xc11v000lvxp07r6uljko	22000	2026-04-16 20:46:33.355	2026-04-16 20:46:33.355
cmo1y9axd04b7vxt0xdd95gfv	cmo1y9awq04b1vxt0u63242cb	cmo1xc12y000qvxp0uqc7d8d8	22000	2026-04-16 20:46:33.361	2026-04-16 20:46:33.361
cmo1y9axn04b9vxt021s2rrzb	cmo1y9awq04b1vxt0u63242cb	cmo1xc13g000svxp0tbndc1wg	22000	2026-04-16 20:46:33.371	2026-04-16 20:46:33.371
cmo1y9axw04bbvxt0d6nh6n1y	cmo1y9awq04b1vxt0u63242cb	cmo1xc12q000pvxp0kun82k4l	22000	2026-04-16 20:46:33.381	2026-04-16 20:46:33.381
cmo1y9ay404bdvxt0bb0oq664	cmo1y9awq04b1vxt0u63242cb	cmo1xc138000rvxp0r16wi1bz	22000	2026-04-16 20:46:33.389	2026-04-16 20:46:33.389
cmo1y9ayd04bfvxt0kxo3cq7r	cmo1y9awq04b1vxt0u63242cb	cmo1xc12i000ovxp01nisgvnu	22000	2026-04-16 20:46:33.398	2026-04-16 20:46:33.398
cmo1y9ayl04bhvxt0o6gsl0bj	cmo1y9awq04b1vxt0u63242cb	cmo1xc13o000tvxp0alok8jeb	22000	2026-04-16 20:46:33.405	2026-04-16 20:46:33.405
cmo1y9ayw04bjvxt0u4iqyc6v	cmo1y9awq04b1vxt0u63242cb	cmo1xc11n000kvxp0g32oj3wx	22000	2026-04-16 20:46:33.417	2026-04-16 20:46:33.417
cmo1y9az304blvxt00l6tzwyi	cmo1y9awq04b1vxt0u63242cb	cmo1xc10u000hvxp0dapryn3r	22000	2026-04-16 20:46:33.423	2026-04-16 20:46:33.423
cmo1y9azd04bnvxt0o8z8sb75	cmo1y9awq04b1vxt0u63242cb	cmo1xc119000jvxp01snwxzoa	22000	2026-04-16 20:46:33.433	2026-04-16 20:46:33.433
cmo1y9azr04brvxt0jazz7uqg	cmo1y9azk04bpvxt05x123u9x	cmo1xsgrt0022vxv8sd7cckj7	68000	2026-04-16 20:46:33.448	2026-04-16 20:46:33.448
cmo1y9azz04btvxt0wwuimjdr	cmo1y9azk04bpvxt05x123u9x	cmo1xc11v000lvxp07r6uljko	68000	2026-04-16 20:46:33.455	2026-04-16 20:46:33.455
cmo1y9b0804bvvxt0k03cjuq9	cmo1y9azk04bpvxt05x123u9x	cmo1xc12y000qvxp0uqc7d8d8	68000	2026-04-16 20:46:33.465	2026-04-16 20:46:33.465
cmo1y9b0f04bxvxt0e9qddn8z	cmo1y9azk04bpvxt05x123u9x	cmo1xc13g000svxp0tbndc1wg	68000	2026-04-16 20:46:33.471	2026-04-16 20:46:33.471
cmo1y9b0r04bzvxt0i4b0u1xv	cmo1y9azk04bpvxt05x123u9x	cmo1xc12q000pvxp0kun82k4l	68000	2026-04-16 20:46:33.484	2026-04-16 20:46:33.484
cmo1y9b0y04c1vxt0nzgvfu7f	cmo1y9azk04bpvxt05x123u9x	cmo1xc138000rvxp0r16wi1bz	68000	2026-04-16 20:46:33.49	2026-04-16 20:46:33.49
cmo1y9b1604c3vxt0zxyureji	cmo1y9azk04bpvxt05x123u9x	cmo1xc12i000ovxp01nisgvnu	68000	2026-04-16 20:46:33.499	2026-04-16 20:46:33.499
cmo1y9b1e04c5vxt0y3qisgaj	cmo1y9azk04bpvxt05x123u9x	cmo1xc13o000tvxp0alok8jeb	68000	2026-04-16 20:46:33.506	2026-04-16 20:46:33.506
cmo1y9b1p04c7vxt0vy6acl3r	cmo1y9azk04bpvxt05x123u9x	cmo1xc11n000kvxp0g32oj3wx	68000	2026-04-16 20:46:33.517	2026-04-16 20:46:33.517
cmo1y9b1v04c9vxt0six1ihn1	cmo1y9azk04bpvxt05x123u9x	cmo1xc10u000hvxp0dapryn3r	68000	2026-04-16 20:46:33.523	2026-04-16 20:46:33.523
cmo1y9b2304cbvxt0eu0x4uyi	cmo1y9azk04bpvxt05x123u9x	cmo1xc119000jvxp01snwxzoa	68000	2026-04-16 20:46:33.531	2026-04-16 20:46:33.531
cmo1y9b2l04cfvxt0op4rjuut	cmo1y9b2a04cdvxt0g0bv723l	cmo1xsgrt0022vxv8sd7cckj7	48000	2026-04-16 20:46:33.549	2026-04-16 20:46:33.549
cmo1y9b2s04chvxt0rduafk4c	cmo1y9b2a04cdvxt0g0bv723l	cmo1xc11v000lvxp07r6uljko	48000	2026-04-16 20:46:33.556	2026-04-16 20:46:33.556
cmo1y9b2x04cjvxt0sbqoz2j9	cmo1y9b2a04cdvxt0g0bv723l	cmo1xc12y000qvxp0uqc7d8d8	48000	2026-04-16 20:46:33.562	2026-04-16 20:46:33.562
cmo1y9b3504clvxt0d2wg012e	cmo1y9b2a04cdvxt0g0bv723l	cmo1xc13g000svxp0tbndc1wg	48000	2026-04-16 20:46:33.569	2026-04-16 20:46:33.569
cmo1y9b3d04cnvxt03l1cgs0x	cmo1y9b2a04cdvxt0g0bv723l	cmo1xc12q000pvxp0kun82k4l	48000	2026-04-16 20:46:33.577	2026-04-16 20:46:33.577
cmo1y9b3j04cpvxt0adcwqmkz	cmo1y9b2a04cdvxt0g0bv723l	cmo1xc138000rvxp0r16wi1bz	48000	2026-04-16 20:46:33.583	2026-04-16 20:46:33.583
cmo1y9b3q04crvxt04a7osibb	cmo1y9b2a04cdvxt0g0bv723l	cmo1xc12i000ovxp01nisgvnu	48000	2026-04-16 20:46:33.59	2026-04-16 20:46:33.59
cmo1y9b3y04ctvxt0e851059m	cmo1y9b2a04cdvxt0g0bv723l	cmo1xc13o000tvxp0alok8jeb	48000	2026-04-16 20:46:33.598	2026-04-16 20:46:33.598
cmo1y9b4704cvvxt0i3rrr5kp	cmo1y9b2a04cdvxt0g0bv723l	cmo1xc11n000kvxp0g32oj3wx	48000	2026-04-16 20:46:33.607	2026-04-16 20:46:33.607
cmo1y9b4g04cxvxt0l89l4tuu	cmo1y9b2a04cdvxt0g0bv723l	cmo1xc10u000hvxp0dapryn3r	48000	2026-04-16 20:46:33.617	2026-04-16 20:46:33.617
cmo1y9b4n04czvxt0n6efa95b	cmo1y9b2a04cdvxt0g0bv723l	cmo1xc119000jvxp01snwxzoa	48000	2026-04-16 20:46:33.623	2026-04-16 20:46:33.623
cmo1y9b5304d3vxt09dw3yvb5	cmo1y9b4v04d1vxt0z7htc1kp	cmo1xsgrt0022vxv8sd7cckj7	28000	2026-04-16 20:46:33.639	2026-04-16 20:46:33.639
cmo1y9b5d04d5vxt0hibxfhud	cmo1y9b4v04d1vxt0z7htc1kp	cmo1xc11v000lvxp07r6uljko	28000	2026-04-16 20:46:33.649	2026-04-16 20:46:33.649
cmo1y9b5k04d7vxt00qnmx2ba	cmo1y9b4v04d1vxt0z7htc1kp	cmo1xc12y000qvxp0uqc7d8d8	28000	2026-04-16 20:46:33.656	2026-04-16 20:46:33.656
cmo1y9b5t04d9vxt0g5cnmy3o	cmo1y9b4v04d1vxt0z7htc1kp	cmo1xc13g000svxp0tbndc1wg	28000	2026-04-16 20:46:33.665	2026-04-16 20:46:33.665
cmo1y9b6304dbvxt0n8862dzs	cmo1y9b4v04d1vxt0z7htc1kp	cmo1xc12q000pvxp0kun82k4l	28000	2026-04-16 20:46:33.675	2026-04-16 20:46:33.675
cmo1y9b6c04ddvxt05iod2bj8	cmo1y9b4v04d1vxt0z7htc1kp	cmo1xc138000rvxp0r16wi1bz	28000	2026-04-16 20:46:33.684	2026-04-16 20:46:33.684
cmo1y9b6i04dfvxt04gb0e8rs	cmo1y9b4v04d1vxt0z7htc1kp	cmo1xc12i000ovxp01nisgvnu	28000	2026-04-16 20:46:33.691	2026-04-16 20:46:33.691
cmo1y9b6q04dhvxt0de91n1hq	cmo1y9b4v04d1vxt0z7htc1kp	cmo1xc13o000tvxp0alok8jeb	28000	2026-04-16 20:46:33.698	2026-04-16 20:46:33.698
cmo1y9b7104djvxt0ilt0s7ju	cmo1y9b4v04d1vxt0z7htc1kp	cmo1xc11n000kvxp0g32oj3wx	28000	2026-04-16 20:46:33.71	2026-04-16 20:46:33.71
cmo1y9b7904dlvxt0fl2gvw52	cmo1y9b4v04d1vxt0z7htc1kp	cmo1xc10u000hvxp0dapryn3r	28000	2026-04-16 20:46:33.717	2026-04-16 20:46:33.717
cmo1y9b7g04dnvxt003p4xwvi	cmo1y9b4v04d1vxt0z7htc1kp	cmo1xc119000jvxp01snwxzoa	28000	2026-04-16 20:46:33.724	2026-04-16 20:46:33.724
cmo1y9b7x04drvxt06k381zoy	cmo1y9b7p04dpvxt0xpxhjhgk	cmo1xsgrt0022vxv8sd7cckj7	65000	2026-04-16 20:46:33.741	2026-04-16 20:46:33.741
cmo1y9b8504dtvxt0xpfe1qer	cmo1y9b7p04dpvxt0xpxhjhgk	cmo1xc11v000lvxp07r6uljko	65000	2026-04-16 20:46:33.749	2026-04-16 20:46:33.749
cmo1y9b8c04dvvxt0rn41bowx	cmo1y9b7p04dpvxt0xpxhjhgk	cmo1xc12y000qvxp0uqc7d8d8	65000	2026-04-16 20:46:33.757	2026-04-16 20:46:33.757
cmo1y9b8m04dxvxt01gsqaso9	cmo1y9b7p04dpvxt0xpxhjhgk	cmo1xc13g000svxp0tbndc1wg	65000	2026-04-16 20:46:33.767	2026-04-16 20:46:33.767
cmo1y9b8u04dzvxt0ilu1g2ac	cmo1y9b7p04dpvxt0xpxhjhgk	cmo1xc12q000pvxp0kun82k4l	65000	2026-04-16 20:46:33.775	2026-04-16 20:46:33.775
cmo1y9b9104e1vxt0nej8e3tu	cmo1y9b7p04dpvxt0xpxhjhgk	cmo1xc138000rvxp0r16wi1bz	65000	2026-04-16 20:46:33.781	2026-04-16 20:46:33.781
cmo1y9b9804e3vxt0dw2sf913	cmo1y9b7p04dpvxt0xpxhjhgk	cmo1xc12i000ovxp01nisgvnu	65000	2026-04-16 20:46:33.788	2026-04-16 20:46:33.788
cmo1y9b9e04e5vxt0rmqiosyq	cmo1y9b7p04dpvxt0xpxhjhgk	cmo1xc13o000tvxp0alok8jeb	65000	2026-04-16 20:46:33.795	2026-04-16 20:46:33.795
cmo1y9b9n04e7vxt085gfk61p	cmo1y9b7p04dpvxt0xpxhjhgk	cmo1xc11n000kvxp0g32oj3wx	65000	2026-04-16 20:46:33.804	2026-04-16 20:46:33.804
cmo1y9b9u04e9vxt0uxxwy3u8	cmo1y9b7p04dpvxt0xpxhjhgk	cmo1xc10u000hvxp0dapryn3r	65000	2026-04-16 20:46:33.811	2026-04-16 20:46:33.811
cmo1y9ba304ebvxt0hefylnzt	cmo1y9b7p04dpvxt0xpxhjhgk	cmo1xc119000jvxp01snwxzoa	65000	2026-04-16 20:46:33.819	2026-04-16 20:46:33.819
cmo1y9bag04efvxt0mz3z3jcf	cmo1y9ba904edvxt0w4nv2tk5	cmo1xsgrt0022vxv8sd7cckj7	74000	2026-04-16 20:46:33.832	2026-04-16 20:46:33.832
cmo1y9ban04ehvxt0hv9zdpdm	cmo1y9ba904edvxt0w4nv2tk5	cmo1xc11v000lvxp07r6uljko	74000	2026-04-16 20:46:33.839	2026-04-16 20:46:33.839
cmo1y9bat04ejvxt0tu7elgzh	cmo1y9ba904edvxt0w4nv2tk5	cmo1xc12y000qvxp0uqc7d8d8	74000	2026-04-16 20:46:33.845	2026-04-16 20:46:33.845
cmo1y9bb104elvxt0vto33xaa	cmo1y9ba904edvxt0w4nv2tk5	cmo1xc13g000svxp0tbndc1wg	74000	2026-04-16 20:46:33.853	2026-04-16 20:46:33.853
cmo1y9bb904envxt0ulkyfc7v	cmo1y9ba904edvxt0w4nv2tk5	cmo1xc12q000pvxp0kun82k4l	74000	2026-04-16 20:46:33.861	2026-04-16 20:46:33.861
cmo1y9bbg04epvxt0olcnstlg	cmo1y9ba904edvxt0w4nv2tk5	cmo1xc138000rvxp0r16wi1bz	74000	2026-04-16 20:46:33.869	2026-04-16 20:46:33.869
cmo1y9bbm04ervxt0uzde64op	cmo1y9ba904edvxt0w4nv2tk5	cmo1xc12i000ovxp01nisgvnu	74000	2026-04-16 20:46:33.875	2026-04-16 20:46:33.875
cmo1y9bbv04etvxt0ohddb0pg	cmo1y9ba904edvxt0w4nv2tk5	cmo1xc13o000tvxp0alok8jeb	74000	2026-04-16 20:46:33.883	2026-04-16 20:46:33.883
cmo1y9bc304evvxt0k82a7j60	cmo1y9ba904edvxt0w4nv2tk5	cmo1xc11n000kvxp0g32oj3wx	74000	2026-04-16 20:46:33.891	2026-04-16 20:46:33.891
cmo1y9bca04exvxt0yztqitd0	cmo1y9ba904edvxt0w4nv2tk5	cmo1xc10u000hvxp0dapryn3r	74000	2026-04-16 20:46:33.898	2026-04-16 20:46:33.898
cmo1y9bch04ezvxt0pxmf6f5w	cmo1y9ba904edvxt0w4nv2tk5	cmo1xc119000jvxp01snwxzoa	74000	2026-04-16 20:46:33.906	2026-04-16 20:46:33.906
cmo1y9bcy04f3vxt0ha1s3oys	cmo1y9bcr04f1vxt0xcoi9mnd	cmo1xsgrt0022vxv8sd7cckj7	79000	2026-04-16 20:46:33.923	2026-04-16 20:46:33.923
cmo1y9bd704f5vxt0dmak9isu	cmo1y9bcr04f1vxt0xcoi9mnd	cmo1xc11v000lvxp07r6uljko	79000	2026-04-16 20:46:33.931	2026-04-16 20:46:33.931
cmo1y9bdx04f7vxt0c1ox8f0l	cmo1y9bcr04f1vxt0xcoi9mnd	cmo1xc10u000hvxp0dapryn3r	79000	2026-04-16 20:46:33.957	2026-04-16 20:46:33.957
cmo1y9beu04fbvxt03sojcwgo	cmo1y9be904f9vxt0ijuv0tc3	cmo1xc13o000tvxp0alok8jeb	66000	2026-04-16 20:46:33.991	2026-04-16 20:46:33.991
cmo1y9bfg04ffvxt0pidgi172	cmo1y9bf904fdvxt0rqeihqjz	cmo1xsgrt0022vxv8sd7cckj7	28000	2026-04-16 20:46:34.012	2026-04-16 20:46:34.012
cmo1y9bfo04fhvxt01u1cpfeg	cmo1y9bf904fdvxt0rqeihqjz	cmo1xc11v000lvxp07r6uljko	28000	2026-04-16 20:46:34.02	2026-04-16 20:46:34.02
cmo1y9bfu04fjvxt0hgtegr0m	cmo1y9bf904fdvxt0rqeihqjz	cmo1xc12y000qvxp0uqc7d8d8	28000	2026-04-16 20:46:34.026	2026-04-16 20:46:34.026
cmo1y9bg104flvxt0609d14ta	cmo1y9bf904fdvxt0rqeihqjz	cmo1xc13g000svxp0tbndc1wg	28000	2026-04-16 20:46:34.033	2026-04-16 20:46:34.033
cmo1y9bga04fnvxt0ewll17w2	cmo1y9bf904fdvxt0rqeihqjz	cmo1xc12q000pvxp0kun82k4l	28000	2026-04-16 20:46:34.042	2026-04-16 20:46:34.042
cmo1y9bgh04fpvxt051r0t85u	cmo1y9bf904fdvxt0rqeihqjz	cmo1xc138000rvxp0r16wi1bz	28000	2026-04-16 20:46:34.05	2026-04-16 20:46:34.05
cmo1y9bgo04frvxt0wt7wimmw	cmo1y9bf904fdvxt0rqeihqjz	cmo1xc12i000ovxp01nisgvnu	28000	2026-04-16 20:46:34.056	2026-04-16 20:46:34.056
cmo1y9bgx04ftvxt0fxnytic3	cmo1y9bf904fdvxt0rqeihqjz	cmo1xc13o000tvxp0alok8jeb	28000	2026-04-16 20:46:34.065	2026-04-16 20:46:34.065
cmo1y9bh704fvvxt0hdltitp8	cmo1y9bf904fdvxt0rqeihqjz	cmo1xc11n000kvxp0g32oj3wx	28000	2026-04-16 20:46:34.075	2026-04-16 20:46:34.075
cmo1y9bhg04fxvxt0xq783xh2	cmo1y9bf904fdvxt0rqeihqjz	cmo1xc10u000hvxp0dapryn3r	28000	2026-04-16 20:46:34.084	2026-04-16 20:46:34.084
cmo1y9bhn04fzvxt07yyjx6hv	cmo1y9bf904fdvxt0rqeihqjz	cmo1xc119000jvxp01snwxzoa	28000	2026-04-16 20:46:34.091	2026-04-16 20:46:34.091
cmo1y9bi504g3vxt02qkuf9fe	cmo1y9bhu04g1vxt0dj4ey3xn	cmo1xc11v000lvxp07r6uljko	45000	2026-04-16 20:46:34.109	2026-04-16 20:46:34.109
cmo1y9bir04g5vxt0uz6zskwe	cmo1y9bhu04g1vxt0dj4ey3xn	cmo1xc10u000hvxp0dapryn3r	45000	2026-04-16 20:46:34.131	2026-04-16 20:46:34.131
cmo1y9bja04g9vxt00fgwfjqb	cmo1y9bj104g7vxt06tw8yrei	cmo1xsgrt0022vxv8sd7cckj7	126000	2026-04-16 20:46:34.15	2026-04-16 20:46:34.15
cmo1y9bjg04gbvxt0m3zwc5ij	cmo1y9bj104g7vxt06tw8yrei	cmo1xc11v000lvxp07r6uljko	126000	2026-04-16 20:46:34.157	2026-04-16 20:46:34.157
cmo1y9bjo04gdvxt0ps7fp73v	cmo1y9bj104g7vxt06tw8yrei	cmo1xc12y000qvxp0uqc7d8d8	126000	2026-04-16 20:46:34.164	2026-04-16 20:46:34.164
cmo1y9bjw04gfvxt061abqlm1	cmo1y9bj104g7vxt06tw8yrei	cmo1xc13g000svxp0tbndc1wg	126000	2026-04-16 20:46:34.172	2026-04-16 20:46:34.172
cmo1y9bk604ghvxt0lwda5ze4	cmo1y9bj104g7vxt06tw8yrei	cmo1xc12q000pvxp0kun82k4l	126000	2026-04-16 20:46:34.182	2026-04-16 20:46:34.182
cmo1y9bkc04gjvxt0bt0e008y	cmo1y9bj104g7vxt06tw8yrei	cmo1xc138000rvxp0r16wi1bz	126000	2026-04-16 20:46:34.189	2026-04-16 20:46:34.189
cmo1y9bkn04glvxt0bzs5og62	cmo1y9bj104g7vxt06tw8yrei	cmo1xc12i000ovxp01nisgvnu	126000	2026-04-16 20:46:34.199	2026-04-16 20:46:34.199
cmo1y9bkv04gnvxt0a0ruetq8	cmo1y9bj104g7vxt06tw8yrei	cmo1xc13o000tvxp0alok8jeb	126000	2026-04-16 20:46:34.207	2026-04-16 20:46:34.207
cmo1y9bl604gpvxt0246rujvu	cmo1y9bj104g7vxt06tw8yrei	cmo1xc11n000kvxp0g32oj3wx	126000	2026-04-16 20:46:34.219	2026-04-16 20:46:34.219
cmo1y9bld04grvxt0al9eywny	cmo1y9bj104g7vxt06tw8yrei	cmo1xc10u000hvxp0dapryn3r	126000	2026-04-16 20:46:34.225	2026-04-16 20:46:34.225
cmo1y9blk04gtvxt0zt0j1iyg	cmo1y9bj104g7vxt06tw8yrei	cmo1xc119000jvxp01snwxzoa	126000	2026-04-16 20:46:34.232	2026-04-16 20:46:34.232
cmo1y9bm004gxvxt0c1s3lg50	cmo1y9blr04gvvxt0f7edli18	cmo1xsgrt0022vxv8sd7cckj7	27000	2026-04-16 20:46:34.248	2026-04-16 20:46:34.248
cmo1y9bm704gzvxt0bxhsm6jc	cmo1y9blr04gvvxt0f7edli18	cmo1xc11v000lvxp07r6uljko	27000	2026-04-16 20:46:34.255	2026-04-16 20:46:34.255
cmo1y9bmd04h1vxt0tqxbvuxp	cmo1y9blr04gvvxt0f7edli18	cmo1xc12y000qvxp0uqc7d8d8	27000	2026-04-16 20:46:34.261	2026-04-16 20:46:34.261
cmo1y9bmk04h3vxt0eake1yhi	cmo1y9blr04gvvxt0f7edli18	cmo1xc13g000svxp0tbndc1wg	27000	2026-04-16 20:46:34.269	2026-04-16 20:46:34.269
cmo1y9bms04h5vxt0nms0b93z	cmo1y9blr04gvvxt0f7edli18	cmo1xc12q000pvxp0kun82k4l	27000	2026-04-16 20:46:34.277	2026-04-16 20:46:34.277
cmo1y9bn004h7vxt0godq9g2o	cmo1y9blr04gvvxt0f7edli18	cmo1xc138000rvxp0r16wi1bz	27000	2026-04-16 20:46:34.284	2026-04-16 20:46:34.284
cmo1y9bn604h9vxt0rluwf2bx	cmo1y9blr04gvvxt0f7edli18	cmo1xc12i000ovxp01nisgvnu	27000	2026-04-16 20:46:34.29	2026-04-16 20:46:34.29
cmo1y9bnd04hbvxt0xrmgztbk	cmo1y9blr04gvvxt0f7edli18	cmo1xc13o000tvxp0alok8jeb	27000	2026-04-16 20:46:34.297	2026-04-16 20:46:34.297
cmo1y9bno04hdvxt0h180xn0m	cmo1y9blr04gvvxt0f7edli18	cmo1xc11n000kvxp0g32oj3wx	27000	2026-04-16 20:46:34.308	2026-04-16 20:46:34.308
cmo1y9bnv04hfvxt0q4ethpa3	cmo1y9blr04gvvxt0f7edli18	cmo1xc10u000hvxp0dapryn3r	27000	2026-04-16 20:46:34.316	2026-04-16 20:46:34.316
cmo1y9bo104hhvxt0p4fzxku1	cmo1y9blr04gvvxt0f7edli18	cmo1xc119000jvxp01snwxzoa	27000	2026-04-16 20:46:34.322	2026-04-16 20:46:34.322
cmo1y9boh04hlvxt0758f3ue8	cmo1y9bo904hjvxt0dy5qm2wl	cmo1xsgrt0022vxv8sd7cckj7	80000	2026-04-16 20:46:34.338	2026-04-16 20:46:34.338
cmo1y9boq04hnvxt0ygxvzooj	cmo1y9bo904hjvxt0dy5qm2wl	cmo1xc11v000lvxp07r6uljko	80000	2026-04-16 20:46:34.346	2026-04-16 20:46:34.346
cmo1y9boz04hpvxt0y9niwm2s	cmo1y9bo904hjvxt0dy5qm2wl	cmo1xc12y000qvxp0uqc7d8d8	80000	2026-04-16 20:46:34.355	2026-04-16 20:46:34.355
cmo1y9bp504hrvxt01qohe76l	cmo1y9bo904hjvxt0dy5qm2wl	cmo1xc13g000svxp0tbndc1wg	80000	2026-04-16 20:46:34.361	2026-04-16 20:46:34.361
cmo1y9bpg04htvxt0c6suukyh	cmo1y9bo904hjvxt0dy5qm2wl	cmo1xc12q000pvxp0kun82k4l	80000	2026-04-16 20:46:34.372	2026-04-16 20:46:34.372
cmo1y9bpn04hvvxt021uvp8k2	cmo1y9bo904hjvxt0dy5qm2wl	cmo1xc138000rvxp0r16wi1bz	80000	2026-04-16 20:46:34.379	2026-04-16 20:46:34.379
cmo1y9bpv04hxvxt0skmer7nt	cmo1y9bo904hjvxt0dy5qm2wl	cmo1xc12i000ovxp01nisgvnu	80000	2026-04-16 20:46:34.387	2026-04-16 20:46:34.387
cmo1y9bq204hzvxt0m9ihpx9h	cmo1y9bo904hjvxt0dy5qm2wl	cmo1xc13o000tvxp0alok8jeb	80000	2026-04-16 20:46:34.394	2026-04-16 20:46:34.394
cmo1y9bqd04i1vxt0myv3su8m	cmo1y9bo904hjvxt0dy5qm2wl	cmo1xc11n000kvxp0g32oj3wx	80000	2026-04-16 20:46:34.405	2026-04-16 20:46:34.405
cmo1y9bqk04i3vxt0di3greum	cmo1y9bo904hjvxt0dy5qm2wl	cmo1xc10u000hvxp0dapryn3r	80000	2026-04-16 20:46:34.412	2026-04-16 20:46:34.412
cmo1y9bqt04i5vxt0lg88fa0o	cmo1y9bo904hjvxt0dy5qm2wl	cmo1xc119000jvxp01snwxzoa	80000	2026-04-16 20:46:34.421	2026-04-16 20:46:34.421
cmo1y9bs504ibvxt0hc1t9wrf	cmo1y9brx04i9vxt0r83rjz2h	cmo1xsgrt0022vxv8sd7cckj7	1228000	2026-04-16 20:46:34.47	2026-04-16 20:46:34.47
cmo1y9bsd04idvxt0gggs214c	cmo1y9brx04i9vxt0r83rjz2h	cmo1xc11v000lvxp07r6uljko	1228000	2026-04-16 20:46:34.477	2026-04-16 20:46:34.477
cmo1y9bsj04ifvxt0oix1gluo	cmo1y9brx04i9vxt0r83rjz2h	cmo1xc12y000qvxp0uqc7d8d8	1228000	2026-04-16 20:46:34.483	2026-04-16 20:46:34.483
cmo1y9bsp04ihvxt0cckh9jsg	cmo1y9brx04i9vxt0r83rjz2h	cmo1xc13g000svxp0tbndc1wg	1228000	2026-04-16 20:46:34.49	2026-04-16 20:46:34.49
cmo1y9bt104ijvxt01xxp4jms	cmo1y9brx04i9vxt0r83rjz2h	cmo1xc12q000pvxp0kun82k4l	1228000	2026-04-16 20:46:34.501	2026-04-16 20:46:34.501
cmo1y9bt804ilvxt0t3ff2xtu	cmo1y9brx04i9vxt0r83rjz2h	cmo1xc138000rvxp0r16wi1bz	1228000	2026-04-16 20:46:34.508	2026-04-16 20:46:34.508
cmo1y9bte04invxt0hrxt9yj0	cmo1y9brx04i9vxt0r83rjz2h	cmo1xc12i000ovxp01nisgvnu	1228000	2026-04-16 20:46:34.514	2026-04-16 20:46:34.514
cmo1y9btl04ipvxt0dpa3bgp3	cmo1y9brx04i9vxt0r83rjz2h	cmo1xc13o000tvxp0alok8jeb	1228000	2026-04-16 20:46:34.522	2026-04-16 20:46:34.522
cmo1y9btw04irvxt0e3k2y8xi	cmo1y9brx04i9vxt0r83rjz2h	cmo1xc11n000kvxp0g32oj3wx	1228000	2026-04-16 20:46:34.533	2026-04-16 20:46:34.533
cmo1y9bu404itvxt00zklu7vz	cmo1y9brx04i9vxt0r83rjz2h	cmo1xc10u000hvxp0dapryn3r	1228000	2026-04-16 20:46:34.54	2026-04-16 20:46:34.54
cmo1y9bue04ivvxt06kbjbw5a	cmo1y9brx04i9vxt0r83rjz2h	cmo1xc119000jvxp01snwxzoa	1228000	2026-04-16 20:46:34.55	2026-04-16 20:46:34.55
cmo1y9but04izvxt0x0l240qb	cmo1y9buk04ixvxt0cq4sxv2v	cmo1xsgrt0022vxv8sd7cckj7	750000	2026-04-16 20:46:34.565	2026-04-16 20:46:34.565
cmo1y9bv004j1vxt0m22b5oem	cmo1y9buk04ixvxt0cq4sxv2v	cmo1xc11v000lvxp07r6uljko	750000	2026-04-16 20:46:34.573	2026-04-16 20:46:34.573
cmo1y9bv904j3vxt0hqpp8qr9	cmo1y9buk04ixvxt0cq4sxv2v	cmo1xc12y000qvxp0uqc7d8d8	750000	2026-04-16 20:46:34.581	2026-04-16 20:46:34.581
cmo1y9bvg04j5vxt0fedck4fl	cmo1y9buk04ixvxt0cq4sxv2v	cmo1xc13g000svxp0tbndc1wg	750000	2026-04-16 20:46:34.589	2026-04-16 20:46:34.589
cmo1y9bvs04j7vxt0vzlprpip	cmo1y9buk04ixvxt0cq4sxv2v	cmo1xc12q000pvxp0kun82k4l	750000	2026-04-16 20:46:34.6	2026-04-16 20:46:34.6
cmo1y9bvy04j9vxt0hvj3q7jt	cmo1y9buk04ixvxt0cq4sxv2v	cmo1xc138000rvxp0r16wi1bz	750000	2026-04-16 20:46:34.607	2026-04-16 20:46:34.607
cmo1y9bw804jbvxt0ou5td3g8	cmo1y9buk04ixvxt0cq4sxv2v	cmo1xc12i000ovxp01nisgvnu	750000	2026-04-16 20:46:34.617	2026-04-16 20:46:34.617
cmo1y9bwf04jdvxt03j6ow2h3	cmo1y9buk04ixvxt0cq4sxv2v	cmo1xc13o000tvxp0alok8jeb	750000	2026-04-16 20:46:34.623	2026-04-16 20:46:34.623
cmo1y9bwq04jfvxt0rsz10nh8	cmo1y9buk04ixvxt0cq4sxv2v	cmo1xc11n000kvxp0g32oj3wx	750000	2026-04-16 20:46:34.634	2026-04-16 20:46:34.634
cmo1y9bww04jhvxt0k3wysbj8	cmo1y9buk04ixvxt0cq4sxv2v	cmo1xc10u000hvxp0dapryn3r	750000	2026-04-16 20:46:34.641	2026-04-16 20:46:34.641
cmo1y9bx504jjvxt0vwfy9pkt	cmo1y9buk04ixvxt0cq4sxv2v	cmo1xc119000jvxp01snwxzoa	750000	2026-04-16 20:46:34.649	2026-04-16 20:46:34.649
cmo1y9bxl04jnvxt0xpe6n05o	cmo1y9bxc04jlvxt0ctlgqmbx	cmo1xsgrt0022vxv8sd7cckj7	62000	2026-04-16 20:46:34.665	2026-04-16 20:46:34.665
cmo1y9bxt04jpvxt07egseuzj	cmo1y9bxc04jlvxt0ctlgqmbx	cmo1xc11v000lvxp07r6uljko	62000	2026-04-16 20:46:34.673	2026-04-16 20:46:34.673
cmo1y9by304jrvxt0dokq9a4v	cmo1y9bxc04jlvxt0ctlgqmbx	cmo1xc12y000qvxp0uqc7d8d8	62000	2026-04-16 20:46:34.683	2026-04-16 20:46:34.683
cmo1y9bya04jtvxt0rsgraktv	cmo1y9bxc04jlvxt0ctlgqmbx	cmo1xc13g000svxp0tbndc1wg	62000	2026-04-16 20:46:34.69	2026-04-16 20:46:34.69
cmo1y9byk04jvvxt000kh09bt	cmo1y9bxc04jlvxt0ctlgqmbx	cmo1xc12q000pvxp0kun82k4l	62000	2026-04-16 20:46:34.7	2026-04-16 20:46:34.7
cmo1y9byr04jxvxt0uub6dxw5	cmo1y9bxc04jlvxt0ctlgqmbx	cmo1xc138000rvxp0r16wi1bz	62000	2026-04-16 20:46:34.707	2026-04-16 20:46:34.707
cmo1y9byz04jzvxt0gtfeyo9o	cmo1y9bxc04jlvxt0ctlgqmbx	cmo1xc12i000ovxp01nisgvnu	62000	2026-04-16 20:46:34.716	2026-04-16 20:46:34.716
cmo1y9bz604k1vxt0h1x2ence	cmo1y9bxc04jlvxt0ctlgqmbx	cmo1xc13o000tvxp0alok8jeb	62000	2026-04-16 20:46:34.723	2026-04-16 20:46:34.723
cmo1y9bzi04k3vxt0qjfc88ho	cmo1y9bxc04jlvxt0ctlgqmbx	cmo1xc11n000kvxp0g32oj3wx	62000	2026-04-16 20:46:34.734	2026-04-16 20:46:34.734
cmo1y9bzo04k5vxt0g5z7te6h	cmo1y9bxc04jlvxt0ctlgqmbx	cmo1xc10u000hvxp0dapryn3r	62000	2026-04-16 20:46:34.741	2026-04-16 20:46:34.741
cmo1y9bzy04k7vxt0g5ppng10	cmo1y9bxc04jlvxt0ctlgqmbx	cmo1xc119000jvxp01snwxzoa	62000	2026-04-16 20:46:34.751	2026-04-16 20:46:34.751
cmo1y9c0d04kbvxt08uaoqpu5	cmo1y9c0504k9vxt043zlhiq3	cmo1xsgrt0022vxv8sd7cckj7	120000	2026-04-16 20:46:34.765	2026-04-16 20:46:34.765
cmo1y9c0l04kdvxt0ly9r7lj6	cmo1y9c0504k9vxt043zlhiq3	cmo1xc11v000lvxp07r6uljko	120000	2026-04-16 20:46:34.773	2026-04-16 20:46:34.773
cmo1y9c0t04kfvxt066qpzg4j	cmo1y9c0504k9vxt043zlhiq3	cmo1xc12y000qvxp0uqc7d8d8	120000	2026-04-16 20:46:34.781	2026-04-16 20:46:34.781
cmo1y9c1104khvxt0kdazmcjs	cmo1y9c0504k9vxt043zlhiq3	cmo1xc13g000svxp0tbndc1wg	120000	2026-04-16 20:46:34.789	2026-04-16 20:46:34.789
cmo1y9c1c04kjvxt038revsfd	cmo1y9c0504k9vxt043zlhiq3	cmo1xc12q000pvxp0kun82k4l	120000	2026-04-16 20:46:34.8	2026-04-16 20:46:34.8
cmo1y9c1i04klvxt00wcedtrv	cmo1y9c0504k9vxt043zlhiq3	cmo1xc138000rvxp0r16wi1bz	120000	2026-04-16 20:46:34.807	2026-04-16 20:46:34.807
cmo1y9c1s04knvxt0g5q7m9ax	cmo1y9c0504k9vxt043zlhiq3	cmo1xc12i000ovxp01nisgvnu	120000	2026-04-16 20:46:34.816	2026-04-16 20:46:34.816
cmo1y9c1z04kpvxt0dvz8z76u	cmo1y9c0504k9vxt043zlhiq3	cmo1xc13o000tvxp0alok8jeb	120000	2026-04-16 20:46:34.823	2026-04-16 20:46:34.823
cmo1y9c2904krvxt0n7p40edh	cmo1y9c0504k9vxt043zlhiq3	cmo1xc11n000kvxp0g32oj3wx	120000	2026-04-16 20:46:34.833	2026-04-16 20:46:34.833
cmo1y9c2f04ktvxt0pj4oqltb	cmo1y9c0504k9vxt043zlhiq3	cmo1xc10u000hvxp0dapryn3r	120000	2026-04-16 20:46:34.84	2026-04-16 20:46:34.84
cmo1y9c2m04kvvxt0t7wnlz0x	cmo1y9c0504k9vxt043zlhiq3	cmo1xc119000jvxp01snwxzoa	120000	2026-04-16 20:46:34.847	2026-04-16 20:46:34.847
cmo1y9c3f04kzvxt0kp0ng24x	cmo1y9c2u04kxvxt0vts5zoic	cmo1xc12i000ovxp01nisgvnu	70000	2026-04-16 20:46:34.875	2026-04-16 20:46:34.875
cmo1y9c4m04l3vxt0jixjqsge	cmo1y9c3v04l1vxt0mjqgyxec	cmo1xc12i000ovxp01nisgvnu	87000	2026-04-16 20:46:34.919	2026-04-16 20:46:34.919
cmo1y9c5804l7vxt0nkia5mew	cmo1y9c5204l5vxt0lg1u6sn6	cmo1xsgrt0022vxv8sd7cckj7	59000	2026-04-16 20:46:34.941	2026-04-16 20:46:34.941
cmo1y9c5j04l9vxt0gu3gr4gf	cmo1y9c5204l5vxt0lg1u6sn6	cmo1xc11v000lvxp07r6uljko	59000	2026-04-16 20:46:34.951	2026-04-16 20:46:34.951
cmo1y9c5q04lbvxt09dkzzxv6	cmo1y9c5204l5vxt0lg1u6sn6	cmo1xc12y000qvxp0uqc7d8d8	59000	2026-04-16 20:46:34.958	2026-04-16 20:46:34.958
cmo1y9c5y04ldvxt0usqtf7fr	cmo1y9c5204l5vxt0lg1u6sn6	cmo1xc13g000svxp0tbndc1wg	59000	2026-04-16 20:46:34.966	2026-04-16 20:46:34.966
cmo1y9c6704lfvxt0e8b65lz8	cmo1y9c5204l5vxt0lg1u6sn6	cmo1xc12q000pvxp0kun82k4l	59000	2026-04-16 20:46:34.975	2026-04-16 20:46:34.975
cmo1y9c6e04lhvxt0as3m8ngh	cmo1y9c5204l5vxt0lg1u6sn6	cmo1xc138000rvxp0r16wi1bz	59000	2026-04-16 20:46:34.982	2026-04-16 20:46:34.982
cmo1y9c6l04ljvxt0fm1tlyab	cmo1y9c5204l5vxt0lg1u6sn6	cmo1xc12i000ovxp01nisgvnu	59000	2026-04-16 20:46:34.989	2026-04-16 20:46:34.989
cmo1y9c6t04llvxt0snzzmpp7	cmo1y9c5204l5vxt0lg1u6sn6	cmo1xc13o000tvxp0alok8jeb	59000	2026-04-16 20:46:34.998	2026-04-16 20:46:34.998
cmo1y9c7204lnvxt0o8mdwoez	cmo1y9c5204l5vxt0lg1u6sn6	cmo1xc11n000kvxp0g32oj3wx	59000	2026-04-16 20:46:35.007	2026-04-16 20:46:35.007
cmo1y9c7c04lpvxt0d40q76in	cmo1y9c5204l5vxt0lg1u6sn6	cmo1xc10u000hvxp0dapryn3r	59000	2026-04-16 20:46:35.016	2026-04-16 20:46:35.016
cmo1y9c7j04lrvxt0r6sdu8wm	cmo1y9c5204l5vxt0lg1u6sn6	cmo1xc119000jvxp01snwxzoa	59000	2026-04-16 20:46:35.023	2026-04-16 20:46:35.023
cmo1y9c7y04lvvxt0mawn5ou4	cmo1y9c7q04ltvxt0fl7c71f5	cmo1xsgrt0022vxv8sd7cckj7	70000	2026-04-16 20:46:35.038	2026-04-16 20:46:35.038
cmo1y9c8504lxvxt0zomjl4eg	cmo1y9c7q04ltvxt0fl7c71f5	cmo1xc11v000lvxp07r6uljko	70000	2026-04-16 20:46:35.045	2026-04-16 20:46:35.045
cmo1y9c8d04lzvxt0bkdqsikp	cmo1y9c7q04ltvxt0fl7c71f5	cmo1xc12y000qvxp0uqc7d8d8	70000	2026-04-16 20:46:35.053	2026-04-16 20:46:35.053
cmo1y9c8j04m1vxt078l8wmfd	cmo1y9c7q04ltvxt0fl7c71f5	cmo1xc13g000svxp0tbndc1wg	70000	2026-04-16 20:46:35.06	2026-04-16 20:46:35.06
cmo1y9c8s04m3vxt0wrjpu5cm	cmo1y9c7q04ltvxt0fl7c71f5	cmo1xc12q000pvxp0kun82k4l	70000	2026-04-16 20:46:35.068	2026-04-16 20:46:35.068
cmo1y9c8y04m5vxt0y47wcl9k	cmo1y9c7q04ltvxt0fl7c71f5	cmo1xc138000rvxp0r16wi1bz	70000	2026-04-16 20:46:35.074	2026-04-16 20:46:35.074
cmo1y9c9704m7vxt0avgwlu0o	cmo1y9c7q04ltvxt0fl7c71f5	cmo1xc12i000ovxp01nisgvnu	70000	2026-04-16 20:46:35.084	2026-04-16 20:46:35.084
cmo1y9c9e04m9vxt0k3b85my7	cmo1y9c7q04ltvxt0fl7c71f5	cmo1xc13o000tvxp0alok8jeb	70000	2026-04-16 20:46:35.09	2026-04-16 20:46:35.09
cmo1y9c9o04mbvxt06u3agzms	cmo1y9c7q04ltvxt0fl7c71f5	cmo1xc11n000kvxp0g32oj3wx	70000	2026-04-16 20:46:35.1	2026-04-16 20:46:35.1
cmo1y9c9v04mdvxt0ohaea95x	cmo1y9c7q04ltvxt0fl7c71f5	cmo1xc10u000hvxp0dapryn3r	70000	2026-04-16 20:46:35.107	2026-04-16 20:46:35.107
cmo1y9ca304mfvxt0chi18l0e	cmo1y9c7q04ltvxt0fl7c71f5	cmo1xc119000jvxp01snwxzoa	70000	2026-04-16 20:46:35.116	2026-04-16 20:46:35.116
cmo1y9caj04mjvxt06yevs5p3	cmo1y9cab04mhvxt0a2cvnn4i	cmo1xsgrt0022vxv8sd7cckj7	26000	2026-04-16 20:46:35.131	2026-04-16 20:46:35.131
cmo1y9car04mlvxt0x5v3rfb2	cmo1y9cab04mhvxt0a2cvnn4i	cmo1xc11v000lvxp07r6uljko	26000	2026-04-16 20:46:35.139	2026-04-16 20:46:35.139
cmo1y9cb204mnvxt032f4fyfr	cmo1y9cab04mhvxt0a2cvnn4i	cmo1xc12y000qvxp0uqc7d8d8	26000	2026-04-16 20:46:35.15	2026-04-16 20:46:35.15
cmo1y9cb804mpvxt027f0s60j	cmo1y9cab04mhvxt0a2cvnn4i	cmo1xc13g000svxp0tbndc1wg	26000	2026-04-16 20:46:35.157	2026-04-16 20:46:35.157
cmo1y9cbj04mrvxt0o550a3dn	cmo1y9cab04mhvxt0a2cvnn4i	cmo1xc12q000pvxp0kun82k4l	26000	2026-04-16 20:46:35.167	2026-04-16 20:46:35.167
cmo1y9cbr04mtvxt09nfx6rjf	cmo1y9cab04mhvxt0a2cvnn4i	cmo1xc138000rvxp0r16wi1bz	26000	2026-04-16 20:46:35.175	2026-04-16 20:46:35.175
cmo1y9cbz04mvvxt092wn6zws	cmo1y9cab04mhvxt0a2cvnn4i	cmo1xc12i000ovxp01nisgvnu	26000	2026-04-16 20:46:35.183	2026-04-16 20:46:35.183
cmo1y9cc504mxvxt016a6l8wg	cmo1y9cab04mhvxt0a2cvnn4i	cmo1xc13o000tvxp0alok8jeb	26000	2026-04-16 20:46:35.19	2026-04-16 20:46:35.19
cmo1y9ccg04mzvxt07zhqo78y	cmo1y9cab04mhvxt0a2cvnn4i	cmo1xc11n000kvxp0g32oj3wx	26000	2026-04-16 20:46:35.201	2026-04-16 20:46:35.201
cmo1y9ccn04n1vxt0yhxrkpwr	cmo1y9cab04mhvxt0a2cvnn4i	cmo1xc10u000hvxp0dapryn3r	26000	2026-04-16 20:46:35.208	2026-04-16 20:46:35.208
cmo1y9ccx04n3vxt0v8ftg938	cmo1y9cab04mhvxt0a2cvnn4i	cmo1xc119000jvxp01snwxzoa	26000	2026-04-16 20:46:35.217	2026-04-16 20:46:35.217
cmo1y9cdb04n7vxt0uhufe2cu	cmo1y9cd404n5vxt04xh0vs7e	cmo1xsgrt0022vxv8sd7cckj7	500000	2026-04-16 20:46:35.232	2026-04-16 20:46:35.232
cmo1y9cdj04n9vxt0qv200gem	cmo1y9cd404n5vxt04xh0vs7e	cmo1xc11v000lvxp07r6uljko	500000	2026-04-16 20:46:35.24	2026-04-16 20:46:35.24
cmo1y9cds04nbvxt0xoco08xp	cmo1y9cd404n5vxt04xh0vs7e	cmo1xc12y000qvxp0uqc7d8d8	500000	2026-04-16 20:46:35.248	2026-04-16 20:46:35.248
cmo1y9cdy04ndvxt0nn63zw5i	cmo1y9cd404n5vxt04xh0vs7e	cmo1xc13g000svxp0tbndc1wg	500000	2026-04-16 20:46:35.255	2026-04-16 20:46:35.255
cmo1y9ce704nfvxt0kllvxjke	cmo1y9cd404n5vxt04xh0vs7e	cmo1xc12q000pvxp0kun82k4l	500000	2026-04-16 20:46:35.263	2026-04-16 20:46:35.263
cmo1y9cee04nhvxt05sz4tswc	cmo1y9cd404n5vxt04xh0vs7e	cmo1xc138000rvxp0r16wi1bz	500000	2026-04-16 20:46:35.271	2026-04-16 20:46:35.271
cmo1y9cel04njvxt01te6btji	cmo1y9cd404n5vxt04xh0vs7e	cmo1xc12i000ovxp01nisgvnu	500000	2026-04-16 20:46:35.277	2026-04-16 20:46:35.277
cmo1y9cer04nlvxt0w0r4ow7m	cmo1y9cd404n5vxt04xh0vs7e	cmo1xc13o000tvxp0alok8jeb	500000	2026-04-16 20:46:35.284	2026-04-16 20:46:35.284
cmo1y9cf004nnvxt0fb6f8l72	cmo1y9cd404n5vxt04xh0vs7e	cmo1xc11n000kvxp0g32oj3wx	500000	2026-04-16 20:46:35.292	2026-04-16 20:46:35.292
cmo1y9cf804npvxt0qegpwjxz	cmo1y9cd404n5vxt04xh0vs7e	cmo1xc10u000hvxp0dapryn3r	500000	2026-04-16 20:46:35.301	2026-04-16 20:46:35.301
cmo1y9cfe04nrvxt0rozj629q	cmo1y9cd404n5vxt04xh0vs7e	cmo1xc119000jvxp01snwxzoa	500000	2026-04-16 20:46:35.307	2026-04-16 20:46:35.307
cmo1y9cft04nvvxt0o4o6pjt2	cmo1y9cfk04ntvxt06uin5ggr	cmo1xsgrt0022vxv8sd7cckj7	55000	2026-04-16 20:46:35.321	2026-04-16 20:46:35.321
cmo1y9cg004nxvxt0mjjf8zpa	cmo1y9cfk04ntvxt06uin5ggr	cmo1xc11v000lvxp07r6uljko	55000	2026-04-16 20:46:35.328	2026-04-16 20:46:35.328
cmo1y9cg804nzvxt0xmp3krr4	cmo1y9cfk04ntvxt06uin5ggr	cmo1xc12y000qvxp0uqc7d8d8	55000	2026-04-16 20:46:35.336	2026-04-16 20:46:35.336
cmo1y9cge04o1vxt05m5thpbn	cmo1y9cfk04ntvxt06uin5ggr	cmo1xc13g000svxp0tbndc1wg	55000	2026-04-16 20:46:35.343	2026-04-16 20:46:35.343
cmo1y9cgn04o3vxt0fdq2msmx	cmo1y9cfk04ntvxt06uin5ggr	cmo1xc12q000pvxp0kun82k4l	55000	2026-04-16 20:46:35.352	2026-04-16 20:46:35.352
cmo1y9cgw04o5vxt0xw2c9dy7	cmo1y9cfk04ntvxt06uin5ggr	cmo1xc138000rvxp0r16wi1bz	55000	2026-04-16 20:46:35.36	2026-04-16 20:46:35.36
cmo1y9ch304o7vxt08cqw3e03	cmo1y9cfk04ntvxt06uin5ggr	cmo1xc12i000ovxp01nisgvnu	55000	2026-04-16 20:46:35.367	2026-04-16 20:46:35.367
cmo1y9cha04o9vxt00d5d24xn	cmo1y9cfk04ntvxt06uin5ggr	cmo1xc13o000tvxp0alok8jeb	55000	2026-04-16 20:46:35.374	2026-04-16 20:46:35.374
cmo1y9chj04obvxt0vzjbfzuj	cmo1y9cfk04ntvxt06uin5ggr	cmo1xc11n000kvxp0g32oj3wx	55000	2026-04-16 20:46:35.384	2026-04-16 20:46:35.384
cmo1y9chp04odvxt0auy6b3gt	cmo1y9cfk04ntvxt06uin5ggr	cmo1xc10u000hvxp0dapryn3r	55000	2026-04-16 20:46:35.39	2026-04-16 20:46:35.39
cmo1y9chy04ofvxt0xm0j2lpf	cmo1y9cfk04ntvxt06uin5ggr	cmo1xc119000jvxp01snwxzoa	55000	2026-04-16 20:46:35.398	2026-04-16 20:46:35.398
cmo1y9cic04ojvxt0cco8v6np	cmo1y9ci504ohvxt0v61mly99	cmo1xsgrt0022vxv8sd7cckj7	35000	2026-04-16 20:46:35.412	2026-04-16 20:46:35.412
cmo1y9cil04olvxt055gmlnhn	cmo1y9ci504ohvxt0v61mly99	cmo1xc11v000lvxp07r6uljko	35000	2026-04-16 20:46:35.421	2026-04-16 20:46:35.421
cmo1y9cir04onvxt0v5bd0169	cmo1y9ci504ohvxt0v61mly99	cmo1xc12y000qvxp0uqc7d8d8	35000	2026-04-16 20:46:35.427	2026-04-16 20:46:35.427
cmo1y9cix04opvxt0xyietdlf	cmo1y9ci504ohvxt0v61mly99	cmo1xc13g000svxp0tbndc1wg	35000	2026-04-16 20:46:35.433	2026-04-16 20:46:35.433
cmo1y9cj504orvxt07mb9y6sf	cmo1y9ci504ohvxt0v61mly99	cmo1xc12q000pvxp0kun82k4l	35000	2026-04-16 20:46:35.442	2026-04-16 20:46:35.442
cmo1y9cjc04otvxt0awgulbh4	cmo1y9ci504ohvxt0v61mly99	cmo1xc138000rvxp0r16wi1bz	35000	2026-04-16 20:46:35.449	2026-04-16 20:46:35.449
cmo1y9cjj04ovvxt0rjlbu0xe	cmo1y9ci504ohvxt0v61mly99	cmo1xc12i000ovxp01nisgvnu	35000	2026-04-16 20:46:35.455	2026-04-16 20:46:35.455
cmo1y9cjq04oxvxt0l00zdd94	cmo1y9ci504ohvxt0v61mly99	cmo1xc13o000tvxp0alok8jeb	35000	2026-04-16 20:46:35.462	2026-04-16 20:46:35.462
cmo1y9ck104ozvxt0np1w7xr8	cmo1y9ci504ohvxt0v61mly99	cmo1xc11n000kvxp0g32oj3wx	35000	2026-04-16 20:46:35.473	2026-04-16 20:46:35.473
cmo1y9ckb04p1vxt0iy3nansk	cmo1y9ci504ohvxt0v61mly99	cmo1xc10u000hvxp0dapryn3r	35000	2026-04-16 20:46:35.484	2026-04-16 20:46:35.484
cmo1y9cki04p3vxt0yps4rmj7	cmo1y9ci504ohvxt0v61mly99	cmo1xc119000jvxp01snwxzoa	35000	2026-04-16 20:46:35.49	2026-04-16 20:46:35.49
cmo1y9ckx04p7vxt0sm4zeu6n	cmo1y9ckp04p5vxt03maaecy1	cmo1xsgrt0022vxv8sd7cckj7	39000	2026-04-16 20:46:35.505	2026-04-16 20:46:35.505
cmo1y9cla04p9vxt04wm18pfr	cmo1y9ckp04p5vxt03maaecy1	cmo1xc11v000lvxp07r6uljko	39000	2026-04-16 20:46:35.518	2026-04-16 20:46:35.518
cmo1y9clg04pbvxt0rmc1mtxn	cmo1y9ckp04p5vxt03maaecy1	cmo1xc12y000qvxp0uqc7d8d8	39000	2026-04-16 20:46:35.525	2026-04-16 20:46:35.525
cmo1y9clo04pdvxt0kgj4imxp	cmo1y9ckp04p5vxt03maaecy1	cmo1xc13g000svxp0tbndc1wg	39000	2026-04-16 20:46:35.532	2026-04-16 20:46:35.532
cmo1y9clx04pfvxt0yfj6dum3	cmo1y9ckp04p5vxt03maaecy1	cmo1xc12q000pvxp0kun82k4l	39000	2026-04-16 20:46:35.541	2026-04-16 20:46:35.541
cmo1y9cm604phvxt0r5040dc4	cmo1y9ckp04p5vxt03maaecy1	cmo1xc138000rvxp0r16wi1bz	39000	2026-04-16 20:46:35.55	2026-04-16 20:46:35.55
cmo1y9cmc04pjvxt0f06sv2hb	cmo1y9ckp04p5vxt03maaecy1	cmo1xc12i000ovxp01nisgvnu	39000	2026-04-16 20:46:35.556	2026-04-16 20:46:35.556
cmo1y9cmi04plvxt00b8k0i3a	cmo1y9ckp04p5vxt03maaecy1	cmo1xc13o000tvxp0alok8jeb	39000	2026-04-16 20:46:35.562	2026-04-16 20:46:35.562
cmo1y9cmr04pnvxt0wxzthk0u	cmo1y9ckp04p5vxt03maaecy1	cmo1xc11n000kvxp0g32oj3wx	39000	2026-04-16 20:46:35.572	2026-04-16 20:46:35.572
cmo1y9cn104ppvxt0fxe6qvm3	cmo1y9ckp04p5vxt03maaecy1	cmo1xc10u000hvxp0dapryn3r	39000	2026-04-16 20:46:35.581	2026-04-16 20:46:35.581
cmo1y9cn804prvxt049xvl8s5	cmo1y9ckp04p5vxt03maaecy1	cmo1xc119000jvxp01snwxzoa	39000	2026-04-16 20:46:35.588	2026-04-16 20:46:35.588
cmo1y9cnq04pvvxt0malij543	cmo1y9cni04ptvxt0nwuugm1t	cmo1xsgrt0022vxv8sd7cckj7	50000	2026-04-16 20:46:35.607	2026-04-16 20:46:35.607
cmo1y9co004pxvxt0nh2ls1lk	cmo1y9cni04ptvxt0nwuugm1t	cmo1xc11v000lvxp07r6uljko	50000	2026-04-16 20:46:35.616	2026-04-16 20:46:35.616
cmo1y9co604pzvxt0zv3vxjuf	cmo1y9cni04ptvxt0nwuugm1t	cmo1xc12y000qvxp0uqc7d8d8	50000	2026-04-16 20:46:35.622	2026-04-16 20:46:35.622
cmo1y9coc04q1vxt09sfjvxy9	cmo1y9cni04ptvxt0nwuugm1t	cmo1xc13g000svxp0tbndc1wg	50000	2026-04-16 20:46:35.628	2026-04-16 20:46:35.628
cmo1y9col04q3vxt0f8ge7jch	cmo1y9cni04ptvxt0nwuugm1t	cmo1xc12q000pvxp0kun82k4l	50000	2026-04-16 20:46:35.637	2026-04-16 20:46:35.637
cmo1y9cos04q5vxt0nmutij2l	cmo1y9cni04ptvxt0nwuugm1t	cmo1xc138000rvxp0r16wi1bz	50000	2026-04-16 20:46:35.644	2026-04-16 20:46:35.644
cmo1y9coy04q7vxt0oqqsy1wt	cmo1y9cni04ptvxt0nwuugm1t	cmo1xc12i000ovxp01nisgvnu	50000	2026-04-16 20:46:35.65	2026-04-16 20:46:35.65
cmo1y9cp504q9vxt0zftu85u0	cmo1y9cni04ptvxt0nwuugm1t	cmo1xc13o000tvxp0alok8jeb	50000	2026-04-16 20:46:35.657	2026-04-16 20:46:35.657
cmo1y9cpf04qbvxt0yji6cfk2	cmo1y9cni04ptvxt0nwuugm1t	cmo1xc11n000kvxp0g32oj3wx	50000	2026-04-16 20:46:35.667	2026-04-16 20:46:35.667
cmo1y9cpl04qdvxt082oj06gb	cmo1y9cni04ptvxt0nwuugm1t	cmo1xc10u000hvxp0dapryn3r	50000	2026-04-16 20:46:35.674	2026-04-16 20:46:35.674
cmo1y9cpt04qfvxt02iws8b5w	cmo1y9cni04ptvxt0nwuugm1t	cmo1xc119000jvxp01snwxzoa	50000	2026-04-16 20:46:35.682	2026-04-16 20:46:35.682
cmo1y9cqb04qjvxt0jglz0vvf	cmo1y9cq104qhvxt0um5kk1e7	cmo1xsgrt0022vxv8sd7cckj7	38000	2026-04-16 20:46:35.7	2026-04-16 20:46:35.7
cmo1y9cqi04qlvxt05fv2h36e	cmo1y9cq104qhvxt0um5kk1e7	cmo1xc11v000lvxp07r6uljko	38000	2026-04-16 20:46:35.707	2026-04-16 20:46:35.707
cmo1y9cqr04qnvxt091gv4lja	cmo1y9cq104qhvxt0um5kk1e7	cmo1xc12y000qvxp0uqc7d8d8	38000	2026-04-16 20:46:35.715	2026-04-16 20:46:35.715
cmo1y9cqy04qpvxt0gs0me0t2	cmo1y9cq104qhvxt0um5kk1e7	cmo1xc13g000svxp0tbndc1wg	38000	2026-04-16 20:46:35.722	2026-04-16 20:46:35.722
cmo1y9cr804qrvxt0a0g0ambg	cmo1y9cq104qhvxt0um5kk1e7	cmo1xc12q000pvxp0kun82k4l	38000	2026-04-16 20:46:35.733	2026-04-16 20:46:35.733
cmo1y9crg04qtvxt0rbbbqorl	cmo1y9cq104qhvxt0um5kk1e7	cmo1xc138000rvxp0r16wi1bz	38000	2026-04-16 20:46:35.74	2026-04-16 20:46:35.74
cmo1y9crp04qvvxt0jz69r8su	cmo1y9cq104qhvxt0um5kk1e7	cmo1xc12i000ovxp01nisgvnu	38000	2026-04-16 20:46:35.749	2026-04-16 20:46:35.749
cmo1y9crw04qxvxt0ceoh6dnd	cmo1y9cq104qhvxt0um5kk1e7	cmo1xc13o000tvxp0alok8jeb	38000	2026-04-16 20:46:35.757	2026-04-16 20:46:35.757
cmo1y9cs604qzvxt0lpjtpnex	cmo1y9cq104qhvxt0um5kk1e7	cmo1xc11n000kvxp0g32oj3wx	38000	2026-04-16 20:46:35.767	2026-04-16 20:46:35.767
cmo1y9cse04r1vxt0ja4ih208	cmo1y9cq104qhvxt0um5kk1e7	cmo1xc10u000hvxp0dapryn3r	38000	2026-04-16 20:46:35.774	2026-04-16 20:46:35.774
cmo1y9csm04r3vxt0enetrffh	cmo1y9cq104qhvxt0um5kk1e7	cmo1xc119000jvxp01snwxzoa	38000	2026-04-16 20:46:35.782	2026-04-16 20:46:35.782
cmo1y9ct304r7vxt00004hkm6	cmo1y9cst04r5vxt0ra2sieoc	cmo1xsgrt0022vxv8sd7cckj7	74000	2026-04-16 20:46:35.799	2026-04-16 20:46:35.799
cmo1y9ctc04r9vxt05gkr1ise	cmo1y9cst04r5vxt0ra2sieoc	cmo1xc11v000lvxp07r6uljko	74000	2026-04-16 20:46:35.809	2026-04-16 20:46:35.809
cmo1y9ctl04rbvxt0cjwr5d6p	cmo1y9cst04r5vxt0ra2sieoc	cmo1xc12y000qvxp0uqc7d8d8	74000	2026-04-16 20:46:35.817	2026-04-16 20:46:35.817
cmo1y9ctr04rdvxt036gsx7yz	cmo1y9cst04r5vxt0ra2sieoc	cmo1xc13g000svxp0tbndc1wg	74000	2026-04-16 20:46:35.824	2026-04-16 20:46:35.824
cmo1y9cu304rfvxt0h8ftca3f	cmo1y9cst04r5vxt0ra2sieoc	cmo1xc12q000pvxp0kun82k4l	74000	2026-04-16 20:46:35.835	2026-04-16 20:46:35.835
cmo1y9cua04rhvxt0hmk362dt	cmo1y9cst04r5vxt0ra2sieoc	cmo1xc138000rvxp0r16wi1bz	74000	2026-04-16 20:46:35.842	2026-04-16 20:46:35.842
cmo1y9cuh04rjvxt001r35o5y	cmo1y9cst04r5vxt0ra2sieoc	cmo1xc12i000ovxp01nisgvnu	74000	2026-04-16 20:46:35.849	2026-04-16 20:46:35.849
cmo1y9cuo04rlvxt0ejxh4pv8	cmo1y9cst04r5vxt0ra2sieoc	cmo1xc13o000tvxp0alok8jeb	74000	2026-04-16 20:46:35.856	2026-04-16 20:46:35.856
cmo1y9cuy04rnvxt0pl4k27qm	cmo1y9cst04r5vxt0ra2sieoc	cmo1xc11n000kvxp0g32oj3wx	74000	2026-04-16 20:46:35.867	2026-04-16 20:46:35.867
cmo1y9cv604rpvxt0n98rz4ih	cmo1y9cst04r5vxt0ra2sieoc	cmo1xc10u000hvxp0dapryn3r	74000	2026-04-16 20:46:35.874	2026-04-16 20:46:35.874
cmo1y9cvg04rrvxt0umj4qobd	cmo1y9cst04r5vxt0ra2sieoc	cmo1xc119000jvxp01snwxzoa	74000	2026-04-16 20:46:35.884	2026-04-16 20:46:35.884
cmo1y9cvv04rvvxt0m2wcooz6	cmo1y9cvn04rtvxt09d7mgsbk	cmo1xsgrt0022vxv8sd7cckj7	40000	2026-04-16 20:46:35.899	2026-04-16 20:46:35.899
cmo1y9cw204rxvxt09zoqarmu	cmo1y9cvn04rtvxt09d7mgsbk	cmo1xc11v000lvxp07r6uljko	40000	2026-04-16 20:46:35.906	2026-04-16 20:46:35.906
cmo1y9cwb04rzvxt0ndg9qd47	cmo1y9cvn04rtvxt09d7mgsbk	cmo1xc12y000qvxp0uqc7d8d8	40000	2026-04-16 20:46:35.916	2026-04-16 20:46:35.916
cmo1y9cwi04s1vxt0nux9nppd	cmo1y9cvn04rtvxt09d7mgsbk	cmo1xc13g000svxp0tbndc1wg	40000	2026-04-16 20:46:35.922	2026-04-16 20:46:35.922
cmo1y9cwt04s3vxt0d4dlu8rz	cmo1y9cvn04rtvxt09d7mgsbk	cmo1xc12q000pvxp0kun82k4l	40000	2026-04-16 20:46:35.933	2026-04-16 20:46:35.933
cmo1y9cwz04s5vxt00pb2t327	cmo1y9cvn04rtvxt09d7mgsbk	cmo1xc138000rvxp0r16wi1bz	40000	2026-04-16 20:46:35.94	2026-04-16 20:46:35.94
cmo1y9cxa04s7vxt00i2pl9mf	cmo1y9cvn04rtvxt09d7mgsbk	cmo1xc12i000ovxp01nisgvnu	40000	2026-04-16 20:46:35.95	2026-04-16 20:46:35.95
cmo1y9cxh04s9vxt0vdpg6paf	cmo1y9cvn04rtvxt09d7mgsbk	cmo1xc13o000tvxp0alok8jeb	40000	2026-04-16 20:46:35.957	2026-04-16 20:46:35.957
cmo1y9cxr04sbvxt0g9z6goim	cmo1y9cvn04rtvxt09d7mgsbk	cmo1xc11n000kvxp0g32oj3wx	40000	2026-04-16 20:46:35.967	2026-04-16 20:46:35.967
cmo1y9cxx04sdvxt0p4g9fdti	cmo1y9cvn04rtvxt09d7mgsbk	cmo1xc10u000hvxp0dapryn3r	40000	2026-04-16 20:46:35.974	2026-04-16 20:46:35.974
cmo1y9cy504sfvxt0ytuxrfmx	cmo1y9cvn04rtvxt09d7mgsbk	cmo1xc119000jvxp01snwxzoa	40000	2026-04-16 20:46:35.981	2026-04-16 20:46:35.981
cmo1y9cyj04sjvxt0jz9vaunc	cmo1y9cyc04shvxt08bf289p0	cmo1xsgrt0022vxv8sd7cckj7	50000	2026-04-16 20:46:35.996	2026-04-16 20:46:35.996
cmo1y9cyt04slvxt02sqrfa7s	cmo1y9cyc04shvxt08bf289p0	cmo1xc11v000lvxp07r6uljko	50000	2026-04-16 20:46:36.005	2026-04-16 20:46:36.005
cmo1y9cz404snvxt0733jj661	cmo1y9cyc04shvxt08bf289p0	cmo1xc12y000qvxp0uqc7d8d8	50000	2026-04-16 20:46:36.016	2026-04-16 20:46:36.016
cmo1y9czb04spvxt0zore8oj5	cmo1y9cyc04shvxt08bf289p0	cmo1xc13g000svxp0tbndc1wg	50000	2026-04-16 20:46:36.023	2026-04-16 20:46:36.023
cmo1y9czl04srvxt0wi05cbpb	cmo1y9cyc04shvxt08bf289p0	cmo1xc12q000pvxp0kun82k4l	50000	2026-04-16 20:46:36.033	2026-04-16 20:46:36.033
cmo1y9czs04stvxt08tsh5ogx	cmo1y9cyc04shvxt08bf289p0	cmo1xc138000rvxp0r16wi1bz	50000	2026-04-16 20:46:36.04	2026-04-16 20:46:36.04
cmo1y9d0004svvxt08fncjryn	cmo1y9cyc04shvxt08bf289p0	cmo1xc12i000ovxp01nisgvnu	50000	2026-04-16 20:46:36.048	2026-04-16 20:46:36.048
cmo1y9d0704sxvxt00tb96b3y	cmo1y9cyc04shvxt08bf289p0	cmo1xc13o000tvxp0alok8jeb	50000	2026-04-16 20:46:36.055	2026-04-16 20:46:36.055
cmo1y9d0j04szvxt0doaylefr	cmo1y9cyc04shvxt08bf289p0	cmo1xc11n000kvxp0g32oj3wx	50000	2026-04-16 20:46:36.067	2026-04-16 20:46:36.067
cmo1y9d0q04t1vxt08yoggdbw	cmo1y9cyc04shvxt08bf289p0	cmo1xc10u000hvxp0dapryn3r	50000	2026-04-16 20:46:36.074	2026-04-16 20:46:36.074
cmo1y9d0z04t3vxt0a21d0ulw	cmo1y9cyc04shvxt08bf289p0	cmo1xc119000jvxp01snwxzoa	50000	2026-04-16 20:46:36.083	2026-04-16 20:46:36.083
cmo1y9d1e04t7vxt04zieneu6	cmo1y9d1604t5vxt054hourcx	cmo1xsgrt0022vxv8sd7cckj7	65000	2026-04-16 20:46:36.098	2026-04-16 20:46:36.098
cmo1y9d1l04t9vxt05795btal	cmo1y9d1604t5vxt054hourcx	cmo1xc11v000lvxp07r6uljko	65000	2026-04-16 20:46:36.106	2026-04-16 20:46:36.106
cmo1y9d1v04tbvxt0skhnj0md	cmo1y9d1604t5vxt054hourcx	cmo1xc12y000qvxp0uqc7d8d8	65000	2026-04-16 20:46:36.115	2026-04-16 20:46:36.115
cmo1y9d2204tdvxt0gu32fi4q	cmo1y9d1604t5vxt054hourcx	cmo1xc13g000svxp0tbndc1wg	65000	2026-04-16 20:46:36.122	2026-04-16 20:46:36.122
cmo1y9d2d04tfvxt0nvcug9rv	cmo1y9d1604t5vxt054hourcx	cmo1xc12q000pvxp0kun82k4l	65000	2026-04-16 20:46:36.134	2026-04-16 20:46:36.134
cmo1y9d2k04thvxt0ugevu45t	cmo1y9d1604t5vxt054hourcx	cmo1xc138000rvxp0r16wi1bz	65000	2026-04-16 20:46:36.14	2026-04-16 20:46:36.14
cmo1y9d2t04tjvxt0idl8t6ao	cmo1y9d1604t5vxt054hourcx	cmo1xc12i000ovxp01nisgvnu	65000	2026-04-16 20:46:36.15	2026-04-16 20:46:36.15
cmo1y9d3004tlvxt0om4qs8g7	cmo1y9d1604t5vxt054hourcx	cmo1xc13o000tvxp0alok8jeb	65000	2026-04-16 20:46:36.157	2026-04-16 20:46:36.157
cmo1y9d3a04tnvxt0vr0o4fei	cmo1y9d1604t5vxt054hourcx	cmo1xc11n000kvxp0g32oj3wx	65000	2026-04-16 20:46:36.167	2026-04-16 20:46:36.167
cmo1y9d3h04tpvxt0ivoiord1	cmo1y9d1604t5vxt054hourcx	cmo1xc10u000hvxp0dapryn3r	65000	2026-04-16 20:46:36.173	2026-04-16 20:46:36.173
cmo1y9d3q04trvxt0e7w4e0g0	cmo1y9d1604t5vxt054hourcx	cmo1xc119000jvxp01snwxzoa	65000	2026-04-16 20:46:36.182	2026-04-16 20:46:36.182
cmo1y9d4604tvvxt0q5w7liwj	cmo1y9d3x04ttvxt0imbzs2rz	cmo1xsgrt0022vxv8sd7cckj7	65000	2026-04-16 20:46:36.198	2026-04-16 20:46:36.198
cmo1y9d4e04txvxt03tbkcffd	cmo1y9d3x04ttvxt0imbzs2rz	cmo1xc11v000lvxp07r6uljko	65000	2026-04-16 20:46:36.206	2026-04-16 20:46:36.206
cmo1y9d4n04tzvxt04sjyh6e6	cmo1y9d3x04ttvxt0imbzs2rz	cmo1xc12y000qvxp0uqc7d8d8	65000	2026-04-16 20:46:36.215	2026-04-16 20:46:36.215
cmo1y9d4v04u1vxt0z9iqo51c	cmo1y9d3x04ttvxt0imbzs2rz	cmo1xc13g000svxp0tbndc1wg	65000	2026-04-16 20:46:36.223	2026-04-16 20:46:36.223
cmo1y9d5604u3vxt0kyfwujd2	cmo1y9d3x04ttvxt0imbzs2rz	cmo1xc12q000pvxp0kun82k4l	65000	2026-04-16 20:46:36.235	2026-04-16 20:46:36.235
cmo1y9d5f04u5vxt0772rnvxb	cmo1y9d3x04ttvxt0imbzs2rz	cmo1xc138000rvxp0r16wi1bz	65000	2026-04-16 20:46:36.243	2026-04-16 20:46:36.243
cmo1y9d5m04u7vxt0nk4at78h	cmo1y9d3x04ttvxt0imbzs2rz	cmo1xc12i000ovxp01nisgvnu	65000	2026-04-16 20:46:36.25	2026-04-16 20:46:36.25
cmo1y9d5t04u9vxt0sxl38gbp	cmo1y9d3x04ttvxt0imbzs2rz	cmo1xc13o000tvxp0alok8jeb	65000	2026-04-16 20:46:36.257	2026-04-16 20:46:36.257
cmo1y9d6304ubvxt0ihmbrxo4	cmo1y9d3x04ttvxt0imbzs2rz	cmo1xc11n000kvxp0g32oj3wx	65000	2026-04-16 20:46:36.267	2026-04-16 20:46:36.267
cmo1y9d6a04udvxt0tffda5rq	cmo1y9d3x04ttvxt0imbzs2rz	cmo1xc10u000hvxp0dapryn3r	65000	2026-04-16 20:46:36.274	2026-04-16 20:46:36.274
cmo1y9d6i04ufvxt0kksctswz	cmo1y9d3x04ttvxt0imbzs2rz	cmo1xc119000jvxp01snwxzoa	65000	2026-04-16 20:46:36.282	2026-04-16 20:46:36.282
cmo1y9d6y04ujvxt0jb02klkm	cmo1y9d6p04uhvxt0g5r2061s	cmo1xsgrt0022vxv8sd7cckj7	200000	2026-04-16 20:46:36.297	2026-04-16 20:46:36.297
cmo1y9d7604ulvxt0q2j0kmku	cmo1y9d6p04uhvxt0g5r2061s	cmo1xc11v000lvxp07r6uljko	200000	2026-04-16 20:46:36.306	2026-04-16 20:46:36.306
cmo1y9d7f04unvxt0hxy1swzt	cmo1y9d6p04uhvxt0g5r2061s	cmo1xc12y000qvxp0uqc7d8d8	200000	2026-04-16 20:46:36.315	2026-04-16 20:46:36.315
cmo1y9d7p04upvxt0t1w0w7kz	cmo1y9d6p04uhvxt0g5r2061s	cmo1xc13g000svxp0tbndc1wg	200000	2026-04-16 20:46:36.325	2026-04-16 20:46:36.325
cmo1y9d7z04urvxt0ss79511w	cmo1y9d6p04uhvxt0g5r2061s	cmo1xc12q000pvxp0kun82k4l	200000	2026-04-16 20:46:36.335	2026-04-16 20:46:36.335
cmo1y9d8604utvxt0fu1b5fno	cmo1y9d6p04uhvxt0g5r2061s	cmo1xc138000rvxp0r16wi1bz	200000	2026-04-16 20:46:36.342	2026-04-16 20:46:36.342
cmo1y9d8d04uvvxt0a0440t3e	cmo1y9d6p04uhvxt0g5r2061s	cmo1xc12i000ovxp01nisgvnu	200000	2026-04-16 20:46:36.35	2026-04-16 20:46:36.35
cmo1y9d8k04uxvxt0so1eqp38	cmo1y9d6p04uhvxt0g5r2061s	cmo1xc13o000tvxp0alok8jeb	200000	2026-04-16 20:46:36.356	2026-04-16 20:46:36.356
cmo1y9d8u04uzvxt0qj7vl5gi	cmo1y9d6p04uhvxt0g5r2061s	cmo1xc11n000kvxp0g32oj3wx	200000	2026-04-16 20:46:36.366	2026-04-16 20:46:36.366
cmo1y9d9004v1vxt0swao6ahs	cmo1y9d6p04uhvxt0g5r2061s	cmo1xc10u000hvxp0dapryn3r	200000	2026-04-16 20:46:36.372	2026-04-16 20:46:36.372
cmo1y9d9a04v3vxt0tqan72se	cmo1y9d6p04uhvxt0g5r2061s	cmo1xc119000jvxp01snwxzoa	200000	2026-04-16 20:46:36.382	2026-04-16 20:46:36.382
cmo1y9d9r04v7vxt084i6wsxg	cmo1y9d9h04v5vxt03n8xpq2m	cmo1xsgrt0022vxv8sd7cckj7	59000	2026-04-16 20:46:36.399	2026-04-16 20:46:36.399
cmo1y9d9x04v9vxt0wffhyi4a	cmo1y9d9h04v5vxt03n8xpq2m	cmo1xc11v000lvxp07r6uljko	59000	2026-04-16 20:46:36.406	2026-04-16 20:46:36.406
cmo1y9da704vbvxt0mb2qg0fs	cmo1y9d9h04v5vxt03n8xpq2m	cmo1xc12y000qvxp0uqc7d8d8	59000	2026-04-16 20:46:36.416	2026-04-16 20:46:36.416
cmo1y9dae04vdvxt0frsdp883	cmo1y9d9h04v5vxt03n8xpq2m	cmo1xc13g000svxp0tbndc1wg	59000	2026-04-16 20:46:36.422	2026-04-16 20:46:36.422
cmo1y9daq04vfvxt0rnalwa41	cmo1y9d9h04v5vxt03n8xpq2m	cmo1xc12q000pvxp0kun82k4l	59000	2026-04-16 20:46:36.434	2026-04-16 20:46:36.434
cmo1y9dax04vhvxt0w633qwuc	cmo1y9d9h04v5vxt03n8xpq2m	cmo1xc138000rvxp0r16wi1bz	59000	2026-04-16 20:46:36.441	2026-04-16 20:46:36.441
cmo1y9db504vjvxt05v0rgplo	cmo1y9d9h04v5vxt03n8xpq2m	cmo1xc12i000ovxp01nisgvnu	59000	2026-04-16 20:46:36.449	2026-04-16 20:46:36.449
cmo1y9dbb04vlvxt0rxe3uvf0	cmo1y9d9h04v5vxt03n8xpq2m	cmo1xc13o000tvxp0alok8jeb	59000	2026-04-16 20:46:36.455	2026-04-16 20:46:36.455
cmo1y9dbl04vnvxt0o4ro9pti	cmo1y9d9h04v5vxt03n8xpq2m	cmo1xc11n000kvxp0g32oj3wx	59000	2026-04-16 20:46:36.465	2026-04-16 20:46:36.465
cmo1y9dbr04vpvxt0obys1qqg	cmo1y9d9h04v5vxt03n8xpq2m	cmo1xc10u000hvxp0dapryn3r	59000	2026-04-16 20:46:36.472	2026-04-16 20:46:36.472
cmo1y9dby04vrvxt0mgdc90kb	cmo1y9d9h04v5vxt03n8xpq2m	cmo1xc119000jvxp01snwxzoa	59000	2026-04-16 20:46:36.479	2026-04-16 20:46:36.479
cmo1y9dcd04vvvxt0euiiygp8	cmo1y9dc604vtvxt0vhsyf3j9	cmo1xsgrt0022vxv8sd7cckj7	59000	2026-04-16 20:46:36.494	2026-04-16 20:46:36.494
cmo1y9dck04vxvxt0rrg4ooab	cmo1y9dc604vtvxt0vhsyf3j9	cmo1xc11v000lvxp07r6uljko	59000	2026-04-16 20:46:36.5	2026-04-16 20:46:36.5
cmo1y9dcq04vzvxt0nu6pt9g8	cmo1y9dc604vtvxt0vhsyf3j9	cmo1xc12y000qvxp0uqc7d8d8	59000	2026-04-16 20:46:36.507	2026-04-16 20:46:36.507
cmo1y9dcz04w1vxt09mz8moch	cmo1y9dc604vtvxt0vhsyf3j9	cmo1xc13g000svxp0tbndc1wg	59000	2026-04-16 20:46:36.515	2026-04-16 20:46:36.515
cmo1y9dd804w3vxt0srv1ccfk	cmo1y9dc604vtvxt0vhsyf3j9	cmo1xc12q000pvxp0kun82k4l	59000	2026-04-16 20:46:36.524	2026-04-16 20:46:36.524
cmo1y9ddg04w5vxt0yc7qzb40	cmo1y9dc604vtvxt0vhsyf3j9	cmo1xc138000rvxp0r16wi1bz	59000	2026-04-16 20:46:36.533	2026-04-16 20:46:36.533
cmo1y9ddn04w7vxt0niy7m9d0	cmo1y9dc604vtvxt0vhsyf3j9	cmo1xc12i000ovxp01nisgvnu	59000	2026-04-16 20:46:36.54	2026-04-16 20:46:36.54
cmo1y9ddw04w9vxt0ven40vt3	cmo1y9dc604vtvxt0vhsyf3j9	cmo1xc13o000tvxp0alok8jeb	59000	2026-04-16 20:46:36.548	2026-04-16 20:46:36.548
cmo1y9de604wbvxt0hw8odqxn	cmo1y9dc604vtvxt0vhsyf3j9	cmo1xc11n000kvxp0g32oj3wx	59000	2026-04-16 20:46:36.558	2026-04-16 20:46:36.558
cmo1y9ded04wdvxt0mh1no338	cmo1y9dc604vtvxt0vhsyf3j9	cmo1xc10u000hvxp0dapryn3r	59000	2026-04-16 20:46:36.566	2026-04-16 20:46:36.566
cmo1y9dek04wfvxt09w25owbg	cmo1y9dc604vtvxt0vhsyf3j9	cmo1xc119000jvxp01snwxzoa	59000	2026-04-16 20:46:36.572	2026-04-16 20:46:36.572
cmo1y9dez04wjvxt0785gty9d	cmo1y9des04whvxt0jgg7neib	cmo1xsgrt0022vxv8sd7cckj7	59000	2026-04-16 20:46:36.588	2026-04-16 20:46:36.588
cmo1y9df604wlvxt0ixcz9zz9	cmo1y9des04whvxt0jgg7neib	cmo1xc11v000lvxp07r6uljko	59000	2026-04-16 20:46:36.594	2026-04-16 20:46:36.594
cmo1y9dfc04wnvxt0bkq9mm8a	cmo1y9des04whvxt0jgg7neib	cmo1xc12y000qvxp0uqc7d8d8	59000	2026-04-16 20:46:36.6	2026-04-16 20:46:36.6
cmo1y9dfj04wpvxt032va3gup	cmo1y9des04whvxt0jgg7neib	cmo1xc13g000svxp0tbndc1wg	59000	2026-04-16 20:46:36.607	2026-04-16 20:46:36.607
cmo1y9dft04wrvxt026bly1hw	cmo1y9des04whvxt0jgg7neib	cmo1xc12q000pvxp0kun82k4l	59000	2026-04-16 20:46:36.617	2026-04-16 20:46:36.617
cmo1y9dg004wtvxt0rao66ug0	cmo1y9des04whvxt0jgg7neib	cmo1xc138000rvxp0r16wi1bz	59000	2026-04-16 20:46:36.624	2026-04-16 20:46:36.624
cmo1y9dg904wvvxt0usakxwxy	cmo1y9des04whvxt0jgg7neib	cmo1xc12i000ovxp01nisgvnu	59000	2026-04-16 20:46:36.633	2026-04-16 20:46:36.633
cmo1y9dgg04wxvxt0a1w66bqw	cmo1y9des04whvxt0jgg7neib	cmo1xc13o000tvxp0alok8jeb	59000	2026-04-16 20:46:36.64	2026-04-16 20:46:36.64
cmo1y9dgr04wzvxt0bnkof23s	cmo1y9des04whvxt0jgg7neib	cmo1xc11n000kvxp0g32oj3wx	59000	2026-04-16 20:46:36.651	2026-04-16 20:46:36.651
cmo1y9dgy04x1vxt0wuuemlj7	cmo1y9des04whvxt0jgg7neib	cmo1xc10u000hvxp0dapryn3r	59000	2026-04-16 20:46:36.658	2026-04-16 20:46:36.658
cmo1y9dh604x3vxt0x8q6hb7q	cmo1y9des04whvxt0jgg7neib	cmo1xc119000jvxp01snwxzoa	59000	2026-04-16 20:46:36.666	2026-04-16 20:46:36.666
cmo1y9dhm04x7vxt01r3p6rr6	cmo1y9dhc04x5vxt05qp2pdol	cmo1xsgrt0022vxv8sd7cckj7	59000	2026-04-16 20:46:36.682	2026-04-16 20:46:36.682
cmo1y9dht04x9vxt0t9yyislj	cmo1y9dhc04x5vxt05qp2pdol	cmo1xc11v000lvxp07r6uljko	59000	2026-04-16 20:46:36.689	2026-04-16 20:46:36.689
cmo1y9di304xbvxt0keu787sp	cmo1y9dhc04x5vxt05qp2pdol	cmo1xc12y000qvxp0uqc7d8d8	59000	2026-04-16 20:46:36.699	2026-04-16 20:46:36.699
cmo1y9dia04xdvxt0t97u29uq	cmo1y9dhc04x5vxt05qp2pdol	cmo1xc13g000svxp0tbndc1wg	59000	2026-04-16 20:46:36.706	2026-04-16 20:46:36.706
cmo1y9dil04xfvxt0vysrldwz	cmo1y9dhc04x5vxt05qp2pdol	cmo1xc12q000pvxp0kun82k4l	59000	2026-04-16 20:46:36.718	2026-04-16 20:46:36.718
cmo1y9dit04xhvxt09bvxu05p	cmo1y9dhc04x5vxt05qp2pdol	cmo1xc138000rvxp0r16wi1bz	59000	2026-04-16 20:46:36.725	2026-04-16 20:46:36.725
cmo1y9dj104xjvxt0kfraui9j	cmo1y9dhc04x5vxt05qp2pdol	cmo1xc12i000ovxp01nisgvnu	59000	2026-04-16 20:46:36.733	2026-04-16 20:46:36.733
cmo1y9dj704xlvxt0zduvs8qs	cmo1y9dhc04x5vxt05qp2pdol	cmo1xc13o000tvxp0alok8jeb	59000	2026-04-16 20:46:36.739	2026-04-16 20:46:36.739
cmo1y9dji04xnvxt0k6ghzhi3	cmo1y9dhc04x5vxt05qp2pdol	cmo1xc11n000kvxp0g32oj3wx	59000	2026-04-16 20:46:36.75	2026-04-16 20:46:36.75
cmo1y9djp04xpvxt04oaynnv9	cmo1y9dhc04x5vxt05qp2pdol	cmo1xc10u000hvxp0dapryn3r	59000	2026-04-16 20:46:36.757	2026-04-16 20:46:36.757
cmo1y9djx04xrvxt0hk1o3ca1	cmo1y9dhc04x5vxt05qp2pdol	cmo1xc119000jvxp01snwxzoa	59000	2026-04-16 20:46:36.766	2026-04-16 20:46:36.766
cmo1y9dkf04xvvxt0jg39ar45	cmo1y9dk504xtvxt041klrgz6	cmo1xsgrt0022vxv8sd7cckj7	79000	2026-04-16 20:46:36.783	2026-04-16 20:46:36.783
cmo1y9dkm04xxvxt0ti5c1hqt	cmo1y9dk504xtvxt041klrgz6	cmo1xc11v000lvxp07r6uljko	79000	2026-04-16 20:46:36.79	2026-04-16 20:46:36.79
cmo1y9dkt04xzvxt0jgrvubb8	cmo1y9dk504xtvxt041klrgz6	cmo1xc12y000qvxp0uqc7d8d8	79000	2026-04-16 20:46:36.798	2026-04-16 20:46:36.798
cmo1y9dl104y1vxt0ez4gwc65	cmo1y9dk504xtvxt041klrgz6	cmo1xc13g000svxp0tbndc1wg	79000	2026-04-16 20:46:36.805	2026-04-16 20:46:36.805
cmo1y9dlb04y3vxt0omxl2p4x	cmo1y9dk504xtvxt041klrgz6	cmo1xc12q000pvxp0kun82k4l	79000	2026-04-16 20:46:36.815	2026-04-16 20:46:36.815
cmo1y9dli04y5vxt0trg8ai1n	cmo1y9dk504xtvxt041klrgz6	cmo1xc138000rvxp0r16wi1bz	79000	2026-04-16 20:46:36.822	2026-04-16 20:46:36.822
cmo1y9dlr04y7vxt047pmm0td	cmo1y9dk504xtvxt041klrgz6	cmo1xc12i000ovxp01nisgvnu	79000	2026-04-16 20:46:36.831	2026-04-16 20:46:36.831
cmo1y9dly04y9vxt0i9e3nhmu	cmo1y9dk504xtvxt041klrgz6	cmo1xc13o000tvxp0alok8jeb	79000	2026-04-16 20:46:36.838	2026-04-16 20:46:36.838
cmo1y9dm704ybvxt0tltlsw3d	cmo1y9dk504xtvxt041klrgz6	cmo1xc11n000kvxp0g32oj3wx	79000	2026-04-16 20:46:36.848	2026-04-16 20:46:36.848
cmo1y9dmf04ydvxt05l7zdafm	cmo1y9dk504xtvxt041klrgz6	cmo1xc10u000hvxp0dapryn3r	79000	2026-04-16 20:46:36.855	2026-04-16 20:46:36.855
cmo1y9dmo04yfvxt0djeqpdpz	cmo1y9dk504xtvxt041klrgz6	cmo1xc119000jvxp01snwxzoa	79000	2026-04-16 20:46:36.864	2026-04-16 20:46:36.864
cmo1y9dn404yjvxt09x9qe82p	cmo1y9dmw04yhvxt03zug4u65	cmo1xsgrt0022vxv8sd7cckj7	39000	2026-04-16 20:46:36.881	2026-04-16 20:46:36.881
cmo1y9dnc04ylvxt0bj956tq0	cmo1y9dmw04yhvxt03zug4u65	cmo1xc11v000lvxp07r6uljko	39000	2026-04-16 20:46:36.888	2026-04-16 20:46:36.888
cmo1y9dnj04ynvxt0bb7xf2q4	cmo1y9dmw04yhvxt03zug4u65	cmo1xc12y000qvxp0uqc7d8d8	39000	2026-04-16 20:46:36.895	2026-04-16 20:46:36.895
cmo1y9dnr04ypvxt06vsei3js	cmo1y9dmw04yhvxt03zug4u65	cmo1xc13g000svxp0tbndc1wg	39000	2026-04-16 20:46:36.903	2026-04-16 20:46:36.903
cmo1y9dnz04yrvxt0duwrbe44	cmo1y9dmw04yhvxt03zug4u65	cmo1xc12q000pvxp0kun82k4l	39000	2026-04-16 20:46:36.911	2026-04-16 20:46:36.911
cmo1y9do604ytvxt0t6l0skeb	cmo1y9dmw04yhvxt03zug4u65	cmo1xc138000rvxp0r16wi1bz	39000	2026-04-16 20:46:36.919	2026-04-16 20:46:36.919
cmo1y9dod04yvvxt0l6iomf08	cmo1y9dmw04yhvxt03zug4u65	cmo1xc12i000ovxp01nisgvnu	39000	2026-04-16 20:46:36.926	2026-04-16 20:46:36.926
cmo1y9dok04yxvxt09pdig9ki	cmo1y9dmw04yhvxt03zug4u65	cmo1xc13o000tvxp0alok8jeb	39000	2026-04-16 20:46:36.933	2026-04-16 20:46:36.933
cmo1y9dou04yzvxt0pm76y01i	cmo1y9dmw04yhvxt03zug4u65	cmo1xc11n000kvxp0g32oj3wx	39000	2026-04-16 20:46:36.942	2026-04-16 20:46:36.942
cmo1y9dp104z1vxt0of62orz5	cmo1y9dmw04yhvxt03zug4u65	cmo1xc10u000hvxp0dapryn3r	39000	2026-04-16 20:46:36.949	2026-04-16 20:46:36.949
cmo1y9dp804z3vxt0wefe2fy8	cmo1y9dmw04yhvxt03zug4u65	cmo1xc119000jvxp01snwxzoa	39000	2026-04-16 20:46:36.956	2026-04-16 20:46:36.956
cmo1y9dpo04z7vxt0xo3uw87j	cmo1y9dph04z5vxt0nufw3sqb	cmo1xsgrt0022vxv8sd7cckj7	110000	2026-04-16 20:46:36.973	2026-04-16 20:46:36.973
cmo1y9dpx04z9vxt0ma9p1fsc	cmo1y9dph04z5vxt0nufw3sqb	cmo1xc11v000lvxp07r6uljko	110000	2026-04-16 20:46:36.981	2026-04-16 20:46:36.981
cmo1y9dq404zbvxt0lxnw9p60	cmo1y9dph04z5vxt0nufw3sqb	cmo1xc12y000qvxp0uqc7d8d8	110000	2026-04-16 20:46:36.989	2026-04-16 20:46:36.989
cmo1y9dqc04zdvxt0dp74cbqs	cmo1y9dph04z5vxt0nufw3sqb	cmo1xc13g000svxp0tbndc1wg	110000	2026-04-16 20:46:36.996	2026-04-16 20:46:36.996
cmo1y9dqo04zfvxt0n3tsjs2a	cmo1y9dph04z5vxt0nufw3sqb	cmo1xc12q000pvxp0kun82k4l	110000	2026-04-16 20:46:37.008	2026-04-16 20:46:37.008
cmo1y9dqw04zhvxt031u9embo	cmo1y9dph04z5vxt0nufw3sqb	cmo1xc138000rvxp0r16wi1bz	110000	2026-04-16 20:46:37.016	2026-04-16 20:46:37.016
cmo1y9dr204zjvxt0nl33a39f	cmo1y9dph04z5vxt0nufw3sqb	cmo1xc12i000ovxp01nisgvnu	110000	2026-04-16 20:46:37.022	2026-04-16 20:46:37.022
cmo1y9drc04zlvxt0hkfatpkw	cmo1y9dph04z5vxt0nufw3sqb	cmo1xc13o000tvxp0alok8jeb	110000	2026-04-16 20:46:37.032	2026-04-16 20:46:37.032
cmo1y9drl04znvxt0qckx5aqb	cmo1y9dph04z5vxt0nufw3sqb	cmo1xc11n000kvxp0g32oj3wx	110000	2026-04-16 20:46:37.041	2026-04-16 20:46:37.041
cmo1y9drs04zpvxt0yi20q9gu	cmo1y9dph04z5vxt0nufw3sqb	cmo1xc10u000hvxp0dapryn3r	110000	2026-04-16 20:46:37.049	2026-04-16 20:46:37.049
cmo1y9drz04zrvxt0kvkqa4nu	cmo1y9dph04z5vxt0nufw3sqb	cmo1xc119000jvxp01snwxzoa	110000	2026-04-16 20:46:37.056	2026-04-16 20:46:37.056
cmo1y9dsh04zvvxt0gyl1vqas	cmo1y9ds904ztvxt0glkz29nr	cmo1xsgrt0022vxv8sd7cckj7	42000	2026-04-16 20:46:37.073	2026-04-16 20:46:37.073
cmo1y9dsq04zxvxt05rov8lul	cmo1y9ds904ztvxt0glkz29nr	cmo1xc11v000lvxp07r6uljko	42000	2026-04-16 20:46:37.082	2026-04-16 20:46:37.082
cmo1y9dsw04zzvxt0znjrt5pa	cmo1y9ds904ztvxt0glkz29nr	cmo1xc12y000qvxp0uqc7d8d8	42000	2026-04-16 20:46:37.089	2026-04-16 20:46:37.089
cmo1y9dt50501vxt0905a3u9m	cmo1y9ds904ztvxt0glkz29nr	cmo1xc13g000svxp0tbndc1wg	42000	2026-04-16 20:46:37.098	2026-04-16 20:46:37.098
cmo1y9dtd0503vxt0zvds0ma8	cmo1y9ds904ztvxt0glkz29nr	cmo1xc12a000nvxp0f1zf3aqg	42000	2026-04-16 20:46:37.105	2026-04-16 20:46:37.105
cmo1y9dtk0505vxt0zc7sywn2	cmo1y9ds904ztvxt0glkz29nr	cmo1xc12q000pvxp0kun82k4l	42000	2026-04-16 20:46:37.112	2026-04-16 20:46:37.112
cmo1y9dts0507vxt0po5jwaew	cmo1y9ds904ztvxt0glkz29nr	cmo1xc138000rvxp0r16wi1bz	42000	2026-04-16 20:46:37.12	2026-04-16 20:46:37.12
cmo1y9dtz0509vxt0gb59sw95	cmo1y9ds904ztvxt0glkz29nr	cmo1xc12i000ovxp01nisgvnu	42000	2026-04-16 20:46:37.127	2026-04-16 20:46:37.127
cmo1y9du5050bvxt0rr3jmo37	cmo1y9ds904ztvxt0glkz29nr	cmo1xc13o000tvxp0alok8jeb	42000	2026-04-16 20:46:37.133	2026-04-16 20:46:37.133
cmo1y9dub050dvxt0gcqozmt2	cmo1y9ds904ztvxt0glkz29nr	cmo1xc123000mvxp0ul7pkio2	42000	2026-04-16 20:46:37.139	2026-04-16 20:46:37.139
cmo1y9duk050fvxt0ifxtz1id	cmo1y9ds904ztvxt0glkz29nr	cmo1xc11n000kvxp0g32oj3wx	42000	2026-04-16 20:46:37.148	2026-04-16 20:46:37.148
cmo1y9dur050hvxt0kxmy1vl8	cmo1y9ds904ztvxt0glkz29nr	cmo1xc10u000hvxp0dapryn3r	42000	2026-04-16 20:46:37.155	2026-04-16 20:46:37.155
cmo1y9dv2050jvxt0hkesc594	cmo1y9ds904ztvxt0glkz29nr	cmo1xc119000jvxp01snwxzoa	42000	2026-04-16 20:46:37.166	2026-04-16 20:46:37.166
cmo1y9dvi050nvxt02n77o9h2	cmo1y9dv9050lvxt0exwwvuso	cmo1xsgrt0022vxv8sd7cckj7	82000	2026-04-16 20:46:37.182	2026-04-16 20:46:37.182
cmo1y9dvp050pvxt0sqkkk3q3	cmo1y9dv9050lvxt0exwwvuso	cmo1xc11v000lvxp07r6uljko	82000	2026-04-16 20:46:37.189	2026-04-16 20:46:37.189
cmo1y9dvy050rvxt0a7t96z6e	cmo1y9dv9050lvxt0exwwvuso	cmo1xc12y000qvxp0uqc7d8d8	82000	2026-04-16 20:46:37.198	2026-04-16 20:46:37.198
cmo1y9dw5050tvxt009fb8wqb	cmo1y9dv9050lvxt0exwwvuso	cmo1xc13g000svxp0tbndc1wg	82000	2026-04-16 20:46:37.205	2026-04-16 20:46:37.205
cmo1y9dwe050vvxt034zho5f4	cmo1y9dv9050lvxt0exwwvuso	cmo1xc12a000nvxp0f1zf3aqg	82000	2026-04-16 20:46:37.214	2026-04-16 20:46:37.214
cmo1y9dwl050xvxt0g2r9rbzd	cmo1y9dv9050lvxt0exwwvuso	cmo1xc12q000pvxp0kun82k4l	82000	2026-04-16 20:46:37.221	2026-04-16 20:46:37.221
cmo1y9dws050zvxt0e6c25ngy	cmo1y9dv9050lvxt0exwwvuso	cmo1xc138000rvxp0r16wi1bz	82000	2026-04-16 20:46:37.228	2026-04-16 20:46:37.228
cmo1y9dx10511vxt0c9vubi7l	cmo1y9dv9050lvxt0exwwvuso	cmo1xc12i000ovxp01nisgvnu	82000	2026-04-16 20:46:37.237	2026-04-16 20:46:37.237
cmo1y9dx90513vxt0qh6qj8c5	cmo1y9dv9050lvxt0exwwvuso	cmo1xc13o000tvxp0alok8jeb	82000	2026-04-16 20:46:37.245	2026-04-16 20:46:37.245
cmo1y9dxg0515vxt0hzjyzjoi	cmo1y9dv9050lvxt0exwwvuso	cmo1xc123000mvxp0ul7pkio2	82000	2026-04-16 20:46:37.253	2026-04-16 20:46:37.253
cmo1y9dxn0517vxt0hsu0tarl	cmo1y9dv9050lvxt0exwwvuso	cmo1xc11n000kvxp0g32oj3wx	82000	2026-04-16 20:46:37.26	2026-04-16 20:46:37.26
cmo1y9dxu0519vxt0yhwk212n	cmo1y9dv9050lvxt0exwwvuso	cmo1xc10u000hvxp0dapryn3r	82000	2026-04-16 20:46:37.266	2026-04-16 20:46:37.266
cmo1y9dy0051bvxt0aea7cfax	cmo1y9dv9050lvxt0exwwvuso	cmo1xc119000jvxp01snwxzoa	82000	2026-04-16 20:46:37.272	2026-04-16 20:46:37.272
cmo1y9dyg051fvxt0lfnbv16s	cmo1y9dy9051dvxt0k7erix33	cmo1xsgrt0022vxv8sd7cckj7	35000	2026-04-16 20:46:37.289	2026-04-16 20:46:37.289
cmo1y9dyp051hvxt0bk92t7v9	cmo1y9dy9051dvxt0k7erix33	cmo1xc11v000lvxp07r6uljko	35000	2026-04-16 20:46:37.297	2026-04-16 20:46:37.297
cmo1y9dyw051jvxt0fofsl1wv	cmo1y9dy9051dvxt0k7erix33	cmo1xc12y000qvxp0uqc7d8d8	35000	2026-04-16 20:46:37.304	2026-04-16 20:46:37.304
cmo1y9dz3051lvxt036hkqgn6	cmo1y9dy9051dvxt0k7erix33	cmo1xc13g000svxp0tbndc1wg	35000	2026-04-16 20:46:37.311	2026-04-16 20:46:37.311
cmo1y9dz9051nvxt0m35ccuze	cmo1y9dy9051dvxt0k7erix33	cmo1xc12a000nvxp0f1zf3aqg	35000	2026-04-16 20:46:37.318	2026-04-16 20:46:37.318
cmo1y9dzg051pvxt0mlkd1nia	cmo1y9dy9051dvxt0k7erix33	cmo1xc12q000pvxp0kun82k4l	35000	2026-04-16 20:46:37.325	2026-04-16 20:46:37.325
cmo1y9dzo051rvxt0nq5gxcax	cmo1y9dy9051dvxt0k7erix33	cmo1xc138000rvxp0r16wi1bz	35000	2026-04-16 20:46:37.332	2026-04-16 20:46:37.332
cmo1y9dzv051tvxt0shw39aj4	cmo1y9dy9051dvxt0k7erix33	cmo1xc12i000ovxp01nisgvnu	35000	2026-04-16 20:46:37.339	2026-04-16 20:46:37.339
cmo1y9e03051vvxt0h1nibqpq	cmo1y9dy9051dvxt0k7erix33	cmo1xc13o000tvxp0alok8jeb	35000	2026-04-16 20:46:37.348	2026-04-16 20:46:37.348
cmo1y9e0b051xvxt0133natm5	cmo1y9dy9051dvxt0k7erix33	cmo1xc123000mvxp0ul7pkio2	35000	2026-04-16 20:46:37.355	2026-04-16 20:46:37.355
cmo1y9e0j051zvxt05wjh7p6t	cmo1y9dy9051dvxt0k7erix33	cmo1xc11n000kvxp0g32oj3wx	35000	2026-04-16 20:46:37.363	2026-04-16 20:46:37.363
cmo1y9e0r0521vxt0zfp6aeh7	cmo1y9dy9051dvxt0k7erix33	cmo1xc10u000hvxp0dapryn3r	35000	2026-04-16 20:46:37.371	2026-04-16 20:46:37.371
cmo1y9e0y0523vxt06p9j0pco	cmo1y9dy9051dvxt0k7erix33	cmo1xc119000jvxp01snwxzoa	35000	2026-04-16 20:46:37.378	2026-04-16 20:46:37.378
cmo1y9e2a0529vxt0ue4cymzs	cmo1y9e200527vxt0yc5luoup	cmo1xc11v000lvxp07r6uljko	53000	2026-04-16 20:46:37.427	2026-04-16 20:46:37.427
cmo1y9e2z052bvxt0wpj83igh	cmo1y9e200527vxt0yc5luoup	cmo1xc10u000hvxp0dapryn3r	53000	2026-04-16 20:46:37.451	2026-04-16 20:46:37.451
cmo1y9e3e052fvxt0epa1l0sp	cmo1y9e38052dvxt0537e6vt2	cmo1xsgrt0022vxv8sd7cckj7	600000	2026-04-16 20:46:37.466	2026-04-16 20:46:37.466
cmo1y9e3m052hvxt0ezk37v8o	cmo1y9e38052dvxt0537e6vt2	cmo1xc11v000lvxp07r6uljko	600000	2026-04-16 20:46:37.474	2026-04-16 20:46:37.474
cmo1y9e42052jvxt0w7jpzmua	cmo1y9e38052dvxt0537e6vt2	cmo1xc12i000ovxp01nisgvnu	440000	2026-04-16 20:46:37.49	2026-04-16 20:46:37.49
cmo1y9e4e052lvxt0125v6vl7	cmo1y9e38052dvxt0537e6vt2	cmo1xc10u000hvxp0dapryn3r	600000	2026-04-16 20:46:37.502	2026-04-16 20:46:37.502
cmo1y9e5q052rvxt00oovwclu	cmo1y9e5g052pvxt0frgjcams	cmo1xc11v000lvxp07r6uljko	117000	2026-04-16 20:46:37.55	2026-04-16 20:46:37.55
cmo1y9e6a052tvxt0c269zwvc	cmo1y9e5g052pvxt0frgjcams	cmo1xc10u000hvxp0dapryn3r	117000	2026-04-16 20:46:37.57	2026-04-16 20:46:37.57
cmo1y9e6r052xvxt09nwcakoo	cmo1y9e6i052vvxt08q2fr1mc	cmo1xc11v000lvxp07r6uljko	366000	2026-04-16 20:46:37.587	2026-04-16 20:46:37.587
cmo1y9e7e052zvxt0bndkkwny	cmo1y9e6i052vvxt08q2fr1mc	cmo1xc10u000hvxp0dapryn3r	366000	2026-04-16 20:46:37.611	2026-04-16 20:46:37.611
cmo1y9e7s0533vxt0wxm4ad2h	cmo1y9e7l0531vxt0e18a6m5p	cmo1xsgrt0022vxv8sd7cckj7	32000	2026-04-16 20:46:37.625	2026-04-16 20:46:37.625
cmo1y9e800535vxt0fghvic6a	cmo1y9e7l0531vxt0e18a6m5p	cmo1xc11v000lvxp07r6uljko	32000	2026-04-16 20:46:37.632	2026-04-16 20:46:37.632
cmo1y9e8m0537vxt0tkwy2quj	cmo1y9e7l0531vxt0e18a6m5p	cmo1xc10u000hvxp0dapryn3r	32000	2026-04-16 20:46:37.654	2026-04-16 20:46:37.654
cmo1y9e96053bvxt0r7vhttf6	cmo1y9e8u0539vxt01bwx6qve	cmo1xsgrt0022vxv8sd7cckj7	38000	2026-04-16 20:46:37.674	2026-04-16 20:46:37.674
cmo1y9e9e053dvxt0cp7at868	cmo1y9e8u0539vxt01bwx6qve	cmo1xc11v000lvxp07r6uljko	38000	2026-04-16 20:46:37.682	2026-04-16 20:46:37.682
cmo1y9ea3053fvxt03xaxp8br	cmo1y9e8u0539vxt01bwx6qve	cmo1xc10u000hvxp0dapryn3r	38000	2026-04-16 20:46:37.707	2026-04-16 20:46:37.707
cmo1y9eal053jvxt08iasiacc	cmo1y9eae053hvxt0m28tm36o	cmo1xsgrt0022vxv8sd7cckj7	32000	2026-04-16 20:46:37.726	2026-04-16 20:46:37.726
cmo1y9eas053lvxt0c8ely7a9	cmo1y9eae053hvxt0m28tm36o	cmo1xc11v000lvxp07r6uljko	32000	2026-04-16 20:46:37.733	2026-04-16 20:46:37.733
cmo1y9ebd053nvxt09rd4u42s	cmo1y9eae053hvxt0m28tm36o	cmo1xc10u000hvxp0dapryn3r	32000	2026-04-16 20:46:37.753	2026-04-16 20:46:37.753
cmo1y9ecm053tvxt0a2folgvo	cmo1y9ecd053rvxt0aypyik1a	cmo1xsgrt0022vxv8sd7cckj7	83000	2026-04-16 20:46:37.798	2026-04-16 20:46:37.798
cmo1y9ect053vvxt0n7hxuavr	cmo1y9ecd053rvxt0aypyik1a	cmo1xc11v000lvxp07r6uljko	83000	2026-04-16 20:46:37.805	2026-04-16 20:46:37.805
cmo1y9edh053xvxt0n621opsz	cmo1y9ecd053rvxt0aypyik1a	cmo1xc10u000hvxp0dapryn3r	83000	2026-04-16 20:46:37.829	2026-04-16 20:46:37.829
cmo1y9ees0543vxt03zvw5e9w	cmo1y9eel0541vxt0bpc5zjfw	cmo1xsgrt0022vxv8sd7cckj7	59000	2026-04-16 20:46:37.876	2026-04-16 20:46:37.876
cmo1y9eey0545vxt0vf9c2f52	cmo1y9eel0541vxt0bpc5zjfw	cmo1xc11v000lvxp07r6uljko	59000	2026-04-16 20:46:37.883	2026-04-16 20:46:37.883
cmo1y9efk0547vxt04yhcub75	cmo1y9eel0541vxt0bpc5zjfw	cmo1xc10u000hvxp0dapryn3r	59000	2026-04-16 20:46:37.905	2026-04-16 20:46:37.905
cmo1y9eg2054bvxt0lno3qbso	cmo1y9efs0549vxt08fpgpu6c	cmo1xc11v000lvxp07r6uljko	432000	2026-04-16 20:46:37.922	2026-04-16 20:46:37.922
cmo1y9egs054dvxt0v1r89y0w	cmo1y9efs0549vxt08fpgpu6c	cmo1xc10u000hvxp0dapryn3r	432000	2026-04-16 20:46:37.948	2026-04-16 20:46:37.948
cmo1y9ehb054hvxt0ruetae84	cmo1y9eh1054fvxt0i2ay48sy	cmo1xc11v000lvxp07r6uljko	367000	2026-04-16 20:46:37.967	2026-04-16 20:46:37.967
cmo1y9ehx054jvxt0w21jcu3p	cmo1y9eh1054fvxt0i2ay48sy	cmo1xc10u000hvxp0dapryn3r	367000	2026-04-16 20:46:37.989	2026-04-16 20:46:37.989
cmo1y9eig054nvxt0kg4sttwh	cmo1y9ei8054lvxt0ix1buhj3	cmo1xsgrt0022vxv8sd7cckj7	135000	2026-04-16 20:46:38.008	2026-04-16 20:46:38.008
cmo1y9ein054pvxt0kf827092	cmo1y9ei8054lvxt0ix1buhj3	cmo1xc11v000lvxp07r6uljko	135000	2026-04-16 20:46:38.016	2026-04-16 20:46:38.016
cmo1y9ej9054rvxt0vw1lvgqs	cmo1y9ei8054lvxt0ix1buhj3	cmo1xc10u000hvxp0dapryn3r	135000	2026-04-16 20:46:38.038	2026-04-16 20:46:38.038
cmo1y9ejs054vvxt0raumqrnt	cmo1y9eji054tvxt0ehdz1kvb	cmo1xc11v000lvxp07r6uljko	395000	2026-04-16 20:46:38.056	2026-04-16 20:46:38.056
cmo1y9eki054xvxt0y2mlmcza	cmo1y9eji054tvxt0ehdz1kvb	cmo1xc10u000hvxp0dapryn3r	395000	2026-04-16 20:46:38.082	2026-04-16 20:46:38.082
cmo1y9ekz0551vxt0cn2irsw5	cmo1y9eks054zvxt03z4ry1u8	cmo1xsgrt0022vxv8sd7cckj7	95000	2026-04-16 20:46:38.1	2026-04-16 20:46:38.1
cmo1y9el60553vxt0gvqjr8ds	cmo1y9eks054zvxt03z4ry1u8	cmo1xc11v000lvxp07r6uljko	95000	2026-04-16 20:46:38.106	2026-04-16 20:46:38.106
cmo1y9ely0555vxt0dzjaf19h	cmo1y9eks054zvxt03z4ry1u8	cmo1xc10u000hvxp0dapryn3r	95000	2026-04-16 20:46:38.134	2026-04-16 20:46:38.134
cmo1y9emd0559vxt0mb2hs9r1	cmo1y9em70557vxt0n5qufst0	cmo1xsgrt0022vxv8sd7cckj7	50000	2026-04-16 20:46:38.15	2026-04-16 20:46:38.15
cmo1y9eml055bvxt0x9nlnd95	cmo1y9em70557vxt0n5qufst0	cmo1xc11v000lvxp07r6uljko	50000	2026-04-16 20:46:38.157	2026-04-16 20:46:38.157
cmo1y9en9055dvxt0hiv1jrir	cmo1y9em70557vxt0n5qufst0	cmo1xc10u000hvxp0dapryn3r	50000	2026-04-16 20:46:38.181	2026-04-16 20:46:38.181
cmo1y9enr055hvxt01g0hsupk	cmo1y9eni055fvxt03rm0mv6r	cmo1xsgrt0022vxv8sd7cckj7	50000	2026-04-16 20:46:38.199	2026-04-16 20:46:38.199
cmo1y9enx055jvxt0uuvk1j0x	cmo1y9eni055fvxt03rm0mv6r	cmo1xc11v000lvxp07r6uljko	50000	2026-04-16 20:46:38.205	2026-04-16 20:46:38.205
cmo1y9eol055lvxt0z2wlxkfl	cmo1y9eni055fvxt03rm0mv6r	cmo1xc10u000hvxp0dapryn3r	50000	2026-04-16 20:46:38.229	2026-04-16 20:46:38.229
cmo1y9ep5055pvxt0k6wqe5vj	cmo1y9eov055nvxt0uz8png1k	cmo1xsgrt0022vxv8sd7cckj7	400000	2026-04-16 20:46:38.249	2026-04-16 20:46:38.249
cmo1y9epb055rvxt091owg78q	cmo1y9eov055nvxt0uz8png1k	cmo1xc11v000lvxp07r6uljko	400000	2026-04-16 20:46:38.255	2026-04-16 20:46:38.255
cmo1y9epy055tvxt01tt67k4d	cmo1y9eov055nvxt0uz8png1k	cmo1xc10u000hvxp0dapryn3r	400000	2026-04-16 20:46:38.278	2026-04-16 20:46:38.278
cmo1y9eqc055xvxt0p1o4s9tj	cmo1y9eq5055vvxt03gy4fdxb	cmo1xsgrt0022vxv8sd7cckj7	460000	2026-04-16 20:46:38.292	2026-04-16 20:46:38.292
cmo1y9eqj055zvxt00w73tmbf	cmo1y9eq5055vvxt03gy4fdxb	cmo1xc11v000lvxp07r6uljko	460000	2026-04-16 20:46:38.299	2026-04-16 20:46:38.299
cmo1y9er50561vxt0ejkrjycc	cmo1y9eq5055vvxt03gy4fdxb	cmo1xc10u000hvxp0dapryn3r	460000	2026-04-16 20:46:38.321	2026-04-16 20:46:38.321
cmo1y9erl0565vxt0ed6h0hcp	cmo1y9erd0563vxt0t4tkyiej	cmo1xsgrt0022vxv8sd7cckj7	220000	2026-04-16 20:46:38.337	2026-04-16 20:46:38.337
cmo1y9ers0567vxt0ud1bs5nm	cmo1y9erd0563vxt0t4tkyiej	cmo1xc11v000lvxp07r6uljko	220000	2026-04-16 20:46:38.344	2026-04-16 20:46:38.344
cmo1y9esd0569vxt0qs5vjuzk	cmo1y9erd0563vxt0t4tkyiej	cmo1xc10u000hvxp0dapryn3r	220000	2026-04-16 20:46:38.366	2026-04-16 20:46:38.366
cmo1y9esw056dvxt005umu3j4	cmo1y9esn056bvxt0fptengvl	cmo1xc11v000lvxp07r6uljko	80000	2026-04-16 20:46:38.384	2026-04-16 20:46:38.384
cmo1y9eti056fvxt0a516dqis	cmo1y9esn056bvxt0fptengvl	cmo1xc10u000hvxp0dapryn3r	80000	2026-04-16 20:46:38.406	2026-04-16 20:46:38.406
cmo1y9eu3056jvxt09lt2xwy5	cmo1y9ett056hvxt0tqkezsi1	cmo1xc11v000lvxp07r6uljko	80000	2026-04-16 20:46:38.427	2026-04-16 20:46:38.427
cmo1y9euo056lvxt0om5ppbgy	cmo1y9ett056hvxt0tqkezsi1	cmo1xc10u000hvxp0dapryn3r	80000	2026-04-16 20:46:38.448	2026-04-16 20:46:38.448
cmo1y9ev6056pvxt0qd12ntum	cmo1y9euy056nvxt0x3jjuhx7	cmo1xsgrt0022vxv8sd7cckj7	220000	2026-04-16 20:46:38.466	2026-04-16 20:46:38.466
cmo1y9evc056rvxt0ji0tqcc9	cmo1y9euy056nvxt0x3jjuhx7	cmo1xc11v000lvxp07r6uljko	220000	2026-04-16 20:46:38.472	2026-04-16 20:46:38.472
cmo1y9evy056tvxt0w0i79wfc	cmo1y9euy056nvxt0x3jjuhx7	cmo1xc10u000hvxp0dapryn3r	220000	2026-04-16 20:46:38.495	2026-04-16 20:46:38.495
cmo1y9ewg056xvxt0fcuh4glq	cmo1y9ew8056vvxt0d76a8m94	cmo1xsgrt0022vxv8sd7cckj7	90000	2026-04-16 20:46:38.512	2026-04-16 20:46:38.512
cmo1y9ewo056zvxt0pv8xgndz	cmo1y9ew8056vvxt0d76a8m94	cmo1xc11v000lvxp07r6uljko	90000	2026-04-16 20:46:38.52	2026-04-16 20:46:38.52
cmo1y9ex90571vxt0hm7lag3n	cmo1y9ew8056vvxt0d76a8m94	cmo1xc10u000hvxp0dapryn3r	90000	2026-04-16 20:46:38.542	2026-04-16 20:46:38.542
cmo1y9eyo0577vxt0lh5l2uoa	cmo1y9eye0575vxt0s52hy23h	cmo1xc11v000lvxp07r6uljko	92000	2026-04-16 20:46:38.592	2026-04-16 20:46:38.592
cmo1y9ez90579vxt0o9nxw8w2	cmo1y9eye0575vxt0s52hy23h	cmo1xc10u000hvxp0dapryn3r	92000	2026-04-16 20:46:38.613	2026-04-16 20:46:38.613
cmo1y9ezv057dvxt08nbnq010	cmo1y9ezk057bvxt07byeb1av	cmo1xc11v000lvxp07r6uljko	38000	2026-04-16 20:46:38.635	2026-04-16 20:46:38.635
cmo1y9f0p057fvxt0t0k5y459	cmo1y9ezk057bvxt07byeb1av	cmo1xc10u000hvxp0dapryn3r	38000	2026-04-16 20:46:38.665	2026-04-16 20:46:38.665
cmo1y9f18057jvxt0i82trqg4	cmo1y9f0z057hvxt0s5jxwzoa	cmo1xc11v000lvxp07r6uljko	175000	2026-04-16 20:46:38.684	2026-04-16 20:46:38.684
cmo1y9f1x057lvxt0ha623vfa	cmo1y9f0z057hvxt0s5jxwzoa	cmo1xc10u000hvxp0dapryn3r	175000	2026-04-16 20:46:38.709	2026-04-16 20:46:38.709
cmo1y9f2d057pvxt0qezrh2z0	cmo1y9f25057nvxt00iajwzgk	cmo1xsgrt0022vxv8sd7cckj7	200000	2026-04-16 20:46:38.725	2026-04-16 20:46:38.725
cmo1y9f2l057rvxt00hurr3ig	cmo1y9f25057nvxt00iajwzgk	cmo1xc11v000lvxp07r6uljko	200000	2026-04-16 20:46:38.733	2026-04-16 20:46:38.733
cmo1y9f3d057tvxt0wdfwym3i	cmo1y9f25057nvxt00iajwzgk	cmo1xc10u000hvxp0dapryn3r	200000	2026-04-16 20:46:38.761	2026-04-16 20:46:38.761
cmo1y9f3y057xvxt0tylidn9v	cmo1y9f3q057vvxt0mfyx1z3n	cmo1xsgrt0022vxv8sd7cckj7	191000	2026-04-16 20:46:38.782	2026-04-16 20:46:38.782
cmo1y9f4e057zvxt02a36w7yb	cmo1y9f3q057vvxt0mfyx1z3n	cmo1xc12i000ovxp01nisgvnu	191000	2026-04-16 20:46:38.799	2026-04-16 20:46:38.799
cmo1y9f590583vxt0k5oueqyo	cmo1y9f4r0581vxt0bevro4gx	cmo1xc12i000ovxp01nisgvnu	15000	2026-04-16 20:46:38.829	2026-04-16 20:46:38.829
cmo1y9f6j0589vxt0o0sttd81	cmo1y9f6c0587vxt0ia8x56c5	cmo1xsgrt0022vxv8sd7cckj7	234000	2026-04-16 20:46:38.875	2026-04-16 20:46:38.875
cmo1y9f6q058bvxt0yruvlc47	cmo1y9f6c0587vxt0ia8x56c5	cmo1xc11v000lvxp07r6uljko	234000	2026-04-16 20:46:38.882	2026-04-16 20:46:38.882
cmo1y9f72058dvxt0jmg94bi7	cmo1y9f6c0587vxt0ia8x56c5	cmo1xc138000rvxp0r16wi1bz	234000	2026-04-16 20:46:38.894	2026-04-16 20:46:38.894
cmo1y9f77058fvxt084qigcle	cmo1y9f6c0587vxt0ia8x56c5	cmo1xc12i000ovxp01nisgvnu	178000	2026-04-16 20:46:38.9	2026-04-16 20:46:38.9
cmo1y9f7i058hvxt0abdxmqg1	cmo1y9f6c0587vxt0ia8x56c5	cmo1xc10u000hvxp0dapryn3r	234000	2026-04-16 20:46:38.911	2026-04-16 20:46:38.911
cmo1y9f7o058jvxt021yqm40u	cmo1y9f6c0587vxt0ia8x56c5	cmo1xc119000jvxp01snwxzoa	202000	2026-04-16 20:46:38.916	2026-04-16 20:46:38.916
cmo1y9f84058nvxt0aht6pofa	cmo1y9f7u058lvxt0ibjm1o4g	cmo1xsgrt0022vxv8sd7cckj7	234000	2026-04-16 20:46:38.932	2026-04-16 20:46:38.932
cmo1y9f8a058pvxt08ukkrh67	cmo1y9f7u058lvxt0ibjm1o4g	cmo1xc11v000lvxp07r6uljko	234000	2026-04-16 20:46:38.939	2026-04-16 20:46:38.939
cmo1y9f8o058rvxt0wr7b1ls8	cmo1y9f7u058lvxt0ibjm1o4g	cmo1xc138000rvxp0r16wi1bz	234000	2026-04-16 20:46:38.953	2026-04-16 20:46:38.953
cmo1y9f8v058tvxt0d7p30sdx	cmo1y9f7u058lvxt0ibjm1o4g	cmo1xc12i000ovxp01nisgvnu	148000	2026-04-16 20:46:38.96	2026-04-16 20:46:38.96
cmo1y9f95058vvxt0uzz2bws6	cmo1y9f7u058lvxt0ibjm1o4g	cmo1xc10u000hvxp0dapryn3r	234000	2026-04-16 20:46:38.97	2026-04-16 20:46:38.97
cmo1y9f9c058xvxt0c3lv15tw	cmo1y9f7u058lvxt0ibjm1o4g	cmo1xc119000jvxp01snwxzoa	202000	2026-04-16 20:46:38.976	2026-04-16 20:46:38.976
cmo1y9f9r0591vxt0wa0w971m	cmo1y9f9j058zvxt0sc7yz347	cmo1xsgrt0022vxv8sd7cckj7	234000	2026-04-16 20:46:38.991	2026-04-16 20:46:38.991
cmo1y9fa00593vxt0oe92ambv	cmo1y9f9j058zvxt0sc7yz347	cmo1xc11v000lvxp07r6uljko	234000	2026-04-16 20:46:39	2026-04-16 20:46:39
cmo1y9fag0595vxt0lnzwoa6m	cmo1y9f9j058zvxt0sc7yz347	cmo1xc138000rvxp0r16wi1bz	234000	2026-04-16 20:46:39.016	2026-04-16 20:46:39.016
cmo1y9fan0597vxt046jqw3ay	cmo1y9f9j058zvxt0sc7yz347	cmo1xc12i000ovxp01nisgvnu	168000	2026-04-16 20:46:39.023	2026-04-16 20:46:39.023
cmo1y9fb00599vxt07vpkvc76	cmo1y9f9j058zvxt0sc7yz347	cmo1xc10u000hvxp0dapryn3r	234000	2026-04-16 20:46:39.036	2026-04-16 20:46:39.036
cmo1y9fb7059bvxt0tmuphg05	cmo1y9f9j058zvxt0sc7yz347	cmo1xc119000jvxp01snwxzoa	202000	2026-04-16 20:46:39.043	2026-04-16 20:46:39.043
cmo1y9fbl059fvxt0s9g2577m	cmo1y9fbe059dvxt04ijh3f89	cmo1xsgrt0022vxv8sd7cckj7	234000	2026-04-16 20:46:39.057	2026-04-16 20:46:39.057
cmo1y9fbt059hvxt0hrh7km6i	cmo1y9fbe059dvxt04ijh3f89	cmo1xc11v000lvxp07r6uljko	234000	2026-04-16 20:46:39.066	2026-04-16 20:46:39.066
cmo1y9fca059jvxt02wl270g5	cmo1y9fbe059dvxt04ijh3f89	cmo1xc138000rvxp0r16wi1bz	234000	2026-04-16 20:46:39.082	2026-04-16 20:46:39.082
cmo1y9fcq059lvxt0pxp6tc81	cmo1y9fbe059dvxt04ijh3f89	cmo1xc10u000hvxp0dapryn3r	234000	2026-04-16 20:46:39.098	2026-04-16 20:46:39.098
cmo1y9fcx059nvxt0p06v47mi	cmo1y9fbe059dvxt04ijh3f89	cmo1xc119000jvxp01snwxzoa	202000	2026-04-16 20:46:39.106	2026-04-16 20:46:39.106
cmo1y9fde059rvxt0mhpg4el8	cmo1y9fd7059pvxt0h30040k7	cmo1xsgrt0022vxv8sd7cckj7	234000	2026-04-16 20:46:39.122	2026-04-16 20:46:39.122
cmo1y9fdn059tvxt04j93d34c	cmo1y9fd7059pvxt0h30040k7	cmo1xc11v000lvxp07r6uljko	234000	2026-04-16 20:46:39.131	2026-04-16 20:46:39.131
cmo1y9fe4059vvxt0aesklq5s	cmo1y9fd7059pvxt0h30040k7	cmo1xc138000rvxp0r16wi1bz	234000	2026-04-16 20:46:39.149	2026-04-16 20:46:39.149
cmo1y9feb059xvxt067jslsmj	cmo1y9fd7059pvxt0h30040k7	cmo1xc12i000ovxp01nisgvnu	168000	2026-04-16 20:46:39.155	2026-04-16 20:46:39.155
cmo1y9fep059zvxt06tolmiol	cmo1y9fd7059pvxt0h30040k7	cmo1xc10u000hvxp0dapryn3r	234000	2026-04-16 20:46:39.169	2026-04-16 20:46:39.169
cmo1y9few05a1vxt0iwpatsqv	cmo1y9fd7059pvxt0h30040k7	cmo1xc119000jvxp01snwxzoa	202000	2026-04-16 20:46:39.176	2026-04-16 20:46:39.176
cmo1y9ffa05a5vxt0pe2kq1vd	cmo1y9ff305a3vxt0cexvwprm	cmo1xsgrt0022vxv8sd7cckj7	234000	2026-04-16 20:46:39.19	2026-04-16 20:46:39.19
cmo1y9ffi05a7vxt0vnb2m9fy	cmo1y9ff305a3vxt0cexvwprm	cmo1xc11v000lvxp07r6uljko	234000	2026-04-16 20:46:39.198	2026-04-16 20:46:39.198
cmo1y9ffz05a9vxt0zlyy0vvo	cmo1y9ff305a3vxt0cexvwprm	cmo1xc138000rvxp0r16wi1bz	234000	2026-04-16 20:46:39.215	2026-04-16 20:46:39.215
cmo1y9fgf05abvxt0cx8tygqt	cmo1y9ff305a3vxt0cexvwprm	cmo1xc10u000hvxp0dapryn3r	234000	2026-04-16 20:46:39.231	2026-04-16 20:46:39.231
cmo1y9fgn05advxt092v5t0is	cmo1y9ff305a3vxt0cexvwprm	cmo1xc119000jvxp01snwxzoa	202000	2026-04-16 20:46:39.239	2026-04-16 20:46:39.239
cmo1y9fh405ahvxt021rlidtl	cmo1y9fgx05afvxt0kxow93y3	cmo1xsgrt0022vxv8sd7cckj7	234000	2026-04-16 20:46:39.256	2026-04-16 20:46:39.256
cmo1y9fhd05ajvxt0f00ip9hl	cmo1y9fgx05afvxt0kxow93y3	cmo1xc11v000lvxp07r6uljko	234000	2026-04-16 20:46:39.264	2026-04-16 20:46:39.264
cmo1y9fhr05alvxt0pv43xuxa	cmo1y9fgx05afvxt0kxow93y3	cmo1xc138000rvxp0r16wi1bz	234000	2026-04-16 20:46:39.279	2026-04-16 20:46:39.279
cmo1y9fi705anvxt0c6nsjlwc	cmo1y9fgx05afvxt0kxow93y3	cmo1xc10u000hvxp0dapryn3r	234000	2026-04-16 20:46:39.295	2026-04-16 20:46:39.295
cmo1y9fif05apvxt0pfxputf1	cmo1y9fgx05afvxt0kxow93y3	cmo1xc119000jvxp01snwxzoa	202000	2026-04-16 20:46:39.304	2026-04-16 20:46:39.304
cmo1y9fit05atvxt0h8723uss	cmo1y9fin05arvxt0bo9wzwfi	cmo1xsgrt0022vxv8sd7cckj7	244000	2026-04-16 20:46:39.318	2026-04-16 20:46:39.318
cmo1y9fj105avvxt03gfvprou	cmo1y9fin05arvxt0bo9wzwfi	cmo1xc11v000lvxp07r6uljko	244000	2026-04-16 20:46:39.325	2026-04-16 20:46:39.325
cmo1y9fjf05axvxt055o6klt0	cmo1y9fin05arvxt0bo9wzwfi	cmo1xc138000rvxp0r16wi1bz	244000	2026-04-16 20:46:39.339	2026-04-16 20:46:39.339
cmo1y9fjm05azvxt0ibvw6yyl	cmo1y9fin05arvxt0bo9wzwfi	cmo1xc12i000ovxp01nisgvnu	178000	2026-04-16 20:46:39.346	2026-04-16 20:46:39.346
cmo1y9fk105b1vxt0318vluu2	cmo1y9fin05arvxt0bo9wzwfi	cmo1xc10u000hvxp0dapryn3r	244000	2026-04-16 20:46:39.361	2026-04-16 20:46:39.361
cmo1y9fk705b3vxt0nciu0qyc	cmo1y9fin05arvxt0bo9wzwfi	cmo1xc119000jvxp01snwxzoa	212000	2026-04-16 20:46:39.367	2026-04-16 20:46:39.367
cmo1y9fkm05b7vxt0k48xx7vc	cmo1y9fke05b5vxt0lal4ug8f	cmo1xsgrt0022vxv8sd7cckj7	191000	2026-04-16 20:46:39.382	2026-04-16 20:46:39.382
cmo1y9fkt05b9vxt0eg0frpyp	cmo1y9fke05b5vxt0lal4ug8f	cmo1xc11v000lvxp07r6uljko	191000	2026-04-16 20:46:39.389	2026-04-16 20:46:39.389
cmo1y9fl705bbvxt0okic2n6r	cmo1y9fke05b5vxt0lal4ug8f	cmo1xc138000rvxp0r16wi1bz	191000	2026-04-16 20:46:39.404	2026-04-16 20:46:39.404
cmo1y9flf05bdvxt0r0kz3v3x	cmo1y9fke05b5vxt0lal4ug8f	cmo1xc12i000ovxp01nisgvnu	158000	2026-04-16 20:46:39.412	2026-04-16 20:46:39.412
cmo1y9flu05bfvxt00ktnuhxv	cmo1y9fke05b5vxt0lal4ug8f	cmo1xc10u000hvxp0dapryn3r	191000	2026-04-16 20:46:39.426	2026-04-16 20:46:39.426
cmo1y9fm105bhvxt0c5f7t91y	cmo1y9fke05b5vxt0lal4ug8f	cmo1xc119000jvxp01snwxzoa	159000	2026-04-16 20:46:39.433	2026-04-16 20:46:39.433
cmo1y9fmh05blvxt0h0125jio	cmo1y9fm805bjvxt0o0ix17v8	cmo1xsgrt0022vxv8sd7cckj7	202000	2026-04-16 20:46:39.449	2026-04-16 20:46:39.449
cmo1y9fmo05bnvxt04ixfoi0u	cmo1y9fm805bjvxt0o0ix17v8	cmo1xc11v000lvxp07r6uljko	202000	2026-04-16 20:46:39.456	2026-04-16 20:46:39.456
cmo1y9fn305bpvxt06t6dy01k	cmo1y9fm805bjvxt0o0ix17v8	cmo1xc138000rvxp0r16wi1bz	202000	2026-04-16 20:46:39.471	2026-04-16 20:46:39.471
cmo1y9fnh05brvxt0dx7hdmcf	cmo1y9fm805bjvxt0o0ix17v8	cmo1xc10u000hvxp0dapryn3r	202000	2026-04-16 20:46:39.485	2026-04-16 20:46:39.485
cmo1y9fno05btvxt0l2e4a2ag	cmo1y9fm805bjvxt0o0ix17v8	cmo1xc119000jvxp01snwxzoa	170000	2026-04-16 20:46:39.492	2026-04-16 20:46:39.492
cmo1y9fo505bxvxt05810vsf2	cmo1y9fnw05bvvxt05ra2lqpd	cmo1xsgrt0022vxv8sd7cckj7	202000	2026-04-16 20:46:39.509	2026-04-16 20:46:39.509
cmo1y9foc05bzvxt0c0hcidgy	cmo1y9fnw05bvvxt05ra2lqpd	cmo1xc11v000lvxp07r6uljko	202000	2026-04-16 20:46:39.517	2026-04-16 20:46:39.517
cmo1y9fou05c1vxt0b3aj815q	cmo1y9fnw05bvvxt05ra2lqpd	cmo1xc138000rvxp0r16wi1bz	202000	2026-04-16 20:46:39.534	2026-04-16 20:46:39.534
cmo1y9fpa05c3vxt0ih9byzxt	cmo1y9fnw05bvvxt05ra2lqpd	cmo1xc10u000hvxp0dapryn3r	202000	2026-04-16 20:46:39.551	2026-04-16 20:46:39.551
cmo1y9fpi05c5vxt0x2nryekk	cmo1y9fnw05bvvxt05ra2lqpd	cmo1xc119000jvxp01snwxzoa	170000	2026-04-16 20:46:39.558	2026-04-16 20:46:39.558
cmo1y9fpy05c9vxt082w6px6o	cmo1y9fpr05c7vxt00y7f3tn4	cmo1xsgrt0022vxv8sd7cckj7	234000	2026-04-16 20:46:39.575	2026-04-16 20:46:39.575
cmo1y9fq605cbvxt08wbrfd5c	cmo1y9fpr05c7vxt00y7f3tn4	cmo1xc11v000lvxp07r6uljko	234000	2026-04-16 20:46:39.583	2026-04-16 20:46:39.583
cmo1y9fqo05cdvxt0unnvu4j2	cmo1y9fpr05c7vxt00y7f3tn4	cmo1xc138000rvxp0r16wi1bz	234000	2026-04-16 20:46:39.6	2026-04-16 20:46:39.6
cmo1y9fr705cfvxt0f86ywm2t	cmo1y9fpr05c7vxt00y7f3tn4	cmo1xc10u000hvxp0dapryn3r	234000	2026-04-16 20:46:39.619	2026-04-16 20:46:39.619
cmo1y9fre05chvxt08ja3fedd	cmo1y9fpr05c7vxt00y7f3tn4	cmo1xc119000jvxp01snwxzoa	202000	2026-04-16 20:46:39.627	2026-04-16 20:46:39.627
cmo1y9frs05clvxt0ds6o6azq	cmo1y9frl05cjvxt0wl6v6c0y	cmo1xsgrt0022vxv8sd7cckj7	191000	2026-04-16 20:46:39.641	2026-04-16 20:46:39.641
cmo1y9fs105cnvxt0hl9pbxq8	cmo1y9frl05cjvxt0wl6v6c0y	cmo1xc11v000lvxp07r6uljko	191000	2026-04-16 20:46:39.649	2026-04-16 20:46:39.649
cmo1y9fsi05cpvxt0vwq99s5q	cmo1y9frl05cjvxt0wl6v6c0y	cmo1xc138000rvxp0r16wi1bz	191000	2026-04-16 20:46:39.667	2026-04-16 20:46:39.667
cmo1y9fsx05crvxt0qlaxaf0k	cmo1y9frl05cjvxt0wl6v6c0y	cmo1xc10u000hvxp0dapryn3r	191000	2026-04-16 20:46:39.681	2026-04-16 20:46:39.681
cmo1y9ft605ctvxt03ba7d57c	cmo1y9frl05cjvxt0wl6v6c0y	cmo1xc119000jvxp01snwxzoa	159000	2026-04-16 20:46:39.69	2026-04-16 20:46:39.69
cmo1y9ftm05cxvxt0m6olqmq6	cmo1y9ftf05cvvxt0lmibgrxo	cmo1xsgrt0022vxv8sd7cckj7	191000	2026-04-16 20:46:39.707	2026-04-16 20:46:39.707
cmo1y9ftw05czvxt06yqxsst3	cmo1y9ftf05cvvxt0lmibgrxo	cmo1xc11v000lvxp07r6uljko	191000	2026-04-16 20:46:39.716	2026-04-16 20:46:39.716
cmo1y9fu905d1vxt0n9n78jg3	cmo1y9ftf05cvvxt0lmibgrxo	cmo1xc138000rvxp0r16wi1bz	191000	2026-04-16 20:46:39.729	2026-04-16 20:46:39.729
cmo1y9fuh05d3vxt0e52m1okr	cmo1y9ftf05cvvxt0lmibgrxo	cmo1xc12i000ovxp01nisgvnu	128000	2026-04-16 20:46:39.738	2026-04-16 20:46:39.738
cmo1y9fux05d5vxt0mveutdf0	cmo1y9ftf05cvvxt0lmibgrxo	cmo1xc10u000hvxp0dapryn3r	191000	2026-04-16 20:46:39.753	2026-04-16 20:46:39.753
cmo1y9fv505d7vxt06xx6z6ia	cmo1y9ftf05cvvxt0lmibgrxo	cmo1xc119000jvxp01snwxzoa	159000	2026-04-16 20:46:39.761	2026-04-16 20:46:39.761
cmo1y9fvl05dbvxt0cbdgaz2x	cmo1y9fvd05d9vxt0j5ypmgtl	cmo1xsgrt0022vxv8sd7cckj7	170000	2026-04-16 20:46:39.778	2026-04-16 20:46:39.778
cmo1y9fvt05ddvxt06x9lw1nl	cmo1y9fvd05d9vxt0j5ypmgtl	cmo1xc11v000lvxp07r6uljko	170000	2026-04-16 20:46:39.785	2026-04-16 20:46:39.785
cmo1y9fwb05dfvxt0a8ugzhro	cmo1y9fvd05d9vxt0j5ypmgtl	cmo1xc138000rvxp0r16wi1bz	170000	2026-04-16 20:46:39.803	2026-04-16 20:46:39.803
cmo1y9fwi05dhvxt0f7hewvg0	cmo1y9fvd05d9vxt0j5ypmgtl	cmo1xc12i000ovxp01nisgvnu	98000	2026-04-16 20:46:39.811	2026-04-16 20:46:39.811
cmo1y9fwq05djvxt0x88q4rz3	cmo1y9fvd05d9vxt0j5ypmgtl	cmo1xc10u000hvxp0dapryn3r	170000	2026-04-16 20:46:39.819	2026-04-16 20:46:39.819
cmo1y9fww05dlvxt0lqhjlhgi	cmo1y9fvd05d9vxt0j5ypmgtl	cmo1xc119000jvxp01snwxzoa	138000	2026-04-16 20:46:39.825	2026-04-16 20:46:39.825
cmo1y9fxa05dpvxt0h6e822cl	cmo1y9fx405dnvxt0orrd2m7l	cmo1xsgrt0022vxv8sd7cckj7	202000	2026-04-16 20:46:39.838	2026-04-16 20:46:39.838
cmo1y9fxh05drvxt0p8x75o4v	cmo1y9fx405dnvxt0orrd2m7l	cmo1xc11v000lvxp07r6uljko	202000	2026-04-16 20:46:39.845	2026-04-16 20:46:39.845
cmo1y9fxu05dtvxt0fhw53y0m	cmo1y9fx405dnvxt0orrd2m7l	cmo1xc138000rvxp0r16wi1bz	202000	2026-04-16 20:46:39.858	2026-04-16 20:46:39.858
cmo1y9fy405dvvxt0118i14t2	cmo1y9fx405dnvxt0orrd2m7l	cmo1xc10u000hvxp0dapryn3r	202000	2026-04-16 20:46:39.869	2026-04-16 20:46:39.869
cmo1y9fyb05dxvxt0joes4p84	cmo1y9fx405dnvxt0orrd2m7l	cmo1xc119000jvxp01snwxzoa	170000	2026-04-16 20:46:39.875	2026-04-16 20:46:39.875
cmo1y9fyo05e1vxt06zr1oud9	cmo1y9fyi05dzvxt0dmjt8j8l	cmo1xsgrt0022vxv8sd7cckj7	170000	2026-04-16 20:46:39.889	2026-04-16 20:46:39.889
cmo1y9fyx05e3vxt0gxnz1z22	cmo1y9fyi05dzvxt0dmjt8j8l	cmo1xc11v000lvxp07r6uljko	170000	2026-04-16 20:46:39.897	2026-04-16 20:46:39.897
cmo1y9fzp05e5vxt05tdxumq0	cmo1y9fyi05dzvxt0dmjt8j8l	cmo1xc138000rvxp0r16wi1bz	170000	2026-04-16 20:46:39.925	2026-04-16 20:46:39.925
cmo1y9g0105e7vxt0el2ukg5v	cmo1y9fyi05dzvxt0dmjt8j8l	cmo1xc10u000hvxp0dapryn3r	170000	2026-04-16 20:46:39.937	2026-04-16 20:46:39.937
cmo1y9g0705e9vxt02f6e414y	cmo1y9fyi05dzvxt0dmjt8j8l	cmo1xc119000jvxp01snwxzoa	138000	2026-04-16 20:46:39.944	2026-04-16 20:46:39.944
cmo1y9g0k05edvxt0cu9plt7b	cmo1y9g0d05ebvxt09qc7fq4v	cmo1xsgrt0022vxv8sd7cckj7	128000	2026-04-16 20:46:39.957	2026-04-16 20:46:39.957
cmo1y9g0t05efvxt0m60dfspc	cmo1y9g0d05ebvxt09qc7fq4v	cmo1xc11v000lvxp07r6uljko	128000	2026-04-16 20:46:39.965	2026-04-16 20:46:39.965
cmo1y9g1905ehvxt0hfulvers	cmo1y9g0d05ebvxt09qc7fq4v	cmo1xc138000rvxp0r16wi1bz	128000	2026-04-16 20:46:39.981	2026-04-16 20:46:39.981
cmo1y9g1g05ejvxt0twra7e93	cmo1y9g0d05ebvxt09qc7fq4v	cmo1xc12i000ovxp01nisgvnu	80000	2026-04-16 20:46:39.988	2026-04-16 20:46:39.988
cmo1y9g1u05elvxt0zg6j8isu	cmo1y9g0d05ebvxt09qc7fq4v	cmo1xc10u000hvxp0dapryn3r	128000	2026-04-16 20:46:40.002	2026-04-16 20:46:40.002
cmo1y9g2105envxt0zhh2kc94	cmo1y9g0d05ebvxt09qc7fq4v	cmo1xc119000jvxp01snwxzoa	96000	2026-04-16 20:46:40.009	2026-04-16 20:46:40.009
cmo1y9g2f05ervxt0nrb8m31e	cmo1y9g2805epvxt0jv1rqp4r	cmo1xsgrt0022vxv8sd7cckj7	43000	2026-04-16 20:46:40.023	2026-04-16 20:46:40.023
cmo1y9g2n05etvxt07b1lj2s2	cmo1y9g2805epvxt0jv1rqp4r	cmo1xc11v000lvxp07r6uljko	43000	2026-04-16 20:46:40.031	2026-04-16 20:46:40.031
cmo1y9g3305evvxt06pvn0vfc	cmo1y9g2805epvxt0jv1rqp4r	cmo1xc138000rvxp0r16wi1bz	43000	2026-04-16 20:46:40.047	2026-04-16 20:46:40.047
cmo1y9g3j05exvxt0oi7dauqb	cmo1y9g2805epvxt0jv1rqp4r	cmo1xc10u000hvxp0dapryn3r	43000	2026-04-16 20:46:40.063	2026-04-16 20:46:40.063
cmo1y9g3q05ezvxt048g2gs4c	cmo1y9g2805epvxt0jv1rqp4r	cmo1xc119000jvxp01snwxzoa	38000	2026-04-16 20:46:40.071	2026-04-16 20:46:40.071
cmo1y9g4305f3vxt0cl79292f	cmo1y9g3x05f1vxt05i1vbfi2	cmo1xsgrt0022vxv8sd7cckj7	234000	2026-04-16 20:46:40.084	2026-04-16 20:46:40.084
cmo1y9g4a05f5vxt03lk5wssb	cmo1y9g3x05f1vxt05i1vbfi2	cmo1xc11v000lvxp07r6uljko	234000	2026-04-16 20:46:40.09	2026-04-16 20:46:40.09
cmo1y9g4n05f7vxt0q65b63np	cmo1y9g3x05f1vxt05i1vbfi2	cmo1xc138000rvxp0r16wi1bz	234000	2026-04-16 20:46:40.103	2026-04-16 20:46:40.103
cmo1y9g5105f9vxt0jynmemyo	cmo1y9g3x05f1vxt05i1vbfi2	cmo1xc10u000hvxp0dapryn3r	234000	2026-04-16 20:46:40.117	2026-04-16 20:46:40.117
cmo1y9g5905fbvxt00kroiywh	cmo1y9g3x05f1vxt05i1vbfi2	cmo1xc119000jvxp01snwxzoa	212000	2026-04-16 20:46:40.125	2026-04-16 20:46:40.125
cmo1y9g6105ffvxt0hbdkfmq3	cmo1y9g5h05fdvxt0ny4qv458	cmo1xc12i000ovxp01nisgvnu	165000	2026-04-16 20:46:40.154	2026-04-16 20:46:40.154
cmo1y9g6n05fjvxt0k5mdpgbe	cmo1y9g6g05fhvxt05d510zna	cmo1xsgrt0022vxv8sd7cckj7	244000	2026-04-16 20:46:40.175	2026-04-16 20:46:40.175
cmo1y9g6u05flvxt0i0hn6p4i	cmo1y9g6g05fhvxt05d510zna	cmo1xc11v000lvxp07r6uljko	244000	2026-04-16 20:46:40.183	2026-04-16 20:46:40.183
cmo1y9g7b05fnvxt03rwyu9dp	cmo1y9g6g05fhvxt05d510zna	cmo1xc138000rvxp0r16wi1bz	244000	2026-04-16 20:46:40.199	2026-04-16 20:46:40.199
cmo1y9g7u05fpvxt0on6u4bj6	cmo1y9g6g05fhvxt05d510zna	cmo1xc10u000hvxp0dapryn3r	244000	2026-04-16 20:46:40.218	2026-04-16 20:46:40.218
cmo1y9g8105frvxt09mjq1sdw	cmo1y9g6g05fhvxt05d510zna	cmo1xc119000jvxp01snwxzoa	212000	2026-04-16 20:46:40.225	2026-04-16 20:46:40.225
cmo1y9g8g05fvvxt0b3u6rn9w	cmo1y9g8905ftvxt0dprrq3yk	cmo1xsgrt0022vxv8sd7cckj7	234000	2026-04-16 20:46:40.241	2026-04-16 20:46:40.241
cmo1y9g8p05fxvxt0bb3th9yu	cmo1y9g8905ftvxt0dprrq3yk	cmo1xc11v000lvxp07r6uljko	234000	2026-04-16 20:46:40.249	2026-04-16 20:46:40.249
cmo1y9g9705fzvxt0m6cc922m	cmo1y9g8905ftvxt0dprrq3yk	cmo1xc138000rvxp0r16wi1bz	234000	2026-04-16 20:46:40.268	2026-04-16 20:46:40.268
cmo1y9g9n05g1vxt0scqndt8v	cmo1y9g8905ftvxt0dprrq3yk	cmo1xc10u000hvxp0dapryn3r	234000	2026-04-16 20:46:40.283	2026-04-16 20:46:40.283
cmo1y9g9u05g3vxt0avqz5xlt	cmo1y9g8905ftvxt0dprrq3yk	cmo1xc119000jvxp01snwxzoa	202000	2026-04-16 20:46:40.29	2026-04-16 20:46:40.29
cmo1y9gaa05g7vxt0oix8bgrz	cmo1y9ga305g5vxt08e4v806g	cmo1xsgrt0022vxv8sd7cckj7	234000	2026-04-16 20:46:40.306	2026-04-16 20:46:40.306
cmo1y9gak05g9vxt0e3bu2u3n	cmo1y9ga305g5vxt08e4v806g	cmo1xc11v000lvxp07r6uljko	234000	2026-04-16 20:46:40.316	2026-04-16 20:46:40.316
cmo1y9gb205gbvxt0b7sxd5nu	cmo1y9ga305g5vxt08e4v806g	cmo1xc138000rvxp0r16wi1bz	234000	2026-04-16 20:46:40.334	2026-04-16 20:46:40.334
cmo1y9gbi05gdvxt0vrrfho6y	cmo1y9ga305g5vxt08e4v806g	cmo1xc10u000hvxp0dapryn3r	234000	2026-04-16 20:46:40.351	2026-04-16 20:46:40.351
cmo1y9gbq05gfvxt0hilkbylu	cmo1y9ga305g5vxt08e4v806g	cmo1xc119000jvxp01snwxzoa	212000	2026-04-16 20:46:40.358	2026-04-16 20:46:40.358
cmo1y9gc505gjvxt03ozictns	cmo1y9gby05ghvxt0kot7y3xw	cmo1xsgrt0022vxv8sd7cckj7	122000	2026-04-16 20:46:40.373	2026-04-16 20:46:40.373
cmo1y9gce05glvxt0m3fbbt2k	cmo1y9gby05ghvxt0kot7y3xw	cmo1xc11v000lvxp07r6uljko	122000	2026-04-16 20:46:40.382	2026-04-16 20:46:40.382
cmo1y9gcr05gnvxt0ppx8ip70	cmo1y9gby05ghvxt0kot7y3xw	cmo1xc138000rvxp0r16wi1bz	122000	2026-04-16 20:46:40.395	2026-04-16 20:46:40.395
cmo1y9gd705gpvxt0tl46ebkr	cmo1y9gby05ghvxt0kot7y3xw	cmo1xc10u000hvxp0dapryn3r	122000	2026-04-16 20:46:40.412	2026-04-16 20:46:40.412
cmo1y9gdf05grvxt0mkwx6dl2	cmo1y9gby05ghvxt0kot7y3xw	cmo1xc119000jvxp01snwxzoa	117000	2026-04-16 20:46:40.419	2026-04-16 20:46:40.419
cmo1y9ge305gvvxt0d8g07g0k	cmo1y9gdm05gtvxt0uveu6b50	cmo1xc12i000ovxp01nisgvnu	10000	2026-04-16 20:46:40.444	2026-04-16 20:46:40.444
cmo1y9geq05gzvxt0u8z9b3th	cmo1y9gej05gxvxt0n30e1qz9	cmo1xsgrt0022vxv8sd7cckj7	244000	2026-04-16 20:46:40.466	2026-04-16 20:46:40.466
cmo1y9gew05h1vxt0qio1c4xl	cmo1y9gej05gxvxt0n30e1qz9	cmo1xc11v000lvxp07r6uljko	244000	2026-04-16 20:46:40.472	2026-04-16 20:46:40.472
cmo1y9gfd05h3vxt0abfk5spf	cmo1y9gej05gxvxt0n30e1qz9	cmo1xc138000rvxp0r16wi1bz	244000	2026-04-16 20:46:40.489	2026-04-16 20:46:40.489
cmo1y9gfr05h5vxt0hb73ox6v	cmo1y9gej05gxvxt0n30e1qz9	cmo1xc10u000hvxp0dapryn3r	244000	2026-04-16 20:46:40.503	2026-04-16 20:46:40.503
cmo1y9gfx05h7vxt06jzm9n5h	cmo1y9gej05gxvxt0n30e1qz9	cmo1xc119000jvxp01snwxzoa	212000	2026-04-16 20:46:40.51	2026-04-16 20:46:40.51
cmo1y9ggi05hbvxt0vmhdbw1o	cmo1y9gg905h9vxt0xjaba1wb	cmo1xsgrt0022vxv8sd7cckj7	205000	2026-04-16 20:46:40.531	2026-04-16 20:46:40.531
cmo1y9ggp05hdvxt0wtivoy2v	cmo1y9gg905h9vxt0xjaba1wb	cmo1xc11v000lvxp07r6uljko	205000	2026-04-16 20:46:40.538	2026-04-16 20:46:40.538
cmo1y9gh405hfvxt08p3s4gc5	cmo1y9gg905h9vxt0xjaba1wb	cmo1xc138000rvxp0r16wi1bz	205000	2026-04-16 20:46:40.553	2026-04-16 20:46:40.553
cmo1y9ghj05hhvxt0ul6lyied	cmo1y9gg905h9vxt0xjaba1wb	cmo1xc10u000hvxp0dapryn3r	205000	2026-04-16 20:46:40.567	2026-04-16 20:46:40.567
cmo1y9ghz05hlvxt0l8wjul1f	cmo1y9ghs05hjvxt097bcs805	cmo1xsgrt0022vxv8sd7cckj7	106000	2026-04-16 20:46:40.583	2026-04-16 20:46:40.583
cmo1y9gi705hnvxt0lrds4ocr	cmo1y9ghs05hjvxt097bcs805	cmo1xc11v000lvxp07r6uljko	106000	2026-04-16 20:46:40.591	2026-04-16 20:46:40.591
cmo1y9gij05hpvxt000n8cttw	cmo1y9ghs05hjvxt097bcs805	cmo1xc138000rvxp0r16wi1bz	106000	2026-04-16 20:46:40.604	2026-04-16 20:46:40.604
cmo1y9giy05hrvxt04kgg8pyc	cmo1y9ghs05hjvxt097bcs805	cmo1xc10u000hvxp0dapryn3r	106000	2026-04-16 20:46:40.618	2026-04-16 20:46:40.618
cmo1y9gj605htvxt071u9wvhk	cmo1y9ghs05hjvxt097bcs805	cmo1xc119000jvxp01snwxzoa	101000	2026-04-16 20:46:40.626	2026-04-16 20:46:40.626
cmo1y9gjk05hxvxt00wc19wdi	cmo1y9gjd05hvvxt0ye4ssip7	cmo1xsgrt0022vxv8sd7cckj7	191000	2026-04-16 20:46:40.64	2026-04-16 20:46:40.64
cmo1y9gjs05hzvxt0lntvdzd8	cmo1y9gjd05hvvxt0ye4ssip7	cmo1xc11v000lvxp07r6uljko	191000	2026-04-16 20:46:40.649	2026-04-16 20:46:40.649
cmo1y9gk905i1vxt0nfr92nj7	cmo1y9gjd05hvvxt0ye4ssip7	cmo1xc138000rvxp0r16wi1bz	191000	2026-04-16 20:46:40.665	2026-04-16 20:46:40.665
cmo1y9gkr05i3vxt0asubvuvf	cmo1y9gjd05hvvxt0ye4ssip7	cmo1xc10u000hvxp0dapryn3r	191000	2026-04-16 20:46:40.683	2026-04-16 20:46:40.683
cmo1y9gkx05i5vxt0mb6avj9z	cmo1y9gjd05hvvxt0ye4ssip7	cmo1xc119000jvxp01snwxzoa	159000	2026-04-16 20:46:40.69	2026-04-16 20:46:40.69
cmo1y9gle05i9vxt0ghzx699w	cmo1y9gl705i7vxt0o0cpkzyg	cmo1xsgrt0022vxv8sd7cckj7	20000	2026-04-16 20:46:40.706	2026-04-16 20:46:40.706
cmo1y9gln05ibvxt01fwpz2em	cmo1y9gl705i7vxt0o0cpkzyg	cmo1xc11v000lvxp07r6uljko	20000	2026-04-16 20:46:40.715	2026-04-16 20:46:40.715
cmo1y9gm605idvxt0j6j0gq8h	cmo1y9gl705i7vxt0o0cpkzyg	cmo1xc138000rvxp0r16wi1bz	20000	2026-04-16 20:46:40.734	2026-04-16 20:46:40.734
cmo1y9gmm05ifvxt0jciis1f1	cmo1y9gl705i7vxt0o0cpkzyg	cmo1xc10u000hvxp0dapryn3r	20000	2026-04-16 20:46:40.75	2026-04-16 20:46:40.75
cmo1y9gn205ijvxt01brktc7o	cmo1y9gmv05ihvxt0y5t2goii	cmo1xsgrt0022vxv8sd7cckj7	170000	2026-04-16 20:46:40.766	2026-04-16 20:46:40.766
cmo1y9gn905ilvxt0y1wufjh2	cmo1y9gmv05ihvxt0y5t2goii	cmo1xc11v000lvxp07r6uljko	170000	2026-04-16 20:46:40.773	2026-04-16 20:46:40.773
cmo1y9gnp05invxt0veiv9j9b	cmo1y9gmv05ihvxt0y5t2goii	cmo1xc138000rvxp0r16wi1bz	170000	2026-04-16 20:46:40.789	2026-04-16 20:46:40.789
cmo1y9go905ipvxt0d91dohku	cmo1y9gmv05ihvxt0y5t2goii	cmo1xc10u000hvxp0dapryn3r	170000	2026-04-16 20:46:40.809	2026-04-16 20:46:40.809
cmo1y9goj05irvxt0k44mby11	cmo1y9gmv05ihvxt0y5t2goii	cmo1xc119000jvxp01snwxzoa	138000	2026-04-16 20:46:40.819	2026-04-16 20:46:40.819
cmo1y9gpl05ivvxt0xlm9b283	cmo1y9gos05itvxt0yuubvcin	cmo1xc119000jvxp01snwxzoa	340000	2026-04-16 20:46:40.857	2026-04-16 20:46:40.857
cmo1y9gqk05izvxt0941t3pza	cmo1y9gpt05ixvxt0elddv8in	cmo1xc119000jvxp01snwxzoa	310000	2026-04-16 20:46:40.893	2026-04-16 20:46:40.893
cmo1y9grp05j5vxt01m8ka2n3	cmo1y9gri05j3vxt0fkx3m8xt	cmo1xsgrt0022vxv8sd7cckj7	234000	2026-04-16 20:46:40.933	2026-04-16 20:46:40.933
cmo1y9grx05j7vxt03gdzfq07	cmo1y9gri05j3vxt0fkx3m8xt	cmo1xc11v000lvxp07r6uljko	234000	2026-04-16 20:46:40.941	2026-04-16 20:46:40.941
cmo1y9gs905j9vxt0xsz5hs7s	cmo1y9gri05j3vxt0fkx3m8xt	cmo1xc138000rvxp0r16wi1bz	234000	2026-04-16 20:46:40.953	2026-04-16 20:46:40.953
cmo1y9gsf05jbvxt0pxf43yon	cmo1y9gri05j3vxt0fkx3m8xt	cmo1xc12i000ovxp01nisgvnu	168000	2026-04-16 20:46:40.96	2026-04-16 20:46:40.96
cmo1y9gsl05jdvxt0wsov15ce	cmo1y9gri05j3vxt0fkx3m8xt	cmo1xc13o000tvxp0alok8jeb	200000	2026-04-16 20:46:40.966	2026-04-16 20:46:40.966
cmo1y9gss05jfvxt0s4z4uu3i	cmo1y9gri05j3vxt0fkx3m8xt	cmo1xc123000mvxp0ul7pkio2	200000	2026-04-16 20:46:40.972	2026-04-16 20:46:40.972
cmo1y9gt105jhvxt0vh6mynfi	cmo1y9gri05j3vxt0fkx3m8xt	cmo1xc10u000hvxp0dapryn3r	234000	2026-04-16 20:46:40.981	2026-04-16 20:46:40.981
cmo1y9gt705jjvxt0u3rzg8l3	cmo1y9gri05j3vxt0fkx3m8xt	cmo1xc119000jvxp01snwxzoa	202000	2026-04-16 20:46:40.988	2026-04-16 20:46:40.988
cmo1y9gug05jpvxt0crkf92ky	cmo1y9gu905jnvxt0931cc8sj	cmo1xsgrt0022vxv8sd7cckj7	234000	2026-04-16 20:46:41.032	2026-04-16 20:46:41.032
cmo1y9gun05jrvxt0o94gwgzj	cmo1y9gu905jnvxt0931cc8sj	cmo1xc11v000lvxp07r6uljko	234000	2026-04-16 20:46:41.039	2026-04-16 20:46:41.039
cmo1y9gv205jtvxt0hpwhl5om	cmo1y9gu905jnvxt0931cc8sj	cmo1xc138000rvxp0r16wi1bz	234000	2026-04-16 20:46:41.054	2026-04-16 20:46:41.054
cmo1y9gvf05jvvxt04hr62eqf	cmo1y9gu905jnvxt0931cc8sj	cmo1xc10u000hvxp0dapryn3r	234000	2026-04-16 20:46:41.067	2026-04-16 20:46:41.067
cmo1y9gvm05jxvxt0cey8iyr7	cmo1y9gu905jnvxt0931cc8sj	cmo1xc119000jvxp01snwxzoa	202000	2026-04-16 20:46:41.075	2026-04-16 20:46:41.075
cmo1y9gw205k1vxt0u6336rfh	cmo1y9gvu05jzvxt00cl191dv	cmo1xsgrt0022vxv8sd7cckj7	276000	2026-04-16 20:46:41.09	2026-04-16 20:46:41.09
cmo1y9gwa05k3vxt0uajgrn2p	cmo1y9gvu05jzvxt00cl191dv	cmo1xc11v000lvxp07r6uljko	276000	2026-04-16 20:46:41.098	2026-04-16 20:46:41.098
cmo1y9gwq05k5vxt03wbq5reu	cmo1y9gvu05jzvxt00cl191dv	cmo1xc138000rvxp0r16wi1bz	276000	2026-04-16 20:46:41.114	2026-04-16 20:46:41.114
cmo1y9gx505k7vxt0vdxf6ekf	cmo1y9gvu05jzvxt00cl191dv	cmo1xc10u000hvxp0dapryn3r	276000	2026-04-16 20:46:41.129	2026-04-16 20:46:41.129
cmo1y9gxd05k9vxt0qiruuh5h	cmo1y9gvu05jzvxt00cl191dv	cmo1xc119000jvxp01snwxzoa	256000	2026-04-16 20:46:41.138	2026-04-16 20:46:41.138
cmo1y9h0t05kjvxt05p2pduzz	cmo1y9h0905khvxt050ytqrcy	cmo1xc12i000ovxp01nisgvnu	225000	2026-04-16 20:46:41.261	2026-04-16 20:46:41.261
cmo1y9h2005knvxt01w871kzl	cmo1y9h1j05klvxt0dvqcfjo8	cmo1xc12i000ovxp01nisgvnu	85000	2026-04-16 20:46:41.304	2026-04-16 20:46:41.304
cmo1y9h3005krvxt06klpg95u	cmo1y9h2e05kpvxt0bux83ma7	cmo1xc119000jvxp01snwxzoa	350000	2026-04-16 20:46:41.341	2026-04-16 20:46:41.341
cmo1y9h3e05kvvxt015t6fog6	cmo1y9h3805ktvxt0ng0y4ffn	cmo1xsgrt0022vxv8sd7cckj7	234000	2026-04-16 20:46:41.355	2026-04-16 20:46:41.355
cmo1y9h3k05kxvxt083unsjq6	cmo1y9h3805ktvxt0ng0y4ffn	cmo1xc11v000lvxp07r6uljko	234000	2026-04-16 20:46:41.36	2026-04-16 20:46:41.36
cmo1y9h3u05kzvxt029oq7za4	cmo1y9h3805ktvxt0ng0y4ffn	cmo1xc138000rvxp0r16wi1bz	234000	2026-04-16 20:46:41.37	2026-04-16 20:46:41.37
cmo1y9h4505l1vxt0t16kflr8	cmo1y9h3805ktvxt0ng0y4ffn	cmo1xc10u000hvxp0dapryn3r	234000	2026-04-16 20:46:41.381	2026-04-16 20:46:41.381
cmo1y9h4c05l3vxt0xd85z7tn	cmo1y9h3805ktvxt0ng0y4ffn	cmo1xc119000jvxp01snwxzoa	202000	2026-04-16 20:46:41.388	2026-04-16 20:46:41.388
cmo1yameg0000vxu0w2npup46	cmo1y94xh02vvvxt0ag84ao9n	cmo1xsgrt0022vxv8sd7cckj7	120000	2026-04-16 20:47:34.889	2026-04-16 20:47:34.889
cmo1yameg0001vxu0uu8fwhqd	cmo1y94xh02vvvxt0ag84ao9n	cmo1xc10u000hvxp0dapryn3r	120000	2026-04-16 20:47:34.889	2026-04-16 20:47:34.889
cmo1yameg0002vxu0vg3i9wcq	cmo1y94xh02vvvxt0ag84ao9n	cmo1xc11v000lvxp07r6uljko	120000	2026-04-16 20:47:34.889	2026-04-16 20:47:34.889
cmo1yb1my0005vxu0kxhs068a	cmo1y8urr0097vxt0o8a2z4m2	cmo1xsgrt0022vxv8sd7cckj7	33600	2026-04-16 20:47:54.634	2026-04-16 20:47:54.634
cmo1yb1my0006vxu0fwlhsnc3	cmo1y8urr0097vxt0o8a2z4m2	cmo1xc10u000hvxp0dapryn3r	33600	2026-04-16 20:47:54.634	2026-04-16 20:47:54.634
cmo1yb1my0007vxu0zrd34iih	cmo1y8urr0097vxt0o8a2z4m2	cmo1xc11v000lvxp07r6uljko	33600	2026-04-16 20:47:54.634	2026-04-16 20:47:54.634
cmo1yb1my0008vxu0oly9cizj	cmo1y8urr0097vxt0o8a2z4m2	cmo1xc13o000tvxp0alok8jeb	33600	2026-04-16 20:47:54.634	2026-04-16 20:47:54.634
cmo1ybcqh000bvxu0ph5qnku4	cmo1y8ur40093vxt06xl2rkss	cmo1xsgrt0022vxv8sd7cckj7	42000	2026-04-16 20:48:09.017	2026-04-16 20:48:09.017
\.


--
-- Data for Name: products; Type: TABLE DATA; Schema: public; Owner: oms_user
--

COPY public.products (id, name, sku, "categoryId", unit, "retailPrice", "costPrice", weight, dimensions, "isActive", "createdAt", "updatedAt") FROM stdin;
cmo1y8tuw0001vxt0dsvpt8f1	Bí xanh khô (gói 50gr)	XUANLOC160	cmo1xc0tk0000vxp0m1od0byy	Gói	80000	\N	\N	\N	t	2026-04-16 20:46:11.24	2026-04-16 20:46:11.24
cmo1y8tw30009vxt0olpvrsao	Hạt ngũ cốc thanh xuân	XUANLOC167	cmo1xc0tk0000vxp0m1od0byy	Gói	93000	\N	\N	\N	t	2026-04-16 20:46:11.283	2026-04-16 20:46:11.283
cmo1y8ty8000xvxt0rxx8s0y8	Bột mè đen cửu chưng cửu sái (hủ 500gr)	XUANLOC155	cmo1xc0tk0000vxp0m1od0byy	Hủ	265000	\N	\N	\N	t	2026-04-16 20:46:11.36	2026-04-16 20:46:11.36
cmo1y8tz70015vxt0h2s7xepy	Hành tây trắng (củ nhỏ)	MOUNTAIN166	cmo1xc0ux0001vxp0gekkc5lr	Kg	63000	\N	\N	\N	t	2026-04-16 20:46:11.395	2026-04-16 20:46:11.395
cmo1y8u11001pvxt0j4rb9sxw	Xích tiểu đậu	MOUNTAIN165	cmo1xc0ux0001vxp0gekkc5lr	Kg	126000	\N	\N	\N	t	2026-04-16 20:46:11.461	2026-04-16 20:46:11.461
cmo1y8u38002fvxt0n4rymwyf	Cà chua	MOUNTAIN164	cmo1xc0ux0001vxp0gekkc5lr	Kg	57000	\N	\N	\N	t	2026-04-16 20:46:11.54	2026-04-16 20:46:11.54
cmo1y8u5a0035vxt05r79ntvj	Cao sâm 100gr	XUANLOC166	cmo1xc0tk0000vxp0m1od0byy	Hộp	508000	\N	\N	\N	t	2026-04-16 20:46:11.614	2026-04-16 20:46:11.614
cmo1y8u7d003rvxt05ljfbjw3	Nước chuối len men	XUANLOC165	cmo1xc0tk0000vxp0m1od0byy	Lít	0	\N	\N	\N	t	2026-04-16 20:46:11.689	2026-04-16 20:46:11.689
cmo1y8u8t003zvxt0takkufpe	Trà xích tiểu đậu (gói 250gr)	XUANLOC154	cmo1xc0tk0000vxp0m1od0byy	Gói	65000	\N	\N	\N	t	2026-04-16 20:46:11.742	2026-04-16 20:46:11.742
cmo1y8uay004nvxt0q8k52q8v	Tai heo	HANGTUOI71	cmo1xc0vc0002vxp0ro9otvn0	Kg	202000	\N	\N	\N	t	2026-04-16 20:46:11.818	2026-04-16 20:46:11.818
cmo1y8uc7004zvxt0t85jkibm	Bó xôi	MOUNTAIN163	cmo1xc0ux0001vxp0gekkc5lr	Kg	65000	\N	\N	\N	t	2026-04-16 20:46:11.863	2026-04-16 20:46:11.863
cmo1y8ue6005lvxt0k6ls88dr	Bột khoai lang chín (gói 100gr)	MOUNTAIN162	cmo1xc0ux0001vxp0gekkc5lr	Gói	59000	\N	\N	\N	t	2026-04-16 20:46:11.934	2026-04-16 20:46:11.934
cmo1y8ug90069vxt0izlrmf5q	Nước dâu tằm lên men (500ml)	XUANLOC153	cmo1xc0tk0000vxp0m1od0byy	Chai	0	\N	\N	\N	t	2026-04-16 20:46:12.009	2026-04-16 20:46:12.009
cmo1y8uh4006hvxt03iacknbz	Set quà Tết	XUANLOC0	cmo1xc0tk0000vxp0m1od0byy	Set	0	\N	\N	\N	t	2026-04-16 20:46:12.041	2026-04-16 20:46:12.041
cmo1y8uhm006jvxt088h99zp0	Bắp cải thảo	MOUNTAIN159	cmo1xc0ux0001vxp0gekkc5lr	Kg	57000	\N	\N	\N	t	2026-04-16 20:46:12.058	2026-04-16 20:46:12.058
cmo1y8ujr007bvxt0g5ais5q9	Thùng giấy	KHAC1	cmo1xc0vm0003vxp0pmlb0lvi	Kg	0	\N	\N	\N	t	2026-04-16 20:46:12.136	2026-04-16 20:46:12.136
cmo1y8uko007jvxt0pk3yj90z	Tiêu hạt	MOUNTAIN158	cmo1xc0ux0001vxp0gekkc5lr	Kg	0	\N	\N	\N	t	2026-04-16 20:46:12.168	2026-04-16 20:46:12.168
cmo1y8uln007rvxt01gbjuya8	Gói xông nhà	XLKHD13	cmo1xybh10000vxi4nigilgz5	Gói	22000	\N	\N	\N	t	2026-04-16 20:46:12.203	2026-04-16 20:46:12.203
cmo1y8umn007zvxt0r6es0wlg	Bắp cải (sú)	MOUNTAIN157	cmo1xc0ux0001vxp0gekkc5lr	Kg	57000	\N	\N	\N	t	2026-04-16 20:46:12.24	2026-04-16 20:46:12.24
cmo1y8usr009hvxt0o8nm88q7	Rượu nếp cẩm vắt	XLKHD12	cmo1xybh10000vxi4nigilgz5	Lít	258000	\N	\N	\N	t	2026-04-16 20:46:12.459	2026-04-16 20:46:12.459
cmo1y8uur00a5vxt0m3zxo614	Rượu nếp trắng vắt (chai nhựa 500ml)	XLKHD11	cmo1xybh10000vxi4nigilgz5	Lít	229000	\N	\N	\N	t	2026-04-16 20:46:12.531	2026-04-16 20:46:12.531
cmo1y8uwn00atvxt0wisf7v9h	Bánh chưng	XLKHD10	cmo1xybh10000vxi4nigilgz5	cây	0	\N	\N	\N	t	2026-04-16 20:46:12.599	2026-04-16 20:46:12.599
cmo1y8ux600avvxt0bgf641ib	Rượu nếp trắng	XLKHD9	cmo1xybh10000vxi4nigilgz5	Lít	70000	\N	\N	\N	t	2026-04-16 20:46:12.618	2026-04-16 20:46:12.618
cmo1y8uz300bjvxt0konvez9s	Rượu trắng 40 độ	XLKHD8	cmo1xybh10000vxi4nigilgz5	Kg	55000	\N	\N	\N	t	2026-04-16 20:46:12.687	2026-04-16 20:46:12.687
cmo1y8v1c00cbvxt0nc3hpngc	Rượu trắng 35 độ	XLKHD7	cmo1xybh10000vxi4nigilgz5	Kg	45000	\N	\N	\N	t	2026-04-16 20:46:12.769	2026-04-16 20:46:12.769
cmo1y8v3g00d3vxt09h6p2g5u	Rượu nếp trắng 40 độ	XLKHD6	cmo1xybh10000vxi4nigilgz5	Kg	65000	\N	\N	\N	t	2026-04-16 20:46:12.844	2026-04-16 20:46:12.844
cmo1y8v5l00dvvxt0mjjs0s68	Gói tắm thân lá khổ qua	XLKHD5	cmo1xybh10000vxi4nigilgz5	Gói	10000	\N	\N	\N	t	2026-04-16 20:46:12.921	2026-04-16 20:46:12.921
cmo1y8v6h00e3vxt03shcm5hh	Gói tắm (ngãi cứu,tía tô,lá sả, thân khổ qua, hương nhu, gừng)	XLKHD4	cmo1xybh10000vxi4nigilgz5	Gói	18000	\N	\N	\N	t	2026-04-16 20:46:12.953	2026-04-16 20:46:12.953
cmo1y8v7f00ebvxt0lsy6dkr7	Gừng xoa bóp có địa liền (500ml)	XLKHD3	cmo1xybh10000vxi4nigilgz5	Chai	70000	\N	\N	\N	t	2026-04-16 20:46:12.988	2026-04-16 20:46:12.988
cmo1y8v8j00elvxt0wzt8g1wq	Gừng xoa bóp (500ml)	XLKHD2	cmo1xybh10000vxi4nigilgz5	Chai	53000	\N	\N	\N	t	2026-04-16 20:46:13.027	2026-04-16 20:46:13.027
cmo1y8v9l00etvxt0h6qk5by0	Gói xông	XLKHD1	cmo1xybh10000vxi4nigilgz5	Gói	22000	\N	\N	\N	t	2026-04-16 20:46:13.065	2026-04-16 20:46:13.065
cmo1y8vaq00f1vxt0uuecxd2x	Tiêu hạt (gói 100gr)	MOUNTAIN156	cmo1xc0ux0001vxp0gekkc5lr	Gói	55000	\N	\N	\N	t	2026-04-16 20:46:13.107	2026-04-16 20:46:13.107
cmo1y8vcn00fpvxt0w44nr1n6	Mắc khén (gói 100gr)	MOUNTAIN155	cmo1xc0ux0001vxp0gekkc5lr	Gói	55000	\N	\N	\N	t	2026-04-16 20:46:13.175	2026-04-16 20:46:13.175
cmo1y8vel00gdvxt0un7jf1zq	Cà ri hạt (gói 100gr)	MOUNTAIN154	cmo1xc0ux0001vxp0gekkc5lr	Gói	47000	\N	\N	\N	t	2026-04-16 20:46:13.245	2026-04-16 20:46:13.245
cmo1y8vgk00h1vxt0a3cbpkhp	Gạo phối ngũ cốc (gói 100gr)	MOUNTAIN153	cmo1xc0ux0001vxp0gekkc5lr	Gói	19000	\N	\N	\N	t	2026-04-16 20:46:13.316	2026-04-16 20:46:13.316
cmo1y8vid00hpvxt086szwghf	Sét ăn dặm cho các bé (size nhỏ)	MOUNTAIN152	cmo1xc0ux0001vxp0gekkc5lr	Gói	207000	\N	\N	\N	t	2026-04-16 20:46:13.382	2026-04-16 20:46:13.382
cmo1y8vkb00idvxt0f9ycjm2s	Sét ăn dặm cho các bé (size lớn)	MOUNTAIN151	cmo1xc0ux0001vxp0gekkc5lr	Gói	260000	\N	\N	\N	t	2026-04-16 20:46:13.451	2026-04-16 20:46:13.451
cmo1y8vme00j1vxt05m7koqjf	Gạo ăn dặm (xà cơn,kê,bobo) gói 500gr	MOUNTAIN150	cmo1xc0ux0001vxp0gekkc5lr	Gói	84000	\N	\N	\N	t	2026-04-16 20:46:13.526	2026-04-16 20:46:13.526
cmo1y8vob00jpvxt0hi10fdjg	Sét hạt kê đậu xanh	MOUNTAIN149	cmo1xc0ux0001vxp0gekkc5lr	Gói	34000	\N	\N	\N	t	2026-04-16 20:46:13.596	2026-04-16 20:46:13.596
cmo1y8vq800kdvxt0axs7apif	Hạt ngũ cốc dưỡng huyết	MOUNTAIN148	cmo1xc0ux0001vxp0gekkc5lr	Gói	42000	\N	\N	\N	t	2026-04-16 20:46:13.664	2026-04-16 20:46:13.664
cmo1y8vs300l1vxt0zr62u4pg	Gạo mix baby	MOUNTAIN147	cmo1xc0ux0001vxp0gekkc5lr	Kg	92000	\N	\N	\N	t	2026-04-16 20:46:13.731	2026-04-16 20:46:13.731
cmo1y8vu400lpvxt0befifjlv	Gạo mix 15 loại đậu hạt	MOUNTAIN146	cmo1xc0ux0001vxp0gekkc5lr	Kg	95000	\N	\N	\N	t	2026-04-16 20:46:13.804	2026-04-16 20:46:13.804
cmo1y8vw000mdvxt02h16yow0	Tỏi	MOUNTAIN145	cmo1xc0ux0001vxp0gekkc5lr	Kg	185000	\N	\N	\N	t	2026-04-16 20:46:13.872	2026-04-16 20:46:13.872
cmo1y8vy300n3vxt05ses51vu	Gừng trâu	MOUNTAIN144	cmo1xc0ux0001vxp0gekkc5lr	Kg	72000	\N	\N	\N	t	2026-04-16 20:46:13.947	2026-04-16 20:46:13.947
cmo1y8w0m00nrvxt0x2nvtfbe	Gừng sẻ	MOUNTAIN143	cmo1xc0ux0001vxp0gekkc5lr	Kg	90000	\N	\N	\N	t	2026-04-16 20:46:14.038	2026-04-16 20:46:14.038
cmo1y8w3100ofvxt0cmzyx2hx	Nghệ	MOUNTAIN142	cmo1xc0ux0001vxp0gekkc5lr	Kg	57000	\N	\N	\N	t	2026-04-16 20:46:14.125	2026-04-16 20:46:14.125
cmo1y8w5m00p3vxt0wkv2naqp	Sả	MOUNTAIN141	cmo1xc0ux0001vxp0gekkc5lr	Kg	36000	\N	\N	\N	t	2026-04-16 20:46:14.218	2026-04-16 20:46:14.218
cmo1y8w8c00prvxt0yskiftu6	Hành tím khô	MOUNTAIN140	cmo1xc0ux0001vxp0gekkc5lr	Kg	172000	\N	\N	\N	t	2026-04-16 20:46:14.316	2026-04-16 20:46:14.316
cmo1y8ur40093vxt06xl2rkss	Khoai lang (nhỏ)	MFKHD2	cmo1xc0vw0004vxp0uzuqvrgw	Kg	0	\N	\N	\N	t	2026-04-16 20:46:12.4	2026-04-16 20:48:09.007
cmo1y8upt008vvxt0pcsob2i7	Cám	MFKHD4	cmo1xc0vw0004vxp0uzuqvrgw	Kg	15000	\N	\N	\N	t	2026-04-16 20:46:12.353	2026-04-16 20:48:41.084
cmo1y8upa008tvxt0c7jllzme	Đậu ve  (tặng)	MFKHD5	cmo1xc0vw0004vxp0uzuqvrgw	Kg	0	\N	\N	\N	t	2026-04-16 20:46:12.335	2026-04-16 20:48:58.766
cmo1y8uos008rvxt08zc3am4g	Dưa leo (tặng)	MFKHD6	cmo1xc0vw0004vxp0uzuqvrgw	Kg	0	\N	\N	\N	t	2026-04-16 20:46:12.317	2026-04-16 20:49:09.118
cmo1y8wab00qfvxt03zhcjaup	Hành tím tươi	MOUNTAIN139	cmo1xc0ux0001vxp0gekkc5lr	Kg	130000	\N	\N	\N	t	2026-04-16 20:46:14.387	2026-04-16 20:46:14.387
cmo1y8wcb00r3vxt0sjsosf6u	Hành tây tím	MOUNTAIN138	cmo1xc0ux0001vxp0gekkc5lr	Kg	75000	\N	\N	\N	t	2026-04-16 20:46:14.46	2026-04-16 20:46:14.46
cmo1y8wed00rrvxt01tm0werf	Hành tây trắng	MOUNTAIN137	cmo1xc0ux0001vxp0gekkc5lr	Kg	70000	\N	\N	\N	t	2026-04-16 20:46:14.533	2026-04-16 20:46:14.533
cmo1y8wgb00sfvxt0i44b5v69	Bí xanh	MOUNTAIN136	cmo1xc0ux0001vxp0gekkc5lr	Kg	42000	\N	\N	\N	t	2026-04-16 20:46:14.603	2026-04-16 20:46:14.603
cmo1y8wib00t3vxt0b6r4ebsb	Bầu	MOUNTAIN135	cmo1xc0ux0001vxp0gekkc5lr	Kg	42000	\N	\N	\N	t	2026-04-16 20:46:14.676	2026-04-16 20:46:14.676
cmo1y8wka00trvxt0rqxd6rlw	Bí đỏ	MOUNTAIN134	cmo1xc0ux0001vxp0gekkc5lr	Kg	42000	\N	\N	\N	t	2026-04-16 20:46:14.747	2026-04-16 20:46:14.747
cmo1y8wme00ufvxt0em9qyrr6	Bắp nếp	MOUNTAIN133	cmo1xc0ux0001vxp0gekkc5lr	Kg	43000	\N	\N	\N	t	2026-04-16 20:46:14.822	2026-04-16 20:46:14.822
cmo1y8wof00v3vxt0e3w3u351	Dưa Leo	MOUNTAIN132	cmo1xc0ux0001vxp0gekkc5lr	Kg	45000	\N	\N	\N	t	2026-04-16 20:46:14.895	2026-04-16 20:46:14.895
cmo1y8wql00vrvxt0gwd5bmby	Đậu ve	MOUNTAIN131	cmo1xc0ux0001vxp0gekkc5lr	Kg	48000	\N	\N	\N	t	2026-04-16 20:46:14.974	2026-04-16 20:46:14.974
cmo1y8wsn00wfvxt09e5fmfvs	Đậu đũa	MOUNTAIN130	cmo1xc0ux0001vxp0gekkc5lr	Kg	48000	\N	\N	\N	t	2026-04-16 20:46:15.048	2026-04-16 20:46:15.048
cmo1y8wuk00x3vxt08v9j8agn	Củ cải trắng	MOUNTAIN129	cmo1xc0ux0001vxp0gekkc5lr	Kg	40000	\N	\N	\N	t	2026-04-16 20:46:15.117	2026-04-16 20:46:15.117
cmo1y8wwj00xrvxt0f0i3wr7g	Củ cải trắng (có lá)	MOUNTAIN128	cmo1xc0ux0001vxp0gekkc5lr	Kg	37000	\N	\N	\N	t	2026-04-16 20:46:15.187	2026-04-16 20:46:15.187
cmo1y8wyk00yfvxt0ol3d74i9	Khoai môn	MOUNTAIN127	cmo1xc0ux0001vxp0gekkc5lr	Kg	72000	\N	\N	\N	t	2026-04-16 20:46:15.26	2026-04-16 20:46:15.26
cmo1y8x0u00z3vxt0btygbkru	Khoai sọ	MOUNTAIN126	cmo1xc0ux0001vxp0gekkc5lr	Kg	63000	\N	\N	\N	t	2026-04-16 20:46:15.342	2026-04-16 20:46:15.342
cmo1y8x3100zrvxt07m5qvex6	Khoai mỡ	MOUNTAIN125	cmo1xc0ux0001vxp0gekkc5lr	Kg	63000	\N	\N	\N	t	2026-04-16 20:46:15.421	2026-04-16 20:46:15.421
cmo1y8x51010fvxt0q8pp70ix	Khoai lang	MOUNTAIN124	cmo1xc0ux0001vxp0gekkc5lr	Kg	60000	\N	\N	\N	t	2026-04-16 20:46:15.494	2026-04-16 20:46:15.494
cmo1y8x7e0113vxt0zl8whfek	Mướp	MOUNTAIN123	cmo1xc0ux0001vxp0gekkc5lr	Kg	40000	\N	\N	\N	t	2026-04-16 20:46:15.578	2026-04-16 20:46:15.578
cmo1y8x9h011rvxt0h5ymd3tk	Ớt đỏ (chỉ thiên)	MOUNTAIN122	cmo1xc0ux0001vxp0gekkc5lr	Kg	72000	\N	\N	\N	t	2026-04-16 20:46:15.653	2026-04-16 20:46:15.653
cmo1y8xd7012fvxt0da1f3l79	Mồng tơi	MOUNTAIN121	cmo1xc0ux0001vxp0gekkc5lr	Kg	65000	\N	\N	\N	t	2026-04-16 20:46:15.787	2026-04-16 20:46:15.787
cmo1y8xgm0131vxt0mnesxbzq	Cải thìa	MOUNTAIN120	cmo1xc0ux0001vxp0gekkc5lr	Kg	65000	\N	\N	\N	t	2026-04-16 20:46:15.91	2026-04-16 20:46:15.91
cmo1y8xjs013nvxt0xw4wzeyz	Cải xanh	MOUNTAIN119	cmo1xc0ux0001vxp0gekkc5lr	Kg	65000	\N	\N	\N	t	2026-04-16 20:46:16.024	2026-04-16 20:46:16.024
cmo1y8xm80149vxt03hh8ej4j	Cải ngọt	MOUNTAIN118	cmo1xc0ux0001vxp0gekkc5lr	Kg	65000	\N	\N	\N	t	2026-04-16 20:46:16.112	2026-04-16 20:46:16.112
cmo1y8xoe014vvxt0bkay8nc7	Cải đuôi phụng	MOUNTAIN117	cmo1xc0ux0001vxp0gekkc5lr	Kg	65000	\N	\N	\N	t	2026-04-16 20:46:16.191	2026-04-16 20:46:16.191
cmo1y8xq9015hvxt07plyla5p	Cải cúc	MOUNTAIN116	cmo1xc0ux0001vxp0gekkc5lr	Kg	65000	\N	\N	\N	t	2026-04-16 20:46:16.257	2026-04-16 20:46:16.257
cmo1y8xt50163vxt091krdi4l	Rau ngót	MOUNTAIN115	cmo1xc0ux0001vxp0gekkc5lr	Kg	65000	\N	\N	\N	t	2026-04-16 20:46:16.361	2026-04-16 20:46:16.361
cmo1y8xus016pvxt05orr4o7i	Rau muống nước	MOUNTAIN114	cmo1xc0ux0001vxp0gekkc5lr	Kg	65000	\N	\N	\N	t	2026-04-16 20:46:16.42	2026-04-16 20:46:16.42
cmo1y8xwo017bvxt0o96cx10e	Rau dền	MOUNTAIN113	cmo1xc0ux0001vxp0gekkc5lr	Kg	65000	\N	\N	\N	t	2026-04-16 20:46:16.488	2026-04-16 20:46:16.488
cmo1y8xyi017xvxt0h6w860e1	Rau lang	MOUNTAIN112	cmo1xc0ux0001vxp0gekkc5lr	Kg	65000	\N	\N	\N	t	2026-04-16 20:46:16.554	2026-04-16 20:46:16.554
cmo1y8y09018jvxt02lu075nd	Tía tô	MOUNTAIN111	cmo1xc0ux0001vxp0gekkc5lr	Kg	86000	\N	\N	\N	t	2026-04-16 20:46:16.618	2026-04-16 20:46:16.618
cmo1y8y230195vxt0r5y4nvra	Hành lá	MOUNTAIN110	cmo1xc0ux0001vxp0gekkc5lr	Kg	86000	\N	\N	\N	t	2026-04-16 20:46:16.683	2026-04-16 20:46:16.683
cmo1y8y3x019rvxt05g6rmw49	Ngò rí	MOUNTAIN109	cmo1xc0ux0001vxp0gekkc5lr	Kg	93000	\N	\N	\N	t	2026-04-16 20:46:16.749	2026-04-16 20:46:16.749
cmo1y8y5q01advxt0rcpqr6j7	Nếp cẩm trồng đồi	MOUNTAIN108	cmo1xc0ux0001vxp0gekkc5lr	Kg	100000	\N	\N	\N	t	2026-04-16 20:46:16.815	2026-04-16 20:46:16.815
cmo1y8y8201b3vxt007da8tl5	Nếp than	MOUNTAIN107	cmo1xc0ux0001vxp0gekkc5lr	Kg	100000	\N	\N	\N	t	2026-04-16 20:46:16.898	2026-04-16 20:46:16.898
cmo1y8yaq01btvxt0myy9zubs	Nếp hoa vàng xát lứt	MOUNTAIN106	cmo1xc0ux0001vxp0gekkc5lr	Kg	75000	\N	\N	\N	t	2026-04-16 20:46:16.995	2026-04-16 20:46:16.995
cmo1y8ycq01chvxt0abcd4945	Nếp hoa vàng xát dối	MOUNTAIN105	cmo1xc0ux0001vxp0gekkc5lr	Kg	75000	\N	\N	\N	t	2026-04-16 20:46:17.066	2026-04-16 20:46:17.066
cmo1y8yeo01d5vxt0czhzmndd	Nếp hoa vàng xát trắng	MOUNTAIN104	cmo1xc0ux0001vxp0gekkc5lr	Kg	75000	\N	\N	\N	t	2026-04-16 20:46:17.136	2026-04-16 20:46:17.136
cmo1y8ygt01dvvxt0yc4kjbtw	Nếp nương xát lứt	MOUNTAIN103	cmo1xc0ux0001vxp0gekkc5lr	Kg	70000	\N	\N	\N	t	2026-04-16 20:46:17.213	2026-04-16 20:46:17.213
cmo1y8yiz01ejvxt0dn4hmk98	Nếp nương xát dối	MOUNTAIN102	cmo1xc0ux0001vxp0gekkc5lr	Kg	70000	\N	\N	\N	t	2026-04-16 20:46:17.292	2026-04-16 20:46:17.292
cmo1y8yl301f7vxt008720ged	Nếp nương xát trắng	MOUNTAIN101	cmo1xc0ux0001vxp0gekkc5lr	Kg	70000	\N	\N	\N	t	2026-04-16 20:46:17.368	2026-04-16 20:46:17.368
cmo1y8yn601fvvxt0q1veynrf	Nếp bắc xát lứt	MOUNTAIN100	cmo1xc0ux0001vxp0gekkc5lr	Kg	66000	\N	\N	\N	t	2026-04-16 20:46:17.442	2026-04-16 20:46:17.442
cmo1y8yp101gjvxt0pcmprmsf	Nếp bắc xát dối	MOUNTAIN99	cmo1xc0ux0001vxp0gekkc5lr	Kg	66000	\N	\N	\N	t	2026-04-16 20:46:17.509	2026-04-16 20:46:17.509
cmo1y8yr201h7vxt0vx725bdj	Nếp bắc xát trắng	MOUNTAIN98	cmo1xc0ux0001vxp0gekkc5lr	Kg	66000	\N	\N	\N	t	2026-04-16 20:46:17.583	2026-04-16 20:46:17.583
cmo1y8ysz01hvvxt0gph2wg0b	Gạo đỏ xưa xát lứt	MOUNTAIN97	cmo1xc0ux0001vxp0gekkc5lr	Kg	57000	\N	\N	\N	t	2026-04-16 20:46:17.651	2026-04-16 20:46:17.651
cmo1y8yuv01ijvxt0v8irnmlo	Gạo đỏ xưa xát dối	MOUNTAIN96	cmo1xc0ux0001vxp0gekkc5lr	Kg	57000	\N	\N	\N	t	2026-04-16 20:46:17.72	2026-04-16 20:46:17.72
cmo1y8yww01j7vxt0ilppuk7e	Gạo đỏ xưa xát trắng	MOUNTAIN95	cmo1xc0ux0001vxp0gekkc5lr	Kg	57000	\N	\N	\N	t	2026-04-16 20:46:17.792	2026-04-16 20:46:17.792
cmo1y8yyr01jvvxt0ig306jns	Gạo xà cơn trắng lứt	MOUNTAIN94	cmo1xc0ux0001vxp0gekkc5lr	Kg	57000	\N	\N	\N	t	2026-04-16 20:46:17.86	2026-04-16 20:46:17.86
cmo1y8z0p01kjvxt0k7zr13f1	Gạo xà cơn trắng dối	MOUNTAIN93	cmo1xc0ux0001vxp0gekkc5lr	Kg	57000	\N	\N	\N	t	2026-04-16 20:46:17.929	2026-04-16 20:46:17.929
cmo1y8z2l01l7vxt0vbyiy8z3	Gạo xà cơn trắng trắng	MOUNTAIN92	cmo1xc0ux0001vxp0gekkc5lr	Kg	57000	\N	\N	\N	t	2026-04-16 20:46:17.997	2026-04-16 20:46:17.997
cmo1y8z4o01lvvxt0l02sqgvp	Gạo xà cơn đỏ lứt	MOUNTAIN91	cmo1xc0ux0001vxp0gekkc5lr	Kg	57000	\N	\N	\N	t	2026-04-16 20:46:18.072	2026-04-16 20:46:18.072
cmo1y8z6k01mjvxt0wmvlblmh	Gạo xà cơn đỏ dối	MOUNTAIN90	cmo1xc0ux0001vxp0gekkc5lr	Kg	57000	\N	\N	\N	t	2026-04-16 20:46:18.14	2026-04-16 20:46:18.14
cmo1y8z8g01n7vxt06tfrz69d	Gạo xà cơn đỏ trắng	MOUNTAIN89	cmo1xc0ux0001vxp0gekkc5lr	Kg	57000	\N	\N	\N	t	2026-04-16 20:46:18.208	2026-04-16 20:46:18.208
cmo1y8zb501nvvxt06eyefnot	Gạo đồi tròn lứt	MOUNTAIN88	cmo1xc0ux0001vxp0gekkc5lr	Kg	52000	\N	\N	\N	t	2026-04-16 20:46:18.305	2026-04-16 20:46:18.305
cmo1y8zd501ojvxt0kevfhixq	Gạo đồi tròn dối	MOUNTAIN87	cmo1xc0ux0001vxp0gekkc5lr	Kg	52000	\N	\N	\N	t	2026-04-16 20:46:18.377	2026-04-16 20:46:18.377
cmo1y8zfh01p7vxt08zci0mcb	Gạo đồi tròn trắng	MOUNTAIN86	cmo1xc0ux0001vxp0gekkc5lr	Kg	52000	\N	\N	\N	t	2026-04-16 20:46:18.461	2026-04-16 20:46:18.461
cmo1y8zhu01pvvxt0a8wu8w1n	Gạo huyết rồng xát lứt	MOUNTAIN85	cmo1xc0ux0001vxp0gekkc5lr	Kg	57000	\N	\N	\N	t	2026-04-16 20:46:18.546	2026-04-16 20:46:18.546
cmo1y8zk101qjvxt0h6yzvl64	Gạo huyết rồng xát dối	MOUNTAIN84	cmo1xc0ux0001vxp0gekkc5lr	Kg	57000	\N	\N	\N	t	2026-04-16 20:46:18.626	2026-04-16 20:46:18.626
cmo1y8zmq01r7vxt08juzbne2	Gạo huyết rồng xát trắng	MOUNTAIN83	cmo1xc0ux0001vxp0gekkc5lr	Kg	57000	\N	\N	\N	t	2026-04-16 20:46:18.722	2026-04-16 20:46:18.722
cmo1y8zp601rvvxt0trpynwpp	Gạo thơm dẻo lứt	MOUNTAIN82	cmo1xc0ux0001vxp0gekkc5lr	Kg	41000	\N	\N	\N	t	2026-04-16 20:46:18.81	2026-04-16 20:46:18.81
cmo1y8zqz01sjvxt0isho03ev	Gạo thơm dẻo dối	MOUNTAIN81	cmo1xc0ux0001vxp0gekkc5lr	Kg	41000	\N	\N	\N	t	2026-04-16 20:46:18.876	2026-04-16 20:46:18.876
cmo1y8zsz01t7vxt0wvmvuycc	Gạo thơm dẻo trắng	MOUNTAIN80	cmo1xc0ux0001vxp0gekkc5lr	Kg	41000	\N	\N	\N	t	2026-04-16 20:46:18.947	2026-04-16 20:46:18.947
cmo1y8zvj01tvvxt0n2rh99gh	Gạo ST24 lứt	MOUNTAIN79	cmo1xc0ux0001vxp0gekkc5lr	Kg	51000	\N	\N	\N	t	2026-04-16 20:46:19.039	2026-04-16 20:46:19.039
cmo1y8zxh01ujvxt0z7cac81f	Gạo ST24 dối	MOUNTAIN78	cmo1xc0ux0001vxp0gekkc5lr	Kg	51000	\N	\N	\N	t	2026-04-16 20:46:19.11	2026-04-16 20:46:19.11
cmo1y8zzn01v7vxt0ta2rb6ex	Gạo ST24  trắng	MOUNTAIN77	cmo1xc0ux0001vxp0gekkc5lr	Kg	51000	\N	\N	\N	t	2026-04-16 20:46:19.188	2026-04-16 20:46:19.188
cmo1y901r01vvvxt0bgh9me63	Đậu xanh	MOUNTAIN76	cmo1xc0ux0001vxp0gekkc5lr	Kg	118000	\N	\N	\N	t	2026-04-16 20:46:19.263	2026-04-16 20:46:19.263
cmo1y904h01wlvxt0oooctw2b	Đậu xanh vỡ đôi	MOUNTAIN75	cmo1xc0ux0001vxp0gekkc5lr	Kg	125000	\N	\N	\N	t	2026-04-16 20:46:19.361	2026-04-16 20:46:19.361
cmo1y906y01xbvxt0l1j904r1	Đậu xanh tách vỏ	MOUNTAIN74	cmo1xc0ux0001vxp0gekkc5lr	Kg	134000	\N	\N	\N	t	2026-04-16 20:46:19.45	2026-04-16 20:46:19.45
cmo1y909b01xvvxt0ebcbcjyr	Đậu đen xanh lòng	MOUNTAIN73	cmo1xc0ux0001vxp0gekkc5lr	Kg	126000	\N	\N	\N	t	2026-04-16 20:46:19.535	2026-04-16 20:46:19.535
cmo1y90k701ylvxt0yb8cye1f	Đậu đỏ	MOUNTAIN72	cmo1xc0ux0001vxp0gekkc5lr	Kg	126000	\N	\N	\N	t	2026-04-16 20:46:19.928	2026-04-16 20:46:19.928
cmo1y90uo01zbvxt0d3m49lb5	Đậu nành	MOUNTAIN71	cmo1xc0ux0001vxp0gekkc5lr	Kg	126000	\N	\N	\N	t	2026-04-16 20:46:20.304	2026-04-16 20:46:20.304
cmo1y91290201vxt06zkmipm2	Đậu trắng	MOUNTAIN70	cmo1xc0ux0001vxp0gekkc5lr	Kg	113000	\N	\N	\N	t	2026-04-16 20:46:20.578	2026-04-16 20:46:20.578
cmo1y915e020rvxt0rnies3mx	Đậu ván	MOUNTAIN69	cmo1xc0ux0001vxp0gekkc5lr	Kg	126000	\N	\N	\N	t	2026-04-16 20:46:20.691	2026-04-16 20:46:20.691
cmo1y918d021fvxt06qdfm1x6	Đậu phộng khô (nhân)	MOUNTAIN68	cmo1xc0ux0001vxp0gekkc5lr	Kg	187000	\N	\N	\N	t	2026-04-16 20:46:20.797	2026-04-16 20:46:20.797
cmo1y91b60225vxt0231a42gg	Bo bo	MOUNTAIN67	cmo1xc0ux0001vxp0gekkc5lr	Kg	222000	\N	\N	\N	t	2026-04-16 20:46:20.899	2026-04-16 20:46:20.899
cmo1y91e8022tvxt0d5l4c4og	Bắp khô	MOUNTAIN66	cmo1xc0ux0001vxp0gekkc5lr	Kg	82000	\N	\N	\N	t	2026-04-16 20:46:21.008	2026-04-16 20:46:21.008
cmo1y91hw023fvxt0s2jwpeor	Mè đen	MOUNTAIN65	cmo1xc0ux0001vxp0gekkc5lr	Kg	231000	\N	\N	\N	t	2026-04-16 20:46:21.139	2026-04-16 20:46:21.139
cmo1y91kp0245vxt0nl1pdvl0	Mè vàng	MOUNTAIN64	cmo1xc0ux0001vxp0gekkc5lr	Kg	231000	\N	\N	\N	t	2026-04-16 20:46:21.241	2026-04-16 20:46:21.241
cmo1y91o8024vvxt0fhd1gxoc	Mè trắng	MOUNTAIN63	cmo1xc0ux0001vxp0gekkc5lr	Kg	231000	\N	\N	\N	t	2026-04-16 20:46:21.368	2026-04-16 20:46:21.368
cmo1y91ro025lvxt0rbcqk5bh	Kê nếp	MOUNTAIN62	cmo1xc0ux0001vxp0gekkc5lr	Kg	210000	\N	\N	\N	t	2026-04-16 20:46:21.492	2026-04-16 20:46:21.492
cmo1y91vp026bvxt0ss4xi7rz	Gạo thơm + Đậu xanh +Kê nếp	MOUNTAIN61	cmo1xc0ux0001vxp0gekkc5lr	Kg	75000	\N	\N	\N	t	2026-04-16 20:46:21.637	2026-04-16 20:46:21.637
cmo1y91yk026xvxt0vx7in7pa	Gạo thơm + Đậu đỏ +Kê nếp	MOUNTAIN60	cmo1xc0ux0001vxp0gekkc5lr	Kg	75000	\N	\N	\N	t	2026-04-16 20:46:21.74	2026-04-16 20:46:21.74
cmo1y921d027jvxt0htzrsdmb	Gạo thơm + Đậu đen +Kê nếp	MOUNTAIN59	cmo1xc0ux0001vxp0gekkc5lr	Kg	75000	\N	\N	\N	t	2026-04-16 20:46:21.841	2026-04-16 20:46:21.841
cmo1y923w0285vxt0435oep6e	Gạo xà cơn trắng +Đậu xanh+Kê nếp	MOUNTAIN58	cmo1xc0ux0001vxp0gekkc5lr	Kg	89000	\N	\N	\N	t	2026-04-16 20:46:21.932	2026-04-16 20:46:21.932
cmo1y926d028rvxt0yzlcemc4	Gạo xà cơn trắng +Đậu đỏ+Kê nếp	MOUNTAIN57	cmo1xc0ux0001vxp0gekkc5lr	Kg	89000	\N	\N	\N	t	2026-04-16 20:46:22.021	2026-04-16 20:46:22.021
cmo1y928q029dvxt0o6rxwsdi	Gạo xà cơn trắng +Đậu đen+Kê nếp	MOUNTAIN56	cmo1xc0ux0001vxp0gekkc5lr	Kg	89000	\N	\N	\N	t	2026-04-16 20:46:22.106	2026-04-16 20:46:22.106
cmo1y92ba029zvxt0en7wfa6c	Gạo huyết rồng +Đậu xanh+Kê nếp	MOUNTAIN55	cmo1xc0ux0001vxp0gekkc5lr	Kg	89000	\N	\N	\N	t	2026-04-16 20:46:22.198	2026-04-16 20:46:22.198
cmo1y92dn02alvxt07m8wg0xy	Gạo huyết rồng +Đậu đỏ +Kê nếp	MOUNTAIN54	cmo1xc0ux0001vxp0gekkc5lr	Kg	89000	\N	\N	\N	t	2026-04-16 20:46:22.283	2026-04-16 20:46:22.283
cmo1y92g402b7vxt0dak56hvv	Gạo huyết rồng +Đậu đen +Kê nếp	MOUNTAIN53	cmo1xc0ux0001vxp0gekkc5lr	Kg	89000	\N	\N	\N	t	2026-04-16 20:46:22.373	2026-04-16 20:46:22.373
cmo1y92ip02btvxt0fup4uwfi	Gạo mix ST24+Thơm (lứt)	MOUNTAIN52	cmo1xc0ux0001vxp0gekkc5lr	Kg	48000	\N	\N	\N	t	2026-04-16 20:46:22.465	2026-04-16 20:46:22.465
cmo1y92l702cfvxt0mkjhr4ho	Gạo mix ST24+Thơm (dối)	MOUNTAIN51	cmo1xc0ux0001vxp0gekkc5lr	Kg	48000	\N	\N	\N	t	2026-04-16 20:46:22.556	2026-04-16 20:46:22.556
cmo1y92nl02d1vxt09yniyjso	Gạo mix ST24+Thơm (trắng)	MOUNTAIN50	cmo1xc0ux0001vxp0gekkc5lr	Kg	48000	\N	\N	\N	t	2026-04-16 20:46:22.642	2026-04-16 20:46:22.642
cmo1y92q302dnvxt09cnyquzj	Gạo trắng	MOUNTAIN49	cmo1xc0ux0001vxp0gekkc5lr	Kg	0	\N	\N	\N	t	2026-04-16 20:46:22.731	2026-04-16 20:46:22.731
cmo1y92ra02drvxt0p44to9ag	Trứng gà	MOUNTAIN48	cmo1xc0ux0001vxp0gekkc5lr	Cái	5500	\N	\N	\N	t	2026-04-16 20:46:22.774	2026-04-16 20:46:22.774
cmo1y92u902ejvxt0iyn7m5dq	Trứng vịt	MOUNTAIN47	cmo1xc0ux0001vxp0gekkc5lr	Cái	5500	\N	\N	\N	t	2026-04-16 20:46:22.882	2026-04-16 20:46:22.882
cmo1y92x702fbvxt0rmd9fg7f	Rau muống hạt	MOUNTAIN46	cmo1xc0ux0001vxp0gekkc5lr	Kg	65000	\N	\N	\N	t	2026-04-16 20:46:22.987	2026-04-16 20:46:22.987
cmo1y930102g3vxt01k1pysa2	Lúa nếp nương	MOUNTAIN45	cmo1xc0ux0001vxp0gekkc5lr	Kg	25500	\N	\N	\N	t	2026-04-16 20:46:23.089	2026-04-16 20:46:23.089
cmo1y932v02gvvxt0mqjaxgan	Dưa leo (đèo)	MOUNTAIN44	cmo1xc0ux0001vxp0gekkc5lr	Kg	18000	\N	\N	\N	t	2026-04-16 20:46:23.191	2026-04-16 20:46:23.191
cmo1y935v02hnvxt0k4coe0ov	Lúa xà cơn trắng	MOUNTAIN43	cmo1xc0ux0001vxp0gekkc5lr	Kg	25500	\N	\N	\N	t	2026-04-16 20:46:23.299	2026-04-16 20:46:23.299
cmo1y938m02ifvxt0px8npgb2	Thơm (sz 700gr - 900gr)	MOUNTAIN42	cmo1xc0ux0001vxp0gekkc5lr	Kg	19000	\N	\N	\N	t	2026-04-16 20:46:23.398	2026-04-16 20:46:23.398
cmo1y93bl02j7vxt0oue1506b	Thơm (sz 400gr-650gr)	MOUNTAIN41	cmo1xc0ux0001vxp0gekkc5lr	Kg	16000	\N	\N	\N	t	2026-04-16 20:46:23.505	2026-04-16 20:46:23.505
cmo1y93f002jzvxt0y20j87zp	Thơm(sz 1kg trở lên)	MOUNTAIN40	cmo1xc0ux0001vxp0gekkc5lr	Kg	21000	\N	\N	\N	t	2026-04-16 20:46:23.628	2026-04-16 20:46:23.628
cmo1y93i302krvxt0xhgoqd9s	Lúa thơm	MOUNTAIN39	cmo1xc0ux0001vxp0gekkc5lr	Kg	20000	\N	\N	\N	t	2026-04-16 20:46:23.739	2026-04-16 20:46:23.739
cmo1y93l002ljvxt0h0e9ep0y	Đậu bắp	MOUNTAIN38	cmo1xc0ux0001vxp0gekkc5lr	Kg	57000	\N	\N	\N	t	2026-04-16 20:46:23.844	2026-04-16 20:46:23.844
cmo1y93nw02mbvxt0dzqjfdmm	Lúa đỏ	MOUNTAIN37	cmo1xc0ux0001vxp0gekkc5lr	Kg	25500	\N	\N	\N	t	2026-04-16 20:46:23.948	2026-04-16 20:46:23.948
cmo1y93qp02n3vxt0fp56p7rj	Diếp cá	MOUNTAIN36	cmo1xc0ux0001vxp0gekkc5lr	Kg	86000	\N	\N	\N	t	2026-04-16 20:46:24.05	2026-04-16 20:46:24.05
cmo1y93tn02nvvxt04ak1nhea	Khổ qua	MOUNTAIN35	cmo1xc0ux0001vxp0gekkc5lr	Kg	57000	\N	\N	\N	t	2026-04-16 20:46:24.155	2026-04-16 20:46:24.155
cmo1y93wl02onvxt0bh4kzbpp	Sachi	MOUNTAIN34	cmo1xc0ux0001vxp0gekkc5lr	Kg	0	\N	\N	\N	t	2026-04-16 20:46:24.261	2026-04-16 20:46:24.261
cmo1y93y502ovvxt0a2yqm5mw	Tỏi vụng	MOUNTAIN33	cmo1xc0ux0001vxp0gekkc5lr	Kg	100000	\N	\N	\N	t	2026-04-16 20:46:24.317	2026-04-16 20:46:24.317
cmo1y941102pnvxt09fxom8bo	Tỏi lột sẵn	MOUNTAIN32	cmo1xc0ux0001vxp0gekkc5lr	Kg	0	\N	\N	\N	t	2026-04-16 20:46:24.421	2026-04-16 20:46:24.421
cmo1y96zi03ddvxt0xv0kbhd6	Nước chuối len men (350ml)	XUANLOC131	cmo1xc0tk0000vxp0m1od0byy	Chai	129000	\N	\N	\N	t	2026-04-16 20:46:28.254	2026-04-16 20:46:28.254
cmo1y942g02pxvxt0goddw81e	Sét ăn dặm 1 (Gạo ST24 xát trắng + Kê nếp) 500gr	MOUNTAIN31	cmo1xc0ux0001vxp0gekkc5lr	Gói	47000	\N	\N	\N	t	2026-04-16 20:46:24.473	2026-04-16 20:46:24.473
cmo1y945d02qpvxt0cm577h9n	Ngãi cứu	MOUNTAIN30	cmo1xc0ux0001vxp0gekkc5lr	Kg	86000	\N	\N	\N	t	2026-04-16 20:46:24.578	2026-04-16 20:46:24.578
cmo1y948g02rhvxt0wbj5ouq4	Đương quy có lá	MOUNTAIN29	cmo1xc0ux0001vxp0gekkc5lr	Kg	0	\N	\N	\N	t	2026-04-16 20:46:24.688	2026-04-16 20:46:24.688
cmo1y949r02rpvxt0tp90r46w	Đương quy củ	MOUNTAIN28	cmo1xc0ux0001vxp0gekkc5lr	Kg	0	\N	\N	\N	t	2026-04-16 20:46:24.735	2026-04-16 20:46:24.735
cmo1y94b402rxvxt0k8h74jyf	Ớt sừng	MOUNTAIN27	cmo1xc0ux0001vxp0gekkc5lr	Kg	72000	\N	\N	\N	t	2026-04-16 20:46:24.784	2026-04-16 20:46:24.784
cmo1y94em02spvxt054kk2cpq	Xà lách	MOUNTAIN26	cmo1xc0ux0001vxp0gekkc5lr	Kg	65000	\N	\N	\N	t	2026-04-16 20:46:24.91	2026-04-16 20:46:24.91
cmo1y94h202tbvxt0i6zreh9g	Ngọn bí	MOUNTAIN25	cmo1xc0ux0001vxp0gekkc5lr	Kg	57000	\N	\N	\N	t	2026-04-16 20:46:24.998	2026-04-16 20:46:24.998
cmo1y94i802thvxt0knwkmqgg	Gạo thơm dẻo trắng (xá)	MOUNTAIN24	cmo1xc0ux0001vxp0gekkc5lr	Kg	40500	\N	\N	\N	t	2026-04-16 20:46:25.04	2026-04-16 20:46:25.04
cmo1y94jg02tnvxt03jxx2whb	Chanh xanh	MOUNTAIN23	cmo1xc0ux0001vxp0gekkc5lr	Kg	60000	\N	\N	\N	t	2026-04-16 20:46:25.084	2026-04-16 20:46:25.084
cmo1y94lw02u9vxt0ald4fm4q	Gạo ST24 + Đậu (xanh+đỏ) + Kê nếp	MOUNTAIN22	cmo1xc0ux0001vxp0gekkc5lr	Kg	0	\N	\N	\N	t	2026-04-16 20:46:25.173	2026-04-16 20:46:25.173
cmo1y94nc02uhvxt05tww8631	Gạo ST24 dối (xá )	MOUNTAIN21	cmo1xc0ux0001vxp0gekkc5lr	Kg	50500	\N	\N	\N	t	2026-04-16 20:46:25.224	2026-04-16 20:46:25.224
cmo1y94oh02unvxt0x9sxf6h0	Gạo xà cơn trắng trắng (xá)	MOUNTAIN20	cmo1xc0ux0001vxp0gekkc5lr	Kg	56500	\N	\N	\N	t	2026-04-16 20:46:25.265	2026-04-16 20:46:25.265
cmo1y94pq02utvxt06g6axnmq	Gạo thơm dẻo dối (xá)	MOUNTAIN19	cmo1xc0ux0001vxp0gekkc5lr	Kg	40500	\N	\N	\N	t	2026-04-16 20:46:25.311	2026-04-16 20:46:25.311
cmo1y94qs02uzvxt06qgm3y4g	Hạt sen khô	MOUNTAIN18	cmo1xc0ux0001vxp0gekkc5lr	Kg	0	\N	\N	\N	t	2026-04-16 20:46:25.348	2026-04-16 20:46:25.348
cmo1y94ry02v5vxt0org2kq4m	Mix đậu (xanh,đen ,trắng, đỏ)	MOUNTAIN17	cmo1xc0ux0001vxp0gekkc5lr	Kg	0	\N	\N	\N	t	2026-04-16 20:46:25.391	2026-04-16 20:46:25.391
cmo1y94tg02vdvxt0hqjzklji	Nếp cái hoa vàng xát lứt - Lớp sữa	MOUNTAIN16	cmo1xc0ux0001vxp0gekkc5lr	Kg	52000	\N	\N	\N	t	2026-04-16 20:46:25.444	2026-04-16 20:46:25.444
cmo1y94ud02vfvxt0kw6mv5s8	Đậu xanh (làm giá)	MOUNTAIN15	cmo1xc0ux0001vxp0gekkc5lr	Kg	126000	\N	\N	\N	t	2026-04-16 20:46:25.477	2026-04-16 20:46:25.477
cmo1y94v902vjvxt0r7m7cqit	Khoai sọ gọt sẵn	MOUNTAIN14	cmo1xc0ux0001vxp0gekkc5lr	Kg	0	\N	\N	\N	t	2026-04-16 20:46:25.509	2026-04-16 20:46:25.509
cmo1y94wd02vpvxt0r0gsqb2t	Gạo ST24  trắng (xá)	MOUNTAIN13	cmo1xc0ux0001vxp0gekkc5lr	Kg	50500	\N	\N	\N	t	2026-04-16 20:46:25.549	2026-04-16 20:46:25.549
cmo1y94yz02w3vxt05z8j13f9	Khoai sọ chạy số lượng từ 5kg (sale)	MOUNTAIN11	cmo1xc0ux0001vxp0gekkc5lr	Kg	0	\N	\N	\N	t	2026-04-16 20:46:25.643	2026-04-16 20:46:25.643
cmo1y94zx02w7vxt0u1j63amt	Khoai lang (héo)	MOUNTAIN10	cmo1xc0ux0001vxp0gekkc5lr	Kg	48000	\N	\N	\N	t	2026-04-16 20:46:25.678	2026-04-16 20:46:25.678
cmo1y951a02whvxt0rzalumvr	Cải ngồng	MOUNTAIN9	cmo1xc0ux0001vxp0gekkc5lr	Kg	65000	\N	\N	\N	t	2026-04-16 20:46:25.726	2026-04-16 20:46:25.726
cmo1y953o02x3vxt00tsq763m	Lúa nếp hoa vàng	MOUNTAIN8	cmo1xc0ux0001vxp0gekkc5lr	Kg	32000	\N	\N	\N	t	2026-04-16 20:46:25.812	2026-04-16 20:46:25.812
cmo1y954z02xbvxt0g9v14vi0	Chanh cao	MOUNTAIN7	cmo1xc0ux0001vxp0gekkc5lr	Kg	150000	\N	\N	\N	t	2026-04-16 20:46:25.859	2026-04-16 20:46:25.859
cmo1y955s02xdvxt0ehj6imm3	Su hào	MOUNTAIN6	cmo1xc0ux0001vxp0gekkc5lr	Kg	57000	\N	\N	\N	t	2026-04-16 20:46:25.888	2026-04-16 20:46:25.888
cmo1y958o02y5vxt0mflr37n0	Hành tây tím (củ nhỏ)	MOUNTAIN5	cmo1xc0ux0001vxp0gekkc5lr	Kg	68000	\N	\N	\N	t	2026-04-16 20:46:25.992	2026-04-16 20:46:25.992
cmo1y95be02ypvxt04po42uwv	Khoai sọ (củ nhỏ)	MOUNTAIN4	cmo1xc0ux0001vxp0gekkc5lr	Kg	51000	\N	\N	\N	t	2026-04-16 20:46:26.09	2026-04-16 20:46:26.09
cmo1y95dy02z9vxt0e94984pc	Hoa hành	MOUNTAIN3	cmo1xc0ux0001vxp0gekkc5lr	Kg	57000	\N	\N	\N	t	2026-04-16 20:46:26.183	2026-04-16 20:46:26.183
cmo1y95gq0301vxt0d9z0rea0	Táo (anh Vàng)	MOUNTAIN2	cmo1xc0ux0001vxp0gekkc5lr	Kg	65000	\N	\N	\N	t	2026-04-16 20:46:26.282	2026-04-16 20:46:26.282
cmo1y95ho0303vxt0hudbv4lc	Cải bẹ xanh	MOUNTAIN1	cmo1xc0ux0001vxp0gekkc5lr	Kg	65000	\N	\N	\N	t	2026-04-16 20:46:26.316	2026-04-16 20:46:26.316
cmo1y95k3030pvxt0xbdxqk2m	Măng luộc	XUANLOC152	cmo1xc0tk0000vxp0m1od0byy	Kg	79000	\N	\N	\N	t	2026-04-16 20:46:26.404	2026-04-16 20:46:26.404
cmo1y95mw031hvxt0y6i7hf91	Bột gạo huyết rồng	XUANLOC151	cmo1xc0tk0000vxp0m1od0byy	Hủ	100000	\N	\N	\N	t	2026-04-16 20:46:26.504	2026-04-16 20:46:26.504
cmo1y95pi0325vxt0i4iwd0k7	Bột ngũ đậu (hủ 500gr)	XUANLOC150	cmo1xc0tk0000vxp0m1od0byy	Hủ	175000	\N	\N	\N	t	2026-04-16 20:46:26.598	2026-04-16 20:46:26.598
cmo1y95sa032tvxt0241c2wp2	Xá bấu (gói 200gr)	XUANLOC149	cmo1xc0tk0000vxp0m1od0byy	Gói	23000	\N	\N	\N	t	2026-04-16 20:46:26.699	2026-04-16 20:46:26.699
cmo1y95v2033hvxt00lpruj1d	Mè đen rang ( gói 100gr)	XUANLOC148	cmo1xc0tk0000vxp0m1od0byy	Gói	36000	\N	\N	\N	t	2026-04-16 20:46:26.799	2026-04-16 20:46:26.799
cmo1y95xk0345vxt0to38h552	Măng chua (ớt, tỏi) (gói 150gr)	XUANLOC147	cmo1xc0tk0000vxp0m1od0byy	Gói	30000	\N	\N	\N	t	2026-04-16 20:46:26.888	2026-04-16 20:46:26.888
cmo1y9602034tvxt08duqwml2	Ngò sấy khô (100gr)	XUANLOC146	cmo1xc0tk0000vxp0m1od0byy	Gói	110000	\N	\N	\N	t	2026-04-16 20:46:26.979	2026-04-16 20:46:26.979
cmo1y962o035hvxt0djed7qgg	Bột ngũ cốc baby (hủ 500gr)	XUANLOC145	cmo1xc0tk0000vxp0m1od0byy	Hủ	200000	\N	\N	\N	t	2026-04-16 20:46:27.072	2026-04-16 20:46:27.072
cmo1y965i0365vxt0jz6uh2sc	Bột nghệ gia vị (gói 100gr)	XUANLOC144	cmo1xc0tk0000vxp0m1od0byy	Gói	105000	\N	\N	\N	t	2026-04-16 20:46:27.174	2026-04-16 20:46:27.174
cmo1y9670036dvxt0e08bzpm7	Trà gạo lứt rang cháy (gói 250gr)	XUANLOC143	cmo1xc0tk0000vxp0m1od0byy	Gói	45000	\N	\N	\N	t	2026-04-16 20:46:27.228	2026-04-16 20:46:27.228
cmo1y969m0371vxt040uhlyky	Bột ngũ cốc nảy mầm (hủ 500gr)	XUANLOC142	cmo1xc0tk0000vxp0m1od0byy	Hủ	215000	\N	\N	\N	t	2026-04-16 20:46:27.322	2026-04-16 20:46:27.322
cmo1y96c7037pvxt0k0je0itb	Sate ớt (đóng xá)	XUANLOC141	cmo1xc0tk0000vxp0m1od0byy	Kg	0	\N	\N	\N	t	2026-04-16 20:46:27.414	2026-04-16 20:46:27.414
cmo1y96d1037rvxt0lsw4lwj5	Bột khoai môn (gói 100gr)	XUANLOC140	cmo1xc0tk0000vxp0m1od0byy	Gói	54000	\N	\N	\N	t	2026-04-16 20:46:27.445	2026-04-16 20:46:27.445
cmo1y96fn038fvxt0aj5jgxwv	Bột khoai lang (gói 100gr)	XUANLOC139	cmo1xc0tk0000vxp0m1od0byy	Gói	54000	\N	\N	\N	t	2026-04-16 20:46:27.539	2026-04-16 20:46:27.539
cmo1y96ie0393vxt0svz5k6sf	Bột bí đỏ (gói 100gr)	XUANLOC138	cmo1xc0tk0000vxp0m1od0byy	Gói	54000	\N	\N	\N	t	2026-04-16 20:46:27.638	2026-04-16 20:46:27.638
cmo1y96kz039rvxt0b1tbdwel	Chanh đào mật ong (hủ 250ml)	XUANLOC137	cmo1xc0tk0000vxp0m1od0byy	Hủ	88000	\N	\N	\N	t	2026-04-16 20:46:27.732	2026-04-16 20:46:27.732
cmo1y96no03afvxt00339co2s	Mật ong rừng	MOUNTAIN160	cmo1xc0ux0001vxp0gekkc5lr	Lít	900000	\N	\N	\N	t	2026-04-16 20:46:27.829	2026-04-16 20:46:27.829
cmo1y96p103apvxt0xkjnvjst	Khoai lang khô (gói 250gr)	XUANLOC135	cmo1xc0tk0000vxp0m1od0byy	Kg	72000	\N	\N	\N	t	2026-04-16 20:46:27.877	2026-04-16 20:46:27.877
cmo1y96rj03bdvxt0ugvmzuzw	Bột nghệ gia vị (xá)	XUANLOC134	cmo1xc0tk0000vxp0m1od0byy	Kg	0	\N	\N	\N	t	2026-04-16 20:46:27.968	2026-04-16 20:46:27.968
cmo1y96ua03c1vxt006gax5u5	Bột gạo	XUANLOC133	cmo1xc0tk0000vxp0m1od0byy	Kg	114000	\N	\N	\N	t	2026-04-16 20:46:28.066	2026-04-16 20:46:28.066
cmo1y96wz03cpvxt091vexgl1	Bột nếp	XUANLOC132	cmo1xc0tk0000vxp0m1od0byy	Kg	120000	\N	\N	\N	t	2026-04-16 20:46:28.163	2026-04-16 20:46:28.163
cmo1y972903e1vxt037ejb62r	Phở gạo trắng	XUANLOC130	cmo1xc0tk0000vxp0m1od0byy	Kg	130000	\N	\N	\N	t	2026-04-16 20:46:28.354	2026-04-16 20:46:28.354
cmo1y974t03epvxt0twf8er9n	Phở gạo lứt	XUANLOC129	cmo1xc0tk0000vxp0m1od0byy	Kg	130000	\N	\N	\N	t	2026-04-16 20:46:28.445	2026-04-16 20:46:28.445
cmo1y977f03fdvxt04av0zukh	Phở gạo gấc	XUANLOC128	cmo1xc0tk0000vxp0m1od0byy	Kg	130000	\N	\N	\N	t	2026-04-16 20:46:28.54	2026-04-16 20:46:28.54
cmo1y97a503g1vxt01hul0r9p	Phở gạo mè đen	XUANLOC127	cmo1xc0tk0000vxp0m1od0byy	Kg	130000	\N	\N	\N	t	2026-04-16 20:46:28.637	2026-04-16 20:46:28.637
cmo1y97ct03gpvxt06b698a73	Bún gạo trắng	XUANLOC126	cmo1xc0tk0000vxp0m1od0byy	Kg	130000	\N	\N	\N	t	2026-04-16 20:46:28.733	2026-04-16 20:46:28.733
cmo1y97ff03hdvxt043lnkxpg	Bún gạo gấc	XUANLOC125	cmo1xc0tk0000vxp0m1od0byy	Kg	130000	\N	\N	\N	t	2026-04-16 20:46:28.828	2026-04-16 20:46:28.828
cmo1y97hv03i1vxt0t3bpz6hn	Bún gạo lứt	XUANLOC124	cmo1xc0tk0000vxp0m1od0byy	Kg	130000	\N	\N	\N	t	2026-04-16 20:46:28.915	2026-04-16 20:46:28.915
cmo1y97kd03ipvxt0l744jbjp	Bún gạo mè đen	XUANLOC123	cmo1xc0tk0000vxp0m1od0byy	Kg	130000	\N	\N	\N	t	2026-04-16 20:46:29.006	2026-04-16 20:46:29.006
cmo1y97mv03jdvxt0g3qmj0av	Phở gạo đậu đỏ	XUANLOC122	cmo1xc0tk0000vxp0m1od0byy	Kg	130000	\N	\N	\N	t	2026-04-16 20:46:29.095	2026-04-16 20:46:29.095
cmo1y97pe03k1vxt0odeeuuqw	Mật ong cà phê	MOUNTAIN161	cmo1xc0ux0001vxp0gekkc5lr	Lít	0	\N	\N	\N	t	2026-04-16 20:46:29.186	2026-04-16 20:46:29.186
cmo1y97q403k3vxt0jz3hdirb	Bún gạo đậu đỏ	XUANLOC120	cmo1xc0tk0000vxp0m1od0byy	Kg	130000	\N	\N	\N	t	2026-04-16 20:46:29.213	2026-04-16 20:46:29.213
cmo1y97sj03krvxt0i9en0yth	Phở mix	XUANLOC119	cmo1xc0tk0000vxp0m1od0byy	Kg	130000	\N	\N	\N	t	2026-04-16 20:46:29.299	2026-04-16 20:46:29.299
cmo1y97v303lfvxt0ssijpkeu	Bún mix	XUANLOC118	cmo1xc0tk0000vxp0m1od0byy	Kg	130000	\N	\N	\N	t	2026-04-16 20:46:29.391	2026-04-16 20:46:29.391
cmo1y97xn03m3vxt05wvb8dao	Bột gừng pha uống (hủ 50gr)	XUANLOC117	cmo1xc0tk0000vxp0m1od0byy	Hủ	85000	\N	\N	\N	t	2026-04-16 20:46:29.483	2026-04-16 20:46:29.483
cmo1y980n03mrvxt0902dj1ys	Bột gừng gia vị (hủ 50gr)	XUANLOC116	cmo1xc0tk0000vxp0m1od0byy	Hủ	80000	\N	\N	\N	t	2026-04-16 20:46:29.591	2026-04-16 20:46:29.591
cmo1y983703nfvxt0c8llq8nx	Bột nghệ gia vị (hủ 50gr)	XUANLOC115	cmo1xc0tk0000vxp0m1od0byy	Hủ	75000	\N	\N	\N	t	2026-04-16 20:46:29.683	2026-04-16 20:46:29.683
cmo1y986703o3vxt084le3qqe	Bột hành tây tím gia vị (hủ 50gr)	XUANLOC114	cmo1xc0tk0000vxp0m1od0byy	Hủ	143000	\N	\N	\N	t	2026-04-16 20:46:29.791	2026-04-16 20:46:29.791
cmo1y98c503orvxt0fgcse4l9	Trà đậu đen (gói 500gr)	XUANLOC113	cmo1xc0tk0000vxp0m1od0byy	Gói	0	\N	\N	\N	t	2026-04-16 20:46:30.006	2026-04-16 20:46:30.006
cmo1y98g603pfvxt053zdiahc	Trà đậu gạo (gói 500gr)	XUANLOC112	cmo1xc0tk0000vxp0m1od0byy	Gói	0	\N	\N	\N	t	2026-04-16 20:46:30.15	2026-04-16 20:46:30.15
cmo1y98ix03q3vxt0qsnmdmf2	Bột hành tím gia vị (hủ 50gr)	XUANLOC111	cmo1xc0tk0000vxp0m1od0byy	Hủ	143000	\N	\N	\N	t	2026-04-16 20:46:30.249	2026-04-16 20:46:30.249
cmo1y98ll03qrvxt0wdjbpnw4	Bột sả gia vị (hủ 50gr)	XUANLOC110	cmo1xc0tk0000vxp0m1od0byy	Hủ	70000	\N	\N	\N	t	2026-04-16 20:46:30.345	2026-04-16 20:46:30.345
cmo1y98nv03rfvxt01sr6df56	Bột tỏi gia vị (hủ 50gr)	XUANLOC109	cmo1xc0tk0000vxp0m1od0byy	Hủ	150000	\N	\N	\N	t	2026-04-16 20:46:30.428	2026-04-16 20:46:30.428
cmo1y98qb03s3vxt0jvxu8t74	Trà gạo lứt (gói 250gr)	XUANLOC108	cmo1xc0tk0000vxp0m1od0byy	Gói	45000	\N	\N	\N	t	2026-04-16 20:46:30.514	2026-04-16 20:46:30.514
cmo1y98st03srvxt0yza6an53	Sâm dây khô	XUANLOC107	cmo1xc0tk0000vxp0m1od0byy	Kg	800000	\N	\N	\N	t	2026-04-16 20:46:30.605	2026-04-16 20:46:30.605
cmo1y98u403sxvxt0md56h59q	Nghệ khô (xá)	XUANLOC106	cmo1xc0tk0000vxp0m1od0byy	Kg	0	\N	\N	\N	t	2026-04-16 20:46:30.652	2026-04-16 20:46:30.652
cmo1y98wq03tlvxt01aj908px	Chanh đào mật ong (hủ 500ml)	XUANLOC105	cmo1xc0tk0000vxp0m1od0byy	Hủ	150000	\N	\N	\N	t	2026-04-16 20:46:30.746	2026-04-16 20:46:30.746
cmo1y98zi03u9vxt0hbcuxpgi	Muối ngâm chân	XUANLOC104	cmo1xc0tk0000vxp0m1od0byy	Hủ	79000	\N	\N	\N	t	2026-04-16 20:46:30.846	2026-04-16 20:46:30.846
cmo1y992803uxvxt09p1d5xy9	Bột gừng uống (xá)	XUANLOC103	cmo1xc0tk0000vxp0m1od0byy	Kg	0	\N	\N	\N	t	2026-04-16 20:46:30.944	2026-04-16 20:46:30.944
cmo1y992x03uzvxt0kql0zrz2	Nước dâu tằm lên men (350ml)	XUANLOC102	cmo1xc0tk0000vxp0m1od0byy	Chai	98000	\N	\N	\N	t	2026-04-16 20:46:30.97	2026-04-16 20:46:30.97
cmo1y995i03vnvxt05683fmp5	Nghệ ngâm mật ong (250ml)	XUANLOC101	cmo1xc0tk0000vxp0m1od0byy	Hủ	112000	\N	\N	\N	t	2026-04-16 20:46:31.062	2026-04-16 20:46:31.062
cmo1y998303wbvxt0p9u9a5lh	Táo mèo ngâm mật ong (350ml)	XUANLOC100	cmo1xc0tk0000vxp0m1od0byy	Chai	155000	\N	\N	\N	t	2026-04-16 20:46:31.155	2026-04-16 20:46:31.155
cmo1y99ap03wzvxt02v7mgk6f	Bột gừng mật ong (hủ 250ml)	XUANLOC99	cmo1xc0tk0000vxp0m1od0byy	Hủ	140000	\N	\N	\N	t	2026-04-16 20:46:31.249	2026-04-16 20:46:31.249
cmo1y99dn03xnvxt04us84wpq	Giấm táo mèo	XUANLOC98	cmo1xc0tk0000vxp0m1od0byy	Chai	58000	\N	\N	\N	t	2026-04-16 20:46:31.355	2026-04-16 20:46:31.355
cmo1y99gh03ybvxt0y6yx18nt	Miến dong	XUANLOC97	cmo1xc0tk0000vxp0m1od0byy	Kg	206000	\N	\N	\N	t	2026-04-16 20:46:31.457	2026-04-16 20:46:31.457
cmo1y99j103yzvxt06a8drz37	Nước dâu tằm lên men	XUANLOC96	cmo1xc0tk0000vxp0m1od0byy	Lít	230000	\N	\N	\N	t	2026-04-16 20:46:31.549	2026-04-16 20:46:31.549
cmo1y99ll03znvxt0uw512c25	Trà đậu gạo (gói 250gr)	XUANLOC95	cmo1xc0tk0000vxp0m1od0byy	Gói	65000	\N	\N	\N	t	2026-04-16 20:46:31.642	2026-04-16 20:46:31.642
cmo1y99ob040bvxt0m19qlevy	Hủ tiếu khô	XUANLOC94	cmo1xc0tk0000vxp0m1od0byy	Kg	150000	\N	\N	\N	t	2026-04-16 20:46:31.739	2026-04-16 20:46:31.739
cmo1y99qv040zvxt0hkbvqqj5	Bánh nổ có đường (gói 200gr)	XUANLOC93	cmo1xc0tk0000vxp0m1od0byy	Gói	41000	\N	\N	\N	t	2026-04-16 20:46:31.831	2026-04-16 20:46:31.831
cmo1y99to041nvxt0mwh78vr0	Bột mình tinh	XUANLOC92	cmo1xc0tk0000vxp0m1od0byy	Kg	267000	\N	\N	\N	t	2026-04-16 20:46:31.932	2026-04-16 20:46:31.932
cmo1y99wg042bvxt0z4w9rnv5	Bột ngũ cốc (hủ 500gr)	XUANLOC91	cmo1xc0tk0000vxp0m1od0byy	Hủ	158000	\N	\N	\N	t	2026-04-16 20:46:32.032	2026-04-16 20:46:32.032
cmo1y99z7042zvxt0i1jt5y1i	Bột gừng gia vị (xá)	XUANLOC90	cmo1xc0tk0000vxp0m1od0byy	Kg	0	\N	\N	\N	t	2026-04-16 20:46:32.131	2026-04-16 20:46:32.131
cmo1y9a010431vxt02kfcbpk2	Bột riềng gia vị (hủ 50gr)	XUANLOC89	cmo1xc0tk0000vxp0m1od0byy	Hủ	70000	\N	\N	\N	t	2026-04-16 20:46:32.162	2026-04-16 20:46:32.162
cmo1y9a2n043pvxt0fqpmml88	Gừng gia vị sấy lát	XUANLOC88	cmo1xc0tk0000vxp0m1od0byy	Kg	870000	\N	\N	\N	t	2026-04-16 20:46:32.256	2026-04-16 20:46:32.256
cmo1y9a5g044dvxt0ledph3p8	Bột ớt đỏ gia vị (hủ 50gr)	XUANLOC87	cmo1xc0tk0000vxp0m1od0byy	Hủ	80000	\N	\N	\N	t	2026-04-16 20:46:32.356	2026-04-16 20:46:32.356
cmo1y9a870451vxt0dia6x5sq	Tắc ngâm mật ong (hủ 250ml)	XUANLOC86	cmo1xc0tk0000vxp0m1od0byy	Hủ	88000	\N	\N	\N	t	2026-04-16 20:46:32.455	2026-04-16 20:46:32.455
cmo1y9aas045pvxt0rmhelf6h	Sả sấy lát (xá)	XUANLOC85	cmo1xc0tk0000vxp0m1od0byy	Kg	0	\N	\N	\N	t	2026-04-16 20:46:32.548	2026-04-16 20:46:32.548
cmo1y9adc046dvxt0ee9deme9	Gừng lát ngâm mật ong (250ml)	XUANLOC84	cmo1xc0tk0000vxp0m1od0byy	Hủ	119000	\N	\N	\N	t	2026-04-16 20:46:32.64	2026-04-16 20:46:32.64
cmo1y9ag40471vxt0t4hfh1h1	Trà tía tô (50gr)	XUANLOC83	cmo1xc0tk0000vxp0m1od0byy	Gói	43000	\N	\N	\N	t	2026-04-16 20:46:32.74	2026-04-16 20:46:32.74
cmo1y9aiv047pvxt0ueop4aro	Bơ đậu phộng (hủ 300gr)	XUANLOC82	cmo1xc0tk0000vxp0m1od0byy	Hủ	107000	\N	\N	\N	t	2026-04-16 20:46:32.839	2026-04-16 20:46:32.839
cmo1y9alo048dvxt0rxvludr9	Bơ đậu phộng (hủ 150gr)	XUANLOC81	cmo1xc0tk0000vxp0m1od0byy	Hủ	68000	\N	\N	\N	t	2026-04-16 20:46:32.94	2026-04-16 20:46:32.94
cmo1y9aof0491vxt0ypw0o7o9	Nghệ sấy lát (xá)	XUANLOC80	cmo1xc0tk0000vxp0m1od0byy	Kg	0	\N	\N	\N	t	2026-04-16 20:46:33.04	2026-04-16 20:46:33.04
cmo1y9ar7049pvxt0vr23gbcm	Ớt khô nguyên trái (gói 50gr)	XUANLOC79	cmo1xc0tk0000vxp0m1od0byy	Gói	41000	\N	\N	\N	t	2026-04-16 20:46:33.139	2026-04-16 20:46:33.139
cmo1y9au404advxt0x4qmwfel	Gừng gia vị sấy lát (gói 50gr)	XUANLOC78	cmo1xc0tk0000vxp0m1od0byy	Gói	45000	\N	\N	\N	t	2026-04-16 20:46:33.244	2026-04-16 20:46:33.244
cmo1y9awq04b1vxt0u63242cb	Trà sả (sả sấy khô)(gói 50gr)	XUANLOC77	cmo1xc0tk0000vxp0m1od0byy	Gói	40000	\N	\N	\N	t	2026-04-16 20:46:33.338	2026-04-16 20:46:33.338
cmo1y9azk04bpvxt05x123u9x	Nước nho lên men (350ml)	XUANLOC76	cmo1xc0tk0000vxp0m1od0byy	Chai	98000	\N	\N	\N	t	2026-04-16 20:46:33.44	2026-04-16 20:46:33.44
cmo1y9b2a04cdvxt0g0bv723l	Măng chua (ớt, tỏi) (hủ 500gr)	XUANLOC75	cmo1xc0tk0000vxp0m1od0byy	Hủ	70000	\N	\N	\N	t	2026-04-16 20:46:33.539	2026-04-16 20:46:33.539
cmo1y9b4v04d1vxt0z7htc1kp	Nghệ sấy lát (gói 50gr)	XUANLOC74	cmo1xc0tk0000vxp0m1od0byy	Gói	43000	\N	\N	\N	t	2026-04-16 20:46:33.631	2026-04-16 20:46:33.631
cmo1y9b7p04dpvxt0xpxhjhgk	Trà gừng (gừng uống sấy lát) (gói 100gr)	XUANLOC73	cmo1xc0tk0000vxp0m1od0byy	Gói	95000	\N	\N	\N	t	2026-04-16 20:46:33.733	2026-04-16 20:46:33.733
cmo1y9ba904edvxt0w4nv2tk5	Hành tím khô sấy lát (gói 50gr)	XUANLOC72	cmo1xc0tk0000vxp0m1od0byy	Gói	106000	\N	\N	\N	t	2026-04-16 20:46:33.825	2026-04-16 20:46:33.825
cmo1y9bcr04f1vxt0xcoi9mnd	Tỏi khô sấy lát (gói 50gr)	XUANLOC71	cmo1xc0tk0000vxp0m1od0byy	Gói	113000	\N	\N	\N	t	2026-04-16 20:46:33.914	2026-04-16 20:46:33.914
cmo1y9be904f9vxt0ijuv0tc3	Xá bấu	XUANLOC70	cmo1xc0tk0000vxp0m1od0byy	Kg	0	\N	\N	\N	t	2026-04-16 20:46:33.969	2026-04-16 20:46:33.969
cmo1y9bf904fdvxt0rqeihqjz	Bánh nổ không đường (gói 200gr)	XUANLOC69	cmo1xc0tk0000vxp0m1od0byy	Gói	41000	\N	\N	\N	t	2026-04-16 20:46:34.005	2026-04-16 20:46:34.005
cmo1y9bhu04g1vxt0dj4ey3xn	Bột mè cửu chưng cửu sái (hủ 100gr)	XUANLOC68	cmo1xc0tk0000vxp0m1od0byy	Hủ	65000	\N	\N	\N	t	2026-04-16 20:46:34.099	2026-04-16 20:46:34.099
cmo1y9bj104g7vxt06tw8yrei	Mè cửu chưng cửu sái (hủ 200gr)	XUANLOC67	cmo1xc0tk0000vxp0m1od0byy	Hủ	185000	\N	\N	\N	t	2026-04-16 20:46:34.141	2026-04-16 20:46:34.141
cmo1y9blr04gvvxt0f7edli18	Dưa leo muối ngọt (gói 150gr)	XUANLOC66	cmo1xc0tk0000vxp0m1od0byy	Gói	36000	\N	\N	\N	t	2026-04-16 20:46:34.239	2026-04-16 20:46:34.239
cmo1y9bo904hjvxt0dy5qm2wl	Sét nấu nước 7 gói (Mã đề+ Rau má + Rau bắp + Rễ cỏ tranh)	XUANLOC65	cmo1xc0tk0000vxp0m1od0byy	Gói	120000	\N	\N	\N	t	2026-04-16 20:46:34.329	2026-04-16 20:46:34.329
cmo1y9bqz04i7vxt0zqdl6lsd	Hoài sơn (gói 50gr)	XUANLOC64	cmo1xc0tk0000vxp0m1od0byy	Gói	50000	\N	\N	\N	t	2026-04-16 20:46:34.427	2026-04-16 20:46:34.427
cmo1y9brx04i9vxt0r83rjz2h	Bơ đậu phộng (hủ 5kg)	XUANLOC63	cmo1xc0tk0000vxp0m1od0byy	Hủ	0	\N	\N	\N	t	2026-04-16 20:46:34.461	2026-04-16 20:46:34.461
cmo1y9buk04ixvxt0cq4sxv2v	Hoài sơn	XUANLOC62	cmo1xc0tk0000vxp0m1od0byy	Kg	0	\N	\N	\N	t	2026-04-16 20:46:34.557	2026-04-16 20:46:34.557
cmo1y9bxc04jlvxt0ctlgqmbx	Sét hầm nước 7 món (gói 90gr-100gr)	XUANLOC61	cmo1xc0tk0000vxp0m1od0byy	Gói	89000	\N	\N	\N	t	2026-04-16 20:46:34.656	2026-04-16 20:46:34.656
cmo1y9c0504k9vxt043zlhiq3	Trà sâm dây (hủ 100gr)	XUANLOC60	cmo1xc0tk0000vxp0m1od0byy	Hủ	180000	\N	\N	\N	t	2026-04-16 20:46:34.757	2026-04-16 20:46:34.757
cmo1y9c2u04kxvxt0vts5zoic	Sét hầm gà (sâm+bo bo+kê+gừng+ hoài sơn)	XUANLOC59	cmo1xc0tk0000vxp0m1od0byy	Gói	0	\N	\N	\N	t	2026-04-16 20:46:34.855	2026-04-16 20:46:34.855
cmo1y9c3v04l1vxt0mjqgyxec	Sét hầm gà (sâm+bo bo+kê+nấm+gừng+ hoài sơn)	XUANLOC58	cmo1xc0tk0000vxp0m1od0byy	Gói	0	\N	\N	\N	t	2026-04-16 20:46:34.891	2026-04-16 20:46:34.891
cmo1y9c5204l5vxt0lg1u6sn6	Dầu hành phi (hủ 150gr)	XUANLOC57	cmo1xc0tk0000vxp0m1od0byy	Hủ	89000	\N	\N	\N	t	2026-04-16 20:46:34.934	2026-04-16 20:46:34.934
cmo1y9c7q04ltvxt0fl7c71f5	Trà đậu săng (gói 250gr)	XUANLOC56	cmo1xc0tk0000vxp0m1od0byy	Gói	100000	\N	\N	\N	t	2026-04-16 20:46:35.031	2026-04-16 20:46:35.031
cmo1y9cab04mhvxt0a2cvnn4i	Ngãi cứu sấy khô (gói 50gr)	XUANLOC55	cmo1xc0tk0000vxp0m1od0byy	Gói	52000	\N	\N	\N	t	2026-04-16 20:46:35.123	2026-04-16 20:46:35.123
cmo1y9cd404n5vxt04xh0vs7e	Củ cải khô	XUANLOC54	cmo1xc0tk0000vxp0m1od0byy	Kg	0	\N	\N	\N	t	2026-04-16 20:46:35.224	2026-04-16 20:46:35.224
cmo1y9cfk04ntvxt06uin5ggr	Hành tím muối chua (hủ 250gr)	XUANLOC53	cmo1xc0tk0000vxp0m1od0byy	Hủ	70000	\N	\N	\N	t	2026-04-16 20:46:35.313	2026-04-16 20:46:35.313
cmo1y9ci504ohvxt0v61mly99	Rau má sấy khô (50gr)	XUANLOC52	cmo1xc0tk0000vxp0m1od0byy	Gói	55000	\N	\N	\N	t	2026-04-16 20:46:35.405	2026-04-16 20:46:35.405
cmo1y9ckp04p5vxt03maaecy1	Sét hạt hoài sơn kê bo bo	XUANLOC51	cmo1xc0tk0000vxp0m1od0byy	Gói	59000	\N	\N	\N	t	2026-04-16 20:46:35.497	2026-04-16 20:46:35.497
cmo1y9cni04ptvxt0nwuugm1t	Củ cải khô (gói 100gr)	XUANLOC50	cmo1xc0tk0000vxp0m1od0byy	Gói	72000	\N	\N	\N	t	2026-04-16 20:46:35.598	2026-04-16 20:46:35.598
cmo1y9cq104qhvxt0um5kk1e7	Hành lá sấy khô (50gr)	XUANLOC49	cmo1xc0tk0000vxp0m1od0byy	Gói	55000	\N	\N	\N	t	2026-04-16 20:46:35.689	2026-04-16 20:46:35.689
cmo1y9cst04r5vxt0ra2sieoc	Hành tây khô sấy lát (gói 50gr)	XUANLOC48	cmo1xc0tk0000vxp0m1od0byy	Gói	106000	\N	\N	\N	t	2026-04-16 20:46:35.789	2026-04-16 20:46:35.789
cmo1y9cvn04rtvxt09d7mgsbk	Gừng chua ngọt (gói 200gr)	XUANLOC47	cmo1xc0tk0000vxp0m1od0byy	Gói	70000	\N	\N	\N	t	2026-04-16 20:46:35.891	2026-04-16 20:46:35.891
cmo1y9cyc04shvxt08bf289p0	Củ cải nguyên củ khô (gói 100gr)	XUANLOC46	cmo1xc0tk0000vxp0m1od0byy	Gói	72000	\N	\N	\N	t	2026-04-16 20:46:35.989	2026-04-16 20:46:35.989
cmo1y9d1604t5vxt054hourcx	Cải muối chua nguyên cây	XUANLOC45	cmo1xc0tk0000vxp0m1od0byy	Kg	85000	\N	\N	\N	t	2026-04-16 20:46:36.09	2026-04-16 20:46:36.09
cmo1y9d3x04ttvxt0imbzs2rz	Cà rốt sấy khô (gói 100gr)	XUANLOC44	cmo1xc0tk0000vxp0m1od0byy	Gói	80000	\N	\N	\N	t	2026-04-16 20:46:36.189	2026-04-16 20:46:36.189
cmo1y9d6p04uhvxt0g5r2061s	Dầu đậu phộng	XUANLOC43	cmo1xc0tk0000vxp0m1od0byy	Lít	285000	\N	\N	\N	t	2026-04-16 20:46:36.289	2026-04-16 20:46:36.289
cmo1y9d9h04v5vxt03n8xpq2m	Sate ớt	XUANLOC42	cmo1xc0tk0000vxp0m1od0byy	Hủ	89000	\N	\N	\N	t	2026-04-16 20:46:36.389	2026-04-16 20:46:36.389
cmo1y9dc604vtvxt0vhsyf3j9	Sate ớt sả	XUANLOC41	cmo1xc0tk0000vxp0m1od0byy	Hủ	89000	\N	\N	\N	t	2026-04-16 20:46:36.486	2026-04-16 20:46:36.486
cmo1y9des04whvxt0jgg7neib	Sate ớt sả tỏi	XUANLOC40	cmo1xc0tk0000vxp0m1od0byy	Hủ	89000	\N	\N	\N	t	2026-04-16 20:46:36.58	2026-04-16 20:46:36.58
cmo1y9dhc04x5vxt05qp2pdol	Sate ớt tỏi	XUANLOC39	cmo1xc0tk0000vxp0m1od0byy	Hủ	89000	\N	\N	\N	t	2026-04-16 20:46:36.672	2026-04-16 20:46:36.672
cmo1y9dk504xtvxt041klrgz6	Dầu điều màu (250ml)	XUANLOC38	cmo1xc0tk0000vxp0m1od0byy	Chai	113000	\N	\N	\N	t	2026-04-16 20:46:36.774	2026-04-16 20:46:36.774
cmo1y9dmw04yhvxt03zug4u65	Dầu điều màu (100ml)	XUANLOC37	cmo1xc0tk0000vxp0m1od0byy	Chai	59000	\N	\N	\N	t	2026-04-16 20:46:36.872	2026-04-16 20:46:36.872
cmo1y9dph04z5vxt0nufw3sqb	Dầu mè đen (250ml)	XUANLOC36	cmo1xc0tk0000vxp0m1od0byy	Chai	158000	\N	\N	\N	t	2026-04-16 20:46:36.965	2026-04-16 20:46:36.965
cmo1y9ds904ztvxt0glkz29nr	Măng khô (gói 100gr)	XUANLOC35	cmo1xc0tk0000vxp0m1od0byy	Gói	60000	\N	\N	\N	t	2026-04-16 20:46:37.066	2026-04-16 20:46:37.066
cmo1y9dv9050lvxt0exwwvuso	Măng khô (gói 200gr)	XUANLOC34	cmo1xc0tk0000vxp0m1od0byy	Gói	117000	\N	\N	\N	t	2026-04-16 20:46:37.173	2026-04-16 20:46:37.173
cmo1y9dy9051dvxt0k7erix33	Mít luộc	XUANLOC33	cmo1xc0tk0000vxp0m1od0byy	Kg	0	\N	\N	\N	t	2026-04-16 20:46:37.281	2026-04-16 20:46:37.281
cmo1y9e160525vxt0nxcp3cjh	Bánh tráng nướng	XUANLOC32	cmo1xc0tk0000vxp0m1od0byy	Cái	6000	\N	\N	\N	t	2026-04-16 20:46:37.386	2026-04-16 20:46:37.386
cmo1y9e200527vxt0yc5luoup	Bột đậu đen cửu chưng cửu sái (200gr)	XUANLOC31	cmo1xc0tk0000vxp0m1od0byy	Hủ	76000	\N	\N	\N	t	2026-04-16 20:46:37.417	2026-04-16 20:46:37.417
cmo1y9e38052dvxt0537e6vt2	Bột ớt đỏ gia vị (xá)	XUANLOC30	cmo1xc0tk0000vxp0m1od0byy	Kg	858000	\N	\N	\N	t	2026-04-16 20:46:37.46	2026-04-16 20:46:37.46
cmo1y9e4n052nvxt0247b851y	Phở gạo trắng (tặng)	XUANLOC29	cmo1xc0tk0000vxp0m1od0byy	Kg	0	\N	\N	\N	t	2026-04-16 20:46:37.511	2026-04-16 20:46:37.511
cmo1y9e5g052pvxt0frgjcams	Bột đậu đen cửu chưng cửu sái (500gr)	XUANLOC28	cmo1xc0tk0000vxp0m1od0byy	Hủ	168000	\N	\N	\N	t	2026-04-16 20:46:37.54	2026-04-16 20:46:37.54
cmo1y9e6i052vvxt08q2fr1mc	Trà tía tô (xá)	XUANLOC27	cmo1xc0tk0000vxp0m1od0byy	Kg	0	\N	\N	\N	t	2026-04-16 20:46:37.578	2026-04-16 20:46:37.578
cmo1y9e7l0531vxt0e18a6m5p	Sét canh hầm bổ tỳ (Bo Bo, Hoài sơn, Táo đỏ, Gừng)	XUANLOC26	cmo1xc0tk0000vxp0m1od0byy	Gói	47000	\N	\N	\N	t	2026-04-16 20:46:37.618	2026-04-16 20:46:37.618
cmo1y9e8u0539vxt01bwx6qve	Sét cháo nếp táo đỏ hạt sen gừng	XUANLOC25	cmo1xc0tk0000vxp0m1od0byy	Gói	55000	\N	\N	\N	t	2026-04-16 20:46:37.662	2026-04-16 20:46:37.662
cmo1y9eae053hvxt0m28tm36o	Sét cháo nếp táo đỏ gừng	XUANLOC24	cmo1xc0tk0000vxp0m1od0byy	Gói	47000	\N	\N	\N	t	2026-04-16 20:46:37.718	2026-04-16 20:46:37.718
cmo1y9ebl053pvxt00qfxh8wm	Bột gừng pha uống (hủ 100gr)	XUANLOC23	cmo1xc0tk0000vxp0m1od0byy	Hủ	160000	\N	\N	\N	t	2026-04-16 20:46:37.761	2026-04-16 20:46:37.761
cmo1y9ecd053rvxt0aypyik1a	Bột ớt đỏ gia vị (gói 100gr)	XUANLOC22	cmo1xc0tk0000vxp0m1od0byy	Gói	118000	\N	\N	\N	t	2026-04-16 20:46:37.789	2026-04-16 20:46:37.789
cmo1y9edr053zvxt06s83ulsw	Trà sâm dây (gói 300gr)	XUANLOC21	cmo1xc0tk0000vxp0m1od0byy	Gói	525000	\N	\N	\N	t	2026-04-16 20:46:37.839	2026-04-16 20:46:37.839
cmo1y9eel0541vxt0bpc5zjfw	Mứt gừng dẻo đường cát lu (hủ 200gr)	XUANLOC20	cmo1xc0tk0000vxp0m1od0byy	Hủ	79000	\N	\N	\N	t	2026-04-16 20:46:37.869	2026-04-16 20:46:37.869
cmo1y9efs0549vxt08fpgpu6c	Hành tây sấy (kg)	XUANLOC19	cmo1xc0tk0000vxp0m1od0byy	Kg	0	\N	\N	\N	t	2026-04-16 20:46:37.912	2026-04-16 20:46:37.912
cmo1y9eh1054fvxt0i2ay48sy	Hành lá khô (kg)	XUANLOC18	cmo1xc0tk0000vxp0m1od0byy	Kg	0	\N	\N	\N	t	2026-04-16 20:46:37.958	2026-04-16 20:46:37.958
cmo1y9ei8054lvxt0ix1buhj3	Sâm dây ngâm mật ong (hủ 120gr)	XUANLOC17	cmo1xc0tk0000vxp0m1od0byy	Hủ	178000	\N	\N	\N	t	2026-04-16 20:46:38	2026-04-16 20:46:38
cmo1y9eji054tvxt0ehdz1kvb	Măng khô (xá)	XUANLOC16	cmo1xc0tk0000vxp0m1od0byy	Kg	0	\N	\N	\N	t	2026-04-16 20:46:38.046	2026-04-16 20:46:38.046
cmo1y9eks054zvxt03z4ry1u8	Mứt gừng dẻo đường mía thô (hủ 200gr)	XUANLOC15	cmo1xc0tk0000vxp0m1od0byy	Hủ	130000	\N	\N	\N	t	2026-04-16 20:46:38.092	2026-04-16 20:46:38.092
cmo1y9em70557vxt0n5qufst0	Bột gạo xà cơn trắng (xay thô) hủ 500gr	XUANLOC14	cmo1xc0tk0000vxp0m1od0byy	Hủ	75000	\N	\N	\N	t	2026-04-16 20:46:38.143	2026-04-16 20:46:38.143
cmo1y9eni055fvxt03rm0mv6r	Bột gạo huyết rồng (xay thô) hủ 500gr	XUANLOC13	cmo1xc0tk0000vxp0m1od0byy	Hủ	75000	\N	\N	\N	t	2026-04-16 20:46:38.191	2026-04-16 20:46:38.191
cmo1y9eov055nvxt0uz8png1k	Dầu mè đen	XUANLOC12	cmo1xc0tk0000vxp0m1od0byy	Lít	570000	\N	\N	\N	t	2026-04-16 20:46:38.239	2026-04-16 20:46:38.239
cmo1y9eq5055vvxt03gy4fdxb	Ớt khô nguyên trái (xá)	XUANLOC11	cmo1xc0tk0000vxp0m1od0byy	Gói	0	\N	\N	\N	t	2026-04-16 20:46:38.285	2026-04-16 20:46:38.285
cmo1y9erd0563vxt0t4tkyiej	Mứt gừng dẻo đường mía thô (hủ 500gr)	XUANLOC10	cmo1xc0tk0000vxp0m1od0byy	Hủ	315000	\N	\N	\N	t	2026-04-16 20:46:38.329	2026-04-16 20:46:38.329
cmo1y9esn056bvxt0fptengvl	Rau bắp khô (100gr)	XUANLOC9	cmo1xc0tk0000vxp0m1od0byy	Gói	0	\N	\N	\N	t	2026-04-16 20:46:38.375	2026-04-16 20:46:38.375
cmo1y9ett056hvxt0tqkezsi1	Rau bắp khô (100gr).	XUANLOC8	cmo1xc0tk0000vxp0m1od0byy	Gói	0	\N	\N	\N	t	2026-04-16 20:46:38.417	2026-04-16 20:46:38.417
cmo1y9euy056nvxt0x3jjuhx7	Sét nấu sữa hạt 15 gói	XUANLOC7	cmo1xc0tk0000vxp0m1od0byy	Set	295000	\N	\N	\N	t	2026-04-16 20:46:38.458	2026-04-16 20:46:38.458
cmo1y9ew8056vvxt0d76a8m94	Đậu ván rang củi (500gr)	XUANLOC6	cmo1xc0tk0000vxp0m1od0byy	Gói	130000	\N	\N	\N	t	2026-04-16 20:46:38.504	2026-04-16 20:46:38.504
cmo1y9exj0573vxt0i4zw0g05	Gói nấu sữa hạt 50gr	XUANLOC5	cmo1xc0tk0000vxp0m1od0byy	Set	20000	\N	\N	\N	t	2026-04-16 20:46:38.551	2026-04-16 20:46:38.551
cmo1y9eye0575vxt0s52hy23h	Sét trà mát dưỡng huyết 7 gói (bo bo, xích tiểu đậu, rau bắp)	XUANLOC4	cmo1xc0tk0000vxp0m1od0byy	Set	125000	\N	\N	\N	t	2026-04-16 20:46:38.583	2026-04-16 20:46:38.583
cmo1y9ezk057bvxt07byeb1av	Sét trà gừng sả 7 gói	XUANLOC3	cmo1xc0tk0000vxp0m1od0byy	Gói	54000	\N	\N	\N	t	2026-04-16 20:46:38.624	2026-04-16 20:46:38.624
cmo1y9f0z057hvxt0s5jxwzoa	Sét trà gừng sả táo đỏ kỷ tử 7 gói	XUANLOC2	cmo1xc0tk0000vxp0m1od0byy	Gói	234000	\N	\N	\N	t	2026-04-16 20:46:38.676	2026-04-16 20:46:38.676
cmo1y9f25057nvxt00iajwzgk	Măng khô (gói 500gr)	XUANLOC1	cmo1xc0tk0000vxp0m1od0byy	Gói	0	\N	\N	\N	t	2026-04-16 20:46:38.718	2026-04-16 20:46:38.718
cmo1y9f3q057vvxt0mfyx1z3n	Cật	HANGTUOI51	cmo1xc0vc0002vxp0ro9otvn0	Kg	191000	\N	\N	\N	t	2026-04-16 20:46:38.774	2026-04-16 20:46:38.774
cmo1y9f4r0581vxt0bevro4gx	Huyết	HANGTUOI50	cmo1xc0vc0002vxp0ro9otvn0	Kg	0	\N	\N	\N	t	2026-04-16 20:46:38.812	2026-04-16 20:46:38.812
cmo1y9f5o0585vxt05vtsmqsi	Cuốn họng	HANGTUOI49	cmo1xc0vc0002vxp0ro9otvn0	Kg	0	\N	\N	\N	t	2026-04-16 20:46:38.845	2026-04-16 20:46:38.845
cmo1y9f6c0587vxt0ia8x56c5	Ba chỉ rút xương	HANGTUOI48	cmo1xc0vc0002vxp0ro9otvn0	Kg	234000	\N	\N	\N	t	2026-04-16 20:46:38.869	2026-04-16 20:46:38.869
cmo1y9f7u058lvxt0ibjm1o4g	Cốt lết	HANGTUOI47	cmo1xc0vc0002vxp0ro9otvn0	Kg	234000	\N	\N	\N	t	2026-04-16 20:46:38.923	2026-04-16 20:46:38.923
cmo1y9f9j058zvxt0sc7yz347	Đùi	HANGTUOI46	cmo1xc0vc0002vxp0ro9otvn0	Kg	234000	\N	\N	\N	t	2026-04-16 20:46:38.984	2026-04-16 20:46:38.984
cmo1y9fbe059dvxt04ijh3f89	Đuôi	HANGTUOI45	cmo1xc0vc0002vxp0ro9otvn0	Kg	234000	\N	\N	\N	t	2026-04-16 20:46:39.05	2026-04-16 20:46:39.05
cmo1y9fd7059pvxt0h30040k7	Nạc dăm	HANGTUOI44	cmo1xc0vc0002vxp0ro9otvn0	Kg	234000	\N	\N	\N	t	2026-04-16 20:46:39.115	2026-04-16 20:46:39.115
cmo1y9ff305a3vxt0cexvwprm	Thịt xay	HANGTUOI43	cmo1xc0vc0002vxp0ro9otvn0	Kg	234000	\N	\N	\N	t	2026-04-16 20:46:39.183	2026-04-16 20:46:39.183
cmo1y9fgx05afvxt0kxow93y3	Giò	HANGTUOI42	cmo1xc0vc0002vxp0ro9otvn0	Kg	234000	\N	\N	\N	t	2026-04-16 20:46:39.248	2026-04-16 20:46:39.248
cmo1y9fin05arvxt0bo9wzwfi	Sườn non	HANGTUOI41	cmo1xc0vc0002vxp0ro9otvn0	Kg	244000	\N	\N	\N	t	2026-04-16 20:46:39.311	2026-04-16 20:46:39.311
cmo1y9fke05b5vxt0lal4ug8f	Dồi huyết	HANGTUOI40	cmo1xc0vc0002vxp0ro9otvn0	Kg	191000	\N	\N	\N	t	2026-04-16 20:46:39.374	2026-04-16 20:46:39.374
cmo1y9fm805bjvxt0o0ix17v8	Bao tử	HANGTUOI39	cmo1xc0vc0002vxp0ro9otvn0	Kg	202000	\N	\N	\N	t	2026-04-16 20:46:39.44	2026-04-16 20:46:39.44
cmo1y9fnw05bvvxt05ra2lqpd	Tai	HANGTUOI38	cmo1xc0vc0002vxp0ro9otvn0	Kg	202000	\N	\N	\N	t	2026-04-16 20:46:39.5	2026-04-16 20:46:39.5
cmo1y9fpr05c7vxt00y7f3tn4	Tim	HANGTUOI37	cmo1xc0vc0002vxp0ro9otvn0	Kg	234000	\N	\N	\N	t	2026-04-16 20:46:39.567	2026-04-16 20:46:39.567
cmo1y9frl05cjvxt0wl6v6c0y	Xương	HANGTUOI36	cmo1xc0vc0002vxp0ro9otvn0	Kg	191000	\N	\N	\N	t	2026-04-16 20:46:39.634	2026-04-16 20:46:39.634
cmo1y9ftf05cvvxt0lmibgrxo	Xương cổ	HANGTUOI35	cmo1xc0vc0002vxp0ro9otvn0	Kg	191000	\N	\N	\N	t	2026-04-16 20:46:39.699	2026-04-16 20:46:39.699
cmo1y9fvd05d9vxt0j5ypmgtl	Xương ống	HANGTUOI34	cmo1xc0vc0002vxp0ro9otvn0	Kg	170000	\N	\N	\N	t	2026-04-16 20:46:39.769	2026-04-16 20:46:39.769
cmo1y9fx405dnvxt0orrd2m7l	Lưỡi	HANGTUOI33	cmo1xc0vc0002vxp0ro9otvn0	Kg	202000	\N	\N	\N	t	2026-04-16 20:46:39.832	2026-04-16 20:46:39.832
cmo1y9fyi05dzvxt0dmjt8j8l	Mỡ heo	HANGTUOI32	cmo1xc0vc0002vxp0ro9otvn0	Kg	170000	\N	\N	\N	t	2026-04-16 20:46:39.882	2026-04-16 20:46:39.882
cmo1y9g0d05ebvxt09qc7fq4v	Gan	HANGTUOI31	cmo1xc0vc0002vxp0ro9otvn0	Kg	128000	\N	\N	\N	t	2026-04-16 20:46:39.95	2026-04-16 20:46:39.95
cmo1y9g2805epvxt0jv1rqp4r	Óc	HANGTUOI30	cmo1xc0vc0002vxp0ro9otvn0	Bộ	43000	\N	\N	\N	t	2026-04-16 20:46:40.016	2026-04-16 20:46:40.016
cmo1y9g3x05f1vxt05i1vbfi2	Gà ta	HANGTUOI29	cmo1xc0vc0002vxp0ro9otvn0	Kg	234000	\N	\N	\N	t	2026-04-16 20:46:40.077	2026-04-16 20:46:40.077
cmo1y9g5h05fdvxt0ny4qv458	Gà bản	HANGTUOI28	cmo1xc0vc0002vxp0ro9otvn0	Kg	0	\N	\N	\N	t	2026-04-16 20:46:40.133	2026-04-16 20:46:40.133
cmo1y9g6g05fhvxt05d510zna	Lòng Hấp	HANGTUOI27	cmo1xc0vc0002vxp0ro9otvn0	Kg	244000	\N	\N	\N	t	2026-04-16 20:46:40.168	2026-04-16 20:46:40.168
cmo1y9g8905ftvxt0dprrq3yk	Nạc vai	HANGTUOI26	cmo1xc0vc0002vxp0ro9otvn0	Kg	234000	\N	\N	\N	t	2026-04-16 20:46:40.233	2026-04-16 20:46:40.233
cmo1y9ga305g5vxt08e4v806g	Vịt đồng	HANGTUOI25	cmo1xc0vc0002vxp0ro9otvn0	Con	234000	\N	\N	\N	t	2026-04-16 20:46:40.299	2026-04-16 20:46:40.299
cmo1y9gby05ghvxt0kot7y3xw	Chim bồ câu	HANGTUOI24	cmo1xc0vc0002vxp0ro9otvn0	Con	122000	\N	\N	\N	t	2026-04-16 20:46:40.366	2026-04-16 20:46:40.366
cmo1y9gdm05gtvxt0uveu6b50	Công gà	HANGTUOI23	cmo1xc0vc0002vxp0ro9otvn0	Con	0	\N	\N	\N	t	2026-04-16 20:46:40.426	2026-04-16 20:46:40.426
cmo1y9gej05gxvxt0n30e1qz9	Sườn cọng	HANGTUOI22	cmo1xc0vc0002vxp0ro9otvn0	Kg	244000	\N	\N	\N	t	2026-04-16 20:46:40.459	2026-04-16 20:46:40.459
cmo1y9gg905h9vxt0xjaba1wb	Mỡ heo + Công cắt, thắng mỡ, đóng hộp	HANGTUOI21	cmo1xc0vc0002vxp0ro9otvn0	Kg	205000	\N	\N	\N	t	2026-04-16 20:46:40.522	2026-04-16 20:46:40.522
cmo1y9ghs05hjvxt097bcs805	Gà ác nhỏ	HANGTUOI20	cmo1xc0vc0002vxp0ro9otvn0	Con	106000	\N	\N	\N	t	2026-04-16 20:46:40.576	2026-04-16 20:46:40.576
cmo1y9gjd05hvvxt0ye4ssip7	Cật	HANGTUOI19	cmo1xc0vc0002vxp0ro9otvn0	Kg	191000	\N	\N	\N	t	2026-04-16 20:46:40.633	2026-04-16 20:46:40.633
cmo1y9gl705i7vxt0o0cpkzyg	Phụ phí thùng xốp	HANGTUOI18	cmo1xc0vc0002vxp0ro9otvn0	Kg	20000	\N	\N	\N	t	2026-04-16 20:46:40.699	2026-04-16 20:46:40.699
cmo1y9gmv05ihvxt0y5t2goii	Lòng tươi	HANGTUOI17	cmo1xc0vc0002vxp0ro9otvn0	Kg	170000	\N	\N	\N	t	2026-04-16 20:46:40.76	2026-04-16 20:46:40.76
cmo1y9gos05itvxt0yuubvcin	Đùi bò	HANGTUOI16	cmo1xc0vc0002vxp0ro9otvn0	Kg	0	\N	\N	\N	t	2026-04-16 20:46:40.828	2026-04-16 20:46:40.828
cmo1y9gpt05ixvxt0elddv8in	Bắp bò	HANGTUOI15	cmo1xc0vc0002vxp0ro9otvn0	Kg	0	\N	\N	\N	t	2026-04-16 20:46:40.865	2026-04-16 20:46:40.865
cmo1y9gqr05j1vxt0p45g6qn9	Phi lê bò	HANGTUOI14	cmo1xc0vc0002vxp0ro9otvn0	Kg	0	\N	\N	\N	t	2026-04-16 20:46:40.9	2026-04-16 20:46:40.9
cmo1y9gri05j3vxt0fkx3m8xt	Nạc thăn	HANGTUOI13	cmo1xc0vc0002vxp0ro9otvn0	Kg	234000	\N	\N	\N	t	2026-04-16 20:46:40.927	2026-04-16 20:46:40.927
cmo1y9gte05jlvxt04svy8md6	Nạm bò	HANGTUOI12	cmo1xc0vc0002vxp0ro9otvn0	Kg	0	\N	\N	\N	t	2026-04-16 20:46:40.995	2026-04-16 20:46:40.995
cmo1y9gu905jnvxt0931cc8sj	Móng heo	HANGTUOI11	cmo1xc0vc0002vxp0ro9otvn0	Kg	234000	\N	\N	\N	t	2026-04-16 20:46:41.025	2026-04-16 20:46:41.025
cmo1y9gvu05jzvxt00cl191dv	Gà ác lớn	HANGTUOI10	cmo1xc0vc0002vxp0ro9otvn0	Con	276000	\N	\N	\N	t	2026-04-16 20:46:41.082	2026-04-16 20:46:41.082
cmo1y9gxk05kbvxt023w07vkw	Dạ trường	HANGTUOI9	cmo1xc0vc0002vxp0ro9otvn0	Kg	0	\N	\N	\N	t	2026-04-16 20:46:41.144	2026-04-16 20:46:41.144
cmo1y9gyg05kdvxt0owdonlel	Má heo	HANGTUOI8	cmo1xc0vc0002vxp0ro9otvn0	Kg	0	\N	\N	\N	t	2026-04-16 20:46:41.176	2026-04-16 20:46:41.176
cmo1y9gzc05kfvxt0i29y35ln	Da heo	HANGTUOI7	cmo1xc0vc0002vxp0ro9otvn0	Kg	0	\N	\N	\N	t	2026-04-16 20:46:41.208	2026-04-16 20:46:41.208
cmo1y9h0905khvxt050ytqrcy	Gù bò	HANGTUOI6	cmo1xc0vc0002vxp0ro9otvn0	Kg	0	\N	\N	\N	t	2026-04-16 20:46:41.241	2026-04-16 20:46:41.241
cmo1y9h1j05klvxt0dvqcfjo8	Xương ống lóc thịt	HANGTUOI5	cmo1xc0vc0002vxp0ro9otvn0	Kg	0	\N	\N	\N	t	2026-04-16 20:46:41.287	2026-04-16 20:46:41.287
cmo1y9h2e05kpvxt0bux83ma7	Thăn bò	HANGTUOI4	cmo1xc0vc0002vxp0ro9otvn0	Kg	0	\N	\N	\N	t	2026-04-16 20:46:41.318	2026-04-16 20:46:41.318
cmo1y9h3805ktvxt0ng0y4ffn	Sườn già	HANGTUOI3	cmo1xc0vc0002vxp0ro9otvn0	Kg	234000	\N	\N	\N	t	2026-04-16 20:46:41.348	2026-04-16 20:46:41.348
cmo1y9h4i05l5vxt0l3spcmsc	Lá xách (lá mía) heo	HANGTUOI2	cmo1xc0vc0002vxp0ro9otvn0	Kg	0	\N	\N	\N	t	2026-04-16 20:46:41.395	2026-04-16 20:46:41.395
cmo1y9h5d05l7vxt0f7a17q1u	Đầu heo	HANGTUOI1	cmo1xc0vc0002vxp0ro9otvn0	Kg	0	\N	\N	\N	t	2026-04-16 20:46:41.426	2026-04-16 20:46:41.426
cmo1y94xh02vvvxt0ag84ao9n	Gạo thơm xát trắng - túi 5kg (Hàng chương trình 15/1-25/1)	MFKHD12	cmo1xc0vw0004vxp0uzuqvrgw	Túi	170000	\N	\N	\N	t	2026-04-16 20:46:25.59	2026-04-16 20:47:34.869
cmo1y8urr0097vxt0o8a2z4m2	Khoai lang (cạp)	MFKHD1	cmo1xc0vw0004vxp0uzuqvrgw	Kg	48000	\N	\N	\N	t	2026-04-16 20:46:12.424	2026-04-16 20:47:54.625
cmo1y8uqj0091vxt0mdhz294w	Trứng gà (tặng)	MFKHD3	cmo1xc0vw0004vxp0uzuqvrgw	Cái	0	\N	\N	\N	t	2026-04-16 20:46:12.379	2026-04-16 20:48:21.113
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: oms_user
--

COPY public.users (id, email, "passwordHash", "fullName", role, "isActive", "refreshTokenHash", "createdAt", "updatedAt") FROM stdin;
cmo1u51iy0000vxgku42az9lu	poka@poka.us	$2b$12$WyrqWDKx9Vm5.RetiIBEoOZkxdmnER.xj8yf/FnpqPeRr.0xuBK7.	Administrator	ADMIN	t	$2b$10$SPobC396vmroWRkXtC1xDeaVo7UX.abkxqvmyUz08Y1gEinxmhco2	2026-04-16 18:51:16.09	2026-04-18 17:45:44.042
\.


--
-- Data for Name: audit_logs; Type: TABLE DATA; Schema: shadow; Owner: oms_user
--

COPY shadow.audit_logs (id, "userId", "userEmail", action, "entityType", "entityId", "oldData", "newData", "ipAddress", "createdAt") FROM stdin;
\.


--
-- Data for Name: cancel_reasons; Type: TABLE DATA; Schema: shadow; Owner: oms_user
--

COPY shadow.cancel_reasons (id, label, "isActive", "sortOrder", "createdAt") FROM stdin;
\.


--
-- Data for Name: company_settings; Type: TABLE DATA; Schema: shadow; Owner: oms_user
--

COPY shadow.company_settings (id, name, address, phone, email, "taxCode", "logoUrl", "bankInfo", "invoiceFooter", "updatedAt") FROM stdin;
\.


--
-- Data for Name: customer_groups; Type: TABLE DATA; Schema: shadow; Owner: oms_user
--

COPY shadow.customer_groups (id, name, description, "priceType", "discountPercent", "isDefault", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: customer_special_prices; Type: TABLE DATA; Schema: shadow; Owner: oms_user
--

COPY shadow.customer_special_prices (id, "customerId", "productId", price, notes, "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: customers; Type: TABLE DATA; Schema: shadow; Owner: oms_user
--

COPY shadow.customers (id, phone, "fullName", "groupId", "provinceCode", "provinceName", "wardCode", "wardName", "addressDetail", notes, "isActive", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: order_items; Type: TABLE DATA; Schema: shadow; Owner: oms_user
--

COPY shadow.order_items (id, "orderId", "productId", "snapshotProductName", "snapshotProductSku", "snapshotProductUnit", "snapshotUnitPrice", "priceSource", "pricingNote", quantity, "lineDiscount", "lineTotal") FROM stdin;
\.


--
-- Data for Name: orders; Type: TABLE DATA; Schema: shadow; Owner: oms_user
--

COPY shadow.orders (id, "orderNumber", "customerId", "snapshotCustomerName", "snapshotCustomerPhone", "createdById", "deliveryStatus", subtotal, "discountAmount", "shippingFee", "totalAmount", "cancelReasonId", "cancelNotes", notes, "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: product_group_prices; Type: TABLE DATA; Schema: shadow; Owner: oms_user
--

COPY shadow.product_group_prices (id, "productId", "groupId", "fixedPrice", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: products; Type: TABLE DATA; Schema: shadow; Owner: oms_user
--

COPY shadow.products (id, name, sku, unit, "retailPrice", "costPrice", stock, weight, dimensions, "isActive", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: shadow; Owner: oms_user
--

COPY shadow.users (id, email, "passwordHash", "fullName", role, "isActive", "createdAt", "updatedAt", "refreshTokenHash") FROM stdin;
\.


--
-- Name: _prisma_migrations _prisma_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: oms_user
--

ALTER TABLE ONLY public._prisma_migrations
    ADD CONSTRAINT _prisma_migrations_pkey PRIMARY KEY (id);


--
-- Name: audit_logs audit_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: oms_user
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT audit_logs_pkey PRIMARY KEY (id);


--
-- Name: cancel_reasons cancel_reasons_pkey; Type: CONSTRAINT; Schema: public; Owner: oms_user
--

ALTER TABLE ONLY public.cancel_reasons
    ADD CONSTRAINT cancel_reasons_pkey PRIMARY KEY (id);


--
-- Name: company_settings company_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: oms_user
--

ALTER TABLE ONLY public.company_settings
    ADD CONSTRAINT company_settings_pkey PRIMARY KEY (id);


--
-- Name: customer_groups customer_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: oms_user
--

ALTER TABLE ONLY public.customer_groups
    ADD CONSTRAINT customer_groups_pkey PRIMARY KEY (id);


--
-- Name: customer_special_prices customer_special_prices_pkey; Type: CONSTRAINT; Schema: public; Owner: oms_user
--

ALTER TABLE ONLY public.customer_special_prices
    ADD CONSTRAINT customer_special_prices_pkey PRIMARY KEY (id);


--
-- Name: customers customers_pkey; Type: CONSTRAINT; Schema: public; Owner: oms_user
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_pkey PRIMARY KEY (id);


--
-- Name: order_items order_items_pkey; Type: CONSTRAINT; Schema: public; Owner: oms_user
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_pkey PRIMARY KEY (id);


--
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: public; Owner: oms_user
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (id);


--
-- Name: product_categories product_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: oms_user
--

ALTER TABLE ONLY public.product_categories
    ADD CONSTRAINT product_categories_pkey PRIMARY KEY (id);


--
-- Name: product_group_prices product_group_prices_pkey; Type: CONSTRAINT; Schema: public; Owner: oms_user
--

ALTER TABLE ONLY public.product_group_prices
    ADD CONSTRAINT product_group_prices_pkey PRIMARY KEY (id);


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: oms_user
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: oms_user
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: audit_logs audit_logs_pkey; Type: CONSTRAINT; Schema: shadow; Owner: oms_user
--

ALTER TABLE ONLY shadow.audit_logs
    ADD CONSTRAINT audit_logs_pkey PRIMARY KEY (id);


--
-- Name: cancel_reasons cancel_reasons_pkey; Type: CONSTRAINT; Schema: shadow; Owner: oms_user
--

ALTER TABLE ONLY shadow.cancel_reasons
    ADD CONSTRAINT cancel_reasons_pkey PRIMARY KEY (id);


--
-- Name: company_settings company_settings_pkey; Type: CONSTRAINT; Schema: shadow; Owner: oms_user
--

ALTER TABLE ONLY shadow.company_settings
    ADD CONSTRAINT company_settings_pkey PRIMARY KEY (id);


--
-- Name: customer_groups customer_groups_pkey; Type: CONSTRAINT; Schema: shadow; Owner: oms_user
--

ALTER TABLE ONLY shadow.customer_groups
    ADD CONSTRAINT customer_groups_pkey PRIMARY KEY (id);


--
-- Name: customer_special_prices customer_special_prices_pkey; Type: CONSTRAINT; Schema: shadow; Owner: oms_user
--

ALTER TABLE ONLY shadow.customer_special_prices
    ADD CONSTRAINT customer_special_prices_pkey PRIMARY KEY (id);


--
-- Name: customers customers_pkey; Type: CONSTRAINT; Schema: shadow; Owner: oms_user
--

ALTER TABLE ONLY shadow.customers
    ADD CONSTRAINT customers_pkey PRIMARY KEY (id);


--
-- Name: order_items order_items_pkey; Type: CONSTRAINT; Schema: shadow; Owner: oms_user
--

ALTER TABLE ONLY shadow.order_items
    ADD CONSTRAINT order_items_pkey PRIMARY KEY (id);


--
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: shadow; Owner: oms_user
--

ALTER TABLE ONLY shadow.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (id);


--
-- Name: product_group_prices product_group_prices_pkey; Type: CONSTRAINT; Schema: shadow; Owner: oms_user
--

ALTER TABLE ONLY shadow.product_group_prices
    ADD CONSTRAINT product_group_prices_pkey PRIMARY KEY (id);


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: shadow; Owner: oms_user
--

ALTER TABLE ONLY shadow.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: shadow; Owner: oms_user
--

ALTER TABLE ONLY shadow.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: audit_logs_createdAt_idx; Type: INDEX; Schema: public; Owner: oms_user
--

CREATE INDEX "audit_logs_createdAt_idx" ON public.audit_logs USING btree ("createdAt");


--
-- Name: audit_logs_entityType_entityId_idx; Type: INDEX; Schema: public; Owner: oms_user
--

CREATE INDEX "audit_logs_entityType_entityId_idx" ON public.audit_logs USING btree ("entityType", "entityId");


--
-- Name: audit_logs_userId_idx; Type: INDEX; Schema: public; Owner: oms_user
--

CREATE INDEX "audit_logs_userId_idx" ON public.audit_logs USING btree ("userId");


--
-- Name: cancel_reasons_label_key; Type: INDEX; Schema: public; Owner: oms_user
--

CREATE UNIQUE INDEX cancel_reasons_label_key ON public.cancel_reasons USING btree (label);


--
-- Name: customer_groups_name_key; Type: INDEX; Schema: public; Owner: oms_user
--

CREATE UNIQUE INDEX customer_groups_name_key ON public.customer_groups USING btree (name);


--
-- Name: customer_special_prices_customerId_productId_key; Type: INDEX; Schema: public; Owner: oms_user
--

CREATE UNIQUE INDEX "customer_special_prices_customerId_productId_key" ON public.customer_special_prices USING btree ("customerId", "productId");


--
-- Name: customers_code_key; Type: INDEX; Schema: public; Owner: oms_user
--

CREATE UNIQUE INDEX customers_code_key ON public.customers USING btree (code);


--
-- Name: customers_phone_key; Type: INDEX; Schema: public; Owner: oms_user
--

CREATE UNIQUE INDEX customers_phone_key ON public.customers USING btree (phone);


--
-- Name: orders_createdAt_idx; Type: INDEX; Schema: public; Owner: oms_user
--

CREATE INDEX "orders_createdAt_idx" ON public.orders USING btree ("createdAt");


--
-- Name: orders_customerId_idx; Type: INDEX; Schema: public; Owner: oms_user
--

CREATE INDEX "orders_customerId_idx" ON public.orders USING btree ("customerId");


--
-- Name: orders_deliveryStatus_idx; Type: INDEX; Schema: public; Owner: oms_user
--

CREATE INDEX "orders_deliveryStatus_idx" ON public.orders USING btree ("deliveryStatus");


--
-- Name: orders_orderNumber_key; Type: INDEX; Schema: public; Owner: oms_user
--

CREATE UNIQUE INDEX "orders_orderNumber_key" ON public.orders USING btree ("orderNumber");


--
-- Name: product_categories_code_key; Type: INDEX; Schema: public; Owner: oms_user
--

CREATE UNIQUE INDEX product_categories_code_key ON public.product_categories USING btree (code);


--
-- Name: product_categories_name_key; Type: INDEX; Schema: public; Owner: oms_user
--

CREATE UNIQUE INDEX product_categories_name_key ON public.product_categories USING btree (name);


--
-- Name: product_group_prices_productId_groupId_key; Type: INDEX; Schema: public; Owner: oms_user
--

CREATE UNIQUE INDEX "product_group_prices_productId_groupId_key" ON public.product_group_prices USING btree ("productId", "groupId");


--
-- Name: products_sku_key; Type: INDEX; Schema: public; Owner: oms_user
--

CREATE UNIQUE INDEX products_sku_key ON public.products USING btree (sku);


--
-- Name: users_email_key; Type: INDEX; Schema: public; Owner: oms_user
--

CREATE UNIQUE INDEX users_email_key ON public.users USING btree (email);


--
-- Name: audit_logs_createdAt_idx; Type: INDEX; Schema: shadow; Owner: oms_user
--

CREATE INDEX "audit_logs_createdAt_idx" ON shadow.audit_logs USING btree ("createdAt");


--
-- Name: audit_logs_entityType_entityId_idx; Type: INDEX; Schema: shadow; Owner: oms_user
--

CREATE INDEX "audit_logs_entityType_entityId_idx" ON shadow.audit_logs USING btree ("entityType", "entityId");


--
-- Name: audit_logs_userId_idx; Type: INDEX; Schema: shadow; Owner: oms_user
--

CREATE INDEX "audit_logs_userId_idx" ON shadow.audit_logs USING btree ("userId");


--
-- Name: cancel_reasons_label_key; Type: INDEX; Schema: shadow; Owner: oms_user
--

CREATE UNIQUE INDEX cancel_reasons_label_key ON shadow.cancel_reasons USING btree (label);


--
-- Name: customer_groups_name_key; Type: INDEX; Schema: shadow; Owner: oms_user
--

CREATE UNIQUE INDEX customer_groups_name_key ON shadow.customer_groups USING btree (name);


--
-- Name: customer_special_prices_customerId_productId_key; Type: INDEX; Schema: shadow; Owner: oms_user
--

CREATE UNIQUE INDEX "customer_special_prices_customerId_productId_key" ON shadow.customer_special_prices USING btree ("customerId", "productId");


--
-- Name: customers_phone_key; Type: INDEX; Schema: shadow; Owner: oms_user
--

CREATE UNIQUE INDEX customers_phone_key ON shadow.customers USING btree (phone);


--
-- Name: orders_createdAt_idx; Type: INDEX; Schema: shadow; Owner: oms_user
--

CREATE INDEX "orders_createdAt_idx" ON shadow.orders USING btree ("createdAt");


--
-- Name: orders_customerId_idx; Type: INDEX; Schema: shadow; Owner: oms_user
--

CREATE INDEX "orders_customerId_idx" ON shadow.orders USING btree ("customerId");


--
-- Name: orders_deliveryStatus_idx; Type: INDEX; Schema: shadow; Owner: oms_user
--

CREATE INDEX "orders_deliveryStatus_idx" ON shadow.orders USING btree ("deliveryStatus");


--
-- Name: orders_orderNumber_key; Type: INDEX; Schema: shadow; Owner: oms_user
--

CREATE UNIQUE INDEX "orders_orderNumber_key" ON shadow.orders USING btree ("orderNumber");


--
-- Name: product_group_prices_productId_groupId_key; Type: INDEX; Schema: shadow; Owner: oms_user
--

CREATE UNIQUE INDEX "product_group_prices_productId_groupId_key" ON shadow.product_group_prices USING btree ("productId", "groupId");


--
-- Name: products_sku_key; Type: INDEX; Schema: shadow; Owner: oms_user
--

CREATE UNIQUE INDEX products_sku_key ON shadow.products USING btree (sku);


--
-- Name: users_email_key; Type: INDEX; Schema: shadow; Owner: oms_user
--

CREATE UNIQUE INDEX users_email_key ON shadow.users USING btree (email);


--
-- Name: audit_logs audit_logs_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: oms_user
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT "audit_logs_userId_fkey" FOREIGN KEY ("userId") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: customer_special_prices customer_special_prices_customerId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: oms_user
--

ALTER TABLE ONLY public.customer_special_prices
    ADD CONSTRAINT "customer_special_prices_customerId_fkey" FOREIGN KEY ("customerId") REFERENCES public.customers(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: customer_special_prices customer_special_prices_productId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: oms_user
--

ALTER TABLE ONLY public.customer_special_prices
    ADD CONSTRAINT "customer_special_prices_productId_fkey" FOREIGN KEY ("productId") REFERENCES public.products(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: customers customers_groupId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: oms_user
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT "customers_groupId_fkey" FOREIGN KEY ("groupId") REFERENCES public.customer_groups(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: order_items order_items_orderId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: oms_user
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT "order_items_orderId_fkey" FOREIGN KEY ("orderId") REFERENCES public.orders(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: order_items order_items_productId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: oms_user
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT "order_items_productId_fkey" FOREIGN KEY ("productId") REFERENCES public.products(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: orders orders_cancelReasonId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: oms_user
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT "orders_cancelReasonId_fkey" FOREIGN KEY ("cancelReasonId") REFERENCES public.cancel_reasons(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: orders orders_createdById_fkey; Type: FK CONSTRAINT; Schema: public; Owner: oms_user
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT "orders_createdById_fkey" FOREIGN KEY ("createdById") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: orders orders_customerId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: oms_user
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT "orders_customerId_fkey" FOREIGN KEY ("customerId") REFERENCES public.customers(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: product_group_prices product_group_prices_groupId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: oms_user
--

ALTER TABLE ONLY public.product_group_prices
    ADD CONSTRAINT "product_group_prices_groupId_fkey" FOREIGN KEY ("groupId") REFERENCES public.customer_groups(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: product_group_prices product_group_prices_productId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: oms_user
--

ALTER TABLE ONLY public.product_group_prices
    ADD CONSTRAINT "product_group_prices_productId_fkey" FOREIGN KEY ("productId") REFERENCES public.products(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: products products_categoryId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: oms_user
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT "products_categoryId_fkey" FOREIGN KEY ("categoryId") REFERENCES public.product_categories(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: audit_logs audit_logs_userId_fkey; Type: FK CONSTRAINT; Schema: shadow; Owner: oms_user
--

ALTER TABLE ONLY shadow.audit_logs
    ADD CONSTRAINT "audit_logs_userId_fkey" FOREIGN KEY ("userId") REFERENCES shadow.users(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: customer_special_prices customer_special_prices_customerId_fkey; Type: FK CONSTRAINT; Schema: shadow; Owner: oms_user
--

ALTER TABLE ONLY shadow.customer_special_prices
    ADD CONSTRAINT "customer_special_prices_customerId_fkey" FOREIGN KEY ("customerId") REFERENCES shadow.customers(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: customer_special_prices customer_special_prices_productId_fkey; Type: FK CONSTRAINT; Schema: shadow; Owner: oms_user
--

ALTER TABLE ONLY shadow.customer_special_prices
    ADD CONSTRAINT "customer_special_prices_productId_fkey" FOREIGN KEY ("productId") REFERENCES shadow.products(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: customers customers_groupId_fkey; Type: FK CONSTRAINT; Schema: shadow; Owner: oms_user
--

ALTER TABLE ONLY shadow.customers
    ADD CONSTRAINT "customers_groupId_fkey" FOREIGN KEY ("groupId") REFERENCES shadow.customer_groups(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: order_items order_items_orderId_fkey; Type: FK CONSTRAINT; Schema: shadow; Owner: oms_user
--

ALTER TABLE ONLY shadow.order_items
    ADD CONSTRAINT "order_items_orderId_fkey" FOREIGN KEY ("orderId") REFERENCES shadow.orders(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: order_items order_items_productId_fkey; Type: FK CONSTRAINT; Schema: shadow; Owner: oms_user
--

ALTER TABLE ONLY shadow.order_items
    ADD CONSTRAINT "order_items_productId_fkey" FOREIGN KEY ("productId") REFERENCES shadow.products(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: orders orders_cancelReasonId_fkey; Type: FK CONSTRAINT; Schema: shadow; Owner: oms_user
--

ALTER TABLE ONLY shadow.orders
    ADD CONSTRAINT "orders_cancelReasonId_fkey" FOREIGN KEY ("cancelReasonId") REFERENCES shadow.cancel_reasons(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: orders orders_createdById_fkey; Type: FK CONSTRAINT; Schema: shadow; Owner: oms_user
--

ALTER TABLE ONLY shadow.orders
    ADD CONSTRAINT "orders_createdById_fkey" FOREIGN KEY ("createdById") REFERENCES shadow.users(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: orders orders_customerId_fkey; Type: FK CONSTRAINT; Schema: shadow; Owner: oms_user
--

ALTER TABLE ONLY shadow.orders
    ADD CONSTRAINT "orders_customerId_fkey" FOREIGN KEY ("customerId") REFERENCES shadow.customers(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: product_group_prices product_group_prices_groupId_fkey; Type: FK CONSTRAINT; Schema: shadow; Owner: oms_user
--

ALTER TABLE ONLY shadow.product_group_prices
    ADD CONSTRAINT "product_group_prices_groupId_fkey" FOREIGN KEY ("groupId") REFERENCES shadow.customer_groups(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: product_group_prices product_group_prices_productId_fkey; Type: FK CONSTRAINT; Schema: shadow; Owner: oms_user
--

ALTER TABLE ONLY shadow.product_group_prices
    ADD CONSTRAINT "product_group_prices_productId_fkey" FOREIGN KEY ("productId") REFERENCES shadow.products(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: oms_user
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;


--
-- PostgreSQL database dump complete
--

\unrestrict kc0mcub5i8OsoZTAKOMDeSG3MkgZbehVhNc2wVO6VVVdQ7TjqfYKBmaq9Xx1sFD

