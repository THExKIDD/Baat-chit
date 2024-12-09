
import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:userapp/models/chat_user.dart';
import 'package:userapp/API/api.dart' as myApi;


class ApiStorage {


  static Future<String> getFirebaseMessagingToken() async
  {

    final serviceAccountJson =
    {

      "type": "service_account",
      "project_id": "taxiwaala",
      "private_key_id": "c030a47c41b025f73628836ee7cae4b7ae6d89b4",
      "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQCvoYgBR6W7myLq\nY5MDl/uiX/q/6TBjUN4YfjDpK1CqLyuabmh/LOkOmWJMN59pGvPaUcrd2Uk988xp\nwUkS/k8MWFTf9HDdu58lD6drB54L+Kt1t0+v49qvxNLnTThp6a/dqDBzeL9Bj7yH\nbsKvu/UddqXfTxVUquak+B62j8mxsxIuAFbKxFUrnjEkIkZMTqvyHcNYjWZkmt9B\nNv7/6FxfLcVea7ejtIZxTSEMPnUnKw+gZSMUF27iI7gqGj8y0s1mfjpZYR0tVfwk\nE0nFkRH4n0pz+IkaobS6FCdrbYZVHYlleBSV+yr5o0/iIfDm272z0sVr2G0j+TWP\noN6Ar63jAgMBAAECggEAD1ZeCq086hJlAllaFCUYb/h4F3yf4aRvvhgoYaG15Hlv\nEjLpxDq3St5BM80NtOo0zmV4f6wt1bpYfl8ckws1+wAsaqGtnjzNa+P0kl0IGR0z\nrU7Up38Qm2s8TGpgGVEI2c9fani/zFQRj4razJRE67hEnv4zK4GAgnqP2rsuzr+N\nMleFsHO48mASaYnV5vsacHh0qGP5JHA+SQoo5pm1IZB/FWUkhfa8JINeGUeRlxh0\nrUzi6nOzZnww6fQ/nB9IQTkJqZ2WACUMoldzOU36xWvGvE9AMhVivkL2Oy24jjtx\n+27GgqanPupfNtMkKOkSJP9WvAQaMru4ClWMXu8OAQKBgQDqcZsiyvqjQegfTLY1\nUpvzer9Ey9uaKJvDj82otAfo3yWJ1jLRjy1rIlvf/nmoDG7IputiVBtdmrfe/qob\nu4JXByuhGfFOw0KpFBzY5o9RvWlr7q+0BxVVrmxn3BYEtZ+w3bCiEZGp8sNl0Tat\nhWm3komgswPuH7xqpYXMkc5j4wKBgQC/x5NbK1gqhFBW968gne0D8heGEFDIimRN\nBok5ooee+TOKObASZVgcz4b0XyfkeemTuHbnIsvoJgDm+jotAcR2JBnwDELr6Ud/\nX24XjimM2Q4B4jpDzn7oXnUGNJfgwH7Eo2N9/m/gEY9bO5z+NckcmqH/ZLjA8RTl\nTZb+f5+uAQKBgCCGSkN1bXgguJc/CTg0kbYhnU9qCLlGUPW8iYeSElbYPlj1Am/Y\nMTDfv2c/4pjRwLzNi3JEwNcnk8K4Cdl3FgoE0KS0+Kk4pZLXW3kr404vvORgZLfR\nE8CjRh7Shat5lwHuf4a8cTzmlP0XHULNc3EoPzewHid296jD9d//imaJAoGBALJ8\nSfZ11q5rSmJGTmUq1eXwMFiDYsvhkQvm41wSmeoowAELQ4U7cNAPjOhujzAjDnJ/\nIZpoViIPDJPrmq08kd3qJ4Gzx6zMBdDTviCKHL2LXW//Xn6w9ofJMVy/IgL45IKa\nFgSzAuglL6iXSLuGz0+h0tdgpFpdhTcMCVV+7dwBAoGBALmNR5HsPw4wJ2PZlnVv\nJstzLWjBCPIJLymklDatPLjAbJ3CNj1VfgDx2dI7RdYV4kVi/p+oqoZZ5RQRUplI\n0ze4isctpZ7ujbCesW2Ajppau9RH9g6/lo5MmwPki8QGR4ulkpcvfc+HFdfH+xuK\nSKOCIMVJecfNfGFtp+828Pbn\n-----END PRIVATE KEY-----\n",
      "client_email": "baateinthexkidd@taxiwaala.iam.gserviceaccount.com",
      "client_id": "102833548759794072079",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/baateinthexkidd%40taxiwaala.iam.gserviceaccount.com",
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


  static sendNotification(ChatUser user,String msg) async{


    final String serverKey = await getFirebaseMessagingToken();

    String endPointFirebaseCloudMessaging = "https://fcm.googleapis.com/v1/projects/taxiwaala/messages:send";

    final Map<String , dynamic> message =
    {

      'message': {

        'token': user.pushToken,

        'notification': {

          'title': user.name,

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