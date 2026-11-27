import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hatbodol/Services/ApiService.dart';
import 'package:hatbodol/Services/StorageService.dart';
import 'package:hatbodol/Services/location_session.dart';
import 'package:hatbodol/core/theme/app_colors.dart';
import 'package:hatbodol/core/utils/app_error.dart';
import 'package:hatbodol/core/utils/app_snackbar.dart';
import 'package:hatbodol/modules/home/models/product_model.dart';
import 'package:hatbodol/modules/profile/models/user_profile.dart';
import 'package:hatbodol/modules/profile/views/saved_products.dart';

/// আমার পোস্টের একটি আইটেম (/products/mine/ এর results থেকে)
class MyPost {
  final int id;
  final ProductModel product; // শিরোনাম, দাম, ছবি এখান থেকে
  final String status; // active, sold ইত্যাদি

  MyPost({required this.id, required this.product, required this.status});

  factory MyPost.fromJson(Map<String, dynamic> j) => MyPost(
    id: (j['id'] as num?)?.toInt() ?? 0,
    product: ProductModel.fromJson(j),
    status: (j['status'] ?? '').toString(),
  );

  String get title => product.title;
  String get price => product.price;
  String get image => product.image;
  bool get isSold => status == 'sold';

  String get statusLabel {
    switch (status) {
      case 'active':
        return 'সক্রিয়';
      case 'sold':
        return 'বিক্রি সম্পন্ন';
      default:
        return status;
    }
  }
}

class ProfileController extends GetxController {
  final _api = Get.find<ApiServices>();

  final tabIndex = 0.obs;

  final profile = Rxn<UserProfile>();
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  bool _deleting = false;

