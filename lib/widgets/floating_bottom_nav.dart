import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Floating pill-shaped navigation bar premium sesuai referensi EcoWatt Solar Energy Dashboard.
/// Menampilkan 3 destinasi navigasi: Dashboard, Smart Devices, dan Energy Control.
/// Item aktif memiliki ikon lingkaran oranye cerah (#FF9234), teks oranye, dan titik indikator di bawahnya.
class FloatingBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const FloatingBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xF2FFFFFF), // Warm frosted white
        borderRadius: BorderRadius.circular(42),
        border: Border.all(
          color: AppTheme.borderBeige.withAlpha(180),
          width: 1.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18252525),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(index: 0, icon: Icons.home_rounded, label: 'Dashboard'),
          _buildNavItem(
            index: 1,
            icon: Icons.devices_other_rounded,
            label: 'Smart Devices',
          ),
          _buildNavItem(
            index: 2,
            icon: Icons.show_chart_rounded,
            label: 'Energy Control',
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = currentIndex == index;

    return InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: () => onTap(index),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  width: isSelected ? 38 : 34,
                  height: isSelected ? 38 : 34,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.accentOrange
                        : AppTheme.secondarySurface,
                    shape: BoxShape.circle,
                    boxShadow: isSelected
                        ? const [
                            BoxShadow(
                              color: Color(0x4DFF9234),
                              blurRadius: 10,
                              offset: Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      size: isSelected ? 20 : 18,
                      color: isSelected ? Colors.white : AppTheme.mutedText,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? AppTheme.accentOrange
                        : AppTheme.mutedText,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
            if (isSelected) ...[
              const SizedBox(height: 3),
              Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: AppTheme.accentOrange,
                  shape: BoxShape.circle,
                ),
              ),
            ] else ...[
              const SizedBox(height: 7),
            ],
          ],
        ),
      ),
    );
  }
}
