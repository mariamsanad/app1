import 'package:flutter/material.dart';
class Mlist extends StatelessWidget {

  final id;
  final fname;
  final lname;
  final email;
  final dob;
  final type;

  Mlist({this.id, this.fname, this.lname, this.email, this.dob, this.type});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        height: 100,
        width: 100,
        child: Card(
          child: Row(
            children: [
              Expanded(flex:1, child: Image.asset("assets/images/chatbot.png")),
              Expanded(flex:2, child: Container(
                alignment: Alignment.topLeft,
                height: 160,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(top:10, bottom:10),
                      child: Text(fname,
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                        textAlign: TextAlign.center,),),
                    Row(
                      children: [
                        Expanded(child: Row(
                          children: [
                            Text("The Last NAme: ",
                              style: TextStyle(color: Colors.green),),
                            Text(lname,
                              style: TextStyle(color: Colors.green),)

                          ],
                        ))
                      ],
                    )
                  ],
                ),
              ),)
            ],
          ),
        ),
      ),
      onTap: (){
        Navigator.of(context).pushNamed("usersdetails");
      },
    ) ;
  }
}
