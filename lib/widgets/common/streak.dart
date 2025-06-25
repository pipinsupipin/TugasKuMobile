import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tugasku/constants.dart';
import 'package:tugasku/services/crud_service.dart';
import 'dart:math' as math;

class Streak extends StatefulWidget {
  const Streak({super.key});

  @override
  _StreakState createState() => _StreakState();
}

class _StreakState extends State<Streak> with TickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  int _currentStreak = 0;
  bool _isLoading = true;
  
  // Animation controllers
  late AnimationController _glowController;
  late AnimationController _sparkleController;
  late AnimationController _pulseController;
  late AnimationController _countController;
  
  // Animations
  late Animation<double> _glowAnimation;
  late Animation<double> _sparkleAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<int> _countAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controllers
    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _sparkleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(); // Make it continuously repeat
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _countController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    // Initialize animations
    _glowAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));
    
    _sparkleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _sparkleController,
      curve: Curves.easeOutBack,
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.elasticOut,
    ));
    
    _fetchStreakData();
  }

  @override
  void dispose() {
    _glowController.dispose();
    _sparkleController.dispose();
    _pulseController.dispose();
    _countController.dispose();
    super.dispose();
  }

  Future<void> _fetchStreakData() async {
    try {
      final response = await _apiService.getStreakData();
      if (response['status'] == 'success') {
        final newStreak = response['data']['current_streak'];
        
        // Setup count animation
        _countAnimation = IntTween(
          begin: 0,
          end: newStreak,
        ).animate(CurvedAnimation(
          parent: _countController,
          curve: Curves.easeOutCubic,
        ));
        
        setState(() {
          _currentStreak = newStreak;
        });
        
        // Start animations
        _startAnimations();
      }
    } catch (e) {
      print('Error fetching streak data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _startAnimations() {
    // Start glow animation (continuous)
    _glowController.repeat(reverse: true);
    
    // Start pulse animation
    _pulseController.forward().then((_) {
      _pulseController.reverse();
    });
    
    // Start count animation
    _countController.forward();
    
    // Start sparkle animation if streak >= 3 (continuous)
    if (_currentStreak >= 3) {
      // Sparkle controller is already repeating from initState
    }
  }

  String _getStreakTitle() {
    if (_currentStreak < 3) return 'Perintis Petualangan!';
    if (_currentStreak < 7) return 'Pejuang Muda';
    if (_currentStreak < 14) return 'Ninja Produktif';
    if (_currentStreak < 30) return 'Raja Konsistensi';
    if (_currentStreak < 50) return 'Master Disiplin';
    if (_currentStreak < 100) return 'Legenda Hidup';
    return 'Dewa Produktivitas';
  }

  Color _getStreakColor() {
    if (_currentStreak < 3) return Colors.grey;
    if (_currentStreak < 7) return orangeColor;
    if (_currentStreak < 14) return Colors.blue;
    if (_currentStreak < 30) return Colors.purple;
    if (_currentStreak < 50) return Colors.red;
    if (_currentStreak < 100) return Colors.amber;
    return Colors.pink;
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Streak title
              Text(
                _getStreakTitle(),
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _getStreakColor(),
                ),
              ),
              const SizedBox(height: 12),
              
              // Main streak display with animations
              Stack(
                alignment: Alignment.center,
                children: [
                  // Glow effect (only for active streaks)
                  if (_currentStreak >= 3)
                    AnimatedBuilder(
                      animation: _glowAnimation,
                      builder: (context, child) {
                        return Container(
                          width: MediaQuery.of(context).size.width * 0.45,
                          height: MediaQuery.of(context).size.width * 0.45,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: _getStreakColor().withOpacity(0.3 * _glowAnimation.value),
                                blurRadius: 40 * _glowAnimation.value,
                                spreadRadius: 10 * _glowAnimation.value,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  
                  // Sparkles effect
                  if (_currentStreak >= 3)
                    AnimatedBuilder(
                      animation: _sparkleAnimation,
                      builder: (context, child) {
                        return SizedBox(
                          width: MediaQuery.of(context).size.width * 0.5,
                          height: MediaQuery.of(context).size.width * 0.5,
                          child: CustomPaint(
                            painter: SparklesPainter(
                              animation: _sparkleAnimation.value,
                              color: _getStreakColor(),
                            ),
                          ),
                        );
                      },
                    ),
                  
                  // Main image with pulse animation
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseAnimation.value,
                        child: Image.asset(
                          _currentStreak < 3
                              ? 'assets/streak_locked.png'
                              : 'assets/streak.png',
                          width: MediaQuery.of(context).size.width * 0.35,
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Streak count with animation
              AnimatedBuilder(
                animation: _countAnimation,
                builder: (context, child) {
                  return RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: GoogleFonts.inter(
                        color: blackColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        shadows: [
                          Shadow(
                            offset: const Offset(0, 2),
                            blurRadius: 5,
                            color: Colors.black.withOpacity(0.1),
                          ),
                        ],
                      ),
                      children: [
                        const TextSpan(text: 'Kamu memiliki '),
                        TextSpan(
                          text: '${_countAnimation.value}',
                          style: GoogleFonts.inter(
                            color: _getStreakColor(),
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            shadows: [
                              Shadow(
                                offset: const Offset(0, 3),
                                blurRadius: 8,
                                color: _getStreakColor().withOpacity(0.3),
                              ),
                            ],
                          ),
                        ),
                        const TextSpan(text: ' Streaks!'),
                      ],
                    ),
                  );
                },
              ),
              
              // Motivational message - removed
              const SizedBox(height: 16),
            ],
          );
  }
}

class SparklesPainter extends CustomPainter {
  final double animation;
  final Color color;
  
  SparklesPainter({required this.animation, required this.color});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.8 * animation)
      ..style = PaintingStyle.fill;
    
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    // Draw sparkles around the circle
    for (int i = 0; i < 8; i++) {
      final angle = (i * math.pi * 2 / 8) + (animation * math.pi * 2);
      final sparkleRadius = radius * 0.8;
      final sparkleX = center.dx + math.cos(angle) * sparkleRadius;
      final sparkleY = center.dy + math.sin(angle) * sparkleRadius;
      
      final sparkleSize = 4 * animation * (1 + math.sin(animation * math.pi * 4 + i) * 0.5);
      
      // Draw star-like sparkle
      _drawStar(canvas, Offset(sparkleX, sparkleY), sparkleSize, paint);
    }
    
    // Additional floating sparkles
    for (int i = 0; i < 12; i++) {
      final angle = (i * math.pi * 2 / 12) + (animation * math.pi * 1.5);
      final sparkleRadius = radius * (0.9 + math.sin(animation * math.pi * 3 + i) * 0.2);
      final sparkleX = center.dx + math.cos(angle) * sparkleRadius;
      final sparkleY = center.dy + math.sin(angle) * sparkleRadius;
      
      final sparkleSize = 2 * animation * (0.5 + math.sin(animation * math.pi * 6 + i) * 0.5);
      
      canvas.drawCircle(Offset(sparkleX, sparkleY), sparkleSize, paint);
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