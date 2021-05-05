import 'package:facepunch/widgets/calendar_strip/date-utils.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'app_const.dart';
import 'package:localstorage/localstorage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';


class UserModel with ChangeNotifier{
  User user;
  final LocalStorage storage = LocalStorage('face_punch_user');
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  String locale = 'en';

  Future<User> getUserFromLocal()async{
    try{
      bool storageReady = await storage.ready;
      if(storageReady){
        var json = await storage.getItem('user');
        if(json!=null){
          user = User.fromJson(json);
          if(user.language=='Spanish'){
            locale = 'es';
          }else if(user.language=='French'){
            locale = 'fr';
          }
          GlobalData.token = user.token;
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

  Future<String> loginWithFace(int companyId, String photo)async{
    String result = 'Oops, Unknown Errors!';
    try{
      String deviceToken = await _firebaseMessaging.getToken();
      print("[deviceToken] $deviceToken");
      var res = await http.post(
          AppConst.loginWithFace,
          headers: {
            'Accept':'application/json',
            'Content-Type':'application/x-www-form-urlencoded',
          },
          body: {
            'company_id':companyId.toString(),
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

  Future<dynamic> findFace(companyId, String photo)async{
    String result = 'Oops, Unknown Errors!';
    try{
      var res = await http.post(
          AppConst.loginWithFace,
          headers: {
            'Accept':'application/json',
            'Content-Type':'application/x-www-form-urlencoded',
          },
          body: {
            'company_id':companyId.toString(),
            'photo':photo,
          }
      );
      print("[UserModel.punchWithFace] ${res.body}");
      if(res.statusCode==200){
        return User.fromJson(jsonDecode(res.body));
      }else{
        result = jsonDecode(res.body)['message'];
      }
    }catch(e){
      print("[UserModel.punchWithFace] $e");
    }
    return result;
  }

  Future<dynamic> savePunch({User employee, double longitude, double latitude})async{
    String result = 'Oops, Unknown Errors!';
    try{
      var res = await http.post(
          AppConst.punchWithFace,
          headers: {
            'Accept':'application/json',
            'Content-Type':'application/json',
            'Authorization':'Bearer '+employee.token
          },
          body: jsonEncode(
              {
                'longitude':longitude,
                'latitude':latitude
              }
          )
      );
      print("[UserModel.savePunch] ${res.body}");
      if(res.statusCode==200){
        Punch punch = Punch.fromJson(jsonDecode(res.body));
        return punch;
      }else{
        return jsonDecode(res.body)['message'];
      }
    }catch(e){
      print("[UserModel.savePunch] $e");
    }
    return result;
  }

  Future<String> getUserPunches()async{
    try{
      var res = await http.get(
          AppConst.getUserPunches,
          headers: {
            'Accept':'application/json',
            'Content-Type':'application/json',
            'Authorization':'Bearer '+user.token
          }
      );
      print("[UserModel.getUserPunches] ${res.body}");
      if(res.statusCode==200){
        List<Punch> punches = [];
        for(var punch in jsonDecode(res.body)){
          punches.add(Punch.fromJson(punch));
        }
        user.punches = punches;
        notifyListeners();
        return null;
      }else{
        return jsonDecode(res.body)['message'];
      }
    }catch(e){
      print("[UserModel.getUserPunches] $e");
      return e.toString();
    }
  }

  Future<List<Punch>> getEmployeePunches(int userId)async{
    try{
      var res = await http.post(
          AppConst.getEmployeePunches,
          headers: {
            'Accept':'application/json',
            'Content-Type':'application/json',
            'Authorization':'Bearer '+user.token
          },
        body: jsonEncode({'user_id':userId}),
      );
      print("[UserModel.getEmployeePunches] ${res.body}");
      if(res.statusCode==200){
        List<Punch> punches = [];
        for(var punch in jsonDecode(res.body)){
          punches.add(Punch.fromJson(punch));
        }
        return punches;
      }
    }catch(e){
      print("[UserModel.getEmployeePunches] $e");
    }
    return [];
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
  String function;
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
  String firebaseToken;
  String emailVerifyNumber;
  int companyId;
  String employeeCode;
  int lunchTime=0;
  String nfc;
  String whatsApp;
  String token;
  String createdAt;
  String updatedAt;
  List<Punch> punches = [];
  Punch lastPunch;

  User({
    this.id,
    this.name,
    this.email,
    this.emailVerifiedAt,
    this.firstName,
    this.lastName,
    this.phone,
    this.pin,
    this.function,
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
    this.firebaseToken,
    this.emailVerifyNumber,
    this.companyId,
    this.employeeCode,
    this.token,
    this.nfc,
    this.whatsApp,
    this.punches,
    this.lastPunch,
    this.lunchTime,
    this.createdAt,
    this.updatedAt
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
      function = json['function'];
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
      firebaseToken = json['firebase_token'];
      emailVerifyNumber = json['email_verify_number'];
      companyId = json['company_id'];
      employeeCode = json['employee_code'];
      token = json['token'];
      if(json['last_punch']!=null){
        lastPunch = Punch.fromJson(json['last_punch']);
      }
      lunchTime = json['lunch_time'];
      nfc = json['nfc'];
      whatsApp = json['whatsapp'];
      createdAt = json['created_at'];
      updatedAt = json['updated_at'];
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
    data['function'] = this.function;
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
    data['firebase_token'] = this.firebaseToken;
    data['email_verify_number'] = this.emailVerifyNumber;
    data['company_id'] = this.companyId;
    data['employee_code'] = this.employeeCode;
    data['token'] = this.token;
    data['lunch_time'] = this.lunchTime;
    data['nfc'] = this.nfc;
    data['whatsapp'] = this.whatsApp;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
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
    return punches.where((p) => isSameDatePunch(p.createdAt, date.toString())).toList();
  }

  List<Punch> getPunchesOfWeek(DateTime startDate){
    DateTime endDate = startDate.add(Duration(days: 6));
    return punches.where((p) => (DateTime.parse(p.createdAt).isAfter(startDate) && DateTime.parse(p.createdAt).isBefore(endDate))).toList();
  }

  Map<String, List<Punch>> getPunchesGroupOfWeek(DateTime startDate){
    Map<String, List<Punch>> punchGroup = {};
    getPunchesOfWeek(startDate).forEach((p) {
      if(punchGroup[getDateString(p.createdAt)]==null){
        punchGroup[getDateString(p.createdAt)] = [p];
      }else{
        punchGroup[getDateString(p.createdAt)].add(p);
      }
    });
    return punchGroup;
  }

  double getHoursOfDate(DateTime date){
    List<Punch> punchesOfDate = getPunchesOfDate(date);
    if(punchesOfDate.length<2)return 0.0;
    double hours = 0.0;
    for(int i=0; i<punchesOfDate.length; i++ ){
      if(punchesOfDate[i].punch=="In"){
        if(i+1<punchesOfDate.length && punchesOfDate[i+1].punch=="Out"){
          hours += DateTime.parse(punchesOfDate[i+1].createdAt).difference(DateTime.parse(punchesOfDate[i].createdAt)).inMinutes/60;
        }else if(i+2<punchesOfDate.length && punchesOfDate[i+2].punch=="Out"){
          hours += DateTime.parse(punchesOfDate[i+2].createdAt).difference(DateTime.parse(punchesOfDate[i].createdAt)).inMinutes/60;
        }
      }
    }
    return hours;
  }

  double getLunchBreakTime(DateTime date){
    List<Punch> punchesOfDate = getPunchesOfDate(date);
    Punch lunch = punchesOfDate.firstWhere((p) => p.punch=="Lunch",orElse: ()=>null);
    if(lunch==null)return 0;
    return DateTime.parse(lunch.updatedAt).difference(DateTime.parse(lunch.createdAt)).inMinutes/60;
  }

  double getTotalHoursOfYear(){
    Map<String, List<Punch>> punchGroup = getPunchesGroupByDate();
    double totalHours = 0.0;
    punchGroup.forEach((key, v) {
      totalHours +=getHoursOfDate(DateTime.parse(key));
    });
    return totalHours;
  }

  double getTotalHoursOfWeek(DateTime startDate){
    DateTime endDate = startDate.add(Duration(days: 6));
    Map<String, List<Punch>> punchGroup = getPunchesGroupByDate();
    double totalHours = 0.0;
    punchGroup.forEach((key, v) {
      DateTime date = DateTime.parse(key);
      if(date.isAfter(startDate) && date.isBefore(endDate)){
        totalHours +=getHoursOfDate(date);
        totalHours -=getLunchBreakTime(date);
      }
    });
    return totalHours;
  }

  double getTotalHoursOfCurrentWeek(){
    DateTime startOfWeek = PunchDateUtils.getStartOfCurrentWeek(DateTime.now());
    return getTotalHoursOfWeek(startOfWeek);
  }

  Future<String> editPunch(int punchId,String value)async{
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

  bool isPunchIn(){
    return lastPunch!=null && lastPunch.punch=='In';
  }

  String pdfUrl(DateTime startDate){
    DateTime pdfDate = startDate??PunchDateUtils.getStartOfCurrentWeek(DateTime.now());
    final pdfLink = "$firstName $lastName (${pdfDate.toString().split(" ")[0]} ~ ${pdfDate.add(Duration(days: 6)).toString().split(" ")[0]}).pdf";
    print(pdfLink);
    return Uri.encodeFull('https://facepunch.app/punch-pdfs/$companyId/$pdfLink');
  }
}

class Punch{
  int id;
  int userId;
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

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = this.id;
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

