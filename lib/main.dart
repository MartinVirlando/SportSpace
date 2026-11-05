import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_colors.dart';
import 'core/constants/app_strings.dart';
import 'core/services/location_service.dart';
import 'core/services/pengingat_service.dart';
import 'features/auth/viewmodel/auth_viewmodel.dart';
import 'features/lapangan/viewmodel/home_viewmodel.dart';
import 'features/pengaturan/viewmodel/pengaturan_viewmodel.dart';
import 'repositories/aktivitas_repository.dart';
import 'repositories/auth_repository.dart';
import 'repositories/booking_repository.dart';
import 'repositories/favorit_repository.dart';
import 'repositories/forum_repository.dart';
import 'repositories/lapangan_repository.dart';
import 'repositories/notifikasi_repository.dart';
import 'repositories/pengaturan_repository.dart';
import 'repositories/rating_repository.dart';
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

  // Pengaturan yang tersimpan di HP (v1.5): disiapkan SEBELUM runApp supaya
  // pilihan pengguna sudah terbaca di frame pertama. Pengingat jadwal (T-67)
  // butuh plugin notifikasi diinisialisasi lebih dulu.
  final pengingat = PengingatService();
  await pengingat.inisialisasi();
  final pengaturan = PengaturanViewModel(
    repository: await PengaturanRepository.buka(),
    pengingat: pengingat,
  );
  await pengaturan.muat();

  runApp(SportSpaceApp(pengaturan: pengaturan));
}

class SportSpaceApp extends StatelessWidget {
  final PengaturanViewModel pengaturan;

  const SportSpaceApp({super.key, required this.pengaturan});

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
        Provider<AktivitasRepository>(create: (_) => AktivitasRepository()),
        Provider<NotifikasiRepository>(create: (_) => NotifikasiRepository()),
        Provider<RatingRepository>(create: (_) => RatingRepository()),
        Provider<BookingRepository>(create: (_) => BookingRepository()),
        Provider<FavoritRepository>(create: (_) => FavoritRepository()),
        Provider<ForumRepository>(create: (_) => ForumRepository()),

        // Status autentikasi lintas layar (CLAUDE.md aturan 6) — dipasang
        // sekali di sini, bukan dibuat ulang tiap layar seperti
        // HomeViewModel, supaya sesi login konsisten di seluruh app.
        ChangeNotifierProvider<AuthViewModel>(
          create: (context) => AuthViewModel(
            repository: context.read<AuthRepository>(),
          ),
        ),

        // Pengaturan di HP (CLAUDE.md aturan 6: state lintas layar) — dibuat
        // di main() dan dititipkan di sini lewat `.value`.
        ChangeNotifierProvider<PengaturanViewModel>.value(value: pengaturan),

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
        // Bahasa antarmuka bawaan Flutter (dialog pilih tanggal/jam, tombol
        // "Batal"/"OK", nama hari & bulan di kalender) dikunci ke bahasa
        // Indonesia. Tanpa ini, widget bawaan seperti showDatePicker()
        // memakai bahasa Inggris ("Select date", "Cancel") — melanggar
        // PRD §12 poin 4. Ini BUKAN fitur multi-bahasa: hanya satu bahasa
        // yang didukung.
        locale: const Locale('id', 'ID'),
        supportedLocales: const [Locale('id', 'ID')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const SplashScreen(),
      ),
    );
  }
}
