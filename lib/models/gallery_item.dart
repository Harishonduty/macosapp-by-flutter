class GalleryItem {
  final String galleryTitle;
  final String path;
  final String galleryId;
  final String fileType;
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
      fileType: json['File_Type']?.toString() ?? '',
      staffName: json['STAFF_NAME']?.toString() ?? '',
      entryDate: json['ENTRY_DATE']?.toString() ?? '',
    );
  }
}
