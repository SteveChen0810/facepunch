import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
class BaseProvider extends BaseModel with ChangeNotifier{

}

class BaseModel{
  Future<http.Response> sendPostRequest(String url, String? token, Map<dynamic, dynamic> data)async{
    Map<String, String> headers = {};
    headers['Accept'] = 'application/json';
    headers['Content-Type'] = 'application/json';
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
    if(token != null){
      headers['Authorization'] = 'Bearer '+token;
    }
    return await http.get(
        Uri.parse(url),
        headers: headers
    );
  }

}