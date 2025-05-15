class Kategori {
  final int id;
  final int userId;
  final String namaKategori;
  final DateTime createdAt;
  final DateTime updatedAt;

  Kategori({
    required this.id,
    required this.userId,
    required this.namaKategori,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Kategori.fromJson(Map<String, dynamic> json) {
    return Kategori(
      id: json['id'],
      userId: json['user_id'],
      namaKategori: json['nama_kategori'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}