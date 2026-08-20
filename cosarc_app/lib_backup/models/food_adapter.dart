import 'package:hive/hive.dart';
import 'food_log.dart';

class FoodLogAdapter extends TypeAdapter<FoodLog> {
  @override
  final int typeId = 0;

  @override
  FoodLog read(BinaryReader reader) {
    return FoodLog(
      name: reader.readString(),
      calories: reader.readDouble(),
      protein: reader.readDouble(),
      carbs: reader.readDouble(),
      fat: reader.readDouble(),
      quantity: reader.readDouble(),
      mealType: reader.readString(),
      dateTime: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      unit: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, FoodLog obj) {
    writer.writeString(obj.name);
    writer.writeDouble(obj.calories);
    writer.writeDouble(obj.protein);
    writer.writeDouble(obj.carbs);
    writer.writeDouble(obj.fat);
    writer.writeDouble(obj.quantity);
    writer.writeString(obj.mealType);
    writer.writeInt(obj.dateTime.millisecondsSinceEpoch);
    writer.writeString(obj.unit);
  }
}