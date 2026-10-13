import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Komponen visualisasi distribusi bauran sumber energi terbarukan (SDG 7).
/// Menggunakan Card, Stack (untuk bar distribusi bertingkat), Row, dan Column.
/// Ditata dengan palet warm beige (#F5F2E9) dan aksen oranye (#FF9234).
class EnergyDistributionCard extends StatelessWidget {
  final double solarKw;
  final double windKw;
  final double batteryKw;
  final double gridKw;

  const EnergyDistributionCard({
    super.key,
    required this.solarKw,
    required this.windKw,
    required this.batteryKw,
    required this.gridKw,
  });

  @override
  Widget build(BuildContext context) {
    final totalKw = solarKw + windKw + batteryKw + gridKw;
    final safeTotal = totalKw > 0 ? totalKw : 1.0;

    final solarPct = ((solarKw / safeTotal) * 100).round();
    final windPct = ((windKw / safeTotal) * 100).round();
    final batteryPct = ((batteryKw / safeTotal) * 100).round();
    final gridPct = (100 - solarPct - windPct - batteryPct).clamp(0, 100);

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.borderBeige, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C252525),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Judul dan Header Komponen
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppTheme.activeDeviceBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.pie_chart_outline_rounded,
                      color: AppTheme.accentOrange,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Distribusi Pasokan Energi',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryText,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
              Text(
                'Total ${totalKw.toStringAsFixed(1)} kW',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.mutedText,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Bar Distribusi Multi-Warna Bertumpuk
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              height: 14,
              child: Row(
                children: [
                  if (solarPct > 0)
                    Expanded(
                      flex: solarPct,
                      child: Container(color: AppTheme.accentOrange),
                    ),
                  if (windPct > 0)
                    Expanded(
                      flex: windPct,
                      child: Container(color: const Color(0xFF0284C7)),
                    ),
                  if (batteryPct > 0)
                    Expanded(
                      flex: batteryPct,
                      child: Container(color: const Color(0xFFFBBF24)),
                    ),
                  if (gridPct > 0)
                    Expanded(
                      flex: gridPct,
                      child: Container(color: AppTheme.secondarySurface),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 18),

          // Rincian Sumber Energi Terbarukan
          _buildSourceItem(
            icon: Icons.solar_power_rounded,
            color: AppTheme.accentOrange,
            title: 'Pembangkit Listrik Surya',
            percentage: '$solarPct%',
            power: '${solarKw.toStringAsFixed(2)} kW',
          ),
          const Divider(height: 18, color: AppTheme.borderBeige),
          _buildSourceItem(
            icon: Icons.air_rounded,
            color: const Color(0xFF0284C7),
            title: 'Mikro Turbin Angin',
            percentage: '$windPct%',
            power: '${windKw.toStringAsFixed(2)} kW',
          ),
          const Divider(height: 18, color: AppTheme.borderBeige),
          _buildSourceItem(
            icon: Icons.battery_charging_full_rounded,
            color: const Color(0xFFFBBF24),
            title: 'Penyimpanan Baterai Rumah',
            percentage: '$batteryPct%',
            power: '${batteryKw.toStringAsFixed(2)} kW',
          ),
          const Divider(height: 18, color: AppTheme.borderBeige),
          _buildSourceItem(
            icon: Icons.electrical_services_rounded,
            color: AppTheme.lightMuted,
            title: 'Jaringan Grid PLN Cadangan',
            percentage: '$gridPct%',
            power: '${gridKw.toStringAsFixed(2)} kW',
          ),
        ],
      ),
    );
  }

  Widget _buildSourceItem({
    required IconData icon,
    required Color color,
    required String title,
    required String percentage,
    required String power,
  }) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withAlpha(31),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryText,
            ),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              percentage,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            Text(
              power,
              style: const TextStyle(fontSize: 11, color: AppTheme.mutedText),
            ),
          ],
        ),
      ],
    );
  }
}
