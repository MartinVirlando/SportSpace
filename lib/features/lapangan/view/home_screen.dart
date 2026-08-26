import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../models/notifikasi_model.dart';
import '../../../repositories/favorit_repository.dart';
import '../../../repositories/notifikasi_repository.dart';
import '../../../widgets/chip_olahraga.dart';
import '../../../widgets/kartu_lapangan.dart';
import '../../auth/viewmodel/auth_viewmodel.dart';
import '../../favorit/viewmodel/favorit_viewmodel.dart';
import '../../notifikasi/view/notifikasi_screen.dart';
import '../../notifikasi/viewmodel/notifikasi_viewmodel.dart';
import '../viewmodel/home_viewmodel.dart';
import 'detail_lapangan_screen.dart';

/// Halaman Home — PRD L-04.
///
/// ATURAN LAPISAN (CLAUDE.md): perhatikan daftar import di atas.
/// TIDAK ADA `cloud_firestore` di sini, dan tidak boleh pernah ada.
/// View hanya membaca state dari ViewModel dan menggambar.
///
/// Kalau kamu merasa butuh `FirebaseFirestore` di file view mana pun,
/// itu tandanya ada logika yang salah tempat — pindahkan ke Repository.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();

    // `context.read` dipakai di initState karena kita hanya ingin
    // memanggil sebuah fungsi, bukan ikut membangun ulang widget.
    // `addPostFrameCallback` memastikan pemanggilan terjadi setelah
    // frame pertama selesai — memanggil notifyListeners saat widget
    // masih dibangun akan memicu error.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _muatLapanganDenganLokasiDefault(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    // `context.watch` membuat widget ini dibangun ulang setiap kali
    // ViewModel memanggil notifyListeners().
    final vm = context.watch<HomeViewModel>();

    // Home hanya bisa dibuka setelah login (lihat splash_screen.dart —
    // ShellNavigasi cuma dituju kalau StatusAuth.sudahMasuk), jadi user
    // di sini biasanya selalu ada. Tapi kalau tab ini tetap hidup di
    // IndexedStack ShellNavigasi dan alur logout suatu saat berubah
    // (mis. AuthViewModel dikosongkan sebelum navigasi ke Login selesai),
    // `user!` di sini bisa crash — jaga dengan spinner, bukan asumsi.
    final user = context.read<AuthViewModel>().user;
    if (user == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final userId = user.userId;

    return ChangeNotifierProvider<FavoritViewModel>(
      create: (context) => FavoritViewModel(
        repository: context.read<FavoritRepository>(),
        userId: userId,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              const _Header(),
              const SizedBox(height: 4),
              _KolomPencarian(
                onBerubah: context.read<HomeViewModel>().ubahKataKunci,
              ),
              const SizedBox(height: 10),
              BarisChipOlahraga(
                terpilih: vm.filterOlahraga,
                onPilih: context.read<HomeViewModel>().ubahFilterOlahraga,
              ),
              const SizedBox(height: 14),
              if (vm.pakaiLokasiDefault) const _SpandukLokasiDefault(),
              // Expanded supaya daftar mengisi sisa layar dan bisa digulir.
              Expanded(child: _Isi(vm: vm)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Memuat lapangan dengan `lokasiDefault` milik pengguna (bila ada)
/// sebagai cadangan saat GPS ditolak/mati — PRD AB-03, T-37. Dipakai di
/// setiap tempat yang memanggil `muatLapangan()`: muat awal, tombol coba
/// lagi, dan tarik-untuk-menyegarkan.
Future<void> _muatLapanganDenganLokasiDefault(BuildContext context) {
  final lokasiDefault = context.read<AuthViewModel>().user?.lokasiDefault;
  return context.read<HomeViewModel>().muatLapangan(
        latDefault: (lokasiDefault?['latitude'] as num?)?.toDouble(),
        lonDefault: (lokasiDefault?['longitude'] as num?)?.toDouble(),
      );
}

/// Memilih apa yang digambar berdasarkan kondisi ViewModel.
///
/// Kelima kondisi ditangani eksplisit. Ini yang dimaksud "tidak boleh ada
/// layar putih polos" di Definisi Selesai PRD Bagian 12 poin 5.
class _Isi extends StatelessWidget {
  final HomeViewModel vm;

  const _Isi({required this.vm});

  @override
  Widget build(BuildContext context) {
    switch (vm.kondisi) {
      case KondisiHome.memuat:
        return const Center(child: CircularProgressIndicator());

      case KondisiHome.gagal:
        return _Pesan(
          ikon: Icons.error_outline,
          judul: 'Gagal memuat',
          keterangan: vm.pesanError ?? 'Terjadi kesalahan.',
          labelTombol: 'Coba Lagi',
          onTekan: () => _muatLapanganDenganLokasiDefault(context),
        );

      case KondisiHome.lokasiDitolak:
        // PRD AB-03: arahkan ke pengaturan, JANGAN crash, dan sediakan
        // jalan keluar berupa tombol coba lagi.
        return _Pesan(
          ikon: Icons.location_off_outlined,
          judul: 'Lokasi belum aktif',
          keterangan: 'Aktifkan izin lokasi supaya kami bisa menghitung jarak '
              'lapangan dari posisimu.',
          labelTombol: 'Buka Pengaturan',
          onTekan: () async {
            await context.read<HomeViewModel>().bukaPengaturanLokasi();
            if (context.mounted) {
              await _muatLapanganDenganLokasiDefault(context);
            }
          },
        );

      case KondisiHome.kosong:
        return const _Pesan(
          ikon: Icons.search_off,
          judul: 'Belum ada lapangan',
          keterangan: 'Belum ada lapangan di sekitar kamu.',
        );

      case KondisiHome.berhasil:
        final daftar = vm.lapanganTampil;

        // Kondisi kosong kedua: data ADA, tapi filter/pencarian tidak
        // menyisakan apa pun. Pesannya harus beda dari kosong di atas,
        // karena solusinya beda — di sini pengguna tinggal mengubah filter.
        if (daftar.isEmpty) {
          return const _Pesan(
            ikon: Icons.filter_alt_off_outlined,
            judul: 'Tidak ada hasil',
            keterangan: 'Coba ubah kata kunci atau pilih olahraga lain.',
          );
        }

        final favoritVm = context.watch<FavoritViewModel>();

        return RefreshIndicator(
          onRefresh: () => _muatLapanganDenganLokasiDefault(context),
          child: StreamBuilder<Set<String>>(
            stream: favoritVm.streamIdFavorit,
            builder: (context, snapshotFavorit) {
              final idFavorit = snapshotFavorit.data ?? const <String>{};

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(
                  AppSizes.marginLayar,
                  0,
                  AppSizes.marginLayar,
                  16,
                ),
                itemCount: daftar.length,
                itemBuilder: (context, i) {
                  final lapangan = daftar[i];
                  return KartuLapangan(
                    lapangan: lapangan,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => DetailLapanganScreen(
                          lapanganId: lapangan.lapanganId,
                        ),
                      ),
                    ),
                    difavoritkan: idFavorit.contains(lapangan.lapanganId),
                    onTapFavorit: () => _toggleFavorit(context, favoritVm, lapangan.lapanganId, lapangan.nama),
                  );
                },
              );
            },
          ),
        );
    }
  }

  /// Menekan ikon ♡/♥ pada kartu — PRD AB-10. Repository melempar pesan
  /// berbahasa Indonesia yang siap tampil (CLAUDE.md "Menangani kesalahan"),
  /// jadi cukup ditangkap dan ditampilkan lewat SnackBar.
  Future<void> _toggleFavorit(
    BuildContext context,
    FavoritViewModel vm,
    String lapanganId,
    String namaLapangan,
  ) async {
    try {
      await vm.toggle(lapanganId, namaLapangan);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    }
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthViewModel>().user;
    final nama = user?.nama ?? '';

    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(
        AppSizes.marginLayar,
        12,
        AppSizes.marginLayar,
        12,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Halo, $nama 👋', style: AppTextStyles.sambutan),
                const SizedBox(height: 2),
                const Text(
                  '📍 Tangerang Selatan',
                  style: AppTextStyles.lokasi,
                ),
              ],
            ),
          ),
          // Ikon lonceng + badge — PRD L-04, belum ada di Figma.
          //
          // NotifikasiViewModel dibuat LOKAL di sini (bukan Provider
          // global — CLAUDE.md aturan 6), terpisah dari instance yang
          // dibuat NotifikasiScreen saat dibuka. Lihat catatan di
          // notifikasi_viewmodel.dart.
          if (user != null)
            ChangeNotifierProvider<NotifikasiViewModel>(
              create: (context) => NotifikasiViewModel(
                repository: context.read<NotifikasiRepository>(),
                userId: user.userId,
              ),
              child: const _IkonLonceng(),
            ),
        ],
      ),
    );
  }
}

