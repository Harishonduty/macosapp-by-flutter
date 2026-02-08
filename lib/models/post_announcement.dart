class PostAnnouncement {
  final String? announceId;
  final String announcement;
  final String dateFrom;
  final String dateTo;
  final String classId;

  PostAnnouncement({
    this.announceId,
    required this.announcement,
    required this.dateFrom,
    required this.dateTo,
    required this.classId,
  });

  Map<String, dynamic> toJson() {
    return {
      'ANNOUNCE_ID': announceId,
      'ANNOUNCE_MENT': announcement,
      'DATE_FROM': dateFrom,
      'DATE_TO': dateTo,
      'CLASS_ID': classId,
    };
  }
}
