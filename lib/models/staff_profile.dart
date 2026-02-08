class StaffProfile {
  final String staffId;
  final String imagePath;
  final String employeeCode;
  final String name;
  final String dob;
  final String doj;
  final String mobile;
  final String genderName;
  final String designation;
  final String deptCategoryName;
  final String qualificationName;
  final String email;
  final String stfCategory;
  final String staffName;
  final String className;
  final String academicYearId;

  StaffProfile({
    required this.staffId,
    required this.imagePath,
    required this.employeeCode,
    required this.name,
    required this.dob,
    required this.doj,
    required this.mobile,
    required this.genderName,
    required this.designation,
    required this.deptCategoryName,
    required this.qualificationName,
    required this.email,
    required this.stfCategory,
    required this.staffName,
    required this.className,
    required this.academicYearId,
  });

  factory StaffProfile.fromJson(Map<String, dynamic> json) {
    return StaffProfile(
      staffId: json['STAFF_ID']?.toString() ?? '',
      imagePath: json['IMAGE_PATH']?.toString() ?? '',
      employeeCode: json['EMPLOYEE_CODE']?.toString() ?? '',
      name: json['NAME']?.toString() ?? '',
      dob: json['DOB']?.toString() ?? '',
      doj: json['DOJ']?.toString() ?? '',
      mobile: json['MOBILE']?.toString() ?? '',
      genderName: json['GENDER_NAME']?.toString() ?? '',
      designation: json['DESIGNATION']?.toString() ?? '',
      deptCategoryName: json['DEPT_CATEGORY_NAME']?.toString() ?? '',
      qualificationName: json['QUALIFICATION_NAME']?.toString() ?? '',
      email: json['EMAIL']?.toString() ?? '',
      stfCategory: json['STF_CATEGORY']?.toString() ?? '',
      staffName: json['STAFF_NAME']?.toString() ?? '',
      className: json['CLASS_NAME']?.toString() ?? '',
      academicYearId: json['ACADEMIC_YEAR_ID']?.toString() ?? '',
    );
  }
}
