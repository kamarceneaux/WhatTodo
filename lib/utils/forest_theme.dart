import 'package:flutter/material.dart';

/// Colours for the misty-morning forest look used across the app.
class Forest {
  Forest._();

  static const pine = Color(0xFF1E3B2F); // darkest green, text on light
  static const fern = Color(0xFF2F5E45); // primary
  static const moss = Color(0xFF5F8A5A);
  static const sage = Color(0xFFA9C29A);
  static const mist = Color(0xFFDCE8D6); // sky / app bar
  static const parchment = Color(0xFFF5F1E6); // page background
  static const card = Color(0xFFFFFDF7); // task cards
  static const bark = Color(0xFF7A5236);
  static const sun = Color(0xFFE8A93A); // warm accent
  static const berry = Color(0xFFB9533C); // destructive / priority 1
  static const ink = Color(0xFF22302A); // body text
  static const muted = Color(0xFF6E7B71); // secondary text

  /// Leaf-like shape: two opposite corners rounded more than the others.
  static const leafShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(28),
      bottomRight: Radius.circular(28),
      topRight: Radius.circular(8),
      bottomLeft: Radius.circular(8),
    ),
  );

  static ThemeData theme() {
    final scheme = ColorScheme.fromSeed(seedColor: fern).copyWith(
      primary: fern,
      onPrimary: parchment,
      secondary: sun,
      onSecondary: pine,
      surface: parchment,
      onSurface: ink,
      error: berry,
      outline: sage,
    );

    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      scaffoldBackgroundColor: parchment,
      primaryColor: fern,
      dividerColor: sage,
      appBarTheme: const AppBarTheme(
        backgroundColor: mist,
        foregroundColor: pine,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          color: pine,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: fern,
        foregroundColor: parchment,
        shape: leafShape,
      ),
      drawerTheme: const DrawerThemeData(backgroundColor: parchment),
      listTileTheme: const ListTileThemeData(
        iconColor: moss,
        textColor: ink,
      ),
      iconTheme: const IconThemeData(color: moss),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: pine,
        contentTextStyle: TextStyle(color: parchment),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: const DialogThemeData(backgroundColor: parchment),
      popupMenuTheme: const PopupMenuThemeData(color: card),
      inputDecorationTheme: const InputDecorationTheme(
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: fern, width: 2),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: moss),
    );
  }
}
