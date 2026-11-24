import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hatbodol/Services/ApiService.dart';
import 'package:hatbodol/core/utils/app_error.dart';
import '../../../core/utils/app_snackbar.dart';

class ForgotPasswordController extends GetxController {
  final _api = Get.find<ApiServices>();

  final emailCtrl = TextEditingController();
  final isLoading = false.obs;

  Future<void> sendOtp() async {
    if (isLoading.value) return;

    final email = emailCtrl.text.trim();
    if (!GetUtils.isEmail(email)) {
      showError('Enter a valid email address');
      return;
    }

    isLoading.value = true;
    try {
      await _api.post('/auth/forgot-password/', body: {'email': email});
      Get.toNamed('/otp', arguments: {'email': email, 'flow': 'forgot'});
    } catch (e) {
      showError(apiErrorMessage(e, fallback: 'Could not send OTP. Please try again.'));
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