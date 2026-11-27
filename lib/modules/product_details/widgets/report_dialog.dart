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
      child: SingleChildScrollView(
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
              final reasons = controller.reportReasons.toList();
              return Column(
                children: List.generate(reasons.length, (i) {
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
                          Expanded(
                            child: Text(
                              reasons[i].label,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: AppColors.textDark,
                              ),
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
            Obx(() {
              final busy = controller.isReporting.value;
              return SizedBox(
                width: double.infinity,
                height: 46.h,
                child: ElevatedButton(
                  onPressed: busy ? null : controller.sendReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.primary.withOpacity(0.6),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  child: busy
                      ? SizedBox(
                    width: 20.w,
                    height: 20.w,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : Text(
                    'রিপোর্ট পাঠান',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              );
            }),
            SizedBox(height: 10.h),
            Obx(() {
              final busy = controller.isBlocking.value;
              return SizedBox(
                width: double.infinity,
                height: 46.h,
                child: OutlinedButton(
                  onPressed: busy ? null : controller.blockSeller,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  child: Text(
                    'বিক্রেতাকে ব্লক করুন',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}