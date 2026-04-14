--
-- PostgreSQL database dump
--

\restrict Tz4xpctnv5K5MVhsWzVxBLirLj3g92mGVstn9XsB5uOGKKUQPzViPI2O3gZEWS0

-- Dumped from database version 16.11
-- Dumped by pg_dump version 16.11

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
    "snapshotCustomerPhone" text NOT NULL,
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
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "refreshTokenHash" text
);


ALTER TABLE public.users OWNER TO oms_user;

--
-- Data for Name: _prisma_migrations; Type: TABLE DATA; Schema: public; Owner: oms_user
--

COPY public._prisma_migrations (id, checksum, finished_at, migration_name, logs, rolled_back_at, started_at, applied_steps_count) FROM stdin;
1669bbd2-e1a9-41de-847e-380b1a405f38	43c93a99f9fa58aa477150552b99c5858dd95e2d01af3100300ed0dc70329ff8	2026-04-14 05:37:27.808559+00	20260411103102_init_schema	\N	\N	2026-04-14 05:37:21.485831+00	1
1dbf2861-04af-4c16-9a90-6b9adedc3185	e7cc2394ac4f256637f55539d2273b2974318905876d07e8da450cdd0729e373	2026-04-14 05:37:29.14514+00	20260413051727_allow_float_quantity	\N	\N	2026-04-14 05:37:27.962114+00	1
ad2bf709-e8d2-4cf4-b403-aeb75992cb5c	3515e88acf8fce81a10184861f923b3f2095644ff7403882d372fd4054de091c	2026-04-14 05:38:14.236322+00	20260414053813_add_refresh_token_hash	\N	\N	2026-04-14 05:38:14.063393+00	1
\.


--
-- Data for Name: audit_logs; Type: TABLE DATA; Schema: public; Owner: oms_user
--

COPY public.audit_logs (id, "userId", "userEmail", action, "entityType", "entityId", "oldData", "newData", "ipAddress", "createdAt") FROM stdin;
cmny9j6fp0003vxowdrctvilx	cmny6xsu00000vxko299h9pug	poka@poka.us	CREATE	Customer	cmny9j6dt0001vxowgxpnasmn	null	{"id": "cmny9j6dt0001vxowgxpnasmn", "notes": null, "phone": "0911342879", "groupId": "cmny9fdcn000dvxy4w3gaald5", "fullName": "Poka", "isActive": true, "wardCode": "778", "wardName": "Quận 7", "createdAt": "2026-04-14T06:51:05.105Z", "updatedAt": "2026-04-14T06:51:05.105Z", "provinceCode": "79", "provinceName": "Thành phố Hồ Chí Minh", "addressDetail": "Eco Green Saigon"}	::1	2026-04-14 06:51:05.163
cmny9k89d000gvxowdxmgpllt	cmny6xsu00000vxko299h9pug	poka@poka.us	CREATE	Order	cmny9k86z0005vxow4wdoc23u	null	{"id": "cmny9k86z0005vxow4wdoc23u", "items": [{"id": "cmny9k8700007vxowyhvuump7", "orderId": "cmny9k86z0005vxow4wdoc23u", "quantity": 1, "lineTotal": "295000", "productId": "cmny9hiry04lovxy4u42lsq73", "priceSource": "RETAIL", "pricingNote": "Áp dụng giá bán lẻ", "lineDiscount": "0", "snapshotUnitPrice": "295000", "snapshotProductSku": "XUANLOC7", "snapshotProductName": "Sét nấu sữa hạt 15 gói", "snapshotProductUnit": "Set"}, {"id": "cmny9k8700008vxowpvjrsfmp", "orderId": "cmny9k86z0005vxow4wdoc23u", "quantity": 1, "lineTotal": "0", "productId": "cmny9hipg04ljvxy4ha2ju0vq", "priceSource": "RETAIL", "pricingNote": "Áp dụng giá bán lẻ", "lineDiscount": "0", "snapshotUnitPrice": "0", "snapshotProductSku": "XUANLOC8", "snapshotProductName": "Rau bắp khô (100gr).", "snapshotProductUnit": "Gói"}, {"id": "cmny9k8700009vxowo4trsvga", "orderId": "cmny9k86z0005vxow4wdoc23u", "quantity": 2, "lineTotal": "250000", "productId": "cmny9hizn04m3vxy4xt84mp84", "priceSource": "RETAIL", "pricingNote": "Áp dụng giá bán lẻ", "lineDiscount": "0", "snapshotUnitPrice": "125000", "snapshotProductSku": "XUANLOC4", "snapshotProductName": "Sét trà mát dưỡng huyết 7 gói (bo bo, xích tiểu đậu, rau bắp)", "snapshotProductUnit": "Set"}, {"id": "cmny9k870000avxowkca7olr9", "orderId": "cmny9k86z0005vxow4wdoc23u", "quantity": 1, "lineTotal": "54000", "productId": "cmny9hj1x04m8vxy4nm9axlnb", "priceSource": "RETAIL", "pricingNote": "Áp dụng giá bán lẻ", "lineDiscount": "0", "snapshotUnitPrice": "54000", "snapshotProductSku": "XUANLOC3", "snapshotProductName": "Sét trà gừng sả 7 gói", "snapshotProductUnit": "Gói"}, {"id": "cmny9k870000bvxowaedmsmex", "orderId": "cmny9k86z0005vxow4wdoc23u", "quantity": 1, "lineTotal": "0", "productId": "cmny9hjgf04mtvxy4wnmlhbzv", "priceSource": "RETAIL", "pricingNote": "Áp dụng giá bán lẻ", "lineDiscount": "0", "snapshotUnitPrice": "0", "snapshotProductSku": "HANGTUOI49", "snapshotProductName": "Cuốn họng", "snapshotProductUnit": "Kg"}, {"id": "cmny9k870000cvxowutov8ozg", "orderId": "cmny9k86z0005vxow4wdoc23u", "quantity": 1, "lineTotal": "202000", "productId": "cmny9hjhv04muvxy4zxm79hu3", "priceSource": "GROUP", "pricingNote": "Áp dụng bảng giá tĩnh nhóm: LOYAL", "lineDiscount": "0", "snapshotUnitPrice": "202000", "snapshotProductSku": "HANGTUOI48", "snapshotProductName": "Ba chỉ rút xương", "snapshotProductUnit": "Kg"}, {"id": "cmny9k870000dvxowceew20ih", "orderId": "cmny9k86z0005vxow4wdoc23u", "quantity": 1, "lineTotal": "202000", "productId": "cmny9hjla04mzvxy4sxy2t9ei", "priceSource": "GROUP", "pricingNote": "Áp dụng bảng giá tĩnh nhóm: LOYAL", "lineDiscount": "0", "snapshotUnitPrice": "202000", "snapshotProductSku": "HANGTUOI47", "snapshotProductName": "Cốt lết", "snapshotProductUnit": "Kg"}, {"id": "cmny9k870000evxowrbuhejet", "orderId": "cmny9k86z0005vxow4wdoc23u", "quantity": 1, "lineTotal": "202000", "productId": "cmny9hjp104n4vxy4b4rltjlf", "priceSource": "GROUP", "pricingNote": "Áp dụng bảng giá tĩnh nhóm: LOYAL", "lineDiscount": "0", "snapshotUnitPrice": "202000", "snapshotProductSku": "HANGTUOI46", "snapshotProductName": "Đùi", "snapshotProductUnit": "Kg"}], "notes": "", "customer": {"id": "cmny9j6dt0001vxowgxpnasmn", "notes": null, "phone": "0911342879", "groupId": "cmny9fdcn000dvxy4w3gaald5", "fullName": "Poka", "isActive": true, "wardCode": "778", "wardName": "Quận 7", "createdAt": "2026-04-14T06:51:05.105Z", "updatedAt": "2026-04-14T06:51:05.105Z", "provinceCode": "79", "provinceName": "Thành phố Hồ Chí Minh", "addressDetail": "Eco Green Saigon"}, "subtotal": "1205000", "createdAt": "2026-04-14T06:51:54.107Z", "updatedAt": "2026-04-14T06:51:54.107Z", "customerId": "cmny9j6dt0001vxowgxpnasmn", "cancelNotes": null, "createdById": "cmny6xsu00000vxko299h9pug", "orderNumber": "ORD-20260414-0001", "shippingFee": "20000", "totalAmount": "1225000", "cancelReasonId": null, "deliveryStatus": "PENDING", "discountAmount": "0", "snapshotCustomerName": "Poka", "snapshotCustomerPhone": "0911342879"}	::1	2026-04-14 06:51:54.193
\.


--
-- Data for Name: cancel_reasons; Type: TABLE DATA; Schema: public; Owner: oms_user
--

COPY public.cancel_reasons (id, label, "isActive", "sortOrder", "createdAt") FROM stdin;
cmny6xzh5006vvxkofzrfuncg	Sai số điện thoại	t	1	2026-04-14 05:38:37.146
cmny6xzjw006wvxkonmf18pyg	Khách đổi ý	t	2	2026-04-14 05:38:37.244
cmny6xzlj006xvxkoyaltllzb	Hết hàng	t	3	2026-04-14 05:38:37.303
cmny6xznd006yvxkoiudo2vqg	Lý do khác	t	99	2026-04-14 05:38:37.369
\.


--
-- Data for Name: company_settings; Type: TABLE DATA; Schema: public; Owner: oms_user
--

COPY public.company_settings (id, name, address, phone, email, "taxCode", "logoUrl", "bankInfo", "invoiceFooter", "updatedAt") FROM stdin;
cmny6xzpl006zvxkoqxaxxleh	Công ty TNHH Mountain Farmers	Thôn Kon Jri, Xã Đăk Rơ Wa, Tỉnh Quảng Ngãi	0906 454 379	\N	\N	\N	\N	Cảm ơn quý khách đã tin tưởng!	2026-04-14 05:50:55.984
\.


--
-- Data for Name: customer_groups; Type: TABLE DATA; Schema: public; Owner: oms_user
--

COPY public.customer_groups (id, name, description, "priceType", "discountPercent", "isDefault", "createdAt", "updatedAt") FROM stdin;
cmny9fd1n0000vxy4o9lqqe9y	Khách lẻ	Imported group from CRM	PERCENTAGE	0	t	2026-04-14 06:48:07.095	2026-04-14 06:48:07.095
cmny9fd420001vxy42djthn1o	Khách sỉ	Imported group from CRM	FIXED	0	f	2026-04-14 06:48:07.202	2026-04-14 06:48:07.202
cmny9fd4t0002vxy4jo0l7gop	KHOADL	Imported group from CRM	FIXED	0	f	2026-04-14 06:48:07.229	2026-04-14 06:48:07.229
cmny9fd5j0003vxy4sw5e14p1	VITA	Imported group from CRM	FIXED	0	f	2026-04-14 06:48:07.255	2026-04-14 06:48:07.255
cmny9fd6h0004vxy4evm3jgfv	VYQN	Imported group from CRM	FIXED	0	f	2026-04-14 06:48:07.289	2026-04-14 06:48:07.289
cmny9fd740005vxy44c2rf5rg	NAMAN	Imported group from CRM	FIXED	0	f	2026-04-14 06:48:07.312	2026-04-14 06:48:07.312
cmny9fd7u0006vxy4mh4wwui4	TRAMQ10	Imported group from CRM	FIXED	0	f	2026-04-14 06:48:07.338	2026-04-14 06:48:07.338
cmny9fd8i0007vxy4tmc0glr0	TUANTHUY	Imported group from CRM	FIXED	0	f	2026-04-14 06:48:07.362	2026-04-14 06:48:07.362
cmny9fd980008vxy4alsawn4y	HOA	Imported group from CRM	FIXED	0	f	2026-04-14 06:48:07.388	2026-04-14 06:48:07.388
cmny9fd9w0009vxy498vvvu1d	TUANH	Imported group from CRM	FIXED	0	f	2026-04-14 06:48:07.413	2026-04-14 06:48:07.413
cmny9fdam000avxy4a12zuxjj	ANHPR	Imported group from CRM	FIXED	0	f	2026-04-14 06:48:07.438	2026-04-14 06:48:07.438
cmny9fdb9000bvxy4h02fexen	GREENTECH	Imported group from CRM	FIXED	0	f	2026-04-14 06:48:07.462	2026-04-14 06:48:07.462
cmny9fdc1000cvxy4n4y9ezu8	P50	Imported group from CRM	FIXED	0	f	2026-04-14 06:48:07.489	2026-04-14 06:48:07.489
cmny9fdcn000dvxy4w3gaald5	LOYAL	Imported group from CRM	FIXED	0	f	2026-04-14 06:48:07.512	2026-04-14 06:48:07.512
\.


--
-- Data for Name: customer_special_prices; Type: TABLE DATA; Schema: public; Owner: oms_user
--

COPY public.customer_special_prices (id, "customerId", "productId", price, notes, "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: customers; Type: TABLE DATA; Schema: public; Owner: oms_user
--

COPY public.customers (id, phone, "fullName", "groupId", "provinceCode", "provinceName", "wardCode", "wardName", "addressDetail", notes, "isActive", "createdAt", "updatedAt") FROM stdin;
cmny9j6dt0001vxowgxpnasmn	0911342879	Poka	cmny9fdcn000dvxy4w3gaald5	79	Thành phố Hồ Chí Minh	778	Quận 7	Eco Green Saigon	\N	t	2026-04-14 06:51:05.105	2026-04-14 06:51:05.105
\.


--
-- Data for Name: order_items; Type: TABLE DATA; Schema: public; Owner: oms_user
--

COPY public.order_items (id, "orderId", "productId", "snapshotProductName", "snapshotProductSku", "snapshotProductUnit", "snapshotUnitPrice", "priceSource", "pricingNote", quantity, "lineDiscount", "lineTotal") FROM stdin;
cmny9k8700007vxowyhvuump7	cmny9k86z0005vxow4wdoc23u	cmny9hiry04lovxy4u42lsq73	Sét nấu sữa hạt 15 gói	XUANLOC7	Set	295000	RETAIL	Áp dụng giá bán lẻ	1	0	295000
cmny9k8700008vxowpvjrsfmp	cmny9k86z0005vxow4wdoc23u	cmny9hipg04ljvxy4ha2ju0vq	Rau bắp khô (100gr).	XUANLOC8	Gói	0	RETAIL	Áp dụng giá bán lẻ	1	0	0
cmny9k8700009vxowo4trsvga	cmny9k86z0005vxow4wdoc23u	cmny9hizn04m3vxy4xt84mp84	Sét trà mát dưỡng huyết 7 gói (bo bo, xích tiểu đậu, rau bắp)	XUANLOC4	Set	125000	RETAIL	Áp dụng giá bán lẻ	2	0	250000
cmny9k870000avxowkca7olr9	cmny9k86z0005vxow4wdoc23u	cmny9hj1x04m8vxy4nm9axlnb	Sét trà gừng sả 7 gói	XUANLOC3	Gói	54000	RETAIL	Áp dụng giá bán lẻ	1	0	54000
cmny9k870000bvxowaedmsmex	cmny9k86z0005vxow4wdoc23u	cmny9hjgf04mtvxy4wnmlhbzv	Cuốn họng	HANGTUOI49	Kg	0	RETAIL	Áp dụng giá bán lẻ	1	0	0
cmny9k870000cvxowutov8ozg	cmny9k86z0005vxow4wdoc23u	cmny9hjhv04muvxy4zxm79hu3	Ba chỉ rút xương	HANGTUOI48	Kg	202000	GROUP	Áp dụng bảng giá tĩnh nhóm: LOYAL	1	0	202000
cmny9k870000dvxowceew20ih	cmny9k86z0005vxow4wdoc23u	cmny9hjla04mzvxy4sxy2t9ei	Cốt lết	HANGTUOI47	Kg	202000	GROUP	Áp dụng bảng giá tĩnh nhóm: LOYAL	1	0	202000
cmny9k870000evxowrbuhejet	cmny9k86z0005vxow4wdoc23u	cmny9hjp104n4vxy4b4rltjlf	Đùi	HANGTUOI46	Kg	202000	GROUP	Áp dụng bảng giá tĩnh nhóm: LOYAL	1	0	202000
\.


--
-- Data for Name: orders; Type: TABLE DATA; Schema: public; Owner: oms_user
--

COPY public.orders (id, "orderNumber", "customerId", "snapshotCustomerName", "snapshotCustomerPhone", "createdById", "deliveryStatus", subtotal, "discountAmount", "shippingFee", "totalAmount", "cancelReasonId", "cancelNotes", notes, "createdAt", "updatedAt") FROM stdin;
cmny9k86z0005vxow4wdoc23u	ORD-20260414-0001	cmny9j6dt0001vxowgxpnasmn	Poka	0911342879	cmny6xsu00000vxko299h9pug	PENDING	1205000	0	20000	1225000	\N	\N		2026-04-14 06:51:54.107	2026-04-14 06:51:54.107
\.


--
-- Data for Name: product_group_prices; Type: TABLE DATA; Schema: public; Owner: oms_user
--

COPY public.product_group_prices (id, "productId", "groupId", "fixedPrice", "createdAt", "updatedAt") FROM stdin;
cmny9fdeb000gvxy461igjprd	cmny9fddf000evxy44pvff3ba	cmny9fd420001vxy42djthn1o	65000	2026-04-14 06:48:07.572	2026-04-14 06:48:07.572
cmny9fdfw000ivxy4kwizo5nz	cmny9fddf000evxy44pvff3ba	cmny9fd4t0002vxy4jo0l7gop	65000	2026-04-14 06:48:07.629	2026-04-14 06:48:07.629
cmny9fdhf000kvxy4mgzmk0pu	cmny9fddf000evxy44pvff3ba	cmny9fdc1000cvxy4n4y9ezu8	65000	2026-04-14 06:48:07.683	2026-04-14 06:48:07.683
cmny9fdiz000nvxy4eunrubj2	cmny9fdi9000lvxy4skepvuid	cmny9fd420001vxy42djthn1o	65000	2026-04-14 06:48:07.739	2026-04-14 06:48:07.739
cmny9fdjl000pvxy4kmyi0omb	cmny9fdi9000lvxy4skepvuid	cmny9fd4t0002vxy4jo0l7gop	65000	2026-04-14 06:48:07.762	2026-04-14 06:48:07.762
cmny9fdkc000rvxy435gm72fq	cmny9fdi9000lvxy4skepvuid	cmny9fd5j0003vxy4sw5e14p1	65000	2026-04-14 06:48:07.788	2026-04-14 06:48:07.788
cmny9fdkz000tvxy4zmxk6f6o	cmny9fdi9000lvxy4skepvuid	cmny9fd6h0004vxy4evm3jgfv	65000	2026-04-14 06:48:07.811	2026-04-14 06:48:07.811
cmny9fdlt000vvxy4ss4anhn6	cmny9fdi9000lvxy4skepvuid	cmny9fd7u0006vxy4mh4wwui4	65000	2026-04-14 06:48:07.842	2026-04-14 06:48:07.842
cmny9fdmo000xvxy4yvp548gn	cmny9fdi9000lvxy4skepvuid	cmny9fd8i0007vxy4tmc0glr0	65000	2026-04-14 06:48:07.872	2026-04-14 06:48:07.872
cmny9fdnb000zvxy4vkuvnkj4	cmny9fdi9000lvxy4skepvuid	cmny9fd980008vxy4alsawn4y	65000	2026-04-14 06:48:07.895	2026-04-14 06:48:07.895
cmny9fdo10011vxy49pxcmrd3	cmny9fdi9000lvxy4skepvuid	cmny9fd9w0009vxy498vvvu1d	65000	2026-04-14 06:48:07.922	2026-04-14 06:48:07.922
cmny9fdp70013vxy4fwc51k3b	cmny9fdi9000lvxy4skepvuid	cmny9fdb9000bvxy4h02fexen	65000	2026-04-14 06:48:07.964	2026-04-14 06:48:07.964
cmny9fdpw0015vxy4rpwlfnbf	cmny9fdi9000lvxy4skepvuid	cmny9fdc1000cvxy4n4y9ezu8	65000	2026-04-14 06:48:07.988	2026-04-14 06:48:07.988
cmny9fdqt0017vxy4g9jqadra	cmny9fdi9000lvxy4skepvuid	cmny9fdcn000dvxy4w3gaald5	65000	2026-04-14 06:48:08.022	2026-04-14 06:48:08.022
cmny9fds8001avxy4pvx1z7ao	cmny9fdrh0018vxy44l8dpxwa	cmny9fd420001vxy42djthn1o	185000	2026-04-14 06:48:08.073	2026-04-14 06:48:08.073
cmny9fdt6001cvxy4bfy0iqjv	cmny9fdrh0018vxy44l8dpxwa	cmny9fd4t0002vxy4jo0l7gop	185000	2026-04-14 06:48:08.106	2026-04-14 06:48:08.106
cmny9fduk001evxy448vezohf	cmny9fdrh0018vxy44l8dpxwa	cmny9fdc1000cvxy4n4y9ezu8	185000	2026-04-14 06:48:08.157	2026-04-14 06:48:08.157
cmny9fdvx001hvxy4pq1goe94	cmny9fdv7001fvxy40trtc7i8	cmny9fd420001vxy42djthn1o	38000	2026-04-14 06:48:08.206	2026-04-14 06:48:08.206
cmny9fdwk001jvxy4g5780b37	cmny9fdv7001fvxy40trtc7i8	cmny9fd4t0002vxy4jo0l7gop	38000	2026-04-14 06:48:08.228	2026-04-14 06:48:08.228
cmny9fdxc001lvxy418hjpzsg	cmny9fdv7001fvxy40trtc7i8	cmny9fd5j0003vxy4sw5e14p1	38000	2026-04-14 06:48:08.256	2026-04-14 06:48:08.256
cmny9fdy8001nvxy4twl03gs9	cmny9fdv7001fvxy40trtc7i8	cmny9fd6h0004vxy4evm3jgfv	38000	2026-04-14 06:48:08.288	2026-04-14 06:48:08.288
cmny9fdyz001pvxy4fysxfdmm	cmny9fdv7001fvxy40trtc7i8	cmny9fd7u0006vxy4mh4wwui4	38000	2026-04-14 06:48:08.315	2026-04-14 06:48:08.315
cmny9fdzu001rvxy4klft0tys	cmny9fdv7001fvxy40trtc7i8	cmny9fd980008vxy4alsawn4y	38000	2026-04-14 06:48:08.346	2026-04-14 06:48:08.346
cmny9fe0k001tvxy4o3qhaqtl	cmny9fdv7001fvxy40trtc7i8	cmny9fd9w0009vxy498vvvu1d	38000	2026-04-14 06:48:08.372	2026-04-14 06:48:08.372
cmny9fe1a001vvxy4033jfmqq	cmny9fdv7001fvxy40trtc7i8	cmny9fdc1000cvxy4n4y9ezu8	38000	2026-04-14 06:48:08.398	2026-04-14 06:48:08.398
cmny9fe25001xvxy43h7hhb63	cmny9fdv7001fvxy40trtc7i8	cmny9fdcn000dvxy4w3gaald5	38000	2026-04-14 06:48:08.429	2026-04-14 06:48:08.429
cmny9fe3s0020vxy4at99hsdo	cmny9fe2v001yvxy4ejpm9q2x	cmny9fd420001vxy42djthn1o	95000	2026-04-14 06:48:08.488	2026-04-14 06:48:08.488
cmny9fe4f0022vxy4hfrk5f24	cmny9fe2v001yvxy4ejpm9q2x	cmny9fd4t0002vxy4jo0l7gop	95000	2026-04-14 06:48:08.512	2026-04-14 06:48:08.512
cmny9fe570024vxy4m125vxk7	cmny9fe2v001yvxy4ejpm9q2x	cmny9fd5j0003vxy4sw5e14p1	95000	2026-04-14 06:48:08.539	2026-04-14 06:48:08.539
cmny9fe5t0026vxy4dp53unea	cmny9fe2v001yvxy4ejpm9q2x	cmny9fd6h0004vxy4evm3jgfv	95000	2026-04-14 06:48:08.562	2026-04-14 06:48:08.562
cmny9fe6n0028vxy4au0qvp5u	cmny9fe2v001yvxy4ejpm9q2x	cmny9fd7u0006vxy4mh4wwui4	95000	2026-04-14 06:48:08.591	2026-04-14 06:48:08.591
cmny9fe7h002avxy4eqxdzjo1	cmny9fe2v001yvxy4ejpm9q2x	cmny9fd8i0007vxy4tmc0glr0	90000	2026-04-14 06:48:08.621	2026-04-14 06:48:08.621
cmny9fe85002cvxy4sj7o13n5	cmny9fe2v001yvxy4ejpm9q2x	cmny9fd980008vxy4alsawn4y	95000	2026-04-14 06:48:08.646	2026-04-14 06:48:08.646
cmny9fe8w002evxy4t6aypnoj	cmny9fe2v001yvxy4ejpm9q2x	cmny9fd9w0009vxy498vvvu1d	90000	2026-04-14 06:48:08.672	2026-04-14 06:48:08.672
cmny9fe9j002gvxy4lmy6zytj	cmny9fe2v001yvxy4ejpm9q2x	cmny9fdam000avxy4a12zuxjj	90000	2026-04-14 06:48:08.696	2026-04-14 06:48:08.696
cmny9fea9002ivxy4z7mrkp0f	cmny9fe2v001yvxy4ejpm9q2x	cmny9fdb9000bvxy4h02fexen	95000	2026-04-14 06:48:08.721	2026-04-14 06:48:08.721
cmny9feax002kvxy4dcz7ykwl	cmny9fe2v001yvxy4ejpm9q2x	cmny9fdc1000cvxy4n4y9ezu8	95000	2026-04-14 06:48:08.745	2026-04-14 06:48:08.745
cmny9febo002mvxy4n19b1wdc	cmny9fe2v001yvxy4ejpm9q2x	cmny9fdcn000dvxy4w3gaald5	95000	2026-04-14 06:48:08.772	2026-04-14 06:48:08.772
cmny9fedi002pvxy4gsae6s7b	cmny9fecm002nvxy4e1rq33hi	cmny9fd420001vxy42djthn1o	40000	2026-04-14 06:48:08.838	2026-04-14 06:48:08.838
cmny9feeh002rvxy4tv5h6jli	cmny9fecm002nvxy4e1rq33hi	cmny9fd4t0002vxy4jo0l7gop	40000	2026-04-14 06:48:08.873	2026-04-14 06:48:08.873
cmny9fef3002tvxy42hxxmag7	cmny9fecm002nvxy4e1rq33hi	cmny9fd5j0003vxy4sw5e14p1	40000	2026-04-14 06:48:08.895	2026-04-14 06:48:08.895
cmny9fefu002vvxy4m1vgk0ar	cmny9fecm002nvxy4e1rq33hi	cmny9fd6h0004vxy4evm3jgfv	40000	2026-04-14 06:48:08.922	2026-04-14 06:48:08.922
cmny9fegi002xvxy4o3kma1h6	cmny9fecm002nvxy4e1rq33hi	cmny9fd7u0006vxy4mh4wwui4	40000	2026-04-14 06:48:08.946	2026-04-14 06:48:08.946
cmny9feh8002zvxy4gg3irdp8	cmny9fecm002nvxy4e1rq33hi	cmny9fd8i0007vxy4tmc0glr0	40000	2026-04-14 06:48:08.972	2026-04-14 06:48:08.972
cmny9fehv0031vxy4uawjagcr	cmny9fecm002nvxy4e1rq33hi	cmny9fd980008vxy4alsawn4y	40000	2026-04-14 06:48:08.995	2026-04-14 06:48:08.995
cmny9feim0033vxy43jj5r8zy	cmny9fecm002nvxy4e1rq33hi	cmny9fd9w0009vxy498vvvu1d	40000	2026-04-14 06:48:09.022	2026-04-14 06:48:09.022
cmny9fejj0035vxy4do42e4e0	cmny9fecm002nvxy4e1rq33hi	cmny9fdam000avxy4a12zuxjj	40000	2026-04-14 06:48:09.055	2026-04-14 06:48:09.055
cmny9fekg0037vxy4fmx95bxn	cmny9fecm002nvxy4e1rq33hi	cmny9fdb9000bvxy4h02fexen	43000	2026-04-14 06:48:09.088	2026-04-14 06:48:09.088
cmny9fel40039vxy449vc6013	cmny9fecm002nvxy4e1rq33hi	cmny9fdc1000cvxy4n4y9ezu8	40000	2026-04-14 06:48:09.112	2026-04-14 06:48:09.112
cmny9felv003bvxy4tpclxcua	cmny9fecm002nvxy4e1rq33hi	cmny9fdcn000dvxy4w3gaald5	40000	2026-04-14 06:48:09.14	2026-04-14 06:48:09.14
cmny9fen9003evxy42wj5bgjr	cmny9femh003cvxy4lp56haa9	cmny9fd420001vxy42djthn1o	352000	2026-04-14 06:48:09.189	2026-04-14 06:48:09.189
cmny9feo5003gvxy4pvuk9gt3	cmny9femh003cvxy4lp56haa9	cmny9fd4t0002vxy4jo0l7gop	352000	2026-04-14 06:48:09.221	2026-04-14 06:48:09.221
cmny9feow003ivxy4coeu1w73	cmny9femh003cvxy4lp56haa9	cmny9fd6h0004vxy4evm3jgfv	352000	2026-04-14 06:48:09.248	2026-04-14 06:48:09.248
cmny9feps003kvxy439tjz2x9	cmny9femh003cvxy4lp56haa9	cmny9fd7u0006vxy4mh4wwui4	352000	2026-04-14 06:48:09.281	2026-04-14 06:48:09.281
cmny9feqh003mvxy4o8x65e1z	cmny9femh003cvxy4lp56haa9	cmny9fd8i0007vxy4tmc0glr0	352000	2026-04-14 06:48:09.305	2026-04-14 06:48:09.305
cmny9fer5003ovxy4s6w4alt5	cmny9femh003cvxy4lp56haa9	cmny9fd980008vxy4alsawn4y	352000	2026-04-14 06:48:09.329	2026-04-14 06:48:09.329
cmny9ferv003qvxy4s0oo9rq8	cmny9femh003cvxy4lp56haa9	cmny9fd9w0009vxy498vvvu1d	352000	2026-04-14 06:48:09.355	2026-04-14 06:48:09.355
cmny9fesu003svxy40chrdt5m	cmny9femh003cvxy4lp56haa9	cmny9fdb9000bvxy4h02fexen	352000	2026-04-14 06:48:09.391	2026-04-14 06:48:09.391
cmny9fetq003uvxy4u2830is3	cmny9femh003cvxy4lp56haa9	cmny9fdc1000cvxy4n4y9ezu8	352000	2026-04-14 06:48:09.422	2026-04-14 06:48:09.422
cmny9feud003wvxy4xh77lsd0	cmny9femh003cvxy4lp56haa9	cmny9fdcn000dvxy4w3gaald5	352000	2026-04-14 06:48:09.445	2026-04-14 06:48:09.445
cmny9few1003zvxy4nenhidzj	cmny9fev6003xvxy4vztc1ynm	cmny9fd420001vxy42djthn1o	230000	2026-04-14 06:48:09.505	2026-04-14 06:48:09.505
cmny9fex00041vxy46ydg90eg	cmny9fev6003xvxy4vztc1ynm	cmny9fd4t0002vxy4jo0l7gop	230000	2026-04-14 06:48:09.54	2026-04-14 06:48:09.54
cmny9feyd0043vxy4ow4qs9y7	cmny9fev6003xvxy4vztc1ynm	cmny9fdc1000cvxy4n4y9ezu8	230000	2026-04-14 06:48:09.589	2026-04-14 06:48:09.589
cmny9fezq0046vxy4c5vc5u72	cmny9fez20044vxy4nzvtaykj	cmny9fd420001vxy42djthn1o	45000	2026-04-14 06:48:09.638	2026-04-14 06:48:09.638
cmny9ff0e0048vxy4erqdihty	cmny9fez20044vxy4nzvtaykj	cmny9fd4t0002vxy4jo0l7gop	45000	2026-04-14 06:48:09.662	2026-04-14 06:48:09.662
cmny9ff14004avxy4cpgiudbj	cmny9fez20044vxy4nzvtaykj	cmny9fd5j0003vxy4sw5e14p1	45000	2026-04-14 06:48:09.688	2026-04-14 06:48:09.688
cmny9ff1s004cvxy4251l1vc3	cmny9fez20044vxy4nzvtaykj	cmny9fd6h0004vxy4evm3jgfv	45000	2026-04-14 06:48:09.712	2026-04-14 06:48:09.712
cmny9ff2k004evxy4vzwlkq1v	cmny9fez20044vxy4nzvtaykj	cmny9fd7u0006vxy4mh4wwui4	45000	2026-04-14 06:48:09.741	2026-04-14 06:48:09.741
cmny9ff3g004gvxy4oheb92ua	cmny9fez20044vxy4nzvtaykj	cmny9fd8i0007vxy4tmc0glr0	45000	2026-04-14 06:48:09.772	2026-04-14 06:48:09.772
cmny9ff43004ivxy4u8033n54	cmny9fez20044vxy4nzvtaykj	cmny9fd980008vxy4alsawn4y	45000	2026-04-14 06:48:09.795	2026-04-14 06:48:09.795
cmny9ff4u004kvxy4l4i1r9cj	cmny9fez20044vxy4nzvtaykj	cmny9fd9w0009vxy498vvvu1d	45000	2026-04-14 06:48:09.822	2026-04-14 06:48:09.822
cmny9ff5i004mvxy4m9kl7v17	cmny9fez20044vxy4nzvtaykj	cmny9fdb9000bvxy4h02fexen	45000	2026-04-14 06:48:09.846	2026-04-14 06:48:09.846
cmny9ff68004ovxy4fnipkn5a	cmny9fez20044vxy4nzvtaykj	cmny9fdc1000cvxy4n4y9ezu8	45000	2026-04-14 06:48:09.873	2026-04-14 06:48:09.873
cmny9ff6u004qvxy47vixths9	cmny9fez20044vxy4nzvtaykj	cmny9fdcn000dvxy4w3gaald5	45000	2026-04-14 06:48:09.895	2026-04-14 06:48:09.895
cmny9ff8t004tvxy40m86rmzd	cmny9ff7m004rvxy4chtcq534	cmny9fdcn000dvxy4w3gaald5	170000	2026-04-14 06:48:09.966	2026-04-14 06:48:09.966
cmny9ffae004wvxy4l2bvx3ui	cmny9ff9o004uvxy4tpj33yho	cmny9fd420001vxy42djthn1o	45000	2026-04-14 06:48:10.022	2026-04-14 06:48:10.022
cmny9ffbb004yvxy4juaip3yh	cmny9ff9o004uvxy4tpj33yho	cmny9fd4t0002vxy4jo0l7gop	45000	2026-04-14 06:48:10.055	2026-04-14 06:48:10.055
cmny9ffc70050vxy4ti3cqv8c	cmny9ff9o004uvxy4tpj33yho	cmny9fd5j0003vxy4sw5e14p1	48000	2026-04-14 06:48:10.088	2026-04-14 06:48:10.088
cmny9ffcw0052vxy4rxfo9q78	cmny9ff9o004uvxy4tpj33yho	cmny9fd6h0004vxy4evm3jgfv	45000	2026-04-14 06:48:10.113	2026-04-14 06:48:10.113
cmny9ffdo0054vxy4hn1nj0kt	cmny9ff9o004uvxy4tpj33yho	cmny9fd7u0006vxy4mh4wwui4	37000	2026-04-14 06:48:10.141	2026-04-14 06:48:10.141
cmny9ffen0056vxy4xrf5swce	cmny9ff9o004uvxy4tpj33yho	cmny9fd980008vxy4alsawn4y	45000	2026-04-14 06:48:10.175	2026-04-14 06:48:10.175
cmny9fffg0058vxy42gudd72m	cmny9ff9o004uvxy4tpj33yho	cmny9fd9w0009vxy498vvvu1d	45000	2026-04-14 06:48:10.205	2026-04-14 06:48:10.205
cmny9ffg6005avxy47p4ximbn	cmny9ff9o004uvxy4tpj33yho	cmny9fdb9000bvxy4h02fexen	48000	2026-04-14 06:48:10.231	2026-04-14 06:48:10.231
cmny9ffgv005cvxy43lv5ttb4	cmny9ff9o004uvxy4tpj33yho	cmny9fdc1000cvxy4n4y9ezu8	45000	2026-04-14 06:48:10.256	2026-04-14 06:48:10.256
cmny9ffhk005evxy4fmss7qyt	cmny9ff9o004uvxy4tpj33yho	cmny9fdcn000dvxy4w3gaald5	45000	2026-04-14 06:48:10.28	2026-04-14 06:48:10.28
cmny9ffix005hvxy4mhus9cxp	cmny9ffi8005fvxy4ocwn8b83	cmny9fd420001vxy42djthn1o	43000	2026-04-14 06:48:10.329	2026-04-14 06:48:10.329
cmny9ffjm005jvxy4srpf85ls	cmny9ffi8005fvxy4ocwn8b83	cmny9fd4t0002vxy4jo0l7gop	43000	2026-04-14 06:48:10.355	2026-04-14 06:48:10.355
cmny9ffkb005lvxy4y2uzphva	cmny9ffi8005fvxy4ocwn8b83	cmny9fd5j0003vxy4sw5e14p1	43000	2026-04-14 06:48:10.379	2026-04-14 06:48:10.379
cmny9ffnj005nvxy4z4j6eoo2	cmny9ffi8005fvxy4ocwn8b83	cmny9fd6h0004vxy4evm3jgfv	43000	2026-04-14 06:48:10.495	2026-04-14 06:48:10.495
cmny9ffoc005pvxy4itssq2rk	cmny9ffi8005fvxy4ocwn8b83	cmny9fd7u0006vxy4mh4wwui4	43000	2026-04-14 06:48:10.524	2026-04-14 06:48:10.524
cmny9ffp7005rvxy4qmykc6vw	cmny9ffi8005fvxy4ocwn8b83	cmny9fd8i0007vxy4tmc0glr0	43000	2026-04-14 06:48:10.555	2026-04-14 06:48:10.555
cmny9ffpv005tvxy483l94loq	cmny9ffi8005fvxy4ocwn8b83	cmny9fd980008vxy4alsawn4y	43000	2026-04-14 06:48:10.579	2026-04-14 06:48:10.579
cmny9ffqm005vvxy4u7i4xo2n	cmny9ffi8005fvxy4ocwn8b83	cmny9fd9w0009vxy498vvvu1d	43000	2026-04-14 06:48:10.606	2026-04-14 06:48:10.606
cmny9ffra005xvxy4tbjl7dss	cmny9ffi8005fvxy4ocwn8b83	cmny9fdb9000bvxy4h02fexen	43000	2026-04-14 06:48:10.63	2026-04-14 06:48:10.63
cmny9ffs1005zvxy43vbt1oqq	cmny9ffi8005fvxy4ocwn8b83	cmny9fdc1000cvxy4n4y9ezu8	43000	2026-04-14 06:48:10.657	2026-04-14 06:48:10.657
cmny9ffsw0061vxy4lwwosekd	cmny9ffi8005fvxy4ocwn8b83	cmny9fdcn000dvxy4w3gaald5	43000	2026-04-14 06:48:10.688	2026-04-14 06:48:10.688
cmny9ffua0064vxy4rcrg42j5	cmny9fftj0062vxy4x0z7c6ow	cmny9fd420001vxy42djthn1o	99000	2026-04-14 06:48:10.738	2026-04-14 06:48:10.738
cmny9ffuy0066vxy49uxv381m	cmny9fftj0062vxy4x0z7c6ow	cmny9fd4t0002vxy4jo0l7gop	99000	2026-04-14 06:48:10.762	2026-04-14 06:48:10.762
cmny9ffwb0068vxy4bgfrvt04	cmny9fftj0062vxy4x0z7c6ow	cmny9fdc1000cvxy4n4y9ezu8	99000	2026-04-14 06:48:10.811	2026-04-14 06:48:10.811
cmny9ffzw006cvxy4aemc0jtk	cmny9ffyx006avxy43xdr680q	cmny9fd420001vxy42djthn1o	40000	2026-04-14 06:48:10.941	2026-04-14 06:48:10.941
cmny9fg0y006evxy4py91jqd7	cmny9ffyx006avxy43xdr680q	cmny9fd4t0002vxy4jo0l7gop	40000	2026-04-14 06:48:10.978	2026-04-14 06:48:10.978
cmny9fg1s006gvxy4x9dkg6jk	cmny9ffyx006avxy43xdr680q	cmny9fd5j0003vxy4sw5e14p1	40000	2026-04-14 06:48:11.008	2026-04-14 06:48:11.008
cmny9fg2m006ivxy4xyvcmgdd	cmny9ffyx006avxy43xdr680q	cmny9fd6h0004vxy4evm3jgfv	40000	2026-04-14 06:48:11.038	2026-04-14 06:48:11.038
cmny9fg3b006kvxy4k6fpz842	cmny9ffyx006avxy43xdr680q	cmny9fd740005vxy44c2rf5rg	40000	2026-04-14 06:48:11.063	2026-04-14 06:48:11.063
cmny9fg40006mvxy4epq0j8jf	cmny9ffyx006avxy43xdr680q	cmny9fd7u0006vxy4mh4wwui4	40000	2026-04-14 06:48:11.088	2026-04-14 06:48:11.088
cmny9fg4n006ovxy4jgebo86d	cmny9ffyx006avxy43xdr680q	cmny9fd8i0007vxy4tmc0glr0	40000	2026-04-14 06:48:11.112	2026-04-14 06:48:11.112
cmny9fg5e006qvxy4exlteck2	cmny9ffyx006avxy43xdr680q	cmny9fd980008vxy4alsawn4y	40000	2026-04-14 06:48:11.138	2026-04-14 06:48:11.138
cmny9fg61006svxy4glk9vdyp	cmny9ffyx006avxy43xdr680q	cmny9fd9w0009vxy498vvvu1d	40000	2026-04-14 06:48:11.162	2026-04-14 06:48:11.162
cmny9fg6v006uvxy4klnfknee	cmny9ffyx006avxy43xdr680q	cmny9fdam000avxy4a12zuxjj	40000	2026-04-14 06:48:11.191	2026-04-14 06:48:11.191
cmny9fg7s006wvxy4xo8fepiu	cmny9ffyx006avxy43xdr680q	cmny9fdb9000bvxy4h02fexen	43000	2026-04-14 06:48:11.224	2026-04-14 06:48:11.224
cmny9fg8r006yvxy41lz5hptm	cmny9ffyx006avxy43xdr680q	cmny9fdc1000cvxy4n4y9ezu8	40000	2026-04-14 06:48:11.259	2026-04-14 06:48:11.259
cmny9fg9l0070vxy43h854ibx	cmny9ffyx006avxy43xdr680q	cmny9fdcn000dvxy4w3gaald5	40000	2026-04-14 06:48:11.29	2026-04-14 06:48:11.29
cmny9fgaz0073vxy4e56svvos	cmny9fga70071vxy436v2ocov	cmny9fd420001vxy42djthn1o	6500	2026-04-14 06:48:11.339	2026-04-14 06:48:11.339
cmny9fgbl0075vxy44xlfve3m	cmny9fga70071vxy436v2ocov	cmny9fd4t0002vxy4jo0l7gop	6500	2026-04-14 06:48:11.362	2026-04-14 06:48:11.362
cmny9fgcv0077vxy4rg3dknkk	cmny9fga70071vxy436v2ocov	cmny9fdc1000cvxy4n4y9ezu8	6500	2026-04-14 06:48:11.407	2026-04-14 06:48:11.407
cmny9fge8007avxy43edl7dps	cmny9fgdh0078vxy4uud17wgi	cmny9fd420001vxy42djthn1o	400000	2026-04-14 06:48:11.456	2026-04-14 06:48:11.456
cmny9fgfb007cvxy4pn78hcxf	cmny9fgdh0078vxy4uud17wgi	cmny9fd4t0002vxy4jo0l7gop	400000	2026-04-14 06:48:11.495	2026-04-14 06:48:11.495
cmny9fggv007evxy4z1a2c7fo	cmny9fgdh0078vxy4uud17wgi	cmny9fdc1000cvxy4n4y9ezu8	400000	2026-04-14 06:48:11.551	2026-04-14 06:48:11.551
cmny9fgid007hvxy4oe7v6yix	cmny9fgho007fvxy43fsynb40	cmny9fd420001vxy42djthn1o	15000	2026-04-14 06:48:11.606	2026-04-14 06:48:11.606
cmny9fgj0007jvxy4ww766rvc	cmny9fgho007fvxy43fsynb40	cmny9fd4t0002vxy4jo0l7gop	15000	2026-04-14 06:48:11.628	2026-04-14 06:48:11.628
cmny9fgkf007lvxy4lu2dtfkq	cmny9fgho007fvxy43fsynb40	cmny9fdc1000cvxy4n4y9ezu8	15000	2026-04-14 06:48:11.679	2026-04-14 06:48:11.679
cmny9fgm3007ovxy48u8fncmp	cmny9fgl8007mvxy4wq7l7kaj	cmny9fd420001vxy42djthn1o	40000	2026-04-14 06:48:11.739	2026-04-14 06:48:11.739
cmny9fgn0007qvxy47u2ucbkv	cmny9fgl8007mvxy4wq7l7kaj	cmny9fd4t0002vxy4jo0l7gop	40000	2026-04-14 06:48:11.772	2026-04-14 06:48:11.772
cmny9fgny007svxy4pdijtbah	cmny9fgl8007mvxy4wq7l7kaj	cmny9fd5j0003vxy4sw5e14p1	40000	2026-04-14 06:48:11.806	2026-04-14 06:48:11.806
cmny9fgok007uvxy42qcrjk24	cmny9fgl8007mvxy4wq7l7kaj	cmny9fd6h0004vxy4evm3jgfv	40000	2026-04-14 06:48:11.828	2026-04-14 06:48:11.828
cmny9fgpc007wvxy45mkb1skv	cmny9fgl8007mvxy4wq7l7kaj	cmny9fd740005vxy44c2rf5rg	40000	2026-04-14 06:48:11.856	2026-04-14 06:48:11.856
cmny9fgqq007yvxy4zw10zway	cmny9fgl8007mvxy4wq7l7kaj	cmny9fd7u0006vxy4mh4wwui4	40000	2026-04-14 06:48:11.906	2026-04-14 06:48:11.906
cmny9fgrt0080vxy4murni6gm	cmny9fgl8007mvxy4wq7l7kaj	cmny9fd8i0007vxy4tmc0glr0	40000	2026-04-14 06:48:11.945	2026-04-14 06:48:11.945
cmny9fgsk0082vxy47kr2yf2i	cmny9fgl8007mvxy4wq7l7kaj	cmny9fd980008vxy4alsawn4y	40000	2026-04-14 06:48:11.972	2026-04-14 06:48:11.972
cmny9fgta0084vxy4xtq4d9wn	cmny9fgl8007mvxy4wq7l7kaj	cmny9fd9w0009vxy498vvvu1d	40000	2026-04-14 06:48:11.998	2026-04-14 06:48:11.998
cmny9fgu60086vxy4m4iuts2o	cmny9fgl8007mvxy4wq7l7kaj	cmny9fdam000avxy4a12zuxjj	40000	2026-04-14 06:48:12.03	2026-04-14 06:48:12.03
cmny9fgv20088vxy4rr91yc8s	cmny9fgl8007mvxy4wq7l7kaj	cmny9fdb9000bvxy4h02fexen	43000	2026-04-14 06:48:12.062	2026-04-14 06:48:12.062
cmny9fgvt008avxy4exsa5185	cmny9fgl8007mvxy4wq7l7kaj	cmny9fdc1000cvxy4n4y9ezu8	40000	2026-04-14 06:48:12.089	2026-04-14 06:48:12.089
cmny9fgx0008cvxy4avu9zvy7	cmny9fgl8007mvxy4wq7l7kaj	cmny9fdcn000dvxy4w3gaald5	40000	2026-04-14 06:48:12.132	2026-04-14 06:48:12.132
cmny9fh5i008jvxy4fsb65z0z	cmny9fh4r008hvxy4vsxsqweo	cmny9fd420001vxy42djthn1o	42000	2026-04-14 06:48:12.438	2026-04-14 06:48:12.438
cmny9fh7u008mvxy4kurqpamf	cmny9fh6y008kvxy4nh40uab1	cmny9fd420001vxy42djthn1o	33600	2026-04-14 06:48:12.522	2026-04-14 06:48:12.522
cmny9fh8i008ovxy4gzf1owen	cmny9fh6y008kvxy4nh40uab1	cmny9fd4t0002vxy4jo0l7gop	33600	2026-04-14 06:48:12.546	2026-04-14 06:48:12.546
cmny9fh9y008qvxy480lth285	cmny9fh6y008kvxy4nh40uab1	cmny9fd9w0009vxy498vvvu1d	33600	2026-04-14 06:48:12.599	2026-04-14 06:48:12.599
cmny9fhbd008svxy4f55i02ig	cmny9fh6y008kvxy4nh40uab1	cmny9fdc1000cvxy4n4y9ezu8	33600	2026-04-14 06:48:12.649	2026-04-14 06:48:12.649
cmny9fhcx008vvxy48kkjxl4p	cmny9fhc9008tvxy4obz60vr8	cmny9fd420001vxy42djthn1o	180000	2026-04-14 06:48:12.705	2026-04-14 06:48:12.705
cmny9fhdk008xvxy4egu77rfb	cmny9fhc9008tvxy4obz60vr8	cmny9fd4t0002vxy4jo0l7gop	180000	2026-04-14 06:48:12.729	2026-04-14 06:48:12.729
cmny9fheb008zvxy4ok63h9kl	cmny9fhc9008tvxy4obz60vr8	cmny9fd5j0003vxy4sw5e14p1	180000	2026-04-14 06:48:12.755	2026-04-14 06:48:12.755
cmny9fhez0091vxy47jykzae0	cmny9fhc9008tvxy4obz60vr8	cmny9fd6h0004vxy4evm3jgfv	180000	2026-04-14 06:48:12.779	2026-04-14 06:48:12.779
cmny9fhft0093vxy4wn1gy5h7	cmny9fhc9008tvxy4obz60vr8	cmny9fd7u0006vxy4mh4wwui4	180000	2026-04-14 06:48:12.809	2026-04-14 06:48:12.809
cmny9fhgn0095vxy494mffx50	cmny9fhc9008tvxy4obz60vr8	cmny9fd8i0007vxy4tmc0glr0	180000	2026-04-14 06:48:12.839	2026-04-14 06:48:12.839
cmny9fhhk0097vxy4hlezu4kj	cmny9fhc9008tvxy4obz60vr8	cmny9fd980008vxy4alsawn4y	180000	2026-04-14 06:48:12.872	2026-04-14 06:48:12.872
cmny9fhii0099vxy4019kqbn3	cmny9fhc9008tvxy4obz60vr8	cmny9fd9w0009vxy498vvvu1d	180000	2026-04-14 06:48:12.906	2026-04-14 06:48:12.906
cmny9fhj7009bvxy4zpzs4hg3	cmny9fhc9008tvxy4obz60vr8	cmny9fdb9000bvxy4h02fexen	180000	2026-04-14 06:48:12.932	2026-04-14 06:48:12.932
cmny9fhjx009dvxy41a0vi1bo	cmny9fhc9008tvxy4obz60vr8	cmny9fdc1000cvxy4n4y9ezu8	180000	2026-04-14 06:48:12.957	2026-04-14 06:48:12.957
cmny9fhlh009fvxy4vyj17bt7	cmny9fhc9008tvxy4obz60vr8	cmny9fdcn000dvxy4w3gaald5	180000	2026-04-14 06:48:13.013	2026-04-14 06:48:13.013
cmny9fhpp009ivxy4j8va3u50	cmny9fhos009gvxy4302vlxg7	cmny9fd420001vxy42djthn1o	160000	2026-04-14 06:48:13.164	2026-04-14 06:48:13.164
cmny9fhrb009kvxy4f6pmkf2q	cmny9fhos009gvxy4302vlxg7	cmny9fd4t0002vxy4jo0l7gop	160000	2026-04-14 06:48:13.223	2026-04-14 06:48:13.223
cmny9fhsv009mvxy48ft5xgmh	cmny9fhos009gvxy4302vlxg7	cmny9fd5j0003vxy4sw5e14p1	160000	2026-04-14 06:48:13.279	2026-04-14 06:48:13.279
cmny9fhts009ovxy4b3esg7fa	cmny9fhos009gvxy4302vlxg7	cmny9fd6h0004vxy4evm3jgfv	160000	2026-04-14 06:48:13.312	2026-04-14 06:48:13.312
cmny9fhvi009qvxy42kk89ddq	cmny9fhos009gvxy4302vlxg7	cmny9fd7u0006vxy4mh4wwui4	160000	2026-04-14 06:48:13.374	2026-04-14 06:48:13.374
cmny9fhwk009svxy4ouc9ac6b	cmny9fhos009gvxy4302vlxg7	cmny9fd8i0007vxy4tmc0glr0	160000	2026-04-14 06:48:13.412	2026-04-14 06:48:13.412
cmny9fhy7009uvxy4c240z16g	cmny9fhos009gvxy4302vlxg7	cmny9fd980008vxy4alsawn4y	160000	2026-04-14 06:48:13.472	2026-04-14 06:48:13.472
cmny9fhzc009wvxy4puttfb9j	cmny9fhos009gvxy4302vlxg7	cmny9fd9w0009vxy498vvvu1d	160000	2026-04-14 06:48:13.512	2026-04-14 06:48:13.512
cmny9fi2k009yvxy4zljai5q6	cmny9fhos009gvxy4302vlxg7	cmny9fdb9000bvxy4h02fexen	160000	2026-04-14 06:48:13.628	2026-04-14 06:48:13.628
cmny9fi4b00a0vxy4dvjj8d0f	cmny9fhos009gvxy4302vlxg7	cmny9fdc1000cvxy4n4y9ezu8	160000	2026-04-14 06:48:13.691	2026-04-14 06:48:13.691
cmny9fi6a00a2vxy4leovda1c	cmny9fhos009gvxy4302vlxg7	cmny9fdcn000dvxy4w3gaald5	160000	2026-04-14 06:48:13.762	2026-04-14 06:48:13.762
cmny9fihv00aavxy458dlzrhq	cmny9fih700a8vxy4mqrn6qik	cmny9fd420001vxy42djthn1o	8000	2026-04-14 06:48:14.18	2026-04-14 06:48:14.18
cmny9fiim00acvxy4uf5ew57l	cmny9fih700a8vxy4mqrn6qik	cmny9fd4t0002vxy4jo0l7gop	8000	2026-04-14 06:48:14.206	2026-04-14 06:48:14.206
cmny9fik700aevxy48s7loeup	cmny9fih700a8vxy4mqrn6qik	cmny9fdc1000cvxy4n4y9ezu8	8000	2026-04-14 06:48:14.263	2026-04-14 06:48:14.263
cmny9filw00ahvxy44f2r5lxd	cmny9fikz00afvxy492t8y5j1	cmny9fd420001vxy42djthn1o	12000	2026-04-14 06:48:14.324	2026-04-14 06:48:14.324
cmny9fipa00ajvxy4epaoszd7	cmny9fikz00afvxy492t8y5j1	cmny9fd4t0002vxy4jo0l7gop	12000	2026-04-14 06:48:14.447	2026-04-14 06:48:14.447
cmny9fiqz00alvxy4rws832d7	cmny9fikz00afvxy492t8y5j1	cmny9fdc1000cvxy4n4y9ezu8	12000	2026-04-14 06:48:14.507	2026-04-14 06:48:14.507
cmny9fist00aovxy4llqeitiq	cmny9firw00amvxy4vb8kj5rf	cmny9fd420001vxy42djthn1o	49000	2026-04-14 06:48:14.573	2026-04-14 06:48:14.573
cmny9fitp00aqvxy4h3d1hp28	cmny9firw00amvxy4vb8kj5rf	cmny9fd4t0002vxy4jo0l7gop	49000	2026-04-14 06:48:14.605	2026-04-14 06:48:14.605
cmny9fiuy00asvxy440aeh6yj	cmny9firw00amvxy4vb8kj5rf	cmny9fd9w0009vxy498vvvu1d	49000	2026-04-14 06:48:14.65	2026-04-14 06:48:14.65
cmny9fivv00auvxy4sq1ksjgm	cmny9firw00amvxy4vb8kj5rf	cmny9fdc1000cvxy4n4y9ezu8	49000	2026-04-14 06:48:14.683	2026-04-14 06:48:14.683
cmny9fixe00axvxy409ke3d07	cmny9fiwq00avvxy44ai6bmnf	cmny9fd420001vxy42djthn1o	37000	2026-04-14 06:48:14.738	2026-04-14 06:48:14.738
cmny9fiy200azvxy4k6thmt85	cmny9fiwq00avvxy44ai6bmnf	cmny9fd4t0002vxy4jo0l7gop	37000	2026-04-14 06:48:14.762	2026-04-14 06:48:14.762
cmny9fizg00b1vxy4yke6mpya	cmny9fiwq00avvxy44ai6bmnf	cmny9fdc1000cvxy4n4y9ezu8	37000	2026-04-14 06:48:14.812	2026-04-14 06:48:14.812
cmny9fj1500b4vxy42znot2jp	cmny9fj0900b2vxy4vo2okk4u	cmny9fd420001vxy42djthn1o	15000	2026-04-14 06:48:14.873	2026-04-14 06:48:14.873
cmny9fj1r00b6vxy4o9o041qg	cmny9fj0900b2vxy4vo2okk4u	cmny9fd4t0002vxy4jo0l7gop	15000	2026-04-14 06:48:14.895	2026-04-14 06:48:14.895
cmny9fj3500b8vxy4cpl5gw51	cmny9fj0900b2vxy4vo2okk4u	cmny9fdc1000cvxy4n4y9ezu8	15000	2026-04-14 06:48:14.945	2026-04-14 06:48:14.945
cmny9fj4t00bbvxy4il3yguvb	cmny9fj3y00b9vxy4e1s4pay0	cmny9fd420001vxy42djthn1o	40000	2026-04-14 06:48:15.005	2026-04-14 06:48:15.005
cmny9fj5r00bdvxy4gra7fzba	cmny9fj3y00b9vxy4e1s4pay0	cmny9fd4t0002vxy4jo0l7gop	40000	2026-04-14 06:48:15.039	2026-04-14 06:48:15.039
cmny9fj6e00bfvxy4tc3eanrr	cmny9fj3y00b9vxy4e1s4pay0	cmny9fd5j0003vxy4sw5e14p1	40000	2026-04-14 06:48:15.062	2026-04-14 06:48:15.062
cmny9fj7500bhvxy4hnr10094	cmny9fj3y00b9vxy4e1s4pay0	cmny9fd6h0004vxy4evm3jgfv	40000	2026-04-14 06:48:15.089	2026-04-14 06:48:15.089
cmny9fj7v00bjvxy4vhwoanjs	cmny9fj3y00b9vxy4e1s4pay0	cmny9fd7u0006vxy4mh4wwui4	40000	2026-04-14 06:48:15.115	2026-04-14 06:48:15.115
cmny9fj8j00blvxy4dvbj8viy	cmny9fj3y00b9vxy4e1s4pay0	cmny9fd8i0007vxy4tmc0glr0	40000	2026-04-14 06:48:15.139	2026-04-14 06:48:15.139
cmny9fj9g00bnvxy47uio1rjf	cmny9fj3y00b9vxy4e1s4pay0	cmny9fd980008vxy4alsawn4y	40000	2026-04-14 06:48:15.172	2026-04-14 06:48:15.172
cmny9fjad00bpvxy4q43coobh	cmny9fj3y00b9vxy4e1s4pay0	cmny9fd9w0009vxy498vvvu1d	40000	2026-04-14 06:48:15.205	2026-04-14 06:48:15.205
cmny9fjb200brvxy4bm57omfr	cmny9fj3y00b9vxy4e1s4pay0	cmny9fdb9000bvxy4h02fexen	40000	2026-04-14 06:48:15.23	2026-04-14 06:48:15.23
cmny9fjbr00btvxy4808xqdif	cmny9fj3y00b9vxy4e1s4pay0	cmny9fdc1000cvxy4n4y9ezu8	40000	2026-04-14 06:48:15.255	2026-04-14 06:48:15.255
cmny9fjce00bvvxy40daal6os	cmny9fj3y00b9vxy4e1s4pay0	cmny9fdcn000dvxy4w3gaald5	40000	2026-04-14 06:48:15.279	2026-04-14 06:48:15.279
cmny9fjdt00byvxy4r16swnmr	cmny9fjd500bwvxy4a8qdnhwi	cmny9fd420001vxy42djthn1o	38000	2026-04-14 06:48:15.329	2026-04-14 06:48:15.329
cmny9fjez00c0vxy4pd9peshj	cmny9fjd500bwvxy4a8qdnhwi	cmny9fd4t0002vxy4jo0l7gop	38000	2026-04-14 06:48:15.372	2026-04-14 06:48:15.372
cmny9fjfn00c2vxy40d87d85o	cmny9fjd500bwvxy4a8qdnhwi	cmny9fd5j0003vxy4sw5e14p1	38000	2026-04-14 06:48:15.395	2026-04-14 06:48:15.395
cmny9fjge00c4vxy4ypnsffqo	cmny9fjd500bwvxy4a8qdnhwi	cmny9fd6h0004vxy4evm3jgfv	38000	2026-04-14 06:48:15.422	2026-04-14 06:48:15.422
cmny9fjh300c6vxy4kwvj7fqi	cmny9fjd500bwvxy4a8qdnhwi	cmny9fd7u0006vxy4mh4wwui4	38000	2026-04-14 06:48:15.447	2026-04-14 06:48:15.447
cmny9fjhs00c8vxy45lv29yly	cmny9fjd500bwvxy4a8qdnhwi	cmny9fd8i0007vxy4tmc0glr0	38000	2026-04-14 06:48:15.472	2026-04-14 06:48:15.472
cmny9fjig00cavxy44f2nj4wx	cmny9fjd500bwvxy4a8qdnhwi	cmny9fd980008vxy4alsawn4y	38000	2026-04-14 06:48:15.496	2026-04-14 06:48:15.496
cmny9fjj600ccvxy4xlq12k0h	cmny9fjd500bwvxy4a8qdnhwi	cmny9fd9w0009vxy498vvvu1d	38000	2026-04-14 06:48:15.522	2026-04-14 06:48:15.522
cmny9fjjv00cevxy4wzi2556d	cmny9fjd500bwvxy4a8qdnhwi	cmny9fdb9000bvxy4h02fexen	38000	2026-04-14 06:48:15.548	2026-04-14 06:48:15.548
cmny9fjkr00cgvxy4jzycd1au	cmny9fjd500bwvxy4a8qdnhwi	cmny9fdc1000cvxy4n4y9ezu8	38000	2026-04-14 06:48:15.579	2026-04-14 06:48:15.579
cmny9fjlh00civxy4ch7g3tb3	cmny9fjd500bwvxy4a8qdnhwi	cmny9fdcn000dvxy4w3gaald5	38000	2026-04-14 06:48:15.605	2026-04-14 06:48:15.605
cmny9fjmv00clvxy4bo4a9rnk	cmny9fjm500cjvxy4cur210b6	cmny9fd420001vxy42djthn1o	32000	2026-04-14 06:48:15.655	2026-04-14 06:48:15.655
cmny9fjnj00cnvxy4obcnit5c	cmny9fjm500cjvxy4cur210b6	cmny9fd4t0002vxy4jo0l7gop	32000	2026-04-14 06:48:15.68	2026-04-14 06:48:15.68
cmny9fjo900cpvxy4tnmqgr30	cmny9fjm500cjvxy4cur210b6	cmny9fd5j0003vxy4sw5e14p1	32000	2026-04-14 06:48:15.705	2026-04-14 06:48:15.705
cmny9fjox00crvxy4od69sopg	cmny9fjm500cjvxy4cur210b6	cmny9fd6h0004vxy4evm3jgfv	32000	2026-04-14 06:48:15.729	2026-04-14 06:48:15.729
cmny9fjpr00ctvxy4nmvn5496	cmny9fjm500cjvxy4cur210b6	cmny9fd7u0006vxy4mh4wwui4	32000	2026-04-14 06:48:15.759	2026-04-14 06:48:15.759
cmny9fjqk00cvvxy4d0h8ke7i	cmny9fjm500cjvxy4cur210b6	cmny9fd8i0007vxy4tmc0glr0	32000	2026-04-14 06:48:15.788	2026-04-14 06:48:15.788
cmny9fjr800cxvxy4jmwpfhfa	cmny9fjm500cjvxy4cur210b6	cmny9fd980008vxy4alsawn4y	32000	2026-04-14 06:48:15.813	2026-04-14 06:48:15.813
cmny9fjrz00czvxy4xkmver1e	cmny9fjm500cjvxy4cur210b6	cmny9fd9w0009vxy498vvvu1d	32000	2026-04-14 06:48:15.839	2026-04-14 06:48:15.839
cmny9fjso00d1vxy45greudx1	cmny9fjm500cjvxy4cur210b6	cmny9fdb9000bvxy4h02fexen	32000	2026-04-14 06:48:15.864	2026-04-14 06:48:15.864
cmny9fjtc00d3vxy43angx69j	cmny9fjm500cjvxy4cur210b6	cmny9fdc1000cvxy4n4y9ezu8	32000	2026-04-14 06:48:15.889	2026-04-14 06:48:15.889
cmny9fju000d5vxy4iaqjmkd5	cmny9fjm500cjvxy4cur210b6	cmny9fdcn000dvxy4w3gaald5	32000	2026-04-14 06:48:15.912	2026-04-14 06:48:15.912
cmny9fjve00d8vxy442j28abu	cmny9fjur00d6vxy4gs774u96	cmny9fd420001vxy42djthn1o	13000	2026-04-14 06:48:15.963	2026-04-14 06:48:15.963
cmny9fjx900davxy4w0f6o9ia	cmny9fjur00d6vxy4gs774u96	cmny9fd4t0002vxy4jo0l7gop	13000	2026-04-14 06:48:16.029	2026-04-14 06:48:16.029
cmny9fjyn00dcvxy4d0fvoj1j	cmny9fjur00d6vxy4gs774u96	cmny9fd5j0003vxy4sw5e14p1	13000	2026-04-14 06:48:16.079	2026-04-14 06:48:16.079
cmny9fjzu00devxy4b5xwiof4	cmny9fjur00d6vxy4gs774u96	cmny9fd6h0004vxy4evm3jgfv	13000	2026-04-14 06:48:16.122	2026-04-14 06:48:16.122
cmny9fk0u00dgvxy4psmtwjqk	cmny9fjur00d6vxy4gs774u96	cmny9fd7u0006vxy4mh4wwui4	13000	2026-04-14 06:48:16.158	2026-04-14 06:48:16.158
cmny9fk3300divxy41gwbtj4t	cmny9fjur00d6vxy4gs774u96	cmny9fd8i0007vxy4tmc0glr0	13000	2026-04-14 06:48:16.239	2026-04-14 06:48:16.239
cmny9fk5d00dkvxy4vc84ents	cmny9fjur00d6vxy4gs774u96	cmny9fd980008vxy4alsawn4y	13000	2026-04-14 06:48:16.321	2026-04-14 06:48:16.321
cmny9fk6i00dmvxy43vsfq2gm	cmny9fjur00d6vxy4gs774u96	cmny9fd9w0009vxy498vvvu1d	13000	2026-04-14 06:48:16.362	2026-04-14 06:48:16.362
cmny9fk8f00dovxy433sn88b6	cmny9fjur00d6vxy4gs774u96	cmny9fdb9000bvxy4h02fexen	13000	2026-04-14 06:48:16.431	2026-04-14 06:48:16.431
cmny9fk9r00dqvxy4vbx16go5	cmny9fjur00d6vxy4gs774u96	cmny9fdc1000cvxy4n4y9ezu8	13000	2026-04-14 06:48:16.479	2026-04-14 06:48:16.479
cmny9fkay00dsvxy45lw59aa8	cmny9fjur00d6vxy4gs774u96	cmny9fdcn000dvxy4w3gaald5	13000	2026-04-14 06:48:16.522	2026-04-14 06:48:16.522
cmny9fkcc00dvvxy4gro2x9c7	cmny9fkbm00dtvxy4tsu13wey	cmny9fd420001vxy42djthn1o	155000	2026-04-14 06:48:16.572	2026-04-14 06:48:16.572
cmny9fkd000dxvxy4ca882dsk	cmny9fkbm00dtvxy4tsu13wey	cmny9fd4t0002vxy4jo0l7gop	155000	2026-04-14 06:48:16.596	2026-04-14 06:48:16.596
cmny9fkdq00dzvxy4c4vyv9tp	cmny9fkbm00dtvxy4tsu13wey	cmny9fd5j0003vxy4sw5e14p1	155000	2026-04-14 06:48:16.622	2026-04-14 06:48:16.622
cmny9fked00e1vxy4ni90i4k7	cmny9fkbm00dtvxy4tsu13wey	cmny9fd6h0004vxy4evm3jgfv	155000	2026-04-14 06:48:16.646	2026-04-14 06:48:16.646
cmny9fkf500e3vxy483fcoils	cmny9fkbm00dtvxy4tsu13wey	cmny9fd7u0006vxy4mh4wwui4	155000	2026-04-14 06:48:16.674	2026-04-14 06:48:16.674
cmny9fkg200e5vxy4j6xfrpxn	cmny9fkbm00dtvxy4tsu13wey	cmny9fd8i0007vxy4tmc0glr0	155000	2026-04-14 06:48:16.706	2026-04-14 06:48:16.706
cmny9fkgy00e7vxy429uxa84h	cmny9fkbm00dtvxy4tsu13wey	cmny9fd980008vxy4alsawn4y	155000	2026-04-14 06:48:16.739	2026-04-14 06:48:16.739
cmny9fkhn00e9vxy40y53gxuj	cmny9fkbm00dtvxy4tsu13wey	cmny9fd9w0009vxy498vvvu1d	155000	2026-04-14 06:48:16.763	2026-04-14 06:48:16.763
cmny9fkie00ebvxy4wd7g1wfs	cmny9fkbm00dtvxy4tsu13wey	cmny9fdb9000bvxy4h02fexen	155000	2026-04-14 06:48:16.791	2026-04-14 06:48:16.791
cmny9fkja00edvxy4hlc7iw4m	cmny9fkbm00dtvxy4tsu13wey	cmny9fdc1000cvxy4n4y9ezu8	155000	2026-04-14 06:48:16.822	2026-04-14 06:48:16.822
cmny9fkjx00efvxy4mm248l7l	cmny9fkbm00dtvxy4tsu13wey	cmny9fdcn000dvxy4w3gaald5	155000	2026-04-14 06:48:16.845	2026-04-14 06:48:16.845
cmny9fkll00eivxy47bucm4mn	cmny9fkko00egvxy4wlit9vfp	cmny9fd420001vxy42djthn1o	195000	2026-04-14 06:48:16.905	2026-04-14 06:48:16.905
cmny9fkm900ekvxy4v76tgnjt	cmny9fkko00egvxy4wlit9vfp	cmny9fd4t0002vxy4jo0l7gop	195000	2026-04-14 06:48:16.929	2026-04-14 06:48:16.929
cmny9fkmz00emvxy45xxg6ktr	cmny9fkko00egvxy4wlit9vfp	cmny9fd5j0003vxy4sw5e14p1	195000	2026-04-14 06:48:16.956	2026-04-14 06:48:16.956
cmny9fknn00eovxy45wgb8hvm	cmny9fkko00egvxy4wlit9vfp	cmny9fd6h0004vxy4evm3jgfv	195000	2026-04-14 06:48:16.98	2026-04-14 06:48:16.98
cmny9fkog00eqvxy41igvc984	cmny9fkko00egvxy4wlit9vfp	cmny9fd7u0006vxy4mh4wwui4	195000	2026-04-14 06:48:17.008	2026-04-14 06:48:17.008
cmny9fkpb00esvxy4ragov4c3	cmny9fkko00egvxy4wlit9vfp	cmny9fd8i0007vxy4tmc0glr0	195000	2026-04-14 06:48:17.039	2026-04-14 06:48:17.039
cmny9fkpy00euvxy401xw3gaw	cmny9fkko00egvxy4wlit9vfp	cmny9fd980008vxy4alsawn4y	195000	2026-04-14 06:48:17.062	2026-04-14 06:48:17.062
cmny9fkqp00ewvxy4hy4zfyjd	cmny9fkko00egvxy4wlit9vfp	cmny9fd9w0009vxy498vvvu1d	195000	2026-04-14 06:48:17.089	2026-04-14 06:48:17.089
cmny9fkre00eyvxy4kv35am6p	cmny9fkko00egvxy4wlit9vfp	cmny9fdb9000bvxy4h02fexen	195000	2026-04-14 06:48:17.114	2026-04-14 06:48:17.114
cmny9fks200f0vxy4i6w52h2k	cmny9fkko00egvxy4wlit9vfp	cmny9fdc1000cvxy4n4y9ezu8	195000	2026-04-14 06:48:17.138	2026-04-14 06:48:17.138
cmny9fksr00f2vxy4q22dqahn	cmny9fkko00egvxy4wlit9vfp	cmny9fdcn000dvxy4w3gaald5	195000	2026-04-14 06:48:17.163	2026-04-14 06:48:17.163
cmny9fku500f5vxy4x8c9x38j	cmny9fkth00f3vxy465j55cz9	cmny9fd420001vxy42djthn1o	58000	2026-04-14 06:48:17.213	2026-04-14 06:48:17.213
cmny9fkuv00f7vxy4tlfknux9	cmny9fkth00f3vxy465j55cz9	cmny9fd4t0002vxy4jo0l7gop	58000	2026-04-14 06:48:17.239	2026-04-14 06:48:17.239
cmny9fkvz00f9vxy4u6z68bxo	cmny9fkth00f3vxy465j55cz9	cmny9fd5j0003vxy4sw5e14p1	58000	2026-04-14 06:48:17.279	2026-04-14 06:48:17.279
cmny9fkwq00fbvxy4ohyzfmk0	cmny9fkth00f3vxy465j55cz9	cmny9fd6h0004vxy4evm3jgfv	58000	2026-04-14 06:48:17.306	2026-04-14 06:48:17.306
cmny9fkxf00fdvxy4mwdezb1m	cmny9fkth00f3vxy465j55cz9	cmny9fd7u0006vxy4mh4wwui4	58000	2026-04-14 06:48:17.332	2026-04-14 06:48:17.332
cmny9fky400ffvxy4mmwqt4qs	cmny9fkth00f3vxy465j55cz9	cmny9fd8i0007vxy4tmc0glr0	58000	2026-04-14 06:48:17.356	2026-04-14 06:48:17.356
cmny9fkyt00fhvxy4tj8y9ycm	cmny9fkth00f3vxy465j55cz9	cmny9fd980008vxy4alsawn4y	58000	2026-04-14 06:48:17.381	2026-04-14 06:48:17.381
cmny9fkzh00fjvxy4x862pxrx	cmny9fkth00f3vxy465j55cz9	cmny9fd9w0009vxy498vvvu1d	58000	2026-04-14 06:48:17.405	2026-04-14 06:48:17.405
cmny9fl0800flvxy4n5dkbwyv	cmny9fkth00f3vxy465j55cz9	cmny9fdb9000bvxy4h02fexen	58000	2026-04-14 06:48:17.433	2026-04-14 06:48:17.433
cmny9fl1200fnvxy4vqqk8wz7	cmny9fkth00f3vxy465j55cz9	cmny9fdc1000cvxy4n4y9ezu8	58000	2026-04-14 06:48:17.462	2026-04-14 06:48:17.462
cmny9fl1z00fpvxy4abbf5gmh	cmny9fkth00f3vxy465j55cz9	cmny9fdcn000dvxy4w3gaald5	58000	2026-04-14 06:48:17.495	2026-04-14 06:48:17.495
cmny9fl3d00fsvxy4qv5o4gyt	cmny9fl2q00fqvxy4z999yy33	cmny9fd420001vxy42djthn1o	19000	2026-04-14 06:48:17.545	2026-04-14 06:48:17.545
cmny9fl4400fuvxy4innvt7ft	cmny9fl2q00fqvxy4z999yy33	cmny9fd4t0002vxy4jo0l7gop	19000	2026-04-14 06:48:17.572	2026-04-14 06:48:17.572
cmny9fl4r00fwvxy4y16692ny	cmny9fl2q00fqvxy4z999yy33	cmny9fd5j0003vxy4sw5e14p1	19000	2026-04-14 06:48:17.596	2026-04-14 06:48:17.596
cmny9fl5j00fyvxy4zgai3k12	cmny9fl2q00fqvxy4z999yy33	cmny9fd6h0004vxy4evm3jgfv	19000	2026-04-14 06:48:17.623	2026-04-14 06:48:17.623
cmny9fl6h00g0vxy4noabbro9	cmny9fl2q00fqvxy4z999yy33	cmny9fd7u0006vxy4mh4wwui4	19000	2026-04-14 06:48:17.657	2026-04-14 06:48:17.657
cmny9fl7c00g2vxy45wt8nxwl	cmny9fl2q00fqvxy4z999yy33	cmny9fd8i0007vxy4tmc0glr0	19000	2026-04-14 06:48:17.689	2026-04-14 06:48:17.689
cmny9fl8900g4vxy4bkgnufwh	cmny9fl2q00fqvxy4z999yy33	cmny9fd980008vxy4alsawn4y	19000	2026-04-14 06:48:17.721	2026-04-14 06:48:17.721
cmny9fl8x00g6vxy4xkt4v8lr	cmny9fl2q00fqvxy4z999yy33	cmny9fd9w0009vxy498vvvu1d	19000	2026-04-14 06:48:17.745	2026-04-14 06:48:17.745
cmny9fl9o00g8vxy43aexjula	cmny9fl2q00fqvxy4z999yy33	cmny9fdb9000bvxy4h02fexen	19000	2026-04-14 06:48:17.773	2026-04-14 06:48:17.773
cmny9flab00gavxy49fd5enur	cmny9fl2q00fqvxy4z999yy33	cmny9fdc1000cvxy4n4y9ezu8	19000	2026-04-14 06:48:17.796	2026-04-14 06:48:17.796
cmny9flb100gcvxy4g5nswtui	cmny9fl2q00fqvxy4z999yy33	cmny9fdcn000dvxy4w3gaald5	19000	2026-04-14 06:48:17.821	2026-04-14 06:48:17.821
cmny9flcf00gfvxy4cmp17xpg	cmny9flbs00gdvxy4pz29chrk	cmny9fd420001vxy42djthn1o	27000	2026-04-14 06:48:17.871	2026-04-14 06:48:17.871
cmny9fld400ghvxy4hpqzcsu7	cmny9flbs00gdvxy4pz29chrk	cmny9fd4t0002vxy4jo0l7gop	27000	2026-04-14 06:48:17.896	2026-04-14 06:48:17.896
cmny9flea00gjvxy4y5vzddp8	cmny9flbs00gdvxy4pz29chrk	cmny9fd5j0003vxy4sw5e14p1	27000	2026-04-14 06:48:17.938	2026-04-14 06:48:17.938
cmny9fley00glvxy41i93k3t2	cmny9flbs00gdvxy4pz29chrk	cmny9fd6h0004vxy4evm3jgfv	27000	2026-04-14 06:48:17.962	2026-04-14 06:48:17.962
cmny9flfq00gnvxy4d9j6ar28	cmny9flbs00gdvxy4pz29chrk	cmny9fd7u0006vxy4mh4wwui4	27000	2026-04-14 06:48:17.991	2026-04-14 06:48:17.991
cmny9flgm00gpvxy4ovgq8lkw	cmny9flbs00gdvxy4pz29chrk	cmny9fd8i0007vxy4tmc0glr0	27000	2026-04-14 06:48:18.022	2026-04-14 06:48:18.022
cmny9flh800grvxy4vphmoaqf	cmny9flbs00gdvxy4pz29chrk	cmny9fd980008vxy4alsawn4y	27000	2026-04-14 06:48:18.045	2026-04-14 06:48:18.045
cmny9flhz00gtvxy4sugf7b77	cmny9flbs00gdvxy4pz29chrk	cmny9fd9w0009vxy498vvvu1d	27000	2026-04-14 06:48:18.072	2026-04-14 06:48:18.072
cmny9flip00gvvxy47z9j1wxl	cmny9flbs00gdvxy4pz29chrk	cmny9fdb9000bvxy4h02fexen	27000	2026-04-14 06:48:18.097	2026-04-14 06:48:18.097
cmny9flju00gxvxy481rm8ba1	cmny9flbs00gdvxy4pz29chrk	cmny9fdc1000cvxy4n4y9ezu8	27000	2026-04-14 06:48:18.138	2026-04-14 06:48:18.138
cmny9flki00gzvxy4ncwif2wi	cmny9flbs00gdvxy4pz29chrk	cmny9fdcn000dvxy4w3gaald5	27000	2026-04-14 06:48:18.162	2026-04-14 06:48:18.162
cmny9fllw00h2vxy49jc1yz6o	cmny9fll900h0vxy4bu3t48hg	cmny9fd420001vxy42djthn1o	69000	2026-04-14 06:48:18.213	2026-04-14 06:48:18.213
cmny9flmm00h4vxy4p68ghd8r	cmny9fll900h0vxy4bu3t48hg	cmny9fd4t0002vxy4jo0l7gop	69000	2026-04-14 06:48:18.238	2026-04-14 06:48:18.238
cmny9flna00h6vxy46sub56hp	cmny9fll900h0vxy4bu3t48hg	cmny9fd5j0003vxy4sw5e14p1	69000	2026-04-14 06:48:18.262	2026-04-14 06:48:18.262
cmny9flo100h8vxy4kyfod7ia	cmny9fll900h0vxy4bu3t48hg	cmny9fd6h0004vxy4evm3jgfv	69000	2026-04-14 06:48:18.289	2026-04-14 06:48:18.289
cmny9flot00havxy4fbuhksc2	cmny9fll900h0vxy4bu3t48hg	cmny9fd7u0006vxy4mh4wwui4	69000	2026-04-14 06:48:18.317	2026-04-14 06:48:18.317
cmny9flpl00hcvxy4uuxwv2wb	cmny9fll900h0vxy4bu3t48hg	cmny9fd8i0007vxy4tmc0glr0	69000	2026-04-14 06:48:18.345	2026-04-14 06:48:18.345
cmny9flqc00hevxy4igpo2oi6	cmny9fll900h0vxy4bu3t48hg	cmny9fd980008vxy4alsawn4y	69000	2026-04-14 06:48:18.372	2026-04-14 06:48:18.372
cmny9flqz00hgvxy4fbeoygfe	cmny9fll900h0vxy4bu3t48hg	cmny9fd9w0009vxy498vvvu1d	69000	2026-04-14 06:48:18.395	2026-04-14 06:48:18.395
cmny9flrr00hivxy4sqrtkdap	cmny9fll900h0vxy4bu3t48hg	cmny9fdb9000bvxy4h02fexen	69000	2026-04-14 06:48:18.424	2026-04-14 06:48:18.424
cmny9flsd00hkvxy43mhugoex	cmny9fll900h0vxy4bu3t48hg	cmny9fdc1000cvxy4n4y9ezu8	69000	2026-04-14 06:48:18.445	2026-04-14 06:48:18.445
cmny9flt400hmvxy41uvytikl	cmny9fll900h0vxy4bu3t48hg	cmny9fdcn000dvxy4w3gaald5	69000	2026-04-14 06:48:18.472	2026-04-14 06:48:18.472
cmny9flui00hpvxy4gx6c8sc7	cmny9fltr00hnvxy42du9zfn4	cmny9fd420001vxy42djthn1o	71000	2026-04-14 06:48:18.522	2026-04-14 06:48:18.522
cmny9flv700hrvxy4t5vfb6qt	cmny9fltr00hnvxy42du9zfn4	cmny9fd4t0002vxy4jo0l7gop	71000	2026-04-14 06:48:18.547	2026-04-14 06:48:18.547
cmny9flvx00htvxy42tvqpw2k	cmny9fltr00hnvxy42du9zfn4	cmny9fd5j0003vxy4sw5e14p1	71000	2026-04-14 06:48:18.573	2026-04-14 06:48:18.573
cmny9flwt00hvvxy4d7qlbdhr	cmny9fltr00hnvxy42du9zfn4	cmny9fd6h0004vxy4evm3jgfv	71000	2026-04-14 06:48:18.605	2026-04-14 06:48:18.605
cmny9flxs00hxvxy4dp0n6b72	cmny9fltr00hnvxy42du9zfn4	cmny9fd7u0006vxy4mh4wwui4	71000	2026-04-14 06:48:18.641	2026-04-14 06:48:18.641
cmny9flyo00hzvxy47cuj2b8t	cmny9fltr00hnvxy42du9zfn4	cmny9fd8i0007vxy4tmc0glr0	71000	2026-04-14 06:48:18.672	2026-04-14 06:48:18.672
cmny9flzl00i1vxy4xz7rgg6x	cmny9fltr00hnvxy42du9zfn4	cmny9fd980008vxy4alsawn4y	71000	2026-04-14 06:48:18.705	2026-04-14 06:48:18.705
cmny9fm0900i3vxy4me3axxal	cmny9fltr00hnvxy42du9zfn4	cmny9fd9w0009vxy498vvvu1d	71000	2026-04-14 06:48:18.729	2026-04-14 06:48:18.729
cmny9fm1200i5vxy4i6uuxax6	cmny9fltr00hnvxy42du9zfn4	cmny9fdb9000bvxy4h02fexen	71000	2026-04-14 06:48:18.759	2026-04-14 06:48:18.759
cmny9fm1y00i7vxy4j58r8q25	cmny9fltr00hnvxy42du9zfn4	cmny9fdc1000cvxy4n4y9ezu8	71000	2026-04-14 06:48:18.79	2026-04-14 06:48:18.79
cmny9fm2t00i9vxy4u8wqqi32	cmny9fltr00hnvxy42du9zfn4	cmny9fdcn000dvxy4w3gaald5	71000	2026-04-14 06:48:18.821	2026-04-14 06:48:18.821
cmny9fm4800icvxy4ni6yb3km	cmny9fm3h00iavxy462ufev27	cmny9fd420001vxy42djthn1o	129000	2026-04-14 06:48:18.872	2026-04-14 06:48:18.872
cmny9fm4w00ievxy4x8xjkks5	cmny9fm3h00iavxy462ufev27	cmny9fd4t0002vxy4jo0l7gop	129000	2026-04-14 06:48:18.896	2026-04-14 06:48:18.896
cmny9fm5m00igvxy4jcbw65q4	cmny9fm3h00iavxy462ufev27	cmny9fd5j0003vxy4sw5e14p1	129000	2026-04-14 06:48:18.922	2026-04-14 06:48:18.922
cmny9fm6900iivxy4709p2ssl	cmny9fm3h00iavxy462ufev27	cmny9fd6h0004vxy4evm3jgfv	129000	2026-04-14 06:48:18.945	2026-04-14 06:48:18.945
cmny9fm6z00ikvxy4rgbjfur9	cmny9fm3h00iavxy462ufev27	cmny9fd740005vxy44c2rf5rg	134000	2026-04-14 06:48:18.971	2026-04-14 06:48:18.971
cmny9fm7n00imvxy4vz82zh37	cmny9fm3h00iavxy462ufev27	cmny9fd7u0006vxy4mh4wwui4	129000	2026-04-14 06:48:18.995	2026-04-14 06:48:18.995
cmny9fm8f00iovxy47sz4h0k2	cmny9fm3h00iavxy462ufev27	cmny9fd8i0007vxy4tmc0glr0	122000	2026-04-14 06:48:19.023	2026-04-14 06:48:19.023
cmny9fm9100iqvxy45r071d4r	cmny9fm3h00iavxy462ufev27	cmny9fd980008vxy4alsawn4y	129000	2026-04-14 06:48:19.045	2026-04-14 06:48:19.045
cmny9fm9s00isvxy48aewfin0	cmny9fm3h00iavxy462ufev27	cmny9fd9w0009vxy498vvvu1d	129000	2026-04-14 06:48:19.073	2026-04-14 06:48:19.073
cmny9fmas00iuvxy4mt2f27o0	cmny9fm3h00iavxy462ufev27	cmny9fdb9000bvxy4h02fexen	129000	2026-04-14 06:48:19.108	2026-04-14 06:48:19.108
cmny9fmbn00iwvxy4vvxopszh	cmny9fm3h00iavxy462ufev27	cmny9fdc1000cvxy4n4y9ezu8	129000	2026-04-14 06:48:19.14	2026-04-14 06:48:19.14
cmny9fmct00iyvxy4hkf1y1xk	cmny9fm3h00iavxy462ufev27	cmny9fdcn000dvxy4w3gaald5	129000	2026-04-14 06:48:19.181	2026-04-14 06:48:19.181
cmny9fmef00j1vxy4mrdp8qa3	cmny9fmdo00izvxy4zcfb0ran	cmny9fd420001vxy42djthn1o	50000	2026-04-14 06:48:19.239	2026-04-14 06:48:19.239
cmny9fmfc00j3vxy4fwy7w0qx	cmny9fmdo00izvxy4zcfb0ran	cmny9fd4t0002vxy4jo0l7gop	50000	2026-04-14 06:48:19.273	2026-04-14 06:48:19.273
cmny9fmfz00j5vxy4ywyx6uy7	cmny9fmdo00izvxy4zcfb0ran	cmny9fd5j0003vxy4sw5e14p1	50000	2026-04-14 06:48:19.296	2026-04-14 06:48:19.296
cmny9fmgq00j7vxy42kapo06u	cmny9fmdo00izvxy4zcfb0ran	cmny9fd6h0004vxy4evm3jgfv	50000	2026-04-14 06:48:19.322	2026-04-14 06:48:19.322
cmny9fmhf00j9vxy4p6xdxqv8	cmny9fmdo00izvxy4zcfb0ran	cmny9fd7u0006vxy4mh4wwui4	50000	2026-04-14 06:48:19.347	2026-04-14 06:48:19.347
cmny9fmi400jbvxy4mx05o6vz	cmny9fmdo00izvxy4zcfb0ran	cmny9fd8i0007vxy4tmc0glr0	50000	2026-04-14 06:48:19.372	2026-04-14 06:48:19.372
cmny9fmir00jdvxy4ag6myr9x	cmny9fmdo00izvxy4zcfb0ran	cmny9fd980008vxy4alsawn4y	50000	2026-04-14 06:48:19.395	2026-04-14 06:48:19.395
cmny9fmji00jfvxy4j3cthekc	cmny9fmdo00izvxy4zcfb0ran	cmny9fd9w0009vxy498vvvu1d	50000	2026-04-14 06:48:19.422	2026-04-14 06:48:19.422
cmny9fmk700jhvxy4kz0m490m	cmny9fmdo00izvxy4zcfb0ran	cmny9fdb9000bvxy4h02fexen	50000	2026-04-14 06:48:19.447	2026-04-14 06:48:19.447
cmny9fmkw00jjvxy4f3zmicss	cmny9fmdo00izvxy4zcfb0ran	cmny9fdc1000cvxy4n4y9ezu8	50000	2026-04-14 06:48:19.472	2026-04-14 06:48:19.472
cmny9fmlj00jlvxy49w7mzs2z	cmny9fmdo00izvxy4zcfb0ran	cmny9fdcn000dvxy4w3gaald5	50000	2026-04-14 06:48:19.495	2026-04-14 06:48:19.495
cmny9fmmy00jovxy4p1kzt5vr	cmny9fmmb00jmvxy46k590w4g	cmny9fd420001vxy42djthn1o	63000	2026-04-14 06:48:19.546	2026-04-14 06:48:19.546
cmny9fmno00jqvxy42dstia9b	cmny9fmmb00jmvxy46k590w4g	cmny9fd4t0002vxy4jo0l7gop	63000	2026-04-14 06:48:19.572	2026-04-14 06:48:19.572
cmny9fmoc00jsvxy4re3nqzko	cmny9fmmb00jmvxy46k590w4g	cmny9fd5j0003vxy4sw5e14p1	63000	2026-04-14 06:48:19.596	2026-04-14 06:48:19.596
cmny9fmp200juvxy4clnkz5g7	cmny9fmmb00jmvxy46k590w4g	cmny9fd6h0004vxy4evm3jgfv	63000	2026-04-14 06:48:19.622	2026-04-14 06:48:19.622
cmny9fmpr00jwvxy4qwha0xg0	cmny9fmmb00jmvxy46k590w4g	cmny9fd7u0006vxy4mh4wwui4	63000	2026-04-14 06:48:19.647	2026-04-14 06:48:19.647
cmny9fmqh00jyvxy4zgrc78hv	cmny9fmmb00jmvxy46k590w4g	cmny9fd8i0007vxy4tmc0glr0	63000	2026-04-14 06:48:19.673	2026-04-14 06:48:19.673
cmny9fmrf00k0vxy4i05a6rfe	cmny9fmmb00jmvxy46k590w4g	cmny9fd980008vxy4alsawn4y	63000	2026-04-14 06:48:19.707	2026-04-14 06:48:19.707
cmny9fmsb00k2vxy45otnk89q	cmny9fmmb00jmvxy46k590w4g	cmny9fd9w0009vxy498vvvu1d	63000	2026-04-14 06:48:19.739	2026-04-14 06:48:19.739
cmny9fmtb00k4vxy4go9ck8n7	cmny9fmmb00jmvxy46k590w4g	cmny9fdb9000bvxy4h02fexen	63000	2026-04-14 06:48:19.775	2026-04-14 06:48:19.775
cmny9fmu600k6vxy4lj3fk39s	cmny9fmmb00jmvxy46k590w4g	cmny9fdc1000cvxy4n4y9ezu8	63000	2026-04-14 06:48:19.806	2026-04-14 06:48:19.806
cmny9fmut00k8vxy4fv9suane	cmny9fmmb00jmvxy46k590w4g	cmny9fdcn000dvxy4w3gaald5	63000	2026-04-14 06:48:19.829	2026-04-14 06:48:19.829
cmny9fmw900kbvxy4h2j4m8ck	cmny9fmvk00k9vxy4cbw4r8qh	cmny9fd420001vxy42djthn1o	40000	2026-04-14 06:48:19.881	2026-04-14 06:48:19.881
cmny9fmx500kdvxy4xlsmoqyv	cmny9fmvk00k9vxy4cbw4r8qh	cmny9fd4t0002vxy4jo0l7gop	40000	2026-04-14 06:48:19.913	2026-04-14 06:48:19.913
cmny9fmxw00kfvxy4nk7zj5yy	cmny9fmvk00k9vxy4cbw4r8qh	cmny9fd5j0003vxy4sw5e14p1	40000	2026-04-14 06:48:19.94	2026-04-14 06:48:19.94
cmny9fmys00khvxy4t4t42kv4	cmny9fmvk00k9vxy4cbw4r8qh	cmny9fd6h0004vxy4evm3jgfv	40000	2026-04-14 06:48:19.972	2026-04-14 06:48:19.972
cmny9fmzs00kjvxy43y143q1u	cmny9fmvk00k9vxy4cbw4r8qh	cmny9fd7u0006vxy4mh4wwui4	40000	2026-04-14 06:48:20.009	2026-04-14 06:48:20.009
cmny9fn0n00klvxy4da755zol	cmny9fmvk00k9vxy4cbw4r8qh	cmny9fd8i0007vxy4tmc0glr0	40000	2026-04-14 06:48:20.039	2026-04-14 06:48:20.039
cmny9fn1a00knvxy4r6ysr8y7	cmny9fmvk00k9vxy4cbw4r8qh	cmny9fd980008vxy4alsawn4y	40000	2026-04-14 06:48:20.062	2026-04-14 06:48:20.062
cmny9fn2000kpvxy4b614z4g2	cmny9fmvk00k9vxy4cbw4r8qh	cmny9fd9w0009vxy498vvvu1d	40000	2026-04-14 06:48:20.089	2026-04-14 06:48:20.089
cmny9fn2s00krvxy4nycqhryg	cmny9fmvk00k9vxy4cbw4r8qh	cmny9fdb9000bvxy4h02fexen	40000	2026-04-14 06:48:20.116	2026-04-14 06:48:20.116
cmny9fn3m00ktvxy4oai5dtsy	cmny9fmvk00k9vxy4cbw4r8qh	cmny9fdc1000cvxy4n4y9ezu8	40000	2026-04-14 06:48:20.146	2026-04-14 06:48:20.146
cmny9fn4c00kvvxy447nsz6op	cmny9fmvk00k9vxy4cbw4r8qh	cmny9fdcn000dvxy4w3gaald5	40000	2026-04-14 06:48:20.172	2026-04-14 06:48:20.172
cmny9fn5q00kyvxy4ls5t6ays	cmny9fn5000kwvxy4m521j248	cmny9fd420001vxy42djthn1o	25000	2026-04-14 06:48:20.222	2026-04-14 06:48:20.222
cmny9fn6o00l0vxy4xvoujo7c	cmny9fn5000kwvxy4m521j248	cmny9fd4t0002vxy4jo0l7gop	25000	2026-04-14 06:48:20.256	2026-04-14 06:48:20.256
cmny9fn7q00l2vxy4c59kmtbi	cmny9fn5000kwvxy4m521j248	cmny9fd5j0003vxy4sw5e14p1	25000	2026-04-14 06:48:20.294	2026-04-14 06:48:20.294
cmny9fn8j00l4vxy4gc8xu6zg	cmny9fn5000kwvxy4m521j248	cmny9fd6h0004vxy4evm3jgfv	25000	2026-04-14 06:48:20.323	2026-04-14 06:48:20.323
cmny9fn9h00l6vxy4nlazoi20	cmny9fn5000kwvxy4m521j248	cmny9fd7u0006vxy4mh4wwui4	25000	2026-04-14 06:48:20.357	2026-04-14 06:48:20.357
cmny9fnac00l8vxy4z1miff8g	cmny9fn5000kwvxy4m521j248	cmny9fd8i0007vxy4tmc0glr0	25000	2026-04-14 06:48:20.389	2026-04-14 06:48:20.389
cmny9fnb000lavxy4sz7dpbiy	cmny9fn5000kwvxy4m521j248	cmny9fd980008vxy4alsawn4y	25000	2026-04-14 06:48:20.412	2026-04-14 06:48:20.412
cmny9fnbq00lcvxy4snj1ug3y	cmny9fn5000kwvxy4m521j248	cmny9fd9w0009vxy498vvvu1d	25000	2026-04-14 06:48:20.439	2026-04-14 06:48:20.439
cmny9fncg00levxy4o0zf19j7	cmny9fn5000kwvxy4m521j248	cmny9fdb9000bvxy4h02fexen	25000	2026-04-14 06:48:20.464	2026-04-14 06:48:20.464
cmny9fndc00lgvxy418hth4ak	cmny9fn5000kwvxy4m521j248	cmny9fdc1000cvxy4n4y9ezu8	25000	2026-04-14 06:48:20.496	2026-04-14 06:48:20.496
cmny9fne200livxy4vm7ghmoj	cmny9fn5000kwvxy4m521j248	cmny9fdcn000dvxy4w3gaald5	25000	2026-04-14 06:48:20.522	2026-04-14 06:48:20.522
cmny9fnfp00llvxy4h2dv1njt	cmny9fnf000ljvxy4er93494o	cmny9fd420001vxy42djthn1o	120000	2026-04-14 06:48:20.581	2026-04-14 06:48:20.581
cmny9fngk00lnvxy41bihsy73	cmny9fnf000ljvxy4er93494o	cmny9fd4t0002vxy4jo0l7gop	120000	2026-04-14 06:48:20.612	2026-04-14 06:48:20.612
cmny9fnhb00lpvxy4rw9g9pnq	cmny9fnf000ljvxy4er93494o	cmny9fd5j0003vxy4sw5e14p1	120000	2026-04-14 06:48:20.639	2026-04-14 06:48:20.639
cmny9fni800lrvxy43xlkuxf3	cmny9fnf000ljvxy4er93494o	cmny9fd6h0004vxy4evm3jgfv	120000	2026-04-14 06:48:20.672	2026-04-14 06:48:20.672
cmny9fnj800ltvxy4iaowut68	cmny9fnf000ljvxy4er93494o	cmny9fd7u0006vxy4mh4wwui4	120000	2026-04-14 06:48:20.708	2026-04-14 06:48:20.708
cmny9fnk300lvvxy4u31lfpqr	cmny9fnf000ljvxy4er93494o	cmny9fd8i0007vxy4tmc0glr0	111000	2026-04-14 06:48:20.739	2026-04-14 06:48:20.739
cmny9fnl000lxvxy4aae3a127	cmny9fnf000ljvxy4er93494o	cmny9fd980008vxy4alsawn4y	120000	2026-04-14 06:48:20.772	2026-04-14 06:48:20.772
cmny9fnlo00lzvxy4xr5ggx5p	cmny9fnf000ljvxy4er93494o	cmny9fd9w0009vxy498vvvu1d	120000	2026-04-14 06:48:20.796	2026-04-14 06:48:20.796
cmny9fnmh00m1vxy4w3sovjaj	cmny9fnf000ljvxy4er93494o	cmny9fdb9000bvxy4h02fexen	120000	2026-04-14 06:48:20.825	2026-04-14 06:48:20.825
cmny9fnnb00m3vxy4wv9abdag	cmny9fnf000ljvxy4er93494o	cmny9fdc1000cvxy4n4y9ezu8	120000	2026-04-14 06:48:20.856	2026-04-14 06:48:20.856
cmny9fnnz00m5vxy4ba5v1z9p	cmny9fnf000ljvxy4er93494o	cmny9fdcn000dvxy4w3gaald5	120000	2026-04-14 06:48:20.879	2026-04-14 06:48:20.879
cmny9fnpo00m8vxy40jlxarsd	cmny9fnot00m6vxy4oys7urk4	cmny9fd420001vxy42djthn1o	85000	2026-04-14 06:48:20.94	2026-04-14 06:48:20.94
cmny9fnqo00mavxy4p9facukr	cmny9fnot00m6vxy4oys7urk4	cmny9fd4t0002vxy4jo0l7gop	85000	2026-04-14 06:48:20.976	2026-04-14 06:48:20.976
cmny9fnri00mcvxy4igajxx09	cmny9fnot00m6vxy4oys7urk4	cmny9fd5j0003vxy4sw5e14p1	85000	2026-04-14 06:48:21.006	2026-04-14 06:48:21.006
cmny9fnsf00mevxy4e86wp46d	cmny9fnot00m6vxy4oys7urk4	cmny9fd6h0004vxy4evm3jgfv	85000	2026-04-14 06:48:21.04	2026-04-14 06:48:21.04
cmny9fnte00mgvxy4zafa4d96	cmny9fnot00m6vxy4oys7urk4	cmny9fd7u0006vxy4mh4wwui4	85000	2026-04-14 06:48:21.074	2026-04-14 06:48:21.074
cmny9fnu900mivxy4gg121u6b	cmny9fnot00m6vxy4oys7urk4	cmny9fd8i0007vxy4tmc0glr0	85000	2026-04-14 06:48:21.106	2026-04-14 06:48:21.106
cmny9fnuw00mkvxy4mh0xehw2	cmny9fnot00m6vxy4oys7urk4	cmny9fd980008vxy4alsawn4y	85000	2026-04-14 06:48:21.128	2026-04-14 06:48:21.128
cmny9fnvo00mmvxy4npaxbrge	cmny9fnot00m6vxy4oys7urk4	cmny9fd9w0009vxy498vvvu1d	85000	2026-04-14 06:48:21.156	2026-04-14 06:48:21.156
cmny9fnwd00movxy4ccxu222n	cmny9fnot00m6vxy4oys7urk4	cmny9fdb9000bvxy4h02fexen	85000	2026-04-14 06:48:21.181	2026-04-14 06:48:21.181
cmny9fnx100mqvxy4hvmfhsmj	cmny9fnot00m6vxy4oys7urk4	cmny9fdc1000cvxy4n4y9ezu8	85000	2026-04-14 06:48:21.206	2026-04-14 06:48:21.206
cmny9fnxo00msvxy43vyvpabb	cmny9fnot00m6vxy4oys7urk4	cmny9fdcn000dvxy4w3gaald5	85000	2026-04-14 06:48:21.228	2026-04-14 06:48:21.228
cmny9fnz400mvvxy4d2xd8jvb	cmny9fnyf00mtvxy4x7kskjyy	cmny9fd420001vxy42djthn1o	50000	2026-04-14 06:48:21.28	2026-04-14 06:48:21.28
cmny9fo0100mxvxy4qxra7823	cmny9fnyf00mtvxy4x7kskjyy	cmny9fd4t0002vxy4jo0l7gop	50000	2026-04-14 06:48:21.313	2026-04-14 06:48:21.313
cmny9fo0r00mzvxy497smwnqg	cmny9fnyf00mtvxy4x7kskjyy	cmny9fd5j0003vxy4sw5e14p1	50000	2026-04-14 06:48:21.339	2026-04-14 06:48:21.339
cmny9fo1o00n1vxy4ywnuw4xf	cmny9fnyf00mtvxy4x7kskjyy	cmny9fd6h0004vxy4evm3jgfv	50000	2026-04-14 06:48:21.372	2026-04-14 06:48:21.372
cmny9fo2o00n3vxy4c13r3r9v	cmny9fnyf00mtvxy4x7kskjyy	cmny9fd7u0006vxy4mh4wwui4	50000	2026-04-14 06:48:21.408	2026-04-14 06:48:21.408
cmny9fo3i00n5vxy4eqnsb7yu	cmny9fnyf00mtvxy4x7kskjyy	cmny9fd8i0007vxy4tmc0glr0	48000	2026-04-14 06:48:21.439	2026-04-14 06:48:21.439
cmny9fo4g00n7vxy4zxq98c1e	cmny9fnyf00mtvxy4x7kskjyy	cmny9fd980008vxy4alsawn4y	50000	2026-04-14 06:48:21.472	2026-04-14 06:48:21.472
cmny9fo5l00n9vxy455x1q6ym	cmny9fnyf00mtvxy4x7kskjyy	cmny9fd9w0009vxy498vvvu1d	50000	2026-04-14 06:48:21.514	2026-04-14 06:48:21.514
cmny9fo6d00nbvxy4928sa59v	cmny9fnyf00mtvxy4x7kskjyy	cmny9fdb9000bvxy4h02fexen	50000	2026-04-14 06:48:21.541	2026-04-14 06:48:21.541
cmny9fo7800ndvxy4w4ilq5zy	cmny9fnyf00mtvxy4x7kskjyy	cmny9fdc1000cvxy4n4y9ezu8	50000	2026-04-14 06:48:21.572	2026-04-14 06:48:21.572
cmny9fo7v00nfvxy412vfh1ga	cmny9fnyf00mtvxy4x7kskjyy	cmny9fdcn000dvxy4w3gaald5	50000	2026-04-14 06:48:21.595	2026-04-14 06:48:21.595
cmny9fo9900nivxy48vyxv6l3	cmny9fo8l00ngvxy46dea435h	cmny9fd420001vxy42djthn1o	45000	2026-04-14 06:48:21.645	2026-04-14 06:48:21.645
cmny9foa000nkvxy4lwc950fd	cmny9fo8l00ngvxy46dea435h	cmny9fd4t0002vxy4jo0l7gop	45000	2026-04-14 06:48:21.672	2026-04-14 06:48:21.672
cmny9foan00nmvxy4v3euruzs	cmny9fo8l00ngvxy46dea435h	cmny9fd5j0003vxy4sw5e14p1	45000	2026-04-14 06:48:21.695	2026-04-14 06:48:21.695
cmny9fobe00novxy4n2vgipdb	cmny9fo8l00ngvxy46dea435h	cmny9fd6h0004vxy4evm3jgfv	45000	2026-04-14 06:48:21.722	2026-04-14 06:48:21.722
cmny9foc500nqvxy4x1fgs1e7	cmny9fo8l00ngvxy46dea435h	cmny9fd7u0006vxy4mh4wwui4	45000	2026-04-14 06:48:21.75	2026-04-14 06:48:21.75
cmny9focz00nsvxy4268rgd8b	cmny9fo8l00ngvxy46dea435h	cmny9fd8i0007vxy4tmc0glr0	43000	2026-04-14 06:48:21.78	2026-04-14 06:48:21.78
cmny9fodp00nuvxy4bpp64n1d	cmny9fo8l00ngvxy46dea435h	cmny9fd980008vxy4alsawn4y	45000	2026-04-14 06:48:21.805	2026-04-14 06:48:21.805
cmny9foed00nwvxy4or3z4ttc	cmny9fo8l00ngvxy46dea435h	cmny9fd9w0009vxy498vvvu1d	45000	2026-04-14 06:48:21.829	2026-04-14 06:48:21.829
cmny9fof600nyvxy4gaaiz5sf	cmny9fo8l00ngvxy46dea435h	cmny9fdb9000bvxy4h02fexen	45000	2026-04-14 06:48:21.858	2026-04-14 06:48:21.858
cmny9fog000o0vxy4t7k4uzm1	cmny9fo8l00ngvxy46dea435h	cmny9fdc1000cvxy4n4y9ezu8	45000	2026-04-14 06:48:21.889	2026-04-14 06:48:21.889
cmny9fogn00o2vxy4ie03bf1a	cmny9fo8l00ngvxy46dea435h	cmny9fdcn000dvxy4w3gaald5	45000	2026-04-14 06:48:21.912	2026-04-14 06:48:21.912
cmny9foi200o5vxy46z7nw1ve	cmny9fohf00o3vxy4c157rfcz	cmny9fd420001vxy42djthn1o	27000	2026-04-14 06:48:21.962	2026-04-14 06:48:21.962
cmny9foit00o7vxy4uomjrq0v	cmny9fohf00o3vxy4c157rfcz	cmny9fd4t0002vxy4jo0l7gop	27000	2026-04-14 06:48:21.989	2026-04-14 06:48:21.989
cmny9fojg00o9vxy4vj5maeju	cmny9fohf00o3vxy4c157rfcz	cmny9fd5j0003vxy4sw5e14p1	27000	2026-04-14 06:48:22.012	2026-04-14 06:48:22.012
cmny9fokb00obvxy4lt20dl7k	cmny9fohf00o3vxy4c157rfcz	cmny9fd6h0004vxy4evm3jgfv	27000	2026-04-14 06:48:22.043	2026-04-14 06:48:22.043
cmny9fol900odvxy4ww0u3cwb	cmny9fohf00o3vxy4c157rfcz	cmny9fd7u0006vxy4mh4wwui4	27000	2026-04-14 06:48:22.076	2026-04-14 06:48:22.076
cmny9fom600ofvxy44xwrbvcy	cmny9fohf00o3vxy4c157rfcz	cmny9fd8i0007vxy4tmc0glr0	25000	2026-04-14 06:48:22.11	2026-04-14 06:48:22.11
cmny9fon100ohvxy4dflelnuk	cmny9fohf00o3vxy4c157rfcz	cmny9fd980008vxy4alsawn4y	27000	2026-04-14 06:48:22.141	2026-04-14 06:48:22.141
cmny9fonx00ojvxy4i6sy394h	cmny9fohf00o3vxy4c157rfcz	cmny9fd9w0009vxy498vvvu1d	27000	2026-04-14 06:48:22.174	2026-04-14 06:48:22.174
cmny9fop300olvxy47rneehqv	cmny9fohf00o3vxy4c157rfcz	cmny9fdb9000bvxy4h02fexen	30000	2026-04-14 06:48:22.215	2026-04-14 06:48:22.215
cmny9fopy00onvxy4bu1dxo3f	cmny9fohf00o3vxy4c157rfcz	cmny9fdc1000cvxy4n4y9ezu8	27000	2026-04-14 06:48:22.246	2026-04-14 06:48:22.246
cmny9foqn00opvxy453yx5wsg	cmny9fohf00o3vxy4c157rfcz	cmny9fdcn000dvxy4w3gaald5	27000	2026-04-14 06:48:22.272	2026-04-14 06:48:22.272
cmny9fos100osvxy4refoeiiw	cmny9ford00oqvxy404oyhktk	cmny9fd420001vxy42djthn1o	27000	2026-04-14 06:48:22.321	2026-04-14 06:48:22.321
cmny9fosp00ouvxy4svvk0so8	cmny9ford00oqvxy404oyhktk	cmny9fd4t0002vxy4jo0l7gop	27000	2026-04-14 06:48:22.346	2026-04-14 06:48:22.346
cmny9fotg00owvxy4sa5fb40u	cmny9ford00oqvxy404oyhktk	cmny9fd5j0003vxy4sw5e14p1	27000	2026-04-14 06:48:22.372	2026-04-14 06:48:22.372
cmny9fou500oyvxy4zd5ydrgu	cmny9ford00oqvxy404oyhktk	cmny9fd6h0004vxy4evm3jgfv	27000	2026-04-14 06:48:22.397	2026-04-14 06:48:22.397
cmny9fouw00p0vxy4kcdxalku	cmny9ford00oqvxy404oyhktk	cmny9fd7u0006vxy4mh4wwui4	27000	2026-04-14 06:48:22.424	2026-04-14 06:48:22.424
cmny9fovr00p2vxy4vs7i9kzb	cmny9ford00oqvxy404oyhktk	cmny9fd8i0007vxy4tmc0glr0	25000	2026-04-14 06:48:22.456	2026-04-14 06:48:22.456
cmny9fowg00p4vxy489n6gme8	cmny9ford00oqvxy404oyhktk	cmny9fd980008vxy4alsawn4y	27000	2026-04-14 06:48:22.48	2026-04-14 06:48:22.48
cmny9fox500p6vxy4oaeux1yj	cmny9ford00oqvxy404oyhktk	cmny9fd9w0009vxy498vvvu1d	27000	2026-04-14 06:48:22.506	2026-04-14 06:48:22.506
cmny9foxw00p8vxy4vawxygi7	cmny9ford00oqvxy404oyhktk	cmny9fdb9000bvxy4h02fexen	30000	2026-04-14 06:48:22.532	2026-04-14 06:48:22.532
cmny9foys00pavxy45mulp1dg	cmny9ford00oqvxy404oyhktk	cmny9fdc1000cvxy4n4y9ezu8	27000	2026-04-14 06:48:22.564	2026-04-14 06:48:22.564
cmny9fozh00pcvxy4vysd49ho	cmny9ford00oqvxy404oyhktk	cmny9fdcn000dvxy4w3gaald5	27000	2026-04-14 06:48:22.589	2026-04-14 06:48:22.589
cmny9fp1c00pfvxy44yauna6m	cmny9fp0i00pdvxy4d8zywy4y	cmny9fd420001vxy42djthn1o	27000	2026-04-14 06:48:22.656	2026-04-14 06:48:22.656
cmny9fp2900phvxy4hzbow5kg	cmny9fp0i00pdvxy4d8zywy4y	cmny9fd4t0002vxy4jo0l7gop	27000	2026-04-14 06:48:22.689	2026-04-14 06:48:22.689
cmny9fp2v00pjvxy4b3k72ibb	cmny9fp0i00pdvxy4d8zywy4y	cmny9fd5j0003vxy4sw5e14p1	27000	2026-04-14 06:48:22.712	2026-04-14 06:48:22.712
cmny9fp3m00plvxy4x4336lwc	cmny9fp0i00pdvxy4d8zywy4y	cmny9fd6h0004vxy4evm3jgfv	27000	2026-04-14 06:48:22.739	2026-04-14 06:48:22.739
cmny9fp4b00pnvxy4k852om7x	cmny9fp0i00pdvxy4d8zywy4y	cmny9fd7u0006vxy4mh4wwui4	27000	2026-04-14 06:48:22.763	2026-04-14 06:48:22.763
cmny9fp5000ppvxy4qkklf0bs	cmny9fp0i00pdvxy4d8zywy4y	cmny9fd8i0007vxy4tmc0glr0	25000	2026-04-14 06:48:22.788	2026-04-14 06:48:22.788
cmny9fp5o00prvxy43is8zcsh	cmny9fp0i00pdvxy4d8zywy4y	cmny9fd980008vxy4alsawn4y	27000	2026-04-14 06:48:22.812	2026-04-14 06:48:22.812
cmny9fp6e00ptvxy44cs4l3sc	cmny9fp0i00pdvxy4d8zywy4y	cmny9fd9w0009vxy498vvvu1d	27000	2026-04-14 06:48:22.839	2026-04-14 06:48:22.839
cmny9fp7300pvvxy4vdzloouq	cmny9fp0i00pdvxy4d8zywy4y	cmny9fdb9000bvxy4h02fexen	30000	2026-04-14 06:48:22.864	2026-04-14 06:48:22.864
cmny9fp7s00pxvxy4iix2n55h	cmny9fp0i00pdvxy4d8zywy4y	cmny9fdc1000cvxy4n4y9ezu8	27000	2026-04-14 06:48:22.888	2026-04-14 06:48:22.888
cmny9fp8g00pzvxy4ngmju51y	cmny9fp0i00pdvxy4d8zywy4y	cmny9fdcn000dvxy4w3gaald5	27000	2026-04-14 06:48:22.912	2026-04-14 06:48:22.912
cmny9fp9t00q2vxy4c7x9ywqr	cmny9fp9800q0vxy40m2n99w1	cmny9fd420001vxy42djthn1o	28000	2026-04-14 06:48:22.961	2026-04-14 06:48:22.961
cmny9fpal00q4vxy495i858yg	cmny9fp9800q0vxy40m2n99w1	cmny9fd4t0002vxy4jo0l7gop	28000	2026-04-14 06:48:22.99	2026-04-14 06:48:22.99
cmny9fpb700q6vxy4h1fnudvu	cmny9fp9800q0vxy40m2n99w1	cmny9fd5j0003vxy4sw5e14p1	31000	2026-04-14 06:48:23.012	2026-04-14 06:48:23.012
cmny9fpbz00q8vxy4056ydy1q	cmny9fp9800q0vxy40m2n99w1	cmny9fd6h0004vxy4evm3jgfv	28000	2026-04-14 06:48:23.039	2026-04-14 06:48:23.039
cmny9fpco00qavxy478hoja9v	cmny9fp9800q0vxy40m2n99w1	cmny9fd7u0006vxy4mh4wwui4	28000	2026-04-14 06:48:23.064	2026-04-14 06:48:23.064
cmny9fpdd00qcvxy45igxog5m	cmny9fp9800q0vxy40m2n99w1	cmny9fd8i0007vxy4tmc0glr0	27000	2026-04-14 06:48:23.089	2026-04-14 06:48:23.089
cmny9fpdz00qevxy4s7z2mfbx	cmny9fp9800q0vxy40m2n99w1	cmny9fd980008vxy4alsawn4y	28000	2026-04-14 06:48:23.112	2026-04-14 06:48:23.112
cmny9fpeq00qgvxy4spb9igqr	cmny9fp9800q0vxy40m2n99w1	cmny9fd9w0009vxy498vvvu1d	28000	2026-04-14 06:48:23.138	2026-04-14 06:48:23.138
cmny9fpfg00qivxy4ce84ga4d	cmny9fp9800q0vxy40m2n99w1	cmny9fdb9000bvxy4h02fexen	31000	2026-04-14 06:48:23.164	2026-04-14 06:48:23.164
cmny9fpg400qkvxy4r6qnyy5d	cmny9fp9800q0vxy40m2n99w1	cmny9fdc1000cvxy4n4y9ezu8	28000	2026-04-14 06:48:23.189	2026-04-14 06:48:23.189
cmny9fpgs00qmvxy4stpnuxl9	cmny9fp9800q0vxy40m2n99w1	cmny9fdcn000dvxy4w3gaald5	28000	2026-04-14 06:48:23.212	2026-04-14 06:48:23.212
cmny9fpi700qpvxy4xe2lcsn6	cmny9fphi00qnvxy4jsz33d96	cmny9fd420001vxy42djthn1o	30000	2026-04-14 06:48:23.264	2026-04-14 06:48:23.264
cmny9fpix00qrvxy4figwq1qt	cmny9fphi00qnvxy4jsz33d96	cmny9fd4t0002vxy4jo0l7gop	30000	2026-04-14 06:48:23.29	2026-04-14 06:48:23.29
cmny9fpjl00qtvxy4sey376l3	cmny9fphi00qnvxy4jsz33d96	cmny9fd5j0003vxy4sw5e14p1	30000	2026-04-14 06:48:23.313	2026-04-14 06:48:23.313
cmny9fpkb00qvvxy4j5ypwf74	cmny9fphi00qnvxy4jsz33d96	cmny9fd6h0004vxy4evm3jgfv	30000	2026-04-14 06:48:23.339	2026-04-14 06:48:23.339
cmny9fpl000qxvxy4ocsltykj	cmny9fphi00qnvxy4jsz33d96	cmny9fd7u0006vxy4mh4wwui4	30000	2026-04-14 06:48:23.364	2026-04-14 06:48:23.364
cmny9fplo00qzvxy4hbrc10yi	cmny9fphi00qnvxy4jsz33d96	cmny9fd8i0007vxy4tmc0glr0	27000	2026-04-14 06:48:23.389	2026-04-14 06:48:23.389
cmny9fpmc00r1vxy45dvfgkw8	cmny9fphi00qnvxy4jsz33d96	cmny9fd980008vxy4alsawn4y	30000	2026-04-14 06:48:23.412	2026-04-14 06:48:23.412
cmny9fpn300r3vxy4ql1gfsa1	cmny9fphi00qnvxy4jsz33d96	cmny9fd9w0009vxy498vvvu1d	30000	2026-04-14 06:48:23.439	2026-04-14 06:48:23.439
cmny9fpns00r5vxy4uo5uf9nh	cmny9fphi00qnvxy4jsz33d96	cmny9fdb9000bvxy4h02fexen	33000	2026-04-14 06:48:23.464	2026-04-14 06:48:23.464
cmny9fpoh00r7vxy4mjvdybqj	cmny9fphi00qnvxy4jsz33d96	cmny9fdc1000cvxy4n4y9ezu8	30000	2026-04-14 06:48:23.489	2026-04-14 06:48:23.489
cmny9fpp300r9vxy4m7qtotdg	cmny9fphi00qnvxy4jsz33d96	cmny9fdcn000dvxy4w3gaald5	30000	2026-04-14 06:48:23.512	2026-04-14 06:48:23.512
cmny9fpqh00rcvxy4uw7t75l8	cmny9fppu00ravxy4rwxtlthy	cmny9fd420001vxy42djthn1o	33000	2026-04-14 06:48:23.562	2026-04-14 06:48:23.562
cmny9fpr900revxy4b3ty69rr	cmny9fppu00ravxy4rwxtlthy	cmny9fd4t0002vxy4jo0l7gop	33000	2026-04-14 06:48:23.589	2026-04-14 06:48:23.589
cmny9fprw00rgvxy43l8yrng4	cmny9fppu00ravxy4rwxtlthy	cmny9fd5j0003vxy4sw5e14p1	33000	2026-04-14 06:48:23.612	2026-04-14 06:48:23.612
cmny9fpsm00rivxy4pu2uvtco	cmny9fppu00ravxy4rwxtlthy	cmny9fd6h0004vxy4evm3jgfv	33000	2026-04-14 06:48:23.638	2026-04-14 06:48:23.638
cmny9fptb00rkvxy4qg9y06f2	cmny9fppu00ravxy4rwxtlthy	cmny9fd7u0006vxy4mh4wwui4	33000	2026-04-14 06:48:23.664	2026-04-14 06:48:23.664
cmny9fpu200rmvxy4detqfi0w	cmny9fppu00ravxy4rwxtlthy	cmny9fd8i0007vxy4tmc0glr0	31000	2026-04-14 06:48:23.69	2026-04-14 06:48:23.69
cmny9fpuy00rovxy4dlrcrnqq	cmny9fppu00ravxy4rwxtlthy	cmny9fd980008vxy4alsawn4y	33000	2026-04-14 06:48:23.722	2026-04-14 06:48:23.722
cmny9fpvm00rqvxy434fg7qb8	cmny9fppu00ravxy4rwxtlthy	cmny9fd9w0009vxy498vvvu1d	33000	2026-04-14 06:48:23.746	2026-04-14 06:48:23.746
cmny9fpwf00rsvxy41684lodf	cmny9fppu00ravxy4rwxtlthy	cmny9fdb9000bvxy4h02fexen	36000	2026-04-14 06:48:23.775	2026-04-14 06:48:23.775
cmny9fpx900ruvxy44thu3fpx	cmny9fppu00ravxy4rwxtlthy	cmny9fdc1000cvxy4n4y9ezu8	33000	2026-04-14 06:48:23.806	2026-04-14 06:48:23.806
cmny9fpxw00rwvxy4xj0p4srw	cmny9fppu00ravxy4rwxtlthy	cmny9fdcn000dvxy4w3gaald5	33000	2026-04-14 06:48:23.828	2026-04-14 06:48:23.828
cmny9fpzb00rzvxy4cj333b2g	cmny9fpyn00rxvxy4ga3bxf7f	cmny9fd420001vxy42djthn1o	33000	2026-04-14 06:48:23.879	2026-04-14 06:48:23.879
cmny9fq0100s1vxy4fqtl2pe6	cmny9fpyn00rxvxy4ga3bxf7f	cmny9fd4t0002vxy4jo0l7gop	33000	2026-04-14 06:48:23.906	2026-04-14 06:48:23.906
cmny9fq0o00s3vxy4owbazs52	cmny9fpyn00rxvxy4ga3bxf7f	cmny9fd5j0003vxy4sw5e14p1	33000	2026-04-14 06:48:23.929	2026-04-14 06:48:23.929
cmny9fq1f00s5vxy4pszjt0q0	cmny9fpyn00rxvxy4ga3bxf7f	cmny9fd6h0004vxy4evm3jgfv	33000	2026-04-14 06:48:23.955	2026-04-14 06:48:23.955
cmny9fq2400s7vxy4mald9sk8	cmny9fpyn00rxvxy4ga3bxf7f	cmny9fd7u0006vxy4mh4wwui4	33000	2026-04-14 06:48:23.981	2026-04-14 06:48:23.981
cmny9fq2u00s9vxy4xv446nkm	cmny9fpyn00rxvxy4ga3bxf7f	cmny9fd8i0007vxy4tmc0glr0	31000	2026-04-14 06:48:24.006	2026-04-14 06:48:24.006
cmny9fq3r00sbvxy4iool6j5o	cmny9fpyn00rxvxy4ga3bxf7f	cmny9fd980008vxy4alsawn4y	33000	2026-04-14 06:48:24.039	2026-04-14 06:48:24.039
cmny9fq4o00sdvxy4s87w2sxe	cmny9fpyn00rxvxy4ga3bxf7f	cmny9fd9w0009vxy498vvvu1d	33000	2026-04-14 06:48:24.072	2026-04-14 06:48:24.072
cmny9fq5e00sfvxy4se4dobt5	cmny9fpyn00rxvxy4ga3bxf7f	cmny9fdb9000bvxy4h02fexen	36000	2026-04-14 06:48:24.098	2026-04-14 06:48:24.098
cmny9fq6200shvxy4ry7lgsji	cmny9fpyn00rxvxy4ga3bxf7f	cmny9fdc1000cvxy4n4y9ezu8	33000	2026-04-14 06:48:24.122	2026-04-14 06:48:24.122
cmny9fq7900sjvxy4aw3pkhei	cmny9fpyn00rxvxy4ga3bxf7f	cmny9fdcn000dvxy4w3gaald5	33000	2026-04-14 06:48:24.165	2026-04-14 06:48:24.165
cmny9fq9a00smvxy4ja2vm10m	cmny9fq8k00skvxy485ibxqwm	cmny9fd420001vxy42djthn1o	25000	2026-04-14 06:48:24.238	2026-04-14 06:48:24.238
cmny9fq9z00sovxy4hqpvl3t1	cmny9fq8k00skvxy485ibxqwm	cmny9fd4t0002vxy4jo0l7gop	25000	2026-04-14 06:48:24.263	2026-04-14 06:48:24.263
cmny9fqao00sqvxy4cmmqnk2e	cmny9fq8k00skvxy485ibxqwm	cmny9fd5j0003vxy4sw5e14p1	25000	2026-04-14 06:48:24.288	2026-04-14 06:48:24.288
cmny9fqbc00ssvxy4mx2hrwhd	cmny9fq8k00skvxy485ibxqwm	cmny9fd6h0004vxy4evm3jgfv	25000	2026-04-14 06:48:24.313	2026-04-14 06:48:24.313
cmny9fqc600suvxy4kf8olc3p	cmny9fq8k00skvxy485ibxqwm	cmny9fd7u0006vxy4mh4wwui4	25000	2026-04-14 06:48:24.342	2026-04-14 06:48:24.342
cmny9fqd000swvxy4yu9l660x	cmny9fq8k00skvxy485ibxqwm	cmny9fd8i0007vxy4tmc0glr0	25000	2026-04-14 06:48:24.372	2026-04-14 06:48:24.372
cmny9fqdw00syvxy4pbqmfd9d	cmny9fq8k00skvxy485ibxqwm	cmny9fd980008vxy4alsawn4y	25000	2026-04-14 06:48:24.405	2026-04-14 06:48:24.405
cmny9fqev00t0vxy48d6839ib	cmny9fq8k00skvxy485ibxqwm	cmny9fd9w0009vxy498vvvu1d	25000	2026-04-14 06:48:24.439	2026-04-14 06:48:24.439
cmny9fqfk00t2vxy4eqmhi0by	cmny9fq8k00skvxy485ibxqwm	cmny9fdb9000bvxy4h02fexen	28000	2026-04-14 06:48:24.464	2026-04-14 06:48:24.464
cmny9fqg900t4vxy4lqxpp86n	cmny9fq8k00skvxy485ibxqwm	cmny9fdc1000cvxy4n4y9ezu8	25000	2026-04-14 06:48:24.489	2026-04-14 06:48:24.489
cmny9fqgw00t6vxy4jqsa5gk3	cmny9fq8k00skvxy485ibxqwm	cmny9fdcn000dvxy4w3gaald5	25000	2026-04-14 06:48:24.512	2026-04-14 06:48:24.512
cmny9fqij00t9vxy4a8kem3wl	cmny9fqhn00t7vxy4gyvnbv6i	cmny9fd420001vxy42djthn1o	22000	2026-04-14 06:48:24.572	2026-04-14 06:48:24.572
cmny9fqj800tbvxy4fkp0mstd	cmny9fqhn00t7vxy4gyvnbv6i	cmny9fd4t0002vxy4jo0l7gop	22000	2026-04-14 06:48:24.596	2026-04-14 06:48:24.596
cmny9fqjy00tdvxy41sptxd6l	cmny9fqhn00t7vxy4gyvnbv6i	cmny9fd5j0003vxy4sw5e14p1	22000	2026-04-14 06:48:24.622	2026-04-14 06:48:24.622
cmny9fqkv00tfvxy40mu94wbf	cmny9fqhn00t7vxy4gyvnbv6i	cmny9fd6h0004vxy4evm3jgfv	22000	2026-04-14 06:48:24.655	2026-04-14 06:48:24.655
cmny9fqll00thvxy4we97ucba	cmny9fqhn00t7vxy4gyvnbv6i	cmny9fd7u0006vxy4mh4wwui4	22000	2026-04-14 06:48:24.681	2026-04-14 06:48:24.681
cmny9fqm900tjvxy4bvdwp0aw	cmny9fqhn00t7vxy4gyvnbv6i	cmny9fd8i0007vxy4tmc0glr0	22000	2026-04-14 06:48:24.706	2026-04-14 06:48:24.706
cmny9fqmw00tlvxy4kyet8rsv	cmny9fqhn00t7vxy4gyvnbv6i	cmny9fd980008vxy4alsawn4y	22000	2026-04-14 06:48:24.729	2026-04-14 06:48:24.729
cmny9fqnn00tnvxy4xl9ee9d2	cmny9fqhn00t7vxy4gyvnbv6i	cmny9fd9w0009vxy498vvvu1d	22000	2026-04-14 06:48:24.756	2026-04-14 06:48:24.756
cmny9fqod00tpvxy4bdhwiwxl	cmny9fqhn00t7vxy4gyvnbv6i	cmny9fdb9000bvxy4h02fexen	25000	2026-04-14 06:48:24.781	2026-04-14 06:48:24.781
cmny9fqp200trvxy4mp4bm671	cmny9fqhn00t7vxy4gyvnbv6i	cmny9fdc1000cvxy4n4y9ezu8	22000	2026-04-14 06:48:24.806	2026-04-14 06:48:24.806
cmny9fqpq00ttvxy49im1rs6r	cmny9fqhn00t7vxy4gyvnbv6i	cmny9fdcn000dvxy4w3gaald5	22000	2026-04-14 06:48:24.83	2026-04-14 06:48:24.83
cmny9fqrd00twvxy4qiv8i925	cmny9fqqn00tuvxy4dvqc51p3	cmny9fd420001vxy42djthn1o	50000	2026-04-14 06:48:24.889	2026-04-14 06:48:24.889
cmny9fqs200tyvxy4tu6fot54	cmny9fqqn00tuvxy4dvqc51p3	cmny9fd4t0002vxy4jo0l7gop	50000	2026-04-14 06:48:24.914	2026-04-14 06:48:24.914
cmny9fqsq00u0vxy43p9rj8ze	cmny9fqqn00tuvxy4dvqc51p3	cmny9fd5j0003vxy4sw5e14p1	50000	2026-04-14 06:48:24.938	2026-04-14 06:48:24.938
cmny9fqtf00u2vxy4wjw2uvyl	cmny9fqqn00tuvxy4dvqc51p3	cmny9fd6h0004vxy4evm3jgfv	50000	2026-04-14 06:48:24.963	2026-04-14 06:48:24.963
cmny9fqu700u4vxy42vwo80az	cmny9fqqn00tuvxy4dvqc51p3	cmny9fd7u0006vxy4mh4wwui4	50000	2026-04-14 06:48:24.991	2026-04-14 06:48:24.991
cmny9fqv300u6vxy4px8t7p28	cmny9fqqn00tuvxy4dvqc51p3	cmny9fd8i0007vxy4tmc0glr0	48000	2026-04-14 06:48:25.023	2026-04-14 06:48:25.023
cmny9fqvp00u8vxy46eqewwxn	cmny9fqqn00tuvxy4dvqc51p3	cmny9fd980008vxy4alsawn4y	50000	2026-04-14 06:48:25.046	2026-04-14 06:48:25.046
cmny9fqwg00uavxy4l5tw489z	cmny9fqqn00tuvxy4dvqc51p3	cmny9fd9w0009vxy498vvvu1d	50000	2026-04-14 06:48:25.072	2026-04-14 06:48:25.072
cmny9fqx500ucvxy4ch7gselr	cmny9fqqn00tuvxy4dvqc51p3	cmny9fdb9000bvxy4h02fexen	53000	2026-04-14 06:48:25.097	2026-04-14 06:48:25.097
cmny9fqxu00uevxy4hd05jocy	cmny9fqqn00tuvxy4dvqc51p3	cmny9fdc1000cvxy4n4y9ezu8	50000	2026-04-14 06:48:25.122	2026-04-14 06:48:25.122
cmny9fqyh00ugvxy4m1kp7hri	cmny9fqqn00tuvxy4dvqc51p3	cmny9fdcn000dvxy4w3gaald5	50000	2026-04-14 06:48:25.145	2026-04-14 06:48:25.145
cmny9fr0m00ujvxy4nqxe4rbt	cmny9fqzu00uhvxy4tn6ep25a	cmny9fd420001vxy42djthn1o	44000	2026-04-14 06:48:25.222	2026-04-14 06:48:25.222
cmny9fr1a00ulvxy4bmqdgkyj	cmny9fqzu00uhvxy4tn6ep25a	cmny9fd4t0002vxy4jo0l7gop	44000	2026-04-14 06:48:25.246	2026-04-14 06:48:25.246
cmny9fr2100unvxy46p085tn8	cmny9fqzu00uhvxy4tn6ep25a	cmny9fd5j0003vxy4sw5e14p1	44000	2026-04-14 06:48:25.273	2026-04-14 06:48:25.273
cmny9fr2x00upvxy4ac21sbwv	cmny9fqzu00uhvxy4tn6ep25a	cmny9fd6h0004vxy4evm3jgfv	44000	2026-04-14 06:48:25.306	2026-04-14 06:48:25.306
cmny9fr5j00urvxy48eh8lael	cmny9fqzu00uhvxy4tn6ep25a	cmny9fd7u0006vxy4mh4wwui4	44000	2026-04-14 06:48:25.399	2026-04-14 06:48:25.399
cmny9fr7700utvxy4ntby5bxc	cmny9fqzu00uhvxy4tn6ep25a	cmny9fd8i0007vxy4tmc0glr0	42000	2026-04-14 06:48:25.459	2026-04-14 06:48:25.459
cmny9fr8100uvvxy480k0g5hn	cmny9fqzu00uhvxy4tn6ep25a	cmny9fd980008vxy4alsawn4y	44000	2026-04-14 06:48:25.489	2026-04-14 06:48:25.489
cmny9fr9700uxvxy47rjkqf34	cmny9fqzu00uhvxy4tn6ep25a	cmny9fd9w0009vxy498vvvu1d	44000	2026-04-14 06:48:25.531	2026-04-14 06:48:25.531
cmny9frci00uzvxy4cbrdlrg6	cmny9fqzu00uhvxy4tn6ep25a	cmny9fdb9000bvxy4h02fexen	47000	2026-04-14 06:48:25.65	2026-04-14 06:48:25.65
cmny9frdd00v1vxy4oauhm32q	cmny9fqzu00uhvxy4tn6ep25a	cmny9fdc1000cvxy4n4y9ezu8	44000	2026-04-14 06:48:25.681	2026-04-14 06:48:25.681
cmny9fre100v3vxy4njiajqou	cmny9fqzu00uhvxy4tn6ep25a	cmny9fdcn000dvxy4w3gaald5	44000	2026-04-14 06:48:25.705	2026-04-14 06:48:25.705
cmny9frfg00v6vxy4w89iq7fw	cmny9frep00v4vxy4rdn8tp2x	cmny9fd420001vxy42djthn1o	44000	2026-04-14 06:48:25.756	2026-04-14 06:48:25.756
cmny9frgd00v8vxy4241m41em	cmny9frep00v4vxy4rdn8tp2x	cmny9fd4t0002vxy4jo0l7gop	44000	2026-04-14 06:48:25.789	2026-04-14 06:48:25.789
cmny9frh000vavxy4fuhrz4y9	cmny9frep00v4vxy4rdn8tp2x	cmny9fd5j0003vxy4sw5e14p1	44000	2026-04-14 06:48:25.812	2026-04-14 06:48:25.812
cmny9frhr00vcvxy4c43woeau	cmny9frep00v4vxy4rdn8tp2x	cmny9fd6h0004vxy4evm3jgfv	44000	2026-04-14 06:48:25.839	2026-04-14 06:48:25.839
cmny9frih00vevxy4hm140f6v	cmny9frep00v4vxy4rdn8tp2x	cmny9fd7u0006vxy4mh4wwui4	44000	2026-04-14 06:48:25.865	2026-04-14 06:48:25.865
cmny9frjc00vgvxy4ucl48n4y	cmny9frep00v4vxy4rdn8tp2x	cmny9fd8i0007vxy4tmc0glr0	42000	2026-04-14 06:48:25.896	2026-04-14 06:48:25.896
cmny9frk200vivxy4ln23t8un	cmny9frep00v4vxy4rdn8tp2x	cmny9fd980008vxy4alsawn4y	44000	2026-04-14 06:48:25.922	2026-04-14 06:48:25.922
cmny9frkq00vkvxy45hf7ozu9	cmny9frep00v4vxy4rdn8tp2x	cmny9fd9w0009vxy498vvvu1d	44000	2026-04-14 06:48:25.946	2026-04-14 06:48:25.946
cmny9frli00vmvxy49u0sr6k3	cmny9frep00v4vxy4rdn8tp2x	cmny9fdb9000bvxy4h02fexen	47000	2026-04-14 06:48:25.974	2026-04-14 06:48:25.974
cmny9frme00vovxy4vhfe9819	cmny9frep00v4vxy4rdn8tp2x	cmny9fdc1000cvxy4n4y9ezu8	44000	2026-04-14 06:48:26.006	2026-04-14 06:48:26.006
cmny9frn100vqvxy4sdxih0eq	cmny9frep00v4vxy4rdn8tp2x	cmny9fdcn000dvxy4w3gaald5	44000	2026-04-14 06:48:26.029	2026-04-14 06:48:26.029
cmny9frof00vtvxy4a7w8ivpu	cmny9frnr00vrvxy4nmi6dk3p	cmny9fd420001vxy42djthn1o	42000	2026-04-14 06:48:26.079	2026-04-14 06:48:26.079
cmny9frp600vvvxy4jrtuue68	cmny9frnr00vrvxy4nmi6dk3p	cmny9fd4t0002vxy4jo0l7gop	42000	2026-04-14 06:48:26.106	2026-04-14 06:48:26.106
cmny9frpt00vxvxy41y4webxd	cmny9frnr00vrvxy4nmi6dk3p	cmny9fd5j0003vxy4sw5e14p1	42000	2026-04-14 06:48:26.129	2026-04-14 06:48:26.129
cmny9frqk00vzvxy40e11n2vc	cmny9frnr00vrvxy4nmi6dk3p	cmny9fd6h0004vxy4evm3jgfv	42000	2026-04-14 06:48:26.156	2026-04-14 06:48:26.156
cmny9frr900w1vxy4tr1skxy9	cmny9frnr00vrvxy4nmi6dk3p	cmny9fd7u0006vxy4mh4wwui4	42000	2026-04-14 06:48:26.181	2026-04-14 06:48:26.181
cmny9frry00w3vxy4vkp5sy8l	cmny9frnr00vrvxy4nmi6dk3p	cmny9fd8i0007vxy4tmc0glr0	40000	2026-04-14 06:48:26.206	2026-04-14 06:48:26.206
cmny9frsk00w5vxy49x84bti4	cmny9frnr00vrvxy4nmi6dk3p	cmny9fd980008vxy4alsawn4y	42000	2026-04-14 06:48:26.229	2026-04-14 06:48:26.229
cmny9frtc00w7vxy4c88d7oqy	cmny9frnr00vrvxy4nmi6dk3p	cmny9fd9w0009vxy498vvvu1d	42000	2026-04-14 06:48:26.256	2026-04-14 06:48:26.256
cmny9fru100w9vxy4miwxcqtw	cmny9frnr00vrvxy4nmi6dk3p	cmny9fdb9000bvxy4h02fexen	45000	2026-04-14 06:48:26.281	2026-04-14 06:48:26.281
cmny9frup00wbvxy4ducup7rj	cmny9frnr00vrvxy4nmi6dk3p	cmny9fdc1000cvxy4n4y9ezu8	42000	2026-04-14 06:48:26.306	2026-04-14 06:48:26.306
cmny9frvc00wdvxy4dx5pgi8c	cmny9frnr00vrvxy4nmi6dk3p	cmny9fdcn000dvxy4w3gaald5	42000	2026-04-14 06:48:26.328	2026-04-14 06:48:26.328
cmny9frwr00wgvxy4tlyinuo9	cmny9frw400wevxy494ut3iuo	cmny9fd420001vxy42djthn1o	25000	2026-04-14 06:48:26.379	2026-04-14 06:48:26.379
cmny9frxi00wivxy4y8x8doj9	cmny9frw400wevxy494ut3iuo	cmny9fd4t0002vxy4jo0l7gop	25000	2026-04-14 06:48:26.406	2026-04-14 06:48:26.406
cmny9fryf00wkvxy4eptctgj3	cmny9frw400wevxy494ut3iuo	cmny9fd5j0003vxy4sw5e14p1	25000	2026-04-14 06:48:26.439	2026-04-14 06:48:26.439
cmny9frz200wmvxy4vf81zn1d	cmny9frw400wevxy494ut3iuo	cmny9fd6h0004vxy4evm3jgfv	25000	2026-04-14 06:48:26.463	2026-04-14 06:48:26.463
cmny9frzu00wovxy42ka9aue4	cmny9frw400wevxy494ut3iuo	cmny9fd7u0006vxy4mh4wwui4	25000	2026-04-14 06:48:26.491	2026-04-14 06:48:26.491
cmny9fs0z00wqvxy41bxyrls8	cmny9frw400wevxy494ut3iuo	cmny9fd8i0007vxy4tmc0glr0	24000	2026-04-14 06:48:26.531	2026-04-14 06:48:26.531
cmny9fs2b00wsvxy4847a9sut	cmny9frw400wevxy494ut3iuo	cmny9fd980008vxy4alsawn4y	25000	2026-04-14 06:48:26.579	2026-04-14 06:48:26.579
cmny9fs3100wuvxy4ivjicrke	cmny9frw400wevxy494ut3iuo	cmny9fd9w0009vxy498vvvu1d	25000	2026-04-14 06:48:26.605	2026-04-14 06:48:26.605
cmny9fs3s00wwvxy4fzvmfes5	cmny9frw400wevxy494ut3iuo	cmny9fdb9000bvxy4h02fexen	28000	2026-04-14 06:48:26.632	2026-04-14 06:48:26.632
cmny9fs4m00wyvxy4tbbykzp6	cmny9frw400wevxy494ut3iuo	cmny9fdc1000cvxy4n4y9ezu8	25000	2026-04-14 06:48:26.662	2026-04-14 06:48:26.662
cmny9fs5d00x0vxy4qcfh27lr	cmny9frw400wevxy494ut3iuo	cmny9fdcn000dvxy4w3gaald5	25000	2026-04-14 06:48:26.689	2026-04-14 06:48:26.689
cmny9fs6r00x3vxy4t4baa791	cmny9fs6100x1vxy49qe3vyt2	cmny9fd420001vxy42djthn1o	50000	2026-04-14 06:48:26.739	2026-04-14 06:48:26.739
cmny9fs7f00x5vxy4zlunggpp	cmny9fs6100x1vxy49qe3vyt2	cmny9fd4t0002vxy4jo0l7gop	50000	2026-04-14 06:48:26.763	2026-04-14 06:48:26.763
cmny9fs8400x7vxy4trkwrk33	cmny9fs6100x1vxy49qe3vyt2	cmny9fd5j0003vxy4sw5e14p1	50000	2026-04-14 06:48:26.789	2026-04-14 06:48:26.789
cmny9fs8s00x9vxy4cgguoe4c	cmny9fs6100x1vxy49qe3vyt2	cmny9fd6h0004vxy4evm3jgfv	50000	2026-04-14 06:48:26.812	2026-04-14 06:48:26.812
cmny9fs9l00xbvxy4hsgtj773	cmny9fs6100x1vxy49qe3vyt2	cmny9fd7u0006vxy4mh4wwui4	50000	2026-04-14 06:48:26.841	2026-04-14 06:48:26.841
cmny9fsag00xdvxy4s9f9glg3	cmny9fs6100x1vxy49qe3vyt2	cmny9fd8i0007vxy4tmc0glr0	45000	2026-04-14 06:48:26.873	2026-04-14 06:48:26.873
cmny9fsbd00xfvxy4vzvhtocn	cmny9fs6100x1vxy49qe3vyt2	cmny9fd980008vxy4alsawn4y	50000	2026-04-14 06:48:26.906	2026-04-14 06:48:26.906
cmny9fsc100xhvxy4rutfzk6e	cmny9fs6100x1vxy49qe3vyt2	cmny9fd9w0009vxy498vvvu1d	50000	2026-04-14 06:48:26.929	2026-04-14 06:48:26.929
cmny9fscv00xjvxy42kndmfl2	cmny9fs6100x1vxy49qe3vyt2	cmny9fdb9000bvxy4h02fexen	53000	2026-04-14 06:48:26.959	2026-04-14 06:48:26.959
cmny9fsdo00xlvxy4xd0njdfy	cmny9fs6100x1vxy49qe3vyt2	cmny9fdc1000cvxy4n4y9ezu8	50000	2026-04-14 06:48:26.988	2026-04-14 06:48:26.988
cmny9fsen00xnvxy42tyhut9g	cmny9fs6100x1vxy49qe3vyt2	cmny9fdcn000dvxy4w3gaald5	50000	2026-04-14 06:48:27.023	2026-04-14 06:48:27.023
cmny9fsg100xqvxy47w8vaj00	cmny9fsfa00xovxy4g4s6mxxd	cmny9fd420001vxy42djthn1o	45000	2026-04-14 06:48:27.073	2026-04-14 06:48:27.073
cmny9fsgn00xsvxy40gk2bgay	cmny9fsfa00xovxy4g4s6mxxd	cmny9fd4t0002vxy4jo0l7gop	45000	2026-04-14 06:48:27.096	2026-04-14 06:48:27.096
cmny9fshe00xuvxy4jr6a3dnb	cmny9fsfa00xovxy4g4s6mxxd	cmny9fd5j0003vxy4sw5e14p1	48000	2026-04-14 06:48:27.122	2026-04-14 06:48:27.122
cmny9fsi100xwvxy44qvjded4	cmny9fsfa00xovxy4g4s6mxxd	cmny9fd6h0004vxy4evm3jgfv	45000	2026-04-14 06:48:27.146	2026-04-14 06:48:27.146
cmny9fsiv00xyvxy4klvk5jul	cmny9fsfa00xovxy4g4s6mxxd	cmny9fd7u0006vxy4mh4wwui4	37000	2026-04-14 06:48:27.175	2026-04-14 06:48:27.175
cmny9fsjr00y0vxy4zgs35lv9	cmny9fsfa00xovxy4g4s6mxxd	cmny9fd980008vxy4alsawn4y	45000	2026-04-14 06:48:27.208	2026-04-14 06:48:27.208
cmny9fskn00y2vxy4tqocp3vd	cmny9fsfa00xovxy4g4s6mxxd	cmny9fd9w0009vxy498vvvu1d	45000	2026-04-14 06:48:27.239	2026-04-14 06:48:27.239
cmny9fslc00y4vxy4x5wtxpy8	cmny9fsfa00xovxy4g4s6mxxd	cmny9fdb9000bvxy4h02fexen	48000	2026-04-14 06:48:27.264	2026-04-14 06:48:27.264
cmny9fsm100y6vxy4vecbpgs8	cmny9fsfa00xovxy4g4s6mxxd	cmny9fdc1000cvxy4n4y9ezu8	45000	2026-04-14 06:48:27.289	2026-04-14 06:48:27.289
cmny9fsmo00y8vxy4m3kukxe4	cmny9fsfa00xovxy4g4s6mxxd	cmny9fdcn000dvxy4w3gaald5	45000	2026-04-14 06:48:27.312	2026-04-14 06:48:27.312
cmny9fso200ybvxy4zrsqi5pf	cmny9fsnf00y9vxy4x3fvrdsa	cmny9fd420001vxy42djthn1o	45000	2026-04-14 06:48:27.362	2026-04-14 06:48:27.362
cmny9fsot00ydvxy4gvnjes4q	cmny9fsnf00y9vxy4x3fvrdsa	cmny9fd4t0002vxy4jo0l7gop	45000	2026-04-14 06:48:27.389	2026-04-14 06:48:27.389
cmny9fspg00yfvxy4olnx912z	cmny9fsnf00y9vxy4x3fvrdsa	cmny9fd5j0003vxy4sw5e14p1	48000	2026-04-14 06:48:27.412	2026-04-14 06:48:27.412
cmny9fsq700yhvxy4nc1eb0vl	cmny9fsnf00y9vxy4x3fvrdsa	cmny9fd6h0004vxy4evm3jgfv	45000	2026-04-14 06:48:27.439	2026-04-14 06:48:27.439
cmny9fsqy00yjvxy4ecrge9a1	cmny9fsnf00y9vxy4x3fvrdsa	cmny9fd7u0006vxy4mh4wwui4	37000	2026-04-14 06:48:27.466	2026-04-14 06:48:27.466
cmny9fsru00ylvxy4ubl5tbn1	cmny9fsnf00y9vxy4x3fvrdsa	cmny9fd980008vxy4alsawn4y	45000	2026-04-14 06:48:27.499	2026-04-14 06:48:27.499
cmny9fssi00ynvxy4sk86fkvp	cmny9fsnf00y9vxy4x3fvrdsa	cmny9fd9w0009vxy498vvvu1d	45000	2026-04-14 06:48:27.522	2026-04-14 06:48:27.522
cmny9fst900ypvxy47vmkjp7a	cmny9fsnf00y9vxy4x3fvrdsa	cmny9fdb9000bvxy4h02fexen	48000	2026-04-14 06:48:27.55	2026-04-14 06:48:27.55
cmny9fstw00yrvxy4tgc5rsch	cmny9fsnf00y9vxy4x3fvrdsa	cmny9fdc1000cvxy4n4y9ezu8	45000	2026-04-14 06:48:27.573	2026-04-14 06:48:27.573
cmny9fsuk00ytvxy4ml7oi80q	cmny9fsnf00y9vxy4x3fvrdsa	cmny9fdcn000dvxy4w3gaald5	45000	2026-04-14 06:48:27.597	2026-04-14 06:48:27.597
cmny9fsvy00ywvxy42clvdzs1	cmny9fsva00yuvxy4zvvz5lhi	cmny9fd420001vxy42djthn1o	45000	2026-04-14 06:48:27.646	2026-04-14 06:48:27.646
cmny9fswo00yyvxy4mhmpucl1	cmny9fsva00yuvxy4zvvz5lhi	cmny9fd4t0002vxy4jo0l7gop	45000	2026-04-14 06:48:27.672	2026-04-14 06:48:27.672
cmny9fsxd00z0vxy4bayup2r8	cmny9fsva00yuvxy4zvvz5lhi	cmny9fd5j0003vxy4sw5e14p1	48000	2026-04-14 06:48:27.697	2026-04-14 06:48:27.697
cmny9fsy200z2vxy4w3kt3jbw	cmny9fsva00yuvxy4zvvz5lhi	cmny9fd6h0004vxy4evm3jgfv	45000	2026-04-14 06:48:27.722	2026-04-14 06:48:27.722
cmny9fsyt00z4vxy4td7wya8u	cmny9fsva00yuvxy4zvvz5lhi	cmny9fd7u0006vxy4mh4wwui4	37000	2026-04-14 06:48:27.749	2026-04-14 06:48:27.749
cmny9fszi00z6vxy4svr2wfzs	cmny9fsva00yuvxy4zvvz5lhi	cmny9fd980008vxy4alsawn4y	45000	2026-04-14 06:48:27.774	2026-04-14 06:48:27.774
cmny9ft0e00z8vxy4cr2cmced	cmny9fsva00yuvxy4zvvz5lhi	cmny9fd9w0009vxy498vvvu1d	45000	2026-04-14 06:48:27.806	2026-04-14 06:48:27.806
cmny9ft1300zavxy4c2cf1msl	cmny9fsva00yuvxy4zvvz5lhi	cmny9fdb9000bvxy4h02fexen	48000	2026-04-14 06:48:27.831	2026-04-14 06:48:27.831
cmny9ft1r00zcvxy4cczqm46e	cmny9fsva00yuvxy4zvvz5lhi	cmny9fdc1000cvxy4n4y9ezu8	45000	2026-04-14 06:48:27.856	2026-04-14 06:48:27.856
cmny9ft2f00zevxy4qko1zpi5	cmny9fsva00yuvxy4zvvz5lhi	cmny9fdcn000dvxy4w3gaald5	45000	2026-04-14 06:48:27.879	2026-04-14 06:48:27.879
cmny9ft3t00zhvxy4nmqxf0kw	cmny9ft3600zfvxy4ubx2j3g8	cmny9fd420001vxy42djthn1o	45000	2026-04-14 06:48:27.929	2026-04-14 06:48:27.929
cmny9ft4j00zjvxy4llcu9dsj	cmny9ft3600zfvxy4ubx2j3g8	cmny9fd4t0002vxy4jo0l7gop	45000	2026-04-14 06:48:27.955	2026-04-14 06:48:27.955
cmny9ft5600zlvxy42rtc4qxj	cmny9ft3600zfvxy4ubx2j3g8	cmny9fd5j0003vxy4sw5e14p1	48000	2026-04-14 06:48:27.978	2026-04-14 06:48:27.978
cmny9ft5y00znvxy4ujzcvoxu	cmny9ft3600zfvxy4ubx2j3g8	cmny9fd6h0004vxy4evm3jgfv	45000	2026-04-14 06:48:28.006	2026-04-14 06:48:28.006
cmny9ft6m00zpvxy4s7z0e13r	cmny9ft3600zfvxy4ubx2j3g8	cmny9fd7u0006vxy4mh4wwui4	37000	2026-04-14 06:48:28.031	2026-04-14 06:48:28.031
cmny9ft7f00zrvxy419jbxy1i	cmny9ft3600zfvxy4ubx2j3g8	cmny9fd980008vxy4alsawn4y	45000	2026-04-14 06:48:28.059	2026-04-14 06:48:28.059
cmny9ft8800ztvxy4ybaneg0e	cmny9ft3600zfvxy4ubx2j3g8	cmny9fd9w0009vxy498vvvu1d	45000	2026-04-14 06:48:28.088	2026-04-14 06:48:28.088
cmny9ft8y00zvvxy4rmvr5szp	cmny9ft3600zfvxy4ubx2j3g8	cmny9fdb9000bvxy4h02fexen	48000	2026-04-14 06:48:28.115	2026-04-14 06:48:28.115
cmny9ft9m00zxvxy4m2pceu8f	cmny9ft3600zfvxy4ubx2j3g8	cmny9fdc1000cvxy4n4y9ezu8	45000	2026-04-14 06:48:28.139	2026-04-14 06:48:28.139
cmny9ftab00zzvxy4uexkz74y	cmny9ft3600zfvxy4ubx2j3g8	cmny9fdcn000dvxy4w3gaald5	45000	2026-04-14 06:48:28.163	2026-04-14 06:48:28.163
cmny9ftbq0102vxy43kflkxxb	cmny9ftb00100vxy4qghsouxb	cmny9fd420001vxy42djthn1o	45000	2026-04-14 06:48:28.215	2026-04-14 06:48:28.215
cmny9ftcn0104vxy4hmmhcwb8	cmny9ftb00100vxy4qghsouxb	cmny9fd4t0002vxy4jo0l7gop	45000	2026-04-14 06:48:28.248	2026-04-14 06:48:28.248
cmny9ftdj0106vxy46fgghexf	cmny9ftb00100vxy4qghsouxb	cmny9fd5j0003vxy4sw5e14p1	48000	2026-04-14 06:48:28.28	2026-04-14 06:48:28.28
cmny9fte80108vxy4aojody4w	cmny9ftb00100vxy4qghsouxb	cmny9fd6h0004vxy4evm3jgfv	45000	2026-04-14 06:48:28.305	2026-04-14 06:48:28.305
cmny9ftf0010avxy42azfbcjx	cmny9ftb00100vxy4qghsouxb	cmny9fd7u0006vxy4mh4wwui4	37000	2026-04-14 06:48:28.332	2026-04-14 06:48:28.332
cmny9ftfo010cvxy48ykwthzu	cmny9ftb00100vxy4qghsouxb	cmny9fd980008vxy4alsawn4y	45000	2026-04-14 06:48:28.357	2026-04-14 06:48:28.357
cmny9ftgm010evxy4fc6p9u2v	cmny9ftb00100vxy4qghsouxb	cmny9fd9w0009vxy498vvvu1d	45000	2026-04-14 06:48:28.39	2026-04-14 06:48:28.39
cmny9ftha010gvxy4849gu3y1	cmny9ftb00100vxy4qghsouxb	cmny9fdb9000bvxy4h02fexen	48000	2026-04-14 06:48:28.414	2026-04-14 06:48:28.414
cmny9fthz010ivxy4d1kve6t7	cmny9ftb00100vxy4qghsouxb	cmny9fdc1000cvxy4n4y9ezu8	45000	2026-04-14 06:48:28.439	2026-04-14 06:48:28.439
cmny9ftim010kvxy4p3nd5jig	cmny9ftb00100vxy4qghsouxb	cmny9fdcn000dvxy4w3gaald5	45000	2026-04-14 06:48:28.462	2026-04-14 06:48:28.462
cmny9ftk0010nvxy4kuqbw4zw	cmny9ftjd010lvxy4kt9t230t	cmny9fd420001vxy42djthn1o	45000	2026-04-14 06:48:28.512	2026-04-14 06:48:28.512
cmny9ftkr010pvxy42bdsy5eg	cmny9ftjd010lvxy4kt9t230t	cmny9fd4t0002vxy4jo0l7gop	45000	2026-04-14 06:48:28.539	2026-04-14 06:48:28.539
cmny9ftld010rvxy4lrhk344r	cmny9ftjd010lvxy4kt9t230t	cmny9fd5j0003vxy4sw5e14p1	48000	2026-04-14 06:48:28.561	2026-04-14 06:48:28.561
cmny9ftm5010tvxy4t9zpjsqr	cmny9ftjd010lvxy4kt9t230t	cmny9fd6h0004vxy4evm3jgfv	45000	2026-04-14 06:48:28.589	2026-04-14 06:48:28.589
cmny9ftmu010vvxy4mlonojob	cmny9ftjd010lvxy4kt9t230t	cmny9fd7u0006vxy4mh4wwui4	37000	2026-04-14 06:48:28.614	2026-04-14 06:48:28.614
cmny9ftnl010xvxy4ltz92hmz	cmny9ftjd010lvxy4kt9t230t	cmny9fd980008vxy4alsawn4y	45000	2026-04-14 06:48:28.641	2026-04-14 06:48:28.641
cmny9ftog010zvxy4si52wyqg	cmny9ftjd010lvxy4kt9t230t	cmny9fd9w0009vxy498vvvu1d	45000	2026-04-14 06:48:28.672	2026-04-14 06:48:28.672
cmny9ftp60111vxy4jygqvvo0	cmny9ftjd010lvxy4kt9t230t	cmny9fdb9000bvxy4h02fexen	48000	2026-04-14 06:48:28.699	2026-04-14 06:48:28.699
cmny9ftpt0113vxy4dex1u4rp	cmny9ftjd010lvxy4kt9t230t	cmny9fdc1000cvxy4n4y9ezu8	45000	2026-04-14 06:48:28.722	2026-04-14 06:48:28.722
cmny9ftqj0115vxy4ptdpy61n	cmny9ftjd010lvxy4kt9t230t	cmny9fdcn000dvxy4w3gaald5	45000	2026-04-14 06:48:28.747	2026-04-14 06:48:28.747
cmny9ftrw0118vxy4sso07xgv	cmny9ftr70116vxy45hhskk83	cmny9fd420001vxy42djthn1o	45000	2026-04-14 06:48:28.797	2026-04-14 06:48:28.797
cmny9ftsm011avxy4cqejxl8k	cmny9ftr70116vxy45hhskk83	cmny9fd4t0002vxy4jo0l7gop	45000	2026-04-14 06:48:28.822	2026-04-14 06:48:28.822
cmny9fttk011cvxy4jyw00tx7	cmny9ftr70116vxy45hhskk83	cmny9fd5j0003vxy4sw5e14p1	48000	2026-04-14 06:48:28.856	2026-04-14 06:48:28.856
cmny9ftu7011evxy4jhd1e6sb	cmny9ftr70116vxy45hhskk83	cmny9fd6h0004vxy4evm3jgfv	45000	2026-04-14 06:48:28.879	2026-04-14 06:48:28.879
cmny9ftv0011gvxy4de9nmm58	cmny9ftr70116vxy45hhskk83	cmny9fd7u0006vxy4mh4wwui4	45000	2026-04-14 06:48:28.908	2026-04-14 06:48:28.908
cmny9ftvx011ivxy4ynkbqkgk	cmny9ftr70116vxy45hhskk83	cmny9fd980008vxy4alsawn4y	45000	2026-04-14 06:48:28.941	2026-04-14 06:48:28.941
cmny9ftws011kvxy4mkfani3u	cmny9ftr70116vxy45hhskk83	cmny9fd9w0009vxy498vvvu1d	45000	2026-04-14 06:48:28.972	2026-04-14 06:48:28.972
cmny9ftxi011mvxy4eergf2ak	cmny9ftr70116vxy45hhskk83	cmny9fdb9000bvxy4h02fexen	48000	2026-04-14 06:48:28.998	2026-04-14 06:48:28.998
cmny9ftye011ovxy4mjp1vddg	cmny9ftr70116vxy45hhskk83	cmny9fdc1000cvxy4n4y9ezu8	45000	2026-04-14 06:48:29.031	2026-04-14 06:48:29.031
cmny9ftz3011qvxy4hdmcika8	cmny9ftr70116vxy45hhskk83	cmny9fdcn000dvxy4w3gaald5	45000	2026-04-14 06:48:29.055	2026-04-14 06:48:29.055
cmny9fu0g011tvxy4h3do2dpi	cmny9ftzr011rvxy4w9olv9f4	cmny9fd420001vxy42djthn1o	45000	2026-04-14 06:48:29.105	2026-04-14 06:48:29.105
cmny9fu16011vvxy4bsr5oa54	cmny9ftzr011rvxy4w9olv9f4	cmny9fd4t0002vxy4jo0l7gop	45000	2026-04-14 06:48:29.13	2026-04-14 06:48:29.13
cmny9fu1v011xvxy4df74s36z	cmny9ftzr011rvxy4w9olv9f4	cmny9fd5j0003vxy4sw5e14p1	48000	2026-04-14 06:48:29.155	2026-04-14 06:48:29.155
cmny9fu2k011zvxy4h14bbbgu	cmny9ftzr011rvxy4w9olv9f4	cmny9fd6h0004vxy4evm3jgfv	37000	2026-04-14 06:48:29.18	2026-04-14 06:48:29.18
cmny9fu3b0121vxy49zzxzvnd	cmny9ftzr011rvxy4w9olv9f4	cmny9fd7u0006vxy4mh4wwui4	37000	2026-04-14 06:48:29.208	2026-04-14 06:48:29.208
cmny9fu490123vxy4hh5pfj26	cmny9ftzr011rvxy4w9olv9f4	cmny9fd980008vxy4alsawn4y	45000	2026-04-14 06:48:29.242	2026-04-14 06:48:29.242
cmny9fu540125vxy4nll16hyi	cmny9ftzr011rvxy4w9olv9f4	cmny9fd9w0009vxy498vvvu1d	45000	2026-04-14 06:48:29.272	2026-04-14 06:48:29.272
cmny9fu5u0127vxy4zqxmtli8	cmny9ftzr011rvxy4w9olv9f4	cmny9fdb9000bvxy4h02fexen	48000	2026-04-14 06:48:29.299	2026-04-14 06:48:29.299
cmny9fu6i0129vxy4otmrf7ft	cmny9ftzr011rvxy4w9olv9f4	cmny9fdc1000cvxy4n4y9ezu8	45000	2026-04-14 06:48:29.322	2026-04-14 06:48:29.322
cmny9fu78012bvxy45zb42yvj	cmny9ftzr011rvxy4w9olv9f4	cmny9fdcn000dvxy4w3gaald5	45000	2026-04-14 06:48:29.349	2026-04-14 06:48:29.349
cmny9fu8u012evxy4af6ixldg	cmny9fu7w012cvxy4zi9iflv9	cmny9fd420001vxy42djthn1o	45000	2026-04-14 06:48:29.406	2026-04-14 06:48:29.406
cmny9fu9g012gvxy4r3kaa47t	cmny9fu7w012cvxy4zi9iflv9	cmny9fd4t0002vxy4jo0l7gop	45000	2026-04-14 06:48:29.428	2026-04-14 06:48:29.428
cmny9fua8012ivxy422xvxoe0	cmny9fu7w012cvxy4zi9iflv9	cmny9fd5j0003vxy4sw5e14p1	48000	2026-04-14 06:48:29.456	2026-04-14 06:48:29.456
cmny9fuau012kvxy464x05isw	cmny9fu7w012cvxy4zi9iflv9	cmny9fd6h0004vxy4evm3jgfv	45000	2026-04-14 06:48:29.478	2026-04-14 06:48:29.478
cmny9fubo012mvxy4xe4xqzbs	cmny9fu7w012cvxy4zi9iflv9	cmny9fd7u0006vxy4mh4wwui4	37000	2026-04-14 06:48:29.508	2026-04-14 06:48:29.508
cmny9fucl012ovxy4vlhjrnsg	cmny9fu7w012cvxy4zi9iflv9	cmny9fd980008vxy4alsawn4y	45000	2026-04-14 06:48:29.541	2026-04-14 06:48:29.541
cmny9fudg012qvxy4wocxpmlp	cmny9fu7w012cvxy4zi9iflv9	cmny9fd9w0009vxy498vvvu1d	45000	2026-04-14 06:48:29.572	2026-04-14 06:48:29.572
cmny9fue5012svxy4lrr20ee6	cmny9fu7w012cvxy4zi9iflv9	cmny9fdb9000bvxy4h02fexen	48000	2026-04-14 06:48:29.598	2026-04-14 06:48:29.598
cmny9fuf2012uvxy4wvutrii6	cmny9fu7w012cvxy4zi9iflv9	cmny9fdc1000cvxy4n4y9ezu8	45000	2026-04-14 06:48:29.63	2026-04-14 06:48:29.63
cmny9fufs012wvxy4mnuwom9p	cmny9fu7w012cvxy4zi9iflv9	cmny9fdcn000dvxy4w3gaald5	45000	2026-04-14 06:48:29.656	2026-04-14 06:48:29.656
cmny9fuhc012zvxy4wahbu4gz	cmny9fugp012xvxy4ylplmb19	cmny9fd420001vxy42djthn1o	45000	2026-04-14 06:48:29.712	2026-04-14 06:48:29.712
cmny9fui30131vxy4n6dotu1t	cmny9fugp012xvxy4ylplmb19	cmny9fd4t0002vxy4jo0l7gop	45000	2026-04-14 06:48:29.74	2026-04-14 06:48:29.74
cmny9fuip0133vxy4mwq8lbp3	cmny9fugp012xvxy4ylplmb19	cmny9fd5j0003vxy4sw5e14p1	48000	2026-04-14 06:48:29.762	2026-04-14 06:48:29.762
cmny9fujh0135vxy4niqrc1o5	cmny9fugp012xvxy4ylplmb19	cmny9fd6h0004vxy4evm3jgfv	45000	2026-04-14 06:48:29.79	2026-04-14 06:48:29.79
cmny9fuk90137vxy4vr79sm3l	cmny9fugp012xvxy4ylplmb19	cmny9fd7u0006vxy4mh4wwui4	37000	2026-04-14 06:48:29.817	2026-04-14 06:48:29.817
cmny9fulh0139vxy40hu4mse8	cmny9fugp012xvxy4ylplmb19	cmny9fd980008vxy4alsawn4y	45000	2026-04-14 06:48:29.861	2026-04-14 06:48:29.861
cmny9fum9013bvxy43rrbqx0k	cmny9fugp012xvxy4ylplmb19	cmny9fd9w0009vxy498vvvu1d	45000	2026-04-14 06:48:29.889	2026-04-14 06:48:29.889
cmny9fumz013dvxy4tprx5rgd	cmny9fugp012xvxy4ylplmb19	cmny9fdb9000bvxy4h02fexen	48000	2026-04-14 06:48:29.915	2026-04-14 06:48:29.915
cmny9funn013fvxy4400skvbp	cmny9fugp012xvxy4ylplmb19	cmny9fdc1000cvxy4n4y9ezu8	45000	2026-04-14 06:48:29.94	2026-04-14 06:48:29.94
cmny9fuok013hvxy41g4mor5m	cmny9fugp012xvxy4ylplmb19	cmny9fdcn000dvxy4w3gaald5	45000	2026-04-14 06:48:29.972	2026-04-14 06:48:29.972
cmny9fupy013kvxy45qoo3wcr	cmny9fup7013ivxy4e7gw91lc	cmny9fd420001vxy42djthn1o	60000	2026-04-14 06:48:30.022	2026-04-14 06:48:30.022
cmny9fuqm013mvxy4rtzqjlga	cmny9fup7013ivxy4e7gw91lc	cmny9fd4t0002vxy4jo0l7gop	60000	2026-04-14 06:48:30.047	2026-04-14 06:48:30.047
cmny9furc013ovxy4ib8bqj9p	cmny9fup7013ivxy4e7gw91lc	cmny9fd5j0003vxy4sw5e14p1	63000	2026-04-14 06:48:30.072	2026-04-14 06:48:30.072
cmny9furz013qvxy42nnu6flr	cmny9fup7013ivxy4e7gw91lc	cmny9fd6h0004vxy4evm3jgfv	60000	2026-04-14 06:48:30.095	2026-04-14 06:48:30.095
cmny9futa013svxy4r32axbb2	cmny9fup7013ivxy4e7gw91lc	cmny9fd7u0006vxy4mh4wwui4	60000	2026-04-14 06:48:30.142	2026-04-14 06:48:30.142
cmny9fuu6013uvxy4s0ufjpbs	cmny9fup7013ivxy4e7gw91lc	cmny9fd980008vxy4alsawn4y	60000	2026-04-14 06:48:30.174	2026-04-14 06:48:30.174
cmny9fuv2013wvxy4mkotzeb0	cmny9fup7013ivxy4e7gw91lc	cmny9fd9w0009vxy498vvvu1d	60000	2026-04-14 06:48:30.206	2026-04-14 06:48:30.206
cmny9fuvq013yvxy4xlpdgpf6	cmny9fup7013ivxy4e7gw91lc	cmny9fdb9000bvxy4h02fexen	63000	2026-04-14 06:48:30.231	2026-04-14 06:48:30.231
cmny9fuwg0140vxy4t5lvgjzl	cmny9fup7013ivxy4e7gw91lc	cmny9fdc1000cvxy4n4y9ezu8	60000	2026-04-14 06:48:30.256	2026-04-14 06:48:30.256
cmny9fuxc0142vxy49ql61231	cmny9fup7013ivxy4e7gw91lc	cmny9fdcn000dvxy4w3gaald5	60000	2026-04-14 06:48:30.289	2026-04-14 06:48:30.289
cmny9fuzf0145vxy4noifcwry	cmny9fuy10143vxy47dj0lu72	cmny9fd420001vxy42djthn1o	60000	2026-04-14 06:48:30.363	2026-04-14 06:48:30.363
cmny9fv040147vxy4cab2j7oi	cmny9fuy10143vxy47dj0lu72	cmny9fd4t0002vxy4jo0l7gop	60000	2026-04-14 06:48:30.388	2026-04-14 06:48:30.388
cmny9fv120149vxy4e0lsrhmz	cmny9fuy10143vxy47dj0lu72	cmny9fd5j0003vxy4sw5e14p1	63000	2026-04-14 06:48:30.422	2026-04-14 06:48:30.422
cmny9fv1p014bvxy4unw8urhw	cmny9fuy10143vxy47dj0lu72	cmny9fd6h0004vxy4evm3jgfv	60000	2026-04-14 06:48:30.445	2026-04-14 06:48:30.445
cmny9fv2i014dvxy4p0vs76yl	cmny9fuy10143vxy47dj0lu72	cmny9fd7u0006vxy4mh4wwui4	43000	2026-04-14 06:48:30.474	2026-04-14 06:48:30.474
cmny9fv34014fvxy4fphthb2s	cmny9fuy10143vxy47dj0lu72	cmny9fd980008vxy4alsawn4y	60000	2026-04-14 06:48:30.497	2026-04-14 06:48:30.497
cmny9fv3v014hvxy4juhimfpa	cmny9fuy10143vxy47dj0lu72	cmny9fd9w0009vxy498vvvu1d	60000	2026-04-14 06:48:30.523	2026-04-14 06:48:30.523
cmny9fv5c014jvxy456208606	cmny9fuy10143vxy47dj0lu72	cmny9fdb9000bvxy4h02fexen	63000	2026-04-14 06:48:30.576	2026-04-14 06:48:30.576
cmny9fv65014lvxy4k25z2za1	cmny9fuy10143vxy47dj0lu72	cmny9fdc1000cvxy4n4y9ezu8	60000	2026-04-14 06:48:30.606	2026-04-14 06:48:30.606
cmny9fv6u014nvxy4nzz7hytz	cmny9fuy10143vxy47dj0lu72	cmny9fdcn000dvxy4w3gaald5	60000	2026-04-14 06:48:30.63	2026-04-14 06:48:30.63
cmny9fv8h014qvxy4rki2nzay	cmny9fv7j014ovxy48cyoctd3	cmny9fd420001vxy42djthn1o	65000	2026-04-14 06:48:30.689	2026-04-14 06:48:30.689
cmny9fv93014svxy4zyosa8z0	cmny9fv7j014ovxy48cyoctd3	cmny9fd4t0002vxy4jo0l7gop	65000	2026-04-14 06:48:30.712	2026-04-14 06:48:30.712
cmny9fv9v014uvxy499s867dl	cmny9fv7j014ovxy48cyoctd3	cmny9fd5j0003vxy4sw5e14p1	68000	2026-04-14 06:48:30.739	2026-04-14 06:48:30.739
cmny9fvb0014wvxy4xke6xzjm	cmny9fv7j014ovxy48cyoctd3	cmny9fd6h0004vxy4evm3jgfv	65000	2026-04-14 06:48:30.78	2026-04-14 06:48:30.78
cmny9fvbs014yvxy4grpbam5t	cmny9fv7j014ovxy48cyoctd3	cmny9fd7u0006vxy4mh4wwui4	60000	2026-04-14 06:48:30.808	2026-04-14 06:48:30.808
cmny9fvcq0150vxy4h9p1jzev	cmny9fv7j014ovxy48cyoctd3	cmny9fd980008vxy4alsawn4y	65000	2026-04-14 06:48:30.842	2026-04-14 06:48:30.842
cmny9fvdk0152vxy45uxowu0s	cmny9fv7j014ovxy48cyoctd3	cmny9fd9w0009vxy498vvvu1d	65000	2026-04-14 06:48:30.872	2026-04-14 06:48:30.872
cmny9fveb0154vxy4filk3poq	cmny9fv7j014ovxy48cyoctd3	cmny9fdb9000bvxy4h02fexen	68000	2026-04-14 06:48:30.899	2026-04-14 06:48:30.899
cmny9fvf30156vxy460xbgdl9	cmny9fv7j014ovxy48cyoctd3	cmny9fdc1000cvxy4n4y9ezu8	65000	2026-04-14 06:48:30.928	2026-04-14 06:48:30.928
cmny9fvfz0158vxy4fv92p6mv	cmny9fv7j014ovxy48cyoctd3	cmny9fdcn000dvxy4w3gaald5	65000	2026-04-14 06:48:30.96	2026-04-14 06:48:30.96
cmny9fvhi015bvxy402i5ts5i	cmny9fvgt0159vxy4rphmrzbz	cmny9fd420001vxy42djthn1o	70000	2026-04-14 06:48:31.014	2026-04-14 06:48:31.014
cmny9fvid015dvxy4myejquuf	cmny9fvgt0159vxy4rphmrzbz	cmny9fd4t0002vxy4jo0l7gop	70000	2026-04-14 06:48:31.046	2026-04-14 06:48:31.046
cmny9fvj4015fvxy4b1qs8jof	cmny9fvgt0159vxy4rphmrzbz	cmny9fd5j0003vxy4sw5e14p1	70000	2026-04-14 06:48:31.073	2026-04-14 06:48:31.073
cmny9fvjq015hvxy4ad1pm2lq	cmny9fvgt0159vxy4rphmrzbz	cmny9fd6h0004vxy4evm3jgfv	70000	2026-04-14 06:48:31.095	2026-04-14 06:48:31.095
cmny9fvkk015jvxy4t9vcegox	cmny9fvgt0159vxy4rphmrzbz	cmny9fd7u0006vxy4mh4wwui4	70000	2026-04-14 06:48:31.124	2026-04-14 06:48:31.124
cmny9fvl5015lvxy4gp3r5023	cmny9fvgt0159vxy4rphmrzbz	cmny9fd8i0007vxy4tmc0glr0	70000	2026-04-14 06:48:31.146	2026-04-14 06:48:31.146
cmny9fvlw015nvxy4vh9kdygb	cmny9fvgt0159vxy4rphmrzbz	cmny9fd980008vxy4alsawn4y	70000	2026-04-14 06:48:31.173	2026-04-14 06:48:31.173
cmny9fvmj015pvxy4s6jgb8wz	cmny9fvgt0159vxy4rphmrzbz	cmny9fd9w0009vxy498vvvu1d	70000	2026-04-14 06:48:31.196	2026-04-14 06:48:31.196
cmny9fvna015rvxy4tcx3jjht	cmny9fvgt0159vxy4rphmrzbz	cmny9fdam000avxy4a12zuxjj	52000	2026-04-14 06:48:31.222	2026-04-14 06:48:31.222
cmny9fvoe015tvxy4qvxk2vhi	cmny9fvgt0159vxy4rphmrzbz	cmny9fdb9000bvxy4h02fexen	70000	2026-04-14 06:48:31.262	2026-04-14 06:48:31.262
cmny9fvp5015vvxy4vwdyv7na	cmny9fvgt0159vxy4rphmrzbz	cmny9fdc1000cvxy4n4y9ezu8	70000	2026-04-14 06:48:31.289	2026-04-14 06:48:31.289
cmny9fvpr015xvxy4w69yt571	cmny9fvgt0159vxy4rphmrzbz	cmny9fdcn000dvxy4w3gaald5	70000	2026-04-14 06:48:31.312	2026-04-14 06:48:31.312
cmny9fvr50160vxy4k9exsq2b	cmny9fvqj015yvxy460fkju0e	cmny9fd420001vxy42djthn1o	70000	2026-04-14 06:48:31.361	2026-04-14 06:48:31.361
cmny9fvrx0162vxy4kss7snr5	cmny9fvqj015yvxy460fkju0e	cmny9fd4t0002vxy4jo0l7gop	70000	2026-04-14 06:48:31.39	2026-04-14 06:48:31.39
cmny9fvsj0164vxy4ltfotgus	cmny9fvqj015yvxy460fkju0e	cmny9fd5j0003vxy4sw5e14p1	70000	2026-04-14 06:48:31.411	2026-04-14 06:48:31.411
cmny9fvtd0166vxy4sfx79y9k	cmny9fvqj015yvxy460fkju0e	cmny9fd6h0004vxy4evm3jgfv	70000	2026-04-14 06:48:31.441	2026-04-14 06:48:31.441
cmny9fvuh0168vxy4hxyt4y3f	cmny9fvqj015yvxy460fkju0e	cmny9fd7u0006vxy4mh4wwui4	70000	2026-04-14 06:48:31.481	2026-04-14 06:48:31.481
cmny9fvv6016avxy425phqsa8	cmny9fvqj015yvxy460fkju0e	cmny9fd8i0007vxy4tmc0glr0	70000	2026-04-14 06:48:31.506	2026-04-14 06:48:31.506
cmny9fvvs016cvxy4xi3jhkn5	cmny9fvqj015yvxy460fkju0e	cmny9fd980008vxy4alsawn4y	70000	2026-04-14 06:48:31.528	2026-04-14 06:48:31.528
cmny9fvwr016evxy4mzptjmzn	cmny9fvqj015yvxy460fkju0e	cmny9fd9w0009vxy498vvvu1d	70000	2026-04-14 06:48:31.564	2026-04-14 06:48:31.564
cmny9fvy5016gvxy4gnj0a2py	cmny9fvqj015yvxy460fkju0e	cmny9fdam000avxy4a12zuxjj	52000	2026-04-14 06:48:31.614	2026-04-14 06:48:31.614
cmny9fvyu016ivxy4nqgn7fvw	cmny9fvqj015yvxy460fkju0e	cmny9fdb9000bvxy4h02fexen	70000	2026-04-14 06:48:31.638	2026-04-14 06:48:31.638
cmny9fvzk016kvxy4zvr7n9pq	cmny9fvqj015yvxy460fkju0e	cmny9fdc1000cvxy4n4y9ezu8	70000	2026-04-14 06:48:31.664	2026-04-14 06:48:31.664
cmny9fw0q016mvxy4jnp3mut2	cmny9fvqj015yvxy460fkju0e	cmny9fdcn000dvxy4w3gaald5	70000	2026-04-14 06:48:31.706	2026-04-14 06:48:31.706
cmny9fw29016pvxy4mo3i87yk	cmny9fw1n016nvxy4iimihogl	cmny9fd420001vxy42djthn1o	52000	2026-04-14 06:48:31.761	2026-04-14 06:48:31.761
cmny9fw31016rvxy4vyi3azwc	cmny9fw1n016nvxy4iimihogl	cmny9fd4t0002vxy4jo0l7gop	52000	2026-04-14 06:48:31.79	2026-04-14 06:48:31.79
cmny9fw3n016tvxy4rqtlrdyr	cmny9fw1n016nvxy4iimihogl	cmny9fd5j0003vxy4sw5e14p1	52000	2026-04-14 06:48:31.812	2026-04-14 06:48:31.812
cmny9fw4i016vvxy4vfd6rbuh	cmny9fw1n016nvxy4iimihogl	cmny9fd7u0006vxy4mh4wwui4	52000	2026-04-14 06:48:31.842	2026-04-14 06:48:31.842
cmny9fw5c016xvxy4owozgk4a	cmny9fw1n016nvxy4iimihogl	cmny9fd8i0007vxy4tmc0glr0	52000	2026-04-14 06:48:31.872	2026-04-14 06:48:31.872
cmny9fw6g016zvxy47j2nacz0	cmny9fw1n016nvxy4iimihogl	cmny9fd980008vxy4alsawn4y	52000	2026-04-14 06:48:31.912	2026-04-14 06:48:31.912
cmny9fw770171vxy497uanhgv	cmny9fw1n016nvxy4iimihogl	cmny9fd9w0009vxy498vvvu1d	42000	2026-04-14 06:48:31.94	2026-04-14 06:48:31.94
cmny9fw7u0173vxy4obetwjym	cmny9fw1n016nvxy4iimihogl	cmny9fdam000avxy4a12zuxjj	49000	2026-04-14 06:48:31.962	2026-04-14 06:48:31.962
cmny9fw8m0175vxy4f6azqntu	cmny9fw1n016nvxy4iimihogl	cmny9fdb9000bvxy4h02fexen	52000	2026-04-14 06:48:31.99	2026-04-14 06:48:31.99
cmny9fw980177vxy4am5sgsjl	cmny9fw1n016nvxy4iimihogl	cmny9fdc1000cvxy4n4y9ezu8	52000	2026-04-14 06:48:32.012	2026-04-14 06:48:32.012
cmny9fwa00179vxy4eh3sow7u	cmny9fw1n016nvxy4iimihogl	cmny9fdcn000dvxy4w3gaald5	52000	2026-04-14 06:48:32.04	2026-04-14 06:48:32.04
cmny9fwbk017cvxy4g1fdw98t	cmny9fwaw017avxy42qv21y88	cmny9fd420001vxy42djthn1o	52000	2026-04-14 06:48:32.097	2026-04-14 06:48:32.097
cmny9fwcb017evxy4t5ho5rr8	cmny9fwaw017avxy42qv21y88	cmny9fd4t0002vxy4jo0l7gop	52000	2026-04-14 06:48:32.123	2026-04-14 06:48:32.123
cmny9fwda017gvxy4sxq7eeic	cmny9fwaw017avxy42qv21y88	cmny9fd5j0003vxy4sw5e14p1	52000	2026-04-14 06:48:32.158	2026-04-14 06:48:32.158
cmny9fwdx017ivxy4529dty5l	cmny9fwaw017avxy42qv21y88	cmny9fd7u0006vxy4mh4wwui4	52000	2026-04-14 06:48:32.181	2026-04-14 06:48:32.181
cmny9fwel017kvxy4dusov8z9	cmny9fwaw017avxy42qv21y88	cmny9fd8i0007vxy4tmc0glr0	52000	2026-04-14 06:48:32.205	2026-04-14 06:48:32.205
cmny9fwf8017mvxy4xwekbyo7	cmny9fwaw017avxy42qv21y88	cmny9fd980008vxy4alsawn4y	52000	2026-04-14 06:48:32.228	2026-04-14 06:48:32.228
cmny9fwg0017ovxy4qfan58re	cmny9fwaw017avxy42qv21y88	cmny9fd9w0009vxy498vvvu1d	42000	2026-04-14 06:48:32.256	2026-04-14 06:48:32.256
cmny9fwgm017qvxy4iesoe95h	cmny9fwaw017avxy42qv21y88	cmny9fdam000avxy4a12zuxjj	49000	2026-04-14 06:48:32.278	2026-04-14 06:48:32.278
cmny9fwhd017svxy4tedvblbc	cmny9fwaw017avxy42qv21y88	cmny9fdb9000bvxy4h02fexen	52000	2026-04-14 06:48:32.306	2026-04-14 06:48:32.306
cmny9fwi1017uvxy4wc60fmnm	cmny9fwaw017avxy42qv21y88	cmny9fdc1000cvxy4n4y9ezu8	52000	2026-04-14 06:48:32.329	2026-04-14 06:48:32.329
cmny9fwir017wvxy4a1jxlr9s	cmny9fwaw017avxy42qv21y88	cmny9fdcn000dvxy4w3gaald5	52000	2026-04-14 06:48:32.355	2026-04-14 06:48:32.355
cmny9fwk5017zvxy4uo4su0ff	cmny9fwje017xvxy40qg5xlot	cmny9fd420001vxy42djthn1o	52000	2026-04-14 06:48:32.406	2026-04-14 06:48:32.406
cmny9fwks0181vxy4n04rzhhn	cmny9fwje017xvxy40qg5xlot	cmny9fd4t0002vxy4jo0l7gop	52000	2026-04-14 06:48:32.429	2026-04-14 06:48:32.429
cmny9fwlk0183vxy48wpyn1pe	cmny9fwje017xvxy40qg5xlot	cmny9fd5j0003vxy4sw5e14p1	52000	2026-04-14 06:48:32.456	2026-04-14 06:48:32.456
cmny9fwom0185vxy4f2joqjhr	cmny9fwje017xvxy40qg5xlot	cmny9fd6h0004vxy4evm3jgfv	45000	2026-04-14 06:48:32.566	2026-04-14 06:48:32.566
cmny9fwpw0187vxy4yj8l8q5f	cmny9fwje017xvxy40qg5xlot	cmny9fd7u0006vxy4mh4wwui4	52000	2026-04-14 06:48:32.612	2026-04-14 06:48:32.612
cmny9fwqn0189vxy4gu9b2q2g	cmny9fwje017xvxy40qg5xlot	cmny9fd8i0007vxy4tmc0glr0	52000	2026-04-14 06:48:32.639	2026-04-14 06:48:32.639
cmny9fwra018bvxy4pqrx9xno	cmny9fwje017xvxy40qg5xlot	cmny9fd980008vxy4alsawn4y	52000	2026-04-14 06:48:32.662	2026-04-14 06:48:32.662
cmny9fws1018dvxy4dhv8brd9	cmny9fwje017xvxy40qg5xlot	cmny9fd9w0009vxy498vvvu1d	42000	2026-04-14 06:48:32.689	2026-04-14 06:48:32.689
cmny9fwsn018fvxy4qbey4kdr	cmny9fwje017xvxy40qg5xlot	cmny9fdam000avxy4a12zuxjj	49000	2026-04-14 06:48:32.711	2026-04-14 06:48:32.711
cmny9fwtf018hvxy49q786taq	cmny9fwje017xvxy40qg5xlot	cmny9fdb9000bvxy4h02fexen	52000	2026-04-14 06:48:32.739	2026-04-14 06:48:32.739
cmny9fwu1018jvxy4xhisjvno	cmny9fwje017xvxy40qg5xlot	cmny9fdc1000cvxy4n4y9ezu8	52000	2026-04-14 06:48:32.761	2026-04-14 06:48:32.761
cmny9fwut018lvxy4udz2jftl	cmny9fwje017xvxy40qg5xlot	cmny9fdcn000dvxy4w3gaald5	52000	2026-04-14 06:48:32.789	2026-04-14 06:48:32.789
cmny9fwwf018ovxy4pk3l865h	cmny9fwvq018mvxy4q31zbav3	cmny9fd420001vxy42djthn1o	47000	2026-04-14 06:48:32.847	2026-04-14 06:48:32.847
cmny9fwx4018qvxy434ml0bnd	cmny9fwvq018mvxy4q31zbav3	cmny9fd4t0002vxy4jo0l7gop	47000	2026-04-14 06:48:32.872	2026-04-14 06:48:32.872
cmny9fwxt018svxy4jy2noh1j	cmny9fwvq018mvxy4q31zbav3	cmny9fd5j0003vxy4sw5e14p1	47000	2026-04-14 06:48:32.897	2026-04-14 06:48:32.897
cmny9fwyi018uvxy4zy6yzqkw	cmny9fwvq018mvxy4q31zbav3	cmny9fd6h0004vxy4evm3jgfv	47000	2026-04-14 06:48:32.922	2026-04-14 06:48:32.922
cmny9fwz9018wvxy41fkrszaw	cmny9fwvq018mvxy4q31zbav3	cmny9fd7u0006vxy4mh4wwui4	47000	2026-04-14 06:48:32.949	2026-04-14 06:48:32.949
cmny9fwzw018yvxy4fbxvui73	cmny9fwvq018mvxy4q31zbav3	cmny9fd8i0007vxy4tmc0glr0	47000	2026-04-14 06:48:32.972	2026-04-14 06:48:32.972
cmny9fx0l0190vxy4ctzmwlxw	cmny9fwvq018mvxy4q31zbav3	cmny9fd980008vxy4alsawn4y	47000	2026-04-14 06:48:32.997	2026-04-14 06:48:32.997
cmny9fx1g0192vxy4mpwkjatl	cmny9fwvq018mvxy4q31zbav3	cmny9fd9w0009vxy498vvvu1d	40000	2026-04-14 06:48:33.028	2026-04-14 06:48:33.028
cmny9fx2a0194vxy4jw7tcom9	cmny9fwvq018mvxy4q31zbav3	cmny9fdb9000bvxy4h02fexen	47000	2026-04-14 06:48:33.059	2026-04-14 06:48:33.059
cmny9fx360196vxy40g9lzsk0	cmny9fwvq018mvxy4q31zbav3	cmny9fdc1000cvxy4n4y9ezu8	47000	2026-04-14 06:48:33.09	2026-04-14 06:48:33.09
cmny9fx420198vxy4fc132w6t	cmny9fwvq018mvxy4q31zbav3	cmny9fdcn000dvxy4w3gaald5	47000	2026-04-14 06:48:33.123	2026-04-14 06:48:33.123
cmny9fx5g019bvxy4da9bzbv9	cmny9fx4p0199vxy4ywsj53mv	cmny9fd420001vxy42djthn1o	47000	2026-04-14 06:48:33.173	2026-04-14 06:48:33.173
cmny9fx63019dvxy40uj6d76e	cmny9fx4p0199vxy4ywsj53mv	cmny9fd4t0002vxy4jo0l7gop	47000	2026-04-14 06:48:33.195	2026-04-14 06:48:33.195
cmny9fx6v019fvxy4u55c43as	cmny9fx4p0199vxy4ywsj53mv	cmny9fd5j0003vxy4sw5e14p1	47000	2026-04-14 06:48:33.223	2026-04-14 06:48:33.223
cmny9fx7r019hvxy4bv8g55ik	cmny9fx4p0199vxy4ywsj53mv	cmny9fd6h0004vxy4evm3jgfv	47000	2026-04-14 06:48:33.255	2026-04-14 06:48:33.255
cmny9fx8i019jvxy4h28kum5p	cmny9fx4p0199vxy4ywsj53mv	cmny9fd7u0006vxy4mh4wwui4	47000	2026-04-14 06:48:33.283	2026-04-14 06:48:33.283
cmny9fx94019lvxy4qm0pt4rb	cmny9fx4p0199vxy4ywsj53mv	cmny9fd8i0007vxy4tmc0glr0	47000	2026-04-14 06:48:33.304	2026-04-14 06:48:33.304
cmny9fx9u019nvxy46ad09bqw	cmny9fx4p0199vxy4ywsj53mv	cmny9fd980008vxy4alsawn4y	47000	2026-04-14 06:48:33.331	2026-04-14 06:48:33.331
cmny9fxaj019pvxy4tjud38qm	cmny9fx4p0199vxy4ywsj53mv	cmny9fd9w0009vxy498vvvu1d	40000	2026-04-14 06:48:33.355	2026-04-14 06:48:33.355
cmny9fxba019rvxy45dum7ds7	cmny9fx4p0199vxy4ywsj53mv	cmny9fdb9000bvxy4h02fexen	47000	2026-04-14 06:48:33.383	2026-04-14 06:48:33.383
cmny9fxbx019tvxy4eeboiy0v	cmny9fx4p0199vxy4ywsj53mv	cmny9fdc1000cvxy4n4y9ezu8	47000	2026-04-14 06:48:33.405	2026-04-14 06:48:33.405
cmny9fxcn019vvxy4axel6twu	cmny9fx4p0199vxy4ywsj53mv	cmny9fdcn000dvxy4w3gaald5	47000	2026-04-14 06:48:33.431	2026-04-14 06:48:33.431
cmny9fxe9019yvxy4phsx9bra	cmny9fxdi019wvxy4ny5svmh2	cmny9fd420001vxy42djthn1o	47000	2026-04-14 06:48:33.489	2026-04-14 06:48:33.489
cmny9fxex01a0vxy44ulcizvf	cmny9fxdi019wvxy4ny5svmh2	cmny9fd4t0002vxy4jo0l7gop	47000	2026-04-14 06:48:33.513	2026-04-14 06:48:33.513
cmny9fxfn01a2vxy4j3t6ust8	cmny9fxdi019wvxy4ny5svmh2	cmny9fd5j0003vxy4sw5e14p1	47000	2026-04-14 06:48:33.539	2026-04-14 06:48:33.539
cmny9fxg901a4vxy4fv5ylqz2	cmny9fxdi019wvxy4ny5svmh2	cmny9fd6h0004vxy4evm3jgfv	47000	2026-04-14 06:48:33.561	2026-04-14 06:48:33.561
cmny9fxh301a6vxy4recnp1vm	cmny9fxdi019wvxy4ny5svmh2	cmny9fd7u0006vxy4mh4wwui4	47000	2026-04-14 06:48:33.591	2026-04-14 06:48:33.591
cmny9fxhy01a8vxy4d2p9us0q	cmny9fxdi019wvxy4ny5svmh2	cmny9fd8i0007vxy4tmc0glr0	47000	2026-04-14 06:48:33.622	2026-04-14 06:48:33.622
cmny9fxin01aavxy4qrvo24o9	cmny9fxdi019wvxy4ny5svmh2	cmny9fd980008vxy4alsawn4y	47000	2026-04-14 06:48:33.647	2026-04-14 06:48:33.647
cmny9fxjc01acvxy4kq9axd0f	cmny9fxdi019wvxy4ny5svmh2	cmny9fd9w0009vxy498vvvu1d	40000	2026-04-14 06:48:33.672	2026-04-14 06:48:33.672
cmny9fxk301aevxy429m5u8nl	cmny9fxdi019wvxy4ny5svmh2	cmny9fdb9000bvxy4h02fexen	47000	2026-04-14 06:48:33.699	2026-04-14 06:48:33.699
cmny9fxkq01agvxy4v2ed8le9	cmny9fxdi019wvxy4ny5svmh2	cmny9fdc1000cvxy4n4y9ezu8	47000	2026-04-14 06:48:33.722	2026-04-14 06:48:33.722
cmny9fxlo01aivxy4dyb04ysv	cmny9fxdi019wvxy4ny5svmh2	cmny9fdcn000dvxy4w3gaald5	47000	2026-04-14 06:48:33.756	2026-04-14 06:48:33.756
cmny9fxn201alvxy4kkgqns1h	cmny9fxma01ajvxy4dohbtfpp	cmny9fd420001vxy42djthn1o	44000	2026-04-14 06:48:33.806	2026-04-14 06:48:33.806
cmny9fxnr01anvxy4p5j8k2xf	cmny9fxma01ajvxy4dohbtfpp	cmny9fd4t0002vxy4jo0l7gop	44000	2026-04-14 06:48:33.831	2026-04-14 06:48:33.831
cmny9fxog01apvxy4tevvbo2t	cmny9fxma01ajvxy4dohbtfpp	cmny9fd5j0003vxy4sw5e14p1	44000	2026-04-14 06:48:33.856	2026-04-14 06:48:33.856
cmny9fxp201arvxy4mg59h9n6	cmny9fxma01ajvxy4dohbtfpp	cmny9fd6h0004vxy4evm3jgfv	44000	2026-04-14 06:48:33.879	2026-04-14 06:48:33.879
cmny9fxpw01atvxy4jxsj1yjo	cmny9fxma01ajvxy4dohbtfpp	cmny9fd7u0006vxy4mh4wwui4	44000	2026-04-14 06:48:33.908	2026-04-14 06:48:33.908
cmny9fxqq01avvxy4j3v4f2vt	cmny9fxma01ajvxy4dohbtfpp	cmny9fd8i0007vxy4tmc0glr0	44000	2026-04-14 06:48:33.938	2026-04-14 06:48:33.938
cmny9fxrf01axvxy4h4i1o95c	cmny9fxma01ajvxy4dohbtfpp	cmny9fd980008vxy4alsawn4y	44000	2026-04-14 06:48:33.964	2026-04-14 06:48:33.964
cmny9fxs301azvxy4qbyihp6s	cmny9fxma01ajvxy4dohbtfpp	cmny9fd9w0009vxy498vvvu1d	40000	2026-04-14 06:48:33.988	2026-04-14 06:48:33.988
cmny9fxsv01b1vxy4ohllpctz	cmny9fxma01ajvxy4dohbtfpp	cmny9fdb9000bvxy4h02fexen	44000	2026-04-14 06:48:34.015	2026-04-14 06:48:34.015
cmny9fxtj01b3vxy4tdlbiofc	cmny9fxma01ajvxy4dohbtfpp	cmny9fdc1000cvxy4n4y9ezu8	44000	2026-04-14 06:48:34.039	2026-04-14 06:48:34.039
cmny9fxug01b5vxy4eqddwb9q	cmny9fxma01ajvxy4dohbtfpp	cmny9fdcn000dvxy4w3gaald5	44000	2026-04-14 06:48:34.073	2026-04-14 06:48:34.073
cmny9fxvu01b8vxy46hlr86k7	cmny9fxv201b6vxy4ua3rt4qb	cmny9fd420001vxy42djthn1o	44000	2026-04-14 06:48:34.123	2026-04-14 06:48:34.123
cmny9fxwh01bavxy40g9mfg0w	cmny9fxv201b6vxy4ua3rt4qb	cmny9fd4t0002vxy4jo0l7gop	44000	2026-04-14 06:48:34.145	2026-04-14 06:48:34.145
cmny9fxx801bcvxy4vvcy5z7f	cmny9fxv201b6vxy4ua3rt4qb	cmny9fd5j0003vxy4sw5e14p1	44000	2026-04-14 06:48:34.173	2026-04-14 06:48:34.173
cmny9fxxv01bevxy4hyxxeqwo	cmny9fxv201b6vxy4ua3rt4qb	cmny9fd6h0004vxy4evm3jgfv	44000	2026-04-14 06:48:34.195	2026-04-14 06:48:34.195
cmny9fxyp01bgvxy4fkou3553	cmny9fxv201b6vxy4ua3rt4qb	cmny9fd7u0006vxy4mh4wwui4	44000	2026-04-14 06:48:34.226	2026-04-14 06:48:34.226
cmny9fxzk01bivxy4wd38bgfp	cmny9fxv201b6vxy4ua3rt4qb	cmny9fd8i0007vxy4tmc0glr0	44000	2026-04-14 06:48:34.256	2026-04-14 06:48:34.256
cmny9fy0o01bkvxy4l1cwdvfm	cmny9fxv201b6vxy4ua3rt4qb	cmny9fd980008vxy4alsawn4y	44000	2026-04-14 06:48:34.297	2026-04-14 06:48:34.297
cmny9fy1d01bmvxy462mfstvi	cmny9fxv201b6vxy4ua3rt4qb	cmny9fd9w0009vxy498vvvu1d	40000	2026-04-14 06:48:34.322	2026-04-14 06:48:34.322
cmny9fy2701bovxy47xsmucwk	cmny9fxv201b6vxy4ua3rt4qb	cmny9fdb9000bvxy4h02fexen	44000	2026-04-14 06:48:34.351	2026-04-14 06:48:34.351
cmny9fy2y01bqvxy4gsn2k9yi	cmny9fxv201b6vxy4ua3rt4qb	cmny9fdc1000cvxy4n4y9ezu8	44000	2026-04-14 06:48:34.379	2026-04-14 06:48:34.379
cmny9fy3q01bsvxy4z6p6gxe4	cmny9fxv201b6vxy4ua3rt4qb	cmny9fdcn000dvxy4w3gaald5	44000	2026-04-14 06:48:34.406	2026-04-14 06:48:34.406
cmny9fy5401bvvxy417ck5p5c	cmny9fy4c01btvxy40j63xyny	cmny9fd420001vxy42djthn1o	44000	2026-04-14 06:48:34.456	2026-04-14 06:48:34.456
cmny9fy5r01bxvxy41fk9qsxe	cmny9fy4c01btvxy40j63xyny	cmny9fd4t0002vxy4jo0l7gop	44000	2026-04-14 06:48:34.479	2026-04-14 06:48:34.479
cmny9fy6i01bzvxy41yqaxu4n	cmny9fy4c01btvxy40j63xyny	cmny9fd5j0003vxy4sw5e14p1	44000	2026-04-14 06:48:34.507	2026-04-14 06:48:34.507
cmny9fy7401c1vxy4qjralxym	cmny9fy4c01btvxy40j63xyny	cmny9fd6h0004vxy4evm3jgfv	44000	2026-04-14 06:48:34.529	2026-04-14 06:48:34.529
cmny9fy7x01c3vxy4lwtpaumb	cmny9fy4c01btvxy40j63xyny	cmny9fd7u0006vxy4mh4wwui4	44000	2026-04-14 06:48:34.558	2026-04-14 06:48:34.558
cmny9fy8i01c5vxy4piyxiynl	cmny9fy4c01btvxy40j63xyny	cmny9fd8i0007vxy4tmc0glr0	44000	2026-04-14 06:48:34.578	2026-04-14 06:48:34.578
cmny9fy9a01c7vxy44ywtbyhf	cmny9fy4c01btvxy40j63xyny	cmny9fd980008vxy4alsawn4y	44000	2026-04-14 06:48:34.606	2026-04-14 06:48:34.606
cmny9fy9w01c9vxy4hjv07cgw	cmny9fy4c01btvxy40j63xyny	cmny9fd9w0009vxy498vvvu1d	40000	2026-04-14 06:48:34.629	2026-04-14 06:48:34.629
cmny9fyaq01cbvxy4hmlhq05q	cmny9fy4c01btvxy40j63xyny	cmny9fdb9000bvxy4h02fexen	44000	2026-04-14 06:48:34.658	2026-04-14 06:48:34.658
cmny9fybc01cdvxy4474jtwlf	cmny9fy4c01btvxy40j63xyny	cmny9fdc1000cvxy4n4y9ezu8	44000	2026-04-14 06:48:34.68	2026-04-14 06:48:34.68
cmny9fyc201cfvxy4edqwqyaz	cmny9fy4c01btvxy40j63xyny	cmny9fdcn000dvxy4w3gaald5	44000	2026-04-14 06:48:34.706	2026-04-14 06:48:34.706
cmny9fydw01civxy4aemtv0yu	cmny9fyco01cgvxy4zadxb4a4	cmny9fd420001vxy42djthn1o	46000	2026-04-14 06:48:34.772	2026-04-14 06:48:34.772
cmny9fyel01ckvxy44aipeots	cmny9fyco01cgvxy4zadxb4a4	cmny9fd4t0002vxy4jo0l7gop	40000	2026-04-14 06:48:34.797	2026-04-14 06:48:34.797
cmny9fyfa01cmvxy4ps01ag5w	cmny9fyco01cgvxy4zadxb4a4	cmny9fd5j0003vxy4sw5e14p1	46000	2026-04-14 06:48:34.822	2026-04-14 06:48:34.822
cmny9fyg801covxy4rq9j1hue	cmny9fyco01cgvxy4zadxb4a4	cmny9fd6h0004vxy4evm3jgfv	46000	2026-04-14 06:48:34.857	2026-04-14 06:48:34.857
cmny9fygw01cqvxy44ru8e81x	cmny9fyco01cgvxy4zadxb4a4	cmny9fd7u0006vxy4mh4wwui4	46000	2026-04-14 06:48:34.881	2026-04-14 06:48:34.881
cmny9fyhl01csvxy4gm3nbsdg	cmny9fyco01cgvxy4zadxb4a4	cmny9fd8i0007vxy4tmc0glr0	46000	2026-04-14 06:48:34.905	2026-04-14 06:48:34.905
cmny9fyi901cuvxy47ptg4ix1	cmny9fyco01cgvxy4zadxb4a4	cmny9fd980008vxy4alsawn4y	46000	2026-04-14 06:48:34.929	2026-04-14 06:48:34.929
cmny9fyjg01cwvxy4ydz6mh4k	cmny9fyco01cgvxy4zadxb4a4	cmny9fd9w0009vxy498vvvu1d	40000	2026-04-14 06:48:34.972	2026-04-14 06:48:34.972
cmny9fyk701cyvxy4rddr34er	cmny9fyco01cgvxy4zadxb4a4	cmny9fdb9000bvxy4h02fexen	46000	2026-04-14 06:48:34.999	2026-04-14 06:48:34.999
cmny9fyku01d0vxy4fokivkvf	cmny9fyco01cgvxy4zadxb4a4	cmny9fdc1000cvxy4n4y9ezu8	46000	2026-04-14 06:48:35.022	2026-04-14 06:48:35.022
cmny9fym001d2vxy4ni0ea1o4	cmny9fyco01cgvxy4zadxb4a4	cmny9fdcn000dvxy4w3gaald5	46000	2026-04-14 06:48:35.064	2026-04-14 06:48:35.064
cmny9fyne01d5vxy43vecpd6p	cmny9fymo01d3vxy42wo51s0r	cmny9fd420001vxy42djthn1o	46000	2026-04-14 06:48:35.114	2026-04-14 06:48:35.114
cmny9fyo201d7vxy4gtik5g45	cmny9fymo01d3vxy42wo51s0r	cmny9fd4t0002vxy4jo0l7gop	40000	2026-04-14 06:48:35.138	2026-04-14 06:48:35.138
cmny9fyp701d9vxy4h268h7ao	cmny9fymo01d3vxy42wo51s0r	cmny9fd5j0003vxy4sw5e14p1	46000	2026-04-14 06:48:35.179	2026-04-14 06:48:35.179
cmny9fypy01dbvxy4sbfpvz7d	cmny9fymo01d3vxy42wo51s0r	cmny9fd6h0004vxy4evm3jgfv	46000	2026-04-14 06:48:35.206	2026-04-14 06:48:35.206
cmny9fyqn01ddvxy4h1hv3nhq	cmny9fymo01d3vxy42wo51s0r	cmny9fd7u0006vxy4mh4wwui4	46000	2026-04-14 06:48:35.231	2026-04-14 06:48:35.231
cmny9fyrc01dfvxy4hjfc9pnr	cmny9fymo01d3vxy42wo51s0r	cmny9fd8i0007vxy4tmc0glr0	46000	2026-04-14 06:48:35.256	2026-04-14 06:48:35.256
cmny9fyrz01dhvxy4flktrax0	cmny9fymo01d3vxy42wo51s0r	cmny9fd980008vxy4alsawn4y	46000	2026-04-14 06:48:35.279	2026-04-14 06:48:35.279
cmny9fysr01djvxy4tu9t9v5j	cmny9fymo01d3vxy42wo51s0r	cmny9fd9w0009vxy498vvvu1d	40000	2026-04-14 06:48:35.307	2026-04-14 06:48:35.307
cmny9fyto01dlvxy4wbxjbxuj	cmny9fymo01d3vxy42wo51s0r	cmny9fdb9000bvxy4h02fexen	46000	2026-04-14 06:48:35.34	2026-04-14 06:48:35.34
cmny9fyur01dnvxy47bo13flz	cmny9fymo01d3vxy42wo51s0r	cmny9fdc1000cvxy4n4y9ezu8	46000	2026-04-14 06:48:35.379	2026-04-14 06:48:35.379
cmny9fyvq01dpvxy4r1ndy07b	cmny9fymo01d3vxy42wo51s0r	cmny9fdcn000dvxy4w3gaald5	46000	2026-04-14 06:48:35.414	2026-04-14 06:48:35.414
cmny9fyx301dsvxy4636x02gb	cmny9fywe01dqvxy4dz0ld4m5	cmny9fd420001vxy42djthn1o	46000	2026-04-14 06:48:35.463	2026-04-14 06:48:35.463
cmny9fyxs01duvxy4wwoinhaf	cmny9fywe01dqvxy4dz0ld4m5	cmny9fd4t0002vxy4jo0l7gop	40000	2026-04-14 06:48:35.488	2026-04-14 06:48:35.488
cmny9fyyh01dwvxy43fq96wfd	cmny9fywe01dqvxy4dz0ld4m5	cmny9fd5j0003vxy4sw5e14p1	46000	2026-04-14 06:48:35.513	2026-04-14 06:48:35.513
cmny9fyz601dyvxy4wjlk7to8	cmny9fywe01dqvxy4dz0ld4m5	cmny9fd6h0004vxy4evm3jgfv	46000	2026-04-14 06:48:35.538	2026-04-14 06:48:35.538
cmny9fyzy01e0vxy4aakmgkeb	cmny9fywe01dqvxy4dz0ld4m5	cmny9fd7u0006vxy4mh4wwui4	46000	2026-04-14 06:48:35.567	2026-04-14 06:48:35.567
cmny9fz0r01e2vxy4m9lpgqxw	cmny9fywe01dqvxy4dz0ld4m5	cmny9fd8i0007vxy4tmc0glr0	46000	2026-04-14 06:48:35.595	2026-04-14 06:48:35.595
cmny9fz1k01e4vxy4l81fz341	cmny9fywe01dqvxy4dz0ld4m5	cmny9fd980008vxy4alsawn4y	46000	2026-04-14 06:48:35.624	2026-04-14 06:48:35.624
cmny9fz2501e6vxy44nfrmqp8	cmny9fywe01dqvxy4dz0ld4m5	cmny9fd9w0009vxy498vvvu1d	40000	2026-04-14 06:48:35.645	2026-04-14 06:48:35.645
cmny9fz2z01e8vxy4n4yhnynl	cmny9fywe01dqvxy4dz0ld4m5	cmny9fdb9000bvxy4h02fexen	46000	2026-04-14 06:48:35.676	2026-04-14 06:48:35.676
cmny9fz3u01eavxy4ksdhn7e5	cmny9fywe01dqvxy4dz0ld4m5	cmny9fdc1000cvxy4n4y9ezu8	46000	2026-04-14 06:48:35.706	2026-04-14 06:48:35.706
cmny9fz4i01ecvxy4asfs57dp	cmny9fywe01dqvxy4dz0ld4m5	cmny9fdcn000dvxy4w3gaald5	46000	2026-04-14 06:48:35.731	2026-04-14 06:48:35.731
cmny9fz5w01efvxy4rstiuu2z	cmny9fz5701edvxy4h1wuuxhy	cmny9fd420001vxy42djthn1o	46000	2026-04-14 06:48:35.781	2026-04-14 06:48:35.781
cmny9fz7301ehvxy4dft878jn	cmny9fz5701edvxy4h1wuuxhy	cmny9fd4t0002vxy4jo0l7gop	40000	2026-04-14 06:48:35.823	2026-04-14 06:48:35.823
cmny9fz7q01ejvxy4hpglgv1q	cmny9fz5701edvxy4h1wuuxhy	cmny9fd5j0003vxy4sw5e14p1	46000	2026-04-14 06:48:35.846	2026-04-14 06:48:35.846
cmny9fz8h01elvxy4adaqx5rd	cmny9fz5701edvxy4h1wuuxhy	cmny9fd6h0004vxy4evm3jgfv	46000	2026-04-14 06:48:35.873	2026-04-14 06:48:35.873
cmny9fz9501envxy44ufkano2	cmny9fz5701edvxy4h1wuuxhy	cmny9fd7u0006vxy4mh4wwui4	46000	2026-04-14 06:48:35.898	2026-04-14 06:48:35.898
cmny9fza201epvxy4tb7slutr	cmny9fz5701edvxy4h1wuuxhy	cmny9fd8i0007vxy4tmc0glr0	46000	2026-04-14 06:48:35.931	2026-04-14 06:48:35.931
cmny9fzas01ervxy4ffdmu3iv	cmny9fz5701edvxy4h1wuuxhy	cmny9fd980008vxy4alsawn4y	46000	2026-04-14 06:48:35.956	2026-04-14 06:48:35.956
cmny9fzbp01etvxy42v9kzonl	cmny9fz5701edvxy4h1wuuxhy	cmny9fd9w0009vxy498vvvu1d	38000	2026-04-14 06:48:35.99	2026-04-14 06:48:35.99
cmny9fzdd01evvxy4hu3d0dlo	cmny9fz5701edvxy4h1wuuxhy	cmny9fdb9000bvxy4h02fexen	46000	2026-04-14 06:48:36.05	2026-04-14 06:48:36.05
cmny9fzdy01exvxy4yagewrd4	cmny9fz5701edvxy4h1wuuxhy	cmny9fdc1000cvxy4n4y9ezu8	46000	2026-04-14 06:48:36.071	2026-04-14 06:48:36.071
cmny9fzeq01ezvxy4jj43rse8	cmny9fz5701edvxy4h1wuuxhy	cmny9fdcn000dvxy4w3gaald5	46000	2026-04-14 06:48:36.098	2026-04-14 06:48:36.098
cmny9fzg301f2vxy45g3ysio1	cmny9fzfe01f0vxy4k2jb49dt	cmny9fd420001vxy42djthn1o	46000	2026-04-14 06:48:36.148	2026-04-14 06:48:36.148
cmny9fzgr01f4vxy43cpwod7c	cmny9fzfe01f0vxy4k2jb49dt	cmny9fd4t0002vxy4jo0l7gop	40000	2026-04-14 06:48:36.172	2026-04-14 06:48:36.172
cmny9fzhh01f6vxy4aiaeojoh	cmny9fzfe01f0vxy4k2jb49dt	cmny9fd5j0003vxy4sw5e14p1	46000	2026-04-14 06:48:36.197	2026-04-14 06:48:36.197
cmny9fziv01f8vxy4qr8junjo	cmny9fzfe01f0vxy4k2jb49dt	cmny9fd6h0004vxy4evm3jgfv	46000	2026-04-14 06:48:36.247	2026-04-14 06:48:36.247
cmny9fzjn01favxy40ntllqaq	cmny9fzfe01f0vxy4k2jb49dt	cmny9fd7u0006vxy4mh4wwui4	46000	2026-04-14 06:48:36.275	2026-04-14 06:48:36.275
cmny9fzki01fcvxy40a7aknfu	cmny9fzfe01f0vxy4k2jb49dt	cmny9fd8i0007vxy4tmc0glr0	46000	2026-04-14 06:48:36.306	2026-04-14 06:48:36.306
cmny9fzl401fevxy4fzyg5xfs	cmny9fzfe01f0vxy4k2jb49dt	cmny9fd980008vxy4alsawn4y	46000	2026-04-14 06:48:36.329	2026-04-14 06:48:36.329
cmny9fzlw01fgvxy4sequjk19	cmny9fzfe01f0vxy4k2jb49dt	cmny9fd9w0009vxy498vvvu1d	38000	2026-04-14 06:48:36.356	2026-04-14 06:48:36.356
cmny9fzml01fivxy4p6gipxc6	cmny9fzfe01f0vxy4k2jb49dt	cmny9fdb9000bvxy4h02fexen	46000	2026-04-14 06:48:36.381	2026-04-14 06:48:36.381
cmny9fzna01fkvxy416ysaodb	cmny9fzfe01f0vxy4k2jb49dt	cmny9fdc1000cvxy4n4y9ezu8	46000	2026-04-14 06:48:36.407	2026-04-14 06:48:36.407
cmny9fzoo01fmvxy47x5oyrxp	cmny9fzfe01f0vxy4k2jb49dt	cmny9fdcn000dvxy4w3gaald5	46000	2026-04-14 06:48:36.456	2026-04-14 06:48:36.456
cmny9fzq201fpvxy4a1m4kpop	cmny9fzpa01fnvxy4ktzgwfij	cmny9fd420001vxy42djthn1o	46000	2026-04-14 06:48:36.506	2026-04-14 06:48:36.506
cmny9fzqp01frvxy4ggsdu6tb	cmny9fzpa01fnvxy4ktzgwfij	cmny9fd4t0002vxy4jo0l7gop	40000	2026-04-14 06:48:36.529	2026-04-14 06:48:36.529
cmny9fzrh01ftvxy4zqa34dh2	cmny9fzpa01fnvxy4ktzgwfij	cmny9fd5j0003vxy4sw5e14p1	46000	2026-04-14 06:48:36.557	2026-04-14 06:48:36.557
cmny9fzs101fvvxy4g082ubks	cmny9fzpa01fnvxy4ktzgwfij	cmny9fd6h0004vxy4evm3jgfv	46000	2026-04-14 06:48:36.578	2026-04-14 06:48:36.578
cmny9fzt401fxvxy4diby04xr	cmny9fzpa01fnvxy4ktzgwfij	cmny9fd7u0006vxy4mh4wwui4	46000	2026-04-14 06:48:36.616	2026-04-14 06:48:36.616
cmny9fzug01fzvxy4vkofjyk3	cmny9fzpa01fnvxy4ktzgwfij	cmny9fd8i0007vxy4tmc0glr0	46000	2026-04-14 06:48:36.664	2026-04-14 06:48:36.664
cmny9fzv401g1vxy4zvmmkpsy	cmny9fzpa01fnvxy4ktzgwfij	cmny9fd980008vxy4alsawn4y	46000	2026-04-14 06:48:36.688	2026-04-14 06:48:36.688
cmny9fzvu01g3vxy4vdvrbd0b	cmny9fzpa01fnvxy4ktzgwfij	cmny9fd9w0009vxy498vvvu1d	38000	2026-04-14 06:48:36.714	2026-04-14 06:48:36.714
cmny9fzwk01g5vxy4vhqd22hm	cmny9fzpa01fnvxy4ktzgwfij	cmny9fdb9000bvxy4h02fexen	46000	2026-04-14 06:48:36.74	2026-04-14 06:48:36.74
cmny9fzxg01g7vxy4d6g1zv17	cmny9fzpa01fnvxy4ktzgwfij	cmny9fdc1000cvxy4n4y9ezu8	46000	2026-04-14 06:48:36.772	2026-04-14 06:48:36.772
cmny9fzy301g9vxy4ypps71kw	cmny9fzpa01fnvxy4ktzgwfij	cmny9fdcn000dvxy4w3gaald5	46000	2026-04-14 06:48:36.795	2026-04-14 06:48:36.795
cmny9fzzg01gcvxy40rusmxkv	cmny9fzyu01gavxy4ljsg7t17	cmny9fd420001vxy42djthn1o	46000	2026-04-14 06:48:36.845	2026-04-14 06:48:36.845
cmny9g00901gevxy4va435kfd	cmny9fzyu01gavxy4ljsg7t17	cmny9fd4t0002vxy4jo0l7gop	40000	2026-04-14 06:48:36.873	2026-04-14 06:48:36.873
cmny9g00u01ggvxy4m9ok80r9	cmny9fzyu01gavxy4ljsg7t17	cmny9fd5j0003vxy4sw5e14p1	46000	2026-04-14 06:48:36.895	2026-04-14 06:48:36.895
cmny9g01m01givxy46epkbnfl	cmny9fzyu01gavxy4ljsg7t17	cmny9fd6h0004vxy4evm3jgfv	46000	2026-04-14 06:48:36.922	2026-04-14 06:48:36.922
cmny9g02b01gkvxy4qx8ftkrw	cmny9fzyu01gavxy4ljsg7t17	cmny9fd7u0006vxy4mh4wwui4	46000	2026-04-14 06:48:36.947	2026-04-14 06:48:36.947
cmny9g03101gmvxy47dh7flsd	cmny9fzyu01gavxy4ljsg7t17	cmny9fd8i0007vxy4tmc0glr0	46000	2026-04-14 06:48:36.973	2026-04-14 06:48:36.973
cmny9g03m01govxy43ebd4is3	cmny9fzyu01gavxy4ljsg7t17	cmny9fd980008vxy4alsawn4y	46000	2026-04-14 06:48:36.995	2026-04-14 06:48:36.995
cmny9g04e01gqvxy452dl5fli	cmny9fzyu01gavxy4ljsg7t17	cmny9fd9w0009vxy498vvvu1d	38000	2026-04-14 06:48:37.023	2026-04-14 06:48:37.023
cmny9g05501gsvxy4fvfh6eac	cmny9fzyu01gavxy4ljsg7t17	cmny9fdb9000bvxy4h02fexen	46000	2026-04-14 06:48:37.049	2026-04-14 06:48:37.049
cmny9g06201guvxy4iktevna8	cmny9fzyu01gavxy4ljsg7t17	cmny9fdc1000cvxy4n4y9ezu8	46000	2026-04-14 06:48:37.081	2026-04-14 06:48:37.081
cmny9g06p01gwvxy4hc480i3h	cmny9fzyu01gavxy4ljsg7t17	cmny9fdcn000dvxy4w3gaald5	46000	2026-04-14 06:48:37.105	2026-04-14 06:48:37.105
cmny9g08401gzvxy4hmuqn0wi	cmny9g07e01gxvxy4n3g7lykr	cmny9fd420001vxy42djthn1o	46000	2026-04-14 06:48:37.156	2026-04-14 06:48:37.156
cmny9g09201h1vxy4rqvnvzb1	cmny9g07e01gxvxy4n3g7lykr	cmny9fd4t0002vxy4jo0l7gop	40000	2026-04-14 06:48:37.19	2026-04-14 06:48:37.19
cmny9g09n01h3vxy4fgjqcb46	cmny9g07e01gxvxy4n3g7lykr	cmny9fd5j0003vxy4sw5e14p1	46000	2026-04-14 06:48:37.212	2026-04-14 06:48:37.212
cmny9g0ag01h5vxy4px83yxl0	cmny9g07e01gxvxy4n3g7lykr	cmny9fd6h0004vxy4evm3jgfv	46000	2026-04-14 06:48:37.24	2026-04-14 06:48:37.24
cmny9g0b501h7vxy4dinu9qou	cmny9g07e01gxvxy4n3g7lykr	cmny9fd7u0006vxy4mh4wwui4	46000	2026-04-14 06:48:37.265	2026-04-14 06:48:37.265
cmny9g0c901h9vxy49trxrb7v	cmny9g07e01gxvxy4n3g7lykr	cmny9fd8i0007vxy4tmc0glr0	46000	2026-04-14 06:48:37.305	2026-04-14 06:48:37.305
cmny9g0cr01hbvxy4qwaqpj0n	cmny9g07e01gxvxy4n3g7lykr	cmny9fd980008vxy4alsawn4y	46000	2026-04-14 06:48:37.323	2026-04-14 06:48:37.323
cmny9g0de01hdvxy4r23ngs3s	cmny9g07e01gxvxy4n3g7lykr	cmny9fd9w0009vxy498vvvu1d	38000	2026-04-14 06:48:37.346	2026-04-14 06:48:37.346
cmny9g0dz01hfvxy44qqyi3ql	cmny9g07e01gxvxy4n3g7lykr	cmny9fdb9000bvxy4h02fexen	46000	2026-04-14 06:48:37.368	2026-04-14 06:48:37.368
cmny9g0er01hhvxy48zen7x0y	cmny9g07e01gxvxy4n3g7lykr	cmny9fdc1000cvxy4n4y9ezu8	46000	2026-04-14 06:48:37.395	2026-04-14 06:48:37.395
cmny9g0fc01hjvxy4djtpz5a4	cmny9g07e01gxvxy4n3g7lykr	cmny9fdcn000dvxy4w3gaald5	46000	2026-04-14 06:48:37.417	2026-04-14 06:48:37.417
cmny9g0ks01hmvxy4k4xgh6cz	cmny9g0h401hkvxy417x1mjae	cmny9fd420001vxy42djthn1o	46000	2026-04-14 06:48:37.613	2026-04-14 06:48:37.613
cmny9g0ll01hovxy49ge2epc6	cmny9g0h401hkvxy417x1mjae	cmny9fd4t0002vxy4jo0l7gop	40000	2026-04-14 06:48:37.641	2026-04-14 06:48:37.641
cmny9g0mg01hqvxy4jwepilce	cmny9g0h401hkvxy417x1mjae	cmny9fd5j0003vxy4sw5e14p1	46000	2026-04-14 06:48:37.672	2026-04-14 06:48:37.672
cmny9g0nm01hsvxy4a0672f0i	cmny9g0h401hkvxy417x1mjae	cmny9fd6h0004vxy4evm3jgfv	46000	2026-04-14 06:48:37.713	2026-04-14 06:48:37.713
cmny9g0ov01huvxy49bl2c9ob	cmny9g0h401hkvxy417x1mjae	cmny9fd7u0006vxy4mh4wwui4	46000	2026-04-14 06:48:37.759	2026-04-14 06:48:37.759
cmny9g0pr01hwvxy40fc7h7z8	cmny9g0h401hkvxy417x1mjae	cmny9fd8i0007vxy4tmc0glr0	46000	2026-04-14 06:48:37.791	2026-04-14 06:48:37.791
cmny9g0ql01hyvxy4i0h0dwe9	cmny9g0h401hkvxy417x1mjae	cmny9fd980008vxy4alsawn4y	46000	2026-04-14 06:48:37.822	2026-04-14 06:48:37.822
cmny9g0rc01i0vxy4uqsait9m	cmny9g0h401hkvxy417x1mjae	cmny9fd9w0009vxy498vvvu1d	38000	2026-04-14 06:48:37.848	2026-04-14 06:48:37.848
cmny9g0s201i2vxy4jc1jebat	cmny9g0h401hkvxy417x1mjae	cmny9fdb9000bvxy4h02fexen	46000	2026-04-14 06:48:37.875	2026-04-14 06:48:37.875
cmny9g0t901i4vxy4fchuwqmo	cmny9g0h401hkvxy417x1mjae	cmny9fdc1000cvxy4n4y9ezu8	46000	2026-04-14 06:48:37.917	2026-04-14 06:48:37.917
cmny9g0v901i6vxy4gtygo863	cmny9g0h401hkvxy417x1mjae	cmny9fdcn000dvxy4w3gaald5	46000	2026-04-14 06:48:37.989	2026-04-14 06:48:37.989
cmny9g0x401i9vxy4i7wo28r8	cmny9g0we01i7vxy40uto4qld	cmny9fd420001vxy42djthn1o	42000	2026-04-14 06:48:38.056	2026-04-14 06:48:38.056
cmny9g0xt01ibvxy4947gujpx	cmny9g0we01i7vxy40uto4qld	cmny9fd4t0002vxy4jo0l7gop	40000	2026-04-14 06:48:38.081	2026-04-14 06:48:38.081
cmny9g0yf01idvxy4onb6spmu	cmny9g0we01i7vxy40uto4qld	cmny9fd5j0003vxy4sw5e14p1	42000	2026-04-14 06:48:38.103	2026-04-14 06:48:38.103
cmny9g0zf01ifvxy434yo0l3k	cmny9g0we01i7vxy40uto4qld	cmny9fd6h0004vxy4evm3jgfv	42000	2026-04-14 06:48:38.14	2026-04-14 06:48:38.14
cmny9g10501ihvxy46qdmu4sa	cmny9g0we01i7vxy40uto4qld	cmny9fd7u0006vxy4mh4wwui4	42000	2026-04-14 06:48:38.165	2026-04-14 06:48:38.165
cmny9g11101ijvxy4av6ii806	cmny9g0we01i7vxy40uto4qld	cmny9fd8i0007vxy4tmc0glr0	42000	2026-04-14 06:48:38.197	2026-04-14 06:48:38.197
cmny9g11q01ilvxy46pmudvua	cmny9g0we01i7vxy40uto4qld	cmny9fd980008vxy4alsawn4y	42000	2026-04-14 06:48:38.222	2026-04-14 06:48:38.222
cmny9g12f01invxy4hvwn1kk4	cmny9g0we01i7vxy40uto4qld	cmny9fd9w0009vxy498vvvu1d	38000	2026-04-14 06:48:38.247	2026-04-14 06:48:38.247
cmny9g13701ipvxy4urhh9vk6	cmny9g0we01i7vxy40uto4qld	cmny9fdb9000bvxy4h02fexen	42000	2026-04-14 06:48:38.275	2026-04-14 06:48:38.275
cmny9g14201irvxy44jdd15m4	cmny9g0we01i7vxy40uto4qld	cmny9fdc1000cvxy4n4y9ezu8	42000	2026-04-14 06:48:38.306	2026-04-14 06:48:38.306
cmny9g14o01itvxy43g56isyn	cmny9g0we01i7vxy40uto4qld	cmny9fdcn000dvxy4w3gaald5	42000	2026-04-14 06:48:38.329	2026-04-14 06:48:38.329
cmny9g16201iwvxy4s9dynfw4	cmny9g15g01iuvxy4k8o2znkt	cmny9fd420001vxy42djthn1o	42000	2026-04-14 06:48:38.378	2026-04-14 06:48:38.378
cmny9g16u01iyvxy4gmwnnrv7	cmny9g15g01iuvxy4k8o2znkt	cmny9fd4t0002vxy4jo0l7gop	40000	2026-04-14 06:48:38.407	2026-04-14 06:48:38.407
cmny9g17f01j0vxy49mano4e1	cmny9g15g01iuvxy4k8o2znkt	cmny9fd5j0003vxy4sw5e14p1	42000	2026-04-14 06:48:38.428	2026-04-14 06:48:38.428
cmny9g18901j2vxy436b4scxx	cmny9g15g01iuvxy4k8o2znkt	cmny9fd6h0004vxy4evm3jgfv	42000	2026-04-14 06:48:38.457	2026-04-14 06:48:38.457
cmny9g18v01j4vxy4g8x85uz2	cmny9g15g01iuvxy4k8o2znkt	cmny9fd7u0006vxy4mh4wwui4	42000	2026-04-14 06:48:38.479	2026-04-14 06:48:38.479
cmny9g19m01j6vxy4w3ws9cis	cmny9g15g01iuvxy4k8o2znkt	cmny9fd8i0007vxy4tmc0glr0	42000	2026-04-14 06:48:38.507	2026-04-14 06:48:38.507
cmny9g1a801j8vxy45kyirgar	cmny9g15g01iuvxy4k8o2znkt	cmny9fd980008vxy4alsawn4y	42000	2026-04-14 06:48:38.528	2026-04-14 06:48:38.528
cmny9g1b001javxy42bvqsc4y	cmny9g15g01iuvxy4k8o2znkt	cmny9fd9w0009vxy498vvvu1d	38000	2026-04-14 06:48:38.557	2026-04-14 06:48:38.557
cmny9g1bo01jcvxy4aikyrgmj	cmny9g15g01iuvxy4k8o2znkt	cmny9fdb9000bvxy4h02fexen	42000	2026-04-14 06:48:38.581	2026-04-14 06:48:38.581
cmny9g1cg01jevxy4xfqsg7m3	cmny9g15g01iuvxy4k8o2znkt	cmny9fdc1000cvxy4n4y9ezu8	42000	2026-04-14 06:48:38.608	2026-04-14 06:48:38.608
cmny9g1d001jgvxy48la3vrqa	cmny9g15g01iuvxy4k8o2znkt	cmny9fdcn000dvxy4w3gaald5	42000	2026-04-14 06:48:38.628	2026-04-14 06:48:38.628
cmny9g1ee01jjvxy4ntycnu8o	cmny9g1ds01jhvxy4vh9ao1kl	cmny9fd420001vxy42djthn1o	42000	2026-04-14 06:48:38.679	2026-04-14 06:48:38.679
cmny9g1f701jlvxy46phhqkk6	cmny9g1ds01jhvxy4vh9ao1kl	cmny9fd4t0002vxy4jo0l7gop	40000	2026-04-14 06:48:38.707	2026-04-14 06:48:38.707
cmny9g1fs01jnvxy4q21pdt5u	cmny9g1ds01jhvxy4vh9ao1kl	cmny9fd5j0003vxy4sw5e14p1	42000	2026-04-14 06:48:38.728	2026-04-14 06:48:38.728
cmny9g1gk01jpvxy4m9jwhr6i	cmny9g1ds01jhvxy4vh9ao1kl	cmny9fd6h0004vxy4evm3jgfv	42000	2026-04-14 06:48:38.756	2026-04-14 06:48:38.756
cmny9g1ha01jrvxy4uas81yhv	cmny9g1ds01jhvxy4vh9ao1kl	cmny9fd7u0006vxy4mh4wwui4	42000	2026-04-14 06:48:38.782	2026-04-14 06:48:38.782
cmny9g1i601jtvxy4t3znxrwk	cmny9g1ds01jhvxy4vh9ao1kl	cmny9fd8i0007vxy4tmc0glr0	42000	2026-04-14 06:48:38.814	2026-04-14 06:48:38.814
cmny9g1iu01jvvxy4k3t2j5l9	cmny9g1ds01jhvxy4vh9ao1kl	cmny9fd980008vxy4alsawn4y	42000	2026-04-14 06:48:38.839	2026-04-14 06:48:38.839
cmny9g1jk01jxvxy4pl665edc	cmny9g1ds01jhvxy4vh9ao1kl	cmny9fd9w0009vxy498vvvu1d	38000	2026-04-14 06:48:38.864	2026-04-14 06:48:38.864
cmny9g1kb01jzvxy4599ji7qt	cmny9g1ds01jhvxy4vh9ao1kl	cmny9fdb9000bvxy4h02fexen	42000	2026-04-14 06:48:38.892	2026-04-14 06:48:38.892
cmny9g1l801k1vxy4lob9sl85	cmny9g1ds01jhvxy4vh9ao1kl	cmny9fdc1000cvxy4n4y9ezu8	42000	2026-04-14 06:48:38.924	2026-04-14 06:48:38.924
cmny9g1lt01k3vxy41bbb67v7	cmny9g1ds01jhvxy4vh9ao1kl	cmny9fdcn000dvxy4w3gaald5	42000	2026-04-14 06:48:38.946	2026-04-14 06:48:38.946
cmny9g1oh01k6vxy4kwax531j	cmny9g1n701k4vxy4m1kr5v71	cmny9fd420001vxy42djthn1o	46000	2026-04-14 06:48:39.041	2026-04-14 06:48:39.041
cmny9g1qf01k8vxy4508yxx90	cmny9g1n701k4vxy4m1kr5v71	cmny9fd4t0002vxy4jo0l7gop	40000	2026-04-14 06:48:39.111	2026-04-14 06:48:39.111
cmny9g1r801kavxy48s73ahkg	cmny9g1n701k4vxy4m1kr5v71	cmny9fd5j0003vxy4sw5e14p1	46000	2026-04-14 06:48:39.14	2026-04-14 06:48:39.14
cmny9g1s501kcvxy49j6t4fu4	cmny9g1n701k4vxy4m1kr5v71	cmny9fd6h0004vxy4evm3jgfv	46000	2026-04-14 06:48:39.173	2026-04-14 06:48:39.173
cmny9g1st01kevxy4yx4yc3sc	cmny9g1n701k4vxy4m1kr5v71	cmny9fd7u0006vxy4mh4wwui4	46000	2026-04-14 06:48:39.197	2026-04-14 06:48:39.197
cmny9g1tj01kgvxy4y3iez2v8	cmny9g1n701k4vxy4m1kr5v71	cmny9fd8i0007vxy4tmc0glr0	46000	2026-04-14 06:48:39.223	2026-04-14 06:48:39.223
cmny9g1u501kivxy4yrwcqjil	cmny9g1n701k4vxy4m1kr5v71	cmny9fd980008vxy4alsawn4y	46000	2026-04-14 06:48:39.246	2026-04-14 06:48:39.246
cmny9g1uy01kkvxy4fzlfnz4c	cmny9g1n701k4vxy4m1kr5v71	cmny9fd9w0009vxy498vvvu1d	40000	2026-04-14 06:48:39.274	2026-04-14 06:48:39.274
cmny9g1vl01kmvxy4d1ryyqqk	cmny9g1n701k4vxy4m1kr5v71	cmny9fdb9000bvxy4h02fexen	46000	2026-04-14 06:48:39.297	2026-04-14 06:48:39.297
cmny9g1wb01kovxy41yj2anv7	cmny9g1n701k4vxy4m1kr5v71	cmny9fdc1000cvxy4n4y9ezu8	46000	2026-04-14 06:48:39.323	2026-04-14 06:48:39.323
cmny9g1wx01kqvxy4plqmd1v5	cmny9g1n701k4vxy4m1kr5v71	cmny9fdcn000dvxy4w3gaald5	46000	2026-04-14 06:48:39.345	2026-04-14 06:48:39.345
cmny9g1yb01ktvxy457lk0w2k	cmny9g1xp01krvxy4v9zhe6qk	cmny9fd420001vxy42djthn1o	46000	2026-04-14 06:48:39.396	2026-04-14 06:48:39.396
cmny9g1z301kvvxy45c3gct8b	cmny9g1xp01krvxy4v9zhe6qk	cmny9fd4t0002vxy4jo0l7gop	40000	2026-04-14 06:48:39.423	2026-04-14 06:48:39.423
cmny9g1zq01kxvxy4l91taz05	cmny9g1xp01krvxy4v9zhe6qk	cmny9fd5j0003vxy4sw5e14p1	46000	2026-04-14 06:48:39.446	2026-04-14 06:48:39.446
cmny9g20g01kzvxy4dnfwl7l8	cmny9g1xp01krvxy4v9zhe6qk	cmny9fd6h0004vxy4evm3jgfv	46000	2026-04-14 06:48:39.473	2026-04-14 06:48:39.473
cmny9g21601l1vxy4ipq192kf	cmny9g1xp01krvxy4v9zhe6qk	cmny9fd7u0006vxy4mh4wwui4	46000	2026-04-14 06:48:39.498	2026-04-14 06:48:39.498
cmny9g21v01l3vxy4v3rc02it	cmny9g1xp01krvxy4v9zhe6qk	cmny9fd8i0007vxy4tmc0glr0	46000	2026-04-14 06:48:39.523	2026-04-14 06:48:39.523
cmny9g22h01l5vxy42dk828np	cmny9g1xp01krvxy4v9zhe6qk	cmny9fd980008vxy4alsawn4y	46000	2026-04-14 06:48:39.545	2026-04-14 06:48:39.545
cmny9g23901l7vxy4xthfabnc	cmny9g1xp01krvxy4v9zhe6qk	cmny9fd9w0009vxy498vvvu1d	40000	2026-04-14 06:48:39.573	2026-04-14 06:48:39.573
cmny9g23y01l9vxy4wcwmfvge	cmny9g1xp01krvxy4v9zhe6qk	cmny9fdb9000bvxy4h02fexen	46000	2026-04-14 06:48:39.598	2026-04-14 06:48:39.598
cmny9g25r01lbvxy4klqkdx6b	cmny9g1xp01krvxy4v9zhe6qk	cmny9fdc1000cvxy4n4y9ezu8	46000	2026-04-14 06:48:39.663	2026-04-14 06:48:39.663
cmny9g26q01ldvxy41cl8sphp	cmny9g1xp01krvxy4v9zhe6qk	cmny9fdcn000dvxy4w3gaald5	46000	2026-04-14 06:48:39.698	2026-04-14 06:48:39.698
cmny9g28301lgvxy44av7j8km	cmny9g27f01levxy4nkhbbpaj	cmny9fd420001vxy42djthn1o	46000	2026-04-14 06:48:39.748	2026-04-14 06:48:39.748
cmny9g28s01livxy47va4ewtf	cmny9g27f01levxy4nkhbbpaj	cmny9fd4t0002vxy4jo0l7gop	40000	2026-04-14 06:48:39.772	2026-04-14 06:48:39.772
cmny9g29a01lkvxy4e7ctlola	cmny9g27f01levxy4nkhbbpaj	cmny9fd5j0003vxy4sw5e14p1	46000	2026-04-14 06:48:39.79	2026-04-14 06:48:39.79
cmny9g29w01lmvxy4r23bo1q0	cmny9g27f01levxy4nkhbbpaj	cmny9fd6h0004vxy4evm3jgfv	46000	2026-04-14 06:48:39.812	2026-04-14 06:48:39.812
cmny9g2ah01lovxy4ufczc1zp	cmny9g27f01levxy4nkhbbpaj	cmny9fd7u0006vxy4mh4wwui4	46000	2026-04-14 06:48:39.833	2026-04-14 06:48:39.833
cmny9g2bk01lqvxy4yhpnt5f1	cmny9g27f01levxy4nkhbbpaj	cmny9fd8i0007vxy4tmc0glr0	46000	2026-04-14 06:48:39.872	2026-04-14 06:48:39.872
cmny9g2c701lsvxy4wbijfjsz	cmny9g27f01levxy4nkhbbpaj	cmny9fd980008vxy4alsawn4y	46000	2026-04-14 06:48:39.895	2026-04-14 06:48:39.895
cmny9g2cq01luvxy4bnu9t33f	cmny9g27f01levxy4nkhbbpaj	cmny9fd9w0009vxy498vvvu1d	40000	2026-04-14 06:48:39.915	2026-04-14 06:48:39.915
cmny9g2dg01lwvxy41me24uu0	cmny9g27f01levxy4nkhbbpaj	cmny9fdb9000bvxy4h02fexen	46000	2026-04-14 06:48:39.941	2026-04-14 06:48:39.941
cmny9g2e401lyvxy4shj7qp66	cmny9g27f01levxy4nkhbbpaj	cmny9fdc1000cvxy4n4y9ezu8	46000	2026-04-14 06:48:39.964	2026-04-14 06:48:39.964
cmny9g2et01m0vxy47cxqhzes	cmny9g27f01levxy4nkhbbpaj	cmny9fdcn000dvxy4w3gaald5	46000	2026-04-14 06:48:39.989	2026-04-14 06:48:39.989
cmny9g2g801m3vxy4gdk1oopf	cmny9g2fi01m1vxy4svc6kyzs	cmny9fd420001vxy42djthn1o	30000	2026-04-14 06:48:40.04	2026-04-14 06:48:40.04
cmny9g2gw01m5vxy4cix9k565	cmny9g2fi01m1vxy4svc6kyzs	cmny9fd4t0002vxy4jo0l7gop	30000	2026-04-14 06:48:40.064	2026-04-14 06:48:40.064
cmny9g2hk01m7vxy4fmdksnlm	cmny9g2fi01m1vxy4svc6kyzs	cmny9fd5j0003vxy4sw5e14p1	30000	2026-04-14 06:48:40.089	2026-04-14 06:48:40.089
cmny9g2ia01m9vxy426f18ihy	cmny9g2fi01m1vxy4svc6kyzs	cmny9fd6h0004vxy4evm3jgfv	30000	2026-04-14 06:48:40.115	2026-04-14 06:48:40.115
cmny9g2j001mbvxy4m1yiotur	cmny9g2fi01m1vxy4svc6kyzs	cmny9fd7u0006vxy4mh4wwui4	30000	2026-04-14 06:48:40.14	2026-04-14 06:48:40.14
cmny9g2jo01mdvxy4y7gnu7ob	cmny9g2fi01m1vxy4svc6kyzs	cmny9fd8i0007vxy4tmc0glr0	30000	2026-04-14 06:48:40.164	2026-04-14 06:48:40.164
cmny9g2kd01mfvxy4w9ujxitn	cmny9g2fi01m1vxy4svc6kyzs	cmny9fd980008vxy4alsawn4y	30000	2026-04-14 06:48:40.189	2026-04-14 06:48:40.189
cmny9g2l201mhvxy466kp7mvm	cmny9g2fi01m1vxy4svc6kyzs	cmny9fd9w0009vxy498vvvu1d	30000	2026-04-14 06:48:40.214	2026-04-14 06:48:40.214
cmny9g2lt01mjvxy4nsptnami	cmny9g2fi01m1vxy4svc6kyzs	cmny9fdb9000bvxy4h02fexen	30000	2026-04-14 06:48:40.242	2026-04-14 06:48:40.242
cmny9g2mg01mlvxy4d3kdlr6h	cmny9g2fi01m1vxy4svc6kyzs	cmny9fdc1000cvxy4n4y9ezu8	30000	2026-04-14 06:48:40.264	2026-04-14 06:48:40.264
cmny9g2n501mnvxy4hazos0ec	cmny9g2fi01m1vxy4svc6kyzs	cmny9fdcn000dvxy4w3gaald5	30000	2026-04-14 06:48:40.289	2026-04-14 06:48:40.289
cmny9g2oj01mqvxy4d9jsuavf	cmny9g2nv01movxy437et0sti	cmny9fd420001vxy42djthn1o	30000	2026-04-14 06:48:40.339	2026-04-14 06:48:40.339
cmny9g2p101msvxy4f2cjhtpt	cmny9g2nv01movxy437et0sti	cmny9fd4t0002vxy4jo0l7gop	30000	2026-04-14 06:48:40.357	2026-04-14 06:48:40.357
cmny9g2pn01muvxy48rotn0gw	cmny9g2nv01movxy437et0sti	cmny9fd5j0003vxy4sw5e14p1	30000	2026-04-14 06:48:40.379	2026-04-14 06:48:40.379
cmny9g2q601mwvxy4o44063eo	cmny9g2nv01movxy437et0sti	cmny9fd6h0004vxy4evm3jgfv	30000	2026-04-14 06:48:40.398	2026-04-14 06:48:40.398
cmny9g2qx01myvxy4gnmoru14	cmny9g2nv01movxy437et0sti	cmny9fd7u0006vxy4mh4wwui4	30000	2026-04-14 06:48:40.425	2026-04-14 06:48:40.425
cmny9g2rk01n0vxy4nq2ypzm4	cmny9g2nv01movxy437et0sti	cmny9fd8i0007vxy4tmc0glr0	30000	2026-04-14 06:48:40.448	2026-04-14 06:48:40.448
cmny9g2s901n2vxy46h8wqixr	cmny9g2nv01movxy437et0sti	cmny9fd980008vxy4alsawn4y	30000	2026-04-14 06:48:40.473	2026-04-14 06:48:40.473
cmny9g2sy01n4vxy45qukha28	cmny9g2nv01movxy437et0sti	cmny9fd9w0009vxy498vvvu1d	30000	2026-04-14 06:48:40.498	2026-04-14 06:48:40.498
cmny9g2to01n6vxy40rf3jvtv	cmny9g2nv01movxy437et0sti	cmny9fdb9000bvxy4h02fexen	30000	2026-04-14 06:48:40.524	2026-04-14 06:48:40.524
cmny9g2uc01n8vxy4vzvoyhl4	cmny9g2nv01movxy437et0sti	cmny9fdc1000cvxy4n4y9ezu8	30000	2026-04-14 06:48:40.548	2026-04-14 06:48:40.548
cmny9g2v001navxy4bdlb3cpl	cmny9g2nv01movxy437et0sti	cmny9fdcn000dvxy4w3gaald5	30000	2026-04-14 06:48:40.572	2026-04-14 06:48:40.572
cmny9g2we01ndvxy439aiyw9j	cmny9g2vq01nbvxy4ve43zehd	cmny9fd420001vxy42djthn1o	30000	2026-04-14 06:48:40.622	2026-04-14 06:48:40.622
cmny9g2ww01nfvxy4c4uha45y	cmny9g2vq01nbvxy4ve43zehd	cmny9fd4t0002vxy4jo0l7gop	30000	2026-04-14 06:48:40.64	2026-04-14 06:48:40.64
cmny9g2xi01nhvxy4wafkxr72	cmny9g2vq01nbvxy4ve43zehd	cmny9fd5j0003vxy4sw5e14p1	30000	2026-04-14 06:48:40.663	2026-04-14 06:48:40.663
cmny9g2y101njvxy4sp03r6du	cmny9g2vq01nbvxy4ve43zehd	cmny9fd6h0004vxy4evm3jgfv	30000	2026-04-14 06:48:40.681	2026-04-14 06:48:40.681
cmny9g2ys01nlvxy4g8r2cio6	cmny9g2vq01nbvxy4ve43zehd	cmny9fd7u0006vxy4mh4wwui4	30000	2026-04-14 06:48:40.708	2026-04-14 06:48:40.708
cmny9g2zf01nnvxy4jaonse7t	cmny9g2vq01nbvxy4ve43zehd	cmny9fd8i0007vxy4tmc0glr0	30000	2026-04-14 06:48:40.731	2026-04-14 06:48:40.731
cmny9g30401npvxy43zlw0qx3	cmny9g2vq01nbvxy4ve43zehd	cmny9fd980008vxy4alsawn4y	30000	2026-04-14 06:48:40.756	2026-04-14 06:48:40.756
cmny9g30t01nrvxy4g4ryz8e2	cmny9g2vq01nbvxy4ve43zehd	cmny9fd9w0009vxy498vvvu1d	30000	2026-04-14 06:48:40.781	2026-04-14 06:48:40.781
cmny9g31l01ntvxy4hrgarmc4	cmny9g2vq01nbvxy4ve43zehd	cmny9fdb9000bvxy4h02fexen	30000	2026-04-14 06:48:40.809	2026-04-14 06:48:40.809
cmny9g32701nvvxy4ra9aqmei	cmny9g2vq01nbvxy4ve43zehd	cmny9fdc1000cvxy4n4y9ezu8	30000	2026-04-14 06:48:40.831	2026-04-14 06:48:40.831
cmny9g32w01nxvxy4b6jmzam8	cmny9g2vq01nbvxy4ve43zehd	cmny9fdcn000dvxy4w3gaald5	30000	2026-04-14 06:48:40.857	2026-04-14 06:48:40.857
cmny9g34801o0vxy4s1biyfb7	cmny9g33l01nyvxy4oow351l0	cmny9fd420001vxy42djthn1o	40500	2026-04-14 06:48:40.905	2026-04-14 06:48:40.905
cmny9g35001o2vxy4g1fcip6w	cmny9g33l01nyvxy4oow351l0	cmny9fd4t0002vxy4jo0l7gop	40500	2026-04-14 06:48:40.932	2026-04-14 06:48:40.932
cmny9g35u01o4vxy4i5cxp6q4	cmny9g33l01nyvxy4oow351l0	cmny9fd5j0003vxy4sw5e14p1	40500	2026-04-14 06:48:40.962	2026-04-14 06:48:40.962
cmny9g36e01o6vxy4ralzakxg	cmny9g33l01nyvxy4oow351l0	cmny9fd6h0004vxy4evm3jgfv	40500	2026-04-14 06:48:40.982	2026-04-14 06:48:40.982
cmny9g37601o8vxy4zw7ozn4s	cmny9g33l01nyvxy4oow351l0	cmny9fd7u0006vxy4mh4wwui4	40500	2026-04-14 06:48:41.009	2026-04-14 06:48:41.009
cmny9g38601oavxy4uv3t8zkd	cmny9g33l01nyvxy4oow351l0	cmny9fd8i0007vxy4tmc0glr0	40500	2026-04-14 06:48:41.046	2026-04-14 06:48:41.046
cmny9g38x01ocvxy4l1ebitpn	cmny9g33l01nyvxy4oow351l0	cmny9fd980008vxy4alsawn4y	40500	2026-04-14 06:48:41.073	2026-04-14 06:48:41.073
cmny9g39m01oevxy4czo6kkzm	cmny9g33l01nyvxy4oow351l0	cmny9fd9w0009vxy498vvvu1d	40500	2026-04-14 06:48:41.098	2026-04-14 06:48:41.098
cmny9g3ac01ogvxy4nhidi8p2	cmny9g33l01nyvxy4oow351l0	cmny9fdb9000bvxy4h02fexen	40500	2026-04-14 06:48:41.125	2026-04-14 06:48:41.125
cmny9g3b001oivxy4n6mp5b31	cmny9g33l01nyvxy4oow351l0	cmny9fdc1000cvxy4n4y9ezu8	40500	2026-04-14 06:48:41.148	2026-04-14 06:48:41.148
cmny9g3bo01okvxy4x1oxvd1w	cmny9g33l01nyvxy4oow351l0	cmny9fdcn000dvxy4w3gaald5	40500	2026-04-14 06:48:41.172	2026-04-14 06:48:41.172
cmny9g3d201onvxy4dwlr09m5	cmny9g3cd01olvxy472e9test	cmny9fd420001vxy42djthn1o	40500	2026-04-14 06:48:41.222	2026-04-14 06:48:41.222
cmny9g3ds01opvxy4b0etaqfc	cmny9g3cd01olvxy472e9test	cmny9fd4t0002vxy4jo0l7gop	40500	2026-04-14 06:48:41.248	2026-04-14 06:48:41.248
cmny9g3ef01orvxy49io0gkkp	cmny9g3cd01olvxy472e9test	cmny9fd5j0003vxy4sw5e14p1	40500	2026-04-14 06:48:41.271	2026-04-14 06:48:41.271
cmny9g3ey01otvxy41ocx0og3	cmny9g3cd01olvxy472e9test	cmny9fd6h0004vxy4evm3jgfv	40500	2026-04-14 06:48:41.29	2026-04-14 06:48:41.29
cmny9g3fn01ovvxy4edkp4p2a	cmny9g3cd01olvxy472e9test	cmny9fd7u0006vxy4mh4wwui4	40500	2026-04-14 06:48:41.315	2026-04-14 06:48:41.315
cmny9g3gb01oxvxy4mu52ojuj	cmny9g3cd01olvxy472e9test	cmny9fd8i0007vxy4tmc0glr0	40500	2026-04-14 06:48:41.34	2026-04-14 06:48:41.34
cmny9g3gy01ozvxy4wjgk4vqx	cmny9g3cd01olvxy472e9test	cmny9fd980008vxy4alsawn4y	40500	2026-04-14 06:48:41.362	2026-04-14 06:48:41.362
cmny9g3hj01p1vxy40ip2n56d	cmny9g3cd01olvxy472e9test	cmny9fd9w0009vxy498vvvu1d	40500	2026-04-14 06:48:41.383	2026-04-14 06:48:41.383
cmny9g3i701p3vxy4rlzf167w	cmny9g3cd01olvxy472e9test	cmny9fdb9000bvxy4h02fexen	40500	2026-04-14 06:48:41.407	2026-04-14 06:48:41.407
cmny9g3iv01p5vxy4loup6cyk	cmny9g3cd01olvxy472e9test	cmny9fdc1000cvxy4n4y9ezu8	40500	2026-04-14 06:48:41.431	2026-04-14 06:48:41.431
cmny9g3jj01p7vxy4iv9rnt9c	cmny9g3cd01olvxy472e9test	cmny9fdcn000dvxy4w3gaald5	40500	2026-04-14 06:48:41.455	2026-04-14 06:48:41.455
cmny9g3kx01pavxy4qo3dgj7m	cmny9g3k901p8vxy45y5n1wps	cmny9fd420001vxy42djthn1o	40500	2026-04-14 06:48:41.505	2026-04-14 06:48:41.505
cmny9g3ln01pcvxy4yierayh5	cmny9g3k901p8vxy45y5n1wps	cmny9fd4t0002vxy4jo0l7gop	40500	2026-04-14 06:48:41.531	2026-04-14 06:48:41.531
cmny9g3mc01pevxy4jlgqwo20	cmny9g3k901p8vxy45y5n1wps	cmny9fd5j0003vxy4sw5e14p1	40500	2026-04-14 06:48:41.556	2026-04-14 06:48:41.556
cmny9g3n101pgvxy4eo986r4v	cmny9g3k901p8vxy45y5n1wps	cmny9fd6h0004vxy4evm3jgfv	40500	2026-04-14 06:48:41.581	2026-04-14 06:48:41.581
cmny9g3nr01pivxy41875lgnp	cmny9g3k901p8vxy45y5n1wps	cmny9fd7u0006vxy4mh4wwui4	40500	2026-04-14 06:48:41.607	2026-04-14 06:48:41.607
cmny9g3of01pkvxy4banw21ls	cmny9g3k901p8vxy45y5n1wps	cmny9fd8i0007vxy4tmc0glr0	40500	2026-04-14 06:48:41.631	2026-04-14 06:48:41.631
cmny9g3pa01pmvxy4i1s51ozc	cmny9g3k901p8vxy45y5n1wps	cmny9fd980008vxy4alsawn4y	40500	2026-04-14 06:48:41.662	2026-04-14 06:48:41.662
cmny9g3qj01povxy49ddvwlr2	cmny9g3k901p8vxy45y5n1wps	cmny9fd9w0009vxy498vvvu1d	40500	2026-04-14 06:48:41.707	2026-04-14 06:48:41.707
cmny9g3rg01pqvxy4nrl67cul	cmny9g3k901p8vxy45y5n1wps	cmny9fdb9000bvxy4h02fexen	40500	2026-04-14 06:48:41.74	2026-04-14 06:48:41.74
cmny9g3s501psvxy4vd0ex1ub	cmny9g3k901p8vxy45y5n1wps	cmny9fdc1000cvxy4n4y9ezu8	40500	2026-04-14 06:48:41.765	2026-04-14 06:48:41.765
cmny9g3st01puvxy4zvjaxhmk	cmny9g3k901p8vxy45y5n1wps	cmny9fdcn000dvxy4w3gaald5	40500	2026-04-14 06:48:41.789	2026-04-14 06:48:41.789
cmny9g3u901pxvxy41or6jw6m	cmny9g3ti01pvvxy4l5g9skkq	cmny9fd420001vxy42djthn1o	89000	2026-04-14 06:48:41.841	2026-04-14 06:48:41.841
cmny9g3uw01pzvxy4rq5x7u9p	cmny9g3ti01pvvxy4l5g9skkq	cmny9fd4t0002vxy4jo0l7gop	89000	2026-04-14 06:48:41.865	2026-04-14 06:48:41.865
cmny9g3vl01q1vxy4rsmgqp6p	cmny9g3ti01pvvxy4l5g9skkq	cmny9fd5j0003vxy4sw5e14p1	89000	2026-04-14 06:48:41.89	2026-04-14 06:48:41.89
cmny9g3wb01q3vxy4ic1ed02r	cmny9g3ti01pvvxy4l5g9skkq	cmny9fd6h0004vxy4evm3jgfv	89000	2026-04-14 06:48:41.915	2026-04-14 06:48:41.915
cmny9g3x101q5vxy4h7vwfpt5	cmny9g3ti01pvvxy4l5g9skkq	cmny9fd7u0006vxy4mh4wwui4	89000	2026-04-14 06:48:41.941	2026-04-14 06:48:41.941
cmny9g3xp01q7vxy46o9n50gr	cmny9g3ti01pvvxy4l5g9skkq	cmny9fd8i0007vxy4tmc0glr0	82000	2026-04-14 06:48:41.965	2026-04-14 06:48:41.965
cmny9g3yh01q9vxy48bpmw235	cmny9g3ti01pvvxy4l5g9skkq	cmny9fd980008vxy4alsawn4y	89000	2026-04-14 06:48:41.993	2026-04-14 06:48:41.993
cmny9g3z301qbvxy4wt5hfmp2	cmny9g3ti01pvvxy4l5g9skkq	cmny9fd9w0009vxy498vvvu1d	82000	2026-04-14 06:48:42.015	2026-04-14 06:48:42.015
cmny9g3zr01qdvxy4agtfjbjw	cmny9g3ti01pvvxy4l5g9skkq	cmny9fdam000avxy4a12zuxjj	82000	2026-04-14 06:48:42.039	2026-04-14 06:48:42.039
cmny9g40g01qfvxy4qwmkyoof	cmny9g3ti01pvvxy4l5g9skkq	cmny9fdb9000bvxy4h02fexen	89000	2026-04-14 06:48:42.064	2026-04-14 06:48:42.064
cmny9g41701qhvxy42clcx1nq	cmny9g3ti01pvvxy4l5g9skkq	cmny9fdc1000cvxy4n4y9ezu8	89000	2026-04-14 06:48:42.09	2026-04-14 06:48:42.09
cmny9g41w01qjvxy4vkkgpsqx	cmny9g3ti01pvvxy4l5g9skkq	cmny9fdcn000dvxy4w3gaald5	89000	2026-04-14 06:48:42.116	2026-04-14 06:48:42.116
cmny9g43p01qmvxy46f7j6htl	cmny9g43101qkvxy4khynrdvk	cmny9fd420001vxy42djthn1o	94000	2026-04-14 06:48:42.182	2026-04-14 06:48:42.182
cmny9g44d01qovxy44zvewun2	cmny9g43101qkvxy4khynrdvk	cmny9fd4t0002vxy4jo0l7gop	94000	2026-04-14 06:48:42.205	2026-04-14 06:48:42.205
cmny9g45301qqvxy4mqyj0o2p	cmny9g43101qkvxy4khynrdvk	cmny9fd5j0003vxy4sw5e14p1	94000	2026-04-14 06:48:42.231	2026-04-14 06:48:42.231
cmny9g45t01qsvxy4zd4reqb1	cmny9g43101qkvxy4khynrdvk	cmny9fd6h0004vxy4evm3jgfv	94000	2026-04-14 06:48:42.257	2026-04-14 06:48:42.257
cmny9g46j01quvxy4r7cv0ywm	cmny9g43101qkvxy4khynrdvk	cmny9fd7u0006vxy4mh4wwui4	94000	2026-04-14 06:48:42.283	2026-04-14 06:48:42.283
cmny9g47f01qwvxy4ogfsncoq	cmny9g43101qkvxy4khynrdvk	cmny9fd8i0007vxy4tmc0glr0	82000	2026-04-14 06:48:42.315	2026-04-14 06:48:42.315
cmny9g47v01qyvxy4vtdloj8e	cmny9g43101qkvxy4khynrdvk	cmny9fd980008vxy4alsawn4y	94000	2026-04-14 06:48:42.331	2026-04-14 06:48:42.331
cmny9g48k01r0vxy4ei62jrvb	cmny9g43101qkvxy4khynrdvk	cmny9fd9w0009vxy498vvvu1d	82000	2026-04-14 06:48:42.356	2026-04-14 06:48:42.356
cmny9g49801r2vxy4dbr6770f	cmny9g43101qkvxy4khynrdvk	cmny9fdam000avxy4a12zuxjj	82000	2026-04-14 06:48:42.381	2026-04-14 06:48:42.381
cmny9g49y01r4vxy496tkimte	cmny9g43101qkvxy4khynrdvk	cmny9fdb9000bvxy4h02fexen	94000	2026-04-14 06:48:42.406	2026-04-14 06:48:42.406
cmny9g4am01r6vxy48ahan5hl	cmny9g43101qkvxy4khynrdvk	cmny9fdc1000cvxy4n4y9ezu8	94000	2026-04-14 06:48:42.431	2026-04-14 06:48:42.431
cmny9g4bc01r8vxy4d3ebaabb	cmny9g43101qkvxy4khynrdvk	cmny9fdcn000dvxy4w3gaald5	94000	2026-04-14 06:48:42.456	2026-04-14 06:48:42.456
cmny9g4cg01rbvxy4eehyb1i5	cmny9g4bu01r9vxy4n8td0f7o	cmny9fd420001vxy42djthn1o	100000	2026-04-14 06:48:42.496	2026-04-14 06:48:42.496
cmny9g4cy01rdvxy4zqjhm05g	cmny9g4bu01r9vxy4n8td0f7o	cmny9fd4t0002vxy4jo0l7gop	100000	2026-04-14 06:48:42.514	2026-04-14 06:48:42.514
cmny9g4dm01rfvxy4xqdeebs8	cmny9g4bu01r9vxy4n8td0f7o	cmny9fd5j0003vxy4sw5e14p1	100000	2026-04-14 06:48:42.538	2026-04-14 06:48:42.538
cmny9g4ec01rhvxy40194yo80	cmny9g4bu01r9vxy4n8td0f7o	cmny9fd6h0004vxy4evm3jgfv	100000	2026-04-14 06:48:42.564	2026-04-14 06:48:42.564
cmny9g4f901rjvxy4udk6afqy	cmny9g4bu01r9vxy4n8td0f7o	cmny9fd7u0006vxy4mh4wwui4	100000	2026-04-14 06:48:42.598	2026-04-14 06:48:42.598
cmny9g4hn01rlvxy4p0e4nphn	cmny9g4bu01r9vxy4n8td0f7o	cmny9fd980008vxy4alsawn4y	100000	2026-04-14 06:48:42.683	2026-04-14 06:48:42.683
cmny9g4if01rnvxy4kj1jowsj	cmny9g4bu01r9vxy4n8td0f7o	cmny9fdb9000bvxy4h02fexen	100000	2026-04-14 06:48:42.711	2026-04-14 06:48:42.711
cmny9g4j601rpvxy4ivwt71r7	cmny9g4bu01r9vxy4n8td0f7o	cmny9fdc1000cvxy4n4y9ezu8	100000	2026-04-14 06:48:42.739	2026-04-14 06:48:42.739
cmny9g4jw01rrvxy44hu7vgo5	cmny9g4bu01r9vxy4n8td0f7o	cmny9fdcn000dvxy4w3gaald5	100000	2026-04-14 06:48:42.764	2026-04-14 06:48:42.764
cmny9g4l301ruvxy40spkc6ds	cmny9g4kk01rsvxy4a9ht03o5	cmny9fd420001vxy42djthn1o	95000	2026-04-14 06:48:42.807	2026-04-14 06:48:42.807
cmny9g4lo01rwvxy4w72mw9qi	cmny9g4kk01rsvxy4a9ht03o5	cmny9fd4t0002vxy4jo0l7gop	95000	2026-04-14 06:48:42.828	2026-04-14 06:48:42.828
cmny9g4m701ryvxy469nkz43a	cmny9g4kk01rsvxy4a9ht03o5	cmny9fd5j0003vxy4sw5e14p1	95000	2026-04-14 06:48:42.847	2026-04-14 06:48:42.847
cmny9g4mw01s0vxy4hn6eh8a0	cmny9g4kk01rsvxy4a9ht03o5	cmny9fd6h0004vxy4evm3jgfv	95000	2026-04-14 06:48:42.872	2026-04-14 06:48:42.872
cmny9g4nn01s2vxy488ixcjfp	cmny9g4kk01rsvxy4a9ht03o5	cmny9fd7u0006vxy4mh4wwui4	95000	2026-04-14 06:48:42.899	2026-04-14 06:48:42.899
cmny9g4oa01s4vxy4ig8qrdc7	cmny9g4kk01rsvxy4a9ht03o5	cmny9fd8i0007vxy4tmc0glr0	90000	2026-04-14 06:48:42.922	2026-04-14 06:48:42.922
cmny9g4or01s6vxy49ry9ve2w	cmny9g4kk01rsvxy4a9ht03o5	cmny9fd980008vxy4alsawn4y	95000	2026-04-14 06:48:42.94	2026-04-14 06:48:42.94
cmny9g4pe01s8vxy46wloxuet	cmny9g4kk01rsvxy4a9ht03o5	cmny9fd9w0009vxy498vvvu1d	90000	2026-04-14 06:48:42.962	2026-04-14 06:48:42.962
cmny9g4pw01savxy4woyh837l	cmny9g4kk01rsvxy4a9ht03o5	cmny9fdam000avxy4a12zuxjj	90000	2026-04-14 06:48:42.981	2026-04-14 06:48:42.981
cmny9g4ql01scvxy4zboutzog	cmny9g4kk01rsvxy4a9ht03o5	cmny9fdb9000bvxy4h02fexen	95000	2026-04-14 06:48:43.005	2026-04-14 06:48:43.005
cmny9g4ra01sevxy4my1d6ygp	cmny9g4kk01rsvxy4a9ht03o5	cmny9fdc1000cvxy4n4y9ezu8	95000	2026-04-14 06:48:43.031	2026-04-14 06:48:43.031
cmny9g4s501sgvxy4t5j3how7	cmny9g4kk01rsvxy4a9ht03o5	cmny9fdcn000dvxy4w3gaald5	95000	2026-04-14 06:48:43.062	2026-04-14 06:48:43.062
cmny9g4td01sjvxy4ou62y4g2	cmny9g4so01shvxy4npifelgr	cmny9fd420001vxy42djthn1o	95000	2026-04-14 06:48:43.106	2026-04-14 06:48:43.106
cmny9g4u301slvxy4vknkj1de	cmny9g4so01shvxy4npifelgr	cmny9fd4t0002vxy4jo0l7gop	95000	2026-04-14 06:48:43.131	2026-04-14 06:48:43.131
cmny9g4ur01snvxy4nebc8r3l	cmny9g4so01shvxy4npifelgr	cmny9fd5j0003vxy4sw5e14p1	95000	2026-04-14 06:48:43.155	2026-04-14 06:48:43.155
cmny9g4vh01spvxy4tqmtt1qi	cmny9g4so01shvxy4npifelgr	cmny9fd6h0004vxy4evm3jgfv	95000	2026-04-14 06:48:43.182	2026-04-14 06:48:43.182
cmny9g4w801srvxy4nitr2tfu	cmny9g4so01shvxy4npifelgr	cmny9fd7u0006vxy4mh4wwui4	95000	2026-04-14 06:48:43.208	2026-04-14 06:48:43.208
cmny9g4wv01stvxy4fiivia5x	cmny9g4so01shvxy4npifelgr	cmny9fd8i0007vxy4tmc0glr0	90000	2026-04-14 06:48:43.231	2026-04-14 06:48:43.231
cmny9g4xk01svvxy4agd548gu	cmny9g4so01shvxy4npifelgr	cmny9fd980008vxy4alsawn4y	95000	2026-04-14 06:48:43.256	2026-04-14 06:48:43.256
cmny9g4y901sxvxy426homdtc	cmny9g4so01shvxy4npifelgr	cmny9fd9w0009vxy498vvvu1d	90000	2026-04-14 06:48:43.281	2026-04-14 06:48:43.281
cmny9g4yw01szvxy4slvuil86	cmny9g4so01shvxy4npifelgr	cmny9fdam000avxy4a12zuxjj	90000	2026-04-14 06:48:43.305	2026-04-14 06:48:43.305
cmny9g4zf01t1vxy4anhy2ime	cmny9g4so01shvxy4npifelgr	cmny9fdb9000bvxy4h02fexen	95000	2026-04-14 06:48:43.323	2026-04-14 06:48:43.323
cmny9g50001t3vxy4nxsyofvu	cmny9g4so01shvxy4npifelgr	cmny9fdc1000cvxy4n4y9ezu8	95000	2026-04-14 06:48:43.345	2026-04-14 06:48:43.345
cmny9g50k01t5vxy43ihgzmh6	cmny9g4so01shvxy4npifelgr	cmny9fdcn000dvxy4w3gaald5	95000	2026-04-14 06:48:43.365	2026-04-14 06:48:43.365
cmny9g51r01t8vxy4gh5find3	cmny9g51801t6vxy4cg7uy0ib	cmny9fd420001vxy42djthn1o	95000	2026-04-14 06:48:43.407	2026-04-14 06:48:43.407
cmny9g52t01tavxy492ikq5zw	cmny9g51801t6vxy4cg7uy0ib	cmny9fd4t0002vxy4jo0l7gop	95000	2026-04-14 06:48:43.445	2026-04-14 06:48:43.445
cmny9g53c01tcvxy4xav21byi	cmny9g51801t6vxy4cg7uy0ib	cmny9fd5j0003vxy4sw5e14p1	95000	2026-04-14 06:48:43.464	2026-04-14 06:48:43.464
cmny9g54101tevxy4jzkumjfs	cmny9g51801t6vxy4cg7uy0ib	cmny9fd6h0004vxy4evm3jgfv	95000	2026-04-14 06:48:43.489	2026-04-14 06:48:43.489
cmny9g54s01tgvxy4f2qjm2xd	cmny9g51801t6vxy4cg7uy0ib	cmny9fd7u0006vxy4mh4wwui4	95000	2026-04-14 06:48:43.516	2026-04-14 06:48:43.516
cmny9g55e01tivxy465yq9ip6	cmny9g51801t6vxy4cg7uy0ib	cmny9fd8i0007vxy4tmc0glr0	82000	2026-04-14 06:48:43.539	2026-04-14 06:48:43.539
cmny9g55w01tkvxy47nkkgfmq	cmny9g51801t6vxy4cg7uy0ib	cmny9fd980008vxy4alsawn4y	95000	2026-04-14 06:48:43.556	2026-04-14 06:48:43.556
cmny9g56j01tmvxy4pbt50hab	cmny9g51801t6vxy4cg7uy0ib	cmny9fd9w0009vxy498vvvu1d	82000	2026-04-14 06:48:43.579	2026-04-14 06:48:43.579
cmny9g57a01tovxy4t1basliy	cmny9g51801t6vxy4cg7uy0ib	cmny9fdam000avxy4a12zuxjj	82000	2026-04-14 06:48:43.607	2026-04-14 06:48:43.607
cmny9g57x01tqvxy4ozpkbui7	cmny9g51801t6vxy4cg7uy0ib	cmny9fdb9000bvxy4h02fexen	95000	2026-04-14 06:48:43.629	2026-04-14 06:48:43.629
cmny9g58g01tsvxy4fheo0wzm	cmny9g51801t6vxy4cg7uy0ib	cmny9fdc1000cvxy4n4y9ezu8	95000	2026-04-14 06:48:43.648	2026-04-14 06:48:43.648
cmny9g59401tuvxy4v25j2z1d	cmny9g51801t6vxy4cg7uy0ib	cmny9fdcn000dvxy4w3gaald5	95000	2026-04-14 06:48:43.672	2026-04-14 06:48:43.672
cmny9g5ai01txvxy4s1lby7w9	cmny9g59u01tvvxy4bploaxya	cmny9fd420001vxy42djthn1o	84000	2026-04-14 06:48:43.722	2026-04-14 06:48:43.722
cmny9g5az01tzvxy490s91zxm	cmny9g59u01tvvxy4bploaxya	cmny9fd4t0002vxy4jo0l7gop	84000	2026-04-14 06:48:43.74	2026-04-14 06:48:43.74
cmny9g5bm01u1vxy4pevmy7nw	cmny9g59u01tvvxy4bploaxya	cmny9fd5j0003vxy4sw5e14p1	84000	2026-04-14 06:48:43.762	2026-04-14 06:48:43.762
cmny9g5c501u3vxy4ihcuwvwz	cmny9g59u01tvvxy4bploaxya	cmny9fd6h0004vxy4evm3jgfv	84000	2026-04-14 06:48:43.782	2026-04-14 06:48:43.782
cmny9g5cv01u5vxy4i03si49s	cmny9g59u01tvvxy4bploaxya	cmny9fd7u0006vxy4mh4wwui4	84000	2026-04-14 06:48:43.807	2026-04-14 06:48:43.807
cmny9g5dj01u7vxy4c17pbrql	cmny9g59u01tvvxy4bploaxya	cmny9fd8i0007vxy4tmc0glr0	84000	2026-04-14 06:48:43.831	2026-04-14 06:48:43.831
cmny9g5e701u9vxy4suo7huuv	cmny9g59u01tvvxy4bploaxya	cmny9fd980008vxy4alsawn4y	84000	2026-04-14 06:48:43.855	2026-04-14 06:48:43.855
cmny9g5ep01ubvxy4c1gc5ztc	cmny9g59u01tvvxy4bploaxya	cmny9fd9w0009vxy498vvvu1d	84000	2026-04-14 06:48:43.873	2026-04-14 06:48:43.873
cmny9g5fc01udvxy4clidfe8q	cmny9g59u01tvvxy4bploaxya	cmny9fdam000avxy4a12zuxjj	84000	2026-04-14 06:48:43.896	2026-04-14 06:48:43.896
cmny9g5fu01ufvxy46zw130sw	cmny9g59u01tvvxy4bploaxya	cmny9fdb9000bvxy4h02fexen	84000	2026-04-14 06:48:43.915	2026-04-14 06:48:43.915
cmny9g5gi01uhvxy4kkalgc6j	cmny9g59u01tvvxy4bploaxya	cmny9fdc1000cvxy4n4y9ezu8	84000	2026-04-14 06:48:43.938	2026-04-14 06:48:43.938
cmny9g5h001ujvxy40nsieftf	cmny9g59u01tvvxy4bploaxya	cmny9fdcn000dvxy4w3gaald5	84000	2026-04-14 06:48:43.957	2026-04-14 06:48:43.957
cmny9g5i501umvxy4g8c9zxmq	cmny9g5hm01ukvxy45l3qkd8d	cmny9fd420001vxy42djthn1o	95000	2026-04-14 06:48:43.998	2026-04-14 06:48:43.998
cmny9g5it01uovxy4hzyqmdcf	cmny9g5hm01ukvxy45l3qkd8d	cmny9fd4t0002vxy4jo0l7gop	95000	2026-04-14 06:48:44.021	2026-04-14 06:48:44.021
cmny9g5jb01uqvxy4nqwcsrhz	cmny9g5hm01ukvxy45l3qkd8d	cmny9fd5j0003vxy4sw5e14p1	95000	2026-04-14 06:48:44.039	2026-04-14 06:48:44.039
cmny9g5jy01usvxy49sli2a0o	cmny9g5hm01ukvxy45l3qkd8d	cmny9fd6h0004vxy4evm3jgfv	95000	2026-04-14 06:48:44.062	2026-04-14 06:48:44.062
cmny9g5ki01uuvxy4bdt2kgcy	cmny9g5hm01ukvxy45l3qkd8d	cmny9fd7u0006vxy4mh4wwui4	95000	2026-04-14 06:48:44.082	2026-04-14 06:48:44.082
cmny9g5l501uwvxy4lg2550wc	cmny9g5hm01ukvxy45l3qkd8d	cmny9fd8i0007vxy4tmc0glr0	95000	2026-04-14 06:48:44.105	2026-04-14 06:48:44.105
cmny9g5lv01uyvxy4lyuhnqmo	cmny9g5hm01ukvxy45l3qkd8d	cmny9fd980008vxy4alsawn4y	95000	2026-04-14 06:48:44.132	2026-04-14 06:48:44.132
cmny9g5mk01v0vxy4s6a9gmqc	cmny9g5hm01ukvxy45l3qkd8d	cmny9fd9w0009vxy498vvvu1d	95000	2026-04-14 06:48:44.156	2026-04-14 06:48:44.156
cmny9g5nb01v2vxy4yorx5bfz	cmny9g5hm01ukvxy45l3qkd8d	cmny9fdb9000bvxy4h02fexen	95000	2026-04-14 06:48:44.183	2026-04-14 06:48:44.183
cmny9g5nx01v4vxy4sv7wczhu	cmny9g5hm01ukvxy45l3qkd8d	cmny9fdc1000cvxy4n4y9ezu8	95000	2026-04-14 06:48:44.205	2026-04-14 06:48:44.205
cmny9g5of01v6vxy42h2khiu8	cmny9g5hm01ukvxy45l3qkd8d	cmny9fdcn000dvxy4w3gaald5	95000	2026-04-14 06:48:44.223	2026-04-14 06:48:44.223
cmny9g5pk01v9vxy4b9lkvolu	cmny9g5p101v7vxy4523xbtl1	cmny9fd420001vxy42djthn1o	140000	2026-04-14 06:48:44.265	2026-04-14 06:48:44.265
cmny9g5q801vbvxy480sch96c	cmny9g5p101v7vxy4523xbtl1	cmny9fd4t0002vxy4jo0l7gop	140000	2026-04-14 06:48:44.288	2026-04-14 06:48:44.288
cmny9g5qq01vdvxy4gtnqx8fz	cmny9g5p101v7vxy4523xbtl1	cmny9fd5j0003vxy4sw5e14p1	140000	2026-04-14 06:48:44.306	2026-04-14 06:48:44.306
cmny9g5rc01vfvxy4m3obgefk	cmny9g5p101v7vxy4523xbtl1	cmny9fd6h0004vxy4evm3jgfv	140000	2026-04-14 06:48:44.329	2026-04-14 06:48:44.329
cmny9g5rx01vhvxy4wbmm5tro	cmny9g5p101v7vxy4523xbtl1	cmny9fd7u0006vxy4mh4wwui4	140000	2026-04-14 06:48:44.35	2026-04-14 06:48:44.35
cmny9g5sk01vjvxy4rx2ysoo5	cmny9g5p101v7vxy4523xbtl1	cmny9fd8i0007vxy4tmc0glr0	140000	2026-04-14 06:48:44.372	2026-04-14 06:48:44.372
cmny9g5t201vlvxy4v48vh72c	cmny9g5p101v7vxy4523xbtl1	cmny9fd980008vxy4alsawn4y	140000	2026-04-14 06:48:44.39	2026-04-14 06:48:44.39
cmny9g5to01vnvxy46omp15gt	cmny9g5p101v7vxy4523xbtl1	cmny9fd9w0009vxy498vvvu1d	128000	2026-04-14 06:48:44.412	2026-04-14 06:48:44.412
cmny9g5u801vpvxy4uusa89ta	cmny9g5p101v7vxy4523xbtl1	cmny9fdam000avxy4a12zuxjj	128000	2026-04-14 06:48:44.432	2026-04-14 06:48:44.432
cmny9g5uw01vrvxy4dxgz0vg9	cmny9g5p101v7vxy4523xbtl1	cmny9fdb9000bvxy4h02fexen	140000	2026-04-14 06:48:44.456	2026-04-14 06:48:44.456
cmny9g5vd01vtvxy4gsweatl8	cmny9g5p101v7vxy4523xbtl1	cmny9fdc1000cvxy4n4y9ezu8	140000	2026-04-14 06:48:44.473	2026-04-14 06:48:44.473
cmny9g5vz01vvvxy4011zdkml	cmny9g5p101v7vxy4523xbtl1	cmny9fdcn000dvxy4w3gaald5	140000	2026-04-14 06:48:44.495	2026-04-14 06:48:44.495
cmny9g5x601vyvxy4yydh1674	cmny9g5wi01vwvxy41ndhmxyk	cmny9fd420001vxy42djthn1o	166000	2026-04-14 06:48:44.538	2026-04-14 06:48:44.538
cmny9g5xo01w0vxy4h8ypfgm3	cmny9g5wi01vwvxy41ndhmxyk	cmny9fd4t0002vxy4jo0l7gop	166000	2026-04-14 06:48:44.556	2026-04-14 06:48:44.556
cmny9g5ya01w2vxy4v9e4tbe5	cmny9g5wi01vwvxy41ndhmxyk	cmny9fd5j0003vxy4sw5e14p1	166000	2026-04-14 06:48:44.578	2026-04-14 06:48:44.578
cmny9g5yu01w4vxy4aczq230z	cmny9g5wi01vwvxy41ndhmxyk	cmny9fd6h0004vxy4evm3jgfv	166000	2026-04-14 06:48:44.598	2026-04-14 06:48:44.598
cmny9g5zk01w6vxy43e0lcazd	cmny9g5wi01vwvxy41ndhmxyk	cmny9fd7u0006vxy4mh4wwui4	166000	2026-04-14 06:48:44.624	2026-04-14 06:48:44.624
cmny9g60801w8vxy4gaxdbydl	cmny9g5wi01vwvxy41ndhmxyk	cmny9fd8i0007vxy4tmc0glr0	166000	2026-04-14 06:48:44.648	2026-04-14 06:48:44.648
cmny9g60w01wavxy45w6g8c72	cmny9g5wi01vwvxy41ndhmxyk	cmny9fd980008vxy4alsawn4y	166000	2026-04-14 06:48:44.672	2026-04-14 06:48:44.672
cmny9g61d01wcvxy4lu5qimox	cmny9g5wi01vwvxy41ndhmxyk	cmny9fd9w0009vxy498vvvu1d	160000	2026-04-14 06:48:44.689	2026-04-14 06:48:44.689
cmny9g62501wevxy4lquw1fuw	cmny9g5wi01vwvxy41ndhmxyk	cmny9fdb9000bvxy4h02fexen	166000	2026-04-14 06:48:44.717	2026-04-14 06:48:44.717
cmny9g62s01wgvxy42uun48ty	cmny9g5wi01vwvxy41ndhmxyk	cmny9fdc1000cvxy4n4y9ezu8	166000	2026-04-14 06:48:44.74	2026-04-14 06:48:44.74
cmny9g63d01wivxy48gkjw745	cmny9g5wi01vwvxy41ndhmxyk	cmny9fdcn000dvxy4w3gaald5	166000	2026-04-14 06:48:44.762	2026-04-14 06:48:44.762
cmny9g64l01wlvxy4zcmwmqj3	cmny9g63x01wjvxy42n802n4o	cmny9fd420001vxy42djthn1o	61000	2026-04-14 06:48:44.805	2026-04-14 06:48:44.805
cmny9g65301wnvxy49layawfd	cmny9g63x01wjvxy42n802n4o	cmny9fd4t0002vxy4jo0l7gop	61000	2026-04-14 06:48:44.823	2026-04-14 06:48:44.823
cmny9g65p01wpvxy4qfwm9pj6	cmny9g63x01wjvxy42n802n4o	cmny9fd5j0003vxy4sw5e14p1	61000	2026-04-14 06:48:44.845	2026-04-14 06:48:44.845
cmny9g66901wrvxy4wk0m2sz7	cmny9g63x01wjvxy42n802n4o	cmny9fd6h0004vxy4evm3jgfv	61000	2026-04-14 06:48:44.865	2026-04-14 06:48:44.865
cmny9g66y01wtvxy45cpltfnd	cmny9g63x01wjvxy42n802n4o	cmny9fd7u0006vxy4mh4wwui4	61000	2026-04-14 06:48:44.891	2026-04-14 06:48:44.891
cmny9g67m01wvvxy4qjwu83gz	cmny9g63x01wjvxy42n802n4o	cmny9fd8i0007vxy4tmc0glr0	61000	2026-04-14 06:48:44.915	2026-04-14 06:48:44.915
cmny9g68a01wxvxy4d2a1299i	cmny9g63x01wjvxy42n802n4o	cmny9fd980008vxy4alsawn4y	61000	2026-04-14 06:48:44.938	2026-04-14 06:48:44.938
cmny9g69501wzvxy4sfq8l31l	cmny9g63x01wjvxy42n802n4o	cmny9fdb9000bvxy4h02fexen	61000	2026-04-14 06:48:44.969	2026-04-14 06:48:44.969
cmny9g69v01x1vxy4ipo94fil	cmny9g63x01wjvxy42n802n4o	cmny9fdc1000cvxy4n4y9ezu8	61000	2026-04-14 06:48:44.995	2026-04-14 06:48:44.995
cmny9g6af01x3vxy4xze5tz6p	cmny9g63x01wjvxy42n802n4o	cmny9fdcn000dvxy4w3gaald5	61000	2026-04-14 06:48:45.015	2026-04-14 06:48:45.015
cmny9g6bk01x6vxy4m7vymv5h	cmny9g6b201x4vxy4lspesloz	cmny9fd420001vxy42djthn1o	175000	2026-04-14 06:48:45.057	2026-04-14 06:48:45.057
cmny9g6c601x8vxy4c5g3kag0	cmny9g6b201x4vxy4lspesloz	cmny9fd4t0002vxy4jo0l7gop	175000	2026-04-14 06:48:45.079	2026-04-14 06:48:45.079
cmny9g6cq01xavxy4jtmb2zqw	cmny9g6b201x4vxy4lspesloz	cmny9fd5j0003vxy4sw5e14p1	175000	2026-04-14 06:48:45.098	2026-04-14 06:48:45.098
cmny9g6de01xcvxy44wenx7me	cmny9g6b201x4vxy4lspesloz	cmny9fd6h0004vxy4evm3jgfv	175000	2026-04-14 06:48:45.122	2026-04-14 06:48:45.122
cmny9g6e601xevxy4ygj6ls5o	cmny9g6b201x4vxy4lspesloz	cmny9fd7u0006vxy4mh4wwui4	175000	2026-04-14 06:48:45.15	2026-04-14 06:48:45.15
cmny9g6er01xgvxy4ypbu055c	cmny9g6b201x4vxy4lspesloz	cmny9fd8i0007vxy4tmc0glr0	175000	2026-04-14 06:48:45.171	2026-04-14 06:48:45.171
cmny9g6f901xivxy4jnj1upn6	cmny9g6b201x4vxy4lspesloz	cmny9fd980008vxy4alsawn4y	175000	2026-04-14 06:48:45.19	2026-04-14 06:48:45.19
cmny9g6fw01xkvxy4mo6v9vem	cmny9g6b201x4vxy4lspesloz	cmny9fd9w0009vxy498vvvu1d	160000	2026-04-14 06:48:45.212	2026-04-14 06:48:45.212
cmny9g6gf01xmvxy4s8d9xdf7	cmny9g6b201x4vxy4lspesloz	cmny9fdam000avxy4a12zuxjj	160000	2026-04-14 06:48:45.231	2026-04-14 06:48:45.231
cmny9g6h301xovxy44m917807	cmny9g6b201x4vxy4lspesloz	cmny9fdb9000bvxy4h02fexen	175000	2026-04-14 06:48:45.255	2026-04-14 06:48:45.255
cmny9g6hk01xqvxy4bes1m2p7	cmny9g6b201x4vxy4lspesloz	cmny9fdc1000cvxy4n4y9ezu8	175000	2026-04-14 06:48:45.273	2026-04-14 06:48:45.273
cmny9g6i701xsvxy411hn75ia	cmny9g6b201x4vxy4lspesloz	cmny9fdcn000dvxy4w3gaald5	175000	2026-04-14 06:48:45.295	2026-04-14 06:48:45.295
cmny9g6jl01xvvxy4cl7fkxmv	cmny9g6iq01xtvxy4vq4bscpb	cmny9fd420001vxy42djthn1o	175000	2026-04-14 06:48:45.345	2026-04-14 06:48:45.345
cmny9g6k501xxvxy44d0nm53c	cmny9g6iq01xtvxy4vq4bscpb	cmny9fd4t0002vxy4jo0l7gop	175000	2026-04-14 06:48:45.365	2026-04-14 06:48:45.365
cmny9g6ks01xzvxy47p3y95wf	cmny9g6iq01xtvxy4vq4bscpb	cmny9fd5j0003vxy4sw5e14p1	175000	2026-04-14 06:48:45.389	2026-04-14 06:48:45.389
cmny9g6lr01y1vxy4zvejfo9v	cmny9g6iq01xtvxy4vq4bscpb	cmny9fd6h0004vxy4evm3jgfv	175000	2026-04-14 06:48:45.423	2026-04-14 06:48:45.423
cmny9g6n301y3vxy4579k8880	cmny9g6iq01xtvxy4vq4bscpb	cmny9fd7u0006vxy4mh4wwui4	175000	2026-04-14 06:48:45.47	2026-04-14 06:48:45.47
cmny9g6o301y5vxy4rc2fpdas	cmny9g6iq01xtvxy4vq4bscpb	cmny9fd8i0007vxy4tmc0glr0	175000	2026-04-14 06:48:45.507	2026-04-14 06:48:45.507
cmny9g6p101y7vxy47qjwrvad	cmny9g6iq01xtvxy4vq4bscpb	cmny9fd980008vxy4alsawn4y	175000	2026-04-14 06:48:45.541	2026-04-14 06:48:45.541
cmny9g6px01y9vxy4e390cuaq	cmny9g6iq01xtvxy4vq4bscpb	cmny9fd9w0009vxy498vvvu1d	160000	2026-04-14 06:48:45.573	2026-04-14 06:48:45.573
cmny9g6qq01ybvxy4iqm9vud2	cmny9g6iq01xtvxy4vq4bscpb	cmny9fdam000avxy4a12zuxjj	160000	2026-04-14 06:48:45.601	2026-04-14 06:48:45.601
cmny9g6ru01ydvxy42bp15tb2	cmny9g6iq01xtvxy4vq4bscpb	cmny9fdb9000bvxy4h02fexen	175000	2026-04-14 06:48:45.642	2026-04-14 06:48:45.642
cmny9g6sw01yfvxy40szohoga	cmny9g6iq01xtvxy4vq4bscpb	cmny9fdc1000cvxy4n4y9ezu8	175000	2026-04-14 06:48:45.68	2026-04-14 06:48:45.68
cmny9g6tg01yhvxy4dwc39cuc	cmny9g6iq01xtvxy4vq4bscpb	cmny9fdcn000dvxy4w3gaald5	175000	2026-04-14 06:48:45.701	2026-04-14 06:48:45.701
cmny9g6us01ykvxy43h4oej1u	cmny9g6ua01yivxy4dn7aprmo	cmny9fd420001vxy42djthn1o	175000	2026-04-14 06:48:45.749	2026-04-14 06:48:45.749
cmny9g6vm01ymvxy4es3myyco	cmny9g6ua01yivxy4dn7aprmo	cmny9fd4t0002vxy4jo0l7gop	175000	2026-04-14 06:48:45.777	2026-04-14 06:48:45.777
cmny9g6w701yovxy4rds6u9sr	cmny9g6ua01yivxy4dn7aprmo	cmny9fd5j0003vxy4sw5e14p1	175000	2026-04-14 06:48:45.799	2026-04-14 06:48:45.799
cmny9g6wu01yqvxy4vt6z5dws	cmny9g6ua01yivxy4dn7aprmo	cmny9fd6h0004vxy4evm3jgfv	175000	2026-04-14 06:48:45.823	2026-04-14 06:48:45.823
cmny9g6y201ysvxy4e41vpi4h	cmny9g6ua01yivxy4dn7aprmo	cmny9fd7u0006vxy4mh4wwui4	175000	2026-04-14 06:48:45.866	2026-04-14 06:48:45.866
cmny9g6yo01yuvxy472xhef5i	cmny9g6ua01yivxy4dn7aprmo	cmny9fd8i0007vxy4tmc0glr0	175000	2026-04-14 06:48:45.888	2026-04-14 06:48:45.888
cmny9g6z601ywvxy46u3t2ora	cmny9g6ua01yivxy4dn7aprmo	cmny9fd980008vxy4alsawn4y	175000	2026-04-14 06:48:45.906	2026-04-14 06:48:45.906
cmny9g6zv01yyvxy4q09wcdiy	cmny9g6ua01yivxy4dn7aprmo	cmny9fd9w0009vxy498vvvu1d	160000	2026-04-14 06:48:45.931	2026-04-14 06:48:45.931
cmny9g71401z0vxy4c18unl95	cmny9g6ua01yivxy4dn7aprmo	cmny9fdam000avxy4a12zuxjj	160000	2026-04-14 06:48:45.976	2026-04-14 06:48:45.976
cmny9g72401z2vxy4axoc6hx2	cmny9g6ua01yivxy4dn7aprmo	cmny9fdb9000bvxy4h02fexen	175000	2026-04-14 06:48:46.012	2026-04-14 06:48:46.012
cmny9g72o01z4vxy4mh6cpop1	cmny9g6ua01yivxy4dn7aprmo	cmny9fdc1000cvxy4n4y9ezu8	175000	2026-04-14 06:48:46.032	2026-04-14 06:48:46.032
cmny9g73t01z6vxy4255fvjmv	cmny9g6ua01yivxy4dn7aprmo	cmny9fdcn000dvxy4w3gaald5	175000	2026-04-14 06:48:46.073	2026-04-14 06:48:46.073
cmny9g75701z9vxy42jn039hv	cmny9g74f01z7vxy4k4k0zbhv	cmny9fd420001vxy42djthn1o	158000	2026-04-14 06:48:46.123	2026-04-14 06:48:46.123
cmny9g75s01zbvxy43oabby3x	cmny9g74f01z7vxy4k4k0zbhv	cmny9fd4t0002vxy4jo0l7gop	158000	2026-04-14 06:48:46.144	2026-04-14 06:48:46.144
cmny9g76d01zdvxy4yik2ek12	cmny9g74f01z7vxy4k4k0zbhv	cmny9fd5j0003vxy4sw5e14p1	158000	2026-04-14 06:48:46.165	2026-04-14 06:48:46.165
cmny9g77001zfvxy45n17fgut	cmny9g74f01z7vxy4k4k0zbhv	cmny9fd6h0004vxy4evm3jgfv	158000	2026-04-14 06:48:46.189	2026-04-14 06:48:46.189
cmny9g77k01zhvxy4y3y6oidm	cmny9g74f01z7vxy4k4k0zbhv	cmny9fd7u0006vxy4mh4wwui4	158000	2026-04-14 06:48:46.208	2026-04-14 06:48:46.208
cmny9g78d01zjvxy4i3kv8tze	cmny9g74f01z7vxy4k4k0zbhv	cmny9fd8i0007vxy4tmc0glr0	158000	2026-04-14 06:48:46.238	2026-04-14 06:48:46.238
cmny9g78w01zlvxy49fav7sdj	cmny9g74f01z7vxy4k4k0zbhv	cmny9fd980008vxy4alsawn4y	158000	2026-04-14 06:48:46.256	2026-04-14 06:48:46.256
cmny9g79i01znvxy47klggqya	cmny9g74f01z7vxy4k4k0zbhv	cmny9fd9w0009vxy498vvvu1d	148000	2026-04-14 06:48:46.278	2026-04-14 06:48:46.278
cmny9g7a201zpvxy40uilhl6r	cmny9g74f01z7vxy4k4k0zbhv	cmny9fdam000avxy4a12zuxjj	135000	2026-04-14 06:48:46.298	2026-04-14 06:48:46.298
cmny9g7ap01zrvxy4gva11mye	cmny9g74f01z7vxy4k4k0zbhv	cmny9fdb9000bvxy4h02fexen	158000	2026-04-14 06:48:46.322	2026-04-14 06:48:46.322
cmny9g7b801ztvxy4ut7c6t8l	cmny9g74f01z7vxy4k4k0zbhv	cmny9fdc1000cvxy4n4y9ezu8	158000	2026-04-14 06:48:46.34	2026-04-14 06:48:46.34
cmny9g7bt01zvvxy4mwvewjeq	cmny9g74f01z7vxy4k4k0zbhv	cmny9fdcn000dvxy4w3gaald5	158000	2026-04-14 06:48:46.362	2026-04-14 06:48:46.362
cmny9g7d101zyvxy40oieve8p	cmny9g7cd01zwvxy48cxjla2t	cmny9fd420001vxy42djthn1o	56000	2026-04-14 06:48:46.405	2026-04-14 06:48:46.405
cmny9g7dj0200vxy4i885lyt3	cmny9g7cd01zwvxy48cxjla2t	cmny9fd4t0002vxy4jo0l7gop	56000	2026-04-14 06:48:46.423	2026-04-14 06:48:46.423
cmny9g7e70202vxy4velf7imh	cmny9g7cd01zwvxy48cxjla2t	cmny9fd5j0003vxy4sw5e14p1	56000	2026-04-14 06:48:46.447	2026-04-14 06:48:46.447
cmny9g7ex0204vxy44u7gfrk3	cmny9g7cd01zwvxy48cxjla2t	cmny9fd6h0004vxy4evm3jgfv	56000	2026-04-14 06:48:46.474	2026-04-14 06:48:46.474
cmny9g7fk0206vxy42stpfxn1	cmny9g7cd01zwvxy48cxjla2t	cmny9fd7u0006vxy4mh4wwui4	56000	2026-04-14 06:48:46.497	2026-04-14 06:48:46.497
cmny9g7gx0208vxy4w3fh9ky2	cmny9g7cd01zwvxy48cxjla2t	cmny9fd8i0007vxy4tmc0glr0	56000	2026-04-14 06:48:46.545	2026-04-14 06:48:46.545
cmny9g7hg020avxy4irumqxz4	cmny9g7cd01zwvxy48cxjla2t	cmny9fd980008vxy4alsawn4y	56000	2026-04-14 06:48:46.565	2026-04-14 06:48:46.565
cmny9g7ia020cvxy4nc62gmkc	cmny9g7cd01zwvxy48cxjla2t	cmny9fdb9000bvxy4h02fexen	56000	2026-04-14 06:48:46.595	2026-04-14 06:48:46.595
cmny9g7iu020evxy4uhw3ptcg	cmny9g7cd01zwvxy48cxjla2t	cmny9fdc1000cvxy4n4y9ezu8	56000	2026-04-14 06:48:46.615	2026-04-14 06:48:46.615
cmny9g7ji020gvxy4tk3opk3f	cmny9g7cd01zwvxy48cxjla2t	cmny9fdcn000dvxy4w3gaald5	56000	2026-04-14 06:48:46.638	2026-04-14 06:48:46.638
cmny9g7ko020jvxy4952m3s3y	cmny9g7k0020hvxy46do5qh1y	cmny9fd420001vxy42djthn1o	56000	2026-04-14 06:48:46.68	2026-04-14 06:48:46.68
cmny9g7lf020lvxy4xql2pvap	cmny9g7k0020hvxy46do5qh1y	cmny9fd4t0002vxy4jo0l7gop	56000	2026-04-14 06:48:46.707	2026-04-14 06:48:46.707
cmny9g7mr020nvxy49zk90mfs	cmny9g7k0020hvxy46do5qh1y	cmny9fd5j0003vxy4sw5e14p1	56000	2026-04-14 06:48:46.755	2026-04-14 06:48:46.755
cmny9g7nh020pvxy4oqsef3wr	cmny9g7k0020hvxy46do5qh1y	cmny9fd6h0004vxy4evm3jgfv	56000	2026-04-14 06:48:46.781	2026-04-14 06:48:46.781
cmny9g7o7020rvxy4ds73kc10	cmny9g7k0020hvxy46do5qh1y	cmny9fd7u0006vxy4mh4wwui4	56000	2026-04-14 06:48:46.807	2026-04-14 06:48:46.807
cmny9g7ov020tvxy435g7uyrv	cmny9g7k0020hvxy46do5qh1y	cmny9fd8i0007vxy4tmc0glr0	56000	2026-04-14 06:48:46.832	2026-04-14 06:48:46.832
cmny9g7pi020vvxy4jtdmzvrz	cmny9g7k0020hvxy46do5qh1y	cmny9fd980008vxy4alsawn4y	56000	2026-04-14 06:48:46.854	2026-04-14 06:48:46.854
cmny9g7q7020xvxy47km71pxg	cmny9g7k0020hvxy46do5qh1y	cmny9fdb9000bvxy4h02fexen	56000	2026-04-14 06:48:46.88	2026-04-14 06:48:46.88
cmny9g7qw020zvxy4qjgjdzwm	cmny9g7k0020hvxy46do5qh1y	cmny9fdc1000cvxy4n4y9ezu8	56000	2026-04-14 06:48:46.904	2026-04-14 06:48:46.904
cmny9g7sb0211vxy4app96t4y	cmny9g7k0020hvxy46do5qh1y	cmny9fdcn000dvxy4w3gaald5	56000	2026-04-14 06:48:46.955	2026-04-14 06:48:46.955
cmny9g7tf0214vxy4gmijm9bv	cmny9g7st0212vxy49wsotw9v	cmny9fd420001vxy42djthn1o	56000	2026-04-14 06:48:46.995	2026-04-14 06:48:46.995
cmny9g7tz0216vxy43bzuw2oa	cmny9g7st0212vxy49wsotw9v	cmny9fd4t0002vxy4jo0l7gop	56000	2026-04-14 06:48:47.015	2026-04-14 06:48:47.015
cmny9g7um0218vxy45urmsvyu	cmny9g7st0212vxy49wsotw9v	cmny9fd5j0003vxy4sw5e14p1	56000	2026-04-14 06:48:47.038	2026-04-14 06:48:47.038
cmny9g7v4021avxy4b2rf0sjk	cmny9g7st0212vxy49wsotw9v	cmny9fd6h0004vxy4evm3jgfv	56000	2026-04-14 06:48:47.057	2026-04-14 06:48:47.057
cmny9g7vt021cvxy4cefp53sc	cmny9g7st0212vxy49wsotw9v	cmny9fd7u0006vxy4mh4wwui4	56000	2026-04-14 06:48:47.081	2026-04-14 06:48:47.081
cmny9g7wi021evxy4dnjo5yt7	cmny9g7st0212vxy49wsotw9v	cmny9fd8i0007vxy4tmc0glr0	56000	2026-04-14 06:48:47.107	2026-04-14 06:48:47.107
cmny9g7xo021gvxy4r40akdq1	cmny9g7st0212vxy49wsotw9v	cmny9fd980008vxy4alsawn4y	56000	2026-04-14 06:48:47.148	2026-04-14 06:48:47.148
cmny9g7yj021ivxy4cprm8gxf	cmny9g7st0212vxy49wsotw9v	cmny9fdb9000bvxy4h02fexen	56000	2026-04-14 06:48:47.179	2026-04-14 06:48:47.179
cmny9g7z9021kvxy4uxoqj1ui	cmny9g7st0212vxy49wsotw9v	cmny9fdc1000cvxy4n4y9ezu8	56000	2026-04-14 06:48:47.205	2026-04-14 06:48:47.205
cmny9g800021mvxy4yh2zwogo	cmny9g7st0212vxy49wsotw9v	cmny9fdcn000dvxy4w3gaald5	56000	2026-04-14 06:48:47.232	2026-04-14 06:48:47.232
cmny9g815021pvxy4osa27ufk	cmny9g80n021nvxy4wbrssmdb	cmny9fd420001vxy42djthn1o	66000	2026-04-14 06:48:47.274	2026-04-14 06:48:47.274
cmny9g81r021rvxy4abi8r7g1	cmny9g80n021nvxy4wbrssmdb	cmny9fd4t0002vxy4jo0l7gop	66000	2026-04-14 06:48:47.295	2026-04-14 06:48:47.295
cmny9g82b021tvxy4yjufiw9k	cmny9g80n021nvxy4wbrssmdb	cmny9fd5j0003vxy4sw5e14p1	66000	2026-04-14 06:48:47.315	2026-04-14 06:48:47.315
cmny9g835021vvxy41ao6q1j1	cmny9g80n021nvxy4wbrssmdb	cmny9fd6h0004vxy4evm3jgfv	66000	2026-04-14 06:48:47.345	2026-04-14 06:48:47.345
cmny9g83r021xvxy4ez4p1b20	cmny9g80n021nvxy4wbrssmdb	cmny9fd7u0006vxy4mh4wwui4	66000	2026-04-14 06:48:47.367	2026-04-14 06:48:47.367
cmny9g84j021zvxy4t8ao6bso	cmny9g80n021nvxy4wbrssmdb	cmny9fd8i0007vxy4tmc0glr0	66000	2026-04-14 06:48:47.395	2026-04-14 06:48:47.395
cmny9g8530221vxy41p2ab6dq	cmny9g80n021nvxy4wbrssmdb	cmny9fd980008vxy4alsawn4y	66000	2026-04-14 06:48:47.416	2026-04-14 06:48:47.416
cmny9g85w0223vxy47pgrfcl7	cmny9g80n021nvxy4wbrssmdb	cmny9fdb9000bvxy4h02fexen	66000	2026-04-14 06:48:47.444	2026-04-14 06:48:47.444
cmny9g86h0225vxy4lw3gue8n	cmny9g80n021nvxy4wbrssmdb	cmny9fdc1000cvxy4n4y9ezu8	66000	2026-04-14 06:48:47.465	2026-04-14 06:48:47.465
cmny9g8740227vxy4ya44zj7u	cmny9g80n021nvxy4wbrssmdb	cmny9fdcn000dvxy4w3gaald5	66000	2026-04-14 06:48:47.488	2026-04-14 06:48:47.488
cmny9g888022avxy4hxqjtkpc	cmny9g87n0228vxy48fcucjjk	cmny9fd420001vxy42djthn1o	66000	2026-04-14 06:48:47.529	2026-04-14 06:48:47.529
cmny9g88s022cvxy4yyqc9tel	cmny9g87n0228vxy48fcucjjk	cmny9fd4t0002vxy4jo0l7gop	66000	2026-04-14 06:48:47.548	2026-04-14 06:48:47.548
cmny9g89f022evxy4cn1lz98d	cmny9g87n0228vxy48fcucjjk	cmny9fd5j0003vxy4sw5e14p1	66000	2026-04-14 06:48:47.572	2026-04-14 06:48:47.572
cmny9g89y022gvxy4nzeg00qh	cmny9g87n0228vxy48fcucjjk	cmny9fd6h0004vxy4evm3jgfv	66000	2026-04-14 06:48:47.59	2026-04-14 06:48:47.59
cmny9g8am022ivxy4nlg8y8n7	cmny9g87n0228vxy48fcucjjk	cmny9fd7u0006vxy4mh4wwui4	66000	2026-04-14 06:48:47.614	2026-04-14 06:48:47.614
cmny9g8b3022kvxy47i9vgtp5	cmny9g87n0228vxy48fcucjjk	cmny9fd8i0007vxy4tmc0glr0	66000	2026-04-14 06:48:47.631	2026-04-14 06:48:47.631
cmny9g8br022mvxy4y2lr2bgn	cmny9g87n0228vxy48fcucjjk	cmny9fd980008vxy4alsawn4y	66000	2026-04-14 06:48:47.655	2026-04-14 06:48:47.655
cmny9g8cl022ovxy4ece88jrq	cmny9g87n0228vxy48fcucjjk	cmny9fdb9000bvxy4h02fexen	66000	2026-04-14 06:48:47.685	2026-04-14 06:48:47.685
cmny9g8dc022qvxy4vkmczmmz	cmny9g87n0228vxy48fcucjjk	cmny9fdc1000cvxy4n4y9ezu8	66000	2026-04-14 06:48:47.712	2026-04-14 06:48:47.712
cmny9g8dw022svxy4x59m7dsc	cmny9g87n0228vxy48fcucjjk	cmny9fdcn000dvxy4w3gaald5	66000	2026-04-14 06:48:47.732	2026-04-14 06:48:47.732
cmny9g8f1022vvxy4uq5l5qo9	cmny9g8ej022tvxy465wj5qd2	cmny9fd420001vxy42djthn1o	66000	2026-04-14 06:48:47.773	2026-04-14 06:48:47.773
cmny9g8fp022xvxy4adlajm45	cmny9g8ej022tvxy465wj5qd2	cmny9fd4t0002vxy4jo0l7gop	66000	2026-04-14 06:48:47.797	2026-04-14 06:48:47.797
cmny9g8gu022zvxy4952h747r	cmny9g8ej022tvxy465wj5qd2	cmny9fd5j0003vxy4sw5e14p1	66000	2026-04-14 06:48:47.838	2026-04-14 06:48:47.838
cmny9g8he0231vxy4qi7liqzt	cmny9g8ej022tvxy465wj5qd2	cmny9fd6h0004vxy4evm3jgfv	66000	2026-04-14 06:48:47.858	2026-04-14 06:48:47.858
cmny9g8i20233vxy4i0mh54la	cmny9g8ej022tvxy465wj5qd2	cmny9fd7u0006vxy4mh4wwui4	66000	2026-04-14 06:48:47.882	2026-04-14 06:48:47.882
cmny9g8is0235vxy4tmjhtmws	cmny9g8ej022tvxy465wj5qd2	cmny9fd8i0007vxy4tmc0glr0	66000	2026-04-14 06:48:47.908	2026-04-14 06:48:47.908
cmny9g8jc0237vxy4aoawv6e1	cmny9g8ej022tvxy465wj5qd2	cmny9fd980008vxy4alsawn4y	66000	2026-04-14 06:48:47.929	2026-04-14 06:48:47.929
cmny9g8k40239vxy4ux5yd32x	cmny9g8ej022tvxy465wj5qd2	cmny9fdb9000bvxy4h02fexen	66000	2026-04-14 06:48:47.956	2026-04-14 06:48:47.956
cmny9g8kq023bvxy43oftkn7t	cmny9g8ej022tvxy465wj5qd2	cmny9fdc1000cvxy4n4y9ezu8	66000	2026-04-14 06:48:47.978	2026-04-14 06:48:47.978
cmny9g8lb023dvxy4hajg5499	cmny9g8ej022tvxy465wj5qd2	cmny9fdcn000dvxy4w3gaald5	66000	2026-04-14 06:48:47.999	2026-04-14 06:48:47.999
cmny9g8mx023gvxy482htf57c	cmny9g8me023evxy4nyefatpe	cmny9fd420001vxy42djthn1o	66000	2026-04-14 06:48:48.057	2026-04-14 06:48:48.057
cmny9g8ni023ivxy42z19evow	cmny9g8me023evxy4nyefatpe	cmny9fd4t0002vxy4jo0l7gop	66000	2026-04-14 06:48:48.078	2026-04-14 06:48:48.078
cmny9g8o2023kvxy47jfyfdw5	cmny9g8me023evxy4nyefatpe	cmny9fd5j0003vxy4sw5e14p1	66000	2026-04-14 06:48:48.098	2026-04-14 06:48:48.098
cmny9g8os023mvxy45lnd0vuq	cmny9g8me023evxy4nyefatpe	cmny9fd6h0004vxy4evm3jgfv	66000	2026-04-14 06:48:48.124	2026-04-14 06:48:48.124
cmny9g8ps023ovxy4q0kjggzh	cmny9g8me023evxy4nyefatpe	cmny9fd7u0006vxy4mh4wwui4	66000	2026-04-14 06:48:48.16	2026-04-14 06:48:48.16
cmny9g8qn023qvxy455e7s8o3	cmny9g8me023evxy4nyefatpe	cmny9fd8i0007vxy4tmc0glr0	66000	2026-04-14 06:48:48.191	2026-04-14 06:48:48.191
cmny9g8ra023svxy4md7vucuf	cmny9g8me023evxy4nyefatpe	cmny9fd980008vxy4alsawn4y	66000	2026-04-14 06:48:48.215	2026-04-14 06:48:48.215
cmny9g8s9023uvxy4kpb61zyb	cmny9g8me023evxy4nyefatpe	cmny9fdb9000bvxy4h02fexen	66000	2026-04-14 06:48:48.249	2026-04-14 06:48:48.249
cmny9g8sy023wvxy414w7ewob	cmny9g8me023evxy4nyefatpe	cmny9fdc1000cvxy4n4y9ezu8	66000	2026-04-14 06:48:48.274	2026-04-14 06:48:48.274
cmny9g8tj023yvxy4v73qjoeg	cmny9g8me023evxy4nyefatpe	cmny9fdcn000dvxy4w3gaald5	66000	2026-04-14 06:48:48.295	2026-04-14 06:48:48.295
cmny9g8uq0241vxy4gr6e1szm	cmny9g8u2023zvxy4p4hnu9m3	cmny9fd420001vxy42djthn1o	66000	2026-04-14 06:48:48.338	2026-04-14 06:48:48.338
cmny9g8vg0243vxy47jlzjjba	cmny9g8u2023zvxy4p4hnu9m3	cmny9fd4t0002vxy4jo0l7gop	66000	2026-04-14 06:48:48.365	2026-04-14 06:48:48.365
cmny9g8w50245vxy4optrsl38	cmny9g8u2023zvxy4p4hnu9m3	cmny9fd5j0003vxy4sw5e14p1	66000	2026-04-14 06:48:48.389	2026-04-14 06:48:48.389
cmny9g8wv0247vxy4scyz5ssr	cmny9g8u2023zvxy4p4hnu9m3	cmny9fd6h0004vxy4evm3jgfv	66000	2026-04-14 06:48:48.415	2026-04-14 06:48:48.415
cmny9g8y60249vxy4bdobpile	cmny9g8u2023zvxy4p4hnu9m3	cmny9fd7u0006vxy4mh4wwui4	66000	2026-04-14 06:48:48.462	2026-04-14 06:48:48.462
cmny9g8yq024bvxy44n9usmv9	cmny9g8u2023zvxy4p4hnu9m3	cmny9fd8i0007vxy4tmc0glr0	66000	2026-04-14 06:48:48.482	2026-04-14 06:48:48.482
cmny9g8zc024dvxy4pryj023i	cmny9g8u2023zvxy4p4hnu9m3	cmny9fd980008vxy4alsawn4y	66000	2026-04-14 06:48:48.504	2026-04-14 06:48:48.504
cmny9g903024fvxy4tqigrbx1	cmny9g8u2023zvxy4p4hnu9m3	cmny9fdb9000bvxy4h02fexen	66000	2026-04-14 06:48:48.532	2026-04-14 06:48:48.532
cmny9g90r024hvxy4831vaxrs	cmny9g8u2023zvxy4p4hnu9m3	cmny9fdc1000cvxy4n4y9ezu8	66000	2026-04-14 06:48:48.555	2026-04-14 06:48:48.555
cmny9g91h024jvxy4wzr6tg01	cmny9g8u2023zvxy4p4hnu9m3	cmny9fdcn000dvxy4w3gaald5	66000	2026-04-14 06:48:48.582	2026-04-14 06:48:48.582
cmny9g92v024mvxy4zr4s3umn	cmny9g926024kvxy4ngms690x	cmny9fd420001vxy42djthn1o	66000	2026-04-14 06:48:48.631	2026-04-14 06:48:48.631
cmny9g93q024ovxy42splwhoa	cmny9g926024kvxy4ngms690x	cmny9fd4t0002vxy4jo0l7gop	66000	2026-04-14 06:48:48.662	2026-04-14 06:48:48.662
cmny9g949024qvxy49ioqx5ok	cmny9g926024kvxy4ngms690x	cmny9fd5j0003vxy4sw5e14p1	66000	2026-04-14 06:48:48.682	2026-04-14 06:48:48.682
cmny9g94x024svxy4qqfgo7ni	cmny9g926024kvxy4ngms690x	cmny9fd6h0004vxy4evm3jgfv	66000	2026-04-14 06:48:48.705	2026-04-14 06:48:48.705
cmny9g95l024uvxy4kef29qhx	cmny9g926024kvxy4ngms690x	cmny9fd7u0006vxy4mh4wwui4	66000	2026-04-14 06:48:48.728	2026-04-14 06:48:48.728
cmny9g96b024wvxy4vh9sad41	cmny9g926024kvxy4ngms690x	cmny9fd8i0007vxy4tmc0glr0	66000	2026-04-14 06:48:48.755	2026-04-14 06:48:48.755
cmny9g96t024yvxy40lz3kaf7	cmny9g926024kvxy4ngms690x	cmny9fd980008vxy4alsawn4y	66000	2026-04-14 06:48:48.774	2026-04-14 06:48:48.774
cmny9g97i0250vxy42e319txb	cmny9g926024kvxy4ngms690x	cmny9fdb9000bvxy4h02fexen	66000	2026-04-14 06:48:48.798	2026-04-14 06:48:48.798
cmny9g97z0252vxy4d3ix44bu	cmny9g926024kvxy4ngms690x	cmny9fdc1000cvxy4n4y9ezu8	66000	2026-04-14 06:48:48.815	2026-04-14 06:48:48.815
cmny9g98m0254vxy4edjjxzco	cmny9g926024kvxy4ngms690x	cmny9fdcn000dvxy4w3gaald5	66000	2026-04-14 06:48:48.838	2026-04-14 06:48:48.838
cmny9g99q0257vxy48cayxoux	cmny9g9950255vxy4en14a9a8	cmny9fd420001vxy42djthn1o	35000	2026-04-14 06:48:48.879	2026-04-14 06:48:48.879
cmny9g9aa0259vxy477yh1nx1	cmny9g9950255vxy4en14a9a8	cmny9fd4t0002vxy4jo0l7gop	35000	2026-04-14 06:48:48.899	2026-04-14 06:48:48.899
cmny9g9ax025bvxy4o6pmvuyq	cmny9g9950255vxy4en14a9a8	cmny9fd5j0003vxy4sw5e14p1	35000	2026-04-14 06:48:48.921	2026-04-14 06:48:48.921
cmny9g9bg025dvxy407z5x9gd	cmny9g9950255vxy4en14a9a8	cmny9fd6h0004vxy4evm3jgfv	35000	2026-04-14 06:48:48.94	2026-04-14 06:48:48.94
cmny9g9c3025fvxy4khdvijuu	cmny9g9950255vxy4en14a9a8	cmny9fd7u0006vxy4mh4wwui4	35000	2026-04-14 06:48:48.964	2026-04-14 06:48:48.964
cmny9g9cl025hvxy44dtw1vta	cmny9g9950255vxy4en14a9a8	cmny9fd8i0007vxy4tmc0glr0	35000	2026-04-14 06:48:48.982	2026-04-14 06:48:48.982
cmny9g9d9025jvxy4d7w9xgtl	cmny9g9950255vxy4en14a9a8	cmny9fd980008vxy4alsawn4y	35000	2026-04-14 06:48:49.005	2026-04-14 06:48:49.005
cmny9g9dx025lvxy40qkpfp9o	cmny9g9950255vxy4en14a9a8	cmny9fdb9000bvxy4h02fexen	35000	2026-04-14 06:48:49.029	2026-04-14 06:48:49.029
cmny9g9eo025nvxy4f6dljo2t	cmny9g9950255vxy4en14a9a8	cmny9fdc1000cvxy4n4y9ezu8	35000	2026-04-14 06:48:49.056	2026-04-14 06:48:49.056
cmny9g9f5025pvxy4hesd4hvl	cmny9g9950255vxy4en14a9a8	cmny9fdcn000dvxy4w3gaald5	35000	2026-04-14 06:48:49.074	2026-04-14 06:48:49.074
cmny9g9gb025svxy4sukyuqhx	cmny9g9fr025qvxy4xolu59wy	cmny9fd420001vxy42djthn1o	35000	2026-04-14 06:48:49.115	2026-04-14 06:48:49.115
cmny9g9gy025uvxy44fa250ox	cmny9g9fr025qvxy4xolu59wy	cmny9fd4t0002vxy4jo0l7gop	35000	2026-04-14 06:48:49.138	2026-04-14 06:48:49.138
cmny9g9hg025wvxy4p3xl7b20	cmny9g9fr025qvxy4xolu59wy	cmny9fd5j0003vxy4sw5e14p1	35000	2026-04-14 06:48:49.157	2026-04-14 06:48:49.157
cmny9g9i2025yvxy4qhpekniu	cmny9g9fr025qvxy4xolu59wy	cmny9fd6h0004vxy4evm3jgfv	35000	2026-04-14 06:48:49.178	2026-04-14 06:48:49.178
cmny9g9j00260vxy4rzzhjmg0	cmny9g9fr025qvxy4xolu59wy	cmny9fd7u0006vxy4mh4wwui4	35000	2026-04-14 06:48:49.212	2026-04-14 06:48:49.212
cmny9g9jp0262vxy4n8ii7yfs	cmny9g9fr025qvxy4xolu59wy	cmny9fd8i0007vxy4tmc0glr0	35000	2026-04-14 06:48:49.238	2026-04-14 06:48:49.238
cmny9g9k90264vxy4af5vz6xq	cmny9g9fr025qvxy4xolu59wy	cmny9fd980008vxy4alsawn4y	35000	2026-04-14 06:48:49.257	2026-04-14 06:48:49.257
cmny9g9ky0266vxy4o5kgfeo8	cmny9g9fr025qvxy4xolu59wy	cmny9fdb9000bvxy4h02fexen	35000	2026-04-14 06:48:49.283	2026-04-14 06:48:49.283
cmny9g9ln0268vxy4wtu6lawr	cmny9g9fr025qvxy4xolu59wy	cmny9fdc1000cvxy4n4y9ezu8	35000	2026-04-14 06:48:49.307	2026-04-14 06:48:49.307
cmny9g9m8026avxy4o864bl46	cmny9g9fr025qvxy4xolu59wy	cmny9fdcn000dvxy4w3gaald5	35000	2026-04-14 06:48:49.328	2026-04-14 06:48:49.328
cmny9g9nf026dvxy4g5yledey	cmny9g9ms026bvxy4va0qhysp	cmny9fd420001vxy42djthn1o	35000	2026-04-14 06:48:49.371	2026-04-14 06:48:49.371
cmny9g9nz026fvxy453neoaz1	cmny9g9ms026bvxy4va0qhysp	cmny9fd4t0002vxy4jo0l7gop	35000	2026-04-14 06:48:49.391	2026-04-14 06:48:49.391
cmny9g9ok026hvxy45h4fzx8r	cmny9g9ms026bvxy4va0qhysp	cmny9fd5j0003vxy4sw5e14p1	35000	2026-04-14 06:48:49.412	2026-04-14 06:48:49.412
cmny9g9p4026jvxy4jn00gerk	cmny9g9ms026bvxy4va0qhysp	cmny9fd6h0004vxy4evm3jgfv	35000	2026-04-14 06:48:49.432	2026-04-14 06:48:49.432
cmny9g9pw026lvxy4il3v3s4o	cmny9g9ms026bvxy4va0qhysp	cmny9fd7u0006vxy4mh4wwui4	35000	2026-04-14 06:48:49.46	2026-04-14 06:48:49.46
cmny9g9qi026nvxy4fyp11lc9	cmny9g9ms026bvxy4va0qhysp	cmny9fd8i0007vxy4tmc0glr0	35000	2026-04-14 06:48:49.482	2026-04-14 06:48:49.482
cmny9g9rc026pvxy4ggfr72ep	cmny9g9ms026bvxy4va0qhysp	cmny9fd980008vxy4alsawn4y	35000	2026-04-14 06:48:49.512	2026-04-14 06:48:49.512
cmny9g9sa026rvxy4wgma6ook	cmny9g9ms026bvxy4va0qhysp	cmny9fdb9000bvxy4h02fexen	35000	2026-04-14 06:48:49.546	2026-04-14 06:48:49.546
cmny9g9t1026tvxy4bet7sum7	cmny9g9ms026bvxy4va0qhysp	cmny9fdc1000cvxy4n4y9ezu8	35000	2026-04-14 06:48:49.574	2026-04-14 06:48:49.574
cmny9g9ts026vvxy4wmg7vzq4	cmny9g9ms026bvxy4va0qhysp	cmny9fdcn000dvxy4w3gaald5	35000	2026-04-14 06:48:49.6	2026-04-14 06:48:49.6
cmny9g9vx026yvxy4vddr520y	cmny9g9uw026wvxy4yqubgqvp	cmny9fd6h0004vxy4evm3jgfv	25500	2026-04-14 06:48:49.678	2026-04-14 06:48:49.678
cmny9ga160273vxy4j4vv3mk8	cmny9ga0j0271vxy4o8ejwb2z	cmny9fd420001vxy42djthn1o	45000	2026-04-14 06:48:49.866	2026-04-14 06:48:49.866
cmny9ga1y0275vxy4edtfsobk	cmny9ga0j0271vxy4o8ejwb2z	cmny9fd4t0002vxy4jo0l7gop	45000	2026-04-14 06:48:49.894	2026-04-14 06:48:49.894
cmny9ga2k0277vxy4p26zxdd7	cmny9ga0j0271vxy4o8ejwb2z	cmny9fd5j0003vxy4sw5e14p1	48000	2026-04-14 06:48:49.916	2026-04-14 06:48:49.916
cmny9ga360279vxy4toud0ims	cmny9ga0j0271vxy4o8ejwb2z	cmny9fd6h0004vxy4evm3jgfv	37000	2026-04-14 06:48:49.939	2026-04-14 06:48:49.939
cmny9ga3q027bvxy4ahkdt1gg	cmny9ga0j0271vxy4o8ejwb2z	cmny9fd740005vxy44c2rf5rg	45000	2026-04-14 06:48:49.958	2026-04-14 06:48:49.958
cmny9ga4a027dvxy4uhu3xv93	cmny9ga0j0271vxy4o8ejwb2z	cmny9fd7u0006vxy4mh4wwui4	45000	2026-04-14 06:48:49.979	2026-04-14 06:48:49.979
cmny9ga4v027fvxy4blh02z9z	cmny9ga0j0271vxy4o8ejwb2z	cmny9fd8i0007vxy4tmc0glr0	45000	2026-04-14 06:48:49.999	2026-04-14 06:48:49.999
cmny9ga5i027hvxy4m56nzkio	cmny9ga0j0271vxy4o8ejwb2z	cmny9fd980008vxy4alsawn4y	45000	2026-04-14 06:48:50.022	2026-04-14 06:48:50.022
cmny9ga61027jvxy4odzmqzpr	cmny9ga0j0271vxy4o8ejwb2z	cmny9fd9w0009vxy498vvvu1d	45000	2026-04-14 06:48:50.041	2026-04-14 06:48:50.041
cmny9ga6o027lvxy4sqyqzlj0	cmny9ga0j0271vxy4o8ejwb2z	cmny9fdam000avxy4a12zuxjj	45000	2026-04-14 06:48:50.064	2026-04-14 06:48:50.064
cmny9ga7n027nvxy4yvj2zpwa	cmny9ga0j0271vxy4o8ejwb2z	cmny9fdb9000bvxy4h02fexen	48000	2026-04-14 06:48:50.099	2026-04-14 06:48:50.099
cmny9ga89027pvxy4596zbfq7	cmny9ga0j0271vxy4o8ejwb2z	cmny9fdc1000cvxy4n4y9ezu8	45000	2026-04-14 06:48:50.121	2026-04-14 06:48:50.121
cmny9ga92027rvxy4gca524dr	cmny9ga0j0271vxy4o8ejwb2z	cmny9fdcn000dvxy4w3gaald5	45000	2026-04-14 06:48:50.15	2026-04-14 06:48:50.15
cmny9gaqm0281vxy4h10i393a	cmny9gaq1027zvxy4bs3xmysr	cmny9fd420001vxy42djthn1o	40000	2026-04-14 06:48:50.783	2026-04-14 06:48:50.783
cmny9gara0283vxy428hphnvj	cmny9gaq1027zvxy4bs3xmysr	cmny9fd4t0002vxy4jo0l7gop	40000	2026-04-14 06:48:50.806	2026-04-14 06:48:50.806
cmny9gas00285vxy4durhpr4r	cmny9gaq1027zvxy4bs3xmysr	cmny9fd5j0003vxy4sw5e14p1	40000	2026-04-14 06:48:50.833	2026-04-14 06:48:50.833
cmny9gaso0287vxy43wigvsrw	cmny9gaq1027zvxy4bs3xmysr	cmny9fd6h0004vxy4evm3jgfv	40000	2026-04-14 06:48:50.856	2026-04-14 06:48:50.856
cmny9gate0289vxy4iolpk7au	cmny9gaq1027zvxy4bs3xmysr	cmny9fd740005vxy44c2rf5rg	40000	2026-04-14 06:48:50.883	2026-04-14 06:48:50.883
cmny9gau1028bvxy49t88fwug	cmny9gaq1027zvxy4bs3xmysr	cmny9fd7u0006vxy4mh4wwui4	40000	2026-04-14 06:48:50.905	2026-04-14 06:48:50.905
cmny9gaul028dvxy4o8gm6r7u	cmny9gaq1027zvxy4bs3xmysr	cmny9fd8i0007vxy4tmc0glr0	40000	2026-04-14 06:48:50.925	2026-04-14 06:48:50.925
cmny9gav7028fvxy44i5a9ukz	cmny9gaq1027zvxy4bs3xmysr	cmny9fd980008vxy4alsawn4y	40000	2026-04-14 06:48:50.946	2026-04-14 06:48:50.946
cmny9gaw3028hvxy41bac4bmz	cmny9gaq1027zvxy4bs3xmysr	cmny9fd9w0009vxy498vvvu1d	40000	2026-04-14 06:48:50.979	2026-04-14 06:48:50.979
cmny9gaww028jvxy40j73dt4d	cmny9gaq1027zvxy4bs3xmysr	cmny9fdam000avxy4a12zuxjj	40000	2026-04-14 06:48:51.009	2026-04-14 06:48:51.009
cmny9gaxl028lvxy4sytswsbz	cmny9gaq1027zvxy4bs3xmysr	cmny9fdb9000bvxy4h02fexen	43000	2026-04-14 06:48:51.033	2026-04-14 06:48:51.033
cmny9gay9028nvxy45f6fzodq	cmny9gaq1027zvxy4bs3xmysr	cmny9fdc1000cvxy4n4y9ezu8	40000	2026-04-14 06:48:51.057	2026-04-14 06:48:51.057
cmny9gayz028pvxy49ntrl3jn	cmny9gaq1027zvxy4bs3xmysr	cmny9fdcn000dvxy4w3gaald5	40000	2026-04-14 06:48:51.083	2026-04-14 06:48:51.083
cmny9gb1m028tvxy4c9ozibpo	cmny9gb11028rvxy4m22rxdoy	cmny9fd420001vxy42djthn1o	60000	2026-04-14 06:48:51.178	2026-04-14 06:48:51.178
cmny9gb27028vvxy47ls32fxm	cmny9gb11028rvxy4m22rxdoy	cmny9fd4t0002vxy4jo0l7gop	60000	2026-04-14 06:48:51.199	2026-04-14 06:48:51.199
cmny9gb2t028xvxy45169dd3u	cmny9gb11028rvxy4m22rxdoy	cmny9fd5j0003vxy4sw5e14p1	60000	2026-04-14 06:48:51.221	2026-04-14 06:48:51.221
cmny9gb3d028zvxy4tr02czt4	cmny9gb11028rvxy4m22rxdoy	cmny9fd6h0004vxy4evm3jgfv	60000	2026-04-14 06:48:51.241	2026-04-14 06:48:51.241
cmny9gb3y0291vxy446jn35ml	cmny9gb11028rvxy4m22rxdoy	cmny9fd740005vxy44c2rf5rg	60000	2026-04-14 06:48:51.262	2026-04-14 06:48:51.262
cmny9gb4j0293vxy4esoz8py6	cmny9gb11028rvxy4m22rxdoy	cmny9fd7u0006vxy4mh4wwui4	60000	2026-04-14 06:48:51.283	2026-04-14 06:48:51.283
cmny9gb550295vxy47164zzga	cmny9gb11028rvxy4m22rxdoy	cmny9fd8i0007vxy4tmc0glr0	60000	2026-04-14 06:48:51.305	2026-04-14 06:48:51.305
cmny9gb5p0297vxy4kkiw3ji4	cmny9gb11028rvxy4m22rxdoy	cmny9fd980008vxy4alsawn4y	60000	2026-04-14 06:48:51.325	2026-04-14 06:48:51.325
cmny9gb680299vxy4vjw6c07j	cmny9gb11028rvxy4m22rxdoy	cmny9fd9w0009vxy498vvvu1d	60000	2026-04-14 06:48:51.344	2026-04-14 06:48:51.344
cmny9gb6u029bvxy44zlvxmo1	cmny9gb11028rvxy4m22rxdoy	cmny9fdam000avxy4a12zuxjj	60000	2026-04-14 06:48:51.367	2026-04-14 06:48:51.367
cmny9gb7n029dvxy4jxv3grdx	cmny9gb11028rvxy4m22rxdoy	cmny9fdb9000bvxy4h02fexen	63000	2026-04-14 06:48:51.395	2026-04-14 06:48:51.395
cmny9gb88029fvxy4i3fmpv0h	cmny9gb11028rvxy4m22rxdoy	cmny9fdc1000cvxy4n4y9ezu8	60000	2026-04-14 06:48:51.416	2026-04-14 06:48:51.416
cmny9gb8u029hvxy41cxm5ayf	cmny9gb11028rvxy4m22rxdoy	cmny9fdcn000dvxy4w3gaald5	60000	2026-04-14 06:48:51.438	2026-04-14 06:48:51.438
cmny9gb9y029kvxy4wo46853q	cmny9gb9e029ivxy45gauj5ew	cmny9fd420001vxy42djthn1o	40000	2026-04-14 06:48:51.478	2026-04-14 06:48:51.478
cmny9gbaj029mvxy4t539hqvz	cmny9gb9e029ivxy45gauj5ew	cmny9fd4t0002vxy4jo0l7gop	40000	2026-04-14 06:48:51.5	2026-04-14 06:48:51.5
cmny9gbb5029ovxy4d1sabb7l	cmny9gb9e029ivxy45gauj5ew	cmny9fd5j0003vxy4sw5e14p1	40000	2026-04-14 06:48:51.521	2026-04-14 06:48:51.521
cmny9gbbp029qvxy4nv687x57	cmny9gb9e029ivxy45gauj5ew	cmny9fd6h0004vxy4evm3jgfv	40000	2026-04-14 06:48:51.541	2026-04-14 06:48:51.541
cmny9gbcb029svxy46vajo5de	cmny9gb9e029ivxy45gauj5ew	cmny9fd740005vxy44c2rf5rg	40000	2026-04-14 06:48:51.563	2026-04-14 06:48:51.563
cmny9gbcv029uvxy4nh8p57dv	cmny9gb9e029ivxy45gauj5ew	cmny9fd7u0006vxy4mh4wwui4	40000	2026-04-14 06:48:51.583	2026-04-14 06:48:51.583
cmny9gbdi029wvxy4id8we5wi	cmny9gb9e029ivxy45gauj5ew	cmny9fd8i0007vxy4tmc0glr0	40000	2026-04-14 06:48:51.606	2026-04-14 06:48:51.606
cmny9gbe0029yvxy40hlz8k23	cmny9gb9e029ivxy45gauj5ew	cmny9fd980008vxy4alsawn4y	40000	2026-04-14 06:48:51.625	2026-04-14 06:48:51.625
cmny9gbel02a0vxy496yc08y3	cmny9gb9e029ivxy45gauj5ew	cmny9fd9w0009vxy498vvvu1d	40000	2026-04-14 06:48:51.645	2026-04-14 06:48:51.645
cmny9gbf602a2vxy420op9oym	cmny9gb9e029ivxy45gauj5ew	cmny9fdam000avxy4a12zuxjj	40000	2026-04-14 06:48:51.667	2026-04-14 06:48:51.667
cmny9gbfy02a4vxy4ayy2zyds	cmny9gb9e029ivxy45gauj5ew	cmny9fdb9000bvxy4h02fexen	43000	2026-04-14 06:48:51.695	2026-04-14 06:48:51.695
cmny9gbgl02a6vxy43b5ylwjc	cmny9gb9e029ivxy45gauj5ew	cmny9fdc1000cvxy4n4y9ezu8	40000	2026-04-14 06:48:51.717	2026-04-14 06:48:51.717
cmny9gbhd02a8vxy4qlbxovmx	cmny9gb9e029ivxy45gauj5ew	cmny9fdcn000dvxy4w3gaald5	40000	2026-04-14 06:48:51.746	2026-04-14 06:48:51.746
cmny9gbj102abvxy4o62z2mle	cmny9gbif02a9vxy4fsn0ejiy	cmny9fd420001vxy42djthn1o	75000	2026-04-14 06:48:51.806	2026-04-14 06:48:51.806
cmny9gbjl02advxy4x9fz9q2h	cmny9gbif02a9vxy4fsn0ejiy	cmny9fd4t0002vxy4jo0l7gop	75000	2026-04-14 06:48:51.825	2026-04-14 06:48:51.825
cmny9gbkp02afvxy4byy4qrqr	cmny9gbif02a9vxy4fsn0ejiy	cmny9fdc1000cvxy4n4y9ezu8	75000	2026-04-14 06:48:51.865	2026-04-14 06:48:51.865
cmny9gbnr02ajvxy4o1cib9ce	cmny9gbmz02ahvxy4zoyre17e	cmny9fd420001vxy42djthn1o	190000	2026-04-14 06:48:51.975	2026-04-14 06:48:51.975
cmny9gbob02alvxy4a8j7j7bg	cmny9gbmz02ahvxy4zoyre17e	cmny9fd4t0002vxy4jo0l7gop	190000	2026-04-14 06:48:51.996	2026-04-14 06:48:51.996
cmny9gbpo02anvxy4xlipf19d	cmny9gbmz02ahvxy4zoyre17e	cmny9fdc1000cvxy4n4y9ezu8	190000	2026-04-14 06:48:52.044	2026-04-14 06:48:52.044
cmny9gbq602apvxy4piaibsu3	cmny9gbmz02ahvxy4zoyre17e	cmny9fdcn000dvxy4w3gaald5	190000	2026-04-14 06:48:52.062	2026-04-14 06:48:52.062
cmny9gbrl02asvxy43romzbux	cmny9gbqt02aqvxy48k5qxa3f	cmny9fd420001vxy42djthn1o	33000	2026-04-14 06:48:52.113	2026-04-14 06:48:52.113
cmny9gbsi02auvxy44wvz8ap2	cmny9gbqt02aqvxy48k5qxa3f	cmny9fd4t0002vxy4jo0l7gop	33000	2026-04-14 06:48:52.146	2026-04-14 06:48:52.146
cmny9gbtc02awvxy4fpfcnbjq	cmny9gbqt02aqvxy48k5qxa3f	cmny9fd5j0003vxy4sw5e14p1	33000	2026-04-14 06:48:52.177	2026-04-14 06:48:52.177
cmny9gbu002ayvxy42yx04i9m	cmny9gbqt02aqvxy48k5qxa3f	cmny9fd6h0004vxy4evm3jgfv	33000	2026-04-14 06:48:52.201	2026-04-14 06:48:52.201
cmny9gbuv02b0vxy4zjajtnow	cmny9gbqt02aqvxy48k5qxa3f	cmny9fd740005vxy44c2rf5rg	33000	2026-04-14 06:48:52.232	2026-04-14 06:48:52.232
cmny9gbvp02b2vxy4ra06ulyt	cmny9gbqt02aqvxy48k5qxa3f	cmny9fd7u0006vxy4mh4wwui4	33000	2026-04-14 06:48:52.261	2026-04-14 06:48:52.261
cmny9gbwg02b4vxy4l03wag2z	cmny9gbqt02aqvxy48k5qxa3f	cmny9fd8i0007vxy4tmc0glr0	33000	2026-04-14 06:48:52.288	2026-04-14 06:48:52.288
cmny9gbx002b6vxy4u9a7tuha	cmny9gbqt02aqvxy48k5qxa3f	cmny9fd980008vxy4alsawn4y	33000	2026-04-14 06:48:52.308	2026-04-14 06:48:52.308
cmny9gbxk02b8vxy40prj2vop	cmny9gbqt02aqvxy48k5qxa3f	cmny9fd9w0009vxy498vvvu1d	33000	2026-04-14 06:48:52.328	2026-04-14 06:48:52.328
cmny9gby602bavxy4uew08yzh	cmny9gbqt02aqvxy48k5qxa3f	cmny9fdam000avxy4a12zuxjj	33000	2026-04-14 06:48:52.35	2026-04-14 06:48:52.35
cmny9gbyy02bcvxy4kjgaefhb	cmny9gbqt02aqvxy48k5qxa3f	cmny9fdb9000bvxy4h02fexen	33000	2026-04-14 06:48:52.378	2026-04-14 06:48:52.378
cmny9gbzj02bevxy4q89l9d0v	cmny9gbqt02aqvxy48k5qxa3f	cmny9fdc1000cvxy4n4y9ezu8	33000	2026-04-14 06:48:52.4	2026-04-14 06:48:52.4
cmny9gc0702bgvxy4k0y6p7kx	cmny9gbqt02aqvxy48k5qxa3f	cmny9fdcn000dvxy4w3gaald5	33000	2026-04-14 06:48:52.423	2026-04-14 06:48:52.423
cmny9gc1q02bjvxy4kkmgljwb	cmny9gc0y02bhvxy4iuoocl00	cmny9fd420001vxy42djthn1o	60000	2026-04-14 06:48:52.478	2026-04-14 06:48:52.478
cmny9gc2b02blvxy40zblm9g5	cmny9gc0y02bhvxy4iuoocl00	cmny9fd4t0002vxy4jo0l7gop	60000	2026-04-14 06:48:52.5	2026-04-14 06:48:52.5
cmny9gc2y02bnvxy403st47um	cmny9gc0y02bhvxy4iuoocl00	cmny9fd5j0003vxy4sw5e14p1	60000	2026-04-14 06:48:52.523	2026-04-14 06:48:52.523
cmny9gc3p02bpvxy4opz45yz9	cmny9gc0y02bhvxy4iuoocl00	cmny9fd6h0004vxy4evm3jgfv	60000	2026-04-14 06:48:52.55	2026-04-14 06:48:52.55
cmny9gc4m02brvxy4j4cm00zq	cmny9gc0y02bhvxy4iuoocl00	cmny9fd740005vxy44c2rf5rg	60000	2026-04-14 06:48:52.583	2026-04-14 06:48:52.583
cmny9gc6r02btvxy4jzb88o02	cmny9gc0y02bhvxy4iuoocl00	cmny9fd7u0006vxy4mh4wwui4	60000	2026-04-14 06:48:52.659	2026-04-14 06:48:52.659
cmny9gc7c02bvvxy4euaw24yl	cmny9gc0y02bhvxy4iuoocl00	cmny9fd8i0007vxy4tmc0glr0	60000	2026-04-14 06:48:52.68	2026-04-14 06:48:52.68
cmny9gc8402bxvxy4w9j66cc4	cmny9gc0y02bhvxy4iuoocl00	cmny9fd980008vxy4alsawn4y	60000	2026-04-14 06:48:52.708	2026-04-14 06:48:52.708
cmny9gc8o02bzvxy4h09gdh32	cmny9gc0y02bhvxy4iuoocl00	cmny9fd9w0009vxy498vvvu1d	60000	2026-04-14 06:48:52.729	2026-04-14 06:48:52.729
cmny9gc9902c1vxy4k14io3gw	cmny9gc0y02bhvxy4iuoocl00	cmny9fdam000avxy4a12zuxjj	60000	2026-04-14 06:48:52.75	2026-04-14 06:48:52.75
cmny9gcat02c3vxy4gwxqccbp	cmny9gc0y02bhvxy4iuoocl00	cmny9fdb9000bvxy4h02fexen	63000	2026-04-14 06:48:52.805	2026-04-14 06:48:52.805
cmny9gcbl02c5vxy4mw3j45cz	cmny9gc0y02bhvxy4iuoocl00	cmny9fdc1000cvxy4n4y9ezu8	60000	2026-04-14 06:48:52.834	2026-04-14 06:48:52.834
cmny9gcce02c7vxy44lmoup6w	cmny9gc0y02bhvxy4iuoocl00	cmny9fdcn000dvxy4w3gaald5	60000	2026-04-14 06:48:52.863	2026-04-14 06:48:52.863
cmny9gcdk02cavxy4d887ehtr	cmny9gccz02c8vxy4a0zolqn2	cmny9fd420001vxy42djthn1o	160000	2026-04-14 06:48:52.905	2026-04-14 06:48:52.905
cmny9gce502ccvxy42l5rqsze	cmny9gccz02c8vxy4a0zolqn2	cmny9fd4t0002vxy4jo0l7gop	160000	2026-04-14 06:48:52.925	2026-04-14 06:48:52.925
cmny9gcfa02cevxy4zrttd1q0	cmny9gccz02c8vxy4a0zolqn2	cmny9fdc1000cvxy4n4y9ezu8	160000	2026-04-14 06:48:52.966	2026-04-14 06:48:52.966
cmny9gcgt02chvxy4734vwf3q	cmny9gcg202cfvxy49lk7u6k9	cmny9fd420001vxy42djthn1o	160000	2026-04-14 06:48:53.022	2026-04-14 06:48:53.022
cmny9gchm02cjvxy40dgav5tj	cmny9gcg202cfvxy49lk7u6k9	cmny9fd4t0002vxy4jo0l7gop	160000	2026-04-14 06:48:53.05	2026-04-14 06:48:53.05
cmny9gcix02clvxy43i1c7ulj	cmny9gcg202cfvxy49lk7u6k9	cmny9fdc1000cvxy4n4y9ezu8	160000	2026-04-14 06:48:53.097	2026-04-14 06:48:53.097
cmny9gck902covxy46o5c9ald	cmny9gcjs02cmvxy4jn48r0lt	cmny9fd420001vxy42djthn1o	50000	2026-04-14 06:48:53.145	2026-04-14 06:48:53.145
cmny9gcku02cqvxy471daj8qs	cmny9gcjs02cmvxy4jn48r0lt	cmny9fd4t0002vxy4jo0l7gop	50000	2026-04-14 06:48:53.166	2026-04-14 06:48:53.166
cmny9gclh02csvxy4iy0wg8vf	cmny9gcjs02cmvxy4jn48r0lt	cmny9fd5j0003vxy4sw5e14p1	50000	2026-04-14 06:48:53.189	2026-04-14 06:48:53.189
cmny9gcmo02cuvxy48fczu6kn	cmny9gcjs02cmvxy4jn48r0lt	cmny9fd6h0004vxy4evm3jgfv	50000	2026-04-14 06:48:53.233	2026-04-14 06:48:53.233
cmny9gcp902cwvxy4dkiyu03c	cmny9gcjs02cmvxy4jn48r0lt	cmny9fd740005vxy44c2rf5rg	50000	2026-04-14 06:48:53.326	2026-04-14 06:48:53.326
cmny9gcpy02cyvxy4bjd2p12z	cmny9gcjs02cmvxy4jn48r0lt	cmny9fd7u0006vxy4mh4wwui4	50000	2026-04-14 06:48:53.35	2026-04-14 06:48:53.35
cmny9gcqj02d0vxy40g0mwxds	cmny9gcjs02cmvxy4jn48r0lt	cmny9fd8i0007vxy4tmc0glr0	50000	2026-04-14 06:48:53.372	2026-04-14 06:48:53.372
cmny9gcr302d2vxy48puitznf	cmny9gcjs02cmvxy4jn48r0lt	cmny9fd980008vxy4alsawn4y	50000	2026-04-14 06:48:53.391	2026-04-14 06:48:53.391
cmny9gcro02d4vxy4u09mrfwq	cmny9gcjs02cmvxy4jn48r0lt	cmny9fd9w0009vxy498vvvu1d	50000	2026-04-14 06:48:53.412	2026-04-14 06:48:53.412
cmny9gcs802d6vxy4pi3t466q	cmny9gcjs02cmvxy4jn48r0lt	cmny9fdam000avxy4a12zuxjj	50000	2026-04-14 06:48:53.433	2026-04-14 06:48:53.433
cmny9gcsw02d8vxy404ayxj7j	cmny9gcjs02cmvxy4jn48r0lt	cmny9fdb9000bvxy4h02fexen	50000	2026-04-14 06:48:53.456	2026-04-14 06:48:53.456
cmny9gctm02davxy4v3313rw5	cmny9gcjs02cmvxy4jn48r0lt	cmny9fdc1000cvxy4n4y9ezu8	50000	2026-04-14 06:48:53.483	2026-04-14 06:48:53.483
cmny9gcu902dcvxy4w9x9f6s7	cmny9gcjs02cmvxy4jn48r0lt	cmny9fdcn000dvxy4w3gaald5	50000	2026-04-14 06:48:53.505	2026-04-14 06:48:53.505
cmny9gcve02dfvxy4dhbsp2k7	cmny9gcut02ddvxy4cu8rejc7	cmny9fd420001vxy42djthn1o	45000	2026-04-14 06:48:53.546	2026-04-14 06:48:53.546
cmny9gcvy02dhvxy4ad79ykpb	cmny9gcut02ddvxy4cu8rejc7	cmny9fd4t0002vxy4jo0l7gop	45000	2026-04-14 06:48:53.566	2026-04-14 06:48:53.566
cmny9gcwl02djvxy4sqi8g6oi	cmny9gcut02ddvxy4cu8rejc7	cmny9fd5j0003vxy4sw5e14p1	45000	2026-04-14 06:48:53.589	2026-04-14 06:48:53.589
cmny9gcxc02dlvxy4rz7de8ga	cmny9gcut02ddvxy4cu8rejc7	cmny9fd6h0004vxy4evm3jgfv	45000	2026-04-14 06:48:53.616	2026-04-14 06:48:53.616
cmny9gcy002dnvxy4l8opvy1l	cmny9gcut02ddvxy4cu8rejc7	cmny9fd7u0006vxy4mh4wwui4	37000	2026-04-14 06:48:53.64	2026-04-14 06:48:53.64
cmny9gcys02dpvxy42i2i4ml9	cmny9gcut02ddvxy4cu8rejc7	cmny9fd980008vxy4alsawn4y	45000	2026-04-14 06:48:53.668	2026-04-14 06:48:53.668
cmny9gczc02drvxy40xl37wc7	cmny9gcut02ddvxy4cu8rejc7	cmny9fd9w0009vxy498vvvu1d	45000	2026-04-14 06:48:53.688	2026-04-14 06:48:53.688
cmny9gd0602dtvxy48xvz0g7l	cmny9gcut02ddvxy4cu8rejc7	cmny9fdb9000bvxy4h02fexen	48000	2026-04-14 06:48:53.718	2026-04-14 06:48:53.718
cmny9gd0q02dvvxy4lm4ylwed	cmny9gcut02ddvxy4cu8rejc7	cmny9fdc1000cvxy4n4y9ezu8	45000	2026-04-14 06:48:53.739	2026-04-14 06:48:53.739
cmny9gd1a02dxvxy480pk3cdp	cmny9gcut02ddvxy4cu8rejc7	cmny9fdcn000dvxy4w3gaald5	45000	2026-04-14 06:48:53.759	2026-04-14 06:48:53.759
cmny9gd2g02e0vxy4txroxhze	cmny9gd1v02dyvxy4k71737mm	cmny9fd4t0002vxy4jo0l7gop	40000	2026-04-14 06:48:53.801	2026-04-14 06:48:53.801
cmny9gd3j02e2vxy4828op7f7	cmny9gd1v02dyvxy4k71737mm	cmny9fdc1000cvxy4n4y9ezu8	40000	2026-04-14 06:48:53.839	2026-04-14 06:48:53.839
cmny9gd4o02e5vxy4wq7tfyxy	cmny9gd4302e3vxy441ff88u5	cmny9fd420001vxy42djthn1o	29500	2026-04-14 06:48:53.88	2026-04-14 06:48:53.88
cmny9gd5p02e7vxy4c43cfyyn	cmny9gd4302e3vxy441ff88u5	cmny9fdc1000cvxy4n4y9ezu8	29500	2026-04-14 06:48:53.917	2026-04-14 06:48:53.917
cmny9gd7k02eavxy4uytmjgfi	cmny9gd6j02e8vxy4q1c6h5i4	cmny9fd4t0002vxy4jo0l7gop	40000	2026-04-14 06:48:53.984	2026-04-14 06:48:53.984
cmny9gd8502ecvxy45w4dcspv	cmny9gd6j02e8vxy4q1c6h5i4	cmny9fd5j0003vxy4sw5e14p1	40000	2026-04-14 06:48:54.005	2026-04-14 06:48:54.005
cmny9gd8p02eevxy45eo2kc55	cmny9gd6j02e8vxy4q1c6h5i4	cmny9fd6h0004vxy4evm3jgfv	40000	2026-04-14 06:48:54.025	2026-04-14 06:48:54.025
cmny9gd9b02egvxy4giia9gp5	cmny9gd6j02e8vxy4q1c6h5i4	cmny9fd7u0006vxy4mh4wwui4	40000	2026-04-14 06:48:54.047	2026-04-14 06:48:54.047
cmny9gd9u02eivxy4ioaicsvl	cmny9gd6j02e8vxy4q1c6h5i4	cmny9fd8i0007vxy4tmc0glr0	40000	2026-04-14 06:48:54.066	2026-04-14 06:48:54.066
cmny9gdah02ekvxy4wttlfxdu	cmny9gd6j02e8vxy4q1c6h5i4	cmny9fd980008vxy4alsawn4y	40000	2026-04-14 06:48:54.09	2026-04-14 06:48:54.09
cmny9gdb902emvxy49k75v7kd	cmny9gd6j02e8vxy4q1c6h5i4	cmny9fd9w0009vxy498vvvu1d	40000	2026-04-14 06:48:54.118	2026-04-14 06:48:54.118
cmny9gdc402eovxy4h3br2902	cmny9gd6j02e8vxy4q1c6h5i4	cmny9fdb9000bvxy4h02fexen	43000	2026-04-14 06:48:54.148	2026-04-14 06:48:54.148
cmny9gdcv02eqvxy4r39d6qy8	cmny9gd6j02e8vxy4q1c6h5i4	cmny9fdc1000cvxy4n4y9ezu8	40000	2026-04-14 06:48:54.175	2026-04-14 06:48:54.175
cmny9gddf02esvxy470qlpar4	cmny9gd6j02e8vxy4q1c6h5i4	cmny9fdcn000dvxy4w3gaald5	40000	2026-04-14 06:48:54.195	2026-04-14 06:48:54.195
cmny9gden02evvxy4z1xj56nv	cmny9gde002etvxy4djvf1jqr	cmny9fd420001vxy42djthn1o	60000	2026-04-14 06:48:54.24	2026-04-14 06:48:54.24
cmny9gdfe02exvxy463vnqlu0	cmny9gde002etvxy4djvf1jqr	cmny9fd4t0002vxy4jo0l7gop	60000	2026-04-14 06:48:54.266	2026-04-14 06:48:54.266
cmny9gdgk02ezvxy432yhl5rp	cmny9gde002etvxy4djvf1jqr	cmny9fdc1000cvxy4n4y9ezu8	60000	2026-04-14 06:48:54.309	2026-04-14 06:48:54.309
cmny9gdhw02f2vxy4bejp8dzq	cmny9gdha02f0vxy4pl8vg2ew	cmny9fd420001vxy42djthn1o	40000	2026-04-14 06:48:54.356	2026-04-14 06:48:54.356
cmny9gdj902f4vxy4j5z4hndf	cmny9gdha02f0vxy4pl8vg2ew	cmny9fdc1000cvxy4n4y9ezu8	40000	2026-04-14 06:48:54.405	2026-04-14 06:48:54.405
cmny9gdkq02f7vxy4szo8rm88	cmny9gdjz02f5vxy4q10ad2fw	cmny9fd420001vxy42djthn1o	45500	2026-04-14 06:48:54.458	2026-04-14 06:48:54.458
cmny9gdls02f9vxy4pz5kyqjq	cmny9gdjz02f5vxy4q10ad2fw	cmny9fdc1000cvxy4n4y9ezu8	45500	2026-04-14 06:48:54.496	2026-04-14 06:48:54.496
cmny9gdpg02fcvxy4u6qqsujr	cmny9gdmd02favxy4oqlm2fo8	cmny9fd420001vxy42djthn1o	29500	2026-04-14 06:48:54.629	2026-04-14 06:48:54.629
cmny9gdql02fevxy4nlzz8g9a	cmny9gdmd02favxy4oqlm2fo8	cmny9fdc1000cvxy4n4y9ezu8	29500	2026-04-14 06:48:54.669	2026-04-14 06:48:54.669
cmny9gds702fhvxy404bv7s0k	cmny9gdrd02ffvxy4a77fplgw	cmny9fd4t0002vxy4jo0l7gop	390000	2026-04-14 06:48:54.727	2026-04-14 06:48:54.727
cmny9gdt902fjvxy4xuwr1bcn	cmny9gdrd02ffvxy4a77fplgw	cmny9fdc1000cvxy4n4y9ezu8	390000	2026-04-14 06:48:54.766	2026-04-14 06:48:54.766
cmny9gduk02fmvxy46egnkb6c	cmny9gdu102fkvxy4b53rgvu9	cmny9fd420001vxy42djthn1o	90000	2026-04-14 06:48:54.812	2026-04-14 06:48:54.812
cmny9gdv502fovxy4gijs074h	cmny9gdu102fkvxy4b53rgvu9	cmny9fd4t0002vxy4jo0l7gop	90000	2026-04-14 06:48:54.833	2026-04-14 06:48:54.833
cmny9gdw902fqvxy4b7pvu4kw	cmny9gdu102fkvxy4b53rgvu9	cmny9fdc1000cvxy4n4y9ezu8	90000	2026-04-14 06:48:54.874	2026-04-14 06:48:54.874
cmny9gdzj02fuvxy48gcpk40q	cmny9gdyu02fsvxy4i1updvjm	cmny9fd420001vxy42djthn1o	90000	2026-04-14 06:48:54.992	2026-04-14 06:48:54.992
cmny9ge1h02fxvxy4xqlummm5	cmny9ge0p02fvvxy4zcr3h6i0	cmny9fd4t0002vxy4jo0l7gop	79000	2026-04-14 06:48:55.062	2026-04-14 06:48:55.062
cmny9ge2p02fzvxy4fe1tg07d	cmny9ge0p02fvvxy4zcr3h6i0	cmny9fdc1000cvxy4n4y9ezu8	79000	2026-04-14 06:48:55.105	2026-04-14 06:48:55.105
cmny9ge3s02g2vxy47zy6mza5	cmny9ge3b02g0vxy4eu5jf90t	cmny9fd420001vxy42djthn1o	40000	2026-04-14 06:48:55.145	2026-04-14 06:48:55.145
cmny9ge5202g4vxy4iibmtah2	cmny9ge3b02g0vxy4eu5jf90t	cmny9fdc1000cvxy4n4y9ezu8	40000	2026-04-14 06:48:55.19	2026-04-14 06:48:55.19
cmny9ge6902g7vxy4pay3fd1r	cmny9ge5p02g5vxy4lk9iut7r	cmny9fd420001vxy42djthn1o	120000	2026-04-14 06:48:55.233	2026-04-14 06:48:55.233
cmny9ge6v02g9vxy43b56euzk	cmny9ge5p02g5vxy4lk9iut7r	cmny9fd4t0002vxy4jo0l7gop	120000	2026-04-14 06:48:55.256	2026-04-14 06:48:55.256
cmny9ge8802gbvxy4neu25xxa	cmny9ge5p02g5vxy4lk9iut7r	cmny9fdc1000cvxy4n4y9ezu8	120000	2026-04-14 06:48:55.305	2026-04-14 06:48:55.305
cmny9ge9i02gevxy4gnzgpt8c	cmny9ge8x02gcvxy47kgz0h1g	cmny9fd420001vxy42djthn1o	41000	2026-04-14 06:48:55.35	2026-04-14 06:48:55.35
cmny9gebl02ghvxy4abey0v4l	cmny9geb102gfvxy47zsvk9yk	cmny9fd420001vxy42djthn1o	33600	2026-04-14 06:48:55.425	2026-04-14 06:48:55.425
cmny9gec502gjvxy4a8pzx0r3	cmny9geb102gfvxy47zsvk9yk	cmny9fd4t0002vxy4jo0l7gop	33600	2026-04-14 06:48:55.445	2026-04-14 06:48:55.445
cmny9gedd02glvxy4udvzb9pt	cmny9geb102gfvxy47zsvk9yk	cmny9fd9w0009vxy498vvvu1d	33600	2026-04-14 06:48:55.49	2026-04-14 06:48:55.49
cmny9geea02gnvxy4e04wvpr8	cmny9geb102gfvxy47zsvk9yk	cmny9fdc1000cvxy4n4y9ezu8	33600	2026-04-14 06:48:55.523	2026-04-14 06:48:55.523
cmny9gefz02gqvxy4kyqe86rc	cmny9gef902govxy4ggomag39	cmny9fd420001vxy42djthn1o	45000	2026-04-14 06:48:55.583	2026-04-14 06:48:55.583
cmny9gehq02gsvxy450mcbvgs	cmny9gef902govxy4ggomag39	cmny9fd4t0002vxy4jo0l7gop	45000	2026-04-14 06:48:55.646	2026-04-14 06:48:55.646
cmny9geir02guvxy4vrtxfyk5	cmny9gef902govxy4ggomag39	cmny9fd5j0003vxy4sw5e14p1	48000	2026-04-14 06:48:55.684	2026-04-14 06:48:55.684
cmny9gejk02gwvxy4u1wip5ap	cmny9gef902govxy4ggomag39	cmny9fd6h0004vxy4evm3jgfv	45000	2026-04-14 06:48:55.712	2026-04-14 06:48:55.712
cmny9gek602gyvxy4i3921mz0	cmny9gef902govxy4ggomag39	cmny9fd7u0006vxy4mh4wwui4	37000	2026-04-14 06:48:55.734	2026-04-14 06:48:55.734
cmny9geky02h0vxy410pklgtr	cmny9gef902govxy4ggomag39	cmny9fd980008vxy4alsawn4y	45000	2026-04-14 06:48:55.763	2026-04-14 06:48:55.763
cmny9gelj02h2vxy4yjz65iv2	cmny9gef902govxy4ggomag39	cmny9fd9w0009vxy498vvvu1d	45000	2026-04-14 06:48:55.783	2026-04-14 06:48:55.783
cmny9gemd02h4vxy4ggnsxxan	cmny9gef902govxy4ggomag39	cmny9fdb9000bvxy4h02fexen	48000	2026-04-14 06:48:55.813	2026-04-14 06:48:55.813
cmny9gemx02h6vxy4xu6mhxm3	cmny9gef902govxy4ggomag39	cmny9fdc1000cvxy4n4y9ezu8	45000	2026-04-14 06:48:55.833	2026-04-14 06:48:55.833
cmny9genp02h8vxy4251t9swx	cmny9gef902govxy4ggomag39	cmny9fdcn000dvxy4w3gaald5	45000	2026-04-14 06:48:55.861	2026-04-14 06:48:55.861
cmny9ges502hdvxy415n5tq34	cmny9gerc02hbvxy49fzp4qpu	cmny9fd420001vxy42djthn1o	40000	2026-04-14 06:48:56.021	2026-04-14 06:48:56.021
cmny9gesq02hfvxy46angci4o	cmny9gerc02hbvxy49fzp4qpu	cmny9fd4t0002vxy4jo0l7gop	40000	2026-04-14 06:48:56.042	2026-04-14 06:48:56.042
cmny9getj02hhvxy4hnk695ky	cmny9gerc02hbvxy49fzp4qpu	cmny9fd5j0003vxy4sw5e14p1	40000	2026-04-14 06:48:56.071	2026-04-14 06:48:56.071
cmny9geu402hjvxy43awisjx7	cmny9gerc02hbvxy49fzp4qpu	cmny9fd6h0004vxy4evm3jgfv	40000	2026-04-14 06:48:56.092	2026-04-14 06:48:56.092
cmny9geuy02hlvxy4ypylmwxu	cmny9gerc02hbvxy49fzp4qpu	cmny9fd740005vxy44c2rf5rg	40000	2026-04-14 06:48:56.122	2026-04-14 06:48:56.122
cmny9gevi02hnvxy4bbw8c8co	cmny9gerc02hbvxy49fzp4qpu	cmny9fd7u0006vxy4mh4wwui4	40000	2026-04-14 06:48:56.142	2026-04-14 06:48:56.142
cmny9gewb02hpvxy4tdnbzupu	cmny9gerc02hbvxy49fzp4qpu	cmny9fd8i0007vxy4tmc0glr0	40000	2026-04-14 06:48:56.172	2026-04-14 06:48:56.172
cmny9geww02hrvxy4atd785hf	cmny9gerc02hbvxy49fzp4qpu	cmny9fd980008vxy4alsawn4y	40000	2026-04-14 06:48:56.192	2026-04-14 06:48:56.192
cmny9gexp02htvxy4z420smyc	cmny9gerc02hbvxy49fzp4qpu	cmny9fd9w0009vxy498vvvu1d	40000	2026-04-14 06:48:56.221	2026-04-14 06:48:56.221
cmny9geya02hvvxy4h0xzkfdn	cmny9gerc02hbvxy49fzp4qpu	cmny9fdam000avxy4a12zuxjj	40000	2026-04-14 06:48:56.242	2026-04-14 06:48:56.242
cmny9gez302hxvxy4sulxwzj4	cmny9gerc02hbvxy49fzp4qpu	cmny9fdb9000bvxy4h02fexen	43000	2026-04-14 06:48:56.272	2026-04-14 06:48:56.272
cmny9gezo02hzvxy4jil8towr	cmny9gerc02hbvxy49fzp4qpu	cmny9fdc1000cvxy4n4y9ezu8	40000	2026-04-14 06:48:56.292	2026-04-14 06:48:56.292
cmny9gf0h02i1vxy4wgcv1sfz	cmny9gerc02hbvxy49fzp4qpu	cmny9fdcn000dvxy4w3gaald5	40000	2026-04-14 06:48:56.321	2026-04-14 06:48:56.321
cmny9gf1w02i4vxy4qro5b95z	cmny9gf1202i2vxy4m5gm5hqe	cmny9fd420001vxy42djthn1o	43000	2026-04-14 06:48:56.372	2026-04-14 06:48:56.372
cmny9gf2g02i6vxy4r7dp6sxj	cmny9gf1202i2vxy4m5gm5hqe	cmny9fd4t0002vxy4jo0l7gop	43000	2026-04-14 06:48:56.392	2026-04-14 06:48:56.392
cmny9gf3902i8vxy4bvofer8j	cmny9gf1202i2vxy4m5gm5hqe	cmny9fd5j0003vxy4sw5e14p1	43000	2026-04-14 06:48:56.421	2026-04-14 06:48:56.421
cmny9gf3v02iavxy4lo4q6hcv	cmny9gf1202i2vxy4m5gm5hqe	cmny9fd6h0004vxy4evm3jgfv	43000	2026-04-14 06:48:56.443	2026-04-14 06:48:56.443
cmny9gf4q02icvxy48myes3mh	cmny9gf1202i2vxy4m5gm5hqe	cmny9fd7u0006vxy4mh4wwui4	43000	2026-04-14 06:48:56.474	2026-04-14 06:48:56.474
cmny9gf5i02ievxy4r8o9ipz6	cmny9gf1202i2vxy4m5gm5hqe	cmny9fd980008vxy4alsawn4y	43000	2026-04-14 06:48:56.502	2026-04-14 06:48:56.502
cmny9gf6i02igvxy4licisuz3	cmny9gf1202i2vxy4m5gm5hqe	cmny9fd9w0009vxy498vvvu1d	43000	2026-04-14 06:48:56.539	2026-04-14 06:48:56.539
cmny9gf7602iivxy4yhahvku3	cmny9gf1202i2vxy4m5gm5hqe	cmny9fdc1000cvxy4n4y9ezu8	43000	2026-04-14 06:48:56.563	2026-04-14 06:48:56.563
cmny9gf8302ikvxy4spt1awf5	cmny9gf1202i2vxy4m5gm5hqe	cmny9fdcn000dvxy4w3gaald5	43000	2026-04-14 06:48:56.595	2026-04-14 06:48:56.595
cmny9gf9g02invxy49d12pd2z	cmny9gf8o02ilvxy4vvf7to0r	cmny9fd420001vxy42djthn1o	32000	2026-04-14 06:48:56.645	2026-04-14 06:48:56.645
cmny9gfa302ipvxy4szaxmqpf	cmny9gf8o02ilvxy4vvf7to0r	cmny9fd4t0002vxy4jo0l7gop	32000	2026-04-14 06:48:56.667	2026-04-14 06:48:56.667
cmny9gfau02irvxy4ze4v7duz	cmny9gf8o02ilvxy4vvf7to0r	cmny9fd5j0003vxy4sw5e14p1	32000	2026-04-14 06:48:56.694	2026-04-14 06:48:56.694
cmny9gfbh02itvxy4by8c9d9l	cmny9gf8o02ilvxy4vvf7to0r	cmny9fd6h0004vxy4evm3jgfv	32000	2026-04-14 06:48:56.717	2026-04-14 06:48:56.717
cmny9gfca02ivvxy4564n8n5d	cmny9gf8o02ilvxy4vvf7to0r	cmny9fd7u0006vxy4mh4wwui4	32000	2026-04-14 06:48:56.746	2026-04-14 06:48:56.746
cmny9gfdp02ixvxy42oidvjho	cmny9gf8o02ilvxy4vvf7to0r	cmny9fd980008vxy4alsawn4y	32000	2026-04-14 06:48:56.797	2026-04-14 06:48:56.797
cmny9gfep02izvxy4f1eitiow	cmny9gf8o02ilvxy4vvf7to0r	cmny9fd9w0009vxy498vvvu1d	32000	2026-04-14 06:48:56.833	2026-04-14 06:48:56.833
cmny9gfff02j1vxy4jd56hnp6	cmny9gf8o02ilvxy4vvf7to0r	cmny9fdc1000cvxy4n4y9ezu8	32000	2026-04-14 06:48:56.859	2026-04-14 06:48:56.859
cmny9gfg302j3vxy4c6t3frx2	cmny9gf8o02ilvxy4vvf7to0r	cmny9fdcn000dvxy4w3gaald5	32000	2026-04-14 06:48:56.883	2026-04-14 06:48:56.883
cmny9gfh902j6vxy4u3msgx6h	cmny9gfgp02j4vxy4o6f7msb1	cmny9fd420001vxy42djthn1o	40000	2026-04-14 06:48:56.926	2026-04-14 06:48:56.926
cmny9gfht02j8vxy4qnsx74e7	cmny9gfgp02j4vxy4o6f7msb1	cmny9fd4t0002vxy4jo0l7gop	40000	2026-04-14 06:48:56.945	2026-04-14 06:48:56.945
cmny9gfie02javxy4smlca7ea	cmny9gfgp02j4vxy4o6f7msb1	cmny9fd5j0003vxy4sw5e14p1	40000	2026-04-14 06:48:56.966	2026-04-14 06:48:56.966
cmny9gfj002jcvxy4mla6j16c	cmny9gfgp02j4vxy4o6f7msb1	cmny9fd6h0004vxy4evm3jgfv	40000	2026-04-14 06:48:56.989	2026-04-14 06:48:56.989
cmny9gfjk02jevxy4jag2aq5r	cmny9gfgp02j4vxy4o6f7msb1	cmny9fd740005vxy44c2rf5rg	40000	2026-04-14 06:48:57.009	2026-04-14 06:48:57.009
cmny9gfk402jgvxy4g607stsg	cmny9gfgp02j4vxy4o6f7msb1	cmny9fd7u0006vxy4mh4wwui4	40000	2026-04-14 06:48:57.028	2026-04-14 06:48:57.028
cmny9gfkq02jivxy44u4rlt9m	cmny9gfgp02j4vxy4o6f7msb1	cmny9fd8i0007vxy4tmc0glr0	40000	2026-04-14 06:48:57.05	2026-04-14 06:48:57.05
cmny9gfli02jkvxy480quv587	cmny9gfgp02j4vxy4o6f7msb1	cmny9fd980008vxy4alsawn4y	40000	2026-04-14 06:48:57.078	2026-04-14 06:48:57.078
cmny9gfm402jmvxy4qjhg4f16	cmny9gfgp02j4vxy4o6f7msb1	cmny9fd9w0009vxy498vvvu1d	40000	2026-04-14 06:48:57.1	2026-04-14 06:48:57.1
cmny9gfmp02jovxy4vbl27cre	cmny9gfgp02j4vxy4o6f7msb1	cmny9fdam000avxy4a12zuxjj	40000	2026-04-14 06:48:57.122	2026-04-14 06:48:57.122
cmny9gfnb02jqvxy46u7iovls	cmny9gfgp02j4vxy4o6f7msb1	cmny9fdb9000bvxy4h02fexen	43000	2026-04-14 06:48:57.144	2026-04-14 06:48:57.144
cmny9gfnu02jsvxy4z0apuqih	cmny9gfgp02j4vxy4o6f7msb1	cmny9fdc1000cvxy4n4y9ezu8	40000	2026-04-14 06:48:57.162	2026-04-14 06:48:57.162
cmny9gfof02juvxy4jp2myc5c	cmny9gfgp02j4vxy4o6f7msb1	cmny9fdcn000dvxy4w3gaald5	40000	2026-04-14 06:48:57.183	2026-04-14 06:48:57.183
cmny9gfqv02jyvxy4aofrun6c	cmny9gfqa02jwvxy4sidey8jw	cmny9fd420001vxy42djthn1o	45000	2026-04-14 06:48:57.272	2026-04-14 06:48:57.272
cmny9gfrg02k0vxy4a2njn8j8	cmny9gfqa02jwvxy4sidey8jw	cmny9fd4t0002vxy4jo0l7gop	45000	2026-04-14 06:48:57.292	2026-04-14 06:48:57.292
cmny9gfrz02k2vxy4khnlr29k	cmny9gfqa02jwvxy4sidey8jw	cmny9fd5j0003vxy4sw5e14p1	48000	2026-04-14 06:48:57.312	2026-04-14 06:48:57.312
cmny9gfsl02k4vxy4vl3rfdtk	cmny9gfqa02jwvxy4sidey8jw	cmny9fd6h0004vxy4evm3jgfv	45000	2026-04-14 06:48:57.334	2026-04-14 06:48:57.334
cmny9gft902k6vxy4z4k407nm	cmny9gfqa02jwvxy4sidey8jw	cmny9fd7u0006vxy4mh4wwui4	37000	2026-04-14 06:48:57.357	2026-04-14 06:48:57.357
cmny9gfu102k8vxy4eefn82hu	cmny9gfqa02jwvxy4sidey8jw	cmny9fd980008vxy4alsawn4y	45000	2026-04-14 06:48:57.385	2026-04-14 06:48:57.385
cmny9gfur02kavxy4dr9g70a2	cmny9gfqa02jwvxy4sidey8jw	cmny9fd9w0009vxy498vvvu1d	45000	2026-04-14 06:48:57.412	2026-04-14 06:48:57.412
cmny9gfve02kcvxy4x86ees5k	cmny9gfqa02jwvxy4sidey8jw	cmny9fdb9000bvxy4h02fexen	48000	2026-04-14 06:48:57.435	2026-04-14 06:48:57.435
cmny9gfvz02kevxy4dv3qxun6	cmny9gfqa02jwvxy4sidey8jw	cmny9fdc1000cvxy4n4y9ezu8	45000	2026-04-14 06:48:57.455	2026-04-14 06:48:57.455
cmny9gfwj02kgvxy4z650dle9	cmny9gfqa02jwvxy4sidey8jw	cmny9fdcn000dvxy4w3gaald5	45000	2026-04-14 06:48:57.476	2026-04-14 06:48:57.476
cmny9gfxo02kjvxy4lsr9j0yf	cmny9gfx302khvxy4vswa3e63	cmny9fd420001vxy42djthn1o	59000	2026-04-14 06:48:57.517	2026-04-14 06:48:57.517
cmny9gfya02klvxy46z26sibk	cmny9gfx302khvxy4vswa3e63	cmny9fd4t0002vxy4jo0l7gop	59000	2026-04-14 06:48:57.539	2026-04-14 06:48:57.539
cmny9gfz302knvxy4kf2hyndh	cmny9gfx302khvxy4vswa3e63	cmny9fd5j0003vxy4sw5e14p1	59000	2026-04-14 06:48:57.567	2026-04-14 06:48:57.567
cmny9gfzv02kpvxy4wv7nz5c7	cmny9gfx302khvxy4vswa3e63	cmny9fd6h0004vxy4evm3jgfv	59000	2026-04-14 06:48:57.595	2026-04-14 06:48:57.595
cmny9gg0h02krvxy46lo0hz1a	cmny9gfx302khvxy4vswa3e63	cmny9fd740005vxy44c2rf5rg	59000	2026-04-14 06:48:57.617	2026-04-14 06:48:57.617
cmny9gg1902ktvxy4582lsrl5	cmny9gfx302khvxy4vswa3e63	cmny9fd7u0006vxy4mh4wwui4	59000	2026-04-14 06:48:57.645	2026-04-14 06:48:57.645
cmny9gg1v02kvvxy4ruce6o91	cmny9gfx302khvxy4vswa3e63	cmny9fd8i0007vxy4tmc0glr0	59000	2026-04-14 06:48:57.667	2026-04-14 06:48:57.667
cmny9gg2n02kxvxy4buro3jog	cmny9gfx302khvxy4vswa3e63	cmny9fd980008vxy4alsawn4y	59000	2026-04-14 06:48:57.695	2026-04-14 06:48:57.695
cmny9gg3902kzvxy4bfp4g8tj	cmny9gfx302khvxy4vswa3e63	cmny9fd9w0009vxy498vvvu1d	59000	2026-04-14 06:48:57.718	2026-04-14 06:48:57.718
cmny9gg4002l1vxy4dx9recug	cmny9gfx302khvxy4vswa3e63	cmny9fdam000avxy4a12zuxjj	59000	2026-04-14 06:48:57.744	2026-04-14 06:48:57.744
cmny9gg4n02l3vxy4d0bexsgp	cmny9gfx302khvxy4vswa3e63	cmny9fdb9000bvxy4h02fexen	59000	2026-04-14 06:48:57.767	2026-04-14 06:48:57.767
cmny9gg5f02l5vxy490l9wigg	cmny9gfx302khvxy4vswa3e63	cmny9fdc1000cvxy4n4y9ezu8	59000	2026-04-14 06:48:57.795	2026-04-14 06:48:57.795
cmny9gg6102l7vxy4p7vgj8ig	cmny9gfx302khvxy4vswa3e63	cmny9fdcn000dvxy4w3gaald5	59000	2026-04-14 06:48:57.817	2026-04-14 06:48:57.817
cmny9gg7e02lavxy4z2jqhn3o	cmny9gg6t02l8vxy4tqeh3tju	cmny9fd420001vxy42djthn1o	70000	2026-04-14 06:48:57.867	2026-04-14 06:48:57.867
cmny9gg8602lcvxy4eintixdy	cmny9gg6t02l8vxy4tqeh3tju	cmny9fd4t0002vxy4jo0l7gop	70000	2026-04-14 06:48:57.895	2026-04-14 06:48:57.895
cmny9gg8s02levxy4sg46gig7	cmny9gg6t02l8vxy4tqeh3tju	cmny9fd5j0003vxy4sw5e14p1	70000	2026-04-14 06:48:57.917	2026-04-14 06:48:57.917
cmny9gg9k02lgvxy4ozpdc4j5	cmny9gg6t02l8vxy4tqeh3tju	cmny9fd6h0004vxy4evm3jgfv	70000	2026-04-14 06:48:57.945	2026-04-14 06:48:57.945
cmny9gga702livxy4ub6k259y	cmny9gg6t02l8vxy4tqeh3tju	cmny9fd7u0006vxy4mh4wwui4	70000	2026-04-14 06:48:57.968	2026-04-14 06:48:57.968
cmny9ggaz02lkvxy45n70x3k4	cmny9gg6t02l8vxy4tqeh3tju	cmny9fd8i0007vxy4tmc0glr0	70000	2026-04-14 06:48:57.995	2026-04-14 06:48:57.995
cmny9ggbk02lmvxy4klju1gk4	cmny9gg6t02l8vxy4tqeh3tju	cmny9fd980008vxy4alsawn4y	70000	2026-04-14 06:48:58.017	2026-04-14 06:48:58.017
cmny9ggcd02lovxy4mjb9p2bd	cmny9gg6t02l8vxy4tqeh3tju	cmny9fd9w0009vxy498vvvu1d	70000	2026-04-14 06:48:58.045	2026-04-14 06:48:58.045
cmny9ggd002lqvxy4ltx0lbkn	cmny9gg6t02l8vxy4tqeh3tju	cmny9fdb9000bvxy4h02fexen	70000	2026-04-14 06:48:58.068	2026-04-14 06:48:58.068
cmny9ggei02lsvxy4tpaxi6xx	cmny9gg6t02l8vxy4tqeh3tju	cmny9fdc1000cvxy4n4y9ezu8	70000	2026-04-14 06:48:58.122	2026-04-14 06:48:58.122
cmny9ggfj02luvxy428t19ut4	cmny9gg6t02l8vxy4tqeh3tju	cmny9fdcn000dvxy4w3gaald5	70000	2026-04-14 06:48:58.159	2026-04-14 06:48:58.159
cmny9gggy02lxvxy4fcp8vgzg	cmny9gggc02lvvxy4gsp90vfj	cmny9fd420001vxy42djthn1o	120000	2026-04-14 06:48:58.21	2026-04-14 06:48:58.21
cmny9gghq02lzvxy4tibdtyog	cmny9gggc02lvvxy4gsp90vfj	cmny9fd4t0002vxy4jo0l7gop	120000	2026-04-14 06:48:58.238	2026-04-14 06:48:58.238
cmny9ggii02m1vxy4j4wlxj59	cmny9gggc02lvvxy4gsp90vfj	cmny9fd5j0003vxy4sw5e14p1	120000	2026-04-14 06:48:58.267	2026-04-14 06:48:58.267
cmny9ggja02m3vxy4hjarl7yg	cmny9gggc02lvvxy4gsp90vfj	cmny9fd6h0004vxy4evm3jgfv	120000	2026-04-14 06:48:58.295	2026-04-14 06:48:58.295
cmny9ggjz02m5vxy44qyye4t1	cmny9gggc02lvvxy4gsp90vfj	cmny9fd7u0006vxy4mh4wwui4	120000	2026-04-14 06:48:58.319	2026-04-14 06:48:58.319
cmny9ggkz02m7vxy4rtasqs1m	cmny9gggc02lvvxy4gsp90vfj	cmny9fd8i0007vxy4tmc0glr0	120000	2026-04-14 06:48:58.355	2026-04-14 06:48:58.355
cmny9gglj02m9vxy4730ru0hj	cmny9gggc02lvvxy4gsp90vfj	cmny9fd980008vxy4alsawn4y	120000	2026-04-14 06:48:58.375	2026-04-14 06:48:58.375
cmny9ggmd02mbvxy4m7mgg4rf	cmny9gggc02lvvxy4gsp90vfj	cmny9fd9w0009vxy498vvvu1d	120000	2026-04-14 06:48:58.405	2026-04-14 06:48:58.405
cmny9ggn102mdvxy4y5bgqr5a	cmny9gggc02lvvxy4gsp90vfj	cmny9fdb9000bvxy4h02fexen	120000	2026-04-14 06:48:58.429	2026-04-14 06:48:58.429
cmny9ggny02mfvxy4tt3xqr1a	cmny9gggc02lvvxy4gsp90vfj	cmny9fdc1000cvxy4n4y9ezu8	120000	2026-04-14 06:48:58.462	2026-04-14 06:48:58.462
cmny9ggoj02mhvxy4a9ogv7r0	cmny9gggc02lvvxy4gsp90vfj	cmny9fdcn000dvxy4w3gaald5	120000	2026-04-14 06:48:58.484	2026-04-14 06:48:58.484
cmny9ggpy02mkvxy4y79s5et6	cmny9ggpb02mivxy41bqgb3cr	cmny9fd420001vxy42djthn1o	16000	2026-04-14 06:48:58.534	2026-04-14 06:48:58.534
cmny9ggr002mmvxy4j9mn02gd	cmny9ggpb02mivxy41bqgb3cr	cmny9fd4t0002vxy4jo0l7gop	16000	2026-04-14 06:48:58.572	2026-04-14 06:48:58.572
cmny9ggrs02movxy49v0r7lr2	cmny9ggpb02mivxy41bqgb3cr	cmny9fd5j0003vxy4sw5e14p1	16000	2026-04-14 06:48:58.6	2026-04-14 06:48:58.6
cmny9ggsk02mqvxy4q42jr29s	cmny9ggpb02mivxy41bqgb3cr	cmny9fd6h0004vxy4evm3jgfv	16000	2026-04-14 06:48:58.628	2026-04-14 06:48:58.628
cmny9ggt902msvxy4jn7121f7	cmny9ggpb02mivxy41bqgb3cr	cmny9fd7u0006vxy4mh4wwui4	16000	2026-04-14 06:48:58.653	2026-04-14 06:48:58.653
cmny9ggu802muvxy4jwy13wqu	cmny9ggpb02mivxy41bqgb3cr	cmny9fd8i0007vxy4tmc0glr0	16000	2026-04-14 06:48:58.688	2026-04-14 06:48:58.688
cmny9ggut02mwvxy45yyqt5ow	cmny9ggpb02mivxy41bqgb3cr	cmny9fd980008vxy4alsawn4y	16000	2026-04-14 06:48:58.709	2026-04-14 06:48:58.709
cmny9ggvm02myvxy4g9182snx	cmny9ggpb02mivxy41bqgb3cr	cmny9fd9w0009vxy498vvvu1d	16000	2026-04-14 06:48:58.738	2026-04-14 06:48:58.738
cmny9ggw902n0vxy4s12bdami	cmny9ggpb02mivxy41bqgb3cr	cmny9fdb9000bvxy4h02fexen	16000	2026-04-14 06:48:58.761	2026-04-14 06:48:58.761
cmny9ggx602n2vxy4u6tpz05x	cmny9ggpb02mivxy41bqgb3cr	cmny9fdc1000cvxy4n4y9ezu8	16000	2026-04-14 06:48:58.795	2026-04-14 06:48:58.795
cmny9ggxt02n4vxy4x4hyvgtp	cmny9ggpb02mivxy41bqgb3cr	cmny9fdcn000dvxy4w3gaald5	16000	2026-04-14 06:48:58.817	2026-04-14 06:48:58.817
cmny9ggz702n7vxy4kop20yc1	cmny9ggyl02n5vxy4hpe88pst	cmny9fd420001vxy42djthn1o	25000	2026-04-14 06:48:58.867	2026-04-14 06:48:58.867
cmny9ggzz02n9vxy4acg4xx2n	cmny9ggyl02n5vxy4hpe88pst	cmny9fd4t0002vxy4jo0l7gop	25000	2026-04-14 06:48:58.895	2026-04-14 06:48:58.895
cmny9gh0l02nbvxy4absmwcvk	cmny9ggyl02n5vxy4hpe88pst	cmny9fd5j0003vxy4sw5e14p1	25000	2026-04-14 06:48:58.918	2026-04-14 06:48:58.918
cmny9gh1n02ndvxy4bil1wg31	cmny9ggyl02n5vxy4hpe88pst	cmny9fd6h0004vxy4evm3jgfv	25000	2026-04-14 06:48:58.955	2026-04-14 06:48:58.955
cmny9gh2l02nfvxy43482ptko	cmny9ggyl02n5vxy4hpe88pst	cmny9fd7u0006vxy4mh4wwui4	25000	2026-04-14 06:48:58.989	2026-04-14 06:48:58.989
cmny9gh3h02nhvxy4poy93zra	cmny9ggyl02n5vxy4hpe88pst	cmny9fd8i0007vxy4tmc0glr0	25000	2026-04-14 06:48:59.021	2026-04-14 06:48:59.021
cmny9gh4202njvxy4w3ps1v43	cmny9ggyl02n5vxy4hpe88pst	cmny9fd980008vxy4alsawn4y	25000	2026-04-14 06:48:59.042	2026-04-14 06:48:59.042
cmny9gh4v02nlvxy4u3hf1bci	cmny9ggyl02n5vxy4hpe88pst	cmny9fd9w0009vxy498vvvu1d	25000	2026-04-14 06:48:59.072	2026-04-14 06:48:59.072
cmny9gh5i02nnvxy4zespyc0s	cmny9ggyl02n5vxy4hpe88pst	cmny9fdb9000bvxy4h02fexen	25000	2026-04-14 06:48:59.094	2026-04-14 06:48:59.094
cmny9gh6a02npvxy4retj91jc	cmny9ggyl02n5vxy4hpe88pst	cmny9fdc1000cvxy4n4y9ezu8	25000	2026-04-14 06:48:59.123	2026-04-14 06:48:59.123
cmny9gh6u02nrvxy4rzv2mzbv	cmny9ggyl02n5vxy4hpe88pst	cmny9fdcn000dvxy4w3gaald5	25000	2026-04-14 06:48:59.142	2026-04-14 06:48:59.142
cmny9gh8702nuvxy41mb6b7ge	cmny9gh7o02nsvxy4a91nwotv	cmny9fd420001vxy42djthn1o	19000	2026-04-14 06:48:59.192	2026-04-14 06:48:59.192
cmny9gh9102nwvxy41k0pqist	cmny9gh7o02nsvxy4a91nwotv	cmny9fd4t0002vxy4jo0l7gop	19000	2026-04-14 06:48:59.222	2026-04-14 06:48:59.222
cmny9gh9m02nyvxy4ysavlzp7	cmny9gh7o02nsvxy4a91nwotv	cmny9fd5j0003vxy4sw5e14p1	19000	2026-04-14 06:48:59.242	2026-04-14 06:48:59.242
cmny9ghag02o0vxy4ek0rtw65	cmny9gh7o02nsvxy4a91nwotv	cmny9fd6h0004vxy4evm3jgfv	19000	2026-04-14 06:48:59.272	2026-04-14 06:48:59.272
cmny9ghb202o2vxy4lswkh7zt	cmny9gh7o02nsvxy4a91nwotv	cmny9fd7u0006vxy4mh4wwui4	19000	2026-04-14 06:48:59.295	2026-04-14 06:48:59.295
cmny9ghbu02o4vxy46vt7h4l1	cmny9gh7o02nsvxy4a91nwotv	cmny9fd8i0007vxy4tmc0glr0	19000	2026-04-14 06:48:59.322	2026-04-14 06:48:59.322
cmny9ghce02o6vxy4vxbqeduj	cmny9gh7o02nsvxy4a91nwotv	cmny9fd980008vxy4alsawn4y	19000	2026-04-14 06:48:59.343	2026-04-14 06:48:59.343
cmny9ghd802o8vxy4qywjwo8r	cmny9gh7o02nsvxy4a91nwotv	cmny9fd9w0009vxy498vvvu1d	19000	2026-04-14 06:48:59.372	2026-04-14 06:48:59.372
cmny9ghe202oavxy4z54llr8i	cmny9gh7o02nsvxy4a91nwotv	cmny9fdb9000bvxy4h02fexen	19000	2026-04-14 06:48:59.402	2026-04-14 06:48:59.402
cmny9ghes02ocvxy4lapzxkip	cmny9gh7o02nsvxy4a91nwotv	cmny9fdc1000cvxy4n4y9ezu8	19000	2026-04-14 06:48:59.428	2026-04-14 06:48:59.428
cmny9ghff02oevxy4csff9s8s	cmny9gh7o02nsvxy4a91nwotv	cmny9fdcn000dvxy4w3gaald5	19000	2026-04-14 06:48:59.451	2026-04-14 06:48:59.451
cmny9ghh902ohvxy4vhd3npnt	cmny9ghgg02ofvxy4bqth4pt4	cmny9fd420001vxy42djthn1o	77000	2026-04-14 06:48:59.517	2026-04-14 06:48:59.517
cmny9ghib02ojvxy4aeulbn8e	cmny9ghgg02ofvxy4bqth4pt4	cmny9fd4t0002vxy4jo0l7gop	77000	2026-04-14 06:48:59.555	2026-04-14 06:48:59.555
cmny9ghiw02olvxy448vn4e0k	cmny9ghgg02ofvxy4bqth4pt4	cmny9fd5j0003vxy4sw5e14p1	77000	2026-04-14 06:48:59.576	2026-04-14 06:48:59.576
cmny9ghjp02onvxy40qma0aah	cmny9ghgg02ofvxy4bqth4pt4	cmny9fd6h0004vxy4evm3jgfv	77000	2026-04-14 06:48:59.605	2026-04-14 06:48:59.605
cmny9ghkc02opvxy45sz2143u	cmny9ghgg02ofvxy4bqth4pt4	cmny9fd7u0006vxy4mh4wwui4	77000	2026-04-14 06:48:59.628	2026-04-14 06:48:59.628
cmny9ghl402orvxy4rayjyogx	cmny9ghgg02ofvxy4bqth4pt4	cmny9fd8i0007vxy4tmc0glr0	77000	2026-04-14 06:48:59.656	2026-04-14 06:48:59.656
cmny9ghlv02otvxy4x1rp4fay	cmny9ghgg02ofvxy4bqth4pt4	cmny9fd980008vxy4alsawn4y	77000	2026-04-14 06:48:59.684	2026-04-14 06:48:59.684
cmny9ghmn02ovvxy4c0a56fnp	cmny9ghgg02ofvxy4bqth4pt4	cmny9fd9w0009vxy498vvvu1d	77000	2026-04-14 06:48:59.712	2026-04-14 06:48:59.712
cmny9ghnc02oxvxy4002933jf	cmny9ghgg02ofvxy4bqth4pt4	cmny9fdb9000bvxy4h02fexen	77000	2026-04-14 06:48:59.736	2026-04-14 06:48:59.736
cmny9ghoc02ozvxy4izu37chg	cmny9ghgg02ofvxy4bqth4pt4	cmny9fdc1000cvxy4n4y9ezu8	77000	2026-04-14 06:48:59.772	2026-04-14 06:48:59.772
cmny9ghow02p1vxy48bhg7m9t	cmny9ghgg02ofvxy4bqth4pt4	cmny9fdcn000dvxy4w3gaald5	77000	2026-04-14 06:48:59.792	2026-04-14 06:48:59.792
cmny9ghqz02p4vxy4kmq17mqm	cmny9ghqe02p2vxy470v027kp	cmny9fd420001vxy42djthn1o	140000	2026-04-14 06:48:59.867	2026-04-14 06:48:59.867
cmny9ghs102p6vxy4y43rp2am	cmny9ghqe02p2vxy470v027kp	cmny9fd4t0002vxy4jo0l7gop	140000	2026-04-14 06:48:59.906	2026-04-14 06:48:59.906
cmny9ghsl02p8vxy49utfzjx3	cmny9ghqe02p2vxy470v027kp	cmny9fd5j0003vxy4sw5e14p1	140000	2026-04-14 06:48:59.925	2026-04-14 06:48:59.925
cmny9ghtf02pavxy4ivwkcrhi	cmny9ghqe02p2vxy470v027kp	cmny9fd6h0004vxy4evm3jgfv	140000	2026-04-14 06:48:59.955	2026-04-14 06:48:59.955
cmny9ghuj02pcvxy4jdo1z16b	cmny9ghqe02p2vxy470v027kp	cmny9fd7u0006vxy4mh4wwui4	140000	2026-04-14 06:48:59.995	2026-04-14 06:48:59.995
cmny9ghvh02pevxy4l0h0ezs3	cmny9ghqe02p2vxy470v027kp	cmny9fd8i0007vxy4tmc0glr0	140000	2026-04-14 06:49:00.029	2026-04-14 06:49:00.029
cmny9ghw202pgvxy4t3y4e632	cmny9ghqe02p2vxy470v027kp	cmny9fd980008vxy4alsawn4y	140000	2026-04-14 06:49:00.05	2026-04-14 06:49:00.05
cmny9ghwt02pivxy49pn0um7a	cmny9ghqe02p2vxy470v027kp	cmny9fd9w0009vxy498vvvu1d	140000	2026-04-14 06:49:00.078	2026-04-14 06:49:00.078
cmny9ghxh02pkvxy4vu5iuusc	cmny9ghqe02p2vxy470v027kp	cmny9fdb9000bvxy4h02fexen	140000	2026-04-14 06:49:00.101	2026-04-14 06:49:00.101
cmny9ghy802pmvxy4p699nehp	cmny9ghqe02p2vxy470v027kp	cmny9fdc1000cvxy4n4y9ezu8	140000	2026-04-14 06:49:00.128	2026-04-14 06:49:00.128
cmny9ghyu02povxy4c9urgkj5	cmny9ghqe02p2vxy470v027kp	cmny9fdcn000dvxy4w3gaald5	140000	2026-04-14 06:49:00.15	2026-04-14 06:49:00.15
cmny9gi0802prvxy49otk2sv0	cmny9ghzm02ppvxy4b1qduz0d	cmny9fd420001vxy42djthn1o	73000	2026-04-14 06:49:00.2	2026-04-14 06:49:00.2
cmny9gi1002ptvxy4x095fi7v	cmny9ghzm02ppvxy4b1qduz0d	cmny9fd4t0002vxy4jo0l7gop	73000	2026-04-14 06:49:00.228	2026-04-14 06:49:00.228
cmny9gi2302pvvxy4afoxjx03	cmny9ghzm02ppvxy4b1qduz0d	cmny9fdc1000cvxy4n4y9ezu8	73000	2026-04-14 06:49:00.268	2026-04-14 06:49:00.268
cmny9gi3h02pyvxy4wedcn1oy	cmny9gi2x02pwvxy4wog9eue2	cmny9fd420001vxy42djthn1o	28000	2026-04-14 06:49:00.317	2026-04-14 06:49:00.317
cmny9gi4902q0vxy4lt3jy49e	cmny9gi2x02pwvxy4wog9eue2	cmny9fd4t0002vxy4jo0l7gop	28000	2026-04-14 06:49:00.345	2026-04-14 06:49:00.345
cmny9gi4v02q2vxy4a3gm29a7	cmny9gi2x02pwvxy4wog9eue2	cmny9fd5j0003vxy4sw5e14p1	28000	2026-04-14 06:49:00.367	2026-04-14 06:49:00.367
cmny9gi5m02q4vxy40g2tr4vl	cmny9gi2x02pwvxy4wog9eue2	cmny9fd6h0004vxy4evm3jgfv	28000	2026-04-14 06:49:00.395	2026-04-14 06:49:00.395
cmny9gi6a02q6vxy47oil64v3	cmny9gi2x02pwvxy4wog9eue2	cmny9fd7u0006vxy4mh4wwui4	28000	2026-04-14 06:49:00.418	2026-04-14 06:49:00.418
cmny9gi7102q8vxy44mkpaaz7	cmny9gi2x02pwvxy4wog9eue2	cmny9fd8i0007vxy4tmc0glr0	28000	2026-04-14 06:49:00.446	2026-04-14 06:49:00.446
cmny9gi7n02qavxy45rp79z4t	cmny9gi2x02pwvxy4wog9eue2	cmny9fd980008vxy4alsawn4y	28000	2026-04-14 06:49:00.467	2026-04-14 06:49:00.467
cmny9gi8e02qcvxy4o33h26of	cmny9gi2x02pwvxy4wog9eue2	cmny9fd9w0009vxy498vvvu1d	28000	2026-04-14 06:49:00.495	2026-04-14 06:49:00.495
cmny9gi9602qevxy4e7lhx0aa	cmny9gi2x02pwvxy4wog9eue2	cmny9fdb9000bvxy4h02fexen	28000	2026-04-14 06:49:00.522	2026-04-14 06:49:00.522
cmny9gia402qgvxy4l5lys8mz	cmny9gi2x02pwvxy4wog9eue2	cmny9fdc1000cvxy4n4y9ezu8	28000	2026-04-14 06:49:00.556	2026-04-14 06:49:00.556
cmny9giaw02qivxy4dw5fu7k5	cmny9gi2x02pwvxy4wog9eue2	cmny9fdcn000dvxy4w3gaald5	28000	2026-04-14 06:49:00.584	2026-04-14 06:49:00.584
cmny9gic902qlvxy48hdyd5yy	cmny9gibn02qjvxy4slwgu2dz	cmny9fd420001vxy42djthn1o	150000	2026-04-14 06:49:00.634	2026-04-14 06:49:00.634
cmny9gidc02qnvxy4ewersyv2	cmny9gibn02qjvxy4slwgu2dz	cmny9fd4t0002vxy4jo0l7gop	150000	2026-04-14 06:49:00.672	2026-04-14 06:49:00.672
cmny9gidx02qpvxy462ie0393	cmny9gibn02qjvxy4slwgu2dz	cmny9fd5j0003vxy4sw5e14p1	150000	2026-04-14 06:49:00.693	2026-04-14 06:49:00.693
cmny9gieq02qrvxy4on5odbtf	cmny9gibn02qjvxy4slwgu2dz	cmny9fd6h0004vxy4evm3jgfv	150000	2026-04-14 06:49:00.722	2026-04-14 06:49:00.722
cmny9gifl02qtvxy44kwo706u	cmny9gibn02qjvxy4slwgu2dz	cmny9fd7u0006vxy4mh4wwui4	150000	2026-04-14 06:49:00.753	2026-04-14 06:49:00.753
cmny9gigk02qvvxy4zmy3sfd6	cmny9gibn02qjvxy4slwgu2dz	cmny9fd8i0007vxy4tmc0glr0	150000	2026-04-14 06:49:00.788	2026-04-14 06:49:00.788
cmny9gihd02qxvxy4ua4lvm7s	cmny9gibn02qjvxy4slwgu2dz	cmny9fd980008vxy4alsawn4y	150000	2026-04-14 06:49:00.817	2026-04-14 06:49:00.817
cmny9gii502qzvxy46lmrsyit	cmny9gibn02qjvxy4slwgu2dz	cmny9fd9w0009vxy498vvvu1d	150000	2026-04-14 06:49:00.845	2026-04-14 06:49:00.845
cmny9giix02r1vxy4jswxya33	cmny9gibn02qjvxy4slwgu2dz	cmny9fdb9000bvxy4h02fexen	150000	2026-04-14 06:49:00.873	2026-04-14 06:49:00.873
cmny9gijt02r3vxy452zqo68a	cmny9gibn02qjvxy4slwgu2dz	cmny9fdc1000cvxy4n4y9ezu8	150000	2026-04-14 06:49:00.906	2026-04-14 06:49:00.906
cmny9gikm02r5vxy4j44q12t3	cmny9gibn02qjvxy4slwgu2dz	cmny9fdcn000dvxy4w3gaald5	150000	2026-04-14 06:49:00.934	2026-04-14 06:49:00.934
cmny9gio602r9vxy4vpv09hk3	cmny9gin802r7vxy4iblmdrsa	cmny9fd420001vxy42djthn1o	38000	2026-04-14 06:49:01.062	2026-04-14 06:49:01.062
cmny9gipa02rbvxy4g2px0fdf	cmny9gin802r7vxy4iblmdrsa	cmny9fd4t0002vxy4jo0l7gop	38000	2026-04-14 06:49:01.102	2026-04-14 06:49:01.102
cmny9giq802rdvxy4vvtoh1wz	cmny9gin802r7vxy4iblmdrsa	cmny9fd5j0003vxy4sw5e14p1	38000	2026-04-14 06:49:01.136	2026-04-14 06:49:01.136
cmny9giqv02rfvxy4fn3ejo8x	cmny9gin802r7vxy4iblmdrsa	cmny9fd6h0004vxy4evm3jgfv	38000	2026-04-14 06:49:01.16	2026-04-14 06:49:01.16
cmny9gisn02rhvxy479ssm6ux	cmny9gin802r7vxy4iblmdrsa	cmny9fd7u0006vxy4mh4wwui4	38000	2026-04-14 06:49:01.224	2026-04-14 06:49:01.224
cmny9gitf02rjvxy440uk88jg	cmny9gin802r7vxy4iblmdrsa	cmny9fd8i0007vxy4tmc0glr0	38000	2026-04-14 06:49:01.251	2026-04-14 06:49:01.251
cmny9giug02rlvxy4vq0czv8g	cmny9gin802r7vxy4iblmdrsa	cmny9fd980008vxy4alsawn4y	38000	2026-04-14 06:49:01.288	2026-04-14 06:49:01.288
cmny9giv102rnvxy48wfwzjid	cmny9gin802r7vxy4iblmdrsa	cmny9fd9w0009vxy498vvvu1d	38000	2026-04-14 06:49:01.31	2026-04-14 06:49:01.31
cmny9givy02rpvxy4getibaa5	cmny9gin802r7vxy4iblmdrsa	cmny9fdb9000bvxy4h02fexen	38000	2026-04-14 06:49:01.342	2026-04-14 06:49:01.342
cmny9giwn02rrvxy4x1p4kz0g	cmny9gin802r7vxy4iblmdrsa	cmny9fdc1000cvxy4n4y9ezu8	38000	2026-04-14 06:49:01.367	2026-04-14 06:49:01.367
cmny9giyb02rtvxy4qayydzgn	cmny9gin802r7vxy4iblmdrsa	cmny9fdcn000dvxy4w3gaald5	38000	2026-04-14 06:49:01.427	2026-04-14 06:49:01.427
cmny9gj0002rwvxy4c84d1fa3	cmny9giyz02ruvxy4s14ulepv	cmny9fd420001vxy42djthn1o	38000	2026-04-14 06:49:01.488	2026-04-14 06:49:01.488
cmny9gj0l02ryvxy44prmie8g	cmny9giyz02ruvxy4s14ulepv	cmny9fd4t0002vxy4jo0l7gop	38000	2026-04-14 06:49:01.509	2026-04-14 06:49:01.509
cmny9gj1e02s0vxy4ming031k	cmny9giyz02ruvxy4s14ulepv	cmny9fd5j0003vxy4sw5e14p1	38000	2026-04-14 06:49:01.538	2026-04-14 06:49:01.538
cmny9gj1z02s2vxy4ksqd7wos	cmny9giyz02ruvxy4s14ulepv	cmny9fd6h0004vxy4evm3jgfv	38000	2026-04-14 06:49:01.559	2026-04-14 06:49:01.559
cmny9gj2u02s4vxy4txmsjf98	cmny9giyz02ruvxy4s14ulepv	cmny9fd7u0006vxy4mh4wwui4	38000	2026-04-14 06:49:01.59	2026-04-14 06:49:01.59
cmny9gj4d02s6vxy47npzhset	cmny9giyz02ruvxy4s14ulepv	cmny9fd8i0007vxy4tmc0glr0	38000	2026-04-14 06:49:01.645	2026-04-14 06:49:01.645
cmny9gj4z02s8vxy4isud69w3	cmny9giyz02ruvxy4s14ulepv	cmny9fd980008vxy4alsawn4y	38000	2026-04-14 06:49:01.667	2026-04-14 06:49:01.667
cmny9gj5r02savxy4662y5f8c	cmny9giyz02ruvxy4s14ulepv	cmny9fd9w0009vxy498vvvu1d	38000	2026-04-14 06:49:01.695	2026-04-14 06:49:01.695
cmny9gj6i02scvxy4h8tgov4f	cmny9giyz02ruvxy4s14ulepv	cmny9fdb9000bvxy4h02fexen	38000	2026-04-14 06:49:01.723	2026-04-14 06:49:01.723
cmny9gj7g02sevxy40kczvt6w	cmny9giyz02ruvxy4s14ulepv	cmny9fdc1000cvxy4n4y9ezu8	38000	2026-04-14 06:49:01.756	2026-04-14 06:49:01.756
cmny9gj8g02sgvxy4qjbggcrd	cmny9giyz02ruvxy4s14ulepv	cmny9fdcn000dvxy4w3gaald5	38000	2026-04-14 06:49:01.793	2026-04-14 06:49:01.793
cmny9gjca02sjvxy4i42ui8f8	cmny9gjaj02shvxy4h18olfo4	cmny9fd420001vxy42djthn1o	38000	2026-04-14 06:49:01.93	2026-04-14 06:49:01.93
cmny9gjd302slvxy4ckh0c574	cmny9gjaj02shvxy4h18olfo4	cmny9fd4t0002vxy4jo0l7gop	38000	2026-04-14 06:49:01.959	2026-04-14 06:49:01.959
cmny9gjdx02snvxy4l7hjojqv	cmny9gjaj02shvxy4h18olfo4	cmny9fd5j0003vxy4sw5e14p1	38000	2026-04-14 06:49:01.989	2026-04-14 06:49:01.989
cmny9gjei02spvxy47slmtond	cmny9gjaj02shvxy4h18olfo4	cmny9fd6h0004vxy4evm3jgfv	38000	2026-04-14 06:49:02.01	2026-04-14 06:49:02.01
cmny9gjgd02srvxy4yl3mpg4p	cmny9gjaj02shvxy4h18olfo4	cmny9fd7u0006vxy4mh4wwui4	38000	2026-04-14 06:49:02.077	2026-04-14 06:49:02.077
cmny9gjh102stvxy4gbzpidh7	cmny9gjaj02shvxy4h18olfo4	cmny9fd8i0007vxy4tmc0glr0	38000	2026-04-14 06:49:02.101	2026-04-14 06:49:02.101
cmny9gji602svvxy49klmfi01	cmny9gjaj02shvxy4h18olfo4	cmny9fd980008vxy4alsawn4y	38000	2026-04-14 06:49:02.142	2026-04-14 06:49:02.142
cmny9gjj702sxvxy43wpqu6ah	cmny9gjaj02shvxy4h18olfo4	cmny9fd9w0009vxy498vvvu1d	38000	2026-04-14 06:49:02.179	2026-04-14 06:49:02.179
cmny9gjk802szvxy4ku5tjpmu	cmny9gjaj02shvxy4h18olfo4	cmny9fdb9000bvxy4h02fexen	38000	2026-04-14 06:49:02.216	2026-04-14 06:49:02.216
cmny9gjmg02t1vxy4cadk2km4	cmny9gjaj02shvxy4h18olfo4	cmny9fdc1000cvxy4n4y9ezu8	38000	2026-04-14 06:49:02.296	2026-04-14 06:49:02.296
cmny9gjov02t3vxy4gq85akjv	cmny9gjaj02shvxy4h18olfo4	cmny9fdcn000dvxy4w3gaald5	38000	2026-04-14 06:49:02.383	2026-04-14 06:49:02.383
cmny9gjqt02t6vxy49e3l8ixl	cmny9gjpy02t4vxy4vnf31ad2	cmny9fd420001vxy42djthn1o	58000	2026-04-14 06:49:02.452	2026-04-14 06:49:02.452
cmny9gjs202t8vxy441myf78g	cmny9gjpy02t4vxy4vnf31ad2	cmny9fd4t0002vxy4jo0l7gop	58000	2026-04-14 06:49:02.499	2026-04-14 06:49:02.499
cmny9gjue02tavxy4b3mjsyi5	cmny9gjpy02t4vxy4vnf31ad2	cmny9fd5j0003vxy4sw5e14p1	58000	2026-04-14 06:49:02.582	2026-04-14 06:49:02.582
cmny9gjva02tcvxy4upt3427k	cmny9gjpy02t4vxy4vnf31ad2	cmny9fd6h0004vxy4evm3jgfv	58000	2026-04-14 06:49:02.615	2026-04-14 06:49:02.615
cmny9gjwa02tevxy4y1g0t6g4	cmny9gjpy02t4vxy4vnf31ad2	cmny9fd7u0006vxy4mh4wwui4	58000	2026-04-14 06:49:02.65	2026-04-14 06:49:02.65
cmny9gjx102tgvxy4tn2cii1f	cmny9gjpy02t4vxy4vnf31ad2	cmny9fd8i0007vxy4tmc0glr0	58000	2026-04-14 06:49:02.677	2026-04-14 06:49:02.677
cmny9gjy002tivxy4d571a1a9	cmny9gjpy02t4vxy4vnf31ad2	cmny9fd980008vxy4alsawn4y	58000	2026-04-14 06:49:02.711	2026-04-14 06:49:02.711
cmny9gjz902tkvxy4mgc66792	cmny9gjpy02t4vxy4vnf31ad2	cmny9fd9w0009vxy498vvvu1d	58000	2026-04-14 06:49:02.757	2026-04-14 06:49:02.757
cmny9gk0c02tmvxy47sqxto3c	cmny9gjpy02t4vxy4vnf31ad2	cmny9fdb9000bvxy4h02fexen	58000	2026-04-14 06:49:02.796	2026-04-14 06:49:02.796
cmny9gk1p02tovxy42i4u5yfm	cmny9gjpy02t4vxy4vnf31ad2	cmny9fdc1000cvxy4n4y9ezu8	58000	2026-04-14 06:49:02.845	2026-04-14 06:49:02.845
cmny9gk2m02tqvxy463n6gkw7	cmny9gjpy02t4vxy4vnf31ad2	cmny9fdcn000dvxy4w3gaald5	58000	2026-04-14 06:49:02.878	2026-04-14 06:49:02.878
cmny9gk5r02ttvxy4d3mbqm7x	cmny9gk3z02trvxy4jto8i1o6	cmny9fd420001vxy42djthn1o	700000	2026-04-14 06:49:02.991	2026-04-14 06:49:02.991
cmny9gk6l02tvvxy4r2i5z61n	cmny9gk3z02trvxy4jto8i1o6	cmny9fd4t0002vxy4jo0l7gop	700000	2026-04-14 06:49:03.021	2026-04-14 06:49:03.021
cmny9gk8a02txvxy43p4qj6sa	cmny9gk3z02trvxy4jto8i1o6	cmny9fd7u0006vxy4mh4wwui4	700000	2026-04-14 06:49:03.082	2026-04-14 06:49:03.082
cmny9gka002tzvxy43elfdw2q	cmny9gk3z02trvxy4jto8i1o6	cmny9fdc1000cvxy4n4y9ezu8	700000	2026-04-14 06:49:03.144	2026-04-14 06:49:03.144
cmny9gkc502u2vxy4a10783f0	cmny9gkb902u0vxy4nyewufpm	cmny9fd420001vxy42djthn1o	50000	2026-04-14 06:49:03.221	2026-04-14 06:49:03.221
cmny9gkda02u4vxy47209vfzw	cmny9gkb902u0vxy4nyewufpm	cmny9fd4t0002vxy4jo0l7gop	50000	2026-04-14 06:49:03.262	2026-04-14 06:49:03.262
cmny9gke102u6vxy4xok1gcfu	cmny9gkb902u0vxy4nyewufpm	cmny9fd5j0003vxy4sw5e14p1	50000	2026-04-14 06:49:03.289	2026-04-14 06:49:03.289
cmny9gkew02u8vxy4jfaqber7	cmny9gkb902u0vxy4nyewufpm	cmny9fd6h0004vxy4evm3jgfv	50000	2026-04-14 06:49:03.32	2026-04-14 06:49:03.32
cmny9gkfx02uavxy4v1xo1ik4	cmny9gkb902u0vxy4nyewufpm	cmny9fd7u0006vxy4mh4wwui4	50000	2026-04-14 06:49:03.357	2026-04-14 06:49:03.357
cmny9gkgw02ucvxy40r7d8a1h	cmny9gkb902u0vxy4nyewufpm	cmny9fd8i0007vxy4tmc0glr0	50000	2026-04-14 06:49:03.392	2026-04-14 06:49:03.392
cmny9gkjg02uevxy463zdz0j8	cmny9gkb902u0vxy4nyewufpm	cmny9fd980008vxy4alsawn4y	50000	2026-04-14 06:49:03.482	2026-04-14 06:49:03.482
cmny9gknt02ugvxy4samctux0	cmny9gkb902u0vxy4nyewufpm	cmny9fd9w0009vxy498vvvu1d	50000	2026-04-14 06:49:03.641	2026-04-14 06:49:03.641
cmny9gkq202uivxy41cya56i3	cmny9gkb902u0vxy4nyewufpm	cmny9fdb9000bvxy4h02fexen	50000	2026-04-14 06:49:03.722	2026-04-14 06:49:03.722
cmny9gkrf02ukvxy4z6z8458t	cmny9gkb902u0vxy4nyewufpm	cmny9fdc1000cvxy4n4y9ezu8	50000	2026-04-14 06:49:03.771	2026-04-14 06:49:03.771
cmny9gks902umvxy4n41kc1dt	cmny9gkb902u0vxy4nyewufpm	cmny9fdcn000dvxy4w3gaald5	50000	2026-04-14 06:49:03.801	2026-04-14 06:49:03.801
cmny9gku002upvxy4pnr2vzgh	cmny9gkt302unvxy4mlma5f9w	cmny9fd420001vxy42djthn1o	700000	2026-04-14 06:49:03.864	2026-04-14 06:49:03.864
cmny9gkv302urvxy4bph0yzgt	cmny9gkt302unvxy4mlma5f9w	cmny9fd4t0002vxy4jo0l7gop	700000	2026-04-14 06:49:03.903	2026-04-14 06:49:03.903
cmny9gkvq02utvxy4krfqp7es	cmny9gkt302unvxy4mlma5f9w	cmny9fd5j0003vxy4sw5e14p1	700000	2026-04-14 06:49:03.926	2026-04-14 06:49:03.926
cmny9gkwh02uvvxy4wpl0i3o6	cmny9gkt302unvxy4mlma5f9w	cmny9fd6h0004vxy4evm3jgfv	700000	2026-04-14 06:49:03.953	2026-04-14 06:49:03.953
cmny9gkx602uxvxy445ivrzq8	cmny9gkt302unvxy4mlma5f9w	cmny9fd7u0006vxy4mh4wwui4	700000	2026-04-14 06:49:03.978	2026-04-14 06:49:03.978
cmny9gkxv02uzvxy4n766sgp7	cmny9gkt302unvxy4mlma5f9w	cmny9fd8i0007vxy4tmc0glr0	700000	2026-04-14 06:49:04.004	2026-04-14 06:49:04.004
cmny9gkyj02v1vxy4kzisylil	cmny9gkt302unvxy4mlma5f9w	cmny9fd980008vxy4alsawn4y	700000	2026-04-14 06:49:04.027	2026-04-14 06:49:04.027
cmny9gkza02v3vxy4oatx1cfk	cmny9gkt302unvxy4mlma5f9w	cmny9fd9w0009vxy498vvvu1d	700000	2026-04-14 06:49:04.054	2026-04-14 06:49:04.054
cmny9gl0702v5vxy4tmkd96bl	cmny9gkt302unvxy4mlma5f9w	cmny9fdb9000bvxy4h02fexen	700000	2026-04-14 06:49:04.087	2026-04-14 06:49:04.087
cmny9gl1b02v7vxy4xe10411d	cmny9gkt302unvxy4mlma5f9w	cmny9fdc1000cvxy4n4y9ezu8	700000	2026-04-14 06:49:04.128	2026-04-14 06:49:04.128
cmny9gl1y02v9vxy40o5gu72h	cmny9gkt302unvxy4mlma5f9w	cmny9fdcn000dvxy4w3gaald5	700000	2026-04-14 06:49:04.151	2026-04-14 06:49:04.151
cmny9gl3c02vcvxy4nzypwnw2	cmny9gl2p02vavxy41pnrbpjb	cmny9fd420001vxy42djthn1o	79000	2026-04-14 06:49:04.201	2026-04-14 06:49:04.201
cmny9gl4302vevxy47iubyl5r	cmny9gl2p02vavxy41pnrbpjb	cmny9fd4t0002vxy4jo0l7gop	79000	2026-04-14 06:49:04.228	2026-04-14 06:49:04.228
cmny9gl4r02vgvxy4zfi90l26	cmny9gl2p02vavxy41pnrbpjb	cmny9fd5j0003vxy4sw5e14p1	79000	2026-04-14 06:49:04.251	2026-04-14 06:49:04.251
cmny9gl6a02vivxy4uncprymw	cmny9gl2p02vavxy41pnrbpjb	cmny9fd6h0004vxy4evm3jgfv	79000	2026-04-14 06:49:04.305	2026-04-14 06:49:04.305
cmny9gl7h02vkvxy4thjx6z1m	cmny9gl2p02vavxy41pnrbpjb	cmny9fd7u0006vxy4mh4wwui4	79000	2026-04-14 06:49:04.349	2026-04-14 06:49:04.349
cmny9gl8802vmvxy4ks67t4h9	cmny9gl2p02vavxy41pnrbpjb	cmny9fd8i0007vxy4tmc0glr0	79000	2026-04-14 06:49:04.376	2026-04-14 06:49:04.376
cmny9gl8z02vovxy4j0j1b2u4	cmny9gl2p02vavxy41pnrbpjb	cmny9fd980008vxy4alsawn4y	79000	2026-04-14 06:49:04.403	2026-04-14 06:49:04.403
cmny9gl9m02vqvxy44ikiq893	cmny9gl2p02vavxy41pnrbpjb	cmny9fd9w0009vxy498vvvu1d	79000	2026-04-14 06:49:04.426	2026-04-14 06:49:04.426
cmny9glag02vsvxy498i3pilt	cmny9gl2p02vavxy41pnrbpjb	cmny9fdb9000bvxy4h02fexen	79000	2026-04-14 06:49:04.456	2026-04-14 06:49:04.456
cmny9glb802vuvxy48hhfqzp6	cmny9gl2p02vavxy41pnrbpjb	cmny9fdc1000cvxy4n4y9ezu8	79000	2026-04-14 06:49:04.485	2026-04-14 06:49:04.485
cmny9glby02vwvxy47pn6cr2w	cmny9gl2p02vavxy41pnrbpjb	cmny9fdcn000dvxy4w3gaald5	79000	2026-04-14 06:49:04.511	2026-04-14 06:49:04.511
cmny9glde02vzvxy4nk5cd2fe	cmny9glcn02vxvxy49n0w7a07	cmny9fd420001vxy42djthn1o	84000	2026-04-14 06:49:04.562	2026-04-14 06:49:04.562
cmny9gle002w1vxy4qjvl5llo	cmny9glcn02vxvxy49n0w7a07	cmny9fd4t0002vxy4jo0l7gop	84000	2026-04-14 06:49:04.584	2026-04-14 06:49:04.584
cmny9gleq02w3vxy45078l6vh	cmny9glcn02vxvxy49n0w7a07	cmny9fd5j0003vxy4sw5e14p1	84000	2026-04-14 06:49:04.611	2026-04-14 06:49:04.611
cmny9glfe02w5vxy4lkr0f97o	cmny9glcn02vxvxy49n0w7a07	cmny9fd6h0004vxy4evm3jgfv	84000	2026-04-14 06:49:04.635	2026-04-14 06:49:04.635
cmny9glgg02w7vxy4k6p0esde	cmny9glcn02vxvxy49n0w7a07	cmny9fd7u0006vxy4mh4wwui4	84000	2026-04-14 06:49:04.673	2026-04-14 06:49:04.673
cmny9glh902w9vxy4fooflm0f	cmny9glcn02vxvxy49n0w7a07	cmny9fd8i0007vxy4tmc0glr0	84000	2026-04-14 06:49:04.701	2026-04-14 06:49:04.701
cmny9gli002wbvxy4x2em8mf9	cmny9glcn02vxvxy49n0w7a07	cmny9fd980008vxy4alsawn4y	84000	2026-04-14 06:49:04.728	2026-04-14 06:49:04.728
cmny9glin02wdvxy4txpdmqeu	cmny9glcn02vxvxy49n0w7a07	cmny9fd9w0009vxy498vvvu1d	84000	2026-04-14 06:49:04.751	2026-04-14 06:49:04.751
cmny9glk702wfvxy430v9gr5h	cmny9glcn02vxvxy49n0w7a07	cmny9fdb9000bvxy4h02fexen	84000	2026-04-14 06:49:04.807	2026-04-14 06:49:04.807
cmny9gll002whvxy4ktecqddo	cmny9glcn02vxvxy49n0w7a07	cmny9fdc1000cvxy4n4y9ezu8	84000	2026-04-14 06:49:04.837	2026-04-14 06:49:04.837
cmny9glln02wjvxy4thv5u4bo	cmny9glcn02vxvxy49n0w7a07	cmny9fdcn000dvxy4w3gaald5	84000	2026-04-14 06:49:04.859	2026-04-14 06:49:04.859
cmny9gln202wmvxy4exg5r7as	cmny9glme02wkvxy4tk6d21q5	cmny9fd420001vxy42djthn1o	90000	2026-04-14 06:49:04.91	2026-04-14 06:49:04.91
cmny9glns02wovxy42fw630eo	cmny9glme02wkvxy4tk6d21q5	cmny9fd4t0002vxy4jo0l7gop	90000	2026-04-14 06:49:04.937	2026-04-14 06:49:04.937
cmny9gloh02wqvxy4pfmhw360	cmny9glme02wkvxy4tk6d21q5	cmny9fd5j0003vxy4sw5e14p1	90000	2026-04-14 06:49:04.961	2026-04-14 06:49:04.961
cmny9glpl02wsvxy4ckjeuzmr	cmny9glme02wkvxy4tk6d21q5	cmny9fd6h0004vxy4evm3jgfv	90000	2026-04-14 06:49:05.001	2026-04-14 06:49:05.001
cmny9glqc02wuvxy4m7b0fcg2	cmny9glme02wkvxy4tk6d21q5	cmny9fd7u0006vxy4mh4wwui4	90000	2026-04-14 06:49:05.028	2026-04-14 06:49:05.028
cmny9glr002wwvxy4vlfuihe0	cmny9glme02wkvxy4tk6d21q5	cmny9fd8i0007vxy4tmc0glr0	90000	2026-04-14 06:49:05.052	2026-04-14 06:49:05.052
cmny9gls002wyvxy43ypamkd7	cmny9glme02wkvxy4tk6d21q5	cmny9fd980008vxy4alsawn4y	90000	2026-04-14 06:49:05.088	2026-04-14 06:49:05.088
cmny9glst02x0vxy45yk3izeg	cmny9glme02wkvxy4tk6d21q5	cmny9fd9w0009vxy498vvvu1d	90000	2026-04-14 06:49:05.118	2026-04-14 06:49:05.118
cmny9gltl02x2vxy46chamtfm	cmny9glme02wkvxy4tk6d21q5	cmny9fdb9000bvxy4h02fexen	90000	2026-04-14 06:49:05.145	2026-04-14 06:49:05.145
cmny9glu702x4vxy43v3l3r5p	cmny9glme02wkvxy4tk6d21q5	cmny9fdc1000cvxy4n4y9ezu8	90000	2026-04-14 06:49:05.168	2026-04-14 06:49:05.168
cmny9glvf02x6vxy45c2q2u6h	cmny9glme02wkvxy4tk6d21q5	cmny9fdcn000dvxy4w3gaald5	90000	2026-04-14 06:49:05.211	2026-04-14 06:49:05.211
cmny9glwz02x9vxy4dgtnucb5	cmny9glw502x7vxy4nahgc1d1	cmny9fd420001vxy42djthn1o	90000	2026-04-14 06:49:05.268	2026-04-14 06:49:05.268
cmny9gly202xbvxy4i5kohjqn	cmny9glw502x7vxy4nahgc1d1	cmny9fd4t0002vxy4jo0l7gop	90000	2026-04-14 06:49:05.306	2026-04-14 06:49:05.306
cmny9glyy02xdvxy4gohmk3n3	cmny9glw502x7vxy4nahgc1d1	cmny9fd5j0003vxy4sw5e14p1	90000	2026-04-14 06:49:05.338	2026-04-14 06:49:05.338
cmny9glzy02xfvxy4yatmy6ey	cmny9glw502x7vxy4nahgc1d1	cmny9fd6h0004vxy4evm3jgfv	90000	2026-04-14 06:49:05.374	2026-04-14 06:49:05.374
cmny9gm1402xhvxy4jm32ftju	cmny9glw502x7vxy4nahgc1d1	cmny9fd7u0006vxy4mh4wwui4	90000	2026-04-14 06:49:05.417	2026-04-14 06:49:05.417
cmny9gm1w02xjvxy4673vi477	cmny9glw502x7vxy4nahgc1d1	cmny9fd8i0007vxy4tmc0glr0	90000	2026-04-14 06:49:05.444	2026-04-14 06:49:05.444
cmny9gm2j02xlvxy4uyect5ks	cmny9glw502x7vxy4nahgc1d1	cmny9fd980008vxy4alsawn4y	90000	2026-04-14 06:49:05.468	2026-04-14 06:49:05.468
cmny9gm3k02xnvxy4uyyfmskq	cmny9glw502x7vxy4nahgc1d1	cmny9fd9w0009vxy498vvvu1d	80000	2026-04-14 06:49:05.504	2026-04-14 06:49:05.504
cmny9gm4802xpvxy45uqmya8p	cmny9glw502x7vxy4nahgc1d1	cmny9fdb9000bvxy4h02fexen	90000	2026-04-14 06:49:05.529	2026-04-14 06:49:05.529
cmny9gm4z02xrvxy416a3f3x0	cmny9glw502x7vxy4nahgc1d1	cmny9fdc1000cvxy4n4y9ezu8	90000	2026-04-14 06:49:05.555	2026-04-14 06:49:05.555
cmny9gm5v02xtvxy4lqpd1o8e	cmny9glw502x7vxy4nahgc1d1	cmny9fdcn000dvxy4w3gaald5	90000	2026-04-14 06:49:05.587	2026-04-14 06:49:05.587
cmny9gmbm02xwvxy449iq5ebt	cmny9gmat02xuvxy4xxszxxur	cmny9fd420001vxy42djthn1o	90000	2026-04-14 06:49:05.795	2026-04-14 06:49:05.795
cmny9gmcb02xyvxy4v73nncff	cmny9gmat02xuvxy4xxszxxur	cmny9fd4t0002vxy4jo0l7gop	90000	2026-04-14 06:49:05.819	2026-04-14 06:49:05.819
cmny9gmd002y0vxy4uih0ogq7	cmny9gmat02xuvxy4xxszxxur	cmny9fd5j0003vxy4sw5e14p1	90000	2026-04-14 06:49:05.845	2026-04-14 06:49:05.845
cmny9gmdn02y2vxy4cw1lyv63	cmny9gmat02xuvxy4xxszxxur	cmny9fd6h0004vxy4evm3jgfv	90000	2026-04-14 06:49:05.868	2026-04-14 06:49:05.868
cmny9gmef02y4vxy4m3s459ju	cmny9gmat02xuvxy4xxszxxur	cmny9fd7u0006vxy4mh4wwui4	90000	2026-04-14 06:49:05.895	2026-04-14 06:49:05.895
cmny9gmf202y6vxy4spmn0fbn	cmny9gmat02xuvxy4xxszxxur	cmny9fd8i0007vxy4tmc0glr0	90000	2026-04-14 06:49:05.918	2026-04-14 06:49:05.918
cmny9gmfs02y8vxy403wo7cd5	cmny9gmat02xuvxy4xxszxxur	cmny9fd980008vxy4alsawn4y	90000	2026-04-14 06:49:05.944	2026-04-14 06:49:05.944
cmny9gmgf02yavxy4zvvdblof	cmny9gmat02xuvxy4xxszxxur	cmny9fd9w0009vxy498vvvu1d	80000	2026-04-14 06:49:05.968	2026-04-14 06:49:05.968
cmny9gmh702ycvxy4arvp7fk6	cmny9gmat02xuvxy4xxszxxur	cmny9fdb9000bvxy4h02fexen	90000	2026-04-14 06:49:05.996	2026-04-14 06:49:05.996
cmny9gmhz02yevxy42ed5bn1m	cmny9gmat02xuvxy4xxszxxur	cmny9fdc1000cvxy4n4y9ezu8	90000	2026-04-14 06:49:06.023	2026-04-14 06:49:06.023
cmny9gmiw02ygvxy4twv1iknr	cmny9gmat02xuvxy4xxszxxur	cmny9fdcn000dvxy4w3gaald5	90000	2026-04-14 06:49:06.056	2026-04-14 06:49:06.056
cmny9gml202yjvxy4wb7ciz4p	cmny9gmju02yhvxy450sl0ev7	cmny9fd420001vxy42djthn1o	90000	2026-04-14 06:49:06.134	2026-04-14 06:49:06.134
cmny9gmlt02ylvxy42w5lacfz	cmny9gmju02yhvxy450sl0ev7	cmny9fd4t0002vxy4jo0l7gop	90000	2026-04-14 06:49:06.161	2026-04-14 06:49:06.161
cmny9gmmg02ynvxy4nuk78s5f	cmny9gmju02yhvxy450sl0ev7	cmny9fd5j0003vxy4sw5e14p1	90000	2026-04-14 06:49:06.184	2026-04-14 06:49:06.184
cmny9gmn702ypvxy4t4si2qjo	cmny9gmju02yhvxy450sl0ev7	cmny9fd6h0004vxy4evm3jgfv	90000	2026-04-14 06:49:06.211	2026-04-14 06:49:06.211
cmny9gmnx02yrvxy4yk532qyo	cmny9gmju02yhvxy450sl0ev7	cmny9fd7u0006vxy4mh4wwui4	90000	2026-04-14 06:49:06.237	2026-04-14 06:49:06.237
cmny9gmol02ytvxy4gay4picg	cmny9gmju02yhvxy450sl0ev7	cmny9fd8i0007vxy4tmc0glr0	90000	2026-04-14 06:49:06.261	2026-04-14 06:49:06.261
cmny9gmp802yvvxy4ur92kqsi	cmny9gmju02yhvxy450sl0ev7	cmny9fd980008vxy4alsawn4y	90000	2026-04-14 06:49:06.284	2026-04-14 06:49:06.284
cmny9gmpz02yxvxy4sz8r1ssj	cmny9gmju02yhvxy450sl0ev7	cmny9fd9w0009vxy498vvvu1d	80000	2026-04-14 06:49:06.311	2026-04-14 06:49:06.311
cmny9gmqr02yzvxy4yv5hrj4g	cmny9gmju02yhvxy450sl0ev7	cmny9fdb9000bvxy4h02fexen	90000	2026-04-14 06:49:06.34	2026-04-14 06:49:06.34
cmny9gmrn02z1vxy4au72np7u	cmny9gmju02yhvxy450sl0ev7	cmny9fdc1000cvxy4n4y9ezu8	90000	2026-04-14 06:49:06.371	2026-04-14 06:49:06.371
cmny9gmss02z3vxy4y7en1e3n	cmny9gmju02yhvxy450sl0ev7	cmny9fdcn000dvxy4w3gaald5	90000	2026-04-14 06:49:06.413	2026-04-14 06:49:06.413
cmny9gmuc02z6vxy41bopz66u	cmny9gmto02z4vxy4invdhxc2	cmny9fd420001vxy42djthn1o	90000	2026-04-14 06:49:06.468	2026-04-14 06:49:06.468
cmny9gmv202z8vxy46ukshfr0	cmny9gmto02z4vxy4invdhxc2	cmny9fd4t0002vxy4jo0l7gop	90000	2026-04-14 06:49:06.494	2026-04-14 06:49:06.494
cmny9gmvp02zavxy4sr3u8c03	cmny9gmto02z4vxy4invdhxc2	cmny9fd5j0003vxy4sw5e14p1	90000	2026-04-14 06:49:06.518	2026-04-14 06:49:06.518
cmny9gmwg02zcvxy4pxamnl22	cmny9gmto02z4vxy4invdhxc2	cmny9fd6h0004vxy4evm3jgfv	90000	2026-04-14 06:49:06.545	2026-04-14 06:49:06.545
cmny9gmx802zevxy4rohj3w57	cmny9gmto02z4vxy4invdhxc2	cmny9fd7u0006vxy4mh4wwui4	90000	2026-04-14 06:49:06.572	2026-04-14 06:49:06.572
cmny9gmy402zgvxy429dgtq7r	cmny9gmto02z4vxy4invdhxc2	cmny9fd8i0007vxy4tmc0glr0	90000	2026-04-14 06:49:06.604	2026-04-14 06:49:06.604
cmny9gmyr02zivxy4bwezbdud	cmny9gmto02z4vxy4invdhxc2	cmny9fd980008vxy4alsawn4y	90000	2026-04-14 06:49:06.627	2026-04-14 06:49:06.627
cmny9gmzh02zkvxy439a20knp	cmny9gmto02z4vxy4invdhxc2	cmny9fd9w0009vxy498vvvu1d	80000	2026-04-14 06:49:06.654	2026-04-14 06:49:06.654
cmny9gn0602zmvxy476il80qz	cmny9gmto02z4vxy4invdhxc2	cmny9fdb9000bvxy4h02fexen	90000	2026-04-14 06:49:06.679	2026-04-14 06:49:06.679
cmny9gn0v02zovxy401qzuopt	cmny9gmto02z4vxy4invdhxc2	cmny9fdc1000cvxy4n4y9ezu8	90000	2026-04-14 06:49:06.703	2026-04-14 06:49:06.703
cmny9gn1j02zqvxy445lqra85	cmny9gmto02z4vxy4invdhxc2	cmny9fdcn000dvxy4w3gaald5	90000	2026-04-14 06:49:06.727	2026-04-14 06:49:06.727
cmny9gn2w02ztvxy4y2vmlupj	cmny9gn2902zrvxy4ksvqjjal	cmny9fd420001vxy42djthn1o	90000	2026-04-14 06:49:06.777	2026-04-14 06:49:06.777
cmny9gn3n02zvvxy47p9im403	cmny9gn2902zrvxy4ksvqjjal	cmny9fd4t0002vxy4jo0l7gop	90000	2026-04-14 06:49:06.803	2026-04-14 06:49:06.803
cmny9gn4m02zxvxy4fk578zm4	cmny9gn2902zrvxy4ksvqjjal	cmny9fd5j0003vxy4sw5e14p1	90000	2026-04-14 06:49:06.838	2026-04-14 06:49:06.838
cmny9gn5x02zzvxy4wzxr8jvz	cmny9gn2902zrvxy4ksvqjjal	cmny9fd6h0004vxy4evm3jgfv	90000	2026-04-14 06:49:06.885	2026-04-14 06:49:06.885
cmny9gn6o0301vxy43rma1vyf	cmny9gn2902zrvxy4ksvqjjal	cmny9fd7u0006vxy4mh4wwui4	90000	2026-04-14 06:49:06.912	2026-04-14 06:49:06.912
cmny9gn7a0303vxy4p0z88wey	cmny9gn2902zrvxy4ksvqjjal	cmny9fd8i0007vxy4tmc0glr0	90000	2026-04-14 06:49:06.934	2026-04-14 06:49:06.934
cmny9gn800305vxy447glepau	cmny9gn2902zrvxy4ksvqjjal	cmny9fd980008vxy4alsawn4y	90000	2026-04-14 06:49:06.961	2026-04-14 06:49:06.961
cmny9gn8o0307vxy44wstq3z0	cmny9gn2902zrvxy4ksvqjjal	cmny9fd9w0009vxy498vvvu1d	80000	2026-04-14 06:49:06.985	2026-04-14 06:49:06.985
cmny9gn9g0309vxy4mricsgt1	cmny9gn2902zrvxy4ksvqjjal	cmny9fdb9000bvxy4h02fexen	90000	2026-04-14 06:49:07.013	2026-04-14 06:49:07.013
cmny9gna3030bvxy437vgy64y	cmny9gn2902zrvxy4ksvqjjal	cmny9fdc1000cvxy4n4y9ezu8	90000	2026-04-14 06:49:07.035	2026-04-14 06:49:07.035
cmny9gnat030dvxy4jr0fcqwc	cmny9gn2902zrvxy4ksvqjjal	cmny9fdcn000dvxy4w3gaald5	90000	2026-04-14 06:49:07.061	2026-04-14 06:49:07.061
cmny9gnch030gvxy4aa9v39c6	cmny9gnbk030evxy4xric0xyd	cmny9fd420001vxy42djthn1o	90000	2026-04-14 06:49:07.122	2026-04-14 06:49:07.122
cmny9gndb030ivxy4yodjxi4v	cmny9gnbk030evxy4xric0xyd	cmny9fd4t0002vxy4jo0l7gop	90000	2026-04-14 06:49:07.152	2026-04-14 06:49:07.152
cmny9gne1030kvxy4oh006vnp	cmny9gnbk030evxy4xric0xyd	cmny9fd5j0003vxy4sw5e14p1	90000	2026-04-14 06:49:07.177	2026-04-14 06:49:07.177
cmny9gnep030mvxy4d5so24ug	cmny9gnbk030evxy4xric0xyd	cmny9fd6h0004vxy4evm3jgfv	90000	2026-04-14 06:49:07.201	2026-04-14 06:49:07.201
cmny9gnfh030ovxy41f3tpw4e	cmny9gnbk030evxy4xric0xyd	cmny9fd7u0006vxy4mh4wwui4	90000	2026-04-14 06:49:07.23	2026-04-14 06:49:07.23
cmny9gng3030qvxy4uk848lw5	cmny9gnbk030evxy4xric0xyd	cmny9fd8i0007vxy4tmc0glr0	90000	2026-04-14 06:49:07.251	2026-04-14 06:49:07.251
cmny9gngt030svxy48pcn99xd	cmny9gnbk030evxy4xric0xyd	cmny9fd980008vxy4alsawn4y	90000	2026-04-14 06:49:07.277	2026-04-14 06:49:07.277
cmny9gnhh030uvxy4bigz5to6	cmny9gnbk030evxy4xric0xyd	cmny9fd9w0009vxy498vvvu1d	80000	2026-04-14 06:49:07.301	2026-04-14 06:49:07.301
cmny9gnia030wvxy4knkribsd	cmny9gnbk030evxy4xric0xyd	cmny9fdb9000bvxy4h02fexen	90000	2026-04-14 06:49:07.33	2026-04-14 06:49:07.33
cmny9gnj4030yvxy4ks5kn6y0	cmny9gnbk030evxy4xric0xyd	cmny9fdc1000cvxy4n4y9ezu8	90000	2026-04-14 06:49:07.36	2026-04-14 06:49:07.36
cmny9gnju0310vxy45qpo3nnb	cmny9gnbk030evxy4xric0xyd	cmny9fdcn000dvxy4w3gaald5	90000	2026-04-14 06:49:07.386	2026-04-14 06:49:07.386
cmny9gnl80313vxy497n76qmu	cmny9gnkh0311vxy49s1hihp3	cmny9fd420001vxy42djthn1o	90000	2026-04-14 06:49:07.436	2026-04-14 06:49:07.436
cmny9gnlv0315vxy417i0wlgi	cmny9gnkh0311vxy49s1hihp3	cmny9fd4t0002vxy4jo0l7gop	90000	2026-04-14 06:49:07.46	2026-04-14 06:49:07.46
cmny9gnmm0317vxy4x8ycuakc	cmny9gnkh0311vxy49s1hihp3	cmny9fd5j0003vxy4sw5e14p1	90000	2026-04-14 06:49:07.486	2026-04-14 06:49:07.486
cmny9gnn90319vxy454jl1yz0	cmny9gnkh0311vxy49s1hihp3	cmny9fd6h0004vxy4evm3jgfv	90000	2026-04-14 06:49:07.51	2026-04-14 06:49:07.51
cmny9gno1031bvxy492cb0hx5	cmny9gnkh0311vxy49s1hihp3	cmny9fd7u0006vxy4mh4wwui4	90000	2026-04-14 06:49:07.538	2026-04-14 06:49:07.538
cmny9gnon031dvxy44otyilpq	cmny9gnkh0311vxy49s1hihp3	cmny9fd8i0007vxy4tmc0glr0	90000	2026-04-14 06:49:07.56	2026-04-14 06:49:07.56
cmny9gnpe031fvxy4um4swgaq	cmny9gnkh0311vxy49s1hihp3	cmny9fd980008vxy4alsawn4y	90000	2026-04-14 06:49:07.586	2026-04-14 06:49:07.586
cmny9gnq2031hvxy4obsa1e5j	cmny9gnkh0311vxy49s1hihp3	cmny9fd9w0009vxy498vvvu1d	80000	2026-04-14 06:49:07.61	2026-04-14 06:49:07.61
cmny9gnqt031jvxy458hmqpko	cmny9gnkh0311vxy49s1hihp3	cmny9fdb9000bvxy4h02fexen	90000	2026-04-14 06:49:07.637	2026-04-14 06:49:07.637
cmny9gnrf031lvxy4vt53fhpk	cmny9gnkh0311vxy49s1hihp3	cmny9fdc1000cvxy4n4y9ezu8	90000	2026-04-14 06:49:07.66	2026-04-14 06:49:07.66
cmny9gnta031nvxy4h2exxru6	cmny9gnkh0311vxy49s1hihp3	cmny9fdcn000dvxy4w3gaald5	90000	2026-04-14 06:49:07.726	2026-04-14 06:49:07.726
cmny9gnuo031qvxy4c2a6fsvj	cmny9gnu0031ovxy484nhm36a	cmny9fd420001vxy42djthn1o	90000	2026-04-14 06:49:07.777	2026-04-14 06:49:07.777
cmny9gnve031svxy4qcxs07og	cmny9gnu0031ovxy484nhm36a	cmny9fd4t0002vxy4jo0l7gop	90000	2026-04-14 06:49:07.802	2026-04-14 06:49:07.802
cmny9gnw3031uvxy4n3vao8wy	cmny9gnu0031ovxy484nhm36a	cmny9fd5j0003vxy4sw5e14p1	90000	2026-04-14 06:49:07.827	2026-04-14 06:49:07.827
cmny9gnwt031wvxy43dazw3kv	cmny9gnu0031ovxy484nhm36a	cmny9fd6h0004vxy4evm3jgfv	90000	2026-04-14 06:49:07.853	2026-04-14 06:49:07.853
cmny9gnxh031yvxy4b9rsj73g	cmny9gnu0031ovxy484nhm36a	cmny9fd7u0006vxy4mh4wwui4	90000	2026-04-14 06:49:07.877	2026-04-14 06:49:07.877
cmny9gny60320vxy48be9euj4	cmny9gnu0031ovxy484nhm36a	cmny9fd8i0007vxy4tmc0glr0	90000	2026-04-14 06:49:07.902	2026-04-14 06:49:07.902
cmny9gnyu0322vxy4u5yypzh4	cmny9gnu0031ovxy484nhm36a	cmny9fd980008vxy4alsawn4y	90000	2026-04-14 06:49:07.926	2026-04-14 06:49:07.926
cmny9gnzk0324vxy456fafyc7	cmny9gnu0031ovxy484nhm36a	cmny9fd9w0009vxy498vvvu1d	80000	2026-04-14 06:49:07.952	2026-04-14 06:49:07.952
cmny9go0a0326vxy4llcnxek6	cmny9gnu0031ovxy484nhm36a	cmny9fdb9000bvxy4h02fexen	90000	2026-04-14 06:49:07.978	2026-04-14 06:49:07.978
cmny9go0y0328vxy46sv8oak7	cmny9gnu0031ovxy484nhm36a	cmny9fdc1000cvxy4n4y9ezu8	90000	2026-04-14 06:49:08.002	2026-04-14 06:49:08.002
cmny9go1m032avxy4a90akhrm	cmny9gnu0031ovxy484nhm36a	cmny9fdcn000dvxy4w3gaald5	90000	2026-04-14 06:49:08.027	2026-04-14 06:49:08.027
cmny9go30032dvxy42zhuz8iz	cmny9go2c032bvxy4dcx2lbtg	cmny9fd420001vxy42djthn1o	90000	2026-04-14 06:49:08.077	2026-04-14 06:49:08.077
cmny9go3q032fvxy4lmez7l57	cmny9go2c032bvxy4dcx2lbtg	cmny9fd4t0002vxy4jo0l7gop	90000	2026-04-14 06:49:08.103	2026-04-14 06:49:08.103
cmny9go4e032hvxy4vsmrus3l	cmny9go2c032bvxy4dcx2lbtg	cmny9fd5j0003vxy4sw5e14p1	90000	2026-04-14 06:49:08.126	2026-04-14 06:49:08.126
cmny9go54032jvxy4ja10rw04	cmny9go2c032bvxy4dcx2lbtg	cmny9fd6h0004vxy4evm3jgfv	90000	2026-04-14 06:49:08.152	2026-04-14 06:49:08.152
cmny9go5t032lvxy4pa1huz1e	cmny9go2c032bvxy4dcx2lbtg	cmny9fd7u0006vxy4mh4wwui4	90000	2026-04-14 06:49:08.178	2026-04-14 06:49:08.178
cmny9go6i032nvxy4gdcc8x4h	cmny9go2c032bvxy4dcx2lbtg	cmny9fd8i0007vxy4tmc0glr0	90000	2026-04-14 06:49:08.202	2026-04-14 06:49:08.202
cmny9go77032pvxy48wovxzsy	cmny9go2c032bvxy4dcx2lbtg	cmny9fd980008vxy4alsawn4y	90000	2026-04-14 06:49:08.227	2026-04-14 06:49:08.227
cmny9go7w032rvxy4ci07jlo3	cmny9go2c032bvxy4dcx2lbtg	cmny9fd9w0009vxy498vvvu1d	80000	2026-04-14 06:49:08.252	2026-04-14 06:49:08.252
cmny9go8m032tvxy45gjj0u2q	cmny9go2c032bvxy4dcx2lbtg	cmny9fdb9000bvxy4h02fexen	90000	2026-04-14 06:49:08.278	2026-04-14 06:49:08.278
cmny9go9a032vvxy4oi00aauo	cmny9go2c032bvxy4dcx2lbtg	cmny9fdc1000cvxy4n4y9ezu8	90000	2026-04-14 06:49:08.302	2026-04-14 06:49:08.302
cmny9goaq032xvxy4pnp7juxz	cmny9go2c032bvxy4dcx2lbtg	cmny9fdcn000dvxy4w3gaald5	90000	2026-04-14 06:49:08.354	2026-04-14 06:49:08.354
cmny9godw0331vxy4egs6t3s5	cmny9god7032zvxy43dhi6nyh	cmny9fd420001vxy42djthn1o	90000	2026-04-14 06:49:08.469	2026-04-14 06:49:08.469
cmny9goel0333vxy4quxgv1rg	cmny9god7032zvxy43dhi6nyh	cmny9fd4t0002vxy4jo0l7gop	90000	2026-04-14 06:49:08.493	2026-04-14 06:49:08.493
cmny9gofb0335vxy4tr9ur84e	cmny9god7032zvxy43dhi6nyh	cmny9fd5j0003vxy4sw5e14p1	90000	2026-04-14 06:49:08.519	2026-04-14 06:49:08.519
cmny9gofz0337vxy44044htuc	cmny9god7032zvxy43dhi6nyh	cmny9fd6h0004vxy4evm3jgfv	90000	2026-04-14 06:49:08.543	2026-04-14 06:49:08.543
cmny9gogq0339vxy4htqoj516	cmny9god7032zvxy43dhi6nyh	cmny9fd7u0006vxy4mh4wwui4	90000	2026-04-14 06:49:08.57	2026-04-14 06:49:08.57
cmny9gohd033bvxy46yovj76c	cmny9god7032zvxy43dhi6nyh	cmny9fd8i0007vxy4tmc0glr0	90000	2026-04-14 06:49:08.594	2026-04-14 06:49:08.594
cmny9goi3033dvxy4kh2bdqx9	cmny9god7032zvxy43dhi6nyh	cmny9fd980008vxy4alsawn4y	90000	2026-04-14 06:49:08.619	2026-04-14 06:49:08.619
cmny9goir033fvxy4l9caw1to	cmny9god7032zvxy43dhi6nyh	cmny9fd9w0009vxy498vvvu1d	80000	2026-04-14 06:49:08.643	2026-04-14 06:49:08.643
cmny9goji033hvxy4uprkz60l	cmny9god7032zvxy43dhi6nyh	cmny9fdb9000bvxy4h02fexen	90000	2026-04-14 06:49:08.67	2026-04-14 06:49:08.67
cmny9gok5033jvxy4qfczn316	cmny9god7032zvxy43dhi6nyh	cmny9fdc1000cvxy4n4y9ezu8	90000	2026-04-14 06:49:08.693	2026-04-14 06:49:08.693
cmny9gokv033lvxy4zbh3ouas	cmny9god7032zvxy43dhi6nyh	cmny9fdcn000dvxy4w3gaald5	90000	2026-04-14 06:49:08.719	2026-04-14 06:49:08.719
cmny9gom9033ovxy4u1iql2dl	cmny9golj033mvxy4fxz1uz14	cmny9fd420001vxy42djthn1o	90000	2026-04-14 06:49:08.769	2026-04-14 06:49:08.769
cmny9gomx033qvxy4nqhpkdd6	cmny9golj033mvxy4fxz1uz14	cmny9fd4t0002vxy4jo0l7gop	90000	2026-04-14 06:49:08.793	2026-04-14 06:49:08.793
cmny9gonn033svxy4g94pbaaa	cmny9golj033mvxy4fxz1uz14	cmny9fd5j0003vxy4sw5e14p1	90000	2026-04-14 06:49:08.819	2026-04-14 06:49:08.819
cmny9goob033uvxy4uno5iejm	cmny9golj033mvxy4fxz1uz14	cmny9fd6h0004vxy4evm3jgfv	90000	2026-04-14 06:49:08.844	2026-04-14 06:49:08.844
cmny9gop7033wvxy49jhe1vvo	cmny9golj033mvxy4fxz1uz14	cmny9fd7u0006vxy4mh4wwui4	90000	2026-04-14 06:49:08.875	2026-04-14 06:49:08.875
cmny9gopx033yvxy4ps34rxkv	cmny9golj033mvxy4fxz1uz14	cmny9fd8i0007vxy4tmc0glr0	90000	2026-04-14 06:49:08.901	2026-04-14 06:49:08.901
cmny9goqn0340vxy45gn7q1rf	cmny9golj033mvxy4fxz1uz14	cmny9fd980008vxy4alsawn4y	90000	2026-04-14 06:49:08.927	2026-04-14 06:49:08.927
cmny9gorb0342vxy4jjd2aq6y	cmny9golj033mvxy4fxz1uz14	cmny9fd9w0009vxy498vvvu1d	80000	2026-04-14 06:49:08.951	2026-04-14 06:49:08.951
cmny9gos30344vxy4gdvguwpl	cmny9golj033mvxy4fxz1uz14	cmny9fdb9000bvxy4h02fexen	90000	2026-04-14 06:49:08.979	2026-04-14 06:49:08.979
cmny9gosq0346vxy4v7ctixhw	cmny9golj033mvxy4fxz1uz14	cmny9fdc1000cvxy4n4y9ezu8	90000	2026-04-14 06:49:09.002	2026-04-14 06:49:09.002
cmny9gotf0348vxy4m7m2npv6	cmny9golj033mvxy4fxz1uz14	cmny9fdcn000dvxy4w3gaald5	90000	2026-04-14 06:49:09.027	2026-04-14 06:49:09.027
cmny9gout034bvxy4ztn89o93	cmny9gou30349vxy417ukkci3	cmny9fd420001vxy42djthn1o	90000	2026-04-14 06:49:09.078	2026-04-14 06:49:09.078
cmny9govi034dvxy4wjapdtu7	cmny9gou30349vxy417ukkci3	cmny9fd4t0002vxy4jo0l7gop	90000	2026-04-14 06:49:09.102	2026-04-14 06:49:09.102
cmny9gow7034fvxy41jbs754x	cmny9gou30349vxy417ukkci3	cmny9fd5j0003vxy4sw5e14p1	90000	2026-04-14 06:49:09.128	2026-04-14 06:49:09.128
cmny9gowv034hvxy4svyqcczt	cmny9gou30349vxy417ukkci3	cmny9fd6h0004vxy4evm3jgfv	90000	2026-04-14 06:49:09.151	2026-04-14 06:49:09.151
cmny9goxm034jvxy4hiep1kl7	cmny9gou30349vxy417ukkci3	cmny9fd7u0006vxy4mh4wwui4	90000	2026-04-14 06:49:09.178	2026-04-14 06:49:09.178
cmny9goy9034lvxy4ty1s5bhz	cmny9gou30349vxy417ukkci3	cmny9fd8i0007vxy4tmc0glr0	90000	2026-04-14 06:49:09.201	2026-04-14 06:49:09.201
cmny9goyz034nvxy4ra73agej	cmny9gou30349vxy417ukkci3	cmny9fd980008vxy4alsawn4y	90000	2026-04-14 06:49:09.228	2026-04-14 06:49:09.228
cmny9gozn034pvxy4v10qzaoc	cmny9gou30349vxy417ukkci3	cmny9fd9w0009vxy498vvvu1d	80000	2026-04-14 06:49:09.252	2026-04-14 06:49:09.252
cmny9gp0e034rvxy4bl5hxjt7	cmny9gou30349vxy417ukkci3	cmny9fdb9000bvxy4h02fexen	90000	2026-04-14 06:49:09.279	2026-04-14 06:49:09.279
cmny9gp11034tvxy42a5q2n97	cmny9gou30349vxy417ukkci3	cmny9fdc1000cvxy4n4y9ezu8	90000	2026-04-14 06:49:09.301	2026-04-14 06:49:09.301
cmny9gp1r034vvxy4yxlp5yuu	cmny9gou30349vxy417ukkci3	cmny9fdcn000dvxy4w3gaald5	90000	2026-04-14 06:49:09.327	2026-04-14 06:49:09.327
cmny9gp35034yvxy4tvwjwweg	cmny9gp2g034wvxy4nxi3ds97	cmny9fd420001vxy42djthn1o	55000	2026-04-14 06:49:09.377	2026-04-14 06:49:09.377
cmny9gp420350vxy4ujr192pa	cmny9gp2g034wvxy4nxi3ds97	cmny9fd4t0002vxy4jo0l7gop	55000	2026-04-14 06:49:09.41	2026-04-14 06:49:09.41
cmny9gp4r0352vxy4qc2bb0qh	cmny9gp2g034wvxy4nxi3ds97	cmny9fd5j0003vxy4sw5e14p1	55000	2026-04-14 06:49:09.436	2026-04-14 06:49:09.436
cmny9gp5g0354vxy4ev8m2xks	cmny9gp2g034wvxy4nxi3ds97	cmny9fd6h0004vxy4evm3jgfv	55000	2026-04-14 06:49:09.46	2026-04-14 06:49:09.46
cmny9gp670356vxy4791pi2zc	cmny9gp2g034wvxy4nxi3ds97	cmny9fd7u0006vxy4mh4wwui4	55000	2026-04-14 06:49:09.487	2026-04-14 06:49:09.487
cmny9gp6u0358vxy4vq74q7ts	cmny9gp2g034wvxy4nxi3ds97	cmny9fd8i0007vxy4tmc0glr0	55000	2026-04-14 06:49:09.51	2026-04-14 06:49:09.51
cmny9gp7k035avxy4yxak16a6	cmny9gp2g034wvxy4nxi3ds97	cmny9fd980008vxy4alsawn4y	55000	2026-04-14 06:49:09.536	2026-04-14 06:49:09.536
cmny9gp87035cvxy4it4n88m3	cmny9gp2g034wvxy4nxi3ds97	cmny9fd9w0009vxy498vvvu1d	55000	2026-04-14 06:49:09.56	2026-04-14 06:49:09.56
cmny9gp90035evxy4m2st6wcr	cmny9gp2g034wvxy4nxi3ds97	cmny9fdb9000bvxy4h02fexen	55000	2026-04-14 06:49:09.588	2026-04-14 06:49:09.588
cmny9gp9v035gvxy4tu8qm19j	cmny9gp2g034wvxy4nxi3ds97	cmny9fdc1000cvxy4n4y9ezu8	55000	2026-04-14 06:49:09.619	2026-04-14 06:49:09.619
cmny9gpaj035ivxy45ja3we8m	cmny9gp2g034wvxy4nxi3ds97	cmny9fdcn000dvxy4w3gaald5	55000	2026-04-14 06:49:09.644	2026-04-14 06:49:09.644
cmny9gpbx035lvxy4rqg7j3xo	cmny9gpb8035jvxy4a8cw3p52	cmny9fd420001vxy42djthn1o	50000	2026-04-14 06:49:09.693	2026-04-14 06:49:09.693
cmny9gpcm035nvxy4fgp1rp74	cmny9gpb8035jvxy4a8cw3p52	cmny9fd4t0002vxy4jo0l7gop	50000	2026-04-14 06:49:09.718	2026-04-14 06:49:09.718
cmny9gpdb035pvxy41ytu0a9x	cmny9gpb8035jvxy4a8cw3p52	cmny9fd5j0003vxy4sw5e14p1	50000	2026-04-14 06:49:09.744	2026-04-14 06:49:09.744
cmny9gpe0035rvxy4jv6rzusn	cmny9gpb8035jvxy4a8cw3p52	cmny9fd6h0004vxy4evm3jgfv	50000	2026-04-14 06:49:09.768	2026-04-14 06:49:09.768
cmny9gpes035tvxy4soy4y7lc	cmny9gpb8035jvxy4a8cw3p52	cmny9fd7u0006vxy4mh4wwui4	50000	2026-04-14 06:49:09.796	2026-04-14 06:49:09.796
cmny9gpfm035vvxy48dqb6qp3	cmny9gpb8035jvxy4a8cw3p52	cmny9fd8i0007vxy4tmc0glr0	50000	2026-04-14 06:49:09.827	2026-04-14 06:49:09.827
cmny9gpgl035xvxy4dmd4djej	cmny9gpb8035jvxy4a8cw3p52	cmny9fd980008vxy4alsawn4y	50000	2026-04-14 06:49:09.861	2026-04-14 06:49:09.861
cmny9gphi035zvxy4ax5my7oc	cmny9gpb8035jvxy4a8cw3p52	cmny9fd9w0009vxy498vvvu1d	50000	2026-04-14 06:49:09.894	2026-04-14 06:49:09.894
cmny9gpi70361vxy4zt43rkim	cmny9gpb8035jvxy4a8cw3p52	cmny9fdb9000bvxy4h02fexen	50000	2026-04-14 06:49:09.92	2026-04-14 06:49:09.92
cmny9gpiw0363vxy49chx7hds	cmny9gpb8035jvxy4a8cw3p52	cmny9fdc1000cvxy4n4y9ezu8	50000	2026-04-14 06:49:09.944	2026-04-14 06:49:09.944
cmny9gpjk0365vxy45201n8nd	cmny9gpb8035jvxy4a8cw3p52	cmny9fdcn000dvxy4w3gaald5	50000	2026-04-14 06:49:09.969	2026-04-14 06:49:09.969
cmny9gpky0368vxy4qy34otsb	cmny9gpk90366vxy425xjt8ti	cmny9fd420001vxy42djthn1o	45000	2026-04-14 06:49:10.019	2026-04-14 06:49:10.019
cmny9gpm4036avxy4aslo8ngx	cmny9gpk90366vxy425xjt8ti	cmny9fd4t0002vxy4jo0l7gop	45000	2026-04-14 06:49:10.061	2026-04-14 06:49:10.061
cmny9gpmv036cvxy41znkhhu5	cmny9gpk90366vxy425xjt8ti	cmny9fd5j0003vxy4sw5e14p1	45000	2026-04-14 06:49:10.087	2026-04-14 06:49:10.087
cmny9gpns036evxy47y3db7dm	cmny9gpk90366vxy425xjt8ti	cmny9fd6h0004vxy4evm3jgfv	45000	2026-04-14 06:49:10.12	2026-04-14 06:49:10.12
cmny9gpov036gvxy42741h9i9	cmny9gpk90366vxy425xjt8ti	cmny9fd7u0006vxy4mh4wwui4	45000	2026-04-14 06:49:10.16	2026-04-14 06:49:10.16
cmny9gppl036ivxy4m54cef8r	cmny9gpk90366vxy425xjt8ti	cmny9fd8i0007vxy4tmc0glr0	45000	2026-04-14 06:49:10.185	2026-04-14 06:49:10.185
cmny9gpqb036kvxy4kjzeew2h	cmny9gpk90366vxy425xjt8ti	cmny9fd980008vxy4alsawn4y	45000	2026-04-14 06:49:10.211	2026-04-14 06:49:10.211
cmny9gpqz036mvxy4gaj48okj	cmny9gpk90366vxy425xjt8ti	cmny9fd9w0009vxy498vvvu1d	45000	2026-04-14 06:49:10.235	2026-04-14 06:49:10.235
cmny9gprp036ovxy40duw03de	cmny9gpk90366vxy425xjt8ti	cmny9fdb9000bvxy4h02fexen	45000	2026-04-14 06:49:10.261	2026-04-14 06:49:10.261
cmny9gpsc036qvxy4beooxmgg	cmny9gpk90366vxy425xjt8ti	cmny9fdc1000cvxy4n4y9ezu8	45000	2026-04-14 06:49:10.285	2026-04-14 06:49:10.285
cmny9gpt2036svxy4gvvu0npc	cmny9gpk90366vxy425xjt8ti	cmny9fdcn000dvxy4w3gaald5	45000	2026-04-14 06:49:10.31	2026-04-14 06:49:10.31
cmny9gpug036vvxy4tzddpoj1	cmny9gpts036tvxy4j04h5bu8	cmny9fd420001vxy42djthn1o	100000	2026-04-14 06:49:10.361	2026-04-14 06:49:10.361
cmny9gpv4036xvxy44wusz8hs	cmny9gpts036tvxy4j04h5bu8	cmny9fd4t0002vxy4jo0l7gop	100000	2026-04-14 06:49:10.385	2026-04-14 06:49:10.385
cmny9gpvu036zvxy4oiboxu3r	cmny9gpts036tvxy4j04h5bu8	cmny9fd5j0003vxy4sw5e14p1	100000	2026-04-14 06:49:10.41	2026-04-14 06:49:10.41
cmny9gpwj0371vxy4vnxgrowd	cmny9gpts036tvxy4j04h5bu8	cmny9fd6h0004vxy4evm3jgfv	100000	2026-04-14 06:49:10.435	2026-04-14 06:49:10.435
cmny9gpx90373vxy45dalcu4t	cmny9gpts036tvxy4j04h5bu8	cmny9fd7u0006vxy4mh4wwui4	100000	2026-04-14 06:49:10.461	2026-04-14 06:49:10.461
cmny9gpxx0375vxy4pqy7vfbh	cmny9gpts036tvxy4j04h5bu8	cmny9fd8i0007vxy4tmc0glr0	100000	2026-04-14 06:49:10.485	2026-04-14 06:49:10.485
cmny9gpym0377vxy4nxts23ul	cmny9gpts036tvxy4j04h5bu8	cmny9fd980008vxy4alsawn4y	100000	2026-04-14 06:49:10.511	2026-04-14 06:49:10.511
cmny9gpzb0379vxy4t7jij0h4	cmny9gpts036tvxy4j04h5bu8	cmny9fd9w0009vxy498vvvu1d	100000	2026-04-14 06:49:10.535	2026-04-14 06:49:10.535
cmny9gq02037bvxy4ei1w2kjr	cmny9gpts036tvxy4j04h5bu8	cmny9fdb9000bvxy4h02fexen	100000	2026-04-14 06:49:10.563	2026-04-14 06:49:10.563
cmny9gq0p037dvxy4lc31wvuj	cmny9gpts036tvxy4j04h5bu8	cmny9fdc1000cvxy4n4y9ezu8	100000	2026-04-14 06:49:10.585	2026-04-14 06:49:10.585
cmny9gq1g037fvxy4jstv6hgb	cmny9gpts036tvxy4j04h5bu8	cmny9fdcn000dvxy4w3gaald5	100000	2026-04-14 06:49:10.612	2026-04-14 06:49:10.612
cmny9gq31037ivxy4p4xshfjy	cmny9gq26037gvxy4d5rte7wh	cmny9fd420001vxy42djthn1o	90000	2026-04-14 06:49:10.669	2026-04-14 06:49:10.669
cmny9gq3q037kvxy4c6w37eo5	cmny9gq26037gvxy4d5rte7wh	cmny9fd4t0002vxy4jo0l7gop	90000	2026-04-14 06:49:10.694	2026-04-14 06:49:10.694
cmny9gq4e037mvxy45vt8mwmb	cmny9gq26037gvxy4d5rte7wh	cmny9fd5j0003vxy4sw5e14p1	90000	2026-04-14 06:49:10.719	2026-04-14 06:49:10.719
cmny9gq53037ovxy4ewzzme6c	cmny9gq26037gvxy4d5rte7wh	cmny9fd6h0004vxy4evm3jgfv	90000	2026-04-14 06:49:10.743	2026-04-14 06:49:10.743
cmny9gq5u037qvxy4a2ld7t6y	cmny9gq26037gvxy4d5rte7wh	cmny9fd7u0006vxy4mh4wwui4	90000	2026-04-14 06:49:10.771	2026-04-14 06:49:10.771
cmny9gq6i037svxy46ift2d6i	cmny9gq26037gvxy4d5rte7wh	cmny9fd8i0007vxy4tmc0glr0	90000	2026-04-14 06:49:10.794	2026-04-14 06:49:10.794
cmny9gq77037uvxy4me5l6bnk	cmny9gq26037gvxy4d5rte7wh	cmny9fd980008vxy4alsawn4y	90000	2026-04-14 06:49:10.819	2026-04-14 06:49:10.819
cmny9gq7x037wvxy4ezbnscwd	cmny9gq26037gvxy4d5rte7wh	cmny9fd9w0009vxy498vvvu1d	90000	2026-04-14 06:49:10.846	2026-04-14 06:49:10.846
cmny9gq8p037yvxy43qn49y1a	cmny9gq26037gvxy4d5rte7wh	cmny9fdb9000bvxy4h02fexen	90000	2026-04-14 06:49:10.874	2026-04-14 06:49:10.874
cmny9gq9h0380vxy4oiiogres	cmny9gq26037gvxy4d5rte7wh	cmny9fdc1000cvxy4n4y9ezu8	90000	2026-04-14 06:49:10.902	2026-04-14 06:49:10.902
cmny9gqa70382vxy4u79g9tag	cmny9gq26037gvxy4d5rte7wh	cmny9fdcn000dvxy4w3gaald5	90000	2026-04-14 06:49:10.927	2026-04-14 06:49:10.927
cmny9gqbl0385vxy4rmi5tccd	cmny9gqaw0383vxy45nnjxnm8	cmny9fd420001vxy42djthn1o	90000	2026-04-14 06:49:10.977	2026-04-14 06:49:10.977
cmny9gqca0387vxy49bmzedeu	cmny9gqaw0383vxy45nnjxnm8	cmny9fd4t0002vxy4jo0l7gop	90000	2026-04-14 06:49:11.002	2026-04-14 06:49:11.002
cmny9gqcy0389vxy45xf10dsh	cmny9gqaw0383vxy45nnjxnm8	cmny9fd5j0003vxy4sw5e14p1	90000	2026-04-14 06:49:11.027	2026-04-14 06:49:11.027
cmny9gqdn038bvxy4n40w5zyc	cmny9gqaw0383vxy45nnjxnm8	cmny9fd6h0004vxy4evm3jgfv	90000	2026-04-14 06:49:11.051	2026-04-14 06:49:11.051
cmny9gqed038dvxy4lo84qwhp	cmny9gqaw0383vxy45nnjxnm8	cmny9fd7u0006vxy4mh4wwui4	90000	2026-04-14 06:49:11.078	2026-04-14 06:49:11.078
cmny9gqf2038fvxy4coy8n8uh	cmny9gqaw0383vxy45nnjxnm8	cmny9fd8i0007vxy4tmc0glr0	90000	2026-04-14 06:49:11.102	2026-04-14 06:49:11.102
cmny9gqfr038hvxy4v7hi1ok5	cmny9gqaw0383vxy45nnjxnm8	cmny9fd980008vxy4alsawn4y	90000	2026-04-14 06:49:11.127	2026-04-14 06:49:11.127
cmny9gqgo038jvxy408fwnkfq	cmny9gqaw0383vxy45nnjxnm8	cmny9fd9w0009vxy498vvvu1d	90000	2026-04-14 06:49:11.16	2026-04-14 06:49:11.16
cmny9gqhe038lvxy4g17hi66y	cmny9gqaw0383vxy45nnjxnm8	cmny9fdb9000bvxy4h02fexen	90000	2026-04-14 06:49:11.187	2026-04-14 06:49:11.187
cmny9gqi2038nvxy40uc7hzz9	cmny9gqaw0383vxy45nnjxnm8	cmny9fdc1000cvxy4n4y9ezu8	90000	2026-04-14 06:49:11.21	2026-04-14 06:49:11.21
cmny9gqir038pvxy45rnjrbed	cmny9gqaw0383vxy45nnjxnm8	cmny9fdcn000dvxy4w3gaald5	90000	2026-04-14 06:49:11.236	2026-04-14 06:49:11.236
cmny9gqk5038svxy40rig4wh4	cmny9gqjg038qvxy4lq1wn1to	cmny9fd420001vxy42djthn1o	100000	2026-04-14 06:49:11.286	2026-04-14 06:49:11.286
cmny9gqku038uvxy4589cnise	cmny9gqjg038qvxy4lq1wn1to	cmny9fd4t0002vxy4jo0l7gop	100000	2026-04-14 06:49:11.31	2026-04-14 06:49:11.31
cmny9gqlj038wvxy4y60vsgem	cmny9gqjg038qvxy4lq1wn1to	cmny9fd5j0003vxy4sw5e14p1	100000	2026-04-14 06:49:11.336	2026-04-14 06:49:11.336
cmny9gqm8038yvxy4o4zpgl3f	cmny9gqjg038qvxy4lq1wn1to	cmny9fd6h0004vxy4evm3jgfv	100000	2026-04-14 06:49:11.36	2026-04-14 06:49:11.36
cmny9gqmz0390vxy4lidqkk4m	cmny9gqjg038qvxy4lq1wn1to	cmny9fd7u0006vxy4mh4wwui4	100000	2026-04-14 06:49:11.387	2026-04-14 06:49:11.387
cmny9gqnl0392vxy4jnx3itb5	cmny9gqjg038qvxy4lq1wn1to	cmny9fd8i0007vxy4tmc0glr0	100000	2026-04-14 06:49:11.41	2026-04-14 06:49:11.41
cmny9gqob0394vxy4tkx5ux4m	cmny9gqjg038qvxy4lq1wn1to	cmny9fd980008vxy4alsawn4y	100000	2026-04-14 06:49:11.435	2026-04-14 06:49:11.435
cmny9gqp00396vxy4g4z7r4dh	cmny9gqjg038qvxy4lq1wn1to	cmny9fd9w0009vxy498vvvu1d	100000	2026-04-14 06:49:11.46	2026-04-14 06:49:11.46
cmny9gqpr0398vxy49f7hzq3y	cmny9gqjg038qvxy4lq1wn1to	cmny9fdb9000bvxy4h02fexen	100000	2026-04-14 06:49:11.488	2026-04-14 06:49:11.488
cmny9gqqe039avxy4asuejbug	cmny9gqjg038qvxy4lq1wn1to	cmny9fdc1000cvxy4n4y9ezu8	100000	2026-04-14 06:49:11.51	2026-04-14 06:49:11.51
cmny9gqr4039cvxy460l6xual	cmny9gqjg038qvxy4lq1wn1to	cmny9fdcn000dvxy4w3gaald5	100000	2026-04-14 06:49:11.536	2026-04-14 06:49:11.536
cmny9gqsi039fvxy49igiw591	cmny9gqrs039dvxy4huz655w3	cmny9fd420001vxy42djthn1o	40000	2026-04-14 06:49:11.586	2026-04-14 06:49:11.586
cmny9gqt9039hvxy4bpf4z2ye	cmny9gqrs039dvxy4huz655w3	cmny9fd4t0002vxy4jo0l7gop	40000	2026-04-14 06:49:11.613	2026-04-14 06:49:11.613
cmny9gqu5039jvxy4z3v1zk7u	cmny9gqrs039dvxy4huz655w3	cmny9fd5j0003vxy4sw5e14p1	40000	2026-04-14 06:49:11.645	2026-04-14 06:49:11.645
cmny9gqut039lvxy4wxeq40wi	cmny9gqrs039dvxy4huz655w3	cmny9fd6h0004vxy4evm3jgfv	40000	2026-04-14 06:49:11.669	2026-04-14 06:49:11.669
cmny9gqvj039nvxy4insvj0h3	cmny9gqrs039dvxy4huz655w3	cmny9fd7u0006vxy4mh4wwui4	40000	2026-04-14 06:49:11.696	2026-04-14 06:49:11.696
cmny9gqw6039pvxy46hd9gyde	cmny9gqrs039dvxy4huz655w3	cmny9fd8i0007vxy4tmc0glr0	40000	2026-04-14 06:49:11.718	2026-04-14 06:49:11.718
cmny9gqww039rvxy4jxkpu18d	cmny9gqrs039dvxy4huz655w3	cmny9fd980008vxy4alsawn4y	40000	2026-04-14 06:49:11.744	2026-04-14 06:49:11.744
cmny9gqxk039tvxy4ydk2sy5z	cmny9gqrs039dvxy4huz655w3	cmny9fd9w0009vxy498vvvu1d	40000	2026-04-14 06:49:11.768	2026-04-14 06:49:11.768
cmny9gqyb039vvxy4h8yzb18b	cmny9gqrs039dvxy4huz655w3	cmny9fdb9000bvxy4h02fexen	40000	2026-04-14 06:49:11.795	2026-04-14 06:49:11.795
cmny9gqyy039xvxy4aewwmqt7	cmny9gqrs039dvxy4huz655w3	cmny9fdc1000cvxy4n4y9ezu8	40000	2026-04-14 06:49:11.819	2026-04-14 06:49:11.819
cmny9gqzo039zvxy488t1cclu	cmny9gqrs039dvxy4huz655w3	cmny9fdcn000dvxy4w3gaald5	40000	2026-04-14 06:49:11.844	2026-04-14 06:49:11.844
cmny9gr2703a2vxy46szcn2it	cmny9gr0l03a0vxy4xe1ur18a	cmny9fd420001vxy42djthn1o	105000	2026-04-14 06:49:11.935	2026-04-14 06:49:11.935
cmny9gr2w03a4vxy4f3aaynnt	cmny9gr0l03a0vxy4xe1ur18a	cmny9fd4t0002vxy4jo0l7gop	105000	2026-04-14 06:49:11.96	2026-04-14 06:49:11.96
cmny9gr3l03a6vxy49vk8gzpc	cmny9gr0l03a0vxy4xe1ur18a	cmny9fd5j0003vxy4sw5e14p1	105000	2026-04-14 06:49:11.986	2026-04-14 06:49:11.986
cmny9gr4b03a8vxy4nu6r5v1i	cmny9gr0l03a0vxy4xe1ur18a	cmny9fd6h0004vxy4evm3jgfv	105000	2026-04-14 06:49:12.011	2026-04-14 06:49:12.011
cmny9gr5003aavxy40peenwyb	cmny9gr0l03a0vxy4xe1ur18a	cmny9fd7u0006vxy4mh4wwui4	105000	2026-04-14 06:49:12.036	2026-04-14 06:49:12.036
cmny9gr5o03acvxy4uxipbq34	cmny9gr0l03a0vxy4xe1ur18a	cmny9fd8i0007vxy4tmc0glr0	105000	2026-04-14 06:49:12.06	2026-04-14 06:49:12.06
cmny9gr6e03aevxy47vxhxn4b	cmny9gr0l03a0vxy4xe1ur18a	cmny9fd980008vxy4alsawn4y	105000	2026-04-14 06:49:12.086	2026-04-14 06:49:12.086
cmny9gr7j03agvxy4vnfuc199	cmny9gr0l03a0vxy4xe1ur18a	cmny9fd9w0009vxy498vvvu1d	105000	2026-04-14 06:49:12.126	2026-04-14 06:49:12.126
cmny9gr8m03aivxy4lk0irf8g	cmny9gr0l03a0vxy4xe1ur18a	cmny9fdb9000bvxy4h02fexen	105000	2026-04-14 06:49:12.167	2026-04-14 06:49:12.167
cmny9gr9s03akvxy4xdm88rwe	cmny9gr0l03a0vxy4xe1ur18a	cmny9fdc1000cvxy4n4y9ezu8	105000	2026-04-14 06:49:12.209	2026-04-14 06:49:12.209
cmny9grao03amvxy4tb6j8hpp	cmny9gr0l03a0vxy4xe1ur18a	cmny9fdcn000dvxy4w3gaald5	105000	2026-04-14 06:49:12.24	2026-04-14 06:49:12.24
cmny9grcd03apvxy47fcnyg19	cmny9grbq03anvxy4q1qesql4	cmny9fd420001vxy42djthn1o	28000	2026-04-14 06:49:12.302	2026-04-14 06:49:12.302
cmny9grd303arvxy4mouj8x9o	cmny9grbq03anvxy4q1qesql4	cmny9fd4t0002vxy4jo0l7gop	28000	2026-04-14 06:49:12.327	2026-04-14 06:49:12.327
cmny9grdt03atvxy462agp9ty	cmny9grbq03anvxy4q1qesql4	cmny9fd5j0003vxy4sw5e14p1	28000	2026-04-14 06:49:12.353	2026-04-14 06:49:12.353
cmny9grej03avvxy4r8prbcjq	cmny9grbq03anvxy4q1qesql4	cmny9fd6h0004vxy4evm3jgfv	28000	2026-04-14 06:49:12.379	2026-04-14 06:49:12.379
cmny9grfg03axvxy46r4mt7vg	cmny9grbq03anvxy4q1qesql4	cmny9fd7u0006vxy4mh4wwui4	28000	2026-04-14 06:49:12.413	2026-04-14 06:49:12.413
cmny9grg303azvxy415kntfdj	cmny9grbq03anvxy4q1qesql4	cmny9fd8i0007vxy4tmc0glr0	28000	2026-04-14 06:49:12.436	2026-04-14 06:49:12.436
cmny9grgs03b1vxy4x48rn4xy	cmny9grbq03anvxy4q1qesql4	cmny9fd980008vxy4alsawn4y	28000	2026-04-14 06:49:12.461	2026-04-14 06:49:12.461
cmny9grhi03b3vxy48b4ly3g4	cmny9grbq03anvxy4q1qesql4	cmny9fd9w0009vxy498vvvu1d	28000	2026-04-14 06:49:12.486	2026-04-14 06:49:12.486
cmny9gri703b5vxy4qnfkg8f1	cmny9grbq03anvxy4q1qesql4	cmny9fdb9000bvxy4h02fexen	28000	2026-04-14 06:49:12.511	2026-04-14 06:49:12.511
cmny9griw03b7vxy47e09brjj	cmny9grbq03anvxy4q1qesql4	cmny9fdc1000cvxy4n4y9ezu8	28000	2026-04-14 06:49:12.536	2026-04-14 06:49:12.536
cmny9grjk03b9vxy47sxfvkyu	cmny9grbq03anvxy4q1qesql4	cmny9fdcn000dvxy4w3gaald5	28000	2026-04-14 06:49:12.56	2026-04-14 06:49:12.56
cmny9grp503bdvxy4acugn7z3	cmny9gro703bbvxy4s5r0qmyj	cmny9fd420001vxy42djthn1o	450000	2026-04-14 06:49:12.762	2026-04-14 06:49:12.762
cmny9grpv03bfvxy49stsjyns	cmny9gro703bbvxy4s5r0qmyj	cmny9fd4t0002vxy4jo0l7gop	450000	2026-04-14 06:49:12.787	2026-04-14 06:49:12.787
cmny9grqj03bhvxy4o776cogm	cmny9gro703bbvxy4s5r0qmyj	cmny9fd5j0003vxy4sw5e14p1	450000	2026-04-14 06:49:12.811	2026-04-14 06:49:12.811
cmny9grr803bjvxy406h1or4t	cmny9gro703bbvxy4s5r0qmyj	cmny9fd6h0004vxy4evm3jgfv	450000	2026-04-14 06:49:12.836	2026-04-14 06:49:12.836
cmny9grs203blvxy4jen6uoca	cmny9gro703bbvxy4s5r0qmyj	cmny9fd7u0006vxy4mh4wwui4	450000	2026-04-14 06:49:12.866	2026-04-14 06:49:12.866
cmny9grst03bnvxy42mhwsaag	cmny9gro703bbvxy4s5r0qmyj	cmny9fd8i0007vxy4tmc0glr0	450000	2026-04-14 06:49:12.893	2026-04-14 06:49:12.893
cmny9grtj03bpvxy44tkjovgd	cmny9gro703bbvxy4s5r0qmyj	cmny9fd980008vxy4alsawn4y	450000	2026-04-14 06:49:12.919	2026-04-14 06:49:12.919
cmny9gru803brvxy4pktkizew	cmny9gro703bbvxy4s5r0qmyj	cmny9fd9w0009vxy498vvvu1d	450000	2026-04-14 06:49:12.944	2026-04-14 06:49:12.944
cmny9gruz03btvxy4ww3mdyvl	cmny9gro703bbvxy4s5r0qmyj	cmny9fdb9000bvxy4h02fexen	450000	2026-04-14 06:49:12.971	2026-04-14 06:49:12.971
cmny9grvm03bvvxy4qiotldc9	cmny9gro703bbvxy4s5r0qmyj	cmny9fdc1000cvxy4n4y9ezu8	450000	2026-04-14 06:49:12.994	2026-04-14 06:49:12.994
cmny9grwb03bxvxy4vg6nnvlw	cmny9gro703bbvxy4s5r0qmyj	cmny9fdcn000dvxy4w3gaald5	450000	2026-04-14 06:49:13.019	2026-04-14 06:49:13.019
cmny9grxp03c0vxy4twjkh4un	cmny9grwz03byvxy4175rk1tz	cmny9fd420001vxy42djthn1o	100000	2026-04-14 06:49:13.069	2026-04-14 06:49:13.069
cmny9grye03c2vxy4kkfr437k	cmny9grwz03byvxy4175rk1tz	cmny9fd4t0002vxy4jo0l7gop	100000	2026-04-14 06:49:13.094	2026-04-14 06:49:13.094
cmny9grz303c4vxy4bculkago	cmny9grwz03byvxy4175rk1tz	cmny9fd5j0003vxy4sw5e14p1	100000	2026-04-14 06:49:13.119	2026-04-14 06:49:13.119
cmny9grzu03c6vxy4jdhmm64k	cmny9grwz03byvxy4175rk1tz	cmny9fd6h0004vxy4evm3jgfv	100000	2026-04-14 06:49:13.146	2026-04-14 06:49:13.146
cmny9gs0j03c8vxy4jnxl3o9m	cmny9grwz03byvxy4175rk1tz	cmny9fd7u0006vxy4mh4wwui4	100000	2026-04-14 06:49:13.171	2026-04-14 06:49:13.171
cmny9gs1603cavxy4xjtrxp17	cmny9grwz03byvxy4175rk1tz	cmny9fd8i0007vxy4tmc0glr0	100000	2026-04-14 06:49:13.194	2026-04-14 06:49:13.194
cmny9gs1v03ccvxy40hdmjwg2	cmny9grwz03byvxy4175rk1tz	cmny9fd980008vxy4alsawn4y	100000	2026-04-14 06:49:13.219	2026-04-14 06:49:13.219
cmny9gs2k03cevxy48260yggf	cmny9grwz03byvxy4175rk1tz	cmny9fd9w0009vxy498vvvu1d	100000	2026-04-14 06:49:13.245	2026-04-14 06:49:13.245
cmny9gs3b03cgvxy4ebh5ah76	cmny9grwz03byvxy4175rk1tz	cmny9fdb9000bvxy4h02fexen	100000	2026-04-14 06:49:13.271	2026-04-14 06:49:13.271
cmny9gs3x03civxy4v6y8bxlf	cmny9grwz03byvxy4175rk1tz	cmny9fdc1000cvxy4n4y9ezu8	100000	2026-04-14 06:49:13.294	2026-04-14 06:49:13.294
cmny9gs4m03ckvxy4yor0l2t0	cmny9grwz03byvxy4175rk1tz	cmny9fdcn000dvxy4w3gaald5	100000	2026-04-14 06:49:13.318	2026-04-14 06:49:13.318
cmny9gs6203cnvxy47yn75u0b	cmny9gs5b03clvxy4jrmcgp21	cmny9fd420001vxy42djthn1o	55000	2026-04-14 06:49:13.371	2026-04-14 06:49:13.371
cmny9gs6q03cpvxy4b6plctk8	cmny9gs5b03clvxy4jrmcgp21	cmny9fd4t0002vxy4jo0l7gop	55000	2026-04-14 06:49:13.394	2026-04-14 06:49:13.394
cmny9gs7e03crvxy490ag6j3m	cmny9gs5b03clvxy4jrmcgp21	cmny9fd5j0003vxy4sw5e14p1	55000	2026-04-14 06:49:13.419	2026-04-14 06:49:13.419
cmny9gs8403ctvxy47gmor4e8	cmny9gs5b03clvxy4jrmcgp21	cmny9fd6h0004vxy4evm3jgfv	55000	2026-04-14 06:49:13.444	2026-04-14 06:49:13.444
cmny9gs8v03cvvxy4hiyq8d9j	cmny9gs5b03clvxy4jrmcgp21	cmny9fd7u0006vxy4mh4wwui4	55000	2026-04-14 06:49:13.471	2026-04-14 06:49:13.471
cmny9gs9h03cxvxy4dcasyr9b	cmny9gs5b03clvxy4jrmcgp21	cmny9fd8i0007vxy4tmc0glr0	55000	2026-04-14 06:49:13.493	2026-04-14 06:49:13.493
cmny9gsa703czvxy4g8xsrkf7	cmny9gs5b03clvxy4jrmcgp21	cmny9fd980008vxy4alsawn4y	55000	2026-04-14 06:49:13.519	2026-04-14 06:49:13.519
cmny9gsav03d1vxy4y6nncg4c	cmny9gs5b03clvxy4jrmcgp21	cmny9fd9w0009vxy498vvvu1d	55000	2026-04-14 06:49:13.544	2026-04-14 06:49:13.544
cmny9gsbm03d3vxy4am9o5v2b	cmny9gs5b03clvxy4jrmcgp21	cmny9fdb9000bvxy4h02fexen	55000	2026-04-14 06:49:13.57	2026-04-14 06:49:13.57
cmny9gsc903d5vxy4t59r43x0	cmny9gs5b03clvxy4jrmcgp21	cmny9fdc1000cvxy4n4y9ezu8	55000	2026-04-14 06:49:13.594	2026-04-14 06:49:13.594
cmny9gscy03d7vxy4agduudiq	cmny9gs5b03clvxy4jrmcgp21	cmny9fdcn000dvxy4w3gaald5	55000	2026-04-14 06:49:13.619	2026-04-14 06:49:13.619
cmny9gsfj03dbvxy4uetcbphq	cmny9gsev03d9vxy467xa4wus	cmny9fd420001vxy42djthn1o	68000	2026-04-14 06:49:13.711	2026-04-14 06:49:13.711
cmny9gsg703ddvxy4c0lklyhe	cmny9gsev03d9vxy467xa4wus	cmny9fd4t0002vxy4jo0l7gop	68000	2026-04-14 06:49:13.736	2026-04-14 06:49:13.736
cmny9gsgw03dfvxy4onztd78e	cmny9gsev03d9vxy467xa4wus	cmny9fd5j0003vxy4sw5e14p1	68000	2026-04-14 06:49:13.76	2026-04-14 06:49:13.76
cmny9gshl03dhvxy44vgfr4lo	cmny9gsev03d9vxy467xa4wus	cmny9fd6h0004vxy4evm3jgfv	68000	2026-04-14 06:49:13.785	2026-04-14 06:49:13.785
cmny9gsib03djvxy4puy691va	cmny9gsev03d9vxy467xa4wus	cmny9fd7u0006vxy4mh4wwui4	68000	2026-04-14 06:49:13.812	2026-04-14 06:49:13.812
cmny9gsiz03dlvxy431bi4wht	cmny9gsev03d9vxy467xa4wus	cmny9fd8i0007vxy4tmc0glr0	68000	2026-04-14 06:49:13.835	2026-04-14 06:49:13.835
cmny9gsjo03dnvxy4g791trbd	cmny9gsev03d9vxy467xa4wus	cmny9fd980008vxy4alsawn4y	68000	2026-04-14 06:49:13.86	2026-04-14 06:49:13.86
cmny9gskd03dpvxy4r48yftzl	cmny9gsev03d9vxy467xa4wus	cmny9fd9w0009vxy498vvvu1d	68000	2026-04-14 06:49:13.885	2026-04-14 06:49:13.885
cmny9gsl403drvxy4k38vnjv1	cmny9gsev03d9vxy467xa4wus	cmny9fdb9000bvxy4h02fexen	68000	2026-04-14 06:49:13.912	2026-04-14 06:49:13.912
cmny9gslr03dtvxy46fbc44ne	cmny9gsev03d9vxy467xa4wus	cmny9fdc1000cvxy4n4y9ezu8	68000	2026-04-14 06:49:13.936	2026-04-14 06:49:13.936
cmny9gsmg03dvvxy4sagtc9z6	cmny9gsev03d9vxy467xa4wus	cmny9fdcn000dvxy4w3gaald5	68000	2026-04-14 06:49:13.96	2026-04-14 06:49:13.96
cmny9gsnv03dyvxy4esct48d2	cmny9gsn503dwvxy4tavnf8kz	cmny9fd420001vxy42djthn1o	78000	2026-04-14 06:49:14.012	2026-04-14 06:49:14.012
cmny9gsok03e0vxy4ou2f4vn2	cmny9gsn503dwvxy4tavnf8kz	cmny9fd4t0002vxy4jo0l7gop	78000	2026-04-14 06:49:14.036	2026-04-14 06:49:14.036
cmny9gsp803e2vxy4qfr64d92	cmny9gsn503dwvxy4tavnf8kz	cmny9fd5j0003vxy4sw5e14p1	78000	2026-04-14 06:49:14.06	2026-04-14 06:49:14.06
cmny9gspx03e4vxy4liz4h1a8	cmny9gsn503dwvxy4tavnf8kz	cmny9fd6h0004vxy4evm3jgfv	78000	2026-04-14 06:49:14.085	2026-04-14 06:49:14.085
cmny9gsqo03e6vxy4lev1t06v	cmny9gsn503dwvxy4tavnf8kz	cmny9fd7u0006vxy4mh4wwui4	78000	2026-04-14 06:49:14.113	2026-04-14 06:49:14.113
cmny9gsrb03e8vxy4hrzlbocz	cmny9gsn503dwvxy4tavnf8kz	cmny9fd8i0007vxy4tmc0glr0	78000	2026-04-14 06:49:14.135	2026-04-14 06:49:14.135
cmny9gss003eavxy4p5mace4y	cmny9gsn503dwvxy4tavnf8kz	cmny9fd980008vxy4alsawn4y	78000	2026-04-14 06:49:14.161	2026-04-14 06:49:14.161
cmny9gssp03ecvxy4b1rwh7z9	cmny9gsn503dwvxy4tavnf8kz	cmny9fd9w0009vxy498vvvu1d	78000	2026-04-14 06:49:14.185	2026-04-14 06:49:14.185
cmny9gstg03eevxy48690tzcc	cmny9gsn503dwvxy4tavnf8kz	cmny9fdb9000bvxy4h02fexen	78000	2026-04-14 06:49:14.212	2026-04-14 06:49:14.212
cmny9gsu303egvxy4j8mddncx	cmny9gsn503dwvxy4tavnf8kz	cmny9fdc1000cvxy4n4y9ezu8	78000	2026-04-14 06:49:14.236	2026-04-14 06:49:14.236
cmny9gsw603eivxy4fkp7gxwh	cmny9gsn503dwvxy4tavnf8kz	cmny9fdcn000dvxy4w3gaald5	78000	2026-04-14 06:49:14.311	2026-04-14 06:49:14.311
cmny9gsxk03elvxy4vyy01fur	cmny9gswv03ejvxy4lcxc3yl6	cmny9fd420001vxy42djthn1o	108000	2026-04-14 06:49:14.36	2026-04-14 06:49:14.36
cmny9gsy903envxy4os9sdm1j	cmny9gswv03ejvxy4lcxc3yl6	cmny9fd4t0002vxy4jo0l7gop	108000	2026-04-14 06:49:14.385	2026-04-14 06:49:14.385
cmny9gsz003epvxy4h8gmebk4	cmny9gswv03ejvxy4lcxc3yl6	cmny9fd5j0003vxy4sw5e14p1	108000	2026-04-14 06:49:14.412	2026-04-14 06:49:14.412
cmny9gszx03ervxy4hmmnjexc	cmny9gswv03ejvxy4lcxc3yl6	cmny9fd6h0004vxy4evm3jgfv	108000	2026-04-14 06:49:14.445	2026-04-14 06:49:14.445
cmny9gt0y03etvxy4xh4opoqm	cmny9gswv03ejvxy4lcxc3yl6	cmny9fd7u0006vxy4mh4wwui4	108000	2026-04-14 06:49:14.482	2026-04-14 06:49:14.482
cmny9gt1s03evvxy4xudw0w6u	cmny9gswv03ejvxy4lcxc3yl6	cmny9fd8i0007vxy4tmc0glr0	108000	2026-04-14 06:49:14.512	2026-04-14 06:49:14.512
cmny9gt2p03exvxy47h5i0d71	cmny9gswv03ejvxy4lcxc3yl6	cmny9fd980008vxy4alsawn4y	108000	2026-04-14 06:49:14.545	2026-04-14 06:49:14.545
cmny9gt3n03ezvxy4uy5h9fxb	cmny9gswv03ejvxy4lcxc3yl6	cmny9fd9w0009vxy498vvvu1d	108000	2026-04-14 06:49:14.579	2026-04-14 06:49:14.579
cmny9gt4k03f1vxy42ja92mzq	cmny9gswv03ejvxy4lcxc3yl6	cmny9fdb9000bvxy4h02fexen	108000	2026-04-14 06:49:14.612	2026-04-14 06:49:14.612
cmny9gt5703f3vxy4pgvkwier	cmny9gswv03ejvxy4lcxc3yl6	cmny9fdc1000cvxy4n4y9ezu8	108000	2026-04-14 06:49:14.635	2026-04-14 06:49:14.635
cmny9gt5y03f5vxy4nkdfrb0j	cmny9gswv03ejvxy4lcxc3yl6	cmny9fdcn000dvxy4w3gaald5	108000	2026-04-14 06:49:14.662	2026-04-14 06:49:14.662
cmny9gt7s03f8vxy4m6m1qr71	cmny9gt6w03f6vxy48y0d9dhc	cmny9fd420001vxy42djthn1o	98000	2026-04-14 06:49:14.729	2026-04-14 06:49:14.729
cmny9gt8h03favxy40v1ur1yy	cmny9gt6w03f6vxy48y0d9dhc	cmny9fd4t0002vxy4jo0l7gop	98000	2026-04-14 06:49:14.753	2026-04-14 06:49:14.753
cmny9gt9503fcvxy40s032g4x	cmny9gt6w03f6vxy48y0d9dhc	cmny9fd5j0003vxy4sw5e14p1	98000	2026-04-14 06:49:14.777	2026-04-14 06:49:14.777
cmny9gt9u03fevxy4j7vu9j06	cmny9gt6w03f6vxy48y0d9dhc	cmny9fd6h0004vxy4evm3jgfv	98000	2026-04-14 06:49:14.802	2026-04-14 06:49:14.802
cmny9gtak03fgvxy4fv265338	cmny9gt6w03f6vxy48y0d9dhc	cmny9fd7u0006vxy4mh4wwui4	98000	2026-04-14 06:49:14.828	2026-04-14 06:49:14.828
cmny9gtb803fivxy4dp0exz5m	cmny9gt6w03f6vxy48y0d9dhc	cmny9fd8i0007vxy4tmc0glr0	98000	2026-04-14 06:49:14.852	2026-04-14 06:49:14.852
cmny9gtbx03fkvxy4s8kwlrz1	cmny9gt6w03f6vxy48y0d9dhc	cmny9fd980008vxy4alsawn4y	98000	2026-04-14 06:49:14.877	2026-04-14 06:49:14.877
cmny9gtcm03fmvxy4sp3ko77b	cmny9gt6w03f6vxy48y0d9dhc	cmny9fd9w0009vxy498vvvu1d	98000	2026-04-14 06:49:14.902	2026-04-14 06:49:14.902
cmny9gtde03fovxy427luerr8	cmny9gt6w03f6vxy48y0d9dhc	cmny9fdb9000bvxy4h02fexen	98000	2026-04-14 06:49:14.93	2026-04-14 06:49:14.93
cmny9gte003fqvxy40dr76k1f	cmny9gt6w03f6vxy48y0d9dhc	cmny9fdc1000cvxy4n4y9ezu8	98000	2026-04-14 06:49:14.952	2026-04-14 06:49:14.952
cmny9gteq03fsvxy44u186wu9	cmny9gt6w03f6vxy48y0d9dhc	cmny9fdcn000dvxy4w3gaald5	98000	2026-04-14 06:49:14.978	2026-04-14 06:49:14.978
cmny9gthi03fwvxy44lj3wlg1	cmny9gtgt03fuvxy4v5edc9ah	cmny9fd420001vxy42djthn1o	162000	2026-04-14 06:49:15.078	2026-04-14 06:49:15.078
cmny9gti703fyvxy4ri3ifd17	cmny9gtgt03fuvxy4v5edc9ah	cmny9fd4t0002vxy4jo0l7gop	162000	2026-04-14 06:49:15.103	2026-04-14 06:49:15.103
cmny9gtiv03g0vxy4bb5if9mw	cmny9gtgt03fuvxy4v5edc9ah	cmny9fd5j0003vxy4sw5e14p1	162000	2026-04-14 06:49:15.127	2026-04-14 06:49:15.127
cmny9gtjm03g2vxy490clhld3	cmny9gtgt03fuvxy4v5edc9ah	cmny9fd6h0004vxy4evm3jgfv	162000	2026-04-14 06:49:15.154	2026-04-14 06:49:15.154
cmny9gtkf03g4vxy4pfvca68c	cmny9gtgt03fuvxy4v5edc9ah	cmny9fd7u0006vxy4mh4wwui4	162000	2026-04-14 06:49:15.183	2026-04-14 06:49:15.183
cmny9gtl603g6vxy40y58psk9	cmny9gtgt03fuvxy4v5edc9ah	cmny9fd8i0007vxy4tmc0glr0	162000	2026-04-14 06:49:15.211	2026-04-14 06:49:15.211
cmny9gtlw03g8vxy43e4u595m	cmny9gtgt03fuvxy4v5edc9ah	cmny9fd980008vxy4alsawn4y	162000	2026-04-14 06:49:15.236	2026-04-14 06:49:15.236
cmny9gtml03gavxy4mejq1hn0	cmny9gtgt03fuvxy4v5edc9ah	cmny9fd9w0009vxy498vvvu1d	162000	2026-04-14 06:49:15.261	2026-04-14 06:49:15.261
cmny9gtnd03gcvxy4rl8g435s	cmny9gtgt03fuvxy4v5edc9ah	cmny9fdb9000bvxy4h02fexen	162000	2026-04-14 06:49:15.289	2026-04-14 06:49:15.289
cmny9gto903gevxy40fogauhy	cmny9gtgt03fuvxy4v5edc9ah	cmny9fdc1000cvxy4n4y9ezu8	162000	2026-04-14 06:49:15.321	2026-04-14 06:49:15.321
cmny9gtow03ggvxy496nd8cm3	cmny9gtgt03fuvxy4v5edc9ah	cmny9fdcn000dvxy4w3gaald5	162000	2026-04-14 06:49:15.344	2026-04-14 06:49:15.344
cmny9gtrh03gjvxy4mz7r2o1d	cmny9gtq203ghvxy4bs4g9r5d	cmny9fd420001vxy42djthn1o	170000	2026-04-14 06:49:15.437	2026-04-14 06:49:15.437
cmny9gtsv03glvxy473drd4rr	cmny9gtq203ghvxy4bs4g9r5d	cmny9fd4t0002vxy4jo0l7gop	170000	2026-04-14 06:49:15.487	2026-04-14 06:49:15.487
cmny9gtu803gnvxy46gg3h92m	cmny9gtq203ghvxy4bs4g9r5d	cmny9fd5j0003vxy4sw5e14p1	170000	2026-04-14 06:49:15.536	2026-04-14 06:49:15.536
cmny9gtvd03gpvxy4qzpcqet2	cmny9gtq203ghvxy4bs4g9r5d	cmny9fd6h0004vxy4evm3jgfv	170000	2026-04-14 06:49:15.577	2026-04-14 06:49:15.577
cmny9gty203grvxy4fa7c72vh	cmny9gtq203ghvxy4bs4g9r5d	cmny9fd7u0006vxy4mh4wwui4	170000	2026-04-14 06:49:15.674	2026-04-14 06:49:15.674
cmny9gtzs03gtvxy41sreqw93	cmny9gtq203ghvxy4bs4g9r5d	cmny9fd8i0007vxy4tmc0glr0	170000	2026-04-14 06:49:15.737	2026-04-14 06:49:15.737
cmny9gu0y03gvvxy46i7o86pm	cmny9gtq203ghvxy4bs4g9r5d	cmny9fd980008vxy4alsawn4y	170000	2026-04-14 06:49:15.779	2026-04-14 06:49:15.779
cmny9gu2303gxvxy4r1ea6g6i	cmny9gtq203ghvxy4bs4g9r5d	cmny9fd9w0009vxy498vvvu1d	170000	2026-04-14 06:49:15.819	2026-04-14 06:49:15.819
cmny9gu3a03gzvxy4jzhxe5kh	cmny9gtq203ghvxy4bs4g9r5d	cmny9fdb9000bvxy4h02fexen	170000	2026-04-14 06:49:15.862	2026-04-14 06:49:15.862
cmny9gu4v03h1vxy4gunbp43t	cmny9gtq203ghvxy4bs4g9r5d	cmny9fdc1000cvxy4n4y9ezu8	170000	2026-04-14 06:49:15.92	2026-04-14 06:49:15.92
cmny9gu6a03h3vxy4h542wpxm	cmny9gtq203ghvxy4bs4g9r5d	cmny9fdcn000dvxy4w3gaald5	170000	2026-04-14 06:49:15.97	2026-04-14 06:49:15.97
cmny9gu9w03h6vxy475bzkqr4	cmny9gu7w03h4vxy4aggamt9m	cmny9fd420001vxy42djthn1o	45000	2026-04-14 06:49:16.1	2026-04-14 06:49:16.1
cmny9gudv03h8vxy46s9vs8l6	cmny9gu7w03h4vxy4aggamt9m	cmny9fd4t0002vxy4jo0l7gop	45000	2026-04-14 06:49:16.244	2026-04-14 06:49:16.244
cmny9gufa03havxy4be4gfys4	cmny9gu7w03h4vxy4aggamt9m	cmny9fd5j0003vxy4sw5e14p1	45000	2026-04-14 06:49:16.294	2026-04-14 06:49:16.294
cmny9guiz03hcvxy4r0j79vse	cmny9gu7w03h4vxy4aggamt9m	cmny9fd6h0004vxy4evm3jgfv	45000	2026-04-14 06:49:16.427	2026-04-14 06:49:16.427
cmny9guo003hevxy46m8ohfgn	cmny9gu7w03h4vxy4aggamt9m	cmny9fd7u0006vxy4mh4wwui4	45000	2026-04-14 06:49:16.609	2026-04-14 06:49:16.609
cmny9gure03hgvxy4qvs4iehf	cmny9gu7w03h4vxy4aggamt9m	cmny9fd8i0007vxy4tmc0glr0	45000	2026-04-14 06:49:16.73	2026-04-14 06:49:16.73
cmny9gusx03hivxy49atvga16	cmny9gu7w03h4vxy4aggamt9m	cmny9fd980008vxy4alsawn4y	45000	2026-04-14 06:49:16.786	2026-04-14 06:49:16.786
cmny9guvl03hkvxy4lcg5lar4	cmny9gu7w03h4vxy4aggamt9m	cmny9fd9w0009vxy498vvvu1d	45000	2026-04-14 06:49:16.881	2026-04-14 06:49:16.881
cmny9guyc03hmvxy4xy50h2ki	cmny9gu7w03h4vxy4aggamt9m	cmny9fdb9000bvxy4h02fexen	45000	2026-04-14 06:49:16.98	2026-04-14 06:49:16.98
cmny9gv2h03hovxy438lp26t8	cmny9gu7w03h4vxy4aggamt9m	cmny9fdc1000cvxy4n4y9ezu8	45000	2026-04-14 06:49:17.129	2026-04-14 06:49:17.129
cmny9gv4s03hqvxy41fvqxg50	cmny9gu7w03h4vxy4aggamt9m	cmny9fdcn000dvxy4w3gaald5	45000	2026-04-14 06:49:17.212	2026-04-14 06:49:17.212
cmny9gvbh03htvxy4tzecypig	cmny9gv7r03hrvxy4yewz17vq	cmny9fd420001vxy42djthn1o	105000	2026-04-14 06:49:17.453	2026-04-14 06:49:17.453
cmny9gvdc03hvvxy4errbvbah	cmny9gv7r03hrvxy4yewz17vq	cmny9fd4t0002vxy4jo0l7gop	105000	2026-04-14 06:49:17.521	2026-04-14 06:49:17.521
cmny9gvex03hxvxy41veserit	cmny9gv7r03hrvxy4yewz17vq	cmny9fd5j0003vxy4sw5e14p1	105000	2026-04-14 06:49:17.578	2026-04-14 06:49:17.578
cmny9gvfm03hzvxy4jk17pes9	cmny9gv7r03hrvxy4yewz17vq	cmny9fd6h0004vxy4evm3jgfv	105000	2026-04-14 06:49:17.603	2026-04-14 06:49:17.603
cmny9gvi003i1vxy4epmcgiu5	cmny9gv7r03hrvxy4yewz17vq	cmny9fd7u0006vxy4mh4wwui4	105000	2026-04-14 06:49:17.688	2026-04-14 06:49:17.688
cmny9gvmk03i3vxy4d549c3d3	cmny9gv7r03hrvxy4yewz17vq	cmny9fd8i0007vxy4tmc0glr0	105000	2026-04-14 06:49:17.853	2026-04-14 06:49:17.853
cmny9gvn903i5vxy4c96gyb7p	cmny9gv7r03hrvxy4yewz17vq	cmny9fd980008vxy4alsawn4y	96800	2026-04-14 06:49:17.878	2026-04-14 06:49:17.878
cmny9gvnz03i7vxy4rrsenm11	cmny9gv7r03hrvxy4yewz17vq	cmny9fd9w0009vxy498vvvu1d	105000	2026-04-14 06:49:17.903	2026-04-14 06:49:17.903
cmny9gvpn03i9vxy4y478zman	cmny9gv7r03hrvxy4yewz17vq	cmny9fdb9000bvxy4h02fexen	105000	2026-04-14 06:49:17.963	2026-04-14 06:49:17.963
cmny9gvqz03ibvxy4tf1cb8ld	cmny9gv7r03hrvxy4yewz17vq	cmny9fdc1000cvxy4n4y9ezu8	105000	2026-04-14 06:49:18.011	2026-04-14 06:49:18.011
cmny9gvro03idvxy4qsxhc7v8	cmny9gv7r03hrvxy4yewz17vq	cmny9fdcn000dvxy4w3gaald5	105000	2026-04-14 06:49:18.036	2026-04-14 06:49:18.036
cmny9gvt203igvxy4wewpqtfe	cmny9gvsc03ievxy480o0kutd	cmny9fd420001vxy42djthn1o	28000	2026-04-14 06:49:18.086	2026-04-14 06:49:18.086
cmny9gvtq03iivxy4yr5krru6	cmny9gvsc03ievxy480o0kutd	cmny9fd4t0002vxy4jo0l7gop	28000	2026-04-14 06:49:18.111	2026-04-14 06:49:18.111
cmny9gvug03ikvxy4yaoo2xwb	cmny9gvsc03ievxy480o0kutd	cmny9fd5j0003vxy4sw5e14p1	28000	2026-04-14 06:49:18.136	2026-04-14 06:49:18.136
cmny9gvvt03imvxy49amvsz6f	cmny9gvsc03ievxy480o0kutd	cmny9fd6h0004vxy4evm3jgfv	28000	2026-04-14 06:49:18.186	2026-04-14 06:49:18.186
cmny9gvwl03iovxy4p7l6s2ps	cmny9gvsc03ievxy480o0kutd	cmny9fd7u0006vxy4mh4wwui4	28000	2026-04-14 06:49:18.213	2026-04-14 06:49:18.213
cmny9gvym03iqvxy4vvqotn5n	cmny9gvsc03ievxy480o0kutd	cmny9fd8i0007vxy4tmc0glr0	28000	2026-04-14 06:49:18.286	2026-04-14 06:49:18.286
cmny9gw0103isvxy4vcwgmllm	cmny9gvsc03ievxy480o0kutd	cmny9fd980008vxy4alsawn4y	28000	2026-04-14 06:49:18.337	2026-04-14 06:49:18.337
cmny9gw0p03iuvxy42ckoefry	cmny9gvsc03ievxy480o0kutd	cmny9fd9w0009vxy498vvvu1d	28000	2026-04-14 06:49:18.361	2026-04-14 06:49:18.361
cmny9gw2d03iwvxy4bxahyayd	cmny9gvsc03ievxy480o0kutd	cmny9fdb9000bvxy4h02fexen	28000	2026-04-14 06:49:18.422	2026-04-14 06:49:18.422
cmny9gw3003iyvxy4xdluv0va	cmny9gvsc03ievxy480o0kutd	cmny9fdc1000cvxy4n4y9ezu8	28000	2026-04-14 06:49:18.445	2026-04-14 06:49:18.445
cmny9gw3p03j0vxy4g8kch17s	cmny9gvsc03ievxy480o0kutd	cmny9fdcn000dvxy4w3gaald5	28000	2026-04-14 06:49:18.47	2026-04-14 06:49:18.47
cmny9gw5303j3vxy4yoou2mb9	cmny9gw4e03j1vxy44tl5siu8	cmny9fd420001vxy42djthn1o	187000	2026-04-14 06:49:18.52	2026-04-14 06:49:18.52
cmny9gw5s03j5vxy4tbjo5cfx	cmny9gw4e03j1vxy44tl5siu8	cmny9fd4t0002vxy4jo0l7gop	187000	2026-04-14 06:49:18.545	2026-04-14 06:49:18.545
cmny9gw6h03j7vxy4v2vt3u3x	cmny9gw4e03j1vxy44tl5siu8	cmny9fd5j0003vxy4sw5e14p1	187000	2026-04-14 06:49:18.569	2026-04-14 06:49:18.569
cmny9gw7603j9vxy4ovjw2efe	cmny9gw4e03j1vxy44tl5siu8	cmny9fd6h0004vxy4evm3jgfv	187000	2026-04-14 06:49:18.594	2026-04-14 06:49:18.594
cmny9gw7x03jbvxy48byaewfn	cmny9gw4e03j1vxy44tl5siu8	cmny9fd7u0006vxy4mh4wwui4	187000	2026-04-14 06:49:18.622	2026-04-14 06:49:18.622
cmny9gw9103jdvxy4jo9runs6	cmny9gw4e03j1vxy44tl5siu8	cmny9fd8i0007vxy4tmc0glr0	187000	2026-04-14 06:49:18.661	2026-04-14 06:49:18.661
cmny9gw9q03jfvxy488sm73c5	cmny9gw4e03j1vxy44tl5siu8	cmny9fd980008vxy4alsawn4y	187000	2026-04-14 06:49:18.687	2026-04-14 06:49:18.687
cmny9gwaf03jhvxy4hytda44u	cmny9gw4e03j1vxy44tl5siu8	cmny9fd9w0009vxy498vvvu1d	187000	2026-04-14 06:49:18.711	2026-04-14 06:49:18.711
cmny9gwb603jjvxy4gupw9nvc	cmny9gw4e03j1vxy44tl5siu8	cmny9fdb9000bvxy4h02fexen	187000	2026-04-14 06:49:18.739	2026-04-14 06:49:18.739
cmny9gwbt03jlvxy45x47jcu3	cmny9gw4e03j1vxy44tl5siu8	cmny9fdc1000cvxy4n4y9ezu8	187000	2026-04-14 06:49:18.761	2026-04-14 06:49:18.761
cmny9gwcj03jnvxy4db4iitxq	cmny9gw4e03j1vxy44tl5siu8	cmny9fdcn000dvxy4w3gaald5	187000	2026-04-14 06:49:18.787	2026-04-14 06:49:18.787
cmny9gwe403jqvxy4o6zfs8zh	cmny9gwdc03jovxy4kekpdhxc	cmny9fd420001vxy42djthn1o	110000	2026-04-14 06:49:18.844	2026-04-14 06:49:18.844
cmny9gwet03jsvxy4swpwuafo	cmny9gwdc03jovxy4kekpdhxc	cmny9fd4t0002vxy4jo0l7gop	110000	2026-04-14 06:49:18.87	2026-04-14 06:49:18.87
cmny9gwfi03juvxy4sxdm4fzy	cmny9gwdc03jovxy4kekpdhxc	cmny9fd5j0003vxy4sw5e14p1	110000	2026-04-14 06:49:18.894	2026-04-14 06:49:18.894
cmny9gwg703jwvxy4ijnlkj58	cmny9gwdc03jovxy4kekpdhxc	cmny9fd6h0004vxy4evm3jgfv	110000	2026-04-14 06:49:18.919	2026-04-14 06:49:18.919
cmny9gwgy03jyvxy481j6l3ih	cmny9gwdc03jovxy4kekpdhxc	cmny9fd7u0006vxy4mh4wwui4	110000	2026-04-14 06:49:18.946	2026-04-14 06:49:18.946
cmny9gwhl03k0vxy4c2aq0vlc	cmny9gwdc03jovxy4kekpdhxc	cmny9fd8i0007vxy4tmc0glr0	110000	2026-04-14 06:49:18.969	2026-04-14 06:49:18.969
cmny9gwib03k2vxy46m0xtofn	cmny9gwdc03jovxy4kekpdhxc	cmny9fd980008vxy4alsawn4y	110000	2026-04-14 06:49:18.995	2026-04-14 06:49:18.995
cmny9gwjg03k4vxy4ylmunkil	cmny9gwdc03jovxy4kekpdhxc	cmny9fd9w0009vxy498vvvu1d	110000	2026-04-14 06:49:19.036	2026-04-14 06:49:19.036
cmny9gwk603k6vxy48ucc79q9	cmny9gwdc03jovxy4kekpdhxc	cmny9fdb9000bvxy4h02fexen	110000	2026-04-14 06:49:19.063	2026-04-14 06:49:19.063
cmny9gwku03k8vxy4gex63wqa	cmny9gwdc03jovxy4kekpdhxc	cmny9fdc1000cvxy4n4y9ezu8	110000	2026-04-14 06:49:19.086	2026-04-14 06:49:19.086
cmny9gwlr03kavxy4aqkazqxs	cmny9gwdc03jovxy4kekpdhxc	cmny9fdcn000dvxy4w3gaald5	110000	2026-04-14 06:49:19.12	2026-04-14 06:49:19.12
cmny9gwoj03kevxy495coetm7	cmny9gwnr03kcvxy439da62yq	cmny9fd420001vxy42djthn1o	40000	2026-04-14 06:49:19.219	2026-04-14 06:49:19.219
cmny9gwr203kgvxy4oixa2859	cmny9gwnr03kcvxy439da62yq	cmny9fd4t0002vxy4jo0l7gop	40000	2026-04-14 06:49:19.311	2026-04-14 06:49:19.311
cmny9gwsg03kivxy47oi0gg4x	cmny9gwnr03kcvxy439da62yq	cmny9fd5j0003vxy4sw5e14p1	40000	2026-04-14 06:49:19.361	2026-04-14 06:49:19.361
cmny9gwt603kkvxy415vydu40	cmny9gwnr03kcvxy439da62yq	cmny9fd6h0004vxy4evm3jgfv	40000	2026-04-14 06:49:19.386	2026-04-14 06:49:19.386
cmny9gwtx03kmvxy4984tklva	cmny9gwnr03kcvxy439da62yq	cmny9fd7u0006vxy4mh4wwui4	40000	2026-04-14 06:49:19.413	2026-04-14 06:49:19.413
cmny9gwuk03kovxy4kv2swtv9	cmny9gwnr03kcvxy439da62yq	cmny9fd8i0007vxy4tmc0glr0	40000	2026-04-14 06:49:19.436	2026-04-14 06:49:19.436
cmny9gwv903kqvxy4hirh7fi6	cmny9gwnr03kcvxy439da62yq	cmny9fd980008vxy4alsawn4y	40000	2026-04-14 06:49:19.461	2026-04-14 06:49:19.461
cmny9gwvy03ksvxy496qa5ml1	cmny9gwnr03kcvxy439da62yq	cmny9fd9w0009vxy498vvvu1d	40000	2026-04-14 06:49:19.486	2026-04-14 06:49:19.486
cmny9gwwo03kuvxy4zuygsani	cmny9gwnr03kcvxy439da62yq	cmny9fdb9000bvxy4h02fexen	40000	2026-04-14 06:49:19.512	2026-04-14 06:49:19.512
cmny9gwxs03kwvxy4upofawhn	cmny9gwnr03kcvxy439da62yq	cmny9fdc1000cvxy4n4y9ezu8	40000	2026-04-14 06:49:19.553	2026-04-14 06:49:19.553
cmny9gwzn03kyvxy40xkcopvp	cmny9gwnr03kcvxy439da62yq	cmny9fdcn000dvxy4w3gaald5	40000	2026-04-14 06:49:19.619	2026-04-14 06:49:19.619
cmny9gx1z03l1vxy48jouuvsv	cmny9gx0c03kzvxy4b4c18ikm	cmny9fd420001vxy42djthn1o	570000	2026-04-14 06:49:19.703	2026-04-14 06:49:19.703
cmny9gx2o03l3vxy40leqhbcs	cmny9gx0c03kzvxy4b4c18ikm	cmny9fd4t0002vxy4jo0l7gop	570000	2026-04-14 06:49:19.728	2026-04-14 06:49:19.728
cmny9gx3d03l5vxy4ew2bjdrm	cmny9gx0c03kzvxy4b4c18ikm	cmny9fd5j0003vxy4sw5e14p1	570000	2026-04-14 06:49:19.753	2026-04-14 06:49:19.753
cmny9gx4i03l7vxy4qc9qjqio	cmny9gx0c03kzvxy4b4c18ikm	cmny9fd6h0004vxy4evm3jgfv	570000	2026-04-14 06:49:19.794	2026-04-14 06:49:19.794
cmny9gx5903l9vxy42a0fnp2d	cmny9gx0c03kzvxy4b4c18ikm	cmny9fd7u0006vxy4mh4wwui4	570000	2026-04-14 06:49:19.821	2026-04-14 06:49:19.821
cmny9gx5w03lbvxy4mkpyys34	cmny9gx0c03kzvxy4b4c18ikm	cmny9fd8i0007vxy4tmc0glr0	570000	2026-04-14 06:49:19.845	2026-04-14 06:49:19.845
cmny9gx6t03ldvxy4z3smsqjn	cmny9gx0c03kzvxy4b4c18ikm	cmny9fd980008vxy4alsawn4y	570000	2026-04-14 06:49:19.878	2026-04-14 06:49:19.878
cmny9gx7i03lfvxy40vb7gq41	cmny9gx0c03kzvxy4b4c18ikm	cmny9fd9w0009vxy498vvvu1d	570000	2026-04-14 06:49:19.903	2026-04-14 06:49:19.903
cmny9gx8903lhvxy4xm4klqbr	cmny9gx0c03kzvxy4b4c18ikm	cmny9fdb9000bvxy4h02fexen	570000	2026-04-14 06:49:19.929	2026-04-14 06:49:19.929
cmny9gx9l03ljvxy4nh5fj3zq	cmny9gx0c03kzvxy4b4c18ikm	cmny9fdc1000cvxy4n4y9ezu8	570000	2026-04-14 06:49:19.977	2026-04-14 06:49:19.977
cmny9gxar03llvxy4is2fgm6z	cmny9gx0c03kzvxy4b4c18ikm	cmny9fdcn000dvxy4w3gaald5	570000	2026-04-14 06:49:20.019	2026-04-14 06:49:20.019
cmny9gxe903lovxy431faixgj	cmny9gxcl03lmvxy4lcfsuq5u	cmny9fd420001vxy42djthn1o	50000	2026-04-14 06:49:20.145	2026-04-14 06:49:20.145
cmny9gxfv03lqvxy44xffb54n	cmny9gxcl03lmvxy4lcfsuq5u	cmny9fd4t0002vxy4jo0l7gop	50000	2026-04-14 06:49:20.203	2026-04-14 06:49:20.203
cmny9gxh903lsvxy4lsjxbjuw	cmny9gxcl03lmvxy4lcfsuq5u	cmny9fd5j0003vxy4sw5e14p1	50000	2026-04-14 06:49:20.254	2026-04-14 06:49:20.254
cmny9gxiv03luvxy4ox1f1p0d	cmny9gxcl03lmvxy4lcfsuq5u	cmny9fd6h0004vxy4evm3jgfv	50000	2026-04-14 06:49:20.311	2026-04-14 06:49:20.311
cmny9gxjn03lwvxy44uq8ouel	cmny9gxcl03lmvxy4lcfsuq5u	cmny9fd7u0006vxy4mh4wwui4	50000	2026-04-14 06:49:20.339	2026-04-14 06:49:20.339
cmny9gxl703lyvxy4ps249c4p	cmny9gxcl03lmvxy4lcfsuq5u	cmny9fd8i0007vxy4tmc0glr0	50000	2026-04-14 06:49:20.395	2026-04-14 06:49:20.395
cmny9gxlv03m0vxy4ut4x08at	cmny9gxcl03lmvxy4lcfsuq5u	cmny9fd980008vxy4alsawn4y	50000	2026-04-14 06:49:20.419	2026-04-14 06:49:20.419
cmny9gxmk03m2vxy420hlp09v	cmny9gxcl03lmvxy4lcfsuq5u	cmny9fd9w0009vxy498vvvu1d	50000	2026-04-14 06:49:20.445	2026-04-14 06:49:20.445
cmny9gxog03m4vxy4tgdu63y1	cmny9gxcl03lmvxy4lcfsuq5u	cmny9fdb9000bvxy4h02fexen	50000	2026-04-14 06:49:20.513	2026-04-14 06:49:20.513
cmny9gxq103m6vxy4rh8sn6bn	cmny9gxcl03lmvxy4lcfsuq5u	cmny9fdc1000cvxy4n4y9ezu8	50000	2026-04-14 06:49:20.569	2026-04-14 06:49:20.569
cmny9gxrn03m8vxy49db6c6ds	cmny9gxcl03lmvxy4lcfsuq5u	cmny9fdcn000dvxy4w3gaald5	50000	2026-04-14 06:49:20.628	2026-04-14 06:49:20.628
cmny9gxty03mbvxy44rq2u01d	cmny9gxt103m9vxy4ekmhaj4q	cmny9fd420001vxy42djthn1o	58000	2026-04-14 06:49:20.71	2026-04-14 06:49:20.71
cmny9gxuo03mdvxy47l9e4tzd	cmny9gxt103m9vxy4ekmhaj4q	cmny9fd4t0002vxy4jo0l7gop	58000	2026-04-14 06:49:20.736	2026-04-14 06:49:20.736
cmny9gxvc03mfvxy4hqygvath	cmny9gxt103m9vxy4ekmhaj4q	cmny9fd5j0003vxy4sw5e14p1	58000	2026-04-14 06:49:20.761	2026-04-14 06:49:20.761
cmny9gxw203mhvxy4vfip7f1b	cmny9gxt103m9vxy4ekmhaj4q	cmny9fd6h0004vxy4evm3jgfv	58000	2026-04-14 06:49:20.786	2026-04-14 06:49:20.786
cmny9gxws03mjvxy4eb2xtpug	cmny9gxt103m9vxy4ekmhaj4q	cmny9fd7u0006vxy4mh4wwui4	58000	2026-04-14 06:49:20.812	2026-04-14 06:49:20.812
cmny9gy0003mlvxy420ko1agd	cmny9gxt103m9vxy4ekmhaj4q	cmny9fd8i0007vxy4tmc0glr0	58000	2026-04-14 06:49:20.928	2026-04-14 06:49:20.928
cmny9gy0x03mnvxy4k67wi8o1	cmny9gxt103m9vxy4ekmhaj4q	cmny9fd980008vxy4alsawn4y	58000	2026-04-14 06:49:20.961	2026-04-14 06:49:20.961
cmny9gy2q03mpvxy4pqmp19ak	cmny9gxt103m9vxy4ekmhaj4q	cmny9fd9w0009vxy498vvvu1d	58000	2026-04-14 06:49:21.025	2026-04-14 06:49:21.025
cmny9gy3m03mrvxy4ntpz1bjd	cmny9gxt103m9vxy4ekmhaj4q	cmny9fdb9000bvxy4h02fexen	58000	2026-04-14 06:49:21.058	2026-04-14 06:49:21.058
cmny9gy4f03mtvxy4ahkvmlhx	cmny9gxt103m9vxy4ekmhaj4q	cmny9fdc1000cvxy4n4y9ezu8	58000	2026-04-14 06:49:21.087	2026-04-14 06:49:21.087
cmny9gy5303mvvxy47sybj1qi	cmny9gxt103m9vxy4ekmhaj4q	cmny9fdcn000dvxy4w3gaald5	58000	2026-04-14 06:49:21.111	2026-04-14 06:49:21.111
cmny9gy6p03myvxy4c1zq8zlu	cmny9gy5s03mwvxy400jtd20o	cmny9fd420001vxy42djthn1o	400000	2026-04-14 06:49:21.169	2026-04-14 06:49:21.169
cmny9gyb403n0vxy41bgw4an5	cmny9gy5s03mwvxy400jtd20o	cmny9fd4t0002vxy4jo0l7gop	400000	2026-04-14 06:49:21.329	2026-04-14 06:49:21.329
cmny9gyd203n2vxy4ku4q2c3k	cmny9gy5s03mwvxy400jtd20o	cmny9fd5j0003vxy4sw5e14p1	400000	2026-04-14 06:49:21.399	2026-04-14 06:49:21.399
cmny9gydw03n4vxy451g9a49e	cmny9gy5s03mwvxy400jtd20o	cmny9fd6h0004vxy4evm3jgfv	400000	2026-04-14 06:49:21.428	2026-04-14 06:49:21.428
cmny9gyel03n6vxy49yfewq3g	cmny9gy5s03mwvxy400jtd20o	cmny9fd7u0006vxy4mh4wwui4	400000	2026-04-14 06:49:21.454	2026-04-14 06:49:21.454
cmny9gyfa03n8vxy4qm9et7eb	cmny9gy5s03mwvxy400jtd20o	cmny9fd8i0007vxy4tmc0glr0	400000	2026-04-14 06:49:21.478	2026-04-14 06:49:21.478
cmny9gyfz03navxy40p3i6opa	cmny9gy5s03mwvxy400jtd20o	cmny9fd980008vxy4alsawn4y	400000	2026-04-14 06:49:21.503	2026-04-14 06:49:21.503
cmny9gygn03ncvxy4gu6f10m3	cmny9gy5s03mwvxy400jtd20o	cmny9fd9w0009vxy498vvvu1d	400000	2026-04-14 06:49:21.528	2026-04-14 06:49:21.528
cmny9gyhf03nevxy4o9bzg0ot	cmny9gy5s03mwvxy400jtd20o	cmny9fdb9000bvxy4h02fexen	400000	2026-04-14 06:49:21.555	2026-04-14 06:49:21.555
cmny9gyi203ngvxy4nd734eus	cmny9gy5s03mwvxy400jtd20o	cmny9fdc1000cvxy4n4y9ezu8	400000	2026-04-14 06:49:21.578	2026-04-14 06:49:21.578
cmny9gyir03nivxy49pez4u97	cmny9gy5s03mwvxy400jtd20o	cmny9fdcn000dvxy4w3gaald5	400000	2026-04-14 06:49:21.603	2026-04-14 06:49:21.603
cmny9gyk403nlvxy4a529phu2	cmny9gyjg03njvxy45645uprt	cmny9fd420001vxy42djthn1o	83000	2026-04-14 06:49:21.652	2026-04-14 06:49:21.652
cmny9gykt03nnvxy431t5ly2p	cmny9gyjg03njvxy45645uprt	cmny9fd4t0002vxy4jo0l7gop	83000	2026-04-14 06:49:21.678	2026-04-14 06:49:21.678
cmny9gyli03npvxy4ln44r9ft	cmny9gyjg03njvxy45645uprt	cmny9fd5j0003vxy4sw5e14p1	83000	2026-04-14 06:49:21.703	2026-04-14 06:49:21.703
cmny9gym803nrvxy4fh2hl34g	cmny9gyjg03njvxy45645uprt	cmny9fd6h0004vxy4evm3jgfv	83000	2026-04-14 06:49:21.728	2026-04-14 06:49:21.728
cmny9gymz03ntvxy4svly140f	cmny9gyjg03njvxy45645uprt	cmny9fd7u0006vxy4mh4wwui4	83000	2026-04-14 06:49:21.755	2026-04-14 06:49:21.755
cmny9gyp803nvvxy4qfknlgnr	cmny9gyjg03njvxy45645uprt	cmny9fd8i0007vxy4tmc0glr0	83000	2026-04-14 06:49:21.836	2026-04-14 06:49:21.836
cmny9gyqd03nxvxy4tzvk6ja0	cmny9gyjg03njvxy45645uprt	cmny9fd980008vxy4alsawn4y	83000	2026-04-14 06:49:21.877	2026-04-14 06:49:21.877
cmny9gyr303nzvxy488bprut9	cmny9gyjg03njvxy45645uprt	cmny9fd9w0009vxy498vvvu1d	83000	2026-04-14 06:49:21.903	2026-04-14 06:49:21.903
cmny9gyrt03o1vxy4sgb8shn2	cmny9gyjg03njvxy45645uprt	cmny9fdb9000bvxy4h02fexen	83000	2026-04-14 06:49:21.93	2026-04-14 06:49:21.93
cmny9gyv003o3vxy4hqgwb5dq	cmny9gyjg03njvxy45645uprt	cmny9fdc1000cvxy4n4y9ezu8	83000	2026-04-14 06:49:22.045	2026-04-14 06:49:22.045
cmny9gywp03o5vxy4xm8tlk4g	cmny9gyjg03njvxy45645uprt	cmny9fdcn000dvxy4w3gaald5	83000	2026-04-14 06:49:22.104	2026-04-14 06:49:22.104
cmny9gyyh03o8vxy4cl7dgpnz	cmny9gyxt03o6vxy49w9d18ma	cmny9fd420001vxy42djthn1o	25000	2026-04-14 06:49:22.169	2026-04-14 06:49:22.169
cmny9gyz603oavxy4kiiwc68o	cmny9gyxt03o6vxy49w9d18ma	cmny9fd4t0002vxy4jo0l7gop	25000	2026-04-14 06:49:22.194	2026-04-14 06:49:22.194
cmny9gyzv03ocvxy4tj4dqj7i	cmny9gyxt03o6vxy49w9d18ma	cmny9fd5j0003vxy4sw5e14p1	25000	2026-04-14 06:49:22.219	2026-04-14 06:49:22.219
cmny9gz0k03oevxy43ixwufkq	cmny9gyxt03o6vxy49w9d18ma	cmny9fd6h0004vxy4evm3jgfv	25000	2026-04-14 06:49:22.244	2026-04-14 06:49:22.244
cmny9gz1c03ogvxy4r0wk7k66	cmny9gyxt03o6vxy49w9d18ma	cmny9fd7u0006vxy4mh4wwui4	25000	2026-04-14 06:49:22.272	2026-04-14 06:49:22.272
cmny9gz2n03oivxy44uls4ezb	cmny9gyxt03o6vxy49w9d18ma	cmny9fd8i0007vxy4tmc0glr0	25000	2026-04-14 06:49:22.319	2026-04-14 06:49:22.319
cmny9gz4103okvxy4w9ya5uuc	cmny9gyxt03o6vxy49w9d18ma	cmny9fd980008vxy4alsawn4y	25000	2026-04-14 06:49:22.369	2026-04-14 06:49:22.369
cmny9gz5f03omvxy46i2f2ba2	cmny9gyxt03o6vxy49w9d18ma	cmny9fd9w0009vxy498vvvu1d	25000	2026-04-14 06:49:22.419	2026-04-14 06:49:22.419
cmny9gz7503oovxy4nztahabs	cmny9gyxt03o6vxy49w9d18ma	cmny9fdb9000bvxy4h02fexen	25000	2026-04-14 06:49:22.481	2026-04-14 06:49:22.481
cmny9gz8703oqvxy47j163t75	cmny9gyxt03o6vxy49w9d18ma	cmny9fdc1000cvxy4n4y9ezu8	25000	2026-04-14 06:49:22.52	2026-04-14 06:49:22.52
cmny9gz9l03osvxy4pvnd2ez0	cmny9gyxt03o6vxy49w9d18ma	cmny9fdcn000dvxy4w3gaald5	25000	2026-04-14 06:49:22.569	2026-04-14 06:49:22.569
cmny9gzc803ovvxy4x5mba2gl	cmny9gzar03otvxy4hzf17iaf	cmny9fd420001vxy42djthn1o	77000	2026-04-14 06:49:22.664	2026-04-14 06:49:22.664
cmny9gzd303oxvxy46tl4pm9p	cmny9gzar03otvxy4hzf17iaf	cmny9fd4t0002vxy4jo0l7gop	77000	2026-04-14 06:49:22.695	2026-04-14 06:49:22.695
cmny9gze003ozvxy4l7j1fer6	cmny9gzar03otvxy4hzf17iaf	cmny9fd5j0003vxy4sw5e14p1	77000	2026-04-14 06:49:22.728	2026-04-14 06:49:22.728
cmny9gzfd03p1vxy4y0qh6qcn	cmny9gzar03otvxy4hzf17iaf	cmny9fd6h0004vxy4evm3jgfv	77000	2026-04-14 06:49:22.777	2026-04-14 06:49:22.777
cmny9gzg403p3vxy491nghp17	cmny9gzar03otvxy4hzf17iaf	cmny9fd7u0006vxy4mh4wwui4	77000	2026-04-14 06:49:22.804	2026-04-14 06:49:22.804
cmny9gzgr03p5vxy4fvd61afs	cmny9gzar03otvxy4hzf17iaf	cmny9fd8i0007vxy4tmc0glr0	77000	2026-04-14 06:49:22.827	2026-04-14 06:49:22.827
cmny9gziu03p7vxy4nqi337pu	cmny9gzar03otvxy4hzf17iaf	cmny9fd980008vxy4alsawn4y	77000	2026-04-14 06:49:22.903	2026-04-14 06:49:22.903
cmny9gzjj03p9vxy4gy5n0ump	cmny9gzar03otvxy4hzf17iaf	cmny9fd9w0009vxy498vvvu1d	77000	2026-04-14 06:49:22.927	2026-04-14 06:49:22.927
cmny9gzka03pbvxy4sb892ojr	cmny9gzar03otvxy4hzf17iaf	cmny9fdb9000bvxy4h02fexen	77000	2026-04-14 06:49:22.954	2026-04-14 06:49:22.954
cmny9gzkx03pdvxy4h9pev1ut	cmny9gzar03otvxy4hzf17iaf	cmny9fdc1000cvxy4n4y9ezu8	77000	2026-04-14 06:49:22.977	2026-04-14 06:49:22.977
cmny9gzln03pfvxy4qecc1mkc	cmny9gzar03otvxy4hzf17iaf	cmny9fdcn000dvxy4w3gaald5	77000	2026-04-14 06:49:23.003	2026-04-14 06:49:23.003
cmny9gzn103pivxy4aiok6upi	cmny9gzmb03pgvxy4zp1bb5q8	cmny9fd420001vxy42djthn1o	47000	2026-04-14 06:49:23.053	2026-04-14 06:49:23.053
cmny9gznp03pkvxy47hp3p2hb	cmny9gzmb03pgvxy4zp1bb5q8	cmny9fd4t0002vxy4jo0l7gop	47000	2026-04-14 06:49:23.078	2026-04-14 06:49:23.078
cmny9gzpc03pmvxy4burlxu40	cmny9gzmb03pgvxy4zp1bb5q8	cmny9fd5j0003vxy4sw5e14p1	47000	2026-04-14 06:49:23.136	2026-04-14 06:49:23.136
cmny9gzqq03povxy468rb8i1e	cmny9gzmb03pgvxy4zp1bb5q8	cmny9fd6h0004vxy4evm3jgfv	47000	2026-04-14 06:49:23.186	2026-04-14 06:49:23.186
cmny9gzrh03pqvxy47d1osd4t	cmny9gzmb03pgvxy4zp1bb5q8	cmny9fd7u0006vxy4mh4wwui4	47000	2026-04-14 06:49:23.213	2026-04-14 06:49:23.213
cmny9gzt103psvxy4xf1ckrwd	cmny9gzmb03pgvxy4zp1bb5q8	cmny9fd8i0007vxy4tmc0glr0	47000	2026-04-14 06:49:23.27	2026-04-14 06:49:23.27
cmny9gztq03puvxy43apjqzjj	cmny9gzmb03pgvxy4zp1bb5q8	cmny9fd980008vxy4alsawn4y	47000	2026-04-14 06:49:23.295	2026-04-14 06:49:23.295
cmny9gzuf03pwvxy4szho20g5	cmny9gzmb03pgvxy4zp1bb5q8	cmny9fd9w0009vxy498vvvu1d	47000	2026-04-14 06:49:23.319	2026-04-14 06:49:23.319
cmny9gzv603pyvxy44vqrue8t	cmny9gzmb03pgvxy4zp1bb5q8	cmny9fdb9000bvxy4h02fexen	47000	2026-04-14 06:49:23.346	2026-04-14 06:49:23.346
cmny9gzvt03q0vxy4ji8oxrhh	cmny9gzmb03pgvxy4zp1bb5q8	cmny9fdc1000cvxy4n4y9ezu8	47000	2026-04-14 06:49:23.369	2026-04-14 06:49:23.369
cmny9gzwi03q2vxy41hqqdypd	cmny9gzmb03pgvxy4zp1bb5q8	cmny9fdcn000dvxy4w3gaald5	47000	2026-04-14 06:49:23.395	2026-04-14 06:49:23.395
cmny9gzxw03q5vxy4xsb4wy4a	cmny9gzx803q3vxy4uev1plkr	cmny9fd420001vxy42djthn1o	480000	2026-04-14 06:49:23.445	2026-04-14 06:49:23.445
cmny9gzyl03q7vxy40d78jrzw	cmny9gzx803q3vxy4uev1plkr	cmny9fd4t0002vxy4jo0l7gop	480000	2026-04-14 06:49:23.469	2026-04-14 06:49:23.469
cmny9h00003q9vxy487790czb	cmny9gzx803q3vxy4uev1plkr	cmny9fd5j0003vxy4sw5e14p1	480000	2026-04-14 06:49:23.52	2026-04-14 06:49:23.52
cmny9h00o03qbvxy4ixz9q5oc	cmny9gzx803q3vxy4uev1plkr	cmny9fd6h0004vxy4evm3jgfv	480000	2026-04-14 06:49:23.545	2026-04-14 06:49:23.545
cmny9h02403qdvxy41ukqtonr	cmny9gzx803q3vxy4uev1plkr	cmny9fd7u0006vxy4mh4wwui4	480000	2026-04-14 06:49:23.596	2026-04-14 06:49:23.596
cmny9h02r03qfvxy4grzv309s	cmny9gzx803q3vxy4uev1plkr	cmny9fd8i0007vxy4tmc0glr0	480000	2026-04-14 06:49:23.619	2026-04-14 06:49:23.619
cmny9h03g03qhvxy4ieyn77z7	cmny9gzx803q3vxy4uev1plkr	cmny9fd980008vxy4alsawn4y	480000	2026-04-14 06:49:23.644	2026-04-14 06:49:23.644
cmny9h04v03qjvxy48qtrr6eg	cmny9gzx803q3vxy4uev1plkr	cmny9fd9w0009vxy498vvvu1d	480000	2026-04-14 06:49:23.695	2026-04-14 06:49:23.695
cmny9h06i03qlvxy4gncmimxs	cmny9gzx803q3vxy4uev1plkr	cmny9fdb9000bvxy4h02fexen	480000	2026-04-14 06:49:23.755	2026-04-14 06:49:23.755
cmny9h07603qnvxy4282ajk1e	cmny9gzx803q3vxy4uev1plkr	cmny9fdc1000cvxy4n4y9ezu8	480000	2026-04-14 06:49:23.778	2026-04-14 06:49:23.778
cmny9h07v03qpvxy4u0bt3s62	cmny9gzx803q3vxy4uev1plkr	cmny9fdcn000dvxy4w3gaald5	480000	2026-04-14 06:49:23.803	2026-04-14 06:49:23.803
cmny9h09a03qsvxy400ff9yuw	cmny9h08j03qqvxy4sn40s412	cmny9fd420001vxy42djthn1o	26000	2026-04-14 06:49:23.854	2026-04-14 06:49:23.854
cmny9h0av03quvxy4fosxrmws	cmny9h08j03qqvxy4sn40s412	cmny9fd4t0002vxy4jo0l7gop	26000	2026-04-14 06:49:23.911	2026-04-14 06:49:23.911
cmny9h0df03qwvxy4s6qpk0kt	cmny9h08j03qqvxy4sn40s412	cmny9fd5j0003vxy4sw5e14p1	26000	2026-04-14 06:49:24.004	2026-04-14 06:49:24.004
cmny9h0f103qyvxy4y7piogt4	cmny9h08j03qqvxy4sn40s412	cmny9fd6h0004vxy4evm3jgfv	26000	2026-04-14 06:49:24.061	2026-04-14 06:49:24.061
cmny9h0ft03r0vxy4dkquys7w	cmny9h08j03qqvxy4sn40s412	cmny9fd7u0006vxy4mh4wwui4	26000	2026-04-14 06:49:24.089	2026-04-14 06:49:24.089
cmny9h0gf03r2vxy478ekn1ae	cmny9h08j03qqvxy4sn40s412	cmny9fd8i0007vxy4tmc0glr0	26000	2026-04-14 06:49:24.111	2026-04-14 06:49:24.111
cmny9h0h403r4vxy4uvkaoo3p	cmny9h08j03qqvxy4sn40s412	cmny9fd980008vxy4alsawn4y	26000	2026-04-14 06:49:24.137	2026-04-14 06:49:24.137
cmny9h0ip03r6vxy4iyere20x	cmny9h08j03qqvxy4sn40s412	cmny9fd9w0009vxy498vvvu1d	26000	2026-04-14 06:49:24.194	2026-04-14 06:49:24.194
cmny9h0ke03r8vxy4nfykehiy	cmny9h08j03qqvxy4sn40s412	cmny9fdb9000bvxy4h02fexen	26000	2026-04-14 06:49:24.255	2026-04-14 06:49:24.255
cmny9h0lz03ravxy4rjstuvgp	cmny9h08j03qqvxy4sn40s412	cmny9fdc1000cvxy4n4y9ezu8	26000	2026-04-14 06:49:24.311	2026-04-14 06:49:24.311
cmny9h0nm03rcvxy403tg4cxp	cmny9h08j03qqvxy4sn40s412	cmny9fdcn000dvxy4w3gaald5	26000	2026-04-14 06:49:24.37	2026-04-14 06:49:24.37
cmny9h0qu03rfvxy4go1309w8	cmny9h0p703rdvxy4n7050gnm	cmny9fd420001vxy42djthn1o	30000	2026-04-14 06:49:24.486	2026-04-14 06:49:24.486
cmny9h0sg03rhvxy41xi7syc6	cmny9h0p703rdvxy4n7050gnm	cmny9fd4t0002vxy4jo0l7gop	30000	2026-04-14 06:49:24.544	2026-04-14 06:49:24.544
cmny9h0t603rjvxy4johv84jd	cmny9h0p703rdvxy4n7050gnm	cmny9fd5j0003vxy4sw5e14p1	30000	2026-04-14 06:49:24.57	2026-04-14 06:49:24.57
cmny9h0tu03rlvxy4nq8e96ft	cmny9h0p703rdvxy4n7050gnm	cmny9fd6h0004vxy4evm3jgfv	30000	2026-04-14 06:49:24.594	2026-04-14 06:49:24.594
cmny9h0ul03rnvxy4xdkfdees	cmny9h0p703rdvxy4n7050gnm	cmny9fd7u0006vxy4mh4wwui4	30000	2026-04-14 06:49:24.621	2026-04-14 06:49:24.621
cmny9h0v803rpvxy4btt0l6wp	cmny9h0p703rdvxy4n7050gnm	cmny9fd8i0007vxy4tmc0glr0	30000	2026-04-14 06:49:24.644	2026-04-14 06:49:24.644
cmny9h0vx03rrvxy4yoh1mh44	cmny9h0p703rdvxy4n7050gnm	cmny9fd980008vxy4alsawn4y	30000	2026-04-14 06:49:24.67	2026-04-14 06:49:24.67
cmny9h0wl03rtvxy4a1bxg8or	cmny9h0p703rdvxy4n7050gnm	cmny9fd9w0009vxy498vvvu1d	30000	2026-04-14 06:49:24.694	2026-04-14 06:49:24.694
cmny9h0xe03rvvxy4y064u1n3	cmny9h0p703rdvxy4n7050gnm	cmny9fdb9000bvxy4h02fexen	30000	2026-04-14 06:49:24.723	2026-04-14 06:49:24.723
cmny9h0y803rxvxy4phl2kwzf	cmny9h0p703rdvxy4n7050gnm	cmny9fdc1000cvxy4n4y9ezu8	30000	2026-04-14 06:49:24.753	2026-04-14 06:49:24.753
cmny9h0yy03rzvxy4w33n9jtb	cmny9h0p703rdvxy4n7050gnm	cmny9fdcn000dvxy4w3gaald5	30000	2026-04-14 06:49:24.778	2026-04-14 06:49:24.778
cmny9h11q03s2vxy4gnoym8wf	cmny9h10b03s0vxy4etpnganx	cmny9fd420001vxy42djthn1o	22000	2026-04-14 06:49:24.878	2026-04-14 06:49:24.878
cmny9h12f03s4vxy4zzxldpl6	cmny9h10b03s0vxy4etpnganx	cmny9fd4t0002vxy4jo0l7gop	22000	2026-04-14 06:49:24.903	2026-04-14 06:49:24.903
cmny9h13t03s6vxy4fplohfyl	cmny9h10b03s0vxy4etpnganx	cmny9fd5j0003vxy4sw5e14p1	22000	2026-04-14 06:49:24.954	2026-04-14 06:49:24.954
cmny9h15n03s8vxy4y1g7t3d0	cmny9h10b03s0vxy4etpnganx	cmny9fd6h0004vxy4evm3jgfv	22000	2026-04-14 06:49:25.019	2026-04-14 06:49:25.019
cmny9h17303savxy4g4wbuah8	cmny9h10b03s0vxy4etpnganx	cmny9fd7u0006vxy4mh4wwui4	22000	2026-04-14 06:49:25.071	2026-04-14 06:49:25.071
cmny9h18f03scvxy4geaa651p	cmny9h10b03s0vxy4etpnganx	cmny9fd8i0007vxy4tmc0glr0	22000	2026-04-14 06:49:25.12	2026-04-14 06:49:25.12
cmny9h1a303sevxy42qmpldlw	cmny9h10b03s0vxy4etpnganx	cmny9fd980008vxy4alsawn4y	22000	2026-04-14 06:49:25.179	2026-04-14 06:49:25.179
cmny9h1bg03sgvxy4ucn0q454	cmny9h10b03s0vxy4etpnganx	cmny9fd9w0009vxy498vvvu1d	22000	2026-04-14 06:49:25.228	2026-04-14 06:49:25.228
cmny9h1dc03sivxy41k76q5ei	cmny9h10b03s0vxy4etpnganx	cmny9fdb9000bvxy4h02fexen	22000	2026-04-14 06:49:25.296	2026-04-14 06:49:25.296
cmny9h1eo03skvxy4acfh7rzu	cmny9h10b03s0vxy4etpnganx	cmny9fdc1000cvxy4n4y9ezu8	22000	2026-04-14 06:49:25.344	2026-04-14 06:49:25.344
cmny9h1ff03smvxy4xzbw37gc	cmny9h10b03s0vxy4etpnganx	cmny9fdcn000dvxy4w3gaald5	22000	2026-04-14 06:49:25.371	2026-04-14 06:49:25.371
cmny9h1hg03spvxy4r8rdeihz	cmny9h1gr03snvxy4gd7copgl	cmny9fd420001vxy42djthn1o	68000	2026-04-14 06:49:25.445	2026-04-14 06:49:25.445
cmny9h1i503srvxy4qfl1xfcw	cmny9h1gr03snvxy4gd7copgl	cmny9fd4t0002vxy4jo0l7gop	68000	2026-04-14 06:49:25.469	2026-04-14 06:49:25.469
cmny9h1iu03stvxy4x892nae0	cmny9h1gr03snvxy4gd7copgl	cmny9fd5j0003vxy4sw5e14p1	68000	2026-04-14 06:49:25.494	2026-04-14 06:49:25.494
cmny9h1kh03svvxy4ugcpt676	cmny9h1gr03snvxy4gd7copgl	cmny9fd6h0004vxy4evm3jgfv	68000	2026-04-14 06:49:25.553	2026-04-14 06:49:25.553
cmny9h1mk03sxvxy4p86yjzdd	cmny9h1gr03snvxy4gd7copgl	cmny9fd7u0006vxy4mh4wwui4	68000	2026-04-14 06:49:25.628	2026-04-14 06:49:25.628
cmny9h1nx03szvxy4yockiyhc	cmny9h1gr03snvxy4gd7copgl	cmny9fd8i0007vxy4tmc0glr0	68000	2026-04-14 06:49:25.677	2026-04-14 06:49:25.677
cmny9h1on03t1vxy49w06qerm	cmny9h1gr03snvxy4gd7copgl	cmny9fd980008vxy4alsawn4y	68000	2026-04-14 06:49:25.703	2026-04-14 06:49:25.703
cmny9h1pb03t3vxy48q8hhy2x	cmny9h1gr03snvxy4gd7copgl	cmny9fd9w0009vxy498vvvu1d	68000	2026-04-14 06:49:25.727	2026-04-14 06:49:25.727
cmny9h1q303t5vxy4nt30fbec	cmny9h1gr03snvxy4gd7copgl	cmny9fdb9000bvxy4h02fexen	68000	2026-04-14 06:49:25.755	2026-04-14 06:49:25.755
cmny9h1rm03t7vxy4vp4g00c2	cmny9h1gr03snvxy4gd7copgl	cmny9fdc1000cvxy4n4y9ezu8	68000	2026-04-14 06:49:25.81	2026-04-14 06:49:25.81
cmny9h1sd03t9vxy4e8dstdc2	cmny9h1gr03snvxy4gd7copgl	cmny9fdcn000dvxy4w3gaald5	68000	2026-04-14 06:49:25.837	2026-04-14 06:49:25.837
cmny9h1un03tcvxy4sg5h0lmz	cmny9h1t103tavxy4l41zkqt5	cmny9fd420001vxy42djthn1o	48000	2026-04-14 06:49:25.919	2026-04-14 06:49:25.919
cmny9h1wa03tevxy4zchipojc	cmny9h1t103tavxy4l41zkqt5	cmny9fd4t0002vxy4jo0l7gop	48000	2026-04-14 06:49:25.978	2026-04-14 06:49:25.978
cmny9h1xw03tgvxy4jytvgi25	cmny9h1t103tavxy4l41zkqt5	cmny9fd5j0003vxy4sw5e14p1	48000	2026-04-14 06:49:26.037	2026-04-14 06:49:26.037
cmny9h1z903tivxy4iozfymqh	cmny9h1t103tavxy4l41zkqt5	cmny9fd6h0004vxy4evm3jgfv	48000	2026-04-14 06:49:26.086	2026-04-14 06:49:26.086
cmny9h20r03tkvxy471ek7b3j	cmny9h1t103tavxy4l41zkqt5	cmny9fd7u0006vxy4mh4wwui4	48000	2026-04-14 06:49:26.139	2026-04-14 06:49:26.139
cmny9h21m03tmvxy4b3c3r9k4	cmny9h1t103tavxy4l41zkqt5	cmny9fd8i0007vxy4tmc0glr0	48000	2026-04-14 06:49:26.17	2026-04-14 06:49:26.17
cmny9h22z03tovxy4dcns4wsz	cmny9h1t103tavxy4l41zkqt5	cmny9fd980008vxy4alsawn4y	48000	2026-04-14 06:49:26.219	2026-04-14 06:49:26.219
cmny9h24d03tqvxy4x3lm9df4	cmny9h1t103tavxy4l41zkqt5	cmny9fd9w0009vxy498vvvu1d	48000	2026-04-14 06:49:26.269	2026-04-14 06:49:26.269
cmny9h27x03tsvxy48y4tlrmm	cmny9h1t103tavxy4l41zkqt5	cmny9fdb9000bvxy4h02fexen	48000	2026-04-14 06:49:26.397	2026-04-14 06:49:26.397
cmny9h29c03tuvxy4dzakkl5d	cmny9h1t103tavxy4l41zkqt5	cmny9fdc1000cvxy4n4y9ezu8	48000	2026-04-14 06:49:26.448	2026-04-14 06:49:26.448
cmny9h2av03twvxy4e62y3vww	cmny9h1t103tavxy4l41zkqt5	cmny9fdcn000dvxy4w3gaald5	48000	2026-04-14 06:49:26.503	2026-04-14 06:49:26.503
cmny9h2cc03tzvxy4a1nzg08z	cmny9h2bl03txvxy43g6cpnh6	cmny9fd420001vxy42djthn1o	28000	2026-04-14 06:49:26.556	2026-04-14 06:49:26.556
cmny9h2dp03u1vxy4ui17d050	cmny9h2bl03txvxy43g6cpnh6	cmny9fd4t0002vxy4jo0l7gop	28000	2026-04-14 06:49:26.605	2026-04-14 06:49:26.605
cmny9h2ek03u3vxy4k4bkoefk	cmny9h2bl03txvxy43g6cpnh6	cmny9fd5j0003vxy4sw5e14p1	28000	2026-04-14 06:49:26.637	2026-04-14 06:49:26.637
cmny9h2f803u5vxy4taglcg7s	cmny9h2bl03txvxy43g6cpnh6	cmny9fd6h0004vxy4evm3jgfv	28000	2026-04-14 06:49:26.66	2026-04-14 06:49:26.66
cmny9h2g103u7vxy4w33dyd40	cmny9h2bl03txvxy43g6cpnh6	cmny9fd7u0006vxy4mh4wwui4	28000	2026-04-14 06:49:26.689	2026-04-14 06:49:26.689
cmny9h2gu03u9vxy424p58god	cmny9h2bl03txvxy43g6cpnh6	cmny9fd8i0007vxy4tmc0glr0	28000	2026-04-14 06:49:26.719	2026-04-14 06:49:26.719
cmny9h2hk03ubvxy4oxeitt75	cmny9h2bl03txvxy43g6cpnh6	cmny9fd980008vxy4alsawn4y	28000	2026-04-14 06:49:26.744	2026-04-14 06:49:26.744
cmny9h2i903udvxy4vlpfgleg	cmny9h2bl03txvxy43g6cpnh6	cmny9fd9w0009vxy498vvvu1d	28000	2026-04-14 06:49:26.769	2026-04-14 06:49:26.769
cmny9h2jw03ufvxy4q585kztq	cmny9h2bl03txvxy43g6cpnh6	cmny9fdb9000bvxy4h02fexen	28000	2026-04-14 06:49:26.828	2026-04-14 06:49:26.828
cmny9h2li03uhvxy42cpp3wes	cmny9h2bl03txvxy43g6cpnh6	cmny9fdc1000cvxy4n4y9ezu8	28000	2026-04-14 06:49:26.886	2026-04-14 06:49:26.886
cmny9h2mw03ujvxy4b3m51o8y	cmny9h2bl03txvxy43g6cpnh6	cmny9fdcn000dvxy4w3gaald5	28000	2026-04-14 06:49:26.936	2026-04-14 06:49:26.936
cmny9h2pw03umvxy4jypmeg0d	cmny9h2oa03ukvxy4rzab1vbm	cmny9fd420001vxy42djthn1o	65000	2026-04-14 06:49:27.044	2026-04-14 06:49:27.044
cmny9h2ra03uovxy468s2co7n	cmny9h2oa03ukvxy4rzab1vbm	cmny9fd4t0002vxy4jo0l7gop	65000	2026-04-14 06:49:27.095	2026-04-14 06:49:27.095
cmny9h2rz03uqvxy4aavkkj9a	cmny9h2oa03ukvxy4rzab1vbm	cmny9fd5j0003vxy4sw5e14p1	65000	2026-04-14 06:49:27.119	2026-04-14 06:49:27.119
cmny9h2so03usvxy4ki2a1ah3	cmny9h2oa03ukvxy4rzab1vbm	cmny9fd6h0004vxy4evm3jgfv	65000	2026-04-14 06:49:27.145	2026-04-14 06:49:27.145
cmny9h2uc03uuvxy4k2ti6kpv	cmny9h2oa03ukvxy4rzab1vbm	cmny9fd7u0006vxy4mh4wwui4	65000	2026-04-14 06:49:27.204	2026-04-14 06:49:27.204
cmny9h2vx03uwvxy4cpw33a4e	cmny9h2oa03ukvxy4rzab1vbm	cmny9fd8i0007vxy4tmc0glr0	65000	2026-04-14 06:49:27.261	2026-04-14 06:49:27.261
cmny9h2xj03uyvxy4dx2qk9ks	cmny9h2oa03ukvxy4rzab1vbm	cmny9fd980008vxy4alsawn4y	65000	2026-04-14 06:49:27.319	2026-04-14 06:49:27.319
cmny9h2z503v0vxy4pdy6gy01	cmny9h2oa03ukvxy4rzab1vbm	cmny9fd9w0009vxy498vvvu1d	65000	2026-04-14 06:49:27.378	2026-04-14 06:49:27.378
cmny9h31y03v2vxy45o603ivf	cmny9h2oa03ukvxy4rzab1vbm	cmny9fdb9000bvxy4h02fexen	65000	2026-04-14 06:49:27.479	2026-04-14 06:49:27.479
cmny9h33s03v4vxy4scsv1e24	cmny9h2oa03ukvxy4rzab1vbm	cmny9fdc1000cvxy4n4y9ezu8	65000	2026-04-14 06:49:27.544	2026-04-14 06:49:27.544
cmny9h35o03v6vxy4fzsy2baj	cmny9h2oa03ukvxy4rzab1vbm	cmny9fdcn000dvxy4w3gaald5	65000	2026-04-14 06:49:27.612	2026-04-14 06:49:27.612
cmny9h38v03v9vxy422qvn37z	cmny9h37a03v7vxy4os1u1eid	cmny9fd420001vxy42djthn1o	74000	2026-04-14 06:49:27.728	2026-04-14 06:49:27.728
cmny9h39k03vbvxy4tvloq4v7	cmny9h37a03v7vxy4os1u1eid	cmny9fd4t0002vxy4jo0l7gop	74000	2026-04-14 06:49:27.752	2026-04-14 06:49:27.752
cmny9h3aa03vdvxy47a93gf6u	cmny9h37a03v7vxy4os1u1eid	cmny9fd5j0003vxy4sw5e14p1	74000	2026-04-14 06:49:27.778	2026-04-14 06:49:27.778
cmny9h3bn03vfvxy40hz4puov	cmny9h37a03v7vxy4os1u1eid	cmny9fd6h0004vxy4evm3jgfv	74000	2026-04-14 06:49:27.827	2026-04-14 06:49:27.827
cmny9h3cf03vhvxy4nivsj68x	cmny9h37a03v7vxy4os1u1eid	cmny9fd7u0006vxy4mh4wwui4	74000	2026-04-14 06:49:27.855	2026-04-14 06:49:27.855
cmny9h3d103vjvxy4imrm1aft	cmny9h37a03v7vxy4os1u1eid	cmny9fd8i0007vxy4tmc0glr0	74000	2026-04-14 06:49:27.877	2026-04-14 06:49:27.877
cmny9h3eg03vlvxy4pqjl8teo	cmny9h37a03v7vxy4os1u1eid	cmny9fd980008vxy4alsawn4y	74000	2026-04-14 06:49:27.928	2026-04-14 06:49:27.928
cmny9h3f403vnvxy43iylzodi	cmny9h37a03v7vxy4os1u1eid	cmny9fd9w0009vxy498vvvu1d	74000	2026-04-14 06:49:27.952	2026-04-14 06:49:27.952
cmny9h3fw03vpvxy4f4n5rnqb	cmny9h37a03v7vxy4os1u1eid	cmny9fdb9000bvxy4h02fexen	74000	2026-04-14 06:49:27.98	2026-04-14 06:49:27.98
cmny9h3gi03vrvxy4yzv1tfht	cmny9h37a03v7vxy4os1u1eid	cmny9fdc1000cvxy4n4y9ezu8	74000	2026-04-14 06:49:28.002	2026-04-14 06:49:28.002
cmny9h3h803vtvxy4zwu6ruvd	cmny9h37a03v7vxy4os1u1eid	cmny9fdcn000dvxy4w3gaald5	74000	2026-04-14 06:49:28.028	2026-04-14 06:49:28.028
cmny9h3im03vwvxy4ccjp9vli	cmny9h3hw03vuvxy4yu40k26w	cmny9fd420001vxy42djthn1o	79000	2026-04-14 06:49:28.078	2026-04-14 06:49:28.078
cmny9h3ja03vyvxy44ax8jb9o	cmny9h3hw03vuvxy4yu40k26w	cmny9fd4t0002vxy4jo0l7gop	79000	2026-04-14 06:49:28.102	2026-04-14 06:49:28.102
cmny9h3ke03w0vxy4lqnzzx9p	cmny9h3hw03vuvxy4yu40k26w	cmny9fdc1000cvxy4n4y9ezu8	79000	2026-04-14 06:49:28.142	2026-04-14 06:49:28.142
cmny9h3o903w3vxy4w8b7w47m	cmny9h3md03w1vxy43mwva72s	cmny9fd9w0009vxy498vvvu1d	66000	2026-04-14 06:49:28.281	2026-04-14 06:49:28.281
cmny9h3rm03w6vxy497uvy0ax	cmny9h3q303w4vxy40ffz36vn	cmny9fd420001vxy42djthn1o	28000	2026-04-14 06:49:28.402	2026-04-14 06:49:28.402
cmny9h3t803w8vxy46u337w3s	cmny9h3q303w4vxy40ffz36vn	cmny9fd4t0002vxy4jo0l7gop	28000	2026-04-14 06:49:28.46	2026-04-14 06:49:28.46
cmny9h3uv03wavxy436mas1zt	cmny9h3q303w4vxy40ffz36vn	cmny9fd5j0003vxy4sw5e14p1	28000	2026-04-14 06:49:28.52	2026-04-14 06:49:28.52
cmny9h3x703wcvxy4y65t24es	cmny9h3q303w4vxy40ffz36vn	cmny9fd6h0004vxy4evm3jgfv	28000	2026-04-14 06:49:28.603	2026-04-14 06:49:28.603
cmny9h3xx03wevxy41h198cyx	cmny9h3q303w4vxy40ffz36vn	cmny9fd7u0006vxy4mh4wwui4	28000	2026-04-14 06:49:28.629	2026-04-14 06:49:28.629
cmny9h3zq03wgvxy4iu5ry046	cmny9h3q303w4vxy40ffz36vn	cmny9fd8i0007vxy4tmc0glr0	28000	2026-04-14 06:49:28.695	2026-04-14 06:49:28.695
cmny9h41503wivxy4km8zwt6v	cmny9h3q303w4vxy40ffz36vn	cmny9fd980008vxy4alsawn4y	28000	2026-04-14 06:49:28.745	2026-04-14 06:49:28.745
cmny9h41t03wkvxy4w6l4daw3	cmny9h3q303w4vxy40ffz36vn	cmny9fd9w0009vxy498vvvu1d	28000	2026-04-14 06:49:28.769	2026-04-14 06:49:28.769
cmny9h42k03wmvxy4aze33qd3	cmny9h3q303w4vxy40ffz36vn	cmny9fdb9000bvxy4h02fexen	28000	2026-04-14 06:49:28.797	2026-04-14 06:49:28.797
cmny9h43703wovxy4h17g2evz	cmny9h3q303w4vxy40ffz36vn	cmny9fdc1000cvxy4n4y9ezu8	28000	2026-04-14 06:49:28.819	2026-04-14 06:49:28.819
cmny9h43x03wqvxy4rgxcgidm	cmny9h3q303w4vxy40ffz36vn	cmny9fdcn000dvxy4w3gaald5	28000	2026-04-14 06:49:28.845	2026-04-14 06:49:28.845
cmny9h46q03wtvxy4urvyapce	cmny9h44l03wrvxy4bhk44lc5	cmny9fd4t0002vxy4jo0l7gop	45000	2026-04-14 06:49:28.946	2026-04-14 06:49:28.946
cmny9h48h03wvvxy4alvzocvv	cmny9h44l03wrvxy4bhk44lc5	cmny9fdc1000cvxy4n4y9ezu8	45000	2026-04-14 06:49:29.009	2026-04-14 06:49:29.009
cmny9h4b303wyvxy4e165xo5k	cmny9h49r03wwvxy4w03e6dhk	cmny9fd420001vxy42djthn1o	126000	2026-04-14 06:49:29.103	2026-04-14 06:49:29.103
cmny9h4cp03x0vxy4hek31yia	cmny9h49r03wwvxy4w03e6dhk	cmny9fd4t0002vxy4jo0l7gop	126000	2026-04-14 06:49:29.162	2026-04-14 06:49:29.162
cmny9h4e403x2vxy4gr9twdrt	cmny9h49r03wwvxy4w03e6dhk	cmny9fd5j0003vxy4sw5e14p1	126000	2026-04-14 06:49:29.212	2026-04-14 06:49:29.212
cmny9h4fg03x4vxy4wqz5ij54	cmny9h49r03wwvxy4w03e6dhk	cmny9fd6h0004vxy4evm3jgfv	126000	2026-04-14 06:49:29.261	2026-04-14 06:49:29.261
cmny9h4g803x6vxy4j5fp3ijq	cmny9h49r03wwvxy4w03e6dhk	cmny9fd7u0006vxy4mh4wwui4	126000	2026-04-14 06:49:29.288	2026-04-14 06:49:29.288
cmny9h4gu03x8vxy4grrp97lj	cmny9h49r03wwvxy4w03e6dhk	cmny9fd8i0007vxy4tmc0glr0	126000	2026-04-14 06:49:29.31	2026-04-14 06:49:29.31
cmny9h4i803xavxy4biixmi6i	cmny9h49r03wwvxy4w03e6dhk	cmny9fd980008vxy4alsawn4y	126000	2026-04-14 06:49:29.36	2026-04-14 06:49:29.36
cmny9h4iy03xcvxy4twyrhx6m	cmny9h49r03wwvxy4w03e6dhk	cmny9fd9w0009vxy498vvvu1d	126000	2026-04-14 06:49:29.386	2026-04-14 06:49:29.386
cmny9h4jp03xevxy4e59n62ac	cmny9h49r03wwvxy4w03e6dhk	cmny9fdb9000bvxy4h02fexen	126000	2026-04-14 06:49:29.413	2026-04-14 06:49:29.413
cmny9h4kc03xgvxy46m56yilb	cmny9h49r03wwvxy4w03e6dhk	cmny9fdc1000cvxy4n4y9ezu8	126000	2026-04-14 06:49:29.436	2026-04-14 06:49:29.436
cmny9h4lq03xivxy4l7ydd5au	cmny9h49r03wwvxy4w03e6dhk	cmny9fdcn000dvxy4w3gaald5	126000	2026-04-14 06:49:29.487	2026-04-14 06:49:29.487
cmny9h4o103xlvxy4vok4757m	cmny9h4nc03xjvxy4kdly6h45	cmny9fd420001vxy42djthn1o	27000	2026-04-14 06:49:29.569	2026-04-14 06:49:29.569
cmny9h4or03xnvxy4fq8ty3y8	cmny9h4nc03xjvxy4kdly6h45	cmny9fd4t0002vxy4jo0l7gop	27000	2026-04-14 06:49:29.596	2026-04-14 06:49:29.596
cmny9h4qd03xpvxy47m1xyqx6	cmny9h4nc03xjvxy4kdly6h45	cmny9fd5j0003vxy4sw5e14p1	27000	2026-04-14 06:49:29.653	2026-04-14 06:49:29.653
cmny9h4rs03xrvxy4kvwowad7	cmny9h4nc03xjvxy4kdly6h45	cmny9fd6h0004vxy4evm3jgfv	27000	2026-04-14 06:49:29.704	2026-04-14 06:49:29.704
cmny9h4tf03xtvxy4diuwyb40	cmny9h4nc03xjvxy4kdly6h45	cmny9fd7u0006vxy4mh4wwui4	27000	2026-04-14 06:49:29.764	2026-04-14 06:49:29.764
cmny9h4wl03xvvxy4bocxu8gk	cmny9h4nc03xjvxy4kdly6h45	cmny9fd8i0007vxy4tmc0glr0	27000	2026-04-14 06:49:29.878	2026-04-14 06:49:29.878
cmny9h4yh03xxvxy44lfaidv9	cmny9h4nc03xjvxy4kdly6h45	cmny9fd980008vxy4alsawn4y	27000	2026-04-14 06:49:29.945	2026-04-14 06:49:29.945
cmny9h50303xzvxy4bdxnefmb	cmny9h4nc03xjvxy4kdly6h45	cmny9fd9w0009vxy498vvvu1d	27000	2026-04-14 06:49:30.003	2026-04-14 06:49:30.003
cmny9h51q03y1vxy4volpzorq	cmny9h4nc03xjvxy4kdly6h45	cmny9fdb9000bvxy4h02fexen	27000	2026-04-14 06:49:30.062	2026-04-14 06:49:30.062
cmny9h53b03y3vxy4w47nx25o	cmny9h4nc03xjvxy4kdly6h45	cmny9fdc1000cvxy4n4y9ezu8	27000	2026-04-14 06:49:30.12	2026-04-14 06:49:30.12
cmny9h54p03y5vxy4pzu9jbn5	cmny9h4nc03xjvxy4kdly6h45	cmny9fdcn000dvxy4w3gaald5	27000	2026-04-14 06:49:30.17	2026-04-14 06:49:30.17
cmny9h57903y8vxy4y7h7478c	cmny9h55e03y6vxy4ylao22x8	cmny9fd420001vxy42djthn1o	80000	2026-04-14 06:49:30.262	2026-04-14 06:49:30.262
cmny9h57x03yavxy4e7nq9jbo	cmny9h55e03y6vxy4ylao22x8	cmny9fd4t0002vxy4jo0l7gop	80000	2026-04-14 06:49:30.286	2026-04-14 06:49:30.286
cmny9h59c03ycvxy4by3rxnbm	cmny9h55e03y6vxy4ylao22x8	cmny9fd5j0003vxy4sw5e14p1	80000	2026-04-14 06:49:30.336	2026-04-14 06:49:30.336
cmny9h5a103yevxy459b8utpu	cmny9h55e03y6vxy4ylao22x8	cmny9fd6h0004vxy4evm3jgfv	80000	2026-04-14 06:49:30.361	2026-04-14 06:49:30.361
cmny9h5at03ygvxy4pn3fkc5s	cmny9h55e03y6vxy4ylao22x8	cmny9fd7u0006vxy4mh4wwui4	80000	2026-04-14 06:49:30.39	2026-04-14 06:49:30.39
cmny9h5bn03yivxy4j8po6ibg	cmny9h55e03y6vxy4ylao22x8	cmny9fd8i0007vxy4tmc0glr0	80000	2026-04-14 06:49:30.42	2026-04-14 06:49:30.42
cmny9h5cc03ykvxy43oymmebt	cmny9h55e03y6vxy4ylao22x8	cmny9fd980008vxy4alsawn4y	80000	2026-04-14 06:49:30.445	2026-04-14 06:49:30.445
cmny9h5d203ymvxy42mvg9tc5	cmny9h55e03y6vxy4ylao22x8	cmny9fd9w0009vxy498vvvu1d	80000	2026-04-14 06:49:30.47	2026-04-14 06:49:30.47
cmny9h5dv03yovxy4eeip9ueb	cmny9h55e03y6vxy4ylao22x8	cmny9fdb9000bvxy4h02fexen	80000	2026-04-14 06:49:30.499	2026-04-14 06:49:30.499
cmny9h5fe03yqvxy4xxvwz5yp	cmny9h55e03y6vxy4ylao22x8	cmny9fdc1000cvxy4n4y9ezu8	80000	2026-04-14 06:49:30.554	2026-04-14 06:49:30.554
cmny9h5g303ysvxy42x6uyc2w	cmny9h55e03y6vxy4ylao22x8	cmny9fdcn000dvxy4w3gaald5	80000	2026-04-14 06:49:30.579	2026-04-14 06:49:30.579
cmny9h5kx03ywvxy45dg2u6zg	cmny9h5ju03yuvxy4v7aj8lsd	cmny9fd420001vxy42djthn1o	1228000	2026-04-14 06:49:30.753	2026-04-14 06:49:30.753
cmny9h5lm03yyvxy4vejf0lwq	cmny9h5ju03yuvxy4v7aj8lsd	cmny9fd4t0002vxy4jo0l7gop	1228000	2026-04-14 06:49:30.779	2026-04-14 06:49:30.779
cmny9h5n003z0vxy4l0c1c5va	cmny9h5ju03yuvxy4v7aj8lsd	cmny9fd5j0003vxy4sw5e14p1	1228000	2026-04-14 06:49:30.828	2026-04-14 06:49:30.828
cmny9h5no03z2vxy4rbac6bsi	cmny9h5ju03yuvxy4v7aj8lsd	cmny9fd6h0004vxy4evm3jgfv	1228000	2026-04-14 06:49:30.852	2026-04-14 06:49:30.852
cmny9h5of03z4vxy464dyptqf	cmny9h5ju03yuvxy4v7aj8lsd	cmny9fd7u0006vxy4mh4wwui4	1228000	2026-04-14 06:49:30.88	2026-04-14 06:49:30.88
cmny9h5p203z6vxy4k8q3ocpu	cmny9h5ju03yuvxy4v7aj8lsd	cmny9fd8i0007vxy4tmc0glr0	1228000	2026-04-14 06:49:30.902	2026-04-14 06:49:30.902
cmny9h5ps03z8vxy43dguj8rj	cmny9h5ju03yuvxy4v7aj8lsd	cmny9fd980008vxy4alsawn4y	1228000	2026-04-14 06:49:30.928	2026-04-14 06:49:30.928
cmny9h5r503zavxy4ltty53x3	cmny9h5ju03yuvxy4v7aj8lsd	cmny9fd9w0009vxy498vvvu1d	1228000	2026-04-14 06:49:30.977	2026-04-14 06:49:30.977
cmny9h5st03zcvxy4td2rsfja	cmny9h5ju03yuvxy4v7aj8lsd	cmny9fdb9000bvxy4h02fexen	1228000	2026-04-14 06:49:31.037	2026-04-14 06:49:31.037
cmny9h5un03zevxy4exib0pjo	cmny9h5ju03yuvxy4v7aj8lsd	cmny9fdc1000cvxy4n4y9ezu8	1228000	2026-04-14 06:49:31.103	2026-04-14 06:49:31.103
cmny9h5w103zgvxy47vjdn2ly	cmny9h5ju03yuvxy4v7aj8lsd	cmny9fdcn000dvxy4w3gaald5	1228000	2026-04-14 06:49:31.153	2026-04-14 06:49:31.153
cmny9h5yk03zjvxy4w8ucuxw9	cmny9h5xn03zhvxy46ymlfk87	cmny9fd420001vxy42djthn1o	750000	2026-04-14 06:49:31.244	2026-04-14 06:49:31.244
cmny9h5zi03zlvxy4yku5bo4l	cmny9h5xn03zhvxy46ymlfk87	cmny9fd4t0002vxy4jo0l7gop	750000	2026-04-14 06:49:31.278	2026-04-14 06:49:31.278
cmny9h61t03znvxy4gg5yctu7	cmny9h5xn03zhvxy46ymlfk87	cmny9fd5j0003vxy4sw5e14p1	750000	2026-04-14 06:49:31.362	2026-04-14 06:49:31.362
cmny9h65203zpvxy4xdpw66lz	cmny9h5xn03zhvxy46ymlfk87	cmny9fd6h0004vxy4evm3jgfv	750000	2026-04-14 06:49:31.478	2026-04-14 06:49:31.478
cmny9h67f03zrvxy4xpeqzjps	cmny9h5xn03zhvxy46ymlfk87	cmny9fd7u0006vxy4mh4wwui4	750000	2026-04-14 06:49:31.563	2026-04-14 06:49:31.563
cmny9h68l03ztvxy4s679t0qr	cmny9h5xn03zhvxy46ymlfk87	cmny9fd8i0007vxy4tmc0glr0	750000	2026-04-14 06:49:31.605	2026-04-14 06:49:31.605
cmny9h6bc03zvvxy4v441xr3c	cmny9h5xn03zhvxy46ymlfk87	cmny9fd980008vxy4alsawn4y	750000	2026-04-14 06:49:31.704	2026-04-14 06:49:31.704
cmny9h6df03zxvxy4j1fto0by	cmny9h5xn03zhvxy46ymlfk87	cmny9fd9w0009vxy498vvvu1d	750000	2026-04-14 06:49:31.779	2026-04-14 06:49:31.779
cmny9h6fb03zzvxy42awm4v9z	cmny9h5xn03zhvxy46ymlfk87	cmny9fdb9000bvxy4h02fexen	750000	2026-04-14 06:49:31.848	2026-04-14 06:49:31.848
cmny9h6i90401vxy4zsprghmk	cmny9h5xn03zhvxy46ymlfk87	cmny9fdc1000cvxy4n4y9ezu8	750000	2026-04-14 06:49:31.953	2026-04-14 06:49:31.953
cmny9h6l10403vxy4dea6n0iq	cmny9h5xn03zhvxy46ymlfk87	cmny9fdcn000dvxy4w3gaald5	750000	2026-04-14 06:49:32.053	2026-04-14 06:49:32.053
cmny9h6oi0406vxy4ph73tfar	cmny9h6n40404vxy469hagl5z	cmny9fd420001vxy42djthn1o	62000	2026-04-14 06:49:32.179	2026-04-14 06:49:32.179
cmny9h6rz0408vxy48roeyhdt	cmny9h6n40404vxy469hagl5z	cmny9fd4t0002vxy4jo0l7gop	62000	2026-04-14 06:49:32.303	2026-04-14 06:49:32.303
cmny9h6uz040avxy4monmflnd	cmny9h6n40404vxy469hagl5z	cmny9fd5j0003vxy4sw5e14p1	62000	2026-04-14 06:49:32.411	2026-04-14 06:49:32.411
cmny9h6x2040cvxy4xzijrbsb	cmny9h6n40404vxy469hagl5z	cmny9fd6h0004vxy4evm3jgfv	62000	2026-04-14 06:49:32.487	2026-04-14 06:49:32.487
cmny9h6yj040evxy4lg3831zo	cmny9h6n40404vxy469hagl5z	cmny9fd7u0006vxy4mh4wwui4	62000	2026-04-14 06:49:32.539	2026-04-14 06:49:32.539
cmny9h6zv040gvxy4zwy843s0	cmny9h6n40404vxy469hagl5z	cmny9fd8i0007vxy4tmc0glr0	62000	2026-04-14 06:49:32.587	2026-04-14 06:49:32.587
cmny9h71x040ivxy46qwwr11u	cmny9h6n40404vxy469hagl5z	cmny9fd980008vxy4alsawn4y	62000	2026-04-14 06:49:32.661	2026-04-14 06:49:32.661
cmny9h748040kvxy4c6gu64p1	cmny9h6n40404vxy469hagl5z	cmny9fd9w0009vxy498vvvu1d	62000	2026-04-14 06:49:32.745	2026-04-14 06:49:32.745
cmny9h75o040mvxy4kgeef3pw	cmny9h6n40404vxy469hagl5z	cmny9fdb9000bvxy4h02fexen	62000	2026-04-14 06:49:32.796	2026-04-14 06:49:32.796
cmny9h779040ovxy4jucyl27j	cmny9h6n40404vxy469hagl5z	cmny9fdc1000cvxy4n4y9ezu8	62000	2026-04-14 06:49:32.854	2026-04-14 06:49:32.854
cmny9h78v040qvxy4vcj2kqkp	cmny9h6n40404vxy469hagl5z	cmny9fdcn000dvxy4w3gaald5	62000	2026-04-14 06:49:32.912	2026-04-14 06:49:32.912
cmny9h7dh040tvxy4fb9tm1fx	cmny9h7aa040rvxy42kh0s52n	cmny9fd420001vxy42djthn1o	120000	2026-04-14 06:49:33.077	2026-04-14 06:49:33.077
cmny9h7ex040vvxy4uuxkhswf	cmny9h7aa040rvxy42kh0s52n	cmny9fd4t0002vxy4jo0l7gop	120000	2026-04-14 06:49:33.129	2026-04-14 06:49:33.129
cmny9h7g2040xvxy49f4xr8ak	cmny9h7aa040rvxy42kh0s52n	cmny9fd5j0003vxy4sw5e14p1	120000	2026-04-14 06:49:33.17	2026-04-14 06:49:33.17
cmny9h7j2040zvxy4g5a6mtws	cmny9h7aa040rvxy42kh0s52n	cmny9fd6h0004vxy4evm3jgfv	120000	2026-04-14 06:49:33.278	2026-04-14 06:49:33.278
cmny9h7l80411vxy48vlnahrx	cmny9h7aa040rvxy42kh0s52n	cmny9fd7u0006vxy4mh4wwui4	120000	2026-04-14 06:49:33.356	2026-04-14 06:49:33.356
cmny9h7mj0413vxy4tjxh9592	cmny9h7aa040rvxy42kh0s52n	cmny9fd8i0007vxy4tmc0glr0	120000	2026-04-14 06:49:33.403	2026-04-14 06:49:33.403
cmny9h7o50415vxy4rhii7hh2	cmny9h7aa040rvxy42kh0s52n	cmny9fd980008vxy4alsawn4y	120000	2026-04-14 06:49:33.462	2026-04-14 06:49:33.462
cmny9h7r00417vxy4gls3nlyd	cmny9h7aa040rvxy42kh0s52n	cmny9fd9w0009vxy498vvvu1d	120000	2026-04-14 06:49:33.564	2026-04-14 06:49:33.564
cmny9h7st0419vxy44bl0do1i	cmny9h7aa040rvxy42kh0s52n	cmny9fdb9000bvxy4h02fexen	120000	2026-04-14 06:49:33.629	2026-04-14 06:49:33.629
cmny9h7ty041bvxy4dtd1glbc	cmny9h7aa040rvxy42kh0s52n	cmny9fdc1000cvxy4n4y9ezu8	120000	2026-04-14 06:49:33.67	2026-04-14 06:49:33.67
cmny9h7vc041dvxy4lnatyf05	cmny9h7aa040rvxy42kh0s52n	cmny9fdcn000dvxy4w3gaald5	120000	2026-04-14 06:49:33.72	2026-04-14 06:49:33.72
cmny9h7z5041gvxy45x650boo	cmny9h7w0041evxy4fa4nplgz	cmny9fd980008vxy4alsawn4y	70000	2026-04-14 06:49:33.857	2026-04-14 06:49:33.857
cmny9h82p041jvxy4uha40yl0	cmny9h80s041hvxy4al5el0no	cmny9fd980008vxy4alsawn4y	87000	2026-04-14 06:49:33.985	2026-04-14 06:49:33.985
cmny9h86p041mvxy4b7139kzg	cmny9h84x041kvxy4ogrq35lg	cmny9fd420001vxy42djthn1o	59000	2026-04-14 06:49:34.129	2026-04-14 06:49:34.129
cmny9h88a041ovxy4lkxejxfr	cmny9h84x041kvxy4ogrq35lg	cmny9fd4t0002vxy4jo0l7gop	59000	2026-04-14 06:49:34.187	2026-04-14 06:49:34.187
cmny9h89y041qvxy4sca6dv1r	cmny9h84x041kvxy4ogrq35lg	cmny9fd5j0003vxy4sw5e14p1	59000	2026-04-14 06:49:34.246	2026-04-14 06:49:34.246
cmny9h8b9041svxy4c4rx108f	cmny9h84x041kvxy4ogrq35lg	cmny9fd6h0004vxy4evm3jgfv	59000	2026-04-14 06:49:34.294	2026-04-14 06:49:34.294
cmny9h8ed041uvxy4jm1wzza8	cmny9h84x041kvxy4ogrq35lg	cmny9fd7u0006vxy4mh4wwui4	59000	2026-04-14 06:49:34.405	2026-04-14 06:49:34.405
cmny9h8fh041wvxy4f3bun5ag	cmny9h84x041kvxy4ogrq35lg	cmny9fd8i0007vxy4tmc0glr0	59000	2026-04-14 06:49:34.446	2026-04-14 06:49:34.446
cmny9h8gn041yvxy4r1vcqdk1	cmny9h84x041kvxy4ogrq35lg	cmny9fd980008vxy4alsawn4y	59000	2026-04-14 06:49:34.487	2026-04-14 06:49:34.487
cmny9h8hs0420vxy4fq6tli50	cmny9h84x041kvxy4ogrq35lg	cmny9fd9w0009vxy498vvvu1d	59000	2026-04-14 06:49:34.528	2026-04-14 06:49:34.528
cmny9h8jy0422vxy4u1imv71s	cmny9h84x041kvxy4ogrq35lg	cmny9fdb9000bvxy4h02fexen	59000	2026-04-14 06:49:34.606	2026-04-14 06:49:34.606
cmny9h8l10424vxy48tkh16on	cmny9h84x041kvxy4ogrq35lg	cmny9fdc1000cvxy4n4y9ezu8	59000	2026-04-14 06:49:34.645	2026-04-14 06:49:34.645
cmny9h8mw0426vxy46aj78nma	cmny9h84x041kvxy4ogrq35lg	cmny9fdcn000dvxy4w3gaald5	59000	2026-04-14 06:49:34.713	2026-04-14 06:49:34.713
cmny9h8pw0429vxy439y6gh2q	cmny9h8oi0427vxy4lzl6s6c3	cmny9fd420001vxy42djthn1o	70000	2026-04-14 06:49:34.82	2026-04-14 06:49:34.82
cmny9h8qk042bvxy4gijmpt8i	cmny9h8oi0427vxy4lzl6s6c3	cmny9fd4t0002vxy4jo0l7gop	70000	2026-04-14 06:49:34.844	2026-04-14 06:49:34.844
cmny9h8ra042dvxy42b23qb7o	cmny9h8oi0427vxy4lzl6s6c3	cmny9fd5j0003vxy4sw5e14p1	70000	2026-04-14 06:49:34.871	2026-04-14 06:49:34.871
cmny9h8ry042fvxy40qz6iez8	cmny9h8oi0427vxy4lzl6s6c3	cmny9fd6h0004vxy4evm3jgfv	70000	2026-04-14 06:49:34.894	2026-04-14 06:49:34.894
cmny9h8sr042hvxy4t64y587h	cmny9h8oi0427vxy4lzl6s6c3	cmny9fd7u0006vxy4mh4wwui4	70000	2026-04-14 06:49:34.923	2026-04-14 06:49:34.923
cmny9h8u2042jvxy4wo60y6va	cmny9h8oi0427vxy4lzl6s6c3	cmny9fd8i0007vxy4tmc0glr0	70000	2026-04-14 06:49:34.97	2026-04-14 06:49:34.97
cmny9h8vg042lvxy4oj14fypx	cmny9h8oi0427vxy4lzl6s6c3	cmny9fd980008vxy4alsawn4y	70000	2026-04-14 06:49:35.02	2026-04-14 06:49:35.02
cmny9h8wu042nvxy47cjncv1x	cmny9h8oi0427vxy4lzl6s6c3	cmny9fd9w0009vxy498vvvu1d	70000	2026-04-14 06:49:35.07	2026-04-14 06:49:35.07
cmny9h8yh042pvxy4gz6ow9w0	cmny9h8oi0427vxy4lzl6s6c3	cmny9fdb9000bvxy4h02fexen	70000	2026-04-14 06:49:35.13	2026-04-14 06:49:35.13
cmny9h901042rvxy427s7f5vy	cmny9h8oi0427vxy4lzl6s6c3	cmny9fdc1000cvxy4n4y9ezu8	70000	2026-04-14 06:49:35.186	2026-04-14 06:49:35.186
cmny9h91f042tvxy4f61ivse4	cmny9h8oi0427vxy4lzl6s6c3	cmny9fdcn000dvxy4w3gaald5	70000	2026-04-14 06:49:35.235	2026-04-14 06:49:35.235
cmny9h93i042wvxy42xs3hh6u	cmny9h926042uvxy43u6dzp9o	cmny9fd420001vxy42djthn1o	26000	2026-04-14 06:49:35.31	2026-04-14 06:49:35.31
cmny9h94y042yvxy4uubg2b40	cmny9h926042uvxy43u6dzp9o	cmny9fd4t0002vxy4jo0l7gop	26000	2026-04-14 06:49:35.362	2026-04-14 06:49:35.362
cmny9h96k0430vxy44yinmueu	cmny9h926042uvxy43u6dzp9o	cmny9fd5j0003vxy4sw5e14p1	26000	2026-04-14 06:49:35.42	2026-04-14 06:49:35.42
cmny9h9850432vxy4deuhygv0	cmny9h926042uvxy43u6dzp9o	cmny9fd6h0004vxy4evm3jgfv	26000	2026-04-14 06:49:35.478	2026-04-14 06:49:35.478
cmny9h99t0434vxy4b9mzbztv	cmny9h926042uvxy43u6dzp9o	cmny9fd7u0006vxy4mh4wwui4	26000	2026-04-14 06:49:35.538	2026-04-14 06:49:35.538
cmny9h9ai0436vxy4s6hf3dlg	cmny9h926042uvxy43u6dzp9o	cmny9fd8i0007vxy4tmc0glr0	26000	2026-04-14 06:49:35.562	2026-04-14 06:49:35.562
cmny9h9b50438vxy4rpdeitp1	cmny9h926042uvxy43u6dzp9o	cmny9fd980008vxy4alsawn4y	26000	2026-04-14 06:49:35.585	2026-04-14 06:49:35.585
cmny9h9bw043avxy4lv7rk7rx	cmny9h926042uvxy43u6dzp9o	cmny9fd9w0009vxy498vvvu1d	26000	2026-04-14 06:49:35.612	2026-04-14 06:49:35.612
cmny9h9cm043cvxy4cpuypj9g	cmny9h926042uvxy43u6dzp9o	cmny9fdb9000bvxy4h02fexen	26000	2026-04-14 06:49:35.638	2026-04-14 06:49:35.638
cmny9h9da043evxy4jktp0r4m	cmny9h926042uvxy43u6dzp9o	cmny9fdc1000cvxy4n4y9ezu8	26000	2026-04-14 06:49:35.662	2026-04-14 06:49:35.662
cmny9h9dy043gvxy458pld1vh	cmny9h926042uvxy43u6dzp9o	cmny9fdcn000dvxy4w3gaald5	26000	2026-04-14 06:49:35.686	2026-04-14 06:49:35.686
cmny9ha4c043jvxy45ked47vu	cmny9ha0u043hvxy4biq8zww0	cmny9fd420001vxy42djthn1o	500000	2026-04-14 06:49:36.637	2026-04-14 06:49:36.637
cmny9ha5p043lvxy43jmar8ae	cmny9ha0u043hvxy4biq8zww0	cmny9fd4t0002vxy4jo0l7gop	500000	2026-04-14 06:49:36.685	2026-04-14 06:49:36.685
cmny9ha6o043nvxy4x0qoadd6	cmny9ha0u043hvxy4biq8zww0	cmny9fd5j0003vxy4sw5e14p1	500000	2026-04-14 06:49:36.721	2026-04-14 06:49:36.721
cmny9ha7s043pvxy4fvofsp23	cmny9ha0u043hvxy4biq8zww0	cmny9fd6h0004vxy4evm3jgfv	500000	2026-04-14 06:49:36.761	2026-04-14 06:49:36.761
cmny9ha8t043rvxy4xzgww7y8	cmny9ha0u043hvxy4biq8zww0	cmny9fd7u0006vxy4mh4wwui4	500000	2026-04-14 06:49:36.797	2026-04-14 06:49:36.797
cmny9ha9x043tvxy40mkt2mb5	cmny9ha0u043hvxy4biq8zww0	cmny9fd8i0007vxy4tmc0glr0	500000	2026-04-14 06:49:36.837	2026-04-14 06:49:36.837
cmny9habb043vvxy4ap73mamn	cmny9ha0u043hvxy4biq8zww0	cmny9fd980008vxy4alsawn4y	500000	2026-04-14 06:49:36.887	2026-04-14 06:49:36.887
cmny9hacf043xvxy4b3d38xwd	cmny9ha0u043hvxy4biq8zww0	cmny9fd9w0009vxy498vvvu1d	500000	2026-04-14 06:49:36.927	2026-04-14 06:49:36.927
cmny9hadg043zvxy4r1kxq2ky	cmny9ha0u043hvxy4biq8zww0	cmny9fdb9000bvxy4h02fexen	500000	2026-04-14 06:49:36.964	2026-04-14 06:49:36.964
cmny9haei0441vxy40stfnigf	cmny9ha0u043hvxy4biq8zww0	cmny9fdc1000cvxy4n4y9ezu8	500000	2026-04-14 06:49:37.002	2026-04-14 06:49:37.002
cmny9hafh0443vxy4wbgx086a	cmny9ha0u043hvxy4biq8zww0	cmny9fdcn000dvxy4w3gaald5	500000	2026-04-14 06:49:37.037	2026-04-14 06:49:37.037
cmny9haht0446vxy4l1wzk617	cmny9hagl0444vxy40m9hvfrt	cmny9fd420001vxy42djthn1o	55000	2026-04-14 06:49:37.12	2026-04-14 06:49:37.12
cmny9haj50448vxy4ecu01vq2	cmny9hagl0444vxy40m9hvfrt	cmny9fd4t0002vxy4jo0l7gop	55000	2026-04-14 06:49:37.169	2026-04-14 06:49:37.169
cmny9hak3044avxy40vriwi5h	cmny9hagl0444vxy40m9hvfrt	cmny9fd5j0003vxy4sw5e14p1	55000	2026-04-14 06:49:37.204	2026-04-14 06:49:37.204
cmny9hal0044cvxy4g1gzoqqf	cmny9hagl0444vxy40m9hvfrt	cmny9fd6h0004vxy4evm3jgfv	55000	2026-04-14 06:49:37.236	2026-04-14 06:49:37.236
cmny9ham8044evxy4d1ra6uwu	cmny9hagl0444vxy40m9hvfrt	cmny9fd7u0006vxy4mh4wwui4	55000	2026-04-14 06:49:37.28	2026-04-14 06:49:37.28
cmny9hant044gvxy4tuolnl5h	cmny9hagl0444vxy40m9hvfrt	cmny9fd8i0007vxy4tmc0glr0	55000	2026-04-14 06:49:37.338	2026-04-14 06:49:37.338
cmny9hap7044ivxy4939m7iih	cmny9hagl0444vxy40m9hvfrt	cmny9fd980008vxy4alsawn4y	55000	2026-04-14 06:49:37.387	2026-04-14 06:49:37.387
cmny9haqt044kvxy4oj7qnbvn	cmny9hagl0444vxy40m9hvfrt	cmny9fd9w0009vxy498vvvu1d	55000	2026-04-14 06:49:37.445	2026-04-14 06:49:37.445
cmny9hash044mvxy4999rbf5z	cmny9hagl0444vxy40m9hvfrt	cmny9fdb9000bvxy4h02fexen	55000	2026-04-14 06:49:37.505	2026-04-14 06:49:37.505
cmny9hau0044ovxy4hjg99x6y	cmny9hagl0444vxy40m9hvfrt	cmny9fdc1000cvxy4n4y9ezu8	55000	2026-04-14 06:49:37.56	2026-04-14 06:49:37.56
cmny9hav7044qvxy471yb5p06	cmny9hagl0444vxy40m9hvfrt	cmny9fdcn000dvxy4w3gaald5	55000	2026-04-14 06:49:37.604	2026-04-14 06:49:37.604
cmny9hayp044tvxy4flobha25	cmny9hawk044rvxy4h7bra21r	cmny9fd420001vxy42djthn1o	35000	2026-04-14 06:49:37.729	2026-04-14 06:49:37.729
cmny9hb19044vvxy47wi57l73	cmny9hawk044rvxy4h7bra21r	cmny9fd4t0002vxy4jo0l7gop	35000	2026-04-14 06:49:37.822	2026-04-14 06:49:37.822
cmny9hb3l044xvxy4afqa1pet	cmny9hawk044rvxy4h7bra21r	cmny9fd5j0003vxy4sw5e14p1	35000	2026-04-14 06:49:37.906	2026-04-14 06:49:37.906
cmny9hb4v044zvxy46sast7wr	cmny9hawk044rvxy4h7bra21r	cmny9fd6h0004vxy4evm3jgfv	35000	2026-04-14 06:49:37.951	2026-04-14 06:49:37.951
cmny9hb5w0451vxy4uqeka7e9	cmny9hawk044rvxy4h7bra21r	cmny9fd7u0006vxy4mh4wwui4	35000	2026-04-14 06:49:37.988	2026-04-14 06:49:37.988
cmny9hb7g0453vxy4w722a38m	cmny9hawk044rvxy4h7bra21r	cmny9fd8i0007vxy4tmc0glr0	35000	2026-04-14 06:49:38.044	2026-04-14 06:49:38.044
cmny9hb8w0455vxy4m0ii1c6r	cmny9hawk044rvxy4h7bra21r	cmny9fd980008vxy4alsawn4y	35000	2026-04-14 06:49:38.097	2026-04-14 06:49:38.097
cmny9hbar0457vxy4y56tc2ie	cmny9hawk044rvxy4h7bra21r	cmny9fd9w0009vxy498vvvu1d	35000	2026-04-14 06:49:38.163	2026-04-14 06:49:38.163
cmny9hbcu0459vxy4n4rgwtc7	cmny9hawk044rvxy4h7bra21r	cmny9fdb9000bvxy4h02fexen	35000	2026-04-14 06:49:38.238	2026-04-14 06:49:38.238
cmny9hbf4045bvxy4hukuuixx	cmny9hawk044rvxy4h7bra21r	cmny9fdc1000cvxy4n4y9ezu8	35000	2026-04-14 06:49:38.32	2026-04-14 06:49:38.32
cmny9hbga045dvxy4gpxmwf8r	cmny9hawk044rvxy4h7bra21r	cmny9fdcn000dvxy4w3gaald5	35000	2026-04-14 06:49:38.362	2026-04-14 06:49:38.362
cmny9hbhv045gvxy41biyu40r	cmny9hbh7045evxy4qbbtqq1x	cmny9fd420001vxy42djthn1o	39000	2026-04-14 06:49:38.419	2026-04-14 06:49:38.419
cmny9hbil045ivxy4bzbdb6ax	cmny9hbh7045evxy4qbbtqq1x	cmny9fd4t0002vxy4jo0l7gop	39000	2026-04-14 06:49:38.445	2026-04-14 06:49:38.445
cmny9hbj9045kvxy4os4hz1rt	cmny9hbh7045evxy4qbbtqq1x	cmny9fd5j0003vxy4sw5e14p1	39000	2026-04-14 06:49:38.469	2026-04-14 06:49:38.469
cmny9hbjz045mvxy4ayytltxw	cmny9hbh7045evxy4qbbtqq1x	cmny9fd6h0004vxy4evm3jgfv	39000	2026-04-14 06:49:38.495	2026-04-14 06:49:38.495
cmny9hbko045ovxy43qkarob8	cmny9hbh7045evxy4qbbtqq1x	cmny9fd7u0006vxy4mh4wwui4	39000	2026-04-14 06:49:38.521	2026-04-14 06:49:38.521
cmny9hbld045qvxy4e8gbsa1a	cmny9hbh7045evxy4qbbtqq1x	cmny9fd8i0007vxy4tmc0glr0	39000	2026-04-14 06:49:38.545	2026-04-14 06:49:38.545
cmny9hbm1045svxy4piv9zyxq	cmny9hbh7045evxy4qbbtqq1x	cmny9fd980008vxy4alsawn4y	39000	2026-04-14 06:49:38.569	2026-04-14 06:49:38.569
cmny9hbno045uvxy46bfxbspu	cmny9hbh7045evxy4qbbtqq1x	cmny9fd9w0009vxy498vvvu1d	39000	2026-04-14 06:49:38.628	2026-04-14 06:49:38.628
cmny9hbou045wvxy49bgjppf1	cmny9hbh7045evxy4qbbtqq1x	cmny9fdb9000bvxy4h02fexen	39000	2026-04-14 06:49:38.67	2026-04-14 06:49:38.67
cmny9hbq0045yvxy465d21bgz	cmny9hbh7045evxy4qbbtqq1x	cmny9fdc1000cvxy4n4y9ezu8	39000	2026-04-14 06:49:38.712	2026-04-14 06:49:38.712
cmny9hbrc0460vxy4b898d0eo	cmny9hbh7045evxy4qbbtqq1x	cmny9fdcn000dvxy4w3gaald5	39000	2026-04-14 06:49:38.76	2026-04-14 06:49:38.76
cmny9hbsq0463vxy4zfu2tpi7	cmny9hbs20461vxy40qacr9vy	cmny9fd420001vxy42djthn1o	50000	2026-04-14 06:49:38.81	2026-04-14 06:49:38.81
cmny9hbtg0465vxy417twzkc7	cmny9hbs20461vxy40qacr9vy	cmny9fd4t0002vxy4jo0l7gop	50000	2026-04-14 06:49:38.837	2026-04-14 06:49:38.837
cmny9hbu40467vxy47ttzvzf8	cmny9hbs20461vxy40qacr9vy	cmny9fd5j0003vxy4sw5e14p1	50000	2026-04-14 06:49:38.86	2026-04-14 06:49:38.86
cmny9hbuu0469vxy48jaf6d4q	cmny9hbs20461vxy40qacr9vy	cmny9fd6h0004vxy4evm3jgfv	50000	2026-04-14 06:49:38.887	2026-04-14 06:49:38.887
cmny9hbvj046bvxy4366q2ggg	cmny9hbs20461vxy40qacr9vy	cmny9fd7u0006vxy4mh4wwui4	50000	2026-04-14 06:49:38.911	2026-04-14 06:49:38.911
cmny9hbw8046dvxy4mlvzem6c	cmny9hbs20461vxy40qacr9vy	cmny9fd8i0007vxy4tmc0glr0	50000	2026-04-14 06:49:38.937	2026-04-14 06:49:38.937
cmny9hbww046fvxy48n6p1t4s	cmny9hbs20461vxy40qacr9vy	cmny9fd980008vxy4alsawn4y	50000	2026-04-14 06:49:38.961	2026-04-14 06:49:38.961
cmny9hbxm046hvxy4eoamtciy	cmny9hbs20461vxy40qacr9vy	cmny9fd9w0009vxy498vvvu1d	50000	2026-04-14 06:49:38.987	2026-04-14 06:49:38.987
cmny9hbyb046jvxy4ef4lj9w7	cmny9hbs20461vxy40qacr9vy	cmny9fdb9000bvxy4h02fexen	50000	2026-04-14 06:49:39.011	2026-04-14 06:49:39.011
cmny9hbz0046lvxy4fg6nida2	cmny9hbs20461vxy40qacr9vy	cmny9fdc1000cvxy4n4y9ezu8	50000	2026-04-14 06:49:39.037	2026-04-14 06:49:39.037
cmny9hbzo046nvxy4f1pi4pwm	cmny9hbs20461vxy40qacr9vy	cmny9fdcn000dvxy4w3gaald5	50000	2026-04-14 06:49:39.06	2026-04-14 06:49:39.06
cmny9hc12046qvxy4b4n1cnnr	cmny9hc0e046ovxy4ogexfwka	cmny9fd420001vxy42djthn1o	38000	2026-04-14 06:49:39.11	2026-04-14 06:49:39.11
cmny9hc1t046svxy4abb10n5d	cmny9hc0e046ovxy4ogexfwka	cmny9fd4t0002vxy4jo0l7gop	38000	2026-04-14 06:49:39.137	2026-04-14 06:49:39.137
cmny9hc2f046uvxy4lw55ho3m	cmny9hc0e046ovxy4ogexfwka	cmny9fd5j0003vxy4sw5e14p1	38000	2026-04-14 06:49:39.16	2026-04-14 06:49:39.16
cmny9hc37046wvxy44cy411gv	cmny9hc0e046ovxy4ogexfwka	cmny9fd6h0004vxy4evm3jgfv	38000	2026-04-14 06:49:39.187	2026-04-14 06:49:39.187
cmny9hc3v046yvxy4doq1ouow	cmny9hc0e046ovxy4ogexfwka	cmny9fd7u0006vxy4mh4wwui4	38000	2026-04-14 06:49:39.211	2026-04-14 06:49:39.211
cmny9hc4l0470vxy4b2pa2vtn	cmny9hc0e046ovxy4ogexfwka	cmny9fd8i0007vxy4tmc0glr0	38000	2026-04-14 06:49:39.237	2026-04-14 06:49:39.237
cmny9hc680472vxy43pdor2qv	cmny9hc0e046ovxy4ogexfwka	cmny9fd980008vxy4alsawn4y	38000	2026-04-14 06:49:39.296	2026-04-14 06:49:39.296
cmny9hc7m0474vxy4ooaztj5i	cmny9hc0e046ovxy4ogexfwka	cmny9fd9w0009vxy498vvvu1d	38000	2026-04-14 06:49:39.346	2026-04-14 06:49:39.346
cmny9hc8s0476vxy4wi6wppfo	cmny9hc0e046ovxy4ogexfwka	cmny9fdb9000bvxy4h02fexen	38000	2026-04-14 06:49:39.388	2026-04-14 06:49:39.388
cmny9hc9p0478vxy4mxxpr0te	cmny9hc0e046ovxy4ogexfwka	cmny9fdc1000cvxy4n4y9ezu8	38000	2026-04-14 06:49:39.421	2026-04-14 06:49:39.421
cmny9hcb1047avxy4bo4ealpu	cmny9hc0e046ovxy4ogexfwka	cmny9fdcn000dvxy4w3gaald5	38000	2026-04-14 06:49:39.469	2026-04-14 06:49:39.469
cmny9hcds047dvxy47gyso77h	cmny9hcc7047bvxy4yltr6q4y	cmny9fd420001vxy42djthn1o	74000	2026-04-14 06:49:39.568	2026-04-14 06:49:39.568
cmny9hcer047fvxy44ryh39zr	cmny9hcc7047bvxy4yltr6q4y	cmny9fd4t0002vxy4jo0l7gop	74000	2026-04-14 06:49:39.604	2026-04-14 06:49:39.604
cmny9hcfv047hvxy45ncwtpma	cmny9hcc7047bvxy4yltr6q4y	cmny9fd5j0003vxy4sw5e14p1	74000	2026-04-14 06:49:39.644	2026-04-14 06:49:39.644
cmny9hcgv047jvxy4j0lnky6o	cmny9hcc7047bvxy4yltr6q4y	cmny9fd6h0004vxy4evm3jgfv	74000	2026-04-14 06:49:39.679	2026-04-14 06:49:39.679
cmny9hciz047lvxy4xmvxepdq	cmny9hcc7047bvxy4yltr6q4y	cmny9fd7u0006vxy4mh4wwui4	74000	2026-04-14 06:49:39.755	2026-04-14 06:49:39.755
cmny9hcl9047nvxy453altvkp	cmny9hcc7047bvxy4yltr6q4y	cmny9fd8i0007vxy4tmc0glr0	74000	2026-04-14 06:49:39.837	2026-04-14 06:49:39.837
cmny9hcmu047pvxy4sxichxs2	cmny9hcc7047bvxy4yltr6q4y	cmny9fd980008vxy4alsawn4y	74000	2026-04-14 06:49:39.894	2026-04-14 06:49:39.894
cmny9hco1047rvxy4zh846mc6	cmny9hcc7047bvxy4yltr6q4y	cmny9fd9w0009vxy498vvvu1d	74000	2026-04-14 06:49:39.937	2026-04-14 06:49:39.937
cmny9hcp8047tvxy420wdshmc	cmny9hcc7047bvxy4yltr6q4y	cmny9fdb9000bvxy4h02fexen	74000	2026-04-14 06:49:39.98	2026-04-14 06:49:39.98
cmny9hcra047vvxy4gt4fgetu	cmny9hcc7047bvxy4yltr6q4y	cmny9fdc1000cvxy4n4y9ezu8	74000	2026-04-14 06:49:40.055	2026-04-14 06:49:40.055
cmny9hcsl047xvxy49oolojz0	cmny9hcc7047bvxy4yltr6q4y	cmny9fdcn000dvxy4w3gaald5	74000	2026-04-14 06:49:40.101	2026-04-14 06:49:40.101
cmny9hcux0480vxy453xwg3v8	cmny9hctl047yvxy4h9dvg2at	cmny9fd420001vxy42djthn1o	40000	2026-04-14 06:49:40.185	2026-04-14 06:49:40.185
cmny9hcw40482vxy4h84un1vk	cmny9hctl047yvxy4h9dvg2at	cmny9fd4t0002vxy4jo0l7gop	40000	2026-04-14 06:49:40.228	2026-04-14 06:49:40.228
cmny9hcxp0484vxy4nyb2lfrb	cmny9hctl047yvxy4h9dvg2at	cmny9fd5j0003vxy4sw5e14p1	40000	2026-04-14 06:49:40.285	2026-04-14 06:49:40.285
cmny9hczd0486vxy48ntw1eju	cmny9hctl047yvxy4h9dvg2at	cmny9fd6h0004vxy4evm3jgfv	40000	2026-04-14 06:49:40.345	2026-04-14 06:49:40.345
cmny9hd0i0488vxy42ofgrm43	cmny9hctl047yvxy4h9dvg2at	cmny9fd7u0006vxy4mh4wwui4	40000	2026-04-14 06:49:40.387	2026-04-14 06:49:40.387
cmny9hd1g048avxy4ockgq5qs	cmny9hctl047yvxy4h9dvg2at	cmny9fd8i0007vxy4tmc0glr0	40000	2026-04-14 06:49:40.42	2026-04-14 06:49:40.42
cmny9hd23048cvxy48rwdlea2	cmny9hctl047yvxy4h9dvg2at	cmny9fd980008vxy4alsawn4y	40000	2026-04-14 06:49:40.443	2026-04-14 06:49:40.443
cmny9hd2t048evxy4n0bhovjw	cmny9hctl047yvxy4h9dvg2at	cmny9fd9w0009vxy498vvvu1d	40000	2026-04-14 06:49:40.47	2026-04-14 06:49:40.47
cmny9hd3i048gvxy40xrfd7hd	cmny9hctl047yvxy4h9dvg2at	cmny9fdb9000bvxy4h02fexen	40000	2026-04-14 06:49:40.495	2026-04-14 06:49:40.495
cmny9hd48048ivxy4jcj3gob6	cmny9hctl047yvxy4h9dvg2at	cmny9fdc1000cvxy4n4y9ezu8	40000	2026-04-14 06:49:40.52	2026-04-14 06:49:40.52
cmny9hd4v048kvxy4azw99xn9	cmny9hctl047yvxy4h9dvg2at	cmny9fdcn000dvxy4w3gaald5	40000	2026-04-14 06:49:40.543	2026-04-14 06:49:40.543
cmny9hd69048nvxy4z7979qis	cmny9hd5m048lvxy49egji9jw	cmny9fd420001vxy42djthn1o	50000	2026-04-14 06:49:40.593	2026-04-14 06:49:40.593
cmny9hd70048pvxy4s6biuety	cmny9hd5m048lvxy49egji9jw	cmny9fd4t0002vxy4jo0l7gop	50000	2026-04-14 06:49:40.62	2026-04-14 06:49:40.62
cmny9hd7n048rvxy4ah4m5nqe	cmny9hd5m048lvxy49egji9jw	cmny9fd5j0003vxy4sw5e14p1	50000	2026-04-14 06:49:40.643	2026-04-14 06:49:40.643
cmny9hd8e048tvxy4lwim66xv	cmny9hd5m048lvxy49egji9jw	cmny9fd6h0004vxy4evm3jgfv	50000	2026-04-14 06:49:40.67	2026-04-14 06:49:40.67
cmny9hd92048vvxy4sjgvejg8	cmny9hd5m048lvxy49egji9jw	cmny9fd7u0006vxy4mh4wwui4	50000	2026-04-14 06:49:40.694	2026-04-14 06:49:40.694
cmny9hd9s048xvxy4zx3y93r9	cmny9hd5m048lvxy49egji9jw	cmny9fd8i0007vxy4tmc0glr0	50000	2026-04-14 06:49:40.72	2026-04-14 06:49:40.72
cmny9hdaf048zvxy4lmvjnkzz	cmny9hd5m048lvxy49egji9jw	cmny9fd980008vxy4alsawn4y	50000	2026-04-14 06:49:40.743	2026-04-14 06:49:40.743
cmny9hdb60491vxy4y3lodsk7	cmny9hd5m048lvxy49egji9jw	cmny9fd9w0009vxy498vvvu1d	50000	2026-04-14 06:49:40.77	2026-04-14 06:49:40.77
cmny9hdbv0493vxy45j4378ax	cmny9hd5m048lvxy49egji9jw	cmny9fdb9000bvxy4h02fexen	50000	2026-04-14 06:49:40.795	2026-04-14 06:49:40.795
cmny9hdck0495vxy4bh5wew8r	cmny9hd5m048lvxy49egji9jw	cmny9fdc1000cvxy4n4y9ezu8	50000	2026-04-14 06:49:40.82	2026-04-14 06:49:40.82
cmny9hdd80497vxy4z3ixx28d	cmny9hd5m048lvxy49egji9jw	cmny9fdcn000dvxy4w3gaald5	50000	2026-04-14 06:49:40.844	2026-04-14 06:49:40.844
cmny9hden049avxy4gsw5n4v3	cmny9hddz0498vxy4ls4h37y5	cmny9fd420001vxy42djthn1o	65000	2026-04-14 06:49:40.895	2026-04-14 06:49:40.895
cmny9hdfc049cvxy41nht943y	cmny9hddz0498vxy4ls4h37y5	cmny9fd4t0002vxy4jo0l7gop	65000	2026-04-14 06:49:40.921	2026-04-14 06:49:40.921
cmny9hdg0049evxy4gmh4gqct	cmny9hddz0498vxy4ls4h37y5	cmny9fd5j0003vxy4sw5e14p1	65000	2026-04-14 06:49:40.944	2026-04-14 06:49:40.944
cmny9hdh0049gvxy4iutds6id	cmny9hddz0498vxy4ls4h37y5	cmny9fd6h0004vxy4evm3jgfv	65000	2026-04-14 06:49:40.98	2026-04-14 06:49:40.98
cmny9hdi8049ivxy4zdb52se2	cmny9hddz0498vxy4ls4h37y5	cmny9fd7u0006vxy4mh4wwui4	65000	2026-04-14 06:49:41.024	2026-04-14 06:49:41.024
cmny9hdj3049kvxy44j2aj0ed	cmny9hddz0498vxy4ls4h37y5	cmny9fd8i0007vxy4tmc0glr0	65000	2026-04-14 06:49:41.055	2026-04-14 06:49:41.055
cmny9hdk0049mvxy4dlt1zddc	cmny9hddz0498vxy4ls4h37y5	cmny9fd980008vxy4alsawn4y	65000	2026-04-14 06:49:41.088	2026-04-14 06:49:41.088
cmny9hdkx049ovxy4yt5dr36j	cmny9hddz0498vxy4ls4h37y5	cmny9fd9w0009vxy498vvvu1d	65000	2026-04-14 06:49:41.121	2026-04-14 06:49:41.121
cmny9hdlu049qvxy4knrn8jp9	cmny9hddz0498vxy4ls4h37y5	cmny9fdb9000bvxy4h02fexen	65000	2026-04-14 06:49:41.154	2026-04-14 06:49:41.154
cmny9hdmj049svxy4ewtrsb0o	cmny9hddz0498vxy4ls4h37y5	cmny9fdc1000cvxy4n4y9ezu8	65000	2026-04-14 06:49:41.179	2026-04-14 06:49:41.179
cmny9hdn6049uvxy4mmx4722f	cmny9hddz0498vxy4ls4h37y5	cmny9fdcn000dvxy4w3gaald5	65000	2026-04-14 06:49:41.202	2026-04-14 06:49:41.202
cmny9hdok049xvxy4eqhrf2ra	cmny9hdnw049vvxy4olznmp3x	cmny9fd420001vxy42djthn1o	65000	2026-04-14 06:49:41.252	2026-04-14 06:49:41.252
cmny9hdpa049zvxy4648vslwp	cmny9hdnw049vvxy4olznmp3x	cmny9fd4t0002vxy4jo0l7gop	65000	2026-04-14 06:49:41.279	2026-04-14 06:49:41.279
cmny9hdpy04a1vxy4ysfl6ar4	cmny9hdnw049vvxy4olznmp3x	cmny9fd5j0003vxy4sw5e14p1	65000	2026-04-14 06:49:41.302	2026-04-14 06:49:41.302
cmny9hdqo04a3vxy42y1sctsr	cmny9hdnw049vvxy4olznmp3x	cmny9fd6h0004vxy4evm3jgfv	65000	2026-04-14 06:49:41.329	2026-04-14 06:49:41.329
cmny9hdre04a5vxy4821j8u6h	cmny9hdnw049vvxy4olznmp3x	cmny9fd7u0006vxy4mh4wwui4	65000	2026-04-14 06:49:41.354	2026-04-14 06:49:41.354
cmny9hds204a7vxy4j5121fuv	cmny9hdnw049vvxy4olznmp3x	cmny9fd8i0007vxy4tmc0glr0	65000	2026-04-14 06:49:41.378	2026-04-14 06:49:41.378
cmny9hdsq04a9vxy4zh6uuutg	cmny9hdnw049vvxy4olznmp3x	cmny9fd980008vxy4alsawn4y	65000	2026-04-14 06:49:41.402	2026-04-14 06:49:41.402
cmny9hdtg04abvxy4xr1nxq68	cmny9hdnw049vvxy4olznmp3x	cmny9fd9w0009vxy498vvvu1d	65000	2026-04-14 06:49:41.429	2026-04-14 06:49:41.429
cmny9hdu604advxy4jsrmy8hb	cmny9hdnw049vvxy4olznmp3x	cmny9fdb9000bvxy4h02fexen	65000	2026-04-14 06:49:41.454	2026-04-14 06:49:41.454
cmny9hduv04afvxy4qbh159ao	cmny9hdnw049vvxy4olznmp3x	cmny9fdc1000cvxy4n4y9ezu8	65000	2026-04-14 06:49:41.479	2026-04-14 06:49:41.479
cmny9hdvj04ahvxy42br2hsrx	cmny9hdnw049vvxy4olznmp3x	cmny9fdcn000dvxy4w3gaald5	65000	2026-04-14 06:49:41.503	2026-04-14 06:49:41.503
cmny9hdww04akvxy41ej77l9b	cmny9hdw904aivxy4uhxowmka	cmny9fd420001vxy42djthn1o	200000	2026-04-14 06:49:41.552	2026-04-14 06:49:41.552
cmny9hdxm04amvxy4rj8t9wqq	cmny9hdw904aivxy4uhxowmka	cmny9fd4t0002vxy4jo0l7gop	200000	2026-04-14 06:49:41.578	2026-04-14 06:49:41.578
cmny9hdya04aovxy4mvak48az	cmny9hdw904aivxy4uhxowmka	cmny9fd5j0003vxy4sw5e14p1	200000	2026-04-14 06:49:41.602	2026-04-14 06:49:41.602
cmny9hdz004aqvxy45zj84zrd	cmny9hdw904aivxy4uhxowmka	cmny9fd6h0004vxy4evm3jgfv	200000	2026-04-14 06:49:41.628	2026-04-14 06:49:41.628
cmny9hdzq04asvxy4aqnhxlnj	cmny9hdw904aivxy4uhxowmka	cmny9fd7u0006vxy4mh4wwui4	200000	2026-04-14 06:49:41.654	2026-04-14 06:49:41.654
cmny9he0f04auvxy4ne6wlozq	cmny9hdw904aivxy4uhxowmka	cmny9fd8i0007vxy4tmc0glr0	200000	2026-04-14 06:49:41.679	2026-04-14 06:49:41.679
cmny9he1104awvxy4tpivq34f	cmny9hdw904aivxy4uhxowmka	cmny9fd980008vxy4alsawn4y	200000	2026-04-14 06:49:41.702	2026-04-14 06:49:41.702
cmny9he1t04ayvxy4009yrqqn	cmny9hdw904aivxy4uhxowmka	cmny9fd9w0009vxy498vvvu1d	200000	2026-04-14 06:49:41.729	2026-04-14 06:49:41.729
cmny9he2h04b0vxy46iomafrv	cmny9hdw904aivxy4uhxowmka	cmny9fdb9000bvxy4h02fexen	200000	2026-04-14 06:49:41.754	2026-04-14 06:49:41.754
cmny9he3704b2vxy4gj94zjw1	cmny9hdw904aivxy4uhxowmka	cmny9fdc1000cvxy4n4y9ezu8	200000	2026-04-14 06:49:41.779	2026-04-14 06:49:41.779
cmny9he3u04b4vxy4d1flwoba	cmny9hdw904aivxy4uhxowmka	cmny9fdcn000dvxy4w3gaald5	200000	2026-04-14 06:49:41.802	2026-04-14 06:49:41.802
cmny9he5804b7vxy464aakih7	cmny9he4k04b5vxy4lwgayqmk	cmny9fd420001vxy42djthn1o	59000	2026-04-14 06:49:41.852	2026-04-14 06:49:41.852
cmny9he5y04b9vxy4b5annwgf	cmny9he4k04b5vxy4lwgayqmk	cmny9fd4t0002vxy4jo0l7gop	59000	2026-04-14 06:49:41.879	2026-04-14 06:49:41.879
cmny9he6m04bbvxy43qjidjcw	cmny9he4k04b5vxy4lwgayqmk	cmny9fd5j0003vxy4sw5e14p1	59000	2026-04-14 06:49:41.902	2026-04-14 06:49:41.902
cmny9he7c04bdvxy4v712w2mu	cmny9he4k04b5vxy4lwgayqmk	cmny9fd6h0004vxy4evm3jgfv	59000	2026-04-14 06:49:41.929	2026-04-14 06:49:41.929
cmny9he8204bfvxy47b6733ld	cmny9he4k04b5vxy4lwgayqmk	cmny9fd7u0006vxy4mh4wwui4	59000	2026-04-14 06:49:41.954	2026-04-14 06:49:41.954
cmny9he8q04bhvxy4ii69oe36	cmny9he4k04b5vxy4lwgayqmk	cmny9fd8i0007vxy4tmc0glr0	59000	2026-04-14 06:49:41.979	2026-04-14 06:49:41.979
cmny9he9e04bjvxy42f4hn5jq	cmny9he4k04b5vxy4lwgayqmk	cmny9fd980008vxy4alsawn4y	59000	2026-04-14 06:49:42.002	2026-04-14 06:49:42.002
cmny9hea404blvxy4y8q5vj4b	cmny9he4k04b5vxy4lwgayqmk	cmny9fd9w0009vxy498vvvu1d	59000	2026-04-14 06:49:42.029	2026-04-14 06:49:42.029
cmny9heau04bnvxy4r4l1t1w6	cmny9he4k04b5vxy4lwgayqmk	cmny9fdb9000bvxy4h02fexen	59000	2026-04-14 06:49:42.054	2026-04-14 06:49:42.054
cmny9hebj04bpvxy4qc5arhny	cmny9he4k04b5vxy4lwgayqmk	cmny9fdc1000cvxy4n4y9ezu8	59000	2026-04-14 06:49:42.079	2026-04-14 06:49:42.079
cmny9hec604brvxy4yqrb1td7	cmny9he4k04b5vxy4lwgayqmk	cmny9fdcn000dvxy4w3gaald5	59000	2026-04-14 06:49:42.102	2026-04-14 06:49:42.102
cmny9hedk04buvxy43qbuxcnp	cmny9hecx04bsvxy43o6ia3fl	cmny9fd420001vxy42djthn1o	59000	2026-04-14 06:49:42.152	2026-04-14 06:49:42.152
cmny9heea04bwvxy45vfs12v3	cmny9hecx04bsvxy43o6ia3fl	cmny9fd4t0002vxy4jo0l7gop	59000	2026-04-14 06:49:42.179	2026-04-14 06:49:42.179
cmny9heey04byvxy4n2f5e9mg	cmny9hecx04bsvxy43o6ia3fl	cmny9fd5j0003vxy4sw5e14p1	59000	2026-04-14 06:49:42.202	2026-04-14 06:49:42.202
cmny9hefp04c0vxy4dzchj233	cmny9hecx04bsvxy43o6ia3fl	cmny9fd6h0004vxy4evm3jgfv	59000	2026-04-14 06:49:42.229	2026-04-14 06:49:42.229
cmny9hegf04c2vxy45oubat9o	cmny9hecx04bsvxy43o6ia3fl	cmny9fd7u0006vxy4mh4wwui4	59000	2026-04-14 06:49:42.255	2026-04-14 06:49:42.255
cmny9heh304c4vxy4k8vhxf4m	cmny9hecx04bsvxy43o6ia3fl	cmny9fd8i0007vxy4tmc0glr0	59000	2026-04-14 06:49:42.279	2026-04-14 06:49:42.279
cmny9hehq04c6vxy4tsxv965j	cmny9hecx04bsvxy43o6ia3fl	cmny9fd980008vxy4alsawn4y	59000	2026-04-14 06:49:42.302	2026-04-14 06:49:42.302
cmny9heig04c8vxy45fud3syf	cmny9hecx04bsvxy43o6ia3fl	cmny9fd9w0009vxy498vvvu1d	59000	2026-04-14 06:49:42.329	2026-04-14 06:49:42.329
cmny9hej504cavxy4hjkhc68b	cmny9hecx04bsvxy43o6ia3fl	cmny9fdb9000bvxy4h02fexen	59000	2026-04-14 06:49:42.354	2026-04-14 06:49:42.354
cmny9hejv04ccvxy41zcb1c7i	cmny9hecx04bsvxy43o6ia3fl	cmny9fdc1000cvxy4n4y9ezu8	59000	2026-04-14 06:49:42.379	2026-04-14 06:49:42.379
cmny9heki04cevxy4evpj41zm	cmny9hecx04bsvxy43o6ia3fl	cmny9fdcn000dvxy4w3gaald5	59000	2026-04-14 06:49:42.402	2026-04-14 06:49:42.402
cmny9hemv04chvxy46id38ec6	cmny9hel804cfvxy4ihe8l77l	cmny9fd420001vxy42djthn1o	59000	2026-04-14 06:49:42.488	2026-04-14 06:49:42.488
cmny9heo004cjvxy48k7jlusy	cmny9hel804cfvxy4ihe8l77l	cmny9fd4t0002vxy4jo0l7gop	59000	2026-04-14 06:49:42.529	2026-04-14 06:49:42.529
cmny9heoo04clvxy431i7gk83	cmny9hel804cfvxy4ihe8l77l	cmny9fd5j0003vxy4sw5e14p1	59000	2026-04-14 06:49:42.552	2026-04-14 06:49:42.552
cmny9hepe04cnvxy4q0jv5jzt	cmny9hel804cfvxy4ihe8l77l	cmny9fd6h0004vxy4evm3jgfv	59000	2026-04-14 06:49:42.579	2026-04-14 06:49:42.579
cmny9heq504cpvxy4tlevphdn	cmny9hel804cfvxy4ihe8l77l	cmny9fd7u0006vxy4mh4wwui4	59000	2026-04-14 06:49:42.605	2026-04-14 06:49:42.605
cmny9her304crvxy4z07oim4s	cmny9hel804cfvxy4ihe8l77l	cmny9fd8i0007vxy4tmc0glr0	59000	2026-04-14 06:49:42.639	2026-04-14 06:49:42.639
cmny9herq04ctvxy4dxlj1odl	cmny9hel804cfvxy4ihe8l77l	cmny9fd980008vxy4alsawn4y	59000	2026-04-14 06:49:42.662	2026-04-14 06:49:42.662
cmny9hesp04cvvxy4o3p1ugs6	cmny9hel804cfvxy4ihe8l77l	cmny9fd9w0009vxy498vvvu1d	59000	2026-04-14 06:49:42.697	2026-04-14 06:49:42.697
cmny9hetd04cxvxy4ta1jeqg2	cmny9hel804cfvxy4ihe8l77l	cmny9fdb9000bvxy4h02fexen	59000	2026-04-14 06:49:42.721	2026-04-14 06:49:42.721
cmny9heu104czvxy41rjgdyof	cmny9hel804cfvxy4ihe8l77l	cmny9fdc1000cvxy4n4y9ezu8	59000	2026-04-14 06:49:42.745	2026-04-14 06:49:42.745
cmny9heuo04d1vxy4074wf5nh	cmny9hel804cfvxy4ihe8l77l	cmny9fdcn000dvxy4w3gaald5	59000	2026-04-14 06:49:42.768	2026-04-14 06:49:42.768
cmny9hew204d4vxy4v8qwvoy2	cmny9hevf04d2vxy4rqwhta1s	cmny9fd420001vxy42djthn1o	59000	2026-04-14 06:49:42.818	2026-04-14 06:49:42.818
cmny9hewt04d6vxy4agodd7p8	cmny9hevf04d2vxy4rqwhta1s	cmny9fd4t0002vxy4jo0l7gop	59000	2026-04-14 06:49:42.845	2026-04-14 06:49:42.845
cmny9hexg04d8vxy4v5krtd28	cmny9hevf04d2vxy4rqwhta1s	cmny9fd5j0003vxy4sw5e14p1	59000	2026-04-14 06:49:42.869	2026-04-14 06:49:42.869
cmny9hey704davxy43x7spbqo	cmny9hevf04d2vxy4rqwhta1s	cmny9fd6h0004vxy4evm3jgfv	59000	2026-04-14 06:49:42.895	2026-04-14 06:49:42.895
cmny9heyv04dcvxy492d8pta0	cmny9hevf04d2vxy4rqwhta1s	cmny9fd7u0006vxy4mh4wwui4	59000	2026-04-14 06:49:42.92	2026-04-14 06:49:42.92
cmny9hezl04devxy4t6b7uyu8	cmny9hevf04d2vxy4rqwhta1s	cmny9fd8i0007vxy4tmc0glr0	59000	2026-04-14 06:49:42.945	2026-04-14 06:49:42.945
cmny9hf0p04dgvxy41nq5g9ya	cmny9hevf04d2vxy4rqwhta1s	cmny9fd980008vxy4alsawn4y	59000	2026-04-14 06:49:42.985	2026-04-14 06:49:42.985
cmny9hf1g04divxy4oma2xrq6	cmny9hevf04d2vxy4rqwhta1s	cmny9fd9w0009vxy498vvvu1d	59000	2026-04-14 06:49:43.012	2026-04-14 06:49:43.012
cmny9hf2404dkvxy4kf6ln9uy	cmny9hevf04d2vxy4rqwhta1s	cmny9fdb9000bvxy4h02fexen	59000	2026-04-14 06:49:43.037	2026-04-14 06:49:43.037
cmny9hf2u04dmvxy4sfngtb86	cmny9hevf04d2vxy4rqwhta1s	cmny9fdc1000cvxy4n4y9ezu8	59000	2026-04-14 06:49:43.062	2026-04-14 06:49:43.062
cmny9hf3i04dovxy4expb08cm	cmny9hevf04d2vxy4rqwhta1s	cmny9fdcn000dvxy4w3gaald5	59000	2026-04-14 06:49:43.086	2026-04-14 06:49:43.086
cmny9hf4v04drvxy4vq3tdw8k	cmny9hf4804dpvxy4c1dwxlqv	cmny9fd420001vxy42djthn1o	79000	2026-04-14 06:49:43.136	2026-04-14 06:49:43.136
cmny9hf5n04dtvxy4m8a17lvc	cmny9hf4804dpvxy4c1dwxlqv	cmny9fd4t0002vxy4jo0l7gop	79000	2026-04-14 06:49:43.163	2026-04-14 06:49:43.163
cmny9hf6q04dvvxy4otsgv7d9	cmny9hf4804dpvxy4c1dwxlqv	cmny9fd5j0003vxy4sw5e14p1	79000	2026-04-14 06:49:43.202	2026-04-14 06:49:43.202
cmny9hf7h04dxvxy4a0w2bmit	cmny9hf4804dpvxy4c1dwxlqv	cmny9fd6h0004vxy4evm3jgfv	79000	2026-04-14 06:49:43.229	2026-04-14 06:49:43.229
cmny9hf8604dzvxy4ua45as14	cmny9hf4804dpvxy4c1dwxlqv	cmny9fd7u0006vxy4mh4wwui4	79000	2026-04-14 06:49:43.254	2026-04-14 06:49:43.254
cmny9hf8v04e1vxy4y2db9rot	cmny9hf4804dpvxy4c1dwxlqv	cmny9fd8i0007vxy4tmc0glr0	79000	2026-04-14 06:49:43.279	2026-04-14 06:49:43.279
cmny9hf9j04e3vxy4tml0nfha	cmny9hf4804dpvxy4c1dwxlqv	cmny9fd980008vxy4alsawn4y	79000	2026-04-14 06:49:43.303	2026-04-14 06:49:43.303
cmny9hfai04e5vxy44qfedhnk	cmny9hf4804dpvxy4c1dwxlqv	cmny9fd9w0009vxy498vvvu1d	79000	2026-04-14 06:49:43.338	2026-04-14 06:49:43.338
cmny9hfbh04e7vxy4besvecp6	cmny9hf4804dpvxy4c1dwxlqv	cmny9fdb9000bvxy4h02fexen	79000	2026-04-14 06:49:43.373	2026-04-14 06:49:43.373
cmny9hfcj04e9vxy4uzvazsi4	cmny9hf4804dpvxy4c1dwxlqv	cmny9fdc1000cvxy4n4y9ezu8	79000	2026-04-14 06:49:43.412	2026-04-14 06:49:43.412
cmny9hfdj04ebvxy4meejohvw	cmny9hf4804dpvxy4c1dwxlqv	cmny9fdcn000dvxy4w3gaald5	79000	2026-04-14 06:49:43.447	2026-04-14 06:49:43.447
cmny9hfew04eevxy4k9o95owe	cmny9hfe604ecvxy4c2vufdv8	cmny9fd420001vxy42djthn1o	39000	2026-04-14 06:49:43.496	2026-04-14 06:49:43.496
cmny9hffj04egvxy4o1ea06mo	cmny9hfe604ecvxy4c2vufdv8	cmny9fd4t0002vxy4jo0l7gop	39000	2026-04-14 06:49:43.519	2026-04-14 06:49:43.519
cmny9hfg904eivxy4qu9k6eyc	cmny9hfe604ecvxy4c2vufdv8	cmny9fd5j0003vxy4sw5e14p1	39000	2026-04-14 06:49:43.546	2026-04-14 06:49:43.546
cmny9hfgx04ekvxy4k6j2zvl9	cmny9hfe604ecvxy4c2vufdv8	cmny9fd6h0004vxy4evm3jgfv	39000	2026-04-14 06:49:43.569	2026-04-14 06:49:43.569
cmny9hfhp04emvxy4e2anspiw	cmny9hfe604ecvxy4c2vufdv8	cmny9fd7u0006vxy4mh4wwui4	39000	2026-04-14 06:49:43.598	2026-04-14 06:49:43.598
cmny9hfij04eovxy4870h7d37	cmny9hfe604ecvxy4c2vufdv8	cmny9fd8i0007vxy4tmc0glr0	39000	2026-04-14 06:49:43.627	2026-04-14 06:49:43.627
cmny9hfja04eqvxy4lnwpskiw	cmny9hfe604ecvxy4c2vufdv8	cmny9fd980008vxy4alsawn4y	39000	2026-04-14 06:49:43.654	2026-04-14 06:49:43.654
cmny9hfk004esvxy4y7hqga4i	cmny9hfe604ecvxy4c2vufdv8	cmny9fd9w0009vxy498vvvu1d	39000	2026-04-14 06:49:43.68	2026-04-14 06:49:43.68
cmny9hfkq04euvxy45htdmgyw	cmny9hfe604ecvxy4c2vufdv8	cmny9fdb9000bvxy4h02fexen	39000	2026-04-14 06:49:43.706	2026-04-14 06:49:43.706
cmny9hfld04ewvxy4e81jnpw7	cmny9hfe604ecvxy4c2vufdv8	cmny9fdc1000cvxy4n4y9ezu8	39000	2026-04-14 06:49:43.729	2026-04-14 06:49:43.729
cmny9hfm204eyvxy4ctqogp70	cmny9hfe604ecvxy4c2vufdv8	cmny9fdcn000dvxy4w3gaald5	39000	2026-04-14 06:49:43.754	2026-04-14 06:49:43.754
cmny9hfng04f1vxy4g26tyfny	cmny9hfmp04ezvxy4ra2tztwz	cmny9fd420001vxy42djthn1o	110000	2026-04-14 06:49:43.804	2026-04-14 06:49:43.804
cmny9hfo304f3vxy4969nla02	cmny9hfmp04ezvxy4ra2tztwz	cmny9fd4t0002vxy4jo0l7gop	110000	2026-04-14 06:49:43.827	2026-04-14 06:49:43.827
cmny9hfou04f5vxy4p9nvgyzp	cmny9hfmp04ezvxy4ra2tztwz	cmny9fd5j0003vxy4sw5e14p1	110000	2026-04-14 06:49:43.854	2026-04-14 06:49:43.854
cmny9hfph04f7vxy4tnnhwz32	cmny9hfmp04ezvxy4ra2tztwz	cmny9fd6h0004vxy4evm3jgfv	110000	2026-04-14 06:49:43.877	2026-04-14 06:49:43.877
cmny9hfq904f9vxy4n7x0to7z	cmny9hfmp04ezvxy4ra2tztwz	cmny9fd7u0006vxy4mh4wwui4	110000	2026-04-14 06:49:43.906	2026-04-14 06:49:43.906
cmny9hfqv04fbvxy4e2ff0b0d	cmny9hfmp04ezvxy4ra2tztwz	cmny9fd8i0007vxy4tmc0glr0	110000	2026-04-14 06:49:43.927	2026-04-14 06:49:43.927
cmny9hfrm04fdvxy42ywlsjf5	cmny9hfmp04ezvxy4ra2tztwz	cmny9fd980008vxy4alsawn4y	110000	2026-04-14 06:49:43.954	2026-04-14 06:49:43.954
cmny9hfs904ffvxy4awcnveh3	cmny9hfmp04ezvxy4ra2tztwz	cmny9fd9w0009vxy498vvvu1d	110000	2026-04-14 06:49:43.978	2026-04-14 06:49:43.978
cmny9hft204fhvxy4y10oak7z	cmny9hfmp04ezvxy4ra2tztwz	cmny9fdb9000bvxy4h02fexen	110000	2026-04-14 06:49:44.007	2026-04-14 06:49:44.007
cmny9hftn04fjvxy456rb91yj	cmny9hfmp04ezvxy4ra2tztwz	cmny9fdc1000cvxy4n4y9ezu8	110000	2026-04-14 06:49:44.027	2026-04-14 06:49:44.027
cmny9hfud04flvxy4qfkqxz8p	cmny9hfmp04ezvxy4ra2tztwz	cmny9fdcn000dvxy4w3gaald5	110000	2026-04-14 06:49:44.054	2026-04-14 06:49:44.054
cmny9hfw604fovxy4xvy7zsn1	cmny9hfv004fmvxy4mzp4n5p7	cmny9fd420001vxy42djthn1o	42000	2026-04-14 06:49:44.118	2026-04-14 06:49:44.118
cmny9hfwx04fqvxy4ef5j086g	cmny9hfv004fmvxy4mzp4n5p7	cmny9fd4t0002vxy4jo0l7gop	42000	2026-04-14 06:49:44.145	2026-04-14 06:49:44.145
cmny9hfxk04fsvxy44yla5h9x	cmny9hfv004fmvxy4mzp4n5p7	cmny9fd5j0003vxy4sw5e14p1	42000	2026-04-14 06:49:44.168	2026-04-14 06:49:44.168
cmny9hfyc04fuvxy4p29p9aru	cmny9hfv004fmvxy4mzp4n5p7	cmny9fd6h0004vxy4evm3jgfv	42000	2026-04-14 06:49:44.196	2026-04-14 06:49:44.196
cmny9hg0704fwvxy412roigsa	cmny9hfv004fmvxy4mzp4n5p7	cmny9fd740005vxy44c2rf5rg	42000	2026-04-14 06:49:44.263	2026-04-14 06:49:44.263
cmny9hg0u04fyvxy4r2ns66o5	cmny9hfv004fmvxy4mzp4n5p7	cmny9fd7u0006vxy4mh4wwui4	42000	2026-04-14 06:49:44.286	2026-04-14 06:49:44.286
cmny9hg1z04g0vxy4af0bq227	cmny9hfv004fmvxy4mzp4n5p7	cmny9fd8i0007vxy4tmc0glr0	42000	2026-04-14 06:49:44.328	2026-04-14 06:49:44.328
cmny9hg2q04g2vxy4ck9dg381	cmny9hfv004fmvxy4mzp4n5p7	cmny9fd980008vxy4alsawn4y	42000	2026-04-14 06:49:44.355	2026-04-14 06:49:44.355
cmny9hg3f04g4vxy44nnm02wa	cmny9hfv004fmvxy4mzp4n5p7	cmny9fd9w0009vxy498vvvu1d	42000	2026-04-14 06:49:44.379	2026-04-14 06:49:44.379
cmny9hg4e04g6vxy4gt70unnl	cmny9hfv004fmvxy4mzp4n5p7	cmny9fdam000avxy4a12zuxjj	42000	2026-04-14 06:49:44.414	2026-04-14 06:49:44.414
cmny9hg5904g8vxy4fetn0upk	cmny9hfv004fmvxy4mzp4n5p7	cmny9fdb9000bvxy4h02fexen	42000	2026-04-14 06:49:44.445	2026-04-14 06:49:44.445
cmny9hg6904gavxy4m4m0d3ji	cmny9hfv004fmvxy4mzp4n5p7	cmny9fdc1000cvxy4n4y9ezu8	42000	2026-04-14 06:49:44.481	2026-04-14 06:49:44.481
cmny9hg7404gcvxy4mn52cmts	cmny9hfv004fmvxy4mzp4n5p7	cmny9fdcn000dvxy4w3gaald5	42000	2026-04-14 06:49:44.512	2026-04-14 06:49:44.512
cmny9hg9904gfvxy4lec22tpr	cmny9hg8c04gdvxy41u388239	cmny9fd420001vxy42djthn1o	82000	2026-04-14 06:49:44.589	2026-04-14 06:49:44.589
cmny9hga604ghvxy4rw971fxc	cmny9hg8c04gdvxy41u388239	cmny9fd4t0002vxy4jo0l7gop	82000	2026-04-14 06:49:44.622	2026-04-14 06:49:44.622
cmny9hgb404gjvxy4xli73hom	cmny9hg8c04gdvxy41u388239	cmny9fd5j0003vxy4sw5e14p1	82000	2026-04-14 06:49:44.656	2026-04-14 06:49:44.656
cmny9hgc004glvxy48s12n5y7	cmny9hg8c04gdvxy41u388239	cmny9fd6h0004vxy4evm3jgfv	82000	2026-04-14 06:49:44.688	2026-04-14 06:49:44.688
cmny9hgcx04gnvxy4li31r0km	cmny9hg8c04gdvxy41u388239	cmny9fd740005vxy44c2rf5rg	82000	2026-04-14 06:49:44.721	2026-04-14 06:49:44.721
cmny9hgdu04gpvxy4iyd40njf	cmny9hg8c04gdvxy41u388239	cmny9fd7u0006vxy4mh4wwui4	82000	2026-04-14 06:49:44.754	2026-04-14 06:49:44.754
cmny9hget04grvxy4eq1awpwu	cmny9hg8c04gdvxy41u388239	cmny9fd8i0007vxy4tmc0glr0	82000	2026-04-14 06:49:44.789	2026-04-14 06:49:44.789
cmny9hgfp04gtvxy4gq7692pw	cmny9hg8c04gdvxy41u388239	cmny9fd980008vxy4alsawn4y	82000	2026-04-14 06:49:44.821	2026-04-14 06:49:44.821
cmny9hggp04gvvxy40uoceme3	cmny9hg8c04gdvxy41u388239	cmny9fd9w0009vxy498vvvu1d	82000	2026-04-14 06:49:44.857	2026-04-14 06:49:44.857
cmny9hghk04gxvxy4kdlxq21t	cmny9hg8c04gdvxy41u388239	cmny9fdam000avxy4a12zuxjj	82000	2026-04-14 06:49:44.888	2026-04-14 06:49:44.888
cmny9hgij04gzvxy4nptxt89p	cmny9hg8c04gdvxy41u388239	cmny9fdb9000bvxy4h02fexen	82000	2026-04-14 06:49:44.923	2026-04-14 06:49:44.923
cmny9hgjl04h1vxy4850ruuno	cmny9hg8c04gdvxy41u388239	cmny9fdc1000cvxy4n4y9ezu8	82000	2026-04-14 06:49:44.961	2026-04-14 06:49:44.961
cmny9hgkb04h3vxy4u98zwd39	cmny9hg8c04gdvxy41u388239	cmny9fdcn000dvxy4w3gaald5	82000	2026-04-14 06:49:44.987	2026-04-14 06:49:44.987
cmny9hglq04h6vxy4b3bg9mk4	cmny9hgky04h4vxy4bnfj3yh8	cmny9fd420001vxy42djthn1o	35000	2026-04-14 06:49:45.038	2026-04-14 06:49:45.038
cmny9hgmc04h8vxy431thov2l	cmny9hgky04h4vxy4bnfj3yh8	cmny9fd4t0002vxy4jo0l7gop	35000	2026-04-14 06:49:45.06	2026-04-14 06:49:45.06
cmny9hgn304havxy4bh6a3bd7	cmny9hgky04h4vxy4bnfj3yh8	cmny9fd5j0003vxy4sw5e14p1	35000	2026-04-14 06:49:45.088	2026-04-14 06:49:45.088
cmny9hgnq04hcvxy4295y78tw	cmny9hgky04h4vxy4bnfj3yh8	cmny9fd6h0004vxy4evm3jgfv	35000	2026-04-14 06:49:45.11	2026-04-14 06:49:45.11
cmny9hgoh04hevxy4dt4n46lg	cmny9hgky04h4vxy4bnfj3yh8	cmny9fd740005vxy44c2rf5rg	35000	2026-04-14 06:49:45.138	2026-04-14 06:49:45.138
cmny9hgp404hgvxy4r8jqejgy	cmny9hgky04h4vxy4bnfj3yh8	cmny9fd7u0006vxy4mh4wwui4	35000	2026-04-14 06:49:45.16	2026-04-14 06:49:45.16
cmny9hgpv04hivxy4qs7toc7l	cmny9hgky04h4vxy4bnfj3yh8	cmny9fd8i0007vxy4tmc0glr0	35000	2026-04-14 06:49:45.188	2026-04-14 06:49:45.188
cmny9hgqi04hkvxy4rbro27z8	cmny9hgky04h4vxy4bnfj3yh8	cmny9fd980008vxy4alsawn4y	35000	2026-04-14 06:49:45.211	2026-04-14 06:49:45.211
cmny9hgr904hmvxy45lx3mdsb	cmny9hgky04h4vxy4bnfj3yh8	cmny9fd9w0009vxy498vvvu1d	35000	2026-04-14 06:49:45.238	2026-04-14 06:49:45.238
cmny9hgrw04hovxy4zkc4cs7z	cmny9hgky04h4vxy4bnfj3yh8	cmny9fdam000avxy4a12zuxjj	35000	2026-04-14 06:49:45.261	2026-04-14 06:49:45.261
cmny9hgsn04hqvxy4gq3aq79x	cmny9hgky04h4vxy4bnfj3yh8	cmny9fdb9000bvxy4h02fexen	35000	2026-04-14 06:49:45.287	2026-04-14 06:49:45.287
cmny9hgta04hsvxy4ha6gae70	cmny9hgky04h4vxy4bnfj3yh8	cmny9fdc1000cvxy4n4y9ezu8	35000	2026-04-14 06:49:45.311	2026-04-14 06:49:45.311
cmny9hgu104huvxy4ry1hr1mf	cmny9hgky04h4vxy4bnfj3yh8	cmny9fdcn000dvxy4w3gaald5	35000	2026-04-14 06:49:45.337	2026-04-14 06:49:45.337
cmny9hgwk04hyvxy4tn1syp2e	cmny9hgvv04hwvxy43s6mss7r	cmny9fd4t0002vxy4jo0l7gop	53000	2026-04-14 06:49:45.429	2026-04-14 06:49:45.429
cmny9hgy304i0vxy40u7vpxxl	cmny9hgvv04hwvxy43s6mss7r	cmny9fdc1000cvxy4n4y9ezu8	53000	2026-04-14 06:49:45.483	2026-04-14 06:49:45.483
cmny9hgzu04i3vxy4q8ec0mnf	cmny9hgz004i1vxy4o9vgwwbu	cmny9fd420001vxy42djthn1o	600000	2026-04-14 06:49:45.546	2026-04-14 06:49:45.546
cmny9hh0h04i5vxy4gv6xf78s	cmny9hgz004i1vxy4o9vgwwbu	cmny9fd4t0002vxy4jo0l7gop	600000	2026-04-14 06:49:45.569	2026-04-14 06:49:45.569
cmny9hh1f04i7vxy4ncus9pf0	cmny9hgz004i1vxy4o9vgwwbu	cmny9fd980008vxy4alsawn4y	440000	2026-04-14 06:49:45.603	2026-04-14 06:49:45.603
cmny9hh2904i9vxy42z9y7hj3	cmny9hgz004i1vxy4o9vgwwbu	cmny9fdc1000cvxy4n4y9ezu8	600000	2026-04-14 06:49:45.634	2026-04-14 06:49:45.634
cmny9hh4p04idvxy4nk1jt49n	cmny9hh4004ibvxy4sdj15h6x	cmny9fd4t0002vxy4jo0l7gop	117000	2026-04-14 06:49:45.722	2026-04-14 06:49:45.722
cmny9hh5n04ifvxy4ps6qpuxk	cmny9hh4004ibvxy4sdj15h6x	cmny9fdc1000cvxy4n4y9ezu8	117000	2026-04-14 06:49:45.755	2026-04-14 06:49:45.755
cmny9hh7004iivxy4hyiozftu	cmny9hh6c04igvxy41c0m34lr	cmny9fd4t0002vxy4jo0l7gop	366000	2026-04-14 06:49:45.804	2026-04-14 06:49:45.804
cmny9hh8104ikvxy4zecf4gr1	cmny9hh6c04igvxy41c0m34lr	cmny9fdc1000cvxy4n4y9ezu8	366000	2026-04-14 06:49:45.841	2026-04-14 06:49:45.841
cmny9hh9j04invxy4tex5d7rq	cmny9hh8u04ilvxy4gmh3u1kz	cmny9fd420001vxy42djthn1o	32000	2026-04-14 06:49:45.896	2026-04-14 06:49:45.896
cmny9hha604ipvxy4praof6ux	cmny9hh8u04ilvxy4gmh3u1kz	cmny9fd4t0002vxy4jo0l7gop	32000	2026-04-14 06:49:45.919	2026-04-14 06:49:45.919
cmny9hhbh04irvxy4sj5oobdz	cmny9hh8u04ilvxy4gmh3u1kz	cmny9fdc1000cvxy4n4y9ezu8	32000	2026-04-14 06:49:45.966	2026-04-14 06:49:45.966
cmny9hhd004iuvxy44y4rl8vm	cmny9hhcb04isvxy47xmb4sop	cmny9fd420001vxy42djthn1o	38000	2026-04-14 06:49:46.021	2026-04-14 06:49:46.021
cmny9hhdn04iwvxy4t2993dzj	cmny9hhcb04isvxy47xmb4sop	cmny9fd4t0002vxy4jo0l7gop	38000	2026-04-14 06:49:46.043	2026-04-14 06:49:46.043
cmny9hhel04iyvxy4vik1nfmo	cmny9hhcb04isvxy47xmb4sop	cmny9fdc1000cvxy4n4y9ezu8	38000	2026-04-14 06:49:46.078	2026-04-14 06:49:46.078
cmny9hhg104j1vxy4kcx9q03g	cmny9hhfb04izvxy4yce9ho2n	cmny9fd420001vxy42djthn1o	32000	2026-04-14 06:49:46.129	2026-04-14 06:49:46.129
cmny9hhgo04j3vxy4t8gp56a3	cmny9hhfb04izvxy4yce9ho2n	cmny9fd4t0002vxy4jo0l7gop	32000	2026-04-14 06:49:46.152	2026-04-14 06:49:46.152
cmny9hhhq04j5vxy42ib9ctqh	cmny9hhfb04izvxy4yce9ho2n	cmny9fdc1000cvxy4n4y9ezu8	32000	2026-04-14 06:49:46.19	2026-04-14 06:49:46.19
cmny9hhk504j9vxy40s3n13fk	cmny9hhje04j7vxy4wnrk61m8	cmny9fd420001vxy42djthn1o	83000	2026-04-14 06:49:46.277	2026-04-14 06:49:46.277
cmny9hhkw04jbvxy45sz2c6c4	cmny9hhje04j7vxy4wnrk61m8	cmny9fd4t0002vxy4jo0l7gop	83000	2026-04-14 06:49:46.304	2026-04-14 06:49:46.304
cmny9hhlu04jdvxy465ji7n31	cmny9hhje04j7vxy4wnrk61m8	cmny9fdc1000cvxy4n4y9ezu8	83000	2026-04-14 06:49:46.339	2026-04-14 06:49:46.339
cmny9hhod04jhvxy4dr1ikwbv	cmny9hhni04jfvxy4fvzn70xh	cmny9fd420001vxy42djthn1o	59000	2026-04-14 06:49:46.429	2026-04-14 06:49:46.429
cmny9hhp004jjvxy44ql0cytw	cmny9hhni04jfvxy4fvzn70xh	cmny9fd4t0002vxy4jo0l7gop	59000	2026-04-14 06:49:46.452	2026-04-14 06:49:46.452
cmny9hhq104jlvxy4l4xtqk7w	cmny9hhni04jfvxy4fvzn70xh	cmny9fdc1000cvxy4n4y9ezu8	59000	2026-04-14 06:49:46.489	2026-04-14 06:49:46.489
cmny9hhrf04jovxy4v2gp9v7x	cmny9hhqo04jmvxy4dw4ujjby	cmny9fd4t0002vxy4jo0l7gop	432000	2026-04-14 06:49:46.539	2026-04-14 06:49:46.539
cmny9hhsb04jqvxy4jjj9l875	cmny9hhqo04jmvxy4dw4ujjby	cmny9fdc1000cvxy4n4y9ezu8	432000	2026-04-14 06:49:46.571	2026-04-14 06:49:46.571
cmny9hhtn04jtvxy4iro1cn2u	cmny9hht104jrvxy44q7kx1uc	cmny9fd4t0002vxy4jo0l7gop	367000	2026-04-14 06:49:46.619	2026-04-14 06:49:46.619
cmny9hhuj04jvvxy4bkpwd2a8	cmny9hht104jrvxy44q7kx1uc	cmny9fdc1000cvxy4n4y9ezu8	367000	2026-04-14 06:49:46.651	2026-04-14 06:49:46.651
cmny9hhw004jyvxy4th26hw1y	cmny9hhv904jwvxy4cbzb9f41	cmny9fd420001vxy42djthn1o	135000	2026-04-14 06:49:46.704	2026-04-14 06:49:46.704
cmny9hhwm04k0vxy4wzjmergj	cmny9hhv904jwvxy4cbzb9f41	cmny9fd4t0002vxy4jo0l7gop	135000	2026-04-14 06:49:46.727	2026-04-14 06:49:46.727
cmny9hhxo04k2vxy42422c5to	cmny9hhv904jwvxy4cbzb9f41	cmny9fdc1000cvxy4n4y9ezu8	135000	2026-04-14 06:49:46.764	2026-04-14 06:49:46.764
cmny9hhz104k5vxy4wygigbod	cmny9hhya04k3vxy47fprunca	cmny9fd4t0002vxy4jo0l7gop	395000	2026-04-14 06:49:46.813	2026-04-14 06:49:46.813
cmny9hhzw04k7vxy442cipjum	cmny9hhya04k3vxy47fprunca	cmny9fdc1000cvxy4n4y9ezu8	395000	2026-04-14 06:49:46.845	2026-04-14 06:49:46.845
cmny9hi1904kavxy41gxuuuph	cmny9hi0n04k8vxy4ntc3rmhu	cmny9fd420001vxy42djthn1o	95000	2026-04-14 06:49:46.893	2026-04-14 06:49:46.893
cmny9hi2004kcvxy4ft4zwmee	cmny9hi0n04k8vxy4ntc3rmhu	cmny9fd4t0002vxy4jo0l7gop	95000	2026-04-14 06:49:46.921	2026-04-14 06:49:46.921
cmny9hi2x04kevxy4hgzthbyf	cmny9hi0n04k8vxy4ntc3rmhu	cmny9fdc1000cvxy4n4y9ezu8	95000	2026-04-14 06:49:46.954	2026-04-14 06:49:46.954
cmny9hi4a04khvxy45uafdats	cmny9hi3o04kfvxy4bwn7bmx7	cmny9fd420001vxy42djthn1o	50000	2026-04-14 06:49:47.002	2026-04-14 06:49:47.002
cmny9hi5104kjvxy4l2ald7mf	cmny9hi3o04kfvxy4bwn7bmx7	cmny9fd4t0002vxy4jo0l7gop	50000	2026-04-14 06:49:47.029	2026-04-14 06:49:47.029
cmny9hi6004klvxy4sv5z4rol	cmny9hi3o04kfvxy4bwn7bmx7	cmny9fdc1000cvxy4n4y9ezu8	50000	2026-04-14 06:49:47.064	2026-04-14 06:49:47.064
cmny9hi7m04kovxy4y0ob2jkp	cmny9hi6x04kmvxy4jk7tyvbg	cmny9fd420001vxy42djthn1o	50000	2026-04-14 06:49:47.122	2026-04-14 06:49:47.122
cmny9hi8j04kqvxy42r0nidoi	cmny9hi6x04kmvxy4jk7tyvbg	cmny9fd4t0002vxy4jo0l7gop	50000	2026-04-14 06:49:47.155	2026-04-14 06:49:47.155
cmny9hi9v04ksvxy4bgsb2s9c	cmny9hi6x04kmvxy4jk7tyvbg	cmny9fdc1000cvxy4n4y9ezu8	50000	2026-04-14 06:49:47.203	2026-04-14 06:49:47.203
cmny9hibg04kvvxy4wjwnxa9s	cmny9hiao04ktvxy4foua0u8p	cmny9fd420001vxy42djthn1o	400000	2026-04-14 06:49:47.261	2026-04-14 06:49:47.261
cmny9hic704kxvxy44g8r2zw3	cmny9hiao04ktvxy4foua0u8p	cmny9fd4t0002vxy4jo0l7gop	400000	2026-04-14 06:49:47.287	2026-04-14 06:49:47.287
cmny9hid504kzvxy4mk2fopqi	cmny9hiao04ktvxy4foua0u8p	cmny9fdc1000cvxy4n4y9ezu8	400000	2026-04-14 06:49:47.321	2026-04-14 06:49:47.321
cmny9hig404l2vxy4ix5nf1xd	cmny9hidu04l0vxy48dx9317f	cmny9fd420001vxy42djthn1o	460000	2026-04-14 06:49:47.428	2026-04-14 06:49:47.428
cmny9hih204l4vxy4spszf8ao	cmny9hidu04l0vxy48dx9317f	cmny9fd4t0002vxy4jo0l7gop	460000	2026-04-14 06:49:47.462	2026-04-14 06:49:47.462
cmny9hij004l6vxy4kw8uuzs9	cmny9hidu04l0vxy48dx9317f	cmny9fdc1000cvxy4n4y9ezu8	460000	2026-04-14 06:49:47.532	2026-04-14 06:49:47.532
cmny9hikb04l9vxy4g0ngjrfm	cmny9hijm04l7vxy4sc2h44br	cmny9fd420001vxy42djthn1o	220000	2026-04-14 06:49:47.58	2026-04-14 06:49:47.58
cmny9hiky04lbvxy4kg18v4eg	cmny9hijm04l7vxy4sc2h44br	cmny9fd4t0002vxy4jo0l7gop	220000	2026-04-14 06:49:47.602	2026-04-14 06:49:47.602
cmny9hilz04ldvxy46w9mg7h5	cmny9hijm04l7vxy4sc2h44br	cmny9fdc1000cvxy4n4y9ezu8	220000	2026-04-14 06:49:47.639	2026-04-14 06:49:47.639
cmny9hine04lgvxy47toel2b5	cmny9himm04levxy45r7jvq2v	cmny9fd4t0002vxy4jo0l7gop	80000	2026-04-14 06:49:47.69	2026-04-14 06:49:47.69
cmny9hioo04livxy4jxac32zp	cmny9himm04levxy45r7jvq2v	cmny9fdc1000cvxy4n4y9ezu8	80000	2026-04-14 06:49:47.736	2026-04-14 06:49:47.736
cmny9hiq304llvxy45f9223oj	cmny9hipg04ljvxy4ha2ju0vq	cmny9fd4t0002vxy4jo0l7gop	80000	2026-04-14 06:49:47.787	2026-04-14 06:49:47.787
cmny9hir904lnvxy4f1p4wddl	cmny9hipg04ljvxy4ha2ju0vq	cmny9fdc1000cvxy4n4y9ezu8	80000	2026-04-14 06:49:47.829	2026-04-14 06:49:47.829
cmny9hisn04lqvxy4r1ciqrkz	cmny9hiry04lovxy4u42lsq73	cmny9fd420001vxy42djthn1o	220000	2026-04-14 06:49:47.879	2026-04-14 06:49:47.879
cmny9hita04lsvxy4wdbyr5ck	cmny9hiry04lovxy4u42lsq73	cmny9fd4t0002vxy4jo0l7gop	220000	2026-04-14 06:49:47.902	2026-04-14 06:49:47.902
cmny9hiuh04luvxy4sy9099zp	cmny9hiry04lovxy4u42lsq73	cmny9fdc1000cvxy4n4y9ezu8	220000	2026-04-14 06:49:47.945	2026-04-14 06:49:47.945
cmny9hiw404lxvxy4twzl7a40	cmny9hiv804lvvxy4qciwkqwe	cmny9fd420001vxy42djthn1o	90000	2026-04-14 06:49:48.004	2026-04-14 06:49:48.004
cmny9hiwr04lzvxy4ulnetzb3	cmny9hiv804lvvxy4qciwkqwe	cmny9fd4t0002vxy4jo0l7gop	90000	2026-04-14 06:49:48.027	2026-04-14 06:49:48.027
cmny9hixt04m1vxy4izwu26ln	cmny9hiv804lvvxy4qciwkqwe	cmny9fdc1000cvxy4n4y9ezu8	90000	2026-04-14 06:49:48.065	2026-04-14 06:49:48.065
cmny9hj0a04m5vxy4mkfnsjtz	cmny9hizn04m3vxy4xt84mp84	cmny9fd4t0002vxy4jo0l7gop	92000	2026-04-14 06:49:48.154	2026-04-14 06:49:48.154
cmny9hj1904m7vxy4mx90l7lb	cmny9hizn04m3vxy4xt84mp84	cmny9fdc1000cvxy4n4y9ezu8	92000	2026-04-14 06:49:48.19	2026-04-14 06:49:48.19
cmny9hj2z04mavxy4uepg44n1	cmny9hj1x04m8vxy4nm9axlnb	cmny9fd4t0002vxy4jo0l7gop	38000	2026-04-14 06:49:48.251	2026-04-14 06:49:48.251
cmny9hj3z04mcvxy4ltulwpqo	cmny9hj1x04m8vxy4nm9axlnb	cmny9fdc1000cvxy4n4y9ezu8	38000	2026-04-14 06:49:48.287	2026-04-14 06:49:48.287
cmny9hj5d04mfvxy4s48bulkd	cmny9hj4p04mdvxy4xt87ymo4	cmny9fd4t0002vxy4jo0l7gop	175000	2026-04-14 06:49:48.338	2026-04-14 06:49:48.338
cmny9hj6e04mhvxy4vdufz8t9	cmny9hj4p04mdvxy4xt87ymo4	cmny9fdc1000cvxy4n4y9ezu8	175000	2026-04-14 06:49:48.374	2026-04-14 06:49:48.374
cmny9hj7o04mkvxy498g8uf5l	cmny9hj6z04mivxy4pjiwg2kt	cmny9fd420001vxy42djthn1o	200000	2026-04-14 06:49:48.421	2026-04-14 06:49:48.421
cmny9hj8u04mmvxy4dpjfmy2e	cmny9hj6z04mivxy4pjiwg2kt	cmny9fd4t0002vxy4jo0l7gop	200000	2026-04-14 06:49:48.462	2026-04-14 06:49:48.462
cmny9hjae04movxy4z7oc7ltl	cmny9hj6z04mivxy4pjiwg2kt	cmny9fdc1000cvxy4n4y9ezu8	200000	2026-04-14 06:49:48.518	2026-04-14 06:49:48.518
cmny9hjfj04msvxy4o2fl14cc	cmny9hjei04mqvxy4bimaklr2	cmny9fd980008vxy4alsawn4y	15000	2026-04-14 06:49:48.703	2026-04-14 06:49:48.703
cmny9hjiz04mwvxy4wmmwr70n	cmny9hjhv04muvxy4zxm79hu3	cmny9fd980008vxy4alsawn4y	178000	2026-04-14 06:49:48.828	2026-04-14 06:49:48.828
cmny9hjkh04myvxy4dsnvs8m8	cmny9hjhv04muvxy4zxm79hu3	cmny9fdcn000dvxy4w3gaald5	202000	2026-04-14 06:49:48.881	2026-04-14 06:49:48.881
cmny9hjmj04n1vxy4qjndm8wq	cmny9hjla04mzvxy4sxy2t9ei	cmny9fd980008vxy4alsawn4y	148000	2026-04-14 06:49:48.955	2026-04-14 06:49:48.955
cmny9hjo304n3vxy4dbpbku6t	cmny9hjla04mzvxy4sxy2t9ei	cmny9fdcn000dvxy4w3gaald5	202000	2026-04-14 06:49:49.011	2026-04-14 06:49:49.011
cmny9hjq204n6vxy498kjhs8w	cmny9hjp104n4vxy4b4rltjlf	cmny9fd980008vxy4alsawn4y	168000	2026-04-14 06:49:49.082	2026-04-14 06:49:49.082
cmny9hjqw04n8vxy4jffgxr7n	cmny9hjp104n4vxy4b4rltjlf	cmny9fdcn000dvxy4w3gaald5	202000	2026-04-14 06:49:49.112	2026-04-14 06:49:49.112
cmny9hjsk04nbvxy4mdlgn2ty	cmny9hjrd04n9vxy4lk6cnv72	cmny9fdcn000dvxy4w3gaald5	202000	2026-04-14 06:49:49.172	2026-04-14 06:49:49.172
cmny9hjtr04nevxy4gz4kqtnt	cmny9hjsz04ncvxy4tu690jer	cmny9fd980008vxy4alsawn4y	168000	2026-04-14 06:49:49.215	2026-04-14 06:49:49.215
cmny9hjuh04ngvxy4kgj4ia48	cmny9hjsz04ncvxy4tu690jer	cmny9fdcn000dvxy4w3gaald5	202000	2026-04-14 06:49:49.242	2026-04-14 06:49:49.242
cmny9hjw304njvxy4rxfjtqes	cmny9hjv904nhvxy4yhlnl4dz	cmny9fdcn000dvxy4w3gaald5	202000	2026-04-14 06:49:49.299	2026-04-14 06:49:49.299
cmny9hjxm04nmvxy4faoi3xup	cmny9hjwn04nkvxy4dhxd5jaw	cmny9fdcn000dvxy4w3gaald5	202000	2026-04-14 06:49:49.354	2026-04-14 06:49:49.354
cmny9hjz104npvxy4k7w0o2lc	cmny9hjy904nnvxy4p6rpeqv8	cmny9fd980008vxy4alsawn4y	178000	2026-04-14 06:49:49.405	2026-04-14 06:49:49.405
cmny9hjzs04nrvxy45ajti00b	cmny9hjy904nnvxy4p6rpeqv8	cmny9fdcn000dvxy4w3gaald5	212000	2026-04-14 06:49:49.432	2026-04-14 06:49:49.432
cmny9hk1a04nuvxy4qh4oevza	cmny9hk0e04nsvxy4386p36zl	cmny9fd980008vxy4alsawn4y	158000	2026-04-14 06:49:49.486	2026-04-14 06:49:49.486
cmny9hk1x04nwvxy4bo3tv9tl	cmny9hk0e04nsvxy4386p36zl	cmny9fdcn000dvxy4w3gaald5	159000	2026-04-14 06:49:49.509	2026-04-14 06:49:49.509
cmny9hk3m04nzvxy48xh6bwax	cmny9hk2n04nxvxy4n6ugccyu	cmny9fdcn000dvxy4w3gaald5	170000	2026-04-14 06:49:49.57	2026-04-14 06:49:49.57
cmny9hk5504o2vxy42x2cw3hk	cmny9hk4904o0vxy4pw6qa0sl	cmny9fdcn000dvxy4w3gaald5	170000	2026-04-14 06:49:49.626	2026-04-14 06:49:49.626
cmny9hk6u04o5vxy4pcaxxq40	cmny9hk5w04o3vxy4zumifla0	cmny9fdcn000dvxy4w3gaald5	202000	2026-04-14 06:49:49.687	2026-04-14 06:49:49.687
cmny9hk8d04o8vxy4hdf39v85	cmny9hk7i04o6vxy41bokj1us	cmny9fdcn000dvxy4w3gaald5	159000	2026-04-14 06:49:49.742	2026-04-14 06:49:49.742
cmny9hk9n04obvxy42n0a8sys	cmny9hk8w04o9vxy4t4p9ovka	cmny9fd980008vxy4alsawn4y	128000	2026-04-14 06:49:49.787	2026-04-14 06:49:49.787
cmny9hkbe04odvxy4bbnyizna	cmny9hk8w04o9vxy4t4p9ovka	cmny9fdcn000dvxy4w3gaald5	159000	2026-04-14 06:49:49.85	2026-04-14 06:49:49.85
cmny9hkdc04ogvxy4j5dmiiel	cmny9hkcl04oevxy4soawdyzr	cmny9fd980008vxy4alsawn4y	98000	2026-04-14 06:49:49.92	2026-04-14 06:49:49.92
cmny9hkfb04oivxy4ho3srny9	cmny9hkcl04oevxy4soawdyzr	cmny9fdcn000dvxy4w3gaald5	138000	2026-04-14 06:49:49.991	2026-04-14 06:49:49.991
cmny9hkgy04olvxy4l7mqnzgj	cmny9hkfw04ojvxy46oncfu1d	cmny9fdcn000dvxy4w3gaald5	170000	2026-04-14 06:49:50.05	2026-04-14 06:49:50.05
cmny9hkil04oovxy4cj3tl4vn	cmny9hkhj04omvxy4o9t3zdoh	cmny9fdcn000dvxy4w3gaald5	138000	2026-04-14 06:49:50.109	2026-04-14 06:49:50.109
cmny9hkk004orvxy4i5sjbk7b	cmny9hkj504opvxy4lo8zps7d	cmny9fd980008vxy4alsawn4y	80000	2026-04-14 06:49:50.16	2026-04-14 06:49:50.16
cmny9hkko04otvxy44avu5mlo	cmny9hkj504opvxy4lo8zps7d	cmny9fdcn000dvxy4w3gaald5	96000	2026-04-14 06:49:50.184	2026-04-14 06:49:50.184
cmny9hkmd04owvxy45h9cdtbl	cmny9hkle04ouvxy4wtolpjob	cmny9fdcn000dvxy4w3gaald5	38000	2026-04-14 06:49:50.245	2026-04-14 06:49:50.245
cmny9hknz04ozvxy4tr0whm06	cmny9hkn004oxvxy4py6ljzpi	cmny9fdcn000dvxy4w3gaald5	212000	2026-04-14 06:49:50.303	2026-04-14 06:49:50.303
cmny9hkpg04p2vxy4465oz75o	cmny9hkon04p0vxy43o1c8ryi	cmny9fd980008vxy4alsawn4y	165000	2026-04-14 06:49:50.356	2026-04-14 06:49:50.356
cmny9hkr604p5vxy4n0wfwv57	cmny9hkq704p3vxy4apo9ekgs	cmny9fdcn000dvxy4w3gaald5	212000	2026-04-14 06:49:50.419	2026-04-14 06:49:50.419
cmny9hkss04p8vxy4hqvr2le6	cmny9hkrv04p6vxy44gz0bh0c	cmny9fdcn000dvxy4w3gaald5	202000	2026-04-14 06:49:50.477	2026-04-14 06:49:50.477
cmny9hkuh04pbvxy4511oebhf	cmny9hkth04p9vxy49hskbffl	cmny9fdcn000dvxy4w3gaald5	212000	2026-04-14 06:49:50.537	2026-04-14 06:49:50.537
cmny9hkw304pevxy404qcde9r	cmny9hkv404pcvxy44i066fn4	cmny9fdcn000dvxy4w3gaald5	117000	2026-04-14 06:49:50.595	2026-04-14 06:49:50.595
cmny9hkxj04phvxy4hf4wg1rs	cmny9hkwq04pfvxy4j8ukti57	cmny9fd980008vxy4alsawn4y	10000	2026-04-14 06:49:50.647	2026-04-14 06:49:50.647
cmny9hkzb04pkvxy4wahrsuwd	cmny9hkye04pivxy4dmm5r3pp	cmny9fdcn000dvxy4w3gaald5	212000	2026-04-14 06:49:50.711	2026-04-14 06:49:50.711
cmny9hl2304povxy4f43e96kk	cmny9hl1004pmvxy4gvu1irks	cmny9fdcn000dvxy4w3gaald5	101000	2026-04-14 06:49:50.811	2026-04-14 06:49:50.811
cmny9hl3o04prvxy46eawymxv	cmny9hl2l04ppvxy44czmzah3	cmny9fdcn000dvxy4w3gaald5	159000	2026-04-14 06:49:50.869	2026-04-14 06:49:50.869
cmny9hl6e04pvvxy4cmewomte	cmny9hl5c04ptvxy4bacqth4g	cmny9fdcn000dvxy4w3gaald5	138000	2026-04-14 06:49:50.966	2026-04-14 06:49:50.966
cmny9hl8804pyvxy4p685v5yz	cmny9hl7504pwvxy4fax6nmvw	cmny9fdcn000dvxy4w3gaald5	340000	2026-04-14 06:49:51.032	2026-04-14 06:49:51.032
cmny9hl9j04q1vxy4u91rc7mw	cmny9hl8r04pzvxy4isx378dl	cmny9fdcn000dvxy4w3gaald5	310000	2026-04-14 06:49:51.079	2026-04-14 06:49:51.079
cmny9hlbs04q5vxy4op6ondbs	cmny9hlb004q3vxy4hy9v4zmg	cmny9fd980008vxy4alsawn4y	168000	2026-04-14 06:49:51.16	2026-04-14 06:49:51.16
cmny9hlcb04q7vxy4nofo6ged	cmny9hlb004q3vxy4hy9v4zmg	cmny9fd9w0009vxy498vvvu1d	200000	2026-04-14 06:49:51.179	2026-04-14 06:49:51.179
cmny9hlcy04q9vxy4f3mq8uwd	cmny9hlb004q3vxy4hy9v4zmg	cmny9fdam000avxy4a12zuxjj	200000	2026-04-14 06:49:51.202	2026-04-14 06:49:51.202
cmny9hle004qbvxy4jmq4vhop	cmny9hlb004q3vxy4hy9v4zmg	cmny9fdcn000dvxy4w3gaald5	202000	2026-04-14 06:49:51.24	2026-04-14 06:49:51.24
cmny9hlgj04qfvxy4hla37hrg	cmny9hlfk04qdvxy4ujqbygxb	cmny9fdcn000dvxy4w3gaald5	202000	2026-04-14 06:49:51.331	2026-04-14 06:49:51.331
cmny9hli504qivxy4tq5k3mze	cmny9hlh604qgvxy47s286zl8	cmny9fdcn000dvxy4w3gaald5	256000	2026-04-14 06:49:51.389	2026-04-14 06:49:51.389
cmny9hlns04qovxy4jl366060	cmny9hlmz04qmvxy4ss3wpy7d	cmny9fd980008vxy4alsawn4y	225000	2026-04-14 06:49:51.592	2026-04-14 06:49:51.592
cmny9hlpz04qrvxy442hl80ie	cmny9hloq04qpvxy4bphsdq38	cmny9fd980008vxy4alsawn4y	85000	2026-04-14 06:49:51.671	2026-04-14 06:49:51.671
cmny9hlrq04quvxy4k7u9z411	cmny9hlqr04qsvxy42cv85i5g	cmny9fdcn000dvxy4w3gaald5	350000	2026-04-14 06:49:51.734	2026-04-14 06:49:51.734
cmny9hltc04qxvxy4rz8nhsod	cmny9hlsg04qvvxy47axouamu	cmny9fdcn000dvxy4w3gaald5	202000	2026-04-14 06:49:51.792	2026-04-14 06:49:51.792
\.


--
-- Data for Name: products; Type: TABLE DATA; Schema: public; Owner: oms_user
--

COPY public.products (id, name, sku, unit, "retailPrice", "costPrice", weight, dimensions, "isActive", "createdAt", "updatedAt") FROM stdin;
cmny9fikz00afvxy492t8y5j1	Gói tắm (ngãi cứu,tía tô,lá sả, thân khổ qua, hương nhu, gừng)	XUANLOCKHD4	Gói	18000	\N	\N	\N	t	2026-04-14 06:48:14.291	2026-04-14 06:48:14.291
cmny9firw00amvxy4vb8kj5rf	Gừng xoa bóp có địa liền (500ml)	XUANLOCKHD3	Chai	70000	\N	\N	\N	t	2026-04-14 06:48:14.54	2026-04-14 06:48:14.54
cmny9fddf000evxy44pvff3ba	Bí xanh khô (gói 50gr)	XUANLOC160	Gói	80000	\N	\N	\N	t	2026-04-14 06:48:07.539	2026-04-14 06:48:07.539
cmny9fdi9000lvxy4skepvuid	Hạt ngũ cốc thanh xuân	XUANLOC167	Gói	93000	\N	\N	\N	t	2026-04-14 06:48:07.713	2026-04-14 06:48:07.713
cmny9fdrh0018vxy44l8dpxwa	Bột mè đen cửu chưng cửu sái (hủ 500gr)	XUANLOC155	Hủ	265000	\N	\N	\N	t	2026-04-14 06:48:08.045	2026-04-14 06:48:08.045
cmny9fdv7001fvxy40trtc7i8	Hành tây trắng (củ nhỏ)	MOUNTAIN166	Kg	63000	\N	\N	\N	t	2026-04-14 06:48:08.18	2026-04-14 06:48:08.18
cmny9fe2v001yvxy4ejpm9q2x	Xích tiểu đậu	MOUNTAIN165	Kg	126000	\N	\N	\N	t	2026-04-14 06:48:08.455	2026-04-14 06:48:08.455
cmny9fecm002nvxy4e1rq33hi	Cà chua	MOUNTAIN164	Kg	57000	\N	\N	\N	t	2026-04-14 06:48:08.807	2026-04-14 06:48:08.807
cmny9femh003cvxy4lp56haa9	Cao sâm 100gr	XUANLOC166	Hộp	508000	\N	\N	\N	t	2026-04-14 06:48:09.162	2026-04-14 06:48:09.162
cmny9fev6003xvxy4vztc1ynm	Nước chuối len men	XUANLOC165	Lít	0	\N	\N	\N	t	2026-04-14 06:48:09.474	2026-04-14 06:48:09.474
cmny9fez20044vxy4nzvtaykj	Trà xích tiểu đậu (gói 250gr)	XUANLOC154	Gói	65000	\N	\N	\N	t	2026-04-14 06:48:09.614	2026-04-14 06:48:09.614
cmny9ff7m004rvxy4chtcq534	Tai heo	HANGTUOI71	Kg	202000	\N	\N	\N	t	2026-04-14 06:48:09.922	2026-04-14 06:48:09.922
cmny9ff9o004uvxy4tpj33yho	Bó xôi	MOUNTAIN163	Kg	65000	\N	\N	\N	t	2026-04-14 06:48:09.996	2026-04-14 06:48:09.996
cmny9ffi8005fvxy4ocwn8b83	Bột khoai lang chín (gói 100gr)	MOUNTAIN162	Gói	59000	\N	\N	\N	t	2026-04-14 06:48:10.305	2026-04-14 06:48:10.305
cmny9fftj0062vxy4x0z7c6ow	Nước dâu tằm lên men (500ml)	XUANLOC153	Chai	0	\N	\N	\N	t	2026-04-14 06:48:10.712	2026-04-14 06:48:10.712
cmny9ffx50069vxy42vuqm8pm	Set quà Tết	XUANLOC999	Set	0	\N	\N	\N	t	2026-04-14 06:48:10.841	2026-04-14 06:48:10.841
cmny9ffyx006avxy43xdr680q	Bắp cải thảo	MOUNTAIN159	Kg	57000	\N	\N	\N	t	2026-04-14 06:48:10.905	2026-04-14 06:48:10.905
cmny9fga70071vxy436v2ocov	Thùng giấy	Q101	Kg	0	\N	\N	\N	t	2026-04-14 06:48:11.312	2026-04-14 06:48:11.312
cmny9fgdh0078vxy4uud17wgi	Tiêu hạt	MOUNTAIN158	Kg	0	\N	\N	\N	t	2026-04-14 06:48:11.429	2026-04-14 06:48:11.429
cmny9fgho007fvxy43fsynb40	Gói xông nhà	XUANLOCKHD13	Gói	22000	\N	\N	\N	t	2026-04-14 06:48:11.58	2026-04-14 06:48:11.58
cmny9fgl8007mvxy4wq7l7kaj	Bắp cải (sú)	MOUNTAIN157	Kg	57000	\N	\N	\N	t	2026-04-14 06:48:11.709	2026-04-14 06:48:11.709
cmny9fgxz008dvxy46c3nq3ar	Dưa leo (tặng)	MOUNTAINKHD6	Kg	0	\N	\N	\N	t	2026-04-14 06:48:12.167	2026-04-14 06:48:12.167
cmny9fh0m008evxy4zb58bpe4	Đậu ve  (tặng)	MOUNTAINKHD5	Kg	0	\N	\N	\N	t	2026-04-14 06:48:12.262	2026-04-14 06:48:12.262
cmny9fh1y008fvxy44hqonibw	Cám	MOUNTAINKHD4	Kg	15000	\N	\N	\N	t	2026-04-14 06:48:12.31	2026-04-14 06:48:12.31
cmny9fh3h008gvxy48c2zjdam	Trứng gà (tặng)	MOUNTAINKHD3	Cái	0	\N	\N	\N	t	2026-04-14 06:48:12.365	2026-04-14 06:48:12.365
cmny9fh4r008hvxy4vsxsqweo	Khoai lang (nhỏ)	MOUNTAINKHD2	Kg	0	\N	\N	\N	t	2026-04-14 06:48:12.412	2026-04-14 06:48:12.412
cmny9fh6y008kvxy4nh40uab1	Khoai lang (cạp)	MOUNTAINKHD1	Kg	48000	\N	\N	\N	t	2026-04-14 06:48:12.491	2026-04-14 06:48:12.491
cmny9fhc9008tvxy4obz60vr8	Rượu nếp cẩm vắt	XUANLOCKHD12	Lít	258000	\N	\N	\N	t	2026-04-14 06:48:12.681	2026-04-14 06:48:12.681
cmny9fhos009gvxy4302vlxg7	Rượu nếp trắng vắt (chai nhựa 500ml)	XUANLOCKHD11	Lít	229000	\N	\N	\N	t	2026-04-14 06:48:13.132	2026-04-14 06:48:13.132
cmny9fi7h00a3vxy4kmdmegcy	Bánh chưng	XUANLOCKHD10	cây	0	\N	\N	\N	t	2026-04-14 06:48:13.806	2026-04-14 06:48:13.806
cmny9fi9t00a4vxy48kigh868	Rượu nếp trắng	XUANLOCKHD9	Lít	70000	\N	\N	\N	t	2026-04-14 06:48:13.889	2026-04-14 06:48:13.889
cmny9fibo00a5vxy4ju3lt8tz	Rượu trắng 40 độ	XUANLOCKHD8	Kg	55000	\N	\N	\N	t	2026-04-14 06:48:13.957	2026-04-14 06:48:13.957
cmny9fida00a6vxy42nq4y4z9	Rượu trắng 35 độ	XUANLOCKHD7	Kg	45000	\N	\N	\N	t	2026-04-14 06:48:14.014	2026-04-14 06:48:14.014
cmny9fifb00a7vxy4kp9jqn7x	Rượu nếp trắng 40 độ	XUANLOCKHD6	Kg	65000	\N	\N	\N	t	2026-04-14 06:48:14.087	2026-04-14 06:48:14.087
cmny9fih700a8vxy4mqrn6qik	Gói tắm thân lá khổ qua	XUANLOCKHD5	Gói	10000	\N	\N	\N	t	2026-04-14 06:48:14.155	2026-04-14 06:48:14.155
cmny9fiwq00avvxy44ai6bmnf	Gừng xoa bóp (500ml)	XUANLOCKHD2	Chai	53000	\N	\N	\N	t	2026-04-14 06:48:14.714	2026-04-14 06:48:14.714
cmny9fj0900b2vxy4vo2okk4u	Gói xông	XUANLOCKHD1	Gói	22000	\N	\N	\N	t	2026-04-14 06:48:14.841	2026-04-14 06:48:14.841
cmny9fj3y00b9vxy4e1s4pay0	Tiêu hạt (gói 100gr)	MOUNTAIN156	Gói	55000	\N	\N	\N	t	2026-04-14 06:48:14.974	2026-04-14 06:48:14.974
cmny9fjd500bwvxy4a8qdnhwi	Mắc khén (gói 100gr)	MOUNTAIN155	Gói	55000	\N	\N	\N	t	2026-04-14 06:48:15.305	2026-04-14 06:48:15.305
cmny9fjm500cjvxy4cur210b6	Cà ri hạt (gói 100gr)	MOUNTAIN154	Gói	47000	\N	\N	\N	t	2026-04-14 06:48:15.629	2026-04-14 06:48:15.629
cmny9fjur00d6vxy4gs774u96	Gạo phối ngũ cốc (gói 100gr)	MOUNTAIN153	Gói	19000	\N	\N	\N	t	2026-04-14 06:48:15.939	2026-04-14 06:48:15.939
cmny9fkbm00dtvxy4tsu13wey	Sét ăn dặm cho các bé (size nhỏ)	MOUNTAIN152	Gói	207000	\N	\N	\N	t	2026-04-14 06:48:16.546	2026-04-14 06:48:16.546
cmny9fkko00egvxy4wlit9vfp	Sét ăn dặm cho các bé (size lớn)	MOUNTAIN151	Gói	260000	\N	\N	\N	t	2026-04-14 06:48:16.872	2026-04-14 06:48:16.872
cmny9fkth00f3vxy465j55cz9	Gạo ăn dặm (xà cơn,kê,bobo) gói 500gr	MOUNTAIN150	Gói	84000	\N	\N	\N	t	2026-04-14 06:48:17.189	2026-04-14 06:48:17.189
cmny9fl2q00fqvxy4z999yy33	Sét hạt kê đậu xanh	MOUNTAIN149	Gói	34000	\N	\N	\N	t	2026-04-14 06:48:17.522	2026-04-14 06:48:17.522
cmny9flbs00gdvxy4pz29chrk	Hạt ngũ cốc dưỡng huyết	MOUNTAIN148	Gói	42000	\N	\N	\N	t	2026-04-14 06:48:17.848	2026-04-14 06:48:17.848
cmny9fll900h0vxy4bu3t48hg	Gạo mix baby	MOUNTAIN147	Kg	92000	\N	\N	\N	t	2026-04-14 06:48:18.189	2026-04-14 06:48:18.189
cmny9fltr00hnvxy42du9zfn4	Gạo mix 15 loại đậu hạt	MOUNTAIN146	Kg	95000	\N	\N	\N	t	2026-04-14 06:48:18.495	2026-04-14 06:48:18.495
cmny9fm3h00iavxy462ufev27	Tỏi	MOUNTAIN145	Kg	185000	\N	\N	\N	t	2026-04-14 06:48:18.846	2026-04-14 06:48:18.846
cmny9fmdo00izvxy4zcfb0ran	Gừng trâu	MOUNTAIN144	Kg	72000	\N	\N	\N	t	2026-04-14 06:48:19.212	2026-04-14 06:48:19.212
cmny9fmmb00jmvxy46k590w4g	Gừng sẻ	MOUNTAIN143	Kg	90000	\N	\N	\N	t	2026-04-14 06:48:19.523	2026-04-14 06:48:19.523
cmny9fmvk00k9vxy4cbw4r8qh	Nghệ	MOUNTAIN142	Kg	57000	\N	\N	\N	t	2026-04-14 06:48:19.856	2026-04-14 06:48:19.856
cmny9fn5000kwvxy4m521j248	Sả	MOUNTAIN141	Kg	36000	\N	\N	\N	t	2026-04-14 06:48:20.196	2026-04-14 06:48:20.196
cmny9fnf000ljvxy4er93494o	Hành tím khô	MOUNTAIN140	Kg	172000	\N	\N	\N	t	2026-04-14 06:48:20.556	2026-04-14 06:48:20.556
cmny9fnot00m6vxy4oys7urk4	Hành tím tươi	MOUNTAIN139	Kg	130000	\N	\N	\N	t	2026-04-14 06:48:20.91	2026-04-14 06:48:20.91
cmny9fnyf00mtvxy4x7kskjyy	Hành tây tím	MOUNTAIN138	Kg	75000	\N	\N	\N	t	2026-04-14 06:48:21.256	2026-04-14 06:48:21.256
cmny9fo8l00ngvxy46dea435h	Hành tây trắng	MOUNTAIN137	Kg	70000	\N	\N	\N	t	2026-04-14 06:48:21.622	2026-04-14 06:48:21.622
cmny9fohf00o3vxy4c157rfcz	Bí xanh	MOUNTAIN136	Kg	42000	\N	\N	\N	t	2026-04-14 06:48:21.939	2026-04-14 06:48:21.939
cmny9ford00oqvxy404oyhktk	Bầu	MOUNTAIN135	Kg	42000	\N	\N	\N	t	2026-04-14 06:48:22.298	2026-04-14 06:48:22.298
cmny9fp0i00pdvxy4d8zywy4y	Bí đỏ	MOUNTAIN134	Kg	42000	\N	\N	\N	t	2026-04-14 06:48:22.627	2026-04-14 06:48:22.627
cmny9fp9800q0vxy40m2n99w1	Bắp nếp	MOUNTAIN133	Kg	43000	\N	\N	\N	t	2026-04-14 06:48:22.94	2026-04-14 06:48:22.94
cmny9fphi00qnvxy4jsz33d96	Dưa Leo	MOUNTAIN132	Kg	45000	\N	\N	\N	t	2026-04-14 06:48:23.239	2026-04-14 06:48:23.239
cmny9fppu00ravxy4rwxtlthy	Đậu ve	MOUNTAIN131	Kg	48000	\N	\N	\N	t	2026-04-14 06:48:23.539	2026-04-14 06:48:23.539
cmny9fpyn00rxvxy4ga3bxf7f	Đậu đũa	MOUNTAIN130	Kg	48000	\N	\N	\N	t	2026-04-14 06:48:23.856	2026-04-14 06:48:23.856
cmny9fq8k00skvxy485ibxqwm	Củ cải trắng	MOUNTAIN129	Kg	40000	\N	\N	\N	t	2026-04-14 06:48:24.213	2026-04-14 06:48:24.213
cmny9fqhn00t7vxy4gyvnbv6i	Củ cải trắng (có lá)	MOUNTAIN128	Kg	37000	\N	\N	\N	t	2026-04-14 06:48:24.54	2026-04-14 06:48:24.54
cmny9fqqn00tuvxy4dvqc51p3	Khoai môn	MOUNTAIN127	Kg	72000	\N	\N	\N	t	2026-04-14 06:48:24.863	2026-04-14 06:48:24.863
cmny9fqzu00uhvxy4tn6ep25a	Khoai sọ	MOUNTAIN126	Kg	63000	\N	\N	\N	t	2026-04-14 06:48:25.195	2026-04-14 06:48:25.195
cmny9frep00v4vxy4rdn8tp2x	Khoai mỡ	MOUNTAIN125	Kg	63000	\N	\N	\N	t	2026-04-14 06:48:25.729	2026-04-14 06:48:25.729
cmny9frnr00vrvxy4nmi6dk3p	Khoai lang	MOUNTAIN124	Kg	60000	\N	\N	\N	t	2026-04-14 06:48:26.056	2026-04-14 06:48:26.056
cmny9frw400wevxy494ut3iuo	Mướp	MOUNTAIN123	Kg	40000	\N	\N	\N	t	2026-04-14 06:48:26.356	2026-04-14 06:48:26.356
cmny9fs6100x1vxy49qe3vyt2	Ớt đỏ (chỉ thiên)	MOUNTAIN122	Kg	72000	\N	\N	\N	t	2026-04-14 06:48:26.713	2026-04-14 06:48:26.713
cmny9fsfa00xovxy4g4s6mxxd	Mồng tơi	MOUNTAIN121	Kg	65000	\N	\N	\N	t	2026-04-14 06:48:27.046	2026-04-14 06:48:27.046
cmny9fsnf00y9vxy4x3fvrdsa	Cải thìa	MOUNTAIN120	Kg	65000	\N	\N	\N	t	2026-04-14 06:48:27.34	2026-04-14 06:48:27.34
cmny9fsva00yuvxy4zvvz5lhi	Cải xanh	MOUNTAIN119	Kg	65000	\N	\N	\N	t	2026-04-14 06:48:27.623	2026-04-14 06:48:27.623
cmny9ft3600zfvxy4ubx2j3g8	Cải ngọt	MOUNTAIN118	Kg	65000	\N	\N	\N	t	2026-04-14 06:48:27.906	2026-04-14 06:48:27.906
cmny9ftb00100vxy4qghsouxb	Cải đuôi phụng	MOUNTAIN117	Kg	65000	\N	\N	\N	t	2026-04-14 06:48:28.188	2026-04-14 06:48:28.188
cmny9ftjd010lvxy4kt9t230t	Cải cúc	MOUNTAIN116	Kg	65000	\N	\N	\N	t	2026-04-14 06:48:28.489	2026-04-14 06:48:28.489
cmny9ftr70116vxy45hhskk83	Rau ngót	MOUNTAIN115	Kg	65000	\N	\N	\N	t	2026-04-14 06:48:28.771	2026-04-14 06:48:28.771
cmny9ftzr011rvxy4w9olv9f4	Rau muống nước	MOUNTAIN114	Kg	65000	\N	\N	\N	t	2026-04-14 06:48:29.08	2026-04-14 06:48:29.08
cmny9fu7w012cvxy4zi9iflv9	Rau dền	MOUNTAIN113	Kg	65000	\N	\N	\N	t	2026-04-14 06:48:29.372	2026-04-14 06:48:29.372
cmny9fugp012xvxy4ylplmb19	Rau lang	MOUNTAIN112	Kg	65000	\N	\N	\N	t	2026-04-14 06:48:29.689	2026-04-14 06:48:29.689
cmny9fup7013ivxy4e7gw91lc	Tía tô	MOUNTAIN111	Kg	86000	\N	\N	\N	t	2026-04-14 06:48:29.996	2026-04-14 06:48:29.996
cmny9fuy10143vxy47dj0lu72	Hành lá	MOUNTAIN110	Kg	86000	\N	\N	\N	t	2026-04-14 06:48:30.314	2026-04-14 06:48:30.314
cmny9fv7j014ovxy48cyoctd3	Ngò rí	MOUNTAIN109	Kg	93000	\N	\N	\N	t	2026-04-14 06:48:30.656	2026-04-14 06:48:30.656
cmny9fvgt0159vxy4rphmrzbz	Nếp cẩm trồng đồi	MOUNTAIN108	Kg	100000	\N	\N	\N	t	2026-04-14 06:48:30.989	2026-04-14 06:48:30.989
cmny9fvqj015yvxy460fkju0e	Nếp than	MOUNTAIN107	Kg	100000	\N	\N	\N	t	2026-04-14 06:48:31.34	2026-04-14 06:48:31.34
cmny9fw1n016nvxy4iimihogl	Nếp hoa vàng xát lứt	MOUNTAIN106	Kg	75000	\N	\N	\N	t	2026-04-14 06:48:31.74	2026-04-14 06:48:31.74
cmny9fwaw017avxy42qv21y88	Nếp hoa vàng xát dối	MOUNTAIN105	Kg	75000	\N	\N	\N	t	2026-04-14 06:48:32.073	2026-04-14 06:48:32.073
cmny9fwje017xvxy40qg5xlot	Nếp hoa vàng xát trắng	MOUNTAIN104	Kg	75000	\N	\N	\N	t	2026-04-14 06:48:32.379	2026-04-14 06:48:32.379
cmny9fwvq018mvxy4q31zbav3	Nếp nương xát lứt	MOUNTAIN103	Kg	70000	\N	\N	\N	t	2026-04-14 06:48:32.822	2026-04-14 06:48:32.822
cmny9fx4p0199vxy4ywsj53mv	Nếp nương xát dối	MOUNTAIN102	Kg	70000	\N	\N	\N	t	2026-04-14 06:48:33.145	2026-04-14 06:48:33.145
cmny9fxdi019wvxy4ny5svmh2	Nếp nương xát trắng	MOUNTAIN101	Kg	70000	\N	\N	\N	t	2026-04-14 06:48:33.462	2026-04-14 06:48:33.462
cmny9fxma01ajvxy4dohbtfpp	Nếp bắc xát lứt	MOUNTAIN100	Kg	66000	\N	\N	\N	t	2026-04-14 06:48:33.779	2026-04-14 06:48:33.779
cmny9fxv201b6vxy4ua3rt4qb	Nếp bắc xát dối	MOUNTAIN99	Kg	66000	\N	\N	\N	t	2026-04-14 06:48:34.095	2026-04-14 06:48:34.095
cmny9fy4c01btvxy40j63xyny	Nếp bắc xát trắng	MOUNTAIN98	Kg	66000	\N	\N	\N	t	2026-04-14 06:48:34.429	2026-04-14 06:48:34.429
cmny9fyco01cgvxy4zadxb4a4	Gạo đỏ xưa xát lứt	MOUNTAIN97	Kg	57000	\N	\N	\N	t	2026-04-14 06:48:34.728	2026-04-14 06:48:34.728
cmny9fymo01d3vxy42wo51s0r	Gạo đỏ xưa xát dối	MOUNTAIN96	Kg	57000	\N	\N	\N	t	2026-04-14 06:48:35.088	2026-04-14 06:48:35.088
cmny9fywe01dqvxy4dz0ld4m5	Gạo đỏ xưa xát trắng	MOUNTAIN95	Kg	57000	\N	\N	\N	t	2026-04-14 06:48:35.438	2026-04-14 06:48:35.438
cmny9fz5701edvxy4h1wuuxhy	Gạo xà cơn trắng lứt	MOUNTAIN94	Kg	57000	\N	\N	\N	t	2026-04-14 06:48:35.755	2026-04-14 06:48:35.755
cmny9fzfe01f0vxy4k2jb49dt	Gạo xà cơn trắng dối	MOUNTAIN93	Kg	57000	\N	\N	\N	t	2026-04-14 06:48:36.122	2026-04-14 06:48:36.122
cmny9fzpa01fnvxy4ktzgwfij	Gạo xà cơn trắng trắng	MOUNTAIN92	Kg	57000	\N	\N	\N	t	2026-04-14 06:48:36.479	2026-04-14 06:48:36.479
cmny9fzyu01gavxy4ljsg7t17	Gạo xà cơn đỏ lứt	MOUNTAIN91	Kg	57000	\N	\N	\N	t	2026-04-14 06:48:36.823	2026-04-14 06:48:36.823
cmny9g07e01gxvxy4n3g7lykr	Gạo xà cơn đỏ dối	MOUNTAIN90	Kg	57000	\N	\N	\N	t	2026-04-14 06:48:37.131	2026-04-14 06:48:37.131
cmny9g0h401hkvxy417x1mjae	Gạo xà cơn đỏ trắng	MOUNTAIN89	Kg	57000	\N	\N	\N	t	2026-04-14 06:48:37.48	2026-04-14 06:48:37.48
cmny9g0we01i7vxy40uto4qld	Gạo đồi tròn lứt	MOUNTAIN88	Kg	52000	\N	\N	\N	t	2026-04-14 06:48:38.031	2026-04-14 06:48:38.031
cmny9g15g01iuvxy4k8o2znkt	Gạo đồi tròn dối	MOUNTAIN87	Kg	52000	\N	\N	\N	t	2026-04-14 06:48:38.357	2026-04-14 06:48:38.357
cmny9g1ds01jhvxy4vh9ao1kl	Gạo đồi tròn trắng	MOUNTAIN86	Kg	52000	\N	\N	\N	t	2026-04-14 06:48:38.657	2026-04-14 06:48:38.657
cmny9g1n701k4vxy4m1kr5v71	Gạo huyết rồng xát lứt	MOUNTAIN85	Kg	57000	\N	\N	\N	t	2026-04-14 06:48:38.996	2026-04-14 06:48:38.996
cmny9g1xp01krvxy4v9zhe6qk	Gạo huyết rồng xát dối	MOUNTAIN84	Kg	57000	\N	\N	\N	t	2026-04-14 06:48:39.373	2026-04-14 06:48:39.373
cmny9g27f01levxy4nkhbbpaj	Gạo huyết rồng xát trắng	MOUNTAIN83	Kg	57000	\N	\N	\N	t	2026-04-14 06:48:39.723	2026-04-14 06:48:39.723
cmny9g2fi01m1vxy4svc6kyzs	Gạo thơm dẻo lứt	MOUNTAIN82	Kg	41000	\N	\N	\N	t	2026-04-14 06:48:40.014	2026-04-14 06:48:40.014
cmny9g2nv01movxy437et0sti	Gạo thơm dẻo dối	MOUNTAIN81	Kg	41000	\N	\N	\N	t	2026-04-14 06:48:40.315	2026-04-14 06:48:40.315
cmny9g2vq01nbvxy4ve43zehd	Gạo thơm dẻo trắng	MOUNTAIN80	Kg	41000	\N	\N	\N	t	2026-04-14 06:48:40.598	2026-04-14 06:48:40.598
cmny9g33l01nyvxy4oow351l0	Gạo ST24 lứt	MOUNTAIN79	Kg	51000	\N	\N	\N	t	2026-04-14 06:48:40.882	2026-04-14 06:48:40.882
cmny9g3cd01olvxy472e9test	Gạo ST24 dối	MOUNTAIN78	Kg	51000	\N	\N	\N	t	2026-04-14 06:48:41.198	2026-04-14 06:48:41.198
cmny9g3k901p8vxy45y5n1wps	Gạo ST24  trắng	MOUNTAIN77	Kg	51000	\N	\N	\N	t	2026-04-14 06:48:41.481	2026-04-14 06:48:41.481
cmny9g3ti01pvvxy4l5g9skkq	Đậu xanh	MOUNTAIN76	Kg	118000	\N	\N	\N	t	2026-04-14 06:48:41.815	2026-04-14 06:48:41.815
cmny9g43101qkvxy4khynrdvk	Đậu xanh vỡ đôi	MOUNTAIN75	Kg	125000	\N	\N	\N	t	2026-04-14 06:48:42.157	2026-04-14 06:48:42.157
cmny9g4bu01r9vxy4n8td0f7o	Đậu xanh tách vỏ	MOUNTAIN74	Kg	134000	\N	\N	\N	t	2026-04-14 06:48:42.474	2026-04-14 06:48:42.474
cmny9g4kk01rsvxy4a9ht03o5	Đậu đen xanh lòng	MOUNTAIN73	Kg	126000	\N	\N	\N	t	2026-04-14 06:48:42.788	2026-04-14 06:48:42.788
cmny9g4so01shvxy4npifelgr	Đậu đỏ	MOUNTAIN72	Kg	126000	\N	\N	\N	t	2026-04-14 06:48:43.081	2026-04-14 06:48:43.081
cmny9g51801t6vxy4cg7uy0ib	Đậu nành	MOUNTAIN71	Kg	126000	\N	\N	\N	t	2026-04-14 06:48:43.388	2026-04-14 06:48:43.388
cmny9g59u01tvvxy4bploaxya	Đậu trắng	MOUNTAIN70	Kg	113000	\N	\N	\N	t	2026-04-14 06:48:43.698	2026-04-14 06:48:43.698
cmny9g5hm01ukvxy45l3qkd8d	Đậu ván	MOUNTAIN69	Kg	126000	\N	\N	\N	t	2026-04-14 06:48:43.979	2026-04-14 06:48:43.979
cmny9g5p101v7vxy4523xbtl1	Đậu phộng khô (nhân)	MOUNTAIN68	Kg	187000	\N	\N	\N	t	2026-04-14 06:48:44.245	2026-04-14 06:48:44.245
cmny9g5wi01vwvxy41ndhmxyk	Bo bo	MOUNTAIN67	Kg	222000	\N	\N	\N	t	2026-04-14 06:48:44.515	2026-04-14 06:48:44.515
cmny9g63x01wjvxy42n802n4o	Bắp khô	MOUNTAIN66	Kg	82000	\N	\N	\N	t	2026-04-14 06:48:44.781	2026-04-14 06:48:44.781
cmny9g6b201x4vxy4lspesloz	Mè đen	MOUNTAIN65	Kg	231000	\N	\N	\N	t	2026-04-14 06:48:45.039	2026-04-14 06:48:45.039
cmny9g6iq01xtvxy4vq4bscpb	Mè vàng	MOUNTAIN64	Kg	231000	\N	\N	\N	t	2026-04-14 06:48:45.315	2026-04-14 06:48:45.315
cmny9g6ua01yivxy4dn7aprmo	Mè trắng	MOUNTAIN63	Kg	231000	\N	\N	\N	t	2026-04-14 06:48:45.73	2026-04-14 06:48:45.73
cmny9g74f01z7vxy4k4k0zbhv	Kê nếp	MOUNTAIN62	Kg	210000	\N	\N	\N	t	2026-04-14 06:48:46.095	2026-04-14 06:48:46.095
cmny9g7cd01zwvxy48cxjla2t	Gạo thơm + Đậu xanh +Kê nếp	MOUNTAIN61	Kg	75000	\N	\N	\N	t	2026-04-14 06:48:46.382	2026-04-14 06:48:46.382
cmny9g7k0020hvxy46do5qh1y	Gạo thơm + Đậu đỏ +Kê nếp	MOUNTAIN60	Kg	75000	\N	\N	\N	t	2026-04-14 06:48:46.657	2026-04-14 06:48:46.657
cmny9g7st0212vxy49wsotw9v	Gạo thơm + Đậu đen +Kê nếp	MOUNTAIN59	Kg	75000	\N	\N	\N	t	2026-04-14 06:48:46.973	2026-04-14 06:48:46.973
cmny9g80n021nvxy4wbrssmdb	Gạo xà cơn trắng +Đậu xanh+Kê nếp	MOUNTAIN58	Kg	89000	\N	\N	\N	t	2026-04-14 06:48:47.255	2026-04-14 06:48:47.255
cmny9g87n0228vxy48fcucjjk	Gạo xà cơn trắng +Đậu đỏ+Kê nếp	MOUNTAIN57	Kg	89000	\N	\N	\N	t	2026-04-14 06:48:47.507	2026-04-14 06:48:47.507
cmny9g8ej022tvxy465wj5qd2	Gạo xà cơn trắng +Đậu đen+Kê nếp	MOUNTAIN56	Kg	89000	\N	\N	\N	t	2026-04-14 06:48:47.755	2026-04-14 06:48:47.755
cmny9g8me023evxy4nyefatpe	Gạo huyết rồng +Đậu xanh+Kê nếp	MOUNTAIN55	Kg	89000	\N	\N	\N	t	2026-04-14 06:48:48.039	2026-04-14 06:48:48.039
cmny9g8u2023zvxy4p4hnu9m3	Gạo huyết rồng +Đậu đỏ +Kê nếp	MOUNTAIN54	Kg	89000	\N	\N	\N	t	2026-04-14 06:48:48.315	2026-04-14 06:48:48.315
cmny9g926024kvxy4ngms690x	Gạo huyết rồng +Đậu đen +Kê nếp	MOUNTAIN53	Kg	89000	\N	\N	\N	t	2026-04-14 06:48:48.606	2026-04-14 06:48:48.606
cmny9g9950255vxy4en14a9a8	Gạo mix ST24+Thơm (lứt)	MOUNTAIN52	Kg	48000	\N	\N	\N	t	2026-04-14 06:48:48.857	2026-04-14 06:48:48.857
cmny9g9fr025qvxy4xolu59wy	Gạo mix ST24+Thơm (dối)	MOUNTAIN51	Kg	48000	\N	\N	\N	t	2026-04-14 06:48:49.095	2026-04-14 06:48:49.095
cmny9g9ms026bvxy4va0qhysp	Gạo mix ST24+Thơm (trắng)	MOUNTAIN50	Kg	48000	\N	\N	\N	t	2026-04-14 06:48:49.349	2026-04-14 06:48:49.349
cmny9g9uw026wvxy4yqubgqvp	Gạo trắng	MOUNTAIN49	Kg	0	\N	\N	\N	t	2026-04-14 06:48:49.64	2026-04-14 06:48:49.64
cmny9g9xd026zvxy4p2kdljn9	Trứng gà	MOUNTAIN48	Cái	5500	\N	\N	\N	t	2026-04-14 06:48:49.729	2026-04-14 06:48:49.729
cmny9g9yt0270vxy43n5w4xl8	Trứng vịt	MOUNTAIN47	Cái	5500	\N	\N	\N	t	2026-04-14 06:48:49.782	2026-04-14 06:48:49.782
cmny9ga0j0271vxy4o8ejwb2z	Rau muống hạt	MOUNTAIN46	Kg	65000	\N	\N	\N	t	2026-04-14 06:48:49.843	2026-04-14 06:48:49.843
cmny9ga9u027svxy4sf18vh1d	Lúa nếp nương	MOUNTAIN45	Kg	25500	\N	\N	\N	t	2026-04-14 06:48:50.178	2026-04-14 06:48:50.178
cmny9gabb027tvxy4dx4g5xxp	Dưa leo (đèo)	MOUNTAIN44	Kg	18000	\N	\N	\N	t	2026-04-14 06:48:50.232	2026-04-14 06:48:50.232
cmny9gahp027uvxy40a6f31vo	Lúa xà cơn trắng	MOUNTAIN43	Kg	25500	\N	\N	\N	t	2026-04-14 06:48:50.461	2026-04-14 06:48:50.461
cmny9gakf027vvxy42ms43pgw	Thơm (sz 700gr - 900gr)	MOUNTAIN42	Kg	19000	\N	\N	\N	t	2026-04-14 06:48:50.559	2026-04-14 06:48:50.559
cmny9galu027wvxy40zgedq1g	Thơm (sz 400gr-650gr)	MOUNTAIN41	Kg	16000	\N	\N	\N	t	2026-04-14 06:48:50.61	2026-04-14 06:48:50.61
cmny9ganc027xvxy4b43bsgzp	Thơm(sz 1kg trở lên)	MOUNTAIN40	Kg	21000	\N	\N	\N	t	2026-04-14 06:48:50.664	2026-04-14 06:48:50.664
cmny9gaot027yvxy40fhgxmwb	Lúa thơm	MOUNTAIN39	Kg	20000	\N	\N	\N	t	2026-04-14 06:48:50.717	2026-04-14 06:48:50.717
cmny9gaq1027zvxy4bs3xmysr	Đậu bắp	MOUNTAIN38	Kg	57000	\N	\N	\N	t	2026-04-14 06:48:50.761	2026-04-14 06:48:50.761
cmny9gazm028qvxy4fm51is9d	Lúa đỏ	MOUNTAIN37	Kg	25500	\N	\N	\N	t	2026-04-14 06:48:51.106	2026-04-14 06:48:51.106
cmny9gb11028rvxy4m22rxdoy	Diếp cá	MOUNTAIN36	Kg	86000	\N	\N	\N	t	2026-04-14 06:48:51.157	2026-04-14 06:48:51.157
cmny9gb9e029ivxy45gauj5ew	Khổ qua	MOUNTAIN35	Kg	57000	\N	\N	\N	t	2026-04-14 06:48:51.458	2026-04-14 06:48:51.458
cmny9gbif02a9vxy4fsn0ejiy	Sachi	MOUNTAIN34	Kg	0	\N	\N	\N	t	2026-04-14 06:48:51.783	2026-04-14 06:48:51.783
cmny9gbli02agvxy4pk4hxt3k	Tỏi vụng	MOUNTAIN33	Kg	100000	\N	\N	\N	t	2026-04-14 06:48:51.895	2026-04-14 06:48:51.895
cmny9gbmz02ahvxy4zoyre17e	Tỏi lột sẵn	MOUNTAIN32	Kg	0	\N	\N	\N	t	2026-04-14 06:48:51.948	2026-04-14 06:48:51.948
cmny9gbqt02aqvxy48k5qxa3f	Sét ăn dặm 1 (Gạo ST24 xát trắng + Kê nếp) 500gr	MOUNTAIN31	Gói	47000	\N	\N	\N	t	2026-04-14 06:48:52.084	2026-04-14 06:48:52.084
cmny9gc0y02bhvxy4iuoocl00	Ngãi cứu	MOUNTAIN30	Kg	86000	\N	\N	\N	t	2026-04-14 06:48:52.45	2026-04-14 06:48:52.45
cmny9gccz02c8vxy4a0zolqn2	Đương quy có lá	MOUNTAIN29	Kg	0	\N	\N	\N	t	2026-04-14 06:48:52.884	2026-04-14 06:48:52.884
cmny9gcg202cfvxy49lk7u6k9	Đương quy củ	MOUNTAIN28	Kg	0	\N	\N	\N	t	2026-04-14 06:48:52.994	2026-04-14 06:48:52.994
cmny9gcjs02cmvxy4jn48r0lt	Ớt sừng	MOUNTAIN27	Kg	72000	\N	\N	\N	t	2026-04-14 06:48:53.128	2026-04-14 06:48:53.128
cmny9gcut02ddvxy4cu8rejc7	Xà lách	MOUNTAIN26	Kg	65000	\N	\N	\N	t	2026-04-14 06:48:53.525	2026-04-14 06:48:53.525
cmny9gd1v02dyvxy4k71737mm	Ngọn bí	MOUNTAIN25	Kg	57000	\N	\N	\N	t	2026-04-14 06:48:53.779	2026-04-14 06:48:53.779
cmny9gd4302e3vxy441ff88u5	Gạo thơm dẻo trắng (xá)	MOUNTAIN24	Kg	40500	\N	\N	\N	t	2026-04-14 06:48:53.859	2026-04-14 06:48:53.859
cmny9gd6j02e8vxy4q1c6h5i4	Chanh xanh	MOUNTAIN23	Kg	60000	\N	\N	\N	t	2026-04-14 06:48:53.947	2026-04-14 06:48:53.947
cmny9gde002etvxy4djvf1jqr	Gạo ST24 + Đậu (xanh+đỏ) + Kê nếp	MOUNTAIN22	Kg	0	\N	\N	\N	t	2026-04-14 06:48:54.216	2026-04-14 06:48:54.216
cmny9gdha02f0vxy4pl8vg2ew	Gạo ST24 dối (xá )	MOUNTAIN21	Kg	50500	\N	\N	\N	t	2026-04-14 06:48:54.334	2026-04-14 06:48:54.334
cmny9gdjz02f5vxy4q10ad2fw	Gạo xà cơn trắng trắng (xá)	MOUNTAIN20	Kg	56500	\N	\N	\N	t	2026-04-14 06:48:54.431	2026-04-14 06:48:54.431
cmny9gdmd02favxy4oqlm2fo8	Gạo thơm dẻo dối (xá)	MOUNTAIN19	Kg	40500	\N	\N	\N	t	2026-04-14 06:48:54.518	2026-04-14 06:48:54.518
cmny9gdrd02ffvxy4a77fplgw	Hạt sen khô	MOUNTAIN18	Kg	0	\N	\N	\N	t	2026-04-14 06:48:54.698	2026-04-14 06:48:54.698
cmny9gdu102fkvxy4b53rgvu9	Mix đậu (xanh,đen ,trắng, đỏ)	MOUNTAIN17	Kg	0	\N	\N	\N	t	2026-04-14 06:48:54.793	2026-04-14 06:48:54.793
cmny9gdx002frvxy42oigjq5a	Nếp cái hoa vàng xát lứt - Lớp sữa	MOUNTAIN16	Kg	52000	\N	\N	\N	t	2026-04-14 06:48:54.901	2026-04-14 06:48:54.901
cmny9gdyu02fsvxy4i1updvjm	Đậu xanh (làm giá)	MOUNTAIN15	Kg	126000	\N	\N	\N	t	2026-04-14 06:48:54.967	2026-04-14 06:48:54.967
cmny9ge0p02fvvxy4zcr3h6i0	Khoai sọ gọt sẵn	MOUNTAIN14	Kg	0	\N	\N	\N	t	2026-04-14 06:48:55.034	2026-04-14 06:48:55.034
cmny9ge3b02g0vxy4eu5jf90t	Gạo ST24  trắng (xá)	MOUNTAIN13	Kg	50500	\N	\N	\N	t	2026-04-14 06:48:55.127	2026-04-14 06:48:55.127
cmny9ge5p02g5vxy4lk9iut7r	Gạo thơm xát trắng - túi 5kg (Hàng chương trình 15/1-25/1)	MOUNTAINKHD12	Túi	170000	\N	\N	\N	t	2026-04-14 06:48:55.214	2026-04-14 06:48:55.214
cmny9ge8x02gcvxy47kgz0h1g	Khoai sọ chạy số lượng từ 5kg (sale)	MOUNTAIN11	Kg	0	\N	\N	\N	t	2026-04-14 06:48:55.33	2026-04-14 06:48:55.33
cmny9geb102gfvxy47zsvk9yk	Khoai lang (héo)	MOUNTAIN10	Kg	48000	\N	\N	\N	t	2026-04-14 06:48:55.405	2026-04-14 06:48:55.405
cmny9gef902govxy4ggomag39	Cải ngồng	MOUNTAIN9	Kg	65000	\N	\N	\N	t	2026-04-14 06:48:55.557	2026-04-14 06:48:55.557
cmny9geob02h9vxy4t4c4pri0	Lúa nếp hoa vàng	MOUNTAIN8	Kg	32000	\N	\N	\N	t	2026-04-14 06:48:55.884	2026-04-14 06:48:55.884
cmny9gepx02havxy4x23z3nju	Chanh cao	MOUNTAIN7	Kg	150000	\N	\N	\N	t	2026-04-14 06:48:55.942	2026-04-14 06:48:55.942
cmny9gerc02hbvxy49fzp4qpu	Su hào	MOUNTAIN6	Kg	57000	\N	\N	\N	t	2026-04-14 06:48:55.992	2026-04-14 06:48:55.992
cmny9gf1202i2vxy4m5gm5hqe	Hành tây tím (củ nhỏ)	MOUNTAIN5	Kg	68000	\N	\N	\N	t	2026-04-14 06:48:56.342	2026-04-14 06:48:56.342
cmny9gf8o02ilvxy4vvf7to0r	Khoai sọ (củ nhỏ)	MOUNTAIN4	Kg	51000	\N	\N	\N	t	2026-04-14 06:48:56.617	2026-04-14 06:48:56.617
cmny9gfgp02j4vxy4o6f7msb1	Hoa hành	MOUNTAIN3	Kg	57000	\N	\N	\N	t	2026-04-14 06:48:56.905	2026-04-14 06:48:56.905
cmny9gfp102jvvxy4pm0kptgh	Táo (anh Vàng)	MOUNTAIN2	Kg	65000	\N	\N	\N	t	2026-04-14 06:48:57.206	2026-04-14 06:48:57.206
cmny9gfqa02jwvxy4sidey8jw	Cải bẹ xanh	MOUNTAIN1	Kg	65000	\N	\N	\N	t	2026-04-14 06:48:57.25	2026-04-14 06:48:57.25
cmny9gfx302khvxy4vswa3e63	Măng luộc	XUANLOC152	Kg	79000	\N	\N	\N	t	2026-04-14 06:48:57.495	2026-04-14 06:48:57.495
cmny9gg6t02l8vxy4tqeh3tju	Bột gạo huyết rồng	XUANLOC151	Hủ	100000	\N	\N	\N	t	2026-04-14 06:48:57.845	2026-04-14 06:48:57.845
cmny9gggc02lvvxy4gsp90vfj	Bột ngũ đậu (hủ 500gr)	XUANLOC150	Hủ	175000	\N	\N	\N	t	2026-04-14 06:48:58.188	2026-04-14 06:48:58.188
cmny9ggpb02mivxy41bqgb3cr	Xá bấu (gói 200gr)	XUANLOC149	Gói	23000	\N	\N	\N	t	2026-04-14 06:48:58.512	2026-04-14 06:48:58.512
cmny9ggyl02n5vxy4hpe88pst	Mè đen rang ( gói 100gr)	XUANLOC148	Gói	36000	\N	\N	\N	t	2026-04-14 06:48:58.845	2026-04-14 06:48:58.845
cmny9gh7o02nsvxy4a91nwotv	Măng chua (ớt, tỏi) (gói 150gr)	XUANLOC147	Gói	30000	\N	\N	\N	t	2026-04-14 06:48:59.172	2026-04-14 06:48:59.172
cmny9ghgg02ofvxy4bqth4pt4	Ngò sấy khô (100gr)	XUANLOC146	Gói	110000	\N	\N	\N	t	2026-04-14 06:48:59.488	2026-04-14 06:48:59.488
cmny9ghqe02p2vxy470v027kp	Bột ngũ cốc baby (hủ 500gr)	XUANLOC145	Hủ	200000	\N	\N	\N	t	2026-04-14 06:48:59.846	2026-04-14 06:48:59.846
cmny9ghzm02ppvxy4b1qduz0d	Bột nghệ gia vị (gói 100gr)	XUANLOC144	Gói	105000	\N	\N	\N	t	2026-04-14 06:49:00.178	2026-04-14 06:49:00.178
cmny9gi2x02pwvxy4wog9eue2	Trà gạo lứt rang cháy (gói 250gr)	XUANLOC143	Gói	45000	\N	\N	\N	t	2026-04-14 06:49:00.297	2026-04-14 06:49:00.297
cmny9gibn02qjvxy4slwgu2dz	Bột ngũ cốc nảy mầm (hủ 500gr)	XUANLOC142	Hủ	215000	\N	\N	\N	t	2026-04-14 06:49:00.611	2026-04-14 06:49:00.611
cmny9gilf02r6vxy49g38invx	Sate ớt (đóng xá)	XUANLOC141	Kg	0	\N	\N	\N	t	2026-04-14 06:49:00.963	2026-04-14 06:49:00.963
cmny9gin802r7vxy4iblmdrsa	Bột khoai môn (gói 100gr)	XUANLOC140	Gói	54000	\N	\N	\N	t	2026-04-14 06:49:01.028	2026-04-14 06:49:01.028
cmny9giyz02ruvxy4s14ulepv	Bột khoai lang (gói 100gr)	XUANLOC139	Gói	54000	\N	\N	\N	t	2026-04-14 06:49:01.451	2026-04-14 06:49:01.451
cmny9gjaj02shvxy4h18olfo4	Bột bí đỏ (gói 100gr)	XUANLOC138	Gói	54000	\N	\N	\N	t	2026-04-14 06:49:01.867	2026-04-14 06:49:01.867
cmny9gjpy02t4vxy4vnf31ad2	Chanh đào mật ong (hủ 250ml)	XUANLOC137	Hủ	88000	\N	\N	\N	t	2026-04-14 06:49:02.422	2026-04-14 06:49:02.422
cmny9gk3z02trvxy4jto8i1o6	Mật ong rừng	MOUNTAIN160	Lít	900000	\N	\N	\N	t	2026-04-14 06:49:02.927	2026-04-14 06:49:02.927
cmny9gkb902u0vxy4nyewufpm	Khoai lang khô (gói 250gr)	XUANLOC135	Kg	72000	\N	\N	\N	t	2026-04-14 06:49:03.189	2026-04-14 06:49:03.189
cmny9gkt302unvxy4mlma5f9w	Bột nghệ gia vị (xá)	XUANLOC134	Kg	0	\N	\N	\N	t	2026-04-14 06:49:03.832	2026-04-14 06:49:03.832
cmny9gl2p02vavxy41pnrbpjb	Bột gạo	XUANLOC133	Kg	114000	\N	\N	\N	t	2026-04-14 06:49:04.178	2026-04-14 06:49:04.178
cmny9glcn02vxvxy49n0w7a07	Bột nếp	XUANLOC132	Kg	120000	\N	\N	\N	t	2026-04-14 06:49:04.535	2026-04-14 06:49:04.535
cmny9glme02wkvxy4tk6d21q5	Nước chuối len men (350ml)	XUANLOC131	Chai	129000	\N	\N	\N	t	2026-04-14 06:49:04.887	2026-04-14 06:49:04.887
cmny9glw502x7vxy4nahgc1d1	Phở gạo trắng	XUANLOC130	Kg	130000	\N	\N	\N	t	2026-04-14 06:49:05.238	2026-04-14 06:49:05.238
cmny9gmat02xuvxy4xxszxxur	Phở gạo lứt	XUANLOC129	Kg	130000	\N	\N	\N	t	2026-04-14 06:49:05.766	2026-04-14 06:49:05.766
cmny9gmju02yhvxy450sl0ev7	Phở gạo gấc	XUANLOC128	Kg	130000	\N	\N	\N	t	2026-04-14 06:49:06.09	2026-04-14 06:49:06.09
cmny9gmto02z4vxy4invdhxc2	Phở gạo mè đen	XUANLOC127	Kg	130000	\N	\N	\N	t	2026-04-14 06:49:06.444	2026-04-14 06:49:06.444
cmny9gn2902zrvxy4ksvqjjal	Bún gạo trắng	XUANLOC126	Kg	130000	\N	\N	\N	t	2026-04-14 06:49:06.753	2026-04-14 06:49:06.753
cmny9gnbk030evxy4xric0xyd	Bún gạo gấc	XUANLOC125	Kg	130000	\N	\N	\N	t	2026-04-14 06:49:07.086	2026-04-14 06:49:07.086
cmny9gnkh0311vxy49s1hihp3	Bún gạo lứt	XUANLOC124	Kg	130000	\N	\N	\N	t	2026-04-14 06:49:07.409	2026-04-14 06:49:07.409
cmny9gnu0031ovxy484nhm36a	Bún gạo mè đen	XUANLOC123	Kg	130000	\N	\N	\N	t	2026-04-14 06:49:07.753	2026-04-14 06:49:07.753
cmny9go2c032bvxy4dcx2lbtg	Phở gạo đậu đỏ	XUANLOC122	Kg	130000	\N	\N	\N	t	2026-04-14 06:49:08.052	2026-04-14 06:49:08.052
cmny9goc9032yvxy4ivxj55za	Mật ong cà phê	MOUNTAIN161	Lít	0	\N	\N	\N	t	2026-04-14 06:49:08.409	2026-04-14 06:49:08.409
cmny9god7032zvxy43dhi6nyh	Bún gạo đậu đỏ	XUANLOC120	Kg	130000	\N	\N	\N	t	2026-04-14 06:49:08.444	2026-04-14 06:49:08.444
cmny9golj033mvxy4fxz1uz14	Phở mix	XUANLOC119	Kg	130000	\N	\N	\N	t	2026-04-14 06:49:08.743	2026-04-14 06:49:08.743
cmny9gou30349vxy417ukkci3	Bún mix	XUANLOC118	Kg	130000	\N	\N	\N	t	2026-04-14 06:49:09.052	2026-04-14 06:49:09.052
cmny9gp2g034wvxy4nxi3ds97	Bột gừng pha uống (hủ 50gr)	XUANLOC117	Hủ	85000	\N	\N	\N	t	2026-04-14 06:49:09.352	2026-04-14 06:49:09.352
cmny9gpb8035jvxy4a8cw3p52	Bột gừng gia vị (hủ 50gr)	XUANLOC116	Hủ	80000	\N	\N	\N	t	2026-04-14 06:49:09.668	2026-04-14 06:49:09.668
cmny9gpk90366vxy425xjt8ti	Bột nghệ gia vị (hủ 50gr)	XUANLOC115	Hủ	75000	\N	\N	\N	t	2026-04-14 06:49:09.994	2026-04-14 06:49:09.994
cmny9gpts036tvxy4j04h5bu8	Bột hành tây tím gia vị (hủ 50gr)	XUANLOC114	Hủ	143000	\N	\N	\N	t	2026-04-14 06:49:10.336	2026-04-14 06:49:10.336
cmny9gq26037gvxy4d5rte7wh	Trà đậu đen (gói 500gr)	XUANLOC113	Gói	0	\N	\N	\N	t	2026-04-14 06:49:10.638	2026-04-14 06:49:10.638
cmny9gqaw0383vxy45nnjxnm8	Trà đậu gạo (gói 500gr)	XUANLOC112	Gói	0	\N	\N	\N	t	2026-04-14 06:49:10.952	2026-04-14 06:49:10.952
cmny9gqjg038qvxy4lq1wn1to	Bột hành tím gia vị (hủ 50gr)	XUANLOC111	Hủ	143000	\N	\N	\N	t	2026-04-14 06:49:11.26	2026-04-14 06:49:11.26
cmny9gqrs039dvxy4huz655w3	Bột sả gia vị (hủ 50gr)	XUANLOC110	Hủ	70000	\N	\N	\N	t	2026-04-14 06:49:11.56	2026-04-14 06:49:11.56
cmny9gr0l03a0vxy4xe1ur18a	Bột tỏi gia vị (hủ 50gr)	XUANLOC109	Hủ	150000	\N	\N	\N	t	2026-04-14 06:49:11.877	2026-04-14 06:49:11.877
cmny9grbq03anvxy4q1qesql4	Trà gạo lứt (gói 250gr)	XUANLOC108	Gói	45000	\N	\N	\N	t	2026-04-14 06:49:12.278	2026-04-14 06:49:12.278
cmny9grka03bavxy4qrrqb2oy	Sâm dây khô	XUANLOC107	Kg	800000	\N	\N	\N	t	2026-04-14 06:49:12.586	2026-04-14 06:49:12.586
cmny9gro703bbvxy4s5r0qmyj	Nghệ khô (xá)	XUANLOC106	Kg	0	\N	\N	\N	t	2026-04-14 06:49:12.727	2026-04-14 06:49:12.727
cmny9grwz03byvxy4175rk1tz	Chanh đào mật ong (hủ 500ml)	XUANLOC105	Hủ	150000	\N	\N	\N	t	2026-04-14 06:49:13.043	2026-04-14 06:49:13.043
cmny9gs5b03clvxy4jrmcgp21	Muối ngâm chân	XUANLOC104	Hủ	79000	\N	\N	\N	t	2026-04-14 06:49:13.344	2026-04-14 06:49:13.344
cmny9gsdp03d8vxy445qqlyap	Bột gừng uống (xá)	XUANLOC103	Kg	0	\N	\N	\N	t	2026-04-14 06:49:13.645	2026-04-14 06:49:13.645
cmny9gsev03d9vxy467xa4wus	Nước dâu tằm lên men (350ml)	XUANLOC102	Chai	98000	\N	\N	\N	t	2026-04-14 06:49:13.688	2026-04-14 06:49:13.688
cmny9gsn503dwvxy4tavnf8kz	Nghệ ngâm mật ong (250ml)	XUANLOC101	Hủ	112000	\N	\N	\N	t	2026-04-14 06:49:13.986	2026-04-14 06:49:13.986
cmny9gswv03ejvxy4lcxc3yl6	Táo mèo ngâm mật ong (350ml)	XUANLOC100	Chai	155000	\N	\N	\N	t	2026-04-14 06:49:14.336	2026-04-14 06:49:14.336
cmny9gt6w03f6vxy48y0d9dhc	Bột gừng mật ong (hủ 250ml)	XUANLOC99	Hủ	140000	\N	\N	\N	t	2026-04-14 06:49:14.696	2026-04-14 06:49:14.696
cmny9gtfe03ftvxy4gbtnj0jv	Giấm táo mèo	XUANLOC98	Chai	58000	\N	\N	\N	t	2026-04-14 06:49:15.003	2026-04-14 06:49:15.003
cmny9gtgt03fuvxy4v5edc9ah	Miến dong	XUANLOC97	Kg	206000	\N	\N	\N	t	2026-04-14 06:49:15.054	2026-04-14 06:49:15.054
cmny9gtq203ghvxy4bs4g9r5d	Nước dâu tằm lên men	XUANLOC96	Lít	230000	\N	\N	\N	t	2026-04-14 06:49:15.387	2026-04-14 06:49:15.387
cmny9gu7w03h4vxy4aggamt9m	Trà đậu gạo (gói 250gr)	XUANLOC95	Gói	65000	\N	\N	\N	t	2026-04-14 06:49:16.028	2026-04-14 06:49:16.028
cmny9gv7r03hrvxy4yewz17vq	Hủ tiếu khô	XUANLOC94	Kg	150000	\N	\N	\N	t	2026-04-14 06:49:17.32	2026-04-14 06:49:17.32
cmny9gvsc03ievxy480o0kutd	Bánh nổ có đường (gói 200gr)	XUANLOC93	Gói	41000	\N	\N	\N	t	2026-04-14 06:49:18.061	2026-04-14 06:49:18.061
cmny9gw4e03j1vxy44tl5siu8	Bột mình tinh	XUANLOC92	Kg	267000	\N	\N	\N	t	2026-04-14 06:49:18.495	2026-04-14 06:49:18.495
cmny9gwdc03jovxy4kekpdhxc	Bột ngũ cốc (hủ 500gr)	XUANLOC91	Hủ	158000	\N	\N	\N	t	2026-04-14 06:49:18.816	2026-04-14 06:49:18.816
cmny9gwmg03kbvxy4nxom8jr8	Bột gừng gia vị (xá)	XUANLOC90	Kg	0	\N	\N	\N	t	2026-04-14 06:49:19.144	2026-04-14 06:49:19.144
cmny9gwnr03kcvxy439da62yq	Bột riềng gia vị (hủ 50gr)	XUANLOC89	Hủ	70000	\N	\N	\N	t	2026-04-14 06:49:19.191	2026-04-14 06:49:19.191
cmny9gx0c03kzvxy4b4c18ikm	Gừng gia vị sấy lát	XUANLOC88	Kg	870000	\N	\N	\N	t	2026-04-14 06:49:19.644	2026-04-14 06:49:19.644
cmny9gxcl03lmvxy4lcfsuq5u	Bột ớt đỏ gia vị (hủ 50gr)	XUANLOC87	Hủ	80000	\N	\N	\N	t	2026-04-14 06:49:20.086	2026-04-14 06:49:20.086
cmny9gxt103m9vxy4ekmhaj4q	Tắc ngâm mật ong (hủ 250ml)	XUANLOC86	Hủ	88000	\N	\N	\N	t	2026-04-14 06:49:20.678	2026-04-14 06:49:20.678
cmny9gy5s03mwvxy400jtd20o	Sả sấy lát (xá)	XUANLOC85	Kg	0	\N	\N	\N	t	2026-04-14 06:49:21.136	2026-04-14 06:49:21.136
cmny9gyjg03njvxy45645uprt	Gừng lát ngâm mật ong (250ml)	XUANLOC84	Hủ	119000	\N	\N	\N	t	2026-04-14 06:49:21.628	2026-04-14 06:49:21.628
cmny9gyxt03o6vxy49w9d18ma	Trà tía tô (50gr)	XUANLOC83	Gói	43000	\N	\N	\N	t	2026-04-14 06:49:22.145	2026-04-14 06:49:22.145
cmny9gzar03otvxy4hzf17iaf	Bơ đậu phộng (hủ 300gr)	XUANLOC82	Hủ	107000	\N	\N	\N	t	2026-04-14 06:49:22.611	2026-04-14 06:49:22.611
cmny9gzmb03pgvxy4zp1bb5q8	Bơ đậu phộng (hủ 150gr)	XUANLOC81	Hủ	68000	\N	\N	\N	t	2026-04-14 06:49:23.028	2026-04-14 06:49:23.028
cmny9gzx803q3vxy4uev1plkr	Nghệ sấy lát (xá)	XUANLOC80	Kg	0	\N	\N	\N	t	2026-04-14 06:49:23.42	2026-04-14 06:49:23.42
cmny9h08j03qqvxy4sn40s412	Ớt khô nguyên trái (gói 50gr)	XUANLOC79	Gói	41000	\N	\N	\N	t	2026-04-14 06:49:23.827	2026-04-14 06:49:23.827
cmny9h0p703rdvxy4n7050gnm	Gừng gia vị sấy lát (gói 50gr)	XUANLOC78	Gói	45000	\N	\N	\N	t	2026-04-14 06:49:24.427	2026-04-14 06:49:24.427
cmny9h10b03s0vxy4etpnganx	Trà sả (sả sấy khô)(gói 50gr)	XUANLOC77	Gói	40000	\N	\N	\N	t	2026-04-14 06:49:24.828	2026-04-14 06:49:24.828
cmny9h1gr03snvxy4gd7copgl	Nước nho lên men (350ml)	XUANLOC76	Chai	98000	\N	\N	\N	t	2026-04-14 06:49:25.419	2026-04-14 06:49:25.419
cmny9h1t103tavxy4l41zkqt5	Măng chua (ớt, tỏi) (hủ 500gr)	XUANLOC75	Hủ	70000	\N	\N	\N	t	2026-04-14 06:49:25.861	2026-04-14 06:49:25.861
cmny9h2bl03txvxy43g6cpnh6	Nghệ sấy lát (gói 50gr)	XUANLOC74	Gói	43000	\N	\N	\N	t	2026-04-14 06:49:26.529	2026-04-14 06:49:26.529
cmny9h2oa03ukvxy4rzab1vbm	Trà gừng (gừng uống sấy lát) (gói 100gr)	XUANLOC73	Gói	95000	\N	\N	\N	t	2026-04-14 06:49:26.986	2026-04-14 06:49:26.986
cmny9h37a03v7vxy4os1u1eid	Hành tím khô sấy lát (gói 50gr)	XUANLOC72	Gói	106000	\N	\N	\N	t	2026-04-14 06:49:27.67	2026-04-14 06:49:27.67
cmny9h3hw03vuvxy4yu40k26w	Tỏi khô sấy lát (gói 50gr)	XUANLOC71	Gói	113000	\N	\N	\N	t	2026-04-14 06:49:28.052	2026-04-14 06:49:28.052
cmny9h3md03w1vxy43mwva72s	Xá bấu	XUANLOC70	Kg	0	\N	\N	\N	t	2026-04-14 06:49:28.214	2026-04-14 06:49:28.214
cmny9h3q303w4vxy40ffz36vn	Bánh nổ không đường (gói 200gr)	XUANLOC69	Gói	41000	\N	\N	\N	t	2026-04-14 06:49:28.348	2026-04-14 06:49:28.348
cmny9h44l03wrvxy4bhk44lc5	Bột mè cửu chưng cửu sái (hủ 100gr)	XUANLOC68	Hủ	65000	\N	\N	\N	t	2026-04-14 06:49:28.869	2026-04-14 06:49:28.869
cmny9h49r03wwvxy4w03e6dhk	Mè cửu chưng cửu sái (hủ 200gr)	XUANLOC67	Hủ	185000	\N	\N	\N	t	2026-04-14 06:49:29.055	2026-04-14 06:49:29.055
cmny9h4nc03xjvxy4kdly6h45	Dưa leo muối ngọt (gói 150gr)	XUANLOC66	Gói	36000	\N	\N	\N	t	2026-04-14 06:49:29.545	2026-04-14 06:49:29.545
cmny9h55e03y6vxy4ylao22x8	Sét nấu nước 7 gói (Mã đề+ Rau má + Rau bắp + Rễ cỏ tranh)	XUANLOC65	Gói	120000	\N	\N	\N	t	2026-04-14 06:49:30.194	2026-04-14 06:49:30.194
cmny9h5ho03ytvxy4arorbuhj	Hoài sơn (gói 50gr)	XUANLOC64	Gói	50000	\N	\N	\N	t	2026-04-14 06:49:30.637	2026-04-14 06:49:30.637
cmny9h5ju03yuvxy4v7aj8lsd	Bơ đậu phộng (hủ 5kg)	XUANLOC63	Hủ	0	\N	\N	\N	t	2026-04-14 06:49:30.715	2026-04-14 06:49:30.715
cmny9h5xn03zhvxy46ymlfk87	Hoài sơn	XUANLOC62	Kg	0	\N	\N	\N	t	2026-04-14 06:49:31.211	2026-04-14 06:49:31.211
cmny9h6n40404vxy469hagl5z	Sét hầm nước 7 món (gói 90gr-100gr)	XUANLOC61	Gói	89000	\N	\N	\N	t	2026-04-14 06:49:32.128	2026-04-14 06:49:32.128
cmny9h7aa040rvxy42kh0s52n	Trà sâm dây (hủ 100gr)	XUANLOC60	Hủ	180000	\N	\N	\N	t	2026-04-14 06:49:32.962	2026-04-14 06:49:32.962
cmny9h7w0041evxy4fa4nplgz	Sét hầm gà (sâm+bo bo+kê+gừng+ hoài sơn)	XUANLOC59	Gói	0	\N	\N	\N	t	2026-04-14 06:49:33.744	2026-04-14 06:49:33.744
cmny9h80s041hvxy4al5el0no	Sét hầm gà (sâm+bo bo+kê+nấm+gừng+ hoài sơn)	XUANLOC58	Gói	0	\N	\N	\N	t	2026-04-14 06:49:33.916	2026-04-14 06:49:33.916
cmny9h84x041kvxy4ogrq35lg	Dầu hành phi (hủ 150gr)	XUANLOC57	Hủ	89000	\N	\N	\N	t	2026-04-14 06:49:34.065	2026-04-14 06:49:34.065
cmny9h8oi0427vxy4lzl6s6c3	Trà đậu săng (gói 250gr)	XUANLOC56	Gói	100000	\N	\N	\N	t	2026-04-14 06:49:34.771	2026-04-14 06:49:34.771
cmny9h926042uvxy43u6dzp9o	Ngãi cứu sấy khô (gói 50gr)	XUANLOC55	Gói	52000	\N	\N	\N	t	2026-04-14 06:49:35.262	2026-04-14 06:49:35.262
cmny9ha0u043hvxy4biq8zww0	Củ cải khô	XUANLOC54	Kg	0	\N	\N	\N	t	2026-04-14 06:49:36.511	2026-04-14 06:49:36.511
cmny9hagl0444vxy40m9hvfrt	Hành tím muối chua (hủ 250gr)	XUANLOC53	Hủ	70000	\N	\N	\N	t	2026-04-14 06:49:37.078	2026-04-14 06:49:37.078
cmny9hawk044rvxy4h7bra21r	Rau má sấy khô (50gr)	XUANLOC52	Gói	55000	\N	\N	\N	t	2026-04-14 06:49:37.652	2026-04-14 06:49:37.652
cmny9hbh7045evxy4qbbtqq1x	Sét hạt hoài sơn kê bo bo	XUANLOC51	Gói	59000	\N	\N	\N	t	2026-04-14 06:49:38.395	2026-04-14 06:49:38.395
cmny9hbs20461vxy40qacr9vy	Củ cải khô (gói 100gr)	XUANLOC50	Gói	72000	\N	\N	\N	t	2026-04-14 06:49:38.787	2026-04-14 06:49:38.787
cmny9hc0e046ovxy4ogexfwka	Hành lá sấy khô (50gr)	XUANLOC49	Gói	55000	\N	\N	\N	t	2026-04-14 06:49:39.087	2026-04-14 06:49:39.087
cmny9hcc7047bvxy4yltr6q4y	Hành tây khô sấy lát (gói 50gr)	XUANLOC48	Gói	106000	\N	\N	\N	t	2026-04-14 06:49:39.512	2026-04-14 06:49:39.512
cmny9hctl047yvxy4h9dvg2at	Gừng chua ngọt (gói 200gr)	XUANLOC47	Gói	70000	\N	\N	\N	t	2026-04-14 06:49:40.137	2026-04-14 06:49:40.137
cmny9hd5m048lvxy49egji9jw	Củ cải nguyên củ khô (gói 100gr)	XUANLOC46	Gói	72000	\N	\N	\N	t	2026-04-14 06:49:40.57	2026-04-14 06:49:40.57
cmny9hddz0498vxy4ls4h37y5	Cải muối chua nguyên cây	XUANLOC45	Kg	85000	\N	\N	\N	t	2026-04-14 06:49:40.871	2026-04-14 06:49:40.871
cmny9hdnw049vvxy4olznmp3x	Cà rốt sấy khô (gói 100gr)	XUANLOC44	Gói	80000	\N	\N	\N	t	2026-04-14 06:49:41.229	2026-04-14 06:49:41.229
cmny9hdw904aivxy4uhxowmka	Dầu đậu phộng	XUANLOC43	Lít	285000	\N	\N	\N	t	2026-04-14 06:49:41.529	2026-04-14 06:49:41.529
cmny9he4k04b5vxy4lwgayqmk	Sate ớt	XUANLOC42	Hủ	89000	\N	\N	\N	t	2026-04-14 06:49:41.829	2026-04-14 06:49:41.829
cmny9hecx04bsvxy43o6ia3fl	Sate ớt sả	XUANLOC41	Hủ	89000	\N	\N	\N	t	2026-04-14 06:49:42.129	2026-04-14 06:49:42.129
cmny9hel804cfvxy4ihe8l77l	Sate ớt sả tỏi	XUANLOC40	Hủ	89000	\N	\N	\N	t	2026-04-14 06:49:42.429	2026-04-14 06:49:42.429
cmny9hevf04d2vxy4rqwhta1s	Sate ớt tỏi	XUANLOC39	Hủ	89000	\N	\N	\N	t	2026-04-14 06:49:42.795	2026-04-14 06:49:42.795
cmny9hf4804dpvxy4c1dwxlqv	Dầu điều màu (250ml)	XUANLOC38	Chai	113000	\N	\N	\N	t	2026-04-14 06:49:43.113	2026-04-14 06:49:43.113
cmny9hfe604ecvxy4c2vufdv8	Dầu điều màu (100ml)	XUANLOC37	Chai	59000	\N	\N	\N	t	2026-04-14 06:49:43.47	2026-04-14 06:49:43.47
cmny9hfmp04ezvxy4ra2tztwz	Dầu mè đen (250ml)	XUANLOC36	Chai	158000	\N	\N	\N	t	2026-04-14 06:49:43.777	2026-04-14 06:49:43.777
cmny9hfv004fmvxy4mzp4n5p7	Măng khô (gói 100gr)	XUANLOC35	Gói	60000	\N	\N	\N	t	2026-04-14 06:49:44.077	2026-04-14 06:49:44.077
cmny9hg8c04gdvxy41u388239	Măng khô (gói 200gr)	XUANLOC34	Gói	117000	\N	\N	\N	t	2026-04-14 06:49:44.556	2026-04-14 06:49:44.556
cmny9hgky04h4vxy4bnfj3yh8	Mít luộc	XUANLOC33	Kg	0	\N	\N	\N	t	2026-04-14 06:49:45.01	2026-04-14 06:49:45.01
cmny9hguo04hvvxy4838pvmi3	Bánh tráng nướng	XUANLOC32	Cái	6000	\N	\N	\N	t	2026-04-14 06:49:45.361	2026-04-14 06:49:45.361
cmny9hgvv04hwvxy43s6mss7r	Bột đậu đen cửu chưng cửu sái (200gr)	XUANLOC31	Hủ	76000	\N	\N	\N	t	2026-04-14 06:49:45.404	2026-04-14 06:49:45.404
cmny9hgz004i1vxy4o9vgwwbu	Bột ớt đỏ gia vị (xá)	XUANLOC30	Kg	858000	\N	\N	\N	t	2026-04-14 06:49:45.516	2026-04-14 06:49:45.516
cmny9hh3204iavxy43i1hvklb	Phở gạo trắng (tặng)	XUANLOC29	Kg	0	\N	\N	\N	t	2026-04-14 06:49:45.663	2026-04-14 06:49:45.663
cmny9hh4004ibvxy4sdj15h6x	Bột đậu đen cửu chưng cửu sái (500gr)	XUANLOC28	Hủ	168000	\N	\N	\N	t	2026-04-14 06:49:45.696	2026-04-14 06:49:45.696
cmny9hh6c04igvxy41c0m34lr	Trà tía tô (xá)	XUANLOC27	Kg	0	\N	\N	\N	t	2026-04-14 06:49:45.78	2026-04-14 06:49:45.78
cmny9hh8u04ilvxy4gmh3u1kz	Sét canh hầm bổ tỳ (Bo Bo, Hoài sơn, Táo đỏ, Gừng)	XUANLOC26	Gói	47000	\N	\N	\N	t	2026-04-14 06:49:45.871	2026-04-14 06:49:45.871
cmny9hhcb04isvxy47xmb4sop	Sét cháo nếp táo đỏ hạt sen gừng	XUANLOC25	Gói	55000	\N	\N	\N	t	2026-04-14 06:49:45.996	2026-04-14 06:49:45.996
cmny9hhfb04izvxy4yce9ho2n	Sét cháo nếp táo đỏ gừng	XUANLOC24	Gói	47000	\N	\N	\N	t	2026-04-14 06:49:46.104	2026-04-14 06:49:46.104
cmny9hhib04j6vxy4ezeunvvv	Bột gừng pha uống (hủ 100gr)	XUANLOC23	Hủ	160000	\N	\N	\N	t	2026-04-14 06:49:46.212	2026-04-14 06:49:46.212
cmny9hhje04j7vxy4wnrk61m8	Bột ớt đỏ gia vị (gói 100gr)	XUANLOC22	Gói	118000	\N	\N	\N	t	2026-04-14 06:49:46.251	2026-04-14 06:49:46.251
cmny9hhmk04jevxy4t1u0w466	Trà sâm dây (gói 300gr)	XUANLOC21	Gói	525000	\N	\N	\N	t	2026-04-14 06:49:46.364	2026-04-14 06:49:46.364
cmny9hhni04jfvxy4fvzn70xh	Mứt gừng dẻo đường cát lu (hủ 200gr)	XUANLOC20	Hủ	79000	\N	\N	\N	t	2026-04-14 06:49:46.399	2026-04-14 06:49:46.399
cmny9hhqo04jmvxy4dw4ujjby	Hành tây sấy (kg)	XUANLOC19	Kg	0	\N	\N	\N	t	2026-04-14 06:49:46.512	2026-04-14 06:49:46.512
cmny9hht104jrvxy44q7kx1uc	Hành lá khô (kg)	XUANLOC18	Kg	0	\N	\N	\N	t	2026-04-14 06:49:46.597	2026-04-14 06:49:46.597
cmny9hhv904jwvxy4cbzb9f41	Sâm dây ngâm mật ong (hủ 120gr)	XUANLOC17	Hủ	178000	\N	\N	\N	t	2026-04-14 06:49:46.678	2026-04-14 06:49:46.678
cmny9hhya04k3vxy47fprunca	Măng khô (xá)	XUANLOC16	Kg	0	\N	\N	\N	t	2026-04-14 06:49:46.786	2026-04-14 06:49:46.786
cmny9hi0n04k8vxy4ntc3rmhu	Mứt gừng dẻo đường mía thô (hủ 200gr)	XUANLOC15	Hủ	130000	\N	\N	\N	t	2026-04-14 06:49:46.872	2026-04-14 06:49:46.872
cmny9hi3o04kfvxy4bwn7bmx7	Bột gạo xà cơn trắng (xay thô) hủ 500gr	XUANLOC14	Hủ	75000	\N	\N	\N	t	2026-04-14 06:49:46.981	2026-04-14 06:49:46.981
cmny9hi6x04kmvxy4jk7tyvbg	Bột gạo huyết rồng (xay thô) hủ 500gr	XUANLOC13	Hủ	75000	\N	\N	\N	t	2026-04-14 06:49:47.097	2026-04-14 06:49:47.097
cmny9hiao04ktvxy4foua0u8p	Dầu mè đen	XUANLOC12	Lít	570000	\N	\N	\N	t	2026-04-14 06:49:47.232	2026-04-14 06:49:47.232
cmny9hidu04l0vxy48dx9317f	Ớt khô nguyên trái (xá)	XUANLOC11	Gói	0	\N	\N	\N	t	2026-04-14 06:49:47.346	2026-04-14 06:49:47.346
cmny9hijm04l7vxy4sc2h44br	Mứt gừng dẻo đường mía thô (hủ 500gr)	XUANLOC10	Hủ	315000	\N	\N	\N	t	2026-04-14 06:49:47.554	2026-04-14 06:49:47.554
cmny9himm04levxy45r7jvq2v	Rau bắp khô (100gr)	XUANLOC9	Gói	0	\N	\N	\N	t	2026-04-14 06:49:47.662	2026-04-14 06:49:47.662
cmny9hipg04ljvxy4ha2ju0vq	Rau bắp khô (100gr).	XUANLOC8	Gói	0	\N	\N	\N	t	2026-04-14 06:49:47.764	2026-04-14 06:49:47.764
cmny9hiry04lovxy4u42lsq73	Sét nấu sữa hạt 15 gói	XUANLOC7	Set	295000	\N	\N	\N	t	2026-04-14 06:49:47.854	2026-04-14 06:49:47.854
cmny9hiv804lvvxy4qciwkqwe	Đậu ván rang củi (500gr)	XUANLOC6	Gói	130000	\N	\N	\N	t	2026-04-14 06:49:47.972	2026-04-14 06:49:47.972
cmny9hiyf04m2vxy4s0nh4tvt	Gói nấu sữa hạt 50gr	XUANLOC5	Set	20000	\N	\N	\N	t	2026-04-14 06:49:48.088	2026-04-14 06:49:48.088
cmny9hizn04m3vxy4xt84mp84	Sét trà mát dưỡng huyết 7 gói (bo bo, xích tiểu đậu, rau bắp)	XUANLOC4	Set	125000	\N	\N	\N	t	2026-04-14 06:49:48.132	2026-04-14 06:49:48.132
cmny9hj1x04m8vxy4nm9axlnb	Sét trà gừng sả 7 gói	XUANLOC3	Gói	54000	\N	\N	\N	t	2026-04-14 06:49:48.213	2026-04-14 06:49:48.213
cmny9hj4p04mdvxy4xt87ymo4	Sét trà gừng sả táo đỏ kỷ tử 7 gói	XUANLOC2	Gói	234000	\N	\N	\N	t	2026-04-14 06:49:48.313	2026-04-14 06:49:48.313
cmny9hj6z04mivxy4pjiwg2kt	Măng khô (gói 500gr)	XUANLOC1	Gói	0	\N	\N	\N	t	2026-04-14 06:49:48.395	2026-04-14 06:49:48.395
cmny9hjcs04mpvxy4dxlddvkx	Cật	HANGTUOI51	Kg	191000	\N	\N	\N	t	2026-04-14 06:49:48.605	2026-04-14 06:49:48.605
cmny9hjei04mqvxy4bimaklr2	Huyết	HANGTUOI50	Kg	0	\N	\N	\N	t	2026-04-14 06:49:48.666	2026-04-14 06:49:48.666
cmny9hjgf04mtvxy4wnmlhbzv	Cuốn họng	HANGTUOI49	Kg	0	\N	\N	\N	t	2026-04-14 06:49:48.735	2026-04-14 06:49:48.735
cmny9hjhv04muvxy4zxm79hu3	Ba chỉ rút xương	HANGTUOI48	Kg	234000	\N	\N	\N	t	2026-04-14 06:49:48.787	2026-04-14 06:49:48.787
cmny9hjla04mzvxy4sxy2t9ei	Cốt lết	HANGTUOI47	Kg	234000	\N	\N	\N	t	2026-04-14 06:49:48.907	2026-04-14 06:49:48.907
cmny9hjp104n4vxy4b4rltjlf	Đùi	HANGTUOI46	Kg	234000	\N	\N	\N	t	2026-04-14 06:49:49.045	2026-04-14 06:49:49.045
cmny9hjrd04n9vxy4lk6cnv72	Đuôi	HANGTUOI45	Kg	234000	\N	\N	\N	t	2026-04-14 06:49:49.129	2026-04-14 06:49:49.129
cmny9hjsz04ncvxy4tu690jer	Nạc dăm	HANGTUOI44	Kg	234000	\N	\N	\N	t	2026-04-14 06:49:49.187	2026-04-14 06:49:49.187
cmny9hjv904nhvxy4yhlnl4dz	Thịt xay	HANGTUOI43	Kg	234000	\N	\N	\N	t	2026-04-14 06:49:49.269	2026-04-14 06:49:49.269
cmny9hjwn04nkvxy4dhxd5jaw	Giò	HANGTUOI42	Kg	234000	\N	\N	\N	t	2026-04-14 06:49:49.319	2026-04-14 06:49:49.319
cmny9hjy904nnvxy4p6rpeqv8	Sườn non	HANGTUOI41	Kg	244000	\N	\N	\N	t	2026-04-14 06:49:49.377	2026-04-14 06:49:49.377
cmny9hk0e04nsvxy4386p36zl	Dồi huyết	HANGTUOI40	Kg	191000	\N	\N	\N	t	2026-04-14 06:49:49.454	2026-04-14 06:49:49.454
cmny9hk2n04nxvxy4n6ugccyu	Bao tử	HANGTUOI39	Kg	202000	\N	\N	\N	t	2026-04-14 06:49:49.535	2026-04-14 06:49:49.535
cmny9hk4904o0vxy4pw6qa0sl	Tai	HANGTUOI38	Kg	202000	\N	\N	\N	t	2026-04-14 06:49:49.594	2026-04-14 06:49:49.594
cmny9hk5w04o3vxy4zumifla0	Tim	HANGTUOI37	Kg	234000	\N	\N	\N	t	2026-04-14 06:49:49.652	2026-04-14 06:49:49.652
cmny9hk7i04o6vxy41bokj1us	Xương	HANGTUOI36	Kg	191000	\N	\N	\N	t	2026-04-14 06:49:49.71	2026-04-14 06:49:49.71
cmny9hk8w04o9vxy4t4p9ovka	Xương cổ	HANGTUOI35	Kg	191000	\N	\N	\N	t	2026-04-14 06:49:49.76	2026-04-14 06:49:49.76
cmny9hkcl04oevxy4soawdyzr	Xương ống	HANGTUOI34	Kg	170000	\N	\N	\N	t	2026-04-14 06:49:49.894	2026-04-14 06:49:49.894
cmny9hkfw04ojvxy46oncfu1d	Lưỡi	HANGTUOI33	Kg	202000	\N	\N	\N	t	2026-04-14 06:49:50.013	2026-04-14 06:49:50.013
cmny9hkhj04omvxy4o9t3zdoh	Mỡ heo	HANGTUOI32	Kg	170000	\N	\N	\N	t	2026-04-14 06:49:50.071	2026-04-14 06:49:50.071
cmny9hkj504opvxy4lo8zps7d	Gan	HANGTUOI31	Kg	128000	\N	\N	\N	t	2026-04-14 06:49:50.129	2026-04-14 06:49:50.129
cmny9hkle04ouvxy4wtolpjob	Óc	HANGTUOI30	Bộ	43000	\N	\N	\N	t	2026-04-14 06:49:50.21	2026-04-14 06:49:50.21
cmny9hkn004oxvxy4py6ljzpi	Gà ta	HANGTUOI29	Kg	234000	\N	\N	\N	t	2026-04-14 06:49:50.269	2026-04-14 06:49:50.269
cmny9hkon04p0vxy43o1c8ryi	Gà bản	HANGTUOI28	Kg	0	\N	\N	\N	t	2026-04-14 06:49:50.327	2026-04-14 06:49:50.327
cmny9hkq704p3vxy4apo9ekgs	Lòng Hấp	HANGTUOI27	Kg	244000	\N	\N	\N	t	2026-04-14 06:49:50.383	2026-04-14 06:49:50.383
cmny9hkrv04p6vxy44gz0bh0c	Nạc vai	HANGTUOI26	Kg	234000	\N	\N	\N	t	2026-04-14 06:49:50.443	2026-04-14 06:49:50.443
cmny9hkth04p9vxy49hskbffl	Vịt đồng	HANGTUOI25	Con	234000	\N	\N	\N	t	2026-04-14 06:49:50.502	2026-04-14 06:49:50.502
cmny9hkv404pcvxy44i066fn4	Chim bồ câu	HANGTUOI24	Con	122000	\N	\N	\N	t	2026-04-14 06:49:50.56	2026-04-14 06:49:50.56
cmny9hkwq04pfvxy4j8ukti57	Công gà	HANGTUOI23	Con	0	\N	\N	\N	t	2026-04-14 06:49:50.619	2026-04-14 06:49:50.619
cmny9hkye04pivxy4dmm5r3pp	Sườn cọng	HANGTUOI22	Kg	244000	\N	\N	\N	t	2026-04-14 06:49:50.679	2026-04-14 06:49:50.679
cmny9hkzz04plvxy40kmkj5le	Mỡ heo + Công cắt, thắng mỡ, đóng hộp	HANGTUOI21	Kg	205000	\N	\N	\N	t	2026-04-14 06:49:50.735	2026-04-14 06:49:50.735
cmny9hl1004pmvxy4gvu1irks	Gà ác nhỏ	HANGTUOI20	Con	106000	\N	\N	\N	t	2026-04-14 06:49:50.772	2026-04-14 06:49:50.772
cmny9hl2l04ppvxy44czmzah3	Cật	HANGTUOI19	Kg	191000	\N	\N	\N	t	2026-04-14 06:49:50.83	2026-04-14 06:49:50.83
cmny9hl4704psvxy41e83i72g	Phụ phí thùng xốp	HANGTUOI18	Kg	20000	\N	\N	\N	t	2026-04-14 06:49:50.888	2026-04-14 06:49:50.888
cmny9hl5c04ptvxy4bacqth4g	Lòng tươi	HANGTUOI17	Kg	170000	\N	\N	\N	t	2026-04-14 06:49:50.929	2026-04-14 06:49:50.929
cmny9hl7504pwvxy4fax6nmvw	Đùi bò	HANGTUOI16	Kg	0	\N	\N	\N	t	2026-04-14 06:49:50.994	2026-04-14 06:49:50.994
cmny9hl8r04pzvxy4isx378dl	Bắp bò	HANGTUOI15	Kg	0	\N	\N	\N	t	2026-04-14 06:49:51.052	2026-04-14 06:49:51.052
cmny9hla504q2vxy4wd4qjre4	Phi lê bò	HANGTUOI14	Kg	0	\N	\N	\N	t	2026-04-14 06:49:51.101	2026-04-14 06:49:51.101
cmny9hlb004q3vxy4hy9v4zmg	Nạc thăn	HANGTUOI13	Kg	234000	\N	\N	\N	t	2026-04-14 06:49:51.132	2026-04-14 06:49:51.132
cmny9hlek04qcvxy4mslnkcni	Nạm bò	HANGTUOI12	Kg	0	\N	\N	\N	t	2026-04-14 06:49:51.26	2026-04-14 06:49:51.26
cmny9hlfk04qdvxy4ujqbygxb	Móng heo	HANGTUOI11	Kg	234000	\N	\N	\N	t	2026-04-14 06:49:51.296	2026-04-14 06:49:51.296
cmny9hlh604qgvxy47s286zl8	Gà ác lớn	HANGTUOI10	Con	276000	\N	\N	\N	t	2026-04-14 06:49:51.354	2026-04-14 06:49:51.354
cmny9hlis04qjvxy42v1f1xie	Dạ trường	HANGTUOI9	Kg	0	\N	\N	\N	t	2026-04-14 06:49:51.413	2026-04-14 06:49:51.413
cmny9hlko04qkvxy41l399pes	Má heo	HANGTUOI8	Kg	0	\N	\N	\N	t	2026-04-14 06:49:51.48	2026-04-14 06:49:51.48
cmny9hllp04qlvxy4gwkr996l	Da heo	HANGTUOI7	Kg	0	\N	\N	\N	t	2026-04-14 06:49:51.517	2026-04-14 06:49:51.517
cmny9hlmz04qmvxy4ss3wpy7d	Gù bò	HANGTUOI6	Kg	0	\N	\N	\N	t	2026-04-14 06:49:51.563	2026-04-14 06:49:51.563
cmny9hloq04qpvxy4bphsdq38	Xương ống lóc thịt	HANGTUOI5	Kg	0	\N	\N	\N	t	2026-04-14 06:49:51.627	2026-04-14 06:49:51.627
cmny9hlqr04qsvxy42cv85i5g	Thăn bò	HANGTUOI4	Kg	0	\N	\N	\N	t	2026-04-14 06:49:51.7	2026-04-14 06:49:51.7
cmny9hlsg04qvvxy47axouamu	Sườn già	HANGTUOI3	Kg	234000	\N	\N	\N	t	2026-04-14 06:49:51.76	2026-04-14 06:49:51.76
cmny9hlu204qyvxy480ve0bp8	Lá xách (lá mía) heo	HANGTUOI2	Kg	0	\N	\N	\N	t	2026-04-14 06:49:51.819	2026-04-14 06:49:51.819
cmny9hluz04qzvxy4hwyy46bh	Đầu heo	HANGTUOI1	Kg	0	\N	\N	\N	t	2026-04-14 06:49:51.851	2026-04-14 06:49:51.851
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: oms_user
--

COPY public.users (id, email, "passwordHash", "fullName", role, "isActive", "createdAt", "updatedAt", "refreshTokenHash") FROM stdin;
cmny6xsu00000vxko299h9pug	poka@poka.us	$2b$12$Qc0lmFJ5YMdxFd8zm8sxnuNg4fDKa2jG9kxtrS1es9jIk0CSc8GYm	Administrator	ADMIN	t	2026-04-14 05:38:28.536	2026-04-14 06:47:22.274	$2b$10$8CYeKOtDziTxUgsPm0p83eW9XQM6w1rPvAaAZL51yhIsMDtH5g30.
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
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: oms_user
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;


--
-- PostgreSQL database dump complete
--

\unrestrict Tz4xpctnv5K5MVhsWzVxBLirLj3g92mGVstn9XsB5uOGKKUQPzViPI2O3gZEWS0

