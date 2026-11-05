import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/formatter.dart';
import '../../../core/utils/harga.dart';
import '../../../core/utils/produk_tambahan.dart';
import '../../../models/booking_model.dart';
import '../../../models/lapangan_model.dart';
import '../../../models/produk_tambahan_model.dart';
import '../../../repositories/booking_repository.dart';
import '../../auth/viewmodel/auth_viewmodel.dart';
import '../viewmodel/booking_viewmodel.dart';

/// Halaman Ajukan Reservasi — PRD L-10, T-24. BB-24 (slot kosong berhasil),
/// BB-25 (slot bentrok ditolak).
///
/// ATURAN LAPISAN (CLAUDE.md): TIDAK ADA `cloud_firestore` di sini.
///
/// Dibuka lewat `Navigator.push` dari Detail Lapangan (L-06), hanya kalau
/// `lapangan.isMitra == true` (AB-08) — tombol pemanggilnya sudah dijaga
/// kondisi itu di `detail_lapangan_screen.dart`.
///
/// **Mode Ubah Jadwal (v1.5, T-62, AB-20):** kalau [bookingLama] diisi,
/// layar yang sama dipakai untuk mengubah jadwal booking itu — tanggal, durasi,
/// dan jam awal terisi jadwal lama, jam milik booking itu sendiri tidak
/// ditandai "Penuh", dan produk tambahan tidak bisa diubah. Dibuka dari
/// Riwayat Pemesanan (L-13), bukan dari Detail Lapangan.
class AjukanReservasiScreen extends StatelessWidget {
  final LapanganModel lapangan;

  /// `null` → mode Ajukan Reservasi biasa. Diisi → mode Ubah Jadwal.
  final BookingModel? bookingLama;

  const AjukanReservasiScreen({
    super.key,
    required this.lapangan,
    this.bookingLama,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<BookingViewModel>(
      create: (context) => BookingViewModel(
        repository: context.read<BookingRepository>(),
      ),
      child: _AjukanReservasiBody(
        lapangan: lapangan,
        bookingLama: bookingLama,
      ),
    );
  }
}

class _AjukanReservasiBody extends StatefulWidget {
  final LapanganModel lapangan;
  final BookingModel? bookingLama;

  const _AjukanReservasiBody({
    required this.lapangan,
    required this.bookingLama,
  });

  @override
  State<_AjukanReservasiBody> createState() => _AjukanReservasiBodyState();
}

class _AjukanReservasiBodyState extends State<_AjukanReservasiBody> {
  DateTime? _tanggal;
  int? _jamMulai;
  int _durasi = 1;

  bool get _modeUbah => widget.bookingLama != null;

  @override
  void initState() {
    super.initState();

    // Mode Ubah Jadwal: awali dengan jadwal lama supaya pengguna tinggal
    // menggeser, bukan mengisi dari nol.
    final lama = widget.bookingLama;
    if (lama != null) {
      final t = lama.tanggal.split('-').map(int.parse).toList();
      _tanggal = DateTime(t[0], t[1], t[2]);
      _jamMulai = int.parse(lama.jamMulai.split(':')[0]);
      final selesai = int.parse(lama.jamSelesai.split(':')[0]);
      // Form hanya menawarkan durasi 1–3 jam.
      _durasi = (selesai - _jamMulai!).clamp(1, 3);

      // Slot dimuat setelah frame pertama: memanggil notifyListeners saat
      // widget masih dibangun akan memicu galat.
      WidgetsBinding.instance.addPostFrameCallback((_) => _muatSlot());
    }
  }

  /// Muat slot terisi untuk tanggal aktif. Dalam mode ubah, slot milik
  /// booking itu sendiri diabaikan supaya jamnya tidak tampil "Penuh".
  Future<void> _muatSlot() {
    return context.read<BookingViewModel>().muatSlotTerisi(
          lapanganId: widget.lapangan.lapanganId,
          tanggal: _tanggalFormat,
          abaikanBookingId: widget.bookingLama?.bookingId,
        );
  }

