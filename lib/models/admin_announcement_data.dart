class AdminAnnouncementData {
  final String? announceId;
  final String? announcement;
  final String? dateFrom;
  final String? dateTo;
  final String? roleId;
  final String? classId;

  AdminAnnouncementData({
    this.announceId,
    this.announcement,
    this.dateFrom,
    this.dateTo,
    this.roleId,
    this.classId,
  });

  factory AdminAnnouncementData.fromJson(Map<String, dynamic> json) {
    return AdminAnnouncementData(
      announceId: json['ANNOUNCE_ID']?.toString(),
      announcement: json['ANNOUNCE_MENT']?.toString(),
      dateFrom: json['DATE_FROM']?.toString(),
      dateTo: json['DATE_TO']?.toString(),
      roleId: json['ROLE_ID']?.toString(),
      classId: json['CLASS_ID']?.toString(),
    );
  }
}
