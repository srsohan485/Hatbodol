import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hatbodol/modules/home/widgets/product_card.dart';
import 'package:hatbodol/modules/profile/views/saved_products.dart';

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
                          SizedBox(width: 12.w),
                          PopupMenuButton<String>(
                            icon: Icon(Icons.more_vert, size: 24.sp),
                            onSelected: (v) {
                              if (v == 'edit_profile') {
                                controller.editProfile();
                              } else if (v == 'delete_account') {
                                controller.confirmDeleteAccount();
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'edit_profile',
                                child: Text('Edit Profile'),
                              ),
                              const PopupMenuItem(
                                value: 'delete_account',
                                child: Text('Delete Account'),
                              ),
                            ],
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
                  Obx(() {
                    final saved = controller.tabIndex.value == 1;
                    final count = saved
                        ? controller.savedPosts
                        .where((p) => SavedProducts.isSaved(p.id, true))
                        .length
                        : controller.myPosts.length;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          saved ? 'সেভ করা পোস্ট' : 'আমার সব পোস্ট',
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                        Text(
                          '${toBn(count)}টি পোস্ট',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textGrey,
                          ),
                        ),
                      ],
                    );
                  }),
                  SizedBox(height: 10.h),
                ],
              ),
            ),
            Expanded(
              child: Obx(() {
                final tab = controller.tabIndex.value;
                final posts = controller.myPosts.toList();

                if (tab == 1) return const _SavedList();
                if (controller.postsLoading.value && posts.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (controller.postsError.value.isNotEmpty && posts.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            controller.postsError.value,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: AppColors.textGrey,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          ElevatedButton(
                            onPressed: controller.fetchMyPosts,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                if (posts.isEmpty) {
                  return _message('আপনি এখনো কোনো পোস্ট করেননি');
                }
                return RefreshIndicator(
                  onRefresh: controller.fetchMyPosts,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                    itemCount: posts.length,
                    itemBuilder: (_, i) => _PostCard(post: posts[i]),
                  ),
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

  Widget _message(String text) => Center(
    child: Text(
      text,
      style: TextStyle(fontSize: 13.sp, color: AppColors.textGrey),
    ),
  );
}

class _ProfileInfo extends GetView<ProfileController> {
  const _ProfileInfo();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final p = controller.profile.value;

      if (p == null) {
        if (controller.isLoading.value) {
          return SizedBox(
            height: 72.h,
            child: const Center(child: CircularProgressIndicator()),
          );
        }
        return Row(
          children: [
            Expanded(
              child: Text(
                controller.errorMessage.value.isEmpty
                    ? 'প্রোফাইল লোড হয়নি'
                    : controller.errorMessage.value,
                style: TextStyle(fontSize: 12.sp, color: AppColors.textGrey),
              ),
            ),
            TextButton(
              onPressed: controller.fetchProfile,
              child: const Text('Retry'),
            ),
          ],
        );
      }

      return Row(
        children: [
          CircleAvatar(
            radius: 32.r,
            backgroundColor: AppColors.primaryLight,
            backgroundImage: p.photo.isNotEmpty ? NetworkImage(p.photo) : null,
            child: p.photo.isEmpty
                ? Icon(Icons.person, size: 32.sp, color: AppColors.primary)
                : null,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
                SizedBox(height: 4.h),
                if (p.isPhoneVerified) ...[
                  Container(
                    padding:
                    EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified_user_outlined,
                            size: 12.sp, color: AppColors.primary),
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
                ],
                Text(
                  p.area,
                  style: TextStyle(fontSize: 12.sp, color: AppColors.textGrey),
                ),
              ],
            ),
          ),
        ],
      );
    });
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
  const _PostCard({required this.post});

  Widget _placeholder(IconData icon) => Container(
    width: 64.w,
    height: 64.w,
    color: Colors.grey.shade200,
    child: Icon(icon),
  );

  Widget _thumb() {
    final img = post.image;
    if (img.isEmpty) return _placeholder(Icons.image_outlined);
    if (img.startsWith('http')) {
      return Image.network(
        img,
        width: 64.w,
        height: 64.w,
        fit: BoxFit.cover,
        cacheWidth: 200,
        errorBuilder: (_, __, ___) =>
            _placeholder(Icons.image_not_supported_outlined),
      );
    }
    return Image.asset(img, width: 64.w, height: 64.w, fit: BoxFit.cover);
  }

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
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Get.toNamed(
              '/product-details',
              arguments: {'id': post.id},
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: _thumb(),
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
                        post.statusLabel,
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
          ),
          Divider(height: 20.h, color: AppColors.border),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _action(
                'সম্পাদনা',
                AppColors.primary,
                    () => controller.editPost(post),
              ),
              Obx(() {
                final busy = controller.busyId.value == post.id;
                if (post.isSold) {
                  return _action(
                    busy ? 'অপেক্ষা করুন...' : 'আবার তালিকাভুক্ত',
                    AppColors.primary,
                    busy ? null : () => controller.relist(post),
                  );
                }
                return _action(
                  busy ? 'অপেক্ষা করুন...' : 'বিক্রি হয়েছে',
                  AppColors.primary,
                  busy ? null : () => controller.confirmMarkSold(post),
                );
              }),
              Obx(() {
                final deleting = controller.deletingId.value == post.id;
                return _action(
                  deleting ? 'মুছছে...' : 'মুছুন',
                  AppColors.danger,
                  deleting ? null : () => controller.confirmDeletePost(post),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _action(String label, Color color, VoidCallback? onTap) {
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
            color: onTap == null ? AppColors.textGrey : color,
          ),
        ),
      ),
    );
  }
}
class _SavedList extends GetView<ProfileController> {
  const _SavedList();

  Widget _message(String text) => Center(
    child: Text(
      text,
      style: TextStyle(fontSize: 13.sp, color: AppColors.textGrey),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final all = controller.savedPosts.toList();
      // হার্টে চাপ দিয়ে আনসেভ করলে সাথে সাথে তালিকা থেকে সরে যায়
      final items =
      all.where((p) => SavedProducts.isSaved(p.id, true)).toList();

      if (controller.savedLoading.value && all.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.savedError.value.isNotEmpty && all.isEmpty) {
        return Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  controller.savedError.value,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13.sp, color: AppColors.textGrey),
                ),
                SizedBox(height: 12.h),
                ElevatedButton(
                  onPressed: controller.fetchSaved,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        );
      }
      if (items.isEmpty) return _message('কোনো সেভ করা পোস্ট নেই');

      return RefreshIndicator(
        onRefresh: controller.fetchSaved,
        child: GridView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12.w,
            mainAxisSpacing: 12.h,
            childAspectRatio: 0.78,
          ),
          itemBuilder: (_, i) => GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Get.toNamed(
              '/product-details',
              arguments: {'id': items[i].id},
            ),
            child: ProductCard(product: items[i]),
          ),
        ),
      );
    });
  }
}