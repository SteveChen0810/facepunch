import 'dart:convert';

import 'package:facepunch/lang/l10n.dart';
import 'base_model.dart';
import '/widgets/calendar_strip/date-utils.dart';
import 'package:flutter/material.dart';

import 'app_const.dart';

class WorkModel extends BaseProvider{
  List<Project> projects = [];
  List<ScheduleTask> tasks = [];

  Future<void> getProjectsAndTasks()async{
    try{
      var res = await sendGetRequest(
        AppConst.getProjectsAndTasks,
        GlobalData.token,
      );
      print('[WorkModel.getProjects]${res.body}');
      if(res.statusCode==200){
        projects.clear();
        for(var project in jsonDecode(res.body)['projects']){
          projects.add(Project.fromJson(project));
        }
        tasks.clear();
        for(var project in jsonDecode(res.body)['tasks']){
          tasks.add(ScheduleTask.fromJson(project));
        }
        notifyListeners();
      }
    }catch(e){
      print('[WorkModel.getProjects]$e');
    }
  }

  Future<String?> startShopTracking({required String token, required int projectId, required int taskId})async{
    try{
      var res = await sendPostRequest(
          AppConst.startShopTracking,
          token,
          {
            'task_id': taskId.toString(),
            'project_id': projectId.toString(),
          }
      );
      print('[ScheduleTask.startShopTracking]${res.body}');
      if(res.statusCode==200){
        return null;
      }else{
        return jsonDecode(res.body)['message'];
      }
    }catch(e){
      print('[ScheduleTask.startShopTracking]$e');
      return e.toString();
    }
  }
}

class Project{
  int? id;
  int? companyId;
  String? name;
  String? companyName;
  String? code;


  Project.fromJson(Map<String, dynamic> json){
    try{
      id = json['id'];
      companyId = json['company_id'];
      companyName = json['company_name'];
      name = json['name'];
      code = json['code'];
    }catch(e){
      print('[Project.fromJson]$e');
    }
  }

}

class ScheduleTask{
  int? id;
  String? name;
  String? code;
  int? companyId;

  ScheduleTask.fromJson(Map<String, dynamic> json){
    try{
      id = json['id'];
      companyId = json['company_id'];
      name = json['name'];
      code = json['code'];
    }catch(e){
      print('[ScheduleTask.fromJson]$e');
    }
  }
}

class WorkHistory{
  int? id;
  int? userId;
  int? punchId;
  int? taskId;
  int? projectId;
  String? start;
  String? end;
  String? createdAt;
  String? updatedAt;
  String? taskName;
  String? projectName;

  WorkHistory({
    this.id,
    this.userId,
    this.taskId,
    this.projectId,
    this.start,
    this.end,
    this.taskName,
    this.projectName
  });

  WorkHistory.fromJson(Map<String, dynamic> json){
    try{
      id = json['id'];
      userId = json['user_id'];
      punchId = json['punch_id'];
      projectId = json['project_id'];
      taskId = json['task_id'];
      taskName = json['task_name'];
      projectName = json['project_name'];
      start = json['start'];
      end = json['end'];
      createdAt = json['created_at'];
      updatedAt = json['updated_at'];
    }catch(e){
      print('[WorkHistory.fromJson]$e');
    }
  }

  double workHour(){
    try{
      final startTime = DateTime.tryParse(start!);
      final endTime = DateTime.tryParse(end!);
      if(startTime == null)return 0.0;
      if(endTime == null)return 0.0;
      return endTime.difference(startTime).inMinutes/60;
    }catch(e){
      print('[WorkHistory.workHour]$e');
    }
    return 0.0;
  }

  DateTime? getStartTime(){
    if(start != null){
      return DateTime.tryParse(start!);
    }
  }

  DateTime? getEndTime(){
    if(end==null || end!.isEmpty) return null;
    return DateTime.tryParse(end!);
  }

  String title(){
    return '${projectName??''} - ${taskName??''}: ${(workHour().toStringAsFixed(2))} h';
  }

  toJson(){
    return {
      'id':id,
      'user_id':userId,
      'punch_id':punchId,
      'start':start,
      'end':end,
      'task_id' : taskId,
      'project_id' : projectId,
      'task_name':taskName,
      'project_name':projectName,
      'created_at':createdAt,
      'updated_at':updatedAt
    };
  }

  bool isEnd(){
    return end != null && end!.isNotEmpty;
  }
}

class WorkSchedule extends BaseModel{
  int? id;
  int? userId;
  int? projectId;
  int? taskId;
  String? projectName;
  String? taskName;
  String? start;
  String? end;
  String? shift;
  String? color;
  String? noAvailable;
  bool? worked;
  String? createdAt;
  String? updatedAt;

