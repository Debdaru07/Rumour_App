import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

class NameScreen extends StatelessWidget {
  final String roomCode;
  final String identity;

  const NameScreen({super.key, required this.roomCode, required this.identity});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),

            // Top Bar
            Row(
              children: [
                const SizedBox(width: 12),

                // Back Button
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFF1E1E1E),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                ),

                const Spacer(),

                // Room Code
                Column(
                  children: [
                    Text(
                      "Room #$roomCode",
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "4 members",
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.textGrey,
                      ),
                    ),
                  ],
                ),

                const Spacer(),
                const SizedBox(width: 48),
              ],
            ),

            const SizedBox(height: 60),

            // Identity Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 40,
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF101820),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Text(
                      "For this room, you are",
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        color: AppColors.textGrey,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Text(
                      identity,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: AppColors.accent,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Text(
                      "This is your anonymous identifier, visible only\nto others in this room.",
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.textGrey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),

            // Continue Button
            Padding(
              padding: const EdgeInsets.all(16),
              child: GestureDetector(
                onTap: () {
                  // TODO: Navigate to chat screen
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      "Acknowledge and continue",
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
