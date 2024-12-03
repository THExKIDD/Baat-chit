import 'package:firebase_auth/firebase_auth.dart';
import 'package:userapp/models/user_model.dart';

final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

User? currentUser;
UserModel? userModelCurrentInfo;