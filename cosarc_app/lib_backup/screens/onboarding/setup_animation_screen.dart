import 'package:flutter/material.dart';
import 'setup_complete_screen.dart';

const Color cosarcPink = Color(0xFFE91E63);

class SetupAnimationScreen extends StatefulWidget {
  const SetupAnimationScreen({super.key});

  @override
  State<SetupAnimationScreen> createState() => _SetupAnimationScreenState();
}

class _SetupAnimationScreenState extends State<SetupAnimationScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SetupCompleteScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: cosarcPink),
            SizedBox(height: 24),
            Text(
              "Just a sec, setting your profile",
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
