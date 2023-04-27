import 'dart:io';

import 'package:agri_project/db.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:tflite/tflite.dart';

import 'db.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:agri_project/l10n/l10n.dart';
import 'package:translator/translator.dart';

import 'languageChange.dart';
import 'main.dart';

class DiseaseDetection extends StatefulWidget {
  const DiseaseDetection({Key? key}) : super(key: key);

  @override
  State<DiseaseDetection> createState() => _DiseaseDetectionState();
}

class _DiseaseDetectionState extends State<DiseaseDetection> {
  var db = Database();
  File? _image;
  String _outputs = "";
  String _marathiLabels = "";
  String _prec = "";
  String _marathiPrec = "";
  String translation = "";
  String english = 'en';

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loading = true;

    loadModel().then((value) {
      setState(() {
        _loading = false;
      });
    });
  }

  loadModel() async {
    await Tflite.loadModel(
      model: "assets/model_unquant.tflite",
      labels: "assets/labels.txt",
      // label: "assets/prec.txt",
      numThreads: 1,
    );
  }

  classifyImage(File image) async {
    var out = await db.sendImage(image);
    // var precs = await db.sendImage(image);
    print(out);
    print('hii');
    // print(precs);
    setState(() {
      // _loading = false;
      _outputs = out[0];
      _marathiLabels = out[1];
      _prec = out[2];
      _marathiPrec = out[3];
    });
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }

  Future captureImage() async {
    try {
      var image = await ImagePicker().pickImage(source: ImageSource.camera);
      if (image == null) return;

      final imageTemp = File(image.path);
      setState(() {
        _image = imageTemp;
        _loading = true;
      });

      await classifyImage(_image!);
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

  Future pickImage() async {
    // try {
    var image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null) return;

    final imageTemp = File(image.path);
    setState(() {
      _image = imageTemp;
      _loading = true;
    });

    await classifyImage(_image!); // setState(() {
  }

  @override
  Widget build(BuildContext context) {
    Locale myLocale = Localizations.localeOf(context);
    print(myLocale);

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
          title: Text(AppLocalizations.of(context)!.diseaseDetection),
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
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                SizedBox(
                  height: 20,
                ),
                _image != null
                    ? Image.file(
                        _image!,
                        width: 300,
                        height: 300,
                      )
                    : Container(),
                Padding(padding: EdgeInsets.symmetric(vertical: 10)),
                _outputs != null
                    ? Container(
                        child: Column(
                          children: [
                            if (myLocale.languageCode == english) ...[
                              Text(
                                _outputs,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                maxLines: 2,
                                textAlign: TextAlign.justify,
                              ),
                            ] else ...[
                              Text(
                                _marathiLabels,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  overflow: TextOverflow.clip,
                                ),
                                maxLines: 10,
                                textAlign: TextAlign.justify,
                              ),
                            ]
                          ],
                        ),
                      )
                    : FlutterLogo(),
                Padding(padding: EdgeInsets.symmetric(vertical: 10)),
                ElevatedButton(
                    onPressed: () => pickImage(),
                    child: Text(AppLocalizations.of(context)!.uploadImage)),
                Padding(padding: EdgeInsets.only(top: 30.0)),
                Text(
                  AppLocalizations.of(context)!.precautionaryMeasures,
                  style: TextStyle(fontSize: 25),
                ),
                Padding(padding: EdgeInsets.only(top: 18.0)),
                _prec != null
                    ? Container(
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        child: Column(
                          children: [
                            if (myLocale.languageCode == english) ...[
                              Text(
                                _prec,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  overflow: TextOverflow.clip,
                                ),
                                maxLines: 10,
                                textAlign: TextAlign.justify,
                              )
                            ] else ...[
                              Text(
                                _marathiPrec,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  overflow: TextOverflow.clip,
                                ),
                                maxLines: 10,
                                textAlign: TextAlign.justify,
                              )
                            ]
                          ],
                        ),
                        //   Text(
                        //     _prec,
                        //     style: TextStyle(
                        //       color: Colors.black,
                        //       fontSize: 20,
                        //       overflow: TextOverflow.clip,
                        //     ),
                        //     maxLines: 10,
                        //     textAlign: TextAlign.justify,
                        //   ),
                      )
                    : FlutterLogo(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
