import 'kategori.dart';

class Tugas {
  final int id;
  final int userId;
  final int kategoriId;
  final String judul;
  final String? deskripsi;
  final DateTime? waktuMulai;
  final DateTime? waktuSelesai;
  final bool isCompleted;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Kategori kategori;

  Tugas({
    required this.id,
    required this.userId,
    required this.kategoriId,
    required this.judul,
    this.deskripsi,
    this.waktuMulai,
    this.waktuSelesai,
    required this.isCompleted,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.kategori,
  });

  Tugas copyWith({
    int? id,
    int? userId,
    int? kategoriId,
    String? judul,
    String? deskripsi,
    DateTime? waktuMulai,
    DateTime? waktuSelesai,
    bool? isCompleted,
    DateTime? completedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    Kategori? kategori,
  }) {
    return Tugas(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      kategoriId: kategoriId ?? this.kategoriId,
      judul: judul ?? this.judul,
      deskripsi: deskripsi ?? this.deskripsi,
      waktuMulai: waktuMulai ?? this.waktuMulai,
      waktuSelesai: waktuSelesai ?? this.waktuSelesai,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      kategori: kategori ?? this.kategori,
    );
  }

  factory Tugas.fromJson(Map<String, dynamic> json) {
    return Tugas(
      id: json['id'],
      userId: json['user_id'],
      kategoriId: json['kategori_id'],
      judul: json['judul'],
      deskripsi: json['deskripsi'],
      waktuMulai: DateTime.parse(json['waktu_mulai']),
      waktuSelesai: json['waktu_selesai'] != null
          ? DateTime.parse(json['waktu_selesai'])
          : null,
      isCompleted: json['is_completed'],
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      kategori: Kategori.fromJson(json['kategori']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "kategori_id": kategoriId,
      "judul": judul,
      "deskripsi": deskripsi,
      "waktu_mulai": waktuMulai?.toIso8601String(),
      "waktu_selesai": waktuSelesai?.toIso8601String(),
      "is_completed": isCompleted,
      "completed_at": completedAt?.toIso8601String(),
    };
  }
}