class SellerInfo {
  final int id;
  final String name;
  final String photo;
  final String area;
  final bool phoneVerified;
  final int productsCount;

  const SellerInfo({
    this.id = 0,
    this.name = '',
    this.photo = '',
    this.area = '',
    this.phoneVerified = false,
    this.productsCount = 0,
  });

  factory SellerInfo.fromJson(Map<String, dynamic> j) => SellerInfo(
    id: (j['id'] as num?)?.toInt() ?? 0,
    name: (j['name'] ?? '').toString(),
    photo: (j['photo'] ?? '').toString(),
    area: (j['area'] ?? '').toString(),
    phoneVerified: j['phone_verified'] == true,
    productsCount: (j['products_count'] as num?)?.toInt() ?? 0,
  );
}

class ProductDetail {
  final int id;
  final String title;
  final String price; // দেখানোর জন্য, যেমন "৳ ৪৫০"
  final String description;
  final String conditionLabel;
  final String area;
  final double? distanceKm;
  final bool hasVideo;
  final bool isSaved;
  final bool isMine;
  final DateTime? createdAt;
  final List<String> images;
  final SellerInfo seller;

  const ProductDetail({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.conditionLabel,
    required this.area,
    required this.distanceKm,
    required this.hasVideo,
    required this.isSaved,
    required this.isMine,
    required this.createdAt,
    required this.images,
    required this.seller,
  });

  factory ProductDetail.fromJson(Map<String, dynamic> j) {
    final km = j['distance_km'];

    // ছবির তালিকা। না থাকলে thumbnail কে একমাত্র ছবি ধরা হয়
    final imgs = ((j['images'] as List?) ?? [])
        .map((e) => ((e as Map)['url'] ?? '').toString())
        .where((u) => u.isNotEmpty)
        .toList();
    final thumb = (j['thumbnail'] ?? '').toString();
    if (imgs.isEmpty && thumb.isNotEmpty) imgs.add(thumb);

    return ProductDetail(
      id: (j['id'] as num?)?.toInt() ?? 0,
      title: (j['title'] ?? '').toString(),
      price: _formatPrice(j['price']),
      description: (j['description'] ?? '').toString().trim(),
      conditionLabel: (j['condition_label'] ?? '').toString(),
      area: (j['area'] ?? '').toString(),
      distanceKm: km is num ? km.toDouble() : null,
      hasVideo: j['has_video'] == true,
      isSaved: j['is_saved'] == true,
      isMine: j['is_mine'] == true,
      createdAt: DateTime.tryParse((j['created_at'] ?? '').toString()),
      images: imgs,
      seller: j['seller'] is Map
          ? SellerInfo.fromJson(j['seller'] as Map<String, dynamic>)
          : const SellerInfo(),
    );
  }

  /// "১.২ কিমি দূর" বা (দূরত্ব না থাকলে) এলাকার নাম
  String get distanceText =>
      distanceKm != null ? '${_bn(distanceKm!.toStringAsFixed(1))} কিমি দূর' : area;

  /// "২ ঘণ্টা আগে" ধরনের লেখা
  String get timeAgo {
    final t = createdAt;
    if (t == null) return '';
    final d = DateTime.now().difference(t);
    if (d.inMinutes < 1) return 'এইমাত্র';
    if (d.inMinutes < 60) return '${_bn('${d.inMinutes}')} মিনিট আগে';
    if (d.inHours < 24) return '${_bn('${d.inHours}')} ঘণ্টা আগে';
    if (d.inDays < 30) return '${_bn('${d.inDays}')} দিন আগে';
    if (d.inDays < 365) return '${_bn('${d.inDays ~/ 30}')} মাস আগে';
    return '${_bn('${d.inDays ~/ 365}')} বছর আগে';
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