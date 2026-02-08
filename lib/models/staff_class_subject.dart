class StaffClassSubject {
  final String classSubjectId;
  final String subjectName;
  final String className;
  final String classId;
  final String subjectId;

  StaffClassSubject({
    required this.classSubjectId,
    required this.subjectName,
    required this.className,
    required this.classId,
    required this.subjectId,
  });

  factory StaffClassSubject.fromJson(Map<String, dynamic> json) {
    return StaffClassSubject(
      classSubjectId: json['CLASS_SUBJECT_ID']?.toString() ?? '',
      subjectName: json['SUBJECT_NAME']?.toString() ?? '',
      className: json['CLASS_NAME']?.toString() ?? '',
      classId: json['CLASS_ID']?.toString() ?? '',
      subjectId: json['SUBJECT_ID']?.toString() ?? '',
    );
  }
}
