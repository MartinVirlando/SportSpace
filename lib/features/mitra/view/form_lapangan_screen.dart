import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fasilitas.dart';
import '../../../core/constants/app_sports.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/services/location_service.dart';
import '../../../core/utils/formatter.dart';
import '../../../core/utils/validators.dart';
import '../../../core/utils/produk_tambahan.dart';
import '../../../models/lapangan_model.dart';
import '../../../models/produk_tambahan_model.dart';
import '../../../repositories/lapangan_repository.dart';
import '../../auth/viewmodel/auth_viewmodel.dart';
import '../viewmodel/form_lapangan_viewmodel.dart';

/// Halaman Tambah/Edit Lapangan — PRD L-15, T-26. BB-29 (tambah lapangan
/// baru tampil di pencarian dengan `isMitra: true`).
///
/// ATURAN LAPISAN (CLAUDE.md): TIDAK ADA `cloud_firestore` di sini.
///
/// [lapangan] `null` → mode Tambah. Diisi → mode Edit, form terisi dari
/// data yang ada; `isMitra`/`pemilikId`/`sumberData`/field rating TIDAK
/// bisa diubah lewat form ini (lihat `FormLapanganViewModel.perbaruiLapangan`).
class FormLapanganScreen extends StatelessWidget {
  final LapanganModel? lapangan;

  const FormLapanganScreen({super.key, this.lapangan});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<FormLapanganViewModel>(
      create: (context) => FormLapanganViewModel(
        repository: context.read<LapanganRepository>(),
      ),
      child: _FormLapanganBody(lapangan: lapangan),
    );
  }
}

class _FormLapanganBody extends StatefulWidget {
  final LapanganModel? lapangan;

  const _FormLapanganBody({required this.lapangan});

  @override
  State<_FormLapanganBody> createState() => _FormLapanganBodyState();
}

class _FormLapanganBodyState extends State<_FormLapanganBody> {
  final _formKey = GlobalKey<FormState>();
  final _namaCtrl = TextEditingController();
  final _alamatCtrl = TextEditingController();
  final _latCtrl = TextEditingController();
  final _lonCtrl = TextEditingController();
  final _hargaCtrl = TextEditingController();
  final _fotoCtrl = TextEditingController();
  final _kontakCtrl = TextEditingController();
  final _diskonCtrl = TextEditingController(); // v1.5 (T-65)

  /// Baris produk tambahan (T-60): satu pasang controller nama + harga.
  final List<_ProdukCtrl> _produk = [];

  final Set<String> _jenisOlahraga = {};
  final Set<String> _fasilitas = {};
  TimeOfDay? _jamBuka;
  TimeOfDay? _jamTutup;
  bool _sedangAmbilLokasi = false;
  String? _errOlahraga;
  String? _errJam;

  bool get _modeEdit => widget.lapangan != null;

  @override
  void initState() {
    super.initState();
    final l = widget.lapangan;
    if (l != null) {
      _namaCtrl.text = l.nama;
      _alamatCtrl.text = l.alamat;
      _latCtrl.text = l.latitude.toString();
      _lonCtrl.text = l.longitude.toString();
      _hargaCtrl.text = l.harga.toString();
      _fotoCtrl.text = l.fotoURL.isEmpty ? '' : l.fotoURL.first;
      _kontakCtrl.text = l.nomorTelepon;
      // 0 berarti tanpa promo: kolom dikosongkan, bukan menampilkan "0".
      _diskonCtrl.text = l.diskonPersen > 0 ? l.diskonPersen.toString() : '';
      for (final p in l.produkTambahan) {
        _produk.add(_ProdukCtrl(nama: p.nama, harga: p.harga.toString()));
      }
      _jenisOlahraga.addAll(l.jenisOlahraga);
      _fasilitas.addAll(l.fasilitas);
      _jamBuka = _parseJam(l.jamBuka);
      _jamTutup = _parseJam(l.jamTutup);
    }
  }

  /// Hapus satu baris produk. Controller-nya TIDAK di-dispose saat itu juga:
  /// kolom teksnya masih terpasang sampai frame berikutnya selesai, dan
  /// memakai controller yang sudah di-dispose memicu galat Flutter. Dispose
  /// ditunda sampai setelah frame.
  void _hapusProduk(int indeks) {
    final dihapus = _produk[indeks];
    setState(() => _produk.removeAt(indeks));
    WidgetsBinding.instance.addPostFrameCallback((_) => dihapus.dispose());
  }

