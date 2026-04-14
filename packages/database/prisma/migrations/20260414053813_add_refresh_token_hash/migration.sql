/*
  Warnings:

  - You are about to drop the column `paidAmount` on the `orders` table. All the data in the column will be lost.
  - You are about to drop the column `paymentStatus` on the `orders` table. All the data in the column will be lost.
  - You are about to drop the `payments` table. If the table is not empty, all the data it contains will be lost.

*/
-- DropForeignKey
ALTER TABLE "payments" DROP CONSTRAINT "payments_orderId_fkey";

-- DropIndex
DROP INDEX "orders_paymentStatus_idx";

-- AlterTable
ALTER TABLE "orders" DROP COLUMN "paidAmount",
DROP COLUMN "paymentStatus";

-- AlterTable
ALTER TABLE "users" ADD COLUMN     "refreshTokenHash" TEXT;

-- DropTable
DROP TABLE "payments";

-- DropEnum
DROP TYPE "OrderPaymentStatus";
