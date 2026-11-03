import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_colors.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 8.h, bottom: 10.h),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _item(0, Icons.home_outlined, Icons.home, 'হোম'),
            _item(1, Icons.search, Icons.search, 'সার্চ'),
            _post(),
            _item(3, Icons.person_outline, Icons.person, 'প্রোফাইল'),
          ],
        ),
      ),
    );
  }

  Widget _item(int i, IconData icon, IconData activeIcon, String label) {
    final active = currentIndex == i;
    final color = active ? AppColors.primary : AppColors.textGrey;
    return GestureDetector(
      onTap: () => onTap(i),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60.w,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(active ? activeIcon : icon, size: 24.sp, color: color),
            SizedBox(height: 2.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _post() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTap(2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 46.w,
            height: 36.h,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(Icons.add, color: Colors.white, size: 24.sp),
          ),
          SizedBox(height: 2.h),
          Text(
            'পোস্ট',
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textGrey,
            ),
          ),
        ],
      ),
    );
  }
}