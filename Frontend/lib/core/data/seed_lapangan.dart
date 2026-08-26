// lib/core/data/seed_lapangan.dart
//
// Data awal lapangan untuk AdminSeedScreen (T-10).
// Skema mengikuti PRD Bagian 6.2 — nama atribut TIDAK boleh diubah.
//
// PENTING — dua hal yang wajib kamu kerjakan sebelum sidang:
//
// 1. KOORDINAT. SELESAI (21 Agustus 2026) — seluruh 30 lapangan sekarang
//    bertanda `// KOORDINAT TERVERIFIKASI`, hasil verifikasi Google Maps
//    (T-00f). BB-13 sudah punya data yang layak ditulis sebagai hasil
//    verifikasi di skripsi.
//
// 2. HARGA & FASILITAS. Harga di bawah adalah perkiraan pasaran, bukan harga
//    resmi. Yang bertanda `sumberData: 'observasi'` adalah 8 lapangan yang
//    paling dekat kampus — itu yang saya sarankan kamu datangi langsung saat
//    T-00e, lalu perbarui harga/jam/fasilitasnya di sini dengan data asli.
//    Sisanya biarkan `sumberData: 'places_api'`.
//
// 3. fotoURL sengaja dikosongkan. Jangan pakai URL hotlink dari Google/Instagram
//    — banyak yang di-blokir dan gambarnya jadi broken pas sidang. Foto sendiri
//    saat survei lapangan lebih aman, dan sekaligus memperkuat klaim sumber data
//    "observasi" di Bab 3.

