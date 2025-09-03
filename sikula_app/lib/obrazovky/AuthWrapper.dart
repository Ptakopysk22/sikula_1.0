import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sikula/obrazovky/Domovska.dart';
import 'package:sikula/obrazovky/Nacitaci.dart';
import 'package:sikula/obrazovky/Prihlasovaci.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({
    Key? key,
  }) : super(key: key);

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _showNacitaci = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        _showNacitaci = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (_showNacitaci) {
          return const Nacitaci();
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return const Nacitaci();
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        } else if (snapshot.hasData) {
          return Domovska();
        } else {
          return const Prihlasovaci();
        }
      },
    );
  }
}
