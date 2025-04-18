import 'package:atc_drive/app/utils/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AppThemeData {
  static ThemeData appThemeData(BuildContext context, {bool isDark = false}) {
    return ThemeData(
      visualDensity: VisualDensity.adaptivePlatformDensity,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.getBackgroundColor(isDark),
      applyElevationOverlayColor: true,
      canvasColor: AppColors.getSurfaceColor(isDark),
      cardColor: AppColors.getSurfaceColor(isDark),
      cardTheme: CardTheme(
        color: AppColors.getSurfaceColor(isDark),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: AppColors.primary,
      ),
      checkboxTheme: CheckboxThemeData(
        checkColor: WidgetStateProperty.all(Colors.white),
        fillColor: WidgetStateProperty.all(AppColors.primary),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      dialogBackgroundColor: AppColors.getSurfaceColor(isDark),
      dialogTheme: DialogTheme(
        backgroundColor: AppColors.getSurfaceColor(isDark),
        contentTextStyle: Theme.of(context).textTheme.bodyLarge,
      ),
      dividerColor: AppColors.lightGrey,
      dividerTheme: DividerThemeData(
        color: AppColors.lightGrey,
        indent: 8.0,
        endIndent: 8.0,
        space: 8.0,
      ),
      focusColor: AppColors.primaryLight,
      //fontFamily: GoogleFonts.roboto().fontFamily,
      hintColor: AppColors.textHint,
      indicatorColor: AppColors.primary,
      outlinedButtonTheme: OutlinedButtonThemeData(style: textButtonStyle),
      primaryTextTheme: textTheme(isDark, context),
      textButtonTheme: TextButtonThemeData(style: textButtonStyle),
      buttonTheme: ButtonThemeData(
        height: 50,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        textTheme: ButtonTextTheme.normal,
      ),
      inputDecorationTheme: InputDecorationTheme(
        focusColor: AppColors.primary,
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color: AppColors.error,
          ),
        ),
        errorBorder: OutlineInputBorder(
          gapPadding: 0,
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(
            color: Colors.grey,
          ),
        ),
        errorStyle: const TextStyle(color: AppColors.error),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color: AppColors.primary,
          ),
        ),
        hintStyle: TextStyle(
          fontSize: 14,
          //fontFamily: GoogleFonts.roboto().fontFamily,
          color: AppColors.textHint,
        ),
      ),
      appBarTheme: AppBarTheme(
        iconTheme: IconThemeData(color: AppColors.getTextColor(isDark)),
        backgroundColor: AppColors.getSurfaceColor(isDark),
        elevation: 0,
        actionsIconTheme: IconThemeData(color: AppColors.primary),
        toolbarTextStyle: TextTheme(
          bodyLarge: TextStyle(
            fontSize: 29,
            //fontFamily: GoogleFonts.roboto().fontFamily,
            color: AppColors.getTextColor(isDark),
          ),
        ).bodyMedium,
        titleTextStyle: TextTheme(
          bodyLarge: TextStyle(
            fontSize: 29,
            //fontFamily: GoogleFonts.roboto().fontFamily,
            color: AppColors.getTextColor(isDark),
          ),
        ).titleLarge,
      ),
      iconTheme: IconThemeData(color: AppColors.getTextColor(isDark)),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.getFABColor(
          isDark,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        elevation: 1,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        backgroundColor: AppColors.getBottomNavigationBarColor(isDark),
      ),
      textTheme: textTheme(isDark, context),
      snackBarTheme: SnackBarThemeData(
        actionTextColor: Colors.white,
        backgroundColor: AppColors.getSurfaceColor(isDark),
        behavior: SnackBarBehavior.floating,
        elevation: 3,
      ),
      bottomSheetTheme: BottomSheetThemeData(
          backgroundColor: AppColors.getBottomNavigationBarColor(isDark)),
      colorScheme: ColorScheme(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        brightness: isDark ? Brightness.dark : Brightness.light,
        error: AppColors.error,
        onError: AppColors.error,
        onPrimary: AppColors.primary,
        onSecondary: AppColors.accent,
        onSurface: AppColors.getTextColor(isDark),
        surface: AppColors.getSurfaceColor(isDark),
      ),
    );
  }

  static ButtonStyle get textButtonStyle {
    return TextButton.styleFrom(
      textStyle: TextStyle(
        color: Colors.white,
        ////fontFamily: GoogleFonts.roboto().fontFamily,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  static TextTheme textTheme(bool isDark, BuildContext context) {
    return TextTheme(
      displayLarge: TextStyle(
        fontSize: 34,
        fontWeight: FontWeight.w700,
        color: AppColors.getTextColor(isDark),
      ),
      displayMedium: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.w600,
        color: AppColors.getTextColor(isDark),
      ),
      bodyLarge: TextStyle(
        fontSize: 20,
        //fontFamily: GoogleFonts.roboto().fontFamily,
        color: AppColors.getTextColor(isDark),
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        //fontFamily: GoogleFonts.roboto().fontFamily,
        color: AppColors.getTextColor(isDark),
      ),
      titleMedium: TextStyle(
        fontSize: 15,
        //fontFamily: GoogleFonts.roboto().fontFamily,
        color: AppColors.getTextColor(isDark),
      ),
    );
  }
}
