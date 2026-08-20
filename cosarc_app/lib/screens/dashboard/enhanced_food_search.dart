import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cosarc/models/food_log.dart';
import 'package:cosarc/services/enhanced_nutrition_service.dart';
import 'package:cosarc/services/daily_contract_service.dart';
import 'package:cosarc/core/theme/cosarc_colors.dart';
import 'package:cosarc/widgets/cosarc/cosarc_button.dart';

/// ======================================================
/// ENHANCED FOOD SEARCH UI
/// Professional Search Experience
/// ======================================================
class EnhancedFoodSearchSheet extends StatefulWidget {
  final String mealType;

  const EnhancedFoodSearchSheet({
    super.key,
    required this.mealType,
  });

  @override
  State<EnhancedFoodSearchSheet> createState() =>
      _EnhancedFoodSearchSheetState();
}

class _EnhancedFoodSearchSheetState extends State<EnhancedFoodSearchSheet>
    with SingleTickerProviderStateMixin {
  final NutritionServiceV2 _service = NutritionServiceV2();
  final DailyContractService _contractService = DailyContractService();
  final TextEditingController _searchCtrl = TextEditingController();
  final TextEditingController _qtyCtrl = TextEditingController(text: "1");

  List<Map<String, dynamic>> _results = [];
  bool _loading = false;
  Timer? _debounce;
  String _selectedUnit = 'servings';
  final List<String> _units = ['grams', 'ml', 'servings', 'tsp', 'tbsp'];

  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    _qtyCtrl.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (query.trim().isEmpty || query.length < 2) {
        setState(() {
          _results = [];
          _loading = false;
        });
        return;
      }

      setState(() => _loading = true);

      try {
        final results = await _service.searchFood(query);
        if (mounted) {
          setState(() {
            _results = results;
            _loading = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _loading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Search failed. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            cosarcCard,
            cosarcDark,
          ],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          _buildDragHandle(),
          _buildHeader(),
          _buildSearchBar(),
          _buildQuantitySelector(),
          _buildSearchResults(),
        ],
      ),
    ));
  }

  /// ======================================================
  /// DRAG HANDLE
  /// ======================================================
  Widget _buildDragHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 8),
      width: 50,
      height: 5,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  /// ======================================================
  /// HEADER SECTION
  /// ======================================================
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "ADD TO ${widget.mealType.toUpperCase()}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Search from 100,000+ foods",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white38,
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.close_rounded,
              color: Colors.white54,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  /// ======================================================
  /// SEARCH BAR
  /// ======================================================
  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: cosarcSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _searchCtrl.text.isNotEmpty
              ? CosarcColors.primary.withOpacity(0.3)
              : Colors.white.withOpacity(0.05),
          width: 2,
        ),
        boxShadow: _searchCtrl.text.isNotEmpty
            ? [
                BoxShadow(
                  color: CosarcColors.primary.withOpacity(0.1),
                  blurRadius: 15,
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          const Icon(
            Icons.search_rounded,
            color: CosarcColors.primary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchCtrl,
              autofocus: true,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              decoration: const InputDecoration(
                hintText: "burger, chicken, dal, maggi...",
                hintStyle: TextStyle(
                  color: Colors.white24,
                  fontSize: 15,
                ),
                border: InputBorder.none,
              ),
              onChanged: _onSearch,
            ),
          ),
          if (_searchCtrl.text.isNotEmpty)
            IconButton(
              onPressed: () {
                _searchCtrl.clear();
                setState(() {
                  _results = [];
                });
              },
              icon: const Icon(
                Icons.clear_rounded,
                color: Colors.white38,
                size: 20,
              ),
            ),
        ],
      ),
    );
  }

  /// ======================================================
  /// QUANTITY SELECTOR
  /// ======================================================
  Widget _buildQuantitySelector() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cosarcSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
        ),
      ),
      child: Row(
        children: [
          // Quantity Input
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "QUANTITY",
                  style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 2,
                    color: Colors.white38,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _qtyCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d{0,2}')),
                    ],
                    style: const TextStyle(
                      color: cosarcAccent,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "0",
                      hintStyle: TextStyle(
                        color: Colors.white12,
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // Unit Selector
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "UNIT",
                  style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 2,
                    color: Colors.white38,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: CosarcColors.primary.withOpacity(0.2),
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedUnit,
                      isExpanded: true,
                      dropdownColor: cosarcCard,
                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: CosarcColors.primary,
                      ),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                      items: _units.map((unit) {
                        return DropdownMenuItem(
                          value: unit,
                          child: Text(unit),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedUnit = value!;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ======================================================
  /// SEARCH RESULTS LIST
  /// ======================================================
  Widget _buildSearchResults() {
    if (_loading) {
      return const Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: CosarcColors.primary,
                strokeWidth: 3,
              ),
              SizedBox(height: 16),
              Text(
                "Searching databases...",
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_searchCtrl.text.isEmpty) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.restaurant_menu_rounded,
                size: 80,
                color: Colors.white.withOpacity(0.1),
              ),
              const SizedBox(height: 16),
              const Text(
                "Start typing to search",
                style: TextStyle(
                  color: Colors.white24,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Indian brands, fast food, and 100k+ items",
                style: TextStyle(
                  color: Colors.white12,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_results.isEmpty && !_loading) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 80,
                color: Colors.white.withOpacity(0.1),
              ),
              const SizedBox(height: 16),
              const Text(
                "No results found",
                style: TextStyle(
                  color: Colors.white24,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Try a different search term",
                style: TextStyle(
                  color: Colors.white12,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        itemCount: _results.length,
        itemBuilder: (context, index) {
          return _buildFoodResultCard(_results[index]);
        },
      ),
    );
  }

  /// ======================================================
  /// FOOD RESULT CARD
  /// ======================================================
  Widget _buildFoodResultCard(Map<String, dynamic> food) {
    final qty = double.tryParse(_qtyCtrl.text) ?? 1.0;
    final servingWeight = food['servingWeight'] as double;

    // Calculate scaling factor based on unit
    double factor = 1.0;
    if (_selectedUnit == 'servings') {
      factor = (qty * servingWeight) / 100;
    } else if (_selectedUnit == 'grams' || _selectedUnit == 'ml') {
      factor = qty / 100;
    } else if (_selectedUnit == 'tsp') {
      factor = (qty * 5) / 100;
    } else if (_selectedUnit == 'tbsp') {
      factor = (qty * 15) / 100;
    }

    final scaledCal = (food['calories'] as double) * factor;
    final scaledProtein = (food['protein'] as double) * factor;
    final scaledCarbs = (food['carbs'] as double) * factor;
    final scaledFat = (food['fat'] as double) * factor;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cosarcSurface,
            cosarcCard.withOpacity(0.5),
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
          onTap: () => _showDetailAndAdd(food, factor),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Food Type Badge
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: _getTypeColor(food['type']).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: _getTypeColor(food['type']).withOpacity(0.3),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _getTypeEmoji(food['type']),
                      style: const TextStyle(fontSize: 30),
                    ),
                  ),
                ),

                const SizedBox(width: 15),

                // Food Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        food['name'],
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "${food['brand']} • ${food['type']}",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white38,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildMiniMacro(
                              "P", scaledProtein.toInt(), const Color(0xFF2196F3)),
                          const SizedBox(width: 10),
                          _buildMiniMacro(
                              "C", scaledCarbs.toInt(), const Color(0xFFFF9800)),
                          const SizedBox(width: 10),
                          _buildMiniMacro(
                              "F", scaledFat.toInt(), const Color(0xFF9C27B0)),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // Add Button + Calories
                Column(
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _addFood(food, factor),
                        borderRadius: BorderRadius.circular(15),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                CosarcColors.primary,
                                CosarcColors.primary.withOpacity(0.7)
                              ],
                            ),
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: CosarcColors.primary.withOpacity(0.3),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.add_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "${scaledCal.toInt()}",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: cosarcAccent,
                      ),
                    ),
                    const Text(
                      "kcal",
                      style: TextStyle(
                        fontSize: 9,
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
    );
  }

  Widget _buildMiniMacro(String label, int value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        "$label $value",
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'packaged':
        return const Color(0xFF2196F3);
      case 'fast food':
        return const Color(0xFFFF5722);
      case 'traditional':
        return const Color(0xFF4CAF50);
      case 'dairy':
        return const Color(0xFFFFEB3B);
      case 'restaurant':
        return const Color(0xFF9C27B0);
      default:
        return Colors.grey;
    }
  }

  String _getTypeEmoji(String type) {
    switch (type.toLowerCase()) {
      case 'packaged':
        return '📦';
      case 'fast food':
        return '🍔';
      case 'traditional':
        return '🍛';
      case 'dairy':
        return '🥛';
      case 'restaurant':
        return '🍽️';
      case 'dessert':
        return '🍰';
      case 'beverage':
        return '🥤';
      default:
        return '🍴';
    }
  }

  /// ======================================================
  /// SHOW DETAIL AND ADD
  /// ======================================================
  void _showDetailAndAdd(Map<String, dynamic> food, double factor) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [cosarcCard, cosarcSurface],
            ),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "NUTRITIONAL BREAKDOWN",
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 3,
                  color: Colors.white38,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                food['name'],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                food['brand'],
                style: const TextStyle(
                  fontSize: 13,
                  color: CosarcColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 30),
              _buildDetailMacro(
                  "Energy",
                  "${(food['calories'] * factor).toInt()} kcal",
                  CosarcColors.primary),
              _buildDetailMacro("Protein",
                  "${(food['protein'] * factor).toInt()} g", const Color(0xFF2196F3)),
              _buildDetailMacro("Carbs",
                  "${(food['carbs'] * factor).toInt()} g", const Color(0xFFFF9800)),
              _buildDetailMacro("Fat", "${(food['fat'] * factor).toInt()} g",
                  const Color(0xFF9C27B0)),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "CANCEL",
                      style: TextStyle(
                        color: Colors.white38,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  CosarcButton(
                    label: "ADD TO LOG",
                    expand: false,
                    onPressed: () {
                      Navigator.pop(context);
                      _addFood(food, factor);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailMacro(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 15,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  /// ======================================================
  /// ADD FOOD TO LOG
  /// ======================================================
  void _addFood(Map<String, dynamic> food, double factor) {
    final qty = double.tryParse(_qtyCtrl.text) ?? 1.0;

    final log = FoodLog(
      name: "${food['name']}",
      calories: (food['calories'] as double) * factor,
      protein: (food['protein'] as double) * factor,
      carbs: (food['carbs'] as double) * factor,
      fat: (food['fat'] as double) * factor,
      quantity: qty,
      mealType: widget.mealType,
      dateTime: DateTime.now(),
      unit: _selectedUnit,
    );

    Hive.box<FoodLog>('daily_logs').add(log);

    _contractService.markNutritionLogged();

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added to ${widget.mealType}!'),
        backgroundColor: cosarcAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
