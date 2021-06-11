class Participation {
  const Participation(
      {required this.id,
      required this.eventId,
      required this.runnerId,
      required this.totalDistance});

  Participation.fromJson(Map<String, Object?> json)
      : this(
            id: json['id']! as String,
            eventId: json['eventId']! as String,
            runnerId: json['runnerId']! as String,
            totalDistance: ((json['totalDistance'] is int)
                ? (json['totalDistance'] as int).toDouble()
                : json['totalDistance'] as double));

  final String id;
  final String eventId;
  final String runnerId;
  final double totalDistance;

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'eventId': eventId,
      'runnerId': runnerId,
      'totalDistance': totalDistance,
    };
  }
}
