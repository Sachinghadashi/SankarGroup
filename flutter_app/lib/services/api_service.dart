import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/api_constants.dart';
import '../models/user_model.dart';
import '../models/item_model.dart';

class ApiService {
  // Auth: Login directly against database
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.loginEndpoint}');
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(ApiConstants.requestTimeout);

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'token': data['token'],
          'user': UserModel.fromJson(data['user']),
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Login failed. Please check your credentials.',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to connect to backend server at ${ApiConstants.baseUrl}. Make sure backend is running.',
      };
    }
  }

  // Auth: Register directly into database
  static Future<Map<String, dynamic>> register(
      String name, String email, String password) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.registerEndpoint}');
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'name': name, 'email': email, 'password': password}),
          )
          .timeout(ApiConstants.requestTimeout);

      final data = jsonDecode(response.body);
      if (response.statusCode == 201 && data['success'] == true) {
        return {
          'success': true,
          'token': data['token'],
          'user': UserModel.fromJson(data['user']),
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Registration failed in database',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to connect to backend server at ${ApiConstants.baseUrl}.',
      };
    }
  }

  // Items: Fetch List from MongoDB with Search & Filtering
  static Future<List<ItemModel>> getItems({
    String? category,
    String? search,
    String? sortBy,
  }) async {
    final queryParams = <String, String>{};
    if (category != null && category != 'All') queryParams['category'] = category;
    if (search != null && search.trim().isNotEmpty) queryParams['search'] = search.trim();
    if (sortBy != null) queryParams['sortBy'] = sortBy;

    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.itemsEndpoint}')
        .replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

    final response = await http.get(uri).timeout(ApiConstants.requestTimeout);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true && data['items'] != null) {
        final List list = data['items'];
        return list.map((item) => ItemModel.fromJson(item)).toList();
      }
    }

    throw Exception('Failed to load items from database (Status ${response.statusCode})');
  }

  // Categories: Fetch distinct categories directly from MongoDB
  static Future<List<String>> getCategories() async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.categoriesEndpoint}');
      final response = await http.get(url).timeout(ApiConstants.requestTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['categories'] != null) {
          final List list = data['categories'];
          return list.map((c) => c.toString()).toList();
        }
      }
    } catch (e) {
      // If error occurs, at least provide 'All'
    }
    return ['All'];
  }

  // Items: Fetch Dashboard Stats from MongoDB
  static Future<Map<String, dynamic>> getDashboardStats() async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.statsEndpoint}');
    final response = await http.get(url).timeout(ApiConstants.requestTimeout);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true && data['stats'] != null) {
        return data['stats'];
      }
    }

    return {
      'totalItems': 0,
      'totalCategories': 0,
      'featuredItems': 0,
      'averageRating': 0.0,
    };
  }
}
