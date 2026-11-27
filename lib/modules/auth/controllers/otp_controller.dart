import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hatbodol/Services/ApiService.dart';
import 'package:hatbodol/Services/StorageService.dart';
import 'package:hatbodol/core/utils/app_error.dart';
import 'package:hatbodol/core/utils/bn_number.dart';

import '../../../core/utils/app_snackbar.dart';
import '../widgets/email_verified_dialog.dart';

class OtpController extends GetxController {
  final _api = Get.find<ApiServices>();

  // ⚠️ নিচের তিনটা endpoint আমার আন্দাজ। তোমার Django urls.py-র সাথে মিলিয়ে নাও।
  static const _signupResendPath = '/auth/resend-otp/';
  static const _forgotResendPath = '/auth/forgot-password/';
  static const _phoneSendPath = '/phone/send-otp/';

  final otpCtrl = TextEditingController();
  final isLoading = false.obs;
  final isResending = false.obs;
  final secondsLeft = 60.obs;

  Timer? _timer;
  late final String email;
  late final String phone;
  late final String flow; // 'signup', 'forgot' বা 'profile'

  String get channel => flow == 'profile' ? 'phone' : 'email';

  Map<String, String> get _auth =>
      {'Authorization': 'Bearer ${StorageService.accessToken}'};

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

  /// Obx-এর ভেতর থেকে ডাকতে হবে
  String get timeText {
    final s = secondsLeft.value;
    return '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';
  }

  bool get canResend => secondsLeft.value == 0 && !isResending.value;

  Future<void> resend() async {
    if (!canResend) return;

    isResending.value = true;
    try {
      if (flow == 'profile') {
        await _api.post(_phoneSendPath, headers: _auth, body: {'phone': phone});
      } else if (flow == 'forgot') {
        await _api.post(_forgotResendPath, body: {'email': email});
      } else {
        await _api.post(_signupResendPath, body: {'email': email});
      }
      _startTimer();
      showSuccess('A new code has been sent to your $channel');
    } catch (e) {
      showError(apiErrorMessage(
        e,
        fallback: 'Could not resend the code. Please try again.',
      ));
    } finally {
      isResending.value = false;
    }
  }

  Future<void> submit() async {
    if (isLoading.value) return;

    // বাংলা সংখ্যায় লিখলেও ইংরেজিতে বদলে নেয়
    final code = toEn(otpCtrl.text.trim());
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
        await _api.post(
          '/phone/verify-otp/',
          headers: _auth,
          body: {'phone': phone, 'otp': code},
        );
        Get.back(result: true); // প্রোফাইল তৈরির পেজ বাকি কাজ করবে
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
      showError(
          apiErrorMessage(e, fallback: 'Invalid code. Please try again.'));
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