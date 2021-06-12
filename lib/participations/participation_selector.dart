import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/event.dart';
import '../models/participation.dart';

class ParticipationSelector extends StatefulWidget {
  ParticipationSelector({required this.onChanged});

  final void Function(String?) onChanged;

  @override
  _ParticipationSelectorState createState() => _ParticipationSelectorState();
}

class _ParticipationSelectorState extends State<ParticipationSelector> {
  final List<DropdownMenuItem<String>> dropdownItems = [];
  bool loaded = false;

  @override
  void initState() {
    super.initState();

    final participationsStream = FirebaseFirestore.instance
        .collection('participations')
        .where('runnerId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .withConverter<Participation>(
          fromFirestore: (snapshot, _) =>
              Participation.fromJson({'id': snapshot.id, ...snapshot.data()!}),
          toFirestore: (event, _) => event.toJson(),
        )
        .snapshots();

    participationsStream.listen((snapshot) async {
      final participations = snapshot.docs.map((doc) => doc.data()).toList();

      final eventFutures = participations.map((p) {
        return FirebaseFirestore.instance
            .collection('events')
            .doc(p.eventId)
            .withConverter<Event>(
              fromFirestore: (snapshot, _) =>
                  Event.fromJson({'id': snapshot.id, ...snapshot.data()!}),
              toFirestore: (event, _) => event.toJson(),
            )
            .get();
      });

      final events = await Future.wait(eventFutures);

      final List<DropdownMenuItem<String>> inputValues = [];

      for (int i = 0; i < events.length; i++) {
        final eventData = events[i].data()!;
        final item = DropdownMenuItem(
            value: participations[i].id, child: Text(eventData.title));
        inputValues.add(item);
      }

      setState(() {
        this.dropdownItems.clear();
        this.dropdownItems.addAll(inputValues);
        loaded = true;
      });
    });
  }

  String get labelText {
    if (loaded) {
      return 'Select Event';
    }
    return 'Loading Events...';
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField(
        onChanged: dropdownItems.length == 0 ? null : widget.onChanged,
        decoration: InputDecoration(
            border: const OutlineInputBorder(), labelText: labelText),
        items: dropdownItems);
  }
}
