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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 48),

            // Top Logo Circle (exact size & spacing from Figma)
            Center(
              child: Container(
                height: 72,
                width: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Image.asset(AppAssets.logo, height: 46, width: 46),
                ),
              ),
            ),

            const Spacer(),

            // Title
            Text(
              "Join A Room",
              style: GoogleFonts.poppins(
                fontSize: 34,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 16),

            // Subtitle (exact line height & center align)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 60),
              child: Text(
                "Enter the code to join the anon chat room",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textGrey,
                  height: 1.4,
                ),
              ),
            ),

            const SizedBox(height: 42),

            // PIN Code Box
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: Container(
                height: 70,
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: PinCodeTextField(
                  appContext: context,
                  length: 4,
                  cursorColor: AppColors.accent,
                  keyboardType: TextInputType.number,
                  animationType: AnimationType.fade,

                  textStyle: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                  ),

                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.underline,
                    fieldHeight: 35,
                    fieldWidth: 35,
                    inactiveColor: const Color(0xFF818181),
                    activeColor: AppColors.accent,
                    selectedColor: AppColors.accent,
                    inactiveFillColor: Colors.transparent,
                  ),

                  onChanged: (_) {},
                  onCompleted: (code) {
                    Navigator.pushNamed(
                      context,
                      '/name',
                      arguments: {
                        'roomId': code, // <— roomId = code
                        'roomCode': code,
                      },
                    );
                  },
                ),
              ),
            ),

            const Spacer(),
          ],
        ),
      ),
    );
  }
}
