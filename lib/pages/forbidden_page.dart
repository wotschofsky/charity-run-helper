import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

import '../navigation/app_drawer.dart';
import '../ui/error_message.dart';

class ForbiddenPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('No Permission'),
      ),
      drawer: AppDrawer(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const ErrorMessage(message: 'No permission'),
            const Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Text(
                  'You may need to login to access this page',
                  style: TextStyle(color: Colors.grey),
                )),
            TextButton(
                onPressed: () =>
                    VxNavigator.of(context).push(Uri(path: '/auth')),
                child: const Text('Login'))
          ],
        ),
      ),
    );
  }
}
