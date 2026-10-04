import 'package:flutter/material.dart';

/// Soft, atmospheric elevation tokens for WeTravel.
/// Avoids heavy material shadows in favor of subtle, warm, diffused layers.
class AppShadows {
  AppShadows._();

  static const List<BoxShadow> subtle = [
    BoxShadow(
      color: Color(0x08005F73),
      offset: Offset(0, 2),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x0C005F73),
      offset: Offset(0, 4),
      blurRadius: 16,
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> floating = [
    BoxShadow(
      color: Color(0x14005F73),
      offset: Offset(0, 8),
      blurRadius: 24,
      spreadRadius: -2,
    ),
  ];
}
