class AdminStudentData {
  final String? studentId;
  final String? classId;
  final String? className;
  final String? firstName;
  final String? lastName;

  AdminStudentData({
    this.studentId,
    this.classId,
    this.className,
    this.firstName,
    this.lastName,
  });

  factory AdminStudentData.fromJson(Map<String, dynamic> json) {
    return AdminStudentData(
      studentId: json['STUDENT_ID']?.toString(),
      classId: json['CLASS_ID']?.toString(),
      className: json['CLASS_NAME']?.toString(),
      firstName: json['FIRST_NAME']?.toString(),
      lastName: json['LAST_NAME']?.toString(),
    );
  }
}

class AdminStudentDataById {
  final String? photoPath;
  final String? firstName;
  final String? admissionNo;
  final String? classId;
  final String? className;
  final String? rollNumber;
  final String? dob;
  final String? bloodGroupId;
  final String? genderName;
  final String? motherName;
  final String? fatherName;
  final String? motherMobile;
  final String? fatherMobile;
  final String? permanentAddress;

  AdminStudentDataById({
    this.photoPath,
    this.firstName,
    this.admissionNo,
    this.classId,
    this.className,
    this.rollNumber,
    this.dob,
    this.bloodGroupId,
    this.genderName,
    this.motherName,
    this.fatherName,
    this.motherMobile,
    this.fatherMobile,
    this.permanentAddress,
  });

  factory AdminStudentDataById.fromJson(Map<String, dynamic> json) {
    return AdminStudentDataById(
      photoPath: json['PHOTO_PATH']?.toString(),
      firstName: json['FIRST_NAME']?.toString(),
      admissionNo: json['ADMISSION_NO']?.toString(),
      classId: json['CLASS_ID']?.toString(),
      className: json['CLASS_NAME']?.toString(),
      rollNumber: json['ROLL_NUMBER']?.toString(),
      dob: json['DOB']?.toString(),
      bloodGroupId: json['BLOOD_GROUP_ID']?.toString(),
      genderName: json['GENDER_NAME']?.toString(),
      motherName: json['MOTHER_NAME']?.toString(),
      fatherName: json['FATHER_NAME']?.toString(),
      motherMobile: json['MOTHER_MOBILE']?.toString(),
      fatherMobile: json['FATHER_MOBILE']?.toString(),
      permanentAddress: json['PERMANENT_ADDRESS']?.toString(),
    );
  }
}
