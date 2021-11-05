import 'package:facepunch/lang/l10n.dart';
import 'package:facepunch/models/revision_model.dart';
import 'package:facepunch/widgets/calendar_strip/date-utils.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'app_const.dart';
import 'package:localstorage/localstorage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'work_model.dart';


class UserModel with ChangeNotifier{
  User user;
  final LocalStorage storage = LocalStorage('face_punch_user');
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  String locale = 'en';
  double yearTotalHours = 0;

  Future<User> getUserFromLocal()async{
    try{
      bool storageReady = await storage.ready;
      if(storageReady){
        var json = await storage.getItem('user');
        if(json!=null){
          user = User.fromJson(json);
          user = await getUserInfoFromServer(user.token);
          if(user != null){
            if(user.language=='Spanish'){
              locale = 'es';
            }else if(user.language=='French'){
              locale = 'fr';
            }
            GlobalData.token = user.token;
          }
        }
      }
    }catch(e){
      print("[UserModel.getUserFromLocal] $e");
    }
    notifyListeners();
    return user;
  }

  saveUserToLocal()async{
    try{
      bool storageReady = await storage.ready;
      if(storageReady)
        await storage.setItem('user', user.toJson());
      if(user.language=='Spanish'){
        locale = 'es';
      }else if(user.language=='French'){
        locale = 'fr';
      }else{
        locale = 'en';
      }
      notifyListeners();
    }catch(e){
      print("[UserModel.saveUserToLocal] $e");
    }
  }

  Future<String> adminLogin({String email,String password, bool isRememberMe})async{
    String result = 'Oops, Unknown Errors!';
    try{
      String deviceToken = await _firebaseMessaging.getToken();
      var res = await http.post(
          AppConst.adminLogin,
          headers: {
            'Accept':'application/json',
            'Content-Type':'application/x-www-form-urlencoded',
          },
          body: {
            'email':email,
            'password':password,
            'firebase_token': deviceToken??''
          }
      );
      print("[UserModel.adminLogin] ${res.body}");
      if(res.statusCode==200){
        user = User.fromJson(jsonDecode(res.body));
        GlobalData.token = user.token;
        if(isRememberMe)await saveUserToLocal();
        result = null;
      }else{
        result =  jsonDecode(res.body)['message'].toString();
      }
    }catch(e){
      print("[UserModel.adminLogin] $e");
    }
    return result;
  }

  Future<String> adminRegister(String email,String password,String fName,String lName)async{
    String result = 'Oops, Unknown Errors!';
    try{
      String deviceToken  = await _firebaseMessaging.getToken();
      var res = await http.post(
          AppConst.adminRegister,
          headers: {
            'Accept':'application/json',
            'Content-Type':'application/x-www-form-urlencoded',
          },
          body: {
            'email':email,
            'password':password,
            'first_name':fName,
            'last_name':lName,
            'firebase_token':deviceToken??''
          }
      );
      print("[UserModel.adminRegister] ${res.body}");
      if(res.statusCode==200){
        user = User.fromJson(jsonDecode(res.body));
        GlobalData.token = user.token;
        await saveUserToLocal();
        result =  null;
      }else{
        result =  jsonDecode(res.body)['message'].toString();
      }
    }catch(e){
      print("[UserModel.adminRegister] $e");
    }
    return result;
  }

  logOut()async{
    try{
      bool storageReady = await storage.ready;
      if(storageReady){
        await storage.deleteItem('user');
        user = null;
      }
    }catch(e){
      print("[UserModel.logOut] $e");
    }
  }

  Future<String> recoverPassword(String email)async{
    try{
      var res = await http.post(
          AppConst.recoverPassword,
          headers: {
            'Accept':'application/json',
            'Content-Type':'application/x-www-form-urlencoded',
          },
          body: {
            'email':email
          }
      );
      print("[UserModel.recoverPassword] ${res.body}");
      if(res.statusCode==200){
        return "We have sent new password to your email.";
      }else{
        return jsonDecode(res.body)['message'].toString();
      }
    }catch(e){
      print("[UserModel.recoverPassword] $e");
      return 'Oops, Unknown Errors!';
    }
  }

