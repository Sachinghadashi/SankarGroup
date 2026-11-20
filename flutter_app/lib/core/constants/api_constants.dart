import 'package:flutter/foundation.dart';

class ApiConstants {
  // Base URLs tailored for different environments:
  // - Android Emulator: 10.0.2.2 points to host machine localhost
  // - iOS Simulator / Web / Desktop: localhost points to host
  // - Real physical phone: replace with your local Wi-Fi IP (e.g. 192.168.1.15:5000)
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5000/api';
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:5000/api';
    } else {
      return 'http://localhost:5000/api';
    }
  }

  // Auth endpoints
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String profileEndpoint = '/auth/me';

  // Items endpoints (Direct from MongoDB)
  static const String itemsEndpoint = '/items';
  static const String statsEndpoint = '/items/stats';
  static const String categoriesEndpoint = '/items/categories';

  // Timeout duration
  static const Duration requestTimeout = Duration(seconds: 10);
}
