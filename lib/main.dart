import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import './pages/home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(App());
}

class App extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.deepOrange,
        ),
        home: FutureBuilder(
          future: _initialization,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              print(snapshot.error);
              return Text('An error occurred!');
            }

            if (snapshot.connectionState == ConnectionState.done) {
              return HomePage();
            }

            return CircularProgressIndicator();
          },
        ));
  }
}
