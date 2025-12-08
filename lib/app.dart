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
      initialRoute: _initialRoute(),
      routes: {
        '/first_splash': (_) => const FirstTimeSplashScreen(),
        '/join': (_) => const JoinRoomScreen(),
        '/name': (_) => const NameScreen(),
        '/rooms': (_) => const RoomsScreen(),
        '/chat': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>?;

          if (args == null && lastRoomId != null && lastIdentity != null) {
            return const ChatScreen(key: ValueKey("resume_chat"));
          }

          return const ChatScreen();
        },
      },
    );
  }

  String _initialRoute() {
    if (isFirstLaunch) return '/first_splash';
    if (lastRoomId != null && lastIdentity != null) return '/chat';
    return '/rooms';
  }
}
