import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../events/event_tile.dart';
import '../../models/event.dart';
import '../../navigation/app_drawer.dart';
import '../../ui/error_message.dart';

class EventsOverviewPage extends StatelessWidget {
  final _eventsStream = FirebaseFirestore.instance
      .collection('events')
      .withConverter<Event>(
        fromFirestore: (snapshot, _) =>
            Event.fromJson({'id': snapshot.id, ...snapshot.data()!}),
        toFirestore: (event, _) => event.toJson(),
      )
      .snapshots();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('All Events'),
        ),
        drawer: AppDrawer(),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: StreamBuilder<QuerySnapshot<Event>>(
            stream: _eventsStream,
            builder: (BuildContext context,
                AsyncSnapshot<QuerySnapshot<Event>> snapshot) {
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

              final docs =
                  snapshot.data!.docs.map((doc) => doc.data()).toList();

              if (docs.length == 0) {
                return const Center(
                    child: ErrorMessage(message: 'No event available'));
              }

              return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (ctx, index) {
                    final doc = docs[index];
                    return EventTile(doc);
                  });
            },
          ),
        ));
  }
}
