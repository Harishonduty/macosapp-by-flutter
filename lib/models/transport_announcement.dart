class TransportAnnouncement {
  final String? vehicleName;
  final String? tripName;
  final String? placeName;
  final String? isTwoWay;
  final String? announcement;
  final String? studentId;
  final String? dateFrom;
  final String? dateTo;
  final String? name;

  TransportAnnouncement({
    this.vehicleName,
    this.tripName,
    this.placeName,
    this.isTwoWay,
    this.announcement,
    this.studentId,
    this.dateFrom,
    this.dateTo,
    this.name,
  });

  factory TransportAnnouncement.fromJson(Map<String, dynamic> json) {
    return TransportAnnouncement(
      vehicleName: json['VEHICLE_NAME']?.toString(),
      tripName: json['TRIP_NAME']?.toString(),
      placeName: json['PLACE_NAME']?.toString(),
      isTwoWay: json['IS_TWO_WAY']?.toString(),
      announcement: json['ANNOUNCEMENT']?.toString(),
      studentId: json['STUDENT_ID']?.toString(),
      dateFrom: json['DATE_FROM']?.toString(),
      dateTo: json['DATE_TO']?.toString(),
      name: json['NAME']?.toString(),
    );
  }
}
