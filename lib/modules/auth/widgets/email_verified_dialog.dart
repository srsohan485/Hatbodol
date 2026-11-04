import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import 'auth_button.dart';

class EmailVerifiedDialog extends StatelessWidget {
  final String email;
  const EmailVerifiedDialog({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.all(18.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle,
                size: 56.sp, color: const Color(0xFF1E9BF0)),
            SizedBox(height: 12.h),
            Text(
              'Email Verified !',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
            SizedBox(height: 14.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_outline,
                      size: 16.sp, color: AppColors.primary),
                  SizedBox(width: 6.w),
                  Flexible(
                    child: Text(
                      email,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'Your email address has been successfully verified',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11.sp, color: AppColors.textGrey),
            ),
            SizedBox(height: 18.h),
            AuthButton(
              label: 'Continue',
              onPressed: () => Get.offAllNamed('/home'),
            ),
          ],
        ),
      ),
    );
  }
}