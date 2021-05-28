import 'package:app1/Screens/Companies.dart';
import 'package:app1/Services/crudUser.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Positions extends StatefulWidget {
  final sid;

  Positions(this.sid);

  @override
  _PositionsState createState() => _PositionsState();
}

class _PositionsState extends State<Positions> {

  // String this.widget.sid=this.widget.sid;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }

  void _showmodal() {
    showDialog(
        context: context,
        builder: (context) {
          bool isLoading = false;
          final TextEditingController _name = TextEditingController();
          final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(32.0))),
            contentPadding: EdgeInsets.only(top: 10.0),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(primary: Color(0xffa45c6c)),
                child: Text('Add Position'),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    setState(() {
                      isLoading = true;
                    });

                    try {
                      await addPosition(
                              this.widget.sid, _name.text)
                          .then((value) {
                        setState(() {
                          isLoading = false;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            duration: const Duration(seconds: 5),
                            content: Text('Position added successfully'),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                            shape: StadiumBorder(),
                          ),
                        );
                      });
                    } catch (e) {
                      setState(() {
                        isLoading = false;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          duration: const Duration(seconds: 3),
                          content: Text(e.toString()),
                          backgroundColor: Colors.red,
                          behavior: SnackBarBehavior.floating,
                          shape: StadiumBorder(),
                        ),
                      );
                    }
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
            content: isLoading
                ? SpinKitSquareCircle(
                    color: Colors.blue.withOpacity(0.6),
                    size: 50.0,
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                          height: 90,
                          padding: EdgeInsets.only(top: 20),
                          child: Text(
                            "Enter the position ",
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor),
                          )),
                      Container(
                        height: 110,
                        child: Form(
                            key: _formKey,
                            child: Container(
                                child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: TextFormField(
                                    controller: _name,
                                    decoration: const InputDecoration(
                                      labelText: 'Name',
                                      border: OutlineInputBorder(
                                        borderRadius: const BorderRadius.all(
                                          const Radius.circular(30.0),
                                        ),
                                      ),
                                    ),
                                    validator: (String? value) {
                                      if (value!.isEmpty)
                                        return 'Please enter the position name';
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ))),
                      ),
                    ],
                  ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Positions'),
          actions: [
            TextButton(
                style:TextButton.styleFrom(primary: Colors.black),
                onPressed: () {
                  _showmodal();
                },
                child: Icon(Icons.add_moderator))
          ],
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: positions
              .doc(this.widget.sid)
              .collection('poses')
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Text('Something went wrong,you may be not authenticated');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              SpinKitSquareCircle(
                color: Colors.blue.withOpacity(0.6),
                size: 50.0,
              );
            }
            if (snapshot.data == null) {
              return Text('No snapshot');
            }

            return new ListView(
                children: snapshot.data!.docs.map((DocumentSnapshot document) {
                  return InkWell(
                    child: new ListTile(
                      trailing: TextButton(
                        style: TextButton.styleFrom(primary: Color(0xffa45c6c)),
                        onPressed:() async {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(32.0))),
                                  contentPadding: EdgeInsets.only(top: 10.0),
                                  actions: [
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(primary: Color(0xffa45c6c)),
                                      child: Text('Delete Position'),
                                      onPressed: () async {
                                        await deletePosition(this.widget.sid,document.id).then((value){
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              duration: const Duration(seconds: 5),
                                              content: Text('Position deleted successfully'),
                                              backgroundColor: Colors.orangeAccent,
                                              behavior: SnackBarBehavior.floating,
                                              shape: StadiumBorder(),
                                            ),
                                          );
                                          Navigator.of(context).pop();
                                        }
                                        );
                                      },
                                    ),
                                  ],
                                  content: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Text('Are you sure you want to delete the position '+document.data()['position']),
                                  ) ,

                                );
                              });
                        },
                        child: Icon(Icons.delete, color: Colors.red,),
                      ),
                      title: new Text(
                        document.id,
                        style: TextStyle(color: Colors.black),
                      ),
                      subtitle: new Text(document.data()['position'].toString()),
                    ),
                    onTap:(){
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => UsersForSuper(this.widget.sid, document.data()['position'].toString()),
                      ));
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(builder: (context) => UserAdd(pos: document.data()['position'].toString() ,)),
                      // );
                    },
                  );
                }).toList(),
              );

          },
        ));
  }
}
