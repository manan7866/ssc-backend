/*
  Warnings:

  - The values [DISPATCH] on the enum `OrderStatus` will be removed. If these variants are still used in the database, this will fail.
  - The `status` column on the `order_items` table would be dropped and recreated. This will lead to data loss if there is data in the column.
  - Added the required column `vendorId` to the `order_items` table without a default value. This is not possible if the table is not empty.

*/
-- CreateEnum
CREATE TYPE "public"."OrderItemStatus" AS ENUM ('PENDING', 'CONFIRMED', 'PROCESSING', 'SHIPPED', 'DELIVERED', 'CANCELLED', 'RETURNED');

-- CreateEnum
CREATE TYPE "public"."CancellationReason" AS ENUM ('CUSTOMER_REQUEST', 'OUT_OF_STOCK', 'PAYMENT_FAILED', 'VENDOR_CANCELLED', 'SYSTEM_ERROR', 'OTHER');

-- CreateEnum
CREATE TYPE "public"."OrderPriority" AS ENUM ('LOW', 'NORMAL', 'HIGH', 'URGENT');

-- CreateEnum
CREATE TYPE "public"."ShippingMethod" AS ENUM ('STANDARD', 'EXPRESS', 'OVERNIGHT', 'SAME_DAY', 'PICKUP');

-- CreateEnum
CREATE TYPE "public"."ShippingStatus" AS ENUM ('PENDING', 'LABEL_CREATED', 'PICKED_UP', 'IN_TRANSIT', 'OUT_FOR_DELIVERY', 'DELIVERED', 'FAILED_DELIVERY', 'RETURNED_TO_SENDER');

-- CreateEnum
CREATE TYPE "public"."Carrier" AS ENUM ('FEDEX', 'UPS', 'DHL', 'USPS', 'CANADA_POST', 'ROYAL_MAIL', 'AUSTRALIA_POST', 'CUSTOM');

-- CreateEnum
CREATE TYPE "public"."ReturnStatus" AS ENUM ('REQUESTED', 'APPROVED', 'REJECTED', 'RECEIVED', 'PROCESSING', 'REFUNDED', 'EXCHANGED', 'CANCELLED');

-- CreateEnum
CREATE TYPE "public"."ReturnReason" AS ENUM ('DEFECTIVE_PRODUCT', 'WRONG_ITEM', 'NOT_AS_DESCRIBED', 'DAMAGED_IN_SHIPPING', 'SIZE_ISSUE', 'CHANGE_OF_MIND', 'DUPLICATE_ORDER', 'QUALITY_ISSUE', 'MISSING_PARTS', 'WRONG_COLOR', 'WRONG_SIZE', 'LATE_DELIVERY', 'CANCELLED_BY_CUSTOMER', 'CANCELLED_BY_SELLER', 'OTHER');

-- CreateEnum
CREATE TYPE "public"."RefundStatus" AS ENUM ('PENDING', 'PROCESSING', 'COMPLETED', 'FAILED', 'CANCELLED', 'PARTIAL');

-- CreateEnum
CREATE TYPE "public"."RefundType" AS ENUM ('FULL_REFUND', 'PARTIAL_REFUND', 'EXCHANGE', 'STORE_CREDIT_ONLY', 'NO_REFUND');

-- CreateEnum
CREATE TYPE "public"."RefundMethod" AS ENUM ('ORIGINAL_PAYMENT', 'STORE_CREDIT', 'BANK_TRANSFER', 'CHECK', 'CASH', 'GIFT_CARD');