  Future<String> verifyEmailAddress(String number)async{
    String result = 'Oops, Unknown Errors!';
    try{
      var res = await http.post(
          AppConst.emailVerify,
          headers: {
            'Accept':'application/json',
            'Content-Type':'application/x-www-form-urlencoded',
            'Authorization':'Bearer '+user.token
          },
          body: {
            'email' : user.email,
            'verify_number' : number,
          }
      );
      print("[UserModel.verifyEmailAddress] ${res.body}");
      if(res.statusCode==200){
        user = User.fromJson(jsonDecode(res.body));
        GlobalData.token = user.token;
        await saveUserToLocal();
        result = null;
      }else{
        result =  jsonDecode(res.body)['message'].toString();
      }
    }catch(e){
      print("[UserModel.verifyEmailAddress] $e");
    }
    return result;
  }

  Future<String> sendVerifyEmailAgain()async{
    String result = 'Oops, Unknown Errors!';
    try{
      var res = await http.get(
          AppConst.sendVerifyAgain,
          headers: {
            'Accept':'application/json',
            'Content-Type':'application/x-www-form-urlencoded',
            'Authorization':'Bearer '+user.token
          }
      );
      print("[UserModel.sendVerifyEmailAgain] ${res.body}");
      if(res.statusCode==200){
        user.emailVerifyNumber = jsonDecode(res.body)['number'];
        await saveUserToLocal();
        result = null;
      }else{
        result =  jsonDecode(res.body)['message'].toString();
      }
    }catch(e){
      print("[UserModel.sendVerifyEmailAgain] $e");
    }
    return result;
  }

  Future<String> updateAdmin({String email, String newPassword, String oldPassword, String fName, String lName})async{
    String result = 'Oops, Unknown Errors!';
    try{
      var res = await http.post(
          AppConst.updateAdmin,
          headers: {
            'Accept':'application/json',
            'Content-Type':'application/x-www-form-urlencoded',
            'Authorization':'Bearer '+user.token
          },
          body: {
            'email':email,
            'new_password' : newPassword,
            'old_password' : oldPassword,
            'first_name' : fName,
            'last_name' : lName
          }
      );
      print("[UserModel.updateUser] ${res.body}");
      if(res.statusCode==200){
        user = User.fromJson(jsonDecode(res.body));
        GlobalData.token = user.token;
        await saveUserToLocal();
        result =  null;
      }else{
        result =  jsonDecode(res.body)['message'].toString();
      }
    }catch(e){
      print("[UserModel.updateUser] $e");
    }
    return result;
  }

  Future<String> loginWithFace(String photo)async{
    String result = 'Oops, Unknown Errors!';
    try{
      String deviceToken = await _firebaseMessaging.getToken();
      print("[UserModel.loginWithFace.deviceToken] $deviceToken");
      var res = await http.post(
          AppConst.loginWithFace,
          headers: {
            'Accept':'application/json',
            'Content-Type':'application/x-www-form-urlencoded',
          },
          body: {
            'photo':photo,
            'firebase_token': deviceToken??''
          }
      );
      print("[UserModel.loginWithFace] ${res.body}");
      if(res.statusCode==200){
        user = User.fromJson(jsonDecode(res.body));
        GlobalData.token = user.token;
        await saveUserToLocal();
        result = null;
      }else{
        result = jsonDecode(res.body)['message'];
      }
    }catch(e){
      print("[UserModel.loginWithFace] $e");
    }
    return result;
  }

  Future<dynamic> punchWithFace({String photo,double longitude, double latitude})async{
    String result = 'Oops, Unknown Errors!';
    try{
      var res = await http.post(
          AppConst.punchWithFace,
          headers: {
            'Accept':'application/json',
            'Content-Type':'application/json',
          },
          body: jsonEncode({
            'photo':photo,
            'longitude':longitude,
            'latitude':latitude
          })
      );
      print("[UserModel.punchWithFace] ${res.body}");
      if(res.statusCode==200){
        return jsonDecode(res.body);
      }else{
        result = jsonDecode(res.body)['message'];
      }
    }catch(e){
      print("[UserModel.punchWithFace] $e");
    }
    return result;
  }

