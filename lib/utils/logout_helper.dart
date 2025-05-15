// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../utils/flushbar_helper.dart';

class LogoutHelper {
  static final AuthService _authService = AuthService();
  
  static void showCustomLogoutDialog({
    required BuildContext context,
    Color blackColor = Colors.black,
    String title = "Konfirmasi Logout",
    String message = "Apakah Anda yakin ingin keluar dari aplikasi?",
    String cancelText = "Batal",
    String confirmText = "Logout",
    Color confirmButtonColor = Colors.red,
    String loginRoute = '/login',
    VoidCallback? onLogoutSuccess,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          title,
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        content: Text(
          message,
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(cancelText, style: TextStyle(color: blackColor.withValues(alpha: 0.7))),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              // Show loading dialog
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return const Center(child: CircularProgressIndicator());
                },
              );
              
              try {
                final success = await _authService.logout();
                Navigator.pop(context);
                
                if (success) {
                  if (onLogoutSuccess != null) {
                    onLogoutSuccess();
                  }
                  Navigator.pushNamedAndRemoveUntil(context, loginRoute, (route) => false);
                } else {
                  await _authService.deleteToken();
                  Navigator.pushNamedAndRemoveUntil(context, loginRoute, (route) => false);
                }
              } catch (e) {
                Navigator.pop(context);
                await _authService.deleteToken();
                
                if (context.mounted) {
                  showCustomSnackbar(
                    context: context,
                    message: "Terjadi kesalahan saat logout, mencoba logout lokal",
                    isSuccess: false,
                  );
                  Navigator.pushNamedAndRemoveUntil(context, loginRoute, (route) => false);
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: confirmButtonColor),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }
  
  static Future<void> forceLocalLogout(BuildContext context, {String loginRoute = '/login'}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_data');
    Navigator.pushNamedAndRemoveUntil(context, loginRoute, (route) => false);
  }
}