# JAL Studio

EKŌ is a Flutter storefront backed by a Node.js/Express API and MongoDB. The
Flutter app is organized by feature; shared networking, storage, theme, and UI
utilities live under `lib/core`.

## Requirements

- Flutter SDK and Dart (see `pubspec.yaml` for the Dart SDK constraint)
- Node.js 20 or newer and npm
- MongoDB 7 or newer, locally or hosted

## Start the API

```powershell
cd backend
Copy-Item .env.example .env
npm install
```

Set `MONGODB_URI` and replace `JWT_SECRET` in `backend/.env` with a private,
random value. Then start the API and, in a second terminal, optionally seed
the catalog:

```powershell
npm run dev
npm run seed
```

The API listens on `http://localhost:4000` by default. It exposes
`/api/v1/health`, catalog, authentication, account, cart, and order endpoints.
The seed command is safe to rerun for its sample catalog records.

Alternatively, with Docker Engine running, from the repository root:

```powershell
docker compose -f backend/docker-compose.yml up --build
```

The backend tests use an in-memory MongoDB and do not require a local MongoDB
service:

```powershell
cd backend
npm test
npm audit
```

## Run the Flutter app

From the repository root:

```powershell
flutter pub get
flutter run --dart-define=API_BASE_URL=http://localhost:4000/api/v1
```

For an Android emulator, use
`--dart-define=API_BASE_URL=http://10.0.2.2:4000/api/v1`. For a physical device,
use the development machine's LAN address and allow the device through the
machine's firewall. `API_BASE_URL` defaults to the local API URL above.

## Structure

```text
backend/
  src/
    config/       Environment and MongoDB setup
    middleware/   Authentication and error handling
    models/       Mongoose data models
    routes/       Versioned API endpoints
  test/           HTTP integration tests
lib/
  app.dart        App theme and root widget
  core/           Shared API, secure storage, theme, widgets, utilities
  features/       Auth, catalog, cart/checkout, account, profile, messaging
  screens/        Main tab shell
test/             Flutter widget tests
```

## Payments

Checkout currently creates an order with `paymentStatus: pending`. No payment
is collected or represented as successful. Configure a payment provider,
server-side verification, and verified webhooks before accepting live
payments.
