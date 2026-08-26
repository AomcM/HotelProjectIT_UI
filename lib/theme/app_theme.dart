import 'package:flutter/material.dart';

/// ---------------------------------------------------------------------
/// PICKALBATROS IT SUPPORT — APP THEME
/// Drop this file into lib/theme/app_theme.dart in your existing project.
/// Then in main.dart:  MaterialApp(theme: AppTheme.light, ...)
/// ---------------------------------------------------------------------

class AppColors {
  AppColors._();

  // Brand
  static const Color navy = Color(0xFF10233D);       // primary dark surfaces (login, headers)
  static const Color navyDark = Color(0xFF0B1A2E);    // deepest shade / gradients
  static const Color gold = Color(0xFFC9A24B);        // primary accent / CTAs
  static const Color goldLight = Color(0xFFE1C583);   // hover / subtle accents

  // Neutrals
  static const Color background = Color(0xFFF5F6F8);  // app background (light screens)
  static const Color surface = Color(0xFFFFFFFF);      // cards
  static const Color border = Color(0xFFE5E8EC);
  static const Color textPrimary = Color(0xFF1B2733);
  static const Color textSecondary = Color(0xFF6B7684);
  static const Color textOnDark = Color(0xFFF5F6F8);
  static const Color textOnDarkMuted = Color(0xFFAAB4C0);

  // Status colors (ticket states — used across all roles)
  static const Color statusOpen = Color(0xFF3B82F6);       // blue
  static const Color statusInProgress = Color(0xFFF59E0B); // amber
  static const Color statusResolved = Color(0xFF10B981);   // green
  static const Color statusClosed = Color(0xFF6B7684);     // gray

  static const Color priorityHigh = Color(0xFFDC2626);
  static const Color priorityMedium = Color(0xFFF59E0B);
  static const Color priorityLow = Color(0xFF10B981);

  /// Maps a ticket status string (as stored in your `Ticket` model) to a color.
  static Color statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return statusOpen;
      case 'in progress':
        return statusInProgress;
      case 'resolved':
        return statusResolved;
      case 'closed':
        return statusClosed;
      default:
        return textSecondary;
    }
  }

  static Color priorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return priorityHigh;
      case 'medium':
        return priorityMedium;
      case 'low':
        return priorityLow;
      default:
        return textSecondary;
    }
  }
}

class AppRadius {
  AppRadius._();
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double pill = 999;
}

class AppSpacing {
  AppSpacing._();
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
}

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final base = ThemeData(useMaterial3: true, brightness: Brightness.light);

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.gold,
        onPrimary: AppColors.navy,
        secondary: AppColors.navy,
        onSecondary: AppColors.textOnDark,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        error: AppColors.priorityHigh,
      ),

      // Typography
      textTheme: base.textTheme.copyWith(
        headlineMedium: const TextStyle(
          fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textPrimary, height: 1.2,
        ),
        titleLarge: const TextStyle(
          fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary,
        ),
        titleMedium: const TextStyle(
          fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary,
        ),
        bodyLarge: const TextStyle(
          fontSize: 15, fontWeight: FontWeight.w400, color: AppColors.textPrimary, height: 1.4,
        ),
        bodyMedium: const TextStyle(
          fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.textSecondary, height: 1.4,
        ),
        labelLarge: const TextStyle(
          fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textOnDark,
        ),
      ),

      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary,
        ),
      ),

      // Buttons — gold filled, navy text (matches "Login" / "Submit Ticket" CTA)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.gold,
          foregroundColor: AppColors.navy,
          minimumSize: const Size.fromHeight(52),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.navy,
          minimumSize: const Size.fromHeight(52),
          side: const BorderSide(color: AppColors.border, width: 1.2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.gold,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),

      // Inputs
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.gold, width: 1.5),
        ),
      ),

      // Cards
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
      ),

      // Bottom nav — used identically across Employee / Technician / Manager
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.navy,
        unselectedItemColor: AppColors.textSecondary,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      dividerTheme: const DividerThemeData(color: AppColors.border, thickness: 1, space: 1),
    );
  }
}