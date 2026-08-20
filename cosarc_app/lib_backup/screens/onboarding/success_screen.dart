import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacementNamed(context, '/dashboard');
    });

    return Scaffold(
      backgroundColor: const Color(0xFF0C0C0C),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle,
              size: 96,
              color: Colors.pinkAccent,
            ),
            const SizedBox(height: 16),
            Text(
              "You're all set!",
              style: GoogleFonts.montserrat(
                fontSize: 26,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "3 months > 1 perfect week",
              style: GoogleFonts.montserrat(
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