/// Ikon lonceng dengan badge titik — hanya muncul kalau ada notifikasi
/// yang belum dibaca. Dihitung dari daftar `StreamBuilder` yang sama,
/// BUKAN query kedua (lihat catatan di `notifikasi_repository.dart`).
class _IkonLonceng extends StatelessWidget {
  const _IkonLonceng();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<NotifikasiViewModel>();

    return StreamBuilder<List<NotifikasiModel>>(
      stream: vm.streamNotifikasi,
      builder: (context, snapshot) {
        final adaBelumDibaca =
            (snapshot.data ?? const []).any((n) => !n.sudahDibaca);

        return Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_none),
              color: AppColors.textPrimary,
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NotifikasiScreen()),
              ),
            ),
            if (adaBelumDibaca)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _KolomPencarian extends StatelessWidget {
  final ValueChanged<String> onBerubah;

  const _KolomPencarian({required this.onBerubah});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.marginLayar),
      child: Container(
        height: AppSizes.tinggiPencarian,
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(AppSizes.radiusPencarian),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: [
            const Icon(Icons.search, size: 18, color: AppColors.textSecondary),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                onChanged: onBerubah,
                style: const TextStyle(fontSize: 13),
                decoration: const InputDecoration(
                  hintText: 'Cari lapangan olahraga...',
                  hintStyle: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Spanduk saat jarak dihitung dari lokasi default, bukan GPS (AB-03).
class _SpandukLokasiDefault extends StatelessWidget {
  const _SpandukLokasiDefault();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(
        AppSizes.marginLayar,
        0,
        AppSizes.marginLayar,
        12,
      ),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        'Memakai lokasi default. Aktifkan GPS untuk hasil lebih akurat.',
        style: AppTextStyles.metaLapangan,
      ),
    );
  }
}

/// Satu widget untuk semua kondisi kosong/gagal, supaya tampilannya seragam.
class _Pesan extends StatelessWidget {
  final IconData ikon;
  final String judul;
  final String keterangan;
  final String? labelTombol;
  final VoidCallback? onTekan;

  const _Pesan({
    required this.ikon,
    required this.judul,
    required this.keterangan,
    this.labelTombol,
    this.onTekan,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(ikon, size: 48, color: AppColors.textSecondary),
            const SizedBox(height: 12),
            Text(judul, style: AppTextStyles.judulSeksi),
            const SizedBox(height: 6),
            Text(
              keterangan,
              textAlign: TextAlign.center,
              style: AppTextStyles.lokasi,
            ),
            if (labelTombol != null) ...[
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: onTekan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusChip),
                  ),
                ),
                child: Text(labelTombol!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