  WorkSchedule({
    this.id,
    this.userId,
    this.projectId,
    this.taskId,
    this.projectName,
    this.taskName,
    this.start,
    this.end,
    this.shift,
    this.color,
    this.noAvailable,
    this.createdAt,
    this.updatedAt
  });

  WorkSchedule.fromJson(Map<String, dynamic> json){
    try{
      id = json['id'];
      userId = json['user_id'];
      projectId = json['project_id'];
      taskId = json['task_id'];
      projectName = json['project_name'];
      taskName = json['task_name'];
      start = json['start'];
      end = json['end'];
      shift = json['shift'];
      noAvailable = json['no_available'];
      color = json['color'];
      worked = json['worked'] == 1;
      createdAt = json['created_at'];
      updatedAt = json['updated_at'];
    }catch(e){
      print('[WorkSchedule.fromJson]$e');
    }
  }

  Map<String, dynamic> toJson(){
    return {
      'id':id,
      'user_id':userId,
      'project_id':projectId,
      'task_id':taskId,
      'project_name':projectName,
      'task_name':taskName,
      'start':start,
      'end':end,
      'shift':shift,
      'no_available':noAvailable,
      'color':color,
      'worked':worked,
      'created_at':createdAt,
      'updated_at':updatedAt
    };
  }

  bool isStarted(){
    return (start !=null && start!.isNotEmpty) && (end==null || end!.isEmpty);
  }

  bool isEnded(){
    return (start !=null && start!.isNotEmpty) && (end !=null && end!.isNotEmpty);
  }

  DateTime? getStartTime(){
    return DateTime.tryParse(start!);
  }

  DateTime? getEndTime(){
    return DateTime.tryParse(end!);
  }

  String startTime(){
    if(start == null) return '--:--';
    return start!.substring(11, 16);
  }

  String endTime(){
    if(start == null) return '--:--';
    return end!.substring(11, 16);
  }

  String? isValid(){
    final startTime = getStartTime();
    if(startTime != null){
      int startDiff = startTime.difference(DateTime.now()).inMinutes;
      if(startDiff > 5){
        return 'Why do you start this schedule early?';
      }else if(startDiff < -5){
        return 'Why do you start this schedule late?';
      }
    }
    final endTime = getEndTime();
    if(endTime != null){
      int endDiff = endTime.difference(DateTime.now()).inMinutes;
      if(endDiff > 5){
        return 'Why do you finish this schedule early?';
      }else if(endDiff < -5){
        return 'Why do you finish this schedule late?';
      }
    }
  }

  Future<String?> startSchedule(token)async{
    try{
      var res = await sendPostRequest(
        AppConst.startSchedule,
        token??GlobalData.token,
        { 'id' : id.toString() }
      );
      print('[WorkSchedule.startSchedule]${res.body}');
      if(res.statusCode==200){
        return null;
      }else{
        return jsonDecode(res.body)['message'];
      }
    }catch(e){
      print('[WorkModel.startSchedule]$e');
      return e.toString();
    }
  }

  Future<String?> endSchedule()async{
    try{
      var res = await sendPostRequest(
        AppConst.endSchedule,
        GlobalData.token,
        {'id':id.toString()}
      );
      print('[WorkSchedule.endSchedule]${res.body}');
      if(res.statusCode==200){
        return null;
      }else{
        return jsonDecode(res.body)['message'];
      }
    }catch(e){
      print('[WorkModel.endSchedule]$e');
      return e.toString();
    }
  }

  Future<String?> deleteSchedule()async{
    try{
      var res = await sendPostRequest(
          AppConst.deleteSchedule,
          GlobalData.token,
          {'id':id.toString()}
      );
      print('[WorkSchedule.deleteSchedule]${res.body}');
      if(res.statusCode==200){
        return null;
      }else{
        return jsonDecode(res.body)['message'];
      }
    }catch(e){
      print('[WorkModel.deleteSchedule]$e');
      return e.toString();
    }
  }

  Future<String?> editSchedule()async{
    try{
      var res = await sendPostRequest(
          AppConst.editSchedule,
          GlobalData.token,
          toJson(),
      );
      print('[WorkSchedule.editSchedule]${res.body}');
      if(res.statusCode==200){
        return null;
      }else{
        return jsonDecode(res.body)['message'];
      }
    }catch(e){
      print('[WorkModel.editSchedule]$e');
      return e.toString();
    }
  }

  Future<String?> addSchedule()async{
    try{
      var res = await sendPostRequest(
          AppConst.addSchedule,
          GlobalData.token,
          toJson()
      );
      print('[WorkSchedule.addSchedule]${res.body}');
      if(res.statusCode==200){
        return null;
      }else{
        return jsonDecode(res.body)['message'];
      }
    }catch(e){
      print('[WorkModel.addSchedule]$e');
      return e.toString();
    }
  }
}

