import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:tugasku/constants.dart';
import 'package:tugasku/logo.dart';
import 'package:tugasku/pages/auth/login_page.dart';
import 'package:tugasku/widgets/common/bottom_tab_bar.dart';
import 'package:tugasku/utils/logout_helper.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: fullWhite,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.transparent,
            ),
            child: Center(
              child: LogoTugasKu(fontSize: 36),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              children: [
                _buildDrawerItem(
                  context, 
                  icon: LucideIcons.home,
                  text: 'Beranda', 
                  onTap: () => _navigateTo(context, BottomTabBar(selectedIndex: 0)),
                ),
                // _buildDrawerItem(
                //   context, 
                //   icon: LucideIcons.clipboardList, 
                //   text: 'Semua Tugas', 
                //   onTap: () => _navigateTo(context, const AllTaskPage()),
                // ),
                _buildDrawerItem(
                  context, 
                  icon: LucideIcons.calendar, 
                  text: 'Kalender', 
                  onTap: () => _navigateTo(context, BottomTabBar(selectedIndex: 1)),
                ),
                _buildDrawerItem(
                  context, 
                  icon: LucideIcons.timer, 
                  text: 'Timer Belajar', 
                  onTap: () => _navigateTo(context, BottomTabBar(selectedIndex: 2)),
                ),
                _buildDrawerItem(
                  context, 
                  icon: LucideIcons.settings, 
                  text: 'Pengaturan', 
                  onTap: () => _navigateTo(context, BottomTabBar(selectedIndex: 3)),
                ),
                const Divider(),
                _buildDrawerItem(
                  context, 
                  icon: LucideIcons.logOut, 
                  text: 'Keluar', 
                  onTap: () => _navigateTo(context, const LoginPage()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String text,
    required Function? onTap,
    Color? color,
  }) {
    if (text == 'Keluar') {
      return ListTile(
        leading: Icon(icon, color: Colors.red),
        title: Text(text, style: GoogleFonts.inter(color: color)),
        onTap: () {

          Navigator.pop(context);
          LogoutHelper.showLogoutDialog(context);
        },
      );
    }
    
    return ListTile(
      leading: Icon(icon, color: primaryColor),
      title: Text(text, style: GoogleFonts.inter(color: color)),
      onTap: onTap != null ? () => onTap() : null,
    );
  }

  void _navigateTo(BuildContext context, Widget page) {
    Navigator.pushReplacement(
      context, 
      MaterialPageRoute(builder: (context) => page),
    );
  }
}