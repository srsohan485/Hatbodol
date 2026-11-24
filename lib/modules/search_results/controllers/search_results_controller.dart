import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hatbodol/Services/ApiService.dart';
import 'package:hatbodol/Services/StorageService.dart';
import 'package:hatbodol/Services/location_session.dart';
import 'package:hatbodol/core/utils/app_error.dart';
import 'package:hatbodol/core/utils/app_snackbar.dart';
import 'package:hatbodol/modules/home/models/product_model.dart';

class SearchItem {
  final String title;
  final int price;
  final double distanceKm;
  final String image;
  final String category;
  final bool isUsed;

  const SearchItem({
    required this.title,
    required this.price,
    required this.distanceKm,
    required this.image,
    required this.category,
    required this.isUsed,
  });
}



class SearchResultsController extends GetxController {
  final _api = Get.find<ApiServices>();

  // query param এর নাম। ⚠️ lat/lng/radius ব্যাকএন্ডের সাথে মিলিয়ে নিন
  static const _queryParam = 'q';
  static const _latParam = 'lat';
  static const _lngParam = 'lng';
  static const _radiusParam = 'radius';

  static const maxPrice = 65000.0;

  final categories = <String>[
    'সব',
    'বই',
    'ফোন',
    'ল্যাপটপ',
    'আসবাব',
    'অন্যান্য',
  ].obs;
  final distanceOptions = const [5, 10, 20];

  // সার্চ বক্স
  final queryCtrl = TextEditingController();
  final queryFocus = FocusNode();
  final query = ''.obs;

  // প্রয়োগ করা ফিল্টার
  final category = 'সব'.obs;
  final priceRange = const RangeValues(0, maxPrice).obs;
  final distance = 10.obs;
  final condition = RxnBool(); // true = ব্যবহৃত, false = নতুন, null = সব

  // শিটে বাছাই করা (বাটন চাপার আগ পর্যন্ত)
  final tCategory = 'সব'.obs;
  final tRange = const RangeValues(0, maxPrice).obs;
  final tDistance = 10.obs;
  final tCondition = RxnBool();

  // সার্ভার থেকে আসা ফলাফল
  final items = <ProductModel>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final errorMessage = ''.obs;

  final scrollCtrl = ScrollController();
  int _page = 1;
  bool _hasNext = false;
  int _reqId = 0; // পুরনো রেসপন্স বাদ দিতে
  late final Worker _queryWorker;

  Map<String, String> get _authHeader =>
      {'Authorization': 'Bearer ${StorageService.accessToken}'};

  @override
  void onInit() {
    super.onInit();
    // ডিজাইনের মতো শুরুতে "ব্যবহৃত" বাছাই করা থাকবে
    condition.value = true;
    scrollCtrl.addListener(_onScroll);
    // টাইপ থামার ০.৪ সেকেন্ড পরে সার্চ
    _queryWorker = debounce(
      query,
          (_) => fetchResults(),
      time: const Duration(milliseconds: 400),
    );
    fetchCategories();
    fetchResults();
  }

  /// Obx-এর ভেতর থেকে ডাকতে হবে। সার্ভারের ফলাফলের উপর
  /// ক্যাটাগরি, দাম ও অবস্থার ফিল্টার অ্যাপে প্রয়োগ হয়।
  List<ProductModel> get results {
    final cat = category.value;
    final range = priceRange.value;
    final km = distance.value;
    final cond = condition.value;

    return items.where((p) {
      if (cat != 'সব' && p.category != cat) return false;
      if (p.priceValue < range.start) return false;
      if (range.end < maxPrice && p.priceValue > range.end) return false;
      if (p.distanceKm != null && p.distanceKm! > km) return false;
      if (cond != null && p.isUsed != cond) return false;
      return true;
    }).toList();
  }

  String _url(int page) {
    final params = <String, String>{'page': '$page'};
    final q = query.value.trim();
    if (q.isNotEmpty) params[_queryParam] = q;

    final lat = LocationSession.latitude;
    final lng = LocationSession.longitude;
    if (LocationSession.hasArea && lat != null && lng != null) {
      params[_latParam] = '$lat';
      params[_lngParam] = '$lng';
      params[_radiusParam] = '${distance.value}';
    }
    // Uri বাংলা অক্ষর নিরাপদে এনকোড করে
    return '/products/?${Uri(queryParameters: params).query}';
  }

