import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/database_service.dart';
import 'package:sembast/sembast.dart';
import 'dart:convert';
import 'dart:typed_data';

class AuthProvider with ChangeNotifier {
  String? _currentUser;
  String? _displayName;
  String? _bio;
  String? _profilePhoto;
  bool _isLoading = false;

  String? get currentUser => _currentUser;
  String? get displayName => _displayName;
  String? get bio => _bio;
  String? get profilePhoto => _profilePhoto;
  Uint8List? get profilePhotoBytes {
    if (_profilePhoto == null) return null;
    try { return base64Decode(_profilePhoto!); } catch (_) { return null; }
  }
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;

  AuthProvider() {
    checkAuth();
  }

  Future<void> _loadUserData(String username) async {
    final db = await DatabaseService.instance.database;
    final userData = await DatabaseService.instance.userStore.record(username).get(db);
    if (userData != null) {
      _displayName = userData['displayName'] as String?;
      _bio = userData['bio'] as String?;
      _profilePhoto = userData['profilePhoto'] as String?;
    }
  }

  Future<void> checkAuth() async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    _currentUser = prefs.getString('user_session');
    
    if (_currentUser != null) {
      await _loadUserData(_currentUser!);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> register(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final db = await DatabaseService.instance.database;
      final store = DatabaseService.instance.userStore;
      
      // Cek apakah user sudah ada
      final existing = await store.record(username).get(db);
      if (existing != null) {
        throw Exception('Username sudah terpakai');
      }

      await store.record(username).put(db, {'password': password});
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final db = await DatabaseService.instance.database;
      final store = DatabaseService.instance.userStore;
      
      final userData = await store.record(username).get(db);
      
      if (userData != null && userData['password'] == password) {
        _currentUser = username;
        await _loadUserData(username);
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_session', username);
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        throw Exception('Username atau Password salah');
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateProfile(String displayName, String bio) async {
    if (_currentUser == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final db = await DatabaseService.instance.database;
      final store = DatabaseService.instance.userStore;
      
      final existingData = await store.record(_currentUser!).get(db);
      final newData = Map<String, dynamic>.from(existingData ?? {});
      newData['displayName'] = displayName;
      newData['bio'] = bio;

      await store.record(_currentUser!).put(db, newData);
      
      _displayName = displayName;
      _bio = bio;
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    _displayName = null;
    _bio = null;
    _profilePhoto = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_session');
    notifyListeners();
  }

  Future<void> updateProfilePhoto(Uint8List bytes) async {
    if (_currentUser == null) return;
    final base64Str = base64Encode(bytes);

    final db = await DatabaseService.instance.database;
    final store = DatabaseService.instance.userStore;
    final existingData = await store.record(_currentUser!).get(db);
    final newData = Map<String, dynamic>.from(existingData ?? {});
    newData['profilePhoto'] = base64Str;
    await store.record(_currentUser!).put(db, newData);

    _profilePhoto = base64Str;
    notifyListeners();
  }
}
