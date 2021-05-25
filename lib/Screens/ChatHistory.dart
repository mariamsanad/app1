import 'package:app1/Screens/Messages.dart';
import 'package:flutter/material.dart';
import 'package:app1/Services/crudUser.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:app1/Components/loading.dart';
import 'Messages.dart';
import 'package:app1/Screens/ChatRoomDr.dart';
class ViewQuestions extends StatefulWidget {
  final userid;

  ViewQuestions(this.userid);

  @override
  _ViewQuestionsState createState() => _ViewQuestionsState();

}

class _ViewQuestionsState extends State<ViewQuestions> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Questions'),),
      body: Container(

          child: StreamBuilder<QuerySnapshot>(
            stream: chats.where('drid', isEqualTo: FirebaseAuth.instance.currentUser.uid).snapshots(),
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
                children: snapshot.data!.docs.map((DocumentSnapshot document) {
                  return Container(
                      padding: EdgeInsets.only(left: 14, right: 14, top: 10, bottom: 10),
                      child: Container(
                          decoration: BoxDecoration(
                            //borderRadius: BorderRadius.circular(50),
                            color: Colors.grey.shade200,
                          ),
                          padding: EdgeInsets.all(16),
                          child: GestureDetector(
                              child:new Text( getUserName(document.data()['userid'].toString()).toString()),
                              onTap:(){ Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => ChatRoomDr(document.data()['userid'],
                                  )));
                              updateChat(document.data()['userid']);
                              }
                          )
                      )
                  );
                }).toList(),
              ): Container(
                child: Text('No New Queastions'),
              );
            },
          )
      ),
    );
  }
}
