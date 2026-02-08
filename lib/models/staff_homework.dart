class StaffHomework {
  final String homeworkId;
  final String className;
  final String description;
  final String homeworkDate;
  final String submissionDate;
  final String subjectName;
  final String classId;
  final String subjectId;

  StaffHomework({
    required this.homeworkId,
    required this.className,
    required this.description,
    required this.homeworkDate,
    required this.submissionDate,
    required this.subjectName,
    required this.classId,
    this.subjectId = '',
  });

  factory StaffHomework.fromJson(Map<String, dynamic> json) {
    return StaffHomework(
      homeworkId: json['HOMEWORK_ID']?.toString() ?? '',
      className: json['CLASS_NAME']?.toString() ?? '',
      description: json['DESCRIPTION']?.toString() ?? '',
      homeworkDate: json['HOMEWORK_DATE']?.toString() ?? '',
      submissionDate: json['SUBMISSION_DATE']?.toString() ?? '',
      subjectName: json['SUBJECT_NAME']?.toString() ?? '',
      classId: json['CLASS_ID']?.toString() ?? '',
      subjectId: json['SUBJECT_ID']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'CLASS_ID': classId,
      'SUBJECT_ID': subjectId,
      'HOMEWORK_DATE': homeworkDate,
      'HOMEWORK_DESCRIPTION': description,
      'SUBMISSION_DATE': submissionDate,
    };
  }
}
