
import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart' as foundation;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:userapp/API/api.dart';
import 'package:userapp/assistant%20methods/date_util.dart';
import 'package:userapp/custom_widgets/message_card.dart';
import 'package:userapp/models/chat_user.dart';
import 'package:userapp/models/message.dart';
import 'package:userapp/screens/view_profile_screen.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser user;
  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {



  //for storing msgs
   List<Message> _list = [];


   final _textController = TextEditingController();

   bool _showEmoji = false, _isUploading = false;

   /*void _scrollToBottom() {

     _scrollWaala.jumpTo(_scrollWaala.position.maxScrollExtent);

   }*/
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: FocusScope.of(context).unfocus,
      child: SafeArea(
        child: PopScope(
          canPop: !_showEmoji, // Control whether the route can be popped
          onPopInvoked: (didPop) async {
            if (_showEmoji && !didPop) { // Only handle if _isSearching is true and the route wasn't popped
              setState(() {
                _showEmoji = !_showEmoji;
              });
            }
          },
          child: Scaffold(
            backgroundColor: const Color.fromARGB(255, 234, 248, 255),
            appBar: AppBar(
              automaticallyImplyLeading: false,
              flexibleSpace: _appBar() ,
            ),

            body: Column(
              children: [
                Expanded(
                  child: StreamBuilder(
                     stream: Api.getAllMessages(widget.user),
                      builder: (context, snapshot) {


                        switch(snapshot.connectionState)
                        {
                          case ConnectionState.waiting:
                          case ConnectionState.none:
                            return const SizedBox();

                          case ConnectionState.active:
                          case ConnectionState.done:
                            final data = snapshot.data?.docs;
                            _list = data?.map((e) => Message.fromJson(e.data())).toList() ?? [];

                            // Scroll to bottom when new messages are loaded





                        }


                        if(_list.isNotEmpty)
                        {
                          return ListView.builder(reverse: true,itemBuilder: (context,index){

                            return MessageCard(message: _list[index]);
                          },
                            itemCount: _list.length,
                            padding: EdgeInsets.only(top: size.height * 0.02),
                            physics: const BouncingScrollPhysics(),

                          );
                        }
                        else
                        {
                          return const Center(
                            child: Text('Say Hi 👋'),
                          );
                        }
                      }
                  ),
                ),
// for showing image upload loading
                if(_isUploading)
                const Align(
                  alignment: Alignment.centerRight,
                    child: Padding(
                      padding:  EdgeInsets.symmetric(vertical: 8,horizontal: 20),
                      child: CircularProgressIndicator(strokeWidth: 2,),
                    )
                ),

                _chatInput(),

                if(_showEmoji)
                  SizedBox(
                  height: size.height * .35,
                  child: EmojiPicker(
                    textEditingController: _textController, // pass here the same [TextEditingController] that is connected to your input field, usually a [TextFormField]
                    config: Config(

                      emojiViewConfig: EmojiViewConfig(
                        emojiSizeMax: 28 * (foundation.defaultTargetPlatform == TargetPlatform.iOS ? 1.20 : 1.0),
                        backgroundColor: const Color.fromARGB(255, 234, 248, 255),
                        columns: 8,


                      ),
                      categoryViewConfig: const CategoryViewConfig(
                        backgroundColor: Color.fromARGB(255, 234, 248, 255),
                      )


                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }





//chat text box

  Widget _chatInput()
  {
    final size = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size.width * .025  ,vertical: size.height * .01 ),
      child: Row(
        children: [
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15)
              ),
              child: Row(
                children: [
                  IconButton(
                      onPressed: (){
                        FocusScope.of(context).unfocus;
                        setState(() {
                          _showEmoji = !_showEmoji;
                        });

                      },
                      icon: const Icon(Icons.emoji_emotions,color: Colors.blueAccent,)
                  ),

                   Expanded(
                    child: TextField(
                      onTap: (){
                        if(_showEmoji) {
                          setState(() {
                          _showEmoji = !_showEmoji;
                        });
                        }
                      },
                      controller: _textController,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      decoration: const InputDecoration(
                        hintText: 'Type Something...',
                        hintStyle: TextStyle(
                          color: Colors.blueAccent,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),

                  IconButton(
                      onPressed: () async {
                        final  ImagePicker picker = ImagePicker();

                        final List<XFile> images =
                            await picker.pickMultiImage(imageQuality: 70);

                        for(var i in images)
                          {
                            
                            
                            log('image path : ${i.path} ');
                            setState(() {
                              _isUploading =true;
                            });
                            await Api.sendChatImage(widget.user, File(i.path));
                            setState(() {
                              _isUploading =false;
                            });
                          }




                      },
                      icon: const Icon(Icons.image,color: Colors.blueAccent,)
                  ),

                  IconButton(
                      onPressed: () async{
                        final  ImagePicker picker = ImagePicker();

                        final XFile? image =
                            await picker.pickImage(source: ImageSource.camera, imageQuality: 70);

                        if(image != null)
                          {

                            log('Image path : ${image.path}');
                            setState(() {
                              _isUploading =true;
                            });
                             await Api.sendChatImage(widget.user, File(image.path));
                            setState(() {
                              _isUploading =false;
                            });
                          }





                      },
                      icon: const Icon(Icons.camera_alt_rounded,color: Colors.blueAccent,)
                  ),

                  SizedBox(width: size.width * .02),
                ],
              ),
            ),
          ),


          //send button

          MaterialButton(
              onPressed: (){
                
               try{
                 if(_textController.text.isNotEmpty)
                 {
                   Api.sendMessage(widget.user, _textController.text,Type.text);
                   _textController.text = '';
                 }
               }
                   catch(e)
                {
                  log(' \n \n error : $e \n \n');
                }
                
              },
            minWidth: 0,
            padding: const EdgeInsets.only(top: 10, bottom: 10,right: 5, left: 10),
            shape: const CircleBorder(),
            color: Colors.green,
            child: const Icon(Icons.send,
            color: Colors.white ,
              size: 28,

            ),

          )
        ],
      ),
    );
  }













  //appbar function
  Widget _appBar(){
    final size = MediaQuery.of(context).size;
    return InkWell(
      onTap: (){
        
        Navigator.push(context, MaterialPageRoute(builder: (_) => ViewProfileScreen(user: widget.user)));
      },
      child: StreamBuilder(stream:Api.getUserInfo(widget.user) ,builder: (context,snapshot){

        final data = snapshot.data?.docs;

        final list =
            data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];

        return Row(
          children: [
            IconButton(
              onPressed: (){
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back),
              color: Colors.black54,
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular( size.height * .3),
              child: CachedNetworkImage(
                width: size.height * .033,
                height: size.height * .033,
                imageUrl: list.isNotEmpty ? list[0].image :widget.user.image  ,
                //placeholder: (context, url) => CircularProgressIndicator(),
                errorWidget: (context, url, error) => const CircleAvatar(
                  child: Icon(CupertinoIcons.person),
                ),
              ),
            ),
            const SizedBox(width: 5),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  list.isNotEmpty ?
                      list[0].name
                  : widget.user.name,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,

                  ),
                ),

                const SizedBox(height: 2),

                 Text(
                  list.isNotEmpty ?
                      list[0].isOnline ?
                          'Online'
                   :DateUtil.getLastActiveTime(context: context, lastActive: list[0].lastActive)
                   :DateUtil.getLastActiveTime(context: context, lastActive: widget.user.lastActive),
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 13,
                    fontWeight: FontWeight.normal,

                  ),
                ),
              ],
            )
          ],
        );

      })
    );
  }
}


