
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:userapp/API/api.dart';
import 'package:userapp/Global/global.dart';
import 'package:userapp/screens/login_screen.dart';
import 'package:userapp/screens/main_screen.dart';

class SplashScreen1 extends StatefulWidget {
  const SplashScreen1({super.key});

  @override
  State<SplashScreen1> createState() => _SplashScreen1State();
}

class _SplashScreen1State extends State<SplashScreen1> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration(seconds: 2),(){
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(systemNavigationBarColor: Colors.white));
      if(Api.auth.currentUser != null){
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
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
              child: Image.asset('lib/images/chat(2).png'),
            top: size.height * 0.15,
            width: size.width * 0.5,
            right: size.width * 0.25,
          ),
          
          Positioned(
              child: Text(
                  'Made by Tarun 😎',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'bebe',
              ),
                textAlign: TextAlign.center,
              ),
            bottom: size.height * 0.15,
            width: size.width,
          )
        ],
      ),
    );
  }
}
