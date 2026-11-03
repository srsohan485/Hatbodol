import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/bn_number.dart';
import '../controllers/home_controller.dart';
import 'distance_sheet.dart';

class HomeHeader extends GetView<HomeController> {
  const HomeHeader({super.key});

  void _openDistanceSheet() {
    controller.tempDistance.value = controller.selectedDistance.value;
    Get.bottomSheet(
      const DistanceSheet(),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Get.toNamed('/location-permission'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'আপনার এলাকা',
                style: TextStyle(fontSize: 11.sp, color: AppColors.textGrey),
              ),
              SizedBox(height: 2.h),
              Row(
                children: [
                  Icon(Icons.location_on,
                      size: 18.sp, color: AppColors.primary),
                  SizedBox(width: 4.w),
                  Text(
                    'ধানমন্ডি, ঢাকা',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _openDistanceSheet,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Row(
              children: [
                Obx(
                  () => Text(
                    '${toBn(controller.selectedDistance.value)} কিমির মধ্যে',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                SizedBox(width: 4.w),
                Icon(Icons.keyboard_arrow_down,
                    size: 18.sp, color: AppColors.primary),
              ],
            ),
          ),
        ),
      ],
    );
  }
}