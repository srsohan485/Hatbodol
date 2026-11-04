import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/app_snackbar.dart';

class ForgotPasswordController extends GetxController {
  final emailCtrl = TextEditingController();
  final isLoading = false.obs;

  Future<void> sendOtp() async {
    final email = emailCtrl.text.trim();
    if (!GetUtils.isEmail(email)) {
      showError('Enter a valid email address');
      return;
    }

    isLoading.value = true;
    try {
      // TODO: এখানে OTP পাঠানোর API কল বসবে
      await Future.delayed(const Duration(milliseconds: 600));
      Get.toNamed('/otp', arguments: {'email': email, 'flow': 'forgot'});
    } catch (_) {
      showError('Could not send OTP. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailCtrl.dispose();
    super.onClose();
  }
}