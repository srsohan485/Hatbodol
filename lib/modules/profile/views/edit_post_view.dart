import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hatbodol/modules/profile/controllers/edit_post_controller.dart';

import '../../../core/theme/app_colors.dart';


class EditPostView extends GetView<EditPostController> {
  const EditPostView({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
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
            'পোস্ট সম্পাদনা',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
        ),
        body: Obx(() {
          if (controller.isLoading.value && !controller.loaded.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!controller.loaded.value) {
            return Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      controller.errorMessage.value.isEmpty
                          ? 'পোস্টটি খুঁজে পাওয়া যায়নি'
                          : controller.errorMessage.value,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AppColors.textGrey,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    ElevatedButton(
                      onPressed: controller.load,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }
          return _form();
        }),
        bottomNavigationBar: Obx(() {
          if (!controller.loaded.value) return const SizedBox.shrink();
          return Container(
            padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 10.h),
            color: AppColors.background,
            child: SafeArea(
              top: false,
              child: SizedBox(
                height: 50.h,
                child: ElevatedButton(
                  onPressed:
                  controller.isSaving.value ? null : controller.save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.primary.withOpacity(0.6),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: controller.isSaving.value
                      ? SizedBox(
                    width: 20.w,
                    height: 20.w,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : Text(
                    'সংরক্ষণ করুন',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _form() {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() {
            final imgs = controller.images.toList();
            if (imgs.isEmpty) return const SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _label('ছবি'),
                SizedBox(height: 8.h),
                SizedBox(
                  height: 78.h,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: imgs.length,
                    separatorBuilder: (_, __) => SizedBox(width: 8.w),
                    itemBuilder: (_, i) => ClipRRect(
                      borderRadius: BorderRadius.circular(10.r),
                      child: Image.network(
                        imgs[i],
                        width: 78.w,
                        height: 78.h,
                        fit: BoxFit.cover,
                        cacheWidth: 300,
                        errorBuilder: (_, __, ___) => Container(
                          width: 78.w,
                          height: 78.h,
                          color: Colors.grey.shade200,
                          child:
                          const Icon(Icons.image_not_supported_outlined),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  'ছবি ও ভিডিও এখান থেকে বদলানো যায় না',
                  style: TextStyle(fontSize: 10.sp, color: AppColors.textGrey),
                ),
                SizedBox(height: 16.h),
              ],
            );
          }),
          _label('শিরোনাম'),
          SizedBox(height: 6.h),
          TextField(
            controller: controller.titleCtrl,
            textInputAction: TextInputAction.next,
            style: _inputStyle,
            decoration: _decoration('যেমন: কাঠের পড়ার টেবিল'),
          ),
          SizedBox(height: 14.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('দাম (৳)'),
                    SizedBox(height: 6.h),
                    TextField(
                      controller: controller.priceCtrl,
                      keyboardType: TextInputType.number,
                      maxLength: 9,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9০-৯]')),
                      ],
                      style: _inputStyle,
                      decoration: _decoration('০').copyWith(counterText: ''),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('ক্যাটাগরি'),
                    SizedBox(height: 6.h),
                    _categoryDropdown(),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Row(
            children: [
              _label('পণ্যের অবস্থা'),
              SizedBox(width: 14.w),
              Expanded(child: _conditionToggle()),
            ],
          ),
          SizedBox(height: 14.h),
          _label('বর্ণনা'),
          SizedBox(height: 6.h),
          TextField(
            controller: controller.descCtrl,
            maxLines: 4,
            style: _inputStyle,
            decoration: _decoration('পণ্য সম্পর্কে কয়েক লাইন লিখুন'),
          ),
        ],
      ),
    );
  }

  TextStyle get _inputStyle =>
      TextStyle(fontSize: 14.sp, color: AppColors.textDark);

  Widget _label(String text) => Text(
    text,
    style: TextStyle(
      fontSize: 13.sp,
      fontWeight: FontWeight.w700,
      color: AppColors.textDark,
    ),
  );

  InputDecoration _decoration(String hint) {
    OutlineInputBorder border(Color c) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.r),
      borderSide: BorderSide(color: c),
    );
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(fontSize: 13.sp, color: AppColors.textGrey),
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      enabledBorder: border(AppColors.border),
      focusedBorder: border(AppColors.primary),
      border: border(AppColors.border),
    );
  }

  Widget _categoryDropdown() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Obx(() {
        final selected = controller.selectedCategory.value;
        final items = controller.categories.toList();
        return DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: items.contains(selected) ? selected : null,
            isExpanded: true,
            hint: Text(
              'বাছাই করুন',
              style: TextStyle(fontSize: 13.sp, color: AppColors.textGrey),
            ),
            icon: Icon(Icons.keyboard_arrow_down, size: 22.sp),
            style: _inputStyle,
            items: items
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: controller.setCategory,
          ),
        );
      }),
    );
  }

  Widget _conditionToggle() {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Obx(() {
        final used = controller.isUsed.value;
        Widget seg(String label, bool isUsedSeg) {
          final active = used == isUsedSeg;
          return Expanded(
            child: GestureDetector(
              onTap: () => controller.setCondition(isUsedSeg),
              child: Container(
                height: 36.h,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: active ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(8.r),
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

        return Row(children: [seg('নতুন', false), seg('ব্যবহৃত', true)]);
      }),
    );
  }
}