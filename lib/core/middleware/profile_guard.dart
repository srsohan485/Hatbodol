import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../services/profile_session.dart';

/// প্রোফাইল তৈরি না থাকলে `/profile` খুলতে গেলে `/create-profile`-এ পাঠায়।
/// এক জায়গায় বসালেই হোম, সার্চ, চ্যাট, সব পেজের নেভিগেশনে কাজ করে।
class ProfileGuard extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final session = Get.find<ProfileSession>();
    if (session.isCreated.value) return null;
    return const RouteSettings(name: '/create-profile');
  }
}