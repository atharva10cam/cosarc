import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../core/config/app_config.dart';

class IndianFoodDatabase {
  // Multiple API endpoints for comprehensive coverage
  static const String usdaApiKey = AppConfig.usdaApiKey;
  static const String usdaBaseUrl = 'https://api.nal.usda.gov/fdc/v1';
  static const String openFoodFactsUrl =
      'https://world.openfoodfacts.org/cgi/search.pl';
  static const String nutritionixAppId = AppConfig.nutritionixAppId;
  static const String nutritionixAppKey = AppConfig.nutritionixAppKey;

  // Extensive local Indian food database
  static final Map<String, Map<String, dynamic>> localIndianFoods = {
    // Fruits
    'apple': {
      'name': 'Apple',
      'calories': 52,
      'protein': 0.3,
      'carbs': 14,
      'fat': 0.2,
      'per': '100g'
    },
    'banana': {
      'name': 'Banana',
      'calories': 89,
      'protein': 1.1,
      'carbs': 23,
      'fat': 0.3,
      'per': '100g'
    },
    'mango': {
      'name': 'Mango',
      'calories': 60,
      'protein': 0.8,
      'carbs': 15,
      'fat': 0.4,
      'per': '100g'
    },
    'orange': {
      'name': 'Orange',
      'calories': 47,
      'protein': 0.9,
      'carbs': 12,
      'fat': 0.1,
      'per': '100g'
    },
    'papaya': {
      'name': 'Papaya',
      'calories': 43,
      'protein': 0.5,
      'carbs': 11,
      'fat': 0.3,
      'per': '100g'
    },
    'guava': {
      'name': 'Guava',
      'calories': 68,
      'protein': 2.6,
      'carbs': 14,
      'fat': 1,
      'per': '100g'
    },

    // Indian Staples
    'rice cooked': {
      'name': 'Cooked White Rice',
      'calories': 130,
      'protein': 2.7,
      'carbs': 28,
      'fat': 0.3,
      'per': '100g'
    },
    'rice uncooked': {
      'name': 'Uncooked White Rice',
      'calories': 365,
      'protein': 7.1,
      'carbs': 80,
      'fat': 0.7,
      'per': '100g'
    },
    'brown rice cooked': {
      'name': 'Cooked Brown Rice',
      'calories': 111,
      'protein': 2.6,
      'carbs': 23,
      'fat': 0.9,
      'per': '100g'
    },
    'basmati rice': {
      'name': 'Basmati Rice (cooked)',
      'calories': 121,
      'protein': 3,
      'carbs': 25,
      'fat': 0.4,
      'per': '100g'
    },
    'wheat chapati': {
      'name': 'Wheat Chapati',
      'calories': 120,
      'protein': 3.5,
      'carbs': 18,
      'fat': 3.7,
      'per': '1 piece'
    },
    'roti': {
      'name': 'Roti (Plain)',
      'calories': 106,
      'protein': 3.5,
      'carbs': 18,
      'fat': 2,
      'per': '1 piece'
    },
    'paratha': {
      'name': 'Paratha',
      'calories': 250,
      'protein': 5,
      'carbs': 28,
      'fat': 13,
      'per': '1 piece'
    },
    'naan': {
      'name': 'Naan Bread',
      'calories': 262,
      'protein': 7.6,
      'carbs': 45,
      'fat': 5.1,
      'per': '1 piece'
    },
    'puri': {
      'name': 'Puri',
      'calories': 156,
      'protein': 3,
      'carbs': 16,
      'fat': 9,
      'per': '1 piece'
    },

    // Dals & Lentils
    'toor dal': {
      'name': 'Toor Dal (cooked)',
      'calories': 118,
      'protein': 7,
      'carbs': 20,
      'fat': 0.7,
      'per': '100g'
    },
    'moong dal': {
      'name': 'Moong Dal (cooked)',
      'calories': 105,
      'protein': 7.6,
      'carbs': 19,
      'fat': 0.4,
      'per': '100g'
    },
    'masoor dal': {
      'name': 'Masoor Dal (cooked)',
      'calories': 116,
      'protein': 9,
      'carbs': 20,
      'fat': 0.4,
      'per': '100g'
    },
    'chana dal': {
      'name': 'Chana Dal (cooked)',
      'calories': 120,
      'protein': 8.9,
      'carbs': 21,
      'fat': 0.6,
      'per': '100g'
    },
    'urad dal': {
      'name': 'Urad Dal (cooked)',
      'calories': 105,
      'protein': 7.7,
      'carbs': 18,
      'fat': 0.5,
      'per': '100g'
    },
    'rajma': {
      'name': 'Rajma (Kidney Beans)',
      'calories': 127,
      'protein': 8.7,
      'carbs': 23,
      'fat': 0.5,
      'per': '100g'
    },
    'chole': {
      'name': 'Chole (Chickpeas)',
      'calories': 164,
      'protein': 8.9,
      'carbs': 27,
      'fat': 2.6,
      'per': '100g'
    },

    // Popular Indian Dishes
    'biryani': {
      'name': 'Chicken Biryani',
      'calories': 290,
      'protein': 12,
      'carbs': 38,
      'fat': 10,
      'per': '1 plate'
    },
    'veg biryani': {
      'name': 'Veg Biryani',
      'calories': 250,
      'protein': 5,
      'carbs': 45,
      'fat': 6,
      'per': '1 plate'
    },
    'dosa': {
      'name': 'Plain Dosa',
      'calories': 168,
      'protein': 4,
      'carbs': 30,
      'fat': 4,
      'per': '1 piece'
    },
    'masala dosa': {
      'name': 'Masala Dosa',
      'calories': 250,
      'protein': 5,
      'carbs': 38,
      'fat': 8,
      'per': '1 piece'
    },
    'idli': {
      'name': 'Idli',
      'calories': 58,
      'protein': 2,
      'carbs': 11,
      'fat': 0.5,
      'per': '1 piece'
    },
    'vada': {
      'name': 'Medu Vada',
      'calories': 145,
      'protein': 3.5,
      'carbs': 16,
      'fat': 7,
      'per': '1 piece'
    },
    'sambar': {
      'name': 'Sambar',
      'calories': 90,
      'protein': 4,
      'carbs': 15,
      'fat': 2,
      'per': '1 bowl'
    },
    'poha': {
      'name': 'Poha',
      'calories': 250,
      'protein': 4,
      'carbs': 45,
      'fat': 6,
      'per': '1 plate'
    },
    'upma': {
      'name': 'Upma',
      'calories': 190,
      'protein': 4,
      'carbs': 33,
      'fat': 5,
      'per': '1 bowl'
    },

    // Protein Sources
    'chicken breast': {
      'name': 'Chicken Breast (cooked)',
      'calories': 165,
      'protein': 31,
      'carbs': 0,
      'fat': 3.6,
      'per': '100g'
    },
    'chicken curry': {
      'name': 'Chicken Curry',
      'calories': 180,
      'protein': 18,
      'carbs': 7,
      'fat': 9,
      'per': '100g'
    },
    'egg boiled': {
      'name': 'Boiled Egg',
      'calories': 155,
      'protein': 13,
      'carbs': 1.1,
      'fat': 11,
      'per': '1 large egg'
    },
    'egg omelette': {
      'name': 'Egg Omelette',
      'calories': 154,
      'protein': 11,
      'carbs': 1,
      'fat': 12,
      'per': '2 eggs'
    },
    'paneer': {
      'name': 'Paneer (Indian Cottage Cheese)',
      'calories': 265,
      'protein': 18,
      'carbs': 1.2,
      'fat': 20,
      'per': '100g'
    },
    'fish': {
      'name': 'Fish (cooked)',
      'calories': 206,
      'protein': 22,
      'carbs': 0,
      'fat': 12,
      'per': '100g'
    },
    'mutton': {
      'name': 'Mutton (cooked)',
      'calories': 294,
      'protein': 25,
      'carbs': 0,
      'fat': 21,
      'per': '100g'
    },

    // Sprouted & Others
    'matki': {
      'name': 'Matki (Moth Beans)',
      'calories': 343,
      'protein': 23,
      'carbs': 61,
      'fat': 1.6,
      'per': '100g'
    },
    'moong sprouts': {
      'name': 'Moong Sprouts',
      'calories': 30,
      'protein': 3,
      'carbs': 6,
      'fat': 0.2,
      'per': '100g'
    },

    // Indian Brands - Amul
    'amul milk': {
      'name': 'Amul Taza Milk',
      'calories': 66,
      'protein': 3.2,
      'carbs': 5,
      'fat': 3.5,
      'per': '100ml'
    },
    'amul gold milk': {
      'name': 'Amul Gold Milk',
      'calories': 70,
      'protein': 3.1,
      'carbs': 4.9,
      'fat': 4.5,
      'per': '100ml'
    },
    'amul curd': {
      'name': 'Amul Curd',
      'calories': 60,
      'protein': 3.1,
      'carbs': 4.4,
      'fat': 3.5,
      'per': '100g'
    },
    'amul paneer': {
      'name': 'Amul Paneer',
      'calories': 296,
      'protein': 18.3,
      'carbs': 6.3,
      'fat': 22,
      'per': '100g'
    },
    'amul cheese': {
      'name': 'Amul Cheese Slice',
      'calories': 337,
      'protein': 20,
      'carbs': 4,
      'fat': 26,
      'per': '100g'
    },
    'amul butter': {
      'name': 'Amul Butter',
      'calories': 717,
      'protein': 0.5,
      'carbs': 0.5,
      'fat': 81,
      'per': '100g'
    },

    // Nutrela
    'nutrela soya': {
      'name': 'Nutrela Soya Chunks',
      'calories': 345,
      'protein': 52,
      'carbs': 33,
      'fat': 0.5,
      'per': '100g'
    },

    // Max Protein
    'max protein spread': {
      'name': 'Max Protein Peanut Butter',
      'calories': 549,
      'protein': 30,
      'carbs': 15,
      'fat': 40,
      'per': '100g'
    },

    // Desi Farms
    'desi farms eggs': {
      'name': 'Desi Farms Free Range Eggs',
      'calories': 143,
      'protein': 12.6,
      'carbs': 0.72,
      'fat': 9.5,
      'per': '1 egg'
    },

    // Cadbury
    'cadbury dairy milk': {
      'name': 'Cadbury Dairy Milk',
      'calories': 534,
      'protein': 7.3,
      'carbs': 59,
      'fat': 30,
      'per': '100g'
    },

    // Common Snacks
    'samosa': {
      'name': 'Samosa',
      'calories': 252,
      'protein': 5,
      'carbs': 28,
      'fat': 13,
      'per': '1 piece'
    },
    'pakora': {
      'name': 'Pakora/Bhaji',
      'calories': 150,
      'protein': 3,
      'carbs': 15,
      'fat': 8,
      'per': '100g'
    },
    'kachori': {
      'name': 'Kachori',
      'calories': 280,
      'protein': 5,
      'carbs': 32,
      'fat': 15,
      'per': '1 piece'
    },
  };

