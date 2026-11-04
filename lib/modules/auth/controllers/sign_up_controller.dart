import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/app_snackbar.dart';

class SignUpController extends GetxController {
  final usernameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();
  final isLoading = false.obs;

  Future<void> signUp() async {
    final username = usernameCtrl.text.trim();
    final email = emailCtrl.text.trim();
    final pass = passCtrl.text;
    final confirm = confirmCtrl.text;

    if (username.length < 3) {
      showError('Username must be at least 3 characters');
      return;
    }
    if (!GetUtils.isEmail(email)) {
      showError('Enter a valid email address');
      return;
    }
    if (pass.length < 6) {
      showError('Password must be at least 6 characters');
      return;
    }
    if (pass != confirm) {
      showError('Passwords do not match');
      return;
    }

    isLoading.value = true;
    try {
      // TODO: এখানে sign up API কল বসবে, সার্ভার OTP পাঠাবে
      await Future.delayed(const Duration(milliseconds: 600));
      Get.toNamed('/otp', arguments: {'email': email, 'flow': 'signup'});
    } catch (_) {
      showError('Sign up failed. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    usernameCtrl.dispose();
    emailCtrl.dispose();
    passCtrl.dispose();
    confirmCtrl.dispose();
    super.onClose();
  }
}