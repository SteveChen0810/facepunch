import 'package:facepunch/models/user_model.dart';
import 'package:facepunch/models/work_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'app_const.dart';

class RevisionModel with ChangeNotifier{

  Future<String> sendPunchRevisionRequest({int punchId, String newValue, String oldValue, String description})async{
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
            'description': description
          }
      );
      print("[RevisionModel.sendPunchRevisionRequest] ${res.body}");
      if(res.statusCode==200){
        return "A revision request has been sent.";
      }else{
        return jsonDecode(res.body)['message'];
      }
    }catch(e){
      print("[RevisionModel.sendPunchRevisionRequest] $e");
      return e.toString();
    }
  }

  Future<String> sendBreakRevisionRequest({EmployeeBreak newBreak, EmployeeBreak oldBreak, String description})async{
    try{
      var res = await http.post(
          AppConst.sendTimeRevisionRequest,
          headers: {
            'Accept':'application/json',
            'Content-Type':'application/json',
            'Authorization':'Bearer '+GlobalData.token
          },
          body: jsonEncode({
            'break_id':oldBreak.id,
            'new_value': newBreak.toJson(),
            'old_value': oldBreak.toJson(),
            'description': description
          })
      );
      print("[RevisionModel.sendBreakRevisionRequest] ${res.body}");
      if(res.statusCode==200){
        return "A revision request has been sent.";
      }else{
        return jsonDecode(res.body)['message'];
      }
    }catch(e){
      print("[RevisionModel.sendBreakRevisionRequest] $e");
      return e.toString();
    }
  }

  Future<String> sendWorkRevisionRequest({WorkHistory newWork, WorkHistory oldWork, String description})async{
    try{
      var res = await http.post(
          AppConst.sendTimeRevisionRequest,
          headers: {
            'Accept':'application/json',
            'Content-Type':'application/json',
            'Authorization':'Bearer '+GlobalData.token
          },
          body: jsonEncode({
            'work_id': oldWork.id,
            'new_value': newWork.toJson(),
            'old_value': oldWork.toJson(),
            'description': description
          })
      );
      print("[RevisionModel.sendWorkRevisionRequest] ${res.body}");
      if(res.statusCode==200){
        return "A revision request has been sent.";
      }else{
        return jsonDecode(res.body)['message'];
      }
    }catch(e){
      print("[RevisionModel.sendWorkRevisionRequest] $e");
      return e.toString();
    }
  }

  Future<String> sendScheduleRevision({WorkSchedule newSchedule, WorkSchedule oldSchedule, String description})async{
    try{
      var res = await http.post(
        AppConst.sendTimeRevisionRequest,
        headers: {
          'Accept':'application/json',
          'Content-Type':'application/json',
          'Authorization':'Bearer '+GlobalData.token
        },
        body: jsonEncode({
          'schedule_id':oldSchedule.id,
          'new_value':newSchedule.toJson(),
          'old_value':oldSchedule.toJson(),
          'description':description
        }),
      );
      print('[RevisionModel.sendScheduleRevision]${res.body}');
      if(res.statusCode==200){
        return null;
      }else{
        return jsonDecode(res.body)['message'];
      }
    }catch(e){
      print('[RevisionModel.sendScheduleRevision]$e');
      return e.toString();
    }
  }

  Future<String> sendCallRevision({EmployeeCall newSchedule, EmployeeCall oldSchedule, String description})async{
    try{
      var res = await http.post(
        AppConst.sendTimeRevisionRequest,
        headers: {
          'Accept':'application/json',
          'Content-Type':'application/json',
          'Authorization':'Bearer '+GlobalData.token
        },
        body: jsonEncode({
          'call_id':oldSchedule.id,
          'new_value':newSchedule.toJson(),
          'old_value':oldSchedule.toJson(),
          'description':description
        }),
      );
      print('[RevisionModel.sendCallRevision]${res.body}');
      if(res.statusCode==200){
        return null;
      }else{
        return jsonDecode(res.body)['message'];
      }
    }catch(e){
      print('[RevisionModel.sendCallRevision]$e');
      return e.toString();
    }
  }
}

class Revision{
  int id;
  int userId;
  int punchId;
  int workId;
  int scheduleId;
  int callId;
  int breakId;
  String type;
  var oldValue;
  var newValue;
  User user;
  Punch punch;
  WorkHistory work;
  WorkSchedule schedule;
  EmployeeCall call;
  EmployeeBreak employeeBreak;
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
      if(json['user'] != null){
        user = User.fromJson(json['user']);
      }
      if(json['punch'] != null){
        punch = Punch.fromJson(json['punch']);
      }
      if(json['work'] != null){
        work = WorkHistory.fromJson(json['work']);
      }
      if(json['schedule'] != null){
        schedule = WorkSchedule.fromJson(json['schedule']);
      }
      if(json['call'] != null){
        call = EmployeeCall.fromJson(json['call']);
      }
      if(json['break'] != null){
        employeeBreak = EmployeeBreak.fromJson(json['break']);
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

  bool isValid(){
    if(newValue is String && oldValue is String) return newValue != oldValue;
    bool valid = false;
    if(newValue is Map && oldValue is Map){
      newValue.forEach((key, value) {
        print([key, value, oldValue[key]]);
        if(oldValue[key] != value) valid = true;
      });
    }
    return valid;
  }

  Future<String> addDescription(String description)async{
    try{
      var res = await http.post(
        AppConst.addRevisionDescription,
        headers: {
          'Accept':'application/json',
          'Content-Type':'application/json',
          'Authorization':'Bearer '+GlobalData.token
        },
        body: jsonEncode({
          'id': id,
          'description': description
        }),
      );
      print('[Revision.addDescription]${res.body}');
      if(res.statusCode==200){
        return null;
      }else{
        return jsonDecode(res.body)['message'];
      }
    }catch(e){
      print('[Revision.addDescription]$e');
      return e.toString();
    }
  }
}