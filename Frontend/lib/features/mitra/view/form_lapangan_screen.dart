import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sports.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/services/location_service.dart';
import '../../../core/utils/validators.dart';
import '../../../models/lapangan_model.dart';
import '../../../repositories/lapangan_repository.dart';
import '../../auth/viewmodel/auth_viewmodel.dart';
import '../viewmodel/form_lapangan_viewmodel.dart';

/// Fasilitas yang bisa dipilih mitra — kosakata yang sama dipakai
/// `SEED-DATA.md`/`seed_lapangan.dart`, bukan daftar baku dari PRD.
const _daftarFasilitas = [
  'parkir',
  'toilet',
  'kantin',
  'ruang ganti',
  'mushola',
  'shower',
];

/// Halaman Tambah/Edit Lapangan — PRD L-15, T-26. BB-29 (tambah lapangan
/// baru tampil di pencarian dengan `isMitra: true`).
///
/// ATURAN LAPISAN (CLAUDE.md): TIDAK ADA `cloud_firestore` di sini.
///
/// [lapangan] `null` → mode Tambah. Diisi → mode Edit, form terisi dari
/// data yang ada; `isMitra`/`pemilikId`/`sumberData`/field rating TIDAK
/// bisa diubah lewat form ini (lihat `FormLapanganViewModel.perbaruiLapangan`).
class FormLapanganScreen extends StatelessWidget {
  final LapanganModel? lapangan;

  const FormLapanganScreen({super.key, this.lapangan});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<FormLapanganViewModel>(
      create: (context) => FormLapanganViewModel(
        repository: context.read<LapanganRepository>(),
      ),
      child: _FormLapanganBody(lapangan: lapangan),
    );
  }
}

class _FormLapanganBody extends StatefulWidget {
  final LapanganModel? lapangan;

  const _FormLapanganBody({required this.lapangan});

  @override
  State<_FormLapanganBody> createState() => _FormLapanganBodyState();
}

class _FormLapanganBodyState extends State<_FormLapanganBody> {
  final _formKey = GlobalKey<FormState>();
  final _namaCtrl = TextEditingController();
  final _alamatCtrl = TextEditingController();
  final _latCtrl = TextEditingController();
  final _lonCtrl = TextEditingController();
  final _hargaCtrl = TextEditingController();
  final _fotoCtrl = TextEditingController();

  final Set<String> _jenisOlahraga = {};
  final Set<String> _fasilitas = {};
  TimeOfDay? _jamBuka;
  TimeOfDay? _jamTutup;
  bool _sedangAmbilLokasi = false;
  String? _errOlahraga;
  String? _errJam;

  bool get _modeEdit => widget.lapangan != null;

  @override
  void initState() {
    super.initState();
    final l = widget.lapangan;
    if (l != null) {
      _namaCtrl.text = l.nama;
      _alamatCtrl.text = l.alamat;
      _latCtrl.text = l.latitude.toString();
      _lonCtrl.text = l.longitude.toString();
      _hargaCtrl.text = l.harga.toString();
      _fotoCtrl.text = l.fotoURL.isEmpty ? '' : l.fotoURL.first;
      _jenisOlahraga.addAll(l.jenisOlahraga);
      _fasilitas.addAll(l.fasilitas);
      _jamBuka = _parseJam(l.jamBuka);
      _jamTutup = _parseJam(l.jamTutup);
    }
  }

  TimeOfDay _parseJam(String hhmm) {
    final bagian = hhmm.split(':');
    return TimeOfDay(hour: int.parse(bagian[0]), minute: int.parse(bagian[1]));
  }

  String _formatJam(TimeOfDay jam) =>
      '${jam.hour.toString().padLeft(2, '0')}:${jam.minute.toString().padLeft(2, '0')}';

