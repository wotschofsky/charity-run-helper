import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:skeleton_text/skeleton_text.dart';
import 'package:velocity_x/velocity_x.dart';

import '../models/event.dart';
import '../ui/error_message.dart';

class ParticipationTile extends StatelessWidget {
  ParticipationTile({required this.id, required this.eventId});

  final String id;
  final String eventId;

  String formatDate(DateTime date) => DateFormat.yMEd().add_jm().format(date);

  @override
  Widget build(BuildContext context) {
    final dataStream = FirebaseFirestore.instance
        .collection('events')
        .doc(eventId)
        .withConverter<Event>(
          fromFirestore: (snapshot, _) =>
              Event.fromJson({'id': snapshot.id, ...snapshot.data()!}),
          toFirestore: (event, _) => event.toJson(),
        )
        .snapshots();

    return Card(
      child: StreamBuilder<DocumentSnapshot<Event>>(
        stream: dataStream,
        builder: (BuildContext context,
            AsyncSnapshot<DocumentSnapshot<Event>> snapshot) {
          if (snapshot.hasError) {
            return const Padding(
              padding: EdgeInsets.all(8),
              child: Center(
                child: ErrorMessage(message: 'Failed loading participation!'),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Padding(
              padding: const EdgeInsets.all(8),
              child: ListTile(
                title: SkeletonAnimation(
                  borderRadius: BorderRadius.circular(4),
                  shimmerColor: Colors.black12,
                  child: Container(
                    height: 20,
                  ),
                ),
                subtitle: SkeletonAnimation(
                  borderRadius: BorderRadius.circular(4),
                  shimmerColor: Colors.black12,
                  child: Container(
                    height: 16,
                  ),
                ),
              ),
            );
          }

          if (snapshot.data == null || !snapshot.data!.exists) {
            return const Padding(
              padding: EdgeInsets.all(8),
              child: Center(
                child: ErrorMessage(message: 'Event not found!'),
              ),
            );
          }

          final data = snapshot.data!.data()!;

          return InkWell(
            onTap: () => VxNavigator.of(context).push(
                Uri(path: '/participations/view', queryParameters: {'id': id})),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: ListTile(
                title: Text(data.title, style: TextStyle(fontSize: 20)),
                subtitle: Text(formatDate(data.startTime)),
              ),
            ),
          );
        },
      ),
    );
  }
}
