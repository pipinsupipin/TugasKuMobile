import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'tugas.dart';

class Kategori {
  final String namaKategori;
  final IconData icon;
  late String tanggal;
  late int sisaTugas;
  late int totalTugas;
  late double progressDecimal;

  Kategori({
    required this.namaKategori,
    required this.icon,
  }) {
    _hitungData();
  }

  void _hitungData() {
    List<Tugas> tugasDalamKategori = tugas.where((t) => t.kategoriTugas == namaKategori).toList();
    totalTugas = tugasDalamKategori.length;
    sisaTugas = tugasDalamKategori.where((t) => t.isCompleted).length;
    progressDecimal = totalTugas > 0 ? sisaTugas / totalTugas : 0.0;
    
    if (tugasDalamKategori.isNotEmpty) {
      DateTime deadlineTerdekat = tugasDalamKategori
          .where((t) => t.waktuSelesai != null)
          .map((t) => t.waktuSelesai!)
          .reduce((a, b) => a.isBefore(b) ? a : b);
      tanggal = "${deadlineTerdekat.day} ${_bulan(deadlineTerdekat.month)}, ${_formatJam(deadlineTerdekat)}";
    } else {
      tanggal = "-";
    }
  }

  String _bulan(int bulan) {
    const bulanNama = ["Januari", "Februari", "Maret", "April", "Mei", "Juni", "Juli", "Agustus", "September", "Oktober", "November", "Desember"];
    return bulanNama[bulan - 1];
  }

  String _formatJam(DateTime dt) {
    String jam = dt.hour.toString().padLeft(2, '0');
    String menit = dt.minute.toString().padLeft(2, '0');
    return "$jam:$menit";
  }
}

var kategori = [
  Kategori(namaKategori: 'Proyek', icon: LucideIcons.construction),
  Kategori(namaKategori: 'Tugas', icon: LucideIcons.clipboardList),
  Kategori(namaKategori: 'Rapat', icon: LucideIcons.users),
  Kategori(namaKategori: 'Ujian', icon: LucideIcons.pencil),
];