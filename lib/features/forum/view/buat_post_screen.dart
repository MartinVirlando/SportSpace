import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../auth/viewmodel/auth_viewmodel.dart';
import '../../../repositories/forum_repository.dart';
import '../viewmodel/buat_post_viewmodel.dart';

/// Batas ukuran gambar MENTAH (sebelum Base64) — sama persis dengan pola
/// `ubah_profil_sheet.dart`: margin aman di bawah batas 1 MB per dokumen
/// Firestore.
const _batasUkuranGambarBytes = 500 * 1024;

/// Layar "Buat Post" forum — input teks + gambar opsional.
///
/// ATURAN LAPISAN (CLAUDE.md): TIDAK ADA `cloud_firestore` di sini.
/// Sama seperti `ubah_profil_sheet.dart`: `ImagePicker` dan konversi
/// Base64 dikerjakan di View (butuh `BuildContext` untuk SnackBar),
/// `BuatPostViewModel` hanya menerima String Base64 yang sudah jadi.
class BuatPostScreen extends StatelessWidget {
  const BuatPostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<BuatPostViewModel>(
      create: (context) => BuatPostViewModel(
        repository: context.read<ForumRepository>(),
      ),
      child: const _BuatPostBody(),
    );
  }
}

class _BuatPostBody extends StatefulWidget {
  const _BuatPostBody();

  @override
  State<_BuatPostBody> createState() => _BuatPostBodyState();
}

class _BuatPostBodyState extends State<_BuatPostBody> {
  final _controllerTeks = TextEditingController();
  String? _gambarBase64;

  Uint8List? get _gambarBytes {
    final b64 = _gambarBase64;
    if (b64 == null || b64.isEmpty) return null;
    try {
      return base64Decode(b64);
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    _controllerTeks.dispose();
    super.dispose();
  }

  /// Sama persis pola `_pilihFoto` di `ubah_profil_sheet.dart`: ambil dari
  /// galeri, kompres di titik pengambilan, cek batas ukuran, encode Base64.
  Future<void> _pilihGambar() async {
    try {
      final berkas = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 70,
      );
      if (berkas == null) return; // dibatalkan pengguna

      final bytes = await berkas.readAsBytes();
      if (bytes.lengthInBytes > _batasUkuranGambarBytes) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text(AppStrings.errFotoTerlaluBesar)),
          );
        }
        return;
      }

      setState(() => _gambarBase64 = base64Encode(bytes));
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.errGagalPilihFoto)),
        );
      }
    }
  }

  Future<void> _kirim() async {
    final teks = _controllerTeks.text.trim();
    if (teks.isEmpty && _gambarBase64 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.errPostKosong)),
      );
      return;
    }

    final user = context.read<AuthViewModel>().user;
    if (user == null) return; // pengaman, seharusnya tidak pernah terjadi

    final error = await context.read<BuatPostViewModel>().kirimPost(
          userId: user.userId,
          namaUser: user.nama,
          teks: teks,
          gambarBase64: _gambarBase64,
        );

    if (!mounted) return;

    if (error == null) {
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final sedangMengirim = context.watch<BuatPostViewModel>().sedangMengirim;
    final bytes = _gambarBytes;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text(AppStrings.buatPost, style: AppTextStyles.judulSeksi),
        actions: [
          TextButton(
            onPressed: sedangMengirim ? null : _kirim,
            child: sedangMengirim
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(AppStrings.kirim),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.marginLayar),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _controllerTeks,
                maxLines: 6,
                minLines: 3,
                enabled: !sedangMengirim,
                decoration: const InputDecoration(
                  hintText: AppStrings.hintBuatPost,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              if (bytes != null) ...[
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppSizes.radiusChip),
                      child: Image.memory(
                        bytes,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      right: 6,
                      top: 6,
                      child: GestureDetector(
                        onTap: sedangMengirim
                            ? null
                            : () => setState(() => _gambarBase64 = null),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close,
                              size: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
              OutlinedButton.icon(
                onPressed: sedangMengirim ? null : _pilihGambar,
                icon: const Icon(Icons.image_outlined),
                label: Text(
                  bytes == null ? AppStrings.pilihFoto : AppStrings.gantiFoto,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}