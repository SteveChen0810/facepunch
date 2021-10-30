import 'dart:convert';

import 'package:facepunch/lang/l10n.dart';
import 'package:facepunch/widgets/calendar_strip/date-utils.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'app_const.dart';

class WorkModel with ChangeNotifier{
  List<Project> projects = [];
  List<ScheduleTask> tasks = [];

  Future<void> getProjectsAndTasks()async{
    try{
      var res = await http.get(
        AppConst.getProjectsAndTasks,
        headers: {
          'Accept':'application/json',
          'Content-Type':'application/x-www-form-urlencoded',
          'Authorization':'Bearer '+GlobalData.token
        },
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

  Future<String> startShopTracking({String token,int projectId, int taskId})async{
    try{
      var res = await http.post(
          AppConst.startShopTracking,
          headers: {
            'Accept':'application/json',
            'Content-Type':'application/x-www-form-urlencoded',
            'Authorization':'Bearer '+token
          },
          body: {
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
  int id;
  int companyId;
  String name;
  String companyName;
  String code;


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
  int id;
  String name;
  String code;
  int companyId;

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
  int id;
  int userId;
  int punchId;
  int taskId;
  int projectId;
  String start;
  String end;
  String createdAt;
  String updatedAt;
  String taskName;
  String projectName;

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
      if(end==null || end.isEmpty)return 0.0;
      final startTime = DateTime.parse(start);
      final endTime = DateTime.parse(end);
      return endTime.difference(startTime).inMinutes/60;
    }catch(e){
      print('[WorkHistory.workHour]$e');
    }
    return 0.0;
  }

  DateTime getStartTime(){
    return DateTime.parse(start);
  }

  DateTime getEndTime(){
    if(end==null || end.isEmpty) return null;
    return DateTime.parse(end);
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
    return end != null && end.isNotEmpty;
  }
}

class WorkSchedule{
  int id;
  int userId;
  int projectId;
  int taskId;
  String projectName;
  String taskName;
  String start;
  String end;
  String shift;
  String color;
  String noAvailable;
  bool worked;
  String createdAt;
  String updatedAt;

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
    return (start !=null && start.isNotEmpty) && (end==null || end.isEmpty);
  }

  bool isEnded(){
    return (start !=null && start.isNotEmpty) && (end !=null && end.isNotEmpty);
  }

  DateTime getStartTime(){
    return DateTime.parse(start);
  }

  DateTime getEndTime(){
    return DateTime.parse(end);
  }

  String startTime(){
    return start.substring(11, 16);
  }

  String endTime(){
    return end.substring(11, 16);
  }

  String isValid(){
    int startDiff = getStartTime().difference(DateTime.now()).inMinutes;
    if(startDiff > 5){
      return 'Why do you start this schedule early?';
    }else if(startDiff < -5){
      return 'Why do you start this schedule late?';
    }
    int endDiff = getEndTime().difference(DateTime.now()).inMinutes;
    if(endDiff > 5){
      return 'Why do you finish this schedule early?';
    }else if(endDiff < -5){
      return 'Why do you finish this schedule late?';
    }
    return null;
  }

  Future<String> startSchedule(token)async{
    try{
      var res = await http.post(
        AppConst.startSchedule,
        headers: {
          'Accept':'application/json',
          'Content-Type':'application/x-www-form-urlencoded',
          'Authorization':'Bearer '+ token??GlobalData.token
        },
        body: {
          'id' : id.toString()
        }
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

  Future<String> endSchedule()async{
    try{
      var res = await http.post(
        AppConst.endSchedule,
        headers: {
          'Accept':'application/json',
          'Content-Type':'application/x-www-form-urlencoded',
          'Authorization':'Bearer '+GlobalData.token
        },
        body: {'id':id.toString()}
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

  Future<String> deleteSchedule()async{
    try{
      var res = await http.post(
          AppConst.deleteSchedule,
          headers: {
            'Accept':'application/json',
            'Content-Type':'application/x-www-form-urlencoded',
            'Authorization':'Bearer '+GlobalData.token
          },
          body: {'id':id.toString()}
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

  Future<String> editSchedule()async{
    try{
      var res = await http.post(
          AppConst.editSchedule,
          headers: {
            'Accept':'application/json',
            'Content-Type':'application/json',
            'Authorization':'Bearer '+GlobalData.token
          },
          body: jsonEncode(toJson()),
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

  Future<String> addSchedule()async{
    try{
      var res = await http.post(
          AppConst.addSchedule,
          headers: {
            'Accept':'application/json',
            'Content-Type':'application/json',
            'Authorization':'Bearer '+GlobalData.token
          },
          body: jsonEncode(toJson()),
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

class EmployeeCall{
  int id;
  int userId;
  int projectId;
  int taskId;
  String projectName;
  String taskName;
  String start;
  String end;
  String todo;
  String note;
  int priority;
  bool worked;
  String createdAt;
  String updatedAt;

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
      'worked':(worked == null || !worked)?1:0,
      'priority':priority,
      'created_at':createdAt,
      'updated_at':updatedAt
    };
  }

  bool isStarted(){
    return (start !=null && start.isNotEmpty) && (end==null || end.isEmpty);
  }

  bool isEnded(){
    return (start !=null && start.isNotEmpty) && (end !=null && end.isNotEmpty);
  }

  DateTime getStartTime(){
    return DateTime.parse(start);
  }

  DateTime getEndTime(){
    return DateTime.parse(end);
  }

  String startTime(){
    return start.substring(11, 16);
  }

  String endTime(){
    return end.substring(11, 16);
  }

  Future<String> startCall(String token)async{
    try{
      var res = await http.post(
          AppConst.startCall,
          headers: {
            'Accept':'application/json',
            'Content-Type':'application/x-www-form-urlencoded',
            'Authorization':'Bearer '+token
          },
          body: {'id':id.toString()}
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

  Future<String> addEditCall()async{
    try{
      var res = await http.post(
        AppConst.addEditCall,
        headers: {
          'Accept':'application/json',
          'Content-Type':'application/json',
          'Authorization':'Bearer '+GlobalData.token
        },
        body: jsonEncode(toJson()),
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
    return colors[id%11];
  }
}

class EmployeeBreak{
  int id;
  int userId;
  int punchId;
  String title;
  String start;
  int length;
  bool calculate;
  String createdAt;
  String updatedAt;

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
    return '$title ${S.of(context).at} ${PunchDateUtils.getTimeString(DateTime.parse(createdAt))}, $length Minutes';
  }

  Map<String, dynamic> toJson(){
    return {
      'id':id,
      'user_id':userId,
      'punch_id':punchId,
      'start':start,
      'title':title,
      'length':length,
      'calculate':calculate?1:0,
      'created_at':createdAt,
      'updated_at':updatedAt
    };
  }
}