import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../core/theme/app_colors.dart';

class OrDivider extends StatelessWidget {
  const OrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.border)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Text(
            'or',
            style: TextStyle(fontSize: 11.sp, color: AppColors.textGrey),
          ),
        ),
        const Expanded(child: Divider(color: AppColors.border)),
      ],
    );
  }
}

class SocialButtons extends StatelessWidget {
  final VoidCallback? onGoogle;
  final VoidCallback? onApple;

  const SocialButtons({super.key, this.onGoogle, this.onApple});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _btn(FontAwesomeIcons.google, onGoogle)),
        SizedBox(width: 12.w),
        Expanded(child: _btn(FontAwesomeIcons.apple, onApple)),
      ],
    );
  }

  Widget _btn(FaIconData icon, VoidCallback? onTap) {
    return SizedBox(
      height: 44.h,
      child: OutlinedButton(
        // TODO: google_sign_in / sign_in_with_apple বসবে
        onPressed: onTap ?? () {},
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textDark,
          side: const BorderSide(color: AppColors.border),
          shape: const StadiumBorder(),
        ),
        child: FaIcon(icon, size: 18.sp),
      ),
    );
  }
}