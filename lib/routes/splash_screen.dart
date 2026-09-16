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
/// Menunggu pengguna menekan "Mulai Sekarang", baru pindah ke
/// [ShellNavigasi] (sudah login) atau [LoginScreen] (belum). Pengecekan
/// status login lewat [AuthViewModel] tetap berjalan di latar belakang
/// SEJAK splash ini dibuka (bahkan sejak `main.dart`, karena
/// `AuthViewModel` dipasang sekali sebagai Provider lintas-layar dan
/// langsung berlangganan `authStateChanges` di constructor-nya) — bukan
/// baru dicek setelah tombol ditekan. Jadi begitu tombol ditekan, biasanya
/// statusnya sudah siap dan langsung berpindah tanpa jeda tambahan;
/// `_tungguStatusSiap` cuma jaga-jaga untuk kasus jaringan lambat.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _sedangProses = false;

  Future<void> _mulaiSekarang() async {
    setState(() => _sedangProses = true);

    final authVm = context.read<AuthViewModel>();
    await _tungguStatusSiap(authVm);

    if (!mounted) return;

    final sudahMasuk = authVm.status == StatusAuth.sudahMasuk;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => sudahMasuk
            ? ShellNavigasi(key: AppRoutes.kunciShell)
            : const LoginScreen(),
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
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                // 180x221 — rasio asli logo.jpg (212x260), supaya gambar
                // utuh tampil tanpa terpotong (logo aslinya juga memuat
                // tulisan "SportSpace" + tagline di bagian bawah).
                child: Image.asset(
                  'assets/images/logo.jpg',
                  width: 180,
                  height: 221,
                  fit: BoxFit.contain,
                ),
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
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: ElevatedButton(
                    onPressed: _sedangProses ? null : _mulaiSekarang,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: _sedangProses
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: AppColors.primary,
                            ),
                          )
                        : const Text(
                            AppStrings.mulaiSekarang,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Badge fitur utama — dari desain Figma splash screen.
              const _BadgeFitur(),
              const SizedBox(height: 16),
              Text(
                AppStrings.splashDaftarOlahraga,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.85)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BadgeFitur extends StatelessWidget {
  const _BadgeFitur();

  @override
  Widget build(BuildContext context) {
    return const Wrap(
      alignment: WrapAlignment.center,
      spacing: 10,
      runSpacing: 10,
      children: [
        _Chip(ikon: '📍', label: AppStrings.splashBadgeLokasi),
        _Chip(ikon: '🏸', label: AppStrings.splashBadgeMultiOlahraga),
        _Chip(ikon: '👥', label: AppStrings.splashBadgeCariRekan),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String ikon;
  final String label;

  const _Chip({required this.ikon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$ikon $label',
        style: const TextStyle(color: Colors.white, fontSize: 13),
      ),
    );
  }
}
