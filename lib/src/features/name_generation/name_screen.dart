import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import 'name_controller.dart';
import 'package:google_fonts/google_fonts.dart';

class NameScreen extends StatelessWidget {
  const NameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    final String roomId = args?['roomId'];
    final String? roomCode = args?['roomCode'];

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
  final String? roomCode;

  const NameScreenBody({super.key, required this.roomId, this.roomCode});

  @override
  Widget build(BuildContext context) {
    final ctrl = Provider.of<NameController>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),
            Row(
              children: [
                const SizedBox(width: 12),
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
                Column(
                  children: [
                    Text(
                      "Room ${roomCode ?? ''}",
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Members: anonymous",
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
                child:
                    ctrl.loading
                        ? const Center(child: CircularProgressIndicator())
                        : Column(
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
                              ctrl.identity?['name'] ?? 'Anonymous',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                color: AppColors.accent,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "This is your anonymous identifier, visible only to others in this room.",
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
            Padding(
              padding: const EdgeInsets.all(16),
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
