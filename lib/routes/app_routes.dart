import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/services/location_service.dart';
import '../features/aktivitas/view/cari_rekan_screen.dart';
import '../features/aktivitas/viewmodel/aktivitas_viewmodel.dart';
import '../features/lapangan/view/home_screen.dart';
import '../features/lapangan/view/map_screen.dart';
import '../features/lapangan/viewmodel/map_viewmodel.dart';
import '../features/profil/view/profil_screen.dart';
import '../repositories/aktivitas_repository.dart';
import '../repositories/lapangan_repository.dart';

/// Daftar rute aplikasi — PRD Bagian 8 (L-01 sampai L-15).
///
/// Diisi bertahap seiring tugas di SPRINT-PLAN selesai. Nama rute
/// dikumpulkan di sini supaya tidak ada string rute yang ditulis
/// langsung di dalam widget.
class AppRoutes {
  AppRoutes._();

  static const splash = '/'; // L-01 · T-08
  static const login = '/login'; // L-02 · T-07
  static const register = '/register'; // L-03 · T-07
  static const shell = '/shell'; // Navigasi 4 tab · T-08

  static const detailLapangan = '/lapangan/detail'; // L-06 · T-13
  static const buatAktivitas = '/aktivitas/buat'; // L-08 · T-18
  static const detailAktivitas = '/aktivitas/detail'; // L-09 · T-19
  static const ajukanReservasi = '/booking/ajukan'; // L-10 · T-24
  static const notifikasi = '/notifikasi'; // L-12 · T-15
  static const dashboardMitra = '/mitra'; // L-14 · T-25
  static const formLapangan = '/mitra/lapangan/form'; // L-15 · T-26

  /// Rute tersembunyi untuk seeding data (PRD Bagian 10).
  /// NONAKTIFKAN setelah dijalankan sekali.
  static const adminSeed = '/admin/seed'; // T-10

  // Catatan T-08: navigasi antar layar di app ini dilakukan langsung lewat
  // Navigator.push(MaterialPageRoute(...)) di tiap View, BUKAN lewat
  // named routes/`rute` di bawah. Konstanta rute di atas tetap dijaga
  // sebagai daftar nama layar yang konsisten dan dokumentasi, dipakai
  // kalau nanti butuh dialihkan ke named routes.
  static Map<String, WidgetBuilder> get rute => {
        splash: (_) => const HomeScreen(),
      };
}

/// Kerangka navigasi 4 tab — PRD v1.1 Bagian 8.
class ShellNavigasi extends StatefulWidget {
  const ShellNavigasi({super.key});

  @override
  State<ShellNavigasi> createState() => _ShellNavigasiState();
}

class _ShellNavigasiState extends State<ShellNavigasi> {
  int _indeks = 0;

  @override
  Widget build(BuildContext context) {
    // Dibangun ulang tiap build(), TAPI aman: Provider hanya menjalankan
    // `create` sekali per elemen di tree (posisi/tipe widget-nya stabil
    // di dalam IndexedStack), jadi MapViewModel tidak dibuat berkali-kali
    // tiap kali tab dipindah. Beda dengan HomeViewModel/AuthViewModel
    // yang memang lintas layar (CLAUDE.md aturan 6), MapViewModel cuma
    // dipakai satu layar ini — jadi disuntik lokal di sini, bukan di
    // `main.dart`.
    final halaman = <Widget>[
      const HomeScreen(), // L-04 · T-12
      ChangeNotifierProvider<MapViewModel>(
        create: (context) => MapViewModel(
          repository: context.read<LapanganRepository>(),
          locationService: context.read<LocationService>(),
        ),
        child: const MapScreen(), // L-05 · T-14
      ),
      ChangeNotifierProvider<AktivitasViewModel>(
        create: (context) => AktivitasViewModel(
          repository: context.read<AktivitasRepository>(),
        ),
        child: const CariRekanScreen(), // L-07 · T-17
      ),
      const ProfilScreen(), // L-13 · T-27
    ];

    return Scaffold(
      // IndexedStack menjaga state tiap tab saat berpindah — daftar
      // lapangan tidak dimuat ulang setiap kali kembali ke Home.
      body: IndexedStack(index: _indeks, children: halaman),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indeks,
        onDestinationSelected: (i) => setState(() => _indeks = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.map_outlined), label: 'Map'),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            label: 'Teman',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
