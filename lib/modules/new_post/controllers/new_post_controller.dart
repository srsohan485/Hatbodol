import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hatbodol/Services/ApiService.dart';
import 'package:hatbodol/Services/StorageService.dart';
import 'package:hatbodol/Services/location_session.dart';
import 'package:hatbodol/core/services/profile_session.dart';
import 'package:hatbodol/core/utils/app_error.dart';
import 'package:hatbodol/core/utils/app_snackbar.dart';
import 'package:hatbodol/core/utils/bn_number.dart';
import 'package:hatbodol/modules/home/controllers/home_controller.dart';
import 'package:hatbodol/modules/profile/models/user_profile.dart';
import 'package:image_picker/image_picker.dart';

class NewPostController extends GetxController {
  final _api = Get.find<ApiServices>();
  final _picker = ImagePicker();

  final titleCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final descCtrl = TextEditingController();

  static const maxImages = 5;

  /// ক্যাটাগরির নাম (সার্ভার থেকে), আর নাম থেকে id এর মানচিত্র
  final categories = <String>[].obs;
  final selectedCategory = RxnString();
  final Map<String, int> _categoryIds = {};

  final isUsed = true.obs; // true = ব্যবহৃত, false = নতুন
  final images = <String>[].obs; // ফাইলের পাথ
  final videoPath = RxnString();
  final isLoading = false.obs;

  Map<String, String> get _auth =>
      {'Authorization': 'Bearer ${StorageService.accessToken}'};

  /// দেখানোর এলাকা: প্রোফাইলের এলাকা, না থাকলে বাছাই করা এলাকা
  /// (Obx এর ভেতর থেকে ডাকলে এলাকা বদলালে নিজে থেকে আপডেট হয়)
  String get areaName {
    final p = Get.find<ProfileSession>().area.value;
    return p.isNotEmpty ? p : LocationSession.areaName.value;
  }

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      final res =
      await _api.get('/products/categories/', headers: _auth) as List;
      _categoryIds.clear();
      for (final e in res) {
        final m = e as Map;
        final name = (m['name'] ?? '').toString();
        final id = (m['id'] as num?)?.toInt();
        if (name.isNotEmpty && id != null) _categoryIds[name] = id;
      }
      categories.assignAll(_categoryIds.keys);
      if (selectedCategory.value == null ||
          !_categoryIds.containsKey(selectedCategory.value)) {
        selectedCategory.value = _categoryIds.containsKey('আসবাব')
            ? 'আসবাব'
            : (categories.isEmpty ? null : categories.first);
      }
    } catch (_) {
      // নীরবে বাদ। পোস্ট করার সময় ক্যাটাগরি না থাকলে আবার চেষ্টা হবে
    }
  }

  // ─── ছবি ও ভিডিও ───
  Future<void> addPhoto() async {
    final remaining = maxImages - images.length;
    if (remaining <= 0) {
      showError('সর্বোচ্চ ৫টি ছবি দেওয়া যাবে');
      return;
    }
    try {
      final picked = await _picker.pickMultiImage(
        maxWidth: 1600,
        imageQuality: 85,
      );
      if (picked.isEmpty) return;
      images.addAll(picked.take(remaining).map((x) => x.path));
      if (picked.length > remaining) {
        showError('সর্বোচ্চ ৫টি ছবি, বাকিগুলো বাদ গেছে');
      }
    } catch (_) {
      showError('ছবি নেওয়া যায়নি, আবার চেষ্টা করুন');
    }
  }

  void removePhoto(int i) => images.removeAt(i);

  Future<void> addVideo() async {
    try {
      final x = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(seconds: 30),
      );
      if (x == null) return;
      videoPath.value = x.path;
    } catch (_) {
      showError('ভিডিও নেওয়া যায়নি, আবার চেষ্টা করুন');
    }
  }

  void removeVideo() => videoPath.value = null;

  void setCategory(String? v) {
    if (v != null) selectedCategory.value = v;
  }

  void setCondition(bool used) => isUsed.value = used;

  // ─── প্রকাশ ───
  Future<void> publish() async {
    if (isLoading.value) return;

    final title = titleCtrl.text.trim();
    final price = toEn(priceCtrl.text.trim());
    final catName = selectedCategory.value;
    final catId = catName == null ? null : _categoryIds[catName];

    if (title.length < 2) {
      showError('পণ্যের শিরোনাম লিখুন');
      return;
    }
    if (images.isEmpty) {
      showError('কমপক্ষে ১টি ছবি দিন');
      return;
    }
    if (!RegExp(r'^\d+$').hasMatch(price) || int.parse(price) <= 0) {
      showError('সঠিক দাম দিন');
      return;
    }
    if (catId == null) {
      showError('ক্যাটাগরি বাছাই করুন');
      fetchCategories();
      return;
    }

    final lat = LocationSession.latitude;
    final lng = LocationSession.longitude;
    final video = videoPath.value;

    isLoading.value = true;
    try {
      await _api.postMultipart(
        '/products/',
        headers: _auth,
        fields: {
          'title': title,
          'price': price,
          'category': '$catId',
          'condition': isUsed.value ? 'used' : 'new',
          'description': descCtrl.text.trim(),
          // বাছাই করা এলাকা থাকলে অবস্থান যাবে, যাতে দূরত্ব হিসাব হয়
          if (LocationSession.hasArea && lat != null && lng != null) ...{
            'latitude': '$lat',
            'longitude': '$lng',
          },
        },
        files: [
          for (final p in images) MapEntry('images', p),
          if (video != null) MapEntry('video', video),
        ],
        timeout: const Duration(minutes: 3), // ভিডিও আপলোডে সময় লাগে
      );

      // হোম ফিডে নতুন পোস্ট দেখাতে
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().fetchProducts();
      }
      Get.back();
      showSuccess('আপনার পোস্ট প্রকাশ হয়েছে');
    } catch (e) {
      if (httpStatusOf(e) == 401) {
        StorageService.clearToken();
        Get.offAllNamed('/sign-in');
        showError('Session expired. Please sign in again.');
      } else {
        showError(apiErrorMessage(
          e,
          fallback: 'পোস্ট করা যায়নি, আবার চেষ্টা করুন',
        ));
      }
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    titleCtrl.dispose();
    priceCtrl.dispose();
    descCtrl.dispose();
    super.onClose();
  }
}