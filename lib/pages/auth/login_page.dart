import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tugasku/constants.dart';
import 'package:tugasku/pages/auth/forgot_password_page.dart';
import 'package:tugasku/pages/auth/register_page.dart';
import 'package:tugasku/logo.dart';
import 'package:tugasku/widgets/common/bottom_tab_bar.dart';
import 'package:tugasku/widgets/common/button_widget.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Logo
              LogoTugasKu(),

              // Greetings
              Column(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Kembali Lagi!',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w700,
                                fontSize: 36,
                              ),
                            ),
                            Gap(10),
                            Text(
                              'Senang bertemu lagi, tugasmu sudah menunggu!',
                              style: GoogleFonts.inter(
                                color: blackColor.withValues(alpha: 0.5),
                                fontSize: 16
                              ),
                            ),
                          ],
                        ),
                      ),
                      Gap(24),
                  
                      // Email Textfield
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        child: Container(
                          decoration: BoxDecoration(
                            color: fullWhite,
                            border: Border.all(color: secondaryColor),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                spreadRadius: 1,
                                blurRadius: 2, 
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20.0),
                            child: TextField(
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Email',
                              ),
                            ),
                          ),
                        ),
                      ),
                      Gap(15),
                      
                      // Password Textfield
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        child: Container(
                          decoration: BoxDecoration(
                            color: fullWhite,
                            border: Border.all(color: secondaryColor),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                spreadRadius: 1,
                                blurRadius: 2, 
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20.0),
                            child: TextField(
                              obscureText: true,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Kata Sandi',
                              ),
                            ),
                          ),
                        ),
                      ),
                      Gap(15),
                  
                      // Forgot Password
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (builder){
                              return ForgotPasswordPage();
                            })
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                'Lupa Kata Sandi?',
                                style: GoogleFonts.inter(
                                  color: blackColor.withValues(alpha: 0.7),
                                  fontSize: 14
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Gap(40),
                  
                      // Login Button
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: ButtonWidget(
                          text: 'Masuk',
                          onTap: (){
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (builder){
                                return BottomTabBar(selectedIndex: 0);
                              })
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 40),

              // Register Button
              GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (builder){
                      return RegisterPage();
                    })
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Belum punya akun? '),
                    Text(
                      'Daftar Disini', 
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      )
    );
  }
}
