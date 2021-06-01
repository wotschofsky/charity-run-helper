import 'package:flutter/material.dart';

class ErrorMessage extends StatelessWidget {
  const ErrorMessage({this.message = 'Something went wrong'});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Icon(
          Icons.warning,
          color: Colors.grey,
          size: 64,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Text(
            message,
            style: TextStyle(color: Colors.grey, fontSize: 20),
          ),
        )
      ],
    );
  }
}
