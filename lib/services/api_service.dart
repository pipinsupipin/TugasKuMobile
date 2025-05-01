import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final String baseUrl = 'http://localhost:8000/api';
  
  // Menyimpan token
  Future<bool> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString('auth_token', token);
  }
  
  // Mendapatkan token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }
  
  // Menghapus token (logout)
  Future<bool> deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.remove('auth_token');
  }
  
  // Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );
      
      if (response.statusCode == 200) {
        String token = response.body;
        await saveToken(token);
        return {'success': true, 'token': token};
      } else {
        return {'success': false, 'message': 'Username atau Password Salah!'};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
  
  // Logout
  Future<bool> logout() async {
    try {
      final token = await getToken();
      
      if (token == null) {
        return false;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/auth/logout'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200 || response.statusCode == 204) {
        await deleteToken();
        return true;
      } else {
        await deleteToken();
        return true;
      }
    } catch (e) {
      await deleteToken();
      return true;
    }
  }

  // Register
  Future<Map<String, dynamic>> register(String name, String email, String password, String passwordConfirmation) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
        }),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        String token = response.body;
        await saveToken(token);
        return {'success': true, 'token': token};
      } else {
        var data = jsonDecode(response.body);
        return {'success': false, 'message': data['message'] ?? 'Registrasi gagal'};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}