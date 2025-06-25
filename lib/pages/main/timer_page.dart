import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:tugasku/constants.dart';
import 'package:tugasku/services/auth_service.dart';
import 'package:tugasku/widgets/common/custom_app_bar.dart';
import 'package:tugasku/widgets/common/drawer.dart';

class TimerPage extends StatefulWidget {
  const TimerPage({super.key});

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> 
    with TickerProviderStateMixin {
  final AuthService _userService = AuthService();
  String userName = 'User';
  bool isLoading = true;
  String? profilePicture;

  // Timer configurations
  static const int focusDuration = 25 * 60;
  static const int shortBreakDuration = 5 * 60;
  static const int longBreakDuration = 15 * 60;

  int remainingSeconds = focusDuration;
  bool isRunning = false;
  TimerMode currentMode = TimerMode.focus;
  int completedSessions = 0;
  Timer? timer;

  // Animation controllers
  late AnimationController _pulseController;
  late AnimationController _scaleController;
  late AnimationController _fadeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _fadeController.forward();
  }

  @override
  void dispose() {
    timer?.cancel();
    _pulseController.dispose();
    _scaleController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserData() async {
    try {
      final userData = await _userService.getUserData();
      setState(() {
        userName = userData['name'] ?? 'User';
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

  void startTimer() {
    if (timer == null || !timer!.isActive) {
      timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          if (remainingSeconds > 0) {
            remainingSeconds--;
          } else {
            timer.cancel();
            _onTimerComplete();
          }
        });
      });
      setState(() => isRunning = true);
      _pulseController.repeat(reverse: true);
      HapticFeedback.lightImpact();
    }
  }

  void pauseTimer() {
    timer?.cancel();
    setState(() => isRunning = false);
    _pulseController.stop();
    HapticFeedback.lightImpact();
  }

  void resetTimer() {
    timer?.cancel();
    setState(() {
      isRunning = false;
      currentMode = TimerMode.focus;
      remainingSeconds = focusDuration;
    });
    _pulseController.stop();
    _pulseController.reset();
    HapticFeedback.mediumImpact();
  }

  void _onTimerComplete() {
    HapticFeedback.heavyImpact();
    
    setState(() {
      isRunning = false;
      
      if (currentMode == TimerMode.focus) {
        completedSessions++;
        // After 4 focus sessions, long break
        if (completedSessions % 4 == 0) {
          currentMode = TimerMode.longBreak;
          remainingSeconds = longBreakDuration;
        } else {
          currentMode = TimerMode.shortBreak;
          remainingSeconds = shortBreakDuration;
        }
      } else {
        currentMode = TimerMode.focus;
        remainingSeconds = focusDuration;
      }
    });

    _pulseController.stop();
    _showCompletionDialog();
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(
              currentMode == TimerMode.focus 
                  ? LucideIcons.coffee 
                  : LucideIcons.bookOpen,
              color: _getCurrentColor(),
            ),
            const Gap(8),
            Text(
              _getCompletionTitle(),
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Text(
          _getCompletionMessage(),
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              startTimer();
            },
            child: Text(
              'Mulai ${_getCurrentModeText()}',
              style: GoogleFonts.inter(
                color: _getCurrentColor(),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getCompletionTitle() {
    switch (currentMode) {
      case TimerMode.shortBreak:
        return 'Waktu Istirahat!';
      case TimerMode.longBreak:
        return 'Istirahat Panjang!';
      case TimerMode.focus:
        return 'Kembali Fokus!';
    }
  }

  String _getCompletionMessage() {
    switch (currentMode) {
      case TimerMode.shortBreak:
        return 'Bagus! Saatnya istirahat sejenak selama 5 menit.';
      case TimerMode.longBreak:
        return 'Luar biasa! Anda sudah menyelesaikan 4 sesi. Istirahat 15 menit ya!';
      case TimerMode.focus:
        return 'Istirahat selesai! Waktunya kembali fokus belajar.';
    }
  }

  void _switchMode(TimerMode mode) {
    timer?.cancel();
    setState(() {
      currentMode = mode;
      isRunning = false;
      remainingSeconds = _getDurationForMode(mode);
    });
    _pulseController.stop();
    _pulseController.reset();
    HapticFeedback.selectionClick();
  }

  int _getDurationForMode(TimerMode mode) {
    switch (mode) {
      case TimerMode.focus:
        return focusDuration;
      case TimerMode.shortBreak:
        return shortBreakDuration;
      case TimerMode.longBreak:
        return longBreakDuration;
    }
  }

  Color _getCurrentColor() {
    switch (currentMode) {
      case TimerMode.focus:
        return primaryColor;
      case TimerMode.shortBreak:
        return Colors.green;
      case TimerMode.longBreak:
        return orangeColor;
    }
  }

  String _getCurrentModeText() {
    switch (currentMode) {
      case TimerMode.focus:
        return 'Fokus';
      case TimerMode.shortBreak:
        return 'Istirahat';
      case TimerMode.longBreak:
        return 'Istirahat Panjang';
    }
  }

  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int secs = seconds % 60;
    return "${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}";
  }

  Widget _buildModeSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            offset: const Offset(0, 4),
            blurRadius: 16,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          _buildModeButton(TimerMode.focus, 'Fokus', LucideIcons.bookOpen),
          _buildModeButton(TimerMode.shortBreak, 'Istirahat', LucideIcons.coffee),
          _buildModeButton(TimerMode.longBreak, 'Panjang', LucideIcons.moon),
        ],
      ),
    );
  }

