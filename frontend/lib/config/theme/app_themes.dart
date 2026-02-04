import 'package:flutter/material.dart';
import 'app_colors.dart';

ThemeData theme() {
  return ThemeData(
    scaffoldBackgroundColor: AppColors.principal,
    fontFamily: 'Muli',
    appBarTheme: appBarTheme(),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.secundario,
      foregroundColor: Colors.white,
    ),
    colorScheme: const ColorScheme.light(
      primary: AppColors.secundario,
      secondary: AppColors.secundario,
      surface: AppColors.principal,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.textoPrincipal,
    ),
  );
}

AppBarTheme appBarTheme() {
  return const AppBarTheme(
    backgroundColor: AppColors.principal,
    elevation: 0,
    centerTitle: true,
    iconTheme: IconThemeData(color: AppColors.textoPrincipal),
    titleTextStyle: TextStyle(
      color: AppColors.textoPrincipal,
      fontSize: 18,
      fontWeight: FontWeight.w600,
    ),
  );
}