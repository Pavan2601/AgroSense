import 'dart:io';
import 'package:dio/dio.dart';

class Database {
  sendImage(File file) async {
    FormData formData = FormData.fromMap({
      "image": await MultipartFile.fromFile(file.path, filename: "lol.jpg")
    });
    var resp =
        (await Dio().post("http://192.168.0.105:5000/image", data: formData));
    print(resp);
    return resp.toString();
  }
}
