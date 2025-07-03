class Ride {
  String? rideId;
  final String origin;
  final String destination;
  final int emptySeats;
  final DateTime startTime;
  final DateTime endTime;

  Ride({
    this.rideId,
    required this.origin,
    required this.destination,
    required this.emptySeats,
    required this.startTime,
    required this.endTime,
  });
}
