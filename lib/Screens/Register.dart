import 'package:app1/Components/loading.dart';
import 'package:app1/Services/crudUser.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/button_builder.dart';

Auth methods = new Auth();
/// Entrypoint example for registering via Email/Password.
class Register extends StatefulWidget {
  /// The page title.
  final String title = 'Registration';

  @override
  State<StatefulWidget> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _username = TextEditingController();
  final TextEditingController _phone = TextEditingController();

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: isLoading?Loading():Form(
          key: _formKey,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: TextFormField(
                      controller: _username,
                      decoration: const InputDecoration(labelText: 'Username',border: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(
                          const Radius.circular(25.0),
                        ),
                      ),),
                      validator: (String? value) {
                        if (value!.isEmpty) {
                          return 'Please enter your username';
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Email',border: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(
                          const Radius.circular(25.0),
                        ),
                      ),),
                      validator: (String? value) {
                        if (value!.isEmpty) {
                          return 'Please enter some text';
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: TextFormField(
                      controller: _phone,
                      decoration: const InputDecoration(labelText: 'Phone',border: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(
                          const Radius.circular(25.0),
                        ),
                      ),),
                      validator: (String? value) {
                        return RegExp(r'^[0-9]{8}$').hasMatch(value!)?null:"enter a valid phone number";
                        },
                      obscureText: true,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(labelText: 'Password',border: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(
                          const Radius.circular(25.0),
                        ),
                      ),),
                      validator: (String? value) {
                        return RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{6,}$').hasMatch(value!)?null:"make sure to have a minimum of 6 charachters(at least one number and one letter)";
                      },
                      obscureText: true,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: TextFormField(
                      decoration: const InputDecoration(labelText: 'Confirm Password',border: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(
                          const Radius.circular(25.0),
                        ),
                      ),),
                      validator: (String? value) {
                        if(value!=_passwordController.text){
                          return 'passwords are not the same';
                        }
                      },
                      obscureText: true,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    alignment: Alignment.center,
                    child: SignInButtonBuilder(
                      icon: Icons.person_add,
                      backgroundColor: Colors.blueGrey,
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            isLoading = true;
                          });
                          try{
                            await methods.register(_emailController.text,_passwordController.text,'normal',_username.text,_phone.text).then((value){
                              setState(() {
                                isLoading = false;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  duration: const Duration(seconds: 10),
                                  content: Text("Successfully registered"),
                                  backgroundColor: Colors.green,
                                  behavior: SnackBarBehavior.floating,
                                  shape: StadiumBorder(),
                                ),
                              );
                              Navigator.of(context).pushNamed("homepage");
                            });

                          }on FirebaseAuthException catch(e){

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                duration: const Duration(seconds: 10),
                                content: Text(e.message),
                                backgroundColor: Colors.red,
                                behavior: SnackBarBehavior.floating,
                                shape: StadiumBorder(),
                              ),
                            );

                          }
                          setState(() {
                            isLoading = false;
                          });
                        }
                      },
                      text: 'Register',
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(30.0))) ,
                    ),
                  ),
                  
                ],
              ),
            ),
          )),
    );
  }

  @override
  void dispose() {
// Clean up the controller when the Widget is disposed
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

// Example code for registration.

}
