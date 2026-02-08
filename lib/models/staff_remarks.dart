class StaffRemark {
  final String remark;
  final String staffName;
  final String entryDate;
  final String remarkType;

  StaffRemark({
    required this.remark,
    required this.staffName,
    required this.entryDate,
    required this.remarkType,
  });

  factory StaffRemark.fromJson(Map<String, dynamic> json) {
    return StaffRemark(
      remark: json['REMARK']?.toString() ?? '',
      staffName: json['STAFF_NAME']?.toString() ?? '',
      entryDate: json['ENTRY_DATE']?.toString() ?? '',
      remarkType: json['REMARK_TYPE_NAME']?.toString() ?? json['REMARK_TYPE']?.toString() ?? '',
    );
  }
}

class RemarksType {
  final String id;
  final String name;

  RemarksType({required this.id, required this.name});

  factory RemarksType.fromJson(Map<String, dynamic> json) {
    return RemarksType(
      id: json['REMARKS_TYPE_ID']?.toString() ?? '',
      name: json['REMARKS_TYPE_NAME']?.toString() ?? '',
    );
  }
}
