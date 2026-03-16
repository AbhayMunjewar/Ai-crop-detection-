import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors
  static const Color primaryGreen = Color(0xFF00FF66); // Neon Green
  static const Color primaryGreenDark = Color(0xFF00CC52);
  
  // Backgrounds - Dark
  static const Color backgroundDark = Color(0xFF0A0F0D); 
  static const Color cardBackgroundDark = Color(0xFF141A17);
  static const Color bottomNavBackgroundDark = Color(0xFF0F1412);
  
  // Backgrounds - Light
  static const Color backgroundLight = Color(0xFFF5F7F5);
  static const Color cardBackgroundLight = Color(0xFFFFFFFF);
  static const Color bottomNavBackgroundLight = Color(0xFFF0F2F0);

  // Status Colors
  static const Color statusSafe = Color(0xFF00FF66);
  static const Color statusWarning = Color(0xFFFFB800);
  static const Color statusDanger = Color(0xFFFF3333);
  
  // Text Colors - Dark Mode
  static const Color textLightDark = Color(0xFFFFFFFF);
  static const Color textMutedDark = Color(0xFF8A9992);

  // Text Colors - Light Mode
  static const Color textLightLight = Color(0xFF1A1F1C);
  static const Color textMutedLight = Color(0xFF6B7570);

  // Dynamic aliases to easily swap in places not using Theme.of()
  static const Color cardBackground = Color(0xFF141A17); // Keep for backwards compatibility
  static const Color bottomNavBackground = Color(0xFF0F1412);
  static const Color textMuted = Color(0xFF8A9992);
  static const Color textLight = Color(0xFFFFFFFF);
  
  // Gradients
  static const RadialGradient scannerGradient = RadialGradient(
    colors: [
      Color(0x3300FF41), // Semi-transparent green
      Color(0x0000FF41),
    ],
    radius: 0.8,
  );
}
