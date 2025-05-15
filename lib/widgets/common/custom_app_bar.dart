// custom_app_bar.dart
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:tugasku/services/auth_service.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _CustomAppBarState extends State<CustomAppBar> {
  final AuthService _userService = AuthService();
  String userName = 'User';
  String? profilePicture;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final userData = await _userService.getUserData();
      setState(() {
        userName = userData['name'] ?? 'Kawan!';
        profilePicture = userData['profile_picture'];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint('Error fetching user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: Builder(
        builder: (context) => Padding(
          padding: const EdgeInsets.only(left: 25),
          child: IconButton(
            icon: const Icon(LucideIcons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 25),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              isLoading
                  ? const SizedBox(
                      width: 80,
                      child: LinearProgressIndicator(),
                    )
                  : Text(
                      'Halo, $userName!',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
              const Gap(16),
              isLoading
                  ? const CircleAvatar(
                      radius: 20,
                      child: CircularProgressIndicator(),
                    )
                  : CircleAvatar(
                      radius: 20,
                      backgroundImage: profilePicture != null
                          ? NetworkImage(profilePicture!)
                          : const AssetImage('assets/profile.jpg')
                              as ImageProvider,
                    ),
            ],
          ),
        ),
      ],
    );
  }
}