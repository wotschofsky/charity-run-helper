import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:location/location.dart';

import '../models/participation.dart';
import '../navigation/app_drawer.dart';
import '../participations/participation_selector.dart';
import '../ui/error_message.dart';
import '../utils/build_snapshot.dart';

class TrackerPage extends StatefulWidget {
  @override
  _TrackerPageState createState() => _TrackerPageState();
}

class _TrackerPageState extends State<TrackerPage> {
  StreamSubscription<LocationData>? subscription;
  String? selectedParticipation;
  bool isRunning = false;

  void startTracking() async {
    setState(() {
      isRunning = true;
    });

    Location location = new Location();

    var serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    var permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    subscription =
        location.onLocationChanged.listen((LocationData updatedLocation) {
      setState(() {
        FirebaseFirestore.instance.collection('geopoints').add({
          'latitude': updatedLocation.latitude,
          'longitude': updatedLocation.longitude,
          'recordedAt': updatedLocation.time,
          'participationId': selectedParticipation,
          'runnerId': FirebaseAuth.instance.currentUser!.uid
        });
      });
    });

    if (subscription != null) {
      subscription!.onDone(() {
        setState(() {
          isRunning = false;
        });
      });
    }
  }

  void stopTracking() {
    if (subscription != null) {
      subscription!.cancel();
    }

    setState(() {
      isRunning = false;
    });
  }

  void dispose() {
    stopTracking();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final participationStream = FirebaseFirestore.instance
        .collection('participations')
        .doc(selectedParticipation)
        .withConverter<Participation>(
          fromFirestore: (snapshot, _) =>
              Participation.fromJson({'id': snapshot.id, ...snapshot.data()!}),
          toFirestore: (event, _) => event.toJson(),
        )
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: Text('Tracker'),
      ),
      drawer: AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (selectedParticipation != null)
              Expanded(
                child: StreamBuilder(
                  stream: participationStream,
                  builder: buildSnapshot<DocumentSnapshot<Participation>>(
                      childLoading:
                          const Center(child: CircularProgressIndicator()),
                      childError: const Center(child: ErrorMessage()),
                      builder: (ctx, snapshot) {
                        if (!snapshot.data!.exists) {
                          return const Center(
                            child: ErrorMessage(),
                          );
                        }

                        final data = snapshot.data!.data()!;

                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Text('Your total distance',
                                  style: const TextStyle(
                                      fontSize: 20, color: Colors.grey)),
                            ),
                            Text(
                              '${data.totalDistance.toStringAsFixed(3)} km',
                              style: const TextStyle(fontSize: 64),
                            ),
                          ],
                        );
                      }),
                ),
              ),
            ButtonBar(
              alignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                    onPressed: selectedParticipation != null && !isRunning
                        ? startTracking
                        : null,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start')),
                ElevatedButton.icon(
                    onPressed: selectedParticipation != null && isRunning
                        ? stopTracking
                        : null,
                    icon: const Icon(Icons.stop),
                    label: const Text('Stop')),
              ],
            ),
            ParticipationSelector(
              onChanged: (newId) {
                stopTracking();
                setState(() {
                  selectedParticipation = newId;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
