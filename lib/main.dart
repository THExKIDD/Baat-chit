import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_notification_channel/flutter_notification_channel.dart';
import 'package:flutter_notification_channel/notification_importance.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:userapp/providers/passProvider.dart';
import 'package:userapp/screens/splash_screen1.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:userapp/firebase_options.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

    Firebase.initializeApp(

      options: DefaultFirebaseOptions.currentPlatform,

    ).then((_) {

      log('Firebase initialized');

    }).catchError((error) {

      log('Error initializing Firebase: $error');

    });


  var result = await FlutterNotificationChannel().registerNotificationChannel(
    description: 'for showing message notifications',
    id: 'chats',
    importance: NotificationImportance.IMPORTANCE_HIGH,
    name: 'Chats',
  );
  log(result);

  await Supabase.initialize(
    url: dotenv.env['SUPABASEURL'] ?? 'no_url',
    anonKey: dotenv.env['ANONKEY'] ?? 'no_key',
  ).then((val){
    log('Supabase Initialized');
  });


    runApp(
        MultiProvider(providers: [
          ChangeNotifierProvider(create: (_) => PassProvider()),
        ],
          child: const MyApp(),
        )
    );


}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Chat',
      debugShowCheckedModeBanner: false,
      home: SplashScreen1(),
    );
  }
}