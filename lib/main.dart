import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:userapp/providers/passProvider.dart';
import 'package:userapp/screens/login_screen.dart';
import 'package:userapp/screens/main_screen.dart';
import 'package:userapp/screens/register_screen.dart';
import 'package:userapp/screens/splash_screen1.dart';
import 'package:userapp/splash_screen.dart';
import 'package:userapp/theme%20provider/theme_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:userapp/firebase_options.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();

    Firebase.initializeApp(

      options: DefaultFirebaseOptions.currentPlatform,

    ).then((_) {

      print('Firebase initialized');

    }).catchError((error) {

      print('Error initializing Firebase: $error');

    });

  await Supabase.initialize(
    url: 'https://bfpxwrffoovoroorlnuj.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJmcHh3cmZmb292b3Jvb3JsbnVqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzEyNjI2NTYsImV4cCI6MjA0NjgzODY1Nn0.rocrnSut9iWU4WZgGOU2EfFE3thN-xfR1s5c5HdQkbI',
  );


    runApp(
        MultiProvider(providers: [
          ChangeNotifierProvider(create: (_) => PassProvider()),
        ],
          child: MyApp(),
        )
    );


}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat',
      debugShowCheckedModeBanner: false,
      home: SplashScreen1(),
    );
  }
}