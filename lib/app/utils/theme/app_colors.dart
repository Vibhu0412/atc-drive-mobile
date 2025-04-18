import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF4285F4); // Google Blue
  static const Color primaryDark = Color(0xFF1A73E8); // Darker Blue
  static const Color primaryLight = Color(0xFF8AB4F8); // Lighter Blue

  // Accent Colors
  static const Color accent = Color(0xFF34A853);
  static const Color accentDark = Color(0xFF1E8E3E);
  static const Color accentLight = Color(0xFF81C995);

  // Background Colors
  static const Color background = Color(0xFFF8F9FA); // Light Grey Background
  static const Color surface = Color(0xFFFFFFFF); // White Surface
  static const Color onSurface = Color(0xFF202124); // Dark Grey for Text

  // Text Colors
  static const Color textPrimary = Color(0xFF202124); // Dark Grey
  static const Color textSecondary = Color(0xFF5F6368); // Medium Grey
  static const Color textHint = Color(0xFF9AA0A6); // Light Grey for Hints

  // Error and Warning Colors
  static const Color error = Color(0xFFD93025); // Google Red
  static const Color warning = Color(0xFFF9AB00); // Google Yellow

  // Neutral Colors
  static const Color grey = Color(0xFF5F6368); // Medium Grey
  static const Color lightGrey = Color(0xFFE8EAED); // Light Grey
  static const Color darkGrey = Color(0xFF3C4043); // Dark Grey

  // App-Specific Colors
  static const Color floatingActionButtonColor = Color(0xffe8e7ec);
  static const Color bottomNavigationBarColor = Color(0xFFeeedf2);
  static const Color searchbarColor = lightGrey;

  // Theme-Dependent Colors
  static Color getBackgroundColor(bool isDark) {
    return isDark ? darkGrey : background;
  }

  static Color getTextColor(bool isDark) {
    return isDark ? Colors.white : textPrimary;
  }

  static Color getSurfaceColor(bool isDark) {
    return isDark ? darkGrey : surface;
  }

  static Color getFABColor(bool isDark) {
    return isDark ? darkGrey : floatingActionButtonColor;
  }

  static Color getBottomNavigationBarColor(bool isDark) {
    return isDark ? darkGrey : bottomNavigationBarColor;
  }

  static const List<Color> userColors = [
    Color(0xFF0077B6), // Deep Blue

    Color(0xFFF77F00), // Vivid Orange
    Color(0xFFFFC300), // Bright Yellow
    Color(0xFF2EC4B6), // Teal
    Color(0xFFE63946), // Bright Red
    Color(0xFF8338EC), // Electric Purple
    Color(0xFFEF233C), // Crimson
    Color(0xFF06D6A0), // Emerald Green
    Color(0xFF118AB2), // Bright Cyan
    Color(0xFFD81159), // Magenta
    Color(0xFFFF006E), // Hot Pink
    Color(0xFF3A86FF), // Royal Blue
    Color(0xFF43AA8B), // Rich Green
    Color(0xFFF15BB5), // Neon Pink
    Color(0xFFFFA822), // Golden Orange
  ];
}
