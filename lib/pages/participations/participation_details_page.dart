import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../models/event.dart';
import '../../models/participation.dart';
import '../../models/sponsor.dart';
import '../../sponsors/edit_sponsor.dart';
import '../../sponsors/sponsor_tile.dart';
import '../../ui/error_message.dart';
import '../../ui/icon_info_item.dart';
import '../../utils/build_snapshot.dart';

class ParticipationDetails extends StatelessWidget {
  ParticipationDetails(this.id);

  final String id;

  void showSponsorDialog(BuildContext ctx, String eventId) {
    showModalBottomSheet(
        context: ctx,
        builder: (ctx) => EditSponsor(
              eventId: eventId,
              participationId: id,
            ));
  }

  void delete(BuildContext context) {
    FirebaseFirestore.instance.collection(('participations')).doc(id).delete();
  }

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
          actions: [
            IconButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                            title: const Text('Are you sure?'),
                            content: const Text(
                                'Your participation for this event will be undone and all your progress and sponsors will be lost!'),
                            actions: [
                              TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(),
                                  child: const Text('Abort')),
                              TextButton(
                                  onPressed: () {
                                    delete(context);
                                    Navigator.of(context).pop();
                                    VxNavigator.of(context).clearAndPush(
                                        Uri(path: '/participations'));
                                  },
                                  child: const Text('Confirm')),
                            ],
                          ));
                },
                icon: Icon(Icons.delete_forever))
          ],
        ),
        body: StreamBuilder(
          stream: participationSteam,
          builder: buildSnapshot<DocumentSnapshot<Participation>>(
              childLoading: const Center(
                child: CircularProgressIndicator(),
              ),
              childError: const Center(
                child: ErrorMessage(),
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
                          child: ErrorMessage(),
                        ),
                        builder: (context, snapshot) {
                          final eventData = snapshot.data!.data()!;

                          final sponsorsStream = FirebaseFirestore.instance
                              .collection('sponsors')
                              .where('runnerId',
                                  isEqualTo:
                                      FirebaseAuth.instance.currentUser!.uid)
                              .where('participationId',
                                  isEqualTo: participationData.id)
                              .withConverter<Sponsor>(
                                fromFirestore: (snapshot, _) =>
                                    Sponsor.fromJson({
                                  'id': snapshot.id,
                                  ...snapshot.data()!
                                }),
                                toFirestore: (event, _) => event.toJson(),
                              )
                              .snapshots();

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
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Sponsors',
                                            style:
                                                const TextStyle(fontSize: 24)),
                                        TextButton(
                                            onPressed: () => showSponsorDialog(
                                                context,
                                                participationData.eventId),
                                            child: Text('Add Sponsor'))
                                      ],
                                    ),
                                  ),
                                  StreamBuilder(
                                      stream: sponsorsStream,
                                      builder: buildSnapshot<
                                              QuerySnapshot<Sponsor>>(
                                          childLoading: Center(
                                              child:
                                                  CircularProgressIndicator()),
                                          childError:
                                              Center(child: ErrorMessage()),
                                          builder: (ctx, snapshot) {
                                            final docs = snapshot.data!.docs
                                                .map((doc) => doc.data())
                                                .toList();

                                            if (docs.length == 0) {
                                              return Center(
                                                  child: Text(
                                                      'No sponsor found! Get started by adding one.',
                                                      style: TextStyle(
                                                          color: Colors.grey)));
                                            }

                                            return Column(
                                              children: docs
                                                  .map((s) => SponsorTile(
                                                      name:
                                                          '${s.firstName} ${s.lastName}',
                                                      amount: s.amount))
                                                  .toList(),
                                            );
                                          }))
                                ],
                              ),
                            ),
                          );
                        }));
              }),
        ));
  }
}