  // Search function that prioritizes Indian foods
  static Future<List<Map<String, dynamic>>> searchFood(String query) async {
    List<Map<String, dynamic>> results = [];
    final lowerQuery = query.toLowerCase().trim();

    // 1. First search local Indian database
    localIndianFoods.forEach((key, value) {
      if (key.contains(lowerQuery) ||
          value['name'].toLowerCase().contains(lowerQuery)) {
        results.add({
          'name': value['name'],
          'calories': value['calories'],
          'protein': value['protein'],
          'carbs': value['carbs'],
          'fat': value['fat'],
          'serving': value['per'],
          'source': 'Indian Database',
        });
      }
    });

    // 2. If local results < 5, search external APIs
    if (results.length < 5) {
      try {
        // Search OpenFoodFacts (good for Indian branded products)
        final offResults = await _searchOpenFoodFacts(query);
        results.addAll(offResults);

        // Search USDA (comprehensive food database)
        if (results.length < 10) {
          final usdaResults = await _searchUSDA(query);
          results.addAll(usdaResults);
        }
      } catch (e) {
        debugPrint('Nutrition API search failed: $e');
      }
    }

    // Remove duplicates and limit to 20 results
    final uniqueResults = <String, Map<String, dynamic>>{};
    for (var result in results) {
      final key = result['name'].toLowerCase();
      if (!uniqueResults.containsKey(key)) {
        uniqueResults[key] = result;
      }
    }

    return uniqueResults.values.take(20).toList();
  }