  Future<String> getUserTimeSheetData(DateTime date)async{
    try{
      var res = await http.post(
          AppConst.getTimeSheetData,
          headers: {
            'Accept':'application/json',
            'Content-Type':'application/x-www-form-urlencoded',
            'Authorization':'Bearer ${user.token}'
          },
        body: {'date': date.toString()}
      );
      print("[UserModel.getUserTimeSheetData] ${res.body}");
      var body = jsonDecode(res.body);
      if(res.statusCode==200){
        List<Punch> punches = [];
        for(var punch in body['punches']) punches.add(Punch.fromJson(punch));
        user.punches = punches;
        List<WorkHistory> works = [];
        for(var work in body['works']) works.add(WorkHistory.fromJson(work));
        user.works = works;
        List<EmployeeBreak> breaks = [];
        for(var b in body['breaks']) breaks.add(EmployeeBreak.fromJson(b));
        user.breaks = breaks;
        notifyListeners();
        return null;
      }else{
        return body['message']??'Something went wrong';
      }
    }catch(e){
      print("[UserModel.getUserTimeSheetData] $e");
      return e.toString() ;
    }
  }

  Future<String> getEmployeeTimeSheetData(DateTime date, User employee)async{
    try{
      var res = await http.post(
          AppConst.getTimeSheetData,
          headers: {
            'Accept':'application/json',
            'Content-Type':'application/x-www-form-urlencoded',
            'Authorization':'Bearer ${user.token}'
          },
        body: {'date': date.toString(),'user_id': employee.id.toString()}
      );
      print("[UserModel.getEmployeeTimeSheetData] ${res.body}");
      var body = jsonDecode(res.body);
      if(res.statusCode==200){
        List<Punch> punches = [];
        for(var punch in body['punches']) punches.add(Punch.fromJson(punch));
        employee.punches = punches;

        List<WorkHistory> works = [];
        for(var work in body['works']) works.add(WorkHistory.fromJson(work));
        employee.works = works;

        List<EmployeeBreak> breaks = [];
        for(var b in body['breaks']) breaks.add(EmployeeBreak.fromJson(b));
        employee.breaks = breaks;
        notifyListeners();
        return null;
      }else{
        return body['message']??'Something went wrong';
      }
    }catch(e){
      print("[UserModel.getEmployeeTimeSheetData] $e");
      return e.toString() ;
    }
  }

  Future<String> notificationSetting()async{
    try{
      String token = "disabled";
      if(user.firebaseToken==null || user.firebaseToken=="disabled"){
        token = await _firebaseMessaging.getToken();
      }
      var res = await http.post(
        AppConst.notificationSetting,
        headers: {
          'Accept':'application/json',
          'Content-Type':'application/json',
          'Authorization':'Bearer '+user.token
        },
        body: jsonEncode({'token':token}),
      );
      print("[UserModel.notificationSetting] ${res.body}");
      if(res.statusCode==200){
        user.firebaseToken = token;
        saveUserToLocal();
        return null;
      }else{
        return jsonDecode(res.body)['message'];
      }
    }catch(e){
      print("[UserModel.notificationSetting]");
      return e.toString();
    }
  }

  changeAppLanguage(String lang){
    locale = lang;
    notifyListeners();
  }

  Future<String> getYearTotalHours()async{
    try{
      var res = await http.get(
          AppConst.getYearTotalHours,
          headers: {
            'Accept':'application/json',
            'Content-Type':'application/x-www-form-urlencoded',
            'Authorization':'Bearer ${user.token}'
          },
      );
      print("[UserModel.getYearTotalHours] ${res.body}");
      var body = jsonDecode(res.body);
      if(res.statusCode==200){
        yearTotalHours = body['total'];
        notifyListeners();
        return null;
      }else{
        return body['message']??'Something went wrong';
      }
    }catch(e){
      print("[UserModel.getYearTotalHours] $e");
      return e.toString() ;
    }
  }

  Future<User> getUserInfoFromServer(String token)async{
    try{
      var res = await http.get(
        AppConst.getUserInfo,
        headers: {
          'Accept':'application/json',
          'Content-Type':'application/x-www-form-urlencoded',
          'Authorization':'Bearer $token'
        },
      );
      print('[UserModel.getUserInfoFromServer]${res.body}');
      if(res.statusCode == 200){
       return User.fromJson(jsonDecode(res.body));
      }
    }catch(e){
      print('[UserModel.getUserInfoFromServer]$e');
    }
    return null;
  }

