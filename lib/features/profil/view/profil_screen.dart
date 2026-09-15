import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sports.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/formatter.dart';
import '../../../models/aktivitas_bermain_model.dart';
import '../../../models/booking_model.dart';
import '../../../models/favorit_model.dart';
import '../../../models/user_model.dart';
import '../../../repositories/aktivitas_repository.dart';
import '../../../repositories/booking_repository.dart';
import '../../../repositories/favorit_repository.dart';
import '../../aktivitas/view/detail_aktivitas_screen.dart';
import '../../auth/view/login_screen.dart';
import '../../auth/viewmodel/auth_viewmodel.dart';
// import '../../../routes/admin_seed_screen.dart'; // lihat catatan tile "Seed Data Awal" di bawah
import '../../mitra/view/dashboard_mitra_screen.dart';
import '../viewmodel/profil_viewmodel.dart';
import 'halaman_statis_screen.dart';
import 'ubah_lokasi_default_sheet.dart';
import 'ubah_olahraga_favorit_sheet.dart';
import 'ubah_profil_sheet.dart';

/// Tab Profil — PRD L-13, T-27. BB-28 (booking lewat jam selesai tampil
/// SELESAI), BB-30 (logout).
///
/// ATURAN LAPISAN (CLAUDE.md): TIDAK ADA `cloud_firestore` di sini.
///
/// Kotak statistik (T-38, AB-12) dan Olahraga Favorit / Lokasi Default
/// (T-37) — masing-masing tugas terpisah dari T-27 — sudah hidup penuh di
/// layar ini. Daftar Lapangan Favorit (AB-10) dipindah ke Home (L-04)
/// lewat tombol toggle ♥ — lihat T-41; hanya kotak angka "Favorit" yang
/// tetap tinggal di sini.
///
/// Riwayat Pemesanan dan Aktivitas Saya SUDAH hidup penuh lewat `Stream`
/// (CLAUDE.md aturan 6), termasuk AB-07 (status SELESAI dihitung klien).
class ProfilScreen extends StatelessWidget {
  const ProfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Sama seperti home_screen.dart — jaga terhadap `user` yang sudah
    // null (mis. jendela logout) supaya tidak crash lewat `!`.
    final user = context.read<AuthViewModel>().user;
    if (user == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final userId = user.userId;

    return ChangeNotifierProvider<ProfilViewModel>(
      create: (context) => ProfilViewModel(
        bookingRepository: context.read<BookingRepository>(),
        aktivitasRepository: context.read<AktivitasRepository>(),
        favoritRepository: context.read<FavoritRepository>(),
        userId: userId,
      ),
      child: const _ProfilBody(),
    );
  }
}

class _ProfilBody extends StatelessWidget {
  const _ProfilBody();

