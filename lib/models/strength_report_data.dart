class StrengthReportData {
  final String? strength;
  final String? sectionName;
  final String? sectionId;
  final String? classId;
  final String? className;
  final String? genderId;

  StrengthReportData({
    this.strength,
    this.sectionName,
    this.sectionId,
    this.classId,
    this.className,
    this.genderId,
  });

  factory StrengthReportData.fromJson(Map<String, dynamic> json) {
    return StrengthReportData(
      strength: json['STRENGTH']?.toString(),
      sectionName: json['SECTION_NAME']?.toString(),
      sectionId: json['SECTION_ID']?.toString(),
      classId: json['CLASSES_ID']?.toString(),
      className: json['CLASS_NAME']?.toString(),
      genderId: json['GENDER_ID']?.toString(),
    );
  }
}
