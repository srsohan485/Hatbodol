import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../controllers/product_details_controller.dart';

class ReportDialog extends GetView<ProductDetailsController> {
  const ReportDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'পোস্ট রিপোর্ট করুন',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
                GestureDetector(
                  onTap: Get.back,
                  child: Icon(Icons.close, size: 22.sp),
                ),
              ],
            ),
            SizedBox(height: 6.h),
            Text(
              'কেন রিপোর্ট করছেন? আপনার পরিচয় বিক্রেতার কাছে প্রকাশ করা হবে না।',
              style: TextStyle(fontSize: 12.sp, color: AppColors.textGrey),
            ),
            SizedBox(height: 14.h),
            Obx(() {
              final selected = controller.selectedReason.value;
              return Column(
                children: List.generate(controller.reportReasons.length, (i) {
                  final isSelected = selected == i;
                  return GestureDetector(
                    onTap: () => controller.selectReason(i),
                    child: Container(
                      margin: EdgeInsets.only(bottom: 8.h),
                      padding: EdgeInsets.symmetric(
                          horizontal: 12.w, vertical: 12.h),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryLight
                            : Colors.white,
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.border,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            controller.reportReasons[i],
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppColors.textDark,
                            ),
                          ),
                          Icon(
                            isSelected
                                ? Icons.radio_button_checked
                                : Icons.radio_button_unchecked,
                            size: 20.sp,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textGrey,
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              );
            }),
            SizedBox(height: 6.h),
            SizedBox(
              width: double.infinity,
              height: 46.h,
              child: ElevatedButton(
                onPressed: controller.sendReport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                child: Text(
                  'রিপোর্ট পাঠান',
                  style:
                      TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            SizedBox(height: 10.h),
            SizedBox(
              width: double.infinity,
              height: 46.h,
              child: OutlinedButton(
                onPressed: controller.blockSeller,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                child: Text(
                  'বিক্রেতাকে ব্লক করুন',
                  style:
                      TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}