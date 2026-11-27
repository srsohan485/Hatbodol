import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hatbodol/Services/ApiService.dart';
import 'package:hatbodol/Services/StorageService.dart';
import 'package:hatbodol/Services/safety_tips.dart';
import 'package:hatbodol/modules/home/controllers/home_controller.dart';
import 'package:hatbodol/modules/profile/views/saved_products.dart';

import '../../../core/utils/app_error.dart';
import '../../../core/utils/app_snackbar.dart';
import '../models/product_detail_model.dart';

/// রিপোর্টের একটি কারণ: value সার্ভারে যায়, label ইউজার দেখে
class ReportReason {
  final String value;
  final String label;
  const ReportReason(this.value, this.label);
}

class ProductDetailsController extends GetxController {
  final _api = Get.find<ApiServices>();

  final product = Rxn<ProductDetail>();
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  final currentImage = 0.obs;
  final isSaved = false.obs;

  // রিপোর্ট। শুরুতে ডিফল্ট কারণ, সার্ভার থেকে আসলে বদলে যায়
  final reportReasons = <ReportReason>[
    const ReportReason('fake', 'ভুয়া পোস্ট'),
    const ReportReason('fraud', 'প্রতারণা'),
    const ReportReason('inappropriate', 'আপত্তিকর কনটেন্ট'),
    const ReportReason('other', 'অন্যান্য'),
  ].obs;
  final selectedReason = 0.obs;
  final isReporting = false.obs;
  final isBlocking = false.obs;

  int? _id;

