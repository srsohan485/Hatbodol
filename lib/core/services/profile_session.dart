import 'package:get/get.dart';

/// প্রোফাইল তৈরি হয়েছে কি না আর প্রোফাইলের তথ্য এখানে থাকে।
/// TODO: এখন শুধু মেমোরিতে আছে, অ্যাপ বন্ধ করলে মুছে যায়।
/// স্থায়ী করতে get_storage বা shared_preferences ব্যবহার করবে।
class ProfileSession extends GetxService {
  final isCreated = false.obs;
  final name = ''.obs;
  final area = ''.obs;
  final phone = ''.obs;
  final photo = RxnString();

  /// OTP যাচাইয়ের আগে তথ্য খসড়া হিসেবে রাখে
  void setDraft({
    required String name,
    required String area,
    required String phone,
    String? photo,
  }) {
    this.name.value = name;
    this.area.value = area;
    this.phone.value = phone;
    this.photo.value = photo;
  }

  /// OTP ঠিক হলে ডাকা হয়
  void complete() => isCreated.value = true;
}