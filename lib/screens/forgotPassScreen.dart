import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:userapp/Controllers/controllers.dart';
import 'package:userapp/Global/global.dart';
import 'package:userapp/screens/login_screen.dart';

class Forgotpassscreen extends StatefulWidget {
  const Forgotpassscreen({super.key});

  @override
  State<Forgotpassscreen> createState() => _ForgotpassscreenState();
}

class _ForgotpassscreenState extends State<Forgotpassscreen> {

  final formkeyforgot = GlobalKey<FormState>();

  void pushed () async{
    if(formkeyforgot.currentState!.validate())
      {
        await firebaseAuth.sendPasswordResetEmail(email: ControllerAali.forgotEmailController.text.trim()).then((value){
          Fluttertoast.showToast(msg: 'We sent you an email to reset your password');
        }).onError((error,stacktrace){
          Fluttertoast.showToast(msg: 'error');
          debugPrint(error.toString());
        });
        
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen()));
      }
    else
      {
        Fluttertoast.showToast(msg: 'fill correct values');
      }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Forgot Password ?',
          style: TextStyle(
            fontFamily: 'bebe',
            fontSize: 50,
            fontWeight: FontWeight.bold
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(image: AssetImage('lib/images/taxiimg.jpg'),
          opacity: 0.3,
            fit: BoxFit.fill,
          )
        ),
        child: Form(
          key: formkeyforgot,
            child: Column(
              children: [
                TextFormField(
                  controller: ControllerAali.forgotEmailController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    hintText: 'Enter Email',
                    labelText: 'Email',
                  ),
                ),
                SizedBox(height: 30,),
                ElevatedButton(onPressed: (){
                  pushed();
                },
                    child: Text('Get Email')
                )
              ],
            )
        ) ,
      ),
    );
  }
}
