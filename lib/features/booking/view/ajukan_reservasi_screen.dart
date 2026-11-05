import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/formatter.dart';
import '../../../core/utils/harga.dart';
import '../../../core/utils/produk_tambahan.dart';
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
class AjukanReservasiScreen extends StatelessWidget {
  final LapanganModel lapangan;

  const AjukanReservasiScreen({super.key, required this.lapangan});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<BookingViewModel>(
      create: (context) => BookingViewModel(
        repository: context.read<BookingRepository>(),
      ),
      child: _AjukanReservasiBody(lapangan: lapangan),
    );
  }
}

class _AjukanReservasiBody extends StatefulWidget {
  final LapanganModel lapangan;

  const _AjukanReservasiBody({required this.lapangan});

  @override
  State<_AjukanReservasiBody> createState() => _AjukanReservasiBodyState();
}

class _AjukanReservasiBodyState extends State<_AjukanReservasiBody> {
  DateTime? _tanggal;
  int? _jamMulai;
  int _durasi = 1;

  /// Jumlah yang dipilih untuk tiap produk di katalog lapangan (indeks sama
  /// dengan `lapangan.produkTambahan`) — T-60, AB-19. Awal semuanya 0.
  late final List<int> _jumlahProduk =
      List<int>.filled(widget.lapangan.produkTambahan.length, 0);

  /// Produk berjumlah > 0, disalin (nama dan harga) dari katalog — inilah
  /// yang disimpan ke `booking.produkTambahan`.
  List<ProdukPesananModel> get _produkDipilih => [
        for (var i = 0; i < _jumlahProduk.length; i++)
          if (_jumlahProduk[i] > 0)
            ProdukPesananModel(
              nama: widget.lapangan.produkTambahan[i].nama,
              harga: widget.lapangan.produkTambahan[i].harga,
              jumlah: _jumlahProduk[i],
            ),
      ];

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
    await context.read<BookingViewModel>().muatSlotTerisi(
          lapanganId: widget.lapangan.lapanganId,
          tanggal: _tanggalFormat,
        );
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

    final booking = await vm.ajukanReservasi(
      lapanganId: widget.lapangan.lapanganId,
      namaLapangan: widget.lapangan.nama,
      pemilikId: widget.lapangan.pemilikId ?? '',
      userId: user.userId,
      namaUser: user.nama,
      tanggal: _tanggalFormat,
      jamMulai: '${_jamMulai!.toString().padLeft(2, '0')}:00',
      jamSelesai: '${jamSelesai.toString().padLeft(2, '0')}:00',
      totalHarga: totalHarga,
      produkTambahan: _produkDipilih,
    );

    if (!mounted) return;

    if (booking != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.reservasiTerkirim)),
      );
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(vm.pesanError ?? AppStrings.errGagalAjukanReservasi)),
      );
      // Slot yang barusan dipakai orang lain (BB-25) harus hilang dari
      // pilihan — muat ulang supaya chipnya langsung bertanda "Penuh".
      setState(() => _jamMulai = null);
      await vm.muatSlotTerisi(
        lapanganId: widget.lapangan.lapanganId,
        tanggal: _tanggalFormat,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<BookingViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text(
          AppStrings.ajukanReservasi,
          style: AppTextStyles.judulSeksi,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.marginLayar),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(widget.lapangan.nama, style: AppTextStyles.namaLapangan),
              const SizedBox(height: 4),
              Text(
                '${widget.lapangan.jamBuka} – ${widget.lapangan.jamTutup}',
                style: AppTextStyles.metaLapangan,
              ),
              const SizedBox(height: 20),
              const Text(AppStrings.tanggal, style: AppTextStyles.judulSeksi),
              const SizedBox(height: 8),
              _TombolPilihTanggal(
                tanggal: _tanggal,
                onTap: _pilihTanggal,
              ),
              const SizedBox(height: 20),
              const Text(AppStrings.durasi, style: AppTextStyles.judulSeksi),
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
                      color: aktif ? Colors.white : AppColors.textPrimary,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              const Text(AppStrings.jamMulai, style: AppTextStyles.judulSeksi),
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
              if (widget.lapangan.produkTambahan.isNotEmpty) ...[
                const SizedBox(height: 20),
                const Text(
                  AppStrings.produkTambahanOpsional,
                  style: AppTextStyles.judulSeksi,
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
                    : const Text(AppStrings.ajukanReservasi),
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
          border: Border.all(color: AppColors.surfaceVariant, width: 1.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              tanggal == null
                  ? AppStrings.pilihTanggal
                  : Formatter.tanggal(tanggal!),
              style: AppTextStyles.namaLapangan,
            ),
            const Icon(Icons.calendar_today, size: 16, color: AppColors.textSecondary),
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
      return const Text(
        AppStrings.errPilihTanggalDulu,
        style: AppTextStyles.metaLapangan,
      );
    }
    if (vm.kondisiSlot == KondisiSlot.memuat) {
      return const LinearProgressIndicator();
    }
    if (vm.kondisiSlot == KondisiSlot.gagal) {
      return const Text(
        AppStrings.errGagalMuat,
        style: AppTextStyles.metaLapangan,
      );
    }
    if (jamTersedia.isEmpty) {
      return const Text(
        AppStrings.kosongJamTersedia,
        style: AppTextStyles.metaLapangan,
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
          disabledColor: AppColors.surfaceVariant,
          labelStyle: TextStyle(
            color: penuh
                ? AppColors.textSecondary
                : (aktif ? Colors.white : AppColors.textPrimary),
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
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusKartu),
        boxShadow: AppColors.shadowKartu,
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
          const Text(AppStrings.totalEstimasi, style: AppTextStyles.metaLapangan),
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
          const Text(
            AppStrings.estimasiDibayarDiLokasi,
            style: AppTextStyles.metaLapangan,
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
          Text(label, style: AppTextStyles.metaLapangan),
          Text(
            nilai,
            style: AppTextStyles.metaLapangan.copyWith(color: warna),
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
                Text(produk.nama, style: AppTextStyles.namaLapangan),
                Text(
                  Formatter.rupiah(produk.harga),
                  style: AppTextStyles.metaLapangan,
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
              style: AppTextStyles.namaLapangan,
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
