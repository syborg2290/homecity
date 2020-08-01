import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nearby/screens/initials/home.dart';
import 'package:nearby/screens/initials/login.dart';
import 'package:nearby/services/auth_services.dart';
import 'package:nearby/utils/pallete.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final AuthServcies _authServcies = AuthServcies();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return MaterialApp(
      title: 'Nearby',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Pallete.mainAppColor,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: AnimatedSplashScreen(
        duration: 3000,
        splashTransition: SplashTransition.sizeTransition,
        splash: Image.asset(
          'assets/logo.png',
          width: 100,
          height: 100,
          color: Pallete.mainAppColor,
        ),
        nextScreen: FutureBuilder(
          future: _authServcies.getCurrentUser(),
          builder: (context, AsyncSnapshot<FirebaseUser> snapshot) {
            if (snapshot.hasData) {
              return Home();
            } else {
              return Login();
            }
          },
        ),
      ),
    );
  }
}
