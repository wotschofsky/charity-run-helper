import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:form_validator/form_validator.dart';

class EditSponsor extends StatefulWidget {
  const EditSponsor({required this.eventId, required this.participationId});

  final String eventId;
  final String participationId;

  @override
  _EditSponsorState createState() => _EditSponsorState();
}

class _EditSponsorState extends State<EditSponsor> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController amountController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController zipController = TextEditingController();
  final TextEditingController cityController = TextEditingController();

  void submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FirebaseFirestore.instance.collection('sponsors').add({
      'eventId': widget.eventId,
      'runnerId': FirebaseAuth.instance.currentUser!.uid,
      'participationId': widget.participationId,
      'amount': double.parse(amountController.text),
      'email': emailController.text,
      'firstName': firstNameController.text,
      'lastName': lastNameController.text,
      'address': addressController.text,
      'zip': zipController.text,
      'city': cityController.text,
      'paymentComplete': false,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text('Add Sponsor', style: const TextStyle(fontSize: 24)),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 16, right: 16),
                child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: TextFormField(
                              controller: amountController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                  border: const OutlineInputBorder(),
                                  labelText: 'Amount',
                                  hintText: 'Amount / km'),
                              validator: (value) {
                                final numericRegex =
                                    RegExp(r'([0-9]+)((\.|,)([0-9]*))?');
                                if (value == null ||
                                    !numericRegex.hasMatch(value)) {
                                  return 'The field is not a valid number';
                                }
                              }),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: TextFormField(
                              controller: emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                  border: const OutlineInputBorder(),
                                  labelText: 'Email'),
                              validator: ValidationBuilder().email().build()),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: TextFormField(
                              controller: firstNameController,
                              keyboardType: TextInputType.name,
                              decoration: const InputDecoration(
                                  border: const OutlineInputBorder(),
                                  labelText: 'First Name'),
                              validator:
                                  ValidationBuilder().minLength(1).build()),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: TextFormField(
                              controller: lastNameController,
                              keyboardType: TextInputType.name,
                              decoration: const InputDecoration(
                                  border: const OutlineInputBorder(),
                                  labelText: 'Last Name'),
                              validator:
                                  ValidationBuilder().minLength(1).build()),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: TextFormField(
                              controller: addressController,
                              keyboardType: TextInputType.streetAddress,
                              decoration: const InputDecoration(
                                  border: const OutlineInputBorder(),
                                  labelText: 'Address'),
                              validator:
                                  ValidationBuilder().minLength(1).build()),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: TextFormField(
                              controller: zipController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                  border: const OutlineInputBorder(),
                                  labelText: 'Zip Code'),
                              validator: (value) {
                                final zipRegex = RegExp(r'[0-9]{4,5}');
                                if (value == null ||
                                    !zipRegex.hasMatch(value)) {
                                  return 'The field is not a valid zip code';
                                }
                              }),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: TextFormField(
                              controller: cityController,
                              keyboardType: TextInputType.text,
                              decoration: const InputDecoration(
                                  border: const OutlineInputBorder(),
                                  labelText: 'City'),
                              validator:
                                  ValidationBuilder().minLength(1).build()),
                        ),
                        TextButton(
                          onPressed: submit,
                          child: const Text('Submit'),
                        ),
                      ],
                    )),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
