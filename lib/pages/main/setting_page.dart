import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:tugasku/constants.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:tugasku/utils/logout_helper.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  bool _notificationsEnabled = true;
  File? _selectedImage;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _launchURL() async {
    const url = 'link';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pengaturan", style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          _buildProfileCard(),
          Gap(20),
          _buildSettingsOption(
            icon: LucideIcons.user,
            title: "Akun",
            subtitle: "Kelola informasi akun Anda",
            onTap: () {
              _showEditAccountDialog(context);
            },
          ),
          _buildNotificationSwitch(),
          _buildSettingsOption(
            icon: LucideIcons.shieldCheck,
            title: "Keamanan",
            subtitle: "Ubah kata sandi dan privasi",
            onTap: () {
              _showChangePasswordDialog(context);
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
            onTap: () => _showLogoutDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: CircleAvatar(
              radius: 40,
              backgroundImage: _selectedImage != null
                  ? FileImage(_selectedImage!)
                  : AssetImage("assets/profile.jpg") as ImageProvider,
            ),
          ),
          Gap(16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Kevin Azaria", style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700)),
              Text("kevinazaria@gmail.com", style: GoogleFonts.inter(color: blackColor.withValues(alpha: 0.5))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsOption({required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: primaryColor),
      title: Text(title, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: GoogleFonts.inter(fontSize: 14, color: blackColor.withValues(alpha: 0.5))),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: blackColor.withValues(alpha: 0.5)),
      onTap: onTap,
    );
  }

  Widget _buildNotificationSwitch() {
    return ListTile(
      leading: Icon(LucideIcons.bell, color: primaryColor),
      title: Text("Notifikasi", style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500)),
      subtitle: Text("Atur preferensi notifikasi", style: GoogleFonts.inter(fontSize: 14, color: blackColor.withValues(alpha: 0.5))),
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
}

void _showEditAccountDialog(BuildContext context) {
  final nameController = TextEditingController(text: "Kevin Azaria");
  final emailController = TextEditingController(text: "kevinazaria@gmail.com");

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        "Edit Akun",
        style: GoogleFonts.inter(fontWeight: FontWeight.w600),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: "Nama",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          Gap(12),
          TextField(
            controller: emailController,
            decoration: InputDecoration(
              labelText: "Email",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Batal", style: TextStyle(color: blackColor.withValues(alpha: 0.7))),
        ),
        ElevatedButton(
          onPressed: () {
            // SAVE DATABASE NYA DISINI YOW
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
          child: Text("Simpan"),
        ),
      ],
    ),
  );
}

void _showChangePasswordDialog(BuildContext context) {
  final currentPwController = TextEditingController();
  final newPwController = TextEditingController();
  final confirmPwController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
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
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Kata Sandi Saat Ini",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            Gap(12),
            TextField(
              controller: newPwController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Kata Sandi Baru",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            Gap(12),
            TextField(
              controller: confirmPwController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Konfirmasi Kata Sandi",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Batal", style: TextStyle(color: blackColor.withValues(alpha: 0.7))),
        ),
        ElevatedButton(
          onPressed: () {
            // SIMPAN KE DATABASE DISINIII
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
          child: Text("Simpan"),
        ),
      ],
    ),
  );
}

void _showLogoutDialog(BuildContext context) {
  LogoutHelper.showLogoutDialog(context, blackColor: blackColor);
}
