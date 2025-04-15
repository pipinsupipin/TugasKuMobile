import 'package:flutter/material.dart';
import 'package:tugasku/constants.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:tugasku/pages/auth/login_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tugasku/widgets/common/button_widget.dart';

class OnBoardingPage extends StatefulWidget {
  const OnBoardingPage({super.key});

  @override
  State<OnBoardingPage> createState() => _OnBoardingPageState();
}

class _OnBoardingPageState extends State<OnBoardingPage> {
  @override
  Widget build(BuildContext context) {
    final pageDecoration = PageDecoration(
      titleTextStyle: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w700),
      bodyTextStyle: GoogleFonts.inter(fontSize: 16),
      bodyPadding: EdgeInsets.fromLTRB(16, 0, 16, 16),
      imagePadding: EdgeInsets.zero,
      bodyFlex: 4,
      imageFlex: 5,
      safeArea: 100,
      );

    return IntroductionScreen(
      globalBackgroundColor: backgroundColor,
      pages: [
        PageViewModel(
          title: 'Catat Tugasmu dengan Lebih Mudah!',
          body: 'Catat semua tugas dan jadwal kamu biar nggak ada yang kelewatan',
          image: Image.asset('assets/backpack.png', width: 250),
          decoration: pageDecoration
          ),
        PageViewModel(
          titleWidget: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Tetap Produktif dengan ',
                  style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w700, color: blackColor),
                ),
                TextSpan(
                  text: 'Streak!',
                  style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w700, color: orangeColor),
                ),
              ],
            ),
          ),
          body: 'Kerjakan tugas setiap hari dan jangan biarkan streakmu padam!',
          image: Image.asset('assets/streak.png'),
          decoration: pageDecoration
          ),
        PageViewModel(
          title: 'Sudah Siap Jadi Lebih Terorganisir?',
          body: 'Yuk! Atur tugasmu sekarang, tingkatkan produktivitas, dan jadi juara di sekolah!',
          image: Image.asset('assets/tos.png', width: 300),
          footer: Container(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: SizedBox(
                height: 50,
                width: double.infinity,
                child: ButtonWidget(
                  text: 'Mulai Nugas!',
                  onTap: (){
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (builder){
                        return LoginPage();
                      })
                    );
                  },
                ),
              ),
            ),
          ),
          decoration: pageDecoration.copyWith(safeArea: 16)
        ),
      ],
      showSkipButton: true,
      showNextButton: true,
      showDoneButton: false,
      showBackButton: false,
      skip: Text(
        'Lewati', 
        style: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          color: blackColor
          )
        ),
      next: const Icon(
        Icons.arrow_forward,
        color: blackColor,
        ),
      curve: Curves.fastLinearToSlowEaseIn,
      controlsMargin: const EdgeInsets.all(16),
      dotsDecorator: DotsDecorator(
        size: Size(10, 10),
        color: primaryColor.withValues(alpha: 0.5),
        activeSize: Size(22, 10),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
        activeColor: primaryColor
      ),
    );
  }
}
