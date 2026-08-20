import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/supabase_config.dart';
import '../domain/onboarding/onboarding_profile.dart';
import 'session_preferences.dart';

enum TwoFactorMethod { totp, email, sms }

class AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String name,
    Map<String, dynamic>? onboardingData,
  }) async {
    try {
      final cleanEmail = email.trim();
      final response = await supabase.auth.signUp(
        email: cleanEmail,
        password: password,
        data: {'full_name': name.trim()},
      ).timeout(const Duration(seconds: 20));

      final user = response.user;
      if (user == null) {
        throw Exception('Failed to create user account');
      }

      await ensureMemberExists(user, fallbackName: name.trim());
      return response;
    } catch (e) {
      debugPrint('Signup error: $e');
      rethrow;
    }
  }

  Future<bool> signInWithGoogle() async {
    if (kIsWeb) {
      return signInWithGoogleWeb();
    }
    return signInWithGoogleNative();
  }

  Future<bool> signInWithGoogleWeb() async {
    try {
      final currentUrl = Uri.base.toString();
      await supabase.auth
          .signInWithOAuth(
            Provider.google,
            redirectTo: currentUrl,
            authScreenLaunchMode: LaunchMode.platformDefault,
          )
          .timeout(const Duration(seconds: 20));

      await Future.delayed(const Duration(seconds: 1));

      final session = supabase.auth.currentSession;
      if (session != null) {
        await ensureMemberExists(session.user);
      }

      return true;
    } catch (e) {
      debugPrint('Google OAuth error: $e');
      rethrow;
    }
  }

  Future<bool> signInWithGoogleNative() async {
    try {
      await _googleSignIn.signOut();

      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return false;

      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (accessToken == null || idToken == null) {
        throw Exception('Google sign-in did not return the required tokens.');
      }

      final response = await supabase.auth
          .signInWithIdToken( // ignore: experimental_member_use
        
            provider: Provider.google,
            idToken: idToken,
            accessToken: accessToken,
          )
          .timeout(const Duration(seconds: 20));

      final user = response.user;
      if (user == null) return false;

      await ensureMemberExists(user);
      return true;
    } catch (e) {
      debugPrint('Native Google error: $e');
      try {
        await _googleSignIn.signOut();
      } catch (_) {}
      rethrow;
    }
  }

  bool get isAppleSignInAvailable {
    if (kIsWeb) return false;
    return Platform.isIOS || Platform.isMacOS;
  }

  Future<bool> signInWithApple() async {
    if (!isAppleSignInAvailable) {
      throw Exception('Apple Sign-In is only available on Apple devices.');
    }

    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final idToken = credential.identityToken;
      if (idToken == null) {
        throw Exception('Apple Sign-In did not return an identity token.');
      }

      final response = await supabase.auth
          .signInWithIdToken( // ignore: experimental_member_use
        
            provider: Provider.apple,
            idToken: idToken,
          )
          .timeout(const Duration(seconds: 20));

      final user = response.user;
      if (user == null) return false;

      final fullName = [
        credential.givenName,
        credential.familyName,
      ].where((part) => part != null && part.isNotEmpty).join(' ');

      await ensureMemberExists(
        user,
        fallbackName: fullName.isNotEmpty ? fullName : null,
      );
      return true;
    } catch (e) {
      debugPrint('Apple sign-in error: $e');
      rethrow;
    }
  }

  Future<void> sendEmailOtp(String email,
      {bool shouldCreateUser = true}) async {
    await supabase.auth
        .signInWithOtp(
          email: email.trim(),
          shouldCreateUser: shouldCreateUser,
        )
        .timeout(const Duration(seconds: 20));
  }

  Future<void> sendPhoneOtp(String phone) async {
    await supabase.auth
        .signInWithOtp(
          phone: phone.trim(),
          channel: OtpChannel.sms,
        )
        .timeout(const Duration(seconds: 20));
  }

  Future<AuthResponse> verifyOtp({
    String? email,
    String? phone,
    required String token,
  }) async {
    final response = await supabase.auth
        .verifyOTP(
          type: email != null ? OtpType.email : OtpType.sms,
          email: email?.trim(),
          phone: phone?.trim(),
          token: token.trim(),
        )
        .timeout(const Duration(seconds: 20));

    await ensureMemberExists(response.user);
    return response;
  }

  Future<void> resetPassword(String email) async {
    await supabase.auth
        .resetPasswordForEmail(
          email.trim(),
          redirectTo: kIsWeb ? Uri.base.toString() : null,
        )
        .timeout(const Duration(seconds: 20));
  }

  Future<void> updatePassword(String newPassword) async {
    await supabase.auth
        .updateUser(
          UserAttributes(password: newPassword),
        )
        .timeout(const Duration(seconds: 20));
  }

  Future<Map<String, dynamic>?> ensureMemberExists(
    User? user, {
    String? fallbackName,
  }) async {
    user ??= currentUser;
    if (user == null) return null;

    Map<String, dynamic>? member = await _findMember(user.id);
    if (member == null) {
      final name = fallbackName?.trim().isNotEmpty == true
          ? fallbackName!.trim()
          : user.userMetadata?['full_name'] ??
              user.email?.split('@').first ??
              'User';

      try {
        await supabase.from('members').insert({
          'auth_user_id': user.id,
          'email': user.email,
          'name': name,
        }).timeout(const Duration(seconds: 10));
      } catch (e) {
        debugPrint('Member insert skipped/retried: $e');
      }

      member = await _findMember(user.id);
    }

    final memberId = member?['id'];
    if (memberId != null) {
      await _ensureStreakExists(memberId.toString());
    }

    return member;
  }

  Future<Map<String, dynamic>?> _findMember(String authUserId) async {
    try {
      return await supabase
          .from('members')
          .select('id')
          .eq('auth_user_id', authUserId)
          .maybeSingle()
          .timeout(const Duration(seconds: 10));
    } catch (e) {
      debugPrint('Error finding member: $e');
      return null;
    }
  }

  Future<void> _ensureStreakExists(String memberId) async {
    try {
      final existing = await supabase
          .from('streaks')
          .select('id')
          .eq('member_id', memberId)
          .maybeSingle()
          .timeout(const Duration(seconds: 10));

      if (existing != null) return;

      await supabase.from('streaks').insert({
        'member_id': memberId,
      }).timeout(const Duration(seconds: 10));
    } catch (e) {
      debugPrint('Streak insert skipped/retried: $e');
    }
  }

  Future<bool> needsOnboarding() async {
    if (!isLoggedIn) return true;

    try {
      await ensureMemberExists(currentUser);

      final member = await supabase
          .from('members')
          .select(OnboardingProfile.selectColumns)
          .eq('auth_user_id', currentUser!.id)
          .maybeSingle()
          .timeout(const Duration(seconds: 10));

      return !OnboardingProfile.isComplete(member);
    } catch (e) {
      debugPrint('Full onboarding check failed, falling back to age gate: $e');
      try {
        final member = await supabase
            .from('members')
            .select('age')
            .eq('auth_user_id', currentUser!.id)
            .maybeSingle()
            .timeout(const Duration(seconds: 10));
        final age = member?['age'];
        return age == null || (age is num && age < 13);
      } catch (_) {
        return true;
      }
    }
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    final response = await supabase.auth
        .signInWithPassword(
          email: email.trim(),
          password: password,
        )
        .timeout(const Duration(seconds: 20));

    await ensureMemberExists(response.user);

    if (await SessionPreferences.instance.rememberMe) {
      await SessionPreferences.instance.setRememberMe(
        enabled: true,
        email: email.trim(),
      );
    }

    return response;
  }

  Future<bool> requiresMfaChallenge() async {
    try {
      final aal = supabase.auth.mfa.getAuthenticatorAssuranceLevel();
      return aal.currentLevel == AuthenticatorAssuranceLevels.aal1 &&
          aal.nextLevel == AuthenticatorAssuranceLevels.aal2;
    } catch (_) {
      return false;
    }
  }

  Future<AuthMFAVerifyResponse> verifyMfaChallenge({
    required String factorId,
    required String code,
  }) async {
    final challenge = await supabase.auth.mfa.challenge(factorId: factorId);
    return supabase.auth.mfa.verify(
      factorId: factorId,
      challengeId: challenge.id,
      code: code.trim(),
    );
  }

  Future<AuthMFAEnrollResponse> enrollTotp() async {
    return supabase.auth.mfa.enroll(factorType: FactorType.totp);
  }

  Future<AuthMFAVerifyResponse> verifyTotpEnrollment({
    required String factorId,
    required String code,
  }) async {
    final challenge = await supabase.auth.mfa.challenge(factorId: factorId);
    return supabase.auth.mfa.verify(
      factorId: factorId,
      challengeId: challenge.id,
      code: code.trim(),
    );
  }

  Future<void> unenrollFactor(String factorId) async {
    await supabase.auth.mfa.unenroll(factorId);
  }

  Future<AuthMFAListFactorsResponse> listMfaFactors() async {
    return supabase.auth.mfa.listFactors();
  }

  Future<TwoFactorMethod> getPreferredTwoFactorMethod() async {
    final method =
        currentUser?.userMetadata?['preferred_2fa_method'] as String?;
    return TwoFactorMethod.values.firstWhere(
      (value) => value.name == method,
      orElse: () => TwoFactorMethod.totp,
    );
  }

  Future<void> setPreferredTwoFactorMethod(TwoFactorMethod method) async {
    await supabase.auth.updateUser(
      UserAttributes(
        data: {'preferred_2fa_method': method.name},
      ),
    );
  }

  Future<void> signOut({bool everywhere = false}) async {
    try {
      await supabase.auth
          .signOut(
            scope: everywhere ? SignOutScope.global : SignOutScope.local,
          )
          .timeout(const Duration(seconds: 10));
      if (!kIsWeb) await _googleSignIn.signOut();
    } catch (e) {
      debugPrint('Signout error: $e');
    }
  }

  User? get currentUser => supabase.auth.currentUser;
  bool get isLoggedIn => currentUser != null;
  Session? get currentSession => supabase.auth.currentSession;

  Future<String?> getMemberId() async {
    if (!isLoggedIn) return null;

    try {
      final member = await ensureMemberExists(currentUser);
      return member?['id']?.toString();
    } catch (e) {
      debugPrint('Error getting member ID: $e');
      return null;
    }
  }

  String friendlyAuthError(Object error) {
    final message = error.toString().toLowerCase();
    if (message.contains('invalid login credentials')) {
      return 'Incorrect email or password. Please try again.';
    }
    if (message.contains('email not confirmed')) {
      return 'Please check your email and confirm your account first.';
    }
    if (message.contains('user already registered')) {
      return 'An account with this email already exists.';
    }
    if (message.contains('email rate limit')) {
      return 'Too many attempts. Please wait a few minutes before trying again.';
    }
    if (message.contains('not enabled') ||
        message.contains('provider is not enabled')) {
      return 'This sign-in method is not available. Please use email instead.';
    }
    if (message.contains('user not found') ||
        message.contains('user_not_found')) {
      return 'No account found with this email. Please sign up first.';
    }
    if (message.contains('phone not confirmed') || message.contains('phone')) {
      return 'Phone verification failed. Please try again.';
    }
    if (message.contains('network') || message.contains('socket')) {
      return 'Network error. Check your connection and try again.';
    }
    if (message.contains('otp') || message.contains('token')) {
      return 'Invalid or expired code. Request a new one.';
    }
    return 'Something went wrong. Please try again.';
  }
}
