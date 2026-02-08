class StaffRemark {
  final String remarkId;
  final String remark;
  final String remarkType;
  final String entryId;
  final String entryDate;
  final String staffId;
  final String staffName;
  final String academicYearId;

  StaffRemark({
    required this.remarkId,
    required this.remark,
    required this.remarkType,
    required this.entryId,
    required this.entryDate,
    required this.staffId,
    required this.staffName,
    required this.academicYearId,
  });

  factory StaffRemark.fromJson(Map<String, dynamic> json) {
    return StaffRemark(
      remarkId: json['REMARK_ID']?.toString() ?? '',
      remark: json['REMARK']?.toString() ?? '',
      remarkType: json['REMARK_TYPE']?.toString() ?? '',
      entryId: json['ENTRY_ID']?.toString() ?? '',
      entryDate: json['ENTRY_DATE']?.toString() ?? '',
      staffId: json['STAFF_ID']?.toString() ?? '',
      staffName: json['STAFF_NAME']?.toString() ?? '',
      academicYearId: json['ACADEMIC_YEAR_ID']?.toString() ?? '',
    );
  }
}