  /// Jumlah yang dipilih untuk tiap produk di katalog lapangan (indeks sama
  /// dengan `lapangan.produkTambahan`) — T-60, AB-19. Awal semuanya 0.
  late final List<int> _jumlahProduk =
      List<int>.filled(widget.lapangan.produkTambahan.length, 0);

  /// Produk berjumlah > 0, disalin (nama dan harga) dari katalog — inilah
  /// yang disimpan ke `booking.produkTambahan`.
  ///
  /// Mode Ubah Jadwal: produk booking lama dipakai apa adanya (tidak bisa
  /// diubah dari sini).
  List<ProdukPesananModel> get _produkDipilih {
    final lama = widget.bookingLama;
    if (lama != null) return lama.produkTambahan;

    return [
      for (var i = 0; i < _jumlahProduk.length; i++)
        if (_jumlahProduk[i] > 0)
          ProdukPesananModel(
            nama: widget.lapangan.produkTambahan[i].nama,
            harga: widget.lapangan.produkTambahan[i].harga,
            jumlah: _jumlahProduk[i],
          ),
    ];
  }

  int get _jamBukaHour => int.parse(widget.lapangan.jamBuka.split(':')[0]);

  /// Jam tutup dalam skala 24 jam. Lapangan yang tutup tengah malam
  /// ("00:00") atau lewat tengah malam akan punya jam lebih kecil (atau
  /// sama) dari jam buka kalau dibaca literal — mis. `06:00–00:00` bisa
  /// terbaca 6..0 yang kosong. Ditambah 24 supaya rentang jamBuka..jamTutup
  /// tetap benar (6..24), bukan rentang kosong.
  int get _jamTutupHour {
    final jam = int.parse(widget.lapangan.jamTutup.split(':')[0]);
    return jam <= _jamBukaHour ? jam + 24 : jam;
  }

  /// Jam mulai yang bisa dipilih: dalam jam operasional, muat sampai
  /// selesai sebelum tutup, tidak bentrok slot terisi, dan (kalau
  /// tanggalnya hari ini) belum lewat jam sekarang.
  List<int> _jamMulaiTersedia(BookingViewModel vm) {
    final sekarang = DateTime.now();
    final isHariIni = _tanggal != null &&
        _tanggal!.year == sekarang.year &&
        _tanggal!.month == sekarang.month &&
        _tanggal!.day == sekarang.day;

    return [
      for (var jam = _jamBukaHour; jam < _jamTutupHour; jam++)
        if (jam + _durasi <= _jamTutupHour &&
            !(isHariIni && jam <= sekarang.hour))
          jam,
    ];
  }

  bool _jamBentrok(BookingViewModel vm, int jamMulai) {
    for (var jam = jamMulai; jam < jamMulai + _durasi; jam++) {
      if (vm.slotTerisi.contains(jam)) return true;
    }
    return false;
  }

  String get _tanggalFormat =>
      DateFormat('yyyy-MM-dd').format(_tanggal!);

  Future<void> _pilihTanggal() async {
    final sekarang = DateTime.now();
    final hasil = await showDatePicker(
      context: context,
      initialDate: _tanggal ?? sekarang,
      firstDate: sekarang,
      lastDate: sekarang.add(const Duration(days: 60)),
    );
    if (hasil == null) return;

    setState(() {
      _tanggal = hasil;
      _jamMulai = null;
    });

    if (!mounted) return;
    await _muatSlot();
  }

