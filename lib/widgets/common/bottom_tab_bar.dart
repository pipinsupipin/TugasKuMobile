import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tugasku/constants.dart';
import 'package:tugasku/pages/main/home_page.dart';
import 'package:tugasku/pages/main/kalender_page.dart';
import 'package:tugasku/pages/main/setting_page.dart';
import 'package:tugasku/pages/main/timer_page.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:tugasku/widgets/overlay/add_task_overlay.dart';

class BottomTabBar extends StatefulWidget {
  final int selectedIndex;
  
  const BottomTabBar({super.key, required this.selectedIndex});

  @override
  State<BottomTabBar> createState() => _BottomTabBarState();
}

class _BottomTabBarState extends State<BottomTabBar> 
    with TickerProviderStateMixin {
  late int _currentIndex;
  late PageController _pageController;
  late AnimationController _fabController;
  late Animation<double> _fabAnimation;
  
  // Page storage for maintaining state
  final PageStorageBucket _bucket = PageStorageBucket();
  
  // Tab data
  final List<TabData> _tabs = [
    TabData(
      icon: LucideIcons.home,
      label: 'Beranda',
      page: const HomePage(),
    ),
    TabData(
      icon: LucideIcons.calendar,
      label: 'Kalender', 
      page: const KalenderPage(),
    ),
    TabData(
      icon: LucideIcons.timer,
      label: 'Timer',
      page: const TimerPage(),
    ),
    TabData(
      icon: LucideIcons.settings,
      label: 'Pengaturan',
      page: const SettingPage(),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.selectedIndex;
    _pageController = PageController(initialPage: _currentIndex);
    
    // FAB animation
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _fabAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(
      parent: _fabController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fabController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (_currentIndex != index) {
      HapticFeedback.lightImpact();
      setState(() {
        _currentIndex = index;
      });
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _onFabPressed() {
    HapticFeedback.mediumImpact();
    _fabController.forward().then((_) {
      _fabController.reverse();
    });
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => AddTaskOverlay(
        onTaskAdded: () {
          // Refresh both HomePage and KalenderPage
          HomePageState.refreshData();
          KalenderPageState.refreshData();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageStorage(
        bucket: _bucket,
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          children: _tabs.map((tab) => tab.page).toList(),
        ),
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabAnimation,
        child: FloatingActionButton(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          onPressed: _onFabPressed,
          child: const Icon(
            LucideIcons.plus,
            size: 28,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: BottomAppBar(
          color: Colors.transparent,
          elevation: 0,
          shape: const CircularNotchedRectangle(),
          notchMargin: 10,
          child: Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // First two tabs
                _buildTabItem(0),
                _buildTabItem(1),
                
                // Space for FAB
                const SizedBox(width: 50),
                
                // Last two tabs
                _buildTabItem(2),
                _buildTabItem(3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem(int index) {
    final tab = _tabs[index];
    final isSelected = _currentIndex == index;
    
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => _onTabTapped(index),
          child: Container(
            height: 40,
            child: Center(
              child: Icon(
                tab.icon,
                color: isSelected ? primaryColor : Colors.grey.shade600,
                size: 22,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Tab data model
class TabData {
  final IconData icon;
  final String label;
  final Widget page;

  const TabData({
    required this.icon,
    required this.label,
    required this.page,
  });
}