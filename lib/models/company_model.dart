import 'user_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'app_const.dart';
import 'package:localstorage/localstorage.dart';

class CompanyModel extends ChangeNotifier{
  final LocalStorage storage = LocalStorage('companies');
  Company myCompany;
  CompanySettings myCompanySettings;
  List<User> users = [];

  Future<bool> getMyCompany(int companyId)async{
    await getCompanyFromLocal();
    await getCompanySettingsFromLocal();
    if(myCompany==null || myCompany.id!=companyId || myCompanySettings==null){
      await getCompanyFromServer();
      await getCompanySettingsFromServer();
    }else{
      getCompanyFromServer();
      getCompanySettingsFromServer();
    }
    return myCompany!=null && myCompanySettings!=null;
  }

  getCompanyFromServer()async{
    try{
      var res = await http.get(
          AppConst.getMyCompany,
          headers: {
            'Accept':'application/json',
            'Content-Type':'application/x-www-form-urlencoded',
            'Authorization':'Bearer '+GlobalData.token
          },
      );
      print("[CompanyModel.getCompanyFromServer] ${res.body}");
      if(res.statusCode==200){
        myCompany = Company.fromJson(jsonDecode(res.body));
        await saveCompanyToLocal();
      }
    }catch(e){
      print("[CompanyModel.getCompanyFromServer] $e");
    }
    notifyListeners();
  }
  saveCompanyToLocal()async{
    try{
      bool storageReady = await storage.ready;
      if(storageReady)
        await storage.setItem('my_company',myCompany.toJson());
    }catch(e){
      print("[CompanyModel.saveCompanyToLocal] $e");
    }
  }
  getCompanyFromLocal()async{
    try{
      bool storageReady = await storage.ready;
      if(storageReady){
        var json = await storage.getItem('my_company');
        if(json!=null){
          myCompany = Company.fromJson(json);
        }
      }
    }catch(e){
      print("[CompanyModel.getCompanyFromLocal] $e");
    }
    notifyListeners();
  }

  Future<String> createEditEmployee(User user,String photo)async{
    String result = 'Oops, Unknown Errors!';
    try{
      user.companyId = myCompany.id;
      var userData = user.toJson();
      if(photo!=null){userData['photo'] = photo;}
      var res = await http.post(
          AppConst.addEditEmployee,
          headers: {
            'Accept':'application/json',
            'Content-Type':'application/json',
            'Authorization':'Bearer '+GlobalData.token
          },
          body: jsonEncode(userData)
      );
      print("[CompanyModel.createEditEmployee] ${res.body}");
      if(res.statusCode==200){
        if(user.id!=null){
          user = users.firstWhere((u) => u.id == user.id,orElse: ()=>null);
          Punch punch = user.lastPunch;
          users.removeWhere((u) => u.id == user.id);
          user = User.fromJson(jsonDecode(res.body));
          user.lastPunch = punch;
          users.add(user);
        }else{
          users.add(User.fromJson(jsonDecode(res.body)));
        }
        notifyListeners();
        result =  null;
      }else{
        result =  jsonDecode(res.body)['message'].toString();
      }
    }catch(e){
      print("[CompanyModel.createEditEmployee] $e");
      result = e.toString();
    }
    return result;
  }

  Future<String> getCompanyUsers()async{
    try{
      var res = await http.get(
          AppConst.getCompanyEmployees,
          headers: {
            'Accept':'application/json',
            'Content-Type':'application/json',
            'Authorization':'Bearer '+GlobalData.token
          },
      );
      print("[CompanyModel.getCompanyUsers] ${res.body}");
      if(res.statusCode==200){
        users.clear();
        for(var json in jsonDecode(res.body))
          users.add(User.fromJson(json));
        notifyListeners();
        return null;
      }else{
        return jsonDecode(res.body)['message'];
      }
    }catch(e){
      print("[CompanyModel.getCompanyUsers] $e");
      return e.toString();
    }
  }

  Future<String> deleteEmployee(int userId)async{
    String result = 'Oops, Unknown Errors!';
    try{
      var res = await http.post(
        AppConst.deleteEmployee,
        headers: {
          'Accept':'application/json',
          'Content-Type':'application/json',
          'Authorization':'Bearer '+GlobalData.token
        },
        body: jsonEncode({'user_id':userId})
      );
      print("[CompanyModel.deleteEmployee] ${res.body}");
      if(res.statusCode==200){
        users.removeWhere((u) => u.id==userId);
        notifyListeners();
        return "A employee has been deleted.";
      }else{
        return jsonDecode(res.body)['message'];
      }
    }catch(e){
      print("[CompanyModel.deleteEmployee] $e");
    }
    return result;
  }

