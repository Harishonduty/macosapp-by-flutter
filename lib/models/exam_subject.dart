class ExamSubject {
  final String? examSubjectId;
  final String? classId;
  final String? subjectId;
  final String? examId;
  final String? subjectName;
  final String? maxMark;
  final String? minMark;

  ExamSubject({
    this.examSubjectId,
    this.classId,
    this.subjectId,
    this.examId,
    this.subjectName,
    this.maxMark,
    this.minMark,
  });

  factory ExamSubject.fromJson(Map<String, dynamic> json) {
    return ExamSubject(
      examSubjectId: (json['EXAM_SUBJECTID'] ?? json['EXAM_SUBJECT_ID'])?.toString(),
      classId: json['CLASS_ID']?.toString(),
      subjectId: json['SUBJECT_ID']?.toString(),
      examId: json['EXAM_ID']?.toString(),
      subjectName: json['SUBJECT_NAME']?.toString(),
      maxMark: json['MAX_MARK']?.toString(),
      minMark: json['MIN_MARK']?.toString(),
    );
  }
}
