import 'package:flutter/material.dart';

import '../models/device_model.dart';
import '../theme/app_theme.dart';
import '../widgets/device_card.dart';

/// Halaman Smart Devices yang didesain ulang terinspirasi smartphone kedua pada gambar referensi.
/// Menampilkan:
/// - Header dengan kontrol navigasi kembali, Judul "Smart Devices", Subtitle "Manage Your Home Energy".
/// - Energy Consumption Summary Card (Energy produced today & Current active load).
/// - Banner visual solar panel hero.
/// - Filter ruangan & 4 Perangkat pintar wajib tugas:
///   1. Smart LED Light (15 W)
///   2. Smart Fan (75 W)
///   3. Smart TV (100 W)
///   4. Inverter AC (900 W)
/// - Menjaga penuh gesture onTap (toggle) dan onLongPress (bottom sheet).
class DevicesScreen extends StatefulWidget {
  final List<SmartDevice> devices;
  final ValueChanged<SmartDevice> onDeviceToggle;
  final VoidCallback onTurnOffAllNonEssential;

  const DevicesScreen({
    super.key,
    required this.devices,
    required this.onDeviceToggle,
    required this.onTurnOffAllNonEssential,
  });

  @override
  State<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen> {
  String _selectedRoom = 'Semua';

  final List<String> _rooms = [
    'Semua',
    'Ruang Tamu',
    'Dapur',
    'Kamar Tidur',
    'Luar Rumah',
  ];

  @override
  Widget build(BuildContext context) {
    // Filter perangkat berdasarkan ruangan yang dipilih
    final filteredDevices = _selectedRoom == 'Semua'
        ? widget.devices
        : widget.devices.where((d) => d.room == _selectedRoom).toList();

    final activeCount = widget.devices.where((d) => d.isOn).length;
    final totalWatts = widget.devices
        .where((d) => d.isOn)
        .fold<double>(0.0, (sum, d) => sum + d.powerWatts);

    return Scaffold(
      backgroundColor: AppTheme.primaryBackground,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Sesuai Referensi Gambar (Back Control, Title, Subtitle, Menu)
              _buildHeader(),

              const SizedBox(height: 18),

              // Hero Panel Surya & Status Ringkas
              _buildSolarHeroBanner(),

              const SizedBox(height: 18),

              // Elegant Energy Consumption Summary Cards (2 Kolom berdampingan)
              _buildSummaryCards(activeCount, totalWatts),

              const SizedBox(height: 18),

              // Filter Ruangan (Chips Elegan)
              _buildRoomFilterChips(),

              const SizedBox(height: 16),

              // Baris Kontrol Cepat & Judul Daftar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Connected Devices (${filteredDevices.length})',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryText,
                      letterSpacing: -0.2,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      widget.onTurnOffAllNonEssential();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Mode Hemat: Mematikan perangkat non-esensial',
                          ),
                          duration: Duration(seconds: 2),
                          backgroundColor: AppTheme.accentOrange,
                        ),
                      );
                    },
                    icon: const Icon(Icons.eco_rounded, size: 15),
                    label: const Text('Eco Mode'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.accentOrange,
                      textStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Banner Panduan Gestur
              _buildGestureGuideBanner(),

              const SizedBox(height: 10),

              // Daftar Kartu Perangkat dengan Animasi dan Gestur
              if (filteredDevices.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceWhite,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.borderBeige),
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.devices_other_rounded,
                          size: 40,
                          color: AppTheme.lightMuted,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tidak ada perangkat di ruangan $_selectedRoom.',
                          style: const TextStyle(color: AppTheme.mutedText),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...filteredDevices.map(
                  (device) => DeviceCard(
                    device: device,
                    onToggle: (newValue) {
                      widget.onDeviceToggle(device);
                    },
                  ),
                ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  /// Header Sesuai Referensi Gambar Tengah
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Tombol Back/Navigasi
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppTheme.surfaceWhite,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.borderBeige, width: 1.2),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A252525),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 16,
              color: AppTheme.primaryText,
            ),
          ),
        ),

        // Judul & Subtitle
        const Column(
          children: [
            Text(
              'Smart Devices',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppTheme.primaryText,
                letterSpacing: -0.3,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Manage Your Home Energy',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppTheme.mutedText,
              ),
            ),
          ],
        ),

        // Menu 3-dots
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppTheme.surfaceWhite,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.borderBeige, width: 1.2),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A252525),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.more_vert_rounded,
              size: 18,
              color: AppTheme.primaryText,
            ),
          ),
        ),
      ],
    );
  }

  /// Hero Solar Panel Banner Terinspirasi HP Tengah
  Widget _buildSolarHeroBanner() {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.borderBeige, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10252525),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/solar_panel.jpg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: AppTheme.secondarySurface,
                  child: const Center(
                    child: Icon(
                      Icons.solar_power_rounded,
                      size: 50,
                      color: AppTheme.accentOrange,
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withAlpha(140), Colors.transparent],
                ),
              ),
            ),
          ),
          Positioned(
            left: 16,
            bottom: 14,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.accentOrange,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Micro-Grid Array #16',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Solar P-1345 Smart Hub',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Dua Kartu Ringkasan Konsumsi Energi Sesuai Gambar HP Tengah
  Widget _buildSummaryCards(int activeCount, double totalWatts) {
    return Row(
      children: [
        // Kartu 1: Energy Produced Today
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceWhite,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.borderBeige, width: 1.2),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0A252525),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppTheme.activeDeviceBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.wb_sunny_rounded,
                    color: AppTheme.accentOrange,
                    size: 18,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  '19.6 kWh',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primaryText,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Energy produced today',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.mutedText,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 14),

        // Kartu 2: Current Active Load
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceWhite,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.borderBeige, width: 1.2),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0A252525),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.bolt_rounded,
                    color: Color(0xFF2563EB),
                    size: 18,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${totalWatts.toInt()} W',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primaryText,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$activeCount device${activeCount != 1 ? 's' : ''} active now',
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.mutedText,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Filter Chips untuk Ruangan
  Widget _buildRoomFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: _rooms.map((room) {
          final isSelected = _selectedRoom == room;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(room),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedRoom = room;
                  });
                }
              },
              selectedColor: AppTheme.accentOrange,
              backgroundColor: AppTheme.surfaceWhite,
              labelStyle: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : AppTheme.primaryText,
              ),
              side: BorderSide(
                color: isSelected
                    ? AppTheme.accentOrange
                    : AppTheme.borderBeige,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Banner Petunjuk Interaksi Gesture (Tap & Long Press)
  Widget _buildGestureGuideBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.activeDeviceBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFD7B0)),
      ),
      child: const Row(
        children: [
          Icon(Icons.touch_app_rounded, color: AppTheme.accentOrange, size: 18),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              '• Tap kartu: Toggle ON/OFF dengan animasi visual\n• Tahan (Long Press): Informasi detail perangkat',
              style: TextStyle(
                fontSize: 10.5,
                color: AppTheme.darkOrange,
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
