import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

class DiseaseDetection extends StatefulWidget {
  const DiseaseDetection({Key? key}) : super(key: key);

  @override
  State<DiseaseDetection> createState() => _DiseaseDetectionState();
}

class _DiseaseDetectionState extends State<DiseaseDetection> {
  File? _image;
  List? _outputs;
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
      numThreads: 1,
    );
  }

  classifyImage(File image) async {
    var output = await Tflite.runModelOnImage(
        path: image.path,
        imageMean: 0.0,
        imageStd: 255.0,
        numResults: 2,
        threshold: 0.2,
        asynch: true);
    print(output);
    setState(() {
      _loading = false;
      _outputs = output!;
    });
    print(_outputs);
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
      // setState(() {
      //   _loading = true;
      //   // image = image as File;
      //   image = imageTemp as XFile?;
      // });
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
    //   _loading = true;
    //   // _image = image as File;
    //   image = imageTemp as XFile?;
    // });
    // } on PlatformException catch (e) {
    // print('Failed to pick image: $e');
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Disease Detection'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Padding(padding: EdgeInsets.only(top: 100.0)),
            // _image == null ? Container() : Image.file(_image!),
            SizedBox(
              height: 20,
            ),
            // _image != null
            //     ? Image.file(
            //         _image!,
            //         width: 300,
            //         height: 300,
            //       )
            //     : _outputs != null
            //         ? Text(
            //             _outputs![0]["label"],
            //             style: TextStyle(color: Colors.black, fontSize: 20),
            //           )
            //         : Container(child: Text("")),

            _image != null
                ? Image.file(
                    _image!,
                    width: 300,
                    height: 300,
                  )
                : Container(),
            _outputs != null
                ? Text(
                    _outputs![0]["label"],
                    style: TextStyle(color: Colors.black, fontSize: 20),
                  )
                : Container(child: Text("")),
            // image != null
            //     ? Image.file(
            //         image!,
            //         width: 300,
            //         height: 300,
            //       )
            //     // Column(
            //     //     children: <Widget>[
            //     //       Image.file(
            //     //         image!,
            //     //         width: 300,
            //     //         height: 300,
            //     //       ),
            //     //       Text(
            //     //         _outputs![0]["label"],
            //     //         style: TextStyle(color: Colors.black, fontSize: 20),
            //     //       )
            //     //       // : Container(child: Text(""))
            //     //     ],
            //     //   )
            //     : Container(child: Text("")),
            // : FlutterLogo(),
            Padding(padding: EdgeInsets.only(top: 30.0)),
            ElevatedButton(
                onPressed: () => captureImage(),
                child: const Text('Take from Camera')),
            Padding(padding: EdgeInsets.only(top: 30.0)),
            ElevatedButton(
                onPressed: () => pickImage(),
                child: const Text('Take from Gallery')),
          ],
        ),
      ),
    );
  }
}
