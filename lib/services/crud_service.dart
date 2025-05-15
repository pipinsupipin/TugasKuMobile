import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tugasku/models/tugas.dart';
import 'package:tugasku/models/kategori.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final String baseUrl = 'http://localhost:8000/api';

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Membuat headers dengan token
  Future<Map<String, String>> _getHeaders() async {
    String? token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Mendapatkan semua kategori tugas
  Future<List<Kategori>> getKategoriTugas() async {
    final response =
        await http.get(Uri.parse('$baseUrl/kategori'), 
        headers: await _getHeaders(),
      );
        
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);

      if (body['success']) {
        List<dynamic> data = body['data'];
        List<Kategori> kategoriList =
            data.map((item) => Kategori.fromJson(item)).toList();
        return kategoriList;
      } else {
        throw Exception('Gagal mengambil data kategori');
      }
    } else {
      throw Exception('Error: ${response.statusCode}');
    }
  }

  // Mendapatkan semua tugas
  Future<List<Tugas>> getTugas() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/tugas'),
        headers: await _getHeaders(),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success'] && responseData['data'] != null) {
          // Parsing JSON ke List<Tugas>
          List<Tugas> tugasList = (responseData['data'] as List)
              .map((json) => Tugas.fromJson(json))
              .toList();
          return tugasList;
        } else {
          throw Exception('Data tidak ditemukan');
        }
      } else {
        throw Exception('Gagal memuat data tugas');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Mendapatkan detail tugas berdasarkan ID
  Future<Tugas> getTugasById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/tugas/$id'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] && responseData['data'] != null) {
          return Tugas.fromJson(responseData['data']);
        } else {
          throw Exception('Tugas tidak ditemukan');
        }
      } else {
        throw Exception('Gagal memuat detail tugas');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<Map<String, dynamic>> getStreakData() async {
    final response = await http.get(
      Uri.parse('$baseUrl/streaks/summary'),
      headers: await _getHeaders(),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load streak data');
    }
  }

  // Menambah tugas baru
  Future<Map<String, dynamic>> createTugas(Map<String, dynamic> tugas) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/tugas'),
        headers: await _getHeaders(),
        body: jsonEncode(tugas),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return {
          "success": true,
          "message": responseData['message'],
          "data": responseData['data']
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          "success": false,
          "message": errorData['message'] ?? "Gagal menambahkan tugas"
        };
      }
    } catch (e) {
      return {"success": false, "message": "Error saat menambah tugas: $e"};
    }
  }

  // Memperbarui tugas
  Future<Tugas> updateTugas(Tugas tugas) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/tugas/${tugas.id}'),
        headers: await _getHeaders(),
        body: json.encode(tugas.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] && responseData['data'] != null) {
          return Tugas.fromJson(responseData['data']);
        } else {
          throw Exception('Gagal memperbarui tugas');
        }
      } else {
        throw Exception('Gagal memperbarui tugas: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Menghapus tugas
  Future<bool> deleteTugas(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/tugas/$id'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return responseData['success'] ?? false;
      } else {
        throw Exception('Gagal menghapus tugas');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
