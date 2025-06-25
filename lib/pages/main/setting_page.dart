// setting_page.dart (enhanced professional version)
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:tugasku/constants.dart';
import 'package:tugasku/widgets/common/custom_app_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:tugasku/utils/logout_helper.dart';
import 'package:tugasku/services/auth_service.dart';
import 'package:tugasku/utils/flushbar_helper.dart';
import 'package:tugasku/widgets/common/drawer.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> 
    with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();
  bool _notificationsEnabled = true;
  File? _selectedImage;
  bool _isLoading = true;
  String _userName = "";
  String _userEmail = "";
  String? _profilePictureUrl;
  
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
    _loadUserData();
  }

  void _initializeAnimation() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _launchURL() async {
    const url = 'https://tugas-ku.cloud';
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          showCustomSnackbar(
            context: context,
            message: "Tidak dapat membuka link",
            isSuccess: false,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        showCustomSnackbar(
          context: context,
          message: "Error: ${e.toString()}",
          isSuccess: false,
        );
      }
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
        _userEmail = userData['email'] ?? "user@email.com";
        _profilePictureUrl = userData['profile_picture'];
        _isLoading = false;
      });
      _fadeController.forward();
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
    HapticFeedback.lightImpact();
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

        if (mounted) {
          showCustomSnackbar(
            context: context,
            message: "Mengupload foto profil...",
            isSuccess: true,
          );
        }

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
      
      final result = await _authService.updateProfile(
        name: name,
        profilePicture: profileImage,
      );

      setState(() {
        _userName = result['user']['name'];
        _profilePictureUrl = result['user']['profile_picture'];
        _isLoading = false;
        _selectedImage = null;
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
      }
    }
  }

  Future<void> _changePassword(String currentPassword, String newPassword,
      String confirmPassword) async {
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
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: const CustomAppBar(),
      drawer: const SideMenu(currentIndex: 3),
      body: _isLoading
          ? Container(
              color: backgroundColor,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(strokeWidth: 3),
                    Gap(16),
                    Text(
                      'Memuat pengaturan...',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : FadeTransition(
              opacity: _fadeAnimation,
              child: RefreshIndicator(
                onRefresh: _loadUserData,
                color: primaryColor,
                backgroundColor: Colors.white,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile Section
                      Text(
                        'Profil',
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      const Gap(12),
                      _buildProfileCard(),
                      
                      const Gap(32),
                      
                      // Account Section
                      Text(
                        'Akun',
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      const Gap(12),
                      _buildSettingsCard([
                        _buildSettingsOption(
                          icon: LucideIcons.user,
                          title: "Ganti Nama",
                          subtitle: "Ubah nama pengguna Anda",
                          onTap: () {
                            HapticFeedback.lightImpact();
                            _showEditNameDialog();
                          },
                        ),
                        _buildDivider(),
                        _buildSettingsOption(
                          icon: LucideIcons.shieldCheck,
                          title: "Keamanan",
                          subtitle: "Ubah kata sandi",
                          onTap: () {
                            HapticFeedback.lightImpact();
                            _showChangePasswordDialog();
                          },
                        ),
                      ]),
                      
                      const Gap(24),
                      
                      // Preferences Section
                      Text(
                        'Preferensi',
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      const Gap(12),
                      _buildSettingsCard([
                        _buildNotificationSwitch(),
                      ]),
                      
                      const Gap(24),
                      
                      // Support Section
                      Text(
                        'Dukungan',
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      const Gap(12),
                      _buildSettingsCard([
                        _buildSettingsOption(
                          icon: LucideIcons.helpCircle,
                          title: "Tentang Kami",
                          subtitle: "Kunjungi website resmi",
                          onTap: () {
                            HapticFeedback.lightImpact();
                            _launchURL();
                          },
                        ),
                        _buildDivider(),
                        _buildSettingsOption(
                          icon: LucideIcons.logOut,
                          title: "Keluar",
                          subtitle: "Keluar dari akun Anda",
                          onTap: () {
                            HapticFeedback.mediumImpact();
                            _showLogoutDialog();
                          },
                          isDestructive: true,
                        ),
                      ]),
                      
                      const Gap(40),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            offset: const Offset(0, 4),
            blurRadius: 16,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    offset: const Offset(0, 4),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.grey.shade100,
                    backgroundImage: _selectedImage != null
                        ? FileImage(_selectedImage!)
                        : _profilePictureUrl != null
                            ? NetworkImage(_profilePictureUrl!) as ImageProvider
                            : const AssetImage("assets/profile.jpg")
                                as ImageProvider,
                    child: _profilePictureUrl == null && _selectedImage == null
                        ? Icon(
                            LucideIcons.user,
                            size: 32,
                            color: Colors.grey.shade600,
                          )
                        : null,
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            offset: const Offset(0, 2),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: const Icon(
                        LucideIcons.camera,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Gap(20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _userName,
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const Gap(4),
                Text(
                  _userEmail,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const Gap(8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.green.shade200,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        LucideIcons.checkCircle,
                        size: 12,
                        color: Colors.green.shade600,
                      ),
                      const Gap(4),
                      Text(
                        'Akun Aktif',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.green.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            offset: const Offset(0, 2),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingsOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDestructive 
                      ? Colors.red.shade50 
                      : primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: isDestructive ? Colors.red.shade600 : primaryColor,
                  size: 20,
                ),
              ),
              const Gap(16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDestructive 
                            ? Colors.red.shade600 
                            : Colors.black87,
                      ),
                    ),
                    const Gap(2),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                LucideIcons.chevronRight,
                size: 18,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationSwitch() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              LucideIcons.bell,
              color: primaryColor,
              size: 20,
            ),
          ),
          const Gap(16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Notifikasi",
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const Gap(2),
                Text(
                  "Atur preferensi notifikasi",
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            activeColor: primaryColor,
            value: _notificationsEnabled,
            onChanged: (value) {
              HapticFeedback.selectionClick();
              setState(() {
                _notificationsEnabled = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 1,
      color: Colors.grey.shade100,
    );
  }

  void _showEditNameDialog() {
    final nameController = TextEditingController(text: _userName);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                LucideIcons.user,
                color: primaryColor,
                size: 20,
              ),
            ),
            const Gap(12),
            Text(
              "Ganti Nama",
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: GoogleFonts.inter(),
              decoration: InputDecoration(
                labelText: "Nama",
                labelStyle: GoogleFonts.inter(color: Colors.grey.shade600),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: primaryColor),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.all(16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: Text(
              "Batal",
              style: GoogleFonts.inter(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
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
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: Text(
              "Simpan",
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
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
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  LucideIcons.shieldCheck,
                  color: primaryColor,
                  size: 20,
                ),
              ),
              const Gap(12),
              Text(
                "Ubah Kata Sandi",
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildPasswordField(
                  controller: currentPwController,
                  label: "Kata Sandi Saat Ini",
                  isObscured: obscureCurrentPw,
                  onToggleObscure: () {
                    setState(() {
                      obscureCurrentPw = !obscureCurrentPw;
                    });
                  },
                ),
                const Gap(16),
                _buildPasswordField(
                  controller: newPwController,
                  label: "Kata Sandi Baru",
                  isObscured: obscureNewPw,
                  onToggleObscure: () {
                    setState(() {
                      obscureNewPw = !obscureNewPw;
                    });
                  },
                ),
                const Gap(16),
                _buildPasswordField(
                  controller: confirmPwController,
                  label: "Konfirmasi Kata Sandi",
                  isObscured: obscureConfirmPw,
                  onToggleObscure: () {
                    setState(() {
                      obscureConfirmPw = !obscureConfirmPw;
                    });
                  },
                ),
              ],
            ),
          ),
          actionsPadding: const EdgeInsets.all(16),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: Text(
                "Batal",
                style: GoogleFonts.inter(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                ),
              ),
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
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: Text(
                "Simpan",
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool isObscured,
    required VoidCallback onToggleObscure,
  }) {
    return TextField(
      controller: controller,
      obscureText: isObscured,
      style: GoogleFonts.inter(),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.inter(color: Colors.grey.shade600),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            isObscured ? LucideIcons.eyeOff : LucideIcons.eye,
            color: Colors.grey.shade600,
            size: 20,
          ),
          onPressed: onToggleObscure,
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