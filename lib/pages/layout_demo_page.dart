import 'package:flutter/material.dart';
import '../translations.dart';

class LayoutDemoPage extends StatelessWidget {
  const LayoutDemoPage({super.key});

  @override
  Widget build(BuildContext context) {

    // Generate data dummy
    final List<String> items =
        List.generate(20, (index) => "Item Data Ke-${index + 1}");

    return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppTranslations.tr('home_title'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(AppTranslations.tr('home_sub')),
            const SizedBox(height: 10),
            Container(
              height: 150,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.indigo),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView(
                children: [
                  ListTile(
                    leading: const Icon(Icons.info, color: Colors.blue),
                    title: Text(AppTranslations.tr('home_info')),
                  ),
                  ListTile(
                    leading: const Icon(Icons.help, color: Colors.orange),
                    title: Text(AppTranslations.tr('home_help')),
                  ),
                  ListTile(
                    leading: const Icon(Icons.settings, color: Colors.grey),
                    title: Text(AppTranslations.tr('home_settings')),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            Text(
              AppTranslations.tr('home_dyn_title'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(AppTranslations.tr('home_dyn_sub')),
            const SizedBox(height: 10),
            Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.green),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: CircleAvatar(child: Text('${index + 1}')),
                    title: Text('${AppTranslations.tr("home_dyn_item")} ${index + 1}'),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${AppTranslations.tr("home_success")}: $index')),
                      );
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 30),

            Text(
              AppTranslations.tr('home_sep_title'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(AppTranslations.tr('home_sep_sub')),
            const SizedBox(height: 10),
            Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.red),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView.separated(
                itemCount: 5, 
                separatorBuilder: (context, index) => const Divider(
                  color: Colors.red,
                  thickness: 1,
                  indent: 15,
                  endIndent: 15,
                ),
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: const Icon(Icons.history),
                    title: Text('${AppTranslations.tr("home_hx")} #00${index + 1}'),
                    trailing: Text(AppTranslations.tr('home_success'), style: const TextStyle(color: Colors.green)),
                  );
                },
              ),
            ),
          ],
        ),
      );
  }
}
