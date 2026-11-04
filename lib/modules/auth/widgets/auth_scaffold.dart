import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_colors.dart';

/// লোগো, শিরোনাম, মাঝের ফিল্ড আর নিচের অংশ নিয়ে সব auth পেজের একই কাঠামো
class AuthScaffold extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final Widget bottom;

  const AuthScaffold({
    super.key,
    required this.title,
    required this.children,
    required this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusScope.of(context).unfocus(),
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 24.h),
                      Center(
                        child: Image.asset(
                          'assets/images/topicon.jpg',
                          height: 64.h,
                          fit: BoxFit.contain,
                        ),
                      ),
                      SizedBox(height: 14.h),
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                      ),
                      SizedBox(height: 18.h),
                      ...children,
                      const Spacer(),
                      SizedBox(height: 24.h),
                      bottom,
                      SizedBox(height: 16.h),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}