-- CreateEnum
CREATE TYPE "public"."NotificationType" AS ENUM ('ORDER_CREATED', 'ORDER_UPDATED', 'ORDER_CANCELLED', 'ORDER_SHIPPED', 'ORDER_DELIVERED', 'PAYMENT_SUCCESS', 'PAYMENT_FAILED', 'PAYMENT_REFUNDED', 'INVENTORY_LOW_STOCK', 'INVENTORY_OUT_OF_STOCK', 'RETURN_REQUESTED', 'RETURN_APPROVED', 'RETURN_REJECTED', 'RETURN_PROCESSED', 'REFUND_PROCESSED', 'SHIPMENT_CREATED', 'SHIPMENT_UPDATED', 'SHIPMENT_DELIVERED', 'COUPON_EXPIRED', 'COUPON_CREATED', 'VENDOR_APPROVED', 'VENDOR_REJECTED', 'SYSTEM_MAINTENANCE', 'SECURITY_ALERT', 'GENERAL');

-- CreateEnum
CREATE TYPE "public"."NotificationPriority" AS ENUM ('LOW', 'NORMAL', 'HIGH', 'URGENT');

-- CreateEnum
CREATE TYPE "public"."NotificationStatus" AS ENUM ('PENDING', 'SENT', 'DELIVERED', 'READ', 'FAILED', 'CANCELLED');

-- CreateEnum
CREATE TYPE "public"."ReportType" AS ENUM ('SALES_REPORT', 'INVENTORY_REPORT', 'CUSTOMER_REPORT', 'VENDOR_REPORT', 'ORDER_REPORT', 'RETURN_REPORT', 'PAYMENT_REPORT', 'PERFORMANCE_REPORT', 'CUSTOM');

-- CreateEnum
CREATE TYPE "public"."ReportFormat" AS ENUM ('PDF', 'EXCEL', 'CSV', 'JSON');

-- CreateEnum
CREATE TYPE "public"."ReportStatus" AS ENUM ('PENDING', 'GENERATING', 'COMPLETED', 'FAILED', 'EXPIRED');

-- CreateEnum
CREATE TYPE "public"."DashboardWidgetType" AS ENUM ('SALES_CHART', 'REVENUE_METRIC', 'ORDER_COUNT', 'CUSTOMER_COUNT', 'INVENTORY_ALERT', 'TOP_PRODUCTS', 'RECENT_ORDERS', 'PERFORMANCE_GAUGE', 'CUSTOM_CHART');

-- CreateEnum
CREATE TYPE "public"."InventoryChangeType" AS ENUM ('SALE', 'RETURN', 'ADJUSTMENT', 'RESTOCK', 'DAMAGE', 'THEFT', 'EXPIRED');

-- CreateEnum
CREATE TYPE "public"."StockAdjustmentType" AS ENUM ('INCREASE', 'DECREASE', 'SET');

-- CreateEnum
CREATE TYPE "public"."ShippingRateType" AS ENUM ('FIXED', 'WEIGHT_BASED', 'ORDER_VALUE_BASED', 'HYBRID');

-- CreateEnum
CREATE TYPE "public"."PayoutMethod" AS ENUM ('BANK_TRANSFER', 'PAYPAL', 'STRIPE_CONNECT', 'CHECK', 'WIRE_TRANSFER');

-- CreateEnum
CREATE TYPE "public"."PayoutFrequency" AS ENUM ('DAILY', 'WEEKLY', 'BI_WEEKLY', 'MONTHLY');

-- AlterEnum
BEGIN;
CREATE TYPE "public"."OrderStatus_new" AS ENUM ('PENDING', 'CONFIRMED', 'PROCESSING', 'SHIPPED', 'IN_TRANSIT', 'DELIVERED', 'COMPLETED', 'FAILED', 'CANCELLED', 'RETURNED', 'REFUNDED');
ALTER TABLE "public"."order_items" ALTER COLUMN "status" DROP DEFAULT;
ALTER TABLE "public"."orders" ALTER COLUMN "status" DROP DEFAULT;
ALTER TABLE "public"."orders" ALTER COLUMN "status" TYPE "public"."OrderStatus_new" USING ("status"::text::"public"."OrderStatus_new");
ALTER TABLE "public"."order_history" ALTER COLUMN "status" TYPE "public"."OrderStatus_new" USING ("status"::text::"public"."OrderStatus_new");
ALTER TABLE "public"."order_history" ALTER COLUMN "previousStatus" TYPE "public"."OrderStatus_new" USING ("previousStatus"::text::"public"."OrderStatus_new");
ALTER TYPE "public"."OrderStatus" RENAME TO "OrderStatus_old";
ALTER TYPE "public"."OrderStatus_new" RENAME TO "OrderStatus";
DROP TYPE "public"."OrderStatus_old";
ALTER TABLE "public"."orders" ALTER COLUMN "status" SET DEFAULT 'PENDING';
COMMIT;

