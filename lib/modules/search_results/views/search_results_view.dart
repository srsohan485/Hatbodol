import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hatbodol/Services/location_session.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/bn_number.dart';
import '../../../core/widgets/app_bottom_nav.dart';
import '../../home/models/product_model.dart';
import '../controllers/search_results_controller.dart';
import '../widgets/filter_sheet.dart';

class SearchResultsView extends GetView<SearchResultsController> {
  const SearchResultsView({super.key});

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
          'সার্চ',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 0),
            child: Row(
              children: [
                Expanded(child: _searchField()),
                SizedBox(width: 10.w),
                GestureDetector(
                  onTap: openFilterSheet,
                  child: Container(
                    width: 46.w,
                    height: 46.w,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      Icons.tune,
                      size: 22.sp,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),
          _filterChips(),
          SizedBox(height: 10.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Obx(() {
                final name = LocationSession.areaName.value;
                return Text(
                  name.isEmpty ? 'আশেপাশে' : '$name থেকে আশেপাশে',
                  style: TextStyle(fontSize: 11.sp, color: AppColors.textGrey),
                );
              }),
            ),
          ),
          SizedBox(height: 6.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Obx(() {
                final count = controller.results.length;
                return Text(
                  '${toBn(count)}টি ফলাফল পাওয়া গেছে',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                );
              }),
            ),
          ),
          SizedBox(height: 10.h),
          Expanded(
            child: Obx(() {
              final items = controller.results;
              final loadingMore = controller.isLoadingMore.value;

              if (controller.isLoading.value && items.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.errorMessage.value.isNotEmpty && items.isEmpty) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          controller.errorMessage.value,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: AppColors.textGrey,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        ElevatedButton(
                          onPressed: controller.fetchResults,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                );
              }
              if (items.isEmpty) {
                return Center(
                  child: Text(
                    'কোনো ফলাফল পাওয়া যায়নি',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppColors.textGrey,
                    ),
                  ),
                );
              }
              return ListView.separated(
                controller: controller.scrollCtrl,
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                itemCount: items.length + (loadingMore ? 1 : 0),
                separatorBuilder: (_, _) => SizedBox(height: 12.h),
                itemBuilder: (_, i) {
                  if (i >= items.length) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  }
                  return _ResultCard(item: items[i]);
                },
              );
            }),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 1,
        onTap: (i) {
          if (i == 0) Get.offAllNamed('/home');
          if (i == 2) Get.toNamed('/new-post');
          if (i == 3) Get.toNamed('/profile');
        },
      ),
    );
  }

  Widget _searchField() {
    return Container(
      height: 46.h,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(Icons.search, size: 22.sp, color: AppColors.textDark),
          SizedBox(width: 8.w),
          Expanded(
            child: TextField(
              controller: controller.queryCtrl,
              focusNode: controller.queryFocus,
              onTap: controller.queryFocus.requestFocus,
              onChanged: controller.onQueryChanged,
              onTapOutside: (_) => controller.queryFocus.unfocus(),
              textAlignVertical: TextAlignVertical.center,
              textInputAction: TextInputAction.search,
              style: TextStyle(fontSize: 14.sp, color: AppColors.textDark),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: 'কী খুঁজছেন?',
                hintStyle: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textGrey,
                ),
              ),
            ),
          ),
          Obx(
                () => controller.query.value.isEmpty
                ? const SizedBox.shrink()
                : GestureDetector(
              onTap: controller.clearQuery,
              child: Icon(
                Icons.close,
                size: 20.sp,
                color: AppColors.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChips() {
    return SizedBox(
      height: 36.h,
      child: Obx(() {
        // সব Rx এখানে পড়া হচ্ছে, তাই বদলালে চিপ আবার আঁকা হবে
        final km = controller.distance.value;
        final range = controller.priceRange.value;
        final cond = controller.condition.value;
        final condLabel = cond == null
            ? 'সব অবস্থা'
            : (cond ? 'ব্যবহৃত' : 'নতুন');

        return ListView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          children: [
            _chip('${toBn(km)} কিমি'),
            _chip('৳ ${bnPrice(range.start)}–${bnPrice(range.end)}'),
            _chip(condLabel),
          ],
        );
      }),
    );
  }

  Widget _chip(String label) {
    return Padding(
      padding: EdgeInsets.only(right: 8.w),
      child: GestureDetector(
        onTap: openFilterSheet,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(width: 4.w),
              Icon(
                Icons.keyboard_arrow_down,
                size: 18.sp,
                color: AppColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final ProductModel item;
  const _ResultCard({required this.item});

  Widget _placeholder(IconData icon) => Container(
    width: 100.w,
    height: double.infinity,
    color: Colors.grey.shade200,
    child: Center(child: Icon(icon)),
  );

  Widget _thumb() {
    final img = item.image;
    if (img.isEmpty) return _placeholder(Icons.image_outlined);
    if (img.startsWith('http')) {
      return Image.network(
        img,
        width: 100.w,
        height: double.infinity,
        fit: BoxFit.cover,
        cacheWidth: 300,
        errorBuilder: (_, __, ___) =>
            _placeholder(Icons.image_not_supported_outlined),
      );
    }
    return Image.asset(
      img,
      width: 100.w,
      height: double.infinity,
      fit: BoxFit.cover,
      cacheWidth: 300,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Get.toNamed(
        '/product-details',
        arguments: {'id': item.id},
      ),
      child: Container(
        height: 100.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            _thumb(),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      item.price,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 12.sp,
                          color: AppColors.textGrey,
                        ),
                        SizedBox(width: 2.w),
                        Expanded(
                          child: Text(
                            item.distance,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: AppColors.textGrey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}