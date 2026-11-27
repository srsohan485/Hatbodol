import 'package:get/get.dart';
import 'package:hatbodol/Services/ApiService.dart';
import 'package:hatbodol/Services/StorageService.dart';
import 'package:hatbodol/core/utils/app_error.dart';
import 'package:hatbodol/core/utils/app_snackbar.dart';
import 'package:hatbodol/modules/home/models/product_model.dart';

/// কোন পণ্য সেভ করা আছে তার অবস্থা, পুরো অ্যাপে এক জায়গায়।
/// হোম, বিস্তারিত ও প্রোফাইলের হার্ট সব এখান থেকে পড়ে, তাই একসাথে বদলায়।
class SavedProducts {
  SavedProducts._();

  static final RxMap<int, bool> _state = <int, bool>{}.obs;
  static final Set<int> _busy = {};

  /// Obx এর ভেতর থেকে ডাকলে অবস্থা বদলালে নিজে থেকে আবার আঁকা হয়।
  /// এখানে কিছু না থাকলে সার্ভারের মানটাই ধরা হয়
  static bool isSaved(int id, bool serverValue) => _state[id] ?? serverValue;

  static void set(int id, bool value) => _state[id] = value;

  /// সার্ভার থেকে আসা তালিকার অবস্থা বসায় (সার্ভারের মানই শেষ কথা)
  static void syncAll(Iterable<ProductModel> items) {
    _state.addAll({for (final p in items) p.id: p.isSaved});
  }

  static int? _statusOf(Object e) {
    try {
      return (e as dynamic).statusCode as int?;
    } catch (_) {
      return null;
    }
  }

  /// সেভ থাকলে আনসেভ, না থাকলে সেভ। সাথে সাথে হার্ট বদলায়,
  /// সার্ভারে ব্যর্থ হলে আগের অবস্থায় ফেরে। শেষ অবস্থা ফেরত দেয়
  static Future<bool> toggle(int id, bool current) async {
    if (id == 0 || _busy.contains(id)) return current;
    _busy.add(id);

    final next = !current;
    _state[id] = next;

    try {
      final api = Get.find<ApiServices>();
      final headers = {
        'Authorization': 'Bearer ${StorageService.accessToken}',
      };
      final res = next
          ? await api.post('/products/$id/save/', headers: headers)
          : await api.delete('/products/$id/save/', headers: headers);

      final saved = res is Map ? res['is_saved'] == true : next;
      _state[id] = saved;
      return saved;
    } catch (e) {
      _state[id] = current;
      final code = _statusOf(e);
      if (code == 401) {
        StorageService.clearToken();
        Get.offAllNamed('/sign-in');
        showError('Session expired. Please sign in again.');
      } else if (code == 404) {
        showError('পণ্যটি আর খুঁজে পাওয়া যায়নি');
      } else {
        showError(apiErrorMessage(
          e,
          fallback: 'সেভ করা যায়নি, আবার চেষ্টা করুন',
        ));
      }
      return current;
    } finally {
      _busy.remove(id);
    }
  }
}