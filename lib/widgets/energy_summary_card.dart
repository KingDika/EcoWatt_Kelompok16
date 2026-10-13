import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Kartu distribusi energi terbarukan sesuai referensi final EcoWatt.
/// Menggunakan permukaan frosted-glass (blur + putih translucent) sehingga bagian bawah
/// foto rumah surya yang memudar tetap terlihat samar di belakang kartu, persis seperti
/// referensi, bukan kartu putih kaku.
class EnergySummaryCard extends StatelessWidget {
  final double solarProductionKw;
  final double consumptionKw;
  final int batteryPercentage;
  final double cleanEnergyRatio;

  const EnergySummaryCard({
    super.key,
    required this.solarProductionKw,
    required this.consumptionKw,
    required this.batteryPercentage,
    required this.cleanEnergyRatio,
  });

  static const double _radius = 28;

  @override
  Widget build(BuildContext context) {
    // Nilai dasar sesuai referensi gambar: 10.8 kWh total (6.9 home, 2.2 stored, 1.7 grid)
    final double multiplier =
        (solarProductionKw > 0 ? solarProductionKw / 10.8 : 1.0).clamp(
          0.1,
          5.0,
        );
    final totalStr = (10.8 * multiplier).toStringAsFixed(1);
    final usedHomeStr = (6.9 * multiplier).toStringAsFixed(1);
    final storedStr = (2.2 * multiplier).toStringAsFixed(1);
    final gridStr = (1.7 * multiplier).toStringAsFixed(1);

    return Container(
      // Bayangan sangat tipis di luar clip (tidak terpotong oleh ClipRRect)
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_radius),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08252525),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_radius),
        child: BackdropFilter(
          // Blur lembut: memburamkan sisa foto yang ada di belakang kartu
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.glassFill,
              borderRadius: BorderRadius.circular(_radius),
              border: Border.all(color: AppTheme.glassBorder, width: 1.2),
            ),
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Judul "Energy Distribution" & Tombol Panah Keluar ↗
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Energy Distribution',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryText,
                        letterSpacing: -0.2,
                      ),
                    ),
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: AppTheme.secondarySurface.withValues(alpha: 0.7),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.north_east_rounded,
                        size: 16,
                        color: AppTheme.primaryText,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Nilai Utama (10.8 kWh) dan Badge Pertumbuhan (+14% vs last month)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '$totalStr kWh',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primaryText,
                        letterSpacing: -0.8,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFDE8D3), // Warm peach tint
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.north_rounded,
                              size: 12,
                              color: Color(0xFFE67319),
                            ),
                            SizedBox(width: 3),
                            Flexible(
                              child: Text(
                                '+14% vs last month',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFE67319),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // Tiga Kolom Rincian Energi:
                // 6.9 kWh (Used in Home), 2.2 kWh (Stored Energy), 1.7 kWh (Exported to Grid)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildMetricColumn(
                      value: '$usedHomeStr kWh',
                      label: 'Used in Home',
                      dotColor: AppTheme.accentOrange,
                    ),
                    _buildMetricColumn(
                      value: '$storedStr kWh',
                      label: 'Stored Energy',
                      dotColor: const Color(0xFFFBBF24),
                    ),
                    _buildMetricColumn(
                      value: '$gridStr kWh',
                      label: 'Exported to Grid',
                      dotColor: const Color(0xFF9CA3AF),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Visualisasi Bar Horizontal Bersegmen (Orange, Yellow, Neutral Grey)
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Row(
                    children: List.generate(24, (index) {
                      Color segmentColor;
                      if (index < 14) {
                        segmentColor =
                            AppTheme.accentOrange; // ~64% Used in Home
                      } else if (index < 19) {
                        segmentColor = const Color(0xFFFBBF24); // ~20% Stored
                      } else {
                        segmentColor = const Color(0xFFD8D3C5); // ~16% Grid
                      }

                      return Expanded(
                        child: Container(
                          height: 15,
                          margin: const EdgeInsets.symmetric(horizontal: 1.5),
                          decoration: BoxDecoration(
                            color: segmentColor,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricColumn({
    required String value,
    required String label,
    required Color dotColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w800,
                color: AppTheme.primaryText,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppTheme.mutedText,
          ),
        ),
      ],
    );
  }
}
