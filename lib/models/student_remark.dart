class StudentRemark {
  final String remarkId;
  final String remark;
  final String remarkType;
  final String entryId;
  final String entryDate;
  final String studentId;
  final String studentName;
  final String subjectName;
  final String staffName;

  StudentRemark({
    required this.remarkId,
    required this.remark,
    required this.remarkType,
    required this.entryId,
    required this.entryDate,
    required this.studentId,
    required this.studentName,
    required this.subjectName,
    required this.staffName,
  });

  factory StudentRemark.fromJson(Map<String, dynamic> json) {
    return StudentRemark(
      remarkId: json['REMARK_ID']?.toString() ?? '',
      remark: json['REMARK']?.toString() ?? '',
      remarkType: json['REMARK_TYPE']?.toString() ?? '',
      entryId: json['ENTRY_ID']?.toString() ?? '',
      entryDate: json['ENTRY_DATE']?.toString() ?? '',
      studentId: json['STUDENT_ID']?.toString() ?? '',
      studentName: json['STUDENT_NAME']?.toString() ?? '',
      subjectName: json['SUBJECT_NAME']?.toString() ?? '',
      staffName: json['STAFF_NAME']?.toString() ?? '',
    );
  }
}
