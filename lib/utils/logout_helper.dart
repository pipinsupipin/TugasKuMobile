// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../pages/auth/login_page.dart';

class LogoutHelper {
  static final ApiService _apiService = ApiService();

  static void showLogoutDialog(BuildContext context, {Color blackColor = Colors.black}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("Konfirmasi", style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        content: Text("Apakah Anda yakin ingin keluar?", style: GoogleFonts.inter()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Batal", style: GoogleFonts.inter(color: blackColor.withValues(alpha: 0.7))),
          ),
          TextButton(
            onPressed: () async {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return Center(child: CircularProgressIndicator());
                },
              );
              
              try {
                final success = await _apiService.logout();

                Navigator.pop(context);
                Navigator.pop(context);
                
                if (success) {
                  Navigator.pushAndRemoveUntil(
                    context, 
                    MaterialPageRoute(builder: (context) => LoginPage()),
                    (route) => false,
                  );
                } else {
                  await _apiService.deleteToken();

                  Navigator.pushAndRemoveUntil(
                    context, 
                    MaterialPageRoute(builder: (context) => LoginPage()),
                    (route) => false,
                  );
                }
              } catch (e) {
                Navigator.pop(context);
                Navigator.pop(context);

                await _apiService.deleteToken();

                Navigator.pushAndRemoveUntil(
                  context, 
                  MaterialPageRoute(builder: (context) => LoginPage()),
                  (route) => false,
                );
              }
            },
            child: Text("Keluar", style: GoogleFonts.inter(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  static Future<void> forceLocalLogout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('auth_token');
    await prefs.remove('user_data');

    Navigator.pushAndRemoveUntil(
      context, 
      MaterialPageRoute(builder: (context) => LoginPage()),
      (route) => false,
    );
  }
}