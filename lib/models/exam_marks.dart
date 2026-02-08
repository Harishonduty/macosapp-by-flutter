class ExamMarks {
  final String firstName;
  final String subjectName;
  final String mark;
  final String result;
  final String examType;
  final String studentId;

  ExamMarks({
    required this.firstName,
    required this.subjectName,
    required this.mark,
    required this.result,
    required this.examType,
    required this.studentId,
  });

  factory ExamMarks.fromJson(Map<String, dynamic> json) {
    return ExamMarks(
      firstName: json['FIRST_NAME']?.toString() ?? '',
      subjectName: json['SUBJECT_NAME']?.toString() ?? '',
      mark: json['MARK']?.toString() ?? '',
      result: json['RESULT']?.toString() ?? '',
      examType: json['EXAM_TYPE']?.toString() ?? '',
      studentId: json['STUDENT_ID']?.toString() ?? '',
    );
  }
}
