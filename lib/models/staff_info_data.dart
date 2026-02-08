class StaffInfoData {
  final String? staffId;
  final String? employeeCode;
  final String? name;
  final String? designation;
  final String? mobile;
  final String? imagePath;
  final String? category;
  final String? gender;

  StaffInfoData({
    this.staffId,
    this.employeeCode,
    this.name,
    this.designation,
    this.mobile,
    this.imagePath,
    this.category,
    this.gender,
  });

  factory StaffInfoData.fromJson(Map<String, dynamic> json) {
    return StaffInfoData(
      staffId: json['STAFF_ID']?.toString(),
      employeeCode: json['EMPLOYEE_CODE']?.toString(),
      name: json['NAME']?.toString(),
      designation: json['DESIGNATION']?.toString(),
      mobile: json['MOBILE']?.toString(),
      imagePath: json['IMAGE_PATH']?.toString(),
      category: json['STF_CATEGORY']?.toString(),
      gender: json['GENDER_NAME']?.toString() ?? json['GENDER']?.toString(),
    );
  }
}
