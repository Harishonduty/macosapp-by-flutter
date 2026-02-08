class PostExamMark {
  final String academicYearId;
  final String classId;
  final String componentId;
  final String examCompMarkId;
  final String examId;
  final String examSubCompId;
  final String smsFlag;
  final String studentId;
  final String subjectId;
  final String stuCompMark;

  PostExamMark({
    required this.academicYearId,
    required this.classId,
    required this.componentId,
    required this.examCompMarkId,
    required this.examId,
    required this.examSubCompId,
    required this.smsFlag,
    required this.studentId,
    required this.subjectId,
    required this.stuCompMark,
  });

  Map<String, dynamic> toJson() {
    return {
      'ACADEMIC_YEAR_ID': academicYearId,
      'CLASS_ID': classId,
      'COMPONENT_ID': componentId,
      'EXAM_COMP_MARK_ID': examCompMarkId,
      'EXAM_ID': examId,
      'EXAM_SUB_COMP_ID': examSubCompId,
      'SMSFLAG': smsFlag,
      'STUDENT_ID': studentId,
      'SUBJECT_ID': subjectId,
      'STU_COMP_MARK': stuCompMark,
    };
  }
}

class PostExamMarkList {
  final List<PostExamMark> marks;
  final String total;

  PostExamMarkList({required this.marks, required this.total});

  Map<String, dynamic> toJson() {
    return {
      'json_MARKS': marks.map((m) => m.toJson()).toList(),
      'chTotal': total,
    };
  }
}
