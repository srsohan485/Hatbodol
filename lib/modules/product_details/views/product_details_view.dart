import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hatbodol/modules/product_details/widgets/safety_tip_dialog.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/bn_number.dart';
import '../controllers/product_details_controller.dart';
import '../widgets/report_dialog.dart';

class ProductDetailsView extends GetView<ProductDetailsController> {
  const ProductDetailsView({super.key});

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
          'বিস্তারিত',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: AppColors.textDark),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _ImageSlider(),
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '৳ ৩,২০০',
                    style: TextStyle(
                      fontSize: 26.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'কাঠের পড়ার টেবিল',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 3.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          'ব্যবহৃত',
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        '১.২ কিমি দূর · ২ ঘণ্টা আগে',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textGrey,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'ছয় মাস ব্যবহার করেছি। মজবুত কাঠের টেবিল, একটি ড্রয়ার আছে। '
                    'কোনো সমস্যা নেই। বাসা বদলের জন্য বিক্রি করছি। '
                    'ধানমন্ডি থেকে নিতে হবে।',
                    style: TextStyle(
                      fontSize: 13.sp,
                      height: 1.5,
                      color: AppColors.textGrey,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  const _SellerCard(),
                  SizedBox(height: 14.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: controller.toggleSave,
                        child: Obx(() {
                          final saved = controller.isSaved.value;
                          return Row(
                            children: [
                              Icon(
                                saved ? Icons.favorite : Icons.favorite_border,
                                size: 20.sp,
                                color: AppColors.primary,
                              ),
                              SizedBox(width: 6.w),
                              Text(
                                'সেভ করুন',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          );
                        }),
                      ),
                      GestureDetector(
                        onTap: () => Get.dialog(const ReportDialog()),
                        child: Text(
                          'রিপোর্ট করুন',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textGrey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
        decoration: const BoxDecoration(
          color: AppColors.background,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 46.h,
                  child: ElevatedButton.icon(
                    // কল করুন বাটন
                    onPressed: () => Get.dialog(
                      SafetyTipDialog(
                        onConfirm: () {
                          // TODO: url_launcher দিয়ে কল করবে
                        },
                      ),
                    ),

                    icon: Icon(Icons.phone, size: 18.sp),
                    label: Text(
                      'কল করুন',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: SizedBox(
                  height: 46.h,
                  child: OutlinedButton.icon(
                    // এসএমএস বাটন
                    onPressed: () => Get.dialog(
                      SafetyTipDialog(
                        onConfirm: () {
                          Get.toNamed('/chat');
                        },
                      ),
                    ),

                    icon: Icon(Icons.chat_bubble_outline, size: 18.sp),
                    label: Text(
                      'এসএমএস',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImageSlider extends GetView<ProductDetailsController> {
  const _ImageSlider();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 230.h,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            itemCount: controller.images.length,
            onPageChanged: controller.onPageChanged,
            itemBuilder: (_, i) =>
                Image.asset(controller.images[i], fit: BoxFit.cover),
          ),
          // ছবির কাউন্টার
          Positioned(
            top: 12.h,
            right: 12.w,
            child: Obx(
              () => Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  '${toBn(controller.currentImage.value + 1)}/${toBn(controller.images.length)}',
                  style: TextStyle(fontSize: 11.sp, color: AppColors.textDark),
                ),
              ),
            ),
          ),
          // ভিডিও ব্যাজ
          Positioned(
            left: 12.w,
            bottom: 12.h,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.play_arrow_outlined,
                    size: 14.sp,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'ভিডিও আছে',
                    style: TextStyle(fontSize: 11.sp, color: AppColors.primary),
                  ),
                ],
              ),
            ),
          ),
          // ডট ইন্ডিকেটর
          Positioned(
            bottom: 16.h,
            left: 0,
            right: 0,
            child: Obx(() {
              final current = controller.currentImage.value;
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  controller.images.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: EdgeInsets.symmetric(horizontal: 2.w),
                    width: i == current ? 16.w : 6.w,
                    height: 6.w,
                    decoration: BoxDecoration(
                      color: i == current
                          ? AppColors.primary
                          : Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(3.r),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _SellerCard extends StatelessWidget {
  const _SellerCard();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(14.r),
        onTap: () => Get.toNamed('/seller-profile'),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22.r,
                backgroundImage: const AssetImage('assets/images/avatar.jpg'),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'রাফসান আহমেদ',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      '১২টি পোস্ট · ধানমন্ডি, ঢাকা',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AppColors.textGrey,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: AppColors.textGrey, size: 22.sp),
            ],
          ),
        ),
      ),
    );
  }
}
