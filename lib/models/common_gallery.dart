class GalleryItem {
  final String galleryTitle;
  final String path;
  final String galleryId;
  final String fileType; // 1: Image, 2: Video, 3: YouTube
  final String staffName;
  final String entryDate;

  GalleryItem({
    required this.galleryTitle,
    required this.path,
    required this.galleryId,
    required this.fileType,
    required this.staffName,
    required this.entryDate,
  });

  factory GalleryItem.fromJson(Map<String, dynamic> json) {
    return GalleryItem(
      galleryTitle: json['GALLARY_TITLE']?.toString() ?? '',
      path: json['PATH']?.toString() ?? '',
      galleryId: json['GALLARY_ID']?.toString() ?? '',
      fileType: json['File_Type']?.toString() ?? '1',
      staffName: json['STAFF_NAME']?.toString() ?? '',
      entryDate: json['ENTRY_DATE']?.toString() ?? '',
    );
  }
}

class GalleryDateGroup {
  final String date;
  final List<GalleryItem> items;

  GalleryDateGroup({required this.date, required this.items});

  factory GalleryDateGroup.fromJson(Map<String, dynamic> json) {
    final List list = json['Images'] ?? [];
    return GalleryDateGroup(
      date: json['Date']?.toString() ?? '',
      items: list.map((e) => GalleryItem.fromJson(e)).toList(),
    );
  }
}
