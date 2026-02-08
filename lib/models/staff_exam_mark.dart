class StaffExamMark {
  final String firstName;
  final String subjectName;
  final String mark;
  final String result;
  final String examName;
  final String componentName;
  final String admissionNo;
  final String studentId;
  final String total;
  final String grade;

  StaffExamMark({
    required this.firstName,
    required this.subjectName,
    required this.mark,
    required this.result,
    required this.examName,
    required this.componentName,
    required this.admissionNo,
    required this.studentId,
    required this.total,
    required this.grade,
  });

  factory StaffExamMark.fromJson(Map<String, dynamic> json) {
    return StaffExamMark(
      firstName: json['FIRST_NAME']?.toString() ?? json['NAME']?.toString() ?? '',
      subjectName: json['SUBJECT_NAME']?.toString() ?? '',
      mark: json['MARK']?.toString() ?? json['STU_COMP_MARK']?.toString() ?? '',
      result: json['RESULT']?.toString() ?? '',
      examName: json['EXAM_NAME']?.toString() ?? '',
      componentName: json['COMPONENT_NAME']?.toString() ?? '',
      admissionNo: json['ADMISSION_NO']?.toString() ?? '',
      studentId: json['STUDENT_ID']?.toString() ?? '',
      total: json['TOTAL']?.toString() ?? '',
      grade: json['GRADE']?.toString() ?? '',
    );
  }
}
