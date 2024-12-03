import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:provider/provider.dart';
import 'package:userapp/Controllers/controllers.dart';
import 'package:userapp/Global/global.dart';
import 'package:userapp/providers/passProvider.dart';
import 'package:userapp/screens/login_screen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:userapp/screens/main_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  @override

  void _submit() async{
    if(_formkey.currentState!.validate())
    {
      await firebaseAuth.createUserWithEmailAndPassword(
          email: ControllerAali.emailController.text.trim(),
          password: ControllerAali.passwordController.text.trim()
      ).then((auth) async{
        currentUser = auth.user;
        if(currentUser != null) {
          Map usermap = {
            'id': currentUser!.uid,
            'name': ControllerAali.nameController.text.trim(),
            'email': ControllerAali.emailController.text.trim(),
            'phone': ControllerAali.phoneController.text.trim(),

          };

          FirebaseFirestore _fireStore = FirebaseFirestore.instance;


          DatabaseReference userRef = FirebaseDatabase.instance.ref().child(
              'users').child(currentUser!.uid);

          try {
            // Create the "users" node if it doesn't exist


            // Write data to the "users" node

            userRef.child(currentUser!.uid).set(usermap);
          } catch (e) {
            print('Error writing to Firebase: $e');
          }


          await Fluttertoast.showToast(msg: 'Successfully Registered')
              .catchError((error) {
            return Fluttertoast.showToast(msg: '$error');
          });

          await _fireStore.collection('users').doc(auth.user!.uid).set({
            'name' : ControllerAali.nameController.text.trim(),
            'email' : ControllerAali.emailController.text.trim(),
            'status' : 'offline',
          });



          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => MainScreen()));
        }
          });
    }
    else{
      Fluttertoast.showToast(msg: 'not all fields are valid');
    }

  }

  final _formkey = GlobalKey<FormState>();


  @override
  Widget build(BuildContext context) {
    final passProvider = Provider.of<PassProvider>(context);
    bool darktheme = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return GestureDetector(
      onTap: (){
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
              'Register',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 20,
            ),

          ),
          centerTitle: true,
          backgroundColor: Colors.black,
        ),
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('lib/images/dark_car.jpg'),
              fit: BoxFit.fill,
              opacity: 0.3,
            ),
          ),
          child: ListView(
            padding: const EdgeInsets.all(0),
            children: [
              Column(
                children: [


                  Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Form(
                      key: _formkey,
                      child: Column(
                        children: [
                          TextFormField(
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(50),
                            ],
                            controller: ControllerAali.nameController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(40),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.blue,width: 2.0),
                                borderRadius: BorderRadius.circular(40),
                              ),
                              labelText: 'Username',
                              hintText: 'Enter your username',
                              prefixIcon: Icon(Icons.person),
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
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(50),
                            ],
                            controller: ControllerAali.emailController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(40),
                              ),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.blue,width: 2.0),
                                borderRadius: BorderRadius.circular(40),
                              ),
                              labelText: 'Email',
                              hintText: 'Enter your email',
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            validator: (text){
                              if(text == null || text.isEmpty){
                                return "Email can't be empty";
                              }
                              if(EmailValidator.validate(text) == true)
                                {
                                  return null;
                                }

                              if(text.length<2)
                              {
                                return "Please enter a valid email";
                              }
                              if(text.length>80)
                              {
                                return "Email cant be this long";
                              }
                              return null;
                            },

                          ),
                          SizedBox(height: 10),
                          IntlPhoneField(
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(40),
                              ),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.blue,width: 2.0),
                                borderRadius: BorderRadius.circular(40),
                              ),
                              labelText: 'Phone Number',
                              hintText: 'Enter your Phone Number',
                              prefixIcon: Icon(Icons.phone),
                            ),
                            initialCountryCode: 'IN',
                            showCountryFlag: false,
                            dropdownIcon: Icon(Icons.arrow_drop_down_circle),
                            onChanged: (phone) {

                              setState(() {

                                ControllerAali.phoneController.text = phone.completeNumber;

                              });
                            },
                          ),
                          SizedBox(height: 10),// add some space between fields
                          TextFormField(
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(30),
                            ],
                            controller: ControllerAali.passwordController,
                            obscureText: passProvider.pass,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(40),
                              ),
                              labelText: 'Password',
                              hintText: 'Enter your password',
                              prefixIcon: Icon(Icons.lock),
                              suffixIcon: InkWell(
                                child: IconButton(onPressed: (){
                                  passProvider.togglepass();
                                }, icon: Icon(passProvider.pass ? Icons.visibility_off : Icons.visibility)),
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          TextFormField(
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(30),
                            ],
                            controller: ControllerAali.confirmController,
                            obscureText: passProvider.pass2, // for password field
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(40),
                              ),
                              labelText: 'Confirm Password',
                              hintText: 'Enter your password',
                              prefixIcon: Icon(Icons.lock),
                              suffixIcon: InkWell(
                                child: IconButton(onPressed: (){
                                  passProvider.togglepass2();
                                }, icon: Icon(passProvider.pass2 ? Icons.visibility_off : Icons.visibility)),
                              ),
                            ),
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            validator: (text){
                              if(text == null || text.isEmpty){
                                return "Password can't be empty";
                              }
                              if(text != ControllerAali.passwordController.text)
                                {
                                  return "Password doesnt match";
                                }
                              if(text.length<2)
                              {
                                return "Please enter a valid Address";
                              }
                              if(text.length>200)
                              {
                                return "Address cant be this long";
                              }
                              return null;
                            },

                          ),
                          const SizedBox(height: 20),
                          Container(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                foregroundColor: Colors.purple,
                              ),
                              onPressed: () {
                                _submit();
                                print('Form submitted');
                              },
                              child: const Text(
                                  'Submit',
                                style: TextStyle(
                                  fontFamily: 'bebe',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 30
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 10,),
                          TextButton(onPressed: () {
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen()));
                          },
                              child: Text('Already have an account \n                   login')
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ) ,
      ),
    );
  }
}
