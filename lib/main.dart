import 'dart:math';

import 'package:agri_project/diseaseDetection.dart';
// import 'package:agri_project/fruitIdentificaton.dart';
import 'package:agri_project/l10n/l10n.dart';
import 'package:agri_project/languageChange.dart';
import 'package:agri_project/npk.dart';
import 'package:agri_project/weather.dart';
// import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import 'fruitIdentificaton.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'api.dart' as k;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LanguageChangeProvider>(
      create: (context) => LanguageChangeProvider(),
      child: Builder(
          builder: (context) => MaterialApp(
                locale:
                    Provider.of<LanguageChangeProvider>(context, listen: true)
                        .currentLocale,
                title: 'Flutter Demo',
                localizationsDelegates: [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: l10n.all,
                theme: ThemeData(
                  primarySwatch: Colors.teal,
                ),
                home: const MyHomePage(title: 'AgroSense'),

                // home: weather(),
              )),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isLoaded = false;
  var temp;
  var press;
  var hum;
  var cover;
  String cityname = '';
  @override
  void initState() {
    super.initState();
    // getCurrentLocation();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Locale myLocale = Localizations.localeOf(context);
    print(myLocale);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                Container(),
                Padding(padding: EdgeInsets.only(top: 20)),
                Image.asset('assets/images/logo.png',
                    // fit: BoxFit.contain,
                    height: 90,
                    width: 250),
              ],
            ),
            // Text(widget.title),
          ],
        ),
      ),
      body: SingleChildScrollView(
          child: Container(
        // width: 100,
        height: 768,

        child: Column(
          children: [
            // Image(image: ),

            Padding(
              padding: const EdgeInsets.all(25.0),
              child: Text(
                AppLocalizations.of(context)!.projectDesc,
                style: TextStyle(
                  fontSize: 21,
                ),
              ),
            ),

            Center(
              child: Column(children: [
                ElevatedButton(
                    onPressed: (() => {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const DiseaseDetection()),
                          )
                        }),
                    child: Text(
                      AppLocalizations.of(context)!.diseaseDetection,
                    )),
                Padding(padding: EdgeInsets.symmetric(vertical: 10)),
                ElevatedButton(
                    onPressed: (() => {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const npk()),
                          )
                        }),
                    child: Text(
                      AppLocalizations.of(context)!.npk,
                    )),
              ]),
            ),
            Padding(padding: EdgeInsets.only(bottom: 250)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                    child: Text(
                      AppLocalizations.of(context)!.marathi,
                    ),
                    onPressed: (() {
                      context.read<LanguageChangeProvider>().changeLocale('mr');
                    })),
                ElevatedButton(
                    child: Text(
                      AppLocalizations.of(context)!.english,
                    ),
                    onLongPress: (() => {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const weather()),
                          )
                        }),
                    onPressed: (() {
                      context.read<LanguageChangeProvider>().changeLocale('en');
                    })),
              ],
            ),
          ],
        ),
      )),
    );
  }

  // getCurrentLocation() async {
  //   var p = await Geolocator.getCurrentPosition(
  //     desiredAccuracy: LocationAccuracy.medium,
  //     forceAndroidLocationManager: true,
  //   );
  //   if (p != null) {
  //     print('Lat:${p.latitude}, Long:${p.longitude}');
  //     getCurrentCityWeather(p);
  //   } else {
  //     print('Data unavailable');
  //   }
  // }

  // // Position position;

  // getCurrentCityWeather(Position position) async {
  //   // print(position);
  //   var client = http.Client();
  //   var uri =
  //       '${k.domain}lat=${position.latitude}&lon=${position.longitude}&appid=${k.apiKey}';
  //   var url = Uri.parse(uri);
  //   var response = await client.get(url);
  //   if (response.statusCode == 200) {
  //     var data = response.body;
  //     var decodeData = json.decode(data);
  //     updateUI(decodeData);
  //     setState(() {
  //       isLoaded = true;
  //     });
  //     print(data);
  //     print('temp =' + temp.toString());
  //     print('hum =' + hum.toString());
  //     print('cover =' + cover.toString());
  //     print('pressre = ' + press.toString());
  //   } else {
  //     print(response.statusCode);
  //   }
  // }

  // updateUI(var decodedData) {
  //   print('heeeiei');

  //   if (decodedData == null) {
  //     temp = 0;
  //     press = 0;
  //     hum = 0;
  //     cover = 0;
  //     cityname = 'Not available';
  //   } else {
  //     temp = decodedData['main']['temp'] - 273;
  //     press = decodedData['main']['pressure'];
  //     hum = decodedData['main']['humidity'];
  //     cover = decodedData['clouds']['all'];
  //     cityname = decodedData['name'];
  //   }
  // }
}
