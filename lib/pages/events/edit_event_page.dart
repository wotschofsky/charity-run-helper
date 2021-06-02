import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_field/date_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditEventPage extends StatefulWidget {
  const EditEventPage({Key? key}) : super(key: key);

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
    });

    VxNavigator.of(context)
        .push(Uri(path: '/events/details', queryParameters: {'id': doc.id}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('New Event')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
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
                    firstDate: DateTime.now(),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Start time',
                      suffixIcon: Icon(Icons.event_note),
                    ),
                    mode: DateTimeFieldPickerMode.dateAndTime,
                    onDateSelected: (date) {
                      setState(() {
                        startTime = date;
                      });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: DateTimeFormField(
                    firstDate: DateTime.now(),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'End time',
                      suffixIcon: Icon(Icons.event_note),
                    ),
                    mode: DateTimeFieldPickerMode.dateAndTime,
                    onDateSelected: (date) {
                      setState(() {
                        endTime = date;
                      });
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
                    child: Text('Create Event'))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