  Future<void> _keluar(BuildContext context) async {
    await context.read<AuthViewModel>().keluar();
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  void _bukaHalamanStatis(BuildContext context, String judul, String isi) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => HalamanStatisScreen(judul: judul, isi: isi),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthViewModel>().user;
    final vm = context.watch<ProfilViewModel>();

    // Sekejap null di jendela antara `keluar()` mengosongkan AuthViewModel
    // dan navigasi ke LoginScreen selesai — tampilkan spinner, bukan layar
    // putih polos, supaya tidak ada kondisi tanpa penanda apa pun.
    if (user == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title:
            const Text(AppStrings.tabProfil, style: AppTextStyles.judulSeksi),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSizes.marginLayar),
          children: [
            _Header(user: user),
            const SizedBox(height: 20),
            _KotakStatistik(vm: vm),
            const Divider(height: 36),
            _SeksiOlahragaFavorit(olahragaFavorit: user.olahragaFavorit),
            const SizedBox(height: 20),
            _SeksiLokasiDefault(lokasiDefault: user.lokasiDefault),
            const Divider(height: 36),
            const Text(
              AppStrings.riwayatPemesanan,
              style: AppTextStyles.judulSeksi,
            ),
            const SizedBox(height: 10),
            _SeksiRiwayatBooking(vm: vm),
            const Divider(height: 36),
            const Text(
              AppStrings.aktivitasSaya,
              style: AppTextStyles.judulSeksi,
            ),
            const SizedBox(height: 10),
            _SeksiAktivitasSaya(vm: vm, userId: user.userId),
            const Divider(height: 36),
            _TileMenu(
              ikon: Icons.help_outline,
              label: AppStrings.bantuan,
              onTap: () => _bukaHalamanStatis(
                context,
                AppStrings.bantuan,
                AppStrings.isiBantuan,
              ),
            ),
            _TileMenu(
              ikon: Icons.privacy_tip_outlined,
              label: AppStrings.kebijakanPrivasi,
              onTap: () => _bukaHalamanStatis(
                context,
                AppStrings.kebijakanPrivasi,
                AppStrings.isiKebijakanPrivasi,
              ),
            ),
            _TileMenu(
              ikon: Icons.info_outline,
              label: AppStrings.tentang,
              onTap: () => _bukaHalamanStatis(
                context,
                AppStrings.tentang,
                AppStrings.isiTentang,
              ),
            ),
            if (user.role == 'mitra')
              _TileMenu(
                ikon: Icons.store_outlined,
                label: AppStrings.dashboardMitra,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const DashboardMitraScreen()),
                ),
              ),
            // T-10: tile "Seed Data Awal" sengaja disembunyikan sejak T-29
            // (build APK release) — 30 lapangan sudah tertulis di project
            // Firestore produksi sejak 21 Agustus 2026, dan tile ini tidak
            // boleh ikut ke APK yang dibagikan ke responden SUS (T-31).
            // `AdminSeedScreen`/`LapanganRepository.seedSemuaLapangan()`
            // SENGAJA tidak dihapus — kalau T-00e selesai dan 8 lapangan
            // `sumberData: observasi` perlu ditulis ulang dengan data survei
            // asli, tile ini tinggal dimunculkan lagi (uncomment blok di
            // bawah), tanpa perlu menulis ulang fiturnya dari nol.
            //
            // _TileMenu(
            //   ikon: Icons.dataset_outlined,
            //   label: AppStrings.adminSeedJudul,
            //   onTap: () => Navigator.of(context).push(
            //     MaterialPageRoute(builder: (_) => const AdminSeedScreen()),
            //   ),
            // ),
            // const SizedBox(height: 8),
            _TileMenu(
              ikon: Icons.logout,
              label: AppStrings.keluar,
              warna: Colors.red,
              onTap: () => _keluar(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final UserModel user;

  const _Header({required this.user});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _AvatarProfil(nama: user.nama, fotoProfilBase64: user.fotoProfilBase64),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(user.nama, style: AppTextStyles.sambutan),
              const SizedBox(height: 2),
              Text(user.surel, style: AppTextStyles.metaLapangan),
              if (user.nomorTelepon.isNotEmpty)
                Text(user.nomorTelepon, style: AppTextStyles.metaLapangan),
            ],
          ),
        ),
        // PRD tidak merinci layar Edit Profil terpisah (§2.4), jadi
        // dibuat sebagai bottom sheet ringkas (pola sama dengan Ubah
        // Olahraga Favorit/Lokasi Default, T-37) — nama, nomor telepon,
        // dan URL foto profil opsional (T-43). Surel sengaja tidak ikut:
        // itu email Firebase Auth (butuh re-autentikasi untuk diubah, di
        // luar cakupan PRD).
        TextButton(
          onPressed: () => showUbahProfilSheet(
            context,
            namaSaatIni: user.nama,
            nomorTeleponSaatIni: user.nomorTelepon,
            fotoProfilBase64SaatIni: user.fotoProfilBase64,
          ),
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: const Size(0, 0),
          ),
          child: const Text(AppStrings.editProfil),
        ),
      ],
    );
  }
}

/// Avatar profil — T-43. Menampilkan foto dari `fotoProfilBase64` (pilih
/// dari galeri via `image_picker`, disimpan Base64 di Firestore — BUKAN
/// Firebase Storage) kalau terisi, jatuh balik ke avatar inisial (pola
/// lama, satu-satunya opsi sebelum T-43) kalau kosong ATAU data gagal
/// didekode.
class _AvatarProfil extends StatefulWidget {
  final String nama;
  final String? fotoProfilBase64;

  const _AvatarProfil({required this.nama, required this.fotoProfilBase64});

  @override
  State<_AvatarProfil> createState() => _AvatarProfilState();
}

class _AvatarProfilState extends State<_AvatarProfil> {
  bool _gagalMuat = false;

  String get _inisial {
    final kata = widget.nama.trim().split(RegExp(r'\s+'));
    if (kata.isEmpty || kata.first.isEmpty) return '?';
    final pertama = kata.first[0];
    final kedua = kata.length > 1 && kata.last.isNotEmpty ? kata.last[0] : '';
    return (pertama + kedua).toUpperCase();
  }

