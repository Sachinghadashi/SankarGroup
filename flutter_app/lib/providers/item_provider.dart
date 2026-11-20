import 'package:flutter/material.dart';
import '../models/item_model.dart';
import '../services/api_service.dart';
import '../core/utils/shared_prefs_helper.dart';

class ItemProvider extends ChangeNotifier {
  List<ItemModel> _items = [];
  List<ItemModel> _featuredItems = [];
  List<String> _favoriteIds = [];
  List<String> _categories = ['All'];
  Map<String, dynamic> _stats = {
    'totalItems': 0,
    'totalCategories': 0,
    'featuredItems': 0,
    'averageRating': 0.0,
  };

  bool _isLoading = false;
  String? _errorMessage;
  String _selectedCategory = 'All';
  String _searchQuery = '';
  String _sortBy = 'newest';

  // Getters
  List<ItemModel> get items => _items;
  List<ItemModel> get featuredItems => _featuredItems;
  List<String> get favoriteIds => _favoriteIds;
  List<String> get categories => _categories;
  Map<String, dynamic> get stats => _stats;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  String get sortBy => _sortBy;

  // Initialize Provider
  Future<void> init() async {
    await loadFavorites();
    await fetchCategories();
    await fetchItems();
    await fetchStats();
  }

  // Fetch dynamic categories directly from MongoDB
  Future<void> fetchCategories() async {
    try {
      final dbCategories = await ApiService.getCategories();
      if (dbCategories.isNotEmpty) {
        _categories = dbCategories;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching categories from database: $e');
    }
  }

  // Load favorites from SharedPreferences
  Future<void> loadFavorites() async {
    _favoriteIds = await SharedPrefsHelper.getFavorites();
    notifyListeners();
  }

  // Toggle favorite and persist in SharedPreferences
  Future<void> toggleFavorite(String itemId) async {
    final isNowFav = await SharedPrefsHelper.toggleFavorite(itemId);
    if (isNowFav) {
      if (!_favoriteIds.contains(itemId)) _favoriteIds.add(itemId);
    } else {
      _favoriteIds.remove(itemId);
    }
    notifyListeners();
  }

  bool isFavorite(String itemId) {
    return _favoriteIds.contains(itemId);
  }

  // Get Favorite Item Objects
  List<ItemModel> get favoriteItems {
    return _items.where((item) => _favoriteIds.contains(item.id)).toList();
  }

  // Fetch Items from MongoDB
  Future<void> fetchItems() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final fetched = await ApiService.getItems(
        category: _selectedCategory,
        search: _searchQuery,
        sortBy: _sortBy,
      );
      _items = fetched;
      _featuredItems = fetched.where((i) => i.isFeatured).toList();
    } catch (e) {
      _errorMessage = e.toString();
      _items = [];
      _featuredItems = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  // Fetch Stats from MongoDB
  Future<void> fetchStats() async {
    try {
      _stats = await ApiService.getDashboardStats();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching stats from database: $e');
    }
  }

  // Set Search Filter
  void setSearchQuery(String query) {
    _searchQuery = query;
    fetchItems();
  }

  // Set Category Filter
  void setCategory(String category) {
    _selectedCategory = category;
    fetchItems();
  }

  // Set Sort By
  void setSortBy(String sortOption) {
    _sortBy = sortOption;
    fetchItems();
  }

  // Reset Filters
  void resetFilters() {
    _selectedCategory = 'All';
    _searchQuery = '';
    _sortBy = 'newest';
    fetchItems();
  }
}
