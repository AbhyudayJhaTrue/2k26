import 'package:flutter/material.dart';
import 'signin_page.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SafeSpace',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppTheme.background,
        primaryColor: AppTheme.primary,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppTheme.primary,
          brightness: Brightness.light,
          primary: AppTheme.primary,
          secondary: AppTheme.accent,
          surface: AppTheme.card,
          background: AppTheme.background,
          error: Colors.redAccent,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: AppTheme.ink,
          onBackground: Colors.white,
        ),
        textTheme: ThemeData.light().textTheme.apply(
              bodyColor: AppTheme.ink,
              displayColor: AppTheme.ink,
            ),
        fontFamily: 'Inter',
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white.withOpacity(.08),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppTheme.accent, width: 1.5),
          ),
        ),
      ),
      home: const SignInPage(),
    );
  }
}