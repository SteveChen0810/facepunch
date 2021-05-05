import 'user_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'app_const.dart';
import 'package:localstorage/localstorage.dart';

class CompanyModel extends ChangeNotifier{
  final LocalStorage storage = LocalStorage('companies');
  List<Company> companies = [];
  Company myCompany = Company(plan: 0);
  CompanySettings myCompanySettings = CompanySettings(receivePunchNotification: true, hasNFC: true,receiveRevisionNotification: true);
  List<User> users = [];

  Future<void> getCompanies()async{
    await getCompanyFromLocal();
    if(companies.isEmpty){
      await getCompanyFromServer();
    }else{
      getCompanyFromServer();
    }
  }

  getCompanyFromServer()async{
    try{
      var res = await http.get(
          AppConst.getAllCompanies,
          headers: {
            'Accept':'application/json',
            'Content-Type':'application/x-www-form-urlencoded',
          }
      );
      print("[CompanyModel.getCompanyFromServer] ${res.body}");
      if(res.statusCode==200){
        companies.clear();
        final json = jsonDecode(res.body);
        for(var c in json){
          companies.add(Company.fromJson(c));
        }
        saveCompanyToLocal();
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
        await storage.setItem('companies', companies.map((c) => c.toJson()).toList());
    }catch(e){
      print("[CompanyModel.saveCompanyToLocal] $e");
    }
  }

  getCompanyFromLocal()async{
    try{
      bool storageReady = await storage.ready;
      if(storageReady){
        var json = await storage.getItem('companies');
        if(json!=null){
          companies.clear();
          for(var c in json){
            companies.add(Company.fromJson(c));
          }
        }
      }
    }catch(e){
      print("[CompanyModel.getCompanyFromLocal] $e");
    }
    notifyListeners();
  }

  addCompany(Company company){
    companies.add(company);
    saveCompanyToLocal();
    notifyListeners();
  }

  setAddressMyCompany({int adminId, String name, String address1, String address2,
    String country, String state, String city, String postalCode, String phone, String website,String pin}){
    try{
      myCompany.name = name;
      myCompany.address1 = address1;
      myCompany.adminId = adminId;
      myCompany.address2 = address2;
      myCompany.country = country;
      myCompany.state = state;
      myCompany.city = city;
      myCompany.postalCode = postalCode;
      myCompany.phone = phone;
      myCompany.website = website;
      myCompany.pin = pin;
      notifyListeners();
    }catch(e){
      print("[CompanyModel.setAddressMyCompany] $e");
    }
  }

  setPlanMyCompany(int plan){
    myCompany.plan = plan;
    notifyListeners();
  }

  Future<String> createCompany()async{
    try{
      var res = await http.post(
          AppConst.createCompany,
          headers: {
            'Accept':'application/json',
            'Content-Type':'application/json',
            'Authorization':'Bearer '+GlobalData.token
          },
          body: jsonEncode(myCompany.toJson())
      );
      print("[CompanyModel.createCompany] ${res.body}");
      if(res.statusCode==200){
        myCompany = Company.fromJson(jsonDecode(res.body));
        return null;
      }else{
        return jsonDecode(res.body)['message'];
      }
    }catch(e){
      print("[CompanyModel.createCompany] $e");
      return e.toString();
    }
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
    }
    return result;
  }

  getMyCompany(int companyId){
    myCompany = companies.firstWhere((c) =>c.id==companyId,orElse: ()=>null);
    notifyListeners();
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
    String country, String state, String city, String postalCode, String phone, String website,int plan})async{
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
                'id':myCompany.id,
                'name':name,
                'address1' : address1,
                'address2' : address2,
                'city' : city,
                'country' : country,
                'state' : state,
                'postal_code' : postalCode,
                'phone' : phone,
                'website' : website,
                'plan' : plan
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

  Future<String> getCompanySettings()async{
    try{
      getCompanySettingsFromLocal();
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
        saveCompanySettingsToLocal();
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
  String address1;
  String address2;
  String city;
  String country;
  String state;
  String postalCode;
  String phone;
  String website;
  int plan;
  String pin;
  String createdAt;
  String updatedAt;

  Company({
    this.id,
    this.adminId,
    this.name,
    this.phone,
    this.address1,
    this.address2,
    this.city,
    this.country,
    this.state,
    this.postalCode,
    this.website,
    this.plan,
    this.createdAt,
    this.updatedAt
  });

  Company.fromJson(Map<String, dynamic> json) {
    try{
      id = json['id'];
      adminId = json['admin_id'];
      name = json['name'];
      phone = json['phone'];
      address1 = json['address1'];
      address2 = json['address2'];
      city = json['city'];
      country = json['country'];
      state = json['state'];
      postalCode = json['postal_code'];
      website = json['website'];
      plan = json['plan'];
      pin = json['pin'];
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
    data['phone'] = this.phone;
    data['address1'] = this.address1;
    data['address2'] = this.address2;
    data['city'] = this.city;
    data['country'] = this.country;
    data['state'] = this.state;
    data['postal_code'] = this.postalCode;
    data['website'] = this.website;
    data['plan'] = this.plan;
    data['pin'] = this.pin;
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
  bool hasNFC;
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
    this.hasNFC,
    this.receivePunchNotification,
    this.receiveRevisionNotification
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
      hasNFC = json['has_nfc']==null || json['has_nfc']=='1';
      receivePunchNotification = json['receive_punch_notification']==null || json['receive_punch_notification']=='1';
      receiveRevisionNotification = json['receive_revision_notification']==null || json['receive_revision_notification']=='1';
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
    if(this.hasNFC!=null)data['has_nfc'] = this.hasNFC?'1':'0';
    if(this.receivePunchNotification!=null)data['receive_punch_notification'] = this.receivePunchNotification?'1':'0';
    if(this.receiveRevisionNotification!=null)data['receive_revision_notification'] = this.receiveRevisionNotification?'1':'0';
    return data;
  }

}