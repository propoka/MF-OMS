import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class AdvancedService {
  constructor(private prisma: PrismaService) {}

  async deleteAllProducts() {
    // Also deletes OrderItems if CASCADE or restrict?
    // Wait, let's look at schema: OrderItem -> product has NO `onDelete: Cascade`.
    // It says `@relation(fields: [productId], references: [id])`.
    // This means we CANNOT delete products that are attached to order items without deleting order items first.
    // Actually, destroying Master Data when orders exist is BAD.
    // I should delete ProductGroupPrice, CustomerSpecialPrice, OrderItems, OR throw an error if they are used!
    // Since this is a "hard reset" advanced command, I will use a transaction to delete all OrderItems first? No, if we delete OrderItems, we break Orders.
    // The user's request is "Xoá tất cả sản phẩm". I should just delete all products. But Prisma will throw a ForeignKeyConstraint error if it has Orders.
    // I will try to delete product. If they want to reset everything, they should click "Xoá tất cả đơn hàng" first.
    // So:
    await this.prisma.productGroupPrice.deleteMany();
    await this.prisma.customerSpecialPrice.deleteMany();
    await this.prisma.product.deleteMany();
    return { success: true, message: 'All products and their prices have been deleted.' };
  }

  async deleteAllCustomers() {
    await this.prisma.customerSpecialPrice.deleteMany();
    await this.prisma.customer.deleteMany();
    return { success: true, message: 'All customers have been deleted.' };
  }

  async deleteAllOrders() {
    // Delete order items first, then orders
    await this.prisma.orderItem.deleteMany();
    await this.prisma.order.deleteMany();
    return { success: true, message: 'All orders have been deleted.' };
  }

  async deleteAllCustomerGroups() {
    // Only delete if no customers belong to them, otherwise Prisma throws FW error.
    // We should delete productGroupPrices first.
    await this.prisma.productGroupPrice.deleteMany();
    // Khách lẻ is default, maybe we shouldn't delete the default one?
    // "id: 'cuid...', isDefault: true".
    await this.prisma.customerGroup.deleteMany({ where: { isDefault: false } });
    return { success: true, message: 'All non-default customer groups have been deleted.' };
  }

  async deleteAllProductCategories() {
    // Will throw FW error if products are using it.
    await this.prisma.productCategory.deleteMany();
    return { success: true, message: 'All product categories have been deleted.' };
  }
}
