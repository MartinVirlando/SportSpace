import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/validators.dart';
import '../../../routes/app_routes.dart';
import '../viewmodel/auth_viewmodel.dart';

/// Halaman Register — PRD L-03. BB-01 (data valid), BB-02 (surel sudah
/// terpakai).
///
/// ATURAN LAPISAN (CLAUDE.md): TIDAK ADA `cloud_firestore` atau
/// `firebase_auth` di sini. Daftar lewat AuthViewModel.daftar().
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaCtrl = TextEditingController();
  final _surelCtrl = TextEditingController();
  final _nomorTeleponCtrl = TextEditingController();
  final _kataSandiCtrl = TextEditingController();
  final _konfirmasiCtrl = TextEditingController();

  // "pengguna" | "mitra" — persis nilai role di PRD Bagian 6.1.
  String _role = 'pengguna';

  @override
  void dispose() {
    _namaCtrl.dispose();
    _surelCtrl.dispose();
    _nomorTeleponCtrl.dispose();
    _kataSandiCtrl.dispose();
    _konfirmasiCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final vm = context.read<AuthViewModel>();
    final berhasil = await vm.daftar(
      nama: _namaCtrl.text,
      surel: _surelCtrl.text,
      kataSandi: _kataSandiCtrl.text,
      nomorTelepon: _nomorTeleponCtrl.text,
      role: _role,
    );
    if (!mounted) return;

    if (berhasil) {
      // Sama seperti LoginScreen: buang seluruh riwayat navigasi
      // (termasuk LoginScreen dan RegisterScreen ini) supaya tombol back
      // tidak membawa pengguna balik ke form setelah berhasil daftar.
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const ShellNavigasi()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(vm.pesanError ?? 'Gagal mendaftar.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final sedangProses = context.watch<AuthViewModel>().sedangProses;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text(AppStrings.daftar, style: AppTextStyles.judulSeksi),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.marginLayar,
            vertical: 16,
          ),
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
                  controller: _surelCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: AppStrings.surel,
                  ),
                  validator: Validators.surel,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nomorTeleponCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: AppStrings.nomorTelepon,
                  ),
                  validator: Validators.nomorTelepon,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _kataSandiCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: AppStrings.kataSandi,
                  ),
                  validator: Validators.kataSandi,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _konfirmasiCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: AppStrings.konfirmasiKataSandi,
                  ),
                  validator: (v) =>
                      Validators.konfirmasiKataSandi(v, _kataSandiCtrl.text),
                ),
                const SizedBox(height: 20),
                const Text(
                  AppStrings.perannya,
                  style: AppTextStyles.judulSeksi,
                ),
                const SizedBox(height: 8),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                      value: 'pengguna',
                      label: Text(AppStrings.peranPengguna),
                    ),
                    ButtonSegment(
                      value: 'mitra',
                      label: Text(AppStrings.peranMitra),
                    ),
                  ],
                  selected: {_role},
                  onSelectionChanged: (nilai) =>
                      setState(() => _role = nilai.first),
                  style: SegmentedButton.styleFrom(
                    selectedBackgroundColor: AppColors.primary,
                    selectedForegroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 28),
                ElevatedButton(
                  onPressed: sedangProses ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppSizes.radiusChip,
                      ),
                    ),
                  ),
                  child: sedangProses
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(AppStrings.daftar),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
