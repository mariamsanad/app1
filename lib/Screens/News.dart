import 'package:app1/Components/loading.dart';
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
        title: Text('Latest Covid-19 News'),
      ),
      body: SingleChildScrollView(
        child: FutureBuilder(
          future: getscrap(),
          builder: (BuildContext context, AsyncSnapshot snapshot){
            if (snapshot.hasData){
              if(snapshot.data.length>0){
                return Card(child:
                Padding(

                padding: EdgeInsets. all(16.0),
                    child:
                Align(alignment: Alignment.centerRight,
                child:
                Text(snapshot.data[0]['title'].toString()))));
              }else{
                return Text('There is no data');
              }

            }
            return Center(child: Loading());
          },
        ),
      ),
    );
  }
}
