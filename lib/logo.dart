import 'package:flutter/material.dart';
import 'package:tugasku/constants.dart';

class LogoTugasKu extends StatelessWidget {
  final double fontSize;
  final Color shadowColor;

  const LogoTugasKu({
    super.key,
    this.fontSize = 44,
    this.shadowColor = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          _buildTextSpan('Tugas', blackColor),
          _buildTextSpan('·', biruLogo),
          _buildTextSpan('Ku', primaryColor),
        ],
      ),
    );
  }

  TextSpan _buildTextSpan(String text, Color color) {
    return TextSpan(
      text: text,
      style: TextStyle(
        color: color,
        fontSize: fontSize,
        fontWeight: FontWeight.w800,
        shadows: [
          Shadow(
            color: shadowColor.withValues(alpha: 0.5),
            offset: Offset(2, 3),
            blurRadius: 5,
          ),
        ],
      ),
    );
  }
}