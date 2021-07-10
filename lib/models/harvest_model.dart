import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:localstorage/localstorage.dart';
import 'dart:convert';

import 'app_const.dart';
import 'user_model.dart';

class HarvestModel extends ChangeNotifier{
  final LocalStorage storage = LocalStorage('harvest');
  List<Field> fields = [];
  List<HContainer> containers = [];
  List<HTask> tasks = [];

  Future getFields()async{
    await getFieldsFromLocal();
    await getFieldsFromServer();
  }

  Future getFieldsFromServer()async{
    try{
      var res = await http.get(
        AppConst.getAllFields,
        headers: {
          'Accept':'application/json',
          'Content-Type':'application/json',
          'Authorization':'Bearer '+GlobalData.token
        },
      );
      print('[getFieldsFromServer] ${res.body}');
      if(res.statusCode==200){
        fields.clear();
        for(var json in jsonDecode(res.body)){
          fields.add(Field.fromJson(json));
        }
        saveFieldsToLocal();
      }
    }catch(e){

    }
  }

  Future<void> getFieldsFromLocal()async{
    try {
      final ready = await storage.ready;
      if (ready) {
        var json = storage.getItem('fields');
        if(json!=null){
          fields.clear();
          for(var f in json){
            fields.add(Field.fromJson(f));
          }
        }
      }
      notifyListeners();
    } catch (err) {
      print("[getFieldsFromLocal] $err");
    }
  }

  Future<void> saveFieldsToLocal() async {
    try {
      final ready = await storage.ready;
      if (ready) {
        await storage.setItem('fields', fields.map((v) => v.toJson()).toList());
      }
      notifyListeners();
    } catch (e) {
      print("[saveFieldsToLocal] $e");
    }
  }

  Future<String> createOrUpdateField(Field field)async{
    try{
      var res = await http.post(
          AppConst.createOrUpdateFiled,
          headers: {
            'Accept':'application/json',
            'Content-Type':'application/json',
            'Authorization':'Bearer '+GlobalData.token
          },
          body: jsonEncode(field.toJson())
      );
      print('[HarvestModel.createOrUpdateField] ${res.body}');
      if(res.statusCode==200){
        if(field.id==null){
          field = Field.fromJson(jsonDecode(res.body));
          fields.add(field);
          notifyListeners();
        }
        saveFieldsToLocal();
        return null;
      }else{
        return jsonDecode(res.body)['message'];
      }
    }catch(e){
      print('[HarvestModel.createOrUpdateField] $e');
     return e.toString();
    }
  }

  Future<String> deleteField(Field field)async{
    try{
      var res = await http.post(
          AppConst.deleteField,
          headers: {
            'Accept':'application/json',
            'Content-Type':'application/json',
            'Authorization':'Bearer '+GlobalData.token
          },
          body: jsonEncode(field.toJson())
      );
      print('[HarvestModel.deleteField] ${res.body}');
      if(res.statusCode==200){
        fields.remove(field);
        notifyListeners();
        saveFieldsToLocal();
        return null;
      }else{
        return jsonDecode(res.body)['message'];
      }
    }catch(e){
      print('[HarvestModel.deleteField] $e');
      return e.toString();
    }
  }

  Future getContainers()async{
    await getContainersFromLocal();
    await getContainersFromServer();
  }

  Future getContainersFromServer()async{
    try{
      var res = await http.get(
        AppConst.getAllContainers,
        headers: {
          'Accept':'application/json',
          'Content-Type':'application/json',
          'Authorization':'Bearer '+GlobalData.token
        },
      );
      print('[getContainersFromServer] ${res.body}');
      if(res.statusCode==200){
        containers.clear();
        for(var json in jsonDecode(res.body)){
          containers.add(HContainer.fromJson(json));
        }
        saveContainersToLocal();
      }
    }catch(e){

    }
  }

  Future<void> getContainersFromLocal()async{
    try {
      final ready = await storage.ready;
      if (ready) {
        var json = storage.getItem('containers');
        if(json!=null){
          containers.clear();
          for(var c in json){
            containers.add(HContainer.fromJson(c));
          }
        }
      }
      notifyListeners();
    } catch (err) {
      print("[getContainersFromLocal] $err");
    }
  }

  Future<void> saveContainersToLocal() async {
    try {
      final ready = await storage.ready;
      if (ready) {
        await storage.setItem('containers', containers.map((v) => v.toJson()).toList());
      }
      notifyListeners();
    } catch (e) {
      print("[saveFieldsToLocal] $e");
    }
  }

