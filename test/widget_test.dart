// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jal_studio/screens/home_screen.dart';

void main() {
  testWidgets('Storefront opens product details', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

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
    await tester.pump();
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
    await tester.pumpWidget(const MaterialApp(home: CheckoutPage()));

    expect(find.text('ORDER SUMMARY'), findsOneWidget);
    expect(find.text('Paystack Checkout'), findsOneWidget);
    expect(find.text('Flutterwave'), findsOneWidget);
    expect(find.text('Bank Transfer'), findsOneWidget);
  });

  testWidgets('Bag and filter sheet fit on a small screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BagContent(
            itemCount: 3,
            onContinueShopping: () {},
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
    expect(find.text('Show 6 pieces'), findsOneWidget);
  });
}
