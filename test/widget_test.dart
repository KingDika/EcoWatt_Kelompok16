import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecowatt/main.dart';

void main() {
  testWidgets('EcoWatt App smoke test and navigation verification', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const EcoWattApp());
    await tester.pumpAndSettle();

    // Verifikasi branding EcoWatt dan SDG 7
    expect(find.text('EcoWatt'), findsOneWidget);
    expect(find.text('SDG 7'), findsAtLeastNWidgets(1));

    // Verifikasi label navigasi utama
    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Smart Devices'), findsOneWidget);
    expect(find.text('Energy Control'), findsOneWidget);
  });

  testWidgets(
    'Gesture 1 & 2: Tap toggles ON/OFF, Long Press shows Modal Bottom Sheet without toggling',
    (WidgetTester tester) async {
      await tester.pumpWidget(const EcoWattApp());
      await tester.pumpAndSettle();

      // Pindah ke tab Smart Devices
      await tester.tap(find.text('Smart Devices'));
      await tester.pumpAndSettle();

      // Verifikasi 4 perangkat wajib tugas kuliah:
      // 1. Lampu (15 Watt), 2. Kipas Angin (75 Watt), 3. Televisi (100 Watt), 4. AC (900 Watt)
      expect(find.text('Lampu Pintar LED'), findsOneWidget);
      expect(find.text('Kipas Angin Cerdas'), findsOneWidget);
      expect(find.text('Televisi Smart 4K'), findsOneWidget);
      expect(find.text('Air Conditioner Inverter'), findsOneWidget);

      // GESTURE 1: Tap Gesture pada Lampu Pintar LED (Status awal: 15 W aktif)
      await tester.ensureVisible(find.text('Lampu Pintar LED'));
      await tester.pumpAndSettle();
      expect(find.text('15 W aktif'), findsOneWidget);

      // Ketuk kartu Lampu Pintar LED untuk mematikan (OFF)
      await tester.tap(find.text('Lampu Pintar LED'));
      await tester.pumpAndSettle();

      // Verifikasi status berubah menjadi Standby 0 W (15 W)
      expect(find.text('Standby 0 W (15 W)'), findsOneWidget);

      // Ketuk kartu kembali untuk menyalakan (ON)
      await tester.tap(find.text('Lampu Pintar LED'));
      await tester.pumpAndSettle();
      expect(find.text('15 W aktif'), findsOneWidget);

      // GESTURE 2: Long Press Gesture pada Lampu Pintar LED
      await tester.longPress(find.text('Lampu Pintar LED'));
      await tester.pumpAndSettle();

      // Modal bottom sheet harus muncul menampilkan:
      // - Nama perangkat: Lampu Pintar LED
      // - Konsumsi daya: 15 Watt
      // - Status ON/OFF: AKTIF (ON)
      // - Deskripsi singkat
      // - Tombol Tutup Informasi
      expect(find.text('15 Watt'), findsOneWidget);
      expect(find.text('AKTIF (ON)'), findsOneWidget);
      expect(find.text('Tutup Informasi'), findsOneWidget);

      // Pastikan Long Press TIDAK mengubah status ON/OFF
      expect(find.text('15 W aktif'), findsOneWidget);

      // Tutup modal menggunakan tombol tutup
      await tester.tap(find.text('Tutup Informasi'));
      await tester.pumpAndSettle();

      // Modal tertutup, kartu tetap pada statusnya
      expect(find.text('Tutup Informasi'), findsNothing);
      expect(find.text('15 W aktif'), findsOneWidget);
    },
  );

  testWidgets(
    'Gesture 3: Custom Pan/Drag Gesture updates energy distribution dynamically',
    (WidgetTester tester) async {
      await tester.pumpWidget(const EcoWattApp());
      await tester.pumpAndSettle();

      // Pindah ke tab Energy Control
      await tester.tap(find.text('Energy Control'));
      await tester.pumpAndSettle();

      // Verifikasi komponen Custom Gesture Slider
      expect(find.text('Distribusi Energi Cerdas'), findsOneWidget);
      expect(find.text('Total 100%'), findsOneWidget);
      expect(find.text('Home Energy'), findsOneWidget);
      expect(find.text('Battery Storage'), findsOneWidget);

      // Nilai awal: Home Energy 60%
      expect(find.text('60%'), findsOneWidget);

      // Cari indikator thumb gesture
      final gestureFinder = find.byIcon(Icons.drag_indicator_rounded);
      expect(gestureFinder, findsOneWidget);
      await tester.ensureVisible(gestureFinder);
      await tester.pumpAndSettle();

      // Geser thumb secara horizontal ke kanan
      await tester.drag(gestureFinder, const Offset(60.0, 0.0));
      await tester.pumpAndSettle();

      // Total distribusi harus tetap 100%
      expect(find.text('Total 100%'), findsOneWidget);
    },
  );
}