  // আমার পোস্ট
  final myPosts = <MyPost>[].obs;
  final postsLoading = false.obs;
  final postsError = ''.obs;
  final deletingId = RxnInt(); // যে পোস্ট মোছা হচ্ছে
  // সেভ করা পোস্ট
  final savedPosts = <ProductModel>[].obs;
  final savedLoading = false.obs;
  final savedError = ''.obs;
  Map<String, String> get _auth =>
      {'Authorization': 'Bearer ${StorageService.accessToken}'};

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
    fetchMyPosts();
  }

  // ─── প্রোফাইল ───
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
        _sessionExpired();
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

  void _sessionExpired() {
    StorageService.clearToken();
    Get.offAllNamed('/sign-in');
    showError('Session expired. Please sign in again.');
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

  void changeTab(int i) {
    tabIndex.value = i;
    if (i == 1) fetchSaved(); // "সেভ করা" ট্যাবে গেলেই নতুন করে আনি
  }

  Future<void> fetchSaved() async {
    if (savedLoading.value) return;
    savedLoading.value = true;
    savedError.value = '';
    try {
      final res = await _api.get('/products/saved/', headers: _auth)
      as Map<String, dynamic>;
      final list = (res['results'] as List?) ?? [];
      final items = list
          .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList();
      savedPosts.assignAll(items);
      SavedProducts.syncAll(items);
    } catch (e) {
      if (httpStatusOf(e) == 401) {
        _sessionExpired();
      } else {
        savedError.value =
            apiErrorMessage(e, fallback: 'সেভ করা পোস্ট লোড করা যায়নি');
      }
    } finally {
      savedLoading.value = false;
    }
  }

  // ─── আমার পোস্ট ───
  Future<void> fetchMyPosts() async {
    if (postsLoading.value) return;
    postsLoading.value = true;
    postsError.value = '';
    try {
      final res = await _api.get('/products/mine/', headers: _auth)
      as Map<String, dynamic>;
      final list = (res['results'] as List?) ?? [];
      myPosts.assignAll(
        list.map((e) => MyPost.fromJson(e as Map<String, dynamic>)),
      );
    } catch (e) {
      if (httpStatusOf(e) == 401) {
        _sessionExpired();
      } else {
        postsError.value =
            apiErrorMessage(e, fallback: 'পোস্টগুলো লোড করা যায়নি');
      }
    } finally {
      postsLoading.value = false;
    }
  }

  void confirmDeletePost(MyPost p) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('পোস্ট মুছবেন?'),
        content: Text('"${p.title}" মুছে ফেলা হবে। এটি ফেরানো যাবে না।'),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('না')),
          TextButton(
            onPressed: () {
              Get.back();
              _deletePost(p);
            },
            child: Text('মুছুন', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }

  Future<void> _deletePost(MyPost p) async {
    if (deletingId.value != null) return;
    deletingId.value = p.id;
    try {
      // ⚠️ ধরে নিয়েছি URL: DELETE /products/{id}/ (Postman এর product delete মিলিয়ে নিন)
      await _api.delete('/products/${p.id}/', headers: _auth);
      myPosts.removeWhere((x) => x.id == p.id);
      showSuccess('পোস্ট মুছে ফেলা হয়েছে');
    } catch (e) {
      final code = httpStatusOf(e);
      if (code == 401) {
        _sessionExpired();
      } else if (code == 404) {
        // সার্ভারে আগেই নেই, তালিকা থেকেও সরিয়ে দিই
        myPosts.removeWhere((x) => x.id == p.id);
        showError('পোস্টটি আগেই মুছে ফেলা হয়েছে');
      } else {
        showError(apiErrorMessage(e, fallback: 'পোস্ট মোছা যায়নি'));
      }
    } finally {
      deletingId.value = null;
    }
  }

  // ⚠️ এখনো সংযুক্ত নয়: URL ও বডি জানা দরকার, তাই ভুয়া পরিবর্তন দেখাচ্ছি না
  Future<void> editPost(MyPost p) async {
    final saved = await Get.toNamed('/edit-post', arguments: {'id': p.id});
    if (saved == true) fetchMyPosts(); // আপডেটের পর তালিকা নতুন করে আনি
  }

  void _comingSoon() {
    Get.snackbar('শীঘ্রই আসছে', 'এই কাজটি এখনো সংযুক্ত করা হয়নি');
  }

  // ─── বিক্রি হয়েছে / আবার তালিকাভুক্ত ───
  final busyId = RxnInt(); // যে পোস্টের কাজ চলছে

  void confirmMarkSold(MyPost p) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('বিক্রি হয়ে গেছে?'),
        content: Text(
          '"${p.title}" বিক্রি সম্পন্ন হিসেবে চিহ্নিত হবে এবং '
              'আর কেনাবেচার তালিকায় দেখা যাবে না।',
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('না')),
          TextButton(
            onPressed: () {
              Get.back();
              _postAction(
                p,
                'mark-sold',
                okMsg: 'বিক্রি সম্পন্ন হিসেবে চিহ্নিত হয়েছে',
                failMsg: 'চিহ্নিত করা যায়নি, আবার চেষ্টা করুন',
              );
            },
            child: const Text('হ্যাঁ'),
          ),
        ],
      ),
    );
  }

  // ⚠️ ধরে নিয়েছি URL: POST /products/{id}/relist/ (Postman এর relist মিলিয়ে নিন)
  void relist(MyPost p) => _postAction(
    p,
    'relist',
    okMsg: 'পোস্টটি আবার তালিকায় যোগ হয়েছে',
    failMsg: 'আবার তালিকাভুক্ত করা যায়নি',
  );

  Future<void> _postAction(
      MyPost p,
      String action, {
        required String okMsg,
        required String failMsg,
      }) async {
    if (busyId.value != null) return;
    busyId.value = p.id;
    try {
      await _api.post('/products/${p.id}/$action/', headers: _auth);
      await fetchMyPosts(); // সার্ভারের আসল অবস্থা দেখাতে তালিকা নতুন করে আনি
      showSuccess(okMsg);
    } catch (e) {
      final code = httpStatusOf(e);
      if (code == 401) {
        _sessionExpired();
      } else if (code == 404) {
        myPosts.removeWhere((x) => x.id == p.id);
        showError('পোস্টটি খুঁজে পাওয়া যায়নি');
      } else {
        showError(apiErrorMessage(e, fallback: failMsg));
      }
    } finally {
      busyId.value = null;
    }
  }
}