  Future<Map<String, dynamic>> getAppVersions()async{
    try{
      var res = await http.get(
        AppConst.getAppVersions,
        headers: {
          'Accept':'application/json',
          'Content-Type':'application/x-www-form-urlencoded',
        },
      );
      print('[UserModel.getAppVersions]${res.body}');
      if(res.statusCode == 200){
        return jsonDecode(res.body);
      }
    }catch(e){
      print('[UserModel.getAppVersions]$e');
    }
    return null;
  }
}

class User {
  int id;
  String name;
  String email;
  String emailVerifiedAt;
  String firstName;
  String lastName;
  String phone;
  String pin;
  List<String> projects;
  String employeeCode;
  String start;
  String salary;
  String birthday;
  String address1;
  String address2;
  String city;
  String country;
  String state;
  String postalCode;
  String language;
  String avatar;
  String role;
  String type;
  String firebaseToken;
  String emailVerifyNumber;
  int companyId;
  bool hasAutoBreak = true;
  String nfc;
  bool canNTCTracking = true;
  bool sendScheduleNotification = true;
  String createdAt;
  String updatedAt;
  bool active = true;

  List<Punch> punches = [];
  List<WorkHistory> works = [];
  List<EmployeeBreak> breaks = [];
  List<WorkSchedule> schedules = [];
  List<EmployeeCall> calls = [];
  List<Revision> revisions = [];
  Punch lastPunch;
  String token;

  User({
    this.id,
    this.name,
    this.email,
    this.emailVerifiedAt,
    this.firstName,
    this.lastName,
    this.phone,
    this.pin,
    this.start,
    this.salary,
    this.birthday,
    this.address1,
    this.address2,
    this.city,
    this.country,
    this.state,
    this.postalCode,
    this.language,
    this.avatar,
    this.role,
    this.type,
    this.firebaseToken,
    this.emailVerifyNumber,
    this.companyId,
    this.employeeCode,
    this.token,
    this.nfc,
    this.lastPunch,
    this.createdAt,
    this.updatedAt,
    this.canNTCTracking,
    this.sendScheduleNotification,
    this.active,
    this.hasAutoBreak,
    this.projects
  });

