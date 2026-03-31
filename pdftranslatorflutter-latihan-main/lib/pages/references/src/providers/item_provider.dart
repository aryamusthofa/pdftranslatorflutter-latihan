import 'package:flutter/material.dart';
import 'package:sembast/sembast.dart';
import '../services/database_service.dart';

class ItemModel {
  final int? id;
  final String name;

  ItemModel({this.id, required this.name});

  Map<String, dynamic> toMap() {
    return {'name': name};
  }

  factory ItemModel.fromMap(int id, Map<String, dynamic> map) {
    return ItemModel(id: id, name: map['name']);
  }
}

class ItemProvider with ChangeNotifier {
  List<ItemModel> _items = [];
  bool _isLoading = false;
  String _searchQuery = '';

  List<ItemModel> get items => _items;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  List<ItemModel> get filteredItems {
    if (_searchQuery.isEmpty) {
      return _items;
    }
    return _items
        .where((item) => item.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  ItemProvider() {
    fetchItems();
  }

  Future<void> fetchItems() async {
    _isLoading = true;
    notifyListeners();

    try {
      final db = await DatabaseService.instance.database;
      final records = await DatabaseService.instance.itemStore.find(db);

      _items = records.map((snapshot) {
        return ItemModel.fromMap(snapshot.key, snapshot.value);
      }).toList();
    } catch (e) {
      debugPrint('ItemProvider ERROR: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addItem(String name) async {
    final db = await DatabaseService.instance.database;
    final newItem = ItemModel(name: name);
    await DatabaseService.instance.itemStore.add(db, newItem.toMap());
    await fetchItems();
  }

  Future<void> deleteItem(int id) async {
    final db = await DatabaseService.instance.database;
    final finder = Finder(filter: Filter.byKey(id));
    await DatabaseService.instance.itemStore.delete(db, finder: finder);
    await fetchItems();
  }
}
