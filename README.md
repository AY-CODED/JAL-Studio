# JAL Studio

JAL Studio is a Flutter storefront backed by a separate Node.js/Express API and
MongoDB service. The Flutter project and API are developed in sibling
directories: `jal_studio/` and `jal-backend/`.

## Requirements

- Flutter SDK and Dart (see `pubspec.yaml` for the Dart SDK constraint)
- Node.js 20 or newer and npm
- MongoDB 7 or newer, locally or hosted

## Start the API

From the JAL Studio project directory, open a terminal and run:

```powershell
Set-Location ..\jal-backend
npm install
```

Configure the backend's local `.env` using its [setup guide](../jal-backend/README.md)
and `.env.example`. Keep database credentials, JWT secrets, and Paystack keys in
that backend environment file; never add them to Flutter, source control, or
chat.

Start the API and, in a second backend terminal, optionally seed the catalog:

```powershell
npm run dev
npm run seed
```

The API listens at `http://localhost:4000` by default. To run backend tests:

```powershell
npm test
npm audit
```

## Run the Flutter app

From the JAL Studio project directory:

```powershell
flutter pub get
flutter run --dart-define=API_BASE_URL=http://localhost:4000/api/v1
```

For an Android emulator, use
`--dart-define=API_BASE_URL=http://10.0.2.2:4000/api/v1`. For a physical device,
use the development machine's LAN address and allow the device through the
machine's firewall.

## Project structure

```text
jal_studio/
  lib/
    app.dart        App theme and root widget
    core/           Shared API, secure storage, theme, UI utilities
    features/       Auth, catalog, checkout, account, seller, support, admin
    screens/        Main tab shell
  test/             Flutter widget tests

jal-backend/
  src/
    config/         Environment and MongoDB setup
    middleware/     Authentication and error handling
    models/         Mongoose data models
    routes/         Versioned API endpoints
    services/       Payment provider integration
  test/             HTTP integration tests
```

The `jal-backend/` path is a separate sibling directory, not a subdirectory or
Git submodule of this Flutter repository.

## Payments

Checkout uses Paystack-hosted checkout. The backend verifies the payment before
an order is marked paid; card numbers and CVVs are not handled by JAL Studio.
Payments remain unavailable until Paystack is configured on the backend. Start
with a Paystack test secret key and follow the backend's
[Paystack setup guide](../jal-backend/README.md#paystack-test-setup). Refunds,
seller payouts, and courier integrations are not enabled by this checkout flow.

## Location permissions

The app does not request location access at startup. On **Profile → Delivery
Addresses → Add a new address**, choose **Use current location** to see an
explanation and then the operating system permission prompt. If allowed, the
app uses the device location to suggest address fields and attach coordinates
to the saved address. You can decline permission and enter an address manually.
