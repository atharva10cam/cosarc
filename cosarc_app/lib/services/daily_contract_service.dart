import 'package:flutter/foundation.dart';
import '../core/supabase_config.dart';
import 'auth_service.dart';

/// Syncs daily contract state between Hive (local nutrition) and Supabase.
class DailyContractService {
  DailyContractService({AuthService? authService})
      : _authService = authService ?? AuthService();

  final AuthService _authService;

  Future<String?> _memberId() => _authService.getMemberId();

  String _today() => DateTime.now().toIso8601String().split('T').first;

  Future<Map<String, dynamic>?> getTodayContract() async {
    final memberId = await _memberId();
    if (memberId == null) return null;

    final today = _today();
    var contract = await supabase
        .from('daily_contracts')
        .select()
        .eq('member_id', memberId)
        .eq('contract_date', today)
        .maybeSingle()
        .timeout(const Duration(seconds: 10));

    if (contract == null) {
      await supabase.from('daily_contracts').insert({
        'member_id': memberId,
        'contract_date': today,
      }).timeout(const Duration(seconds: 10));

      contract = await supabase
          .from('daily_contracts')
          .select()
          .eq('member_id', memberId)
          .eq('contract_date', today)
          .maybeSingle()
          .timeout(const Duration(seconds: 10));
    }

    return contract;
  }

  Future<void> markNutritionLogged() async {
    final memberId = await _memberId();
    if (memberId == null) return;

    final today = _today();
    try {
      await supabase
          .from('daily_contracts')
          .update({'nutrition_logged': true})
          .eq('member_id', memberId)
          .eq('contract_date', today)
          .timeout(const Duration(seconds: 10));
    } catch (e) {
      debugPrint('Failed to mark nutrition logged: $e');
    }
  }

  Future<void> addWater(int amountMl) async {
    final contract = await getTodayContract();
    if (contract == null) return;

    final current = (contract['water_intake_ml'] as int?) ?? 0;
    await supabase
        .from('daily_contracts')
        .update({'water_intake_ml': current + amountMl})
        .eq('id', contract['id'])
        .timeout(const Duration(seconds: 10));
  }

  Future<void> recalculateStreak() async {
    final memberId = await _memberId();
    if (memberId == null) return;

    await supabase.rpc('calculate_streak',
        params: {'p_member_id': memberId}).timeout(const Duration(seconds: 10));
  }
}
