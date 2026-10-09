import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/formatter.dart';
import '../../../models/forum_post_model.dart';
import '../../../repositories/forum_repository.dart';
import '../viewmodel/forum_viewmodel.dart';
import 'buat_post_screen.dart';
import 'detail_post_screen.dart';

/// Tab/halaman Forum — daftar post, terbaru dulu.
///
/// ATURAN LAPISAN (CLAUDE.md): TIDAK ADA `cloud_firestore` di sini.
/// Daftar post langsung hidup lewat `StreamBuilder` (lihat catatan di
/// `ForumViewModel`), bukan state manual seperti `HomeViewModel`.
class ForumScreen extends StatelessWidget {
  const ForumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ForumViewModel>(
      create: (context) => ForumViewModel(
        repository: context.read<ForumRepository>(),
      ),
      child: const _ForumBody(),
    );
  }
}

class _ForumBody extends StatelessWidget {
  const _ForumBody();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ForumViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text(AppStrings.forum, style: AppTextStyles.judulSeksi),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const BuatPostScreen()),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
        child: StreamBuilder<List<ForumPostModel>>(
          stream: vm.streamPosts,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return _Pesan(
                ikon: Icons.error_outline,
                judul: AppStrings.errGagalMuat,
                keterangan:
                    snapshot.error.toString().replaceFirst('Exception: ', ''),
              );
            }

            final daftar = snapshot.data ?? const [];
            if (daftar.isEmpty) {
              return const _Pesan(
                ikon: Icons.forum_outlined,
                judul: AppStrings.kosongForum,
                keterangan: '',
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(AppSizes.marginLayar),
              itemCount: daftar.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final post = daftar[i];
                return _KartuPost(
                  post: post,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => DetailPostScreen(post: post),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

/// Kartu satu post di daftar forum. Gambar (opsional) ditampilkan lewat
/// `Image.memory` setelah decode Base64 — pola sama seperti
/// `_AvatarProfil` di `profil_screen.dart`, dibungkus try/catch supaya
/// data rusak tidak membuat layar crash, cukup tidak menampilkan gambar.
class _KartuPost extends StatelessWidget {
  final ForumPostModel post;
  final VoidCallback onTap;

  const _KartuPost({required this.post, required this.onTap});

  Uint8List? get _gambarBytes {
    final b64 = post.gambarBase64;
    if (b64 == null || b64.isEmpty) return null;
    try {
      return base64Decode(b64);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bytes = _gambarBytes;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusKartu),
      child: Container(
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
            Text(post.namaUser, style: AppTextStyles.namaLapangan),
            const SizedBox(height: 4),
            Text(
              post.teks,
              style: AppTextStyles.metaLapangan,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
            if (bytes != null) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSizes.radiusChip),
                child: Image.memory(
                  bytes,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  Formatter.tanggalDanJam(post.createdAt),
                  style: AppTextStyles.metaLapangan,
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.chat_bubble_outline,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${post.jumlahKomentar}',
                      style: AppTextStyles.metaLapangan,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Pesan extends StatelessWidget {
  final IconData ikon;
  final String judul;
  final String keterangan;

  const _Pesan({
    required this.ikon,
    required this.judul,
    required this.keterangan,
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
            Text(
              judul,
              style: AppTextStyles.judulSeksi,
              textAlign: TextAlign.center,
            ),
            if (keterangan.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                keterangan,
                textAlign: TextAlign.center,
                style: AppTextStyles.lokasi,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
