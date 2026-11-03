import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/home_controller.dart';

class CategoryChips extends GetView<HomeController> {
  const CategoryChips({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38.h,
      child: Obx(() {
        // observable ta ekhane pora hocche, tai Obx bujhte pare
        final selectedIndex = controller.selectedCategory.value;

        return ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: controller.categories.length,
          separatorBuilder: (_, __) => SizedBox(width: 8.w),
          itemBuilder: (_, i) {
            final selected = selectedIndex == i;
            return GestureDetector(
              onTap: () => controller.selectCategory(i),
              child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(horizontal: 18.w),
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary : AppColors.card,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: selected ? AppColors.primary : AppColors.border,
                  ),
                ),
                child: Text(
                  controller.categories[i],
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : AppColors.textDark,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}