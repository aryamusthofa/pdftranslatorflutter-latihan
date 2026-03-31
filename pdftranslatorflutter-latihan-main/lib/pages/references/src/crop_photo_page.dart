import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:crop_your_image/crop_your_image.dart';
import 'utils/app_language.dart';

class CropPhotoPage extends StatefulWidget {
  final Uint8List imageBytes;
  const CropPhotoPage({super.key, required this.imageBytes});

  @override
  State<CropPhotoPage> createState() => _CropPhotoPageState();
}

class _CropPhotoPageState extends State<CropPhotoPage> {
  final _cropController = CropController();
  bool _isCropping = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(AppLanguage.t(context, 'crop_photo')),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          _isCropping
            ? const Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(
                  width: 20, height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                ),
              )
            : TextButton.icon(
                onPressed: () {
                  setState(() => _isCropping = true);
                  _cropController.crop();
                },
                icon: const Icon(Icons.check_rounded, color: Colors.greenAccent),
                label: Text(
                  AppLanguage.t(context, 'crop_save'),
                  style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold),
                ),
              ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Crop(
              image: widget.imageBytes,
              controller: _cropController,
              aspectRatio: 1.0,
              withCircleUi: true,
              baseColor: Colors.black,
              maskColor: Colors.black.withValues(alpha: 0.7),
              cornerDotBuilder: (size, edgeAlignment) => const SizedBox.shrink(),
              onCropped: (result) {
                Navigator.pop(context, result);
                            },
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.only(bottom: 24, left: 20, right: 20),
            child: Text(
              "Gunakan dua jari (pinch) di trackpad atau scroll mouse untuk memperbesar/kecil foto",
              style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
