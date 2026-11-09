import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;
  final Set<int> _wishlist = {};
  int _cartCount = 0;

  void _openProduct(int index) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProductDetailsPage(
          product: storeProducts[index % storeProducts.length],
          onAddToBag: _addToBag,
          isWishlisted: _wishlist.contains(index),
          onWishlist: () => _toggleWishlist(index),
        ),
      ),
    );
  }

  void _toggleWishlist(int index) {
    setState(() {
      if (!_wishlist.add(index)) _wishlist.remove(index);
    });
  }

  void _addToBag() => setState(() => _cartCount++);

  @override
  Widget build(BuildContext context) {
    final tabs = [
      StoreHomeContent(
        wishlist: _wishlist,
        onWishlist: _toggleWishlist,
        onOpenProduct: _openProduct,
        onShop: () => setState(() => _tab = 1),
      ),
      ShopContent(
        wishlist: _wishlist,
        onWishlist: _toggleWishlist,
        onOpenProduct: _openProduct,
      ),
      ProductCollectionPage(
        title: 'Wishlist',
        products: _wishlist
            .map((index) => storeProducts[index % storeProducts.length])
            .toList(),
        onOpenProduct: _openProduct,
        onWishlist: _toggleWishlist,
        wishlist: _wishlist,
        emptyMessage: 'Your saved pieces will appear here.',
      ),
      BagContent(
        itemCount: _cartCount,
        onContinueShopping: () => setState(() => _tab = 1),
        onCheckout: () => Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: (_) => const CheckoutPage())),
      ),
      ProfileContent(
        onOpen: (page) =>
            Navigator.of(context)
                .push(MaterialPageRoute<void>(builder: (_) => page)),
      ),
    ];

    return Scaffold(
      backgroundColor: StoreColors.paper,
      appBar: _buildAppBar(),
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

  PreferredSizeWidget _buildAppBar() => AppBar(
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
          isLabelVisible: _cartCount > 0,
          label: Text('$_cartCount'),
          backgroundColor: StoreColors.ink,
          child: const Icon(
            Icons.shopping_cart_outlined,
            color: StoreColors.ink,
          ),
        ),
      ),
    ],
  );
}

class StoreHomeContent extends StatelessWidget {
  const StoreHomeContent({
    super.key,
    required this.wishlist,
    required this.onWishlist,
    required this.onOpenProduct,
    required this.onShop,
  });

  final Set<int> wishlist;
  final ValueChanged<int> onWishlist;
  final ValueChanged<int> onOpenProduct;
  final VoidCallback onShop;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: SizedBox(
            height: 230,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset('assets/images/banner1.jpg', fit: BoxFit.cover),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.black26, Colors.black87],
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'NEW COLLECTION',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Timeless Elegance\nStarts Here',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        height: 1.15,
                        fontFamily: 'serif',
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Modern styles. Classic vibes.',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: onShop,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white),
                      ),
                      child: const Text('Shop now  →'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        const CategoryChips(
          categories: ['All', 'Men', 'Women', 'Accessories', 'Activewear'],
        ),
        const SizedBox(height: 16),
        ProductGrid(
          products: storeProducts,
          wishlist: wishlist,
          onWishlist: onWishlist,
          onOpenProduct: onOpenProduct,
        ),
      ],
    ),
  );
}

class ShopContent extends StatefulWidget {
  const ShopContent({
    super.key,
    required this.wishlist,
    required this.onWishlist,
    required this.onOpenProduct,
  });
  final Set<int> wishlist;
  final ValueChanged<int> onWishlist;
  final ValueChanged<int> onOpenProduct;

  @override
  State<ShopContent> createState() => _ShopContentState();
}

class _ShopContentState extends State<ShopContent> {
  String _category = 'All';

  @override
  Widget build(BuildContext context) {
    final products = _category == 'All'
        ? storeProducts
        : storeProducts
              .where(
                (product) => product.category.toLowerCase().contains(
                  _category.toLowerCase(),
                ),
              )
              .toList();
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'HOME  ›  ${_category.toUpperCase()}',
            style: const TextStyle(
              fontSize: 10,
              letterSpacing: 1.2,
              color: StoreColors.muted,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _category == 'All' ? 'Shop' : '${_category}wear',
            style: const TextStyle(fontSize: 32, fontFamily: 'serif'),
          ),
          const Text(
            'Modern styles for every occasion. Find your next look.',
            style: TextStyle(color: StoreColors.muted),
          ),
          const SizedBox(height: 18),
          CategoryChips(
            categories: const [
              'All',
              'Men',
              'Women',
              'Accessories',
              'Activewear',
            ],
            selected: _category,
            onSelected: (category) => setState(() => _category = category),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${products.length} pieces',
                style: const TextStyle(color: StoreColors.muted, fontSize: 12),
              ),
              TextButton.icon(
                onPressed: () => showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: StoreColors.paper,
                  builder: (_) => const FilterSortSheet(),
                ),
                icon: const Icon(Icons.tune, size: 18),
                label: const Text('Filter & sort'),
                style: TextButton.styleFrom(foregroundColor: StoreColors.ink),
              ),
            ],
          ),
          ProductGrid(
            products: products,
            wishlist: widget.wishlist,
            onWishlist: widget.onWishlist,
            onOpenProduct: widget.onOpenProduct,
          ),
        ],
      ),
    );
  }
}

