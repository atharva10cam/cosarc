import 'package:flutter/material.dart';
import 'core/supabase_config.dart';
import 'screens/auth/login_screen.dart';

class TestConnectionScreen extends StatefulWidget {
  const TestConnectionScreen({super.key});

  @override
  State<TestConnectionScreen> createState() => _TestConnectionScreenState();
}

class _TestConnectionScreenState extends State<TestConnectionScreen> {
  String _status = 'Testing connection...';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _testConnection();
  }

  Future<void> _testConnection() async {
    try {
      debugPrint('Testing Supabase connection');

      await supabase.from('members').select().limit(1);

      setState(() {
        _status = '✅ BACKEND CONNECTED!\n\nDatabase is ready!';
        _loading = false;
      });

      debugPrint('Supabase connection successful');

      // Auto-navigate after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        }
      });
    } catch (e) {
      setState(() {
        _status = '❌ CONNECTION FAILED\n\n$e';
        _loading = false;
      });
      debugPrint('Supabase connection failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_loading)
                const CircularProgressIndicator(color: Color(0xFFD7BB73))
              else
                Icon(
                  _status.contains('✅') ? Icons.check_circle : Icons.error,
                  color: _status.contains('✅') ? Colors.green : Colors.red,
                  size: 80,
                ),
              const SizedBox(height: 32),
              Text(
                _status,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  height: 1.5,
                ),
              ),
              if (!_loading && !_status.contains('✅'))
                Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                    child: const Text('Continue Anyway'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