  static Future<List<Map<String, dynamic>>> _searchOpenFoodFacts(
      String query) async {
    try {
      final url = Uri.parse(
          '$openFoodFactsUrl?search_terms=$query&search_simple=1&json=1&page_size=10');
      final response = await http.get(url).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final products = data['products'] as List? ?? [];

        return products.map<Map<String, dynamic>>((product) {
          final nutriments = product['nutriments'] ?? {};
          return {
            'name': product['product_name'] ?? 'Unknown',
            'calories': (nutriments['energy-kcal_100g'] ?? 0).toDouble(),
            'protein': (nutriments['proteins_100g'] ?? 0).toDouble(),
            'carbs': (nutriments['carbohydrates_100g'] ?? 0).toDouble(),
            'fat': (nutriments['fat_100g'] ?? 0).toDouble(),
            'serving': '100g',
            'source': 'OpenFoodFacts',
            'brand': product['brands'] ?? '',
          };
        }).toList();
      }
    } catch (e) {
      debugPrint('OpenFoodFacts search failed: $e');
    }
    return [];
  }

  static Future<List<Map<String, dynamic>>> _searchUSDA(String query) async {
    try {
      final url = Uri.parse(
          '$usdaBaseUrl/foods/search?api_key=$usdaApiKey&query=$query&pageSize=10');
      final response = await http.get(url).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final foods = data['foods'] as List? ?? [];

        return foods.map<Map<String, dynamic>>((food) {
          final nutrients = food['foodNutrients'] as List? ?? [];

          double getNutrient(int nutrientId) {
            try {
              final nutrient = nutrients.firstWhere(
                (n) => n['nutrientId'] == nutrientId,
                orElse: () => {'value': 0},
              );
              return (nutrient['value'] ?? 0).toDouble();
            } catch (e) {
              return 0;
            }
          }

          return {
            'name': food['description'] ?? 'Unknown',
            'calories': getNutrient(1008), // Energy
            'protein': getNutrient(1003), // Protein
            'carbs': getNutrient(1005), // Carbs
            'fat': getNutrient(1004), // Fat
            'serving': '100g',
            'source': 'USDA',
          };
        }).toList();
      }
    } catch (e) {
      debugPrint('USDA search failed: $e');
    }
    return [];
  }

  // Quick access for common Indian foods
  static List<Map<String, dynamic>> getCommonIndianFoods() {
    return [
      localIndianFoods['rice cooked']!,
      localIndianFoods['wheat chapati']!,
      localIndianFoods['chicken breast']!,
      localIndianFoods['egg boiled']!,
      localIndianFoods['paneer']!,
      localIndianFoods['toor dal']!,
      localIndianFoods['dosa']!,
      localIndianFoods['idli']!,
    ];
  }
}
