import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:translator/translator.dart';
import '../translations.dart';

class TtsGeneratorPage extends StatefulWidget {
  const TtsGeneratorPage({super.key});

  @override
  State<TtsGeneratorPage> createState() => _TtsGeneratorPageState();
}

class _TtsGeneratorPageState extends State<TtsGeneratorPage> with SingleTickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final GoogleTranslator _translator = GoogleTranslator();
  final FlutterTts _flutterTts = FlutterTts();

  String _sourceLang = 'id';
  String _targetLang = 'en';
  String _gender = 'female'; // 'male' or 'female'

  bool _isTranslating = false;
  bool _isPlaying = false;
  String _translatedText = '';

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final Map<String, String> _locales = {
    'id': 'id-ID', 'en': 'en-US', 'zh': 'zh-CN', 'ja': 'ja-JP',
    'ko': 'ko-KR', 'ar': 'ar-SA', 'ru': 'ru-RU', 'fr': 'fr-FR',
    'es': 'es-ES', 'de': 'de-DE', 'it': 'it-IT', 'pt': 'pt-BR',
    'nl': 'nl-NL', 'th': 'th-TH', 'vi': 'vi-VN', 'hi': 'hi-IN',
    'tr': 'tr-TR', 'pl': 'pl-PL', 'sv': 'sv-SE', 'el': 'el-GR'
  };

  @override
  void initState() {
    super.initState();
    _initTts();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _pulseController.reverse();
        } else if (status == AnimationStatus.dismissed && _isPlaying) {
          _pulseController.forward();
        }
      });
  }

  Future<void> _initTts() async {
    try {
      // setSharedInstance mainly used for iOS to share audio session
      await _flutterTts.setSharedInstance(true);
    } catch (e) {
      debugPrint("setSharedInstance is not supported on this platform: $e");
    }
    
    _flutterTts.setStartHandler(() {
      if (mounted) {
        setState(() => _isPlaying = true);
        _pulseController.forward();
      }
    });
    _flutterTts.setCompletionHandler(() {
      if (mounted) {
        setState(() => _isPlaying = false);
        _pulseController.stop();
      }
    });
    _flutterTts.setErrorHandler((msg) {
      if (mounted) {
        setState(() => _isPlaying = false);
        _pulseController.stop();
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _flutterTts.stop();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _generateSpeech() async {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppTranslations.tr('tts_err_empty'))),
      );
      return;
    }

    setState(() {
      _isTranslating = true;
      _translatedText = '';
    });

    try {
      // Translate
      var translation = await _translator.translate(
        text,
        from: _sourceLang,
        to: _targetLang,
      );
      
      if (!mounted) return;
      
      setState(() {
        _translatedText = translation.text;
      });

      // Manage TTS
      String targetLocale = _locales[_targetLang] ?? 'en-US';
      try {
        await _flutterTts.setLanguage(targetLocale);
      } catch (e) {
        debugPrint("setLanguage not supported on this platform (fallback active): $e");
      }

      // Attempt Gender Selection (Fallback nicely if unavailable)
      try {
        dynamic rawVoices = await _flutterTts.getVoices;
        if (rawVoices != null && rawVoices is List) {
          List<dynamic> voices = rawVoices;
          List<dynamic> filteredVoices = voices.where((v) {
            return v["locale"].toString().startsWith(_targetLang);
          }).toList();

          dynamic targetedVoice;
          for (var v in filteredVoices) {
            var name = v["name"].toString().toLowerCase();
            if (_gender == 'male' && name.contains('male') && !name.contains('female')) {
              targetedVoice = v;
              break;
            } else if (_gender == 'female' && name.contains('female')) {
              targetedVoice = v;
              break;
            }
          }
          
          if (targetedVoice != null) {
            await _flutterTts.setVoice({"name": targetedVoice["name"], "locale": targetedVoice["locale"]});
          }
        }
      } catch (e) {
        debugPrint("Error fetching/setting voices (Linux/WSL fallback active): $e");
      }

      debugPrint("Attempting to speak translated text: $_translatedText");
      try {
        await _flutterTts.speak(_translatedText);
        debugPrint("Successfully triggered speak()");
      } catch (e) {
        if (e.toString().contains('MissingPluginException')) {
          if (Platform.isLinux) {
             debugPrint("WSL detected. Using PowerShell fallback for TTS...");
             try {
                // Base64 encode to prevent quote/escaping issues in powershell command
                String b64Text = base64.encode(utf8.encode(_translatedText));
                
                String pGender = _gender == 'female' ? 'Female' : 'Male';
                String pLang = _locales[_targetLang] ?? 'en-US';
                
                String psCommand = "Add-Type -AssemblyName System.Speech; \$s = New-Object System.Speech.Synthesis.SpeechSynthesizer; "
                                   "try { \$s.SelectVoiceByHints([System.Speech.Synthesis.VoiceGender]::$pGender, [System.Speech.Synthesis.VoiceAge]::Adult, 0, [System.Globalization.CultureInfo]::GetCultureInfo('$pLang')) } catch {}; "
                                   "\$s.Speak([System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('$b64Text')))";
                
                await Process.run('powershell.exe', [
                  '-Command', psCommand
                ]);
                if (mounted) {
                  setState(() => _isPlaying = false);
                  _pulseController.stop();
                }
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
      debugPrint("Main _generateSpeech exception: $e");
      if (!e.toString().contains('MissingPluginException')) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      debugPrint("Finished _generateSpeech execution");
      if (mounted) setState(() => _isTranslating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: AppTranslations.currentLocale,
      builder: (context, locale, _) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.indigo.shade900,
                Colors.purple.shade800,
                Colors.black87,
              ],
            ),
          ),
          child: SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(50),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: const Icon(Icons.record_voice_over, color: Colors.white, size: 30),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppTranslations.tr('tts_title'),
                                    style: const TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    AppTranslations.tr('tts_subtitle'),
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white.withAlpha(180),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),

                        // Input Card
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(20),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withAlpha(40)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextField(
                                controller: _textController,
                                maxLines: 4,
                                style: const TextStyle(color: Colors.white, fontSize: 18),
                                decoration: InputDecoration(
                                  hintText: AppTranslations.tr('tts_input_hint'),
                                  hintStyle: TextStyle(color: Colors.white.withAlpha(100)),
                                  border: InputBorder.none,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Controls Grid
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          childAspectRatio: 2.5,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          children: [
                            _buildDropdown(
                              label: AppTranslations.tr('tts_source_lang'),
                              value: _sourceLang,
                              items: _locales.keys.toList(),
                              onChanged: (v) => setState(() => _sourceLang = v!),
                            ),
                            _buildDropdown(
                              label: AppTranslations.tr('tts_target_lang'),
                              value: _targetLang,
                              items: _locales.keys.toList(),
                              onChanged: (v) => setState(() => _targetLang = v!),
                            ),
                            _buildGenderDropdown(),
                          ],
                        ),

                        const SizedBox(height: 30),

                        // Generate Button & Animation
                        Center(
                          child: Column(
                            children: [
                              AnimatedBuilder(
                                animation: _pulseAnimation,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: _isPlaying ? _pulseAnimation.value : 1.0,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        boxShadow: _isPlaying
                                            ? [
                                                BoxShadow(
                                                  color: Colors.purple.withAlpha(150),
                                                  blurRadius: 30,
                                                  spreadRadius: 10,
                                                )
                                              ]
                                            : [],
                                      ),
                                      child: child,
                                    ),
                                  );
                                },
                                child: ElevatedButton(
                                  onPressed: _isTranslating || _isPlaying ? () {
                                    _flutterTts.stop();
                                    setState(() {
                                      _isPlaying = false;
                                    });
                                  } : _generateSpeech,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _isPlaying ? Colors.redAccent : Colors.purpleAccent,
                                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  child: _isTranslating 
                                      ? const CircularProgressIndicator(color: Colors.white)
                                      : Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(_isPlaying ? Icons.stop : Icons.play_arrow, color: Colors.white, size: 28),
                                            const SizedBox(width: 10),
                                            Text(
                                              _isPlaying ? AppTranslations.tr('tts_speaking') : AppTranslations.tr('tts_generate_btn'),
                                              style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                              const SizedBox(height: 30),

                              // Translation Result
                              if (_translatedText.isNotEmpty)
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withAlpha(20),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.greenAccent.withAlpha(100)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Translation:',
                                        style: TextStyle(color: Colors.greenAccent.shade100, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        _translatedText,
                                        style: const TextStyle(color: Colors.white, fontSize: 18),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(30),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: TextStyle(color: Colors.white.withAlpha(150), fontSize: 12)),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: Colors.indigo.shade900,
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              onChanged: onChanged,
              items: items.map((String it) {
                return DropdownMenuItem(value: it, child: Text(AppTranslations.fullLanguageNames[it] ?? it.toUpperCase()));
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(30),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(AppTranslations.tr('tts_gender'), style: TextStyle(color: Colors.white.withAlpha(150), fontSize: 12)),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _gender,
              isExpanded: true,
              dropdownColor: Colors.indigo.shade900,
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              onChanged: (v) => setState(() => _gender = v!),
              items: [
                DropdownMenuItem(value: 'male', child: Text(AppTranslations.tr('tts_gender_male'))),
                DropdownMenuItem(value: 'female', child: Text(AppTranslations.tr('tts_gender_female'))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