  /// Base64 → bytes, dibungkus try/catch — data yang tersimpan seharusnya
  /// selalu valid lewat alur `ubah_profil_sheet.dart`, tapi tetap dijaga
  /// supaya data rusak jatuh balik ke inisial, bukan crash.
  Uint8List? get _fotoBytes {
    final b64 = widget.fotoProfilBase64;
    if (b64 == null || b64.isEmpty) return null;
    try {
      return base64Decode(b64);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bytes = _gagalMuat ? null : _fotoBytes;

    return CircleAvatar(
      radius: 28,
      backgroundColor: AppColors.primary,
      backgroundImage: bytes != null ? MemoryImage(bytes) : null,
      onBackgroundImageError: bytes != null
          ? (_, __) => setState(() => _gagalMuat = true)
          : null,
      child: bytes != null
          ? null
          : Text(
              _inisial,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
    );
  }
}

/// Kotak statistik Booking · Aktivitas · Favorit — PRD L-13, T-38, AB-12.
///
/// Tiap angka dihitung dari `snapshot.data?.length` pada stream yang SAMA
/// dipakai daftar di bawahnya (`vm.streamRiwayatBooking` dkk.) — bukan
/// query `count()` sekali-ambil terpisah. Konsekuensinya: angka ini ikut
/// hidup begitu ada perubahan (mis. menambah favorit dari Home lalu
/// kembali ke tab ini), tanpa perlu logout/login untuk melihat angka
/// terbaru.
class _KotakStatistik extends StatelessWidget {
  final ProfilViewModel vm;

  const _KotakStatistik({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: StreamBuilder<List<BookingModel>>(
            stream: vm.streamRiwayatBooking,
            builder: (context, snapshot) => _KotakAngka(
              label: AppStrings.statBooking,
              nilai: snapshot.data?.length ?? 0,
              memuat: snapshot.connectionState == ConnectionState.waiting,
              gagal: snapshot.hasError,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: StreamBuilder<List<AktivitasBermainModel>>(
            stream: vm.streamAktivitasSaya,
            builder: (context, snapshot) => _KotakAngka(
              label: AppStrings.statAktivitas,
              nilai: snapshot.data?.length ?? 0,
              memuat: snapshot.connectionState == ConnectionState.waiting,
              gagal: snapshot.hasError,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: StreamBuilder<List<FavoritModel>>(
            stream: vm.streamDaftarFavorit,
            builder: (context, snapshot) => _KotakAngka(
              label: AppStrings.statFavorit,
              nilai: snapshot.data?.length ?? 0,
              memuat: snapshot.connectionState == ConnectionState.waiting,
              gagal: snapshot.hasError,
            ),
          ),
        ),
      ],
    );
  }
}

class _KotakAngka extends StatelessWidget {
  final String label;
  final int nilai;
  final bool memuat;
  final bool gagal;

  const _KotakAngka({
    required this.label,
    required this.nilai,
    required this.memuat,
    required this.gagal,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusKartu),
        boxShadow: AppColors.shadowKartu,
      ),
      child: Column(
        children: [
          if (memuat)
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            Text(
              gagal ? '—' : '$nilai',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.metaLapangan),
        ],
      ),
    );
  }
}

class _SeksiOlahragaFavorit extends StatelessWidget {
  final List<String> olahragaFavorit;

  const _SeksiOlahragaFavorit({required this.olahragaFavorit});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              AppStrings.olahragaFavorit,
              style: AppTextStyles.judulSeksi,
            ),
            TextButton(
              onPressed: () => showUbahOlahragaFavoritSheet(
                context,
                olahragaFavoritSaatIni: olahragaFavorit,
              ),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 0),
              ),
              child: const Text(AppStrings.ubah),
            ),
          ],
        ),
        const SizedBox(height: 8),
        olahragaFavorit.isEmpty
            ? const Text(
                AppStrings.belumDipilih,
                style: AppTextStyles.metaLapangan,
              )
            : Wrap(
                spacing: 8,
                runSpacing: 8,
                children: olahragaFavorit
                    .map(
                      (kode) => Chip(
                        label: Text(
                          '${AppSports.ikonDari(kode)} ${AppSports.labelDari(kode)}',
                        ),
                        backgroundColor: AppColors.surfaceVariant,
                      ),
                    )
                    .toList(),
              ),
      ],
    );
  }
}

class _SeksiLokasiDefault extends StatelessWidget {
  final Map<String, dynamic>? lokasiDefault;

  const _SeksiLokasiDefault({required this.lokasiDefault});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              AppStrings.lokasiDefault,
              style: AppTextStyles.judulSeksi,
            ),
            TextButton(
              onPressed: () => showUbahLokasiDefaultSheet(context),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 0),
              ),
              child: const Text(AppStrings.ubah),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          (lokasiDefault?['nama'] as String?) ?? AppStrings.belumDiatur,
          style: AppTextStyles.metaLapangan,
        ),
      ],
    );
  }
}

class _SeksiRiwayatBooking extends StatelessWidget {
  final ProfilViewModel vm;

