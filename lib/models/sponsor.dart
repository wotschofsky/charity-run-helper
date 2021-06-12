class Sponsor {
  const Sponsor(
      {required this.id,
      required this.eventId,
      required this.runnerId,
      required this.participationId,
      required this.amount,
      required this.email,
      required this.firstName,
      required this.lastName,
      required this.address,
      required this.zip,
      required this.city,
      required this.paymentComplete});

  Sponsor.fromJson(Map<String, Object?> json)
      : this(
            id: json['id']! as String,
            eventId: json['eventId']! as String,
            runnerId: json['runnerId']! as String,
            participationId: json['participationId']! as String,
            amount: ((json['amount'] is int)
                ? (json['amount'] as int).toDouble()
                : json['amount'] as double),
            email: json['email']! as String,
            firstName: json['firstName']! as String,
            lastName: json['lastName']! as String,
            address: json['address']! as String,
            zip: json['zip']! as String,
            city: json['city']! as String,
            paymentComplete: json['paymentComplete']! as bool);

  final String id;
  final String eventId;
  final String runnerId;
  final String participationId;
  final double amount;
  final String email;
  final String firstName;
  final String lastName;
  final String address;
  final String zip;
  final String city;
  final bool paymentComplete;

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'eventId': eventId,
      'runnerId': runnerId,
      'participationId': participationId,
      'amount': amount,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'address': address,
      'zip': zip,
      'city': city,
      'paymentComplete': paymentComplete,
    };
  }
}
