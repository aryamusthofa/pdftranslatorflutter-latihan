import 'package:flutter/material.dart';

// Definisi pilihan tema yang tersedia
enum ThemeColorOption {
  teal('Teal', Colors.teal),
  purple('Purple', Colors.purple),
  red('Red', Colors.red),
  blue('Blue', Colors.blue),
  green('Green', Colors.green),
  grey('Grey', Colors.grey),
  orange('Orange', Colors.orange);

  final String name;
  final MaterialColor color;
  const ThemeColorOption(this.name, this.color);
}

class ThemeProvider extends InheritedWidget {
  final ThemeColorOption themeColorOption;
  final bool isDarkMode;
  final Function(ThemeColorOption) changeThemeColor;
  final Function(bool) toggleDarkMode;

  const ThemeProvider({
    super.key,
    required this.themeColorOption,
    required this.isDarkMode,
    required this.changeThemeColor,
    required this.toggleDarkMode,
    required super.child,
  });

  static ThemeProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ThemeProvider>();
  }

  @override
  bool updateShouldNotify(ThemeProvider oldWidget) {
    return themeColorOption != oldWidget.themeColorOption ||
           isDarkMode != oldWidget.isDarkMode;
  }
}

class GlobalThemeSelector extends StatelessWidget {
  const GlobalThemeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = ThemeProvider.of(context);
    if (themeProvider == null) return const SizedBox.shrink();

    return PopupMenuButton<String>(
      icon: const Icon(Icons.palette),
      tooltip: 'Pilih Tema Global',
      onSelected: (value) {
        if (value == 'dark_mode_toggle') {
          themeProvider.toggleDarkMode(!themeProvider.isDarkMode);
        } else {
          // Cari warna yang sesuai dari enum
          final selectedOption = ThemeColorOption.values.firstWhere(
            (e) => e.name == value,
            orElse: () => ThemeColorOption.teal,
          );
          themeProvider.changeThemeColor(selectedOption);
        }
      },
      itemBuilder: (BuildContext context) {
        List<PopupMenuEntry<String>> items = [];
        
        // Pilihan Mode (Light / Dark)
        items.add(
          PopupMenuItem<String>(
            value: 'dark_mode_toggle',
            child: Row(
              children: [
                Icon(
                  themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                  color: themeProvider.isDarkMode ? Colors.orange : Colors.grey[800],
                ),
                const SizedBox(width: 10),
                Text(themeProvider.isDarkMode ? 'Ganti ke Light Mode' : 'Ganti ke Dark Mode'),
              ],
            ),
          ),
        );
        
        items.add(const PopupMenuDivider());

        // Pilihan Warna-warni
        for (var option in ThemeColorOption.values) {
          items.add(
            PopupMenuItem<String>(
              value: option.name,
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: option.color,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey, width: 0.5),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(option.name, 
                    style: TextStyle(
                      fontWeight: themeProvider.themeColorOption == option ? FontWeight.bold : FontWeight.normal
                    ),
                  ),
                  if (themeProvider.themeColorOption == option)
                    const Spacer(),
                  if (themeProvider.themeColorOption == option)
                    const Icon(Icons.check, size: 18, color: Colors.green),
                ],
              ),
            ),
          );
        }
        return items;
      },
    );
  }
}
