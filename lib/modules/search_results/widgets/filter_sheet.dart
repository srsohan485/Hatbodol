import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/bn_number.dart';
import '../controllers/search_results_controller.dart';

/// শিট খোলার ফাংশন, চিপ আর ফিল্টার আইকন থেকে ডাকা হবে
void openFilterSheet() {
  Get.find<SearchResultsController>().prepareFilter();
  Get.bottomSheet(
    const FilterSheet(),
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
    ),
  );
}

class FilterSheet extends GetView<SearchResultsController> {
  const FilterSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
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
            SizedBox(height: 14.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ফিল্টার করুন',
                  style: TextStyle(
                    fontSize: 19.sp,
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
            SizedBox(height: 16.h),

            // ক্যাটাগরি
            _label('ক্যাটাগরি'),
            SizedBox(height: 8.h),
            SizedBox(
              height: 40.h,
              child: Obx(() {
                final selected = controller.tCategory.value;
                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: controller.categories.length,
                  separatorBuilder: (_, __) => SizedBox(width: 8.w),
                  itemBuilder: (_, i) {
                    final c = controller.categories[i];
                    return _Choice(
                      label: c,
                      selected: selected == c,
                      horizontalPadding: 20.w,
                      onTap: () => controller.tCategory.value = c,
                    );
                  },
                );
              }),
            ),
            SizedBox(height: 16.h),

            // দামের সীমা
            _label('দামের সীমা'),
            SizedBox(height: 8.h),
            Obx(() {
              final r = controller.tRange.value;
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _priceBox('সর্বনিম্ন', '৳ ${bnPrice(r.start)}'),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _priceBox('সর্বোচ্চ', '৳ ${bnPrice(r.end)}'),
                      ),
                    ],
                  ),
                  SliderTheme(
                    data: SliderTheme.of(Get.context!).copyWith(
                      activeTrackColor: AppColors.primary,
                      inactiveTrackColor: AppColors.border,
                      thumbColor: Colors.white,
                      overlayColor: AppColors.primary.withOpacity(0.1),
                      trackHeight: 3.h,
                    ),
                    child: RangeSlider(
                      values: r,
                      min: 0,
                      max: SearchResultsController.maxPrice,
                      divisions: 130,
                      onChanged: (v) => controller.tRange.value = v,
                    ),
                  ),
                ],
              );
            }),
            SizedBox(height: 8.h),

            // দূরত্ব
            _label('দূরত্ব - ধানমন্ডি, ঢাকা থেকে'),
            SizedBox(height: 8.h),
            Obx(() {
              final selected = controller.tDistance.value;
              return Row(
                children: [
                  for (final km in controller.distanceOptions)
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: km == controller.distanceOptions.last
                              ? 0
                              : 8.w,
                        ),
                        child: _Choice(
                          label: '${toBn(km)} কিমি',
                          selected: selected == km,
                          onTap: () => controller.tDistance.value = km,
                        ),
                      ),
                    ),
                ],
              );
            }),
            SizedBox(height: 16.h),

            // পণ্যের অবস্থা
            _label('পণ্যের অবস্থা'),
            SizedBox(height: 8.h),
            Obx(() {
              final cond = controller.tCondition.value;
              return Row(
                children: [
                  Expanded(
                    child: _Choice(
                      label: 'নতুন',
                      selected: cond == false,
                      onTap: () => controller.setCondition(false),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: _Choice(
                      label: 'ব্যবহৃত',
                      selected: cond == true,
                      onTap: () => controller.setCondition(true),
                    ),
                  ),
                ],
              );
            }),
            SizedBox(height: 20.h),

            // বাটন
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 48.h,
                    child: OutlinedButton(
                      onPressed: controller.resetFilter,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                      child: Text(
                        'রিসেট',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  flex: 5,
                  child: SizedBox(
                    height: 48.h,
                    child: ElevatedButton(
                      onPressed: controller.applyFilter,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                      child: Text(
                        'ফিল্টার প্রয়োগ করুন',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w800,
          color: AppColors.textDark,
        ),
      );

  Widget _priceBox(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 10.sp, color: AppColors.textGrey),
        ),
        SizedBox(height: 4.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: AppColors.border),
          ),
          child: Text(
            value,
            style: TextStyle(fontSize: 13.sp, color: AppColors.textDark),
          ),
        ),
      ],
    );
  }
}

class _Choice extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final double? horizontalPadding;

  const _Choice({
    required this.label,
    required this.selected,
    required this.onTap,
    this.horizontalPadding,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 40.h,
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding ?? 0),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColors.textDark,
          ),
        ),
      ),
    );
  }
}