  Future<String> createOrUpdateContainer(HContainer container)async{
    try{
      var res = await http.post(
          AppConst.createOrUpdateContainer,
          headers: {
            'Accept':'application/json',
            'Content-Type':'application/json',
            'Authorization':'Bearer '+GlobalData.token
          },
          body: jsonEncode(container.toJson())
      );
      print('[HarvestModel.createOrUpdateContainer] ${res.body}');
      if(res.statusCode==200){
        if(container.id==null){
          container = HContainer.fromJson(jsonDecode(res.body));
          containers.add(container);
          notifyListeners();
        }
        saveContainersToLocal();
        return null;
      }else{
        return jsonDecode(res.body)['message'];
      }
    }catch(e){
      print('[HarvestModel.createOrUpdateContainer] $e');
      return e.toString();
    }
  }

  Future<String> deleteContainer(HContainer container)async{
    try{
      var res = await http.post(
          AppConst.deleteContainer,
          headers: {
            'Accept':'application/json',
            'Content-Type':'application/json',
            'Authorization':'Bearer '+GlobalData.token
          },
          body: jsonEncode(container.toJson())
      );
      print('[HarvestModel.deleteContainer] ${res.body}');
      if(res.statusCode==200){
        containers.remove(container);
        notifyListeners();
        saveContainersToLocal();
        return null;
      }else{
        return jsonDecode(res.body)['message'];
      }
    }catch(e){
      print('[HarvestModel.deleteContainer] $e');
      return e.toString();
    }
  }


  Future getHarvestTasks()async{
    await getTasksFromLocal();
    await getTasksFromServer();
  }

  Future getTasksFromServer()async{
    try{
      var res = await http.get(
        AppConst.getAllTasks,
        headers: {
          'Accept':'application/json',
          'Content-Type':'application/json',
          'Authorization':'Bearer '+GlobalData.token
        },
      );
      print('[getTasksFromServer] ${res.body}');
      if(res.statusCode==200){
        tasks.clear();
        for(var json in jsonDecode(res.body)){
          tasks.add(HTask.fromJson(json));
        }
        saveTasksToLocal();
      }
    }catch(e){

    }
  }

  Future<void> getTasksFromLocal()async{
    try {
      final ready = await storage.ready;
      if (ready) {
        var json = storage.getItem('tasks');
        if(json!=null){
          tasks.clear();
          for(var t in json){
            tasks.add(HTask.fromJson(t));
          }
        }
      }
      notifyListeners();
    } catch (err) {
      print("[getTasksFromLocal] $err");
    }
  }

  Future<void> saveTasksToLocal() async {
    try {
      final ready = await storage.ready;
      if (ready) {
        await storage.setItem('tasks', tasks.map((v) => v.toJson()).toList());
      }
      notifyListeners();
    } catch (e) {
      print("[saveTasksToLocal] $e");
    }
  }

  Future<String> deleteTask(HTask task)async{
    try{
      var res = await http.post(
        AppConst.deleteTask,
        headers: {
          'Accept':'application/json',
          'Content-Type':'application/json',
          'Authorization':'Bearer '+GlobalData.token
        },
        body: jsonEncode(task.toJson()),
      );
      print('[deleteTask]${res.body}');
      if(res.statusCode==200){
        tasks.remove(task);
        await saveTasksToLocal();
        return null;
      }else{
        return jsonDecode(res.body)['message'];
      }
    }catch(e){
      print('[deleteTask] $e');
      return e.toString();
    }
  }

  Future<String> createOrUpdateTask(HTask task)async{
    try{
      var res = await http.post(
        AppConst.createOrUpdateTask,
        headers: {
          'Accept':'application/json',
          'Content-Type':'application/json',
          'Authorization':'Bearer '+GlobalData.token
        },
        body: jsonEncode(task.toJson()),
      );
      print('[createOrUpdateTask]${res.body}');
      if(res.statusCode==200){
        final newTask = HTask.fromJson(jsonDecode(res.body));
        tasks.removeWhere((t) => t.id==newTask.id);
        newTask.container = task.container;
        newTask.field = task.field;
        tasks.add(newTask);
        await saveTasksToLocal();
        notifyListeners();
      }else{
        return jsonDecode(res.body)['message'];
      }
      return null;
    }catch(e){
      print('[HarvestModel.createOrUpdateContainer] $e');
      return e.toString();
    }
  }

