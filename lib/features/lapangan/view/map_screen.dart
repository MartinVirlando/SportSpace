import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sports.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/formatter.dart';
import '../../../models/lapangan_model.dart';
import '../../auth/viewmodel/auth_viewmodel.dart';
import '../viewmodel/map_viewmodel.dart';
import 'detail_lapangan_screen.dart';

/// Halaman Peta Lapangan — PRD L-05. BB-09 (marker tampil), BB-10 (tekan
/// marker membuka kartu ringkas menuju Detail).
///
/// ATURAN LAPISAN (CLAUDE.md): TIDAK ADA `cloud_firestore` di sini.
/// Data diambil lewat MapViewModel, yang tidak dibuat di sini tapi
/// disuntik dari ShellNavigasi supaya sesuai pola Provider yang sama
/// dengan HomeScreen.
///
/// `latlong2` di sini HANYA untuk tipe `LatLng` yang dibutuhkan
/// flutter_map — PRD Bagian 4 melarang `Distance()` bawaannya untuk
/// menghitung jarak. Jarak tetap dari `hitungJarakHaversine` manual,
/// dihitung di MapViewModel.
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _muatPetaDenganLokasiDefault(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MapViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(child: _Isi(vm: vm)),
    );
  }
}

/// Memuat peta dengan `lokasiDefault` milik pengguna (bila ada) sebagai
/// cadangan saat GPS ditolak/mati — PRD AB-03, T-37. Pola yang sama
/// dengan `home_screen.dart`.
Future<void> _muatPetaDenganLokasiDefault(BuildContext context) {
  final lokasiDefault = context.read<AuthViewModel>().user?.lokasiDefault;
  return context.read<MapViewModel>().muatPeta(
        latDefault: (lokasiDefault?['latitude'] as num?)?.toDouble(),
        lonDefault: (lokasiDefault?['longitude'] as num?)?.toDouble(),
      );
}

class _Isi extends StatelessWidget {
  final MapViewModel vm;

  const _Isi({required this.vm});

  @override
  Widget build(BuildContext context) {
    switch (vm.kondisi) {
      case KondisiMap.memuat:
        return const Center(child: CircularProgressIndicator());

      case KondisiMap.gagal:
        return _Pesan(
          ikon: Icons.error_outline,
          judul: AppStrings.errGagalMuat,
          keterangan: vm.pesanError ?? 'Terjadi kesalahan.',
          labelTombol: AppStrings.cobaLagi,
          onTekan: () => _muatPetaDenganLokasiDefault(context),
        );

      case KondisiMap.lokasiDitolak:
        // Sama seperti Home — AB-03, JANGAN crash, sediakan jalan keluar.
        return _Pesan(
          ikon: Icons.location_off_outlined,
          judul: AppStrings.lokasiBelumAktif,
          keterangan: AppStrings.lokasiKeterangan,
          labelTombol: AppStrings.bukaPengaturan,
          onTekan: () async {
            await context.read<MapViewModel>().bukaPengaturanLokasi();
            if (context.mounted) {
              await _muatPetaDenganLokasiDefault(context);
            }
          },
        );

      case KondisiMap.berhasil:
        return _PetaBerhasil(vm: vm);
    }
  }
}

class _PetaBerhasil extends StatefulWidget {
  final MapViewModel vm;

  const _PetaBerhasil({required this.vm});

  @override
  State<_PetaBerhasil> createState() => _PetaBerhasilState();
}

