import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/bn_number.dart';
import '../../../core/widgets/app_bottom_nav.dart';
import '../controllers/chat_list_controller.dart';

class ChatListView extends GetView<ChatListController> {
  const ChatListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
              child: Text(
                'মেসেজ',
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
            ),
            SizedBox(height: 14.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: const _Tabs(),
            ),
            SizedBox(height: 12.h),
            Expanded(
              child: Obx(() {
                final tab = controller.tabIndex.value;
                final all = controller.chats.toList();
                final items = controller.filter(all, tab);

                if (items.isEmpty) {
                  return Center(
                    child: Text(
                      'কোনো মেসেজ নেই',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AppColors.textGrey,
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => SizedBox(height: 10.h),
                  itemBuilder: (_, i) => _ChatTile(chat: items[i]),
                );
              }),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 0,
        onTap: (i) {
          if (i == 0) Get.offAllNamed('/home');
          if (i == 1) Get.toNamed('/search');
          if (i == 2) Get.toNamed('/new-post');
          if (i == 3) Get.toNamed('/profile');
        },
      ),
    );
  }
}

class _Tabs extends GetView<ChatListController> {
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
        final current = controller.tabIndex.value;
        return Row(
          children: [
            for (var i = 0; i < controller.tabs.length; i++)
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => controller.changeTab(i),
                  child: Container(
                    height: 38.h,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: current == i
                          ? AppColors.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(9.r),
                    ),
                    child: Text(
                      controller.tabs[i],
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color:
                            current == i ? Colors.white : AppColors.textDark,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }
}

class _ChatTile extends StatelessWidget {
  final ChatPreview chat;
  const _ChatTile({required this.chat});

  @override
  Widget build(BuildContext context) {
    final hasUnread = chat.unread > 0;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Get.toNamed('/chat'), // TODO: arguments দিয়ে চ্যাটের আইডি পাঠাবে
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _avatar(),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          chat.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                      Text(
                        chat.time,
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight:
                              hasUnread ? FontWeight.w700 : FontWeight.w500,
                          color: hasUnread
                              ? AppColors.primary
                              : AppColors.textGrey,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4.r),
                        child: Image.asset(
                          chat.productImage,
                          width: 22.w,
                          height: 22.w,
                          fit: BoxFit.cover,
                          cacheWidth: 100,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: Text(
                          chat.productTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textGrey,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          chat.lastMessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight:
                                hasUnread ? FontWeight.w700 : FontWeight.w500,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                      if (hasUnread) ...[
                        SizedBox(width: 8.w),
                        Container(
                          width: 20.w,
                          height: 20.w,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            toBn(chat.unread),
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _avatar() {
    if (chat.avatar != null) {
      return CircleAvatar(
        radius: 22.r,
        backgroundImage: AssetImage(chat.avatar!),
      );
    }
    return CircleAvatar(
      radius: 22.r,
      backgroundColor: AppColors.primaryLight,
      child: Text(
        chat.initial,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      ),
    );
  }
}