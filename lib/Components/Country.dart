import 'dart:convert';
import 'package:http/http.dart' as http;
class Country{

  final country;
  final code;
  final confirmed;
  final deaths;
  final recoverd;
  final active;
  final date;


  Country(this.country, this.code, this.confirmed, this.deaths, this.recoverd,
      this.active, this.date);

  factory Country.fromJson(Map<String,dynamic>json){
    return Country(json['Country'],json['CountryCode'], json['Confirmed'],  json['Deaths'],  json['Recovered'],  json['Active'],  json['Date']);
  }
}

Future<Country> fetchCountry()async{
  final response = await http.get('https://api.covid19api.com/country/');

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return Country.fromJson(jsonDecode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load country');
  }
}