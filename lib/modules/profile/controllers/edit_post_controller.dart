import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hatbodol/Services/ApiService.dart';
import 'package:hatbodol/Services/StorageService.dart';
import 'package:hatbodol/core/utils/app_error.dart';
import 'package:hatbodol/core/utils/app_snackbar.dart';
import 'package:hatbodol/core/utils/bn_number.dart';
import 'package:hatbodol/modules/profile/models/user_profile.dart';

class EditPostController extends GetxController {
  final _api = Get.find<ApiServices>();

  final titleCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final descCtrl = TextEditingController();

  final categories = <String>[].obs;
  final selectedCategory = RxnString();
  final Map<String, int> _categoryIds = {};

  final isUsed = true.obs; // true = ব্যবহৃত, false = নতুন
  final images = <String>[].obs; // বর্তমান ছবির URL (শুধু দেখার জন্য)

  final isLoading = false.obs; // পণ্যের তথ্য আনা হচ্ছে
  final isSaving = false.obs;
  final loaded = false.obs;
  final errorMessage = ''.obs;

  int? _id;

  Map<String, String> get _auth =>
      {'Authorization': 'Bearer ${StorageService.accessToken}'};

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map) _id = (args['id'] as num?)?.toInt();
    load();
  }

  Future<void> _loadCategories() async {
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
    } catch (_) {
      // নীরবে বাদ, নিচে পণ্যের ক্যাটাগরি না মিললে সংরক্ষণে বলা হবে
    }
  }

  Future<void> load() async {
    final id = _id;
    if (id == null || id == 0) {
      errorMessage.value = 'পোস্টটি খুঁজে পাওয়া যায়নি';
      return;
    }
    if (isLoading.value) return;

    isLoading.value = true;
    errorMessage.value = '';
    try {
      await _loadCategories();
      final res = await _api.get('/products/$id/', headers: _auth)
      as Map<String, dynamic>;

      if (res['is_mine'] != true) {
        errorMessage.value = 'এটি আপনার পোস্ট নয়';
        return;
      }

      titleCtrl.text = (res['title'] ?? '').toString();
      final price = num.tryParse('${res['price']}');
      priceCtrl.text = price == null ? '' : price.round().toString();
      descCtrl.text = (res['description'] ?? '').toString();
      isUsed.value = res['condition'] == 'used';

      // category_id থেকে ক্যাটাগরির নাম বের করা
      final catId = (res['category_id'] as num?)?.toInt();
      String? catName;
      _categoryIds.forEach((name, cid) {
        if (cid == catId) catName = name;
      });
      selectedCategory.value = catName;

      images.assignAll(
        ((res['images'] as List?) ?? [])
            .map((e) => ((e as Map)['url'] ?? '').toString())
            .where((u) => u.isNotEmpty),
      );
      loaded.value = true;
    } catch (e) {
      final code = httpStatusOf(e);
      if (code == 401) {
        _sessionExpired();
      } else if (code == 404) {
        errorMessage.value = 'পোস্টটি খুঁজে পাওয়া যায়নি';
      } else {
        errorMessage.value =
            apiErrorMessage(e, fallback: 'পোস্টের তথ্য আনা যায়নি');
      }
    } finally {
      isLoading.value = false;
    }
  }

  void _sessionExpired() {
    StorageService.clearToken();
    Get.offAllNamed('/sign-in');
    showError('Session expired. Please sign in again.');
  }

  void setCategory(String? v) {
    if (v != null) selectedCategory.value = v;
  }

  void setCondition(bool used) => isUsed.value = used;

  Future<void> save() async {
    if (isSaving.value || !loaded.value) return;

    final title = titleCtrl.text.trim();
    final price = toEn(priceCtrl.text.trim());
    final catName = selectedCategory.value;
    final catId = catName == null ? null : _categoryIds[catName];

    if (title.length < 2) {
      showError('পণ্যের শিরোনাম লিখুন');
      return;
    }
    if (!RegExp(r'^\d+$').hasMatch(price) || int.parse(price) <= 0) {
      showError('সঠিক দাম দিন');
      return;
    }
    if (catId == null) {
      showError('ক্যাটাগরি বাছাই করুন');
      return;
    }

    isSaving.value = true;
    try {
      await _api.patch(
        '/products/$_id/',
        headers: _auth,
        body: {
          'title': title,
          'price': int.parse(price),
          'category': catId,
          'condition': isUsed.value ? 'used' : 'new',
          'description': descCtrl.text.trim(),
        },
      );
      Get.back(result: true); // প্রোফাইল পেজ এই ফলাফল দেখে তালিকা নতুন করে আনবে
      showSuccess('পোস্ট আপডেট হয়েছে');
    } catch (e) {
      final code = httpStatusOf(e);
      if (code == 401) {
        _sessionExpired();
      } else if (code == 404) {
        showError('পোস্টটি খুঁজে পাওয়া যায়নি');
      } else {
        showError(apiErrorMessage(e, fallback: 'আপডেট করা যায়নি'));
      }
    } finally {
      isSaving.value = false;
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