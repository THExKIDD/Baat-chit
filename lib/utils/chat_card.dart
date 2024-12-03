

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:userapp/API/api.dart';
import 'package:userapp/assistant%20methods/date_util.dart';
import 'package:userapp/models/chat_user.dart';
import 'package:userapp/models/message.dart';
import 'package:userapp/screens/chat_screen.dart';
import 'package:userapp/screens/view_profile_screen.dart';
import 'package:userapp/utils/profile_pic_dialog.dart';

class ChatCard extends StatefulWidget {
  final ChatUser user;
  const ChatCard({super.key, required this.user});

  @override
  State<ChatCard> createState() => _ChatCardState();
}

class _ChatCardState extends State<ChatCard> {
  Message? _message;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      height: size.height * .09,
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: size.width * 0.02,vertical: 2),
        shape: RoundedRectangleBorder(),
        //color: Colors.blue.shade100,
        child: InkWell(
          onLongPress: (){
            Navigator.push(context, MaterialPageRoute(builder: (_) => ViewProfileScreen(user: widget.user)));
          },
          onTap: (){

            Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(user: widget.user)));
          },
          child:StreamBuilder(
           stream: Api.getLastmsg(widget.user),
           builder: (context ,snapshot){



             final data = snapshot.data?.docs;

             final list = data?.map((e) => Message.fromJson(e.data())).toList() ?? [];

             if(list.isNotEmpty)
               {

                 _message = list[0];

               }




             return ListTile(
               leading: InkWell(
                 onTap: (){

                   showDialog(context: context, builder: (_) => ProfilePicDialog(user: widget.user,) );

                 },
                 child: ClipRRect(
                   borderRadius: BorderRadius.circular(size.height * .5),
                   child: CachedNetworkImage(
                     width: size.height * .06,
                     height: size.height * .06,
                     imageUrl: widget.user.image,
                     //placeholder: (context, url) => CircularProgressIndicator(),
                     errorWidget: (context, url, error) => const CircleAvatar(
                       child: Icon(CupertinoIcons.person),
                     ),
                   ),
                 ),
               ),
               title: Text(widget.user.name),
               subtitle: Text( style: const TextStyle(color: Colors.blue,fontWeight: FontWeight.bold),
                   _message != null ?

                   _message!.type == Type.image ?
                   ' sent an image'

               :_message!.message

                   :  widget.user.about,maxLines: 1),
               trailing: _message == null
                   ? null
                   :
               _message!.read.isEmpty && _message!.fromId != Api.user.uid ? Container(
                 width: 15,
                 height: 15,
                 decoration: BoxDecoration(
                     borderRadius: BorderRadius.circular(10),
                     color: Colors.greenAccent.shade400
                 ),
               )
                   : Text(
              DateUtil.getLastMsgTime(context: context, time: _message!.sent),
              style: const TextStyle(
                color: Colors.black54
              ),
            ),
             );
           },
          )
        ),
      ),
    );
  }
}
