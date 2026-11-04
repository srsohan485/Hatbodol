import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controllers/reset_password_controller.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/auth_text_field.dart';

class ResetPasswordView extends GetView<ResetPasswordController> {
  const ResetPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Reset Your Password',
      children: [
        AuthTextField(
          controller: controller.passCtrl,
          hint: 'Password',
          isPassword: true,
          textInputAction: TextInputAction.next,
        ),
        SizedBox(height: 12.h),
        AuthTextField(
          controller: controller.confirmCtrl,
          hint: 'Re-type your password',
          isPassword: true,
          textInputAction: TextInputAction.done,
        ),
      ],
      bottom: Obx(
        () => AuthButton(
          label: 'Confirm',
          loading: controller.isLoading.value,
          onPressed: controller.confirm,
        ),
      ),
    );
  }
}