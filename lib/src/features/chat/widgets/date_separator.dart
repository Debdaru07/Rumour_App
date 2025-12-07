import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DateSeparator extends StatelessWidget {
  final String text;
  const DateSeparator({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          text,
          style: GoogleFonts.inter(fontSize: 12, color: Colors.white),
        ),
      ),
    );
  }
}
