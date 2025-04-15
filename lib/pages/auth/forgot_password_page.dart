import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tugasku/constants.dart';
import 'package:tugasku/pages/auth/login_page.dart';
import 'package:tugasku/widgets/common/button_widget.dart';

class ForgotPasswordPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Lupa Password",
              style: GoogleFonts.inter(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: blackColor,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Masukkan email kamu untuk reset password.",
              style: GoogleFonts.inter(
                fontSize: 16,
                color: blackColor.withValues(alpha: 0.5),
              ),
            ),
            SizedBox(height: 24),
            TextField(
              decoration: InputDecoration(
                filled: true,
                fillColor: fullWhite,
                hintText: "Email",
                hintStyle: GoogleFonts.inter(color: blackColor.withValues(alpha: 0.5)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ButtonWidget(text: 'Kirim Email', onTap: (){})),
            SizedBox(height: 16),
            Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
                child: Text(
                  "Kembali ke Login",
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: blackColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}