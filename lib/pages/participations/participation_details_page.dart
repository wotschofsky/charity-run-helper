import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../models/event.dart';
import '../../models/participation.dart';
import '../../ui/error_message.dart';
import '../../ui/icon_info_item.dart';
import '../../utils/build_snapshot.dart';

class ParticipationDetails extends StatelessWidget {
  ParticipationDetails(this.id);

  final String id;

  @override
  Widget build(BuildContext context) {
    final participationSteam = FirebaseFirestore.instance
        .collection('participations')
        .doc(id)
        .withConverter<Participation>(
          fromFirestore: (snapshot, _) =>
              Participation.fromJson({'id': snapshot.id, ...snapshot.data()!}),
          toFirestore: (event, _) => event.toJson(),
        )
        .snapshots();

    return Scaffold(
        appBar: AppBar(
          title: const Text('Participation'),
        ),
        body: StreamBuilder(
          stream: participationSteam,
          builder: buildSnapshot<DocumentSnapshot<Participation>>(
              childLoading: const Center(
                child: CircularProgressIndicator(),
              ),
              childError: const Center(
                child: ErrorMessage(message: 'Failed loading participation!'),
              ),
              builder: (context, snapshot) {
                final participationData = snapshot.data!.data()!;

                final eventStream = FirebaseFirestore.instance
                    .collection('events')
                    .doc(participationData.eventId)
                    .withConverter<Event>(
                      fromFirestore: (snapshot, _) => Event.fromJson(
                          {'id': snapshot.id, ...snapshot.data()!}),
                      toFirestore: (event, _) => event.toJson(),
                    )
                    .snapshots();

                return StreamBuilder(
                    stream: eventStream,
                    builder: buildSnapshot<DocumentSnapshot<Event>>(
                        childLoading: const Center(
                          child: CircularProgressIndicator(),
                        ),
                        childError: const Center(
                          child: ErrorMessage(
                              message: 'Failed loading related event!'),
                        ),
                        builder: (context, snapshot) {
                          final eventData = snapshot.data!.data()!;

                          return SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 24),
                                    child: Row(
                                      children: [
                                        Text(eventData.title,
                                            style:
                                                const TextStyle(fontSize: 32)),
                                        IconButton(
                                            onPressed: () =>
                                                VxNavigator.of(context).push(
                                                    Uri(
                                                        path: '/events/details',
                                                        queryParameters: {
                                                      'id': participationData
                                                          .eventId
                                                    })),
                                            icon: const Icon(Icons.info,
                                                color: Colors.grey))
                                      ],
                                    ),
                                  ),
                                  const Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Placeholder(
                                      fallbackHeight: 300,
                                    ),
                                  ),
                                  const Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Text('Your Progress',
                                        style: const TextStyle(fontSize: 24)),
                                  ),
                                  const IconInfoItem(
                                      icon: Icons.map, label: 'n km'),
                                  const IconInfoItem(
                                      icon: Icons.monetization_on,
                                      label: 'n €'),
                                  const Divider(),
                                  const Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Text('Sponsors',
                                        style: const TextStyle(fontSize: 24)),
                                  ),
                                  ...List.filled(3, null)
                                      .map((e) => const Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 8),
                                            child: Placeholder(
                                              fallbackHeight: 100,
                                            ),
                                          ))
                                      .toList()
                                ],
                              ),
                            ),
                          );
                        }));
              }),
        ));
  }
}
