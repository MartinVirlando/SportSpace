import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/formatter.dart';
import '../../../models/forum_komentar_model.dart';
import '../../../models/forum_post_model.dart';
import '../../../repositories/forum_repository.dart';
import '../../auth/viewmodel/auth_viewmodel.dart';
import '../viewmodel/detail_post_viewmodel.dart';
import 'buat_post_screen.dart';

/// Layar Detail Post forum — isi post lengkap + komentar.
///
/// ATURAN LAPISAN (CLAUDE.md): TIDAK ADA `cloud_firestore` di sini.
/// Objek [post] dioper dari daftar forum. Setelah diedit, versi terbaru
/// dikembalikan oleh `BuatPostScreen` dan disimpan di state layar ini.
class DetailPostScreen extends StatelessWidget {
  final ForumPostModel post;

  const DetailPostScreen({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<DetailPostViewModel>(
      create: (context) => DetailPostViewModel(
        repository: context.read<ForumRepository>(),
        postId: post.id,
      ),
      child: _DetailPostBody(post: post),
    );
  }
}

class _DetailPostBody extends StatefulWidget {
  final ForumPostModel post;

  const _DetailPostBody({required this.post});

  @override
  State<_DetailPostBody> createState() => _DetailPostBodyState();
}

class _DetailPostBodyState extends State<_DetailPostBody> {
  final _controllerKomentar = TextEditingController();

  /// Salinan post yang ditampilkan. Awalnya sama dengan `widget.post`,
  /// diganti setelah pemilik mengedit.
  late ForumPostModel _post = widget.post;

  @override
  void dispose() {
    _controllerKomentar.dispose();
    super.dispose();
  }

  Future<void> _kirimKomentar() async {
    final teks = _controllerKomentar.text.trim();
    if (teks.isEmpty) return;

    final user = context.read<AuthViewModel>().user;
    if (user == null) return; // pengaman

    final error = await context.read<DetailPostViewModel>().kirimKomentar(
          userId: user.userId,
          namaUser: user.nama,
          teks: teks,
        );

    if (!mounted) return;

    if (error == null) {
      _controllerKomentar.clear();
      FocusScope.of(context).unfocus(); // tutup keyboard
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    }
  }

  Future<void> _edit() async {
    final hasil = await Navigator.of(context).push<ForumPostModel>(
      MaterialPageRoute(builder: (_) => BuatPostScreen(postLama: _post)),
    );
    if (hasil != null && mounted) {
      setState(() => _post = hasil);
    }
  }

  Future<void> _hapus() async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.hapusPost),
        content: const Text(AppStrings.konfirmasiHapusPost),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(AppStrings.batal),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              AppStrings.hapusPost,
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
    if (konfirmasi != true || !mounted) return;

    // Disimpan sebelum `await`, karena setelah layar ditutup `context`
    // layar ini tidak boleh dipakai lagi.
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final error = await context.read<DetailPostViewModel>().hapusPost();

    if (error == null) {
      navigator.pop(); // kembali ke daftar forum
      messenger.showSnackBar(
        const SnackBar(content: Text(AppStrings.postDihapus)),
      );
    } else {
      messenger.showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DetailPostViewModel>();
    final user = context.watch<AuthViewModel>().user;
    final apakahPemilik = user != null && user.userId == _post.userId;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text(
          AppStrings.detailPost,
          style: AppTextStyles.judulSeksi,
        ),
        actions: [
          if (apakahPemilik)
            vm.sedangMenghapus
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : PopupMenuButton<String>(
                    onSelected: (nilai) {
                      if (nilai == 'edit') _edit();
                      if (nilai == 'hapus') _hapus();
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: 'edit',
                        child: Text(AppStrings.editPost),
                      ),
                      PopupMenuItem(
                        value: 'hapus',
                        child: Text(
                          AppStrings.hapusPost,
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppSizes.marginLayar),
                children: [
                  _IsiPost(post: _post),
                  const Divider(height: 32),
                  _SeksiKomentar(stream: vm.streamKomentar),
                ],
              ),
            ),
            _KolomKomentar(
              controller: _controllerKomentar,
              sedangMengirim: vm.sedangMengirim,
              onKirim: _kirimKomentar,
            ),
          ],
        ),
      ),
    );
  }
}

/// Isi post lengkap (teks tidak dipotong, beda dengan kartu di daftar).
class _IsiPost extends StatelessWidget {
  final ForumPostModel post;

  const _IsiPost({required this.post});

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(post.namaUser, style: AppTextStyles.namaLapangan),
        const SizedBox(height: 2),
        Text(
          post.dieditPada == null
              ? Formatter.tanggalDanJam(post.createdAt)
              : '${Formatter.tanggalDanJam(post.createdAt)} ${AppStrings.tandaDiedit}',
          style: AppTextStyles.metaLapangan,
        ),
        if (post.teks.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(post.teks),
        ],
        if (bytes != null) ...[
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.radiusChip),
            child: Image.memory(
              bytes,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ],
    );
  }
}

/// Daftar komentar, hidup lewat StreamBuilder — pola sama dengan
/// `_SeksiRiwayatBooking` di `profil_screen.dart`.
class _SeksiKomentar extends StatelessWidget {
  final Stream<List<ForumKomentarModel>> stream;

  const _SeksiKomentar({required this.stream});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ForumKomentarModel>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Text(
            snapshot.error.toString().replaceFirst('Exception: ', ''),
            style: AppTextStyles.metaLapangan,
          );
        }
        final daftar = snapshot.data ?? const [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${AppStrings.komentar} (${daftar.length})',
              style: AppTextStyles.judulSeksi,
            ),
            const SizedBox(height: 10),
            if (daftar.isEmpty)
              const Text(
                AppStrings.kosongKomentar,
                style: AppTextStyles.metaLapangan,
              )
            else
              for (final k in daftar) ...[
                _KartuKomentar(komentar: k),
                const SizedBox(height: 8),
              ],
          ],
        );
      },
    );
  }
}

class _KartuKomentar extends StatelessWidget {
  final ForumKomentarModel komentar;

  const _KartuKomentar({required this.komentar});

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Text(komentar.namaUser, style: AppTextStyles.namaLapangan),
          const SizedBox(height: 2),
          Text(komentar.teks),
          const SizedBox(height: 4),
          Text(
            Formatter.tanggalDanJam(komentar.createdAt),
            style: AppTextStyles.metaLapangan,
          ),
        ],
      ),
    );
  }
}

/// Kolom input komentar yang menempel di bawah layar.
class _KolomKomentar extends StatelessWidget {
  final TextEditingController controller;
  final bool sedangMengirim;
  final VoidCallback onKirim;

  const _KolomKomentar({
    required this.controller,
    required this.sedangMengirim,
    required this.onKirim,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              enabled: !sedangMengirim,
              minLines: 1,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: AppStrings.hintKomentar,
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 8),
          sedangMengirim
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : IconButton(
                  onPressed: onKirim,
                  icon: const Icon(Icons.send, color: AppColors.primary),
                ),
        ],
      ),
    );
  }
}