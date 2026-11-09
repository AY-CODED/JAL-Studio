import 'package:flutter/material.dart';

import '../theme/store_colors.dart';

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

class StoreEyebrow extends StatelessWidget {
  const StoreEyebrow(this.text, {super.key});
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

class PriceLine extends StatelessWidget {
  const PriceLine({
    super.key,
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
