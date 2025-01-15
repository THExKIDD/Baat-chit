
import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:userapp/models/chat_user.dart';
import 'package:userapp/API/api.dart' as myApi;
import 'package:userapp/models/message.dart';


class ApiStorage {




  static Future<String> getFirebaseMessagingToken() async
  {

    final serviceAccountJson =
    {

      "type": "service_account",
      "project_id": "taxiwaala",
      "private_key_id": dotenv.env["PRIVATEKEYID"] ?? "not found" ,
      "private_key": dotenv.env["PRIVATEKEY"] ?? 'not found',
      "client_email": "baateinthexkidd@taxiwaala.iam.gserviceaccount.com",
      "client_id": dotenv.env["CLIENTID"] ?? 'not found',
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url": dotenv.env["CLIENT_X509_CERT_URL"] ?? 'notfound',
      "universe_domain": "googleapis.com"

    };


    List<String> scopes =
        [
          "https://www.googleapis.com/auth/firebase.messaging"
        ];

    http.Client client = await auth.clientViaServiceAccount(
        auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
        scopes
    );

  //get access token
    auth.AccessCredentials credentials = await auth.obtainAccessCredentialsViaServiceAccount(
        auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
        scopes,
        client);

    client.close();

    return credentials.accessToken.data;


  }



  static sendNotification(Message userMessage,ChatUser user,String msg) async{


    DocumentSnapshot getTitle =  await FirebaseFirestore.instance.collection('users').doc(userMessage.fromId).get();

    log(getTitle.exists.toString());

    String nameData = getTitle.get('name');


    log('\n \n getTitle : $nameData \n \n');
    
    final String serverKey = await getFirebaseMessagingToken();

    String endPointFirebaseCloudMessaging = dotenv.env['ENDPOINTFIREBASECLOUDMESSAGING'] ?? 'no_key';

    final Map<String , dynamic> message =
    {

      'message': {

        'token': user.pushToken,

        'notification': {

          'title': nameData,

          'body': msg,

        },

        'data': {

          'some_data': 'User  ID : ${myApi.Api.me}',

        },

        'android': {

          'notification': {

            'channel_id': 'chats',

          },

        },

      },

    };
    
    final http.Response response = await http.post(
      Uri.parse(endPointFirebaseCloudMessaging),
      headers: <String,String>
        {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $serverKey'


        },
      body: jsonEncode(message),
    );

    if(response.statusCode == 200)
      {
        log('\n Notification sent');
      }
    else
      {
        log('Notification failed to sent : ${response.statusCode}');

        log(response.body);
      }


  }
  





}