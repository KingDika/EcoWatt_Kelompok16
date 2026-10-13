# ecowatt

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

# EcoWatt – Interactive Renewable Energy Dashboard

**EcoWatt** adalah aplikasi interaktif berbasis Flutter untuk menyimulasikan pemantauan energi terbarukan, pengendalian perangkat listrik rumah, dan pengaturan distribusi energi antara kebutuhan rumah dan penyimpanan baterai. Proyek ini mengangkat tema **Sustainable Development Goals (SDG) 7: Affordable and Clean Energy (Energi Bersih dan Terjangkau)**.

> **Catatan:** Data energi, daya, emisi, dan penghematan pada aplikasi merupakan data simulasi untuk pembelajaran, bukan hasil pengukuran perangkat IoT atau panel surya nyata.

## Identitas Kelompok

**Kelompok 16**

| Nama | NIM | Peran |
| --- | --- | --- |
| Rendy Pradika Abiyoga | 202431111 | Ketua Kelompok |
| Sony Abdullah Maulidan Tuasikal | 202431054 | Anggota |

## Fitur Aplikasi

- **Dashboard:** menampilkan ringkasan energi surya dan informasi pemantauan energi dalam antarmuka visual.
- **Smart Devices:** menampilkan perangkat listrik yang dapat diaktifkan atau dinonaktifkan secara interaktif, disertai informasi konsumsi daya.
- **Energy Control:** menyediakan simulasi pengaturan distribusi energi untuk kebutuhan rumah dan penyimpanan baterai.
- **Navigasi:** berpindah di antara halaman Dashboard, Smart Devices, dan Energy Control.

## Implementasi Gesture Flutter

Sesuai ketentuan NIM ketua kelompok yang berakhiran ganjil, aplikasi menerapkan tiga gesture berikut:

| Gesture | Lokasi | Interaksi dan perubahan visual |
| --- | --- | --- |
| **Tap** (`onTap`) | Smart Devices | Mengetuk kartu perangkat untuk mengubah status ON/OFF; tampilan kartu dan indikator daya ikut berubah. |
| **Long Press** (`onLongPress`) | Smart Devices | Menekan lama kartu perangkat untuk menampilkan panel informasi detail tanpa mengubah status ON/OFF. |
| **Drag/Pan** (`onPanStart`, `onPanUpdate`) | Energy Control | Menggeser pengatur distribusi energi; persentase Home dan Battery diperbarui secara interaktif dengan total 100%. |

Interaksi menggunakan `GestureDetector`, sedangkan perubahan state lokal dikelola dengan `StatefulWidget` dan `setState`.

## Teknologi

- Flutter dan Dart
- Material Design
- Widget `Stack`, `Row`, `Column`, `Card`, dan `GestureDetector`
- `StatefulWidget` dan `setState` untuk pengelolaan state lokal

## Struktur Proyek

```text
lib/
├── main.dart
├── models/
│   └── device_model.dart
├── screens/
│   ├── dashboard_screen.dart
│   ├── devices_screen.dart
│   └── energy_control_screen.dart
├── theme/
│   └── app_theme.dart
└── widgets/
    ├── device_card.dart
    ├── energy_distribution.dart
    ├── energy_summary_card.dart
    └── floating_bottom_nav.dart
```

## Cara Menjalankan

Pastikan Flutter SDK telah terpasang dan perangkat atau browser tujuan tersedia. Buka terminal pada folder proyek yang berisi `pubspec.yaml`, kemudian jalankan:

```bash
flutter pub get
flutter run -d chrome
```

Untuk melihat perangkat yang tersedia:

```bash
flutter devices
```

Untuk pemeriksaan kode dan pengujian:

```bash
flutter analyze
flutter test
```

## Dokumentasi Gesture

Bukti interaksi aplikasi berupa enam screenshot sebelum dan sesudah Tap, Long Press, serta Drag/Pan disertakan dalam laporan tugas `Tugas4_Kelompok16.pdf`.

## Repository

https://github.com/KingDika/EcoWatt_Kelompok16

Riwayat kontribusi anggota dapat diperiksa melalui tab **Commits** pada repository setelah masing-masing anggota melakukan commit asli.

---

Dibuat untuk tugas **Interactive Mobile UI dengan Flutter Gestures** – Kelompok 16.
