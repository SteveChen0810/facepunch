import 'package:facepunch/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'app_const.dart';

class RevisionModel with ChangeNotifier{

  Future<String> sendTimeRevisionRequest({int punchId, String newValue, String oldValue})async{
    try{
      var res = await http.post(
          AppConst.sendTimeRevisionRequest,
          headers: {
            'Accept':'application/json',
            'Content-Type':'application/x-www-form-urlencoded',
            'Authorization':'Bearer '+GlobalData.token
          },
          body: {
            'punch_id':punchId.toString(),
            'new_value': newValue,
            'old_value': oldValue,
          }
      );
      print("[RevisionModel.sendTimeRevisionRequest] ${res.body}");
      if(res.statusCode==200){
        return "A revision request has been sent.";
      }else{
        return jsonDecode(res.body)['message'];
      }
    }catch(e){
      print("[RevisionModel.sendTimeRevisionRequest] $e");
      return e.toString();
    }
  }

}

class Revision{
  int id;
  int userId;
  int punchId;
  String type;
  String oldValue;
  String newValue;
  User user;
  Punch punch;
  String status;
  String createdAt;
  String updatedAt;

  Revision({
    this.id,
    this.userId,
    this.punchId,
    this.type,
    this.oldValue,
    this.newValue,
    this.user,
    this.punch,
    this.status,
    this.createdAt,
    this.updatedAt
  });

  Revision.fromJson(Map<String, dynamic> json) {
    try{
      id = json['id'];
      userId = json['user_id'];
      punchId = json['punch_id'];
      type = json['type'];
      status = json['status'];
      oldValue = json['old_value'];
      newValue = json['new_value'];
      if(json['user']!=null){
        user = User.fromJson(json['user']);
      }
      if(json['punch']!=null){
        punch = Punch.fromJson(json['punch']);
      }
      createdAt = json['created_at'];
      updatedAt = json['updated_at'];
    }catch(e){
      print("[Revision.fromJson] $e");
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.id;
    data['punch_id'] = this.punchId;
    data['type'] = this.type;
    data['status'] = this.status;
    data['old_value'] = this.oldValue;
    data['new_value'] = this.newValue;
    if(this.punch!=null)data['punch'] = this.punch.toJson();
    if(this.user!=null)data['user'] = this.user.toJson();
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}