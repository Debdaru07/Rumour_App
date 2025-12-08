import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'src/core/constants/app_colors.dart';
import 'src/features/rooms/rooms_screen.dart';
import 'src/features/splash/first_time_splash_screen.dart';
import 'src/features/join_room/join_room_screen.dart';
import 'src/features/name_generation/name_screen.dart';
import 'src/features/chat/chat_screen.dart';

class RumourApp extends StatelessWidget {
  final bool isFirstLaunch;

  /// NEW — If user previously joined a room
  final String? lastRoomId;
  final Map<String, dynamic>? lastIdentity;

  const RumourApp({
    super.key,
    required this.isFirstLaunch,
    this.lastRoomId,
    this.lastIdentity,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Rumour",
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        textTheme: GoogleFonts.poppinsTextTheme(),
        colorScheme: const ColorScheme.dark(),
      ),

      // ---------------------------------------------------------
      // 🚀 Decide Startup Screen
      // ---------------------------------------------------------
      initialRoute: _resolveInitialRoute(),

      routes: {
        '/first_splash': (context) => const FirstTimeSplashScreen(),
        '/join': (context) => const JoinRoomScreen(),
        '/name': (context) => const NameScreen(),
        '/rooms': (context) => const RoomsScreen(),
        // ------------------------------------------
        // CHAT ROUTE — Pass session if returning user
        // ------------------------------------------
        '/chat': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>?;

          // If returning user:
          if (args == null && lastRoomId != null && lastIdentity != null) {
            return ChatScreen(
              key: const ValueKey("resume_chat"),
              // ChatScreen reads params using ModalRoute when needed
            );
          }

          return const ChatScreen();
        },
      },
    );
  }

  // ---------------------------------------------------------
  // 🚦 Decide which screen to start with
  // ---------------------------------------------------------
  String _resolveInitialRoute() {
    if (isFirstLaunch) return '/first_splash';

    // If user was inside a room → go directly to chat
    if (lastRoomId != null && lastIdentity != null) {
      return '/chat';
    }

    // Default — Join screen
    return '/rooms';
  }
}
