import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/app_snackbar.dart';
import '../widgets/email_verified_dialog.dart';

class OtpController extends GetxController {
  final otpCtrl = TextEditingController();
  final isLoading = false.obs;
  final secondsLeft = 60.obs;

  Timer? _timer;
  late final String email;
  late final String flow; // 'signup' বা 'forgot'

  @override
  void onInit() {
    super.onInit();
    final args = (Get.arguments as Map?) ?? {};
    email = (args['email'] as String?) ?? '';
    flow = (args['flow'] as String?) ?? 'signup';
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    secondsLeft.value = 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (secondsLeft.value <= 1) {
        secondsLeft.value = 0;
        t.cancel();
      } else {
        secondsLeft.value--;
      }
    });
  }

  /// Obx-এর ভেতর থেকে ডাকতে হবে
  String get timeText {
    final s = secondsLeft.value;
    return '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';
  }

  bool get canResend => secondsLeft.value == 0;

  void resend() {
    if (!canResend) return;
    // TODO: এখানে OTP আবার পাঠানোর API কল বসবে
    _startTimer();
    showSuccess('A new code has been sent to your email');
  }

  Future<void> submit() async {
    final code = otpCtrl.text.trim();
    if (code.length != 6) {
      showError('Enter the 6 digit OTP');
      return;
    }

    isLoading.value = true;
    try {
      // TODO: এখানে OTP যাচাইয়ের API কল বসবে
      await Future.delayed(const Duration(milliseconds: 600));

      if (flow == 'forgot') {
        Get.offNamed('/reset-password', arguments: {'email': email});
      } else {
        Get.dialog(
          EmailVerifiedDialog(email: email),
          barrierDismissible: false,
        );
      }
    } catch (_) {
      showError('Invalid code. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    otpCtrl.dispose();
    super.onClose();
  }
}