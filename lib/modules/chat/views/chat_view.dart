import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../controllers/chat_controller.dart';

class ChatView extends GetView<ChatController> {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _appBar(),
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 0),
              child: Column(
                children: [
                  const _ProductBar(),
                  SizedBox(height: 10.h),
                  const _SafetyBanner(),
                ],
              ),
            ),
            SizedBox(height: 8.h),
            Expanded(
              child: Obx(() {
                final items = controller.messages.toList();
                return ListView.builder(
                  controller: controller.scrollCtrl,
                  padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 8.h),
                  itemCount: items.length + 1,
                  itemBuilder: (_, i) {
                    if (i == 0) return const _DateChip();
                    return _Bubble(msg: items[i - 1]);
                  },
                );
              }),
            ),
            _quickReplies(),
            _inputBar(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _appBar() {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleSpacing: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
        onPressed: Get.back,
      ),
      title: Row(
        children: [
          CircleAvatar(
            radius: 18.r,
            backgroundImage: const AssetImage('assets/images/avatar.jpg'),
          ),
          SizedBox(width: 10.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'রাফসান আহমেদ',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              Text(
                'অনলাইন আছেন',
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: AppColors.textDark),
          onSelected: controller.onMenu,
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'report', child: Text('রিপোর্ট করুন')),
            PopupMenuItem(value: 'block', child: Text('ব্লক করুন')),
          ],
        ),
      ],
    );
  }

  Widget _quickReplies() {
    return SizedBox(
      height: 38.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: controller.quickReplies.length,
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (_, i) {
          final text = controller.quickReplies[i];
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => controller.send(text),
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18.r),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _inputBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 8.h),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                // TODO: image_picker দিয়ে ছবি/ফাইল পাঠাবে
              },
              child: Icon(Icons.attach_file,
                  size: 24.sp, color: AppColors.textGrey),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(22.r),
                ),
                child: TextField(
                  controller: controller.inputCtrl,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => controller.send(),
                  style:
                      TextStyle(fontSize: 14.sp, color: AppColors.textDark),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'মেসেজ লিখুন...',
                    hintStyle: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textGrey,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 8.w),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => controller.send(),
              child: Container(
                width: 44.w,
                height: 44.w,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.send, size: 20.sp, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductBar extends StatelessWidget {
  const _ProductBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: Image.asset(
              'assets/images/table.jpg',
              width: 54.w,
              height: 54.w,
              fit: BoxFit.cover,
              cacheWidth: 200,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'কাঠের পড়ার টেবিল',
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
                  '৳ ৩,২০০',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
                GestureDetector(
                  onTap: () => Get.toNamed('/product-details'),
                  child: Text(
                    'বিস্তারিত দেখুন',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SafetyBanner extends StatelessWidget {
  const _SafetyBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(Icons.verified_user_outlined,
              size: 18.sp, color: AppColors.primary),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              'নিরাপদে থাকতে অগ্রিম টাকা পাঠাবেন না, সামনাসামনি দেখে নিন।',
              style: TextStyle(
                fontSize: 11.sp,
                height: 1.4,
                color: AppColors.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DateChip extends StatelessWidget {
  const _DateChip();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: AppColors.border,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Text(
          'আজ',
          style: TextStyle(fontSize: 11.sp, color: AppColors.textGrey),
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final ChatMessage msg;
  const _Bubble({required this.msg});

  @override
  Widget build(BuildContext context) {
    final mine = msg.isMine;
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        constraints: BoxConstraints(maxWidth: 0.72.sw),
        padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 6.h),
        decoration: BoxDecoration(
          color: mine ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(14.r),
            topRight: Radius.circular(14.r),
            bottomLeft: Radius.circular(mine ? 14.r : 4.r),
            bottomRight: Radius.circular(mine ? 4.r : 14.r),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment:
              mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              msg.text,
              style: TextStyle(
                fontSize: 14.sp,
                height: 1.35,
                color: mine ? Colors.white : AppColors.textDark,
              ),
            ),
            SizedBox(height: 4.h),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  msg.time,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: mine ? Colors.white70 : AppColors.textGrey,
                  ),
                ),
                if (mine) ...[
                  SizedBox(width: 4.w),
                  Icon(Icons.done_all, size: 13.sp, color: Colors.white70),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}