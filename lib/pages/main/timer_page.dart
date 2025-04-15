import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:tugasku/constants.dart';
import 'package:tugasku/widgets/common/drawer.dart';

class TimerPage extends StatefulWidget {
  const TimerPage({super.key});

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  static const int focusDuration = 25 * 60;
  static const int breakDuration = 5 * 60;

  int remainingSeconds = focusDuration;
  bool isRunning = false;
  bool isBreakTime = false;
  int completedSessions = 0;
  Timer? timer;

  void startTimer() {
    if (timer == null || !timer!.isActive) {
      timer = Timer.periodic(Duration(seconds: 1), (timer) {
        setState(() {
          if (remainingSeconds > 0) {
            remainingSeconds--;
          } else {
            timer.cancel();
            isBreakTime = !isBreakTime;
            remainingSeconds = isBreakTime ? breakDuration : focusDuration;
            if (!isBreakTime) completedSessions++;
            startTimer();
          }
        });
      });
      setState(() => isRunning = true);
    }
  }

  void pauseTimer() {
    timer?.cancel();
    setState(() => isRunning = false);
  }

  void resetTimer() {
    timer?.cancel();
    setState(() {
      isRunning = false;
      isBreakTime = false;
      remainingSeconds = focusDuration;
      completedSessions = 0;
    });
  }

  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int secs = seconds % 60;
    return "${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => Padding(
            padding: const EdgeInsets.only(left: 25),
            child: IconButton(
              icon: Icon(LucideIcons.menu),
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
                Text(
                  'Halo, Kevin!',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Gap(16),
                CircleAvatar(
                  radius: 20,
                  backgroundImage: AssetImage(
                    'assets/profile.jpg'
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      drawer: SideMenu(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text.rich(
              TextSpan(
                text: isBreakTime ? "Waktunya " : "Selamat Belajar,",
                style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.black),
                children: [
                  TextSpan(
                    text: isBreakTime ? "Istirahat!" : "\nKevin!",
                    style: GoogleFonts.inter(
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                      color: isBreakTime ? orangeColor : primaryColor,
                    ),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            Gap(40),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 220,
                  height: 220,
                  child: CircularProgressIndicator(
                    value: remainingSeconds / (isBreakTime ? breakDuration : focusDuration),
                    strokeWidth: 12,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(isBreakTime ? orangeColor : primaryColor),
                  ),
                ),
                Text(
                  formatTime(remainingSeconds),
                  style: GoogleFonts.inter(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            Gap(30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: isRunning ? pauseTimer : startTimer,
                  style: ElevatedButton.styleFrom(
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(18),
                    backgroundColor: isRunning ? Colors.redAccent : primaryColor,
                  ),
                  child: Icon(isRunning ? LucideIcons.pause : LucideIcons.play, size: 30, color: Colors.white),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: resetTimer,
                  style: ElevatedButton.styleFrom(
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(18),
                    backgroundColor: Colors.grey[400],
                  ),
                  child: Icon(LucideIcons.refreshCw, size: 28, color: Colors.white),
                ),
              ],
            ),
            Gap(30),
            Container(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              decoration: BoxDecoration(
                color: fullWhite,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
              ),
              child: Text(
                "Sesi belajar selesai: $completedSessions",
                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}