import 'package:get/get.dart';

class ProductDetailsController extends GetxController {
  final images = List.filled(8, 'assets/images/table.jpg');
  final currentImage = 0.obs;
  final isSaved = false.obs;
  final selectedReason = 0.obs;

  final reportReasons = const [
    'ভুয়া পোস্ট',
    'প্রতারণা',
    'আপত্তিকর কনটেন্ট',
    'অন্যান্য',
  ];

  void onPageChanged(int i) => currentImage.value = i;
  void toggleSave() => isSaved.toggle();
  void selectReason(int i) => selectedReason.value = i;

  void sendReport() {
    Get.back();
    Get.snackbar('ধন্যবাদ', 'আপনার রিপোর্ট পাঠানো হয়েছে');
  }

  void blockSeller() {
    Get.back();
    Get.snackbar('ব্লক করা হয়েছে', 'বিক্রেতাকে ব্লক করা হয়েছে');
  }
}