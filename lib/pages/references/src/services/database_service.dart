import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast_io.dart';

class DatabaseService {
  static final DatabaseService _singleton = DatabaseService._();
  static DatabaseService get instance => _singleton;

  Completer<Database>? _dbOpenCompleter;

  DatabaseService._();

  Future<Database> get database async {
    if (_dbOpenCompleter == null) {
      _dbOpenCompleter = Completer();
      _openDatabase();
    }
    return _dbOpenCompleter!.future;
  }

  Future _openDatabase() async {
    try {
      debugPrint('Sembast: Opening database...');
      String dbDir;
      
      try {
        final appDocumentDir = await getApplicationDocumentsDirectory();
        dbDir = appDocumentDir.path;
      } catch (e) {
        debugPrint('Sembast WARNING: path_provider failed to get documents dir: $e');
        // Fallback: Gunakan folder home user atau folder saat ini
        dbDir = Platform.environment['HOME'] ?? '.';
        debugPrint('Sembast: Using fallback directory: $dbDir');
      }

      final dbPath = join(dbDir, 'my_app_db.db');
      debugPrint('Sembast: DB Path: $dbPath');

      final database = await databaseFactoryIo.openDatabase(dbPath);
      debugPrint('Sembast: Database opened successfully.');
      _dbOpenCompleter!.complete(database);
    } catch (e) {
      debugPrint('Sembast ERROR: Failed to open database: $e');
      _dbOpenCompleter!.completeError(e);
    }
  }

  // Stores
  final itemStore = intMapStoreFactory.store('items');
  final userStore = stringMapStoreFactory.store('users'); // Key is username
}
