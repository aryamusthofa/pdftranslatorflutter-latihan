import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'providers/item_provider.dart';
import 'providers/auth_provider.dart';
import 'profile_page.dart';
import 'lampu_page.dart';
import 'grid_demo_page.dart';
import 'utils/app_language.dart';

class MainPage extends StatefulWidget {
  final String username;
  const MainPage({super.key, required this.username});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int currentIndex = 0;
  late final List<Widget> pages;

  @override
  void initState() {
    super.initState();
    pages = [
      const LayoutDemoPage(),
      const LampuPage(),
      const GridDemoPage(),
      ProfilePage(username: widget.username),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLanguage.t(context, 'app_title')),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            tooltip: 'Kembali ke Aplikasi Utama',
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop();
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Consumer<AuthProvider>(
              builder: (context, auth, _) {
                final photoBytes = auth.profilePhotoBytes;
                return GestureDetector(
                  onTap: () => setState(() => currentIndex = 3),
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white.withValues(alpha: 0.3),
                    backgroundImage: photoBytes != null ? MemoryImage(photoBytes) : null,
                    child: photoBytes == null
                      ? Text(
                          widget.username[0].toUpperCase(),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        )
                      : null,
                  ),
                );
              },
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary),
              child: Consumer<AuthProvider>(
                builder: (context, auth, _) {
                  final photoBytes = auth.profilePhotoBytes;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white,
                        backgroundImage: photoBytes != null ? MemoryImage(photoBytes) : null,
                        child: photoBytes == null
                          ? const Icon(Icons.person, size: 40, color: Colors.blue)
                          : null,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        auth.displayName ?? widget.username,
                        style: const TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      Text(
                        '@${widget.username}',
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  );
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: Text(AppLanguage.t(context, 'home')),
              onTap: () {
                setState(() => currentIndex = 0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.lightbulb),
              title: Text(AppLanguage.t(context, 'lamp')),
              onTap: () {
                setState(() => currentIndex = 1);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.grid_view),
              title: Text(AppLanguage.t(context, 'gallery')),
              onTap: () {
                setState(() => currentIndex = 2);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: Text(AppLanguage.t(context, 'profile')),
              onTap: () {
                setState(() => currentIndex = 3);
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: Text(AppLanguage.t(context, 'logout'), style: const TextStyle(color: Colors.red)),
              onTap: () {
                Provider.of<AuthProvider>(context, listen: false).logout();
                Navigator.pop(context); // Close drawer
              },
            ),
          ],
        ),
      ),
      body: pages[currentIndex],
      floatingActionButton: currentIndex == 0 
        ? FloatingActionButton(
            onPressed: () => _showAddItemDialog(context),
            child: const Icon(Icons.add),
          )
        : null,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() => currentIndex = index);
        },
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.home), label: AppLanguage.t(context, 'home')),
          BottomNavigationBarItem(icon: const Icon(Icons.lightbulb), label: AppLanguage.t(context, 'lamp')),
          BottomNavigationBarItem(icon: const Icon(Icons.grid_view), label: AppLanguage.t(context, 'gallery')),
          BottomNavigationBarItem(icon: const Icon(Icons.person), label: AppLanguage.t(context, 'profile')),
        ],
      ),
    );
  }

  void _showAddItemDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLanguage.t(context, 'add_new_item')),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: AppLanguage.t(context, 'item_name')),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLanguage.t(context, 'cancel')),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  debugPrint('UI: Clicked Simpan with value: ${controller.text}');
                  Provider.of<ItemProvider>(context, listen: false)
                      .addItem(controller.text);
                  Navigator.pop(context);
                } else {
                  debugPrint('UI: Simpan ignored (empty text)');
                }
              },
              child: Text(AppLanguage.t(context, 'save')),
            ),
          ],
        );
      },
    );
  }
}

class LayoutDemoPage extends StatelessWidget {
  const LayoutDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLanguage.t(context, 'explore_listview')),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 2,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Provider.of<ItemProvider>(context, listen: false).fetchItems();
        },
        child: Consumer<ItemProvider>(
          builder: (context, itemProvider, child) {
            final items = itemProvider.filteredItems;
            
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionInfo(context, AppLanguage.t(context, 'listview_default'), AppLanguage.t(context, 'listview_default_desc')),
                  const SizedBox(height: 12),
                  _buildPremiumListContainer(
                    context,
                    ListView(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildClassicListTile(context, Icons.info_outline, AppLanguage.t(context, 'app_info'), Colors.blue),
                        _buildClassicListTile(context, Icons.help_outline, AppLanguage.t(context, 'help_center'), Colors.orange),
                        _buildClassicListTile(context, Icons.settings_outlined, AppLanguage.t(context, 'general_settings'), Colors.teal),
                      ],
                    ),
                  ),

                  const SizedBox(height: 35),

                  _buildSectionInfo(context, AppLanguage.t(context, 'listview_builder'), AppLanguage.t(context, 'listview_builder_desc')),
                  const SizedBox(height: 12),
                  TextField(
                    onChanged: (value) => itemProvider.setSearchQuery(value),
                    decoration: InputDecoration(
                      hintText: AppLanguage.t(context, 'search_hint'),
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 300,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: itemProvider.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : AnimationLimiter(
                            child: ListView.builder(
                              itemCount: items.length,
                              itemBuilder: (context, index) {
                                final item = items[index];
                                return AnimationConfiguration.staggeredList(
                                  position: index,
                                  duration: const Duration(milliseconds: 375),
                                  child: SlideAnimation(
                                    verticalOffset: 50.0,
                                    child: FadeInAnimation(
                                      child: Card(
                                        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                        elevation: 0,
                                        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                                        child: ListTile(
                                          leading: CircleAvatar(
                                            backgroundColor: Theme.of(context).colorScheme.primary,
                                            child: Text('${index + 1}', style: const TextStyle(color: Colors.white, fontSize: 12)),
                                          ),
                                          title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                                          trailing: IconButton(
                                            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                            onPressed: () {
                                              itemProvider.deleteItem(item.id!);
                                            },
                                          ),
                                          onTap: () {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text(AppLanguage.t(context, 'detail_open').replaceAll('{name}', item.name)),
                                                behavior: SnackBarBehavior.floating,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                    ),
                  ),

                  const SizedBox(height: 35),

                  _buildSectionInfo(context, AppLanguage.t(context, 'listview_separated'), AppLanguage.t(context, 'listview_separated_desc')),
                  const SizedBox(height: 12),
                  _buildPremiumListContainer(
                    context,
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 4,
                      separatorBuilder: (context, index) => Divider(
                        color: Theme.of(context).colorScheme.outlineVariant,
                        height: 1,
                        indent: 60,
                      ),
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.receipt_long_outlined, color: Colors.red, size: 20),
                          ),
                          title: Text('${AppLanguage.t(context, 'transaction')} #99${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('10 Feb 2026 \u2022 ${AppLanguage.t(context, 'paid')}', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.outline)),
                          trailing: const Text('Rp 50.000', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionInfo(BuildContext context, String title, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(description, style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurfaceVariant)),
      ],
    );
  }

  Widget _buildPremiumListContainer(BuildContext context, Widget child) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: child,
      ),
    );
  }

  Widget _buildClassicListTile(BuildContext context, IconData icon, String title, Color accentColor) {
    return ListTile(
      leading: Icon(icon, color: accentColor),
      title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
      trailing: Icon(Icons.arrow_forward_ios, size: 14, color: Theme.of(context).colorScheme.outline),
      onTap: () {},
    );
  }
}
