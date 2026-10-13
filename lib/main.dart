import 'package:flutter/material.dart';

import 'models/device_model.dart';
import 'screens/dashboard_screen.dart';
import 'screens/devices_screen.dart';
import 'screens/energy_control_screen.dart';
import 'theme/app_theme.dart';
import 'widgets/floating_bottom_nav.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const EcoWattApp());
}

/// Root widget aplikasi EcoWatt - Interactive Renewable Energy Dashboard
class EcoWattApp extends StatelessWidget {
  const EcoWattApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EcoWatt – Renewable Energy',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const MainNavigationScreen(),
    );
  }
}

/// Layar utama yang mengatur navigasi floating pill antar tiga halaman utama:
/// 1. Dashboard
/// 2. Smart Devices
/// 3. Energy Control
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  // State simulasi lokal terpusat menggunakan StatefulWidget & setState
  List<SmartDevice> _devices = SmartDevice.initialDevices;
  String _activeTimePeriod = 'Siang (12:00)';
  double _batteryReserveLimit = 25.0;

  /// Pengali produksi surya berdasarkan simulasi waktu harian
  double get _solarMultiplier {
    if (_activeTimePeriod.startsWith('Pagi')) return 0.55;
    if (_activeTimePeriod.startsWith('Siang')) return 1.0;
    if (_activeTimePeriod.startsWith('Sore')) return 0.35;
    return 0.05; // Malam hari (hampir 0 surya)
  }

  /// Toggle on/off untuk perangkat tertentu dengan setState (Tap Gesture)
  void _toggleDevice(SmartDevice targetDevice) {
    setState(() {
      _devices = _devices.map((device) {
        if (device.id == targetDevice.id) {
          return device.copyWith(isOn: !device.isOn);
        }
        return device;
      }).toList();
    });
  }

  /// Mematikan semua perangkat non-esensial (Fitur Mode Hemat Cepat)
  void _turnOffNonEssential() {
    setState(() {
      _devices = _devices.map((device) {
        if (device.id == 'dev-kulkas') return device;
        return device.copyWith(isOn: false);
      }).toList();
    });
  }

  /// Mengubah periode simulasi waktu harian
  void _updateTimePeriod(String newPeriod) {
    setState(() {
      _activeTimePeriod = newPeriod;
    });
  }

  /// Mengubah batas cadangan baterai rumah
  void _updateBatteryLimit(double newLimit) {
    setState(() {
      _batteryReserveLimit = newLimit;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      DashboardScreen(
        devices: _devices,
        onDeviceToggle: _toggleDevice,
        activeTimePeriod: _activeTimePeriod,
        solarMultiplier: _solarMultiplier,
      ),
      DevicesScreen(
        devices: _devices,
        onDeviceToggle: _toggleDevice,
        onTurnOffAllNonEssential: _turnOffNonEssential,
      ),
      EnergyControlScreen(
        activeTimePeriod: _activeTimePeriod,
        onTimePeriodChanged: _updateTimePeriod,
        batteryReserveLimit: _batteryReserveLimit,
        onBatteryLimitChanged: _updateBatteryLimit,
      ),
    ];

    return Scaffold(
      backgroundColor: AppTheme.primaryBackground,
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: FloatingBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
