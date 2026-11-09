const { randomUUID } = require('node:crypto');
const { Router } = require('express');
const Cart = require('../models/cart');
const Order = require('../models/order');
const Product = require('../models/product');
const { ApiError } = require('../utils/api-error');
const { asyncHandler } = require('../utils/async-handler');
const { objectId, z } = require('../utils/validators');

const checkoutSchema = z.object({
  addressId: objectId,
  paymentProvider: z.enum(['paystack', 'flutterwave', 'bank_transfer']),
});

function createOrdersRouter({ requireAuth }) {
  const router = Router();
  router.use(requireAuth);

  router.post(
    '/',
    asyncHandler(async (request, response) => {
      const input = checkoutSchema.parse(request.body);
      const address = request.user.addresses.id(input.addressId);
      if (!address) throw new ApiError(400, 'Select a saved delivery address');
      const cart = await Cart.findOne({ user: request.user.id }).populate('items.product');
      if (!cart || !cart.items.length) throw new ApiError(400, 'Your bag is empty');

      const items = cart.items.map((item) => {
        const product = item.product;
        if (!product || !product.isActive) throw new ApiError(409, 'A product in your bag is no longer available');
        if (product.stock < item.quantity) throw new ApiError(409, `${product.name} no longer has the requested stock`);
        return {
          product: product.id,
          name: product.name,
          imageUrl: product.imageUrl,
          unitPriceKobo: product.priceKobo,
          quantity: item.quantity,
          size: item.size,
          color: item.color,
        };
      });
      const subtotalKobo = items.reduce((total, item) => total + item.unitPriceKobo * item.quantity, 0);
      const deliveryKobo = 1500000;
      const order = await Order.create({
        user: request.user.id,
        orderNumber: `EKO-${randomUUID().slice(0, 8).toUpperCase()}`,
        items,
        subtotalKobo,
        deliveryKobo,
        totalKobo: subtotalKobo + deliveryKobo,
        paymentProvider: input.paymentProvider,
        shippingAddress: address.toObject(),
      });

      response.status(201).json({
        data: {
          order,
          payment: {
            status: 'pending',
            message: 'Payment has not been collected. Configure a payment gateway to continue.',
          },
        },
      });
    }),
  );

  router.get(
    '/',
    asyncHandler(async (request, response) => {
      const orders = await Order.find({ user: request.user.id }).sort({ createdAt: -1 }).lean();
      response.json({ data: orders });
    }),
  );

  router.get(
    '/:orderId',
    asyncHandler(async (request, response) => {
      const orderId = objectId.parse(request.params.orderId);
      const order = await Order.findOne({ _id: orderId, user: request.user.id }).lean();
      if (!order) throw new ApiError(404, 'Order not found');
      response.json({ data: order });
    }),
  );

  return router;
}

module.exports = { createOrdersRouter };