  Future<void> fetchCategories() async {
    try {
      final res =
      await _api.get('/products/categories/', headers: _authHeader);
      final names = ((res as List?) ?? [])
          .map((e) => ((e as Map)['name'] ?? '').toString())
          .where((n) => n.isNotEmpty)
          .toList();
      if (names.isEmpty) return;
      categories.assignAll(['সব', ...names]);
    } catch (_) {
      // ডিফল্ট ক্যাটাগরি দিয়েই চলবে
    }
  }

  /// প্রথম পেজ থেকে নতুন করে সার্চ
  Future<void> fetchResults() async {
    final id = ++_reqId;
    isLoading.value = true;
    isLoadingMore.value = false;
    errorMessage.value = '';
    try {
      final res = await _api.get(_url(1), headers: _authHeader)
      as Map<String, dynamic>;
      if (id != _reqId) return; // এর মধ্যে নতুন সার্চ শুরু হয়ে গেছে
      final list = (res['results'] as List?) ?? [];
      items.assignAll(
        list.map((e) => ProductModel.fromJson(e as Map<String, dynamic>)),
      );
      _page = (res['page'] as num?)?.toInt() ?? 1;
      _hasNext = res['has_next'] == true;
    } catch (e) {
      if (id != _reqId) return;
      _handleError(e, 'Search failed. Please try again.');
    } finally {
      if (id == _reqId) isLoading.value = false;
    }
  }

  void _onScroll() {
    if (!scrollCtrl.hasClients) return;
    final pos = scrollCtrl.position;
    if (pos.pixels >= pos.maxScrollExtent - 300) loadMore();
  }

  Future<void> loadMore() async {
    if (!_hasNext || isLoading.value || isLoadingMore.value) return;
    final id = _reqId;
    isLoadingMore.value = true;
    try {
      final res = await _api.get(_url(_page + 1), headers: _authHeader)
      as Map<String, dynamic>;
      if (id != _reqId) return;
      final list = (res['results'] as List?) ?? [];
      items.addAll(
        list.map((e) => ProductModel.fromJson(e as Map<String, dynamic>)),
      );
      _page = (res['page'] as num?)?.toInt() ?? _page + 1;
      _hasNext = res['has_next'] == true;
    } catch (e) {
      if (id != _reqId) return;
      _handleError(e, 'Could not load more results.', silent: true);
    } finally {
      isLoadingMore.value = false;
    }
  }

  int? _statusOf(Object e) {
    try {
      return (e as dynamic).statusCode as int?;
    } catch (_) {
      return null;
    }
  }

  void _handleError(Object e, String fallback, {bool silent = false}) {
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

  void onQueryChanged(String v) => query.value = v;

  void clearQuery() {
    queryCtrl.clear();
    query.value = '';
  }

  /// শিট খোলার আগে প্রয়োগ করা মান শিটে কপি করে
  void prepareFilter() {
    tCategory.value = category.value;
    tRange.value = priceRange.value;
    tDistance.value = distance.value;
    tCondition.value = condition.value;
  }

  void applyFilter() {
    category.value = tCategory.value;
    priceRange.value = tRange.value;
    distance.value = tDistance.value;
    condition.value = tCondition.value;
    Get.back();
    fetchResults(); // দূরত্ব সার্ভারে যায়, তাই আবার লোড
  }

  void resetFilter() {
    tCategory.value = 'সব';
    tRange.value = const RangeValues(0, maxPrice);
    tDistance.value = 10;
    tCondition.value = null;
  }

  void setCondition(bool used) {
    // একই বাটনে আবার চাপলে বাছাই উঠে যাবে
    tCondition.value = tCondition.value == used ? null : used;
  }

  @override
  void onClose() {
    _queryWorker.dispose();
    scrollCtrl.dispose();
    queryCtrl.dispose();
    queryFocus.dispose();
    super.onClose();
  }
}
