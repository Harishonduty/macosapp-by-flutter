class TransportDetails {
  final String routeName;
  final String vehicleNo;
  final String boardingPlace;
  final String vehicleName;
  final String isOneWayTwoWay;
  final String distance;

  TransportDetails({
    required this.routeName,
    required this.vehicleNo,
    required this.boardingPlace,
    required this.vehicleName,
    required this.isOneWayTwoWay,
    required this.distance,
  });

  factory TransportDetails.fromJson(Map<String, dynamic> json) {
    return TransportDetails(
      routeName: json['ROUTE_NAME']?.toString() ?? '',
      vehicleNo: json['VEHICLE_NO']?.toString() ?? '',
      boardingPlace: json['BOARDING_PLACE']?.toString() ?? '',
      vehicleName: json['VEHICLE_NAME']?.toString() ?? '',
      isOneWayTwoWay: json['IS_ONEWAY_TWOWAY']?.toString() ?? '',
      distance: json['DISTANCE']?.toString() ?? '',
    );
  }
}
