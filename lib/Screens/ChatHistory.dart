import 'package:flutter/material.dart';
import 'package:app1/Services/CRUD.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app1/Components/loading.dart';
import 'package:app1/Screens/ChatRoomDr.dart';

class ChatHistory extends StatefulWidget {
  final userid;

  ChatHistory(this.userid);

  @override
  _ChatHistoryState createState() => _ChatHistoryState();
}

class _ChatHistoryState extends State<ChatHistory> {
//check
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Questions'),
      ),
      body: Container(
          child: StreamBuilder<QuerySnapshot>(
            stream: chats
                .where('drid', isEqualTo: FirebaseAuth.instance.currentUser.uid)
                .snapshots(),
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return Text('Something went wrong,you may be not authenticated');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Loading();
              }
              return snapshot.hasData
                  ? ListView(
                physics: BouncingScrollPhysics(),
                padding: EdgeInsets.only(top: 10, bottom: 10),
                children:
                snapshot.data!.docs.map((DocumentSnapshot document) {
                  return Container(
                      padding: EdgeInsets.only(
                          left: 14, right: 14, top: 10, bottom: 10),
                      child: Container(
                          decoration: BoxDecoration(
                            //borderRadius: BorderRadius.circular(50),
                            color: Colors.grey.shade200,
                          ),
                          padding: EdgeInsets.all(16),
                          child: FutureBuilder(
                            future: getUserName(document.data()['userid']),
                            builder: (context, snapshot) {
                              return GestureDetector(
                                  child: new Text(snapshot.data.toString()),
                                  onTap: () {
                                    Navigator.of(context).push(MaterialPageRoute(
                                        builder: (context) => ChatRoomDr(
                                          document.data()['userid'],
                                        )));
                                    updateChat(document.data()['userid']);
                                  });
                            }
                          )));
                }).toList(),
              )
                  : Container(
                child: Text('No New Queastions'),
              );
            },
          )),
    );
  }
}