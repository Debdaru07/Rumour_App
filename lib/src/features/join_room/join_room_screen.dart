import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_assets.dart';

class JoinRoomScreen extends StatelessWidget {
  const JoinRoomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),

            // App Logo
            Center(
              child: Container(
                height: 60,
                width: 60,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF1A1A1A),
                ),
                child: Center(
                  child: Image.asset(
                    AppAssets.logo,
                    height: 28,
                    color: AppColors.accent,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 60),

            // Title
            Text(
              "Join A Room",
              style: GoogleFonts.inter(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              "Enter the code to join the anon chat room",
              style: GoogleFonts.inter(fontSize: 15, color: AppColors.textGrey),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 40),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: PinCodeTextField(
                  appContext: context,
                  length: 4,
                  cursorColor: AppColors.accent,
                  textStyle: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                  keyboardType: TextInputType.number,
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.underline,
                    fieldHeight: 40,
                    fieldWidth: 40,
                    inactiveColor: AppColors.textGrey,
                    activeColor: AppColors.accent,
                    selectedColor: AppColors.accent,
                  ),
                  onCompleted: (code) {
                    // TODO: Navigate to Name Generation Screen
                  },
                  onChanged: (_) {},
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
