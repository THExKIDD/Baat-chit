import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as Firebase_Auth;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:gallery_saver_updated/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:userapp/API/api_storage.dart';
import 'package:userapp/Controllers/controllers.dart';

import 'package:userapp/models/chat_user.dart';
import 'package:userapp/models/message.dart';
import 'package:userapp/utils/dialogs.dart';

class Api{
  static Firebase_Auth.User get user => auth.currentUser!;

  static late ChatUser me;


  static FirebaseAuth auth = FirebaseAuth.instance;

  static Supabase bucket = Supabase.instance;



  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  //for push notifications firebase messaging
   static FirebaseMessaging fMessaging = FirebaseMessaging.instance;


  //to check if user exists
static Future<bool> userExists() async {
  return (await firestore.collection('users').doc(auth.currentUser!.uid).get()).exists;
}


//creating new user
static Future<void> createUser() async{

  final time = DateTime.now().millisecondsSinceEpoch.toString();

  final chatUser = ChatUser(
      email: auth.currentUser!.email.toString(),
      image: auth.currentUser!.photoURL.toString(),
      name: auth.currentUser!.displayName.toString(),
      id: auth.currentUser!.uid,
      about: "about test",
      isOnline: false,
      lastActive: time,
      pushToken:  '',
      createdAt: time
  );

  return await firestore.collection('users').doc(auth.currentUser!.uid).set(chatUser.toJson());

}



  static Stream<QuerySnapshot<Map<String, dynamic>>> getMyUsers() {

    return firestore.collection('users')
        .doc(user.uid)
        .collection('my_users')
        .snapshots();
  }

//getting users from firestore
static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers(List<String> userIds) {

  log('\n userIds: $userIds');

  return firestore.collection('users')
      .where('id', whereIn: userIds.isEmpty
      ? ['']
      : userIds)
      .snapshots();
}


  static Future<void> sendFirstMessage(ChatUser chatUser, String msg, Type type) async {

  await firestore
      .collection('users')
      .doc(chatUser.id)
      .collection('my_users')
      .doc(user.uid)
      .set({})
      .then((value) => sendMessage(chatUser, msg, type));

  }




// for user info only
static Future<void> getSelfInfo() async{

  await firestore.collection('users')
      .doc(user.uid)
      .get()
      .then((user) async{

        if(user.exists)
          {
            me = ChatUser.fromJson(user.data()!);

            await getFirebaseMessagingToken();

            Api.updateActiveStatus(true);
          }
        else
          {
            await createUser().then((value) => getSelfInfo());
          }

  });

}

// for updating user profile
static Future<void> updateUserInfo() async{

  await firestore.collection('users').doc(user.uid)
      .update({
    'name' : me.name,
    'about' : me.about,
      });
}

  // chats (collection) => conversation id(doc) => messages (collection) => message(doc)


  static String getConvoId(String Id) => user.uid.hashCode <= Id.hashCode
      ? '${user.uid}_$Id'
      : '${Id}_${user.uid}';


//message apis

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(ChatUser user) {

    return firestore.collection('chats/${getConvoId(user.id)}/messages/').orderBy('sent',descending: true).snapshots();
  }



  static Future<void> sendMessage(ChatUser chatUser, String msg, Type type) async
  {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    
    final Message message = Message(read: '', told: chatUser.id, message: msg, type: type, sent: time, fromId: user.uid);

    final ref = firestore.collection('chats/${getConvoId(chatUser.id)}/messages/');
    await ref.doc(time).set(message.toJson()).then((value) =>
      ApiStorage.sendNotification(chatUser, type == Type.text ? msg : "sent an image" )
    );

  }

  //download image
  static Future<void> downloadImage(String fileUrl) async {

    try {

      // Step 1: Extract the file path from the URL

      String searchString = 'chat_image';

      int index = fileUrl.indexOf(searchString);

      late String result;


      if (index != -1) {

        result = fileUrl.substring(index + searchString.length);

      } else {

        print('"$searchString" not found in the URL.');

        return; // Exit if the search string is not found

      }


      // Step 2: Download the image data from Supabase

      final Uint8List imageData = await Supabase.instance.client.storage.from('chat_image').download(result);


      // Step 3: Get the directory to save the image

      final directory = await getApplicationDocumentsDirectory();

      final imageDirectory = Directory('${directory.path}/images');


      // Create the directory if it doesn't exist

      if (!await imageDirectory.exists()) {

        await imageDirectory.create(recursive: true);

      }


      final filePath = '${imageDirectory.path}$result'; // Ensure the path is correct

      final file = File(filePath);


      // Step 4: Write the file data to the local file

      await file.writeAsBytes(imageData);


      // Step 5: Save the image to the gallery

      final galleryResult = await GallerySaver.saveImage(file.path);

      if (galleryResult != null && galleryResult) {

        print("Image moved to gallery");

      } else {

        print("Failed to save image to gallery");

      }

    } catch (e) {

      log('downloadImage: ${e.toString()}');

    }

  }


