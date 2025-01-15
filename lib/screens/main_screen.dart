
import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:userapp/API/api.dart';
import 'package:userapp/models/chat_user.dart';
import 'package:userapp/screens/profile_screen.dart';
import 'package:userapp/utils/chat_card.dart';
import 'package:userapp/utils/dialogs.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});


  @override

  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
//storing all users
  List<ChatUser> list = [];

  //storing searched items
 final List<ChatUser> _searchList = [];

 //for storing search status
  bool _isSearching = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Api.getSelfInfo();



    // for updating last active according to app lifecycle
    SystemChannels.lifecycle.setMessageHandler((message){


      log('Message : $message');

      if(Api.auth.currentUser != null) {
        if (message!.contains('resume')) {
          Api.updateActiveStatus(true);
        }
        if (message.contains('pause') || message.contains('detached')) {
          Api.updateActiveStatus(false);
          log(' \n updated the status \n');
        }
      }
      return Future.value(message);
    });
  }

  bool isLoading = false;
  Map <String,dynamic>? userMap;

  /*void forSearch () async {
    FirebaseFirestore _fireStore = FirebaseFirestore.instance;
    setState(() {
      isLoading = true;
    });

    try
    {
      await _fireStore.collection('users').where('email',isEqualTo: ControllerAali.searchController.text.trim())
          .get()
          .then((value){

        setState(() {
          userMap = value.docs[0].data();
          isLoading = false;
        });
        print(userMap);
      });



    }
    catch(e){
      print(e.toString());
      Fluttertoast.showToast(msg: 'not found');
    }


  }*/


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child:PopScope(
        canPop: !_isSearching, // Control whether the route can be popped
        onPopInvokedWithResult: (didPop,Object? result) async {
          if (_isSearching && !didPop) { // Only handle if _isSearching is true and the route wasn't popped
            setState(() {
              _isSearching = !_isSearching;
            });
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: _isSearching ?
                TextField(
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Name, Email, ...',
                  ),
                  autofocus: true,
                  style: const TextStyle(
                    fontSize: 17,
                    letterSpacing: 0.5
                  ),
                  onChanged: (val) {

                    _searchList.clear();
                    //search logic

                    for(var i in list){
                      if(i.name.toLowerCase().contains(val.toLowerCase()) ||
                          i.email.substring(i.email.indexOf('@')-1).toLowerCase().contains(val.toLowerCase()))
                      {

                        _searchList.add(i);
                        setState(() {
                          _searchList;
                        });

                      }
                    }

                  },
                )
                : const Text(
              'Baat Chit',
              style: TextStyle(
                fontFamily: 'bebe',
                fontWeight: FontWeight.bold,
                fontSize: 40,
              ),
            ),
            actions: [
              IconButton(
                  onPressed: (){

                    setState(() {
                      _isSearching = !_isSearching;
                    });
                  },
                  icon: Icon(
                      _isSearching ?
                      CupertinoIcons.clear_circled_solid
                          : Icons.search)
              ),
              /*IconButton(
                  onPressed: () async{
                    await Api.auth.signOut();
                   ControllerAali.googleLoginCheck ?  await GoogleSignIn().signOut() : null;

                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen()));

                  },
                  icon: Icon(Icons.logout)
              ),*/
              IconButton(
                  onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileScreen(user: Api.me)));
                  },
                  icon: const Icon(CupertinoIcons.ellipsis_vertical)
              ),

            ],
          ),



          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: FloatingActionButton(
                onPressed: (){
                  _addChatUserDialog();
                },
              child: const Icon(Icons.add),

            ),
          ),


          body: StreamBuilder(
              stream: Api.getMyUsers(),
              builder: (context,snapshot){

                switch(snapshot.connectionState)
                {
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    return const Center(child: CircularProgressIndicator());

                  case ConnectionState.active:
                  case ConnectionState.done:
                    return StreamBuilder(
                        stream: Api.getAllUsers(snapshot.data?.docs.map((e) => e.id).toList() ?? []),
                        builder: (context, snapshot) {

                          switch(snapshot.connectionState)
                          {
                            case ConnectionState.waiting:
                            case ConnectionState.none:
                              // return const Center(child: CircularProgressIndicator());

                            case ConnectionState.active:
                            case ConnectionState.done:
                              final data = snapshot.data?.docs;
                              list = data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];
                          }


                          if(list.isNotEmpty)
                          {
                            return ListView.builder(itemBuilder: (context,index){

                              return ChatCard(user: _isSearching ? _searchList[index] :list[index]);
                            },
                              itemCount: _isSearching ? _searchList.length
                                  :list.length,
                              padding: EdgeInsets.only(top: size.height * 0.02),
                              physics: const BouncingScrollPhysics(),

                            );
                          }
                          else
                          {
                            return const Center(
                              child: Text('No Connections Found'),
                            );
                          }
                        }
                    );

                  }
              },
          )
        ),
      ),
    );
  }

  void _addChatUserDialog() {
    String email = '';

    showDialog(
        context: context,
        builder: (_) => AlertDialog(
          contentPadding: const EdgeInsets.only(
              left: 24, right: 24, top: 20, bottom: 10),

          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(15))),

          //title
          title: const Row(
            children: [
              Icon(
                Icons.person_add,
                color: Colors.blue,
                size: 28,
              ),
              Text('  Add User')
            ],
          ),

          //content
          content: TextFormField(
            maxLines: null,
            onChanged: (value) => email = value,
            decoration: const InputDecoration(
                hintText: 'Email Id',
                prefixIcon: Icon(Icons.email, color: Colors.blue),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15)))),
          ),

          //actions
          actions: [
            //cancel button
            MaterialButton(
                onPressed: () {
                  //hide alert dialog
                  Navigator.pop(context);
                },
                child: const Text('Cancel',
                    style: TextStyle(color: Colors.blue, fontSize: 16))),

            //add button
            MaterialButton(
                onPressed: () async {
                  //hide alert dialog
                  Navigator.pop(context);
                  if (email.trim().isNotEmpty) {
                    await Api.addChatUser(email).then((value) {
                      if (!value) {
                        Dialogs.showSnackbar(
                            context, 'User does not Exists!');
                      }
                    });
                  }
                },
                child: const Text(
                  'Add',
                  style: TextStyle(color: Colors.blue, fontSize: 16),
                ))
          ],
        ));
  }

}
