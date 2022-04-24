import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class FruitIdentification extends StatefulWidget {
  const FruitIdentification({Key? key}) : super(key: key);

  @override
  State<FruitIdentification> createState() => _FruitIdentificationState();
}

class _FruitIdentificationState extends State<FruitIdentification> {
  File? image;

  Future captureImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.camera);
      if (image == null) return;

      final imageTemp = File(image.path);
      setState(() => this.image = imageTemp);
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

  Future pickImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return;

      final imageTemp = File(image.path);
      setState(() => this.image = imageTemp);
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
        children: [
          Padding(padding: EdgeInsets.only(top: 100.0)),
          image != null
              ? Image.file(
                  image!,
                  width: 300,
                  height: 300,
                )
              : FlutterLogo(),
          Padding(padding: EdgeInsets.only(top: 30.0)),
          ElevatedButton(
              onPressed: () => captureImage(),
              child: const Text('Take from Camera')),
          Padding(padding: EdgeInsets.only(top: 30.0)),
          ElevatedButton(
              onPressed: () => pickImage(),
              child: const Text('Take from Gallery')),
        ],
      )),
    );
  }
}
