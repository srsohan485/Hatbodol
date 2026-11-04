import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hatbodol/modules/chat/bindings/chat_binding.dart';
import 'package:hatbodol/modules/chat/bindings/chat_list_binding.dart';
import 'package:hatbodol/modules/chat/views/chat_list_view.dart';
import 'package:hatbodol/modules/chat/views/chat_view.dart';
import 'package:hatbodol/modules/location/bindings/location_binding.dart';
import 'package:hatbodol/modules/location/views/location_permission_view.dart';
import 'package:hatbodol/modules/new_post/bindings/new_post_binding.dart';
import 'package:hatbodol/modules/new_post/views/new_post_view.dart';
import 'package:hatbodol/modules/search_results/bindings/search_results_binding.dart';
import 'package:hatbodol/modules/search_results/views/search_results_view.dart';
import 'package:hatbodol/modules/seller_profile/bindings/seller_profile_binding.dart';
import 'package:hatbodol/modules/seller_profile/views/seller_profile_view.dart';

import 'core/theme/app_colors.dart';
import 'modules/home/bindings/home_binding.dart';
import 'modules/home/views/home_view.dart';
import 'modules/product_details/bindings/product_details_binding.dart';
import 'modules/product_details/views/product_details_view.dart';
import 'modules/profile/bindings/profile_binding.dart';
import 'modules/profile/views/profile_view.dart';
import 'modules/settings/bindings/settings_binding.dart';
import 'modules/settings/views/settings_view.dart';

import 'modules/auth/bindings/auth_bindings.dart';
import 'modules/auth/views/forgot_password_view.dart';
import 'modules/auth/views/otp_view.dart';
import 'modules/auth/views/reset_password_view.dart';
import 'modules/auth/views/sign_in_view.dart';
import 'modules/auth/views/sign_up_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 800),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Hatbodol',
          theme: ThemeData(
            useMaterial3: true,
            scaffoldBackgroundColor: AppColors.background,
            colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
            // pubspec.yaml e font add korle ekhane name dao
            // fontFamily: 'HindSiliguri',
          ),
          initialRoute: '/sign-in',
          getPages: [
            GetPage(
              name: '/home',
              page: () => const HomeView(),
              binding: HomeBinding(),
            ),
            GetPage(
              name: '/product-details',
              page: () => const ProductDetailsView(),
              binding: ProductDetailsBinding(),
            ),
            GetPage(
              name: '/profile',
              page: () => const ProfileView(),
              binding: ProfileBinding(),
            ),
            GetPage(
              name: '/settings',
              page: () => const SettingsView(),
              binding: SettingsBinding(),
            ),
            GetPage(
              name: '/seller-profile',
              page: () => const SellerProfileView(),
              binding: SellerProfileBinding(),
            ),
            GetPage(
              name: '/location-permission',
              page: () => const LocationPermissionView(),
              binding: LocationBinding(),
            ),
            GetPage(
              name: '/new-post',
              page: () => const NewPostView(),
              binding: NewPostBinding(),
            ),
            GetPage(
              name: '/search',
              page: () => const SearchResultsView(),
              binding: SearchResultsBinding(),
            ),
            GetPage(
              name: '/chat',
              page: () => const ChatView(),
              binding: ChatBinding(),
            ),
            GetPage(
              name: '/chat-list',
              page: () => const ChatListView(),
              binding: ChatListBinding(),
            ),
            GetPage(
              name: '/sign-in',
              page: () => const SignInView(),
              binding: SignInBinding(),
            ),
            GetPage(
              name: '/sign-up',
              page: () => const SignUpView(),
              binding: SignUpBinding(),
            ),
            GetPage(
              name: '/forgot-password',
              page: () => const ForgotPasswordView(),
              binding: ForgotPasswordBinding(),
            ),
            GetPage(
              name: '/otp',
              page: () => const OtpView(),
              binding: OtpBinding(),
            ),
            GetPage(
              name: '/reset-password',
              page: () => const ResetPasswordView(),
              binding: ResetPasswordBinding(),
            ),
          ],
        );
      },
    );
  }
}
