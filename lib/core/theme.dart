import 'package:flutter/material.dart';

class AppColors {
  static const navy = Color(0xFF0B1430);
  static const violet = Color(0xFF6C47FF);
  static const teal = Color(0xFF14B8A6);
  static const amber = Color(0xFFF59E0B);
  static const pink = Color(0xFFEC4899);
}

class Sp {
  static const double s = 8, m = 16, l = 24;
}

final themeModeNotifier = ValueNotifier<ThemeMode>(ThemeMode.system);

ThemeData buildTheme(Brightness b) {
  final d = b == Brightness.dark;
  final cs = ColorScheme(
    brightness: b,
    primary: d ? const Color(0xFFA48BFF) : AppColors.violet,
    onPrimary: d ? AppColors.navy : Colors.white,
    secondary: AppColors.teal,
    onSecondary: AppColors.navy,
    error: const Color(0xFFE5484D),
    onError: Colors.white,
    surface: d ? const Color(0xFF141E3D) : Colors.white,
    onSurface: d ? const Color(0xFFE8ECFF) : AppColors.navy,
    onSurfaceVariant: d ? const Color(0xFFA9B3D6) : const Color(0xFF55607F),
    outlineVariant: d ? const Color(0xFF26325C) : const Color(0xFFE1E5F2),
    surfaceContainerHighest: d ? const Color(0xFF1C2850) : const Color(0xFFE9ECF8),
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: cs,
    scaffoldBackgroundColor: d ? const Color(0xFF0A1128) : const Color(0xFFF4F6FC),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: cs.onSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: cs.onSurface),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: cs.surface,
      indicatorColor: cs.primary.withValues(alpha: .18),
      height: 68,
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {TargetPlatform.android: FadeUpwardsPageTransitionsBuilder()},
    ),
  );
}
