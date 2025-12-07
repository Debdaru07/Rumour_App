import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'src/core/constants/app_colors.dart';
import 'src/features/splash/first_time_splash_screen.dart';
import 'src/features/join_room/join_room_screen.dart';
import 'src/features/name_generation/name_screen.dart';
import 'src/features/chat/chat_screen.dart';

class RumourApp extends StatelessWidget {
  final bool isFirstLaunch;

  const RumourApp({super.key, required this.isFirstLaunch});

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

      initialRoute: isFirstLaunch ? '/first_splash' : '/join',

      routes: {
        '/first_splash': (context) => const FirstTimeSplashScreen(),
        '/join': (context) => const JoinRoomScreen(),
        '/name': (context) => const NameScreen(),
        '/chat': (context) => const ChatScreen(),
      },
    );
  }
}
