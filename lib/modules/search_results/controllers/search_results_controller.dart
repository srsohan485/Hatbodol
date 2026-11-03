import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
  static const maxPrice = 65000.0;

  final categories = const ['সব', 'বই', 'ফোন', 'ল্যাপটপ', 'আসবাব', 'অন্যান্য'];
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

  // ডামি ডেটা, পরে এখানে API-র ডেটা বসবে
  static const _all = <SearchItem>[
    SearchItem(
      title: 'কাঠের পড়ার টেবিল',
      price: 3200,
      distanceKm: 1.2,
      image: 'assets/images/table.jpg',
      category: 'আসবাব',
      isUsed: true,
    ),
    SearchItem(
      title: 'স্যামসাং গ্যালাক্সি এ৫২',
      price: 4500,
      distanceKm: 0.8,
      image: 'assets/images/phone.jpg',
      category: 'ফোন',
      isUsed: true,
    ),
    SearchItem(
      title: 'গল্পের বইয়ের সংগ্রহ',
      price: 650,
      distanceKm: 2.5,
      image: 'assets/images/books.jpg',
      category: 'বই',
      isUsed: true,
    ),
    SearchItem(
      title: 'আরামদায়ক অফিস চেয়ার',
      price: 2800,
      distanceKm: 0.5,
      image: 'assets/images/chair.jpg',
      category: 'আসবাব',
      isUsed: false,
    ),
    SearchItem(
      title: 'ডেল ল্যাপটপ',
      price: 38000,
      distanceKm: 15,
      image: 'assets/images/phone.jpg',
      category: 'ল্যাপটপ',
      isUsed: true,
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    // ডিজাইনের মতো শুরুতে "ব্যবহৃত" বাছাই করা থাকবে
    condition.value = true;
  }

  /// Obx-এর ভেতর থেকে ডাকতে হবে। সব Rx আগে পড়ে নেওয়া হয়েছে,
  /// যাতে যেকোনো ফিল্টার বদলালে তালিকা আবার আঁকা হয়।
  List<SearchItem> get results {
    final q = query.value.trim();
    final cat = category.value;
    final range = priceRange.value;
    final km = distance.value;
    final cond = condition.value;

    return _all.where((e) {
      if (q.isNotEmpty && !e.title.contains(q)) return false;
      if (cat != 'সব' && e.category != cat) return false;
      if (e.price < range.start || e.price > range.end) return false;
      if (e.distanceKm > km) return false;
      if (cond != null && e.isUsed != cond) return false;
      return true;
    }).toList();
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
    queryCtrl.dispose();
    queryFocus.dispose();
    super.onClose();
  }
}
