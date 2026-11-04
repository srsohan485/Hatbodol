import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/forgot_password_controller.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/auth_text_field.dart';

class ForgotPasswordView extends GetView<ForgotPasswordController> {
  const ForgotPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Forgot Password',
      children: [
        AuthTextField(
          controller: controller.emailCtrl,
          hint: 'Email',
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
        ),
      ],
      bottom: Obx(
        () => AuthButton(
          label: 'Send OTP',
          loading: controller.isLoading.value,
          onPressed: controller.sendOtp,
        ),
      ),
    );
  }
}