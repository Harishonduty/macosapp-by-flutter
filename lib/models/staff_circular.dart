class StaffCircular {
  final String circularId;
  final String academicYearId;
  final String classId;
  final String circularMessage;
  final String entryId;
  final String entryDate;
  final String isActive;
  final String isDeleted;
  final String className;
  final String staffName;

  StaffCircular({
    required this.circularId,
    required this.academicYearId,
    required this.classId,
    required this.circularMessage,
    required this.entryId,
    required this.entryDate,
    required this.isActive,
    required this.isDeleted,
    required this.className,
    required this.staffName,
  });

  factory StaffCircular.fromJson(Map<String, dynamic> json) {
    return StaffCircular(
      circularId: json['CIRCULAR_ID']?.toString() ?? '',
      academicYearId: json['ACADEMIC_YEAR_ID']?.toString() ?? '',
      classId: json['CLASS_ID']?.toString() ?? '',
      circularMessage: json['CIRCULAR_MESSAGE']?.toString() ?? '',
      entryId: json['ENTRY_ID']?.toString() ?? '',
      entryDate: json['ENTRY_DATE']?.toString() ?? '',
      isActive: json['IS_ACTIVE']?.toString() ?? '',
      isDeleted: json['IS_DELETED']?.toString() ?? '',
      className: json['CLASS_NAME']?.toString() ?? '',
      staffName: json['STAFF_NAME']?.toString() ?? '',
    );
  }
}
