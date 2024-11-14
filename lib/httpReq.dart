import 'dart:convert';

import 'package:http/http.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;


class HttpManager{
  static const urlPrefix = 'https://api.clevertap.com/1';

  Future<void> updatePushStatus(String objectId) async{
    print("ctid $objectId");

    // Response response = await get(urlPrefix);

    final url = Uri.parse('$urlPrefix/upload');
    final headers = {'X-CleverTap-Account-Id':'TEST-RZ7-Z94-K95Z',
      'X-CleverTap-Passcode':'EVQ-ZUA-GXKL',
      'Content-Type': 'application/json; charset=UTF-8'};
    final response = await post(url,headers: headers,
        body: jsonEncode({
          "d":[{"objectId":objectId,"type":"profile",
            "profileData":{"MSG-push": false}
          }]
        }));

    print('Status code: ${response.statusCode}');
    print('Body: ${response.body}');
  }
}