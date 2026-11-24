import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hatbodol/Services/ApiService.dart';
import 'package:hatbodol/Services/StorageService.dart';
import 'package:hatbodol/Services/location_session.dart';
import 'package:hatbodol/core/utils/app_error.dart';
import 'package:hatbodol/core/utils/app_snackbar.dart';
import 'package:hatbodol/modules/profile/models/user_profile.dart';
import 'package:image_picker/image_picker.dart';

class CreateProfileController extends GetxController {
  final _api = Get.find<ApiServices>();
  final _picker = ImagePicker();

  final nameCtrl = TextEditingController();

  final area = ''.obs;
  final photoPath = RxnString(); // নতুন বাছাই করা ছবির ফাইল
  final photoUrl = RxnString(); // সার্ভারে থাকা ছবি (সম্পাদনার সময়)
  final isLoading = false.obs;

  bool isEdit = false;
  double? _lat;
  double? _lng;
  bool _areaChanged = false;
  bool _photoRemoved = false;

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

    isLoading.value = true;
    try {
      if (isEdit) {
        await _update(name, areaText);
      } else {
        await _create(name, areaText);
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

  Future<void> _create(String name, String areaText) async {
    final res = await _api.postMultipart(
      '/profile/create/',
      headers: _auth,
      fields: {
        'full_name': name,
        'area': areaText,
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
    super.onClose();
  }
}