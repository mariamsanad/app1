import 'package:flutter/material.dart';
import 'package:app1/Services/crudUser.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Messages.dart';
class ChatRoomDr extends StatefulWidget {
  final userid;

  ChatRoomDr(this.userid);

  @override
  _ChatRoomDrState createState() => _ChatRoomDrState();
}

class _ChatRoomDrState extends State<ChatRoomDr> {
  final TextEditingController _message = TextEditingController();
  ScrollController scrollController = ScrollController();

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Answer questions'),),
      body:   Column(
        children: <Widget>[
          Expanded(
            //messages container
            flex: 70,
            child: Messages(widget.userid),),

          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              padding: EdgeInsets.only(left: 10,bottom: 10,top: 10),
              child: Row(
                children: <Widget>[
                  SizedBox(width: 15,),
                  Expanded(
                    flex: 30,
                    child: TextFormField(
                      textCapitalization: TextCapitalization.sentences,
                      autocorrect: true,
                      enableSuggestions: true,
                      controller: _message,
                      decoration: const InputDecoration(
                        labelText: 'type a message',
                        fillColor: Color(0xFF111111),
                        border: OutlineInputBorder(),
                      ),
                    ),),
                  SizedBox(width: 15,),
                  FloatingActionButton(
                    onPressed: ()async {
                      if (_message.text != "") {
                        try{
                          final  _date = new DateTime.now();
                          await addReply(this.widget.userid,_message.text, _date.toString()).then((value){
                            _message.clear();
                            scrollController.animateTo(scrollController.position.maxScrollExtent, curve:Curves.easeOut ,duration: Duration(milliseconds: 300));
                          });
                        }on FirebaseAuthException catch(e){
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              duration: const Duration(seconds: 3),
                              content: Text(e.message),
                              backgroundColor: Colors.red,
                              behavior: SnackBarBehavior.floating,
                              shape: StadiumBorder(),
                            ),);}}},
                    child: Icon(Icons.send,color: Color(0xFF111111),size: 18,),
                    backgroundColor: Colors.white,
                    elevation: 0,
                  ),],),),),],),);
  }
}