import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hatbodol/Services/ApiService.dart';
import 'package:hatbodol/Services/AppLog.dart';
import 'package:hatbodol/Services/StorageService.dart';
import 'package:hatbodol/core/utils/app_error.dart';
import 'package:hatbodol/modules/profile/models/user_profile.dart';
import '../../../core/utils/app_snackbar.dart';

class SignInController extends GetxController {
  final _api = Get.find<ApiServices>();

  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final isLoading = false.obs;

  Future<void> signIn() async {
    if (isLoading.value) return;

    final email = emailCtrl.text.trim();
    final pass = passCtrl.text;

    if (!GetUtils.isEmail(email)) {
      showError('Enter a valid email address');
      return;
    }
    if (pass.isEmpty) {
      showError('Enter your password');
      return;
    }

    isLoading.value = true;
    try {
      final res = await _api.post('/auth/signin/', body: {
        'email': email,
        'password': pass,
      }) as Map<String, dynamic>;

      final user = (res['user'] as Map?) ?? {};

      // ইমেইল ভেরিফাই না থাকলে আগে OTP পেজে যাবে
      if (user['is_email_verified'] != true) {
        await _api.post('/auth/resend-otp/', body: {'email': email});
        Get.toNamed('/otp', arguments: {'email': email, 'flow': 'signup'});
        return;
      }

      await StorageService.saveToken(res['access'] as String);
      await StorageService.saveRefreshToken(res['refresh'] as String);

      // প্রোফাইল আছে কিনা সার্ভার থেকে জেনে ProfileSession ঠিক করা।
      // না করলে প্রোফাইল থাকা ইউজারও "প্রোফাইল তৈরি" পেজে চলে যাবে,
      // আর আগের ইউজারের ডেটা মেমরিতে থেকে যাবে
      if (user['has_profile'] == true) {
        try {
          final me = await _api.get('/profile/me/', headers: {
            'Authorization': 'Bearer ${StorageService.accessToken}',
          }) as Map<String, dynamic>;
          syncProfileSession(UserProfile.fromJson(me));
        } catch (_) {
          // না এলেও চলবে, প্রোফাইল পেজ নিজে আবার লোড করবে
        }
      } else {
        resetProfileSession();
      }

      Get.offAllNamed('/home');
    } catch (e) {
      showError(apiErrorMessage(e, fallback: 'Sign in failed. Please try again.'));
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    super.onClose();
  }
}