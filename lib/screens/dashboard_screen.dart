import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../models/device_model.dart';
import '../theme/app_theme.dart';
import '../widgets/energy_summary_card.dart';

/// Halaman Dashboard Utama EcoWatt (versi "seamless hero").
///
/// Foto rumah surya tidak lagi berupa kartu persegi panjang. Foto dilebur ke latar
/// beige hangat menggunakan alpha-mask (ShaderMask + BlendMode.dstIn) pada keempat
/// sisinya, lalu digabung dalam satu Stack dengan statistik energi dan chip informasi.
///
/// Struktur hero (satu Stack, urutan dari belakang ke depan):
///   1. Sun glow (RadialGradient hangat di sisi kanan)
///   2. Foto rumah surya yang di-mask (fade atas / bawah / kiri / kanan)
///   3. Statistik energi (Energy Produced + nilai + badge pertumbuhan)
///   4. Chip kaca: Sun Intensity, CO2 Saved, Savings
/// Kartu Energy Distribution ditempatkan tepat di bawah hero dan sedikit menimpa
/// bagian bawah foto yang sudah memudar.
class DashboardScreen extends StatefulWidget {
  final List<SmartDevice> devices;
  final ValueChanged<SmartDevice> onDeviceToggle;
  final String activeTimePeriod;
  final double solarMultiplier;

