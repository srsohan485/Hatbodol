import 'package:get/get.dart';

class SettingsController extends GetxController {
  final notificationOn = true.obs;

  void toggleNotification(bool v) => notificationOn.value = v;
}