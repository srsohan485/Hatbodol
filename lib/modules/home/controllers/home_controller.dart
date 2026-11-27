import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hatbodol/Services/ApiService.dart';
import 'package:hatbodol/Services/StorageService.dart';
import 'package:hatbodol/Services/location_session.dart';
import 'package:hatbodol/modules/profile/views/saved_products.dart';
import '../../../core/utils/app_error.dart';
import '../../../core/utils/app_snackbar.dart';
import '../models/product_model.dart';

class HomeController extends GetxController {
  final _api = Get.find<ApiServices>();

  // ⚠️ ব্যাকএন্ডের query param এর আসল নাম এখানে মিলিয়ে নিন
  static const _latParam = 'lat';
  static const _lngParam = 'lng';
  static const _radiusParam = 'radius';

  /// হেডারে দেখানোর এলাকার নাম (খালি থাকলে এখনো বাছাই হয়নি)
  RxString get areaName => LocationSession.areaName;

  /// প্রথমে ডিফল্ট তালিকা, API থেকে আসলে সেটা দিয়ে বদলে যাবে
  final categories = <String>[
    'সব',
    'বই',
    'ফোন',
    'ল্যাপটপ',
    'আসবাব',
    'অন্যান্য',
  ].obs;
  final selectedCategory = 0.obs;
  final currentIndex = 0.obs;

  // দূরত্ব
  final selectedDistance = 10.obs;
  final tempDistance = 10.obs;
  final distanceOptions = const [5, 10, 20];

  final products = <ProductModel>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final errorMessage = ''.obs;

  final scrollCtrl = ScrollController();
  int _page = 1;
  bool _hasNext = false;

  Map<String, String> get _authHeader =>
      {'Authorization': 'Bearer ${StorageService.accessToken}'};

  /// ক্যাটাগরি অনুযায়ী ফিল্টার করা তালিকা (Obx এর ভেতর থেকে ডাকতে হবে)
  List<ProductModel> get visibleProducts {
    if (selectedCategory.value == 0) return products.toList();
    final c = categories[selectedCategory.value];
    return products.where((p) => p.category == c).toList();
  }

  @override
  void onInit() {
    super.onInit();
    scrollCtrl.addListener(_onScroll);
    // এলাকা বদলালে ফিড নতুন করে লোড হবে
    ever(LocationSession.areaId, (_) => fetchProducts());
    fetchCategories();
    fetchProducts();
  }

  void _onScroll() {
    if (!scrollCtrl.hasClients) return;
    final pos = scrollCtrl.position;
    if (pos.pixels >= pos.maxScrollExtent - 300) loadMore();
  }

  /// /products/ এর URL: পেজ + (এলাকা বাছাই থাকলে) অবস্থান ও দূরত্ব
  String _productsUrl(int page) {
    final params = <String, String>{'page': '$page'};
    final lat = LocationSession.latitude;
    final lng = LocationSession.longitude;
    if (LocationSession.hasArea && lat != null && lng != null) {
      params[_latParam] = '$lat';
      params[_lngParam] = '$lng';
      params[_radiusParam] = '${selectedDistance.value}';
    }
    return '/products/?${Uri(queryParameters: params).query}';
  }

  /// ক্যাটাগরি তালিকা লোড। ফেল করলে ডিফল্ট তালিকাই থাকবে
  Future<void> fetchCategories() async {
    try {
      final res =
      await _api.get('/products/categories/', headers: _authHeader);
      final list = (res as List?) ?? [];
      final names = list
          .map((e) => ((e as Map)['name'] ?? '').toString())
          .where((n) => n.isNotEmpty)
          .toList();
      if (names.isEmpty) return;
      categories.assignAll(['সব', ...names]);
      selectedCategory.value = 0;
    } catch (_) {
      // নীরবে বাদ, ডিফল্ট ক্যাটাগরি দিয়েই চলবে
    }
  }

  /// প্রথম পেজ থেকে নতুন করে লোড (রিফ্রেশেও এটাই চলবে)
  Future<void> fetchProducts() async {
    if (isLoading.value) return;
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final res = await _api.get(_productsUrl(1), headers: _authHeader)
      as Map<String, dynamic>;
      final list = (res['results'] as List?) ?? [];
      products.assignAll(
        list.map((e) => ProductModel.fromJson(e as Map<String, dynamic>)),
      );
      SavedProducts.syncAll(products);
      _page = (res['page'] as num?)?.toInt() ?? 1;
      _hasNext = res['has_next'] == true;
    } catch (e) {
      _handleError(e, 'Could not load products.');
    } finally {
      isLoading.value = false;
    }
  }

  /// স্ক্রল শেষের কাছাকাছি গেলে পরের পেজ
  Future<void> loadMore() async {
    if (!_hasNext || isLoading.value || isLoadingMore.value) return;
    isLoadingMore.value = true;
    try {
      final res = await _api.get(_productsUrl(_page + 1),
          headers: _authHeader) as Map<String, dynamic>;
      final list = (res['results'] as List?) ?? [];
      products.addAll(
        list.map((e) => ProductModel.fromJson(e as Map<String, dynamic>)),
      );
      _page = (res['page'] as num?)?.toInt() ?? _page + 1;
      _hasNext = res['has_next'] == true;
    } catch (e) {
      _handleError(e, 'Could not load more products.', silent: true);
    } finally {
      isLoadingMore.value = false;
    }
  }

  /// error থেকে HTTP status code বের করে (না থাকলে null)
  int? _statusOf(Object e) {
    try {
      return (e as dynamic).statusCode as int?;
    } catch (_) {
      return null;
    }
  }

  void _handleError(Object e, String fallback, {bool silent = false}) {
    // টোকেনের মেয়াদ শেষ বা ভুল হলে আবার সাইন-ইনে পাঠাও
    if (_statusOf(e) == 401) {
      StorageService.clearToken();
      Get.offAllNamed('/sign-in');
      showError('Session expired. Please sign in again.');
      return;
    }
    final msg = apiErrorMessage(e, fallback: fallback);
    if (silent) {
      showError(msg);
    } else {
      errorMessage.value = msg;
    }
  }

  void selectCategory(int i) => selectedCategory.value = i;

  /// শিটে "বিজ্ঞাপন দেখুন" চাপলে: নতুন দূরত্ব ধরে ফিড আবার লোড
  void applyDistance() {
    selectedDistance.value = tempDistance.value;
    Get.back();
    if (!LocationSession.hasArea) {
      showError('দূরত্ব অনুযায়ী দেখতে আগে আপনার এলাকা বেছে নিন');
      return;
    }
    fetchProducts();
  }

  void changeTab(int i) {
    if (i == 1) {
      Get.toNamed('/search');
      return;
    }
    if (i == 2) {
      Get.toNamed('/new-post');
      return;
    }
    if (i == 3) {
      Get.toNamed('/profile');
      return;
    }
    currentIndex.value = i;
  }

  @override
  void onClose() {
    scrollCtrl.dispose();
    super.onClose();
  }
}