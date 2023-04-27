import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';

class Database {
  sendImage(File file) async {
    FormData formData = FormData.fromMap({
      "image": await MultipartFile.fromFile(file.path, filename: "lol.jpg")
    });
    var resp = (await Dio().post(
        "https://b4ad-2401-4900-54d2-d69a-f847-49d4-6196-f3b0.ngrok-free.app/image",
        data: formData,
        options: Options(headers: {"ngrok-skip-browser-warning": 41102})));
    print(resp);
    return resp.data["data"];
  }

  npk(
    int n,
    int p,
    int k,
    double pH,
    double temp,
    double hum,
  ) async {
    var url =
        'https://b4ad-2401-4900-54d2-d69a-f847-49d4-6196-f3b0.ngrok-free.app/npk';
    var response = await Dio().post(url,
        data: json.encode({
          'int1': n,
          'int2': p,
          'int3': k,
          'int5': temp,
          'int6': hum,
          'int4': pH,
        }));

    // Parse the prediction result from the API response
    var data = (response.data["data"]);
    return data;
  }
}
