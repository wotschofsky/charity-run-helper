import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:velocity_x/velocity_x.dart';

class AppDrawer extends StatefulWidget {
  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  bool signedIn = false;

  initState() {
    super.initState();

    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        setState(() {
          signedIn = false;
        });
      } else {
        setState(() {
          signedIn = true;
        });
      }
    });
  }

  String get label {
    if (FirebaseAuth.instance.currentUser == null ||
        FirebaseAuth.instance.currentUser!.email == null) {
      return 'Welcome';
    }
    return FirebaseAuth.instance.currentUser!.email!;
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(
                image: DecorationImage(
                    image: NetworkImage(
                        'https://images.unsplash.com/photo-1590333748338-d629e4564ad9?w=500'),
                    fit: BoxFit.cover)),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                label,
                style: const TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Home'),
            onTap: () => VxNavigator.of(context).replace(Uri(path: '/')),
          ),
          ListTile(
            leading: Icon(Icons.calendar_today),
            title: Text('Events'),
            onTap: () => VxNavigator.of(context).replace(Uri(path: '/events')),
          ),
          Divider(),
          if (!signedIn)
            ListTile(
              leading: Icon(Icons.vpn_key),
              title: Text('Login'),
              onTap: () => VxNavigator.of(context).push(Uri(path: '/auth')),
            )
          else
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () => FirebaseAuth.instance.signOut(),
            ),
        ],
      ),
    );
  }
}
