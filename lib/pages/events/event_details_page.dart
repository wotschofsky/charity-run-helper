import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../models/event.dart';
import '../../participations/participate_button.dart';
import '../../ui/error_message.dart';
import '../../ui/icon_info_item.dart';
import '../../utils/build_snapshot.dart';

class EventDetailsPage extends StatelessWidget {
  EventDetailsPage(this.id);

  final String id;

  String formatDate(DateTime date) => DateFormat.yMEd().add_jm().format(date);

  String formatDuration(DateTime startTime, DateTime endTime) {
    final difference = startTime.difference(endTime).abs();
    final hours = difference.inMinutes / 60;
    return '${hours.toStringAsFixed(1)} hours';
  }

  @override
  Widget build(BuildContext context) {
    final dataStream = FirebaseFirestore.instance
        .collection('events')
        .doc(id)
        .withConverter<Event>(
          fromFirestore: (snapshot, _) =>
              Event.fromJson({'id': snapshot.id, ...snapshot.data()!}),
          toFirestore: (event, _) => event.toJson(),
        )
        .snapshots();

    return StreamBuilder<DocumentSnapshot<Event>>(
      stream: dataStream,
      builder: buildSnapshot(
          childLoading: Scaffold(
            appBar: AppBar(),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
          childError: Scaffold(
            appBar: AppBar(),
            body: const Center(
              child: ErrorMessage(),
            ),
          ),
          builder: (BuildContext context,
              AsyncSnapshot<DocumentSnapshot<Event>> snapshot) {
            if (!snapshot.data!.exists) {
              return Scaffold(
                  appBar: AppBar(),
                  body: Center(
                    child: const ErrorMessage(message: 'Event not found'),
                  ));
            }

            final data = snapshot.data!.data()!;

            return Scaffold(
                appBar: AppBar(
                  title: Text(data.title),
                ),
                floatingActionButton: FirebaseAuth.instance.currentUser !=
                            null &&
                        FirebaseAuth.instance.currentUser!.uid == data.createdBy
                    ? FloatingActionButton.extended(
                        onPressed: () => VxNavigator.of(context).push(Uri(
                            path: '/events/edit',
                            queryParameters: {'id': data.id})),
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit'))
                    : null,
                body: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(data.title,
                            style: const TextStyle(fontSize: 32)),
                      ),
                      IconInfoItem(
                          icon: Icons.calendar_today,
                          label:
                              '${formatDate(data.startTime)} - ${formatDate(data.endTime)}'),
                      Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: IconInfoItem(
                            icon: Icons.timer,
                            label: formatDuration(data.startTime, data.endTime),
                          )),
                      if (FirebaseAuth.instance.currentUser != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8, bottom: 8),
                          child: ParticipateButton(id),
                        ),
                      Divider(),
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: MarkdownBody(
                            selectable: true, data: data.description),
                      ),
                    ],
                  ),
                ));
          }),
    );
  }
}
