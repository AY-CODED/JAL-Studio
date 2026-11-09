const { after, before, test } = require('node:test');
const assert = require('node:assert/strict');
const request = require('supertest');
const { MongoMemoryServer } = require('mongodb-memory-server');
const { connectDatabase, disconnectDatabase } = require('../src/config/database');
const { createApp } = require('../src/app');
const Product = require('../src/models/product');

process.env.NODE_ENV = 'test';
process.env.JWT_SECRET = 'test-only-secret-that-is-long-enough-123456';
process.env.MONGODB_URI = 'mongodb://127.0.0.1:27017/eko_test';
process.env.CORS_ORIGINS = 'http://localhost:8765';

let mongo;
let app;

before(async () => {
  mongo = await MongoMemoryServer.create();
  await connectDatabase(mongo.getUri());
  app = createApp();
});

after(async () => {
  await disconnectDatabase();
  await mongo.stop();
});

test('health endpoint reports database readiness', async () => {
  const response = await request(app).get('/api/v1/health');
  assert.equal(response.status, 200);
  assert.deepEqual(response.body, { status: 'ok', database: 'connected' });
});

test('catalog is public, paginated, searchable, and validates its query', async () => {
  await Product.create([
    {
      slug: 'test-blazer',
      name: 'Test Blazer',
      category: 'menswear',
      brand: 'Test Atelier',
      priceKobo: 1200000,
      imageUrl: '/media/banner1.jpg',
      stock: 3,
    },
    {
      slug: 'test-dress',
      name: 'Test Dress',
      category: 'womenswear',
      brand: 'Test Atelier',
      priceKobo: 900000,
      imageUrl: '/media/banner2.jpg',
      stock: 2,
    },
  ]);
  const list = await request(app).get('/api/v1/products?category=menswear&page=1&limit=1');
  assert.equal(list.status, 200);
  assert.equal(list.body.data.length, 1);
  assert.equal(list.body.pagination.total, 1);
  assert.equal(list.body.data[0].priceKobo, 1200000);

  const invalid = await request(app).get('/api/v1/products?limit=500');
  assert.equal(invalid.status, 400);
});

test('registration, authentication, and server-priced cart operations work', async () => {
  const registration = await request(app).post('/api/v1/auth/register').send({
    fullName: 'Test Customer',
    email: 'customer@example.com',
    password: 'a-secure-test-password',
  });
  assert.equal(registration.status, 201);
  assert.equal(registration.body.data.user.email, 'customer@example.com');
  const token = registration.body.data.token;

  const unauthenticated = await request(app).get('/api/v1/cart');
  assert.equal(unauthenticated.status, 401);

  const product = await Product.findOne({ slug: 'test-blazer' });
  const add = await request(app)
    .post('/api/v1/cart/items')
    .set('Authorization', `Bearer ${token}`)
    .send({ productId: product.id, quantity: 2 });
  assert.equal(add.status, 201);
  assert.equal(add.body.data.itemCount, 2);
  assert.equal(add.body.data.subtotalKobo, 2400000);

  const login = await request(app).post('/api/v1/auth/login').send({
    email: 'customer@example.com',
    password: 'wrong-password-123',
  });
  assert.equal(login.status, 401);
});

test('checkout rejects a missing saved address and never reports a payment as completed', async () => {
  const registration = await request(app).post('/api/v1/auth/register').send({
    fullName: 'Order Customer',
    email: 'order@example.com',
    password: 'a-secure-test-password',
  });
  const token = registration.body.data.token;
  const response = await request(app)
    .post('/api/v1/orders')
    .set('Authorization', `Bearer ${token}`)
    .send({ addressId: '000000000000000000000000', paymentProvider: 'paystack' });
  assert.equal(response.status, 400);
});
