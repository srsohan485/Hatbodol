import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../controllers/sign_up_controller.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/social_buttons.dart';

class SignUpView extends GetView<SignUpController> {
  const SignUpView({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Sign Up',
      children: [
        AuthTextField(
          controller: controller.usernameCtrl,
          hint: 'Username',
          textInputAction: TextInputAction.next,
        ),
        SizedBox(height: 12.h),
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
      bottom: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Text(
              'By clicking the "Sign Up" button, you accept the terms of the '
              'Privacy Policy.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10.sp,
                height: 1.4,
                color: AppColors.textGrey,
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Obx(
            () => AuthButton(
              label: 'Sign Up',
              loading: controller.isLoading.value,
              onPressed: controller.signUp,
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
                'Already have an account? ',
                style: TextStyle(fontSize: 12.sp, color: AppColors.textGrey),
              ),
              GestureDetector(
                onTap: () => Get.offNamed('/sign-in'),
                child: Text(
                  'Sign in',
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