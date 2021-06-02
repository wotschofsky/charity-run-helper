import 'package:flutter/material.dart';

import '../ui/error_message.dart';

class NotFoundPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Charity Run Helper'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const ErrorMessage(
              message: 'Page not found',
            )
          ],
        ),
      ),
    );
  }
}
