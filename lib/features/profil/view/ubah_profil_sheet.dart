import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/validators.dart';
import '../../auth/viewmodel/auth_viewmodel.dart';

/// Bottom sheet "Edit Profil" — PRD L-13.
///
/// Hanya `nama` dan `nomorTelepon` yang bisa diubah. `surel` sengaja
/// tidak ditampilkan sebagai field yang bisa diedit: itu email Firebase
/// Auth, mengubahnya butuh re-autentikasi dan PRD tidak merinci alur itu.
///
/// Sama seperti `ubah_olahraga_favorit_sheet.dart`: tidak butuh
/// Repository/ViewModel baru, cukup `AuthViewModel` yang sudah global
/// (CLAUDE.md aturan 6). Sheet ini TIDAK `import cloud_firestore`.
Future<void> showUbahProfilSheet(
  BuildContext context, {
  required String namaSaatIni,
  required String nomorTeleponSaatIni,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => _UbahProfilBody(
      namaSaatIni: namaSaatIni,
      nomorTeleponSaatIni: nomorTeleponSaatIni,
    ),
  );
}

class _UbahProfilBody extends StatefulWidget {
  final String namaSaatIni;
  final String nomorTeleponSaatIni;

  const _UbahProfilBody({
    required this.namaSaatIni,
    required this.nomorTeleponSaatIni,
  });

  @override
  State<_UbahProfilBody> createState() => _UbahProfilBodyState();
}

class _UbahProfilBodyState extends State<_UbahProfilBody> {
  final _formKey = GlobalKey<FormState>();
  late final _controllerNama = TextEditingController(text: widget.namaSaatIni);
  late final _controllerTelepon =
      TextEditingController(text: widget.nomorTeleponSaatIni);
  bool _sedangProses = false;

  @override
  void dispose() {
    _controllerNama.dispose();
    _controllerTelepon.dispose();
    super.dispose();
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _sedangProses = true);

    final berhasil = await context.read<AuthViewModel>().ubahProfil(
          nama: _controllerNama.text.trim(),
          nomorTelepon: _controllerTelepon.text.trim(),
        );

    if (!mounted) return;
    setState(() => _sedangProses = false);

    if (berhasil) {
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.read<AuthViewModel>().pesanError ?? 'Gagal menyimpan profil.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
            const Text(AppStrings.editProfil, style: AppTextStyles.judulSeksi),
            const SizedBox(height: 16),
            TextFormField(
              controller: _controllerNama,
              decoration: const InputDecoration(labelText: AppStrings.nama),
              validator: (v) => Validators.wajib(v, AppStrings.nama),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _controllerTelepon,
              keyboardType: TextInputType.phone,
              decoration:
                  const InputDecoration(labelText: AppStrings.nomorTelepon),
              validator: Validators.nomorTelepon,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _sedangProses ? null : _simpan,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusChip),
                ),
              ),
              child: _sedangProses
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
    );
  }
}
