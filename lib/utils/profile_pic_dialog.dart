


import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:userapp/models/chat_user.dart';



class ProfilePicDialog extends StatelessWidget {
  final ChatUser user;
  const ProfilePicDialog({super.key, required this.user});


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return AlertDialog(
      backgroundColor: Colors.white,
      shape:  RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30)
      ),
      content: ClipRRect(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
          child: CachedNetworkImage(
            alignment: Alignment.center,
            width: size.width * 1,
            height: size.height * 0.35,
            imageUrl: user.image,
            fit: BoxFit.fill ,
            placeholder: (context, url) => const CircularProgressIndicator(),
            errorWidget: (context, url, error) => const CircleAvatar(
              child: Icon(CupertinoIcons.person),
            ),
          ),
        ),
      ),
    );
  }
}