class ProductCollectionPage extends StatelessWidget {
  const ProductCollectionPage({
    super.key,
    required this.title,
    required this.products,
    required this.onOpenProduct,
    required this.onWishlist,
    required this.wishlist,
    this.emptyMessage = 'There are no items here yet.',
  });
  final String title;
  final List<StoreProduct> products;
  final ValueChanged<int> onOpenProduct;
  final ValueChanged<int> onWishlist;
  final Set<int> wishlist;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) => products.isEmpty
      ? Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Text(
              emptyMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(color: StoreColors.muted),
            ),
          ),
        )
      : SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontFamily: 'serif', fontSize: 32),
              ),
              const SizedBox(height: 16),
              ProductGrid(
                products: products,
                wishlist: wishlist,
                onWishlist: onWishlist,
                onOpenProduct: onOpenProduct,
              ),
            ],
          ),
        );
}

class CategoryChips extends StatefulWidget {
  const CategoryChips({
    super.key,
    required this.categories,
    this.selected = 'All',
    this.onSelected,
  });
  final List<String> categories;
  final String selected;
  final ValueChanged<String>? onSelected;

  @override
  State<CategoryChips> createState() => _CategoryChipsState();
}

class _CategoryChipsState extends State<CategoryChips> {
  late String _selected = widget.selected;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 40,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: widget.categories.length,
      separatorBuilder: (_, _) => const SizedBox(width: 8),
      itemBuilder: (context, index) {
        final category = widget.categories[index];
        final isSelected = _selected == category;
        return ChoiceChip(
          label: Text(category),
          selected: isSelected,
          onSelected: (_) {
            setState(() => _selected = category);
            widget.onSelected?.call(category);
          },
          selectedColor: StoreColors.ink,
          backgroundColor: StoreColors.paper,
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : StoreColors.ink,
            fontSize: 12,
          ),
          side: BorderSide(
            color: isSelected ? StoreColors.ink : StoreColors.line,
          ),
          shape: const StadiumBorder(),
          showCheckmark: false,
        );
      },
    ),
  );
}

class ProductGrid extends StatelessWidget {
  const ProductGrid({
    super.key,
    required this.products,
    required this.wishlist,
    required this.onWishlist,
    required this.onOpenProduct,
  });
  final List<StoreProduct> products;
  final Set<int> wishlist;
  final ValueChanged<int> onWishlist;
  final ValueChanged<int> onOpenProduct;

  @override
  Widget build(BuildContext context) => GridView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: products.length,
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: .63,
    ),
    itemBuilder: (context, index) {
      final product = products[index];
      final id = storeProducts.indexOf(product);
      final saved = wishlist.contains(id);
      return GestureDetector(
        onTap: () => onOpenProduct(id < 0 ? index : id),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      product.image,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) =>
                          const ColoredBox(color: StoreColors.sand),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: CircleIconButton(
                      icon: saved ? Icons.favorite : Icons.favorite_border,
                      onPressed: () => onWishlist(id < 0 ? index : id),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              product.category.toUpperCase(),
              style: const TextStyle(
                color: StoreColors.muted,
                fontSize: 9,
                letterSpacing: .8,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              product.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  product.price,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: () => onOpenProduct(id < 0 ? index : id),
                  icon: const Icon(Icons.shopping_cart_outlined, size: 18),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}

class ProfileContent extends StatelessWidget {
  const ProfileContent({super.key, required this.onOpen});
  final ValueChanged<Widget> onOpen;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const CircleAvatar(
              radius: 34,
              backgroundColor: StoreColors.sand,
              child: Icon(Icons.person, color: StoreColors.ink, size: 34),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ayomipo Soyinka  ✓',
                    style: TextStyle(fontFamily: 'serif', fontSize: 18),
                  ),
                  Text(
                    'PREMIUM MEMBER',
                    style: TextStyle(
                      letterSpacing: 1.2,
                      fontSize: 9,
                      color: StoreColors.muted,
                    ),
                  ),
                  Text(
                    'Style is a language. I speak it well.',
                    style: TextStyle(fontSize: 11, color: StoreColors.muted),
                  ),
                  Text('⌖ Lagos, Nigeria', style: TextStyle(fontSize: 11)),
                ],
              ),
            ),
            TextButton(
              onPressed: () => onOpen(const EditProfilePage()),
              child: const Text('Edit profile'),
            ),
          ],
        ),
        const SizedBox(height: 18),
        const _StatsRow(),
        const SizedBox(height: 18),
        _SectionHeading(
          title: 'My Measurements',
          action: 'View / Edit',
          onTap: () => onOpen(const BodyMeasurementsPage()),
        ),
        const SizedBox(height: 10),
        const _MeasurementSummary(),
        const SizedBox(height: 22),
        _SectionHeading(
          title: 'Recent Orders',
          action: 'View all',
          onTap: () => onOpen(const OrderHistoryPage()),
        ),
        const SizedBox(height: 8),
        ...[
          'Custom Suit Set',
          'Linen Blend Outfit',
          'Classic Overcoat',
        ].map((name) => _OrderPreview(name: name)),
        const SizedBox(height: 14),
        ...[
          (
            'Account Settings',
            'Personal info, email, password',
            const AccountSettingsPage(),
          ),
          (
            'Notifications',
            'Your notification preferences',
            const NotificationsPage(),
          ),
          (
            'Delivery Addresses',
            'Manage your saved addresses',
            const DeliveryAddressesPage(),
          ),
          (
            'Messages',
            'Chat with your stylist and ateliers',
            const MessagesPage(),
          ),
          ('Help & Support', 'FAQs and contact us', const HelpSupportPage()),
        ].map(
          (item) => _ProfileLink(
            title: item.$1,
            subtitle: item.$2,
            onTap: () => onOpen(item.$3),
          ),
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: StoreColors.sand,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Row(
            children: [
              Icon(Icons.workspace_premium_outlined),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Private Client Concierge\nNeed help? Our style experts are here for you.',
                  style: TextStyle(fontSize: 12),
                ),
              ),
              Icon(Icons.arrow_forward),
            ],
          ),
        ),
      ],
    ),
  );
}

