import 'package:flutter/material.dart';

import '../ui/error_message.dart';

class NotFoundPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Charity Run Helper'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ErrorMessage(
              message: 'Page not found',
            )
          ],
        ),
      ),
    );
  }
}