  Future<List<Harvest>> getHarvestsOfDate(String date)async{
    try{
      List<Harvest> harvests = [];
      var res = await http.post(
        AppConst.getHarvestsOfDate,
        headers: {
          'Accept':'application/json',
          'Content-Type':'application/json',
          'Authorization':'Bearer '+GlobalData.token
        },
        body: jsonEncode({'date':date}),
      );
      print('[getHarvestsOfDate] ${res.body}');
      if(res.statusCode==200){
        for(var json in jsonDecode(res.body)){
          harvests.add(Harvest.fromJson(json));
        }
        return harvests;
      }
    }catch(e){
      print('[HarvestModel.getHarvestsOfDate] $e');
    }
    return [];
  }

  Future addHarvest({HTask task,String date,String nfc})async{
    try{
      var res = await http.post(
        AppConst.addHarvest,
        headers: {
          'Accept':'application/json',
          'Content-Type':'application/json',
          'Authorization':'Bearer '+GlobalData.token
        },
        body: jsonEncode({
          'container_id':task.container.id,
          'field_id':task.field.id,
          'date':date,
          'quantity':1.0,
          'nfc':nfc
        }),
      );
      print('[addHarvest] ${res.body}');
      if(res.statusCode==200){
        return Harvest.fromJson(jsonDecode(res.body));
      }else{
        return jsonDecode(res.body)['message'];
      }
    }catch(e){
      print('[HarvestModel.addHarvest] $e');
    }
    return null;
  }
  Future deleteHarvest(int id)async{
    try{
      var res = await http.post(
        AppConst.deleteHarvest,
        headers: {
          'Accept':'application/json',
          'Content-Type':'application/json',
          'Authorization':'Bearer '+GlobalData.token
        },
        body: jsonEncode({'id':id}),
      );
      print('[deleteHarvest] ${res.body}');
      if(res.statusCode==200){
        return Harvest.fromJson(jsonDecode(res.body));
      }else{
        return jsonDecode(res.body)['message'];
      }
    }catch(e){
      print('[HarvestModel.deleteHarvest] $e');
    }
    return null;
  }

  Future getEmployeeHarvestStats({String date, int field})async{
    try{
      var res = await http.post(
        AppConst.getEmployeeHarvestStats,
        headers: {
          'Accept':'application/json',
          'Content-Type':'application/json',
          'Authorization':'Bearer '+GlobalData.token
        },
        body: jsonEncode({
          'date':date,
          'field':field,
        }),
      );
      print('[getEmployeeHarvestStats]${res.body}');
      if(res.statusCode==200){
        List<HarvestEmployeeStats> eStats = [];
        final json = jsonDecode(res.body);
        for(var stats in json){
          eStats.add(HarvestEmployeeStats.fromJson(stats));
        }
        return eStats;
      }else{
        return jsonDecode(res.body)['message'];
      }
    }catch(e){
      print('[getEmployeeHarvestStats]$e');
      return e.toString();
    }
  }

  Future getCompanyHarvestStats({String date, int field})async{
    try{
      var res = await http.post(
        AppConst.getCompanyHarvestStats,
        headers: {
          'Accept':'application/json',
          'Content-Type':'application/json',
          'Authorization':'Bearer '+GlobalData.token
        },
        body: jsonEncode({
          'date':date,
          'field':field,
        }),
      );
      print('[getCompanyHarvestStats]${res.body}');
      if(res.statusCode==200){
        return HarvestCompanyStats.fromJson(jsonDecode(res.body));
      }else{
        return jsonDecode(res.body)['message'];
      }
    }catch(e){
      print('[getEmployeeHarvestStats]$e');
      return e.toString();
    }
  }

  Future getDateHarvestStats(String date)async{
    try{
      var res = await http.post(
        AppConst.getDateHarvestStats,
        headers: {
          'Accept':'application/json',
          'Content-Type':'application/json',
          'Authorization':'Bearer '+GlobalData.token
        },
        body: jsonEncode({
          'date':date,
        }),
      );
      print('[getDateHarvestStats]${res.body}');
      if(res.statusCode==200){
        List<HarvestDateStats> dateStats = [];
        for(var stats in jsonDecode(res.body))
          dateStats.add(HarvestDateStats.fromJson(stats));
        return dateStats;
      }else{
        return jsonDecode(res.body)['message'];
      }
    }catch(e){
      print('[getDateHarvestStats]$e');
      return e.toString();
    }
  }
}

class Harvest{
  int id;
  int userId;
  int fieldId;
  int containerId;
  int companyId;
  double quantity;
  String createdAt;
  String updatedAt;
  User user;
  HContainer container;
  Field field;