-- AlterEnum
ALTER TYPE "public"."PaymentStatus" ADD VALUE 'PARTIALLY_REFUNDED';

-- AlterTable
ALTER TABLE "public"."Meditation" ADD COLUMN     "dimensions" TEXT,
ADD COLUMN     "shippingClass" TEXT,
ADD COLUMN     "weight" DOUBLE PRECISION;

-- AlterTable
ALTER TABLE "public"."accessories" ADD COLUMN     "dimensions" TEXT,
ADD COLUMN     "shippingClass" TEXT,
ADD COLUMN     "weight" DOUBLE PRECISION;

-- AlterTable
ALTER TABLE "public"."decorations" ADD COLUMN     "dimensions" TEXT,
ADD COLUMN     "shippingClass" TEXT,
ADD COLUMN     "weight" DOUBLE PRECISION;

-- AlterTable
ALTER TABLE "public"."digitalBooks" ADD COLUMN     "stock" INTEGER NOT NULL DEFAULT 0;

-- AlterTable
ALTER TABLE "public"."fashion" ADD COLUMN     "dimensions" TEXT,
ADD COLUMN     "shippingClass" TEXT,
ADD COLUMN     "weight" DOUBLE PRECISION;

-- AlterTable
ALTER TABLE "public"."homeAndLiving" ADD COLUMN     "dimensions" TEXT,
ADD COLUMN     "shippingClass" TEXT,
ADD COLUMN     "weight" DOUBLE PRECISION;

-- AlterTable
ALTER TABLE "public"."order_items" ADD COLUMN     "accessoriesId" INTEGER,
ADD COLUMN     "decorationId" INTEGER,
ADD COLUMN     "deliveredAt" TIMESTAMP(3),
ADD COLUMN     "digitalBookId" INTEGER,
ADD COLUMN     "fashionId" INTEGER,
ADD COLUMN     "homeAndLivingId" INTEGER,
ADD COLUMN     "meditationId" INTEGER,
ADD COLUMN     "musicId" INTEGER,
ADD COLUMN     "shippedAt" TIMESTAMP(3),
ADD COLUMN     "trackingNumber" TEXT,
ADD COLUMN     "vendorId" TEXT NOT NULL,
DROP COLUMN "status",
ADD COLUMN     "status" "public"."OrderItemStatus" NOT NULL DEFAULT 'PENDING';

-- AlterTable
ALTER TABLE "public"."orders" ADD COLUMN     "actualDelivery" TIMESTAMP(3),
ADD COLUMN     "cancellationNotes" TEXT,
ADD COLUMN     "cancellationReason" "public"."CancellationReason",
ADD COLUMN     "cancelledAt" TIMESTAMP(3),
ADD COLUMN     "cancelledBy" TEXT,
ADD COLUMN     "carrier" "public"."Carrier",
ADD COLUMN     "estimatedDelivery" TIMESTAMP(3),
ADD COLUMN     "estimatedDeliveryDays" INTEGER DEFAULT 0,
ADD COLUMN     "priority" "public"."OrderPriority" NOT NULL DEFAULT 'NORMAL',
ADD COLUMN     "selectedShippingService" TEXT DEFAULT '',
ADD COLUMN     "shippingCost" DOUBLE PRECISION NOT NULL DEFAULT 0,
ADD COLUMN     "shippingMethod" "public"."ShippingMethod" NOT NULL DEFAULT 'STANDARD',
ADD COLUMN     "shippingStatus" "public"."ShippingStatus" NOT NULL DEFAULT 'PENDING',
ADD COLUMN     "trackingNumber" TEXT;