  @override
  void dispose() {
    _namaCtrl.dispose();
    _alamatCtrl.dispose();
    _latCtrl.dispose();
    _lonCtrl.dispose();
    _hargaCtrl.dispose();
    _fotoCtrl.dispose();
    super.dispose();
  }

  Future<void> _pilihJamBuka() async {
    final hasil = await showTimePicker(
      context: context,
      initialTime: _jamBuka ?? const TimeOfDay(hour: 8, minute: 0),
    );
    if (hasil != null) setState(() => _jamBuka = hasil);
  }

  Future<void> _pilihJamTutup() async {
    final hasil = await showTimePicker(
      context: context,
      initialTime: _jamTutup ?? const TimeOfDay(hour: 22, minute: 0),
    );
    if (hasil != null) setState(() => _jamTutup = hasil);
  }

  Future<void> _ambilLokasi() async {
    setState(() => _sedangAmbilLokasi = true);
    final hasil = await context.read<LocationService>().ambilPosisi();
    if (!mounted) return;
    setState(() => _sedangAmbilLokasi = false);

    if (hasil.ada) {
      setState(() {
        _latCtrl.text = hasil.latitude!.toStringAsFixed(6);
        _lonCtrl.text = hasil.longitude!.toStringAsFixed(6);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.errGagalAmbilLokasi)),
      );
    }
  }

  Future<void> _submit() async {
    final formValid = _formKey.currentState?.validate() ?? false;

    setState(() {
      _errOlahraga =
          _jenisOlahraga.isEmpty ? AppStrings.errPilihOlahraga : null;
      _errJam = (_jamBuka == null || _jamTutup == null)
          ? 'Jam buka dan tutup wajib diisi.'
          : (_jamTutup!.hour * 60 + _jamTutup!.minute <=
                  _jamBuka!.hour * 60 + _jamBuka!.minute)
              ? 'Jam tutup harus setelah jam buka.'
              : null;
    });

    if (!formValid || _errOlahraga != null || _errJam != null) return;

    final user = context.read<AuthViewModel>().user;
    if (user == null) return;

    final vm = context.read<FormLapanganViewModel>();
    final fotoURL =
        _fotoCtrl.text.trim().isEmpty ? <String>[] : [_fotoCtrl.text.trim()];

    final berhasil = _modeEdit
        ? await vm.perbaruiLapangan(
            widget.lapangan!,
            nama: _namaCtrl.text.trim(),
            alamat: _alamatCtrl.text.trim(),
            latitude: double.parse(_latCtrl.text.trim()),
            longitude: double.parse(_lonCtrl.text.trim()),
            jenisOlahraga: _jenisOlahraga.toList(),
            harga: int.parse(_hargaCtrl.text.trim()),
            jamBuka: _formatJam(_jamBuka!),
            jamTutup: _formatJam(_jamTutup!),
            fasilitas: _fasilitas.toList(),
            fotoURL: fotoURL,
          )
        : await vm.tambahLapangan(
            nama: _namaCtrl.text.trim(),
            alamat: _alamatCtrl.text.trim(),
            latitude: double.parse(_latCtrl.text.trim()),
            longitude: double.parse(_lonCtrl.text.trim()),
            jenisOlahraga: _jenisOlahraga.toList(),
            harga: int.parse(_hargaCtrl.text.trim()),
            jamBuka: _formatJam(_jamBuka!),
            jamTutup: _formatJam(_jamTutup!),
            fasilitas: _fasilitas.toList(),
            fotoURL: fotoURL,
            pemilikId: user.userId,
          );

    if (!mounted) return;

    if (berhasil) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.lapanganTersimpan)),
      );
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(vm.pesanError ?? 'Gagal menyimpan lapangan.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<FormLapanganViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          _modeEdit
              ? AppStrings.editLapanganJudul
              : AppStrings.tambahLapanganJudul,
          style: AppTextStyles.judulSeksi,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.marginLayar),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _namaCtrl,
                  decoration: const InputDecoration(labelText: AppStrings.nama),
                  validator: (v) => Validators.wajib(v, AppStrings.nama),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _alamatCtrl,
                  decoration:
                      const InputDecoration(labelText: AppStrings.alamat),
                  validator: (v) => Validators.wajib(v, AppStrings.alamat),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _latCtrl,
                        keyboardType:
                            const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: AppStrings.latitude,
                        ),
                        validator: (v) => Validators.koordinat(
                          v,
                          namaField: AppStrings.latitude,
                          min: -90,
                          max: 90,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _lonCtrl,
                        keyboardType:
                            const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: AppStrings.longitude,
                        ),
                        validator: (v) => Validators.koordinat(
                          v,
                          namaField: AppStrings.longitude,
                          min: -180,
                          max: 180,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: _sedangAmbilLokasi ? null : _ambilLokasi,
                    icon: _sedangAmbilLokasi
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.my_location, size: 16),
                    label: const Text(AppStrings.ambilLokasiSaatIni),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 0),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  AppStrings.jenisOlahraga,
                  style: AppTextStyles.judulSeksi,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    AppSports.futsal,
                    AppSports.miniSoccer,
                    AppSports.badminton,
                    AppSports.padel,
                  ].map((kode) {
                    final aktif = _jenisOlahraga.contains(kode);
                    return FilterChip(
                      label: Text(
                        '${AppSports.ikonDari(kode)} ${AppSports.labelDari(kode)}',
                      ),
                      selected: aktif,
                      onSelected: (dipilih) => setState(() {
                        if (dipilih) {
                          _jenisOlahraga.add(kode);
                        } else {
                          _jenisOlahraga.remove(kode);
                        }
                        _errOlahraga = null;
                      }),
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: aktif ? Colors.white : AppColors.textPrimary,
                      ),
                    );
                  }).toList(),
                ),
                if (_errOlahraga != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      _errOlahraga!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _hargaCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: AppStrings.harga,
                    hintText: 'Rupiah per jam',
                  ),
                  validator: Validators.harga,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _TombolPilihJam(
                        label: AppStrings.jamBuka,
                        nilai: _jamBuka == null
                            ? 'Pilih jam'
                            : _jamBuka!.format(context),
                        onTap: _pilihJamBuka,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _TombolPilihJam(
                        label: AppStrings.jamTutup,
                        nilai: _jamTutup == null
                            ? 'Pilih jam'
                            : _jamTutup!.format(context),
                        onTap: _pilihJamTutup,
                      ),
                    ),
                  ],
                ),
                if (_errJam != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      _errJam!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                const SizedBox(height: 20),
                const Text(AppStrings.fasilitas, style: AppTextStyles.judulSeksi),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _daftarFasilitas.map((f) {
                    final aktif = _fasilitas.contains(f);
                    return FilterChip(
                      label: Text(f),
                      selected: aktif,
                      onSelected: (dipilih) => setState(() {
                        if (dipilih) {
                          _fasilitas.add(f);
                        } else {
                          _fasilitas.remove(f);
                        }
                      }),
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: aktif ? Colors.white : AppColors.textPrimary,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _fotoCtrl,
                  keyboardType: TextInputType.url,
                  decoration: const InputDecoration(
                    labelText: AppStrings.urlFotoOpsional,
                  ),
                  validator: Validators.urlOpsional,
                ),
                const SizedBox(height: 28),
                ElevatedButton(
                  onPressed: vm.sedangProses ? null : _submit,
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
                      : const Text(AppStrings.simpan),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TombolPilihJam extends StatelessWidget {
  final String label;
  final String nilai;
  final VoidCallback onTap;

  const _TombolPilihJam({
    required this.label,
    required this.nilai,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.surfaceVariant, width: 1.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.metaLapangan),
            const SizedBox(height: 2),
            Text(nilai, style: AppTextStyles.namaLapangan),
          ],
        ),
      ),
    );
  }
}
