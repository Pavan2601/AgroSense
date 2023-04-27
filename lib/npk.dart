import 'dart:convert';

import 'package:agri_project/main.dart';
import 'package:agri_project/weather.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:agri_project/l10n/l10n.dart';
import 'package:http/http.dart' as http;
import 'package:translator/translator.dart';

import 'db.dart';
import 'languageChange.dart';
import 'package:google_translator/google_translator.dart';
import 'api.dart' as k;

class npk extends StatefulWidget {
  const npk({Key? key}) : super(key: key);

  @override
  State<npk> createState() => _npkState();
}

class _npkState extends State<npk> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: Provider.of<LanguageChangeProvider>(context, listen: true)
          .currentLocale,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: l10n.all,
      home: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(AppLocalizations.of(context)!.npk),
          leading: IconButton(
            onPressed: () {
              Navigator.pop(
                context,
                MaterialPageRoute(
                    builder: (context) => const MyHomePage(
                          title: 'AgroSense',
                        )),
              );
            },
            icon: Icon(Icons.home),
          ),
        ),
        body: MyCustomForm(),
      ),
    );
  }
}

// Create a Form widget.
class MyCustomForm extends StatefulWidget {
  @override
  MyCustomFormState createState() {
    return MyCustomFormState();
  }
}

// Create a corresponding State class. This class holds data related to the form.
class MyCustomFormState extends State<MyCustomForm> {
  var db = Database();
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  final _formKey = GlobalKey<FormState>();
  List<int> integerInputs = [];
  final nController = TextEditingController();
  final pController = TextEditingController();
  final kController = TextEditingController();
  final pHController = TextEditingController();

  String _outputs = "";
  String _marathiNames = "";
  String out = " ";
  String english = "en";
  String translatedText = "";
  String targetLanguage = 'mr';
  bool isLoaded = false;
  var temp;
  var press;
  var hum;
  var cover;
  String cityname = '';

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      _outputs = await db.npk(
          int.parse(nController.text),
          int.parse(pController.text),
          int.parse(kController.text),
          double.parse(pHController.text),
          double.parse(temp.toString()),
          double.parse(hum.toString()));
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Locale myLocale = Localizations.localeOf(context);
    GoogleTranslator translator = GoogleTranslator();
    translator.translate(_outputs, to: targetLanguage).then((result) {
      setState(() {
        translatedText = result.toString();
      });
    });
    print(translatedText);
    // getCurrentLocation();

    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 35, vertical: 15),
        child: Column(
          children: [
            Text(
              AppLocalizations.of(context)!.valuesOfNPK,
              style: TextStyle(fontSize: 20),
            ),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextFormField(
                    decoration: InputDecoration(labelText: 'N'),
                    keyboardType: TextInputType.number,
                    // onSaved: (value) => integerInputs.add(int.parse(value!)),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an integer.';
                      }
                      if (int.parse(value) < 1 || int.parse(value) > 140) {
                        return 'The value must be between 1 and 140';
                      }
                      return null;
                    },
                    controller: nController,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'P'),
                    keyboardType: TextInputType.number,
                    // onSaved: (value) => integerInputs.add(int.parse(value!)),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an integer.';
                      }
                      if (int.parse(value) < 5 || int.parse(value) > 145) {
                        return 'The value must be between 5 and 145';
                      }
                      return null;
                    },
                    controller: pController,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'K'),
                    keyboardType: TextInputType.number,
                    // onSaved: (value) => integerInputs.add(int.parse(value!)),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an integer.';
                      }
                      if (int.parse(value) < 5 || int.parse(value) > 205) {
                        return 'The value must be between 5 and 205';
                      }
                      return null;
                    },
                    controller: kController,
                  ),
                  Padding(padding: EdgeInsets.symmetric(vertical: 5)),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'pH'),
                    keyboardType: TextInputType.number,
                    // onSaved: (value) => integerInputs.add(int.parse(value!)),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an integer.';
                      }
                      if (double.parse(value) < 0 || double.parse(value) > 14) {
                        return 'The value must be between 0 and 14';
                      }
                      return null;
                    },
                    controller: pHController,
                  ),
                  Padding(padding: EdgeInsets.symmetric(vertical: 15)),
                  Center(
                    child: _outputs != null
                        ? Container(
                            child: Column(
                              children: [
                                if (myLocale.languageCode == english) ...[
                                  Text(
                                    AppLocalizations.of(context)!
                                            .suitableCropIs +
                                        _outputs,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 20,
                                      overflow: TextOverflow.clip,
                                    ),
                                    maxLines: 10,
                                    textAlign: TextAlign.justify,
                                  ),
                                ] else ...[
                                  Text(
                                    AppLocalizations.of(context)!
                                            .suitableCropIs +
                                        " " +
                                        translatedText,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 20,
                                      overflow: TextOverflow.clip,
                                    ),
                                    maxLines: 10,
                                    textAlign: TextAlign.justify,
                                  ),
                                ],
                              ],
                            ),
                          )
                        : FlutterLogo(),
                  ),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.only(top: 40.0),
                      child: ElevatedButton(
                        child: Text(AppLocalizations.of(context)!.submit),
                        onPressed: _submitForm,
                        onLongPress: (() => {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const weather()),
                              )
                            }),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