  Map<String, String> get _authHeader =>
      {'Authorization': 'Bearer ${StorageService.accessToken}'};

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map) _id = (args['id'] as num?)?.toInt();
    fetchProduct();
    _loadReportReasons();
    SafetyTips.load();
  }

  // ─── পণ্যের তথ্য ───
  Future<void> fetchProduct() async {
    final id = _id;
    if (id == null || id == 0) {
      errorMessage.value = 'পণ্যটি খুঁজে পাওয়া যায়নি';
      return;
    }
    if (isLoading.value) return;

    isLoading.value = true;
    errorMessage.value = '';
    try {
      final res = await _api.get('/products/$id/', headers: _authHeader)
      as Map<String, dynamic>;
      final p = ProductDetail.fromJson(res);
      product.value = p;
      isSaved.value = p.isSaved;
      SavedProducts.set(id, p.isSaved); // হোমের হার্টও যেন মেলে
      currentImage.value = 0;
    } catch (e) {
      final code = _statusOf(e);
      if (code == 401) {
        _sessionExpired();
      } else if (code == 404) {
        errorMessage.value =
        'পণ্যটি খুঁজে পাওয়া যায়নি (সম্ভবত মুছে ফেলা হয়েছে)';
      } else {
        errorMessage.value =
            apiErrorMessage(e, fallback: 'Could not load product details.');
      }
    } finally {
      isLoading.value = false;
    }
  }

  int? _statusOf(Object e) {
    try {
      return (e as dynamic).statusCode as int?;
    } catch (_) {
      return null;
    }
  }

  void _sessionExpired() {
    StorageService.clearToken();
    Get.offAllNamed('/sign-in');
    showError('Session expired. Please sign in again.');
  }

  /// ৪০১ হলে সাইন-ইনে পাঠায়, নইলে সার্ভারের মেসেজ দেখায়
  void _showApiError(Object e, String fallback) {
    if (_statusOf(e) == 401) {
      _sessionExpired();
    } else {
      showError(apiErrorMessage(e, fallback: fallback));
    }
  }

  void onPageChanged(int i) => currentImage.value = i;

  // ─── সেভ ───
  /// সেভ/আনসেভ। সাথে সাথে হার্ট বদলায়, ব্যর্থ হলে আগের অবস্থায় ফেরে
  Future<void> toggleSave() async {
    final id = _id;
    if (id == null || id == 0) return;

    final before = isSaved.value;
    isSaved.value = !before;
    isSaved.value = await SavedProducts.toggle(id, before);
  }

  // ─── রিপোর্ট ───
  Future<void> _loadReportReasons() async {
    try {
      final res =
      await _api.get('/products/report-reasons/', headers: _authHeader);
      final list = ((res as List?) ?? [])
          .map((e) {
        final m = e as Map;
        return ReportReason(
          (m['value'] ?? '').toString(),
          (m['label'] ?? '').toString(),
        );
      })
          .where((r) => r.value.isNotEmpty && r.label.isNotEmpty)
          .toList();
      if (list.isEmpty) return;
      reportReasons.assignAll(list);
      selectedReason.value = 0;
    } catch (_) {
      // নীরবে বাদ, ডিফল্ট কারণ দিয়েই চলবে
    }
  }

  void selectReason(int i) => selectedReason.value = i;

  Future<void> sendReport() async {
    final id = _id;
    if (id == null || id == 0 || isReporting.value) return;

    final i = selectedReason.value;
    if (i < 0 || i >= reportReasons.length) {
      showError('রিপোর্টের কারণ বাছাই করুন');
      return;
    }

    isReporting.value = true;
    try {
      await _api.post(
        '/products/$id/report/',
        headers: _authHeader,
        body: {'reason': reportReasons[i].value},
      );
      if (Get.isDialogOpen == true) Get.back(); // রিপোর্ট ডায়ালগ বন্ধ
      showSuccess('আপনার রিপোর্ট পাঠানো হয়েছে। ধন্যবাদ');
    } catch (e) {
      _showApiError(e, 'রিপোর্ট পাঠানো যায়নি, আবার চেষ্টা করুন');
    } finally {
      isReporting.value = false;
    }
  }

  // ─── ব্লক / আনব্লক ───
  /// রিপোর্ট ডায়ালগের "বিক্রেতাকে ব্লক করুন" বাটন
  void blockSeller() {
    final p = product.value;
    if (p == null) return;

    Get.back(); // রিপোর্ট ডায়ালগ বন্ধ
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('বিক্রেতাকে ব্লক করবেন?'),
        content: Text(
          '${p.seller.name} কে ব্লক করলে তার পোস্ট আপনার কাছে আর দেখানো হবে না। '
              'পরে চাইলে আনব্লক করা যাবে।',
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('না')),
          TextButton(
            onPressed: () {
              Get.back();
              _doBlock(p.seller.id, p.seller.name);
            },
            child: const Text('ব্লক করুন'),
          ),
        ],
      ),
    );
  }

  Future<void> _doBlock(int sellerId, String name) async {
    if (isBlocking.value) return;
    if (sellerId == 0) {
      showError('বিক্রেতাকে চেনা যায়নি');
      return;
    }

    isBlocking.value = true;
    try {
      await _api.post('/products/block/$sellerId/', headers: _authHeader);
      _refreshHome();
      Get.back(); // এই পেজ বন্ধ, কারণ বিক্রেতা এখন ব্লক
      Get.snackbar(
        'ব্লক করা হয়েছে',
        '$name কে ব্লক করা হয়েছে',
        duration: const Duration(seconds: 6),
        mainButton: TextButton(
          onPressed: () => _unblock(sellerId),
          child: const Text('আনব্লক'),
        ),
      );
    } catch (e) {
      _showApiError(e, 'ব্লক করা যায়নি, আবার চেষ্টা করুন');
    } finally {
      if (!isClosed) isBlocking.value = false;
    }
  }

  Future<void> _unblock(int sellerId) async {
    try {
      await _api.delete('/products/block/$sellerId/', headers: _authHeader);
      _refreshHome();
      showSuccess('আনব্লক করা হয়েছে');
    } catch (e) {
      _showApiError(e, 'আনব্লক করা যায়নি');
    }
  }

  /// ব্লক বদলালে হোম ফিডে কোন পণ্য দেখাবে সেটাও বদলায়
  void _refreshHome() {
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().fetchProducts();
    }
  }
}