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
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            // এলাকা বাছাই পেজ খোলে, ফিরে এলে নাম নিজে থেকেই বদলে যায়
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
                    Flexible(
                      child: Obx(() {
                        final name = controller.areaName.value;
                        return Text(
                          name.isEmpty ? 'এলাকা বাছুন' : name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: name.isEmpty
                                ? AppColors.textGrey
                                : AppColors.textDark,
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 8.w),
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