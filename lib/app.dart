import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'src/features/join_room/join_room_screen.dart';

class RumourApp extends StatelessWidget {
  const RumourApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Rumour",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF0D0D0D),
        textTheme: GoogleFonts.interTextTheme(),
        colorScheme: const ColorScheme.dark(),
      ),
      home: const JoinRoomScreen(),
    );
  }
}
