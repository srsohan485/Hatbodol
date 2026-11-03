import 'package:get/get.dart';

class MyPost {
  final String title;
  final String price;
  final String image;
  bool isSold;

  MyPost({
    required this.title,
    required this.price,
    required this.image,
    this.isSold = false,
  });
}

class ProfileController extends GetxController {
  final tabIndex = 0.obs;

  final myPosts = <MyPost>[
    MyPost(
      title: 'কাঠের পড়ার টেবিল',
      price: '৳ ৩,২০০',
      image: 'assets/images/table.jpg',
    ),
    MyPost(
      title: 'গল্পের বইয়ের সংগ্রহ',
      price: '৳ ৬৫০',
      image: 'assets/images/books.jpg',
      isSold: true,
    ),
    MyPost(
      title: 'আরামদায়ক অফিস চেয়ার',
      price: '৳ ২,৮০০',
      image: 'assets/images/chair.jpg',
    ),
  ].obs;

  void changeTab(int i) => tabIndex.value = i;

  void markAsSold(int i) {
    myPosts[i].isSold = true;
    myPosts.refresh();
  }

  void deletePost(int i) => myPosts.removeAt(i);
}