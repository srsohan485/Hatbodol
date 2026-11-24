import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hatbodol/modules/product_details/widgets/safety_tip_dialog.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/bn_number.dart';
import '../controllers/product_details_controller.dart';
import '../models/product_detail_model.dart';
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
      body: Obx(() {
        final p = controller.product.value;

        if (controller.isLoading.value && p == null) {
          return const Center(child: CircularProgressIndicator());
        }
        if (p == null) {
          return Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    controller.errorMessage.value.isEmpty
                        ? 'পণ্যটি খুঁজে পাওয়া যায়নি'
                        : controller.errorMessage.value,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppColors.textGrey,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  ElevatedButton(
                    onPressed: controller.fetchProduct,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        final meta = [p.distanceText, p.timeAgo]
            .where((s) => s.isNotEmpty)
            .join(' · ');

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ImageSlider(images: p.images, hasVideo: p.hasVideo),
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.price,
                      style: TextStyle(
                        fontSize: 26.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      p.title,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        if (p.conditionLabel.isNotEmpty) ...[
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
                              p.conditionLabel,
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                        ],
                        Expanded(
                          child: Text(
                            meta,
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
                    if (p.description.isNotEmpty) ...[
                      SizedBox(height: 12.h),
                      Text(
                        p.description,
                        style: TextStyle(
                          fontSize: 13.sp,
                          height: 1.5,
                          color: AppColors.textGrey,
                        ),
                      ),
                    ],
                    SizedBox(height: 16.h),
                    _SellerCard(seller: p.seller),
                    if (!p.isMine) ...[
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
                                    saved
                                        ? Icons.favorite
                                        : Icons.favorite_border,
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
                  ],
                ),
              ),
            ],
          ),
        );
      }),
      bottomNavigationBar: Obx(() {
        final p = controller.product.value;
        if (p == null) return const SizedBox.shrink();

        // নিজের পোস্ট হলে কল/এসএমএস নেই
        if (p.isMine) {
          return Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 14.h),
            decoration: const BoxDecoration(
              color: AppColors.background,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: SafeArea(
              top: false,
              child: Text(
                'এটি আপনার নিজের পোস্ট',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13.sp, color: AppColors.textGrey),
              ),
            ),
          );
        }

        return Container(
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
                            // TODO: contact API + url_launcher দিয়ে কল করবে
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
        );
      }),
    );
  }
}

class _ImageSlider extends GetView<ProductDetailsController> {
  final List<String> images;
  final bool hasVideo;
  const _ImageSlider({required this.images, required this.hasVideo});

  Widget _placeholder(IconData icon) => Container(
    color: Colors.grey.shade200,
    child: Center(child: Icon(icon, size: 40.sp)),
  );

  Widget _image(String url) {
    return Image.network(
      url,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          color: Colors.grey.shade200,
          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        );
      },
      errorBuilder: (_, __, ___) =>
          _placeholder(Icons.image_not_supported_outlined),
    );
  }

  @override
  Widget build(BuildContext context) {
    final multiple = images.length > 1;

    return SizedBox(
      height: 230.h,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (images.isEmpty)
            _placeholder(Icons.image_outlined)
          else
            PageView.builder(
              itemCount: images.length,
              onPageChanged: controller.onPageChanged,
              itemBuilder: (_, i) => _image(images[i]),
            ),
          // ছবির কাউন্টার (একাধিক ছবি থাকলে)
          if (multiple)
            Positioned(
              top: 12.h,
              right: 12.w,
              child: Obx(
                    () => Container(
                  padding:
                  EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    '${toBn(controller.currentImage.value + 1)}/${toBn(images.length)}',
                    style:
                    TextStyle(fontSize: 11.sp, color: AppColors.textDark),
                  ),
                ),
              ),
            ),
          // ভিডিও ব্যাজ
          if (hasVideo)
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
                      style:
                      TextStyle(fontSize: 11.sp, color: AppColors.primary),
                    ),
                  ],
                ),
              ),
            ),
          // ডট ইন্ডিকেটর (একাধিক ছবি থাকলে)
          if (multiple)
            Positioned(
              bottom: 16.h,
              left: 0,
              right: 0,
              child: Obx(() {
                final current = controller.currentImage.value;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    images.length,
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
  final SellerInfo seller;
  const _SellerCard({required this.seller});

  @override
  Widget build(BuildContext context) {
    final sub = [
      '${toBn(seller.productsCount)}টি পোস্ট',
      if (seller.area.isNotEmpty) seller.area,
    ].join(' · ');

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(14.r),
        onTap: () => Get.toNamed(
          '/seller-profile',
          arguments: {'id': seller.id},
        ),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22.r,
                backgroundColor: AppColors.primaryLight,
                backgroundImage: seller.photo.isNotEmpty
                    ? NetworkImage(seller.photo)
                    : null,
                child: seller.photo.isEmpty
                    ? Icon(Icons.person, size: 22.sp, color: AppColors.primary)
                    : null,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            seller.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                          ),
                        ),
                        if (seller.phoneVerified) ...[
                          SizedBox(width: 4.w),
                          Icon(Icons.verified,
                              size: 14.sp, color: AppColors.primary),
                        ],
                      ],
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      sub,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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