  const DashboardScreen({
    super.key,
    required this.devices,
    required this.onDeviceToggle,
    this.activeTimePeriod = 'Siang (12:00)',
    this.solarMultiplier = 1.0,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // ---------------------------------------------------------------------------
  // Konstanta layout hero (mudah di-tuning)
  // ---------------------------------------------------------------------------

  /// Rasio lebar : tinggi area foto. Foto asli 1200x896 (rasio 1.339). Dengan rasio
  /// 1.2 (lebih "tinggi" dari fotonya), BoxFit.cover memotong sedikit sisi kiri-kanan
  /// foto (tanpa distorsi) sehingga rumah tampil lebih besar, seperti referensi.
  static const double _heroImageAspect = 1.2;

  /// Posisi atas foto di dalam hero (di bawah blok teks energi). Bagian atas foto
  /// memudar, jadi sedikit tumpang tindih dengan teks tidak masalah.
  static const double _heroImageTop = 90;

  /// Berapa bagian tinggi foto yang dihitung sebagai tinggi hero. Sisanya (14%)
  /// meluap ke bawah dan berada di balik kartu Energy Distribution.
  static const double _heroImageVisibleFactor = 0.86;

  static const double _horizontalPadding = 20;

  @override
  Widget build(BuildContext context) {
    // Total daya dari perangkat aktif
    final activeDevices = widget.devices.where((d) => d.isOn).toList();
    final totalWatts = activeDevices.fold<double>(
      0.0,
      (sum, item) => sum + item.powerWatts,
    );
    final consumptionKw = totalWatts / 1000.0;

    // Nilai energi simulasi
    final double energyProducedKwh = 19.6 * widget.solarMultiplier;

    return Scaffold(
      backgroundColor: AppTheme.primaryBackground,
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              // Tidak ada padding horizontal di sini: hero harus full-width.
              // Padding horizontal diberikan per-bagian.
              padding: const EdgeInsets.only(top: 10, bottom: 110),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // A. Header
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: _horizontalPadding,
                    ),
                    child: _buildHeader(),
                  ),

                  const SizedBox(height: 14),

                  // B. Hero: statistik + foto seamless + glow + chip (satu Stack)
                  _buildHeroSection(width, energyProducedKwh),

                  // C. Energy Summary (menimpa tepi bawah foto yang memudar)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: _horizontalPadding,
                    ),
                    child: EnergySummaryCard(
                      solarProductionKw: energyProducedKwh,
                      consumptionKw: consumptionKw > 0 ? consumptionKw : 1.6,
                      batteryPercentage: 92,
                      cleanEnergyRatio: 0.94,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Baris Status Tambahan: SDG 7 & Active Device Quick Summary
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: _horizontalPadding,
                    ),
                    child: _buildSdgQuickStrip(activeDevices.length),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ===========================================================================
  // A. HEADER
  // ===========================================================================

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Avatar Profil & Teks Sapaan
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.secondarySurface,
                border: Border.all(color: AppTheme.borderBeige, width: 1.5),
              ),
              child: const Center(
                child: Icon(
                  Icons.person_rounded,
                  color: AppTheme.primaryText,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'EcoWatt',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primaryText,
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  'Hello, Rendy 👋 • Kelompok 16',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.mutedText,
                  ),
                ),
              ],
            ),
          ],
        ),

        // Shortcut Icon Energi & Notifikasi Bell dengan Badge
        Row(
          children: [
            _buildHeaderIconButton(
              icon: Icons.bolt_rounded,
              iconColor: AppTheme.primaryText,
              onTap: () {},
            ),
            const SizedBox(width: 10),
            Stack(
              clipBehavior: Clip.none,
              children: [
                _buildHeaderIconButton(
                  icon: Icons.notifications_none_rounded,
                  iconColor: AppTheme.primaryText,
                  onTap: () {},
                ),
                // Badge Notifikasi Merah
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEF4444),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeaderIconButton({
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Container(
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
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(icon, color: iconColor, size: 20),
        onPressed: onTap,
      ),
    );
  }

  // ===========================================================================
  // B. HERO (Stack: glow + foto ter-mask + statistik + chip)
  // ===========================================================================

  Widget _buildHeroSection(double width, double energyProducedKwh) {
    // Tinggi foto responsif terhadap lebar layar (dibatasi untuk tablet/web).
    final double imageHeight = math.min(width / _heroImageAspect, 460.0);
    final double heroHeight =
        _heroImageTop + imageHeight * _heroImageVisibleFactor;

    // Intensitas glow mengikuti simulasi waktu (malam = redup, siang = terang).
    final double glowStrength = widget.solarMultiplier
        .clamp(0.0, 1.0)
        .toDouble();
    final Color glow = AppTheme.sunGlow.withValues(
      alpha: 0.12 + 0.28 * glowStrength,
    );

    return SizedBox(
      width: width,
      height: heroHeight,
      child: Stack(
        // Foto sengaja boleh meluap ke bawah: bagian itu berada di balik kartu.
        clipBehavior: Clip.none,
        children: [
          // 1. Sun glow: radial gradient yang memudar penuh sebelum tepi hero,
          //    jadi tidak ada garis batas terlihat.
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0.9, 0.0),
                    radius: 0.48,
                    colors: [
                      glow,
                      glow.withValues(alpha: glow.a * 0.35),
                      glow.withValues(alpha: 0),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),
          ),

          // 2. Foto rumah surya dengan alpha-mask 4 sisi.
          Positioned(
            top: _heroImageTop,
            left: 0,
            right: 0,
            height: imageHeight,
            child: const IgnorePointer(child: _SeamlessHeroImage()),
          ),

          // 3. Statistik energi (di atas foto)
          Positioned(
            left: _horizontalPadding,
            top: 0,
            child: _buildEnergyStats(energyProducedKwh),
          ),

          // 4. Chip informasi mengambang (kanan)
          Positioned(
            right: 16,
            top: 30,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildGlassChip(
                  icon: Icons.wb_sunny_rounded,
                  iconColor: AppTheme.accentOrange,
                  title: 'Sun Intensity',
                  value: '6.8',
                  badge: 'High',
                ),
                const SizedBox(height: 8),
                _buildGlassChip(
                  icon: Icons.eco_rounded,
                  iconColor: AppTheme.greenEco,
                  title: 'CO2 Saved',
                  value: '6.8',
                  badge: 'High',
                ),
                const SizedBox(height: 8),
                _buildGlassChip(
                  icon: Icons.account_balance_wallet_rounded,
                  iconColor: AppTheme.darkOrange,
                  title: 'Savings',
                  value: '\$25.00',
                  badge: null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Label + nilai energi + badge pertumbuhan (sesuai referensi).
  Widget _buildEnergyStats(double energyProducedKwh) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Energy Produced',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppTheme.mutedText,
            letterSpacing: -0.1,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '${energyProducedKwh.toStringAsFixed(1)} kWh',
          style: const TextStyle(
            fontSize: 38,
            fontWeight: FontWeight.w800,
            color: AppTheme.primaryText,
            letterSpacing: -1.0,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 4),
        const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.arrow_upward_rounded,
              size: 14,
              color: AppTheme.darkOrange,
            ),
            SizedBox(width: 3),
            Text(
              '+14% vs last month',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.darkOrange,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Chip informasi bergaya frosted-glass (blur + putih translucent).
  Widget _buildGlassChip({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    String? badge,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: 128,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.glassFill,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppTheme.glassBorder, width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppTheme.secondarySurface.withValues(alpha: 0.7),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 15),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.mutedText,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            value,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.primaryText,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),
                        if (badge != null) ...[
                          const SizedBox(width: 4),
                          Text(
                            badge,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.accentOrange,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // Banner Ringkasan Cepat SDG 7
  // ===========================================================================

  Widget _buildSdgQuickStrip(int activeCount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.secondarySurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.borderBeige),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.accentOrange,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'SDG 7',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Clean & Affordable Energy',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryText,
                  ),
                ),
                Text(
                  '$activeCount perangkat aktif • Sistem beroperasi mandiri',
                  style: const TextStyle(
                    fontSize: 10.5,
                    color: AppTheme.mutedText,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.check_circle_rounded,
            color: AppTheme.accentOrange,
            size: 18,
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// SEAMLESS HERO IMAGE
// =============================================================================

/// Foto rumah surya yang tepinya dilebur ke latar lewat ALPHA MASK.
///
/// Teknik: dua [ShaderMask] bertingkat dengan [BlendMode.dstIn].
///  - `dstIn` menyimpan piksel foto (destination) dengan alpha = alpha dari shader.
///    Shader hitam-transparan -> hitam-opaque -> hitam-transparan berarti foto
///    transparan di tepi, opaque di tengah. Warna hitam shader tidak pernah terlihat;
///    hanya kanal alpha-nya yang dipakai.
///  - Mask vertikal (atas/bawah) dan mask horizontal (kiri/kanan) di-nest; alpha
///    akhir = alpha_vertikal x alpha_horizontal, sehingga keempat sisi memudar.
///  - Gradient memakai kurva smoothstep (bukan linear) agar tidak ada "garis" Mach band
///    di titik awal fade.
class _SeamlessHeroImage extends StatelessWidget {
  const _SeamlessHeroImage();

  // Proporsi lebar/tinggi area yang dipakai untuk memudar di tiap sisi.
  static const double _fadeLeft = 0.07;
  static const double _fadeRight = 0.10;
  static const double _fadeTop = 0.22;
  static const double _fadeBottom = 0.26;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: (bounds) => _softFadeGradient(
        axis: Axis.horizontal,
        fadeStart: _fadeLeft,
        fadeEnd: _fadeRight,
      ).createShader(bounds),
      child: ShaderMask(
        blendMode: BlendMode.dstIn,
        shaderCallback: (bounds) => _softFadeGradient(
          axis: Axis.vertical,
          fadeStart: _fadeTop,
          fadeEnd: _fadeBottom,
        ).createShader(bounds),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // BoxFit.cover: mengisi area tanpa distorsi (hanya memotong tepi).
            Image.asset(
              'assets/images/solar_house.jpg',
              fit: BoxFit.cover,
              alignment: Alignment.center,
              filterQuality: FilterQuality.high,
              errorBuilder: (context, error, stackTrace) => const Center(
                child: Icon(
                  Icons.solar_power_rounded,
                  size: 80,
                  color: AppTheme.accentOrange,
                ),
              ),
            ),
            // Tint peach tipis: menyelaraskan warna foto dengan latar beige.
            // Berada DI DALAM mask, jadi ikut memudar bersama foto.
            IgnorePointer(
              child: ColoredBox(
                color: AppTheme.heroPeach.withValues(alpha: 0.14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Membuat gradient alpha "transparan -> opaque -> transparan" sepanjang satu sumbu.
///
/// [fadeStart] / [fadeEnd] adalah fraksi (0..1) panjang sumbu untuk fade-in di awal
/// dan fade-out di akhir. Nilai di antaranya 100% opaque. Syarat:
/// fadeStart + fadeEnd <= 1.
///
/// Kurva smoothstep (3t^2 - 2t^3) dipakai agar transisi mulus di kedua ujungnya.
LinearGradient _softFadeGradient({
  required Axis axis,
  required double fadeStart,
  required double fadeEnd,
  int steps = 10,
}) {
  assert(fadeStart + fadeEnd <= 1.0);

  final colors = <Color>[];
  final stops = <double>[];

  double smoothstep(double t) => t * t * (3 - 2 * t);

  // Fade-in: alpha 0 -> 1 pada [0, fadeStart]
  for (var i = 0; i <= steps; i++) {
    final t = i / steps;
    stops.add(fadeStart * t);
    colors.add(Colors.black.withValues(alpha: smoothstep(t)));
  }

  // Fade-out: alpha 1 -> 0 pada [1 - fadeEnd, 1]
  for (var i = 0; i <= steps; i++) {
    final t = i / steps;
    stops.add((1 - fadeEnd) + fadeEnd * t);
    colors.add(Colors.black.withValues(alpha: 1 - smoothstep(t)));
  }

  return LinearGradient(
    begin: axis == Axis.vertical ? Alignment.topCenter : Alignment.centerLeft,
    end: axis == Axis.vertical ? Alignment.bottomCenter : Alignment.centerRight,
    colors: colors,
    stops: stops,
  );
}
