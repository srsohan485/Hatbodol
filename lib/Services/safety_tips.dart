import 'package:get/get.dart';
import 'package:hatbodol/Services/ApiService.dart';
import 'package:hatbodol/Services/StorageService.dart';

/// "নিরাপদে কেনাবেচা" ডায়ালগের লেখা। শুরুতে ডিফল্ট লেখা থাকে,
/// সার্ভার থেকে আসলে সেটা দিয়ে বদলে যায়।
class SafetyTips {
  SafetyTips._();

  static final title = 'নিরাপদে কেনাবেচা করুন'.obs;
  static final subtitle =
      'বিক্রেতার সঙ্গে যোগাযোগের আগে এই বিষয়গুলো মনে রাখুন'.obs;
  static final tips = <String>[
    'অগ্রিম টাকা পাঠাবেন না',
    'সামনাসামনি দেখে কিনুন',
    'পণ্য যাচাই করে টাকা দিন',
  ].obs;

  static bool _loaded = false;
  static bool _loading = false;

  static Future<void> load() async {
    if (_loaded || _loading) return;
    _loading = true;
    try {
      final api = Get.find<ApiServices>();
      final res = await api.get(
        '/products/safety-tips/',
        headers: {'Authorization': 'Bearer ${StorageService.accessToken}'},
      );
      if (res is! Map) return;

      final t = (res['title'] ?? '').toString();
      final s = (res['subtitle'] ?? '').toString();
      final list = ((res['tips'] as List?) ?? [])
          .map((e) => e.toString())
          .where((e) => e.isNotEmpty)
          .toList();

      if (t.isNotEmpty) title.value = t;
      if (s.isNotEmpty) subtitle.value = s;
      if (list.isNotEmpty) tips.assignAll(list);
      _loaded = true;
    } catch (_) {
      // নীরবে বাদ, ডিফল্ট লেখাই থাকবে। পরের বার আবার চেষ্টা হবে
    } finally {
      _loading = false;
    }
  }
}