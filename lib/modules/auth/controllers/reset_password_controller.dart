import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/app_snackbar.dart';

class ResetPasswordController extends GetxController {
  final passCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();
  final isLoading = false.obs;

  Future<void> confirm() async {
    final pass = passCtrl.text;
    final confirm = confirmCtrl.text;

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
      // TODO: এখানে পাসওয়ার্ড বদলানোর API কল বসবে
      await Future.delayed(const Duration(milliseconds: 600));
      Get.offAllNamed('/sign-in');
      showSuccess('Password updated. Please sign in.');
    } catch (_) {
      showError('Could not reset password. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    passCtrl.dispose();
    confirmCtrl.dispose();
    super.onClose();
  }
}