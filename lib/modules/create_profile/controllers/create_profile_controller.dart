import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/profile_session.dart';
import '../../../core/utils/app_snackbar.dart';
import '../../../core/utils/bn_number.dart';

class CreateProfileController extends GetxController {
  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final phoneFocus = FocusNode();

  final area = 'ধানমন্ডি, ঢাকা'.obs;
  final photo = RxnString();
  final isLoading = false.obs;

  void pickPhoto() {
    // TODO: image_picker দিয়ে আসল ছবি নেবে, এখন ডামি ছবি বসছে
    photo.value = 'assets/images/avatar.jpg';
  }

  Future<void> changeArea() async {
    final result = await Get.toNamed('/location-permission');
    if (result is String && result.isNotEmpty) area.value = result;
  }

  void changePhone() {
    phoneFocus.requestFocus();
    phoneCtrl.selection = TextSelection(
      baseOffset: 0,
      extentOffset: phoneCtrl.text.length,
    );
  }

  Future<void> start() async {
    final name = nameCtrl.text.trim();
    final areaText = area.value.trim();
    final phone = toEn(phoneCtrl.text.trim());

    if (name.length < 2) {
      showError('আপনার নাম লিখুন');
      return;
    }
    if (areaText.isEmpty) {
      showError('আপনার এলাকা বাছাই করুন');
      return;
    }
    // বাংলাদেশি মোবাইল নম্বর: ০১ দিয়ে শুরু, মোট ১১ সংখ্যা
    if (!RegExp(r'^01[3-9]\d{8}$').hasMatch(phone)) {
      showError('সঠিক ১১ সংখ্যার মোবাইল নম্বর দিন');
      return;
    }

    isLoading.value = true;
    try {
      // TODO: এখানে ফোনে OTP পাঠানোর API কল বসবে
      await Future.delayed(const Duration(milliseconds: 600));

      Get.find<ProfileSession>().setDraft(
        name: name,
        area: areaText,
        phone: phone,
        photo: photo.value,
      );
      Get.toNamed('/otp', arguments: {'phone': phone, 'flow': 'profile'});
    } catch (_) {
      showError('OTP পাঠানো যায়নি, আবার চেষ্টা করুন');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();
    phoneFocus.dispose();
    super.onClose();
  }
}