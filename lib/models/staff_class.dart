class StaffClass {
  final String classId;
  final String classesId;
  final String className;
  final String sectionName;

  StaffClass({
    required this.classId,
    required this.classesId,
    required this.className,
    required this.sectionName,
  });

  factory StaffClass.fromJson(Map<String, dynamic> json) {
    return StaffClass(
      classId: json['CLASS_ID']?.toString() ?? json['class_id']?.toString() ?? '',
      classesId: json['CLASSES_ID']?.toString() ?? json['classes_id']?.toString() ?? '',
      className: json['CLASS_NAME']?.toString() ?? json['class_name']?.toString() ?? '',
      sectionName: json['SECTION_NAME']?.toString() ?? json['section_name']?.toString() ?? '',
    );
  }
}
