import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/registration.dart';
import '../../navigation/app_drawer.dart';
import '../../registrations/registration_tile.dart';
import '../../ui/error_message.dart';

class RegistrationsOverviewPage extends StatelessWidget {
  final _registrationsStream = FirebaseFirestore.instance
      .collection('registrations')
      .where('runnerId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
      .withConverter<Registration>(
        fromFirestore: (snapshot, _) =>
            Registration.fromJson({'id': snapshot.id, ...snapshot.data()!}),
        toFirestore: (event, _) => event.toJson(),
      )
      .snapshots();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Registrations'),
      ),
      drawer: AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: StreamBuilder<QuerySnapshot<Registration>>(
          stream: _registrationsStream,
          builder: (BuildContext context,
              AsyncSnapshot<QuerySnapshot<Registration>> snapshot) {
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
                  child: ErrorMessage(message: 'No registrations found'));
            }

            return ListView.builder(
                itemCount: docs.length,
                itemBuilder: (ctx, index) {
                  final doc = docs[index];
                  return RegistrationTile(id: doc.id, eventId: doc.eventId);
                });
          },
        ),
      ),
    );
  }
}
