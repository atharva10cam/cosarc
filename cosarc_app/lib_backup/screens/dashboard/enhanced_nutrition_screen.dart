import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:cosarc/models/food_log.dart';
import 'package:cosarc/services/enhanced_nutrition_service.dart';
import 'package:cosarc/screens/dashboard/enhanced_food_search.dart'; // ADD THIS LINE

// COSARC Professional Color System
const Color cosarcPink = Color(0xFFE91E63);
const Color cosarcDark = Color(0xFF080808);
const Color cosarcSurface = Color(0xFF121212);
const Color cosarcCard = Color(0xFF1A1A1A);
const Color cosarcAccent = Color(0xFF00E676);
const Color cosarcBlue = Color(0xFF2196F3);
const Color cosarcOrange = Color(0xFFFF9800);
const Color cosarcPurple = Color(0xFF9C27B0);

/// ======================================================
/// ENHANCED NUTRITION SCREEN V2.0
/// Professional, Cinematic Design
/// ======================================================
class EnhancedNutritionScreen extends StatefulWidget {
  const EnhancedNutritionScreen({super.key});
  
  @override
  State<EnhancedNutritionScreen> createState() => _EnhancedNutritionScreenState();
}

class _EnhancedNutritionScreenState extends State<EnhancedNutritionScreen> 
    with SingleTickerProviderStateMixin {
  final double dailyTarget = 2500;
  late AnimationController _animController;
  
  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }
  
  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cosarcDark,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(child: SizedBox(height: 10)),
          ValueListenableBuilder(
            valueListenable: Hive.box<FoodLog>('daily_logs').listenable(),
            builder: (context, Box<FoodLog> box, _) {
              final now = DateTime.now();
              final logs = box.values.where((l) => 
                l.dateTime.day == now.day && 
                l.dateTime.month == now.month &&
                l.dateTime.year == now.year
              ).toList();

              double tCal = logs.fold(0, (s, i) => s + i.calories);
              double tP = logs.fold(0, (s, i) => s + i.protein);
              double tC = logs.fold(0, (s, i) => s + i.carbs);
              double tF = logs.fold(0, (s, i) => s + i.fat);

              return SliverList(
                delegate: SliverChildListDelegate([
                  _buildStatsHeader(tCal, tP, tC, tF),
                  SizedBox(height: 20),
                  _buildMacroBreakdown(tP, tC, tF),
                  SizedBox(height: 30),
                  _buildMealSection("Breakfast", "🌅", logs, MealType.breakfast),
                  _buildMealSection("Lunch", "☀️", logs, MealType.lunch),
                  _buildMealSection("Dinner", "🌙", logs, MealType.dinner),
                  _buildMealSection("Snacks", "🍿", logs, MealType.snack),
                  SizedBox(height: 100),
                ]),
              );
            },
          ),
        ],
      ),
    );
  }

  /// ======================================================
  /// MODERN APP BAR WITH GLASSMORPHISM
  /// ======================================================
  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 100,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              cosarcPink.withOpacity(0.1),
              cosarcDark,
            ],
          ),
        ),
        child: FlexibleSpaceBar(
          centerTitle: true,
          title: Text(
            'FUEL LOG',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              letterSpacing: 4,
              color: Colors.white,
            ),
          ),
          background: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  cosarcPink.withOpacity(0.2),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// ======================================================
  /// CINEMATIC STATS HEADER
  /// ======================================================
  Widget _buildStatsHeader(double cal, double p, double c, double f) {
    final remaining = (dailyTarget - cal).clamp(0, dailyTarget);
    final progress = (cal / dailyTarget).clamp(0.0, 1.0);
    
    return FadeTransition(
      opacity: _animController,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20),
        padding: EdgeInsets.all(28),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              cosarcCard,
              cosarcSurface,
            ],
          ),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: Colors.white.withOpacity(0.05),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: cosarcPink.withOpacity(0.1),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // Main Stats Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMainStat(
                  label: "CONSUMED",
                  value: cal.toInt().toString(),
                  color: cosarcPink,
                  icon: Icons.local_fire_department_rounded,
                ),
                Container(
                  width: 2,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.white.withOpacity(0.1),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                _buildMainStat(
                  label: "REMAINING",
                  value: remaining.toInt().toString(),
                  color: remaining > 500 ? cosarcAccent : Colors.orangeAccent,
                  icon: Icons.favorite_rounded,
                ),
              ],
            ),
            
            SizedBox(height: 30),
            
            // Progress Bar
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Daily Target",
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 12,
                        letterSpacing: 1.5,
                      ),
                    ),
                    Text(
                      "${(progress * 100).toInt()}%",
                      style: TextStyle(
                        color: cosarcPink,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Stack(
                  children: [
                    Container(
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    AnimatedContainer(
                      duration: Duration(milliseconds: 600),
                      curve: Curves.easeOut,
                      height: 14,
                      width: MediaQuery.of(context).size.width * 0.85 * progress,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [cosarcPink, cosarcPink.withOpacity(0.6)],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: cosarcPink.withOpacity(0.3),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainStat({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.white38,
            fontSize: 10,
            letterSpacing: 2,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 5),
        Text(
          value,
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w900,
            color: color,
            height: 1,
          ),
        ),
        Text(
          "kcal",
          style: TextStyle(
            color: Colors.white24,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  /// ======================================================
  /// MACRO BREAKDOWN CARDS
  /// ======================================================
  Widget _buildMacroBreakdown(double protein, double carbs, double fat) {
    final total = protein + carbs + fat;
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildMacroCard(
              label: "Protein",
              value: protein.toInt(),
              color: cosarcBlue,
              icon: "💪",
              percentage: total > 0 ? (protein / total * 100).toInt() : 0,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _buildMacroCard(
              label: "Carbs",
              value: carbs.toInt(),
              color: cosarcOrange,
              icon: "⚡",
              percentage: total > 0 ? (carbs / total * 100).toInt() : 0,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _buildMacroCard(
              label: "Fat",
              value: fat.toInt(),
              color: cosarcPurple,
              icon: "🔥",
              percentage: total > 0 ? (fat / total * 100).toInt() : 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroCard({
    required String label,
    required int value,
    required Color color,
    required String icon,
    required int percentage,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            icon,
            style: TextStyle(fontSize: 24),
          ),
          SizedBox(height: 8),
          Text(
            "$value",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          Text(
            "grams",
            style: TextStyle(
              fontSize: 9,
              color: Colors.white38,
            ),
          ),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white54,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            "$percentage%",
            style: TextStyle(
              fontSize: 10,
              color: color.withOpacity(0.7),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// ======================================================
  /// MEAL SECTIONS WITH ENHANCED DESIGN
  /// ======================================================
  Widget _buildMealSection(
    String name,
    String emoji,
    List<FoodLog> allLogs,
    MealType mealType,
  ) {
    final logs = allLogs.where((l) => l.mealType == mealType.displayName).toList();
    final totalCal = logs.fold(0.0, (sum, log) => sum + log.calories);
    final isEmpty = logs.isEmpty;

    return Container(
      margin: EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          // Meal Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cosarcCard,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.05),
                    ),
                  ),
                  child: Text(
                    emoji,
                    style: TextStyle(fontSize: 24),
                  ),
                ),
                SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name.toUpperCase(),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        isEmpty ? "No items logged" : "${totalCal.toInt()} kcal",
                        style: TextStyle(
                          fontSize: 12,
                          color: isEmpty ? Colors.white24 : cosarcAccent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                // Add Button
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _openEnhancedSearch(context, mealType),
                    borderRadius: BorderRadius.circular(15),
                    child: Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [cosarcPink, cosarcPink.withOpacity(0.7)],
                        ),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: cosarcPink.withOpacity(0.3),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.add_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 12),
          
          // Food Items
          ...logs.map((log) => _buildFoodItem(log)).toList(),
          
          // Empty State
          if (isEmpty)
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.02),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.05),
                  style: BorderStyle.solid,
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  "Track your $name here",
                  style: TextStyle(
                    color: Colors.white24,
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// ======================================================
  /// ENHANCED FOOD ITEM CARD
  /// ======================================================
  Widget _buildFoodItem(FoodLog log) {
    return Dismissible(
      key: Key(log.dateTime.toString()),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        log.delete();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${log.name} removed'),
            backgroundColor: cosarcPink,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      },
      background: Container(
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        padding: EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.transparent, Colors.red.withOpacity(0.3)],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.centerRight,
        child: Icon(
          Icons.delete_rounded,
          color: Colors.red,
          size: 28,
        ),
      ),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              cosarcCard.withOpacity(0.5),
              cosarcSurface,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.03),
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => _showFoodDetail(log),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  // Food Icon/Type Indicator
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: cosarcPink.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.restaurant_rounded,
                      color: cosarcPink,
                      size: 24,
                    ),
                  ),
                  
                  SizedBox(width: 15),
                  
                  // Food Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          log.name,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            _buildMicroStat("P", log.protein.toInt(), cosarcBlue),
                            SizedBox(width: 12),
                            _buildMicroStat("C", log.carbs.toInt(), cosarcOrange),
                            SizedBox(width: 12),
                            _buildMicroStat("F", log.fat.toInt(), cosarcPurple),
                          ],
                        ),
                        SizedBox(height: 4),
                        Text(
                          "${log.quantity.toInt()} ${log.unit}",
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white24,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Calories
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "${log.calories.toInt()}",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: cosarcAccent,
                        ),
                      ),
                      Text(
                        "kcal",
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white38,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMicroStat(String label, int value, Color color) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          " $value",
          style: TextStyle(
            fontSize: 11,
            color: Colors.white54,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  /// ======================================================
  /// FOOD DETAIL DIALOG
  /// ======================================================
  void _showFoodDetail(FoodLog log) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [cosarcCard, cosarcSurface],
            ),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "NUTRITIONAL INFO",
                style: TextStyle(
                  fontSize: 12,
                  letterSpacing: 3,
                  color: Colors.white38,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 20),
              Text(
                log.name,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),
              _buildDetailRow("Energy", "${log.calories.toInt()} kcal", cosarcPink),
              _buildDetailRow("Protein", "${log.protein.toInt()} g", cosarcBlue),
              _buildDetailRow("Carbs", "${log.carbs.toInt()} g", cosarcOrange),
              _buildDetailRow("Fat", "${log.fat.toInt()} g", cosarcPurple),
              _buildDetailRow("Quantity", "${log.quantity} ${log.unit}", cosarcAccent),
              SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "CLOSE",
                  style: TextStyle(
                    color: cosarcPink,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white54,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  /// ======================================================
  /// OPEN ENHANCED SEARCH - FIXED VERSION
  /// ======================================================
  void _openEnhancedSearch(BuildContext context, MealType mealType) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EnhancedFoodSearchSheet(mealType: mealType.displayName), // FIXED HERE
    );
  }
}

/// ======================================================
/// MEAL TYPE ENUM
/// ======================================================
enum MealType {
  breakfast,
  lunch,
  dinner,
  snack,
}

extension MealTypeExtension on MealType {
  String get displayName {
    switch (this) {
      case MealType.breakfast:
        return "Breakfast";
      case MealType.lunch:
        return "Lunch";
      case MealType.dinner:
        return "Dinner";
      case MealType.snack:
        return "Snack";
    }
  }
}