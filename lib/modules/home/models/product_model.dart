class ProductModel {
  final int id;
  final String title;
  final String price; // দেখানোর জন্য, যেমন "৳ ৪৫০"
  final double priceValue; // ফিল্টারের জন্য সংখ্যা
  final String distance; // দেখানোর জন্য: "১.২ কিমি দূর" বা এলাকার নাম
  final double? distanceKm;
  final String area;
  final String image;
  final bool hasVideo;
  final String category;
  final String condition; // "used" বা "new"
  final bool isSaved;

  const ProductModel({
    this.id = 0,
    required this.title,
    required this.price,
    required this.distance,
    required this.image,
    this.priceValue = 0,
    this.distanceKm,
    this.area = '',
    this.hasVideo = false,
    this.category = '',
    this.condition = '',
    this.isSaved = false,
  });

  bool get isUsed => condition == 'used';

  factory ProductModel.fromJson(Map<String, dynamic> j) {
    final km = j['distance_km'];
    final area = (j['area'] ?? '').toString();
    return ProductModel(
      id: (j['id'] as num?)?.toInt() ?? 0,
      title: (j['title'] ?? '').toString(),
      price: _formatPrice(j['price']),
      priceValue: double.tryParse('${j['price']}') ?? 0,
      distance: km is num ? '${_bn(km.toStringAsFixed(1))} কিমি দূর' : area,
      distanceKm: km is num ? km.toDouble() : null,
      area: area,
      image: (j['thumbnail'] ?? '').toString(),
      hasVideo: j['has_video'] == true,
      category: (j['category'] ?? '').toString(),
      condition: (j['condition'] ?? '').toString(),
      isSaved: j['is_saved'] == true,
    );
  }
}

String _bn(String s) {
  const en = '0123456789';
  const bn = '০১২৩৪৫৬৭৮৯';
  return s.split('').map((c) {
    final i = en.indexOf(c);
    return i == -1 ? c : bn[i];
  }).join();
}

String _formatPrice(dynamic v) {
  final n = num.tryParse('$v');
  if (n == null) return '৳ $v';
  final s = n.round().toString().replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+$)'),
        (m) => '${m[1]},',
  );
  return '৳ ${_bn(s)}';
}