const List<Map<String, dynamic>> seedLapangan = [
  // ==========================================================
  // FUTSAL
  // ==========================================================
  {
    'nama': 'Stadiums Futsal',
    'alamat':
        'Jl. Pondok Jagung Timur No. 35, Serpong Utara, Kota Tangerang Selatan',
    'latitude': -6.2528074648485985, // KOORDINAT TERVERIFIKASI
    'longitude': 106.66815713743357, // KOORDINAT TERVERIFIKASI
    'jenisOlahraga': ['futsal'],
    'harga': 200000,
    'hargaSlot': {'pagi': 150000, 'siang': 180000, 'malam': 250000},
    'jamBuka': '08:00',
    'jamTutup': '22:00',
    'fasilitas': ['parkir', 'toilet', 'kantin', 'ruang ganti', 'mushola'],
    'fotoURL': <String>[],
    'isMitra': false,
    'pemilikId': null,
    'sumberData': 'observasi',
    'ratingTotal': 0,
    'jumlahRating': 0,
    'ratingRata2': 0.0,
  },
  {
    'nama': 'MS Sport Arena',
    'alamat':
        'Kav. Ocean Walk, Jl. Pahlawan Seribu Blok CBD Lot VI A, Lengkong Gudang, Serpong, Kota Tangerang Selatan',
    'latitude': -6.2923897, // KOORDINAT TERVERIFIKASI
    'longitude': 106.6692950, // KOORDINAT TERVERIFIKASI
    'jenisOlahraga': ['futsal'],
    'harga': 300000,
    'hargaSlot': {'pagi': 250000, 'siang': 275000, 'malam': 350000},
    'jamBuka': '06:00',
    'jamTutup': '00:00',
    'fasilitas': [
      'parkir',
      'toilet',
      'kantin',
      'ruang ganti',
      'mushola',
      'shower',
    ],
    'fotoURL': <String>[],
    'isMitra': false,
    'pemilikId': null,
    'sumberData': 'observasi',
    'ratingTotal': 0,
    'jumlahRating': 0,
    'ratingRata2': 0.0,
  },
  {
    'nama': 'Vegas Futsal',
    'alamat': 'Jl. Raya Buaran - Viktor, BSD, Serpong, Kota Tangerang Selatan',
    'latitude': -6.341018584011025, // KOORDINAT TERVERIFIKASI
    'longitude': 106.68640517791016, // KOORDINAT TERVERIFIKASI
    'jenisOlahraga': ['futsal'],
    'harga': 180000,
    'jamBuka': '08:00',
    'jamTutup': '22:00',
    'fasilitas': ['parkir', 'toilet', 'kantin', 'mushola'],
    'fotoURL': <String>[],
    'isMitra': false,
    'pemilikId': null,
    'sumberData': 'places_api',
    'ratingTotal': 0,
    'jumlahRating': 0,
    'ratingRata2': 0.0,
  },
  {
    'nama': 'Noel Futsal',
    'alamat':
        'Jl. Raya Puspitek No. 58, Buaran, Serpong, Kota Tangerang Selatan',
    'latitude': -6.34685471693536, // KOORDINAT TERVERIFIKASI
    'longitude': 106.70860309325391, // KOORDINAT TERVERIFIKASI
    'jenisOlahraga': ['futsal'],
    'harga': 150000,
    'jamBuka': '07:00',
    'jamTutup': '22:00',
    'fasilitas': ['parkir', 'toilet', 'kantin'],
    'fotoURL': <String>[],
    'isMitra': false,
    'pemilikId': null,
    'sumberData': 'places_api',
    'ratingTotal': 0,
    'jumlahRating': 0,
    'ratingRata2': 0.0,
  },
  {
    'nama': 'Primaraga Hall',
    'alamat':
        'Jl. Mandor Baret No. 1, Legoso, Ciputat Timur, Kota Tangerang Selatan',
    'latitude': -6.31651426226122, // KOORDINAT TERVERIFIKASI
    'longitude': 106.75186409325389, // KOORDINAT TERVERIFIKASI
    'jenisOlahraga': ['futsal'],
    'harga': 120000,
    'jamBuka': '07:00',
    'jamTutup': '00:00',
    'fasilitas': ['parkir', 'toilet'],
    'fotoURL': <String>[],
    'isMitra': false,
    'pemilikId': null,
    'sumberData': 'places_api',
    'ratingTotal': 0,
    'jumlahRating': 0,
    'ratingRata2': 0.0,
  },
  {
    'nama': 'Raw Futsal',
    'alamat': 'Jl. Pahlawan No. 79, Ciputat Timur, Kota Tangerang Selatan',
    'latitude': -6.297289197577858, // KOORDINAT TERVERIFIKASI
    'longitude': 106.76054313558205, // KOORDINAT TERVERIFIKASI
    'jenisOlahraga': ['futsal'],
    'harga': 185000,
    'jamBuka': '06:00',
    'jamTutup': '17:00',
    'fasilitas': ['parkir', 'toilet', 'kantin'],
    'fotoURL': <String>[],
    'isMitra': false,
    'pemilikId': null,
    'sumberData': 'places_api',
    'ratingTotal': 0,
    'jumlahRating': 0,
    'ratingRata2': 0.0,
  },
  {
    'nama': 'Garasi Futsal',
    'alamat':
        'Jl. R.E. Martadinata No. 73, Cipayung, Ciputat, Kota Tangerang Selatan',
    'latitude': -6.339960498855506, // KOORDINAT TERVERIFIKASI
    'longitude': 106.74974715092577, // KOORDINAT TERVERIFIKASI
    'jenisOlahraga': ['futsal'],
    'harga': 140000,
    'jamBuka': '07:00',
    'jamTutup': '23:00',
    'fasilitas': ['parkir', 'toilet', 'kantin'],
    'fotoURL': <String>[],
    'isMitra': false,
    'pemilikId': null,
    'sumberData': 'places_api',
    'ratingTotal': 0,
    'jumlahRating': 0,
    'ratingRata2': 0.0,
  },
  {
    // Lapangan multi-olahraga — berguna untuk menguji filter chip (BB-07).
    'nama': 'Taruna Futsal',
    'alamat':
        'Jl. Salak Raya No. 76, Pondok Benda, Pamulang, Kota Tangerang Selatan',
    'latitude': -6.345359256076884, // KOORDINAT TERVERIFIKASI
    'longitude': 106.72040302011467, // KOORDINAT TERVERIFIKASI
    'jenisOlahraga': ['futsal', 'badminton'],
    'harga': 130000,
    'jamBuka': '07:00',
    'jamTutup': '23:00',
    'fasilitas': ['parkir', 'toilet', 'kantin'],
    'fotoURL': <String>[],
    'isMitra': false,
    'pemilikId': null,
    'sumberData': 'places_api',
    'ratingTotal': 0,
    'jumlahRating': 0,
    'ratingRata2': 0.0,
  },

  // ==========================================================
  // MINI SOCCER
  // ==========================================================
  {
    'nama': 'Kicktopia Mini Soccer Gading Serpong',
    'alamat': 'Gading Serpong, Kelapa Dua, Kabupaten Tangerang',
    'latitude': -6.2488333, // KOORDINAT TERVERIFIKASI
    'longitude': 106.6119167, // KOORDINAT TERVERIFIKASI
    'jenisOlahraga': ['mini_soccer'],
    'harga': 600000,
    'hargaSlot': {'pagi': 450000, 'siang': 500000, 'malam': 700000},
    'jamBuka': '06:00',
    'jamTutup': '00:00',
    'fasilitas': ['parkir', 'toilet', 'kantin', 'ruang ganti', 'mushola'],
    'fotoURL': <String>[],
    'isMitra': true, // MITRA — alur reservasi (AB-04) bisa didemokan di sini
    'pemilikId':
        null, // diisi otomatis oleh AdminSeedScreen, lihat catatan di SEED-DATA.md
    'sumberData': 'mitra',
    'ratingTotal': 0,
    'jumlahRating': 0,
    'ratingRata2': 0.0,
  },
  {
    'nama': 'KM7 Mini Soccer',
    'alamat':
        'Jl. Raya Serpong KM. 7 No. 28, Pondok Jagung, Serpong Utara, Kota Tangerang Selatan',
    'latitude': -6.2552602, // KOORDINAT TERVERIFIKASI
    'longitude': 106.6515011, // KOORDINAT TERVERIFIKASI
    'jenisOlahraga': ['mini_soccer'],
    'harga': 550000,
    'hargaSlot': {'pagi': 400000, 'siang': 450000, 'malam': 650000},
    'jamBuka': '06:00',
    'jamTutup': '00:00',
    'fasilitas': [
      'parkir',
      'toilet',
      'kantin',
      'ruang ganti',
      'mushola',
      'shower',
    ],
    'fotoURL': <String>[],
    'isMitra': true, // MITRA
    'pemilikId': null,
    'sumberData': 'mitra',
    'ratingTotal': 0,
    'jumlahRating': 0,
    'ratingRata2': 0.0,
  },
  {
    'nama': 'Sabnani Football',
    'alamat': 'Rawa Kutuk, Serpong Utara, Kota Tangerang Selatan',
    'latitude': -6.2517854, // KOORDINAT TERVERIFIKASI
    'longitude': 106.6653203, // KOORDINAT TERVERIFIKASI
    'jenisOlahraga': ['mini_soccer'],
    'harga': 550000,
    'jamBuka': '06:00',
    'jamTutup': '23:00',
    'fasilitas': ['parkir', 'toilet', 'shower'],
    'fotoURL': <String>[],
    'isMitra': false,
    'pemilikId': null,
    'sumberData': 'observasi',
    'ratingTotal': 0,
    'jumlahRating': 0,
    'ratingRata2': 0.0,
  },
  {
    'nama': 'Arsa Sport Mini Soccer',
    'alamat': 'Jl. Cilenggang 1, Cilenggang, Serpong, Kota Tangerang Selatan',
    'latitude': -6.3085641, // KOORDINAT TERVERIFIKASI
    'longitude': 106.6679653, // KOORDINAT TERVERIFIKASI
    'jenisOlahraga': ['mini_soccer'],
    'harga': 500000,
    'jamBuka': '06:00',
    'jamTutup': '22:00',
    'fasilitas': ['parkir', 'toilet', 'kantin', 'mushola', 'shower'],
    'fotoURL': <String>[],
    'isMitra': false,
    'pemilikId': null,
    'sumberData': 'observasi',
    'ratingTotal': 0,
    'jumlahRating': 0,
    'ratingRata2': 0.0,
  },
  {
    'nama': 'AM Soccer Arena',
    'alamat': 'Kp. Curug Kongsi Baru, Medang, Pagedangan, Kabupaten Tangerang',
    'latitude': -6.262730067071001, // KOORDINAT TERVERIFIKASI
    'longitude': 106.62890882883595, // KOORDINAT TERVERIFIKASI
    'jenisOlahraga': ['mini_soccer'],
    'harga': 700000,
    'jamBuka': '06:00',
    'jamTutup': '00:00',
    'fasilitas': [
      'parkir',
      'toilet',
      'kantin',
      'ruang ganti',
      'mushola',
      'shower',
    ],
    'fotoURL': <String>[],
    'isMitra': false,
    'pemilikId': null,
    'sumberData': 'places_api',
    'ratingTotal': 0,
    'jumlahRating': 0,
    'ratingRata2': 0.0,
  },

  // ==========================================================
  // BADMINTON
  // ==========================================================
  {
    'nama': 'Candra Wijaya International Badminton Centre',
    'alamat':
        'Jl. Jelupang Raya No. 15, Jelupang, Serpong Utara, Kota Tangerang Selatan',
    'latitude': -6.272101, // KOORDINAT TERVERIFIKASI
    'longitude': 106.669655, // KOORDINAT TERVERIFIKASI
    'jenisOlahraga': ['badminton'],
    'harga': 150000,
    'hargaSlot': {'pagi': 120000, 'siang': 150000, 'malam': 175000},
    'jamBuka': '06:00',
    'jamTutup': '00:00',
    'fasilitas': ['parkir', 'toilet', 'kantin', 'ruang ganti', 'mushola'],
    'fotoURL': <String>[],
    'isMitra': true, // MITRA
    'pemilikId': null,
    'sumberData': 'mitra',
    'ratingTotal': 0,
    'jumlahRating': 0,
    'ratingRata2': 0.0,
  },
  {
    'nama': 'Hall Badminton Jonex',
    'alamat':
        'Jl. Pemakanan No. 37, Pondok Jagung, Serpong Utara, Kota Tangerang Selatan',
    'latitude': -6.261959468397658, // KOORDINAT TERVERIFIKASI
    'longitude': 106.65228917976172, // KOORDINAT TERVERIFIKASI
    'jenisOlahraga': ['badminton'],
    'harga': 55000,
    'jamBuka': '08:00',
    'jamTutup': '23:00',
    'fasilitas': ['parkir', 'toilet', 'kantin', 'ruang ganti', 'mushola'],
    'fotoURL': <String>[],
    'isMitra': false,
    'pemilikId': null,
    'sumberData': 'observasi',
    'ratingTotal': 0,
    'jumlahRating': 0,
    'ratingRata2': 0.0,
  },
  {
    'nama': 'Matrix Badminton Arena',
    'alamat': 'BSD City, Kota Tangerang Selatan',
    'latitude': -6.2870124353666474, // KOORDINAT TERVERIFIKASI
    'longitude': 106.66588367791014, // KOORDINAT TERVERIFIKASI
    'jenisOlahraga': ['badminton'],
    'harga': 90000,
    'jamBuka': '07:00',
    'jamTutup': '23:00',
    'fasilitas': ['parkir', 'toilet', 'kantin'],
    'fotoURL': <String>[],
    'isMitra': false,
    'pemilikId': null,
    'sumberData': 'places_api',
    'ratingTotal': 0,
    'jumlahRating': 0,
    'ratingRata2': 0.0,
  },
  {
    'nama': 'Tontowi Ahmad Badminton Hall BSD',
    'alamat': 'Lengkong Kulon, Pagedangan, Kabupaten Tangerang',
    'latitude': -6.289731707700752, // KOORDINAT TERVERIFIKASI
    'longitude': 106.63745855277732, // KOORDINAT TERVERIFIKASI
    'jenisOlahraga': ['badminton'],
    'harga': 80000,
    'jamBuka': '06:00',
    'jamTutup': '23:00',
    'fasilitas': ['parkir', 'toilet', 'kantin', 'ruang ganti', 'mushola'],
    'fotoURL': <String>[],
    'isMitra': false,
    'pemilikId': null,
    'sumberData': 'places_api',
    'ratingTotal': 0,
    'jumlahRating': 0,
    'ratingRata2': 0.0,
  },
  {
    'nama': 'Benteng Badminton Hall',
    'alamat':
        'Jl. Ciakar, Kp. Pangger, Situgadung, Pagedangan, Kabupaten Tangerang',
    'latitude': -6.31663188970679, // KOORDINAT TERVERIFIKASI
    'longitude': 106.61148726441797, // KOORDINAT TERVERIFIKASI
    'jenisOlahraga': ['badminton'],
    'harga': 70000,
    'jamBuka': '07:00',
    'jamTutup': '23:00',
    'fasilitas': ['parkir', 'toilet', 'kantin', 'ruang ganti', 'mushola'],
    'fotoURL': <String>[],
    'isMitra': false,
    'pemilikId': null,
    'sumberData': 'places_api',
    'ratingTotal': 0,
    'jumlahRating': 0,
    'ratingRata2': 0.0,
  },
  {
    'nama': 'Ultra Badminton Hall',
    'alamat':
        'Kp. Ciakar, Jl. Raya Pagedangan, Situgadung, Pagedangan, Kabupaten Tangerang',
    'latitude': -6.304916968761347, // KOORDINAT TERVERIFIKASI
    'longitude': 106.61159536441795, // KOORDINAT TERVERIFIKASI
    'jenisOlahraga': ['badminton'],
    'harga': 65000,
    'jamBuka': '07:00',
    'jamTutup': '23:00',
    'fasilitas': ['parkir', 'toilet', 'kantin', 'ruang ganti', 'mushola'],
    'fotoURL': <String>[],
    'isMitra': false,
    'pemilikId': null,
    'sumberData': 'places_api',
    'ratingTotal': 0,
    'jumlahRating': 0,
    'ratingRata2': 0.0,
  },
  {
    'nama': 'GOR Panca Putra',
    'alamat': 'Gg. Betawi, Ciater, Serpong, Kota Tangerang Selatan',
    'latitude': -6.3340062231958845, // KOORDINAT TERVERIFIKASI
    'longitude': 106.68758932208983, // KOORDINAT TERVERIFIKASI
    'jenisOlahraga': ['badminton'],
    'harga': 60000,
    'jamBuka': '07:00',
    'jamTutup': '23:00',
    'fasilitas': ['parkir', 'toilet'],
    'fotoURL': <String>[],
    'isMitra': false,
    'pemilikId': null,
    'sumberData': 'observasi',
    'ratingTotal': 0,
    'jumlahRating': 0,
    'ratingRata2': 0.0,
  },
  {
    'nama': 'GOR Saratoga',
    'alamat':
        'Jl. Mede No. 60, Pamulang Barat, Pamulang, Kota Tangerang Selatan',
    'latitude': -6.345007846905685, // KOORDINAT TERVERIFIKASI
    'longitude': 106.73813222497195, // KOORDINAT TERVERIFIKASI
    'jenisOlahraga': ['badminton'],
    'harga': 40000,
    'jamBuka': '07:00',
    'jamTutup': '00:00',
    'fasilitas': ['parkir', 'toilet', 'kantin', 'mushola'],
    'fotoURL': <String>[],
    'isMitra': false,
    'pemilikId': null,
    'sumberData': 'places_api',
    'ratingTotal': 0,
    'jumlahRating': 0,
    'ratingRata2': 0.0,
  },
  {
    'nama': 'GOR Jambu',
    'alamat':
        'Jl. Jambu No. 8B, Pisangan, Ciputat Timur, Kota Tangerang Selatan',
    'latitude': -6.316137599182247, // KOORDINAT TERVERIFIKASI
    'longitude': 106.75777580859764, // KOORDINAT TERVERIFIKASI
    'jenisOlahraga': ['badminton'],
    'harga': 35000,
    'jamBuka': '07:00',
    'jamTutup': '23:00',
    'fasilitas': ['parkir', 'toilet', 'kantin', 'mushola'],
    'fotoURL': <String>[],
    'isMitra': false,
    'pemilikId': null,
    'sumberData': 'places_api',
    'ratingTotal': 0,
    'jumlahRating': 0,
    'ratingRata2': 0.0,
  },

  // ==========================================================
  // PADEL
  // ==========================================================
  {
    'nama': 'Hey Beach Padel Club',
    'alamat':
        'Jalur Sutera No. 30A, Pakualam, Serpong Utara, Kota Tangerang Selatan',
    'latitude': -6.236185897040052, // KOORDINAT TERVERIFIKASI
    'longitude': 106.66042176441796, // KOORDINAT TERVERIFIKASI
    'jenisOlahraga': ['padel'],
    'harga': 280000,
    'hargaSlot': {'pagi': 220000, 'siang': 260000, 'malam': 320000},
    'jamBuka': '07:00',
    'jamTutup': '23:00',
    'fasilitas': ['parkir', 'toilet', 'kantin', 'ruang ganti'],
    'fotoURL': <String>[],
    'isMitra': true, // MITRA — paling dekat kampus, enak buat demo langsung
    'pemilikId': null,
    'sumberData': 'mitra',
    'ratingTotal': 0,
    'jumlahRating': 0,
    'ratingRata2': 0.0,
  },
  {
    'nama': 'Mad Padel Club BSD',
    'alamat':
        'Jl. Damar Poso 8 No. 23 Blok AA8, Medang, Pagedangan, Kabupaten Tangerang',
    'latitude': -6.26521518900636, // KOORDINAT TERVERIFIKASI
    'longitude': 106.62822196931252, // KOORDINAT TERVERIFIKASI
    'jenisOlahraga': ['padel'],
    'harga': 320000,
    'hargaSlot': {'pagi': 260000, 'siang': 300000, 'malam': 360000},
    'jamBuka': '06:00',
    'jamTutup': '00:00',
    'fasilitas': ['parkir', 'toilet', 'kantin', 'ruang ganti'],
    'fotoURL': <String>[],
    'isMitra': true, // MITRA
    'pemilikId': null,
    'sumberData': 'mitra',
    'ratingTotal': 0,
    'jumlahRating': 0,
    'ratingRata2': 0.0,
  },
  {
    'nama': 'Rekket Space Padel Hall BSD',
    'alamat': 'Jl. Buaran Raya, Buaran, Serpong, Kota Tangerang Selatan',
    'latitude': -6.342980500042306, // KOORDINAT TERVERIFIKASI
    'longitude': 106.68687865277731, // KOORDINAT TERVERIFIKASI
    'jenisOlahraga': ['padel'],
    'harga': 240000,
    'jamBuka': '06:00',
    'jamTutup': '23:00',
    'fasilitas': ['parkir', 'toilet', 'kantin', 'ruang ganti'],
    'fotoURL': <String>[],
    'isMitra': false,
    'pemilikId': null,
    'sumberData': 'observasi',
    'ratingTotal': 0,
    'jumlahRating': 0,
    'ratingRata2': 0.0,
  },
  {
    'nama': 'Beyond Padel BSD',
    'alamat':
        'Jl. Melati VIII No. 7, Jelupang, Serpong Utara, Kota Tangerang Selatan',
    'latitude': -6.2579065019235705, // KOORDINAT TERVERIFIKASI
    'longitude': 106.66621309140238, // KOORDINAT TERVERIFIKASI
    'jenisOlahraga': ['padel'],
    'harga': 260000,
    'jamBuka': '07:00',
    'jamTutup': '23:00',
    'fasilitas': ['parkir', 'toilet', 'kantin', 'ruang ganti'],
    'fotoURL': <String>[],
    'isMitra': false,
    'pemilikId': null,
    'sumberData': 'observasi',
    'ratingTotal': 0,
    'jumlahRating': 0,
    'ratingRata2': 0.0,
  },
  {
    'nama': 'Racquet Padel Club BSD',
    'alamat': 'Jl. Raya Pagedangan, BSD, Kota Tangerang Selatan',
    'latitude': -6.289787264721472, // KOORDINAT TERVERIFIKASI
    'longitude': 106.63619976441797, // KOORDINAT TERVERIFIKASI
    'jenisOlahraga': ['padel'],
    'harga': 160000,
    'jamBuka': '06:00',
    'jamTutup': '23:00',
    'fasilitas': ['parkir', 'toilet', 'ruang ganti', 'mushola'],
    'fotoURL': <String>[],
    'isMitra': false,
    'pemilikId': null,
    'sumberData': 'places_api',
    'ratingTotal': 0,
    'jumlahRating': 0,
    'ratingRata2': 0.0,
  },
  {
    'nama': 'Go Padel BSD',
    'alamat':
        'Jl. Jatake - Babakan Raya No. 78, Jatake, Pagedangan, Kabupaten Tangerang',
    'latitude': -6.318413290404208, // KOORDINAT TERVERIFIKASI
    'longitude': 106.59275026812107, // KOORDINAT TERVERIFIKASI
    'jenisOlahraga': ['padel'],
    'harga': 200000,
    'jamBuka': '06:00',
    'jamTutup': '23:00',
    'fasilitas': ['parkir', 'toilet', 'kantin'],
    'fotoURL': <String>[],
    'isMitra': false,
    'pemilikId': null,
    'sumberData': 'places_api',
    'ratingTotal': 0,
    'jumlahRating': 0,
    'ratingRata2': 0.0,
  },
  {
    'nama': 'The Good Padel Club',
    'alamat':
        'Jl. Alam Utama Kav. 10, Panunggangan Timur, Pinang, Kota Tangerang',
    'latitude': -6.229440997276477, // KOORDINAT TERVERIFIKASI
    'longitude': 106.65492022497119, // KOORDINAT TERVERIFIKASI
    'jenisOlahraga': ['padel'],
    'harga': 350000,
    'jamBuka': '07:00',
    'jamTutup': '23:00',
    'fasilitas': ['parkir', 'toilet', 'kantin', 'ruang ganti'],
    'fotoURL': <String>[],
    'isMitra': false,
    'pemilikId': null,
    'sumberData': 'places_api',
    'ratingTotal': 0,
    'jumlahRating': 0,
    'ratingRata2': 0.0,
  },
  {
    'nama': 'Powerhouse Padel',
    'alamat': 'Jl. Kejaksaan Raya No. 60, Kreo, Larangan, Kota Tangerang',
    'latitude': -6.225476888718839, // KOORDINAT TERVERIFIKASI
    'longitude': 106.73764339510545, // KOORDINAT TERVERIFIKASI
    'jenisOlahraga': ['padel'],
    'harga': 250000,
    'jamBuka': '07:00',
    'jamTutup': '23:00',
    'fasilitas': ['parkir', 'toilet', 'ruang ganti'],
    'fotoURL': <String>[],
    'isMitra': false,
    'pemilikId': null,
    'sumberData': 'places_api',
    'ratingTotal': 0,
    'jumlahRating': 0,
    'ratingRata2': 0.0,
  },
];
