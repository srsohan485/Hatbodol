import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../controllers/sign_in_controller.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/social_buttons.dart';

class SignInView extends GetView<SignInController> {
  const SignInView({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Sign In',
      children: [
        AuthTextField(
          controller: controller.emailCtrl,
          hint: 'Email',
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
        ),
        SizedBox(height: 12.h),
        AuthTextField(
          controller: controller.passCtrl,
          hint: 'Password',
          isPassword: true,
          textInputAction: TextInputAction.done,
        ),
        SizedBox(height: 16.h),
        Center(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Get.toNamed('/forgot-password'),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 4.h),
              child: Text(
                'Forgot password?',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textDark,
                ),
              ),
            ),
          ),
        ),
      ],
      bottom: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Obx(
            () => AuthButton(
              label: 'Sign In',
              loading: controller.isLoading.value,
              onPressed: controller.signIn,
            ),
          ),
          SizedBox(height: 16.h),
          const OrDivider(),
          SizedBox(height: 16.h),
          const SocialButtons(),
          SizedBox(height: 18.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Don't have an account? ",
                style: TextStyle(fontSize: 12.sp, color: AppColors.textGrey),
              ),
              GestureDetector(
                onTap: () => Get.offNamed('/sign-up'),
                child: Text(
                  'Sign Up',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}