  const _SeksiRiwayatBooking({required this.vm});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<BookingModel>>(
      stream: vm.streamRiwayatBooking,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Text(
            snapshot.error.toString().replaceFirst('Exception: ', ''),
            style: AppTextStyles.metaLapangan,
          );
        }
        final daftar = snapshot.data ?? const [];
        if (daftar.isEmpty) {
          return const Text(
            AppStrings.kosongRiwayatBooking,
            style: AppTextStyles.metaLapangan,
          );
        }
        return Column(
          children: [
            for (final b in daftar) ...[
              _KartuRiwayatBooking(booking: b, vm: vm),
              const SizedBox(height: 10),
            ],
          ],
        );
      },
    );
  }
}

class _KartuRiwayatBooking extends StatelessWidget {
  final BookingModel booking;
  final ProfilViewModel vm;

  const _KartuRiwayatBooking({required this.booking, required this.vm});

  String _label(String status) {
    switch (status) {
      case 'DIKONFIRMASI':
        return 'Dikonfirmasi';
      case 'DITOLAK':
        return 'Ditolak';
      case 'SELESAI':
        return 'Selesai';
      case 'DIBATALKAN':
        return 'Dibatalkan';
      default:
        return 'Menunggu';
    }
  }

  @override
  Widget build(BuildContext context) {
    // AB-07: tulis balik ke Firestore begitu baris ini ditampilkan dan
    // memenuhi syarat lewat jam selesai — lihat dokumentasi method-nya.
    vm.tandaiSelesaiJikaPerlu(booking);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusKartu),
        boxShadow: AppColors.shadowKartu,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  booking.namaLapangan,
                  style: AppTextStyles.namaLapangan,
                ),
              ),
              Text(
                Formatter.rupiah(booking.totalHarga),
                style: AppTextStyles.harga,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${booking.tanggal} · ${booking.jamMulai}–${booking.jamSelesai}',
            style: AppTextStyles.metaLapangan,
          ),
          const SizedBox(height: 4),
          Text(
            _label(vm.statusTampilan(booking)),
            style: AppTextStyles.metaLapangan.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SeksiAktivitasSaya extends StatelessWidget {
  final ProfilViewModel vm;
  final String userId;

  const _SeksiAktivitasSaya({required this.vm, required this.userId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<AktivitasBermainModel>>(
      stream: vm.streamAktivitasSaya,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Text(
            snapshot.error.toString().replaceFirst('Exception: ', ''),
            style: AppTextStyles.metaLapangan,
          );
        }
        final daftar = snapshot.data ?? const [];
        if (daftar.isEmpty) {
          return const Text(
            AppStrings.kosongAktivitasSaya,
            style: AppTextStyles.metaLapangan,
          );
        }
        return Column(
          children: [
            for (final a in daftar) ...[
              _KartuAktivitasSaya(aktivitas: a, userId: userId),
              const SizedBox(height: 10),
            ],
          ],
        );
      },
    );
  }
}

class _KartuAktivitasSaya extends StatelessWidget {
  final AktivitasBermainModel aktivitas;
  final String userId;

  const _KartuAktivitasSaya({required this.aktivitas, required this.userId});

  @override
  Widget build(BuildContext context) {
    final apakahPembuat = aktivitas.pembuatId == userId;

    return InkWell(
      borderRadius: BorderRadius.circular(AppSizes.radiusKartu),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) =>
              DetailAktivitasScreen(aktivitasId: aktivitas.aktivitasId),
        ),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusKartu),
          boxShadow: AppColors.shadowKartu,
        ),
        child: Row(
          children: [
            Text(
              AppSports.ikonDari(aktivitas.jenisOlahraga),
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(aktivitas.namaLapangan, style: AppTextStyles.namaLapangan),
                  const SizedBox(height: 2),
                  Text(
                    Formatter.tanggalDanJam(aktivitas.waktu),
                    style: AppTextStyles.metaLapangan,
                  ),
                ],
              ),
            ),
            if (apakahPembuat)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppSizes.radiusChip),
                ),
                child: const Text(
                  AppStrings.pembuatAktivitas,
                  style: TextStyle(fontSize: 10, color: AppColors.primary),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TileMenu extends StatelessWidget {
  final IconData ikon;
  final String label;
  final VoidCallback onTap;
  final Color? warna;

  const _TileMenu({
    required this.ikon,
    required this.label,
    required this.onTap,
    this.warna,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(ikon, color: warna ?? AppColors.textSecondary),
      title: Text(
        label,
        style: AppTextStyles.namaLapangan.copyWith(color: warna),
      ),
      trailing: const Icon(Icons.chevron_right, size: 18, color: AppColors.textSecondary),
      onTap: onTap,
    );
  }
}
