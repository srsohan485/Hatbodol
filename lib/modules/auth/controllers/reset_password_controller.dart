import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hatbodol/Services/ApiService.dart';
import 'package:hatbodol/core/utils/app_error.dart';
import '../../../core/utils/app_snackbar.dart';

class ResetPasswordController extends GetxController {
  final _api = Get.find<ApiServices>();

  final passCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();
  final isLoading = false.obs;

  late final String email;
  late final String otp;

  @override
  void onInit() {
    super.onInit();
    final args = (Get.arguments as Map?) ?? {};
    email = (args['email'] as String?) ?? '';
    otp = (args['otp'] as String?) ?? '';
  }

  Future<void> confirm() async {
    if (isLoading.value) return;

    final pass = passCtrl.text;
    final confirm = confirmCtrl.text;

    if (email.isEmpty || otp.isEmpty) {
      showError('Session expired. Please start again.');
      Get.offAllNamed('/forgot-password');
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
      await _api.post('/auth/reset-password/', body: {
        'email': email,
        'otp': otp,
        'password': pass,
        'confirm_password': confirm,
      });
      Get.offAllNamed('/sign-in');
      showSuccess('Password updated. Please sign in.');
    } catch (e) {
      showError(apiErrorMessage(e, fallback: 'Could not reset password. Please try again.'));
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