import 'package:firebase_database/firebase_database.dart';
import 'package:userapp/Global/global.dart';
import 'package:userapp/models/user_model.dart';

class AssistantMethods{

  static void readCurrentUserInfo() async{
    currentUser = firebaseAuth.currentUser;
    DatabaseReference userRef = FirebaseDatabase.instance.ref().child('users').child(currentUser!.uid);

    userRef.once().then((snap){
      if(snap.snapshot.value != null)
        {
          userModelCurrentInfo = UserModel.fromSnapshot(snap.snapshot);
        }
    });
  }
}