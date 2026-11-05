import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/validators.dart';
import '../../../repositories/rating_repository.dart';
import '../viewmodel/beri_rating_viewmodel.dart';

/// Membuka modal Beri Rating (L-11) sebagai bottom sheet.
///
/// Mengembalikan `true` kalau rating berhasil terkirim, supaya pemanggil
/// (Detail Lapangan) tahu kapan harus memuat ulang datanya — layar itu
/// pakai `Future` sekali ambil (CLAUDE.md aturan 6), bukan stream, jadi
/// `ratingRata2` yang baru tidak otomatis ikut berubah sendiri.
///
/// Begitu dibuka, lembar ini memuat rating lama pengguna untuk lapangan itu
/// (kalau ada) dan mengisi bintang serta teksnya — rating itu satu per
/// pengguna, jadi mengirim ulang MENGGANTI, dan pengguna harus tahu itu.
Future<bool?> showBeriRatingSheet(
  BuildContext context, {
  required String lapanganId,
  required String userId,
  required String namaUser,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.warna.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => ChangeNotifierProvider<BeriRatingViewModel>(
      create: (context) => BeriRatingViewModel(
        repository: context.read<RatingRepository>(),
      )..muatRatingLama(userId: userId, lapanganId: lapanganId),
      child: _BeriRatingBody(
        lapanganId: lapanganId,
        userId: userId,
        namaUser: namaUser,
      ),
    ),
  );
}

class _BeriRatingBody extends StatefulWidget {
  final String lapanganId;
  final String userId;
  final String namaUser;

  const _BeriRatingBody({
    required this.lapanganId,
    required this.userId,
    required this.namaUser,
  });

  @override
  State<_BeriRatingBody> createState() => _BeriRatingBodyState();
}

class _BeriRatingBodyState extends State<_BeriRatingBody> {
  final _formKey = GlobalKey<FormState>();
  final _ulasanCtrl = TextEditingController();
  int _bintang = 0;
  String? _errBintang;

  late final BeriRatingViewModel _vm;

  /// Rating lama cukup diisikan SEKALI ke form. Kalau tidak, setiap
  /// `notifyListeners()` berikutnya (mis. saat tombol Kirim ditekan) akan
  /// menimpa apa yang sedang diketik pengguna.
  bool _sudahDiisiDariRatingLama = false;

  @override
  void initState() {
    super.initState();
    // Pemuatan rating lama sudah dimulai di `create` provider; di sini kita
    // hanya mendengarkan hasilnya (Flutter: `addListener` pada ChangeNotifier
    // memanggil fungsi kita tiap ada `notifyListeners()`).
    _vm = context.read<BeriRatingViewModel>();
    _vm.addListener(_isiDariRatingLama);
  }

  @override
  void dispose() {
    _vm.removeListener(_isiDariRatingLama);
    _ulasanCtrl.dispose();
    super.dispose();
  }

  void _isiDariRatingLama() {
    if (_sudahDiisiDariRatingLama) return;
    if (_vm.kondisiRatingLama != KondisiRatingLama.siap) return;
    _sudahDiisiDariRatingLama = true;

    final lama = _vm.ratingLama;
    if (lama == null) return; // belum pernah menilai: biarkan form kosong

    setState(() {
      _bintang = lama.nilaiRating;
      _ulasanCtrl.text = lama.ulasanTeks ?? '';
    });
  }

  Future<void> _submit() async {
    final formValid = _formKey.currentState?.validate() ?? false;
    setState(() => _errBintang = _bintang == 0 ? AppStrings.errPilihBintang : null);

    if (!formValid || _bintang == 0) return;

    final vm = context.read<BeriRatingViewModel>();
    final berhasil = await vm.kirim(
      lapanganId: widget.lapanganId,
      userId: widget.userId,
      namaUser: widget.namaUser,
      nilaiRating: _bintang,
      ulasanTeks:
          _ulasanCtrl.text.trim().isEmpty ? null : _ulasanCtrl.text.trim(),
    );

    if (!mounted) return;

    if (berhasil) {
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(vm.pesanError ?? AppStrings.errGagalKirimRating)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<BeriRatingViewModel>();
    final sudahPernahMenilai = vm.ratingLama != null;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSizes.marginLayar,
        20,
        AppSizes.marginLayar,
        20 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            sudahPernahMenilai ? AppStrings.ubahRating : AppStrings.beriRating,
            style: AppTextStyles.judulSeksi(context),
          ),
          const SizedBox(height: 16),
          switch (vm.kondisiRatingLama) {
            KondisiRatingLama.memuat => const SizedBox(
                height: 160,
                child: Center(child: CircularProgressIndicator()),
              ),
            KondisiRatingLama.gagal => _GagalMuatRatingLama(
                pesan: vm.pesanError ?? AppStrings.errTerjadiKesalahan,
                onCobaLagi: () => vm.muatRatingLama(
                  userId: widget.userId,
                  lapanganId: widget.lapanganId,
                ),
              ),
            KondisiRatingLama.siap => _formRating(vm, sudahPernahMenilai),
          },
        ],
      ),
    );
  }

  Widget _formRating(BeriRatingViewModel vm, bool sudahPernahMenilai) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (sudahPernahMenilai) ...[
            Text(
              AppStrings.ratingSudahAda,
              style: AppTextStyles.metaLapangan(context),
            ),
            const SizedBox(height: 8),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              final nilai = i + 1;
              return IconButton(
                onPressed: () => setState(() {
                  _bintang = nilai;
                  _errBintang = null;
                }),
                icon: Icon(
                  nilai <= _bintang ? Icons.star : Icons.star_border,
                  color: AppColors.primary,
                  size: 32,
                ),
              );
            }),
          ),
          if (_errBintang != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                _errBintang!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _ulasanCtrl,
            maxLines: 3,
            maxLength: 500,
            decoration: const InputDecoration(
              labelText: AppStrings.ulasanOpsional,
            ),
            validator: Validators.ulasan,
          ),
          const SizedBox(height: 12),
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
                : const Text(AppStrings.kirim),
          ),
        ],
      ),
    );
  }
}

/// Tampilan saat rating lama gagal dimuat. Form sengaja TIDAK dibuka dalam
/// keadaan kosong: kalau pengguna ternyata sudah pernah menilai, mengirim
/// dari form kosong akan menimpa ulasannya tanpa ia tahu.
class _GagalMuatRatingLama extends StatelessWidget {
  final String pesan;
  final VoidCallback onCobaLagi;

  const _GagalMuatRatingLama({required this.pesan, required this.onCobaLagi});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.error_outline,
          size: 40,
          color: context.warna.textSecondary,
        ),
        const SizedBox(height: 8),
        Text(
          pesan,
          textAlign: TextAlign.center,
          style: AppTextStyles.metaLapangan(context),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: onCobaLagi,
          child: const Text(AppStrings.cobaLagi),
        ),
      ],
    );
  }
}
