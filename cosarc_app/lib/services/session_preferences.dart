import 'package:shared_preferences/shared_preferences.dart';

/// Persists lightweight auth UX preferences (remember me, waitlist).
class SessionPreferences {
  SessionPreferences._();
  static final SessionPreferences instance = SessionPreferences._();

  static const _rememberMeKey = 'cosarc_remember_me';
  static const _savedEmailKey = 'cosarc_saved_email';
  static const _nutriwaveWaitlistKey = 'cosarc_nutriwave_waitlist';
  static const _cosarcAiWaitlistKey = 'cosarc_cosarc_ai_waitlist';
  static const _notifyNutriwaveKey = 'cosarc_notify_nutriwave';
  static const _notifyCosarcAiKey = 'cosarc_notify_cosarc_ai';

  SharedPreferences? _prefs;

  Future<SharedPreferences> get _store async {
    return _prefs ??= await SharedPreferences.getInstance();
  }

  Future<bool> get rememberMe async =>
      (await _store).getBool(_rememberMeKey) ?? false;

  Future<String?> get savedEmail async =>
      (await _store).getString(_savedEmailKey);

  Future<void> setRememberMe({
    required bool enabled,
    String? email,
  }) async {
    final prefs = await _store;
    await prefs.setBool(_rememberMeKey, enabled);
    if (enabled && email != null && email.isNotEmpty) {
      await prefs.setString(_savedEmailKey, email.trim());
    } else if (!enabled) {
      await prefs.remove(_savedEmailKey);
    }
  }

  Future<bool> isOnWaitlist(String feature) async {
    final prefs = await _store;
    return switch (feature) {
      'nutriwave' => prefs.getBool(_nutriwaveWaitlistKey) ?? false,
      'cosarc_ai' => prefs.getBool(_cosarcAiWaitlistKey) ?? false,
      _ => false,
    };
  }

  Future<void> joinWaitlist(String feature) async {
    final prefs = await _store;
    switch (feature) {
      case 'nutriwave':
        await prefs.setBool(_nutriwaveWaitlistKey, true);
      case 'cosarc_ai':
        await prefs.setBool(_cosarcAiWaitlistKey, true);
    }
  }

  Future<bool> wantsNotification(String feature) async {
    final prefs = await _store;
    return switch (feature) {
      'nutriwave' => prefs.getBool(_notifyNutriwaveKey) ?? false,
      'cosarc_ai' => prefs.getBool(_notifyCosarcAiKey) ?? false,
      _ => false,
    };
  }

  Future<void> setNotifyMe(String feature, bool enabled) async {
    final prefs = await _store;
    switch (feature) {
      case 'nutriwave':
        await prefs.setBool(_notifyNutriwaveKey, enabled);
      case 'cosarc_ai':
        await prefs.setBool(_notifyCosarcAiKey, enabled);
    }
  }
}
