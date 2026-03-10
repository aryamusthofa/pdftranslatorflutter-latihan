import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';

  Future<List<Map<String, dynamic>>> fetchPhotos() async {
    try {
      debugPrint('ApiService: Fetching photos from $baseUrl...');
      final response = await http.get(
        Uri.parse('$baseUrl/photos?_limit=21'),
        headers: {
          'User-Agent': 'FlutterApp/1.0',
          'Accept': '*/*',
        },
      );
      
      debugPrint('ApiService: Status Code: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        
        // Ganti URL gambar placeholder yang diblokir dengan Picsum Photos
        return data.map((item) {
          final Map<String, dynamic> photo = Map<String, dynamic>.from(item);
          final int id = photo['id'];
          photo['thumbnailUrl'] = 'https://picsum.photos/id/$id/200/200';
          return photo;
        }).toList();
      } else {
        debugPrint('ApiService ERROR Body: ${response.body}');
        throw Exception('Server mengembalikan error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('ApiService CATCH Error: $e');
      throw Exception('Gagal terhubung ke internet: $e');
    }
  }
}
