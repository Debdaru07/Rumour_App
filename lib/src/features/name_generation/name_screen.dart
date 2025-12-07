import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import 'name_controller.dart';

class NameScreen extends StatelessWidget {
  const NameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    final String roomId = args['roomId'] ?? '';
    final String roomCode = args['roomCode'] ?? '';

    return ChangeNotifierProvider(
      create: (_) {
        final c = NameController();
        c.ensureIdentity(roomId);
        return c;
      },
      child: NameScreenBody(roomId: roomId, roomCode: roomCode),
    );
  }
}

class NameScreenBody extends StatelessWidget {
  final String roomId;
  final String roomCode;

  const NameScreenBody({
    super.key,
    required this.roomId,
    required this.roomCode,
  });

  @override
  Widget build(BuildContext context) {
    final ctrl = Provider.of<NameController>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),

            // ---------------- HEADER ----------------
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(width: 16),

                // back button circle
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
                Spacer(),
                // room info
                Column(
                  children: [
                    Text(
                      "Room #$roomCode",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "4 members",
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textGrey,
                      ),
                    ),
                  ],
                ),
                Spacer(),
                // right placeholder circle
                Container(
                  height: 42,
                  width: 42,
                  decoration: const BoxDecoration(
                    color: Color(0xFF0D0D0D),
                    shape: BoxShape.circle,
                  ),
                ),

                const SizedBox(width: 12),
              ],
            ),

            Spacer(),
            // ---------------- IDENTITY CARD ----------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 40,
                  horizontal: 22,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F1525), // dark navy from Figma
                  borderRadius: BorderRadius.circular(24),
                ),
                child:
                    ctrl.loading
                        ? const Center(child: CircularProgressIndicator())
                        : Column(
                          children: [
                            Text(
                              "For this room, you are",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: AppColors.textGrey,
                                height: 1.3,
                              ),
                            ),

                            const SizedBox(height: 22),

                            // IDENTITY NAME
                            Text(
                              ctrl.identity?['name'] ?? "Anonymous",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 36,
                                fontWeight: FontWeight.w800,
                                height: 1.1,
                                color: AppColors.accent,
                              ),
                            ),

                            const SizedBox(height: 20),

                            Text(
                              "This is your anonymous identifier, visible only to others in this room.",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                height: 1.5,
                                color: AppColors.textGrey,
                              ),
                            ),
                          ],
                        ),
              ),
            ),

            // ---------------- BUTTON ----------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 50),
              child: GestureDetector(
                onTap: () {
                  final identity =
                      ctrl.identity ??
                      {'id': 'anon', 'name': 'Anonymous', 'avatar': ''};

                  Navigator.pushReplacementNamed(
                    context,
                    '/chat',
                    arguments: {
                      'roomId': roomId,
                      'roomCode': roomCode,
                      'identity': identity,
                    },
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withOpacity(0.35),
                        blurRadius: 22,
                        spreadRadius: 1,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      "Acknowledge and continue",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
