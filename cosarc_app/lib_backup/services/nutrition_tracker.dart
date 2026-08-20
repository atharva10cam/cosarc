import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:cosarc/models/food_log.dart';

// Cinematic Professional Palette
const Color cosarcPink = Color(0xFFE91E63);
const Color cosarcDark = Color(0xFF080808);
const Color cosarcSurface = Color(0xFF141414);
const Color cosarcAccent = Color(0xFF00E676);

/// ======================================================
/// 1. APEX NUTRITION SERVICE (OFF + USDA + Indian Dataset)
/// ======================================================
class NutritionService {
  final String _usdaKey = 'DEMO_KEY'; // Replace with a free key for higher limits

  Future<List<Map<String, dynamic>>> searchFood(String query) async {
    final q = query.trim().toLowerCase();
    if (q.length < 2) return [];

    // Parallel fetch from all professional datasets
    final results = await Future.wait([
      _fetchOFF(q),
      _fetchUSDA(q),
    ]);

    List<Map<String, dynamic>> combined = results.expand((x) => x).toList();

    // 🏆 MEAL-FIRST RANKING ALGORITHM
    combined.sort((a, b) {
      final mealKeywords = ['burger', 'pizza', 'sandwich', 'meal', 'platter', 'thali', 'roll'];
      bool aIsMeal = mealKeywords.any((k) => a['name'].toString().toLowerCase().contains(k));
      bool bIsMeal = mealKeywords.any((k) => b['name'].toString().toLowerCase().contains(k));
      
      if (aIsMeal && !bIsMeal) return -1;
      if (!aIsMeal && bIsMeal) return 1;
      return 0;
    });

    return combined;
  }

  Future<List<Map<String, dynamic>>> _fetchOFF(String query) async {
    try {
      final url = Uri.parse('https://world.openfoodfacts.org/cgi/search.pl?search_terms=$query&search_simple=1&action=process&json=1&page_size=30&cc=in');
      final res = await http.get(url).timeout(const Duration(seconds: 5));
      if (res.statusCode != 200) return [];
      final products = json.decode(res.body)['products'] as List;
      return products.map((p) {
        final n = p['nutriments'] ?? {};
        return {
          'name': p['product_name'] ?? 'Unknown',
          'brand': p['brands'] ?? 'Retail Brand',
          'calories': _num(n['energy-kcal_100g']),
          'protein': _num(n['proteins_100g']),
          'carbs': _num(n['carbohydrates_100g']),
          'fat': _num(n['fat_100g']),
          'servingWeight': _num(p['serving_quantity']) > 0 ? _num(p['serving_quantity']) : 100.0,
          'type': 'Packaged',
        };
      }).where((i) => i['calories'] > 0).toList();
    } catch (_) { return []; }
  }

  Future<List<Map<String, dynamic>>> _fetchUSDA(String query) async {
    try {
      final url = Uri.parse('https://api.nal.usda.gov/fdc/v1/foods/search?query=$query&pageSize=20&api_key=$_usdaKey');
      final res = await http.get(url).timeout(const Duration(seconds: 5));
      if (res.statusCode != 200) return [];
      final foods = json.decode(res.body)['foods'] as List;
      return foods.map((f) {
        final nuts = f['foodNutrients'] as List;
        return {
          'name': f['description'] ?? 'Unknown',
          'brand': f['brandOwner'] ?? 'Generic/Scientific',
          'calories': _findUSDA(nuts, 1008),
          'protein': _findUSDA(nuts, 1003),
          'carbs': _findUSDA(nuts, 1005),
          'fat': _findUSDA(nuts, 1004),
          'servingWeight': 100.0,
          'type': 'Scientific/Shop',
        };
      }).toList();
    } catch (_) { return []; }
  }

  double _findUSDA(List nuts, int id) {
    final n = nuts.firstWhere((e) => e['nutrientId'] == id, orElse: () => null);
    return n != null ? (n['value'] as num).toDouble() : 0.0;
  }

  double _num(dynamic v) => (v is num) ? v.toDouble() : (double.tryParse(v?.toString() ?? "0") ?? 0.0);
}

