import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_assets.dart';
import '../../core/services/room_service.dart';

class JoinRoomScreen extends StatefulWidget {
  const JoinRoomScreen({super.key});

  @override
  State<JoinRoomScreen> createState() => _JoinRoomScreenState();
}

class _JoinRoomScreenState extends State<JoinRoomScreen> {
  bool isLoading = false;
  String? errorMessage;

  Future<void> _verifyRoomAndProceed(String code) async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final roomService = RoomService();
    final exists = await roomService.roomExists(code);

    if (!mounted) return;

    if (!exists) {
      setState(() {
        isLoading = false;
        errorMessage = "Room not found. Try '1234'.";
      });
      return;
    }

    Navigator.pushNamed(
      context,
      '/name',
      arguments: {'roomId': code, 'roomCode': code},
    );

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 12),

            // ----------------------------------------------------
            // BACK BUTTON (NEW)
            // ----------------------------------------------------
            Row(
              children: [
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    height: 42,
                    width: 42,
                    decoration: const BoxDecoration(
                      color: Color(0xFF1F2430),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 26),

            // Top Logo Circle
            Center(
              child: Container(
                height: 72,
                width: 72,
                decoration: const BoxDecoration(
                  color: Color(0xFF1A1A1A),
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

            // Subtitle
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

            const SizedBox(height: 24),

            Text(
              "Hint: Try room code 1234",
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.white.withOpacity(0.6),
              ),
            ),

            const SizedBox(height: 30),

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
                  enableActiveFill: false,

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
                  ),

                  onChanged: (_) {},

                  onCompleted: (code) async {
                    await _verifyRoomAndProceed(code);
                  },
                ),
              ),
            ),

            const SizedBox(height: 12),

            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  errorMessage!,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.redAccent,
                  ),
                ),
              ),

            if (isLoading)
              const Padding(
                padding: EdgeInsets.only(top: 18),
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),

            const Spacer(),
          ],
        ),
      ),
    );
  }
}
