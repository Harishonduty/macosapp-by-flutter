class PostStaffRemark {
  final String studentId;
  final String subjectId;
  final String remark;
  final String remarkType;
  final String entryId;
  final String entryDate;
  final String academicYearId;

  PostStaffRemark({
    required this.studentId,
    required this.subjectId,
    required this.remark,
    required this.remarkType,
    required this.entryId,
    required this.entryDate,
    required this.academicYearId,
  });

  Map<String, dynamic> toJson() {
    return {
      'STUDENT_ID': studentId,
      'SUBJECT_ID': subjectId,
      'REMARK': remark,
      'REMARK_TYPE': remarkType,
      'ENTRY_ID': entryId,
      'ENTRY_DATE': entryDate,
      'ACADEMIC_YEAR_ID': academicYearId,
    };
  }
}
