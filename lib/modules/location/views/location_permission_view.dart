import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../controllers/location_controller.dart';

class LocationPermissionView extends GetView<LocationController> {
  const LocationPermissionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: Get.back,
        ),
        title: Text(
          'আপনার এলাকা',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            children: [
              const Spacer(flex: 2),
              const _Illustration(),
              SizedBox(height: 28.h),
              Text(
                'আপনার এলাকা জানান',
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'আপনার কাছের পণ্য ও বিক্রেতা খুঁজে পেতে লোকেশন চালু করুন। '
                'চাইলে হাতেও এলাকা বেছে নিতে পারেন।',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.sp,
                  height: 1.5,
                  color: AppColors.textGrey,
                ),
              ),
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton.icon(
                  onPressed: controller.enableLocation,
                  icon: Icon(Icons.location_on_outlined, size: 18.sp),
                  label: Text(
                    'লোকেশন চালু করুন',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: OutlinedButton(
                  onPressed: controller.chooseManually,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  child: Text(
                    'হাতে এলাকা বেছে নিন',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 18.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.verified_user_outlined,
                      size: 16.sp, color: AppColors.primary),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'আপনার সঠিক ঠিকানা কাউকে দেখানো হবে না। '
                      'শুধু এলাকা ও আনুমানিক দূরত্ব দেখা হবে।',
                      style: TextStyle(
                        fontSize: 11.sp,
                        height: 1.4,
                        color: AppColors.textGrey,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _Illustration extends StatelessWidget {
  const _Illustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240.w,
      height: 150.h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 150.w,
            height: 150.w,
            decoration: const BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
          ),
          Transform.rotate(
            angle: -0.12,
            child: Container(
              width: 210.w,
              height: 100.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: AppColors.border),
              ),
            ),
          ),
          Container(
            width: 66.w,
            height: 66.w,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Icon(Icons.location_on_outlined,
                size: 34.sp, color: Colors.white),
          ),
        ],
      ),
    );
  }
}