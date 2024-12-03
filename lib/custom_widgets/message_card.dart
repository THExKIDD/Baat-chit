
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:userapp/API/api.dart';
import 'package:userapp/assistant%20methods/date_util.dart';
import 'package:userapp/models/message.dart';

class MessageCard extends StatefulWidget {
  final Message message;
  const MessageCard({super.key, required this.message});

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Api.user.uid == widget.message.fromId
    ? _blueMessage()
    : _purpleMessage();

  }


  //incoming msg
Widget _purpleMessage()
{
  final size = MediaQuery.of(context).size;
  if(widget.message.read.isEmpty)
    {
      Api.updateReadStatus(widget.message);
      log(' \n \n msg Updated');
    }
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Flexible(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.purple.shade100,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
              bottomRight: Radius.circular(30),

            ),
            border: Border.all(color: Colors.purpleAccent)
          ),
          padding: EdgeInsets.all(  widget.message.type == Type.image ?   size.width * .03   :size.width * .04),
          margin: EdgeInsets.symmetric(horizontal: size.width * .04 , vertical: size.height * .01),



          child:

              widget.message.type  == Type.text ?

          Text(
              widget.message.message,
          style: const TextStyle(
            fontSize: 15,
            color: Colors.black87
          ),
          )
          :
              ClipRRect(
                borderRadius: BorderRadius.circular( size.height * .03),
                child: CachedNetworkImage(
                  imageUrl: widget.message.message,
                  placeholder: (context, url) => const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(strokeWidth: 2,),
                  ),
                  errorWidget: (context, url, error) => const CircleAvatar(
                    child: Icon(Icons.image,size: 70),
                  ),
                ),
              ),

        ),
      ),
      Padding(
        padding:  EdgeInsets.only(right: size.width * .04 ),
        child: Text(
          DateUtil.getFormattedTime(context: context, time: widget.message.sent),
        style: const TextStyle(
          fontSize: 13,
          color: Colors.black54,
        ),
        ),
      ),
    ],
  );
}


//outgoing msg
  Widget _blueMessage()
  {
    final size = MediaQuery.of(context).size;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [

        Row(
          children: [
            SizedBox(width: size.width * .04,),



           if(widget.message.read.isNotEmpty)
             const Icon(Icons.done_all_rounded,color: Colors.blue,size: 20,),

            const SizedBox(width: 2,),

            Text(
              DateUtil.getFormattedTime(context: context, time: widget.message.sent),
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black54,
              ),
            ),
          ],
        ),

        Flexible(
          child: Container(
            decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                  bottomLeft: Radius.circular(30),

                ),
                border: Border.all(color: Colors.lightBlue)
            ),
            padding: EdgeInsets.all(  widget.message.type == Type.image ?   size.width * .03   :size.width * .04),
            margin: EdgeInsets.symmetric(horizontal: size.width * .04 , vertical: size.height * .01),
            child:

            widget.message.type  == Type.text ?

            Text(
              widget.message.message,
              style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black87
              ),
            )
                :
            ClipRRect(
              borderRadius: BorderRadius.circular( size.height * .03),
              child: CachedNetworkImage(
                imageUrl: widget.message.message,
                placeholder: (context, url) => const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(strokeWidth: 2,),
                ),
                errorWidget: (context, url, error) => const CircleAvatar(
                  child: Icon(Icons.image,size: 70),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
