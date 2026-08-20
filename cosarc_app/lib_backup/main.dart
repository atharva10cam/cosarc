import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Entry screen
import 'package:cosarc/screens/app_start/app_start_screen.dart';

// Hive
import 'package:cosarc/models/food_log.dart';
import 'package:cosarc/models/food_adapter.dart';

Future<void> main() async {
  // REQUIRED for Hive, video_player, unity
  WidgetsFlutterBinding.ensureInitialized();

  // INIT HIVE
  await Hive.initFlutter();

  // REGISTER ADAPTER (ONLY ONCE)
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(FoodLogAdapter());
  }

  // 🔴 CRITICAL: OPEN BOX BEFORE runApp
  if (!Hive.isBoxOpen('daily_logs')) {
    await Hive.openBox<FoodLog>('daily_logs');
  }

  // START APP
  runApp(const CosarcApp());
}

class CosarcApp extends StatelessWidget {
  const CosarcApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cosarc',

      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0C0C0C),

        textTheme: GoogleFonts.montserratTextTheme(
          Theme.of(context).textTheme.apply(
                bodyColor: Colors.white,
                displayColor: Colors.white,
              ),
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF161616),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          hintStyle: const TextStyle(color: Colors.white54),
        ),
      ),

      // ENTRY
      home: const AppStartScreen(),
    );
  }
}
