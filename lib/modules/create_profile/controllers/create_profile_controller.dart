import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hatbodol/Services/ApiService.dart';
import 'package:hatbodol/Services/StorageService.dart';
import 'package:hatbodol/Services/location_session.dart';
import 'package:hatbodol/core/utils/app_error.dart';
import 'package:hatbodol/core/utils/app_snackbar.dart';
import 'package:hatbodol/core/utils/bn_number.dart';
import 'package:hatbodol/modules/profile/models/user_profile.dart';
import 'package:image_picker/image_picker.dart';

class CreateProfileController extends GetxController {
  final _api = Get.find<ApiServices>();
  final _picker = ImagePicker();

  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final phoneFocus = FocusNode();

  final area = ''.obs;
  final photoPath = RxnString(); // নতুন বাছাই করা ছবির ফাইল
  final photoUrl = RxnString(); // সার্ভারে থাকা ছবি (সম্পাদনার সময়)
  final isLoading = false.obs;

  bool isEdit = false;
  double? _lat;
  double? _lng;
  bool _areaChanged = false;
  bool _photoRemoved = false;
  String? _verifiedPhone; // যে নম্বর একবার যাচাই হয়েছে

  bool get hasPhoto => photoPath.value != null || photoUrl.value != null;

  Map<String, String> get _auth =>
      {'Authorization': 'Bearer ${StorageService.accessToken}'};

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map && args['edit'] == true && args['profile'] is UserProfile) {
      isEdit = true;
      final p = args['profile'] as UserProfile;
      nameCtrl.text = p.fullName;
      area.value = p.area;
      photoUrl.value = p.photo.isEmpty ? null : p.photo;
    } else {
      // আগে এলাকা বাছাই করা থাকলে সেটাই শুরুতে বসবে
      area.value = LocationSession.areaName.value;
      _lat = LocationSession.latitude;
      _lng = LocationSession.longitude;
    }
  }

  Future<void> pickPhoto() async {
    try {
      final x = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (x == null) return;
      photoPath.value = x.path;
      _photoRemoved = false;
    } catch (_) {
      showError('ছবি নেওয়া যায়নি, আবার চেষ্টা করুন');
    }
  }

  void removePhoto() {
    photoPath.value = null;
    if (photoUrl.value != null) {
      photoUrl.value = null;
      _photoRemoved = true; // সম্পাদনায় সংরক্ষণের সময় সার্ভার থেকে মুছবে
    }
  }

  Future<void> changeArea() async {
    final result = await Get.toNamed('/location-permission');
    if (result is String && result.isNotEmpty) {
      area.value = result;
      _areaChanged = true;
      _lat = LocationSession.latitude;
      _lng = LocationSession.longitude;
    }
  }

  void changePhone() {
    phoneFocus.requestFocus();
    phoneCtrl.selection = TextSelection(
      baseOffset: 0,
      extentOffset: phoneCtrl.text.length,
    );
  }

  Future<void> start() async {
    if (isLoading.value) return;

    final name = nameCtrl.text.trim();
    final areaText = area.value.trim();

    if (name.length < 2) {
      showError('আপনার নাম লিখুন');
      return;
    }
    if (areaText.isEmpty) {
      showError('আপনার এলাকা বাছাই করুন');
      return;
    }

    // ফোন নম্বর শুধু তৈরির সময় লাগে। বাংলাদেশি মোবাইল: ০১ দিয়ে শুরু, মোট ১১ সংখ্যা
    var phone = '';
    if (!isEdit) {
      phone = toEn(phoneCtrl.text.trim());
      if (!RegExp(r'^01[3-9]\d{8}$').hasMatch(phone)) {
        showError('সঠিক ১১ সংখ্যার মোবাইল নম্বর দিন');
        return;
      }
    }

    isLoading.value = true;
    try {
      if (isEdit) {
        await _update(name, areaText);
      } else {
        await _create(name, areaText, phone);
      }
    } catch (e) {
      if (httpStatusOf(e) == 401) {
        StorageService.clearToken();
        Get.offAllNamed('/sign-in');
        showError('Session expired. Please sign in again.');
      } else {
        showError(apiErrorMessage(
          e,
          fallback: isEdit
              ? 'প্রোফাইল আপডেট করা যায়নি'
              : 'প্রোফাইল তৈরি করা যায়নি',
        ));
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _create(String name, String areaText, String phone) async {
    // এই নম্বর আগেই যাচাই হয়ে থাকলে আবার OTP চাইবে না
    if (_verifiedPhone != phone) {
      // ১) ফোনে OTP পাঠানো
      await _api.post(
        '/phone/send-otp/',
        headers: _auth,
        body: {'phone': phone},
      );

      // ২) OTP পেজ খোলে। যাচাই হলে true নিয়ে ফেরে, ব্যাক চাপলে null
      final verified = await Get.toNamed(
        '/otp',
        arguments: {'phone': phone, 'flow': 'profile'},
      );
      if (verified != true) return;
      _verifiedPhone = phone;
    }

    // ৩) প্রোফাইল তৈরি (নিচের কোড যেমন ছিল তেমনই থাকবে)
    final res = await _api.postMultipart(
      '/profile/create/',
      headers: _auth,
      fields: {
        'full_name': name,
        'area': areaText,
        'phone': phone,
        if (_lat != null) 'latitude': '$_lat',
        if (_lng != null) 'longitude': '$_lng',
      },
      fileField: 'image',
      filePath: photoPath.value,
    ) as Map<String, dynamic>;

    syncProfileSession(UserProfile.fromJson(res));

    // প্রোফাইল পেজ খোলে, নিচে হোম থাকে
    Get.offNamedUntil('/profile', (route) => route.settings.name == '/home');
    showSuccess('প্রোফাইল তৈরি হয়েছে');
  }

  Future<void> _update(String name, String areaText) async {
    // ১) নাম ও এলাকা
    var res = await _api.patch(
      '/profile/me/',
      headers: _auth,
      body: {
        'full_name': name,
        'area': areaText,
        if (_areaChanged && _lat != null) 'latitude': _lat,
        if (_areaChanged && _lng != null) 'longitude': _lng,
      },
    ) as Map<String, dynamic>;

    // ২) ছবি: নতুন বাছাই হলে আপলোড, মুছে ফেললে ডিলিট
    if (photoPath.value != null) {
      res = await _api.postMultipart(
        '/profile/me/photo/',
        headers: _auth,
        fileField: 'photo',
        filePath: photoPath.value,
      ) as Map<String, dynamic>;
    } else if (_photoRemoved) {
      res = await _api.delete('/profile/me/photo/', headers: _auth)
      as Map<String, dynamic>;
    }

    final p = UserProfile.fromJson(res);
    syncProfileSession(p);
    Get.back(result: p);
    showSuccess('প্রোফাইল আপডেট হয়েছে');
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();
    phoneFocus.dispose();
    super.onClose();
  }
}