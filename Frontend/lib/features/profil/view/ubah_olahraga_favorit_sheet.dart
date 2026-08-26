import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sports.dart';
import '../../../core/constants/app_strings.dart';
import '../../auth/viewmodel/auth_viewmodel.dart';

/// Bottom sheet "Ubah Olahraga Favorit" — PRD L-13, T-37.
///
/// Tidak butuh Repository/ViewModel baru: AuthViewModel sudah global
/// (CLAUDE.md aturan 6) dan sudah punya `ubahOlahragaFavorit()`, jadi
/// sheet ini cukup menyuntingnya langsung — sama seperti sheet ini
/// TIDAK `import cloud_firestore` (aturan lapisan tetap berlaku).
Future<void> showUbahOlahragaFavoritSheet(
  BuildContext context, {
  required List<String> olahragaFavoritSaatIni,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => _UbahOlahragaFavoritBody(
      olahragaFavoritSaatIni: olahragaFavoritSaatIni,
    ),
  );
}

const _daftarOlahraga = [
  AppSports.futsal,
  AppSports.miniSoccer,
  AppSports.badminton,
  AppSports.padel,
];

class _UbahOlahragaFavoritBody extends StatefulWidget {
  final List<String> olahragaFavoritSaatIni;

  const _UbahOlahragaFavoritBody({required this.olahragaFavoritSaatIni});

  @override
  State<_UbahOlahragaFavoritBody> createState() =>
      _UbahOlahragaFavoritBodyState();
}

class _UbahOlahragaFavoritBodyState extends State<_UbahOlahragaFavoritBody> {
  late final Set<String> _terpilih = {...widget.olahragaFavoritSaatIni};
  bool _sedangProses = false;

  Future<void> _simpan() async {
    setState(() => _sedangProses = true);

    final berhasil = await context
        .read<AuthViewModel>()
        .ubahOlahragaFavorit(_terpilih.toList());

    if (!mounted) return;
    setState(() => _sedangProses = false);

    if (berhasil) {
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.read<AuthViewModel>().pesanError ??
                'Gagal menyimpan olahraga favorit.',
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(AppStrings.olahragaFavorit, style: AppTextStyles.judulSeksi),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _daftarOlahraga.map((kode) {
              final aktif = _terpilih.contains(kode);
              return FilterChip(
                label: Text('${AppSports.ikonDari(kode)} ${AppSports.labelDari(kode)}'),
                selected: aktif,
                onSelected: (dipilih) => setState(() {
                  if (dipilih) {
                    _terpilih.add(kode);
                  } else {
                    _terpilih.remove(kode);
                  }
                }),
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: aktif ? Colors.white : AppColors.textPrimary,
                ),
              );
            }).toList(),
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
    );
  }
}
