import 'dart:math';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Halaman Energy Control / Analytics yang didesain ulang sesuai smartphone ketiga pada gambar referensi.
/// Menampilkan:
/// 1. Header dengan tombol navigasi, Judul "Energy Control", dan menu opsi.
/// 2. Main Analytics Card dengan semi-circular energy gauge (24.8 kWh, Total Energy Generated).
/// 3. Interactive Energy Distribution Card dengan gestur Drag/Pan (onPanStart, onPanUpdate)
///    yang memperbarui Home Energy & Battery Storage secara real-time (Total selalu 100%).
/// 4. System Insights List: Grid Usage, Battery Level, Solar Efficiency, Peak Consumption, Estimated Savings.
/// 5. Simulasi Siklus Waktu Harian dan Edukasi SDG 7.
class EnergyControlScreen extends StatefulWidget {
  final String activeTimePeriod;
  final ValueChanged<String> onTimePeriodChanged;
  final double batteryReserveLimit;
  final ValueChanged<double> onBatteryLimitChanged;

  const EnergyControlScreen({
    super.key,
    required this.activeTimePeriod,
    required this.onTimePeriodChanged,
    required this.batteryReserveLimit,
    required this.onBatteryLimitChanged,
  });

  @override
  State<EnergyControlScreen> createState() => _EnergyControlScreenState();
}

class _EnergyControlScreenState extends State<EnergyControlScreen> {
  // State persentase distribusi energi (Total selalu 100%)
  // Default: Home Energy 60%, Battery Storage 40%
  double _homeEnergyPercent = 60.0;
  double get _batteryStoragePercent => 100.0 - _homeEnergyPercent;

  bool _gridExportEnabled = true;
  bool _autoEcoMode = true;

  final List<Map<String, dynamic>> _timePresets = [
    {
      'label': 'Pagi (07:00)',
      'desc': 'Surya Mulai Naik (40%)',
      'icon': Icons.wb_twilight_rounded,
      'color': AppTheme.accentOrange,
    },
    {
      'label': 'Siang (12:00)',
      'desc': 'Puncak Surya (100%)',
      'icon': Icons.wb_sunny_rounded,
      'color': AppTheme.accentOrange,
    },
    {
      'label': 'Sore (16:30)',
      'desc': 'Angin & Surya Rendah (30%)',
      'icon': Icons.wb_cloudy_rounded,
      'color': const Color(0xFF0284C7),
    },
    {
      'label': 'Malam (20:00)',
      'desc': 'Baterai Rumah Mandiri (0%)',
      'icon': Icons.nightlight_round,
      'color': const Color(0xFF8B5CF6),
    },
  ];

  @override
  Widget build(BuildContext context) {
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
              // 1. Header (Back Control, Title "Energy Control", More Options)
              _buildHeader(),

              const SizedBox(height: 18),

              // 2. Main Analytics Card dengan Semi-Circular Energy Gauge
              _buildMainAnalyticsCard(),

              const SizedBox(height: 18),

              // 3. WIDGET CUSTOM GESTURE SLIDER: DISTRIBUSI ENERGI (Drag/Pan Gesture)
              _buildCustomEnergyDistributionSliderCard(),

              const SizedBox(height: 18),

              // 4. System Insights List Sesuai Referensi Gambar Kanan
              _buildSystemInsightsCard(),

              const SizedBox(height: 18),

              // 5. Simulasi Periode Waktu Harian
              _buildTimeSimulationCard(),

              const SizedBox(height: 18),

              // 6. Batas Cadangan Baterai (Preset Chips) & Sakelar Otomasi
              _buildSmartSwitchesCard(),

              const SizedBox(height: 18),

              // 7. Card Edukasi SDG 7
              _buildSdgEducationalCard(),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  /// 1. Header
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
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
        const Column(
          children: [
            Text(
              'Energy Control',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppTheme.primaryText,
                letterSpacing: -0.3,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Analytics & System Control',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppTheme.mutedText,
              ),
            ),
          ],
        ),
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

