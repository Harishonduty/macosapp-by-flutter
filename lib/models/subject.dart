class Subject {
  final String subjectId;
  final String subjectName;

  Subject({
    required this.subjectId,
    required this.subjectName,
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      subjectId: json['SUBJECT_ID']?.toString() ?? json['subject_id']?.toString() ?? '',
      subjectName: json['SUBJECT_NAME']?.toString() ?? json['subject_name']?.toString() ?? '',
    );
  }
}