class _StatsRow extends StatelessWidget {
  const _StatsRow();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 14),
    decoration: BoxDecoration(
      border: Border.all(color: StoreColors.line),
      borderRadius: BorderRadius.circular(12),
    ),
    child: const Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _Stat(value: '12', label: 'Orders'),
        _Stat(value: '3', label: 'Measurements'),
        _Stat(value: '2', label: 'Saved looks'),
        _Stat(value: '1 year+', label: 'Member since'),
      ],
    ),
  );
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});
  final String value;
  final String label;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(value, style: const TextStyle(fontSize: 18, fontFamily: 'serif')),
      Text(
        label,
        style: const TextStyle(fontSize: 9, color: StoreColors.muted),
      ),
    ],
  );
}

class _MeasurementSummary extends StatelessWidget {
  const _MeasurementSummary();
  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 8,
    runSpacing: 8,
    children: const [
      _MeasurementTile(label: 'Chest', value: '40 in'),
      _MeasurementTile(label: 'Waist', value: '32 in'),
      _MeasurementTile(label: 'Hips', value: '38 in'),
      _MeasurementTile(label: 'Height', value: '6\'0"'),
      _MeasurementTile(label: 'Weight', value: '75 kg'),
      _MeasurementTile(label: 'Shoe size', value: '10 (US)'),
    ],
  );
}

class _MeasurementTile extends StatelessWidget {
  const _MeasurementTile({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Container(
    width: (MediaQuery.sizeOf(context).width - 52) / 3,
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: StoreColors.line),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: StoreColors.muted),
        ),
        Text(value, style: const TextStyle(fontSize: 15, fontFamily: 'serif')),
      ],
    ),
  );
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.title,
    required this.action,
    required this.onTap,
  });
  final String title;
  final String action;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(title, style: const TextStyle(fontSize: 18, fontFamily: 'serif')),
      TextButton(
        onPressed: onTap,
        child: Text(
          action,
          style: const TextStyle(color: StoreColors.muted, fontSize: 11),
        ),
      ),
    ],
  );
}

class _OrderPreview extends StatelessWidget {
  const _OrderPreview({required this.name});
  final String name;
  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.asset(
        'assets/images/banner2.jpg',
        width: 42,
        height: 46,
        fit: BoxFit.cover,
      ),
    ),
    title: Text(name, style: const TextStyle(fontSize: 12)),
    subtitle: const Text('Delivered', style: TextStyle(fontSize: 10)),
    trailing: const Icon(Icons.chevron_right, size: 18),
    dense: true,
  );
}

class _ProfileLink extends StatelessWidget {
  const _ProfileLink({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: const Icon(Icons.circle_outlined, size: 20),
    title: Text(title, style: const TextStyle(fontSize: 13)),
    subtitle: Text(
      subtitle,
      style: const TextStyle(fontSize: 10, color: StoreColors.muted),
    ),
    trailing: const Icon(Icons.chevron_right, size: 19),
    onTap: onTap,
  );
}

class BagContent extends StatelessWidget {
  const BagContent({
    super.key,
    required this.itemCount,
    required this.onContinueShopping,
    required this.onCheckout,
  });
  final int itemCount;
  final VoidCallback onContinueShopping;
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    if (itemCount == 0) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.shopping_bag_outlined,
              size: 48,
              color: StoreColors.muted,
            ),
            const SizedBox(height: 12),
            const Text(
              'Your bag is waiting',
              style: TextStyle(fontSize: 22, fontFamily: 'serif'),
            ),
            const SizedBox(height: 6),
            const Text(
              'Discover pieces made for you.',
              style: TextStyle(color: StoreColors.muted),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: onContinueShopping,
              style: FilledButton.styleFrom(backgroundColor: StoreColors.ink),
              child: const Text('Continue shopping'),
            ),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your bag',
            style: TextStyle(fontFamily: 'serif', fontSize: 30),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: ListView.builder(
              itemCount: itemCount,
              itemBuilder: (context, index) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    storeProducts[index % storeProducts.length].image,
                    width: 68,
                    height: 76,
                    fit: BoxFit.cover,
                  ),
                ),
                title: Text(storeProducts[index % storeProducts.length].name),
                subtitle: Text(
                  storeProducts[index % storeProducts.length].price,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Divider(),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text('Subtotal'), Text('₦70,000')],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onCheckout,
              style: FilledButton.styleFrom(
                backgroundColor: StoreColors.ink,
                padding: const EdgeInsets.all(16),
              ),
              child: const Text('Proceed to checkout'),
            ),
          ),
        ],
      ),
    );
  }
}

