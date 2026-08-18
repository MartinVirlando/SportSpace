import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/validators.dart';
import '../../../routes/app_routes.dart';
import '../viewmodel/auth_viewmodel.dart';
import 'register_screen.dart';

/// Halaman Login — PRD L-02. BB-03 (kredensial benar), BB-04 (kata sandi
/// salah).
///
/// ATURAN LAPISAN (CLAUDE.md): TIDAK ADA `cloud_firestore` atau
/// `firebase_auth` di sini. Login lewat AuthViewModel.masuk().
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _surelCtrl = TextEditingController();
  final _kataSandiCtrl = TextEditingController();

  @override
  void dispose() {
    _surelCtrl.dispose();
    _kataSandiCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final vm = context.read<AuthViewModel>();
    final berhasil = await vm.masuk(_surelCtrl.text, _kataSandiCtrl.text);
    if (!mounted) return;

    if (berhasil) {
      // pushAndRemoveUntil(false) membuang seluruh riwayat navigasi
      // (termasuk LoginScreen ini) supaya tombol back tidak bisa
      // membawa pengguna balik ke Login setelah berhasil masuk.
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const ShellNavigasi()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(vm.pesanError ?? AppStrings.errKredensialSalah)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final sedangProses = context.watch<AuthViewModel>().sedangProses;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.marginLayar,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 64),
                const Text('⚽', style: TextStyle(fontSize: 40)),
                const SizedBox(height: 12),
                const Text(
                  AppStrings.namaAplikasi,
                  style: AppTextStyles.sambutan,
                ),
                const SizedBox(height: 4),
                const Text(AppStrings.tagline, style: AppTextStyles.lokasi),
                const SizedBox(height: 40),
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
                  controller: _kataSandiCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: AppStrings.kataSandi,
                  ),
                  validator: Validators.kataSandi,
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
                      : const Text(AppStrings.masuk),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: sedangProses
                      ? null
                      : () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const RegisterScreen(),
                            ),
                          ),
                  child: const Text('Belum punya akun? Daftar'),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
