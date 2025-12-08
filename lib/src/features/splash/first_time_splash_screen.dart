import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_assets.dart';
import '../../core/services/first_launch_service.dart';

class FirstTimeSplashScreen extends StatefulWidget {
  const FirstTimeSplashScreen({super.key});

  @override
  State<FirstTimeSplashScreen> createState() => _FirstTimeSplashScreenState();
}

class _FirstTimeSplashScreenState extends State<FirstTimeSplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 2), () async {
      await FirstLaunchService.setLaunched();
      Navigator.pushReplacementNamed(context, '/rooms');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(AppAssets.logo, height: 110),
            const SizedBox(height: 20),
            Text(
              "Rumour",
              style: GoogleFonts.inter(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
