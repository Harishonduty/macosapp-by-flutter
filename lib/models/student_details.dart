class StudentDetails {
  final String studentId;
  final String registerNumber;
  final String admissionNo;
  final String className;
  final String sectionId;
  final String firstName;
  final String lastName;
  final String photoPath;

  final String rollNumber;
  final String dob;
  final String bloodGroupId;
  final String motherName;
  final String genderName;
  final String fatherName;
  final String motherMobile;
  final String fatherMobile;
  final String permanentAddress;
  final String emisNo;
  final String penNo;

  StudentDetails({
    required this.studentId,
    required this.registerNumber,
    required this.admissionNo,
    required this.className,
    required this.sectionId,
    required this.firstName,
    required this.lastName,
    required this.photoPath,
    required this.rollNumber,
    required this.dob,
    required this.bloodGroupId,
    required this.motherName,
    required this.genderName,
    required this.fatherName,
    required this.motherMobile,
    required this.fatherMobile,
    required this.permanentAddress,
    required this.emisNo,
    required this.penNo,
  });

  factory StudentDetails.fromJson(Map<String, dynamic> json) {
    return StudentDetails(
      studentId: json['STUDENT_ID']?.toString() ?? '',
      registerNumber: json['REGISTER_NUMBER']?.toString() ?? '',
      admissionNo: json['ADMISSION_NO']?.toString() ?? '',
      className: json['CLASS_NAME']?.toString() ?? '',
      sectionId: json['SECTION_ID']?.toString() ?? '',
      firstName: json['FIRST_NAME']?.toString() ?? '',
      lastName: json['LAST_NAME']?.toString() ?? '',
      photoPath: json['PHOTO_PATH']?.toString() ?? '',
      rollNumber: json['ROLL_NUMBER']?.toString() ?? '',
      dob: json['DOB']?.toString() ?? '',
      bloodGroupId: json['BLOOD_GROUP_ID']?.toString() ?? '',
      motherName: json['MOTHER_NAME']?.toString() ?? '',
      genderName: json['GENDER_NAME']?.toString() ?? '',
      fatherName: json['FATHER_NAME']?.toString() ?? '',
      motherMobile: json['MOTHER_MOBILE']?.toString() ?? '',
      fatherMobile: json['FATHER_MOBILE']?.toString() ?? '',
      permanentAddress: json['PERMANENT_ADDRESS']?.toString() ?? '',
      emisNo: json['EMIS_NO']?.toString() ?? '',
      penNo: json['PEN_NO']?.toString() ?? '',
    );
  }
}
