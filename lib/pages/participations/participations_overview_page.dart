import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/participation.dart';
import '../../navigation/app_drawer.dart';
import '../../participations/participation_tile.dart';
import '../../ui/error_message.dart';

class ParticipationsOverviewPage extends StatelessWidget {
  final participationsStream = FirebaseFirestore.instance
      .collection('participations')
      .where('runnerId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
      .withConverter<Participation>(
        fromFirestore: (snapshot, _) =>
            Participation.fromJson({'id': snapshot.id, ...snapshot.data()!}),
        toFirestore: (event, _) => event.toJson(),
      )
      .snapshots();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Participations'),
      ),
      drawer: AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: StreamBuilder<QuerySnapshot<Participation>>(
          stream: participationsStream,
          builder: (BuildContext context,
              AsyncSnapshot<QuerySnapshot<Participation>> snapshot) {
            if (snapshot.hasError) {
              return const Center(
                child: ErrorMessage(),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            final docs = snapshot.data!.docs.map((doc) => doc.data()).toList();

            if (docs.length == 0) {
              return const Center(
                  child: ErrorMessage(message: 'No participations found!'));
            }

            return ListView.builder(
                itemCount: docs.length,
                itemBuilder: (ctx, index) {
                  final doc = docs[index];
                  return ParticipationTile(id: doc.id, eventId: doc.eventId);
                });
          },
        ),
      ),
    );
  }
}
