import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NewPostController extends GetxController {
  final titleCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final descCtrl = TextEditingController();

  static const maxImages = 5;

  final categories = const ['বই', 'ফোন', 'ল্যাপটপ', 'আসবাব', 'অন্যান্য'];
  final selectedCategory = 'আসবাব'.obs;
  final isUsed = true.obs; // true = ব্যবহৃত, false = নতুন
  final images = <String>[].obs;
  final hasVideo = false.obs;

  void addPhoto() {
    if (images.length >= maxImages) {
      Get.snackbar('সীমা শেষ', 'সর্বোচ্চ ৫টি ছবি দেওয়া যাবে');
      return;
    }
    // TODO: image_picker দিয়ে আসল ছবি নেবে, এখন ডামি ছবি যোগ হচ্ছে
    images.add('assets/images/table.jpg');
  }

  void removePhoto(int i) => images.removeAt(i);

  void addVideo() {
    // TODO: image_picker দিয়ে ভিডিও নেবে (সর্বোচ্চ ৩০ সেকেন্ড)
    hasVideo.value = true;
  }

  void setCategory(String? v) {
    if (v != null) selectedCategory.value = v;
  }

  void setCondition(bool used) => isUsed.value = used;

  void publish() {
    if (titleCtrl.text.trim().isEmpty) {
      Get.snackbar('শিরোনাম লিখুন', 'পণ্যের নাম ছাড়া পোস্ট করা যাবে না');
      return;
    }
    if (priceCtrl.text.trim().isEmpty) {
      Get.snackbar('দাম লিখুন', 'পণ্যের দাম দিন');
      return;
    }
    // TODO: এখানে API-তে পোস্ট পাঠাবে
    Get.back();
    Get.snackbar('সফল', 'আপনার পোস্ট প্রকাশ হয়েছে');
  }

  @override
  void onClose() {
    titleCtrl.dispose();
    priceCtrl.dispose();
    descCtrl.dispose();
    super.onClose();
  }
}