import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';
import '../features/auth/viewmodel/auth_viewmodel.dart';
import '../repositories/lapangan_repository.dart';

/// Halaman tersembunyi "Seed Data Awal" — PRD Bagian 10, T-10.
///
/// **Status: JEMBATAN SEMENTARA, BUKAN T-10 SELESAI.** T-10 sungguhan
/// mengisi 30 lapangan dengan data yang sudah diverifikasi lewat T-00e
/// (survei 8 lapangan `observasi`) dan T-00f (koordinat 25 lapangan).
/// Sampai data itu siap, layar ini memanggil
/// [LapanganRepository.seedPrototipe] — 7 lapangan yang koordinatnya
/// SUDAH terverifikasi (lihat catatan di `lapangan_repository.dart`),
/// termasuk 3 lapangan mitra — supaya alur utama (cari lapangan, detail,
/// rating, cari rekan, reservasi) bisa dicoba di device/emulator nyata
/// SEBELUM 30 lapangan lengkap tersedia.
///
/// Tombol masuknya sengaja hanya lewat menu Profil (lihat
/// `profil_screen.dart`, ditandai `// SEMENTARA (T-10)`), bukan navigasi
/// utama — sesuai PRD: "halaman tersembunyi ... setelah dijalankan sekali,
/// rutenya dinonaktifkan". **Hapus tile itu dan file ini setelah T-10
/// sungguhan (AdminSeedScreen 30 lapangan) menggantikannya, dan jangan
/// pernah ikut dibundel ke APK yang dibagikan ke responden SUS.**
///
/// ATURAN LAPISAN (CLAUDE.md): TIDAK ADA `cloud_firestore` di sini —
/// lewat `LapanganRepository` seperti layar lain.
class AdminSeedScreen extends StatelessWidget {
  const AdminSeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<_AdminSeedViewModel>(
      create: (context) => _AdminSeedViewModel(
        repository: context.read<LapanganRepository>(),
      ),
      child: const _AdminSeedBody(),
    );
  }
}

class _AdminSeedBody extends StatelessWidget {
  const _AdminSeedBody();

  Future<void> _jalankan(BuildContext context, String uidMitra) async {
    final vm = context.read<_AdminSeedViewModel>();
    final jumlah = await vm.jalankanSeed(uidMitra);

    if (!context.mounted) return;

    if (jumlah != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$jumlah ${AppStrings.adminSeedBerhasil}')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(vm.pesanError ?? 'Gagal menjalankan seed.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<_AdminSeedViewModel>();
    final user = context.watch<AuthViewModel>().user;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text(
          AppStrings.adminSeedJudul,
          style: AppTextStyles.judulSeksi,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.marginLayar),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                AppStrings.adminSeedKeterangan,
                style: AppTextStyles.metaLapangan,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: (vm.sedangProses || user == null)
                    ? null
                    : () => _jalankan(context, user.userId),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusChip),
                  ),
                ),
                child: vm.sedangProses
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(AppStrings.adminSeedTombol),
              ),
              if (user == null) ...[
                const SizedBox(height: 12),
                const Text(
                  AppStrings.adminSeedPerluLogin,
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// ViewModel minimal — hanya membungkus satu aksi (jalankan seed), pola
/// yang sama dengan `FormLapanganViewModel` (sedangProses + pesanError).
class _AdminSeedViewModel extends ChangeNotifier {
  final LapanganRepository _repository;

  _AdminSeedViewModel({required LapanganRepository repository})
      : _repository = repository;

  bool _sedangProses = false;
  bool get sedangProses => _sedangProses;

  String? _pesanError;
  String? get pesanError => _pesanError;

  /// Mengembalikan jumlah lapangan yang berhasil ditambahkan, atau `null`
  /// kalau gagal — baca [pesanError] untuk pesannya.
  Future<int?> jalankanSeed(String uidMitra) async {
    _sedangProses = true;
    _pesanError = null;
    notifyListeners();

    try {
      final jumlah = await _repository.seedPrototipe(uidMitra: uidMitra);
      _sedangProses = false;
      notifyListeners();
      return jumlah;
    } catch (e) {
      _pesanError = e.toString().replaceFirst('Exception: ', '');
      _sedangProses = false;
      notifyListeners();
      return null;
    }
  }
}
