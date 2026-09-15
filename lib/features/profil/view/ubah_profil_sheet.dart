import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/validators.dart';
import '../../auth/viewmodel/auth_viewmodel.dart';

/// Batas ukuran foto MENTAH (sebelum Base64) — margin aman di bawah batas
/// 1 MB per dokumen Firestore. `maxWidth`/`maxHeight`/`imageQuality` di
/// bawah biasanya sudah menghasilkan file jauh lebih kecil dari ini;
/// pengaman ini hanya untuk kasus di luar dugaan (mis. galeri Android
/// mengembalikan file mentah tanpa kompresi di beberapa perangkat).
const _batasUkuranFotoBytes = 500 * 1024;

/// Bottom sheet "Edit Profil" — PRD L-13.
///
/// `nama`, `nomorTelepon`, dan foto profil (opsional, T-43 lanjutan) yang
/// bisa diubah. Foto diambil dari galeri lewat `image_picker` dan
/// disimpan sebagai Base64 di dokumen Firestore — BUKAN Firebase Storage
/// (PRD §12b), dan BUKAN URL seperti versi T-43 sebelumnya. `surel`
/// sengaja tidak ditampilkan sebagai field yang bisa diedit: itu email
/// Firebase Auth, mengubahnya butuh re-autentikasi dan PRD tidak
/// merinci alur itu.
///
/// Sama seperti `ubah_olahraga_favorit_sheet.dart`: tidak butuh
/// Repository/ViewModel baru, cukup `AuthViewModel` yang sudah global
/// (CLAUDE.md aturan 6). Sheet ini TIDAK `import cloud_firestore`.
Future<void> showUbahProfilSheet(
  BuildContext context, {
  required String namaSaatIni,
  required String nomorTeleponSaatIni,
  required String? fotoProfilBase64SaatIni,
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
      fotoProfilBase64SaatIni: fotoProfilBase64SaatIni,
    ),
  );
}

class _UbahProfilBody extends StatefulWidget {
  final String namaSaatIni;
  final String nomorTeleponSaatIni;
  final String? fotoProfilBase64SaatIni;

  const _UbahProfilBody({
    required this.namaSaatIni,
    required this.nomorTeleponSaatIni,
    required this.fotoProfilBase64SaatIni,
  });

  @override
  State<_UbahProfilBody> createState() => _UbahProfilBodyState();
}

class _UbahProfilBodyState extends State<_UbahProfilBody> {
  final _formKey = GlobalKey<FormState>();
  late final _controllerNama = TextEditingController(text: widget.namaSaatIni);
  late final _controllerTelepon =
      TextEditingController(text: widget.nomorTeleponSaatIni);
  late String? _fotoBase64 = widget.fotoProfilBase64SaatIni;
  bool _sedangProses = false;

  String get _inisial {
    final kata = _controllerNama.text.trim().split(RegExp(r'\s+'));
    if (kata.isEmpty || kata.first.isEmpty) return '?';
    final pertama = kata.first[0];
    final kedua = kata.length > 1 && kata.last.isNotEmpty ? kata.last[0] : '';
    return (pertama + kedua).toUpperCase();
  }

  Uint8List? get _fotoBytes {
    final b64 = _fotoBase64;
    if (b64 == null || b64.isEmpty) return null;
    try {
      return base64Decode(b64);
    } catch (_) {
      // Data rusak (seharusnya tidak pernah terjadi lewat alur normal) —
      // jatuh balik ke inisial daripada crash.
      return null;
    }
  }

  @override
  void dispose() {
    _controllerNama.dispose();
    _controllerTelepon.dispose();
    super.dispose();
  }

  /// Buka galeri, kompres di titik pengambilan (`maxWidth`/`maxHeight`/
  /// `imageQuality` — bawaan `image_picker`, tanpa paket tambahan), lalu
  /// encode ke Base64. PRD §12b: ini TETAP tanpa Firebase Storage/Blaze —
  /// foto disimpan langsung di dokumen `users/{uid}`.
  Future<void> _pilihFoto() async {
    try {
      final berkas = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 70,
      );
      if (berkas == null) return; // dibatalkan pengguna

      final bytes = await berkas.readAsBytes();
      if (bytes.lengthInBytes > _batasUkuranFotoBytes) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text(AppStrings.errFotoTerlaluBesar)),
          );
        }
        return;
      }

      setState(() => _fotoBase64 = base64Encode(bytes));
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.errGagalPilihFoto)),
        );
      }
    }
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _sedangProses = true);

    final berhasil = await context.read<AuthViewModel>().ubahProfil(
          nama: _controllerNama.text.trim(),
          nomorTelepon: _controllerTelepon.text.trim(),
          fotoProfilBase64: _fotoBase64 ?? '',
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
    final fotoBytes = _fotoBytes;

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
            Center(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _sedangProses ? null : _pilihFoto,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: AppColors.primary,
                          backgroundImage:
                              fotoBytes != null ? MemoryImage(fotoBytes) : null,
                          child: fotoBytes == null
                              ? Text(
                                  _inisial,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                  ),
                                )
                              : null,
                        ),
                        Positioned(
                          right: -2,
                          bottom: -2,
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.surface,
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextButton(
                    onPressed: _sedangProses ? null : _pilihFoto,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 0),
                    ),
                    child: Text(
                      fotoBytes == null
                          ? AppStrings.pilihFoto
                          : AppStrings.gantiFoto,
                    ),
                  ),
                  if (fotoBytes != null)
                    TextButton(
                      onPressed: _sedangProses
                          ? null
                          : () => setState(() => _fotoBase64 = null),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                      ),
                      child: const Text(
                        AppStrings.hapusFoto,
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _controllerNama,
              decoration: const InputDecoration(labelText: AppStrings.nama),
              validator: (v) => Validators.wajib(v, AppStrings.nama),
              onChanged: (_) => setState(() {}), // inisial ikut berubah
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
