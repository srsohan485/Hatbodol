import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hatbodol/Services/ApiService.dart';
import 'package:hatbodol/core/utils/app_error.dart';
import '../../../core/utils/app_snackbar.dart';

class SignUpController extends GetxController {
  final _api = Get.find<ApiServices>();

  final usernameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();
  final isLoading = false.obs;

  Future<void> signUp() async {
    if (isLoading.value) return;

    final username = usernameCtrl.text.trim();
    final email = emailCtrl.text.trim();
    final pass = passCtrl.text;
    final confirm = confirmCtrl.text;

    if (username.length < 3) {
      showError('Username must be at least 3 characters');
      return;
    }
    if (username.contains(' ')) {
      showError('Username cannot contain spaces');
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
      await _api.post('/auth/signup/', body: {
        'username': username,
        'email': email,
        'password': pass,
        'confirm_password': confirm,
      });
      Get.toNamed('/otp', arguments: {'email': email, 'flow': 'signup'});
    } catch (e) {
      showError(apiErrorMessage(e, fallback: 'Sign up failed. Please try again.'));
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