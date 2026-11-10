import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/store_colors.dart';
import 'features/splash/presentation/splash_screen.dart';

class JalStudioApp extends StatelessWidget {
  const JalStudioApp({super.key});

  @override
  Widget build(BuildContext context) => ProviderScope(
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EKŌ',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: StoreColors.olive,
          surface: StoreColors.paper,
        ),
        scaffoldBackgroundColor: StoreColors.paper,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          backgroundColor: StoreColors.paper,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      home: const SplashScreen(),
    ),
  );
}