/// ======================================================
/// 2. MAIN FUEL LOG SCREEN
/// ======================================================
class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});
  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  final double dailyTarget = 2500;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cosarcDark,
      appBar: AppBar(
        title: const Text('FUEL LOG', style: TextStyle(letterSpacing: 4, fontWeight: FontWeight.w900, fontSize: 13)),
        centerTitle: true, backgroundColor: Colors.transparent,
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<FoodLog>('daily_logs').listenable(),
        builder: (context, Box<FoodLog> box, _) {
          final now = DateTime.now();
          final logs = box.values.where((l) => l.dateTime.day == now.day && l.dateTime.month == now.month).toList();

          double tCal = logs.fold(0, (s, i) => s + i.calories);
          double tP = logs.fold(0, (s, i) => s + i.protein);
          double tC = logs.fold(0, (s, i) => s + i.carbs);
          double tF = logs.fold(0, (s, i) => s + i.fat);

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _buildHeader(tCal, tP, tC, tF)),
              _mealGroup("Breakfast", logs.where((l) => l.mealType == "Breakfast").toList()),
              _mealGroup("Lunch", logs.where((l) => l.mealType == "Lunch").toList()),
              _mealGroup("Dinner", logs.where((l) => l.mealType == "Dinner").toList()),
              _mealGroup("Snacks", logs.where((l) => l.mealType == "Snack").toList()),
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(double c, double p, double carb, double f) {
    double rem = dailyTarget - c;
    return Container(
      margin: const EdgeInsets.all(20), padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: cosarcSurface, borderRadius: BorderRadius.circular(35), border: Border.all(color: Colors.white.withOpacity(0.05))),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          _statCol("REMAINING", rem < 0 ? "0" : rem.toInt().toString(), cosarcAccent),
          _statCol("CONSUMED", c.toInt().toString(), cosarcPink),
        ]),
        const SizedBox(height: 25),
        ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(value: (c/dailyTarget).clamp(0,1), minHeight: 12, backgroundColor: Colors.white10, color: cosarcPink)),
        const SizedBox(height: 25),
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          _miniStat("P", p, Colors.blue), _miniStat("C", carb, Colors.orange), _miniStat("F", f, Colors.purple),
        ])
      ]),
    );
  }

  Widget _statCol(String l, String v, Color col) => Column(children: [
    Text(l, style: const TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 2)),
    Text(v, style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: col)),
  ]);

  Widget _miniStat(String l, double v, Color col) => Row(children: [
    Text("$l: ", style: const TextStyle(color: Colors.white24, fontSize: 11)),
    Text("${v.toInt()}g", style: TextStyle(color: col, fontWeight: FontWeight.bold, fontSize: 14)),
  ]);

  Widget _mealGroup(String name, List<FoodLog> logs) {
    double total = logs.fold(0, (s, i) => s + i.calories);
    return SliverMainAxisGroup(slivers: [
      SliverToBoxAdapter(child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 10),
        child: Row(children: [
          Expanded(child: Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
          Text("${total.toInt()} kcal", style: const TextStyle(color: Colors.white38, fontSize: 14)),
          const SizedBox(width: 12),
          IconButton(onPressed: () => _openSearch(context, name), icon: const Icon(Icons.add_circle_rounded, color: cosarcAccent, size: 32)),
        ]),
      )),
      SliverList(delegate: SliverChildBuilderDelegate((_, i) => _foodTile(logs[i]), childCount: logs.length)),
    ]);
  }

  Widget _foodTile(FoodLog log) => Dismissible(
    key: Key(log.dateTime.toString()),
    onDismissed: (_) => log.delete(),
    direction: DismissDirection.endToStart,
    background: Container(color: Colors.redAccent.withOpacity(0.1), alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), child: const Icon(Icons.delete_forever, color: Colors.redAccent)),
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 2), padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), borderRadius: BorderRadius.circular(20)),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(log.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
          Text("${log.quantity.toInt()} ${log.unit} • P: ${log.protein.toInt()}g", style: const TextStyle(color: Colors.white24, fontSize: 11)),
        ])),
        Text("${log.calories.toInt()}", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.white)),
      ]),
    ),
  );

  void _openSearch(BuildContext ctx, String m) => showModalBottomSheet(context: ctx, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (_) => FoodSearchComponent(preSelectedMeal: m));
}

/// ======================================================
/// 3. SMART SEARCH UI (Click Info + Plus Add)
/// ======================================================
class FoodSearchComponent extends StatefulWidget {
  final String preSelectedMeal;
  const FoodSearchComponent({super.key, required this.preSelectedMeal});
  @override
  State<FoodSearchComponent> createState() => _FoodSearchComponentState();
}

class _FoodSearchComponentState extends State<FoodSearchComponent> {
  final NutritionService _service = NutritionService();
  final TextEditingController _searchCtrl = TextEditingController();
  final TextEditingController _qtyCtrl = TextEditingController(text: "1");
  
  List<Map<String, dynamic>> _results = [];
  bool _loading = false;
  Timer? _debounce;
  String selectedUnit = 'servings';
  final List<String> _units = ['grams', 'ml', 'servings', 'tsp', 'tbsp'];