class FilterSortSheet extends StatefulWidget {
  const FilterSortSheet({super.key});
  @override
  State<FilterSortSheet> createState() => _FilterSortSheetState();
}

class _FilterSortSheetState extends State<FilterSortSheet> {
  String _sort = 'Recommended';
  @override
  Widget build(BuildContext context) => SafeArea(
    child: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: StoreColors.line,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filter & sort',
                  style: TextStyle(fontSize: 28, fontFamily: 'serif'),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const Divider(),
            const Text(
              'SORT BY',
              style: TextStyle(
                fontSize: 10,
                letterSpacing: 1.5,
                fontWeight: FontWeight.bold,
              ),
            ),
            ...[
              'Recommended',
              'Newest first',
              'Price: low to high',
              'Price: high to low',
            ].map(
              (value) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(value, style: const TextStyle(fontSize: 13)),
                trailing: Icon(
                  _sort == value
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: StoreColors.ink,
                ),
                onTap: () => setState(() => _sort = value),
              ),
            ),
            const Divider(),
            ...['Category', 'Size', 'Colour', 'Price'].map(
              (value) => ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title: Text(value, style: const TextStyle(fontSize: 14)),
                children: [
                  Wrap(
                    spacing: 8,
                    children: ['S', 'M', 'L', 'XL']
                        .map(
                          (size) => ChoiceChip(
                            label: Text(size),
                            selected: false,
                            onSelected: (_) {},
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                style: FilledButton.styleFrom(
                  backgroundColor: StoreColors.ink,
                  padding: const EdgeInsets.all(15),
                ),
                child: const Text('Show 6 pieces'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});
  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String _payment = 'Paystack Checkout';
  @override
  Widget build(BuildContext context) => StorePageScaffold(
    title: 'Checkout',
    child: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _Eyebrow('ORDER SUMMARY'),
            const SizedBox(height: 12),
            Card(
              color: Colors.white,
              child: ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/images/banner2.jpg',
                    width: 60,
                    height: 70,
                    fit: BoxFit.cover,
                  ),
                ),
                title: const Text(
                  'Stitched Leather Silk Shirt',
                  style: TextStyle(fontFamily: 'serif', fontSize: 14),
                ),
                subtitle: const Text(
                  'ATELIER URBANETT\nBlue  •  Size M',
                  style: TextStyle(fontSize: 10, height: 1.8),
                ),
                trailing: const Text(
                  '₦70,000',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const _PriceLine(title: 'Subtotal', amount: '₦70,000'),
            const _PriceLine(
              title: 'Lagos Premium Delivery',
              amount: '₦144,890',
            ),
            const Divider(height: 24),
            const _PriceLine(title: 'Total', amount: '₦214,890', bold: true),
            const SizedBox(height: 24),
            const _Eyebrow('PAYMENT METHOD'),
            const SizedBox(height: 10),
            ...['Paystack Checkout', 'Flutterwave', 'Bank Transfer'].map(
              (method) => ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                tileColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: StoreColors.line),
                ),
                title: Text(
                  method,
                  style: const TextStyle(fontFamily: 'serif'),
                ),
                subtitle: Text(
                  method == 'Bank Transfer'
                      ? 'Direct bank transfer'
                      : 'Pay securely with your card',
                  style: const TextStyle(fontSize: 11),
                ),
                leading: Icon(
                  _payment == method
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: StoreColors.olive,
                ),
                onTap: () => setState(() => _payment = method),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Payment selected. Checkout integration can be connected next.',
                    ),
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: StoreColors.ink,
                  padding: const EdgeInsets.all(16),
                ),
                child: const Text('CONFIRM & PAY  ·  ₦214,890  →'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _PriceLine extends StatelessWidget {
  const _PriceLine({
    required this.title,
    required this.amount,
    this.bold = false,
  });
  final String title;
  final String amount;
  final bool bold;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            fontSize: bold ? 18 : 14,
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: bold ? 18 : 14,
          ),
        ),
      ],
    ),
  );
}

