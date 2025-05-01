import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tugasku/constants.dart';
import 'package:tugasku/pages/auth/login_page.dart';
import 'package:tugasku/logo.dart';
import 'package:tugasku/widgets/common/button_widget.dart';
import 'package:tugasku/widgets/common/bottom_tab_bar.dart';
import 'package:tugasku/services/api_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

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
                  _buildTextField('Nama Lengkap', _nameController),
                  Gap(15),
                  // Email Textfield
                  _buildTextField('Email', _emailController),
                  Gap(15),
                  // Password Textfield
                  _buildTextField('Kata Sandi', _passwordController, obscureText: true),
                  Gap(15),
                  // Confirm Password Textfield
                  _buildTextField('Ulangi Kata Sandi', _confirmPasswordController, obscureText: true),
                  Gap(40),

                  // Register Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child:_isLoading
                    ? Center(child: CircularProgressIndicator())
                    : ButtonWidget(
                        text: 'Daftar',
                        onTap: () async {
                          // Validasi input
                          if (_nameController.text.isEmpty ||
                              _emailController.text.isEmpty ||
                              _passwordController.text.isEmpty ||
                              _confirmPasswordController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Semua data harus diisi')),
                            );
                            return;
                          }
                          
                          if (_passwordController.text != _confirmPasswordController.text) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Kata sandi dan konfirmasi kata sandi harus sama')),
                            );
                            return;
                          }
                          
                          setState(() {
                            _isLoading = true;
                          });
                          
                          final result = await _apiService.register(
                            _nameController.text,
                            _emailController.text,
                            _passwordController.text,
                            _confirmPasswordController.text,
                          );
                          
                          setState(() {
                            _isLoading = false;
                          });
                          
                          if (result['success']) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (builder){
                                return BottomTabBar(selectedIndex: 0);
                              })
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(result['message'])),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),

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

  Widget _buildTextField(String hintText, controller, {bool obscureText = false}) {
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
            controller: controller,
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