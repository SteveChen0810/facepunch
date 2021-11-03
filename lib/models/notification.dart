import 'dart:convert';
import 'package:localstorage/localstorage.dart';
import 'package:flutter/material.dart';
import 'revision_model.dart';
import 'package:http/http.dart' as http;
import 'app_const.dart';

class NotificationModel with ChangeNotifier {
  final LocalStorage storage = LocalStorage('notifications');
  List<Revision> revisions = [];


  Future<void> getNotificationFromServer()async{
    try{
      var res = await http.get(
          AppConst.getRevisionRequest,
          headers: {
            'Accept':'application/json',
            'Content-Type':'application/x-www-form-urlencoded',
            'Authorization':'Bearer '+GlobalData.token
          }
      );
      print("[NotificationModel.getNotificationFromServer] ${res.body}");
      final body = jsonDecode(res.body);
      if(res.statusCode==200){
        revisions.clear();
        for(var json in body){
          revisions.add(Revision.fromJson(json));
        }
        notifyListeners();
      }
    }catch(e){
      print("[NotificationModel.getNotificationFromServer] $e");
    }
  }

  removeRevision(Revision revision){
    revisions.remove(revision);
    notifyListeners();
  }
}

class AppNotification {
  String body;
  String title;
  bool seen;
  String date;
  String type;

  AppNotification({
    this.body,
    this.title,
    this.seen,
    this.date,
    this.type,
  });

  AppNotification.fromJsonFirebase(Map<String, dynamic> json) {
    try {
      var notification;
      if(json['data']!=null){
        notification = json['data']; // android
      }else{
        notification = json; // iOS real device
      }
      print("[AppNotification.fromJsonFirebase] $notification");
      body = notification['body'];
      title = notification['title'];
      type = notification['notify_type'];
      seen = false;
      date = DateTime.now().toString();
    } catch (e) {
      print("AppNotification.fromJsonFirebase--$e");
    }
  }


  AppNotification.fromLocalStorage(Map<String, dynamic> json) {
    try {
      body = json['body'];
      title = json['title'];
      date = json['date'];
      type = json['notify_type'];
      seen = json['seen'];
    } catch (e) {
      print("AppNotification.fromLocalStorage--$e");
    }
  }


  Map<String, dynamic> toJson() => {
    'body': body,
    'title': title,
    'notify_type': type,
    'seen': seen,
    'date': date,
  };
}
