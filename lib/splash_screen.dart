import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:userapp/Global/global.dart';
import 'package:userapp/assistant%20methods/assistant_methods.dart';
import 'package:userapp/screens/login_screen.dart';
import 'package:userapp/screens/main_screen.dart';
import 'package:async/async.dart';
import 'dart:async' as async;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    startTimer();
  }
  startTimer()
  {
    async.Timer(Duration(seconds: 3),() async{
      if(await firebaseAuth.currentUser != null)
        {
          firebaseAuth.currentUser != null ? AssistantMethods.readCurrentUserInfo() : null;
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MainScreen()));
        }
      else
        {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen()));
        }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(image: AssetImage('lib/images/dark_car.jpg'),
          opacity: 0.3,
            fit: BoxFit.fill,
          )
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 300, 0, 0),
          child: Column(
            children: [
              Text(
                  'Baatein',
                style: TextStyle(
                  fontFamily: 'bebe',
                  fontWeight: FontWeight.bold,
                  fontSize: 50,
                ),
              ),
              SpinKitThreeInOut(
                size: 50,
                color: Colors.blue,
              )
            ],
          ),
        ),
      ),
    );
  }
}
