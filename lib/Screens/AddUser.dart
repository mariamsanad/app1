import 'package:app1/Components/loading.dart';
import 'package:app1/Services/crudUser.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';


class UserAdd extends StatefulWidget {
  final String pos,sid;

  const UserAdd({Key? key, required this.pos,required this.sid}) : super(key: key);

  @override
  _UserAddState createState() => _UserAddState();
}


class _UserAddState extends State<UserAdd> {

  bool isLoading = false;
  bool vac = false;
  String comId='';
  String userId=FirebaseAuth.instance.currentUser.uid;


  @override
  initState() {
    // TODO: implement initState
    super.initState();
    getCompanyid(this.widget.sid).then((c) {
      setState(() {
        comId = c;
      });
    });
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _cpr = TextEditingController();
  final TextEditingController _address = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _position = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Add a User to "+this.widget.pos),
        ),
        body: isLoading?SpinKitSquareCircle(
          color: Colors.blue.withOpacity(0.6),
          size: 50.0,
        ):Form(
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
                        'Add a User',
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
                          if (value!.isEmpty) return 'Please enter the user name';
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
                          if (value!.isEmpty) return 'Please enter user\'s email!';
                          return null;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: TextFormField(
                        controller: _cpr,
                        decoration: const InputDecoration(labelText: 'user\'s cpr(password he can change it)',border: OutlineInputBorder(),),
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
                      CheckboxListTile(
                        title: Text('Vaccined'),
                        value: vac, onChanged: (v){
                        setState(() {
                          vac = v!;
                        });
                      },),
                    Container(
                      padding: const EdgeInsets.only(top: 16),
                      alignment: Alignment.center,
                      child: ElevatedButton(
                        child: Text('Add user'),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              isLoading = true;
                            });

                            try{

                              print('the company id is '+comId);
                              await UserAdd1(comId,this.widget.sid,_name.text, _email.text, _cpr.text,_phone.text,this.widget.pos,vac).then((value){
                                setState(() {
                                  isLoading = false;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    duration: const Duration(seconds: 5),
                                    content: Text('User added successfully'),
                                    backgroundColor: Colors.green,
                                    behavior: SnackBarBehavior.floating,
                                    shape: StadiumBorder(),
                                  ),
                                );

                                Navigator.of(context).pop();
                              });

                               Loading();


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
            )));
  }

  @override
  void dispose() {
    _email.dispose();
    _cpr.dispose();
    _address.dispose();
    _phone.dispose();
    _name.dispose();
    _position.dispose();
    super.dispose();
  }

}