  Future<String> updateCompany({String name, String address1, String address2,
    String country, String state, String city, String postalCode, String phone})async{
    String result = 'Oops, Unknown Errors!';
    try{
      var res = await http.post(
          AppConst.updateCompany,
          headers: {
            'Accept':'application/json',
            'Content-Type':'application/json',
            'Authorization':'Bearer '+GlobalData.token
          },
          body: jsonEncode(
              {
                'name':name,
                'address1' : address1,
                'address2' : address2,
                'city' : city,
                'country' : country,
                'state' : state,
                'postal_code' : postalCode,
                'phone' : phone
              }
          )
      );
      print("[CompanyModel.updateCompany] ${res.body}");
      if(res.statusCode==200){
        myCompany = Company.fromJson(jsonDecode(res.body));
        await saveCompanyToLocal();
        result =  null;
      }else{
        result =  jsonDecode(res.body)['message'].toString();
      }
    }catch(e){
      print("[CompanyModel.updateCompany] $e");
    }
    return result;
  }

  Future<String> getCompanySettingsFromServer()async{
    try{
      var res = await http.get(
          AppConst.getCompanySettings,
          headers: {
            'Accept':'application/json',
            'Content-Type':'application/json',
            'Authorization':'Bearer '+GlobalData.token
          }
      );
      print("[CompanyModel.getCompanySettings] ${res.body}");
      if(res.statusCode==200){
        myCompanySettings = CompanySettings.fromJson(jsonDecode(res.body));
        await saveCompanySettingsToLocal();
        return null;
      }else{
        return jsonDecode(res.body)['message'];
      }
    }catch(e){
      print("[CompanyModel.getCompanySettings] $e");
      return e.toString();
    }
  }
  getCompanySettingsFromLocal()async{
    try{
      bool storageReady = await storage.ready;
      if(storageReady){
        var json = await storage.getItem('company_settings');
        if(json!=null){
          myCompanySettings = CompanySettings.fromJson(json);
          notifyListeners();
        }
      }
    }catch(e){
      print("[CompanyModel.getCompanyFromLocal] $e");
    }
    notifyListeners();
  }
  saveCompanySettingsToLocal()async{
    try{
      bool storageReady = await storage.ready;
      if(storageReady)
        await storage.setItem('company_settings', myCompanySettings.toJson());
      notifyListeners();
    }catch(e){
      print("[CompanyModel.saveCompanySettingsToLocal] $e");
    }
  }

  Future<String> updateCompanySetting(CompanySettings settings)async{
    try{
      var res = await http.post(
          AppConst.updateCompanySettings,
          headers: {
            'Accept':'application/json',
            'Content-Type':'application/json',
            'Authorization':'Bearer '+GlobalData.token
          },
          body: jsonEncode(settings.toJson())
      );
      print("[CompanyModel.updateCompanySetting] ${res.body}");
      if(res.statusCode==200){
        myCompanySettings = settings;
        saveCompanySettingsToLocal();
        return null;
      }else{
        return jsonDecode(res.body)['message'];
      }
    }catch(e){
      print("[CompanyModel.updateCompanySetting] $e");
      return e.toString();
    }
  }

  Future<String> punchByAdmin({int userId,String action,double longitude,double latitude, String punchTime})async{
    try{
      var res = await http.post(
          AppConst.punchByAdmin,
          headers: {
            'Accept':'application/json',
            'Content-Type':'application/json',
            'Authorization':'Bearer '+GlobalData.token
          },
          body: jsonEncode({
            'user_id':userId,
            'action':action,
            'longitude':longitude,
            'latitude':latitude,
            'punch_time':punchTime,
          })
      );
      print("[CompanyModel.punchByAdmin] ${res.body}");
      if(res.statusCode==200){
        final punch = Punch.fromJson(jsonDecode(res.body));
        users.firstWhere((u) => u.id==userId).lastPunch = punch;
        notifyListeners();
        return null;
      }else{
        return jsonDecode(res.body)['message'];
      }
    }catch(e){
      print("[CompanyModel.punchByAdmin] $e");
      return e.toString();
    }
  }
}

class Company {
  int id;
  int adminId;
  String name;
  int plan;
  String createdAt;
  String updatedAt;

