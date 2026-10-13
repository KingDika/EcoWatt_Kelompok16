import 'package:flutter/material.dart';

/// Tema visual premium EcoWatt berdasarkan referensi desain solar energy monitoring.
/// Palet Warna: Warm Beige (#F5F2E9), Secondary Surface (#E8E4D8), Accent Orange (#FF9234),
/// Primary Text (#252525), Muted Text (#777777), dan Active Device Tint (#FFF0DF).
class AppTheme {
  // Palet Warna Utama (Referensi Desain)
  static const Color primaryBackground = Color(0xFFF5F2E9); // Warm Beige
  static const Color secondarySurface = Color(
    0xFFE8E4D8,
  ); // Soft Warm Grey/Beige
  static const Color accentOrange = Color(0xFFFF9234); // Solar Accent Orange
  static const Color darkOrange = Color(0xFFE67319); // Deep Solar Orange
  static const Color activeDeviceBg = Color(0xFFFFF0DF); // Warm Orange Tint
  static const Color primaryText = Color(0xFF252525); // Rich Charcoal
  static const Color mutedText = Color(0xFF777777); // Elegant Grey
  static const Color lightMuted = Color(0xFFA5A196); // Subtle Divider/Muted
  static const Color surfaceWhite = Color(0xFFFFFFFF); // Pure White
  static const Color borderBeige = Color(0xFFE5E0D2); // Soft Border
  static const Color cardShadowColor = Color(0x12000000); // Soft Ambient Shadow

  // ---------------------------------------------------------------------------
  // BARU: Token untuk hero "seamless" & efek glass (frosted) sesuai referensi
  // ---------------------------------------------------------------------------

  /// Cahaya matahari terbenam di sisi kanan hero (radial glow di belakang foto).
  static const Color sunGlow = Color(0xFFFFB566);

  /// Warna peach hangat untuk menyelaraskan tone foto dengan latar beige.
  static const Color heroPeach = Color(0xFFF8E3C4);

  /// Permukaan kaca (frosted glass) untuk chip & kartu: putih ~55% opacity.
  static const Color glassFill = Color(0x8CFFFFFF);

  /// Tepi kaca: putih ~60% opacity agar terlihat lembut, bukan garis keras.
  static const Color glassBorder = Color(0x99FFFFFF);

  // Kompatibilitas aksen energi terbarukan
  static const Color solarAmber = Color(0xFFFF9234);
  static const Color batteryAmber = Color(0xFFF59E0B);
  static const Color greenEco = Color(0xFF10B981);
  static const Color gridGrey = Color(0xFF6B7280);

  // Kompatibilitas variabel lama untuk transisi mulus
  static const Color backgroundLight = primaryBackground;
  static const Color primaryGreen = accentOrange;
  static const Color darkGreen = darkOrange;
  static const Color lightGreen = activeDeviceBg;
  static const Color textDark = primaryText;
  static const Color borderGrey = borderBeige;
  static const Color cardGrey = secondarySurface;
  static const Color batteryPurple = Color(0xFF8B5CF6);
  static const Color windBlue = Color(0xFF0284C7);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: primaryBackground,
      colorScheme: ColorScheme.fromSeed(
        seedColor: accentOrange,
        primary: accentOrange,
        secondary: darkOrange,
        surface: surfaceWhite,
        error: const Color(0xFFEF4444),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryBackground,
        foregroundColor: primaryText,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: primaryText,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: borderBeige, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentOrange,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
