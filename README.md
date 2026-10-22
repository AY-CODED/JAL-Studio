# EKŌ (formerly JAL Studio)

A premium, high-fashion mobile marketplace inspired by ASOS and SSENSE, designed exclusively for the Nigerian market. EKŌ connects elite local fashion ateliers with modern buyers through a minimalist, luxury editorial mobile experience.

## 🚀 The 12-Week MVP Vision
This project is currently in a 12-week rapid development sprint. The MVP scope is strictly constrained to ensure a fast, reliable launch:
*   **Currency:** Naira (₦ NGN) only.
*   **Theme:** Light mode only (pure white backgrounds, deep black text, subtle beige/gold accents).
*   **Payments:** Direct split-settlement via Paystack and Flutterwave integrations.
*   **Typography:** Playfair Display (Headers) & Inter/SF Pro (Body).

## 🛠️ Tech Stack
*   **Framework:** [Flutter](https://flutter.dev/) (Dart)
*   **State Management:** [Riverpod](https://riverpod.dev/)
*   **Networking:** Dio
*   **UI/Design:** Google Fonts, Lucide Icons, Cached Network Image
*   **Backend:** Node.js (NestJS) + MongoDB Atlas (Hosted separately)

## 📂 Feature-First Architecture
To ensure high velocity and prevent merge conflicts, this app strictly follows a **Feature-First Domain-Driven Architecture**. Every feature contains its own UI (`presentation`), State (`providers`), and API logic (`data`).

```text
eko_threads_app/
├── lib/
│   ├── main.dart                 # App entry & ProviderScope
│   ├── app.dart                  # MaterialApp & routing
│   │
│   ├── core/                     # 🛠️ APP-WIDE GLOBALS
│   │   ├── theme/                # Colors, Typography (Light mode only)
│   │   ├── widgets/              # Reusable UI (Buttons, Skeletons)
│   │   ├── network/              # Dio client, Interceptors
│   │   └── utils/                # Currency/Date formatters
│   │
│   └── features/                 # 📱 THE DOMAINS
│       ├── splash/               # App initialization & token checks
│       ├── auth/                 # Login, OTP, Registration
│       ├── discovery/            # Home feed, Editorial banners
│       ├── product/              # PDP, Image carousel, Size selectors
│       ├── cart_checkout/        # Bag, Paystack UI, Order summary
│       ├── profile/              # User settings, Measurements, History
│       └── seller_studio/        # Vendor dashboard, Order management
