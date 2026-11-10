// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jal_studio/features/account/data/account_repository.dart';
import 'package:jal_studio/features/auth/data/auth_repository.dart';
import 'package:jal_studio/features/auth/providers/auth_provider.dart';
import 'package:jal_studio/features/cart_checkout/presentation/bag_content.dart';
import 'package:jal_studio/features/cart_checkout/presentation/checkout_page.dart';
import 'package:jal_studio/features/cart_checkout/domain/store_cart.dart';
import 'package:jal_studio/features/cart_checkout/data/order_repository.dart';
import 'package:jal_studio/features/catalog/data/catalog_repository.dart';
import 'package:jal_studio/features/catalog/domain/store_product.dart';
import 'package:jal_studio/features/catalog/presentation/filter_sort_sheet.dart';
import 'package:jal_studio/screens/home_screen.dart';

class _UnauthenticatedController extends AuthController {
  @override
  Future<AuthUser?> build() async => null;
}

void main() {
  testWidgets('Storefront opens product details', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          catalogProductsProvider.overrideWith(
            (ref) async => sampleStoreProducts,
          ),
          authProvider.overrideWith(_UnauthenticatedController.new),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('E K Ō'), findsOneWidget);
    expect(find.text('Timeless Elegance\nStarts Here'), findsOneWidget);

    final product = find.text('Stitched Leather Silk Blazer');
    await tester.ensureVisible(product);
    await tester.pumpAndSettle();
    await tester.tap(product);
    await tester.pumpAndSettle();

    expect(find.text('ADD TO BAG'), findsOneWidget);
    await tester.ensureVisible(find.text('ADD TO BAG'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ADD TO BAG'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome back'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    final settings = find.text('Account Settings');
    await tester.ensureVisible(settings);
    await tester.pumpAndSettle();
    await tester.tap(settings);
    await tester.pumpAndSettle();
    expect(find.text('Privacy, security and preferences'), findsOneWidget);
    await tester.tap(find.text('Personal information'));
    await tester.pumpAndSettle();
    expect(find.text('Your member information'), findsOneWidget);
  });

  testWidgets('Checkout page presents payment methods', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          addressesProvider.overrideWith((ref) async => const []),
          paystackEnabledProvider.overrideWith((ref) async => true),
          authProvider.overrideWith(_UnauthenticatedController.new),
        ],
        child: const MaterialApp(home: CheckoutPage(cart: StoreCart.empty())),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('ORDER SUMMARY'), findsOneWidget);
    expect(find.text('Paystack secure checkout'), findsOneWidget);
  });

  testWidgets('Bag and filter sheet fit on a small screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BagContent(
            cart: StoreCart(
              items: [
                CartItem(
                  product: sampleStoreProducts.first,
                  quantity: 3,
                  lineTotalKobo: 21000000,
                ),
              ],
              itemCount: 3,
              subtotalKobo: 21000000,
            ),
            isSignedIn: true,
            onContinueShopping: () {},
            onSignIn: () {},
            onCheckout: () {},
          ),
        ),
      ),
    );
    expect(find.text('Proceed to checkout'), findsOneWidget);

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: FilterSortSheet())),
    );
    expect(find.text('Filter & sort'), findsOneWidget);
    expect(find.text('Apply filters'), findsOneWidget);
  });
}
