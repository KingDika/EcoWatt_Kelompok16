import 'package:flutter/material.dart';

import '../models/device_model.dart';
import '../theme/app_theme.dart';

/// Kartu perangkat pintar premium dengan dukungan gesture onTap dan onLongPress.
/// Didesain ulang sesuai panduan visual Phase 2.5:
/// - Warm white / light beige background (#FFF0DF saat aktif).
/// - Sudut melengkung halus (20px) dengan soft ambient shadow.
/// - Aksen oranye (#FF9234) pada state aktif.
/// - AnimatedContainer untuk transisi warna halus.
/// - onTap: Toggle status ON/OFF dengan animasi visual dan kalkulasi daya real-time.
/// - onLongPress: Menampilkan modal bottom sheet informasi tanpa mengubah status ON/OFF.
class DeviceCard extends StatefulWidget {
  final SmartDevice device;
  final ValueChanged<bool> onToggle;

  const DeviceCard({super.key, required this.device, required this.onToggle});

  @override
  State<DeviceCard> createState() => _DeviceCardState();
}

class _DeviceCardState extends State<DeviceCard> {
  late bool _isOn;

  @override
  void initState() {
    super.initState();
    _isOn = widget.device.isOn;
  }

  @override
  void didUpdateWidget(covariant DeviceCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.device.isOn != widget.device.isOn) {
      _isOn = widget.device.isOn;
    }
  }

  /// Handler untuk Tap Gesture: Mengubah status perangkat ON/OFF
  void _handleTap() {
    setState(() {
      _isOn = !_isOn;
    });
    // Memperbarui status ke parent widget untuk perhitungan total konsumsi daya
    widget.onToggle(_isOn);
  }

  /// Handler untuk Long Press Gesture: Menampilkan modal bottom sheet
  /// Catatan: Tidak memicu perubahan status ON/OFF perangkat
  void _handleLongPress() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext modalContext) {
        return _buildDetailBottomSheet(modalContext);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // GestureDetector membungkus kartu dengan HitTestBehavior.opaque
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _handleTap,
      onLongPress: _handleLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.symmetric(vertical: 6.0),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        decoration: BoxDecoration(
          color: _isOn ? AppTheme.activeDeviceBg : AppTheme.surfaceWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _isOn ? AppTheme.accentOrange : AppTheme.borderBeige,
            width: _isOn ? 1.6 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: _isOn ? const Color(0x26FF9234) : const Color(0x0A252525),
              blurRadius: _isOn ? 14 : 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon Perangkat dengan Stack untuk status titik aktif & animasi
            Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: _isOn
                        ? AppTheme.accentOrange.withAlpha(46)
                        : AppTheme.secondarySurface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    // Ikon perangkat berubah secara dinamis sesuai status aktif/nonaktif
                    _isOn
                        ? widget.device.activeIcon
                        : widget.device.inactiveIcon,
                    size: 26,
                    color: _isOn ? AppTheme.accentOrange : AppTheme.mutedText,
                  ),
                ),
                // Indikator Titik Status di Sudut Kanan Atas Icon
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isOn
                          ? AppTheme.accentOrange
                          : const Color(0xFFCCCCCC),
                      border: Border.all(
                        color: AppTheme.surfaceWhite,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(width: 14),

            // Informasi Perangkat: Nama, Ruangan, Wattage
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.device.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _isOn ? AppTheme.primaryText : AppTheme.mutedText,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 3),
                  // Lokasi Ruangan & Sumber Daya
                  Row(
                    children: [
                      Text(
                        widget.device.room,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.mutedText,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        '•',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.lightMuted,
                        ),
                      ),
                      const SizedBox(width: 6),
                      _buildEnergySourceBadge(widget.device.energySource),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Daya Konsumsi (Watt)
                  Row(
                    children: [
                      Icon(
                        Icons.bolt_rounded,
                        size: 14,
                        color: _isOn
                            ? AppTheme.accentOrange
                            : AppTheme.lightMuted,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        _isOn
                            ? '${widget.device.powerWatts.toInt()} W aktif'
                            : 'Standby 0 W (${widget.device.powerWatts.toInt()} W)',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: _isOn
                              ? AppTheme.darkOrange
                              : AppTheme.lightMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            // Indikator Switch & Visual Pill Status
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Switch.adaptive(
                  value: _isOn,
                  onChanged: (newValue) => _handleTap(),
                  activeTrackColor: AppTheme.accentOrange.withAlpha(102),
                  activeThumbColor: AppTheme.accentOrange,
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: AppTheme.borderBeige,
                ),
                Text(
                  'Tahan: Info',
                  style: TextStyle(
                    fontSize: 9.5,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Modal Bottom Sheet dengan Tema Premium Warm Beige & Orange
  Widget _buildDetailBottomSheet(BuildContext modalContext) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.primaryBackground,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag Handle Indikator
            Center(
              child: Container(
                width: 44,
                height: 4,
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  color: AppTheme.borderBeige,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header: Ikon & Nama Perangkat
            Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: _isOn
                        ? AppTheme.accentOrange.withAlpha(46)
                        : AppTheme.secondarySurface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    _isOn
                        ? widget.device.activeIcon
                        : widget.device.inactiveIcon,
                    color: _isOn ? AppTheme.accentOrange : AppTheme.mutedText,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.device.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primaryText,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Lokasi: ${widget.device.room} • Sumber: ${widget.device.energySource}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.mutedText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            const Divider(height: 1, color: AppTheme.borderBeige),
            const SizedBox(height: 16),

            // Detail Status ON/OFF dan Konsumsi Daya dalam Watt
            Row(
              children: [
                // Info Status ON/OFF
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _isOn
                          ? AppTheme.activeDeviceBg
                          : AppTheme.surfaceWhite,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _isOn
                            ? AppTheme.accentOrange
                            : AppTheme.borderBeige,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Status Perangkat',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.mutedText,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              _isOn
                                  ? Icons.check_circle_rounded
                                  : Icons.cancel_rounded,
                              size: 16,
                              color: _isOn
                                  ? AppTheme.accentOrange
                                  : AppTheme.mutedText,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _isOn ? 'AKTIF (ON)' : 'MATI (OFF)',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: _isOn
                                    ? AppTheme.accentOrange
                                    : AppTheme.primaryText,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Info Konsumsi Daya (Watt)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceWhite,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.borderBeige),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Konsumsi Daya',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.mutedText,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.bolt_rounded,
                              size: 16,
                              color: AppTheme.accentOrange,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${widget.device.powerWatts.toInt()} Watt',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryText,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Deskripsi Singkat Perangkat
            const Text(
              'Deskripsi Perangkat & Efisiensi Energi',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryText,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.surfaceWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.borderBeige),
              ),
              child: Text(
                widget.device.description,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.primaryText,
                  height: 1.5,
                ),
              ),
            ),

            const SizedBox(height: 22),

            // Tombol untuk Menutup Modal Bottom Sheet
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(modalContext).pop();
                },
                icon: const Icon(Icons.close_rounded, size: 18),
                label: const Text('Tutup Informasi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnergySourceBadge(String source) {
    Color badgeColor;
    Color textColor;
    IconData icon;

    switch (source.toLowerCase()) {
      case 'solar':
        badgeColor = AppTheme.activeDeviceBg;
        textColor = AppTheme.darkOrange;
        icon = Icons.solar_power_rounded;
        break;
      case 'baterai':
        badgeColor = const Color(0xFFF3E8FF);
        textColor = const Color(0xFF7E22CE);
        icon = Icons.battery_charging_full_rounded;
        break;
      default:
        badgeColor = AppTheme.secondarySurface;
        textColor = AppTheme.mutedText;
        icon = Icons.power_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: textColor),
          const SizedBox(width: 3),
          Text(
            source,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
