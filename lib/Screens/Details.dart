import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UsersDetails extends StatefulWidget {
  @override
  _UsersDetailsState createState() => _UsersDetailsState();
}

class _UsersDetailsState extends State<UsersDetails> {
  @override
  Widget build(BuildContext context) {
    return Directionality(textDirection: TextDirection.ltr, child: Scaffold(
      appBar: AppBar(
        title: Text("Users Details"),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          Container(
            height: 300,
            child: GridTile(
              child: Image.asset("assets/images/chatbot.png"),
              footer: Container(
                height: 60,
                color: Colors.black.withOpacity(0.3) ,
                child: Row(
                  //mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(child: Container(
                        padding: EdgeInsets.all(10),
                        child: Text("Price 1200", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),))),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text("somthing", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),),
                    ),
                  ],
                )
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(10),
            child: Text("Details", style: TextStyle(fontSize: 20),),
          ),
          Container(
            child:
            Column(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  color: Colors.white,
                  child: RichText(
                    text: TextSpan(
                      children: <TextSpan>[
                        TextSpan(text: "first name", style: TextStyle(fontSize: 18, color: Colors.black)),
                        TextSpan(text: "Mariam", style: TextStyle(fontSize: 18, color: Colors.black)),
                      ]
                    ),
                  )
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  color: Colors.white,
                  child:  RichText(
                    text: TextSpan(
                        children: <TextSpan>[
                          TextSpan(text: "last name", style: TextStyle(fontSize: 18, color: Colors.black)),
                          TextSpan(text: " Sanad", style: TextStyle(fontSize: 18, color: Colors.black)),
                        ]
                    ),
                  )
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  color: Colors.white,
                  child:  RichText(
                    text: TextSpan(
                        children: <TextSpan>[
                          TextSpan(text: "Email", style: TextStyle(fontSize: 18, color: Colors.black)),
                          TextSpan(text: "mjeahs1234@gmail.com", style: TextStyle(fontSize: 18, color: Colors.black)),
                        ]
                    ),
                  )
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.all(10),
                  color: Colors.blue,
                  child: RichText(
                    text: TextSpan(
                        children: <TextSpan>[
                          TextSpan(text: "User id", style: TextStyle(fontSize: 18, color: Colors.black)),
                          TextSpan(text: "100", style: TextStyle(fontSize: 18, color: Colors.black)),
                        ]
                    ),
                  )
                ),
              ],
            ),
          )
        ],
      )
    ));
  }
}
