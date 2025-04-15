import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:tugasku/constants.dart';
import 'package:tugasku/models/kategori.dart';
import 'package:tugasku/models/tugas.dart';
import 'package:tugasku/widgets/common/bottom_tab_bar.dart';
import 'package:tugasku/widgets/common/drawer.dart';
import 'package:tugasku/widgets/tugas/kategori_tugas.dart';
import 'package:tugasku/widgets/tugas/tugas_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final sisaTugas = tugas.where((t) => t.isCompleted == false).toList()..sort((a, b) {
      final aTime = a.waktuMulai ?? DateTime(9999);
      final bTime = b.waktuMulai ?? DateTime(9999);
      return aTime.compareTo(bTime);
    });

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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Column(
              children: [
                Gap(32),
                // ===== STREAK COUNT =====
                _Streak(),
                Gap(21),
                // ===== KATEGORI TUGAS =====
                SizedBox(
                  height: 200,
                  child: ListView.separated(
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: KategoriTugas(
                          kategori: kategori[index],
                        ),
                      );
                    }, 
                    separatorBuilder: (BuildContext context, int index){
                      return Gap(8);
                    }, 
                    itemCount: kategori.length,
                    scrollDirection: Axis.horizontal,
                  ),
                ),
                Gap(24),
                // ===== JUDUL SISA TUGAS =====
                Row(
                  children: [
                    Text(
                      'Sisa Tugas',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Spacer(),
                    GestureDetector(
                      onTap: (){
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (builder){
                            return BottomTabBar(selectedIndex: 1);
                          })
                        );
                      },
                      child: Text(
                        "Lihat Semua Tugas",
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: blackColor.withValues(alpha: 0.7)
                        ),
                      )
                    )
                  ],
                ),
                Gap(8),
                // ===== SISA TUGAS =====
                ListView.separated(
                  itemBuilder: (BuildContext context, int index) {
                    return TugasWidget(
                      tugas: sisaTugas[index],
                    );
                  }, 
                  separatorBuilder: (BuildContext context, int index){
                    return Gap(8);
                  }, 
                  itemCount: sisaTugas.length,
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                ),
              ],
            ),
          ),
        )
      ),
    );
  }
}

class _Streak extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'assets/streak.png',
          width: MediaQuery.of(context).size.width * 0.35,
          fit: BoxFit.cover,
        ),
        SizedBox(height: 8),
        RichText(
          text: TextSpan(
            style: GoogleFonts.inter(
              color: blackColor, 
              fontSize: 21, 
              fontWeight: FontWeight.w600,
              shadows: [
                Shadow(
                  offset: Offset(0, 2),
                  blurRadius: 5,
                  color: Colors.black26.withValues(alpha: 0.15)
                )
              ],
            ),
            children: [
              TextSpan(
                text: 'Kamu memiliki',
              ),
              TextSpan(
                text: ' 69 ',
                style: GoogleFonts.inter(
                  color: orangeColor,
                  fontSize: 42,
                  fontWeight: FontWeight.w800
                ),
              ),
              TextSpan(
                text: 'Streaks!',
              ),
            ]
          ),
        ),
      ],
    );
  }
}