  /// 2. Main Analytics Card dengan Semi-Circular Energy Gauge Sesuai Referensi Gambar Kanan
  Widget _buildMainAnalyticsCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppTheme.borderBeige, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C252525),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Kartu Analytics: Smart Energy Overview & Dropdown Today
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Smart Energy Overview',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryText,
                  letterSpacing: -0.2,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.secondarySurface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Today',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryText,
                      ),
                    ),
                    SizedBox(width: 3),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 14,
                      color: AppTheme.primaryText,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Semi-Circular Energy Gauge Custom Painter
          Center(
            child: SizedBox(
              width: 240,
              height: 145,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size(240, 145),
                    painter: _SemiCircularGaugePainter(
                      progress: 0.78, // 78% dari kapasitas harian
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          '24.8 kWh',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.primaryText,
                            letterSpacing: -0.8,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Total Energy Generated',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.mutedText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 3. WIDGET CUSTOM ENERGY DISTRIBUTION SLIDER (DRAG/PAN GESTURE PRESERVATION)
  /// Menggunakan Stack, Positioned, Container, dan GestureDetector.
  /// Menerapkan onPanStart dan onPanUpdate untuk mendeteksi pergeseran horizontal.
  Widget _buildCustomEnergyDistributionSliderCard() {
    final homeInt = _homeEnergyPercent.round();
    final batteryInt = _batteryStoragePercent.round();

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
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Kartu
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.activeDeviceBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.tune_rounded,
                  color: AppTheme.accentOrange,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Distribusi Energi Cerdas',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryText,
                      ),
                    ),
                    Text(
                      'Custom Horizontal Pan Gesture',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.accentOrange,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.activeDeviceBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Total 100%',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.accentOrange,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Tampilan Real-Time Persentase Home Energy & Battery Storage
          Row(
            children: [
              // Home Energy
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.activeDeviceBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFFFD7B0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.home_rounded,
                            size: 15,
                            color: AppTheme.darkOrange,
                          ),
                          SizedBox(width: 5),
                          Text(
                            'Home Energy',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.mutedText,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$homeInt%',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.darkOrange,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Battery Storage
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.secondarySurface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.borderBeige),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.battery_charging_full_rounded,
                            size: 15,
                            color: AppTheme.primaryText,
                          ),
                          SizedBox(width: 5),
                          Text(
                            'Battery Storage',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.mutedText,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$batteryInt%',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primaryText,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Petunjuk Interaksi
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Beban Rumah ($homeInt%)',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.accentOrange,
                ),
              ),
              const Row(
                children: [
                  Icon(
                    Icons.swipe_rounded,
                    size: 13,
                    color: AppTheme.mutedText,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Geser thumb horizontal',
                    style: TextStyle(fontSize: 11, color: AppTheme.mutedText),
                  ),
                ],
              ),
              Text(
                'Baterai ($batteryInt%)',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryText,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // IMPLEMENTASI SLIDER DENGAN STACK, POSITIONED, CONTAINER, & GESTUREDETECTOR
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final double totalTrackWidth = constraints.maxWidth;
              const double thumbDiameter = 36.0;
              const double trackBarHeight = 24.0;
              final double maxThumbOffset = (totalTrackWidth - thumbDiameter)
                  .clamp(0.0, double.infinity);
              final double thumbLeft =
                  (_homeEnergyPercent / 100.0) * maxThumbOffset;

              void handleDrag(Offset localPosition) {
                if (maxThumbOffset <= 0) return;
                final double clampedDx =
                    (localPosition.dx - (thumbDiameter / 2)).clamp(
                      0.0,
                      maxThumbOffset,
                    );
                final double ratio = clampedDx / maxThumbOffset;

                setState(() {
                  _homeEnergyPercent = (ratio * 100.0).clamp(5.0, 95.0);
                });
              }

              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                // Menerapkan onPanStart saat pengguna mulai menyentuh slider
                onPanStart: (DragStartDetails details) {
                  handleDrag(details.localPosition);
                },
                // Menerapkan onPanUpdate saat pengguna menggeser jari secara horizontal
                onPanUpdate: (DragUpdateDetails details) {
                  handleDrag(details.localPosition);
                },
                child: Container(
                  height: 52,
                  color: Colors.transparent,
                  alignment: Alignment.center,
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.centerLeft,
                    children: [
                      // Track Bar Container
                      Container(
                        width: totalTrackWidth,
                        height: trackBarHeight,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            trackBarHeight / 2,
                          ),
                          color: AppTheme.secondarySurface,
                          border: Border.all(color: AppTheme.borderBeige),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Row(
                          children: [
                            // Porsi Home Energy (Orange)
                            Expanded(
                              flex: homeInt.clamp(1, 100),
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: AppTheme.accentOrange,
                                ),
                              ),
                            ),
                            // Porsi Battery Storage (Warm Beige Surface)
                            Expanded(
                              flex: batteryInt.clamp(1, 100),
                              child: Container(
                                color: AppTheme.secondarySurface,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Indikator Thumb yang Mengikuti Jari (Positioned + Container)
                      Positioned(
                        left: thumbLeft.clamp(0.0, maxThumbOffset),
                        child: Container(
                          width: thumbDiameter,
                          height: thumbDiameter,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            border: Border.all(
                              color: AppTheme.accentOrange,
                              width: 3.0,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x33252525),
                                blurRadius: 8,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.drag_indicator_rounded,
                              size: 18,
                              color: AppTheme.accentOrange,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// 4. System Insights List Sesuai Referensi Gambar Kanan
  Widget _buildSystemInsightsCard() {
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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header System Insights
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'System Insights',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryText,
                      letterSpacing: -0.2,
                    ),
                  ),
                  SizedBox(height: 1),
                  Text(
                    'Last synced 5 min ago',
                    style: TextStyle(fontSize: 11, color: AppTheme.mutedText),
                  ),
                ],
              ),
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppTheme.secondarySurface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.sync_rounded,
                  size: 18,
                  color: AppTheme.primaryText,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(height: 1, color: AppTheme.borderBeige),
          const SizedBox(height: 12),

          // 5 Insight Rows Sesuai Referensi Gambar
          _buildInsightRow(
            icon: Icons.bolt_rounded,
            iconColor: AppTheme.accentOrange,
            title: 'Grid Usage',
            subtitle: 'Import from Utility',
            value: '1.9 kWh',
          ),
          const Divider(height: 18, color: AppTheme.borderBeige),
          _buildInsightRow(
            icon: Icons.battery_charging_full_rounded,
            iconColor: const Color(0xFFF59E0B),
            title: 'Battery Level',
            subtitle: 'Charging mode',
            value: '96%',
          ),
          const Divider(height: 18, color: AppTheme.borderBeige),
          _buildInsightRow(
            icon: Icons.wb_sunny_rounded,
            iconColor: AppTheme.accentOrange,
            title: 'Solar Efficiency',
            subtitle: 'Panel Performance',
            value: '92%',
          ),
          const Divider(height: 18, color: AppTheme.borderBeige),
          _buildInsightRow(
            icon: Icons.bar_chart_rounded,
            iconColor: const Color(0xFFEA580C),
            title: 'Peak Consumption',
            subtitle: 'Highest Usage Today',
            value: '2.6 kW',
          ),
          const Divider(height: 18, color: AppTheme.borderBeige),
          _buildInsightRow(
            icon: Icons.account_balance_wallet_rounded,
            iconColor: AppTheme.accentOrange,
            title: 'Estimated Savings',
            subtitle: 'Today\'s Cost Reduction',
            value: '\$6.70',
          ),
        ],
      ),
    );
  }

  Widget _buildInsightRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: iconColor.withAlpha(31),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryText,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 11, color: AppTheme.mutedText),
              ),
            ],
          ),
        ),
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
    );
  }

  /// 5. Simulasi Periode Waktu Harian
  Widget _buildTimeSimulationCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.borderBeige, width: 1.2),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Simulasi Periode Waktu Harian',
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryText,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Respons output surya dan baterai berubah dinamis.',
            style: TextStyle(fontSize: 11, color: AppTheme.mutedText),
          ),
          const SizedBox(height: 14),
          Column(
            children: _timePresets.map((preset) {
              final isSelected = widget.activeTimePeriod.startsWith(
                (preset['label'] as String).split(' ').first,
              );
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () {
                    widget.onTimePeriodChanged(preset['label'] as String);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.activeDeviceBg
                          : AppTheme.secondarySurface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.accentOrange
                            : AppTheme.borderBeige,
                        width: isSelected ? 1.5 : 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          preset['icon'] as IconData,
                          size: 20,
                          color: preset['color'] as Color,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                preset['label'] as String,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isSelected
                                      ? FontWeight.w800
                                      : FontWeight.w600,
                                  color: isSelected
                                      ? AppTheme.accentOrange
                                      : AppTheme.primaryText,
                                ),
                              ),
                              Text(
                                preset['desc'] as String,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.mutedText,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          const Icon(
                            Icons.check_circle_rounded,
                            size: 18,
                            color: AppTheme.accentOrange,
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// 6. Sakelar Cerdas & Cadangan Baterai
  Widget _buildSmartSwitchesCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.borderBeige, width: 1.2),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Material(
        color: Colors.transparent,
        child: Column(
          children: [
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Ekspor Surplus ke Jaringan Listrik',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryText,
                ),
              ),
              subtitle: const Text(
                'Net-metering kredit listrik surya',
                style: TextStyle(fontSize: 11, color: AppTheme.mutedText),
              ),
              value: _gridExportEnabled,
              activeTrackColor: AppTheme.accentOrange.withAlpha(102),
              activeThumbColor: AppTheme.accentOrange,
              onChanged: (val) {
                setState(() {
                  _gridExportEnabled = val;
                });
              },
            ),
            const Divider(height: 1, color: AppTheme.borderBeige),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Otomasi Penghematan SDG 7',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryText,
                ),
              ),
              subtitle: const Text(
                'Optimasi beban perangkat otomatis',
                style: TextStyle(fontSize: 11, color: AppTheme.mutedText),
              ),
              value: _autoEcoMode,
              activeTrackColor: AppTheme.accentOrange.withAlpha(102),
              activeThumbColor: AppTheme.accentOrange,
              onChanged: (val) {
                setState(() {
                  _autoEcoMode = val;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 7. Edukasi SDG 7
  Widget _buildSdgEducationalCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.activeDeviceBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFD7B0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: AppTheme.accentOrange,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lightbulb_outline_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SDG 7: Affordable & Clean Energy',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryText,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Memaksimalkan pemanfaatan pembangkit lokal (surya dan baterai) menurunkan emisi karbon dan mempercepat transisi energi bersih terjangkau.',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.darkOrange,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// CustomPainter untuk Semi-Circular Energy Gauge Sesuai Referensi Desain
class _SemiCircularGaugePainter extends CustomPainter {
  final double progress; // 0.0 sampai 1.0

  _SemiCircularGaugePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2 - 14;
    const strokeWidth = 18.0;

    // 1. Busur Track Latar Belakang (Beige/Soft Grey)
    final trackPaint = Paint()
      ..color = AppTheme.secondarySurface
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(rect, pi, pi, false, trackPaint);

    // 2. Busur Progres Gradient Oranye ke Kuning
    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..shader = const SweepGradient(
        startAngle: pi,
        endAngle: 2 * pi,
        colors: [AppTheme.accentOrange, Color(0xFFFBBF24)],
      ).createShader(rect);

    canvas.drawArc(
      rect,
      pi,
      pi * progress.clamp(0.0, 1.0),
      false,
      progressPaint,
    );

    // 3. Thumb Cap Indikator Bulat di Ujung Busur
    final angle = pi + (pi * progress.clamp(0.0, 1.0));
    final thumbCenter = Offset(
      center.dx + radius * cos(angle),
      center.dy + radius * sin(angle),
    );

    // Bayangan thumb
    canvas.drawCircle(
      thumbCenter,
      strokeWidth / 1.6,
      Paint()..color = const Color(0x33252525),
    );

    // Thumb putih dengan border oranye
    canvas.drawCircle(
      thumbCenter,
      strokeWidth / 1.8,
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(
      thumbCenter,
      strokeWidth / 2.6,
      Paint()..color = AppTheme.accentOrange,
    );
  }

  @override
  bool shouldRepaint(covariant _SemiCircularGaugePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
