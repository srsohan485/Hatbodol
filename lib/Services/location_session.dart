import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

/// বাছাই করা এলাকা, যা পুরো অ্যাপ থেকে পড়া যায় (অ্যাপ বন্ধ করলেও থাকে)
class LocationSession {
  LocationSession._();

  static final _box = GetStorage();

  static final areaName = ((_box.read('area_name') as String?) ?? '').obs;
  static final areaId = ((_box.read('area_id') as num?)?.toInt() ?? 0).obs;

  static double? get latitude => (_box.read('area_lat') as num?)?.toDouble();
  static double? get longitude => (_box.read('area_lng') as num?)?.toDouble();

  static bool get hasArea => areaId.value != 0;

  static Future<void> save({
    required int id,
    required String name,
    required double latitude,
    required double longitude,
  }) async {
    areaId.value = id;
    areaName.value = name;
    await _box.write('area_id', id);
    await _box.write('area_name', name);
    await _box.write('area_lat', latitude);
    await _box.write('area_lng', longitude);
  }

  static Future<void> clear() async {
    areaId.value = 0;
    areaName.value = '';
    await _box.remove('area_id');
    await _box.remove('area_name');
    await _box.remove('area_lat');
    await _box.remove('area_lng');
  }
}