  User.fromJson(Map<String, dynamic> json) {
    try{
      id = json['id'];
      name = json['name'];
      email = json['email'];
      emailVerifiedAt = json['email_verified_at'];
      firstName = json['first_name'];
      lastName = json['last_name'];
      phone = json['phone'];
      pin = json['pin'];
      start = json['start'];
      salary = json['salary'];
      birthday = json['birthday'];
      address1 = json['address1'];
      address2 = json['address2'];
      city = json['city'];
      country = json['country'];
      state = json['state'];
      postalCode = json['postal_code'];
      language = json['language'];
      if(language==null){
        language = 'English';
      }
      avatar = json['avatar'];
      if(avatar==null){
        avatar = 'user_avatar.png';
      }
      role = json['role'];
      type = json['type'];
      firebaseToken = json['firebase_token'];
      emailVerifyNumber = json['email_verify_number'];
      companyId = json['company_id'];
      employeeCode = json['employee_code'];
      token = json['token'];
      if(json['last_punch']!=null){
        lastPunch = Punch.fromJson(json['last_punch']);
      }
      nfc = json['nfc'];
      canNTCTracking = json['can_nfc_tracking'] != null && json['can_nfc_tracking'] == 1;
      sendScheduleNotification = json['send_schedule_notification'] != null && json['send_schedule_notification'] == 1;
      createdAt = json['created_at'];
      updatedAt = json['updated_at'];
      if(json['projects'] != null){
        projects = json['projects'].cast<String>();
      }
      hasAutoBreak = json['has_auto_break'] != null && json['has_auto_break'] == 1;
      active = json['active'] != null && json['active'] == 1;
    }catch(e){
      print("[User.fromJson] $e");
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['email'] = this.email;
    data['email_verified_at'] = this.emailVerifiedAt;
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    data['phone'] = this.phone;
    data['pin'] = this.pin;
    data['start'] = this.start;
    data['salary'] = this.salary;
    data['birthday'] = this.birthday;
    data['address1'] = this.address1;
    data['address2'] = this.address2;
    data['city'] = this.city;
    data['country'] = this.country;
    data['state'] = this.state;
    data['postal_code'] = this.postalCode;
    if(language!=null)data['language'] = this.language;
    if(avatar!=null)data['avatar'] = this.avatar;
    data['role'] = this.role;
    data['type'] = this.type;
    data['firebase_token'] = this.firebaseToken;
    data['email_verify_number'] = this.emailVerifyNumber;
    data['company_id'] = this.companyId;
    data['employee_code'] = this.employeeCode;
    data['token'] = this.token;
    data['nfc'] = this.nfc;
    if(this.canNTCTracking!=null){
      data['can_nfc_tracking'] = this.canNTCTracking?1:0;
    }
    if(this.sendScheduleNotification!=null){
      data['send_schedule_notification'] = this.sendScheduleNotification?1:0;
    }
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['projects'] = this.projects;
    if(this.hasAutoBreak != null){
      data['has_auto_break'] = this.hasAutoBreak?1:0;
    }
    if(this.active != null){
      data['active'] = this.active?1:0;
    }
    return data;
  }

  String getFullName(){
    return '$firstName $lastName';
  }

  Punch getTodayPunch(){
    return punches.lastWhere((p) =>isSameDatePunch(p.createdAt, DateTime.now().toString()),orElse: ()=>null);
  }

  bool isSameDatePunch(String punchDate, String date){
    return getDateString(punchDate) == getDateString(date);
  }

  String getDateString(String date){
    return date.split(" ").first;
  }

  Map<String, List<Punch>> getPunchesGroupByDate(){
    Map<String, List<Punch>> punchGroup = {};
    punches.forEach((p) {
      if(punchGroup[getDateString(p.createdAt)]==null){
        punchGroup[getDateString(p.createdAt)] = [p];
      }else{
        punchGroup[getDateString(p.createdAt)].add(p);
      }
    });
    return punchGroup;
  }

  List<Punch> getPunchesOfDate(DateTime date){
    return punches.where((p) => isSameDatePunch(p.createdAt, date.toString()) && p.isIn()).toList();
  }

  List<Punch> getPunchesOfWeek(DateTime startDate){
    DateTime endDate = startDate.add(Duration(days: 7));
    return punches.where((p) => (DateTime.parse(p.createdAt).isAfter(startDate) && DateTime.parse(p.createdAt).isBefore(endDate))).toList();
  }

  Map<String, List<Punch>> getPunchesGroupOfWeek(DateTime startDate){
    Map<String, List<Punch>> punchGroup = {};
    getPunchesOfWeek(startDate).forEach((p) {
      if(p.punch == "In"){
        if(punchGroup[getDateString(p.createdAt)]==null){
          punchGroup[getDateString(p.createdAt)] = [p];
        }else{
          punchGroup[getDateString(p.createdAt)].add(p);
        }
      }
    });
    return punchGroup;
  }

  double getHoursOfDate(DateTime date){
    List<Punch> punchesOfDate = getPunchesOfDate(date);
    double hours = 0.0;
    punchesOfDate.forEach((punchIn) {
      Punch punchOut = getPunchOut(punchIn);
      if(punchOut != null){
        hours += DateTime.parse(punchOut.createdAt).difference(DateTime.parse(punchIn.createdAt)).inMinutes/60;
      }
    });
    return hours;
  }

  double getBreakTime(DateTime date){
    double hours = 0;
    breaks.where((b) => isSameDatePunch(b.start, date.toString())).forEach((b) {
      hours += b.length/60;
    });
    return hours;
  }

  double calculateHoursOfDate(DateTime date){
    return getHoursOfDate(date) - getBreakTime(date);
  }

  double getTotalHoursOfWeek(DateTime startDate){
    DateTime endDate = startDate.add(Duration(days: 6));
    Map<String, List<Punch>> punchGroup = getPunchesGroupByDate();
    double totalHours = 0.0;
    punchGroup.forEach((d, v) {
      DateTime date = DateTime.parse(d);
      if(date.isAfter(startDate) && date.isBefore(endDate)){
        totalHours += calculateHoursOfDate(date);
      }
    });
    return totalHours;
  }

  double getTotalHoursOfCurrentWeek(){
    DateTime startOfWeek = PunchDateUtils.getStartOfCurrentWeek(DateTime.now());
    return getTotalHoursOfWeek(startOfWeek);
  }

  double getTotalHoursOfLastWeek(){
    DateTime startOfWeek = PunchDateUtils.getStartOfCurrentWeek(DateTime.now());
    return getTotalHoursOfWeek(startOfWeek.subtract(Duration(days: 7)));
  }

  Punch getPunchOut(Punch punchIn){
    return punches.firstWhere((p) => (p.inId != null && p.inId == punchIn.id), orElse: ()=>null);
  }

  List<WorkHistory> worksOfPunch(Punch punch){
    return works.where((w) => (w.punchId!=null && w.punchId == punch.id),).toList();
  }

  List<EmployeeBreak> breaksOfPunch(Punch punch){
    return breaks.where((b) => (b.punchId!=null && b.punchId == punch.id),).toList();
  }

  Future<String> editPunch(int punchId, String value)async{
    try{
      var res = await http.post(
        AppConst.editPunch,
        headers: {
          'Accept':'application/json',
          'Content-Type':'application/json',
          'Authorization':'Bearer '+GlobalData.token
        },
        body: jsonEncode({'punch_id':punchId,'value':value}),
      );
      print("[User.editPunch] ${res.body}");
      if(res.statusCode==200){
        return null;
      }else{
        return jsonDecode(res.body)['message'];
      }
    }catch(e){
      print("[User.editPunch] $e");
      return e.toString();
    }
  }

  Future<String> deletePunch(int punchId)async{
    try{
      var res = await http.post(
        AppConst.deletePunch,
        headers: {
          'Accept':'application/json',
          'Content-Type':'application/json',
          'Authorization':'Bearer '+GlobalData.token
        },
        body: jsonEncode({'punch_id':punchId}),
      );
      print("[User.deletePunch] ${res.body}");
      if(res.statusCode==200){
        return null;
      }else{
        return jsonDecode(res.body)['message'];
      }
    }catch(e){
      print("[User.deletePunch] $e");
      return e.toString();
    }
  }

  Future<String> editWork(WorkHistory work)async{
    try{
      var res = await http.post(
        AppConst.editWork,
        headers: {
          'Accept':'application/json',
          'Content-Type':'application/json',
          'Authorization':'Bearer '+GlobalData.token
        },
        body: jsonEncode(work.toJson()),
      );
      print("[User.editWork] ${res.body}");
      if(res.statusCode==200){
        return null;
      }else{
        return jsonDecode(res.body)['message'];
      }
    }catch(e){
      print("[User.editWork] $e");
      return e.toString();
    }
  }

  Future<String> deleteWork(int workId)async{
    try{
      var res = await http.post(
        AppConst.deleteWork,
        headers: {
          'Accept':'application/json',
          'Content-Type':'application/json',
          'Authorization':'Bearer '+GlobalData.token
        },
        body: jsonEncode({'id':workId}),
      );
      print("[User.deleteWork] ${res.body}");
      if(res.statusCode==200){
        return null;
      }else{
        return jsonDecode(res.body)['message'];
      }
    }catch(e){
      print("[User.deleteWork] $e");
      return e.toString();
    }
  }

  bool isPunchIn(){
    return lastPunch!=null && lastPunch.punch=='In';
  }

  bool hasTracking(){
    return ['shop_tracking','call_shop_tracking'].contains(type);
  }

  bool hasSchedule(){
    return ['shop_daily','call_shop_daily'].contains(type);
  }

  bool hasCall(){
    return ['call', 'call_shop_daily', 'call_shop_tracking'].contains(type);
  }

  String pdfUrl(DateTime startDate){
    DateTime pdfDate = startDate??PunchDateUtils.getStartOfCurrentWeek(DateTime.now());
    final pdfLink = "$firstName $lastName (${pdfDate.toString().split(" ")[0]} ~ ${pdfDate.add(Duration(days: 6)).toString().split(" ")[0]}).pdf";
    print(pdfLink);
    return Uri.encodeFull('https://facepunch.app/punch-pdfs/$companyId/$pdfLink');
  }

  Future<String> getDailySchedule(String date)async{
    try{
      var res = await http.post(
          AppConst.getDailySchedule,
          headers: {
            'Accept':'application/json',
            'Content-Type':'application/x-www-form-urlencoded',
            'Authorization':'Bearer '+token
          },
          body: {'date':date}
      );
      print('[WorkModel.getDailySchedule]${res.body}');
      var body = jsonDecode(res.body);
      if(res.statusCode==200){
        schedules.clear();
        calls.clear();
        for(var s in body['schedules']){
          schedules.add(WorkSchedule.fromJson(s));
        }
        for(var c in body['calls']){
          calls.add(EmployeeCall.fromJson(c));
        }
        return null;
      }else{
        return body['message']??'Something went wrong.';
      }
    }catch(e){
      print('[WorkModel.getDailySchedule]$e');
      return e.toString();
    }
  }

  Future<String> getRevisionNotifications()async{
    try{
      var res = await http.get(
          AppConst.getRevisionNotifications,
          headers: {
            'Accept':'application/json',
            'Content-Type':'application/json',
            'Authorization':'Bearer '+token
          }
      );
      print('[User.getRevisionNotifications]${res.body}');
      final body = jsonDecode(res.body);
      if(res.statusCode==200){
        revisions.clear();
        for(var revision in body){
          revisions.add(Revision.fromJson(revision));
        }
        return null;
      }else{
        return body['message']??'Something went wrong.';
      }
    }catch(e){
      print('[User.getRevisionNotifications]$e');
      return e.toString();
    }
  }

  Future<String> getDailyCall(String date)async{
    try{
      var res = await http.post(
          AppConst.getEmployeeCall,
          headers: {
            'Accept':'application/json',
            'Content-Type':'application/x-www-form-urlencoded',
            'Authorization':'Bearer ${token??GlobalData.token}'
          },
          body: {
            'date' : date,
            'id' : id.toString()
          }
      );
      print('[WorkModel.getDailyCall]${res.body}');
      var body = jsonDecode(res.body);
      if(res.statusCode == 200){
        calls.clear();
        for(var c in body){
          calls.add(EmployeeCall.fromJson(c));
        }
        return null;
      }else{
        return body['message']??'Something went wrong.';
      }
    }catch(e){
      print('[WorkModel.getDailyCall]$e');
      return e.toString();
    }
  }

  Future<String> deleteBreak(int breakId)async{
    try{
      var res = await http.post(
        AppConst.deleteBreak,
        headers: {
          'Accept':'application/json',
          'Content-Type':'application/json',
          'Authorization':'Bearer '+GlobalData.token
        },
        body: jsonEncode({'id':breakId}),
      );
      print("[User.deleteBreak] ${res.body}");
      if(res.statusCode==200){
        return null;
      }else{
        return jsonDecode(res.body)['message'];
      }
    }catch(e){
      print("[User.deleteBreak] $e");
      return e.toString();
    }
  }
}

class Punch{
  int id;
  int userId;
  int inId;
  String punch;
  double longitude;
  double latitude;
  String createdAt;
  String updatedAt;
  int paid;

  Punch({
    this.id,
    this.userId,
    this.punch,
    this.longitude,
    this.latitude,
    this.paid,
    this.createdAt,
    this.updatedAt
  });

  Punch.fromJson(Map<String, dynamic> json) {
    try{
      id = json['id'];
      userId = json['user_id'];
      inId = json['in_id'];
      punch = json['punch'];
      longitude = json['longitude']==null?null:double.parse(json['longitude'].toString());
      latitude = json['latitude']==null?null:double.parse(json['latitude'].toString());
      paid = json['paid'];
      createdAt = json['created_at'];
      updatedAt = json['updated_at'];
    }catch(e){
      print("[Punch.fromJson] $e");
    }
  }

  bool isIn(){
    return punch == "In";
  }

  bool isOut(){
    return punch == "Out";
  }

  String title(BuildContext context){
    return "${S.of(context).punch} $punch ${S.of(context).at} ${PunchDateUtils.getTimeString(DateTime.parse(createdAt))}";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = this.id;
    data['in_id'] = this.inId;
    data['user_id'] = this.userId;
    data['punch'] = this.punch;
    data['longitude'] = this.longitude;
    data['latitude'] = this.latitude;
    data['paid'] = this.paid;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}

