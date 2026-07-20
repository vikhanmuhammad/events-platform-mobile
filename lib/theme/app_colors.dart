import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const brand300 = Color(0xFFC4B5FD);
  static const brand400 = Color(0xFFA78BFA);
  static const brand500 = Color(0xFF8B5CF6);
  static const brand600 = Color(0xFF7C3AED);
  static const brand700 = Color(0xFF6D28D9);
  static const fuchsia500 = Color(0xFFD946EF);

  static const accent400 = Color(0xFFFBBF24);
  static const accent500 = Color(0xFFF59E0B);
  static const accent600 = Color(0xFFD97706);

  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const danger = Color(0xFFF43F5E);

  static const background = Color(0xFFFAF9FC);

  static const brandGradient = LinearGradient(
    colors: [brand600, fuchsia500],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class CategoryColors {
  CategoryColors._();

  static const Map<String, Color> _colors = {
    'Tech': Color(0xFF3B82F6),
    'Sports': Color(0xFF10B981),
    'Music': Color(0xFFEC4899),
    'Art': Color(0xFFA855F7),
    'Food': Color(0xFFF97316),
    'Social': Color(0xFF06B6D4),
  };

  static Color of(String category) => _colors[category] ?? Colors.grey;
}
