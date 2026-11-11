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
      title: 'JAL Studio',
      theme: _buildTheme(),
      home: const SplashScreen(),
    ),
  );

  ThemeData _buildTheme() {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: StoreColors.olive,
          surface: StoreColors.paper,
        ).copyWith(
          primary: StoreColors.ink,
          onPrimary: StoreColors.white,
          secondary: StoreColors.olive,
          onSecondary: StoreColors.white,
          surface: StoreColors.paper,
          onSurface: StoreColors.ink,
          outline: StoreColors.line,
        );
    const radius = BorderRadius.all(Radius.circular(12));
    final textTheme = ThemeData.light().textTheme.copyWith(
      displayLarge: const TextStyle(
        color: StoreColors.ink,
        fontFamily: 'serif',
        fontSize: 44,
        height: 1.08,
        fontWeight: FontWeight.w400,
      ),
      headlineLarge: const TextStyle(
        color: StoreColors.ink,
        fontFamily: 'serif',
        fontSize: 34,
        height: 1.12,
        fontWeight: FontWeight.w400,
      ),
      headlineMedium: const TextStyle(
        color: StoreColors.ink,
        fontFamily: 'serif',
        fontSize: 28,
        height: 1.18,
        fontWeight: FontWeight.w400,
      ),
      titleLarge: const TextStyle(
        color: StoreColors.ink,
        fontSize: 17,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: const TextStyle(
        color: StoreColors.ink,
        fontSize: 15,
        height: 1.5,
      ),
      bodyMedium: const TextStyle(
        color: StoreColors.ink,
        fontSize: 14,
        height: 1.45,
      ),
      bodySmall: const TextStyle(
        color: StoreColors.muted,
        fontSize: 12,
        height: 1.4,
      ),
      labelLarge: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: .2,
      ),
    );

    return ThemeData(
      colorScheme: scheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: StoreColors.paper,
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        backgroundColor: StoreColors.paper,
        foregroundColor: StoreColors.ink,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          color: StoreColors.ink,
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: .3,
        ),
      ),
      cardTheme: CardThemeData(
        color: StoreColors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: const BorderSide(color: StoreColors.line),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: StoreColors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        hintStyle: const TextStyle(color: StoreColors.muted, fontSize: 13),
        labelStyle: const TextStyle(color: StoreColors.muted, fontSize: 13),
        border: OutlineInputBorder(
          borderRadius: radius,
          borderSide: const BorderSide(color: StoreColors.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: const BorderSide(color: StoreColors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: const BorderSide(color: StoreColors.olive, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: const BorderSide(color: Color(0xFFB54A42)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: const BorderSide(color: Color(0xFFB54A42), width: 1.4),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: StoreColors.ink,
          foregroundColor: StoreColors.white,
          minimumSize: const Size(48, 50),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: radius),
          textStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: .3,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: StoreColors.ink,
          minimumSize: const Size(44, 46),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          side: const BorderSide(color: StoreColors.line),
          shape: RoundedRectangleBorder(borderRadius: radius),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: StoreColors.ink,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: StoreColors.white,
        selectedColor: StoreColors.oliveWash,
        labelStyle: const TextStyle(fontSize: 12),
        side: const BorderSide(color: StoreColors.line),
        shape: const StadiumBorder(),
        showCheckmark: false,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 70,
        backgroundColor: StoreColors.white,
        surfaceTintColor: Colors.transparent,
        indicatorColor: StoreColors.oliveWash,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 10,
            letterSpacing: .1,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w600
                : FontWeight.w400,
          ),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: StoreColors.line,
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: StoreColors.ink,
        contentTextStyle: const TextStyle(color: StoreColors.white),
        shape: RoundedRectangleBorder(borderRadius: radius),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: StoreColors.olive,
        linearTrackColor: StoreColors.sand,
      ),
    );
  }
}
