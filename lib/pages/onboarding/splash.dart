import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

import 'package:tugasku/logo.dart';

class SplashScreen extends StatefulWidget {
  final Widget nextScreen;
  
  const SplashScreen({super.key, required this.nextScreen});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  
  // Animation Controllers
  late AnimationController _mainController;
  late AnimationController _logoController;
  late AnimationController _particleController;
  late AnimationController _textController;
  late AnimationController _loadingController;
  
  // Animations
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _logoRotation;
  late Animation<double> _logoGlow;
  late Animation<double> _particleAnimation;
  late Animation<double> _textSlide;
  late Animation<double> _loadingPulse;

  @override
  void initState() {
    super.initState();
    
    // Hide status bar for immersive experience
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    
    _initializeAnimations();
    _startAnimationSequence();
  }

  void _initializeAnimations() {
    // Main animation controller
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    
    // Logo specific animations
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    // Particle effects
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    );
    
    // Text animations
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    // Loading animations
    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Setup animations
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));
    
    _logoRotation = Tween<double>(
      begin: -0.5,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
    ));
    
    _logoGlow = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeInOut),
    ));

    _slideAnimation = Tween<double>(
      begin: 100.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.3, 0.9, curve: Curves.easeOutCubic),
    ));
    
    _particleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _particleController,
      curve: Curves.easeOut,
    ));
    
    _textSlide = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOutBack,
    ));
    
    _loadingPulse = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _loadingController,
      curve: Curves.easeInOut,
    ));
  }

  void _startAnimationSequence() async {
    // Start particle background
    _particleController.repeat();
    
    // Start loading pulse
    _loadingController.repeat(reverse: true);
    
    // Sequence animations
    await Future.delayed(const Duration(milliseconds: 200));
    _mainController.forward();
    
    await Future.delayed(const Duration(milliseconds: 400));
    _logoController.forward();
    
    await Future.delayed(const Duration(milliseconds: 800));
    _textController.forward();
    
    // Wait for animations to complete
    await Future.delayed(const Duration(milliseconds: 1500));
    
    if (mounted) {
      // Restore system UI
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => widget.nextScreen,
          transitionDuration: const Duration(milliseconds: 800),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.0, 0.1),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                )),
                child: child,
              ),
            );
          },
        ),
      );
    }
  }

  @override
  void dispose() {
    _mainController.dispose();
    _logoController.dispose();
    _particleController.dispose();
    _textController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: size.width,
        height: size.height,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.5,
            colors: [
              Color(0xFFFFF8E1), // Light cream
              Color(0xFFFFE0B2), // Light orange
              Color(0xFFFFCC02), // Golden yellow
              Color(0xFFFF8F00), // Deep orange
            ],
            stops: [0.0, 0.4, 0.7, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Animated background particles
            AnimatedBuilder(
              animation: _particleAnimation,
              builder: (context, child) {
                return CustomPaint(
                  painter: ParticlesPainter(_particleAnimation.value),
                  size: Size.infinite,
                );
              },
            ),
            
            // Main content
            AnimatedBuilder(
              animation: _mainController,
              builder: (context, child) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Enhanced Logo with glow and rotation
                      Transform.translate(
                        offset: Offset(0, _slideAnimation.value),
                        child: AnimatedBuilder(
                          animation: _logoController,
                          builder: (context, child) {
                            return Transform.rotate(
                              angle: _logoRotation.value,
                              child: Transform.scale(
                                scale: _scaleAnimation.value,
                                child: FadeTransition(
                                  opacity: _fadeAnimation,
                                  child: Container(
                                    width: 180,
                                    height: 180,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(28),
                                      boxShadow: [
                                        // Main shadow
                                        BoxShadow(
                                          color: const Color(0xFFFF6B35).withOpacity(0.3 * _logoGlow.value),
                                          blurRadius: 30 * _logoGlow.value,
                                          spreadRadius: 8 * _logoGlow.value,
                                          offset: const Offset(0, 10),
                                        ),
                                        // Glow effect
                                        BoxShadow(
                                          color: const Color(0xFFFFCC02).withOpacity(0.2 * _logoGlow.value),
                                          blurRadius: 60 * _logoGlow.value,
                                          spreadRadius: 15 * _logoGlow.value,
                                          offset: const Offset(0, 5),
                                        ),
                                        // Depth shadow
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 50,
                                          spreadRadius: 0,
                                          offset: const Offset(0, 20),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(28),
                                      child: Container(
                                        padding: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(28),
                                          border: Border.all(
                                            color: const Color(0xFFFFCC02).withOpacity(0.3),
                                            width: 2,
                                          ),
                                        ),
                                        child: Image.asset(
                                          'assets/logo_notext.png',
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // App name with slide animation
                      AnimatedBuilder(
                        animation: _textController,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, _textSlide.value),
                            child: FadeTransition(
                              opacity: _fadeAnimation,
                              child: LogoTugasKu()
                            ),
                          );
                        },
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Enhanced tagline
                      AnimatedBuilder(
                        animation: _textController,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, _textSlide.value * 0.6),
                            child: FadeTransition(
                              opacity: _fadeAnimation,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: const Color(0xFFFFCC02).withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  'Catat Tugas, Makin Seru!',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF8B6914),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
            
            // Enhanced loading indicator
            Positioned(
              bottom: 100,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    // Animated loading dots with pulse
                    AnimatedBuilder(
                      animation: _loadingController,
                      builder: (context, child) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildEnhancedDot(0),
                            const SizedBox(width: 12),
                            _buildEnhancedDot(1),
                            const SizedBox(width: 12),
                            _buildEnhancedDot(2),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 30),
                    // Loading text with subtle animation
                    AnimatedBuilder(
                      animation: _loadingPulse,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: 1.0 + (_loadingPulse.value - 1.0) * 0.05,
                          child: Text(
                            'Mempersiapkan pengalaman terbaik...',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF8B6914).withOpacity(0.8),
                              letterSpacing: 0.3,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            // Version with fade
            Positioned(
              bottom: 32,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  margin: const EdgeInsets.symmetric(horizontal: 100),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'v1.0.0 • Made with ❤️',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF8B6914).withOpacity(0.7),
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedDot(int index) {
    return AnimatedBuilder(
      animation: _mainController,
      builder: (context, child) {
        final delay = index * 0.15;
        final animationValue = ((_mainController.value - delay) * 2).clamp(0.0, 1.0);
        final pulseValue = _loadingPulse.value;
        
        final scale = (0.6 + (0.4 * animationValue)) * pulseValue;
        final opacity = (animationValue * 0.8 + 0.2).clamp(0.0, 1.0);
        
        return Transform.scale(
          scale: scale,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFF6B35).withOpacity(opacity),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF6B35).withOpacity(opacity * 0.5),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ParticlesPainter extends CustomPainter {
  final double animation;
  
  ParticlesPainter(this.animation);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    
    // Floating particles with safe opacity
    for (int i = 0; i < 15; i++) {
      final progress = (animation + i * 0.1) % 1.0;
      final x = size.width * (0.1 + (i % 4) * 0.25) + 
                 math.sin(animation * 2 * math.pi + i) * 40;
      final y = size.height * (progress * 1.2 - 0.1);
      final radius = 3 + math.sin(animation * 3 * math.pi + i) * 2;
      
      final opacity = (0.1 + math.sin(animation * math.pi + i) * 0.05).clamp(0.0, 1.0);
      paint.color = const Color(0xFFFFCC02).withOpacity(opacity);
      
      if (x >= 0 && x <= size.width && y >= 0 && y <= size.height) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
    
    // Gentle sparkles
    for (int i = 0; i < 8; i++) {
      final progress = (animation * 0.6 + i * 0.2) % 1.0;
      final x = size.width * (0.2 + (i % 3) * 0.3) + 
                 math.cos(animation * 1.5 * math.pi + i) * 60;
      final y = size.height * (0.1 + progress * 0.8);
      final size_star = 4 + math.cos(animation * 2 * math.pi + i) * 2;
      
      final opacity = (0.08 + math.cos(animation * math.pi + i) * 0.04).clamp(0.0, 1.0);
      paint.color = const Color(0xFFFF8F00).withOpacity(opacity);
      
      if (x >= 0 && x <= size.width && y >= 0 && y <= size.height) {
        _drawStar(canvas, Offset(x, y), size_star, paint);
      }
    }
  }
  
  void _drawStar(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    const int points = 4;
    const double outerRadius = 1.0;
    const double innerRadius = 0.4;
    
    for (int i = 0; i < points * 2; i++) {
      final angle = (i * math.pi / points) - math.pi / 2;
      final radius = (i % 2 == 0) ? outerRadius : innerRadius;
      final x = center.dx + math.cos(angle) * radius * size;
      final y = center.dy + math.sin(angle) * radius * size;
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}