class ProductDetailsPage extends StatefulWidget {
  const ProductDetailsPage({
    super.key,
    required this.product,
    required this.onAddToBag,
    required this.isWishlisted,
    required this.onWishlist,
  });
  final StoreProduct product;
  final VoidCallback onAddToBag;
  final bool isWishlisted;
  final VoidCallback onWishlist;

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  String _size = 'M';
  late bool _isWishlisted = widget.isWishlisted;
  @override
  Widget build(BuildContext context) => StorePageScaffold(
    title: 'E K Ō',
    actions: [
      IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
      IconButton(
        onPressed: () {},
        icon: const Icon(Icons.shopping_cart_outlined),
      ),
    ],
    child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.asset(
                    widget.product.image,
                    width: double.infinity,
                    height: 390,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: CircleIconButton(
                    icon: _isWishlisted
                        ? Icons.favorite
                        : Icons.favorite_border,
                    onPressed: () {
                      widget.onWishlist();
                      setState(() => _isWishlisted = !_isWishlisted);
                    },
                  ),
                ),
                const Positioned(
                  left: 12,
                  bottom: 12,
                  child: Chip(
                    label: Text('1 / 5'),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: List.generate(
                4,
                (index) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      'assets/images/banner${index + 1}.jpg',
                      width: 78,
                      height: 70,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _Eyebrow('ATELIER URBANETT'),
                const SizedBox(height: 6),
                Text(
                  widget.product.name,
                  style: const TextStyle(fontSize: 23, fontFamily: 'serif'),
                ),
                Text(
                  widget.product.price,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  '★  4.8  (124 reviews)     ·     ● In Stock',
                  style: TextStyle(fontSize: 12, color: StoreColors.muted),
                ),
                const SizedBox(height: 18),
                const Text('Color', style: TextStyle(fontSize: 13)),
                const SizedBox(height: 8),
                const Row(
                  children: [
                    ColorDot(color: Color(0xFF243957), selected: true),
                    ColorDot(color: Colors.black),
                    ColorDot(color: Color(0xFFCABC9D)),
                    ColorDot(color: Color(0xFFB7B9B8)),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('Size', style: TextStyle(fontSize: 13)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: ['S', 'M', 'L', 'XL', 'XXL']
                      .map(
                        (size) => ChoiceChip(
                          label: Text(size),
                          selected: _size == size,
                          onSelected: (_) => setState(() => _size = size),
                          selectedColor: StoreColors.sand,
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: StoreColors.line),
                        ),
                      )
                      .toList(),
                ),
                const Divider(height: 30),
                const Text(
                  'Payment Method',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'VISA     Mastercard     Verve      Pay     Paystack',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                ),
                const SizedBox(height: 12),
                const Text(
                  '✓ Secure payment   ·   Fast delivery   ·   7-day return policy',
                  style: TextStyle(fontSize: 10, color: StoreColors.muted),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      widget.onAddToBag();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Added to your bag')),
                      );
                    },
                    icon: const Icon(Icons.shopping_bag_outlined),
                    label: const Text('ADD TO BAG'),
                    style: FilledButton.styleFrom(
                      backgroundColor: StoreColors.ink,
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class ColorDot extends StatelessWidget {
  const ColorDot({super.key, required this.color, this.selected = false});
  final Color color;
  final bool selected;
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(right: 10),
    padding: const EdgeInsets.all(3),
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(
        color: selected ? StoreColors.ink : Colors.transparent,
      ),
    ),
    child: CircleAvatar(radius: 11, backgroundColor: color),
  );
}

class AccountSettingsPage extends StatelessWidget {
  const AccountSettingsPage({super.key});
  @override
  Widget build(BuildContext context) => StorePageScaffold(
    title: 'Account Settings',
    child: SingleChildScrollView(
      child: Column(
        children: [
          const PageIntro(
            icon: Icons.lock_outline,
            title: 'Account Settings',
            subtitle: 'Privacy, security and preferences',
          ),
          ...[
            (
              'Personal information',
              'Edit your name and contact details',
              const EditProfilePage(),
            ),
            (
              'Password & security',
              'Face ID is enabled',
              const SimpleInfoPage(
                title: 'Password & security',
                message: 'Manage your password and sign-in security.',
              ),
            ),
            (
              'Communication preferences',
              'Email and SMS',
              const NotificationsPage(),
            ),
            (
              'Privacy controls',
              'Data and personalisation',
              const SimpleInfoPage(
                title: 'Privacy controls',
                message: 'Choose how your personal data is used.',
              ),
            ),
            (
              'Delete account',
              'Permanently remove your account',
              const SimpleInfoPage(
                title: 'Delete account',
                message: 'Contact support to request account deletion.',
              ),
            ),
          ].map(
            (item) => _SettingsRow(
              title: item.$1,
              subtitle: item.$2,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute<void>(builder: (_) => item.$3),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});
  @override
  Widget build(BuildContext context) => StorePageScaffold(
    title: 'Edit Profile',
    child: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          children: [
            const PageIntro(
              icon: Icons.person_outline,
              title: 'Edit Profile',
              subtitle: 'Your member information',
            ),
            const CircleAvatar(
              radius: 42,
              backgroundColor: StoreColors.ink,
              child: Text(
                'OO',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontFamily: 'serif',
                ),
              ),
            ),
            const SizedBox(height: 24),
            const _ProfileTextField(
              label: 'FULL NAME',
              initial: 'Obinna Okeke',
            ),
            const _ProfileTextField(
              label: 'EMAIL ADDRESS',
              initial: 'obinna.okeke@email.com',
            ),
            const _ProfileTextField(
              label: 'PHONE NUMBER',
              initial: '+234 803 452 1970',
            ),
            const _ProfileTextField(
              label: 'DATE OF BIRTH',
              initial: '18 September 1990',
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile changes saved')),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: StoreColors.ink,
                  padding: const EdgeInsets.all(16),
                ),
                child: const Text('Save changes'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _ProfileTextField extends StatelessWidget {
  const _ProfileTextField({required this.label, required this.initial});
  final String label;
  final String initial;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextFormField(
      initialValue: initial,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          fontSize: 9,
          letterSpacing: 1.2,
          color: StoreColors.muted,
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: StoreColors.line),
        ),
      ),
    ),
  );
}

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});
  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  bool _current = true;
  @override
  Widget build(BuildContext context) => StorePageScaffold(
    title: 'Order History',
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => setState(() => _current = true),
                  child: Text(
                    'Current',
                    style: TextStyle(
                      color: _current ? StoreColors.ink : StoreColors.muted,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: TextButton(
                  onPressed: () => setState(() => _current = false),
                  child: Text(
                    'Past orders',
                    style: TextStyle(
                      color: !_current ? StoreColors.ink : StoreColors.muted,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const Divider(),
          if (_current)
            Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                side: const BorderSide(color: StoreColors.line),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ORDER #EKO-260508',
                      style: TextStyle(fontSize: 9, color: StoreColors.muted),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Preparing your order',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Image.asset(
                          'assets/images/banner2.jpg',
                          width: 62,
                          height: 72,
                          fit: BoxFit.cover,
                        ),
                        const SizedBox(width: 8),
                        Image.asset(
                          'assets/images/banner3.jpg',
                          width: 62,
                          height: 72,
                          fit: BoxFit.cover,
                        ),
                        const SizedBox(width: 10),
                        const Text('2 pieces', style: TextStyle(fontSize: 11)),
                      ],
                    ),
                    const Divider(height: 24),
                    const _PriceLine(
                      title: 'Estimated delivery',
                      amount: '₦468,500',
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) => const SimpleInfoPage(
                              title: 'Track order',
                              message: 'Your order is being prepared by the atelier.',
                            ),
                          ),
                        ),
                        child: const Text('Track order'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (!_current)
            const ListTile(
              title: Text('12 FEB 2026 · #EKO-260212'),
              subtitle: Text('Delivered'),
              trailing: Text('₦280,000'),
            ),
        ],
      ),
    ),
  );
}

class BodyMeasurementsPage extends StatelessWidget {
  const BodyMeasurementsPage({super.key});
  @override
  Widget build(BuildContext context) => StorePageScaffold(
    title: 'Body Measurements',
    child: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 190,
              color: StoreColors.sand,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Icon(
                    Icons.accessibility_new,
                    size: 110,
                    color: Color(0xFF9A9A90),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PROFILE',
                        style: TextStyle(fontSize: 9, color: StoreColors.muted),
                      ),
                      Text(
                        'Regular fit',
                        style: TextStyle(fontSize: 23, fontFamily: 'serif'),
                      ),
                      Text(
                        'Last updated 14 March 2026',
                        style: TextStyle(fontSize: 9, color: StoreColors.muted),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Wrap(
              spacing: 0,
              runSpacing: 0,
              children: [
                _MeasureCell(label: 'Chest', value: '102 cm'),
                _MeasureCell(label: 'Waist', value: '86 cm'),
                _MeasureCell(label: 'Seat', value: '100 cm'),
                _MeasureCell(label: 'Shoulder', value: '47 cm'),
                _MeasureCell(label: 'Sleeve', value: '64 cm'),
                _MeasureCell(label: 'Inside leg', value: '81 cm'),
              ],
            ),
            const SizedBox(height: 18),
            const ListTile(
              tileColor: Color(0xFFE9ECE5),
              leading: Icon(Icons.straighten),
              title: Text(
                'Your fit, remembered',
                style: TextStyle(fontSize: 12),
              ),
              subtitle: Text(
                'We use these measurements to recommend your best size.',
                style: TextStyle(fontSize: 10),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Fitting appointment request started'),
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: StoreColors.ink,
                  padding: const EdgeInsets.all(16),
                ),
                child: const Text('Book a fitting appointment'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _MeasureCell extends StatelessWidget {
  const _MeasureCell({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Container(
    width: (MediaQuery.sizeOf(context).width - 38) / 2,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(border: Border.all(color: StoreColors.line)),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: StoreColors.muted),
        ),
        Text(value, style: const TextStyle(fontFamily: 'serif', fontSize: 17)),
      ],
    ),
  );
}

class DeliveryAddressesPage extends StatelessWidget {
  const DeliveryAddressesPage({super.key});
  @override
  Widget build(BuildContext context) => StorePageScaffold(
    title: 'Delivery Addresses',
    child: Padding(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const PageIntro(
            icon: Icons.location_on_outlined,
            title: 'Your addresses',
            subtitle: 'Manage where your orders arrive.',
          ),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              border: Border.all(color: StoreColors.ink),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: Chip(
                    label: Text('DEFAULT', style: TextStyle(fontSize: 9)),
                    backgroundColor: StoreColors.ink,
                    labelStyle: TextStyle(color: Colors.white),
                  ),
                ),
                Text(
                  'Home · Obinna Okeke',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 10),
                Text(
                  '14 Thompson Avenue\nIkoyi, Lagos 106104\n+234 803 452 1970',
                  style: TextStyle(
                    color: StoreColors.muted,
                    fontSize: 12,
                    height: 1.6,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Edit       Remove',
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          OutlinedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(builder: (_) => const AddAddressPage()),
            ),
            icon: const Icon(Icons.add),
            label: const Text('Add a new address'),
            style: OutlinedButton.styleFrom(
              foregroundColor: StoreColors.ink,
              padding: const EdgeInsets.all(16),
            ),
          ),
        ],
      ),
    ),
  );
}

class AddAddressPage extends StatelessWidget {
  const AddAddressPage({super.key});
  @override
  Widget build(BuildContext context) => StorePageScaffold(
    title: 'New address',
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const _ProfileTextField(label: 'ADDRESS LABEL', initial: 'Home'),
          const _ProfileTextField(label: 'FULL NAME', initial: ''),
          const _ProfileTextField(label: 'STREET ADDRESS', initial: ''),
          const _ProfileTextField(label: 'CITY', initial: ''),
          const _ProfileTextField(label: 'PHONE NUMBER', initial: ''),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.pop(context),
              style: FilledButton.styleFrom(
                backgroundColor: StoreColors.ink,
                padding: const EdgeInsets.all(16),
              ),
              child: const Text('Save address'),
            ),
          ),
        ],
      ),
    ),
  );
}

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});
  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final List<bool> _enabled = [true, true, true, false];
  final List<String> _titles = [
    'Order updates',
    'Private styling',
    'New collections',
    'Offers & events',
  ];
  final List<String> _subtitles = [
    'Delivery and payment notifications',
    'Messages from your concierge',
    'Editorial launches and early access',
    'Private events and member benefits',
  ];
  @override
  Widget build(BuildContext context) => StorePageScaffold(
    title: 'Notifications',
    child: Column(
      children: [
        const PageIntro(
          icon: Icons.notifications_none,
          title: 'Notifications',
          subtitle: 'Choose what you hear from us about',
        ),
        ...List.generate(
          _titles.length,
          (index) => SwitchListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 22),
            title: Text(_titles[index], style: const TextStyle(fontSize: 13)),
            subtitle: Text(
              _subtitles[index],
              style: const TextStyle(fontSize: 10, color: StoreColors.muted),
            ),
            value: _enabled[index],
            activeThumbColor: StoreColors.olive,
            onChanged: (value) => setState(() => _enabled[index] = value),
          ),
        ),
      ],
    ),
  );
}

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});
  @override
  Widget build(BuildContext context) => StorePageScaffold(
    title: 'Help & Support',
    child: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'HOW CAN WE HELP?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                letterSpacing: 1.5,
                color: StoreColors.olive,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'We’re here for you.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 34, fontFamily: 'serif'),
            ),
            const SizedBox(height: 22),
            const TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search help topics',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),
            const _SettingsRow(
              title: 'Chat with us',
              subtitle: 'Usually replies instantly',
              onTap: _noop,
            ),
            const _SettingsRow(
              title: 'Ask your stylist',
              subtitle: 'Personal wardrobe advice',
              onTap: _noop,
            ),
            const SizedBox(height: 10),
            ...[
              'Orders & delivery',
              'Returns & exchanges',
              'Sizing & fit',
              'Payments',
              'Product care',
            ].map(
              (topic) => ListTile(
                title: Text(topic, style: const TextStyle(fontSize: 13)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => SimpleInfoPage(
                      title: topic,
                      message:
                          'For help with $topic, chat with our client support team.',
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Or call us on +234 1 888 0456\nMon–Sat, 9am–7pm WAT',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                height: 1.7,
                color: StoreColors.muted,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

void _noop() {}

class MessagesPage extends StatelessWidget {
  const MessagesPage({super.key});
  @override
  Widget build(BuildContext context) => StorePageScaffold(
    title: 'Messages',
    child: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _Eyebrow('ATELIER & CONCIERGE'),
            const Text(
              'Messages',
              style: TextStyle(fontSize: 32, fontFamily: 'serif'),
            ),
            const SizedBox(height: 12),
            const TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search conversations, orders, sellers...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(28)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const CategoryChips(
              categories: ['All', 'Ateliers', 'Concierge', 'Orders'],
            ),
            const SizedBox(height: 12),
            ...[
              ('EKŌ Private Styling', 'Upgrade to Premium · 1 hour ago'),
              ('Atelier Synergy', 'Eli: I’ve prepared some fits. Here’s…'),
              ('EKŌ Client Refills', 'Your wardrobe is 70% Luxe & 30% You.'),
              ('BRIKK Studio', 'Eli: New arrivals just landed.'),
              ('Kensington Atelier', 'Your appointment is confirmed.'),
            ].map(
              (message) => ListTile(
                leading: const CircleAvatar(
                  backgroundColor: StoreColors.sand,
                  child: Icon(
                    Icons.storefront_outlined,
                    color: StoreColors.ink,
                  ),
                ),
                title: Text(
                  message.$1,
                  style: const TextStyle(
                    fontFamily: 'serif',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  message.$2,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        SimpleInfoPage(title: message.$1, message: message.$2),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class SimpleInfoPage extends StatelessWidget {
  const SimpleInfoPage({super.key, required this.title, required this.message});
  final String title;
  final String message;
  @override
  Widget build(BuildContext context) => StorePageScaffold(
    title: title,
    child: Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, color: StoreColors.muted),
        ),
      ),
    ),
  );
}

class PageIntro extends StatelessWidget {
  const PageIntro({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 26, 20, 24),
    child: Column(
      children: [
        CircleAvatar(
          radius: 27,
          backgroundColor: StoreColors.sand,
          child: Icon(icon, color: StoreColors.ink),
        ),
        const SizedBox(height: 16),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 30, fontFamily: 'serif'),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 11, color: StoreColors.muted),
        ),
      ],
    ),
  );
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => ListTile(
    onTap: onTap,
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    title: Text(
      title,
      style: TextStyle(
        fontSize: 13,
        color: title == 'Delete account' ? Colors.brown : StoreColors.ink,
      ),
    ),
    subtitle: Text(
      subtitle,
      style: const TextStyle(fontSize: 10, color: StoreColors.muted),
    ),
    trailing: const Icon(Icons.chevron_right, size: 18),
  );
}

class StorePageScaffold extends StatelessWidget {
  const StorePageScaffold({
    super.key,
    required this.title,
    required this.child,
    this.actions = const [],
  });
  final String title;
  final Widget child;
  final List<Widget> actions;
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: StoreColors.paper,
    appBar: AppBar(
      backgroundColor: StoreColors.paper,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.maybePop(context),
        icon: const Icon(Icons.arrow_back, color: StoreColors.ink),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: StoreColors.ink,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
      actions: actions,
    ),
    body: SafeArea(child: child),
  );
}

class CircleIconButton extends StatelessWidget {
  const CircleIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
  });
  final IconData icon;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    shape: const CircleBorder(),
    child: IconButton(
      onPressed: onPressed,
      icon: Icon(icon, size: 19, color: StoreColors.ink),
      constraints: const BoxConstraints.tightFor(width: 38, height: 38),
      padding: EdgeInsets.zero,
    ),
  );
}

