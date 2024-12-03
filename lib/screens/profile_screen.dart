



import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:userapp/API/api.dart';
import 'package:userapp/Controllers/controllers.dart';

import 'package:userapp/models/chat_user.dart';
import 'package:userapp/screens/login_screen.dart';
import 'package:userapp/utils/dialogs.dart';

class ProfileScreen extends StatefulWidget {
  final ChatUser user;
  const ProfileScreen({super.key, required this.user});


  @override

  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {






  bool isLoading = false;
  Map <String,dynamic>? userMap;
  String? _image;



  final _formkey2 = GlobalKey<FormState>();




  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: (){
        return FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Profile',
            style: TextStyle(
              fontFamily: 'bebe',
              fontWeight: FontWeight.bold,
              fontSize: 40,
            ),
          ),

        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: FloatingActionButton.extended(
            backgroundColor: Colors.redAccent,
              onPressed: ()async{

                Dialogs.showProgress(context);


                await Api.updateActiveStatus(false);


                //logout logic
                  if(ControllerAali.googleLoginCheck)
                    {
                      await Api.auth.signOut().then((value) async{
                        await GoogleSignIn().signOut().then((value){
                          Navigator.pop(context);
                          Navigator.pop(context);

                          Api.auth = FirebaseAuth.instance;
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                        });

                      });

                    }
                  else
                    {
                      Navigator.pop(context);
                      await Api.auth.signOut();
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                    }
              },
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),

          ),
        ),

        body: Form(
          key: _formkey2,
          child: Padding(
            padding:  EdgeInsets.symmetric(horizontal: size.width * .05),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(width: size.width,height: size.height * .03,),

                  Stack(
                    children: [
                      _image == null
                          ?
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
                      )





                      :ClipRRect(
                        borderRadius: BorderRadius.circular(size.height * .1),
                        child: Image.file(
                          File(_image!),
                          width: size.height * .2,
                          height: size.height * .2,
                          fit: BoxFit.cover,

                        ),
                      ),


                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: MaterialButton(
                          elevation: 1,
                            onPressed: (){
                            _showBottomSheet();
                            },
                          shape: const CircleBorder(),
                          color: Colors.white,
                          child: const Icon(Icons.edit),
                        ),
                      )
                    ],
                  ),

                  SizedBox(height: size.height * .03),

                  Text(
                    widget.user.email,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 16
                  ),
                  ),
                  SizedBox(height: size.height * .03),

                  TextFormField(
                    initialValue: widget.user.name,
                    onSaved: (val) => Api.me.name = val ?? '',
                    validator: (val) => val != null && val.isNotEmpty ? null
                    :
                    'Required field',
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.person,color: Colors.blue,),
                      border:  OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)
                      ),
                      hintText: 'eg Bunty Puttar',
                      label: const Text('Name')
                    ),
                  ),




                  SizedBox(height: size.height * .02),

                  TextFormField(
                    initialValue: widget.user.about,
                    onSaved: (val) => Api.me.about = val ?? '',
                    decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.info_outline,color: Colors.blue),
                        border:  OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)
                        ),
                        hintText: 'eg Feeling GUD',
                        label: const Text('about')
                    ),
                  ),

                  SizedBox(height: size.height * .05),

                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: const StadiumBorder(),
                      minimumSize: Size(size.width * .4, size.height * .06)
                    ),
                      onPressed: (){

                      if(_formkey2.currentState!.validate())
                        {
                          _formkey2.currentState!.save();
                         Api.updateUserInfo().then((value){
                           Dialogs.showSnackbar(context, 'Profile Updated');
                         });
                        }
                      },
                      icon: const Icon(Icons.edit,color: Colors.white,),
                    label: const Text('Update',style: TextStyle(fontSize: 16, color: Colors.white),),
                  ),
                ],
              ),
            ),
          ),
        )


      ),
    );


    

  }
  void _showBottomSheet(){
   final size = MediaQuery.of(context).size;
    showModalBottomSheet(context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20))
        ),
        builder: (_) {
      return ListView(
        shrinkWrap: true,
        padding: EdgeInsets.only(top: size.height * 0.02 ,bottom: size.height *0.05 ),
        children: [
          const Text('Pick Profile pic',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500
          ),
          ),
          SizedBox( height: size.height * .02),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: const CircleBorder(),
                  fixedSize: Size(size.width * .3, size.height * .15)
                ),
                  onPressed: () async {
                    final ImagePicker picker = ImagePicker();

                    final XFile? image =
                    await picker.pickImage(source: ImageSource.gallery,imageQuality: 80);

                    if(image != null)
                    {

                      setState(() {
                        _image = image.path;
                        ControllerAali.imageUpdate = image.path;
                      });
                      log('Image path = ${image.path} and --MIMETYPE = ${image.mimeType}');

                       Api.updatePfp(File(_image!));
                      Navigator.pop(context);
                    }



                  },
                  child: Image.asset('lib/images/gallery.png')
              ),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: const CircleBorder(),
                      fixedSize: Size(size.width * .3, size.height * .15)
                  ),
                  onPressed: () async{
                    final ImagePicker picker = ImagePicker();

                    final XFile? image =
                    await picker.pickImage(source: ImageSource.camera, imageQuality: 80);

                    if(image != null)
                    {


                      setState(() {
                        _image = image.path;
                        ControllerAali.imageUpdate = image.path;
                      });
                      log('Image path = ${image.path} and --MIMETYPE = ${image.mimeType}');

                      Api.updatePfp(File(_image!));

                      Navigator.pop(context);
                    }
                  },
                  child: Image.asset('lib/images/camera.png')
              ),


            ],
          ),
          SizedBox(height: size.height * 0.02,)


        ],

      );
        });
  }

}
