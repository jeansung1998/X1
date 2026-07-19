class Wallpaper {
  final String id;
  final String title;
  final String category;
  final int price;
  final String priceLabel;
  final String? thumbnailUrl;
  final String? videoUrl;
  final List<String> tags;

  Wallpaper({
    required this.id,
    required this.title,
    required this.category,
    required this.price,
    required this.priceLabel,
    this.thumbnailUrl,
    this.videoUrl,
    this.tags = const [],
  });

  factory Wallpaper.fromJson(Map<String, dynamic> json) {
    return Wallpaper(
      id: json['id'],
      title: json['title'],
      category: json['category'],
      price: json['price'],
      priceLabel: json['price_label'],
      thumbnailUrl: json['thumbnail_url'],
      videoUrl: json['video_url'],
      tags: json['tags'] == null
          ? const []
          : List<String>.from(json['tags'] as List),
    );
  }
}