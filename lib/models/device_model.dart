import 'package:flutter/material.dart';

/// Model data perangkat listrik pintar untuk simulasi EcoWatt.
class SmartDevice {
  final String id;
  final String name;
  final String room;
  final double powerWatts;
  final bool isOn;
  final IconData activeIcon;
  final IconData inactiveIcon;
  final String energySource; // 'Solar', 'Baterai', 'PLN Eco'
  final bool isEcoMode;
  final double dailyUsageKwh;
  final String description;

  const SmartDevice({
    required this.id,
    required this.name,
    required this.room,
    required this.powerWatts,
    required this.isOn,
    required this.activeIcon,
    required this.inactiveIcon,
    this.energySource = 'Solar',
    this.isEcoMode = true,
    this.dailyUsageKwh = 1.2,
    this.description = 'Perangkat rumah pintar ramah lingkungan yang mendukung efisiensi energi SDG 7.',
  });

  /// Getter kompatibilitas untuk icon aktif
  IconData get icon => isOn ? activeIcon : inactiveIcon;

  SmartDevice copyWith({
    String? id,
    String? name,
    String? room,
    double? powerWatts,
    bool? isOn,
    IconData? activeIcon,
    IconData? inactiveIcon,
    String? energySource,
    bool? isEcoMode,
    double? dailyUsageKwh,
    String? description,
  }) {
    return SmartDevice(
      id: id ?? this.id,
      name: name ?? this.name,
      room: room ?? this.room,
      powerWatts: powerWatts ?? this.powerWatts,
      isOn: isOn ?? this.isOn,
      activeIcon: activeIcon ?? this.activeIcon,
      inactiveIcon: inactiveIcon ?? this.inactiveIcon,
      energySource: energySource ?? this.energySource,
      isEcoMode: isEcoMode ?? this.isEcoMode,
      dailyUsageKwh: dailyUsageKwh ?? this.dailyUsageKwh,
      description: description ?? this.description,
    );
  }

  /// Data simulasi awal perangkat rumah pintar ramah lingkungan (SDG 7)
  /// Menyediakan 4 perangkat wajib tugas: Lampu (15W), Kipas Angin (75W), Televisi (100W), AC (900W).
  static List<SmartDevice> get initialDevices => [
    const SmartDevice(
      id: 'dev-lampu',
      name: 'Lampu Pintar LED',
      room: 'Ruang Tamu',
      powerWatts: 15.0,
      isOn: true,
      activeIcon: Icons.lightbulb_rounded,
      inactiveIcon: Icons.lightbulb_outline_rounded,
      energySource: 'Solar',
      isEcoMode: true,
      dailyUsageKwh: 0.18,
      description: 'Lampu LED cerdas dengan sensor gerak dan intensitas cahaya adaptif. Menggunakan sumber daya tenaga surya dengan efisiensi tinggi.',
    ),
    const SmartDevice(
      id: 'dev-kipas',
      name: 'Kipas Angin Cerdas',
      room: 'Kamar Tidur',
      powerWatts: 75.0,
      isOn: false,
      activeIcon: Icons.air_rounded,
      inactiveIcon: Icons.wind_power_outlined,
      energySource: 'Baterai',
      isEcoMode: true,
      dailyUsageKwh: 0.60,
      description: 'Kipas angin DC brushless berkecepatan dinamis dengan sirkulasi udara optimal dan motor hemat daya baterai cadangan.',
    ),
    const SmartDevice(
      id: 'dev-tv',
      name: 'Televisi Smart 4K',
      room: 'Ruang Tamu',
      powerWatts: 100.0,
      isOn: true,
      activeIcon: Icons.tv_rounded,
      inactiveIcon: Icons.tv_off_rounded,
      energySource: 'Baterai',
      isEcoMode: true,
      dailyUsageKwh: 0.85,
      description: 'Smart TV dengan layar OLED hemat energi dan teknologi auto-dimming untuk meminimalkan beban listrik rumah.',
    ),
    const SmartDevice(
      id: 'dev-ac',
      name: 'Air Conditioner Inverter',
      room: 'Ruang Tamu',
      powerWatts: 900.0,
      isOn: true,
      activeIcon: Icons.ac_unit_rounded,
      inactiveIcon: Icons.ac_unit_outlined,
      energySource: 'Solar',
      isEcoMode: true,
      dailyUsageKwh: 4.80,
      description: 'AC hemat energi dengan teknologi inverter ganda cerdas yang menyesuaikan beban kompresor secara presisi sesuai suhu ruangan.',
    ),
    const SmartDevice(
      id: 'dev-kulkas',
      name: 'Kulkas Inverter Eco',
      room: 'Dapur',
      powerWatts: 95.0,
      isOn: true,
      activeIcon: Icons.kitchen_rounded,
      inactiveIcon: Icons.kitchen_outlined,
      energySource: 'Baterai',
      isEcoMode: true,
      dailyUsageKwh: 1.80,
      description: 'Kulkas ramah lingkungan dengan sistem insulasi vakum canggih yang beroperasi nonstop dengan suplai baterai rumah.',
    ),
    const SmartDevice(
      id: 'dev-pompa',
      name: 'Pompa Air Surya',
      room: 'Luar Rumah',
      powerWatts: 250.0,
      isOn: false,
      activeIcon: Icons.water_drop_rounded,
      inactiveIcon: Icons.water_drop_outlined,
      energySource: 'Solar',
      isEcoMode: true,
      dailyUsageKwh: 1.25,
      description: 'Pompa air submersible otomatis terhubung langsung ke panel surya fotovoltaik untuk kebutuhan irigasi dan suplai tandon.',
    ),
  ];
}
