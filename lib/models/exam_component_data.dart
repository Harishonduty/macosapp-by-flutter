class ExamComponentData {
  final String? componentId;
  final String? examSubCompId;
  final String? componentName;
  final String? maxMark;
  final String? passMark;

  ExamComponentData({
    this.componentId,
    this.examSubCompId,
    this.componentName,
    this.maxMark,
    this.passMark,
  });

  factory ExamComponentData.fromJson(Map<String, dynamic> json) {
    return ExamComponentData(
      componentId: json['COMPONENT_ID']?.toString(),
      examSubCompId: json['EXAM_SUB_COMP_ID']?.toString(),
      componentName: json['COMPONENT_NAME']?.toString(),
      maxMark: json['MAX_MARK']?.toString(),
      passMark: json['PASS_MARK']?.toString(),
    );
  }
}
