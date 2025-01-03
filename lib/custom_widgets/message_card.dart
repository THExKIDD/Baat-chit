
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:userapp/API/api.dart';
import 'package:userapp/assistant%20methods/date_util.dart';
import 'package:userapp/models/message.dart';
import 'package:userapp/utils/dialogs.dart';

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

    bool isMe = Api.user.uid == widget.message.fromId;
    return InkWell(
      onLongPress: (){
        _showBottomSheet(isMe);
      },
      child: isMe ? _blueMessage() : _purpleMessage(),
    );

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

  void _showBottomSheet(bool checkUser){
    final size = MediaQuery.of(context).size;
    showModalBottomSheet(context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20))
        ),
        builder: (_) {
          return SingleChildScrollView(
            child: ListView(
              shrinkWrap: true,
              children: [
                Container(
                  height: 4,
                  margin: EdgeInsets.symmetric(vertical: size.height * 0.015,horizontal: size.width * .4 ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey
                  ),
                ),

                if(widget.message.type == Type.text)
                _OptionItem(
                    icon: const Icon(Icons.copy_all_outlined,
                      color: Colors.blue,
                      size: 26,
                    ),
                    name: 'Copy Text',
                    onTap: (ctx) async {
                      await Clipboard.setData(
                          ClipboardData(text: widget.message.message))
                          .then((value) {
                        //for hiding bottom sheet
                        if(ctx.mounted){
                          Navigator.of(ctx).pop();
                          Dialogs.showSnackbar(ctx, 'Text Copied!');
                        }



                      });
                    }),



                if(checkUser)
                Divider(
                  color: Colors.black54,
                  endIndent: size.width * .04 ,
                  indent: size.height * .04,
                ),



                //edit message
                if(widget.message.type == Type.text && checkUser)
                _OptionItem(
                    icon: const Icon(Icons.edit,
                      color: Colors.blue,
                      size: 26,
                    ),
                    name: 'Edit Message',
                    onTap: (ctx)async{
                      if(ctx.mounted) {
                       _showMessageUpdateDialog(ctx);
                      }






                    }
                ),



                // delete message
                if(checkUser)
                _OptionItem(
                    icon: const Icon(Icons.delete,
                      color: Colors.red,
                      size: 26,
                    ),
                    name: 'Delete Message',
                    onTap: (ctx)async {

                      await Api.deleteMsg(widget.message);

                      Navigator.pop(ctx);
                    }
                ),



                Divider(
                  color: Colors.black54,
                  endIndent: size.width * .04 ,
                  indent: size.height * .04,
                ),
                //Sent at
                _OptionItem(
                    icon: const Icon(Icons.remove_red_eye,
                      color: Colors.blue,
                    ),
                    name: 'Sent At : ${DateUtil.getMessageTime(time: widget.message.sent)}',
                    onTap: (ctx){}
                ),

                //Read at
                _OptionItem(
                    icon: const Icon(Icons.remove_red_eye,
                      color: Colors.greenAccent,
                      size: 26,
                    ),
                    name: widget.message.read.isEmpty ?
                        'Read At : not seen yet'
                    :'Read At : ${DateUtil.getMessageTime(time: widget.message.read)}',
                    onTap: (ctx){}
                ),

              ],

            ),
          );
        });

  }
  void _showMessageUpdateDialog(final BuildContext ctx)
  {
    String updatedMsg = widget.message.message;

    showDialog(
        context: ctx,
        builder: (_) => AlertDialog(
      contentPadding: const EdgeInsets.only(
          left: 24, right: 24, top: 20, bottom: 10),

      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20))),

      //title
      title: const Row(
        children: [
          Icon(
            Icons.message,
            color: Colors.blue,
            size: 28,
          ),
          Text(' Update Message')
        ],
      ),

      //content
      content: TextFormField(
        initialValue: updatedMsg,
        maxLines: null,
        onChanged: (value) => updatedMsg = value,
        decoration: const InputDecoration(
            border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(15)))),
      ),

      //actions
      actions: [
        //cancel button
        MaterialButton(
            onPressed: () {
              //hide alert dialog
              Navigator.pop(ctx);
            },
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.blue, fontSize: 16),
            )),

        //update button
        MaterialButton(
            onPressed: () {
              Api.updateMessage(widget.message, updatedMsg);
              //hide alert dialog
              Navigator.pop(ctx);

              //for hiding bottom sheet
              Navigator.pop(ctx);
            },
            child: const Text(
              'Update',
              style: TextStyle(color: Colors.blue, fontSize: 16),
            ))
      ],
    ));
  }
}




class _OptionItem extends StatelessWidget {
  final Icon icon;
  final String name;
  final Function(BuildContext) onTap;
  const _OptionItem({super.key, required this.icon, required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return InkWell(
      onTap: () => onTap(context),
      child: Padding(
        padding: EdgeInsets.only(left: size.width *.05,top: size.height * .015, bottom: size.height * .02),
        child: Row(
          children: [
           icon,
            Flexible(
                child: Text(
                  '    $name',
              style: const TextStyle(
                color: Colors.black54,
                letterSpacing: 0.5,
              ),
            )
            ),
          ],
        ),
      ),
    );
  }
}

