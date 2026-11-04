import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/app_snackbar.dart';

class SignInController extends GetxController {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final isLoading = false.obs;

  Future<void> signIn() async {
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
      // TODO: এখানে sign in API কল বসবে
      await Future.delayed(const Duration(milliseconds: 600));
      Get.offAllNamed('/home');
    } catch (_) {
      showError('Sign in failed. Please try again.');
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