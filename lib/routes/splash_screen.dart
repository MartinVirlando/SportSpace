import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';
import '../features/auth/view/login_screen.dart';
import '../features/auth/viewmodel/auth_viewmodel.dart';
import 'app_routes.dart';

/// Splash Screen — PRD L-01.
///
/// Tampil ~2 detik, lalu cek status login lewat [AuthViewModel] dan
/// pindah otomatis ke [ShellNavigasi] (sudah login) atau [LoginScreen]
/// (belum). TIDAK ADA tombol "Mulai Sekarang" — Figma menampilkannya,
/// tapi PRD §8 L-01 sengaja tidak membangunnya karena splash harus
/// berpindah sendiri, bukan menunggu ditekan.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _mulai());
  }

  Future<void> _mulai() async {
    // Dua syarat dijalankan bersamaan: jeda minimal 2 detik (PRD L-01)
    // DAN menunggu AuthViewModel selesai memeriksa sesi tersimpan
    // (status masih `memuat` sesaat setelah app dibuka, sampai
    // `authStateChanges` mengirim nilai pertamanya).
    final authVm = context.read<AuthViewModel>();

    await Future.wait([
      Future.delayed(const Duration(seconds: 2)),
      _tungguStatusSiap(authVm),
    ]);

    if (!mounted) return;

    final sudahMasuk = authVm.status == StatusAuth.sudahMasuk;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) =>
            sudahMasuk ? const ShellNavigasi() : const LoginScreen(),
      ),
    );
  }

  Future<void> _tungguStatusSiap(AuthViewModel vm) async {
    if (vm.status != StatusAuth.memuat) return;

    final selesai = Completer<void>();
    void pendengar() {
      if (vm.status != StatusAuth.memuat) selesai.complete();
    }

    vm.addListener(pendengar);
    await selesai.future;
    vm.removeListener(pendengar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Text('⚽', style: TextStyle(fontSize: 48)),
              ),
              const SizedBox(height: 24),
              const Text(
                AppStrings.namaAplikasi,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  AppStrings.tagline,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.85)),
                ),
              ),
              const SizedBox(height: 40),
              const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2.5,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
