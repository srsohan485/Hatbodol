import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/bn_number.dart';
import '../../home/widgets/product_card.dart';
import '../controllers/seller_profile_controller.dart';

class SellerProfileView extends GetView<SellerProfileController> {
  const SellerProfileView({super.key});

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
          'বিক্রেতার প্রোফাইল',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                SizedBox(height: 8.h),
                _SellerInfo(controller: controller),
                SizedBox(height: 14.h),
                _AreaBar(controller: controller),
                SizedBox(height: 18.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'বিক্রেতার বিজ্ঞাপন',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      'নতুন আগে',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textGrey,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
              ]),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
            sliver: Obx(() {
              final items = controller.products.toList();
              return SliverGrid.builder(
                itemCount: items.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12.w,
                  mainAxisSpacing: 12.h,
                  childAspectRatio: 0.78,
                ),
                itemBuilder: (_, i) => GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Get.toNamed('/product-details'),
                  child: ProductCard(product: items[i]),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _SellerInfo extends StatelessWidget {
  final SellerProfileController controller;
  const _SellerInfo({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 34.r,
          backgroundImage: const AssetImage('assets/images/avatar.jpg'),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                controller.name,
                style: TextStyle(
                  fontSize: 19.sp,
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
              Text(
                'যোগ দিয়েছেন ${controller.joinedAt}',
                style: TextStyle(fontSize: 12.sp, color: AppColors.textGrey),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AreaBar extends StatelessWidget {
  final SellerProfileController controller;
  const _AreaBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(Icons.location_on_outlined,
              size: 18.sp, color: AppColors.primary),
          SizedBox(width: 6.w),
          Expanded(
            child: Text(
              controller.area,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
          ),
          Text(
            '${toBn(controller.postCount)}টি পোস্ট',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}