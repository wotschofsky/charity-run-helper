import 'package:flutter/material.dart';

import '../navigation/app_drawer.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Charity Run Helper'),
        ),
        drawer: AppDrawer(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Welcome!', style: TextStyle(fontSize: 48)),
              Padding(
                padding: const EdgeInsets.only(top: 32),
                child: Text(
                    'Get started by creating an event or signing up for one.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 20)),
              )
            ],
          ),
        ));
  }
}
