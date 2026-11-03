class ProductModel {
  final String title;
  final String price;
  final String distance;
  final String image;
  final bool hasVideo;

  const ProductModel({
    required this.title,
    required this.price,
    required this.distance,
    required this.image,
    this.hasVideo = false,
  });
}