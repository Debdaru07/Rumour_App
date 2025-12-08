import 'dart:developer' as console;
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
    console.log("Entered Code: $code");

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final roomId = await RoomService().getRoomIdFromCode(code.trim());
    console.log("Resolved Room ID: $roomId");

    if (!mounted) return;

    if (roomId == null) {
      setState(() {
        isLoading = false;
        errorMessage = "Room not found.";
      });
      return;
    }

    Navigator.pushNamed(
      context,
      '/name',
      arguments: {'roomId': roomId, 'roomCode': code},
    );

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),

            Row(
              children: [
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
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

            Text(
              "Join A Room",
              style: GoogleFonts.poppins(
                fontSize: 34,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 60),
              child: Text(
                "Enter the code to join the anonymous chat room",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  color: AppColors.textGrey,
                  height: 1.4,
                ),
              ),
            ),

            const SizedBox(height: 30),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: Container(
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
                  ),
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.underline,
                    fieldHeight: 35,
                    fieldWidth: 35,
                    inactiveColor: const Color(0xFF818181),
                    activeColor: AppColors.accent,
                    selectedColor: AppColors.accent,
                  ),
                  onCompleted: (code) async => _verifyRoomAndProceed(code),
                  onChanged: (_) {},
                ),
              ),
            ),

            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
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
