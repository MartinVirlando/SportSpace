import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sports.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/validators.dart';
import '../../../repositories/aktivitas_repository.dart';
import '../../../repositories/lapangan_repository.dart';
import '../../auth/viewmodel/auth_viewmodel.dart';
import '../viewmodel/buat_aktivitas_viewmodel.dart';

/// Halaman Buat Aktivitas — PRD L-08. BB-14 (data valid), BB-15 (waktu
/// di masa lalu ditolak).
///
/// ATURAN LAPISAN (CLAUDE.md): TIDAK ADA `cloud_firestore` di sini.
class BuatAktivitasScreen extends StatelessWidget {
  const BuatAktivitasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<BuatAktivitasViewModel>(
      create: (context) => BuatAktivitasViewModel(
        aktivitasRepository: context.read<AktivitasRepository>(),
        lapanganRepository: context.read<LapanganRepository>(),
      )..muatDaftarLapangan(),
      child: const _BuatAktivitasBody(),
    );
  }
}

class _BuatAktivitasBody extends StatefulWidget {
  const _BuatAktivitasBody();

  @override
  State<_BuatAktivitasBody> createState() => _BuatAktivitasBodyState();
}

class _BuatAktivitasBodyState extends State<_BuatAktivitasBody> {
  final _formKey = GlobalKey<FormState>();
  final _jumlahPemainCtrl = TextEditingController();
  final _catatanCtrl = TextEditingController();

  String _olahraga = AppSports.futsal;
  String? _lapanganId;
  DateTime? _tanggal;
  TimeOfDay? _jam;

  @override
  void dispose() {
    _jumlahPemainCtrl.dispose();
    _catatanCtrl.dispose();
    super.dispose();
  }

  DateTime? get _waktuGabungan {
    if (_tanggal == null || _jam == null) return null;
    return DateTime(
      _tanggal!.year,
      _tanggal!.month,
      _tanggal!.day,
      _jam!.hour,
      _jam!.minute,
    );
  }

  Future<void> _pilihTanggal() async {
    final sekarang = DateTime.now();
    final hasil = await showDatePicker(
      context: context,
      initialDate: _tanggal ?? sekarang,
      firstDate: sekarang,
      lastDate: sekarang.add(const Duration(days: 365)),
    );
    if (hasil != null) setState(() => _tanggal = hasil);
  }

  Future<void> _pilihJam() async {
    final hasil = await showTimePicker(
      context: context,
      initialTime: _jam ?? TimeOfDay.now(),
    );
    if (hasil != null) setState(() => _jam = hasil);
  }

  Future<void> _submit() async {
    final formValid = _formKey.currentState?.validate() ?? false;
    final waktu = _waktuGabungan;
    final errWaktu = Validators.waktuDiMasaDepan(waktu);

    if (!formValid || _lapanganId == null || errWaktu != null) {
      setState(() {}); // supaya pesan lapangan/waktu ikut tampil ulang
      if (errWaktu != null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(errWaktu)));
      } else if (_lapanganId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lapangan wajib dipilih.')),
        );
      }
      return;
    }

    final vm = context.read<BuatAktivitasViewModel>();
    final user = context.read<AuthViewModel>().user;
    if (user == null) return;

    final lapangan =
        vm.daftarLapangan.firstWhere((l) => l.lapanganId == _lapanganId);

    final berhasil = await vm.buatAktivitas(
      jenisOlahraga: _olahraga,
      jumlahPemainDibutuhkan: int.parse(_jumlahPemainCtrl.text),
      waktu: waktu!,
      lapanganId: lapangan.lapanganId,
      namaLapangan: lapangan.nama,
      pembuatId: user.userId,
      namaPembuat: user.nama,
      catatan:
          _catatanCtrl.text.trim().isEmpty ? null : _catatanCtrl.text.trim(),
    );

    if (!mounted) return;

    if (berhasil) {
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(vm.pesanError ?? 'Gagal membuat aktivitas.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<BuatAktivitasViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text(
          AppStrings.buatAktivitas,
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
                const Text('Olahraga', style: AppTextStyles.judulSeksi),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    AppSports.futsal,
                    AppSports.miniSoccer,
                    AppSports.badminton,
                    AppSports.padel,
                  ].map((kode) {
                    final aktif = kode == _olahraga;
                    return ChoiceChip(
                      label: Text(
                        '${AppSports.ikonDari(kode)} ${AppSports.labelDari(kode)}',
                      ),
                      selected: aktif,
                      onSelected: (_) => setState(() => _olahraga = kode),
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: aktif ? Colors.white : AppColors.textPrimary,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                const Text('Lapangan', style: AppTextStyles.judulSeksi),
                const SizedBox(height: 8),
                _DropdownLapangan(
                  vm: vm,
                  nilai: _lapanganId,
                  onUbah: (id) => setState(() => _lapanganId = id),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _TombolPilih(
                        label: 'Tanggal',
                        nilai: _tanggal == null
                            ? 'Pilih tanggal'
                            : DateFormat('d MMM yyyy', 'id_ID')
                                .format(_tanggal!),
                        onTap: _pilihTanggal,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _TombolPilih(
                        label: 'Jam',
                        nilai:
                            _jam == null ? 'Pilih jam' : _jam!.format(context),
                        onTap: _pilihJam,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _jumlahPemainCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Jumlah Pemain Dibutuhkan',
                    hintText: '2 – 30',
                  ),
                  validator: Validators.jumlahPemain,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _catatanCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Catatan (opsional)',
                  ),
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
                      : const Text(AppStrings.buatAktivitas),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DropdownLapangan extends StatelessWidget {
  final BuatAktivitasViewModel vm;
  final String? nilai;
  final ValueChanged<String?> onUbah;

  const _DropdownLapangan({
    required this.vm,
    required this.nilai,
    required this.onUbah,
  });

  @override
  Widget build(BuildContext context) {
    switch (vm.kondisiLapangan) {
      case KondisiDaftarLapangan.memuat:
        return const LinearProgressIndicator();
      case KondisiDaftarLapangan.gagal:
        return Row(
          children: [
            const Expanded(
              child: Text(
                'Gagal memuat daftar lapangan.',
                style: AppTextStyles.metaLapangan,
              ),
            ),
            TextButton(
              onPressed: () =>
                  context.read<BuatAktivitasViewModel>().muatDaftarLapangan(),
              child: const Text(AppStrings.cobaLagi),
            ),
          ],
        );
      case KondisiDaftarLapangan.berhasil:
        if (vm.daftarLapangan.isEmpty) {
          return const Text(
            'Belum ada lapangan terdaftar.',
            style: AppTextStyles.metaLapangan,
          );
        }
        return DropdownButtonFormField<String>(
          initialValue: nilai,
          decoration: const InputDecoration(hintText: 'Pilih lapangan'),
          items: vm.daftarLapangan
              .map(
                (l) => DropdownMenuItem(
                  value: l.lapanganId,
                  child: Text(l.nama, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          onChanged: onUbah,
        );
    }
  }
}

class _TombolPilih extends StatelessWidget {
  final String label;
  final String nilai;
  final VoidCallback onTap;

  const _TombolPilih({
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
