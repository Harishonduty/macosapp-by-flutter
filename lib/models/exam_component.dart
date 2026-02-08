class ExamComponent {
  final String componentId;
  final String examSubCompId;
  final String componentName;
  final String classId;
  final String maxMark;
  final String passMark;

  ExamComponent({
    required this.componentId,
    required this.examSubCompId,
    required this.componentName,
    required this.classId,
    required this.maxMark,
    required this.passMark,
  });

  factory ExamComponent.fromJson(Map<String, dynamic> json) {
    return ExamComponent(
      componentId: json['COMPONENT_ID']?.toString() ?? '',
      examSubCompId: json['EXAM_SUB_COMP_ID']?.toString() ?? '',
      componentName: json['COMPONENT_NAME']?.toString() ?? '',
      classId: json['CLASS_ID']?.toString() ?? '',
      maxMark: json['MAX_MARK']?.toString() ?? '',
      passMark: json['PASS_MARK']?.toString() ?? '',
    );
  }
}
