import 'package:flutter/material.dart';

/// Shape and corner radius tokens for WeTravel.
/// Follows moderate, refined curves (16-20px cards, 12-16px buttons/inputs, pill chips).
class AppRadius {
  AppRadius._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 28.0;
  static const double pill = 999.0;

  // BorderRadius presets
  static const BorderRadius roundedSm = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius roundedMd = BorderRadius.all(Radius.circular(md));
  static const BorderRadius roundedLg = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius roundedXl = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius roundedPill = BorderRadius.all(Radius.circular(pill));

  // Component-specific shapes
  static const BorderRadius card = BorderRadius.all(Radius.circular(xl)); // 20px
  static const BorderRadius button = BorderRadius.all(Radius.circular(lg)); // 16px
  static const BorderRadius input = BorderRadius.all(Radius.circular(md)); // 12-14px
  static const BorderRadius chip = BorderRadius.all(Radius.circular(pill));
  static const BorderRadius bottomSheet = BorderRadius.vertical(top: Radius.circular(24.0));
}
