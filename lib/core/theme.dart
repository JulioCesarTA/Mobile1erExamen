// lib/core/theme.dart
import 'package:flutter/material.dart';

ThemeData buildAppTheme() {
  final primary = const Color(0xFF2563EB); // Azul 600
  final secondary = const Color(0xFF10B981); // Verde 500
  final surface = const Color(0xFFFFFFFF);
  final background = const Color(0xFFF6F7FB);
  final textPrimary = const Color(0xFF1F2937); // Gris 800
  final textSecondary = const Color(0xFF6B7280); // Gris 500

  final scheme = ColorScheme.light(
    primary: primary,
    secondary: secondary,
    surface: surface,
    background: background,
    error: const Color(0xFFDC2626),
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: textPrimary,
    onBackground: textPrimary,
    onError: Colors.white,
  );

  return ThemeData(
    useMaterial3: false, // 👈 compacta todo y evita sorpresas de M3
    colorScheme: scheme,
    scaffoldBackgroundColor: background,
    visualDensity: VisualDensity.adaptivePlatformDensity,

    // Tipografías afinadas (más pequeñas y legibles)
    textTheme: const TextTheme(
      headlineSmall: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1F2937),
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1F2937),
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1F2937),
      ),
      bodyLarge: TextStyle(fontSize: 14, color: Color(0xFF1F2937)),
      bodyMedium: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
    ),

    // AppBar sobrio
    appBarTheme: AppBarTheme(
      backgroundColor: surface,
      foregroundColor: textPrimary,
      elevation: 0.5,
      centerTitle: true,
      iconTheme: IconThemeData(color: textPrimary),
      titleTextStyle: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1F2937),
      ),
    ),

    // Inputs modernos
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primary, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
    ),

    // Botones
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(44),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: primary),
    ),

    // Cards y listas
    cardTheme: CardThemeData(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      color: surface,
    ),
    listTileTheme: const ListTileThemeData(
      iconColor: Color(0xFF6B7280),
      titleTextStyle: TextStyle(fontSize: 14, color: Color(0xFF1F2937)),
      subtitleTextStyle: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
    ),

    // Navbar
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: Color(0xFF2563EB),
      unselectedItemColor: Color(0xFF6B7280),
      elevation: 8,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: TextStyle(fontSize: 12),
      unselectedLabelStyle: TextStyle(fontSize: 12),
    ),

    dividerTheme: const DividerThemeData(
      color: Color(0xFFE5E7EB),
      thickness: 1,
    ),
  );
}