-- AlterTable
ALTER TABLE "public"."reviews" ALTER COLUMN "content" DROP DEFAULT;

-- AlterTable
ALTER TABLE "public"."users" ADD COLUMN     "businessLegalStructure" TEXT DEFAULT '',
ADD COLUMN     "payoutConfigCompleted" BOOLEAN NOT NULL DEFAULT false,
ADD COLUMN     "shippingConfigCompleted" BOOLEAN NOT NULL DEFAULT false;

-- CreateTable
CREATE TABLE "public"."order_history" (
    "id" SERIAL NOT NULL,
    "orderId" INTEGER NOT NULL,
    "status" "public"."OrderStatus" NOT NULL,
    "previousStatus" "public"."OrderStatus",
    "changedBy" TEXT NOT NULL,
    "reason" TEXT,
    "notes" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "order_history_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."order_notes" (
    "id" SERIAL NOT NULL,
    "orderId" INTEGER NOT NULL,
    "userId" TEXT NOT NULL,
    "note" TEXT NOT NULL,
    "isInternal" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "order_notes_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."shipments" (
    "id" SERIAL NOT NULL,
    "orderId" INTEGER NOT NULL,
    "vendorId" TEXT,
    "trackingNumber" TEXT NOT NULL,
    "carrier" "public"."Carrier" NOT NULL,
    "shippingMethod" "public"."ShippingMethod" NOT NULL,
    "status" "public"."ShippingStatus" NOT NULL DEFAULT 'PENDING',
    "labelUrl" TEXT,
    "trackingUrl" TEXT,
    "estimatedDelivery" TIMESTAMP(3),
    "actualDelivery" TIMESTAMP(3),
    "weight" DOUBLE PRECISION,
    "dimensions" TEXT,
    "cost" DOUBLE PRECISION NOT NULL,
    "notes" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "shipments_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."returns" (
    "id" SERIAL NOT NULL,
    "orderId" INTEGER NOT NULL,
    "userId" TEXT NOT NULL,
    "status" "public"."ReturnStatus" NOT NULL DEFAULT 'REQUESTED',
    "reason" "public"."ReturnReason" NOT NULL,
    "description" TEXT NOT NULL,
    "requestedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "approvedAt" TIMESTAMP(3),
    "approvedBy" TEXT,
    "rejectedAt" TIMESTAMP(3),
    "rejectedBy" TEXT,
    "rejectionReason" TEXT,
    "receivedAt" TIMESTAMP(3),
    "processedAt" TIMESTAMP(3),
    "refundAmount" DOUBLE PRECISION,
    "refundMethod" "public"."RefundMethod",
    "refundType" "public"."RefundType" NOT NULL DEFAULT 'FULL_REFUND',
    "refundStatus" "public"."RefundStatus" NOT NULL DEFAULT 'PENDING',
    "refundId" TEXT,
    "trackingNumber" TEXT,
    "returnLabelUrl" TEXT,
    "returnWindow" INTEGER NOT NULL DEFAULT 30,
    "returnDeadline" TIMESTAMP(3),
    "isExpedited" BOOLEAN NOT NULL DEFAULT false,
    "priority" "public"."OrderPriority" NOT NULL DEFAULT 'NORMAL',
    "notes" TEXT,
    "internalNotes" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "returns_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."return_items" (
    "id" SERIAL NOT NULL,
    "returnId" INTEGER NOT NULL,
    "productId" INTEGER NOT NULL,
    "quantity" INTEGER NOT NULL,
    "reason" "public"."ReturnReason" NOT NULL,
    "condition" TEXT,
    "notes" TEXT,
    "refundAmount" DOUBLE PRECISION,
    "isEligibleForRefund" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "return_items_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."refunds" (
    "id" SERIAL NOT NULL,
    "returnId" INTEGER NOT NULL,
    "orderId" INTEGER NOT NULL,
    "userId" TEXT NOT NULL,
    "amount" DOUBLE PRECISION NOT NULL,
    "refundMethod" "public"."RefundMethod" NOT NULL,
    "refundType" "public"."RefundType" NOT NULL,
    "status" "public"."RefundStatus" NOT NULL DEFAULT 'PENDING',
    "externalRefundId" TEXT,
    "processedAt" TIMESTAMP(3),
    "processedBy" TEXT,
    "failureReason" TEXT,
    "notes" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "refunds_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."store_credits" (
    "id" SERIAL NOT NULL,
    "userId" TEXT NOT NULL,
    "amount" DOUBLE PRECISION NOT NULL,
    "balance" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "reason" TEXT NOT NULL,
    "returnId" INTEGER,
    "expiresAt" TIMESTAMP(3),
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "usedAt" TIMESTAMP(3),
    "notes" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "store_credits_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."notifications" (
    "id" SERIAL NOT NULL,
    "userId" TEXT NOT NULL,
    "type" "public"."NotificationType" NOT NULL,
    "title" TEXT NOT NULL,
    "message" TEXT NOT NULL,
    "priority" "public"."NotificationPriority" NOT NULL DEFAULT 'NORMAL',
    "status" "public"."NotificationStatus" NOT NULL DEFAULT 'PENDING',
    "data" TEXT,
    "orderId" INTEGER,
    "returnId" INTEGER,
    "shipmentId" INTEGER,
    "isRead" BOOLEAN NOT NULL DEFAULT false,
    "readAt" TIMESTAMP(3),
    "sentAt" TIMESTAMP(3),
    "deliveredAt" TIMESTAMP(3),
    "expiresAt" TIMESTAMP(3),
    "retryCount" INTEGER NOT NULL DEFAULT 0,
    "maxRetries" INTEGER NOT NULL DEFAULT 3,
    "lastRetryAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "notifications_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."notification_templates" (
    "id" SERIAL NOT NULL,
    "type" "public"."NotificationType" NOT NULL,
    "title" TEXT NOT NULL,
    "message" TEXT NOT NULL,
    "priority" "public"."NotificationPriority" NOT NULL DEFAULT 'NORMAL',
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "variables" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "notification_templates_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."notification_preferences" (
    "id" SERIAL NOT NULL,
    "userId" TEXT NOT NULL,
    "type" "public"."NotificationType" NOT NULL,
    "emailEnabled" BOOLEAN NOT NULL DEFAULT true,
    "pushEnabled" BOOLEAN NOT NULL DEFAULT true,
    "smsEnabled" BOOLEAN NOT NULL DEFAULT false,
    "webSocketEnabled" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "notification_preferences_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."websocket_connections" (
    "id" SERIAL NOT NULL,
    "userId" TEXT NOT NULL,
    "connectionId" TEXT NOT NULL,
    "socketId" TEXT,
    "userAgent" TEXT,
    "ipAddress" TEXT,
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "lastPingAt" TIMESTAMP(3),
    "disconnectedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "websocket_connections_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."reports" (
    "id" SERIAL NOT NULL,
    "userId" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "type" "public"."ReportType" NOT NULL,
    "format" "public"."ReportFormat" NOT NULL,
    "status" "public"."ReportStatus" NOT NULL DEFAULT 'PENDING',
    "parameters" TEXT,
    "filters" TEXT,
    "data" TEXT,
    "fileUrl" TEXT,
    "fileSize" INTEGER,
    "expiresAt" TIMESTAMP(3),
    "generatedAt" TIMESTAMP(3),
    "generatedBy" TEXT,
    "errorMessage" TEXT,
    "downloadCount" INTEGER NOT NULL DEFAULT 0,
    "lastDownloadedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "reports_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."dashboards" (
    "id" SERIAL NOT NULL,
    "userId" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT,
    "isDefault" BOOLEAN NOT NULL DEFAULT false,
    "isPublic" BOOLEAN NOT NULL DEFAULT false,
    "layout" TEXT,
    "settings" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "dashboards_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."dashboard_widgets" (
    "id" SERIAL NOT NULL,
    "dashboardId" INTEGER NOT NULL,
    "type" "public"."DashboardWidgetType" NOT NULL,
    "title" TEXT NOT NULL,
    "description" TEXT,
    "position" INTEGER NOT NULL,
    "size" TEXT,
    "configuration" TEXT,
    "data" TEXT,
    "refreshInterval" INTEGER,
    "isVisible" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "dashboard_widgets_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."analytics_events" (
    "id" SERIAL NOT NULL,
    "userId" TEXT,
    "eventType" TEXT NOT NULL,
    "eventName" TEXT NOT NULL,
    "properties" TEXT,
    "sessionId" TEXT,
    "ipAddress" TEXT,
    "userAgent" TEXT,
    "referrer" TEXT,
    "timestamp" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "analytics_events_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."kpis" (
    "id" SERIAL NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT,
    "category" TEXT NOT NULL,
    "formula" TEXT,
    "target" DOUBLE PRECISION,
    "currentValue" DOUBLE PRECISION,
    "unit" TEXT,
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "lastCalculatedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "kpis_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."inventory_logs" (
    "id" SERIAL NOT NULL,
    "productId" INTEGER NOT NULL,
    "productCategory" "public"."ProductCategory" NOT NULL,
    "changeType" "public"."InventoryChangeType" NOT NULL,
    "quantityChange" INTEGER NOT NULL,
    "previousStock" INTEGER NOT NULL,
    "newStock" INTEGER NOT NULL,
    "reason" TEXT,
    "orderId" INTEGER,
    "userId" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "inventory_logs_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."low_stock_alerts" (
    "id" SERIAL NOT NULL,
    "productId" INTEGER NOT NULL,
    "productCategory" "public"."ProductCategory" NOT NULL,
    "currentStock" INTEGER NOT NULL,
    "threshold" INTEGER NOT NULL DEFAULT 10,
    "isResolved" BOOLEAN NOT NULL DEFAULT false,
    "resolvedAt" TIMESTAMP(3),
    "userId" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "low_stock_alerts_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."stock_adjustments" (
    "id" SERIAL NOT NULL,
    "productId" INTEGER NOT NULL,
    "productCategory" "public"."ProductCategory" NOT NULL,
    "adjustmentType" "public"."StockAdjustmentType" NOT NULL,
    "quantity" INTEGER NOT NULL,
    "reason" TEXT NOT NULL,
    "notes" TEXT,
    "userId" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "stock_adjustments_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."vendor_shipping_configs" (
    "id" SERIAL NOT NULL,
    "vendorId" TEXT NOT NULL,
    "defaultCarrier" "public"."Carrier",
    "defaultMethod" "public"."ShippingMethod" NOT NULL DEFAULT 'STANDARD',
    "handlingTime" INTEGER NOT NULL DEFAULT 1,
    "freeShippingThreshold" DOUBLE PRECISION,
    "isConfigured" BOOLEAN NOT NULL DEFAULT false,
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "vendor_shipping_configs_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."vendor_shipping_zones" (
    "id" SERIAL NOT NULL,
    "vendorId" TEXT NOT NULL,
    "configId" INTEGER NOT NULL,
    "country" TEXT,
    "state" TEXT,
    "zipCodeRanges" JSONB,
    "zoneName" TEXT NOT NULL,
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "description" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "vendor_shipping_zones_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."vendor_shipping_rates" (
    "id" SERIAL NOT NULL,
    "zoneId" INTEGER NOT NULL,
    "carrier" "public"."Carrier" NOT NULL,
    "method" "public"."ShippingMethod" NOT NULL,
    "rateType" "public"."ShippingRateType" NOT NULL,
    "baseRate" DOUBLE PRECISION NOT NULL,
    "perKgRate" DOUBLE PRECISION,
    "perItemRate" DOUBLE PRECISION,
    "freeShippingThreshold" DOUBLE PRECISION,
    "maxWeight" DOUBLE PRECISION,
    "maxDimensions" TEXT,
    "estimatedDays" INTEGER NOT NULL,
    "cutoffTime" TEXT,
    "description" TEXT,
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "vendor_shipping_rates_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."vendor_payout_configs" (
    "id" SERIAL NOT NULL,
    "vendorId" TEXT NOT NULL,
    "payoutMethod" "public"."PayoutMethod" NOT NULL,
    "payoutFrequency" "public"."PayoutFrequency" NOT NULL DEFAULT 'WEEKLY',
    "bankName" TEXT,
    "accountNumber" TEXT,
    "routingNumber" TEXT,
    "bankAddress" TEXT,
    "paypalEmail" TEXT,
    "stripeAccountId" TEXT,
    "minimumPayout" DOUBLE PRECISION NOT NULL DEFAULT 50.0,
    "autoPayout" BOOLEAN NOT NULL DEFAULT true,
    "taxId" TEXT,
    "taxForm" TEXT,
    "isVerified" BOOLEAN NOT NULL DEFAULT false,
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "verifiedAt" TIMESTAMP(3),
    "verifiedBy" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "vendor_payout_configs_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "notification_templates_type_key" ON "public"."notification_templates"("type");

-- CreateIndex
CREATE UNIQUE INDEX "notification_preferences_userId_type_key" ON "public"."notification_preferences"("userId", "type");

-- CreateIndex
CREATE UNIQUE INDEX "websocket_connections_connectionId_key" ON "public"."websocket_connections"("connectionId");

-- CreateIndex
CREATE UNIQUE INDEX "kpis_name_key" ON "public"."kpis"("name");

-- CreateIndex
CREATE UNIQUE INDEX "vendor_shipping_configs_vendorId_key" ON "public"."vendor_shipping_configs"("vendorId");

-- CreateIndex
CREATE UNIQUE INDEX "vendor_payout_configs_vendorId_key" ON "public"."vendor_payout_configs"("vendorId");

-- AddForeignKey
ALTER TABLE "public"."order_items" ADD CONSTRAINT "order_items_vendorId_fkey" FOREIGN KEY ("vendorId") REFERENCES "public"."users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."order_items" ADD CONSTRAINT "order_items_accessoriesId_fkey" FOREIGN KEY ("accessoriesId") REFERENCES "public"."accessories"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."order_items" ADD CONSTRAINT "order_items_decorationId_fkey" FOREIGN KEY ("decorationId") REFERENCES "public"."decorations"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."order_items" ADD CONSTRAINT "order_items_homeAndLivingId_fkey" FOREIGN KEY ("homeAndLivingId") REFERENCES "public"."homeAndLiving"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."order_items" ADD CONSTRAINT "order_items_fashionId_fkey" FOREIGN KEY ("fashionId") REFERENCES "public"."fashion"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."order_items" ADD CONSTRAINT "order_items_meditationId_fkey" FOREIGN KEY ("meditationId") REFERENCES "public"."Meditation"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."order_items" ADD CONSTRAINT "order_items_digitalBookId_fkey" FOREIGN KEY ("digitalBookId") REFERENCES "public"."digitalBooks"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."order_items" ADD CONSTRAINT "order_items_musicId_fkey" FOREIGN KEY ("musicId") REFERENCES "public"."music"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."order_history" ADD CONSTRAINT "order_history_orderId_fkey" FOREIGN KEY ("orderId") REFERENCES "public"."orders"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."order_notes" ADD CONSTRAINT "order_notes_orderId_fkey" FOREIGN KEY ("orderId") REFERENCES "public"."orders"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."order_notes" ADD CONSTRAINT "order_notes_userId_fkey" FOREIGN KEY ("userId") REFERENCES "public"."users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."shipments" ADD CONSTRAINT "shipments_orderId_fkey" FOREIGN KEY ("orderId") REFERENCES "public"."orders"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."shipments" ADD CONSTRAINT "shipments_vendorId_fkey" FOREIGN KEY ("vendorId") REFERENCES "public"."users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."returns" ADD CONSTRAINT "returns_orderId_fkey" FOREIGN KEY ("orderId") REFERENCES "public"."orders"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."returns" ADD CONSTRAINT "returns_userId_fkey" FOREIGN KEY ("userId") REFERENCES "public"."users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."return_items" ADD CONSTRAINT "return_items_returnId_fkey" FOREIGN KEY ("returnId") REFERENCES "public"."returns"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."refunds" ADD CONSTRAINT "refunds_returnId_fkey" FOREIGN KEY ("returnId") REFERENCES "public"."returns"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."refunds" ADD CONSTRAINT "refunds_orderId_fkey" FOREIGN KEY ("orderId") REFERENCES "public"."orders"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."refunds" ADD CONSTRAINT "refunds_userId_fkey" FOREIGN KEY ("userId") REFERENCES "public"."users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."store_credits" ADD CONSTRAINT "store_credits_userId_fkey" FOREIGN KEY ("userId") REFERENCES "public"."users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."store_credits" ADD CONSTRAINT "store_credits_returnId_fkey" FOREIGN KEY ("returnId") REFERENCES "public"."returns"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."notifications" ADD CONSTRAINT "notifications_userId_fkey" FOREIGN KEY ("userId") REFERENCES "public"."users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."notifications" ADD CONSTRAINT "notifications_orderId_fkey" FOREIGN KEY ("orderId") REFERENCES "public"."orders"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."notifications" ADD CONSTRAINT "notifications_returnId_fkey" FOREIGN KEY ("returnId") REFERENCES "public"."returns"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."notifications" ADD CONSTRAINT "notifications_shipmentId_fkey" FOREIGN KEY ("shipmentId") REFERENCES "public"."shipments"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."notification_preferences" ADD CONSTRAINT "notification_preferences_userId_fkey" FOREIGN KEY ("userId") REFERENCES "public"."users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."websocket_connections" ADD CONSTRAINT "websocket_connections_userId_fkey" FOREIGN KEY ("userId") REFERENCES "public"."users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."reports" ADD CONSTRAINT "reports_userId_fkey" FOREIGN KEY ("userId") REFERENCES "public"."users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."dashboards" ADD CONSTRAINT "dashboards_userId_fkey" FOREIGN KEY ("userId") REFERENCES "public"."users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."dashboard_widgets" ADD CONSTRAINT "dashboard_widgets_dashboardId_fkey" FOREIGN KEY ("dashboardId") REFERENCES "public"."dashboards"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."analytics_events" ADD CONSTRAINT "analytics_events_userId_fkey" FOREIGN KEY ("userId") REFERENCES "public"."users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."inventory_logs" ADD CONSTRAINT "inventory_logs_orderId_fkey" FOREIGN KEY ("orderId") REFERENCES "public"."orders"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."inventory_logs" ADD CONSTRAINT "inventory_logs_userId_fkey" FOREIGN KEY ("userId") REFERENCES "public"."users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."low_stock_alerts" ADD CONSTRAINT "low_stock_alerts_userId_fkey" FOREIGN KEY ("userId") REFERENCES "public"."users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."stock_adjustments" ADD CONSTRAINT "stock_adjustments_userId_fkey" FOREIGN KEY ("userId") REFERENCES "public"."users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."vendor_shipping_configs" ADD CONSTRAINT "vendor_shipping_configs_vendorId_fkey" FOREIGN KEY ("vendorId") REFERENCES "public"."users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."vendor_shipping_zones" ADD CONSTRAINT "vendor_shipping_zones_configId_fkey" FOREIGN KEY ("configId") REFERENCES "public"."vendor_shipping_configs"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."vendor_shipping_rates" ADD CONSTRAINT "vendor_shipping_rates_zoneId_fkey" FOREIGN KEY ("zoneId") REFERENCES "public"."vendor_shipping_zones"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."vendor_payout_configs" ADD CONSTRAINT "vendor_payout_configs_vendorId_fkey" FOREIGN KEY ("vendorId") REFERENCES "public"."users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
