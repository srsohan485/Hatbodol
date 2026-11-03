import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';

class SearchBox extends StatelessWidget {
  const SearchBox({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Get.toNamed('/search'),
      child: Container(
        height: 46.h,
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(Icons.search, size: 22.sp, color: AppColors.textDark),
            SizedBox(width: 10.w),
            Text(
              'কী খুঁজছেন?',
              style: TextStyle(fontSize: 14.sp, color: AppColors.textGrey),
            ),
          ],
        ),
      ),
    );
  }
}