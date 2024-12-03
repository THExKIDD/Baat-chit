import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:userapp/custom_widgets/chat_tile.dart';
import 'package:userapp/screens/main_screen.dart';

class ChatTile{

   static Widget chatTile ({required Size size, required Map usermap})
  {
    return Container(
      height: size.height/12,
      width: size.width/1.2,
      child: ListTile(
        title: Text(usermap['name']),
        subtitle: Text(usermap['email']),
      )
    );
  }
}