import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LampuProvider with ChangeNotifier {
  bool _isSwitched = false;
  double _intensity = 0.5;

  bool get isSwitched => _isSwitched;
  double get intensity => _intensity;

  LampuProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isSwitched = prefs.getBool('lamp_on') ?? false;
    _intensity = prefs.getDouble('lamp_intensity') ?? 0.5;
    notifyListeners();
  }

  Future<void> toggleLamp(bool value) async {
    _isSwitched = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('lamp_on', value);
    notifyListeners();
  }

  Future<void> setIntensity(double value) async {
    _intensity = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('lamp_intensity', value);
    notifyListeners();
  }
}
