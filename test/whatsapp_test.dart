import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sport_space/core/constants/app_aktivitas.dart';
import 'package:sport_space/core/utils/whatsapp.dart';
import 'package:sport_space/models/aktivitas_bermain_model.dart';
import 'package:sport_space/models/lapangan_model.dart';

/// Uji otomatis untuk BB-58 dan BB-59 (bagikan ke WhatsApp, T-63).
/// Membuka WhatsApp-nya sendiri (`launchUrl`) hanya bisa diuji di perangkat.

AktivitasBermainModel _aktivitas({
  String? tingkat = AppTingkat.menengah,
  int biaya = 0,
  String? catatan,
}) {
  return AktivitasBermainModel(
    aktivitasId: 'a1',
    jenisOlahraga: 'futsal',
    jumlahPemainDibutuhkan: 10,
    jumlahPemainSaatIni: 3,
    waktu: DateTime(2026, 12, 1, 19),
    lapanganId: 'lap1',
    namaLapangan: 'Lapangan Uji',
    pembuatId: 'u1',
    namaPembuat: 'Pembuat',
    status: 'TERBUKA',
    peserta: const ['u1'],
    dibuatPada: DateTime(2026, 11, 1),
    jenisAktivitas: AppJenisAktivitas.sparring,
    tingkatKemampuan: tingkat,
    biayaPerOrang: biaya,
    catatan: catatan,
  );
}

LapanganModel _lapangan({String tautanMaps = ''}) {
  return LapanganModel(
    lapanganId: 'lap1',
    nama: 'Lapangan Uji',
    alamat: 'Jl. Contoh No. 1, Tangerang',
    latitude: -6.2,
    longitude: 106.6,
    jenisOlahraga: const ['futsal', 'badminton'],
    harga: 150000,
    jamBuka: '08:00',
    jamTutup: '23:00',
    fasilitas: const ['parkir'],
    fotoURL: const [],
    tautanMaps: tautanMaps,
    isMitra: false,
    sumberData: 'direktori_daring',
    ratingTotal: 0,
    jumlahRating: 0,
    ratingRata2: 0,
  );
}

void main() {
  // Teks aktivitas memuat tanggal berbahasa Indonesia (`DateFormat('id_ID')`),
  // dan aplikasi menginisialisasinya di main(). Di tes harus dilakukan sendiri.
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  group('tautanBagikanWhatsApp', () {
    test('memakai https://wa.me/ dengan parameter text', () {
      final tautan = tautanBagikanWhatsApp('Halo');
      expect(tautan.scheme, 'https');
      expect(tautan.host, 'wa.me');
      expect(tautan.queryParameters['text'], 'Halo');
    });

    test('spasi menjadi %20 dan baris baru %0A, bukan tanda +', () {
      final tautan = tautanBagikanWhatsApp('a b\nc');
      expect(tautan.toString(), 'https://wa.me/?text=a%20b%0Ac');
    });

    test('teks asli bisa dibaca kembali utuh (emoji dan karakter khusus)', () {
      const teks = 'Yuk main! 🏟️ Biaya: Rp 25.000 / orang & catatan';
      expect(tautanBagikanWhatsApp(teks).queryParameters['text'], teks);
    });
  });

  group('teksBagikanAktivitas', () {
    test('memuat olahraga, jenis, tingkat, lapangan, waktu, dan pemain', () {
      final teks = teksBagikanAktivitas(_aktivitas());
      expect(teks, contains('Futsal'));
      expect(teks, contains('Sparring'));
      expect(teks, contains('Menengah'));
      expect(teks, contains('Lapangan Uji'));
      expect(teks, contains('19:00'));
      expect(teks, contains('3/10'));
    });

    test('biaya 0 tampil Gratis tanpa keterangan "dibayar di lokasi"', () {
      final teks = teksBagikanAktivitas(_aktivitas(biaya: 0));
      expect(teks, contains('Gratis'));
      expect(teks, isNot(contains('dibayar di lokasi')));
    });

    test('biaya terisi tampil nominal dan keterangan dibayar di lokasi', () {
      final teks = teksBagikanAktivitas(_aktivitas(biaya: 25000));
      expect(teks, contains('25.000'));
      expect(teks, contains('dibayar di lokasi'));
    });

    test('dokumen lama tanpa tingkat: tidak ada kata tingkat, tidak crash', () {
      final teks = teksBagikanAktivitas(_aktivitas(tingkat: null));
      expect(teks, isNot(contains('Pemula')));
      expect(teks, isNot(contains('Menengah')));
      expect(teks, isNot(contains('Mahir')));
      expect(teks, contains('Sparring'));
    });

    test('catatan ikut hanya kalau terisi', () {
      expect(
        teksBagikanAktivitas(_aktivitas(catatan: 'Bawa sepatu futsal')),
        contains('Bawa sepatu futsal'),
      );
      expect(teksBagikanAktivitas(_aktivitas()), isNot(contains('Catatan')));
      expect(
        teksBagikanAktivitas(_aktivitas(catatan: '   ')),
        isNot(contains('Catatan')),
      );
    });
  });

  group('teksBagikanLapangan', () {
    test('memuat nama, olahraga, alamat, dan jam buka', () {
      final teks = teksBagikanLapangan(_lapangan());
      expect(teks, contains('Lapangan Uji'));
      expect(teks, contains('Futsal, Badminton'));
      expect(teks, contains('Jl. Contoh No. 1, Tangerang'));
      expect(teks, contains('08:00 – 23:00'));
    });

    test('tautan Google Maps ikut hanya kalau tautanMaps terisi', () {
      const tautan = 'https://maps.app.goo.gl/abc123';
      expect(
        teksBagikanLapangan(_lapangan(tautanMaps: tautan)),
        contains(tautan),
      );
      expect(teksBagikanLapangan(_lapangan()), isNot(contains('http')));
    });
  });
}
