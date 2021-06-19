import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../utils/build_snapshot.dart';

class EventLink extends StatelessWidget {
  EventLink(this.eventId);

  final String eventId;

  final generateEventUrl = FirebaseFunctions.instanceFor(region: 'europe-west3')
      .httpsCallable('generateEventUrl');

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.black12,
          borderRadius: BorderRadius.all(Radius.circular(4))),
      child: FutureBuilder(
        future: generateEventUrl({'eventId': eventId}),
        builder: buildSnapshot<HttpsCallableResult>(
            childLoading: Row(
              children: [
                const IconButton(onPressed: null, icon: Icon(Icons.copy)),
                const Text('Loading event link...')
              ],
            ),
            childError: Row(
              children: [
                const IconButton(onPressed: null, icon: Icon(Icons.copy)),
                const Text('Error loading event link')
              ],
            ),
            builder: (ctx, snapshot) {
              snapshot.data!.data;
              return Row(
                children: [
                  IconButton(
                      onPressed: () => Clipboard.setData(
                          ClipboardData(text: snapshot.data!.data)),
                      icon: const Icon(Icons.copy)),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Text(snapshot.data!.data)),
                    ),
                  ),
                ],
              );
            }),
      ),
    );
  }
}
