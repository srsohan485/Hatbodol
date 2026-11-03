import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/bn_number.dart';
import '../../../core/widgets/app_bottom_nav.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'আমার প্রোফাইল',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                      ),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Get.toNamed('/chat-list'),
                            child: Icon(Icons.chat_bubble_outline, size: 24.sp),
                          ),
                          SizedBox(width: 16.w),
                          GestureDetector(
                            onTap: () => Get.toNamed('/settings'),
                            child: Icon(Icons.settings_outlined, size: 24.sp),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  const _ProfileInfo(),
                  SizedBox(height: 16.h),
                  const _Tabs(),
                  SizedBox(height: 14.h),
                  Obx(
                    () => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'আমার সব পোস্ট',
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                        Text(
                          '${toBn(controller.myPosts.length)}টি পোস্ট',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10.h),
                ],
              ),
            ),
            Expanded(
              child: Obx(() {
                final tab = controller.tabIndex.value;
                final posts = controller.myPosts.toList();

                if (tab == 1) {
                  return Center(
                    child: Text(
                      'কোনো সেভ করা পোস্ট নেই',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AppColors.textGrey,
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                  itemCount: posts.length,
                  itemBuilder: (_, i) => _PostCard(post: posts[i], index: i),
                );
              }),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 3,
        onTap: (i) {
          if (i == 0) Get.offAllNamed('/home');
          if (i == 1) Get.toNamed('/search');
          if (i == 2) Get.toNamed('/new-post');
        },
      ),
    );
  }
}

class _ProfileInfo extends StatelessWidget {
  const _ProfileInfo();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 32.r,
          backgroundImage: const AssetImage('assets/images/avatar.jpg'),
        ),
        SizedBox(width: 12.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'রাফসান আহমেদ',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
            SizedBox(height: 4.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.verified_user_outlined,
                    size: 12.sp,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    'ফোন নম্বর যাচাইকৃত',
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'ধানমন্ডি, ঢাকা',
              style: TextStyle(fontSize: 12.sp, color: AppColors.textGrey),
            ),
          ],
        ),
      ],
    );
  }
}

class _Tabs extends GetView<ProfileController> {
  const _Tabs();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Obx(() {
        final tab = controller.tabIndex.value;
        return Row(
          children: [
            _tab('আমার পোস্ট', 0, tab == 0),
            _tab('সেভ করা', 1, tab == 1),
          ],
        );
      }),
    );
  }

  Widget _tab(String label, int index, bool active) {
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.changeTab(index),
        child: Container(
          height: 40.h,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(9.r),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: active ? Colors.white : AppColors.textDark,
            ),
          ),
        ),
      ),
    );
  }
}

class _PostCard extends GetView<ProfileController> {
  final MyPost post;
  final int index;
  const _PostCard({required this.post, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: Image.asset(
                  post.image,
                  width: 64.w,
                  height: 64.w,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      post.price,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      post.isSold ? 'বিক্রি সম্পন্ন' : 'সক্রিয়',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AppColors.textGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Divider(height: 20.h, color: AppColors.border),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _action('সম্পাদনা', AppColors.primary, () {}),
              _action(
                'বিক্রি হয়েছে',
                AppColors.primary,
                () => controller.markAsSold(index),
              ),
              _action(
                'মুছুন',
                AppColors.danger,
                () => controller.deletePost(index),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _action(String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ),
    );
  }
}
