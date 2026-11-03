import 'package:get/get.dart';

import '../models/product_model.dart';

class HomeController extends GetxController {
  final categories = const ['সব', 'বই', 'ফোন', 'ল্যাপটপ', 'আসবাব', 'অন্যান্য'];
  final selectedCategory = 0.obs;
  final currentIndex = 0.obs;

  // দূরত্ব
  final selectedDistance = 10.obs; // প্রয়োগ করা দূরত্ব
  final tempDistance = 10.obs; // শিটে বাছাই করা, বাটন চাপার আগ পর্যন্ত
  final distanceOptions = const [5, 10, 20];

  final products = <ProductModel>[].obs;

  static const _sample = <ProductModel>[
    ProductModel(
      title: 'কাঠের পড়ার টেবিল',
      price: '৳ ৩,২০০',
      distance: '১.২ কিমি দূর',
      image: 'assets/images/table.jpg',
      hasVideo: true,
    ),
    ProductModel(
      title: 'স্যামসাং গ্যালাক্সি এ৫২',
      price: '৳ ৪,৫০০',
      distance: '০.৮ কিমি দূর',
      image: 'assets/images/phone.jpg',
    ),
    ProductModel(
      title: 'গল্পের বইয়ের সংগ্রহ',
      price: '৳ ৬৫০',
      distance: '২.৫ কিমি দূর',
      image: 'assets/images/books.jpg',
    ),
    ProductModel(
      title: 'আরামদায়ক অফিস চেয়ার',
      price: '৳ ২,৮০০',
      distance: '০.৫ কিমি দূর',
      image: 'assets/images/chair.jpg',
      hasVideo: true,
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    // টেস্টের জন্য ২৪টা আইটেম, পরে এখানে API-র ডেটা বসবে
    products.assignAll(List.generate(24, (i) => _sample[i % _sample.length]));
  }

  void selectCategory(int i) => selectedCategory.value = i;

  void applyDistance() {
    selectedDistance.value = tempDistance.value;
    Get.back();
    // TODO: নতুন দূরত্ব দিয়ে প্রোডাক্ট লিস্ট আবার লোড হবে
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
}