import 'package:flutter/material.dart';
import 'package:tugasku/constants.dart';
import 'package:tugasku/pages/main/home_page.dart';
import 'package:tugasku/pages/main/kalender_page.dart';
import 'package:tugasku/pages/main/setting_page.dart';
import 'package:tugasku/pages/main/timer_page.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:tugasku/widgets/overlay/add_task_overlay.dart';

// ignore: must_be_immutable
class BottomTabBar extends StatefulWidget {
  int selectedIndex = 0;

  BottomTabBar({super.key, required this.selectedIndex});

  @override
  State<BottomTabBar> createState() => _BottomTabBarState();
}

class _BottomTabBarState extends State<BottomTabBar> {
  int currentIndex = 0;

  void onItemTapped(int index) {
    setState(() {
      widget.selectedIndex = index;
      currentIndex = widget.selectedIndex;
    });
  }

  @override
  void initState() {
    onItemTapped(widget.selectedIndex);
    super.initState();
  }

  final List<Widget> pages = [
    HomePage(),
    KalenderPage(),
    TimerPage(),
    SettingPage(),
  ];

  final PageStorageBucket bucket = PageStorageBucket();

  @override
  Widget build(BuildContext context) {
    Widget currentScreen = currentIndex == 0
        ? HomePage()
        : currentIndex == 1
            ? KalenderPage()
            : currentIndex == 2
                ? TimerPage()
                : SettingPage();

    return Scaffold(
      body: PageStorage(
        bucket: bucket,
        child: currentScreen,
      ),
      floatingActionButton: FloatingActionButton(
          backgroundColor: primaryColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          child: Icon(LucideIcons.plus, color: fullWhite),
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => AddTaskOverlay(
                onTaskAdded: () {
                  // Panggil refresh pada kedua halaman secara langsung
                  HomePageState.refreshData();
                  KalenderPageState.refreshData();
                },
              ),
            );
          }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: fullWhite,
        shape: const CircularNotchedRectangle(),
        notchMargin: 10,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            MaterialButton(
              minWidth: 50,
              onPressed: () {
                setState(() {
                  currentScreen = HomePage();
                  currentIndex = 0;
                });
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    LucideIcons.home,
                    color: currentIndex == 0 ? primaryColor : Colors.grey,
                  ),
                ],
              ),
            ),
            MaterialButton(
              minWidth: 50,
              onPressed: () {
                setState(() {
                  currentScreen = KalenderPage();
                  currentIndex = 1;
                });
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    LucideIcons.calendar,
                    color: currentIndex == 1 ? primaryColor : Colors.grey,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 50),
            MaterialButton(
              minWidth: 50,
              onPressed: () {
                setState(() {
                  currentScreen = TimerPage();
                  currentIndex = 2;
                });
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    LucideIcons.timer,
                    color: currentIndex == 2 ? primaryColor : Colors.grey,
                  ),
                ],
              ),
            ),
            MaterialButton(
              minWidth: 50,
              onPressed: () {
                setState(() {
                  currentScreen = SettingPage();
                  currentIndex = 3;
                });
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    LucideIcons.settings,
                    color: currentIndex == 3 ? primaryColor : Colors.grey,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