  /// Isi baris produk menjadi daftar untuk disimpan. Hanya dipanggil
  /// setelah form lolos validasi, jadi nama tidak kosong dan harga angka.
  List<ProdukTambahanModel> get _produkTambahan => [
        for (final p in _produk)
          ProdukTambahanModel(
            nama: p.nama.text.trim(),
            harga: int.parse(p.harga.text.trim()),
          ),
      ];

  TimeOfDay _parseJam(String hhmm) {
    final bagian = hhmm.split(':');
    return TimeOfDay(hour: int.parse(bagian[0]), minute: int.parse(bagian[1]));
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    _alamatCtrl.dispose();
    _latCtrl.dispose();
    _lonCtrl.dispose();
    _hargaCtrl.dispose();
    _fotoCtrl.dispose();
    _kontakCtrl.dispose();
    _diskonCtrl.dispose();
    for (final p in _produk) {
      p.dispose();
    }
    super.dispose();
  }

  Future<void> _pilihJamBuka() async {
    final hasil = await showTimePicker(
      context: context,
      initialTime: _jamBuka ?? const TimeOfDay(hour: 8, minute: 0),
    );
    if (hasil != null) setState(() => _jamBuka = hasil);
  }

  Future<void> _pilihJamTutup() async {
    final hasil = await showTimePicker(
      context: context,
      initialTime: _jamTutup ?? const TimeOfDay(hour: 22, minute: 0),
    );
    if (hasil != null) setState(() => _jamTutup = hasil);
  }

