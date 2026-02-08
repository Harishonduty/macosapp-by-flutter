class StaffTimetable {
  final String classId;
  final String className;
  final String path;
  final String staffId;

  StaffTimetable({
    required this.classId,
    required this.className,
    required this.path,
    required this.staffId,
  });

  factory StaffTimetable.fromJson(Map<String, dynamic> json) {
    return StaffTimetable(
      classId: json['CLASS_ID']?.toString() ?? '',
      className: json['CLASS_NAME']?.toString() ?? '',
      path: json['PATH']?.toString() ?? '',
      staffId: json['STAFF_ID']?.toString() ?? '',
    );
  }
}
