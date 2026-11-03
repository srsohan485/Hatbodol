import 'package:get/get.dart';

class LocationController extends GetxController {
  void enableLocation() {
    // TODO: এখানে geolocator / permission_handler দিয়ে আসল পারমিশন চাইবে
    Get.offAllNamed('/home');
  }

  void chooseManually() {
    // TODO: এলাকা বাছাইয়ের পেজ/বটম শিট খুলবে
    Get.snackbar('এলাকা বাছুন', 'এলাকা বাছাইয়ের পেজ এখনো বানানো হয়নি');
  }
}