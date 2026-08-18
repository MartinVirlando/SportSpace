import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_colors.dart';
import 'core/constants/app_strings.dart';
import 'core/services/location_service.dart';
import 'features/auth/viewmodel/auth_viewmodel.dart';
import 'features/lapangan/viewmodel/home_viewmodel.dart';
import 'repositories/auth_repository.dart';
import 'repositories/lapangan_repository.dart';
import 'routes/splash_screen.dart';
import 'firebase_options.dart';

Future<void> main() async {
  // Wajib dipanggil sebelum memakai plugin apa pun sebelum runApp().
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Format tanggal berbahasa Indonesia ("Sen, 17 Agu 2026") butuh data
  // locale dimuat lebih dulu. Tanpa ini, Formatter.tanggal() akan error.
  await initializeDateFormatting('id_ID', null);

  runApp(const SportSpaceApp());
}

class SportSpaceApp extends StatelessWidget {
  const SportSpaceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // CLAUDE.md aturan 6: Provider hanya untuk state lintas layar.
        // LocationService dan Repository disediakan di sini supaya
        // ViewModel bisa mengambilnya tanpa membuat instance baru
        // di setiap layar.
        Provider<LocationService>(create: (_) => LocationService()),
        Provider<LapanganRepository>(create: (_) => LapanganRepository()),
        Provider<AuthRepository>(create: (_) => AuthRepository()),

        // Status autentikasi lintas layar (CLAUDE.md aturan 6) — dipasang
        // sekali di sini, bukan dibuat ulang tiap layar seperti
        // HomeViewModel, supaya sesi login konsisten di seluruh app.
        ChangeNotifierProvider<AuthViewModel>(
          create: (context) => AuthViewModel(
            repository: context.read<AuthRepository>(),
          ),
        ),

        ChangeNotifierProvider<HomeViewModel>(
          create: (context) => HomeViewModel(
            repository: context.read<LapanganRepository>(),
            locationService: context.read<LocationService>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: AppStrings.namaAplikasi,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
          scaffoldBackgroundColor: AppColors.background,
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
