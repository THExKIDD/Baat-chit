import 'dart:developer';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:userapp/API/api.dart';
import 'package:userapp/Controllers/controllers.dart';
import 'package:userapp/Global/global.dart';
import 'package:userapp/providers/passProvider.dart';
import 'package:userapp/screens/forgotPassScreen.dart';
import 'package:userapp/screens/main_screen.dart';
import 'package:userapp/screens/register_screen.dart';
import 'package:userapp/utils/dialogs.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey1 = GlobalKey<FormState>();
  late String error1;
  void submit() async{

    if(_formKey1.currentState!.validate())
    {
      await firebaseAuth.signInWithEmailAndPassword(
          email: ControllerAali.loginEmailController.text.trim(),
          password: ControllerAali.loginPasswordController.text.trim()
      ).then((auth) async {
        currentUser = auth.user;
        await Fluttertoast.showToast(msg: 'Logged in Successfully');
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainScreen()));
      }).onError((error,stacktrace){
        print(error.toString());
        Fluttertoast.showToast(msg: 'error');
      });
    }

    ControllerAali.loginEmailController.clear();
    ControllerAali.loginPasswordController.clear();

  }

  googleButton() {
    googleLogin().then((user) async {
      Navigator.pop(context);
      if(user != null){
        log('\n user : ${user.user}');
        log('\n userAdditionalInfo :  ${user.additionalUserInfo}');

        if(await Api.userExists())
          {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MainScreen()));
          }
        else{
          Api.createUser().then((value){
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MainScreen()));
          });
        }


      }
    }).onError((error,stackTrace){
      Fluttertoast.showToast(msg: error.toString());
      print('\n \n ${error.toString()} \n \n \n \n ');
      error1 = error.toString();
    });
  }

   Future<UserCredential?> googleLogin() async{
    try
    {
      ControllerAali.googleLoginCheck = true;
      Dialogs.showProgress(context);
      await InternetAddress.lookup('google.com');
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

      final Credential = GoogleAuthProvider.credential(
          accessToken: googleAuth?.accessToken,
          idToken: googleAuth?.idToken
      );

      return await Api.auth.signInWithCredential(Credential);
    }
        catch(e){
      log('google signIn Error : ${e}');
      Dialogs.showSnackbar(context, 'Check Internet Connection');
      return null;

        }
  }
 @override
  Widget build(BuildContext context) {
    bool darktheme = MediaQuery.of(context).platformBrightness == Brightness.dark;
    final passProvider = Provider.of<PassProvider>(context);
    final size = MediaQuery.of(context).size;







    return GestureDetector(
      onTap: (){
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
              'Login',style: TextStyle(
          fontSize: 35,
          fontFamily: 'bebe',
          ),
          ),
          centerTitle: true,
          backgroundColor: Colors.purple.shade50,
        ),
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage(
                    'lib/images/background.webp'
                ),
              fit: BoxFit.fill,
            )
          ),
          child: Align(
            alignment: Alignment.center,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                child: Form(
                  key: _formKey1,
                  child: Column(
                    children: [
/*
                      TextFormField(
                        style: TextStyle(
                          color: Colors.white
                        ),

                        inputFormatters: [
                          LengthLimitingTextInputFormatter(50),
                        ],
                        controller: ControllerAali.loginEmailController,
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.white
                            )
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.white,
                            ),
                            borderRadius: BorderRadius.circular(40),
                          ),
                          focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue,width: 2.0)
                          ),
                          labelText: 'Email',
                          hintText: 'Enter your email',
                          hintStyle: TextStyle(
                            color: Colors.white
                          ),
                          labelStyle: TextStyle(
                            color: Colors.white
                          ),
                          prefixIcon: const Icon(Icons.person,color: Colors.white,),
                        ),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (text){
                          if(text == null || text.isEmpty){
                            return "name can't be empty";
                          }
                          if(text.length<2)
                          {
                            return "Please enter a valid name";
                          }
                          if(text.length>49)
                          {
                            return "Name cant be this long";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        style: TextStyle(
                          color: Colors.white
                        ),
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(30),
                        ],
                        controller: ControllerAali.loginPasswordController,
                        obscureText: passProvider.pass,
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.white
                            )
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.white
                            ),
                            borderRadius: BorderRadius.circular(40),
                          ),
                          labelText: 'Password',
                          labelStyle: TextStyle(
                            color: Colors.white
                          ),
                          hintStyle: TextStyle(
                            color: Colors.white
                          ),
                          hintText: 'Enter your password',
                          prefixIcon: const Icon(Icons.lock,color: Colors.white,),
                          suffixIcon: InkWell(
                            child: IconButton(onPressed: (){
                              passProvider.togglepass();
                            }, icon: Icon(passProvider.pass ? Icons.visibility_off : Icons.visibility),color: Colors.white,),
                          ),
                        ),
                      ),*/
                      /*const SizedBox(height: 20,),
                      Container(
                        height: 40,
                        width: double.infinity,
                        child: ElevatedButton(onPressed: (){
                          log('pressed');

                        },
                            child: const Text("Login",
                              style: TextStyle(
                                color: Colors.blue,
                              ) ,
                            )
                        ),
                      ),
                      const SizedBox(height: 60,),
*/
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          /*TextButton(onPressed: (){
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const RegisterScreen()));
                          },
                              child: const Text(
                                  "Don't have an account?",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12
                              ),
                              )
                          ),*/
                          // const SizedBox(height: 20,),
                          // TextButton(onPressed: (){
                          //   Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Forgotpassscreen()));
                          // },
                          //     child: const Text("Forgot Password?",
                          //       style: TextStyle(
                          //         color: Colors.white,
                          //         fontSize: 12
                          //       ),

                             // )
                         // ),
                        ],
                      ),

                      ElevatedButton(
                          onPressed: (){
                            googleButton();
                          },
                          child: Text('Login with Google',
                            style: TextStyle(
                                color: Colors.blueAccent
                            ),
                          )
                      )


                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
