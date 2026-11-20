import 'package:flutter/foundation.dart';

class ApiConstants {
  // Production Render Backend URL
  static const String productionBaseUrl = 'https://sankargroup-backend.onrender.com/api';

  // Local development URLs
  static const String _localWebDesktopUrl = 'http://localhost:5000/api';
  static const String _localAndroidUrl = 'http://10.0.2.2:5000/api';

  // Toggle between cloud production backend and local server
  static const bool useProduction = true;

  // Active Base URL
  static String get baseUrl {
    if (useProduction) {
      return productionBaseUrl;
    }

    if (kIsWeb) {
      return _localWebDesktopUrl;
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      return _localAndroidUrl;
    } else {
      return _localWebDesktopUrl;
    }
  }

  // Health check endpoint
  static const String healthEndpoint = '/health';

  // Auth endpoints
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String profileEndpoint = '/auth/me';

  // Items endpoints (Direct from MongoDB)
  static const String itemsEndpoint = '/items';
  static const String statsEndpoint = '/items/stats';
  static const String categoriesEndpoint = '/items/categories';

  // Timeout duration (45 seconds to accommodate Render free-tier cold starts)
  static const Duration requestTimeout = Duration(seconds: 45);
}
