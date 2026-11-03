import 'package:get/get.dart';
import '../../home/models/product_model.dart';

class SellerProfileController extends GetxController {
  final name = 'রাফসান আহমেদ';
  final joinedAt = 'জানুয়ারি ২০২৪';
  final area = 'ধানমন্ডি, ঢাকা';
  final postCount = 12;

  final products = <ProductModel>[
    const ProductModel(
      title: 'কাঠের পড়ার টেবিল',
      price: '৳ ৩,২০০',
      distance: '১.২ কিমি দূর',
      image: 'assets/images/table.jpg',
      hasVideo: true,
    ),
    const ProductModel(
      title: 'স্যামসাং গ্যালাক্সি এ৫২',
      price: '৳ ৪,৫০০',
      distance: '০.৮ কিমি দূর',
      image: 'assets/images/phone.jpg',
    ),
    const ProductModel(
      title: 'গল্পের বইয়ের সংগ্রহ',
      price: '৳ ৬৫০',
      distance: '২.৫ কিমি দূর',
      image: 'assets/images/books.jpg',
    ),
    const ProductModel(
      title: 'আরামদায়ক অফিস চেয়ার',
      price: '৳ ২,৮০০',
      distance: '০.৫ কিমি দূর',
      image: 'assets/images/chair.jpg',
      hasVideo: true,
    ),
  ].obs;
}