import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/app_state.dart';
import 'core/supabase_config.dart';
import 'core/theme/cosarc_theme.dart';
import 'screens/app_start/app_start_screen.dart';
import 'screens/onboarding/onboarding_wrapper.dart';
import 'screens/dashboard/dashboard_root.dart';
import 'models/food_log.dart';
import 'models/food_adapter.dart';
import 'services/auth_service.dart';

ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.dark);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Hive.initFlutter().timeout(const Duration(seconds: 8));

    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(FoodLogAdapter());
    }

    if (!Hive.isBoxOpen('daily_logs')) {
      await Hive.openBox<FoodLog>('daily_logs')
          .timeout(const Duration(seconds: 8));
    }
  } catch (e) {
    debugPrint('Hive startup failed: $e');
  }

  try {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString('theme') ?? 'Dark';
    themeNotifier.value =
        savedTheme == 'System' ? ThemeMode.system : ThemeMode.dark;
  } catch (e) {
    debugPrint('SharedPreferences read failed: $e');
  }

  try {
    await SupabaseConfig.initialize();
  } catch (e) {
    debugPrint('Supabase startup failed: $e');
  }

  runApp(const CosarcApp());
}

class CosarcApp extends StatefulWidget {
  const CosarcApp({super.key});

  @override
  State<CosarcApp> createState() => _CosarcAppState();
}

class _CosarcAppState extends State<CosarcApp> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final AuthService _authService = AuthService();
  bool _isHandlingAuth = false;

  @override
  void initState() {
    super.initState();
    _setupAuthListener();
  }

  void _setupAuthListener() {
    if (!SupabaseConfig.isInitialized) return;

    supabase.auth.onAuthStateChange.listen((data) async {
      // Do not navigate while the splash screen is still handling routing.
      // AppStartScreen sets splashNavigationDone = true before it navigates.
      if (!splashNavigationDone) return;
      if (_isHandlingAuth) return;

      final session = data.session;

      if (session != null) {
        _isHandlingAuth = true;

        debugPrint(
            'Auth state changed - user logged in: ${session.user.email}');

        await Future.delayed(const Duration(milliseconds: 500));

        try {
          await _authService.ensureMemberExists(session.user);

          final needsOnboarding = await _authService.needsOnboarding();

          if (!mounted) return;
          final navigator = navigatorKey.currentState;
          if (navigator != null) {
            if (needsOnboarding) {
              debugPrint('Navigating to onboarding');
              navigator.pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const OnboardingWrapper()),
                (route) => false,
              );
            } else {
              debugPrint('Navigating to dashboard');
              navigator.pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const DashboardRoot()),
                (route) => false,
              );
            }
          }
        } catch (e) {
          debugPrint('Error handling auth state: $e');
        } finally {
          _isHandlingAuth = false;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, mode, child) {
        return MaterialApp(
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          title: 'Cosarc',
          themeMode: mode,
          theme: CosarcTheme.dark(),
          darkTheme: CosarcTheme.dark(),
          home: const AppStartScreen(),
        );
      },
    );
  }
}
