import 'package:hive/hive.dart';

@HiveType(typeId: 0)
class FoodLog extends HiveObject {
  @HiveField(0) String name;
  @HiveField(1) double calories;
  @HiveField(2) double protein;
  @HiveField(3) double carbs;
  @HiveField(4) double fat;
  @HiveField(5) double quantity;
  @HiveField(6) String mealType;
  @HiveField(7) DateTime dateTime;
  @HiveField(8) String unit;

  FoodLog({
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.quantity,
    required this.mealType,
    required this.dateTime,
    this.unit = 'grams',
  });
}