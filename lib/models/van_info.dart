class VanInfo {
  final String? vehicleId;
  final String? vehicleName;
  final String? placeName;
  final String? boardingPlaceId;
  final String? distance;
  final String? firstName;
  final String? studentId;
  final String? tripId;

  VanInfo({
    this.vehicleId,
    this.vehicleName,
    this.placeName,
    this.boardingPlaceId,
    this.distance,
    this.firstName,
    this.studentId,
    this.tripId,
  });

  factory VanInfo.fromJson(Map<String, dynamic> json) {
    return VanInfo(
      vehicleId: json['VEHICLE_ID']?.toString(),
      vehicleName: json['VEHICLE_NAME']?.toString(),
      placeName: json['PLACE_NAME']?.toString(),
      boardingPlaceId: json['BOARDING_PLACE_ID']?.toString(),
      distance: json['DISTANCE']?.toString(),
      firstName: json['FIRST_NAME']?.toString(),
      studentId: json['STUDENT_ID']?.toString(),
      tripId: json['TRIP_ID']?.toString(),
    );
  }
}
