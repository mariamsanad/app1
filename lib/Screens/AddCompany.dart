import 'package:app1/Components/loading.dart';
import 'package:app1/Screens/Login.dart';
import 'package:app1/Services/User.dart';
import 'package:app1/Services/crudUser.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CompanyAdd extends StatefulWidget {
  @override
  _CompanyAddState createState() => _CompanyAddState();
}

class _CompanyAddState extends State<CompanyAdd> {

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _cpr = TextEditingController();
  final TextEditingController _address = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _type = TextEditingController();

  @override
  Widget build(BuildContext context) {
   // final active_user = Provider.of<user>(context);

    if(FirebaseAuth.instance.currentUser== null){
      return SignIn(null);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Add a Company"),
      ),
      body: isLoading?Loading():Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      alignment: Alignment.center,
                      child: const Text(
                        'Add a company',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(12),
                      child: TextFormField(
                        controller: _name,
                        decoration: const InputDecoration(
                          labelText: 'Name',border: OutlineInputBorder(),

                        ),
                        validator: (String? value) {
                          if (value!.isEmpty) return 'Please enter the company name';
                          return null;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: TextFormField(
                        controller: _email,
                        decoration: const InputDecoration(labelText: 'Email',border: OutlineInputBorder(),),
                        validator: (String? value) {
                          if (value!.isEmpty) return 'Please enter owner\'s email!';
                          return null;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: TextFormField(
                        controller: _cpr,
                        decoration: const InputDecoration(labelText: 'Admin\'s cpr(password he can change it)',border: OutlineInputBorder(),),
                        validator: (String? value) {
                          return RegExp(r'^[0-9]{9}$').hasMatch(value!)?null:"enter a valid cpr";
                        },
                        //obscureText: true,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: TextFormField(
                        controller: _address,
                        decoration: const InputDecoration(labelText: 'address',border: OutlineInputBorder(),),
                        validator: (String? value) {
                          if (value!.isEmpty) return 'Please enter the address';
                          return null;
                        },
                        //obscureText: true,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: TextFormField(
                        controller: _phone,
                        decoration: const InputDecoration(labelText: 'phone',border: OutlineInputBorder(),),
                        validator: (String? value) {
                          if (value!.isEmpty) return 'Please enter the phone number';
                          return null;
                        },
                        //obscureText: true,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: _type,
                        decoration: const InputDecoration(labelText: 'Company Type',border: OutlineInputBorder(),),
                        validator: (String? value) {
                          if (value!.isEmpty) return 'Please enter the company type';
                          return null;
                        },
                        //obscureText: true,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(top: 16),
                      alignment: Alignment.center,
                      child: ElevatedButton(
                        child: Text('Add'),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {

                            setState(() {
                              isLoading = true;
                            });
                            try{
                              await addCompany(_name.text, _type.text, _address.text,_cpr.text,_email.text,_phone.text).then((value) {
                                setState(() {
                                  isLoading = false;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    duration: const Duration(seconds: 5),
                                    content: Text('Company added successfully'),
                                    backgroundColor: Colors.green,
                                    behavior: SnackBarBehavior.floating,
                                    shape: StadiumBorder(),
                                  ),
                                );

                                // Navigator.of(context).pop();
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
                      ),
                    ),
                  ],
                ),
              ),
            ))

    );
  }

  @override
  void dispose() {
    _email.dispose();
    _cpr.dispose();
    _address.dispose();
    _phone.dispose();
    _name.dispose();
    _type.dispose();
    super.dispose();
  }


}
