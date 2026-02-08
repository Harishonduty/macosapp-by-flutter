class StudentExamDetails {
  final String examId;
  final String examName;
  final String examType;
  final String isActive;
  final String dateFrom;
  final String dateTo;

  StudentExamDetails({
    required this.examId,
    required this.examName,
    required this.examType,
    required this.isActive,
    required this.dateFrom,
    required this.dateTo,
  });

  factory StudentExamDetails.fromJson(Map<String, dynamic> json) {
    return StudentExamDetails(
      examId: json['EXAM_ID']?.toString() ?? '',
      examName: json['EXAM_NAME']?.toString() ?? '',
      examType: json['EXAM_TYPE']?.toString() ?? '',
      isActive: json['IS_ACTIVE']?.toString() ?? '',
      dateFrom: json['DATE_FROM']?.toString() ?? '',
      dateTo: json['DATE_TO']?.toString() ?? '',
    );
  }
}
