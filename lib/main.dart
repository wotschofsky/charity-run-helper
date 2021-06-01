import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:url_strategy/url_strategy.dart';

import './pages/home_page.dart';
import './pages/auth_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setPathUrlStrategy();
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
      initialRoute: '/',
      routes: {
        '/': (ctx) => HomePage(),
        '/auth': (ctx) => AuthPage(),
      },
    );
  }
}