  Future<void> _submit() async {
    if (_tanggal == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.errPilihTanggalDulu)),
      );
      return;
    }
    if (_jamMulai == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.errPilihJamMulai)),
      );
      return;
    }

    final vm = context.read<BookingViewModel>();
    final user = context.read<AuthViewModel>().user;
    if (user == null) return;

    final jamSelesai = _jamMulai! + _durasi;
    final daftarJam = [
      for (var jam = _jamMulai!; jam < jamSelesai; jam++) jam,
    ];
    // Total setelah promo (AB-18) — inilah yang disimpan ke booking.totalHarga.
    final totalHarga = vm
        .hitungRincian(
          widget.lapangan,
          daftarJam,
          produkDipilih: _produkDipilih,
        )
        .total;

    final jamMulaiTeks = '${_jamMulai!.toString().padLeft(2, '0')}:00';
    final jamSelesaiTeks = '${jamSelesai.toString().padLeft(2, '0')}:00';

    // Mode Ubah Jadwal (T-62, AB-20, BB-76/BB-77) atau Ajukan Reservasi biasa
    // (AB-04). `berhasil` dan pesannya disamakan supaya penanganan di bawah
    // satu jalur.
    final bool berhasil;
    final String pesanSukses;
    final String pesanGagalBawaan;
    final lama = widget.bookingLama;
    if (lama != null) {
      berhasil = await vm.ubahJadwal(
        bookingLama: lama,
        lapangan: widget.lapangan,
        userId: user.userId,
        tanggal: _tanggalFormat,
        jamMulai: jamMulaiTeks,
        jamSelesai: jamSelesaiTeks,
      );
      pesanSukses = AppStrings.jadwalDiubah;
      pesanGagalBawaan = AppStrings.errGagalUbahJadwal;
    } else {
      final booking = await vm.ajukanReservasi(
        lapanganId: widget.lapangan.lapanganId,
        namaLapangan: widget.lapangan.nama,
        pemilikId: widget.lapangan.pemilikId ?? '',
        userId: user.userId,
        namaUser: user.nama,
        tanggal: _tanggalFormat,
        jamMulai: jamMulaiTeks,
        jamSelesai: jamSelesaiTeks,
        totalHarga: totalHarga,
        produkTambahan: _produkDipilih,
      );
      berhasil = booking != null;
      pesanSukses = AppStrings.reservasiTerkirim;
      pesanGagalBawaan = AppStrings.errGagalAjukanReservasi;
    }

    if (!mounted) return;

    if (berhasil) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(pesanSukses)),
      );
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(vm.pesanError ?? pesanGagalBawaan)),
      );
      // Slot yang barusan dipakai orang lain (BB-25, BB-77) harus hilang dari
      // pilihan — muat ulang supaya chipnya langsung bertanda "Penuh".
      setState(() => _jamMulai = null);
      await _muatSlot();
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<BookingViewModel>();

    return Scaffold(
      backgroundColor: context.warna.background,
      appBar: AppBar(
        backgroundColor: context.warna.surface,
        elevation: 0,
        title: Text(
          _modeUbah ? AppStrings.ubahJadwal : AppStrings.ajukanReservasi,
          style: AppTextStyles.judulSeksi(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.marginLayar),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(widget.lapangan.nama, style: AppTextStyles.namaLapangan(context)),
              const SizedBox(height: 4),
              Text(
                '${widget.lapangan.jamBuka} – ${widget.lapangan.jamTutup}',
                style: AppTextStyles.metaLapangan(context),
              ),
              const SizedBox(height: 20),
              Text(AppStrings.tanggal, style: AppTextStyles.judulSeksi(context)),
              const SizedBox(height: 8),
              _TombolPilihTanggal(
                tanggal: _tanggal,
                onTap: _pilihTanggal,
              ),
              const SizedBox(height: 20),
              Text(AppStrings.durasi, style: AppTextStyles.judulSeksi(context)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [1, 2, 3].map((jam) {
                  final aktif = jam == _durasi;
                  return ChoiceChip(
                    label: Text('$jam ${AppStrings.satuanJam}'),
                    selected: aktif,
                    onSelected: (_) => setState(() {
                      _durasi = jam;
                      _jamMulai = null;
                    }),
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: aktif ? Colors.white : context.warna.textPrimary,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              Text(AppStrings.jamMulai, style: AppTextStyles.judulSeksi(context)),
              const SizedBox(height: 8),
              _DaftarJamMulai(
                tanggalDipilih: _tanggal != null,
                vm: vm,
                jamTersedia: _tanggal == null ? const [] : _jamMulaiTersedia(vm),
                jamBentrok: _tanggal == null
                    ? const {}
                    : {
                        for (final jam in _jamMulaiTersedia(vm))
                          jam: _jamBentrok(vm, jam),
                      },
                jamDipilih: _jamMulai,
                onPilih: (jam) => setState(() => _jamMulai = jam),
              ),
              // v1.5 (T-60) — produk tambahan, hanya kalau lapangan punya.
              // Mode Ubah Jadwal: produk tidak bisa diubah, jadi tidak ditawarkan.
              if (!_modeUbah && widget.lapangan.produkTambahan.isNotEmpty) ...[
                const SizedBox(height: 20),
                Text(
                  AppStrings.produkTambahanOpsional,
                  style: AppTextStyles.judulSeksi(context),
                ),
                const SizedBox(height: 8),
                for (var i = 0; i < _jumlahProduk.length; i++)
                  _BarisProdukPesan(
                    produk: widget.lapangan.produkTambahan[i],
                    jumlah: _jumlahProduk[i],
                    onUbah: (jumlah) =>
                        setState(() => _jumlahProduk[i] = jumlah),
                  ),
              ],
              const Divider(height: 40),
              _KotakEstimasi(
                rincian: _tanggal != null && _jamMulai != null
                    ? vm.hitungRincian(
                        widget.lapangan,
                        [
                          for (var jam = _jamMulai!;
                              jam < _jamMulai! + _durasi;
                              jam++)
                            jam,
                        ],
                        produkDipilih: _produkDipilih,
                      )
                    : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: vm.sedangProses ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusChip),
                  ),
                ),
                child: vm.sedangProses
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        _modeUbah
                            ? AppStrings.simpanJadwalBaru
                            : AppStrings.ajukanReservasi,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TombolPilihTanggal extends StatelessWidget {
  final DateTime? tanggal;
  final VoidCallback onTap;

  const _TombolPilihTanggal({required this.tanggal, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: context.warna.surfaceVariant, width: 1.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              tanggal == null
                  ? AppStrings.pilihTanggal
                  : Formatter.tanggal(tanggal!),
              style: AppTextStyles.namaLapangan(context),
            ),
            Icon(Icons.calendar_today, size: 16, color: context.warna.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _DaftarJamMulai extends StatelessWidget {
  final bool tanggalDipilih;
  final BookingViewModel vm;
  final List<int> jamTersedia;
  final Map<int, bool> jamBentrok;
  final int? jamDipilih;
  final ValueChanged<int> onPilih;

  const _DaftarJamMulai({
    required this.tanggalDipilih,
    required this.vm,
    required this.jamTersedia,
    required this.jamBentrok,
    required this.jamDipilih,
    required this.onPilih,
  });

  @override
  Widget build(BuildContext context) {
    if (!tanggalDipilih) {
      return Text(
        AppStrings.errPilihTanggalDulu,
        style: AppTextStyles.metaLapangan(context),
      );
    }
    if (vm.kondisiSlot == KondisiSlot.memuat) {
      return const LinearProgressIndicator();
    }
    if (vm.kondisiSlot == KondisiSlot.gagal) {
      return Text(
        AppStrings.errGagalMuat,
        style: AppTextStyles.metaLapangan(context),
      );
    }
    if (jamTersedia.isEmpty) {
      return Text(
        AppStrings.kosongJamTersedia,
        style: AppTextStyles.metaLapangan(context),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: jamTersedia.map((jam) {
        final penuh = jamBentrok[jam] ?? false;
        final aktif = jam == jamDipilih;
        final label = '${jam.toString().padLeft(2, '0')}:00';

        return ChoiceChip(
          label: Text(penuh ? '$label · ${AppStrings.slotPenuh}' : label),
          selected: aktif,
          onSelected: penuh ? null : (_) => onPilih(jam),
          selectedColor: AppColors.primary,
          disabledColor: context.warna.surfaceVariant,
          labelStyle: TextStyle(
            color: penuh
                ? context.warna.textSecondary
                : (aktif ? Colors.white : context.warna.textPrimary),
          ),
        );
      }).toList(),
    );
  }
}

class _KotakEstimasi extends StatelessWidget {
  /// `null` selama tanggal atau jam belum dipilih.
  final RincianHarga? rincian;

  const _KotakEstimasi({required this.rincian});

  @override
  Widget build(BuildContext context) {
    final totalHarga = rincian?.total;
    // Rincian hanya perlu tampil kalau ada potongan (AB-18) atau produk
    // tambahan (AB-19); tanpa keduanya kotaknya persis seperti sebelum v1.5.
    final adaPotongan = rincian != null && rincian!.potongan > 0;
    final adaProduk = rincian != null && rincian!.totalProduk > 0;
    final tampilRincian = adaPotongan || adaProduk;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.warna.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusKartu),
        boxShadow: context.warna.shadowKartu,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (tampilRincian) ...[
            _BarisRincian(
              label: AppStrings.sewaLapangan,
              nilai: Formatter.rupiah(rincian!.sewaAsli),
            ),
            if (adaPotongan)
              _BarisRincian(
                label: AppStrings.potongan,
                nilai: '− ${Formatter.rupiah(rincian!.potongan)}',
                warna: Colors.red.shade700,
              ),
            if (adaProduk)
              _BarisRincian(
                label: AppStrings.tambahanLabel,
                nilai: '+ ${Formatter.rupiah(rincian!.totalProduk)}',
              ),
            const Divider(height: 16),
          ],
          Text(AppStrings.totalEstimasi, style: AppTextStyles.metaLapangan(context)),
          const SizedBox(height: 4),
          Text(
            totalHarga == null ? '—' : Formatter.rupiah(totalHarga),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            AppStrings.estimasiDibayarDiLokasi,
            style: AppTextStyles.metaLapangan(context),
          ),
        ],
      ),
    );
  }
}

/// Satu baris rincian di kotak estimasi (label di kiri, nilai di kanan).
class _BarisRincian extends StatelessWidget {
  final String label;
  final String nilai;
  final Color? warna;

  const _BarisRincian({required this.label, required this.nilai, this.warna});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.metaLapangan(context)),
          Text(
            nilai,
            style: AppTextStyles.metaLapangan(context).copyWith(color: warna),
          ),
        ],
      ),
    );
  }
}

/// Satu produk tambahan dengan pengatur jumlah — PRD L-10, AB-19, BB-74.
/// Jumlah 0 sampai [BatasProduk.jumlahPerItemMaksimal]; 0 berarti tidak
/// dipesan dan tidak disimpan.
class _BarisProdukPesan extends StatelessWidget {
  final ProdukTambahanModel produk;
  final int jumlah;
  final ValueChanged<int> onUbah;

  const _BarisProdukPesan({
    required this.produk,
    required this.jumlah,
    required this.onUbah,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(produk.nama, style: AppTextStyles.namaLapangan(context)),
                Text(
                  Formatter.rupiah(produk.harga),
                  style: AppTextStyles.metaLapangan(context),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: jumlah > 0 ? () => onUbah(jumlah - 1) : null,
            icon: const Icon(Icons.remove_circle_outline),
          ),
          SizedBox(
            width: 24,
            child: Text(
              '$jumlah',
              textAlign: TextAlign.center,
              style: AppTextStyles.namaLapangan(context),
            ),
          ),
          IconButton(
            onPressed: jumlah < BatasProduk.jumlahPerItemMaksimal
                ? () => onUbah(jumlah + 1)
                : null,
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
    );
  }
}
