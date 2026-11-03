import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/bn_number.dart';
import '../../../core/widgets/dashed_border.dart';
import '../controllers/new_post_controller.dart';

class NewPostView extends GetView<NewPostController> {
  const NewPostView({super.key});

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
            'নতুন পোস্ট',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _mediaHeader(),
              SizedBox(height: 10.h),
              _mediaRow(),
              SizedBox(height: 6.h),
              Text(
                'সর্বোচ্চ ৫টি ছবি ও ১টি ভিডিও · ভিডিও ৩০ সেকেন্ড',
                style: TextStyle(fontSize: 10.sp, color: AppColors.textGrey),
              ),
              SizedBox(height: 16.h),
              _label('শিরোনাম'),
              SizedBox(height: 6.h),
              TextField(
                controller: controller.titleCtrl,
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
                          style: _inputStyle,
                          decoration: _decoration('০'),
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
              SizedBox(height: 14.h),
              _locationBox(),
            ],
          ),
        ),
        bottomNavigationBar: Container(
          padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 10.h),
          color: AppColors.background,
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 50.h,
              child: ElevatedButton(
                onPressed: controller.publish,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  'পোস্ট প্রকাশ করুন',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ),
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

  // ছবি ও ভিডিও শিরোনাম + কাউন্টার
  Widget _mediaHeader() {
    return Obx(() {
      final count = controller.images.length;
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _label('ছবি ও ভিডিও'),
          if (count > 0)
            Text(
              '${toBn(count)}টি ছবি যোগ হয়েছে',
              style: TextStyle(fontSize: 11.sp, color: AppColors.textGrey),
            ),
        ],
      );
    });
  }

  Widget _mediaRow() {
    return SizedBox(
      height: 78.h,
      child: Obx(() {
        final images = controller.images.toList();
        final video = controller.hasVideo.value;
        return ListView(
          scrollDirection: Axis.horizontal,
          children: [
            for (var i = 0; i < images.length; i++)
              _thumb(images[i], i),
            _addBox(
              icon: Icons.photo_camera_outlined,
              label: 'ছবি যোগ করুন',
              onTap: controller.addPhoto,
            ),
            _addBox(
              icon: video ? Icons.check_circle_outline : Icons.videocam_outlined,
              label: video ? 'ভিডিও যোগ হয়েছে' : 'ভিডিও যোগ করুন',
              onTap: controller.addVideo,
            ),
          ],
        );
      }),
    );
  }

  Widget _thumb(String path, int index) {
    return Padding(
      padding: EdgeInsets.only(right: 8.w),
      child: SizedBox(
        width: 78.w,
        height: 78.h,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: Image.asset(path, fit: BoxFit.cover, cacheWidth: 300),
            ),
            Positioned(
              top: 4.h,
              right: 4.w,
              child: GestureDetector(
                onTap: () => controller.removePhoto(index),
                child: Container(
                  padding: EdgeInsets.all(3.w),
                  decoration: const BoxDecoration(
                    color: Colors.black87,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close, size: 12.sp, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _addBox({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: EdgeInsets.only(right: 8.w),
      child: GestureDetector(
        onTap: onTap,
        child: DashedBorder(
          color: AppColors.primary,
          radius: 10.r,
          child: Container(
            width: 96.w,
            height: 78.h,
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withOpacity(0.5),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 22.sp, color: AppColors.primary),
                SizedBox(height: 4.h),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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
        return DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: selected,
            isExpanded: true,
            icon: Icon(Icons.keyboard_arrow_down, size: 22.sp),
            style: _inputStyle,
            items: controller.categories
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

  Widget _locationBox() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(Icons.location_on_outlined,
              size: 20.sp, color: AppColors.primary),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ধানমন্ডি, ঢাকা',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'আপনার বর্তমান এলাকা স্বয়ংক্রিয়ভাবে যোগ হবে',
                  style: TextStyle(fontSize: 10.sp, color: AppColors.textGrey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}