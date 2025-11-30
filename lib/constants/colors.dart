import 'package:flutter/material.dart';

class AppColors {
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color lightBlue = Color(0xFF64B5F6);
  static const Color lightCyan = Color(0xFFBEE6FF);
  static const LinearGradient blueWhiteGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.lightCyan, AppColors.white],
  );
}
