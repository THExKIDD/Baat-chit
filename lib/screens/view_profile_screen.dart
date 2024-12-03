
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:userapp/assistant%20methods/date_util.dart';

import 'package:userapp/models/chat_user.dart';


class ViewProfileScreen extends StatefulWidget {
  final ChatUser user;
  const ViewProfileScreen({super.key, required this.user});


  @override

  State<ViewProfileScreen> createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> {






  bool isLoading = false;
  Map <String,dynamic>? userMap;








  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: (){
        return FocusScope.of(context).unfocus();
      },
      child: Scaffold(
          appBar: AppBar(
            title: Text(
              widget.user.name,
              style: const TextStyle(
                fontFamily: 'bebe',
                fontWeight: FontWeight.bold,
                fontSize: 40,
              ),
            ),

          ),


          floatingActionButton: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              const Text(
                'Joined On: ',
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),

              ),
              Text(
                DateUtil.getLastMsgTime(context: context, time: widget.user.createdAt,showYear: true),
                style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 16
                ),
              ),
            ],
          ) ,




          body: Padding(
            padding:  EdgeInsets.symmetric(horizontal: size.width * .05),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(width: size.width,height: size.height * .03,),

                  Stack(
                    children: [

                      ClipRRect(
                        borderRadius: BorderRadius.circular(size.height * .1),
                        child: CachedNetworkImage(
                          width: size.height * .2,
                          height: size.height * .2,
                          fit: BoxFit.cover,
                          imageUrl: widget.user.image,
                          //placeholder: (context, url) => CircularProgressIndicator(),
                          errorWidget: (context, url, error) => const CircleAvatar(
                            child: Icon(CupertinoIcons.person),
                          ),
                        ),
                      ),



                    ],
                  ),

                  SizedBox(height: size.height * .03),

                  Text(
                    widget.user.name,
                    style: const TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                    ),
                  ),
                  SizedBox(height: size.height * .02),

                  Text(
                    widget.user.email,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: size.height * .02),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      const Text(
                        'About: ',
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),

                      ),
                      Text(
                        widget.user.about,
                        style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 16
                        ),
                      ),
                    ],
                  ),









                ],
              ),
            ),
          )


      ),
    );


  }

}
