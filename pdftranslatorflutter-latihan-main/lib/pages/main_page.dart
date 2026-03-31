import 'package:flutter/material.dart';

import 'login_page.dart';
import 'profile_page.dart';
import 'advanced_ui_page.dart';
import 'layout_demo_page.dart';
import 'pdf_translator_page.dart';
import 'tts_generator_page.dart';
import 'references/src/references_main.dart';

import '../theme_provider.dart';
import '../translations.dart';

class MainPage extends StatefulWidget {
  final String username;
  const MainPage({super.key, required this.username});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: AppTranslations.currentLocale,
      builder: (context, locale, _) {
        return Scaffold(
          drawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                UserAccountsDrawerHeader(
                  accountName: Text(widget.username),
                  accountEmail: const Text('user@app.com'),
                  currentAccountPicture: const CircleAvatar(
                    child: Icon(Icons.person),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.translate),
                  title: Text(AppTranslations.tr('menu_translate')),
                  onTap: () {
                    setState(() => currentIndex = 0);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.home),
                  title: Text(AppTranslations.tr('menu_home')),
                  onTap: () {
                    setState(() => currentIndex = 1);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.history),
                  title: Text(AppTranslations.tr('menu_history')),
                  onTap: () {
                    setState(() => currentIndex = 2);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(AppTranslations.tr('menu_profile')),
                  onTap: () {
                    setState(() => currentIndex = 3);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.record_voice_over),
                  title: Text(AppTranslations.tr('menu_tts')),
                  onTap: () {
                    setState(() => currentIndex = 4);
                    Navigator.pop(context);
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.book, color: Colors.indigo),
                  title: const Text('Referensi my_first_app', style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold)),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MyFirstAppReference()),
                    );
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: Text(AppTranslations.tr('menu_logout')),
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                    );
                  },
                ),
              ],
            ),
          ),
          body: IndexedStack(
            index: currentIndex,
            children: [
              const PdfTranslatorPage(),
              const LayoutDemoPage(),
              const AdvancedUIPage(),
              ProfilePage(username: widget.username),
              const TtsGeneratorPage(),
            ],
          ),
          appBar: AppBar(
            title: Text(
              currentIndex == 0 ? AppTranslations.tr('menu_translate') :
              currentIndex == 1 ? AppTranslations.tr('menu_home') :
              currentIndex == 2 ? AppTranslations.tr('menu_history') : 
              currentIndex == 3 ? AppTranslations.tr('menu_profile') : AppTranslations.tr('menu_tts')
            ),
            actions: const [
              GlobalLanguageSelector(),
              GlobalThemeSelector(),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: currentIndex,
            type: BottomNavigationBarType.fixed, // Added to prevent shifting text issues with 5 items
            selectedItemColor: Colors.blue.shade700, 
            unselectedItemColor: Colors.grey.shade500, 
            onTap: (index) {
              setState(() => currentIndex = index);
            },
            items: [
              BottomNavigationBarItem(icon: const Icon(Icons.translate), label: AppTranslations.tr('menu_translate')),
              BottomNavigationBarItem(icon: const Icon(Icons.home), label: AppTranslations.tr('menu_home')),
              BottomNavigationBarItem(icon: const Icon(Icons.history), label: AppTranslations.tr('menu_history')),
              BottomNavigationBarItem(icon: const Icon(Icons.person), label: AppTranslations.tr('menu_profile')),
              BottomNavigationBarItem(icon: const Icon(Icons.record_voice_over), label: AppTranslations.tr('menu_tts')), 
            ],
          ),
        );
      }
    );
  }
}
