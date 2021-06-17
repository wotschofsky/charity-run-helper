import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:velocity_x/velocity_x.dart';

import '../models/participation.dart';
import '../utils/build_snapshot.dart';

class ParticipateButton extends StatefulWidget {
  ParticipateButton(this.eventId);

  final String eventId;

  @override
  _ParticipateButtonState createState() => _ParticipateButtonState();
}

class _ParticipateButtonState extends State<ParticipateButton> {
  String nameInputValue = '';

  void createParticipation(String runnerName) {
    if (FirebaseAuth.instance.currentUser == null) {
      return;
    }

    FirebaseFirestore.instance.collection('participations').add({
      'runnerName': runnerName,
      'eventId': widget.eventId,
      'runnerId': FirebaseAuth.instance.currentUser!.uid,
      'sponsorsSum': 0.0,
      'totalDistance': 0.0
    });
  }

  @override
  Widget build(BuildContext context) {
    final dataStream = FirebaseFirestore.instance
        .collection('participations')
        .where('runnerId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .where('eventId', isEqualTo: widget.eventId)
        .limit(1)
        .withConverter<Participation>(
          fromFirestore: (snapshot, _) =>
              Participation.fromJson({'id': snapshot.id, ...snapshot.data()!}),
          toFirestore: (event, _) => event.toJson(),
        )
        .snapshots();

    return StreamBuilder(
        stream: dataStream,
        builder: buildSnapshot<QuerySnapshot<Participation>>(
            childLoading: const ElevatedButton(
                onPressed: null, child: Text('Loading...')),
            childError: const ElevatedButton(
                onPressed: null, child: Text('Participate')),
            builder: (context, snapshot) {
              final docs = snapshot.data!.docs;

              if (docs.length > 0) {
                return TextButton(
                    onPressed: () => VxNavigator.of(context).push(Uri(
                        path: '/participations/view',
                        queryParameters: {'id': docs[0].id})),
                    child: const Text('View Participation'));
              }

              return ElevatedButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                              title: Text('Please enter your name'),
                              content: TextField(
                                onChanged: (value) {
                                  nameInputValue = value;
                                },
                                decoration: const InputDecoration(
                                  border: const OutlineInputBorder(),
                                  labelText: 'Your Name',
                                ),
                              ),
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      createParticipation(nameInputValue);
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('Participate'))
                              ],
                            ));
                  },
                  child: const Text('Participate'));
            }));
  }
}
