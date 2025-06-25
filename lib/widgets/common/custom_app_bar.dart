// custom_app_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:tugasku/services/auth_service.dart';
import 'package:tugasku/utils/logout_helper.dart';
import 'package:tugasku/constants.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(70);
}

class _CustomAppBarState extends State<CustomAppBar>
    with SingleTickerProviderStateMixin {
  final AuthService _userService = AuthService();
  String userName = 'User';
  String userEmail = '';
  String? profilePicture;
  bool isLoading = true;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _fetchUserData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _fetchUserData() async {
    try {
      final userData = await _userService.getUserData();
      setState(() {
        userName = userData['name'] ?? 'Kawan!';
        userEmail = userData['email'] ?? '';
        profilePicture = userData['profile_picture'];
        isLoading = false;
      });
      _controller.forward();
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _controller.forward();
      debugPrint('Error fetching user data: $e');
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Selamat pagi';
    } else if (hour < 17) {
      return 'Selamat siang';
    } else {
      return 'Selamat malam';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            offset: const Offset(0, 2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        toolbarHeight: 70,
        leadingWidth: 70,
        leading: Builder(
          builder: (context) => Container(
            margin: const EdgeInsets.only(left: 20, top: 8, bottom: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey.shade200,
                width: 1,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  HapticFeedback.lightImpact();
                  Scaffold.of(context).openDrawer();
                },
                child: const Icon(
                  LucideIcons.menu,
                  color: Colors.black87,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
        actions: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(left: 70, right: 20),
              child: FadeTransition(
                opacity: _animation,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // User info section
                    Flexible(
                      child: isLoading
                          ? Container(
                              height: 16,
                              width: 140,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            )
                          : RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: '${_getGreeting()}, ',
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black87.withValues(alpha: 0.7),
                                    ),
                                  ),
                                  TextSpan(
                                    text: '$userName!',
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                    ),
                    
                    const Gap(12),
                    
                    // Profile picture
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        // Add profile tap functionality here
                        _showProfileMenu(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.grey.shade200,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              offset: const Offset(0, 2),
                              blurRadius: 4,
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: isLoading
                            ? CircleAvatar(
                                radius: 22,
                                backgroundColor: Colors.grey.shade200,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : CircleAvatar(
                                radius: 22,
                                backgroundColor: Colors.grey.shade100,
                                backgroundImage: profilePicture != null
                                    ? NetworkImage(profilePicture!)
                                    : const AssetImage('assets/profile.jpg')
                                        as ImageProvider,
                                child: profilePicture == null
                                    ? Icon(
                                        LucideIcons.user,
                                        size: 20,
                                        color: Colors.grey.shade600,
                                      )
                                    : null,
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showProfileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Gap(24),
            _buildProfileCard(),
            const Gap(24),
            _buildMenuItem(
              icon: LucideIcons.logOut,
              title: 'Logout',
              onTap: () {
                Navigator.pop(context);
                _showLogoutDialog();
              },
              isDestructive: true,
            ),
            const Gap(20),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: Offset(0, 2),
          )
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.grey.shade100,
            backgroundImage: profilePicture != null
                ? NetworkImage(profilePicture!)
                : const AssetImage('assets/profile.jpg') as ImageProvider,
            child: profilePicture == null
                ? Icon(
                    LucideIcons.user,
                    size: 32,
                    color: Colors.grey.shade600,
                  )
                : null,
          ),
          const Gap(16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (userEmail.isNotEmpty) ...[
                  const Gap(4),
                  Text(
                    userEmail,
                    style: GoogleFonts.inter(
                      color: blackColor.withValues(alpha: 0.5),
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    LogoutHelper.showCustomLogoutDialog(
      context: context,
      blackColor: blackColor,
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: isDestructive ? Colors.red : Colors.grey.shade700,
              ),
              const Gap(16),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDestructive ? Colors.red : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}