import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/api_error_message.dart';
import '../core/theme/store_colors.dart';
import '../features/auth/presentation/sign_in_page.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/account/data/account_repository.dart';
import '../features/cart_checkout/data/cart_repository.dart';
import '../features/cart_checkout/presentation/bag_content.dart';
import '../features/cart_checkout/presentation/checkout_page.dart';
import '../features/catalog/data/catalog_repository.dart';
import '../features/catalog/domain/store_product.dart';
import '../features/catalog/presentation/catalog_pages.dart';
import '../features/catalog/presentation/product_details_page.dart';
import '../features/profile/presentation/profile_content.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _tab = 0;

  Future<void> _openPage(Widget page) async {
    await Navigator.of(context)
        .push<void>(MaterialPageRoute<void>(builder: (_) => page));
  }

  void _openProduct(StoreProduct product) {
    _openPage(
      ProductDetailsPage(
        product: product,
        isWishlisted: (ref.read(wishlistProvider).asData?.value ?? const [])
            .any((item) => item.id == product.id),
        onWishlist: () => _toggleWishlist(product.id),
        onAddToBag: _addToBag,
      ),
    );
  }

  Future<void> _toggleWishlist(String productId) async {
    if (ref.read(authProvider).asData?.value == null) {
      await _openPage(const SignInPage());
      if (!mounted || ref.read(authProvider).asData?.value == null) return;
    }
    try {
      final saved = (ref.read(wishlistProvider).asData?.value ?? const []).any(
        (product) => product.id == productId,
      );
      if (saved) {
        await ref.read(accountRepositoryProvider).removeFromWishlist(productId);
      } else {
        await ref.read(accountRepositoryProvider).addToWishlist(productId);
      }
      ref.invalidate(wishlistProvider);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(apiErrorMessage(error))));
      }
    }
  }

  Future<void> _addToBag(
    StoreProduct product,
    String size,
    String? color,
  ) async {
    if (ref.read(authProvider).asData?.value == null) {
      await _openPage(const SignInPage());
      if (!mounted || ref.read(authProvider).asData?.value == null) return;
    }

    try {
      await ref
          .read(cartRepositoryProvider)
          .addItem(
            productId: product.id,
            quantity: 1,
            size: size,
            color: color,
          );
      ref.invalidate(cartProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${product.name} added to your bag')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(apiErrorMessage(error))));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final catalog = ref.watch(catalogProductsProvider);
    final auth = ref.watch(authProvider);
    final cart = ref.watch(cartProvider);
    final wishlist = ref.watch(wishlistProvider);
    final savedProducts = wishlist.asData?.value ?? const <StoreProduct>[];
    final wishlistIds = savedProducts.map((product) => product.id).toSet();
    final user = auth.asData?.value;

    final tabs = [
      catalog.when(
        data: (items) => StoreHomeContent(
          products: items,
          wishlist: wishlistIds,
          onWishlist: _toggleWishlist,
          onOpenProduct: _openProduct,
          onShop: () => setState(() => _tab = 1),
        ),
        loading: _buildLoading,
        error: (error, _) => _LoadError(
          message: apiErrorMessage(error),
          onRetry: () => ref.invalidate(catalogProductsProvider),
        ),
      ),
      catalog.when(
        data: (items) => ShopContent(
          products: items,
          wishlist: wishlistIds,
          onWishlist: _toggleWishlist,
          onOpenProduct: _openProduct,
        ),
        loading: _buildLoading,
        error: (error, _) => _LoadError(
          message: apiErrorMessage(error),
          onRetry: () => ref.invalidate(catalogProductsProvider),
        ),
      ),
      ProductCollectionPage(
        title: 'Wishlist',
        products: savedProducts,
        onOpenProduct: _openProduct,
        onWishlist: _toggleWishlist,
        wishlist: wishlistIds,
        emptyMessage: 'Your saved pieces will appear here.',
      ),
      cart.when(
        data: (items) => BagContent(
          cart: items,
          isSignedIn: user != null,
          onContinueShopping: () => setState(() => _tab = 1),
          onSignIn: () => _openPage(const SignInPage()),
          onCheckout: _openCheckout,
        ),
        loading: _buildLoading,
        error: (error, _) => _LoadError(
          message: apiErrorMessage(error),
          onRetry: () => ref.invalidate(cartProvider),
        ),
      ),
      ProfileContent(
        userName: user?.fullName,
        email: user?.email,
        onSignIn: () => _openPage(const SignInPage()),
        onSignOut: user == null ? null : _signOut,
        isAdmin: user?.role == 'admin',
        onOpen: _openPage,
      ),
    ];

    return Scaffold(
      backgroundColor: StoreColors.paper,
      appBar: _buildAppBar(cart.asData?.value.itemCount ?? 0),
      body: IndexedStack(index: _tab, children: tabs),
      bottomNavigationBar: NavigationBar(
        backgroundColor: StoreColors.paper,
        surfaceTintColor: Colors.transparent,
        indicatorColor: StoreColors.sand,
        selectedIndex: _tab,
        onDestinationSelected: (index) => setState(() => _tab = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(icon: Icon(Icons.search), label: 'Shop'),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: 'Wishlist',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_bag_outlined),
            label: 'Bag',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() =>
      const Center(child: CircularProgressIndicator(color: StoreColors.olive));

  PreferredSizeWidget _buildAppBar(int cartCount) => AppBar(
    backgroundColor: StoreColors.paper,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    leading: IconButton(
      icon: const Icon(Icons.menu, color: StoreColors.ink),
      onPressed: () => setState(() => _tab = 4),
    ),
    title: const Text(
      'E K Ō',
      style: TextStyle(
        color: StoreColors.ink,
        fontWeight: FontWeight.w700,
        letterSpacing: 4,
      ),
    ),
    centerTitle: true,
    actions: [
      IconButton(
        onPressed: () => setState(() => _tab = 1),
        icon: const Icon(Icons.search, color: StoreColors.ink),
      ),
      IconButton(
        onPressed: () => setState(() => _tab = 3),
        icon: Badge(
          isLabelVisible: cartCount > 0,
          label: Text('$cartCount'),
          backgroundColor: StoreColors.ink,
          child: const Icon(
            Icons.shopping_cart_outlined,
            color: StoreColors.ink,
          ),
        ),
      ),
    ],
  );

  Future<void> _signOut() async {
    await ref.read(authProvider.notifier).signOut();
    ref.invalidate(cartProvider);
  }

  void _openCheckout() {
    if (ref.read(authProvider).asData?.value == null) {
      _openPage(const SignInPage());
      return;
    }
    final cart = ref.read(cartProvider).asData?.value;
    if (cart == null || cart.itemCount == 0) return;
    _openPage(CheckoutPage(cart: cart));
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_outlined, size: 40),
          const SizedBox(height: 12),
          const Text(
            'Could not load the store',
            style: TextStyle(fontFamily: 'serif', fontSize: 22),
          ),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onRetry, child: const Text('Try again')),
        ],
      ),
    ),
  );
}
