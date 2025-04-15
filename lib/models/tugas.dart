class Tugas {
  final String namaTugas;
  final DateTime? waktuMulai;
  final DateTime? waktuSelesai;
  final String kategoriTugas;
  final String? catatan;
  final bool isCompleted;

  Tugas({
    required this.namaTugas,
    this.waktuMulai,
    this.waktuSelesai,
    required this.kategoriTugas,
    this.catatan,
    this.isCompleted = false,
  }) {

    if (waktuMulai == null && waktuSelesai == null) {
      throw ArgumentError('Minimal salah satu waktu harus terisi');
    }
  }
}

var tugas = [
  Tugas(
    namaTugas: 'Pembangunan Gapura',
    waktuMulai: DateTime(2025, 4, 14, 8, 0),
    waktuSelesai: DateTime(2025, 4, 14, 10, 0),
    kategoriTugas: 'Proyek',
    catatan: 'Proyek pembangunan gapura di gang V raya sebelah masjid pagar hijau.',
    isCompleted: true,
  ),
  Tugas(
    namaTugas: 'Tugas Web Design',
    waktuMulai: null,
    waktuSelesai: DateTime(2025, 4, 14, 12, 0),
    kategoriTugas: 'Tugas',
    catatan: null,
    isCompleted: true,
  ),
  Tugas(
    namaTugas: 'Diskusi Proposal Proyek',
    waktuMulai: DateTime(2025, 4, 14, 13, 30),
    waktuSelesai: DateTime(2025, 4, 14, 15, 0),
    kategoriTugas: 'Proyek',
    catatan: 'Bahas bab 3 proposal',
    isCompleted: false,
  ),
  Tugas(
    namaTugas: 'Rapat Koordinasi Tim',
    waktuMulai: DateTime(2025, 4, 14, 16, 0),
    waktuSelesai: DateTime(2025, 4, 14, 17, 30),
    kategoriTugas: 'Rapat',
    catatan: 'Evaluasi progress minggu ini',
    isCompleted: false,
  ),
  Tugas(
    namaTugas: 'Ujian Analisis Data',
    waktuMulai: DateTime(2025, 4, 15, 9, 0),
    waktuSelesai: DateTime(2025, 4, 15, 11, 0),
    kategoriTugas: 'Ujian',
    catatan: 'Pelajari regresi linear',
    isCompleted: false,
  ),
  Tugas(
    namaTugas: 'Implementasi Backend API',
    waktuMulai: DateTime(2025, 4, 15, 14, 0),
    waktuSelesai: null,
    kategoriTugas: 'Proyek',
    catatan: 'Integrasi dengan frontend',
    isCompleted: true,
  ),
  Tugas(
    namaTugas: 'Presentasi Hasil Proyek',
    waktuMulai: DateTime(2025, 4, 16, 10, 0),
    waktuSelesai: DateTime(2025, 4, 16, 11, 30),
    kategoriTugas: 'Proyek',
    catatan: 'Siapkan slide dan demo',
    isCompleted: false,
  ),
  Tugas(
    namaTugas: 'Rapat Evaluasi Kinerja',
    waktuMulai: null,
    waktuSelesai: DateTime(2025, 4, 16, 15, 0),
    kategoriTugas: 'Rapat',
    catatan: 'Diskusi target bulan depan',
    isCompleted: true,
  ),
  Tugas(
    namaTugas: 'Ujian Keamanan Jaringan',
    waktuMulai: DateTime(2025, 4, 17, 8, 0),
    waktuSelesai: DateTime(2025, 4, 17, 10, 0),
    kategoriTugas: 'Ujian',
    catatan: 'Fokus pada enkripsi data',
    isCompleted: false,
  ),
  Tugas(
    namaTugas: 'Pengumpulan Tugas Machine Learning',
    waktuMulai: null,
    waktuSelesai: DateTime(2025, 4, 18, 23, 59),
    kategoriTugas: 'Tugas',
    catatan: 'Selesaikan model prediksi',
    isCompleted: false,
  ),
];