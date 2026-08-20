import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../core/theme/cosarc_colors.dart';
import '../../core/theme/cosarc_spacing.dart';
import '../../core/theme/cosarc_typography.dart';
import '../../widgets/cosarc/cosarc_button.dart';
import '../../widgets/cosarc/cosarc_scaffold.dart';
import '../dashboard/dashboard_root.dart';
import '../onboarding/onboarding_wrapper.dart';
import 'otp_verification_screen.dart';

enum PhoneAuthMode { signIn, signUp }

// Simple country model — avoids Dart records for broader SDK compatibility.
class _Country {
  const _Country({required this.name, required this.code, required this.flag});
  final String name;
  final String code;
  final String flag;
}

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({super.key, this.mode = PhoneAuthMode.signIn});

  final PhoneAuthMode mode;

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  static const _countries = [
    _Country(name: 'India', code: '+91', flag: '🇮🇳'),
    _Country(name: 'United States', code: '+1', flag: '🇺🇸'),
    _Country(name: 'United Kingdom', code: '+44', flag: '🇬🇧'),
    _Country(name: 'United Arab Emirates', code: '+971', flag: '🇦🇪'),
    _Country(name: 'Canada', code: '+1', flag: '🇨🇦'),
    _Country(name: 'Australia', code: '+61', flag: '🇦🇺'),
    _Country(name: 'Singapore', code: '+65', flag: '🇸🇬'),
    _Country(name: 'Germany', code: '+49', flag: '🇩🇪'),
    _Country(name: 'France', code: '+33', flag: '🇫🇷'),
    _Country(name: 'Brazil', code: '+55', flag: '🇧🇷'),
    _Country(name: 'Japan', code: '+81', flag: '🇯🇵'),
    _Country(name: 'South Korea', code: '+82', flag: '🇰🇷'),
    _Country(name: 'Philippines', code: '+63', flag: '🇵🇭'),
    _Country(name: 'Bangladesh', code: '+880', flag: '🇧🇩'),
    _Country(name: 'Pakistan', code: '+92', flag: '🇵🇰'),
    _Country(name: 'Nigeria', code: '+234', flag: '🇳🇬'),
    _Country(name: 'South Africa', code: '+27', flag: '🇿🇦'),
    _Country(name: 'Mexico', code: '+52', flag: '🇲🇽'),
    _Country(name: 'Indonesia', code: '+62', flag: '🇮🇩'),
    _Country(name: 'Malaysia', code: '+60', flag: '🇲🇾'),
  ];

  final _authService = AuthService();
  final _phoneController = TextEditingController();
  bool _isLoading = false;
  _Country _selectedCountry = _countries.first; // Default: India (+91)

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _showCountryPicker() {
    showModalBottomSheet<_Country>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: _countries.length,
          itemBuilder: (ctx, i) {
            final c = _countries[i];
            return ListTile(
              leading: Text(c.flag, style: const TextStyle(fontSize: 24)),
              title: Text(c.name),
              trailing: Text(
                c.code,
                style: const TextStyle(color: CosarcColors.textSecondary),
              ),
              selected: c.code == _selectedCountry.code &&
                  c.name == _selectedCountry.name,
              onTap: () {
                setState(() => _selectedCountry = c);
                Navigator.pop(ctx);
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> _sendCode() async {
    final local =
        _phoneController.text.trim().replaceAll(RegExp(r'[^0-9]'), '');
    if (local.length < 7) {
      _showError('Enter a valid local phone number');
      return;
    }

    final fullPhone = _selectedCountry.code + local; // E.164

    setState(() => _isLoading = true);
    try {
      await _authService.sendPhoneOtp(fullPhone);
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OtpVerificationScreen(
            phone: fullPhone,
            onVerified: _routeAfterAuth,
          ),
        ),
      );
    } catch (e) {
      final errMsg = e.toString().toLowerCase();
      if (errMsg.contains('not enabled') ||
          errMsg.contains('sms') ||
          errMsg.contains('phone provider')) {
        _showError('Phone sign-in is not available. Please use email instead.');
      } else {
        _showError(_authService.friendlyAuthError(e));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _routeAfterAuth() async {
    final needsOnboarding = await _authService.needsOnboarding();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) =>
            needsOnboarding ? const OnboardingWrapper() : const DashboardRoot(),
      ),
      (route) => false,
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: CosarcColors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CosarcScaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(
              horizontal: CosarcSpacing.screenHorizontal),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: CosarcSpacing.lg),
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
              ),
              const SizedBox(height: CosarcSpacing.lg),
              Text('Phone sign-in', style: CosarcTypography.headline(context)),
              const SizedBox(height: CosarcSpacing.sm),
              Text(
                "We'll text you a one-time code.",
                style: CosarcTypography.body(context),
              ),
              const SizedBox(height: CosarcSpacing.xxl),
              // Phone field: country picker prefix + local number input
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Country picker button
                  GestureDetector(
                    onTap: _showCountryPicker,
                    child: Container(
                      height: 56,
                      padding: const EdgeInsets.symmetric(
                          horizontal: CosarcSpacing.sm),
                      decoration: BoxDecoration(
                        color: CosarcColors.glassFill(0.06),
                        borderRadius:
                            BorderRadius.circular(CosarcSpacing.radiusMd),
                        border: Border.all(color: CosarcColors.glassBorder()),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _selectedCountry.flag,
                            style: const TextStyle(fontSize: 20),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _selectedCountry.code,
                            style: CosarcTypography.body(context),
                          ),
                          const SizedBox(width: 2),
                          const Icon(
                            Icons.arrow_drop_down,
                            size: 18,
                            color: CosarcColors.textTertiary,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: CosarcSpacing.sm),
                  // Local number text field
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _sendCode(),
                        style: CosarcTypography.body(context),
                        decoration: InputDecoration(
                          hintText: '9876543210',
                          hintStyle:
                              const TextStyle(color: CosarcColors.textTertiary),
                          filled: true,
                          fillColor: CosarcColors.glassFill(0.06),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(CosarcSpacing.radiusMd),
                            borderSide:
                                BorderSide(color: CosarcColors.glassBorder()),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(CosarcSpacing.radiusMd),
                            borderSide:
                                BorderSide(color: CosarcColors.glassBorder()),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(CosarcSpacing.radiusMd),
                            borderSide: const BorderSide(color: CosarcColors.primary),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: CosarcSpacing.md,
                            vertical: CosarcSpacing.sm,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: CosarcSpacing.xxl),
              CosarcButton(
                label: 'Send code',
                isLoading: _isLoading,
                onPressed: _isLoading ? null : _sendCode,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
