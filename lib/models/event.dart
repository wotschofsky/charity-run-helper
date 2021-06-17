import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  const Event({
    required this.id,
    required this.createdBy,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.hasConcluded,
  });

  Event.fromJson(Map<String, Object?> json)
      : this(
          id: json['id']! as String,
          createdBy: json['createdBy']! as String,
          title: json['title']! as String,
          description: json['description']! as String,
          startTime: (json['startTime']! as Timestamp).toDate(),
          endTime: (json['endTime']! as Timestamp).toDate(),
          hasConcluded: json['hasConcluded']! as bool,
        );

  final String id;
  final String createdBy;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final bool hasConcluded;

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'createdBy': createdBy,
      'title': title,
      'description': description,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'hasConcluded': hasConcluded,
    };
  }
}
