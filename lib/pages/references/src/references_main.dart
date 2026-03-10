import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'providers/item_provider.dart';
import 'providers/gallery_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/lampu_provider.dart';
import 'providers/settings_provider.dart';
import 'login_page.dart';
import 'main_page.dart';

class MyFirstAppReference extends StatelessWidget {
  const MyFirstAppReference({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ItemProvider()),
        ChangeNotifierProvider(create: (_) => GalleryProvider()),
        ChangeNotifierProvider(create: (_) => LampuProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: const _InnerApp(),
    );
  }
}

class _InnerApp extends StatelessWidget {
  const _InnerApp();

  @override
  Widget build(BuildContext context) {
    return Consumer3<ThemeProvider, AuthProvider, SettingsProvider>(
      builder: (context, themeProvider, authProvider, settingsProvider, child) {
        return MaterialApp(
          title: 'My First App',
          debugShowCheckedModeBanner: false,
          locale: settingsProvider.locale,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple, brightness: Brightness.light),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple, brightness: Brightness.dark),
            useMaterial3: true,
          ),
          themeMode: themeProvider.themeMode,
          home: authProvider.isLoading
            ? const Scaffold(body: Center(child: CircularProgressIndicator()))
            : authProvider.isAuthenticated
              ? MainPage(username: authProvider.currentUser!)
              : const LoginPage(),
        );
      },
    );
  }
}
