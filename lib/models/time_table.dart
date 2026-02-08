class TimeTable {
  final String timeTableId;
  final String subjectId;
  final String subjectName;
  final String day;
  final String hour;
  final String staffId;
  final String className;

  TimeTable({
    required this.timeTableId,
    required this.subjectId,
    required this.subjectName,
    required this.day,
    required this.hour,
    required this.staffId,
    required this.className,
  });

  factory TimeTable.fromJson(Map<String, dynamic> json) {
    return TimeTable(
      timeTableId: json['TIME_TABLE_ID']?.toString() ?? '',
      subjectId: json['SUBJECT_ID']?.toString() ?? '',
      subjectName: json['SUBJECT_NAME']?.toString() ?? '',
      day: json['DAY']?.toString() ?? '',
      hour: json['HOUR']?.toString() ?? '',
      staffId: json['STAFF_ID']?.toString() ?? '',
      className: json['CLASS_NAME']?.toString() ?? '',
    );
  }
}
