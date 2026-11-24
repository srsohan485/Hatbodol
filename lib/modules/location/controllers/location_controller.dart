import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:hatbodol/Services/ApiService.dart';
import 'package:hatbodol/Services/StorageService.dart';
import 'package:hatbodol/Services/location_session.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_error.dart';
import '../../../core/utils/app_snackbar.dart';
import '../models/area_model.dart';

class LocationController extends GetxController {
  final _api = Get.find<ApiServices>();

  final areas = <AreaModel>[].obs;
  final isLoading = false.obs;

  bool _busy = false;

  /// এই দূরত্বের (কিমি) মধ্যে কোনো এলাকা না পেলে "তালিকায় নেই" ধরা হবে
  static const _maxKm = 30.0;

  @override
  void onInit() {
    super.onInit();
    fetchAreas();
  }

  Map<String, String> get _authHeader =>
      {'Authorization': 'Bearer ${StorageService.accessToken}'};

  /// এলাকার তালিকা লোড। সফল হলে true
  Future<bool> fetchAreas() async {
    if (areas.isNotEmpty) return true;
    isLoading.value = true;
    try {
      final res = await _api.get('/products/areas/', headers: _authHeader);
      final list = (res as List?) ?? [];
      areas.assignAll(
        list.map((e) => AreaModel.fromJson(e as Map<String, dynamic>)),
      );
      return areas.isNotEmpty;
    } catch (e) {
      showError(apiErrorMessage(e, fallback: 'Could not load areas.'));
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// এলাকা ঠিক হয়ে গেলে: সেভ করে, তারপর আগের পেজে ফেরে বা হোমে যায়
  Future<void> _finish(AreaModel area) async {
    await LocationSession.save(
      id: area.id,
      name: area.name,
      latitude: area.latitude,
      longitude: area.longitude,
    );

    if (Get.key.currentState?.canPop() == true) {
      Get.back(result: area.name);
    } else {
      Get.offAllNamed('/home');
    }
    showSuccess('এলাকা: ${area.name}');
  }

  // ─── হাতে এলাকা বাছাই ───
  Future<void> chooseManually() async {
    if (!await fetchAreas()) return;

    Get.bottomSheet(
      Container(
        constraints: BoxConstraints(maxHeight: Get.height * 0.6),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'এলাকা বেছে নিন',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
            ),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: areas.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final a = areas[i];
                  return ListTile(
                    leading: const Icon(Icons.location_on_outlined),
                    title: Text(a.name),
                    onTap: () {
                      Get.back(); // বটম শিট বন্ধ
                      _finish(a);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  // ─── GPS দিয়ে ───
  Future<void> enableLocation() async {
    if (_busy) return;
    _busy = true;
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    String? problem;
    AreaModel? nearest;
    try {
      problem = await _ensurePermission();
      if (problem == null) {
        if (!await fetchAreas()) return; // error আগেই দেখানো হয়েছে
        final pos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium,
            timeLimit: Duration(seconds: 15),
          ),
        );
        nearest = _nearest(pos);
        if (nearest == null) {
          problem = 'আপনি তালিকার এলাকাগুলোর কাছে নেই। হাতে এলাকা বেছে নিন';
        }
      }
    } catch (_) {
      problem = 'লোকেশন পাওয়া যায়নি, আবার চেষ্টা করুন';
    } finally {
      if (Get.isDialogOpen == true) Get.back(); // লোডিং বন্ধ
      _busy = false;
    }

    if (nearest != null) {
      await _finish(nearest);
    } else if (problem != null) {
      showError(problem);
    }
  }

  /// ফোনের GPS চালু আছে কিনা আর অনুমতি আছে কিনা দেখে। সমস্যা হলে মেসেজ ফেরত দেয়
  Future<String?> _ensurePermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return 'ফোনের লোকেশন (GPS) বন্ধ আছে, চালু করুন';
    }
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.denied) {
      return 'লোকেশনের অনুমতি দেওয়া হয়নি';
    }
    if (perm == LocationPermission.deniedForever) {
      return 'অনুমতি বন্ধ করা আছে, ফোনের সেটিংস থেকে চালু করুন';
    }
    return null;
  }

  /// সবচেয়ে কাছের এলাকা। ৩০ কিমির মধ্যে না থাকলে null
  AreaModel? _nearest(Position p) {
    AreaModel? best;
    var bestMeters = double.infinity;
    for (final a in areas) {
      final m = Geolocator.distanceBetween(
        p.latitude,
        p.longitude,
        a.latitude,
        a.longitude,
      );
      if (m < bestMeters) {
        bestMeters = m;
        best = a;
      }
    }
    return bestMeters <= _maxKm * 1000 ? best : null;
  }
}