import 'package:flutter/material.dart';
import '../../views/splash/splash_screen.dart';
import '../../views/auth/login_screen.dart';
import '../../views/auth/signup_screen.dart';
import '../../views/home/home_screen.dart';
import '../../views/listing/listing_screen.dart';
import '../../views/details/details_screen.dart';
import '../../models/item_model.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String listing = '/listing';
  static const String details = '/details';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case signup:
        return MaterialPageRoute(builder: (_) => const SignupScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case listing:
        final initialCategory = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => ListingScreen(initialCategory: initialCategory),
        );
      case details:
        final item = settings.arguments as ItemModel;
        return MaterialPageRoute(
          builder: (_) => DetailsScreen(item: item),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
