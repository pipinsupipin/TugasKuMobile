import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tugasku/constants.dart';
import 'package:tugasku/logo.dart';
import 'package:tugasku/widgets/common/bottom_tab_bar.dart';
import 'package:tugasku/widgets/common/button_widget.dart';
import 'package:tugasku/services/auth_service.dart';
import 'package:tugasku/utils/flushbar_helper.dart';
import 'dart:math' as math;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final AuthService _apiService = AuthService();
  
  // State
  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  
  // Animation Controllers
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late AnimationController _logoController;
  late AnimationController _backgroundController;
  
  // Animations
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _logoAnimation;
  late Animation<double> _backgroundAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startInitialAnimations();
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));
    
    _logoAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));
    
    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.linear,
    ));
  }

  void _startInitialAnimations() {
    Future.delayed(const Duration(milliseconds: 100), () {
      _logoController.forward();
    });
    
    Future.delayed(const Duration(milliseconds: 300), () {
      _slideController.forward();
    });
    
    Future.delayed(const Duration(milliseconds: 500), () {
      _fadeController.forward();
    });
    
    _backgroundController.repeat();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _slideController.dispose();
    _fadeController.dispose();
    _logoController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  void _toggleAuthMode() {
    setState(() {
      _isLogin = !_isLogin;
    });
    
    _slideController.reset();
    _fadeController.reset();
    
    _slideController.forward();
    _fadeController.forward();
    
    // Clear form when switching
    if (_isLogin) {
      _nameController.clear();
      _confirmPasswordController.clear();
    }
  }

  Future<void> _handleAuth() async {
    if (_isLoading) return;
    
    // Validation
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      showCustomSnackbar(
        context: context,
        message: 'Email dan password tidak boleh kosong',
        isSuccess: false,
      );
      return;
    }
    
    if (!_isLogin) {
      if (_nameController.text.isEmpty) {
        showCustomSnackbar(
          context: context,
          message: 'Nama lengkap tidak boleh kosong',
          isSuccess: false,
        );
        return;
      }
      
      if (_passwordController.text != _confirmPasswordController.text) {
        showCustomSnackbar(
          context: context,
          message: 'Konfirmasi password tidak cocok',
          isSuccess: false,
        );
        return;
      }
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      late Map<String, dynamic> result;
      
      if (_isLogin) {
        result = await _apiService.login(
          _emailController.text,
          _passwordController.text,
          context,
        );
      } else {
        result = await _apiService.register(
          _nameController.text,
          _emailController.text,
          _passwordController.text,
          _confirmPasswordController.text,
        );
      }
      
      if (result['success']) {
        showCustomSnackbar(
          context: context,
          message: _isLogin ? 'Login berhasil!' : 'Registrasi berhasil!',
          isSuccess: true,
        );
        
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => BottomTabBar(selectedIndex: 0),
          ),
        );
      } else {
        showCustomSnackbar(
          context: context,
          message: result['message'] ?? 'Terjadi kesalahan',
          isSuccess: false,
        );
      }
    } catch (e) {
      showCustomSnackbar(
        context: context,
        message: 'Terjadi kesalahan: $e',
        isSuccess: false,
      );
    }
    
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated Background
          AnimatedBuilder(
            animation: _backgroundAnimation,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    transform: GradientRotation((_backgroundAnimation.value * 0.1).clamp(0.0, 2 * math.pi)),
                    colors: [
                      backgroundColor,
                      backgroundColor.withOpacity(0.8),
                      primaryColor.withOpacity(0.1),
                      backgroundColor,
                    ],
                    stops: const [0.0, 0.3, 0.7, 1.0],
                  ),
                ),
                child: CustomPaint(
                  painter: FloatingShapesPainter(_backgroundAnimation.value),
                  size: Size.infinite,
                ),
              );
            },
          ),
          
          // Main Content
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Column(
                  children: [
                    const Gap(40),
                    
                    // Animated Logo - FIX: Clamp opacity value
                    AnimatedBuilder(
                      animation: _logoAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _logoAnimation.value,
                          child: Transform.rotate(
                            angle: (1 - _logoAnimation.value) * 0.5,
                            child: Opacity(
                              opacity: _logoAnimation.value.clamp(0.0, 1.0),
                              child: LogoTugasKu(),
                            ),
                          ),
                        );
                      },
                    ),
                    
                    const Gap(50),
                    
                    // Auth Form Card
                    SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Container(
                          padding: const EdgeInsets.all(30),
                          decoration: BoxDecoration(
                            color: fullWhite,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                spreadRadius: 0,
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                              BoxShadow(
                                color: primaryColor.withOpacity(0.1),
                                spreadRadius: 0,
                                blurRadius: 40,
                                offset: const Offset(0, 20),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header
                              Center(
                                child: Column(
                                  children: [
                                    Text(
                                      _isLogin ? 'Selamat Datang Kembali!' : 'Bergabung Bersama Kami!',
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 24,
                                        color: blackColor,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const Gap(8),
                                    Text(
                                      _isLogin 
                                        ? 'Masuk untuk melanjutkan perjalanan produktif Anda'
                                        : 'Mulai perjalanan produktivitas Anda hari ini',
                                      style: GoogleFonts.inter(
                                        color: blackColor.withOpacity(0.6),
                                        fontSize: 14,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                              
                              const Gap(30),
                              
                              // Form Fields
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: Column(
                                  key: ValueKey(_isLogin),
                                  children: [
                                    // Name field (only for register)
                                    if (!_isLogin) ...[
                                      _buildEnhancedTextField(
                                        'Nama Lengkap',
                                        _nameController,
                                        Icons.person_outline,
                                      ),
                                      const Gap(20),
                                    ],
                                    
                                    // Email field
                                    _buildEnhancedTextField(
                                      'Email',
                                      _emailController,
                                      Icons.email_outlined,
                                    ),
                                    const Gap(20),
                                    
                                    // Password field
                                    _buildEnhancedTextField(
                                      'Kata Sandi',
                                      _passwordController,
                                      Icons.lock_outline,
                                      obscureText: _obscurePassword,
                                      onToggleVisibility: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                    ),
                                    const Gap(20),
                                    
                                    // Confirm password (only for register)
                                    if (!_isLogin) ...[
                                      _buildEnhancedTextField(
                                        'Ulangi Kata Sandi',
                                        _confirmPasswordController,
                                        Icons.lock_outline,
                                        obscureText: _obscureConfirmPassword,
                                        onToggleVisibility: () {
                                          setState(() {
                                            _obscureConfirmPassword = !_obscureConfirmPassword;
                                          });
                                        },
                                      ),
                                      const Gap(20),
                                    ],
                                  ],
                                ),
                              ),
                              
                              const Gap(30),
                              
                              // Auth Button
                              SizedBox(
                                width: double.infinity,
                                child: _isLoading
                                  ? Container(
                                      height: 55,
                                      decoration: BoxDecoration(
                                        color: primaryColor.withOpacity(0.7),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Center(
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                        ),
                                      ),
                                    )
                                  : ButtonWidget(
                                      text: _isLogin ? 'Masuk' : 'Daftar',
                                      onTap: _handleAuth,
                                    ),
                              ),
                              
                              const Gap(25),
                              
                              // Toggle Auth Mode
                              Center(
                                child: GestureDetector(
                                  onTap: _toggleAuthMode,
                                  child: RichText(
                                    text: TextSpan(
                                      style: GoogleFonts.inter(
                                        color: blackColor.withOpacity(0.7),
                                        fontSize: 14,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: _isLogin 
                                            ? 'Belum punya akun? ' 
                                            : 'Sudah punya akun? ',
                                        ),
                                        TextSpan(
                                          text: _isLogin ? 'Daftar' : 'Masuk',
                                          style: GoogleFonts.inter(
                                            fontWeight: FontWeight.w700,
                                            color: primaryColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    const Gap(50),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedTextField(
    String hintText,
    TextEditingController controller,
    IconData icon, {
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: secondaryColor.withOpacity(0.3),
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: GoogleFonts.inter(
          fontSize: 16,
          color: blackColor,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.inter(
            color: blackColor.withOpacity(0.5),
            fontSize: 16,
          ),
          prefixIcon: Icon(
            icon,
            color: primaryColor.withOpacity(0.7),
            size: 22,
          ),
          suffixIcon: onToggleVisibility != null
            ? GestureDetector(
                onTap: onToggleVisibility,
                child: Icon(
                  obscureText ? Icons.visibility_off : Icons.visibility,
                  color: blackColor.withOpacity(0.5),
                  size: 22,
                ),
              )
            : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
        ),
      ),
    );
  }
}

// FIXED: FloatingShapesPainter with proper opacity clamping
class FloatingShapesPainter extends CustomPainter {
  final double animation;
  
  FloatingShapesPainter(this.animation);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;
    
    // Floating circles
    for (int i = 0; i < 8; i++) {
      final progress = (animation + i * 0.3) % 1.0;
      final x = size.width * (0.1 + (i % 3) * 0.3) + 
                 math.sin(animation * 2 * math.pi + i) * 30;
      final y = size.height * (0.2 + progress * 0.6);
      final radius = 20 + math.sin(animation * 3 * math.pi + i) * 10;
      
      // FIX: Properly clamp opacity between 0.0 and 1.0
      final baseOpacity = 0.05;
      final variableOpacity = math.sin(animation * math.pi + i) * 0.03;
      final finalOpacity = (baseOpacity + variableOpacity).clamp(0.0, 1.0);
      
      paint.color = primaryColor.withOpacity(finalOpacity);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
    
    // Floating triangles
    for (int i = 0; i < 5; i++) {
      final progress = (animation * 0.7 + i * 0.4) % 1.0;
      final x = size.width * (0.2 + (i % 2) * 0.6) + 
                 math.cos(animation * 1.5 * math.pi + i) * 40;
      final y = size.height * (0.1 + progress * 0.8);
      final size_triangle = 15 + math.cos(animation * 2 * math.pi + i) * 5;
      
      // FIX: Properly clamp opacity between 0.0 and 1.0
      final baseOpacity = 0.04;
      final variableOpacity = math.cos(animation * math.pi + i) * 0.02;
      final finalOpacity = (baseOpacity + variableOpacity).clamp(0.0, 1.0);
      
      paint.color = orangeColor.withOpacity(finalOpacity);
      
      final path = Path();
      path.moveTo(x, y - size_triangle);
      path.lineTo(x - size_triangle, y + size_triangle);
      path.lineTo(x + size_triangle, y + size_triangle);
      path.close();
      
      canvas.drawPath(path, paint);
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}