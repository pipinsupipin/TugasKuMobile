// setting_page.dart
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:tugasku/constants.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:tugasku/utils/logout_helper.dart';
import 'package:tugasku/services/auth_service.dart';
import 'package:tugasku/utils/flushbar_helper.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  final AuthService _authService = AuthService();
  bool _notificationsEnabled = true;
  File? _selectedImage;
  bool _isLoading = true;
  String _userName = "";
  String _userEmail = "";
  String? _profilePictureUrl;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _launchURL() async {
    const url = 'link';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userData = await _authService.getUserData();
      setState(() {
        _userName = userData['name'] ?? "User";
        _userEmail = userData['email'] ?? "user@example.com";
        _profilePictureUrl = userData['profile_picture'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        showCustomSnackbar(
          context: context,
          message: "Gagal memuat data pengguna: ${e.toString()}",
          isSuccess: false,
        );
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });

        // Show loading indicator
        if (mounted) {
          showCustomSnackbar(
            context: context,
            message: "Mengupload foto profil...",
            isSuccess: true,
          );
        }

        // Update profile with new image
        await _updateProfile(_userName, _selectedImage);
      }
    } catch (e) {
      if (mounted) {
        showCustomSnackbar(
          context: context,
          message: "Gagal memilih gambar: ${e.toString()}",
          isSuccess: false,
        );
      }
    }
  }

  Future<void> _updateProfile(String name, File? profileImage) async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Debugging: print what we're sending
      debugPrint('Updating profile with name: $name');
      debugPrint('Profile image path: ${profileImage?.path}');
      
      // Show debug information
      if (mounted) {
        showCustomSnackbar(
          context: context,
          message: "Memperbarui profil dengan nama: $name",
          isSuccess: true,
        );
      }

      final result = await _authService.updateProfile(
        name: name,
        profilePicture: profileImage,
      );

      // Debugging: print the response
      debugPrint('Update profile response: $result');

      setState(() {
        _userName = result['user']['name'];
        _profilePictureUrl = result['user']['profile_picture'];
        _isLoading = false;
        _selectedImage = null; // Reset selected image after upload
      });

      if (mounted) {
        showCustomSnackbar(
          context: context,
          message: "Profil berhasil diperbarui",
          isSuccess: true,
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        showCustomSnackbar(
          context: context,
          message: "Gagal memperbarui profil: ${e.toString()}",
          isSuccess: false,
        );
        
        // Print detailed debugging info
        debugPrint('===== PROFILE UPDATE ERROR =====');
        debugPrint(e.toString());
        debugPrint('================================');
      }
    }
  }

  Future<void> _changePassword(String currentPassword, String newPassword,
      String confirmPassword) async {
    // Validate passwords match
    if (newPassword != confirmPassword) {
      showCustomSnackbar(
        context: context,
        message: "Konfirmasi kata sandi tidak cocok",
        isSuccess: false,
      );
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      // Debugging: print what we're sending (without exposing actual passwords)
      debugPrint('Changing password...');
      
      // Show debug information
      if (mounted) {
        showCustomSnackbar(
          context: context,
          message: "Memperbarui kata sandi...",
          isSuccess: true,
        );
      }

      await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        newPasswordConfirmation: confirmPassword,
      );

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        showCustomSnackbar(
          context: context,
          message: "Kata sandi berhasil diperbarui",
          isSuccess: true,
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        showCustomSnackbar(
          context: context,
          message: "Gagal memperbarui kata sandi: ${e.toString()}",
          isSuccess: false,
        );
        
        // Print detailed debugging info
        debugPrint('===== PASSWORD CHANGE ERROR =====');
        debugPrint(e.toString());
        debugPrint('==================================');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pengaturan",
            style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadUserData,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _buildProfileCard(),
                  const Gap(20),
                  _buildSettingsOption(
                    icon: LucideIcons.user,
                    title: "Ganti Nama",
                    subtitle: "Ubah nama pengguna Anda",
                    onTap: () {
                      _showEditNameDialog();
                    },
                  ),
                  _buildNotificationSwitch(),
                  _buildSettingsOption(
                    icon: LucideIcons.shieldCheck,
                    title: "Keamanan",
                    subtitle: "Ubah kata sandi",
                    onTap: () {
                      _showChangePasswordDialog();
                    },
                  ),
                  _buildSettingsOption(
                    icon: LucideIcons.helpCircle,
                    title: "Tentang Kami",
                    subtitle: "Kunjungi website resmi",
                    onTap: _launchURL,
                  ),
                  _buildSettingsOption(
                    icon: LucideIcons.logOut,
                    title: "Keluar",
                    subtitle: "Keluar dari akun Anda",
                    onTap: () => _showLogoutDialog(),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: _selectedImage != null
                      ? FileImage(_selectedImage!)
                      : _profilePictureUrl != null
                          ? NetworkImage(_profilePictureUrl!) as ImageProvider
                          : const AssetImage("assets/profile.jpg")
                              as ImageProvider,
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      LucideIcons.pencil,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Gap(16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_userName,
                    style: GoogleFonts.inter(
                        fontSize: 18, fontWeight: FontWeight.w700),
                    overflow: TextOverflow.ellipsis),
                Text(_userEmail,
                    style: GoogleFonts.inter(
                        color: blackColor.withValues(alpha: 0.5)),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsOption(
      {required IconData icon,
      required String title,
      required String subtitle,
      required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: primaryColor),
      title: Text(title,
          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle,
          style: GoogleFonts.inter(
              fontSize: 14, color: blackColor.withValues(alpha: 0.5))),
      trailing: Icon(Icons.arrow_forward_ios,
          size: 16, color: blackColor.withValues(alpha: 0.5)),
      onTap: onTap,
    );
  }

  Widget _buildNotificationSwitch() {
    return ListTile(
      leading: Icon(LucideIcons.bell, color: primaryColor),
      title: Text("Notifikasi",
          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500)),
      subtitle: Text("Atur preferensi notifikasi",
          style: GoogleFonts.inter(
              fontSize: 14, color: blackColor.withValues(alpha: 0.5))),
      trailing: Switch(
        activeColor: primaryColor,
        value: _notificationsEnabled,
        onChanged: (value) {
          setState(() {
            _notificationsEnabled = value;
          });
        },
      ),
    );
  }

  void _showEditNameDialog() {
    final nameController = TextEditingController(text: _userName);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          "Ganti Nama",
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: "Nama",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Batal",
                style: TextStyle(color: blackColor.withValues(alpha: 0.7))),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isEmpty) {
                showCustomSnackbar(
                  context: context,
                  message: "Nama tidak boleh kosong",
                  isSuccess: false,
                );
                return;
              }
              Navigator.pop(context);
              _updateProfile(nameController.text, null);
            },
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    final currentPwController = TextEditingController();
    final newPwController = TextEditingController();
    final confirmPwController = TextEditingController();
    bool obscureCurrentPw = true;
    bool obscureNewPw = true;
    bool obscureConfirmPw = true;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            "Ubah Kata Sandi",
            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: currentPwController,
                  obscureText: obscureCurrentPw,
                  decoration: InputDecoration(
                    labelText: "Kata Sandi Saat Ini",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureCurrentPw ? LucideIcons.eyeOff : LucideIcons.eye,
                      ),
                      onPressed: () {
                        setState(() {
                          obscureCurrentPw = !obscureCurrentPw;
                        });
                      },
                    ),
                  ),
                ),
                const Gap(12),
                TextField(
                  controller: newPwController,
                  obscureText: obscureNewPw,
                  decoration: InputDecoration(
                    labelText: "Kata Sandi Baru",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureNewPw ? LucideIcons.eyeOff : LucideIcons.eye,
                      ),
                      onPressed: () {
                        setState(() {
                          obscureNewPw = !obscureNewPw;
                        });
                      },
                    ),
                  ),
                ),
                const Gap(12),
                TextField(
                  controller: confirmPwController,
                  obscureText: obscureConfirmPw,
                  decoration: InputDecoration(
                    labelText: "Konfirmasi Kata Sandi",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureConfirmPw ? LucideIcons.eyeOff : LucideIcons.eye,
                      ),
                      onPressed: () {
                        setState(() {
                          obscureConfirmPw = !obscureConfirmPw;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Batal",
                  style: TextStyle(color: blackColor.withValues(alpha: 0.7))),
            ),
            ElevatedButton(
              onPressed: () {
                if (currentPwController.text.isEmpty || 
                    newPwController.text.isEmpty || 
                    confirmPwController.text.isEmpty) {
                  showCustomSnackbar(
                    context: context, 
                    message: "Semua field harus diisi",
                    isSuccess: false,
                  );
                  return;
                }
                
                Navigator.pop(context);
                _changePassword(currentPwController.text, newPwController.text,
                    confirmPwController.text);
              },
              style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
              child: const Text("Simpan"),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    LogoutHelper.showCustomLogoutDialog(
      context: context,
      blackColor: blackColor,
    );
  }
}