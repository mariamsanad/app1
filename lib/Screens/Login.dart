// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// @dart=2.9

// ignore_for_file: deprecated_member_use

import 'package:app1/Components/loading.dart';

import 'package:app1/Services/crudUser.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';

bool isLoading = false;

class SignIn extends StatefulWidget {
  final Function togg;

  final String title = 'Sign In';

  @override
  State<StatefulWidget> createState() => _SignInState();

  SignIn(this.togg);
}

class _SignInState extends State<SignIn> {


  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //key: scaffoldKey,
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: isLoading?Loading():SingleChildScrollView(child: _EmailPasswordForm()));


  }

}

class _EmailPasswordForm extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _EmailPasswordFormState();
}

Auth methods = new Auth();


class _EmailPasswordFormState extends State<_EmailPasswordForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child:  Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  alignment: Alignment.center,
                  child: const Text(
                    'Sign in with email and password',
                    style: TextStyle(fontWeight: FontWeight.bold),
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
                    validator: (String value) {
                      if (value.isEmpty) return 'Please enter some text';
                      return null;
                    },
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
                    validator: (String value) {

                      if (value.isEmpty) return 'Please enter password';
                      return null;
                    },
                    obscureText: true,
                  ),
                ),
                Row(
                  children: [
                    TextButton(onPressed: (){
                      Navigator.of(context).pushNamed('reset');
                    }, child: Text('Forgot password?'))
                  ],
                ),
                Container(
                  padding: const EdgeInsets.only(top: 2),
                  alignment: Alignment.center,
                  child: SignInButton(
                    //shape: ,
                    Buttons.Email,
                    text: 'Sign In',
                    onPressed: () async {
                      if (_formKey.currentState.validate()) {

                        setState(() {
                          isLoading = true;
                        });

                        try{
                          await methods.signInNormal(_emailController.text,_passwordController.text).then((value){
                            setState(() {
                              isLoading = false;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                duration: const Duration(seconds: 10),
                                content: Text('Successfully signed in'),
                                backgroundColor: Colors.green,
                                behavior: SnackBarBehavior.floating,
                                shape: StadiumBorder(),
                              ),
                            );
                            Navigator.of(context).pop();
                          });

                        }on FirebaseAuthException catch(e){

                          setState(() {
                            isLoading = false;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              duration: const Duration(seconds: 3),
                              content: Text(e.message),
                              backgroundColor: Colors.red,
                              behavior: SnackBarBehavior.floating,
                              shape: StadiumBorder(),
                            ),
                          );

                        }

                      }
                    },
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(30.0))) ,
                  ),
                ),
                Center(
                  child: SignInButton((Buttons.GoogleDark),
                    text: 'Sign In',
                    onPressed: () async {
                      methods.signInWithGoogle().then((value) {
                        String v;

                        setState(() {
                          isLoading = false;
                        });

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            duration: const Duration(seconds: 3),
                            content: Text("Successfully signd in with google"),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                            shape: StadiumBorder(),
                          ),
                        );
                        Navigator.of(context).pop();
                      });
                      //Navigator.pushReplacementNamed(context, 'homepage');
                    },
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(30.0))) ,
                  ),

                )
               ,RichText(
          text: TextSpan(

              children: <TextSpan>[
              TextSpan(text: 'Dont have an account?',style: TextStyle(color: Colors.black)),
          TextSpan(
              text: 'Register',
              style: TextStyle(color: Colors.blue),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  Navigator.pushReplacementNamed(context, "register");
                }),
              ],

            ),
          ),
        ]))));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

}
/*----------------------------------------------------------------------------------------------------------------------*/

class ForgotPass extends StatefulWidget {
  @override
  _ForgotPassState createState() => _ForgotPassState();
}

class _ForgotPassState extends State<ForgotPass> {

   GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reset Password'),
      ),
      body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              child: const Text(
                'Enter your email',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Form(
                key: _formKey,
                child: TextFormField(
                  controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email',border: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(
                        const Radius.circular(25.0),
                      ),
                    ),),
                  validator: (String value) {
                    if (value.isEmpty) return 'Please enter email';
                    return null;
                  },
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.only(top: 16),
              alignment: Alignment.center,
              child: SignInButton(
                Buttons.Email,
                text: 'Send Request',
                onPressed: () async {
    if (_formKey.currentState.validate()) {

                    try{
                      await methods.ResetPassword(_emailController.text).then((value){
                        setState(() {
                          isLoading = false;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            duration: const Duration(seconds: 3),
                            content: Text('Message Sent'),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                            shape: StadiumBorder(),
                          ),
                        );

                        Navigator.of(context).pop();
                      });

                    }on FirebaseAuthException catch(e){

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          duration: const Duration(seconds: 3),
                          content: Text(e.message),
                          backgroundColor: Colors.red,
                          behavior: SnackBarBehavior.floating,
                          shape: StadiumBorder(),
                        ),
                      );

                    }

                  }
                },
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30.0))) ,
              ),
            ),

          ]),
    );
  }
}
