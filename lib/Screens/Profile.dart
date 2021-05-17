import 'package:app1/Components/loading.dart';
import 'package:app1/Screens/Login.dart';
import 'package:app1/Services/crudUser.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
  final user_id;

  @override
  _ProfileState createState() => _ProfileState();

  Profile(this.user_id);
}

class _ProfileState extends State<Profile> {
  bool edit = false, isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Profile'),
        ),
        body: StreamBuilder<DocumentSnapshot>(

          stream: users.doc(this.widget.user_id).snapshots(includeMetadataChanges: true),
          builder:
              (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {


            GlobalKey<FormState> _formKey = GlobalKey<FormState>();
            TextEditingController _email = TextEditingController(text:snapshot.data!.data()['email'].toString());
            TextEditingController _name = TextEditingController(text:snapshot.data!.data()['user_name'].toString());
            TextEditingController _phone = TextEditingController(text:snapshot.data!.data()['phone'].toString());
            TextEditingController _type = TextEditingController(text:snapshot.data!.data()['type'].toString());

            if (snapshot.hasError) {
              return Text('Something went wrong, you may be not authenticated');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: Loading());
            }

            return new Form(
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
                          'Update Profile',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(12),
                        child: !edit?Text(_name.text):TextFormField(
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
                        child: !edit?Text(_email.text):TextFormField(
                           enabled: false,
                          controller: _email,
                          decoration: const InputDecoration(labelText: 'Email',border: OutlineInputBorder(),),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: !edit?Text(_phone.text):TextFormField(
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
                        padding: const EdgeInsets.all(12.0),
                        child: !edit?Text(_type.text):TextFormField(
                          // enabled: false,
                          controller: _type,
                          decoration: const InputDecoration(labelText: 'Type',border: OutlineInputBorder(),),
                          //obscureText: true,
                        ),
                      ),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: !edit?null:ElevatedButton(
                            child: Text('Reset Password'),
                            onPressed: (){
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => ForgotPass()),
                              );
                            },
                          )
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.only(top: 16),
                        alignment: Alignment.center,
                        child: ElevatedButton(
                          child: Text('Update Profile'),
                          onPressed: () async {

                            if(edit){
                              if (_formKey.currentState!.validate()) {
                                try{
                                  setState(() {
                                    edit = !edit;
                                    isLoading = false;
                                  });

                                  updateProfile(this.widget.user_id,_name.text,_phone.text);

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      duration: const Duration(seconds: 5),
                                      content: Text('Profile updated successfully'),
                                      backgroundColor: Colors.green,
                                      behavior: SnackBarBehavior.floating,
                                      shape: StadiumBorder(),
                                    ),
                                  );
                                  // Navigator.of(context).pop();
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
                            }else{
                              setState(() {
                                edit=!edit;
                              });
                            }
                            },
                        ),
                      ),
                    ],
                  ),
                ),
              ), );
          },
        ));
  }
}


class CompanyProfile extends StatefulWidget {
  final user_id;

  @override
  _CompanyProfileState createState() => _CompanyProfileState();

  CompanyProfile(this.user_id);
}

class _CompanyProfileState extends State<CompanyProfile> {
  bool edit = false, isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Company Information'),
        ),
        body: StreamBuilder<DocumentSnapshot>(

          stream: users.doc(this.widget.user_id).snapshots(includeMetadataChanges: true),
          builder:
              (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {


            GlobalKey<FormState> _formKey = GlobalKey<FormState>();
            TextEditingController _email = TextEditingController(text:snapshot.data!.data()['email'].toString());
            TextEditingController _name = TextEditingController(text:snapshot.data!.data()['user_name'].toString());
            TextEditingController _phone = TextEditingController(text:snapshot.data!.data()['phone'].toString());
            TextEditingController _type = TextEditingController(text:snapshot.data!.data()['type'].toString());

            if (snapshot.hasError) {
              return Text('Something went wrong, you may be not authenticated');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: Loading());
            }

            return new Form(
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
                          'Update Profile',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(12),
                        child: !edit?Text(_name.text):TextFormField(
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
                        child: !edit?Text(_email.text):TextFormField(
                          enabled: false,
                          controller: _email,
                          decoration: const InputDecoration(labelText: 'Email',border: OutlineInputBorder(),),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: !edit?Text(_phone.text):TextFormField(
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
                        padding: const EdgeInsets.all(12.0),
                        child: !edit?Text(_type.text):TextFormField(
                          enabled: false,
                          controller: _type,
                          decoration: const InputDecoration(labelText: 'Type',border: OutlineInputBorder(),),
                          //obscureText: true,
                        ),
                      ),
                      Center(
                        child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: !edit?null:ElevatedButton(
                              child: Text('Reset Password'),
                              onPressed: (){
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => ForgotPass()),
                                );
                              },
                            )
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.only(top: 16),
                        alignment: Alignment.center,
                        child: ElevatedButton(
                          child: Text('Update Company information'),
                          onPressed: () async {

                            if(edit){
                              if (_formKey.currentState!.validate()) {
                                try{
                                  setState(() {
                                    edit = !edit;
                                    isLoading = false;
                                  });

                                  updateCompanyProfile(this.widget.user_id,_name.text,_phone.text,_type.text);

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      duration: const Duration(seconds: 5),
                                      content: Text('Profile updated successfully'),
                                      backgroundColor: Colors.green,
                                      behavior: SnackBarBehavior.floating,
                                      shape: StadiumBorder(),
                                    ),
                                  );
                                  // Navigator.of(context).pop();
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
                            }else{
                              setState(() {
                                edit=!edit;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ), );
          },
        ));
  }
}
