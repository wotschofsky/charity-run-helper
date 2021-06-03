import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:velocity_x/velocity_x.dart';

import './pages/home_page.dart';
import './pages/auth_page.dart';
import './pages/events/edit_event_page.dart';
import './pages/events/event_details_page.dart';
import './pages/events/events_overview_page.dart';
import './pages/not_found_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Vx.setPathUrlStrategy();
  runApp(App());
}

class App extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
      ),
      routeInformationParser: VxInformationParser(),
      routerDelegate: VxNavigator(
        routes: {
          '/': (uri, params) => MaterialPage(child: HomePage()),
          '/auth': (uri, params) => MaterialPage(child: AuthPage()),
          '/events': (uri, params) => MaterialPage(child: EventsOverviewPage()),
          '/events/details': (uri, params) {
            final id = uri.queryParameters['id'] as String;
            return MaterialPage(child: EventDetailsPage(id));
          },
          '/events/edit': (uri, params) {
            final id = uri.queryParameters['id'] as String;
            return MaterialPage(
                child: EditEventPage(
              id: id,
            ));
          },
          '/events/new': (uri, params) => MaterialPage(child: EditEventPage()),
        },
        notFoundPage: (uri, params) => MaterialPage(child: NotFoundPage()),
      ),
    );
  }
}
