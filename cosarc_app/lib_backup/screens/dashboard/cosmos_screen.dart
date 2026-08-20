import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:hive_flutter/hive_flutter.dart'; // REQUIRED
import '../../widgets/dynamic_island_streak.dart';
import 'workout_log_screen.dart';
import 'package:cosarc/screens/dashboard/enhanced_nutrition_screen.dart';

// IMPORTANT: Ensure these paths match your project exactly
import 'package:cosarc/services/nutrition_tracker.dart'; 
import 'package:cosarc/models/food_log.dart'; 

const Color cosarcPink = Color(0xFFE91E63);

class CosmosScreen extends StatefulWidget {
  const CosmosScreen({super.key});

  @override
  State<CosmosScreen> createState() => _CosmosScreenState();
}

class _CosmosScreenState extends State<CosmosScreen> {
  late VideoPlayerController _controller;

  bool workoutDone = false;
  // bool eatCleanDone = false; // We now use Hive for this
  int waterMl = 0;
  int steps = 3200;
  bool moodSubmitted = false;

  static const int waterTarget = 3000;
  static const int stepTarget = 10000;

  @override
  void initState() {
    super.initState();
    // Initialize Video
    _controller = VideoPlayerController.asset(
      'assets/backgrounds/cosarc_intro.mp4',
    )
      ..setLooping(true)
      ..setVolume(0)
      ..initialize().then((_) {
        if (mounted) {
          _controller.play();
          setState(() {});
        }
      }).catchError((error) {
        debugPrint("Video Error: $error");
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Helper to check if food was logged today in Hive
  bool isFoodLoggedToday() {
    final box = Hive.box<FoodLog>('daily_logs');
    final now = DateTime.now();
    return box.values.any((log) => 
      log.dateTime.day == now.day && 
      log.dateTime.month == now.month && 
      log.dateTime.year == now.year);
  }

  bool get contractComplete {
    return workoutDone &&
           isFoodLoggedToday() &&
           waterMl >= waterTarget &&
           steps >= stepTarget;
  }

  String timeState() {
    final h = DateTime.now().hour;
    if (h < 11) return "The system is stable — for now.";
    if (h < 17) return "Input pending.";
    if (h < 21) return "Stability is deteriorating.";
    return "Final correction window.";
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    final height = MediaQuery.of(context).size.height;

    // Wrap in ValueListenableBuilder so the UI updates when food is logged
    return ValueListenableBuilder(
      valueListenable: Hive.box<FoodLog>('daily_logs').listenable(),
      builder: (context, Box<FoodLog> box, _) {
        bool eatCleanDone = isFoodLoggedToday();

        return Stack(
          children: [
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // ================= HERO =================
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: height * 0.70,
                    width: double.infinity,
                    child: Stack(
                      children: [
                        // 🎬 VIDEO
                        if (_controller.value.isInitialized)
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(36),
                              bottomRight: Radius.circular(36),
                            ),
                            child: SizedBox.expand(
                              child: FittedBox(
                                fit: BoxFit.cover,
                                child: SizedBox(
                                  width: _controller.value.size.width,
                                  height: _controller.value.size.height,
                                  child: VideoPlayer(_controller),
                                ),
                              ),
                            ),
                          )
                        else
                          Container(color: Colors.black), // Fallback while loading

                        // 🌑 GRADIENT
                        Positioned.fill(
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.black87,
                                  Colors.transparent,
                                  Colors.black,
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                        ),

                        // 🔠 HEADER
                        SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Text(
                                  "cosarc",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                                CircleAvatar(
                                  backgroundColor: Colors.white24,
                                  child: Icon(Icons.person, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // 🧠 QUOTE
                        Positioned(
                          left: 20,
                          right: 20,
                          bottom: 36,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                "“",
                                style: TextStyle(
                                  fontSize: 44,
                                  color: Colors.white70,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                "the quiet space\nbetween who you are\nand who you are meant to be.",
                                style: TextStyle(
                                  fontSize: 18,
                                  height: 1.35,
                                  color: Colors.white70,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                "— cosarc",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white38,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(
                  child: SizedBox(height: 32),
                ),

                // ================= CONTRACT =================
                _section("today’s contract"),
                _headline("Order does not sustain itself."),
                _hint(timeState()),

                _ruleWorkout(context),
                _ruleEatClean(eatCleanDone),
                _ruleWater(),
                _ruleSteps(),

                _section("reflection"),
                _reflection(),

                const SliverToBoxAdapter(child: SizedBox(height: 120)),
              ],
            ),

            // 🔥 DYNAMIC ISLAND
            Positioned(
              top: topInset + 8,
              left: 0,
              right: 0,
              child: const Center(
                child: DynamicIslandStreak(streak: 7),
              ),
            ),
          ],
        );
      }
    );
  }

  // ================= UI HELPERS =================

  static SliverPadding _section(String text) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      sliver: SliverToBoxAdapter(
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            decoration: TextDecoration.none,
          ),
        ),
      ),
    );
  }

  static SliverToBoxAdapter _headline(String text) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w600,
            height: 1.2,
            color: Colors.white,
            decoration: TextDecoration.none,
          ),
        ),
      ),
    );
  }

  static SliverToBoxAdapter _hint(String text) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white70,
            decoration: TextDecoration.none,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  // ================= RULES =================

  SliverToBoxAdapter _ruleWorkout(BuildContext context) {
    return _ruleCard(
      title: "Workout",
      main: "The body degrades without resistance.",
      sub: workoutDone ? "Logged. Signal accepted." : "Tap to log workout.",
      completed: workoutDone,
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const WorkoutLogScreen()),
        );
        if (result == true) {
          setState(() => workoutDone = true);
        }
      },
    );
  }

  SliverToBoxAdapter _ruleEatClean(bool completed) {
    return _ruleCard(
      title: "Eat clean",
      main: "Fuel determines trajectory.",
      sub: completed
          ? "Fuel logged. Trajectory locked."
          : "Awaiting fuel input.",
      completed: completed,
      onTap: () {
        Navigator.push(
          context, 
          MaterialPageRoute(builder: (context) => const EnhancedNutritionScreen())
        );
      },
    );
  }

  SliverToBoxAdapter _ruleWater() {
    final progress = (waterMl / waterTarget).clamp(0.0, 1.0);
    return _ruleMeter(
      title: "Water · 3L",
      main: "Hydration sustains cognition.",
      sub: "$waterMl ml logged",
      progress: progress,
      action: () => setState(() => waterMl += 300),
    );
  }

  SliverToBoxAdapter _ruleSteps() {
    final progress = (steps / stepTarget).clamp(0.0, 1.0);
    return _ruleMeter(
      title: "Steps · 10,000",
      main: "Motion prevents decay.",
      sub: "$steps / $stepTarget",
      progress: progress,
    );
  }

  SliverToBoxAdapter _reflection() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(24),
        ),
        child: contractComplete
            ? const Text("Reflection unlocked.", style: TextStyle(color: Colors.white))
            : const Text(
                "Reflection permitted once order is restored.",
                style: TextStyle(color: Colors.white54, fontSize: 14, decoration: TextDecoration.none),
              ),
      ),
    );
  }

  // ================= COMPONENTS =================

  SliverToBoxAdapter _ruleCard({
    required String title,
    required String main,
    required String sub,
    required bool completed,
    VoidCallback? onTap,
  }) {
    return SliverToBoxAdapter(
      child: _shell(
        title: title,
        main: main,
        sub: sub,
        completed: completed,
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white70),
        onTap: onTap,
      ),
    );
  }

  SliverToBoxAdapter _ruleMeter({
    required String title,
    required String main,
    required String sub,
    required double progress,
    VoidCallback? action,
  }) {
    return SliverToBoxAdapter(
      child: _shell(
        title: title,
        main: main,
        sub: sub,
        completed: progress >= 1,
        trailing: action == null
            ? null
            : GestureDetector(
                onTap: action,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text("+300 ml", style: TextStyle(color: Colors.white, fontSize: 12)),
                ),
              ),
        progress: progress,
      ),
    );
  }

  Widget _shell({
    required String title,
    required String main,
    required String sub,
    required bool completed,
    Widget? trailing,
    double? progress,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 26),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            width: 2,
            color: completed
                ? cosarcPink.withOpacity(0.8)
                : Colors.transparent,
          ),
        ),
        child: Material( // Wrap in material to prevent text rendering issues
          color: Colors.transparent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  if (trailing != null) trailing,
                ],
              ),
              const SizedBox(height: 10),
              Text(main, style: const TextStyle(fontSize: 16, color: Colors.white)),
              const SizedBox(height: 6),
              Text(sub, style: const TextStyle(color: Colors.white70, fontSize: 13)),
              if (progress != null) ...[
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.white24,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(cosarcPink),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}