import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/services/location_service.dart';
import '../../../core/utils/validators.dart';
import '../../auth/viewmodel/auth_viewmodel.dart';

/// Bottom sheet "Ubah Lokasi Default" — PRD L-13, T-37 (cadangan AB-03
/// saat GPS ditolak/mati).
///
/// Pengguna memberi nama lokasi (mis. "Rumah") lalu menekan "Ambil Lokasi
/// Saat Ini" — pola yang sama dengan `FormLapanganScreen` (T-26), supaya
/// koordinatnya akurat tanpa perlu mengetik manual.
Future<void> showUbahLokasiDefaultSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => const _UbahLokasiDefaultBody(),
  );
}

class _UbahLokasiDefaultBody extends StatefulWidget {
  const _UbahLokasiDefaultBody();

  @override
  State<_UbahLokasiDefaultBody> createState() =>
      _UbahLokasiDefaultBodyState();
}

class _UbahLokasiDefaultBodyState extends State<_UbahLokasiDefaultBody> {
  final _formKey = GlobalKey<FormState>();
  final _namaCtrl = TextEditingController();
  double? _latitude;
  double? _longitude;
  bool _sedangAmbilLokasi = false;
  bool _sedangProses = false;

  @override
  void initState() {
    super.initState();
    final lokasiSaatIni = context.read<AuthViewModel>().user?.lokasiDefault;
    if (lokasiSaatIni != null) {
      _namaCtrl.text = lokasiSaatIni['nama'] as String? ?? '';
      _latitude = (lokasiSaatIni['latitude'] as num?)?.toDouble();
      _longitude = (lokasiSaatIni['longitude'] as num?)?.toDouble();
    }
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    super.dispose();
  }

  Future<void> _ambilLokasi() async {
    setState(() => _sedangAmbilLokasi = true);
    final hasil = await context.read<LocationService>().ambilPosisi();
    if (!mounted) return;
    setState(() => _sedangAmbilLokasi = false);

    if (hasil.ada) {
      setState(() {
        _latitude = hasil.latitude;
        _longitude = hasil.longitude;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.errGagalAmbilLokasi)),
      );
    }
  }

  Future<void> _simpan() async {
    final formValid = _formKey.currentState?.validate() ?? false;
    if (!formValid || _latitude == null || _longitude == null) {
      if (_latitude == null || _longitude == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.errGagalAmbilLokasi)),
        );
      }
      return;
    }

    setState(() => _sedangProses = true);

    final berhasil = await context.read<AuthViewModel>().ubahLokasiDefault({
      'nama': _namaCtrl.text.trim(),
      'latitude': _latitude,
      'longitude': _longitude,
    });

    if (!mounted) return;
    setState(() => _sedangProses = false);

    if (berhasil) {
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.read<AuthViewModel>().pesanError ??
                'Gagal menyimpan lokasi default.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSizes.marginLayar,
        20,
        AppSizes.marginLayar,
        20 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(AppStrings.lokasiDefault, style: AppTextStyles.judulSeksi),
            const SizedBox(height: 16),
            TextFormField(
              controller: _namaCtrl,
              decoration: const InputDecoration(
                labelText: AppStrings.namaLokasi,
                hintText: AppStrings.contohNamaLokasi,
              ),
              validator: (v) => Validators.wajib(v, AppStrings.namaLokasi),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _latitude == null || _longitude == null
                        ? AppStrings.belumDiatur
                        : '${_latitude!.toStringAsFixed(6)}, '
                            '${_longitude!.toStringAsFixed(6)}',
                    style: AppTextStyles.metaLapangan,
                  ),
                ),
                TextButton.icon(
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
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _sedangProses ? null : _simpan,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusChip),
                ),
              ),
              child: _sedangProses
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
    );
  }
}
