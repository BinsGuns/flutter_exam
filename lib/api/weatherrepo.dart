import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertest/model/weathermodel.dart';

class WeatherRepo{
  Future<WeatherModel> getWeather(String lat,String lon) async{

  final result = await http.Client().get("https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=f9276180cda09757eb38a78233c085f0");
    
  if(result.statusCode != 200)
      throw Exception();
    
    return parsedJson(result.body);
  }
  
  WeatherModel parsedJson(final response){
    final jsonDecoded = json.decode(response);

    final jsonWeather = jsonDecoded["main"];

    return WeatherModel.fromJson(jsonWeather);
  }
}