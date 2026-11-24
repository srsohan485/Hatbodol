import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hatbodol/Services/ApiService.dart';
import 'package:hatbodol/Services/StorageService.dart';
import 'package:hatbodol/core/utils/app_error.dart';

import '../../../core/services/profile_session.dart';
import '../../../core/utils/app_snackbar.dart';
import '../widgets/email_verified_dialog.dart';

class OtpController extends GetxController {
  final _api = Get.find<ApiServices>();

  final otpCtrl = TextEditingController();
  final isLoading = false.obs;
  final isResending = false.obs;
  final secondsLeft = 60.obs;

  Timer? _timer;
  late final String email;
  late final String phone;
  late final String flow; // 'signup', 'forgot' বা 'profile'

  String get channel => flow == 'profile' ? 'phone' : 'email';

  @override
  void onInit() {
    super.onInit();
    final args = (Get.arguments as Map?) ?? {};
    email = (args['email'] as String?) ?? '';
    phone = (args['phone'] as String?) ?? '';
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

  String get timeText {
    final s = secondsLeft.value;
    return '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';
  }

  bool get canResend => secondsLeft.value == 0 && !isResending.value;

  Future<void> resend() async {
    if (!canResend) return;

    isResending.value = true;
    try {
      if (flow == 'signup') {
        await _api.post('/auth/resend-otp/', body: {'email': email});
      } else if (flow == 'forgot') {
        await _api.post('/auth/forgot-password/', body: {'email': email});
      } else {
        // TODO: profile (phone) flow এর API পরে বসবে
      }
      _startTimer();
      showSuccess('A new code has been sent to your $channel');
    } catch (e) {
      showError(apiErrorMessage(e, fallback: 'Could not resend code.'));
    } finally {
      isLoading.value = false;
      isResending.value = false;
    }
  }

  Future<void> submit() async {
    if (isLoading.value) return;

    final code = otpCtrl.text.trim();
    if (!RegExp(r'^\d{6}$').hasMatch(code)) {
      showError('Enter the 6 digit OTP');
      return;
    }

    isLoading.value = true;
    try {
      if (flow == 'forgot') {
        await _api.post('/auth/verify-reset-otp/',
            body: {'email': email, 'otp': code});
        // reset-password এ OTP ও লাগে, তাই সাথে পাঠাচ্ছি
        Get.offNamed('/reset-password',
            arguments: {'email': email, 'otp': code});
      } else if (flow == 'profile') {
        // TODO: phone OTP যাচাইয়ের API পরে বসবে
        Get.find<ProfileSession>().complete();
        Get.offNamedUntil(
          '/profile',
              (route) => route.settings.name == '/home',
        );
      } else {
        final res = await _api.post('/auth/verify-email/',
            body: {'email': email, 'otp': code}) as Map<String, dynamic>;

        await StorageService.saveToken(res['access'] as String);
        await StorageService.saveRefreshToken(res['refresh'] as String);

        Get.dialog(
          EmailVerifiedDialog(email: email),
          barrierDismissible: false,
        );
      }
    } catch (e) {
      showError(apiErrorMessage(e, fallback: 'Invalid code. Please try again.'));
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