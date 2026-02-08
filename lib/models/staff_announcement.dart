class StaffAnnouncement {
  final String announceId;
  final String announcement;
  final String dateFrom;
  final String dateTo;
  final String roleId;
  final String classId;

  StaffAnnouncement({
    required this.announceId,
    required this.announcement,
    required this.dateFrom,
    required this.dateTo,
    required this.roleId,
    required this.classId,
  });

  factory StaffAnnouncement.fromJson(Map<String, dynamic> json) {
    return StaffAnnouncement(
      announceId: json['ANNOUNCE_ID']?.toString() ?? '',
      announcement: json['ANNOUNCE_MENT']?.toString() ?? '',
      dateFrom: json['DATE_FROM']?.toString() ?? '',
      dateTo: json['DATE_TO']?.toString() ?? '',
      roleId: json['ROLE_ID']?.toString() ?? '',
      classId: json['CLASS_ID']?.toString() ?? '',
    );
  }
}
