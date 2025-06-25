// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tugasku/constants.dart';
import '../services/auth_service.dart';

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
    HapticFeedback.lightImpact();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        contentPadding: EdgeInsets.zero,
        content: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  LucideIcons.logOut,
                  color: Colors.red.shade600,
                  size: 32,
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Title
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 12),
              
              // Message
              Text(
                message,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 24),
              
              // Action buttons
              Row(
                children: [
                  // Cancel button
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Navigator.pop(context);
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        cancelText,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Logout button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _performLogout(
                        context: context,
                        loginRoute: loginRoute,
                        onLogoutSuccess: onLogoutSuccess,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: confirmButtonColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(LucideIcons.logOut, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            confirmText,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Future<void> _performLogout({
    required BuildContext context,
    required String loginRoute,
    VoidCallback? onLogoutSuccess,
  }) async {
    HapticFeedback.mediumImpact();
    
    // Close confirmation dialog first
    Navigator.pop(context);
    
    // Show enhanced loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return PopScope(
          canPop: false,
          child: Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: primaryColor,
                        strokeWidth: 3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Keluar dari Aplikasi...',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Mohon tunggu sebentar',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    try {
      // Attempt API logout
      final success = await _authService.logout();
      
      // Close loading dialog
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      
      if (success) {
        // Successful API logout
        await _clearLocalData();
        _navigateToLogin(context, loginRoute);
        onLogoutSuccess?.call();
        _showLogoutSuccessMessage(context);
      } else {
        // API logout failed, force local logout
        await _handleLogoutFailure(context, loginRoute, onLogoutSuccess);
      }
    } catch (e) {
      // Error occurred, force local logout
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      await _handleLogoutFailure(context, loginRoute, onLogoutSuccess);
    }
  }

  static Future<void> _handleLogoutFailure(
    BuildContext context,
    String loginRoute,
    VoidCallback? onLogoutSuccess,
  ) async {
    // Force local logout when API fails
    await forceLocalLogout(context, loginRoute: loginRoute);
    onLogoutSuccess?.call();
    
    // Show warning message
    _showLogoutWarningMessage(context);
  }

  static void _navigateToLogin(BuildContext context, String loginRoute) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      loginRoute,
      (route) => false,
    );
  }

  static void _showLogoutSuccessMessage(BuildContext context) {
    // Show success message using ScaffoldMessenger
    // This will work even after navigation
    Future.delayed(const Duration(milliseconds: 500), () {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(LucideIcons.checkCircle, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Berhasil keluar dari aplikasi',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    });
  }

  static void _showLogoutWarningMessage(BuildContext context) {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(LucideIcons.alertTriangle, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Logout paksa dilakukan (koneksi bermasalah)',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.orange.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    });
  }

  static Future<void> _clearLocalData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user_data');
      await _authService.deleteToken();
    } catch (e) {
      debugPrint('Error clearing local data: $e');
    }
  }

  static Future<void> forceLocalLogout(
    BuildContext context, {
    String loginRoute = '/login',
  }) async {
    try {
      await _clearLocalData();
      _navigateToLogin(context, loginRoute);
    } catch (e) {
      debugPrint('Error in force logout: $e');
      // Even if clearing fails, still navigate to login
      _navigateToLogin(context, loginRoute);
    }
  }

  // Check if user is logged in
  static Future<bool> isUserLoggedIn() async {
    try {
      final token = await _authService.getToken();
      return token != null && token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}