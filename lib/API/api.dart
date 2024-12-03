import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as Firebase_Auth;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:userapp/Controllers/controllers.dart';

import 'package:userapp/models/chat_user.dart';
import 'package:userapp/models/message.dart';

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

//getting users from firestore
static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers() {

  return firestore.collection('users')
      .where('id', isNotEqualTo: user.uid)
      .snapshots();
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
    await ref.doc(time).set(message.toJson()).then((value){
      log('MESSAGE SENT ');
    });
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
      log('data transferred : ${value}');
    }).onError((e,stacktrace) async{
      if(e is StorageException)
        {
          await bucket.client.storage.from('chat_image').remove([pfpPath]);
          updatePfp(File(ControllerAali.imageUpdate!));
        }
    });

    await (me.image = bucket.client.storage.from('chat_image').getPublicUrl(pfpPath));
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

    final ext  = file.path.split('.').last;

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
   }












}