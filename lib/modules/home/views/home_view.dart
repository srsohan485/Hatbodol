import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../controllers/home_controller.dart';
import '../widgets/category_chips.dart';
import '../widgets/home_bottom_nav.dart';
import '../widgets/home_header.dart';
import '../widgets/product_card.dart';
import '../widgets/search_box.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.fetchProducts,
          child: CustomScrollView(
            controller: controller.scrollCtrl,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    SizedBox(height: 12.h),
                    const HomeHeader(),
                    SizedBox(height: 14.h),
                    const SearchBox(),
                    SizedBox(height: 12.h),
                    const CategoryChips(),
                    SizedBox(height: 16.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'কাছেই ভালো কিছু',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w700,
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
              Obx(() {
                // প্রথমবার লোড হচ্ছে
                if (controller.isLoading.value && controller.products.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 60.h),
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                  );
                }
                // error আর কোনো ডেটা নেই
                if (controller.errorMessage.value.isNotEmpty &&
                    controller.products.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: 40.h, horizontal: 24.w),
                      child: Column(
                        children: [
                          Text(
                            controller.errorMessage.value,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 13.sp, color: AppColors.textGrey),
                          ),
                          SizedBox(height: 12.h),
                          ElevatedButton(
                            onPressed: controller.fetchProducts,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final items = controller.visibleProducts;
                if (items.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 60.h),
                      child: Center(
                        child: Text(
                          'কোনো পণ্য পাওয়া যায়নি',
                          style: TextStyle(
                              fontSize: 13.sp, color: AppColors.textGrey),
                        ),
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                  sliver: SliverGrid.builder(
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
              }),
              // পরের পেজ লোড হওয়ার স্পিনার
              Obx(() => SliverToBoxAdapter(
                child: controller.isLoadingMore.value
                    ? Padding(
                  padding: EdgeInsets.only(bottom: 16.h),
                  child: const Center(
                      child: CircularProgressIndicator()),
                )
                    : const SizedBox.shrink(),
              )),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const HomeBottomNav(),
    );
  }
}