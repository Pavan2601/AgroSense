import 'dart:async';

import 'package:agri_project/npk.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'api.dart' as k;
import 'dart:convert';

class weather extends StatefulWidget {
  const weather({Key? key}) : super(key: key);

  @override
  State<weather> createState() => _weatherState();
}

class _weatherState extends State<weather> {
  bool isLoaded = false;
  var temp;
  var press;
  var hum;
  var cover;
  String cityname = '';

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
    Timer(
        Duration(seconds: 5),
        () => Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => npk())));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Visibility(visible: isLoaded, child: Scaffold()),
    );
  }

  getCurrentLocation() async {
    var p = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.medium,
      forceAndroidLocationManager: true,
    );
    if (p != null) {
      print('Lat:${p.latitude}, Long:${p.longitude}');
      getCurrentCityWeather(p);
    } else {
      print('Data unavailable');
    }
  }

  // Position position;

  getCurrentCityWeather(Position position) async {
    // print(position);
    var client = http.Client();
    var uri =
        '${k.domain}lat=${position.latitude}&lon=${position.longitude}&appid=${k.apiKey}';
    var url = Uri.parse(uri);
    var response = await client.get(url);
    if (response.statusCode == 200) {
      var data = response.body;
      var decodeData = json.decode(data);
      updateUI(decodeData);
      setState(() {
        isLoaded = true;
      });
      print(data);
      print('temp =' + temp.toString());
      print('hum =' + hum.toString());
      print('cover =' + cover.toString());
      print('pressre = ' + press.toString());
    } else {
      print(response.statusCode);
    }
  }

  updateUI(var decodedData) {
    print('heeeiei');

    if (decodedData == null) {
      temp = 0;
      press = 0;
      hum = 0;
      cover = 0;
      cityname = 'Not available';
    } else {
      temp = decodedData['main']['temp'] - 273;
      press = decodedData['main']['pressure'];
      hum = decodedData['main']['humidity'];
      cover = decodedData['clouds']['all'];
      cityname = decodedData['name'];
    }
  }
}
