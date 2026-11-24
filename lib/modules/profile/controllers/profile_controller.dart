import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hatbodol/Services/ApiService.dart';
import 'package:hatbodol/Services/StorageService.dart';
import 'package:hatbodol/Services/location_session.dart';
import 'package:hatbodol/core/theme/app_colors.dart';
import 'package:hatbodol/core/utils/app_error.dart';
import 'package:hatbodol/core/utils/app_snackbar.dart';
import 'package:hatbodol/modules/profile/models/user_profile.dart';

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
  final _api = Get.find<ApiServices>();

  final tabIndex = 0.obs;

  final profile = Rxn<UserProfile>();
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  bool _deleting = false;

  // ⚠️ এখনো ডামি, "আমার পোস্ট" API পরের ধাপে জুড়ব
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

  Map<String, String> get _auth =>
      {'Authorization': 'Bearer ${StorageService.accessToken}'};

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    if (isLoading.value) return;
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final res = await _api.get('/profile/me/', headers: _auth)
      as Map<String, dynamic>;
      final p = UserProfile.fromJson(res);
      profile.value = p;
      syncProfileSession(p);
    } catch (e) {
      final code = httpStatusOf(e);
      if (code == 401) {
        StorageService.clearToken();
        Get.offAllNamed('/sign-in');
        showError('Session expired. Please sign in again.');
      } else if (code == 404) {
        // সার্ভারে প্রোফাইল নেই, তৈরি করতে পাঠাও
        resetProfileSession();
        Get.offNamed('/create-profile');
      } else {
        errorMessage.value =
            apiErrorMessage(e, fallback: 'প্রোফাইল লোড করা যায়নি');
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> editProfile() async {
    final p = profile.value;
    if (p == null) return;
    final result = await Get.toNamed(
      '/create-profile',
      arguments: {'edit': true, 'profile': p},
    );
    if (result is UserProfile) profile.value = result;
  }

  void confirmDeleteAccount() {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('অ্যাকাউন্ট মুছবেন?'),
        content: const Text(
          'আপনার প্রোফাইল মুছে যাবে এবং আপনি সাইন-আউট হয়ে যাবেন। '
              'এটি ফেরানো যাবে না।',
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('না')),
          TextButton(
            onPressed: () {
              Get.back();
              _deleteAccount();
            },
            child: Text('মুছুন', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount() async {
    if (_deleting) return;
    _deleting = true;
    try {
      await _api.delete('/profile/me/', headers: _auth); // 204, কোনো বডি নেই
      await StorageService.clearToken();
      await LocationSession.clear();
      resetProfileSession();
      Get.offAllNamed('/sign-in');
      showSuccess('প্রোফাইল মুছে ফেলা হয়েছে');
    } catch (e) {
      showError(apiErrorMessage(e, fallback: 'মোছা যায়নি, আবার চেষ্টা করুন'));
    } finally {
      _deleting = false;
    }
  }

  void changeTab(int i) => tabIndex.value = i;

  // ⚠️ নিচের দুটো এখনো শুধু অ্যাপের ভেতরে (ডামি)
  void markAsSold(int i) {
    myPosts[i].isSold = true;
    myPosts.refresh();
  }

  void deletePost(int i) => myPosts.removeAt(i);
}