  Company({
    this.id,
    this.adminId,
    this.name,
    this.plan,
    this.createdAt,
    this.updatedAt
  });

  Company.fromJson(Map<String, dynamic> json) {
    try{
      id = json['id'];
      adminId = json['admin_id'];
      name = json['name'];
      plan = json['plan'];
      createdAt = json['created_at'];
      updatedAt = json['updated_at'];
    }catch(e){
      print("[User.fromJson] $e");
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['admin_id'] = this.adminId;
    data['name'] = this.name;
    data['plan'] = this.plan;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}

class CompanySettings{
  String lowValue;
  String lowColor;
  String mediumColor;
  String highValue;
  String highColor;
  String lastUpdated;
  String reportTime;
  bool hasNFCHarvest;
  bool hasNFCReport;
  bool hasHarvestReport;
  bool hasTimeSheetRevision;
  bool hasTimeSheetSchedule;
  bool hasGeolocationPunch;
  bool useOwnData;

  bool receivePunchNotification;
  bool receiveRevisionNotification;



  CompanySettings({
    this.lowValue,
    this.lowColor,
    this.mediumColor,
    this.highValue,
    this.highColor,
    this.lastUpdated,
    this.reportTime,
    this.hasNFCHarvest,
    this.hasNFCReport,
    this.hasHarvestReport,
    this.hasTimeSheetRevision,
    this.hasTimeSheetSchedule,
    this.hasGeolocationPunch,
    this.receivePunchNotification,
    this.receiveRevisionNotification,
  });

  CompanySettings.fromJson(Map<String, dynamic> json){
    try{
      lowValue = json['low_value'];
      lowColor = json['low_color'];
      mediumColor = json['medium_color'];
      highValue = json['high_value'];
      highColor = json['high_color'];
      lastUpdated = json['last_updated'];
      reportTime = json['report_time'];
      receivePunchNotification = json['receive_punch_notification']==null || json['receive_punch_notification']=='1';
      receiveRevisionNotification = json['receive_revision_notification']==null || json['receive_revision_notification']=='1';

      hasNFCHarvest = json['has_nfc_harvest']!=null && json['has_nfc_harvest']=='1';
      hasNFCReport = json['has_nfc_report']!=null && json['has_nfc_report']=='1';
      hasHarvestReport = json['has_harvest_report']!=null && json['has_harvest_report']=='1';
      hasTimeSheetRevision = json['has_time_sheet_revision']!=null && json['has_time_sheet_revision']=='1';
      hasTimeSheetSchedule = json['has_time_sheet_schedule']!=null && json['has_time_sheet_schedule']=='1';
      hasGeolocationPunch = json['has_geolocation_punch']!=null && json['has_geolocation_punch']=='1';
      useOwnData = json['use_own_data']!=null && json['use_own_data']=='1';
    }catch(e){
      print('[CompanySettings.fromJson]$e');
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if(this.lowValue!=null)data['low_value'] = this.lowValue;
    if(this.lowColor!=null)data['low_color'] = this.lowColor;
    if(this.mediumColor!=null)data['medium_color'] = this.mediumColor;
    if(this.highValue!=null)data['high_value'] = this.highValue;
    if(this.highColor!=null)data['high_color'] = this.highColor;
    if(this.reportTime!=null)data['report_time'] = this.reportTime;
    if(this.lastUpdated!=null)data['last_updated'] = this.lastUpdated;
    if(this.receivePunchNotification!=null)data['receive_punch_notification'] = this.receivePunchNotification?'1':'0';
    if(this.receiveRevisionNotification!=null)data['receive_revision_notification'] = this.receiveRevisionNotification?'1':'0';

    if(this.hasNFCHarvest!=null)data['has_nfc_harvest'] = this.hasNFCHarvest?'1':'0';
    if(this.hasNFCReport!=null)data['has_nfc_report'] = this.hasNFCReport?'1':'0';
    if(this.hasHarvestReport!=null)data['has_harvest_report'] = this.hasHarvestReport?'1':'0';
    if(this.hasTimeSheetRevision!=null)data['has_time_sheet_revision'] = this.hasTimeSheetRevision?'1':'0';
    if(this.hasTimeSheetSchedule!=null)data['has_time_sheet_schedule'] = this.hasTimeSheetSchedule?'1':'0';
    if(this.hasGeolocationPunch!=null)data['has_geolocation_punch'] = this.hasGeolocationPunch?'1':'0';
    if(this.useOwnData!=null)data['use_own_data'] = this.useOwnData?'1':'0';

    return data;
  }

}