import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'app_const.dart';
class BaseProvider with ChangeNotifier, HttpRequest{

}

class HttpRequest{

  Future<http.Response> sendPostRequest(String url, String? token, Map<dynamic, dynamic> data)async{
    Map<String, String> headers = {};
    headers['Accept'] = 'application/json';
    headers['Content-Type'] = 'application/json';
    headers['app-version'] = '${AppConst.currentVersion}';
    headers['operating-system'] = Platform.operatingSystem;
    headers['lang'] = GlobalData.lang;
    if(token != null){
      headers['Authorization'] = 'Bearer '+token;
    }
    return await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(data)
    );
  }

  Future<http.Response> sendGetRequest(String url, String? token)async{
    Map<String, String> headers = {};
    headers['Accept'] = 'application/json';
    headers['Content-Type'] = 'application/json';
    headers['app-version'] = '${AppConst.currentVersion}';
    headers['operating-system'] = Platform.operatingSystem;
    headers['lang'] = GlobalData.lang;
    if(token != null){
      headers['Authorization'] = 'Bearer '+token;
    }
    return await http.get(
        Uri.parse(url),
        headers: headers
    );
  }

}