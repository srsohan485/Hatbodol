import 'package:get/get.dart';

import '../controllers/forgot_password_controller.dart';
import '../controllers/otp_controller.dart';
import '../controllers/reset_password_controller.dart';
import '../controllers/sign_in_controller.dart';
import '../controllers/sign_up_controller.dart';

class SignInBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(() => SignInController());
}

class SignUpBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(() => SignUpController());
}

class ForgotPasswordBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(() => ForgotPasswordController());
}

class OtpBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(() => OtpController());
}

class ResetPasswordBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(() => ResetPasswordController());
}