  static Future<void> updateMessage(Message message) async
  {




  }


  static Future<void> deleteMsg(Message message) async
  {
    await firestore
        .collection('chats/${getConvoId(message.told)}/messages/')
        .doc(message.sent)
        .delete();

    if(message.type == Type.image){


        String url = message.message;

        // Define the substring to search for
        String searchString = 'chat_image';

        // Find the index of the search string
        int index = url.indexOf(searchString);

        late String result;
        if (index != -1) {
          // Get the substring starting from the end of 'chat_image'
          result = url.substring(index + searchString.length);
          log('Substring after "chat_image": $result');
        } else {
          log('"$searchString" not found in the URL.');
        }

        await bucket.client.storage.from('chat_image').remove([result]);
    }

  }



  static Future<void> updateReadStatus(Message message) async
  {
    firestore
        .collection('chats/${getConvoId(message.fromId)}/messages/')
        .doc(message.sent)
        .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }


  static Future<void> updatePfp(File file) async{

    final ext = file.path.split('.').last;

    log('Extension = $ext');

    String pfpPath = 'profile_pictures/${user.uid}.$ext';

    await bucket.client.storage.from('chat_image').update(pfpPath, file).then((value){
      log('data transferred : $value');
    }).onError((e,stacktrace) async{
      if(e is StorageException)
        {
          await bucket.client.storage.from('chat_image').remove([pfpPath]);
          updatePfp(File(ControllerAali.imageUpdate!));
        }
    });

    me.image = bucket.client.storage.from('chat_image').getPublicUrl(pfpPath);
// updating firestore path
    await firestore.collection('users').doc(user.uid).update({
      'image' : me.image
    }).then((value){
      log('\n \n  ${me.image}  \n');
    });



    

  }

  static Stream<QuerySnapshot<Map<String ,dynamic>>> getLastmsg (ChatUser user)
  {

    return firestore
        .collection('chats/${getConvoId(user.id)}/messages/')
        .orderBy('sent' , descending: true)
        .limit(1)
        .snapshots();

  }


  static Future<void> sendChatImage(ChatUser chatUser , File file) async
  {



    final ref = bucket.client.storage.from('chat_image');

    String chatImagePath = 'images/${getConvoId(chatUser.id)}/${DateTime.now().millisecondsSinceEpoch}';
    


    await ref.upload(chatImagePath, file).then((value){
      log('file uploaded successfully');
    });

    final imageUrl = ref.getPublicUrl(chatImagePath);

    await sendMessage(chatUser, imageUrl, Type.image);







  }



  // for realtime active status

  static Future<void> updateActiveStatus(bool isOnline)async
  {

    firestore.collection('users')
        .doc(user.uid).update({
      'is_online': isOnline,
      'last_active': DateTime.now().millisecondsSinceEpoch.toString(),
      'push_token': me.pushToken,
        });

  }



 static Stream<QuerySnapshot<Map<String,dynamic>>> getUserInfo(ChatUser chatUser) {

    return firestore.collection('users')
        .where('id' ,isEqualTo: chatUser.id)
        .snapshots();

 }



// Notification Logic

   static Future<void> getFirebaseMessagingToken() async
   {
     await fMessaging.requestPermission();

     fMessaging.getToken().then((value){

       if(value != null)
         {
           me.pushToken = value;


           log('push token: ${me.pushToken}');
         }

     });

     FirebaseMessaging.onMessage.listen((RemoteMessage message){
       
       log('Got a message in foreground!');
       log('Message data : ${message.data}');
       
       if(message.notification != null)
         {
           log('Message also contained a notification: ${message.notification}');
         }
     });


   }


   static Future<bool> addChatUser(String email)async
   {
     
     final data = await firestore.collection('users').where('email',isEqualTo: email).get();


     if(data.docs.isNotEmpty && data.docs.first.id != user.uid)
       {

         log('user exists : ${data.docs.first.data()}');

         firestore
             .collection('users')
             .doc(user.uid)
             .collection('my_users')
             .doc(data.docs.first.id)
             .set({});

         return true;
       }
     else{
       return false;
     }
   }














}