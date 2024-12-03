import 'package:firebase_database/firebase_database.dart';

class UserModel{

  String? phone;
  String? name;
  String? address;
  String? id;
  String? email;

  UserModel({this.phone,this.name,this.address,this.email,this.id});

  UserModel.fromSnapshot(DataSnapshot snap){
    phone = (snap.value as dynamic)['phone'];
    name = (snap.value as dynamic)['name'];
    id = (snap.value as dynamic)['id'];
    email = (snap.value as dynamic)['email'];
    address = (snap.value as dynamic)['address'];
  }


}