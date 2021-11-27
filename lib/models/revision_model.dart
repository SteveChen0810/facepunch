import 'package:facepunch/lang/l10n.dart';
import 'package:facepunch/widgets/calendar_strip/date-utils.dart';
import 'package:flutter/material.dart';

import 'base_model.dart';
import 'user_model.dart';
import 'work_model.dart';
import 'dart:convert';
import 'app_const.dart';
import '/widgets/utils.dart';

class RevisionModel extends BaseProvider {

  Future<String?> sendPunchRevisionRequest({int? punchId, required String newValue,
    String? oldValue, required String description})async{
    try{
      var res = await sendPostRequest(
          AppConst.sendTimeRevisionRequest,
          GlobalData.token,
          {
            'punch_id' : punchId.toString(),
            'new_value' : newValue,
            'old_value' : oldValue,
            'description' : description
          }
      );
      Tools.consoleLog("[RevisionModel.sendPunchRevisionRequest.res] ${res.body}");
      if(res.statusCode==200){
        return null;
      }else{
        return jsonDecode(res.body)['message'];
      }
    }catch(e){
      Tools.consoleLog("[RevisionModel.sendPunchRevisionRequest.err] $e");
      return e.toString();
    }
  }

  Future<String?> sendBreakRevisionRequest({required EmployeeBreak newBreak, required EmployeeBreak oldBreak, required String description})async{
    try{
      var res = await sendPostRequest(
          AppConst.sendTimeRevisionRequest,
          GlobalData.token,
          {
            'break_id':oldBreak.id,
            'new_value': newBreak.toJson(),
            'old_value': oldBreak.toJson(),
            'description': description
          }
      );
      Tools.consoleLog("[RevisionModel.sendBreakRevisionRequest.res] ${res.body}");
      if(res.statusCode==200){
        return null;
      }else{
        return jsonDecode(res.body)['message'];
      }
    }catch(e){
      Tools.consoleLog("[RevisionModel.sendBreakRevisionRequest.err] $e");
      return e.toString();
    }
  }

  Future<String?> sendWorkRevisionRequest({required WorkHistory newWork, required WorkHistory oldWork, required String description})async{
    try{
      var res = await sendPostRequest(
          AppConst.sendTimeRevisionRequest,
          GlobalData.token,
          {
          'work_id': oldWork.id,
          'new_value': newWork.toJson(),
          'old_value': oldWork.toJson(),
          'description': description
          }
      );
      Tools.consoleLog("[RevisionModel.sendWorkRevisionRequest.res] ${res.body}");
      if(res.statusCode==200){
        return null;
      }else{
        return jsonDecode(res.body)['message'];
      }
    }catch(e){
      Tools.consoleLog("[RevisionModel.sendWorkRevisionRequest.err] $e");
      return e.toString();
    }
  }

  Future<String?> sendScheduleRevision({required WorkSchedule newSchedule, required WorkSchedule oldSchedule, required String description})async{
    try{
      var res = await sendPostRequest(
        AppConst.sendTimeRevisionRequest,
        GlobalData.token,
        {
          'schedule_id':oldSchedule.id,
          'new_value':newSchedule.toJson(),
          'old_value':oldSchedule.toJson(),
          'description':description
        },
      );
      Tools.consoleLog('[RevisionModel.sendScheduleRevision.res]${res.body}');
      if(res.statusCode==200){
        return null;
      }else{
        return jsonDecode(res.body)['message'];
      }
    }catch(e){
      Tools.consoleLog('[RevisionModel.sendScheduleRevision.err]$e');
      return e.toString();
    }
  }

  Future<String?> sendCallRevision({required EmployeeCall newSchedule, required EmployeeCall oldSchedule, required String description})async{
    try{
      var res = await sendPostRequest(
        AppConst.sendTimeRevisionRequest,
        GlobalData.token,
        {
          'call_id':oldSchedule.id,
          'new_value':newSchedule.toJson(),
          'old_value':oldSchedule.toJson(),
          'description':description
        },
      );
      Tools.consoleLog('[RevisionModel.sendCallRevision.res]${res.body}');
      if(res.statusCode==200){
        return null;
      }else{
        return jsonDecode(res.body)['message'];
      }
    }catch(e){
      Tools.consoleLog('[RevisionModel.sendCallRevision.err]$e');
      return e.toString();
    }
  }
}

