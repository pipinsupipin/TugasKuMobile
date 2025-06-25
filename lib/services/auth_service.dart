import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tugasku/utils/flushbar_helper.dart';
// import 'package:tugasku/services/crud_service.dart';
// import 'package:tugasku/models/kategori.dart';

class AuthService {
  final String baseUrl = 'https://tugas-ku.cloud/api';
  // final ApiService _apiService = ApiService();

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

  // Ambil Headers
  Future<Map<String, String>> _getHeaders() async {
    String? token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Ambil info user
  Future<Map<String, dynamic>> getUserData() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load user data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error occurred while fetching user data: $e');
    }
  }

  // Update user profile
  Future<Map<String, dynamic>> updateProfile(
      {required String name, File? profilePicture}) async {
    try {
      final headers = await _getHeaders();

      // Gunakan multipart request dengan metode POST (bukan PUT)
      if (profilePicture != null) {
        // Remove Content-Type karena akan diatur oleh multipart
        headers.remove('Content-Type');

        // Buat multipart request dengan metode POST
        final request = http.MultipartRequest(
          'POST', // Metode POST karena sudah terbukti works di backend
          Uri.parse('$baseUrl/user/profile'),
        );

        // Tambahkan headers termasuk Authorization
        request.headers.addAll(headers);

        // Tambahkan field name
        request.fields['name'] = name;

        // Tambahkan file image
        final fileExtension = profilePicture.path.split('.').last.toLowerCase();
        final mimeType =
            'image/${fileExtension == 'jpg' ? 'jpeg' : fileExtension}';

        debugPrint('Adding file with mime type: $mimeType');

        request.files.add(
          await http.MultipartFile.fromPath(
            'profile_picture',
            profilePicture.path,
            contentType: MediaType.parse(mimeType),
          ),
        );

        // Kirim request
        debugPrint('Sending multipart request...');
        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);

        debugPrint('Response status: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');

        if (response.statusCode == 200) {
          return jsonDecode(response.body);
        } else {
          throw Exception(
              'Failed to update profile: ${response.statusCode} - ${response.body}');
        }
      }
      // Jika tidak ada profile picture, gunakan POST biasa
      else {
        final response = await http.post(
          Uri.parse('$baseUrl/user/profile'),
          headers: headers,
          body: jsonEncode({
            'name': name,
          }),
        );

        debugPrint('Response status: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');

        if (response.statusCode == 200) {
          return jsonDecode(response.body);
        } else {
          throw Exception(
              'Failed to update profile: ${response.statusCode} - ${response.body}');
        }
      }
    } catch (e) {
      debugPrint('Error occurred while updating profile: $e');
      throw Exception('Error updating profile: $e');
    }
  }

// Change password
  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    try {
      // Gunakan metode POST untuk konsistensi dengan backend
      final response = await http.post(
        Uri.parse('$baseUrl/user/password'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'current_password': currentPassword,
          'new_password': newPassword,
          'new_password_confirmation': newPasswordConfirmation,
        }),
      );

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
            'Failed to change password: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('Error occurred while changing password: $e');
      throw Exception('Error changing password: $e');
    }
  }

// Login
  Future<Map<String, dynamic>> login(
      String email, String password, BuildContext context) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      Map<String, dynamic> responseData = {};
      if (response.body.isNotEmpty) {
        try {
          responseData = jsonDecode(response.body);
        } catch (e) {
          // Jika gagal parsing JSON, asumsikan response tidak valid
          responseData = {};
        }
      }

      if (response.statusCode == 200) {
        // ✅ Ambil token dan user
        final token = responseData['token'];
        final user = responseData['user'];
        final role = user['role'];

        await saveToken(
            token); // Simpan token ke local storage atau secure storage
        // Bisa juga: await saveUserData(user);

        showCustomSnackbar(
          context: context,
          message: 'Login berhasil! Selamat datang kembali.',
          isSuccess: true,
        );

        return {
          'success': true,
          'token': token,
          'role': role,
          'user': user,
        };
      } else if (response.statusCode == 422 || response.statusCode == 401) {
        String errorMessage = 'Login gagal';

        if (responseData.containsKey('errors')) {
          final errors = responseData['errors'] as Map<String, dynamic>;

          if (errors.containsKey('email') &&
              errors['email'] is List &&
              errors['email'].isNotEmpty &&
              errors['email'][0]
                  .toString()
                  .contains('credentials are incorrect')) {
            errorMessage =
                'Email atau kata sandi salah. Silakan periksa kembali.';
          } else if (errors.containsKey('password') &&
              errors['password'] is List &&
              errors['password'].isNotEmpty &&
              errors['password'][0]
                  .toString()
                  .contains('password field is required')) {
            errorMessage = 'Kata sandi tidak boleh kosong.';
          } else if (errors.containsKey('email') &&
              errors['email'] is List &&
              errors['email'].isNotEmpty &&
              errors['email'][0]
                  .toString()
                  .contains('email field is required')) {
            errorMessage = 'Email tidak boleh kosong.';
          } else if (errors.containsKey('email') &&
              errors.containsKey('password')) {
            errorMessage = 'Email dan kata sandi tidak boleh kosong.';
          } else if (errors.isNotEmpty) {
            String fieldName = errors.keys.first;
            if (errors[fieldName] is List && errors[fieldName].isNotEmpty) {
              errorMessage = errors[fieldName][0];
            }
          }
        }

        showCustomSnackbar(
          context: context,
          message: errorMessage,
          isSuccess: false,
        );
        return {
          'success': false,
          'message': errorMessage,
        };
      } else {
        String errorMessage = 'Login gagal. Terjadi kesalahan pada server.';
        if (responseData.containsKey('message')) {
          errorMessage = responseData['message'];
        }

        showCustomSnackbar(
          context: context,
          message: errorMessage,
          isSuccess: false,
        );
        return {
          'success': false,
          'message': errorMessage,
        };
      }
    } catch (e) {
      showCustomSnackbar(
        context: context,
        message: 'Terjadi kesalahan: $e',
        isSuccess: false,
      );
      return {'success': false, 'message': 'Terjadi kesalahan: $e'};
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
  Future<Map<String, dynamic>> register(String name, String email,
      String password, String passwordConfirmation) async {
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
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        if (responseData.containsKey('token')) {
          String token = responseData['token'];
          await saveToken(token); // Menyimpan token di local storage
          return {
            'success': true,
            'token': token,
            'user': responseData['user']
          };
        } else {
          return {
            'success': false,
            'message': 'Token tidak ditemukan dalam respons'
          };
        }
      } else if (response.statusCode == 422) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        // Ambil error dari response
        final errors = responseData['errors'] as Map<String, dynamic>;

        // Ambil error pertama yang ditemukan
        String firstErrorMessage = errors.values.first[0];

        return {
          'success': false,
          'message': firstErrorMessage, // Langsung pesan errornya saja
        };
      } else {
        var data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Registrasi gagal'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }
}
