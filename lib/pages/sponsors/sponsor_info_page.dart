import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/event.dart';
import '../../models/participation.dart';
import '../../models/sponsor.dart';
import '../../sponsors/payment_button.dart';
import '../../ui/error_message.dart';
import '../../utils/build_snapshot.dart';
import '../../utils/custom_math.dart';

class SponsorInfoPage extends StatelessWidget {
  const SponsorInfoPage(this.id);

  final String id;

  @override
  Widget build(BuildContext context) {
    final sponsorStream = FirebaseFirestore.instance
        .collection('sponsors')
        .doc(id)
        .withConverter<Sponsor>(
          fromFirestore: (snapshot, _) =>
              Sponsor.fromJson({'id': snapshot.id, ...snapshot.data()!}),
          toFirestore: (event, _) => event.toJson(),
        )
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sponsor Information'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: StreamBuilder(
              stream: sponsorStream,
              builder: buildSnapshot<DocumentSnapshot<Sponsor>>(
                  childLoading: const Center(
                    child: CircularProgressIndicator(),
                  ),
                  childError: const Center(
                    child: ErrorMessage(),
                  ),
                  builder: (context, snapshot) {
                    if (!snapshot.data!.exists) {
                      return const Center(
                        child: ErrorMessage(message: 'Sponsor not found'),
                      );
                    }

                    final sponsorData = snapshot.data!.data()!;

                    final participationStream = FirebaseFirestore.instance
                        .collection('participations')
                        .doc(sponsorData.participationId)
                        .withConverter<Participation>(
                          fromFirestore: (snapshot, _) =>
                              Participation.fromJson(
                                  {'id': snapshot.id, ...snapshot.data()!}),
                          toFirestore: (event, _) => event.toJson(),
                        )
                        .snapshots();

                    return StreamBuilder(
                        stream: participationStream,
                        builder: buildSnapshot<DocumentSnapshot<Participation>>(
                            childLoading: const Center(
                              child: CircularProgressIndicator(),
                            ),
                            childError: const Center(
                              child: ErrorMessage(),
                            ),
                            builder: (context, snapshot) {
                              if (!snapshot.data!.exists) {
                                return const Center(
                                  child: ErrorMessage(),
                                );
                              }

                              final participationData = snapshot.data!.data()!;

                              final eventStream = FirebaseFirestore.instance
                                  .collection('events')
                                  .doc(participationData.eventId)
                                  .withConverter<Event>(
                                    fromFirestore: (snapshot, _) =>
                                        Event.fromJson({
                                      'id': snapshot.id,
                                      ...snapshot.data()!
                                    }),
                                    toFirestore: (event, _) => event.toJson(),
                                  )
                                  .snapshots();

                              return StreamBuilder(
                                  stream: eventStream,
                                  builder:
                                      buildSnapshot<DocumentSnapshot<Event>>(
                                          childLoading: const Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                          childError: const Center(
                                            child: ErrorMessage(),
                                          ),
                                          builder: (context, snapshot) {
                                            if (!snapshot.data!.exists) {
                                              return const Center(
                                                child: ErrorMessage(),
                                              );
                                            }

                                            final eventData =
                                                snapshot.data!.data()!;

                                            final formattedTotal =
                                                (sponsorData.amount *
                                                        roundFloor(
                                                            participationData
                                                                .totalDistance,
                                                            1))
                                                    .toStringAsFixed(2);

                                            return Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            bottom: 12),
                                                    child: Text(
                                                      'Welcome ${sponsorData.firstName}!',
                                                      style: const TextStyle(
                                                          fontSize: 32),
                                                    ),
                                                  ),
                                                  Text(
                                                      'Thank you for supporting us and ${participationData.runnerName} during our ${eventData.title} event. We truly appreciate it!'),
                                                  Text(
                                                      'We are thrilled to announce that during the event ${participationData.runnerName} managed to accumulate a stunning ${roundFloor(participationData.totalDistance, 1)} km.'),
                                                  Text(
                                                      'Therefore we would like to kindly ask you to donate a total of $formattedTotal€ through the payment button below.'),
                                                  Center(
                                                    child: !sponsorData
                                                            .paymentComplete
                                                        ? Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(32),
                                                                child:
                                                                    PaymentButton(
                                                                  sponsorId: id,
                                                                  amount:
                                                                      formattedTotal,
                                                                ),
                                                              ),
                                                              const Text(
                                                                  'After your payment is complete you will receive a receipt in your email inbox.')
                                                            ],
                                                          )
                                                        : const Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(32),
                                                            child: const Text(
                                                              'Payment complete - Thank you!',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                  fontSize: 24),
                                                            ),
                                                          ),
                                                  ),
                                                ]);
                                          }));
                            }));
                  })),
        ),
      ),
    );
  }
}
