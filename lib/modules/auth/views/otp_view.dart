import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../controllers/otp_controller.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/auth_text_field.dart';

class OtpView extends GetView<OtpController> {
  const OtpView({super.key});

  @override
  Widget build(BuildContext context) {
    final small = TextStyle(fontSize: 10.sp, color: AppColors.textGrey);

    return AuthScaffold(
      title: 'Enter OTP',
      children: [
        AuthTextField(
          controller: controller.otpCtrl,
          hint: 'Enter 6 digit OTP',
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          maxLength: 6,
        ),
      ],
      bottom: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'We sent a verification code to your email. Please check.',
            textAlign: TextAlign.center,
            style: small,
          ),
          SizedBox(height: 2.h),
          Obx(() {
            final time = controller.timeText;
            final canResend = controller.canResend;
            return Wrap(
              alignment: WrapAlignment.center,
              children: [
                Text('If not, resend in ', style: small),
                Text(
                  time,
                  style: small.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
                Text(' minutes. ', style: small),
                GestureDetector(
                  onTap: controller.resend,
                  child: Text(
                    'Resend',
                    style: small.copyWith(
                      fontWeight: FontWeight.w800,
                      decoration: TextDecoration.underline,
                      color: canResend
                          ? AppColors.textDark
                          : AppColors.textGrey,
                    ),
                  ),
                ),
              ],
            );
          }),
          SizedBox(height: 14.h),
          Obx(
            () => AuthButton(
              label: 'Submit',
              loading: controller.isLoading.value,
              onPressed: controller.submit,
            ),
          ),
        ],
      ),
    );
  }
}