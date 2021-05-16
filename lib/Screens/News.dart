import 'package:flutter/material.dart';
import 'package:web_scraper/web_scraper.dart';
// import 'package:html/parser.dart' show parse;
// import 'package:html/dom.dart';

class News extends StatefulWidget {
  @override
  _NewsState createState() => _NewsState();
}

getscrap() async {
  final webScraper = WebScraper('https://www.moh.gov.bh');
  if (await webScraper.loadWebPage('/COVID19/News')) {
    /*List<Map<String, dynamic>> */
    final elements = webScraper.getElement('tbody#myTable', []);
    return elements;
  }
}

class _NewsState extends State<News> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('News'),
      ),
      body: SingleChildScrollView(
        child: FutureBuilder(
          future: getscrap(),
          builder: (BuildContext context, AsyncSnapshot snapshot){
            if (snapshot.hasData){
              if(snapshot.data.length>0){
                return Text(snapshot.data[0].toString());
              }else{
                return Text('There is no data');
              }

            }
            return Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
