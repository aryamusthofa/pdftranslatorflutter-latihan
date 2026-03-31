import 'package:flutter/material.dart';
import '../services/api_service.dart';

class GalleryProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _photos = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<Map<String, dynamic>> get photos => _photos;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  GalleryProvider() {
    fetchPhotos();
  }

  Future<void> fetchPhotos() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _photos = await _apiService.fetchPhotos();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
