import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_field/date_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../models/event.dart';
import '../../ui/error_message.dart';
import '../../utils/build_snapshot.dart';

class EditEventPage extends StatefulWidget {
  const EditEventPage({this.id});

  final String? id;

  @override
  _EditEventPageState createState() => _EditEventPageState();
}

class _EditEventPageState extends State<EditEventPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  DateTime? startTime;
  DateTime? endTime;

  void submit(BuildContext ctx) async {
    if (widget.id == null) {
      if (!_formKey.currentState!.validate() ||
          startTime == null ||
          endTime == null) {
        return;
      }

      final doc = await FirebaseFirestore.instance.collection('events').add({
        'createdBy': FirebaseAuth.instance.currentUser!.uid,
        'title': titleController.value.text,
        'startTime': startTime,
        'endTime': endTime,
        'description': descriptionController.value.text,
        'hasConcluded': false,
      });

      VxNavigator.of(context)
          .push(Uri(path: '/events/details', queryParameters: {'id': doc.id}));
    } else {
      if (!_formKey.currentState!.validate()) {
        return;
      }

      await FirebaseFirestore.instance
          .collection(('events'))
          .doc(widget.id)
          .update({
        'title': titleController.value.text,
        'startTime': startTime,
        'endTime': endTime,
        'description': descriptionController.value.text,
      });

      VxNavigator.of(context).pop();
    }
  }

  void delete(BuildContext context) {
    FirebaseFirestore.instance.collection(('events')).doc(widget.id).delete();
  }

  @override
  Widget build(BuildContext context) {
    final eventFuture = FirebaseFirestore.instance
        .collection('events')
        .doc(widget.id)
        .withConverter<Event>(
          fromFirestore: (snapshot, _) =>
              Event.fromJson({'id': snapshot.id, ...snapshot.data()!}),
          toFirestore: (event, _) => event.toJson(),
        )
        .get();

    return Scaffold(
        appBar: AppBar(
          title: const Text('New Event'),
          actions: [
            if (widget.id != null)
              IconButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                              title: const Text('Are you sure?'),
                              content: const Text(
                                  'This event including all sign ups and sponsors will be lost forever!'),
                              actions: [
                                TextButton(
                                    onPressed: () => Navigator.of(ctx).pop(),
                                    child: const Text('Abort')),
                                TextButton(
                                    onPressed: () {
                                      delete(context);
                                      Navigator.of(context).pop();
                                      VxNavigator.of(context)
                                          .clearAndPush(Uri(path: '/events'));
                                    },
                                    child: const Text('Confirm')),
                              ],
                            ));
                  },
                  icon: Icon(Icons.delete_forever))
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: widget.id == null
                ? generateForm(context)
                : FutureBuilder<DocumentSnapshot<Event>>(
                    future: eventFuture,
                    builder: buildSnapshot<DocumentSnapshot<Event>>(
                        childLoading: const Center(
                          child: CircularProgressIndicator(),
                        ),
                        childError: const Center(
                          child: ErrorMessage(),
                        ),
                        builder: (BuildContext context,
                            AsyncSnapshot<DocumentSnapshot<Event>> snapshot) {
                          if (!snapshot.data!.exists) {
                            return const Center(
                              child: ErrorMessage(message: 'Event not found'),
                            );
                          }

                          final data = snapshot.data!.data()!;
                          return generateForm(context,
                              titleValue: data.title,
                              startTimeValue: data.startTime,
                              endTimeValue: data.endTime,
                              descriptionValue: data.description);
                        }),
                  ),
          ),
        ));
  }

  Form generateForm(BuildContext context,
      {String? titleValue,
      DateTime? startTimeValue,
      DateTime? endTimeValue,
      String? descriptionValue}) {
    if (titleValue != null) {
      titleController.text = titleValue;
    }

    if (startTimeValue != null) {
      startTime = startTimeValue;
    }

    if (endTimeValue != null) {
      endTime = endTimeValue;
    }

    if (descriptionValue != null) {
      descriptionController.text = descriptionValue;
    }

    return Form(
      key: _formKey,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: TextFormField(
              controller: titleController,
              decoration: const InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: 'Title',
                  suffixIcon: Icon(Icons.title)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: DateTimeFormField(
              initialValue: startTimeValue,
              firstDate: DateTime.now(),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Start time',
                suffixIcon: Icon(Icons.event_note),
              ),
              mode: DateTimeFieldPickerMode.dateAndTime,
              onDateSelected: (date) {
                startTime = date;
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: DateTimeFormField(
              initialValue: endTimeValue,
              firstDate: DateTime.now(),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'End time',
                suffixIcon: Icon(Icons.event_note),
              ),
              mode: DateTimeFieldPickerMode.dateAndTime,
              onDateSelected: (date) {
                endTime = date;
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: TextFormField(
              controller: descriptionController,
              minLines: 5,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              decoration: const InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: 'Description',
                  helperText: 'Supports Markdown',
                  suffixIcon: Icon(Icons.info)),
            ),
          ),
          ElevatedButton(
              onPressed: () => submit(context),
              child: const Text('Create Event'))
        ],
      ),
    );
  }
}