  Harvest.fromJson(Map<String, dynamic> json) {
    try{
      id = json['id'];
      userId = json['user_id'];
      fieldId = json['field_id'];
      containerId = json['container_id'];
      companyId = json['company_id'];
      quantity = double.tryParse(json['quantity'].toString());
      createdAt = json['created_at'];
      updatedAt = json['updated_at'];
      if(json['user']!=null)user = User.fromJson(json['user']);
      if(json['field']!=null)field = Field.fromJson(json['field']);
      if(json['container']!=null)container = HContainer.fromJson(json['container']);
    }catch(e){
      print("[Field.fromJson] $e");
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['field_id'] = this.fieldId;
    data['container_id'] = this.containerId;
    data['company_id'] = this.companyId;
    data['quantity'] = this.quantity;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}

class HTask{
  int id;
  int companyId;
  int containerId;
  int fieldId;
  Field field;
  HContainer container;

  HTask({
    this.id,
    this.companyId,
    this.containerId,
    this.fieldId,
    this.field,
    this.container,
  });

  HTask.fromJson(Map<String, dynamic> json) {
    try{
      id = json['id'];
      companyId = json['company_id'];
      containerId = json['container_id'];
      fieldId = json['field_id'];
      if(json['field']!=null)field = Field.fromJson(json['field']);
      if(json['container']!=null)container = HContainer.fromJson(json['container']);
    }catch(e){
      print("[Field.fromJson] $e");
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = this.id;
    data['company_id'] = this.companyId;
    data['container_id'] = this.containerId;
    data['field_id'] = this.fieldId;
    data['field'] = this.field?.toJson();
    data['container'] = this.container?.toJson();
    return data;
  }

}

class HContainer{
  int id;
  String name;
  int companyId;
  String createdAt;
  String updatedAt;

  HContainer({this.id,this.name,this.companyId,this.createdAt,this.updatedAt});

  HContainer.fromJson(Map<String, dynamic> json) {
    try{
      id = json['id'];
      name = json['name'];
      companyId = json['company_id'];
      createdAt = json['created_at'];
      updatedAt = json['updated_at'];
    }catch(e){
      print("[Field.fromJson] $e");
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['company_id'] = this.companyId;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}

class Field{
  int id;
  String name;
  String crop;
  String cropVariety;
  int companyId;
  String createdAt;
  String updatedAt;

  Field({
    this.id,
    this.name,
    this.crop,
    this.cropVariety,
    this.companyId,
    this.createdAt,
    this.updatedAt
  });

  Field.fromJson(Map<String, dynamic> json) {
    try{
      id = json['id'];
      name = json['name'];
      crop = json['crop'];
      cropVariety = json['crop_variety'];
      companyId = json['company_id'];
      createdAt = json['created_at'];
      updatedAt = json['updated_at'];
    }catch(e){
      print("[Field.fromJson] $e");
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['crop'] = this.crop;
    data['crop_variety'] = this.cropVariety;
    data['company_id'] = this.companyId;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}

class HarvestEmployeeStats{
  int userId;
  String employeeName;
  double time;
  double quantity;

  HarvestEmployeeStats.fromJson(Map<String, dynamic> json){
    try{
      userId = json['id'];
      employeeName = json['name'];
      time = double.tryParse(json['time'].toString())??0.0;
      quantity = double.tryParse(json['quantity'].toString())??0.0;
    }catch(e){
      print('[HarvestEmployeeStats.fromJson]$e');
    }
  }
}

class HarvestCompanyStats{
  double harvestTimeOfDate;
  double harvestTimeOfYear;
  double quantityOfDate;
  double quantityOfYear;
  List containersOfDate;
  List containersOfYear;

  HarvestCompanyStats.fromJson(Map<String, dynamic> json){
    try{
      harvestTimeOfDate = double.tryParse(json['date']['time'].toString())??0.0;
      harvestTimeOfYear = double.tryParse(json['year']['time'].toString())??0.0;
      quantityOfDate = double.tryParse(json['date']['quantity'].toString())??0.0;
      quantityOfYear = double.tryParse(json['year']['quantity'].toString())??0.0;
      containersOfDate = json['date']['containers'];
      containersOfYear = json['year']['containers'];
    }catch(e){
      print('[HarvestCompanyStats.fromJson]$e');
    }
  }

}

class HarvestDateStats{
  int fieldId;
  String fieldName;
  List containers;

  HarvestDateStats.fromJson(Map<String, dynamic> json){
    try{
      fieldId = json['id'];
      fieldName = json['name'];
      containers = json['containers'];
    }catch(e){
      print('[HarvestCompanyStats.fromJson]$e');
    }
  }

  double getTotalQuantity(){
    double quantity = 0;
    try{
      for(var c in containers){
        quantity += double.tryParse(c['quantity'].toString())??0;
      }
    }catch(e){
      print(e);
    }
    return quantity;
  }
}