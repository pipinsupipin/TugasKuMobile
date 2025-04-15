import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tugasku/constants.dart';
import 'package:tugasku/pages/auth/login_page.dart';
import 'package:tugasku/logo.dart';
import 'package:tugasku/widgets/common/button_widget.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
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
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selamat Datang!',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w700,
                              fontSize: 36,
                            ),
                          ),
                          Gap(10),
                          Text(
                            'Sudah siap untuk mencatat tugasmu?',
                            style: GoogleFonts.inter(
                              color: blackColor.withValues(alpha: 0.5),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Gap(24),

                  // Full Name Textfield
                  _buildTextField('Nama Lengkap'),
                  Gap(15),
                  // Email Textfield
                  _buildTextField('Email'),
                  Gap(15),
                  // Password Textfield
                  _buildTextField('Kata Sandi', obscureText: true),
                  Gap(15),
                  // Confirm Password Textfield
                  _buildTextField('Ulangi Kata Sandi', obscureText: true),
                  Gap(40),

                  // Register Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: ButtonWidget(
                      text: 'Daftar',
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (builder) => LoginPage()),
                        );
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 40),

              // Login Button
              GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (builder) => LoginPage()),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Sudah punya akun? '),
                    Text(
                      'Masuk Disini',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String hintText, {bool obscureText = false}) {
    return Padding(
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
            obscureText: obscureText,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hintText,
            ),
          ),
        ),
      ),
    );
  }
}