class Revision with HttpRequest{
  int? id;
  int? userId;
  int? punchId;
  int? workId;
  int? scheduleId;
  int? callId;
  int? breakId;
  String? type;
  var oldValue;
  var newValue;
  User? user;
  Punch? punch;
  WorkHistory? work;
  WorkSchedule? schedule;
  EmployeeCall? call;
  EmployeeBreak? employeeBreak;
  String? status;
  String? description;
  String? createdAt;
  String? updatedAt;

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
    this.description,
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
      description = json['description'];
      createdAt = json['created_at'];
      updatedAt = json['updated_at'];
    }catch(e){
      Tools.consoleLog("[Revision.fromJson.err] $e");
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
    data['punch'] = this.punch?.toJson();
    data['user'] = this.user?.toJson();
    data['description'] = this.description;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }

  bool isValid(){
    if(newValue is String && oldValue is String) return newValue != oldValue;
    bool valid = false;
    if(newValue is Map && oldValue is Map){
      newValue.forEach((key, value) {
        if(oldValue[key] != value) valid = true;
      });
    }
    return valid;
  }

  Future<String?> addDescription(String description)async{
    try{
      var res = await sendPostRequest(
        AppConst.addRevisionDescription,
        GlobalData.token,
        {
          'id': id,
          'description': description
        },
      );
      Tools.consoleLog('[Revision.addDescription.res]${res.body}');
      if(res.statusCode==200){
        this.description = description;
        return null;
      }else{
        return jsonDecode(res.body)['message'];
      }
    }catch(e){
      Tools.consoleLog('[Revision.addDescription.err]$e');
      return e.toString();
    }
  }

  Future<String?> accept()async{
    try{
      var res = await sendPostRequest(
          AppConst.acceptRevision,
          GlobalData.token,
          {'id':id.toString()}
      );
      Tools.consoleLog("[Revision.accept.res] ${res.body}");
      if(res.statusCode==200){
        status = "accepted";
        return null;
      }else{
        return jsonDecode(res.body)['message'];
      }
    }catch(e){
      Tools.consoleLog("[Revision.accept.err] $e");
      return e.toString();
    }
  }

  Future<String?> decline()async{
    try{
      var res = await sendPostRequest(
          AppConst.declineRevision,
          GlobalData.token,
          { 'id':id.toString() }
      );
      Tools.consoleLog("[Revision.decline.res] ${res.body}");
      if(res.statusCode==200){
        status = "declined";
        return null;
      }else{
        return jsonDecode(res.body)['message'];
      }
    }catch(e){
      Tools.consoleLog("[Revision.decline.err] $e");
      return e.toString();
    }
  }

  Future<String?> delete()async{
    try{
      var res = await sendPostRequest(
          AppConst.deleteRevision,
          GlobalData.token,
          { 'id':id.toString() }
      );
      Tools.consoleLog("[Revision.delete.res] ${res.body}");
      if(res.statusCode==200){
        return null;
      }else{
        return jsonDecode(res.body)['message'];
      }
    }catch(e){
      Tools.consoleLog("[Revision.delete.err] $e");
      return e.toString();
    }
  }

  Color statusColor(){
    if(status == 'requested') return Colors.orange;
    if(status == 'accepted') return Colors.green;
    return Colors.red;
  }

  bool hasDescription(){
    return description != null;
  }

  Widget statusWidget(BuildContext context){
    String s = S.of(context).sent;
    if(status == 'accepted'){
      s = S.of(context).accepted;
    }else if(status == 'declined'){
      s = S.of(context).declined;
    }
    return Container(
      decoration: BoxDecoration(
        color: statusColor(),
        borderRadius: BorderRadius.circular(30),
      ),
      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Text(s, style: TextStyle(color: Colors.white),),
    );
  }

  String getTime(){
    if(updatedAt == null || updatedAt!.length < 16) return '--:--';
    return updatedAt!.substring(0, 16);
  }

  bool isChanged(String key){
    if(this.newValue == null || this.oldValue == null)return false;
    if(this.type == 'punch'){
      return PunchDateUtils.toStandardDateTime(this.newValue) != PunchDateUtils.toStandardDateTime(this.oldValue);
    }
    var newValue = this.newValue[key];
    var oldValue = this.oldValue[key];
    if(newValue == null && oldValue == null)return false;
    if(newValue == null || oldValue == null)return false;
    if(this.isDateTime(newValue) && this.isDateTime(oldValue)){
      return PunchDateUtils.toStandardDateTime(newValue) != PunchDateUtils.toStandardDateTime(oldValue);
    }
    return newValue != oldValue;
  }

  bool isDateTime(v){
    return DateTime.tryParse(v.toString()) != null;
  }

  String projectTitle({required bool isNewValue}){
    if(isNewValue){
      if(newValue != null && newValue is Map){
        return '${newValue['project_name']} - ${newValue['project_code']??''} \n ${newValue['project_address']??''}'.trim();
      }
    }else{
      if(oldValue != null && oldValue is Map){
        return '${oldValue['project_name']} - ${oldValue['project_code']??''} \n ${oldValue['project_address']??''}'.trim();
      }
    }
    return '';
  }

  String taskTitle({required isNewValue}){
    if(isNewValue){
      if(newValue != null && newValue is Map){
        return '${newValue['task_name']} - ${newValue['task_code']??''}'.trim();
      }
    }else{
      if(oldValue != null && oldValue is Map){
        return '${oldValue['task_name']} - ${oldValue['task_code']??''}'.trim();
      }
    }
    return '';
  }
}