  Widget _buildModeButton(TimerMode mode, String text, IconData icon) {
    final isSelected = currentMode == mode;
    final color = _getColorForMode(mode);
    
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _switchMode(mode),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isSelected ? color : Colors.grey.shade600,
                ),
                const Gap(4),
                Text(
                  text,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? color : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getColorForMode(TimerMode mode) {
    switch (mode) {
      case TimerMode.focus:
        return primaryColor;
      case TimerMode.shortBreak:
        return Colors.green;
      case TimerMode.longBreak:
        return orangeColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = remainingSeconds / _getDurationForMode(currentMode);
    
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: const CustomAppBar(),
      drawer: const SideMenu(currentIndex: 2),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - 
                          MediaQuery.of(context).padding.top - 
                          kToolbarHeight - 70, // AppBar height
              ),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    const Gap(20),
                    
                    // Mode Selector
                    _buildModeSelector(),
                    
                    const Gap(40),
                    
                    // Main Timer Section
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Welcome Text
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 40),
                          child: Text.rich(
                            TextSpan(
                              text: _getWelcomeText(),
                              style: GoogleFonts.inter(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                              children: [
                                if (!isLoading) TextSpan(
                                  text: currentMode == TimerMode.focus ? '$userName!' : '',
                                  style: GoogleFonts.inter(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    color: _getCurrentColor(),
                                  ),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        
                        const Gap(10),
                        
                        // Timer Circle
                        AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: isRunning ? _pulseAnimation.value : 1.0,
                              child: Container(
                                width: 260,
                                height: 260,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: _getCurrentColor().withOpacity(0.2),
                                      blurRadius: 30,
                                      spreadRadius: isRunning ? 10 : 5,
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    SizedBox(
                                      width: 260,
                                      height: 260,
                                      child: CircularProgressIndicator(
                                        value: 1 - progress,
                                        strokeWidth: 12,
                                        backgroundColor: Colors.grey.shade200,
                                        valueColor: AlwaysStoppedAnimation<Color>(_getCurrentColor()),
                                        strokeCap: StrokeCap.round,
                                      ),
                                    ),
                                    Container(
                                      width: 220,
                                      height: 220,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.1),
                                            blurRadius: 20,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              formatTime(remainingSeconds),
                                              style: GoogleFonts.inter(
                                                fontSize: 42,
                                                fontWeight: FontWeight.w800,
                                                color: _getCurrentColor(),
                                                letterSpacing: -2,
                                              ),
                                            ),
                                            const Gap(4),
                                            Text(
                                              _getCurrentModeText(),
                                              style: GoogleFonts.inter(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        
                        const Gap(15),
                        
                        // Control Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTapDown: (_) => _scaleController.forward(),
                              onTapUp: (_) => _scaleController.reverse(),
                              onTapCancel: () => _scaleController.reverse(),
                              onTap: isRunning ? pauseTimer : startTimer,
                              child: AnimatedBuilder(
                                animation: _scaleAnimation,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: _scaleAnimation.value,
                                    child: Container(
                                      width: 70,
                                      height: 70,
                                      decoration: BoxDecoration(
                                        color: isRunning ? Colors.red.shade400 : _getCurrentColor(),
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: (isRunning ? Colors.red.shade400 : _getCurrentColor()).withOpacity(0.3),
                                            blurRadius: 20,
                                            offset: const Offset(0, 6),
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        isRunning ? LucideIcons.pause : LucideIcons.play,
                                        size: 28,
                                        color: Colors.white,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            
                            const Gap(20),
                            
                            GestureDetector(
                              onTap: resetTimer,
                              child: Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                    width: 2,
                                  ),
                                ),
                                child: Icon(
                                  LucideIcons.refreshCw,
                                  size: 22,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getWelcomeText() {
    switch (currentMode) {
      case TimerMode.focus:
        return 'Selamat Belajar, ';
      case TimerMode.shortBreak:
        return 'Waktunya Istirahat!';
      case TimerMode.longBreak:
        return 'Istirahat Panjang!';
    }
  }
}

enum TimerMode {
  focus,
  shortBreak,
  longBreak,
}