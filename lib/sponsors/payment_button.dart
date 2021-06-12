import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';

class PaymentButton extends StatefulWidget {
  const PaymentButton({required this.sponsorId, required this.amount});

  final String sponsorId;
  final String amount;

  @override
  _PaymentButtonState createState() => _PaymentButtonState();
}

class _PaymentButtonState extends State<PaymentButton> {
  var isProcessing = false;

  void handlePayment() async {
    setState(() {
      isProcessing = true;
    });

    final processPayment = FirebaseFunctions.instanceFor(region: 'europe-west3')
        .httpsCallable('processPayment');
    await processPayment({'sponsorId': widget.sponsorId});

    setState(() {
      isProcessing = false;
    });
  }

  String get buttonLabel {
    if (isProcessing) {
      return 'Processing...';
    }
    return 'Donate Now (${widget.amount}€)';
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: !isProcessing ? handlePayment : null,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(20),
        ),
        child: Text(buttonLabel));
  }
}