class _PetaBerhasilState extends State<_PetaBerhasil> {
  final _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    final vm = widget.vm;
    final posisiPengguna = LatLng(vm.latPengguna!, vm.lonPengguna!);

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: posisiPengguna,
            initialZoom: 14,
            onTap: (_, __) => context.read<MapViewModel>().pilihLapangan(null),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'id.ac.binus.sport_space',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: posisiPengguna,
                  width: 24,
                  height: 24,
                  child: const _PenandaPengguna(),
                ),
                for (final l in vm.lapangan)
                  Marker(
                    point: LatLng(l.latitude, l.longitude),
                    width: 40,
                    height: 40,
                    child: GestureDetector(
                      onTap: () =>
                          context.read<MapViewModel>().pilihLapangan(l),
                      child: _PenandaLapangan(lapangan: l),
                    ),
                  ),
              ],
            ),
          ],
        ),
        if (vm.pakaiLokasiDefault || vm.lapangan.isEmpty)
          Positioned(
            top: 12,
            left: AppSizes.marginLayar,
            right: AppSizes.marginLayar,
            child: Column(
              children: [
                if (vm.pakaiLokasiDefault) const _SpandukLokasiDefault(),
                if (vm.pakaiLokasiDefault && vm.lapangan.isEmpty)
                  const SizedBox(height: 8),
                // Peta tetap valid secara visual dengan hanya marker
                // posisi pengguna, tapi spanduk ini tetap dibutuhkan
                // supaya "kosong" terlihat sebagai kondisi yang memang
                // ditangani, bukan cuma peta yang belum selesai memuat.
                if (vm.lapangan.isEmpty) const _SpandukKosong(),
              ],
            ),
          ),
        if (vm.lapanganTerpilih != null)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _KartuRingkas(lapangan: vm.lapanganTerpilih!),
          ),
        Positioned(
          right: 12,
          bottom: vm.lapanganTerpilih != null ? 132 : 16,
          child: _TombolRecenter(
            onTap: () => _mapController.move(posisiPengguna, 14),
          ),
        ),
      ],
    );
  }
}

/// Tombol kembali ke posisi pengguna — tidak ada di PRD L-05 secara
/// eksplisit, ditambahkan karena marker posisi bisa keluar layar begitu
/// peta digeser untuk lihat lapangan lain, dan tidak ada cara lain untuk
/// kembali selain geser manual.
class _TombolRecenter extends StatelessWidget {
  final VoidCallback onTap;

  const _TombolRecenter({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
          boxShadow: AppColors.shadowKartu,
        ),
        child: const Icon(
          Icons.my_location,
          size: 20,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class _PenandaPengguna extends StatelessWidget {
  const _PenandaPengguna();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 4),
        ],
      ),
    );
  }
}

class _PenandaLapangan extends StatelessWidget {
  final LapanganModel lapangan;

  const _PenandaLapangan({required this.lapangan});

  @override
  Widget build(BuildContext context) {
    final olahragaUtama =
        lapangan.jenisOlahraga.isNotEmpty ? lapangan.jenisOlahraga.first : '';

    return Container(
      decoration: BoxDecoration(
        color: _warnaOlahraga(olahragaUtama),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 4),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        AppSports.ikonDari(olahragaUtama),
        style: const TextStyle(fontSize: 18),
      ),
    );
  }

  Color _warnaOlahraga(String kode) {
    switch (kode) {
      case AppSports.futsal:
        return AppColors.futsal;
      case AppSports.badminton:
        return AppColors.badminton;
      case AppSports.padel:
        return AppColors.padel;
      case AppSports.miniSoccer:
        return AppColors.miniSoccer;
      default:
        return AppColors.surfaceVariant;
    }
  }
}

/// Kartu ringkas saat marker ditekan — PRD L-05, BB-10: nama, jarak,
/// harga, tombol menuju Detail (L-06).
class _KartuRingkas extends StatelessWidget {
  final LapanganModel lapangan;

  const _KartuRingkas({required this.lapangan});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppSizes.marginLayar),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusKartu),
        boxShadow: AppColors.shadowKartu,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lapangan.nama,
                  style: AppTextStyles.namaLapangan.copyWith(fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  lapangan.jarakKm != null
                      ? Formatter.jarak(lapangan.jarakKm!)
                      : '',
                  style: AppTextStyles.metaLapangan,
                ),
                const SizedBox(height: 4),
                Text(
                  '${Formatter.rupiahRingkas(lapangan.harga)}/jam',
                  style: AppTextStyles.harga,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) =>
                    DetailLapanganScreen(lapanganId: lapangan.lapanganId),
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusChip),
              ),
            ),
            child: const Text('Lihat', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

class _SpandukLokasiDefault extends StatelessWidget {
  const _SpandukLokasiDefault();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        boxShadow: AppColors.shadowKartu,
      ),
      child: const Text(
        AppStrings.spandukLokasiDefault,
        style: AppTextStyles.metaLapangan,
      ),
    );
  }
}

class _SpandukKosong extends StatelessWidget {
  const _SpandukKosong();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        boxShadow: AppColors.shadowKartu,
      ),
      child: const Text(
        AppStrings.kosongLapangan,
        style: AppTextStyles.metaLapangan,
      ),
    );
  }
}

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
