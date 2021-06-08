class Registration {
  const Registration({
    required this.id,
    required this.eventId,
    required this.runnerId,
  });

  Registration.fromJson(Map<String, Object?> json)
      : this(
          id: json['id']! as String,
          eventId: json['eventId']! as String,
          runnerId: json['runnerId']! as String,
        );

  final String id;
  final String eventId;
  final String runnerId;

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'eventId': eventId,
      'runnerId': runnerId,
    };
  }
}
