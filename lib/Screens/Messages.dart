import 'package:app1/Components/loading.dart';
import 'package:flutter/material.dart';
import 'package:app1/Services/crudUser.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Messages extends StatefulWidget {
  final userid;
  @override
  _MessagesState createState() => _MessagesState();
  Messages(this.userid);
}

class _MessagesState extends State<Messages> {
  @override

  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: StreamBuilder<QuerySnapshot>(
          stream: chats.doc(this.widget.userid)
              .collection('messages').orderBy(
              'date', descending: false).snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {

            if (snapshot.hasError) {
              return Text('Something went wrong,you may be not authenticated');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Loading();
            }

            return new ListView(
              physics: BouncingScrollPhysics(),
              padding: EdgeInsets.only(top: 10,bottom: 10),
              children: snapshot.data!.docs.map((DocumentSnapshot document) {
                return Container(
                    padding: EdgeInsets.only(left: 14,right: 14,top: 10,bottom: 10),
                    child: Align(
                        alignment: (FirebaseAuth.instance.currentUser.uid == document.data()['userid']?Alignment.topRight:Alignment.topLeft),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: (FirebaseAuth.instance.currentUser.uid == document.data()['userid']?Color(0xffa45c6c):Colors.grey.shade200),
                          ),
                          padding: EdgeInsets.all(16),
                          child: new Text(
                            document.data()['message'].toString(),
                            style: TextStyle(color: Colors.black),
                          ),
                        )
                    )
                );
              }).toList(),
            );
          },
        ),
      ),

    );
  }
}