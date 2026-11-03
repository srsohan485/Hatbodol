import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';

class SafetyTipDialog extends StatelessWidget {
  /// "বুঝেছি, এগিয়ে যান" চাপলে যা করবে (কল বা এসএমএস)
  final VoidCallback onConfirm;
  const SafetyTipDialog({super.key, required this.onConfirm});

  static const _tips = [
    'অগ্রিম টাকা পাঠাবেন না',
    'সামনাসামনি দেখে কিনুন',
    'পণ্য যাচাই করে টাকা দিন',
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
      child: Padding(
        padding: EdgeInsets.all(18.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(Icons.verified_user_outlined,
                  size: 22.sp, color: AppColors.primary),
            ),
            SizedBox(height: 12.h),
            Text(
              'নিরাপদে কেনাবেচা করুন',
              style: TextStyle(
                fontSize: 19.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'বিক্রেতার সঙ্গে যোগাযোগের আগে এই বিষয়গুলো মনে রাখুন।',
              style: TextStyle(fontSize: 12.sp, color: AppColors.textGrey),
            ),
            SizedBox(height: 14.h),
            ..._tips.map(
              (t) => Padding(
                padding: EdgeInsets.only(bottom: 10.h),
                child: Row(
                  children: [
                    Container(
                      width: 20.w,
                      height: 20.w,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(5.r),
                        border: Border.all(color: AppColors.primary),
                      ),
                      child: Icon(Icons.check,
                          size: 14.sp, color: AppColors.primary),
                    ),
                    SizedBox(width: 10.w),
                    Text(
                      t,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 6.h),
            SizedBox(
              width: double.infinity,
              height: 46.h,
              child: ElevatedButton(
                onPressed: () {
                  Get.back();
                  onConfirm();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                child: Text(
                  'বুঝেছি, এগিয়ে যান',
                  style:
                      TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            SizedBox(height: 4.h),
            Center(
              child: TextButton(
                onPressed: Get.back,
                child: Text(
                  'এখন নয়',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}