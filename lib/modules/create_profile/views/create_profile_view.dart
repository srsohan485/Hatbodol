import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hatbodol/core/widgets/app_bottom_nav.dart';

import '../../../core/theme/app_colors.dart';
import '../controllers/create_profile_controller.dart';

class CreateProfileView extends GetView<CreateProfileController> {
  const CreateProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final isEdit = controller.isEdit;

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
            isEdit ? 'প্রোফাইল সম্পাদনা' : 'প্রোফাইল তৈরি করুন',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isEdit) ...[
                Text(
                  'আপনাকে স্বাগতম!',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  'আপনার পরিচয় দিন। একটি প্রোফাইল কাছের মানুষের সঙ্গে '
                      'কেনাবেচা সহজ করবে।',
                  style: TextStyle(
                    fontSize: 12.sp,
                    height: 1.5,
                    color: AppColors.textGrey,
                  ),
                ),
                SizedBox(height: 16.h),
              ],
              _photoCard(isEdit),
              Obx(
                    () => controller.hasPhoto
                    ? Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: controller.removePhoto,
                    child: Text(
                      'ছবি মুছুন',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.danger,
                      ),
                    ),
                  ),
                )
                    : const SizedBox.shrink(),
              ),
              SizedBox(height: 10.h),
              _label('আপনার নাম (আবশ্যক)'),
              SizedBox(height: 6.h),
              TextField(
                controller: controller.nameCtrl,
                textInputAction: TextInputAction.done,
                style: _inputStyle,
                decoration: _decoration('আপনার নাম লিখুন'),
              ),
              SizedBox(height: 16.h),
              _label('আপনার এলাকা (আবশ্যক)'),
              SizedBox(height: 6.h),
              _areaBox(),
              SizedBox(height: 22.h),
              Obx(
                    () => SizedBox(
                  width: double.infinity,
                  height: 50.h,
                  child: ElevatedButton(
                    onPressed:
                    controller.isLoading.value ? null : controller.start,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      disabledBackgroundColor:
                      AppColors.primary.withOpacity(0.6),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: controller.isLoading.value
                        ? SizedBox(
                      width: 20.w,
                      height: 20.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : Text(
                      isEdit ? 'সংরক্ষণ করুন' : 'শুরু করুন',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: AppBottomNav(
          currentIndex: 3,
          onTap: (i) {
            if (i == 0) Get.offAllNamed('/home');
            if (i == 1) Get.toNamed('/search');
            if (i == 2) Get.toNamed('/new-post');
          },
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
      borderRadius: BorderRadius.circular(12.r),
      borderSide: BorderSide(color: c),
    );
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(fontSize: 13.sp, color: AppColors.textGrey),
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      enabledBorder: border(AppColors.border),
      focusedBorder: border(AppColors.primary),
      border: border(AppColors.border),
    );
  }

  Widget _photoCard(bool isEdit) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: controller.pickPhoto,
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Row(
          children: [
            Obx(() {
              final path = controller.photoPath.value;
              final url = controller.photoUrl.value;
              final ImageProvider? provider = path != null
                  ? FileImage(File(path))
                  : (url != null ? NetworkImage(url) : null);

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 28.r,
                    backgroundColor: Colors.white,
                    backgroundImage: provider,
                    child: provider == null
                        ? Icon(Icons.person_outline,
                        size: 30.sp, color: AppColors.primary)
                        : null,
                  ),
                  Positioned(
                    right: -2.w,
                    bottom: -2.h,
                    child: Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: Icon(Icons.photo_camera,
                          size: 11.sp, color: Colors.white),
                    ),
                  ),
                ],
              );
            }),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEdit ? 'ছবি বদলান' : 'ছবি যোগ করুন',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    isEdit
                        ? 'নতুন ছবি বাছাই করতে চাপুন'
                        : 'ঐচ্ছিক - পরে যোগ করতে পারবেন',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: AppColors.textGrey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _areaBox() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: controller.changeArea,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(Icons.location_on, size: 18.sp, color: AppColors.primary),
            SizedBox(width: 8.w),
            Expanded(
              child: Obx(() {
                final a = controller.area.value;
                return Text(
                  a.isEmpty ? 'এলাকা বাছুন' : a,
                  style: a.isEmpty
                      ? _inputStyle.copyWith(color: AppColors.textGrey)
                      : _inputStyle,
                );
              }),
            ),
            Text(
              'পরিবর্তন',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}