class EmployeeCall extends BaseModel{
  int? id;
  int? userId;
  int? projectId;
  int? taskId;
  String? projectName;
  String? taskName;
  String? start;
  String? end;
  String? todo;
  String? note;
  int? priority;
  bool? worked;
  String? createdAt;
  String? updatedAt;

  EmployeeCall({
    this.id,
    this.userId,
    this.projectId,
    this.taskId,
    this.projectName,
    this.taskName,
    this.start,
    this.end,
    this.todo,
    this.note,
    this.priority,
    this.worked,
    this.createdAt,
    this.updatedAt
  });

  EmployeeCall.fromJson(Map<String, dynamic> json){
    try{
      id = json['id'];
      userId = json['user_id'];
      projectId = json['project_id'];
      taskId = json['task_id'];
      projectName = json['project_name'];
      taskName = json['task_name'];
      start = json['start'];
      end = json['end'];
      todo = json['todo'];
      note = json['note'];
      priority = json['priority'];
      worked = json['worked'] == 1;
      createdAt = json['created_at'];
      updatedAt = json['updated_at'];
    }catch(e){
      print('[EmployeeCall.fromJson]$e');
    }
  }

  Map<String, dynamic> toJson(){
    return {
      'id':id,
      'user_id':userId,
      'project_id':projectId,
      'task_id':taskId,
      'project_name':projectName,
      'task_name':taskName,
      'start':start,
      'end':end,
      'todo':todo,
      'note':note,
      'worked':(worked == null || !worked!)?1:0,
      'priority':priority,
      'created_at':createdAt,
      'updated_at':updatedAt
    };
  }

  bool isStarted(){
    return (start !=null && start!.isNotEmpty) && (end == null || end!.isEmpty);
  }

  bool isEnded(){
    return (start !=null && start!.isNotEmpty) && (end !=null && end!.isNotEmpty);
  }

  DateTime? getStartTime(){
    return DateTime.tryParse(start??'');
  }

  DateTime? getEndTime(){
    return DateTime.tryParse(end??'');
  }

  String startTime(){
    if(start == null || start!.length < 16) return '--:--';
    return start!.substring(11, 16);
  }

  String endTime(){
    if(end == null || end!.length < 16) return '--:--';
    return end!.substring(11, 16);
  }

  Future<String?> startCall(String token)async{
    try{
      var res = await sendPostRequest(
          AppConst.startCall,
          token,
          {'id':id.toString()}
      );
      print('[EmployeeCall.startCall]${res.body}');
      if(res.statusCode==200){
        return null;
      }else{
        return jsonDecode(res.body)['message'];
      }
    }catch(e){
      print('[EmployeeCall.startSchedule]$e');
      return e.toString();
    }
  }

  Future<String?> addEditCall()async{
    try{
      var res = await sendPostRequest(
        AppConst.addEditCall,
        GlobalData.token,
        toJson(),
      );
      print('[EmployeeCall.addEditCall]${res.body}');
      if(res.statusCode==200){
        return null;
      }else{
        return jsonDecode(res.body)['message'];
      }
    }catch(e){
      print('[EmployeeCall.addEditCall]$e');
      return e.toString();
    }
  }

  Color color(){
    List<Color> colors = [
      Colors.blue,
      Colors.green,
      Colors.teal,
      Colors.amber,
      Colors.brown,
      Colors.cyan,
      Colors.indigo,
      Colors.orange,
      Colors.pink,
      Colors.purple,
      Colors.teal,
    ];
    if(id==null) return Colors.blue;
    return colors[id!%11];
  }
}

class EmployeeBreak{
  int? id;
  int? userId;
  int? punchId;
  String? title;
  String? start;
  int? length;
  bool? calculate;
  String? createdAt;
  String? updatedAt;

  EmployeeBreak.fromJson(Map<String, dynamic> json){
    try{
      id = json['id'];
      userId = json['user_id'];
      punchId = json['punch_id'];
      title = json['title'];
      start = json['start'];
      length = json['length'];
      calculate = json['calculate']==1;
      createdAt = json['created_at'];
      updatedAt = json['updated_at'];
    }catch(e){
      print('[EmployeeBreak.fromJson]$e');
    }
  }

  String getTitle(BuildContext context){
    if(createdAt == null){
      return '$title ${S.of(context).at} --:--, $length Minutes';
    }
    return '$title ${S.of(context).at} ${PunchDateUtils.getTimeString(DateTime.tryParse(createdAt!))}, $length Minutes';
  }

  Map<String, dynamic> toJson(){
    return {
      'id':id,
      'user_id':userId,
      'punch_id':punchId,
      'start':start,
      'title':title,
      'length':length,
      'calculate':(calculate!= null && calculate!)?1:0,
      'created_at':createdAt,
      'updated_at':updatedAt
    };
  }
}