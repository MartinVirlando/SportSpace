import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/validators.dart';
import '../../../repositories/rating_repository.dart';
import '../viewmodel/balas_ulasan_viewmodel.dart';

/// Membuka bottom sheet Balas Ulasan untuk mitra pemilik lapangan — PRD
/// AB-22, v1.5 (T-66).
///
/// [teksAwal] diisi balasan lama kalau mitra mengganti balasannya, supaya
/// ia tidak mengetik ulang dari nol. Mengembalikan `true` kalau balasan
/// terkirim; daftar ulasannya sendiri hidup lewat `StreamBuilder`, jadi
/// pemanggil tidak perlu memuat ulang apa pun.
Future<bool?> showBalasUlasanSheet(
  BuildContext context, {
  required String ratingId,
  required String namaPengulas,
  String? teksAwal,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => ChangeNotifierProvider<BalasUlasanViewModel>(
      create: (context) => BalasUlasanViewModel(
        repository: context.read<RatingRepository>(),
      ),
      child: _BalasUlasanBody(
        ratingId: ratingId,
        namaPengulas: namaPengulas,
        teksAwal: teksAwal,
      ),
    ),
  );
}

class _BalasUlasanBody extends StatefulWidget {
  final String ratingId;
  final String namaPengulas;
  final String? teksAwal;

  const _BalasUlasanBody({
    required this.ratingId,
    required this.namaPengulas,
    required this.teksAwal,
  });

  @override
  State<_BalasUlasanBody> createState() => _BalasUlasanBodyState();
}

class _BalasUlasanBodyState extends State<_BalasUlasanBody> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _teksCtrl =
      TextEditingController(text: widget.teksAwal ?? '');

  @override
  void dispose() {
    _teksCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final vm = context.read<BalasUlasanViewModel>();
    final berhasil = await vm.kirim(
      ratingId: widget.ratingId,
      teks: _teksCtrl.text,
    );

    if (!mounted) return;

    if (berhasil) {
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(vm.pesanError ?? AppStrings.errGagalKirimBalasan),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<BalasUlasanViewModel>();

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSizes.marginLayar,
        20,
        AppSizes.marginLayar,
        20 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              AppStrings.judulBalasUlasan,
              style: AppTextStyles.judulSeksi,
            ),
            const SizedBox(height: 4),
            Text(widget.namaPengulas, style: AppTextStyles.metaLapangan),
            const SizedBox(height: 12),
            TextFormField(
              controller: _teksCtrl,
              maxLines: 4,
              maxLength: 500,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: AppStrings.labelBalasan,
              ),
              validator: Validators.balasan,
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
      ),
    );
  }
}
