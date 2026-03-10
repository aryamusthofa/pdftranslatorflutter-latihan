import 'package:flutter/material.dart';
import '../translations.dart';

class AdvancedUIPage extends StatefulWidget {
  const AdvancedUIPage({super.key});

  @override
  State<AdvancedUIPage> createState() => _AdvancedUIPageState();
}

class _AdvancedUIPageState extends State<AdvancedUIPage> {
  // Animation state
  bool _isExpanded = false;

  void _showAlertDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppTranslations.tr('hx_btn_alert')),
        content: Text(AppTranslations.tr('hx_dlg_sub')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSimpleDialog() {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(AppTranslations.tr('hx_btn_simple')),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 'Opsi 1'),
            child: const Text('Option 1'),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 'Opsi 2'),
            child: const Text('Option 2'),
          ),
        ],
      ),
    );
  }

  void _showCustomDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.info_outline, size: 50, color: Colors.blue),
              const SizedBox(height: 15),
              Text(AppTranslations.tr('hx_btn_custom'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text(AppTranslations.tr('hx_dlg_sub'), textAlign: TextAlign.center),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final isDark = themeData.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              AppTranslations.tr('hx_title'),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: themeData.primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 20),
              
              // 2. Jenis Dialog Interaktif
              Text(
                AppTranslations.tr('hx_dlg_title'),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(AppTranslations.tr('hx_dlg_sub')),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  OutlinedButton.icon(
                    onPressed: _showAlertDialog,
                    icon: const Icon(Icons.warning_amber_rounded),
                    label: Text(AppTranslations.tr('hx_btn_alert')),
                    style: OutlinedButton.styleFrom(shape: const StadiumBorder()),
                  ),
                  OutlinedButton.icon(
                    onPressed: _showSimpleDialog,
                    icon: const Icon(Icons.notes),
                    label: Text(AppTranslations.tr('hx_btn_simple')),
                    style: OutlinedButton.styleFrom(shape: const StadiumBorder()),
                  ),
                  OutlinedButton.icon(
                    onPressed: _showCustomDialog,
                    icon: const Icon(Icons.grid_view_rounded),
                    label: Text(AppTranslations.tr('hx_btn_custom')),
                    style: OutlinedButton.styleFrom(shape: const StadiumBorder()),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // 3. Animasi di Flutter
              Text(
                AppTranslations.tr('hx_anim_title'),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                AppTranslations.tr('hx_anim_sub'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Text(AppTranslations.tr('hx_anim_btn')),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(seconds: 1),
                  curve: Curves.easeInOut,
                  width: double.infinity,
                  height: _isExpanded ? 150 : 50,
                  decoration: BoxDecoration(
                    color: _isExpanded ? (isDark ? Colors.orange : themeData.primaryColor) : Colors.grey[400],
                    borderRadius: BorderRadius.circular(_isExpanded ? 30 : 5),
                  ),
                  child: Center(
                    child: Text(
                      AppTranslations.tr('hx_tap_box'),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _isExpanded ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
    );
  }
}