  void _onSearch(String q) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (q.length < 2) return;
      setState(() => _loading = true);
      final data = await _service.searchFood(q);
      if (mounted) setState(() { _results = data; _loading = false; });
    });
  }

  @override
  Widget build(BuildContext context) {
    double qty = double.tryParse(_qtyCtrl.text) ?? 1.0;
    return Container(
      decoration: const BoxDecoration(color: Color(0xFF0A0A0A), borderRadius: BorderRadius.vertical(top: Radius.circular(40))),
      height: MediaQuery.of(context).size.height * 0.9,
      child: Column(children: [
        const SizedBox(height: 15),
        Container(width: 45, height: 5, decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(10))),
        Padding(padding: const EdgeInsets.all(24), child: TextField(
          controller: _searchCtrl, onChanged: _onSearch, autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Search Shop or Brands...", 
            prefixIcon: const Icon(Icons.search, color: cosarcPink), 
            filled: true, fillColor: Colors.white.withOpacity(0.04), 
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none)
          ),
        )),
        
        Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: Row(children: [
          Expanded(child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(20)),
            child: TextField(
              controller: _qtyCtrl, keyboardType: const TextInputType.numberWithOptions(decimal: true), 
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
              style: const TextStyle(color: cosarcAccent, fontWeight: FontWeight.bold, fontSize: 24), 
              decoration: const InputDecoration(border: InputBorder.none, hintText: "Qty"), onChanged: (_) => setState((){}),
            ),
          )),
          const SizedBox(width: 15),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(border: Border.all(color: Colors.white10), borderRadius: BorderRadius.circular(20)),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedUnit, dropdownColor: cosarcSurface, icon: const Icon(Icons.unfold_more, color: cosarcPink, size: 20),
                items: _units.map((u) => DropdownMenuItem(value: u, child: Text(u, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))).toList(),
                onChanged: (v) => setState(() => selectedUnit = v!),
              ),
            ),
          ),
        ])),

        if (_loading) const Padding(padding: EdgeInsets.all(30), child: CircularProgressIndicator(color: cosarcPink, strokeWidth: 3)),
        
        Expanded(child: ListView.builder(
          itemCount: _results.length, padding: const EdgeInsets.all(20),
          itemBuilder: (_, i) {
            final item = _results[i];
            double base = item['servingWeight'];
            double factor = 1.0;

            if (selectedUnit == 'servings') factor = (qty * base) / 100;
            else if (selectedUnit == 'grams' || selectedUnit == 'ml') factor = qty / 100;
            else if (selectedUnit == 'tsp') factor = (qty * 5) / 100;
            else if (selectedUnit == 'tbsp') factor = (qty * 15) / 100;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.02), borderRadius: BorderRadius.circular(25), border: Border.all(color: Colors.white.withOpacity(0.01))),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                title: Text(item['name'], style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                subtitle: Text("${item['brand']} • 1 Serv ≈ ${base.toInt()}g", style: const TextStyle(color: Colors.white38, fontSize: 12)),
                trailing: IconButton(
                  icon: const Icon(Icons.add_circle, color: cosarcPink, size: 34),
                  onPressed: () {
                    Hive.box<FoodLog>('daily_logs').add(FoodLog(
                      name: "${item['name']} (${item['brand']})", 
                      calories: item['calories'] * factor, protein: item['protein'] * factor,
                      carbs: item['carbs'] * factor, fat: item['fat'] * factor,
                      quantity: qty, mealType: widget.preSelectedMeal, dateTime: DateTime.now(), unit: selectedUnit,
                    ));
                    Navigator.pop(context);
                  },
                ),
                onTap: () => _showDetail(item, factor), // 👈 Tap card for details
              ),
            );
          },
        )),
      ]),
    );
  }

  void _showDetail(Map item, double f) {
    showDialog(context: context, builder: (_) => AlertDialog(
      backgroundColor: cosarcSurface, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      title: Text("Nutritional Intelligence", style: TextStyle(color: Colors.white54, fontSize: 12, letterSpacing: 2)),
      content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(item['name'], style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        _detailRow("Energy", "${(item['calories'] * f).toInt()} kcal", cosarcPink),
        _detailRow("Protein", "${(item['protein'] * f).toStringAsFixed(1)} g", Colors.blueAccent),
        _detailRow("Carbs", "${(item['carbs'] * f).toStringAsFixed(1)} g", Colors.orangeAccent),
        _detailRow("Fat", "${(item['fat'] * f).toStringAsFixed(1)} g", Colors.purpleAccent),
      ]),
    ));
  }

  Widget _detailRow(String l, String v, Color c) => Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(l, style: const TextStyle(color: Colors.white54)), Text(v, style: TextStyle(color: c, fontWeight: FontWeight.bold, fontSize: 18))]));
}