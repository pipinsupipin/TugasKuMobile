import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tugasku/constants.dart';
import 'package:tugasku/services/crud_service.dart';

class Streak extends StatefulWidget {
  const Streak({super.key});

  @override
  _StreakState createState() => _StreakState();
}

class _StreakState extends State<Streak> {
  final ApiService _apiService = ApiService();
  int _currentStreak = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStreakData();
  }

  Future<void> _fetchStreakData() async {
    try {
      final response = await _apiService.getStreakData();
      if (response['status'] == 'success') {
        setState(() {
          _currentStreak = response['data']['current_streak'];
        });
      }
    } catch (e) {
      print('Error fetching streak data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                _currentStreak < 3
                    ? 'assets/streak_locked.png'
                    : 'assets/streak.png',
                width: MediaQuery.of(context).size.width * 0.35,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  style: GoogleFonts.inter(
                    color: blackColor,
                    fontSize: 21,
                    fontWeight: FontWeight.w600,
                    shadows: [
                      Shadow(
                        offset: const Offset(0, 2),
                        blurRadius: 5,
                        color: Colors.black.withValues(alpha: 0.15),
                      ),
                    ],
                  ),
                  children: [
                    const TextSpan(
                      text: 'Kamu memiliki',
                    ),
                    TextSpan(
                      text: ' $_currentStreak ',
                      style: GoogleFonts.inter(
                        color: _currentStreak < 3 ? Colors.grey : orangeColor,
                        fontSize: 42,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const TextSpan(
                      text: 'Streaks!',
                    ),
                  ],
                ),
              ),
            ],
          );
  }
}