class TripData {
  final String tripId;
  final String tripName;

  TripData({
    required this.tripId,
    required this.tripName,
  });

  factory TripData.fromJson(Map<String, dynamic> json) {
    return TripData(
      tripId: json['TRIP_ID']?.toString() ?? '',
      tripName: json['TRIP_NAME']?.toString() ?? '',
    );
  }
}
