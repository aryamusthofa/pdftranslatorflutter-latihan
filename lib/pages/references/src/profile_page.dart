import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'providers/auth_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/theme_provider.dart';
import 'utils/app_language.dart';
import 'crop_photo_page.dart';

class ProfilePage extends StatelessWidget {
  final String username;
  const ProfilePage({super.key, required this.username});

  Future<void> _pickAndCropPhoto(BuildContext context, AuthProvider authProvider) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile == null) return;

      final bytes = await pickedFile.readAsBytes();

      if (!context.mounted) return;
      final croppedBytes = await Navigator.push<Uint8List>(
        context,
        MaterialPageRoute(
          builder: (_) => CropPhotoPage(imageBytes: bytes),
        ),
      );

      if (croppedBytes != null) {
        await authProvider.updateProfilePhoto(croppedBytes);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showEditProfileDialog(BuildContext context, AuthProvider authProvider) {
    final nameController = TextEditingController(text: authProvider.displayName ?? username);
    final bioController = TextEditingController(text: authProvider.bio ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 20,
          left: 20,
          right: 20,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              AppLanguage.t(context, 'edit_profile'),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: AppLanguage.t(context, 'full_name'),
                prefixIcon: const Icon(Icons.badge_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: bioController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: AppLanguage.t(context, 'bio'),
                prefixIcon: const Icon(Icons.info_outline),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () async {
                  await authProvider.updateProfile(nameController.text, bioController.text);
                  if (context.mounted) Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(AppLanguage.t(context, 'save'), style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final photoBytes = authProvider.profilePhotoBytes;

        return Scaffold(
          appBar: AppBar(
            title: Text(AppLanguage.t(context, 'profile')),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => _showEditProfileDialog(context, authProvider),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Profile Avatar with Camera Button
                GestureDetector(
                  onTap: () => _pickAndCropPhoto(context, authProvider),
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.blueAccent,
                        backgroundImage: photoBytes != null ? MemoryImage(photoBytes) : null,
                        child: photoBytes == null
                          ? const Icon(Icons.person, size: 80, color: Colors.white)
                          : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: colorScheme.surface, width: 3),
                          ),
                          child: Icon(
                            Icons.camera_alt_rounded,
                            size: 20,
                            color: colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => _pickAndCropPhoto(context, authProvider),
                  child: Text(
                    AppLanguage.t(context, 'change_photo'),
                    style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  authProvider.displayName ?? username,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(
                  '@$username',
                  style: TextStyle(color: colorScheme.outline, fontSize: 16),
                ),
                const SizedBox(height: 16),
                if (authProvider.bio != null && authProvider.bio!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      authProvider.bio!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                    ),
                  ),
                const SizedBox(height: 40),
                const Divider(),
                const SizedBox(height: 20),
                Consumer<ThemeProvider>(
                  builder: (context, themeProvider, child) {
                    return SwitchListTile(
                      title: Text(AppLanguage.t(context, 'dark_mode')),
                      secondary: const Icon(Icons.dark_mode_outlined),
                      value: themeProvider.themeMode == ThemeMode.dark,
                      onChanged: (value) => themeProvider.toggleTheme(value),
                    );
                  },
                ),
                Consumer<SettingsProvider>(
                  builder: (context, settingsProvider, child) {
                    final isIndo = settingsProvider.locale.languageCode == 'id';
                    return ListTile(
                      title: Text(AppLanguage.t(context, 'language')),
                      subtitle: Text(isIndo ? 'Bahasa Indonesia' : 'English'),
                      leading: const Icon(Icons.language_outlined),
                      trailing: Switch(
                        value: !isIndo,
                        onChanged: (value) {
                          settingsProvider.setLocale(
                            value ? const Locale('en', 'US') : const Locale('id', 'ID'),
                          );
                        },
                      ),
                    );
                  },
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton.icon(
                    onPressed: () => authProvider.logout(),
                    icon: const Icon(Icons.logout, color: Colors.red),
                    label: Text(AppLanguage.t(context, 'logout'), style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