class _Eyebrow extends StatelessWidget {
  const _Eyebrow(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      color: StoreColors.olive,
      fontSize: 10,
      letterSpacing: 2,
      fontWeight: FontWeight.w600,
    ),
  );
}

class StoreProduct {
  const StoreProduct({
    required this.name,
    required this.category,
    required this.price,
    required this.image,
  });
  final String name;
  final String category;
  final String price;
  final String image;
}

const storeProducts = [
  StoreProduct(
    name: 'Stitched Leather Silk Blazer',
    category: 'Atelier Urbanett',
    price: '₦70,000',
    image: 'assets/images/banner1.jpg',
  ),
  StoreProduct(
    name: 'Linen Blend Suit',
    category: 'Atelier Urbanett',
    price: '₦95,000',
    image: 'assets/images/banner2.jpg',
  ),
  StoreProduct(
    name: 'Classic Overcoat',
    category: 'Men’s wear',
    price: '₦120,000',
    image: 'assets/images/banner3.jpg',
  ),
  StoreProduct(
    name: 'Two Piece Set',
    category: 'Women’s wear',
    price: '₦80,000',
    image: 'assets/images/banner4.jpg',
  ),
  StoreProduct(
    name: 'Floral Midi Dress',
    category: 'Women’s wear',
    price: '₦32,000',
    image: 'assets/images/banner2.jpg',
  ),
  StoreProduct(
    name: 'Oversized Tee Set',
    category: 'Men’s wear',
    price: '₦28,000',
    image: 'assets/images/banner3.jpg',
  ),
];

abstract final class StoreColors {
  static const paper = Color(0xFFF8F7F3);
  static const sand = Color(0xFFE9E5DA);
  static const ink = Color(0xFF171716);
  static const muted = Color(0xFF77766F);
  static const line = Color(0xFFDCDAD3);
  static const olive = Color(0xFF69705F);
}
