const { Router } = require('express');
const Product = require('../models/product');
const { ApiError } = require('../utils/api-error');
const { asyncHandler } = require('../utils/async-handler');
const { z } = require('../utils/validators');

const querySchema = z.object({
  search: z.string().trim().max(100).optional(),
  category: z.enum(['menswear', 'womenswear', 'accessories', 'activewear']).optional(),
  sort: z.enum(['recommended', 'newest', 'price_asc', 'price_desc']).default('recommended'),
  page: z.coerce.number().int().min(1).default(1),
  limit: z.coerce.number().int().min(1).max(50).default(20),
});

function createProductsRouter() {
  const router = Router();

  router.get(
    '/',
    asyncHandler(async (request, response) => {
      const query = querySchema.parse(request.query);
      const filter = { isActive: true };
      if (query.category) filter.category = query.category;
      if (query.search) filter.$text = { $search: query.search };
      const sort = {
        recommended: { rating: -1, createdAt: -1 },
        newest: { createdAt: -1 },
        price_asc: { priceKobo: 1 },
        price_desc: { priceKobo: -1 },
      }[query.sort];
      const [items, total] = await Promise.all([
        Product.find(filter)
          .sort(sort)
          .skip((query.page - 1) * query.limit)
          .limit(query.limit)
          .lean(),
        Product.countDocuments(filter),
      ]);
      response.json({
        data: items,
        pagination: {
          page: query.page,
          limit: query.limit,
          total,
          pages: Math.ceil(total / query.limit),
        },
      });
    }),
  );

  router.get(
    '/:idOrSlug',
    asyncHandler(async (request, response) => {
      const value = request.params.idOrSlug;
      const product = await Product.findOne({
        isActive: true,
        $or: [
          { slug: value.toLowerCase() },
          ...( /^[a-f\d]{24}$/i.test(value) ? [{ _id: value }] : []),
        ],
      }).lean();
      if (!product) throw new ApiError(404, 'Product not found');
      response.json({ data: product });
    }),
  );

  return router;
}

module.exports = { createProductsRouter };
