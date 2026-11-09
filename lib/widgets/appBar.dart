import 'package:flutter/material.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final int cartCount;

  const AppBarWidget({
    super.key,
    required this.title,
    this.cartCount = 3,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 0,

      leading: IconButton(
        onPressed: () {
          Scaffold.of(context).openDrawer();
        },
        icon: const Icon(
          Icons.menu,
          color: Colors.black,
          size: 27,
        ),
      ),

      title: Image.asset(
        'assets/images/LogoLight.png',
        height: 38,
        fit: BoxFit.contain,
      ),

      centerTitle: true,

      actions: [
        IconButton(
          onPressed: () {
            // Navigate to search screen
          },
          icon: const Icon(
            Icons.search,
            color: Colors.black,
            size: 27,
          ),
        ),

        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: IconButton(
            onPressed: () {
              // Navigate to cart screen
            },
            icon: Badge(
              label: Text('$cartCount'),
              backgroundColor: Colors.black,
              textColor: Colors.white,
              child: const Icon(
                Icons.shopping_cart_outlined,
                color: Colors.black,
                size: 25,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
