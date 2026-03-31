import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import 'translations.dart';

import 'theme_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeColorOption _currentThemeColor = ThemeColorOption.teal;
  bool _isDarkMode = false;

  void _changeThemeColor(ThemeColorOption newColor) {
    setState(() {
      _currentThemeColor = newColor;
      _isDarkMode = false; // Jika pilih warna, matikan dark mode agar warnanya terlihat
    });
  }

  void _toggleDarkMode(bool isDark) {
    setState(() {
      _isDarkMode = isDark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: AppTranslations.currentLocale,
      builder: (context, locale, child) {
        // Bangun ThemeData berdasarkan state
        final ThemeData themeData = _isDarkMode
            ? ThemeData.dark().copyWith(
                appBarTheme: AppBarTheme(
                  backgroundColor: Colors.grey[900], 
                  foregroundColor: Colors.white,
                ),
              )
            : ThemeData.light().copyWith(
                primaryColor: _currentThemeColor.color,
                colorScheme: ColorScheme.fromSwatch(
                  primarySwatch: _currentThemeColor.color,
                ).copyWith(
                  secondary: _currentThemeColor.color,
                ),
                appBarTheme: AppBarTheme(
                  backgroundColor: _currentThemeColor.color, 
                  foregroundColor: Colors.white,
                ),
              );

        return ThemeProvider(
          themeColorOption: _currentThemeColor,
          isDarkMode: _isDarkMode,
          changeThemeColor: _changeThemeColor,
          toggleDarkMode: _toggleDarkMode,
          child: AnimatedTheme(
            data: themeData,
            duration: const Duration(milliseconds: 500), // Durasi transisi warna (smooth fade)
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: themeData, // tetap di-pass agar Navigator/Dialog sync
              home: const LoginPage(),
            ),
          ),
        );
      },
    );
  }
}