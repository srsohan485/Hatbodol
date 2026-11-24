class AreaModel {
  final int id;
  final String name;
  final double latitude;
  final double longitude;

  const AreaModel({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  factory AreaModel.fromJson(Map<String, dynamic> j) => AreaModel(
    id: (j['id'] as num?)?.toInt() ?? 0,
    name: (j['name'] ?? '').toString(),
    latitude: double.tryParse('${j['latitude']}') ?? 0,
    longitude: double.tryParse('${j['longitude']}') ?? 0,
  );
}