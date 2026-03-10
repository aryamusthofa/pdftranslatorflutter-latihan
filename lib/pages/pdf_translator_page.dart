import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:translator/translator.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../translations.dart';

class PdfTranslatorPage extends StatefulWidget {
  const PdfTranslatorPage({super.key});

  @override
  State<PdfTranslatorPage> createState() => _PdfTranslatorPageState();
}

class _PdfTranslatorPageState extends State<PdfTranslatorPage> {
  String _translatedText = '';
  String _extractedText = ''; 
  int _totalDetectedCharacters = 0; 
  bool _isLoading = false;
  final GoogleTranslator _translator = GoogleTranslator();
  final FlutterTts _flutterTts = FlutterTts();
  
  final TextEditingController _characterLimitController = TextEditingController(text: '15000');
  
  static const int maxSafeCharacterLimit = 15000;

  final Map<String, String> languages = AppTranslations.fullLanguageNames;

  late String _sourceLanguage = 'auto'; 
  late String _targetLanguage = 'id';
  String _detectedLanguageName = ''; 

  @override
  void initState() {
    super.initState();
    _sourceLanguage = 'auto';
    _targetLanguage = 'id';
  }

  @override
  void dispose() {
    _characterLimitController.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  Future<void> _speak(String text) async {
    if (text.isNotEmpty) {
      try {
        debugPrint("pdf_translator_page: Setting up TTS language $_targetLanguage");
        String speechLang = AppTranslations.currentLocale.value == 'id' ? "id-ID" : 
                            AppTranslations.currentLocale.value == 'en' ? "en-US" : 
                            "zh-CN";
                            
        if (_targetLanguage == 'en') {
          speechLang = 'en-US';
        } else if (_targetLanguage == 'id') {
          speechLang = 'id-ID';
        } else if (_targetLanguage == 'es') {
          speechLang = 'es-ES';
        } else if (_targetLanguage == 'fr') {
          speechLang = 'fr-FR';
        } else if (_targetLanguage == 'de') {
          speechLang = 'de-DE';
        } else if (_targetLanguage == 'pt') {
          speechLang = 'pt-BR';
        } else if (_targetLanguage == 'nl') {
          speechLang = 'nl-NL';
        } else if (_targetLanguage == 'ru') {
          speechLang = 'ru-RU';
        } else if (_targetLanguage.startsWith('zh')) {
          speechLang = 'zh-CN';
        } else if (_targetLanguage == 'ja') {
          speechLang = 'ja-JP';
        } else if (_targetLanguage == 'ar') {
          speechLang = 'ar-SA';
        } else if (_targetLanguage == 'th') {
          speechLang = 'th-TH';
        } else if (_targetLanguage == 'vi') {
          speechLang = 'vi-VN';
        } else if (_targetLanguage == 'hi') {
          speechLang = 'hi-IN';
        } else if (_targetLanguage == 'ko') {
          speechLang = 'ko-KR';
        } else if (_targetLanguage == 'tr') {
          speechLang = 'tr-TR';
        } else if (_targetLanguage == 'pl') {
          speechLang = 'pl-PL';
        } else if (_targetLanguage == 'sv') {
          speechLang = 'sv-SE';
        } else if (_targetLanguage == 'el') {
          speechLang = 'el-GR';
        }

        try {
          await _flutterTts.setLanguage(speechLang);
        } catch (e) {
          debugPrint("setLanguage not supported on this platform (fallback active): $e");
        }
        
        debugPrint("pdf_translator_page: Attempting to speak translated text...");
        try {
          await _flutterTts.speak(text);
          debugPrint("pdf_translator_page: Successfully completed speak()");
        } catch (e) {
          if (e.toString().contains('MissingPluginException')) {
             if (Platform.isLinux) {
                debugPrint("pdf_translator_page WSL detected. Using PowerShell fallback for TTS...");
                try {
                   String b64Text = base64.encode(utf8.encode(text));
                   String psCommand = "Add-Type -AssemblyName System.Speech; \$s = New-Object System.Speech.Synthesis.SpeechSynthesizer; "
                                      "try { \$s.SelectVoiceByHints([System.Speech.Synthesis.VoiceGender]::Female, [System.Speech.Synthesis.VoiceAge]::Adult, 0, [System.Globalization.CultureInfo]::GetCultureInfo('$speechLang')) } catch {}; "
                                      "\$s.Speak([System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('$b64Text')))";
                   
                   await Process.run('powershell.exe', [
                     '-Command', psCommand
                   ]);
                } catch (fallbackErr) {
                   if (!mounted) return;
                   ScaffoldMessenger.of(context).showSnackBar(
                     const SnackBar(content: Text('⚠️ Gagal memainkan PowerShell fallback TTS.')),
                   );
                }
             } else {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('⚠️ Fitur Suara (TTS) tidak didukung pada platform ini.')),
                );
             }
          } else {
             rethrow;
          }
        }
      } catch (e) {
        debugPrint("pdf_translator_page TTS Error: $e");
        if (!mounted) return;
        if (!e.toString().contains('MissingPluginException')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('TTS Error: $e')),
          );
        }
      }
    }
  }

  Future<void> _retranslateText() async {
    if (_extractedText.isEmpty) return;
    
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      int userLimit = int.tryParse(_characterLimitController.text) ?? 5000;
      
      int safeLimitToUse = min(userLimit, maxSafeCharacterLimit);
      
      String textToTranslate = _extractedText;
      
      if (textToTranslate.length > safeLimitToUse) {
        textToTranslate = textToTranslate.substring(0, safeLimitToUse);
      }

      String apiTargetLang = _targetLanguage == 'zh' ? 'zh-cn' : _targetLanguage;

      var translation = await _translator.translate(
        textToTranslate,
        from: _sourceLanguage,
        to: apiTargetLang
      );

      if (!mounted) return;
      setState(() {
        _translatedText = translation.text;
        _detectedLanguageName = languages[translation.sourceLanguage.code] ?? translation.sourceLanguage.code;
      });
    } catch (e) {
      if (!mounted) return;
      String errorMsg = 'Terjadi kesalahan: ';
      
      if (e.toString().contains('400')) {
        errorMsg += 'Request terlalu besar atau format salah. Coba kurangi batas karakter.';
      } else if (e.toString().contains('Read') || e.toString().contains('timeout')) {
        errorMsg += 'Koneksi timeout. Coba kurangi batas karakter atau cek internet.';
      } else if (e.toString().contains('Broken')) {
        errorMsg += 'Koneksi terputus. Coba lagi atau kurangi batas karakter.';
      } else {
        errorMsg += e.toString();
      }
      
      if (mounted) {
        setState(() {
          _translatedText = errorMsg;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _pickAndTranslatePdf() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _translatedText = AppTranslations.tr('pdf_loading');
    });

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true, 
      );

      if (!mounted) return;

      if (result != null) {
        List<int>? bytes;

        if (kIsWeb) {
          bytes = result.files.single.bytes;
        } else {
          if (result.files.single.path != null) {
            File file = File(result.files.single.path!);
            bytes = await file.readAsBytes();
          }
        }

        if (bytes == null) {
          if (!mounted) return;
          setState(() {
            _translatedText = AppTranslations.tr('pdf_fail');
            _isLoading = false;
          });
          return;
        }

        final PdfDocument document = PdfDocument(inputBytes: bytes);
        final String extractedText = PdfTextExtractor(document).extractText();
        document.dispose();

        if (extractedText.trim().isEmpty) {
          if (!mounted) return;
          setState(() {
            _translatedText = AppTranslations.tr('pdf_no_text');
            _isLoading = false;
          });
          return;
        }

        String cleanText = extractedText.replaceAll('\\r\\n', '\\n');
        cleanText = cleanText.replaceAll(RegExp(r'(?<!\\n)\\n(?!\\n)'), ' ');
        cleanText = cleanText.replaceAll(RegExp(r'[ \\t]+'), ' ').trim();

        _extractedText = cleanText;
        
        int detectedChars = cleanText.length;

        String textToTranslate = cleanText;
        if (textToTranslate.length > maxSafeCharacterLimit) {
          textToTranslate = textToTranslate.substring(0, maxSafeCharacterLimit);
        }

        String apiTargetLang = _targetLanguage == 'zh' ? 'zh-cn' : _targetLanguage;

        var translation = await _translator.translate(
          textToTranslate, 
          from: _sourceLanguage, 
          to: apiTargetLang
        );

        if (!mounted) return;
        setState(() {
          _translatedText = translation.text;
          _detectedLanguageName = languages[translation.sourceLanguage.code] ?? translation.sourceLanguage.name;
          _totalDetectedCharacters = detectedChars;
        });
      } else {
        if (!mounted) return;
        setState(() {
          _translatedText = '';
          _extractedText = '';
          _detectedLanguageName = '';
          _totalDetectedCharacters = 0;
        });
      }
    } catch (e) {
      if (!mounted) return;
      String errorMsg = 'Terjadi kesalahan: ';
      
      if (e.toString().contains('400')) {
        errorMsg += 'Request terlalu besar atau format salah. Kurangi batas karakter.';
      } else if (e.toString().contains('Read') || e.toString().contains('timeout')) {
        errorMsg += 'Koneksi timeout. Cek internet atau kurangi batas karakter.';
      } else if (e.toString().contains('Broken')) {
        errorMsg += 'Koneksi terputus. Coba lagi atau kurangi batas karakter.';
      } else {
        errorMsg += e.toString();
      }
      
      if (mounted) {
        setState(() {
          _translatedText = errorMsg;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${AppTranslations.tr('tts_target_lang')}:',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      DropdownButton<String>(
                        isExpanded: true,
                        value: _targetLanguage,
                        items: languages.entries
                            .map((e) => DropdownMenuItem<String>(
                              value: e.key,
                              child: Text(e.value),
                            ))
                            .toList(),
                        onChanged: (value) {
                          if (!mounted) return;
                          setState(() {
                            _targetLanguage = value!;
                          });
                          if (_extractedText.isNotEmpty) {
                            _retranslateText();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppTranslations.tr('limit_char_trans'),
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _characterLimitController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: '${AppTranslations.tr('limit_char_hint')}$maxSafeCharacterLimit)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          helperText: '${AppTranslations.tr('limit_char_max')}$maxSafeCharacterLimit${AppTranslations.tr('limit_char_api')}',
                          helperStyle: const TextStyle(fontSize: 10, color: Colors.orange),
                        ),
                        onChanged: (value) {
                          int? parsed = int.tryParse(value);
                          if (parsed != null && parsed > maxSafeCharacterLimit) {
                            _characterLimitController.text = maxSafeCharacterLimit.toString();
                          }
                          if (_extractedText.isNotEmpty && !_isLoading) {
                            Future.delayed(const Duration(milliseconds: 500), () {
                              if (_extractedText.isNotEmpty && mounted) {
                                _retranslateText();
                              }
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        _characterLimitController.text = maxSafeCharacterLimit.toString();
                        if (_extractedText.isNotEmpty && !_isLoading) {
                          _retranslateText();
                        }
                      },
                      child: Text(AppTranslations.tr('btn_reset')),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (_totalDetectedCharacters > 0)
                  Text(
                    '${AppTranslations.tr('limit_detected')}$_totalDetectedCharacters${AppTranslations.tr('limit_chars')}${AppTranslations.tr('limit_will_translate')}${min(_totalDetectedCharacters, maxSafeCharacterLimit)}${AppTranslations.tr('limit_chars')}',
                    style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                  ),
                if (_totalDetectedCharacters > maxSafeCharacterLimit)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        border: Border.all(color: Colors.orange),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning, color: Colors.orange, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${AppTranslations.tr('limit_pdf_has')}${_totalDetectedCharacters - maxSafeCharacterLimit}${AppTranslations.tr('limit_above_api')}$maxSafeCharacterLimit${AppTranslations.tr('limit_first_translated')}',
                              style: const TextStyle(fontSize: 10, color: Colors.orange),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            
            Text(
              '${AppTranslations.tr('trans_manual')}:',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            TextField(
              maxLines: 4,
              decoration: InputDecoration(
                hintText: AppTranslations.tr('hint_manual'),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onChanged: (text) {
                if (text.trim().isEmpty) {
                  setState(() {
                    _extractedText = '';
                    _translatedText = '';
                    _totalDetectedCharacters = 0;
                  });
                  return;
                }
                
                setState(() {
                  _extractedText = text;
                  _totalDetectedCharacters = text.length;
                });
                
                Future.delayed(const Duration(milliseconds: 1000), () {
                  if (mounted && _extractedText == text && !_isLoading) {
                    _retranslateText();
                  }
                });
              },
            ),
            const SizedBox(height: 15),

            ElevatedButton.icon(
              onPressed: _isLoading ? null : _pickAndTranslatePdf,
              label: Text(AppTranslations.tr('btn_pick_pdf')),
              icon: const Icon(Icons.picture_as_pdf),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 20),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${AppTranslations.tr('result_id')} (${languages[_targetLanguage]}):',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      if (_detectedLanguageName.isNotEmpty)
                        Text(
                          'Mendeteksi bahasa dari: $_detectedLanguageName',
                          style: TextStyle(fontSize: 11, color: Colors.blue.shade700, fontStyle: FontStyle.italic),
                        ),
                    ],
                  ),
                ),
                  IconButton(
                    icon: const Icon(Icons.volume_up, color: Colors.blue),
                    tooltip: 'Dengarkan Teks',
                    onPressed: _translatedText.isNotEmpty && !_isLoading
                        ? () => _speak(_translatedText)
                        : null,
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy, color: Colors.blue),
                    tooltip: 'Salin Teks',
                    onPressed: _translatedText.isNotEmpty && !_isLoading
                        ? () async {
                            await Clipboard.setData(
                              ClipboardData(text: _translatedText)
                            );
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(AppTranslations.tr('copy_success')),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          }
                        : null,
                  ),
                ],
              ),
            
            const SizedBox(height: 20),

            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  border: Border.all(color: Theme.of(context).dividerColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : SingleChildScrollView(
                        child: Text(
                          _translatedText.isEmpty
                              ? AppTranslations.tr('res_pdf_empty')
                              : _translatedText,
                          style: const TextStyle(fontSize: 16, height: 1.5),
                        ),
                      ),
              ),
            ),
          ],
        ),
    );
  }
}
