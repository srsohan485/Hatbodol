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
        child: Listener(
          behavior: HitTestBehavior.translucent,
          onPointerDown: (e) => debugPrint('pointer down: ${e.position}'),
          child: CustomScrollView(
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
        ),
      ),
      bottomNavigationBar: const HomeBottomNav(),
    );
  }
}
