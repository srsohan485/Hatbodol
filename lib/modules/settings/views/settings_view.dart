import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../controllers/settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

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
          'সেটিংস',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          _Group(
            children: [
              _Tile(
                icon: Icons.translate,
                title: 'ভাষা',
                trailingText: 'বাংলা',
                onTap: () {},
              ),
              _Tile(
                icon: Icons.notifications_none,
                title: 'নোটিফিকেশন',
                trailing: Obx(
                  () => Switch(
                    value: controller.notificationOn.value,
                    onChanged: controller.toggleNotification,
                    activeColor: Colors.white,
                    activeTrackColor: AppColors.primary,
                  ),
                ),
              ),
              _Tile(
                icon: Icons.location_on_outlined,
                title: 'আমার এলাকা',
                trailingText: 'ধানমন্ডি, ঢাকা',
                onTap: () => Get.toNamed('/location-permission'),
              ),
              _Tile(
                icon: Icons.phone_outlined,
                title: 'ফোন নম্বর পরিবর্তন',
                onTap: () {},
              ),
            ],
          ),
          SizedBox(height: 12.h),
          _Group(
            children: [
              _Tile(
                icon: Icons.verified_user_outlined,
                title: 'গোপনীয়তা নীতি',
                onTap: () {},
              ),
              _Tile(
                icon: Icons.chat_bubble_outline,
                title: 'সাহায্য ও যোগাযোগ',
                onTap: () {},
              ),
            ],
          ),
          SizedBox(height: 12.h),
          _Group(
            children: [
              _Tile(icon: Icons.logout, title: 'লগআউট', onTap: () {}),
              _Tile(
                icon: Icons.delete_outline,
                title: 'অ্যাকাউন্ট মুছুন',
                color: AppColors.danger,
                onTap: () {},
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Center(
            child: Text(
              'হাতবদল - পুরোনো জিনিস, নতুন হাতে।',
              style: TextStyle(fontSize: 11.sp, color: AppColors.textGrey),
            ),
          ),
        ],
      ),
    );
  }
}

class _Group extends StatelessWidget {
  final List<Widget> children;
  const _Group({required this.children});

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      items.add(children[i]);
      if (i != children.length - 1) {
        items.add(Divider(height: 1, color: AppColors.border));
      }
    }
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(children: items),
    );
  }
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? trailingText;
  final Widget? trailing;
  final Color color;
  final VoidCallback? onTap;

  const _Tile({
    required this.icon,
    required this.title,
    this.trailingText,
    this.trailing,
    this.color = AppColors.textDark,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        child: Row(
          children: [
            Icon(icon, size: 20.sp, color: color),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ),
            if (trailingText != null) ...[
              Text(
                trailingText!,
                style: TextStyle(fontSize: 11.sp, color: AppColors.textGrey),
              ),
              SizedBox(width: 4.w),
            ],
            trailing ?? Icon(Icons.chevron_right, size: 20.sp, color: color),
          ],
        ),
      ),
    );
  }
}
