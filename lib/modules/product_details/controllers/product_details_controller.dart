import 'package:get/get.dart';
import 'package:hatbodol/Services/ApiService.dart';
import 'package:hatbodol/Services/StorageService.dart';

import '../../../core/utils/app_error.dart';
import '../../../core/utils/app_snackbar.dart';
import '../models/product_detail_model.dart';

class ProductDetailsController extends GetxController {
  final _api = Get.find<ApiServices>();

  final product = Rxn<ProductDetail>();
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  final currentImage = 0.obs;
  final isSaved = false.obs;
  final selectedReason = 0.obs;

  final reportReasons = const [
    'ভুয়া পোস্ট',
    'প্রতারণা',
    'আপত্তিকর কনটেন্ট',
    'অন্যান্য',
  ];

  int? _id;

  Map<String, String> get _authHeader =>
      {'Authorization': 'Bearer ${StorageService.accessToken}'};

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map) _id = (args['id'] as num?)?.toInt();
    fetchProduct();
  }

  Future<void> fetchProduct() async {
    final id = _id;
    if (id == null || id == 0) {
      errorMessage.value = 'পণ্যটি খুঁজে পাওয়া যায়নি';
      return;
    }
    if (isLoading.value) return;

    isLoading.value = true;
    errorMessage.value = '';
    try {
      final res = await _api.get('/products/$id/', headers: _authHeader)
      as Map<String, dynamic>;
      final p = ProductDetail.fromJson(res);
      product.value = p;
      isSaved.value = p.isSaved;
      currentImage.value = 0;
    } catch (e) {
      _handleError(e);
    } finally {
      isLoading.value = false;
    }
  }

  int? _statusOf(Object e) {
    try {
      return (e as dynamic).statusCode as int?;
    } catch (_) {
      return null;
    }
  }

  void _handleError(Object e) {
    final code = _statusOf(e);
    if (code == 401) {
      StorageService.clearToken();
      Get.offAllNamed('/sign-in');
      showError('Session expired. Please sign in again.');
      return;
    }
    if (code == 404) {
      errorMessage.value = 'পণ্যটি খুঁজে পাওয়া যায়নি (সম্ভবত মুছে ফেলা হয়েছে)';
      return;
    }
    errorMessage.value =
        apiErrorMessage(e, fallback: 'Could not load product details.');
  }

  void onPageChanged(int i) => currentImage.value = i;

  // TODO: সেভ/আনসেভ API বসবে (এখন শুধু অ্যাপের ভেতরে বদলায়)
  void toggleSave() => isSaved.toggle();

  void selectReason(int i) => selectedReason.value = i;

  // TODO: রিপোর্ট API বসবে
  void sendReport() {
    Get.back();
    Get.snackbar('ধন্যবাদ', 'আপনার রিপোর্ট পাঠানো হয়েছে');
  }

  // TODO: ব্লক API বসবে
  void blockSeller() {
    Get.back();
    Get.snackbar('ব্লক করা হয়েছে', 'বিক্রেতাকে ব্লক করা হয়েছে');
  }
}