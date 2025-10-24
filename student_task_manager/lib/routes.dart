// lib/routes.dart
import 'package:flutter/material.dart';

import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';

class AppRoutes {
  static const login = '/';
  static const signup = '/signup';
  static const home = '/home';
  static const profile = '/profile';

  // Custom page transition: fade + scale
  static Route<dynamic> _buildRoute(Widget child, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionDuration: const Duration(milliseconds: 420),
      reverseTransitionDuration: const Duration(milliseconds: 320),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final fade = CurvedAnimation(parent: animation, curve: Curves.easeOut);
        final scale = Tween<double>(begin: 0.98, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
        );
        return FadeTransition(
          opacity: fade,
          child: ScaleTransition(scale: scale, child: child),
        );
      },
    );
  }

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return _buildRoute(const LoginScreen(), settings);
      case signup:
        return _buildRoute(const SignupScreen(), settings);
      case home:
        return _buildRoute(const HomeScreen(), settings);
      case profile:
        return _buildRoute(const ProfileScreen(), settings);
      default:
        return _buildRoute(const LoginScreen(), settings);
    }
  }
}
