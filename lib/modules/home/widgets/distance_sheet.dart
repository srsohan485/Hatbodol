import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/bn_number.dart';
import '../controllers/home_controller.dart';

class DistanceSheet extends GetView<HomeController> {
  const DistanceSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 16.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'কত দূরে খুঁজতে চান?',
              style: TextStyle(
                fontSize: 19.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'ধানমন্ডি, ঢাকা থেকে আশেপাশের বিজ্ঞাপন',
              style: TextStyle(fontSize: 12.sp, color: AppColors.textGrey),
            ),
            SizedBox(height: 14.h),
            Obx(() {
              final temp = controller.tempDistance.value;
              return Column(
                children: controller.distanceOptions.map((km) {
                  final selected = temp == km;
                  return GestureDetector(
                    onTap: () => controller.tempDistance.value = km,
                    child: Container(
                      margin: EdgeInsets.only(bottom: 8.h),
                      padding: EdgeInsets.symmetric(
                          horizontal: 14.w, vertical: 14.h),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.primaryLight : Colors.white,
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                          color: selected
                              ? AppColors.primary
                              : AppColors.border,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${toBn(km)} কিমি',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: selected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: AppColors.textDark,
                            ),
                          ),
                          Icon(
                            selected
                                ? Icons.radio_button_checked
                                : Icons.radio_button_unchecked,
                            size: 20.sp,
                            color: selected
                                ? AppColors.primary
                                : AppColors.textGrey,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            }),
            SizedBox(height: 6.h),
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton(
                onPressed: controller.applyDistance,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  'বিজ্ঞাপন দেখুন',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
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