  Future<void> _ambilLokasi() async {
    setState(() => _sedangAmbilLokasi = true);
    final hasil = await context.read<LocationService>().ambilPosisi();
    if (!mounted) return;
    setState(() => _sedangAmbilLokasi = false);

    if (hasil.ada) {
      setState(() {
        _latCtrl.text = hasil.latitude!.toStringAsFixed(6);
        _lonCtrl.text = hasil.longitude!.toStringAsFixed(6);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.errGagalAmbilLokasi)),
      );
    }
  }

  Future<void> _submit() async {
    final formValid = _formKey.currentState?.validate() ?? false;

    setState(() {
      _errOlahraga =
          _jenisOlahraga.isEmpty ? AppStrings.errPilihOlahraga : null;
      // "00:00" berarti TENGAH MALAM (tutup di hari berikutnya), bukan
      // jam 0 di hari yang sama — lihat CLAUDE.md "gampang salah" #jamTutup
      // dan `ajukan_reservasi_screen.dart:_jamTutupHour`. Perbandingan
      // menit-mentah lama di sini menolak SEMUA jam tutup "00:00" karena
      // selalu terbaca lebih kecil dari jam buka manapun — 14 dari 30
      // lapangan seed justru tutup tengah malam. Satu-satunya kombinasi
      // yang benar-benar tidak bermakna adalah jam buka == jam tutup.
      _errJam = (_jamBuka == null || _jamTutup == null)
          ? AppStrings.errJamWajib
          : (_jamBuka! == _jamTutup!)
              ? AppStrings.errJamSama
              : null;
    });

    if (!formValid || _errOlahraga != null || _errJam != null) return;

    final user = context.read<AuthViewModel>().user;
    if (user == null) return;

    final vm = context.read<FormLapanganViewModel>();
    final fotoURL =
        _fotoCtrl.text.trim().isEmpty ? <String>[] : [_fotoCtrl.text.trim()];

    final berhasil = _modeEdit
        ? await vm.perbaruiLapangan(
            widget.lapangan!,
            nama: _namaCtrl.text.trim(),
            alamat: _alamatCtrl.text.trim(),
            latitude: double.parse(_latCtrl.text.trim()),
            longitude: double.parse(_lonCtrl.text.trim()),
            jenisOlahraga: _jenisOlahraga.toList(),
            harga: int.parse(_hargaCtrl.text.trim()),
            jamBuka: Formatter.jamDariPilihan(_jamBuka!),
            jamTutup: Formatter.jamDariPilihan(_jamTutup!),
            fasilitas: _fasilitas.toList(),
            fotoURL: fotoURL,
            nomorTelepon: _kontakCtrl.text.trim(),
            diskonPersen: int.tryParse(_diskonCtrl.text.trim()) ?? 0,
            produkTambahan: _produkTambahan,
          )
        : await vm.tambahLapangan(
            nama: _namaCtrl.text.trim(),
            alamat: _alamatCtrl.text.trim(),
            latitude: double.parse(_latCtrl.text.trim()),
            longitude: double.parse(_lonCtrl.text.trim()),
            jenisOlahraga: _jenisOlahraga.toList(),
            harga: int.parse(_hargaCtrl.text.trim()),
            jamBuka: Formatter.jamDariPilihan(_jamBuka!),
            jamTutup: Formatter.jamDariPilihan(_jamTutup!),
            fasilitas: _fasilitas.toList(),
            fotoURL: fotoURL,
            nomorTelepon: _kontakCtrl.text.trim(),
            diskonPersen: int.tryParse(_diskonCtrl.text.trim()) ?? 0,
            produkTambahan: _produkTambahan,
            pemilikId: user.userId,
          );

    if (!mounted) return;

    if (berhasil) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.lapanganTersimpan)),
      );
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(vm.pesanError ?? AppStrings.errGagalSimpanLapangan)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<FormLapanganViewModel>();

    return Scaffold(
      backgroundColor: context.warna.background,
      appBar: AppBar(
        backgroundColor: context.warna.surface,
        elevation: 0,
        title: Text(
          _modeEdit
              ? AppStrings.editLapanganJudul
              : AppStrings.tambahLapanganJudul,
          style: AppTextStyles.judulSeksi(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.marginLayar),
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
                  controller: _alamatCtrl,
                  decoration:
                      const InputDecoration(labelText: AppStrings.alamat),
                  validator: (v) => Validators.wajib(v, AppStrings.alamat),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _kontakCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: AppStrings.nomorTeleponLapanganOpsional,
                  ),
                  validator: Validators.nomorTelepon,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _latCtrl,
                        keyboardType:
                            const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: AppStrings.latitude,
                        ),
                        validator: (v) => Validators.koordinat(
                          v,
                          namaField: AppStrings.latitude,
                          min: -90,
                          max: 90,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _lonCtrl,
                        keyboardType:
                            const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: AppStrings.longitude,
                        ),
                        validator: (v) => Validators.koordinat(
                          v,
                          namaField: AppStrings.longitude,
                          min: -180,
                          max: 180,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: _sedangAmbilLokasi ? null : _ambilLokasi,
                    icon: _sedangAmbilLokasi
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.my_location, size: 16),
                    label: const Text(AppStrings.ambilLokasiSaatIni),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 0),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  AppStrings.jenisOlahraga,
                  style: AppTextStyles.judulSeksi(context),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    AppSports.futsal,
                    AppSports.miniSoccer,
                    AppSports.badminton,
                    AppSports.padel,
                  ].map((kode) {
                    final aktif = _jenisOlahraga.contains(kode);
                    return FilterChip(
                      label: Text(
                        '${AppSports.ikonDari(kode)} ${AppSports.labelDari(kode)}',
                      ),
                      selected: aktif,
                      onSelected: (dipilih) => setState(() {
                        if (dipilih) {
                          _jenisOlahraga.add(kode);
                        } else {
                          _jenisOlahraga.remove(kode);
                        }
                        _errOlahraga = null;
                      }),
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: aktif ? Colors.white : context.warna.textPrimary,
                      ),
                    );
                  }).toList(),
                ),
                if (_errOlahraga != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      _errOlahraga!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _hargaCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: AppStrings.harga,
                    hintText: AppStrings.hintHarga,
                  ),
                  validator: Validators.harga,
                ),
                const SizedBox(height: 16),
                // v1.5 (T-65) — promo: persen diskon untuk sewa lapangan.
                TextFormField(
                  controller: _diskonCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: AppStrings.diskonPersenOpsional,
                    hintText: AppStrings.hintDiskon,
                    helperText: AppStrings.bantuDiskon,
                    suffixText: '%',
                  ),
                  validator: Validators.diskonPersen,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _TombolPilihJam(
                        label: AppStrings.jamBuka,
                        nilai: _jamBuka == null
                            ? AppStrings.pilihJam
                            : Formatter.jamDariPilihan(_jamBuka!),
                        onTap: _pilihJamBuka,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _TombolPilihJam(
                        label: AppStrings.jamTutup,
                        nilai: _jamTutup == null
                            ? AppStrings.pilihJam
                            : Formatter.jamDariPilihan(_jamTutup!),
                        onTap: _pilihJamTutup,
                      ),
                    ),
                  ],
                ),
                if (_errJam != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      _errJam!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                const SizedBox(height: 20),
                Text(AppStrings.fasilitas, style: AppTextStyles.judulSeksi(context)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: AppFasilitas.daftar.map((f) {
                    final aktif = _fasilitas.contains(f);
                    return FilterChip(
                      label: Text(f),
                      selected: aktif,
                      onSelected: (dipilih) => setState(() {
                        if (dipilih) {
                          _fasilitas.add(f);
                        } else {
                          _fasilitas.remove(f);
                        }
                      }),
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: aktif ? Colors.white : context.warna.textPrimary,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                // v1.5 (T-60) — katalog produk tambahan, maksimal 5.
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppStrings.produkTambahanJudul,
                      style: AppTextStyles.judulSeksi(context),
                    ),
                    TextButton.icon(
                      onPressed: _produk.length >= BatasProduk.jumlahProdukMaksimal
                          ? null
                          : () => setState(() => _produk.add(_ProdukCtrl())),
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text(AppStrings.tambahProduk),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  AppStrings.keteranganProdukTambahan,
                  style: AppTextStyles.metaLapangan(context),
                ),
                const SizedBox(height: 8),
                if (_produk.isEmpty)
                  Text(
                    AppStrings.produkMasihKosong,
                    style: AppTextStyles.metaLapangan(context),
                  ),
                for (var i = 0; i < _produk.length; i++)
                  // Key dari objek controller supaya baris yang dihapus di
                  // tengah tidak "menukar" isi baris sesudahnya.
                  Row(
                    key: ObjectKey(_produk[i]),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          controller: _produk[i].nama,
                          decoration: const InputDecoration(
                            labelText: AppStrings.namaProduk,
                          ),
                          validator: Validators.namaProduk,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          controller: _produk[i].harga,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          decoration: const InputDecoration(
                            labelText: AppStrings.hargaProduk,
                            // Kolom ini sempit; tanpa ini pesan galat yang
                            // panjang dipotong satu baris.
                            errorMaxLines: 3,
                          ),
                          validator: Validators.hargaProduk,
                        ),
                      ),
                      IconButton(
                        onPressed: () => _hapusProduk(i),
                        tooltip: AppStrings.hapusProduk,
                        icon: const Icon(Icons.delete_outline),
                        color: context.warna.textSecondary,
                      ),
                    ],
                  ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _fotoCtrl,
                  keyboardType: TextInputType.url,
                  decoration: const InputDecoration(
                    labelText: AppStrings.urlFotoOpsional,
                  ),
                  validator: Validators.urlOpsional,
                ),
                const SizedBox(height: 28),
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
                      : const Text(AppStrings.simpan),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TombolPilihJam extends StatelessWidget {
  final String label;
  final String nilai;
  final VoidCallback onTap;

  const _TombolPilihJam({
    required this.label,
    required this.nilai,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: context.warna.surfaceVariant, width: 1.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.metaLapangan(context)),
            const SizedBox(height: 2),
            Text(nilai, style: AppTextStyles.namaLapangan(context)),
          ],
        ),
      ),
    );
  }
}

/// Sepasang controller untuk satu baris produk tambahan (nama + harga).
/// Dikelola `_FormLapanganBodyState` — dibuat saat baris ditambah, dan
/// di-dispose saat baris dihapus atau form ditutup.
class _ProdukCtrl {
  final TextEditingController nama;
  final TextEditingController harga;

  _ProdukCtrl({String nama = '', String harga = ''})
      : nama = TextEditingController(text: nama),
        harga = TextEditingController(text: harga);

  void dispose() {
    nama.dispose();
    harga.dispose();
  }
}
