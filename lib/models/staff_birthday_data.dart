class StaffBirthdayData {
  final String? name;
  final String? dob;
  final String? staffCode;

  StaffBirthdayData({
    this.name,
    this.dob,
    this.staffCode,
  });

  factory StaffBirthdayData.fromJson(Map<String, dynamic> json) {
    return StaffBirthdayData(
      name: json['name']?.toString(),
      dob: json['dob']?.toString(),
      staffCode: json['staffCode']?.toString(),
    );
  }
}
