import 'package:holy_cross_app/models/gallery_item.dart';

class GalleryDateGroup {
  final String date;
  final List<GalleryItem> images;

  GalleryDateGroup({
    required this.date,
    required this.images,
  });

  factory GalleryDateGroup.fromJson(Map<String, dynamic> json) {
    return GalleryDateGroup(
      date: json['Date']?.toString() ?? '',
      images: (json['Images'] as List<dynamic>?)
              ?.map((e) => GalleryItem.fromJson(e))
              .toList() ??
          [],
    );
  }
}
