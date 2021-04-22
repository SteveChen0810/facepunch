import 'dart:convert';
import 'package:localstorage/localstorage.dart';
import 'package:flutter/material.dart';
import 'revision_model.dart';
import 'package:http/http.dart' as http;
import 'app_const.dart';

class NotificationModel with ChangeNotifier {
  final LocalStorage storage = LocalStorage('notifications');
  List<AppNotification> notifications = [];

  NotificationModel(){
    getNotificationsFromLocal();
  }

  getNotificationsFromLocal()async{
    try {
      final ready = await storage.ready;
      if (ready) {
        var json = storage.getItem('notifications');
        if(json!=null){
          notifications.clear();
          for(var notification in json){
            notifications.add(AppNotification.fromLocalStorage(notification));
          }
        }
      }
      notifyListeners();
    } catch (err) {
      print("getNotificationsFromLocal--$err");
    }
  }

  Future<void> saveToLocal() async {
    try {
      final ready = await storage.ready;
      if (ready) {
        await storage.setItem('notifications', notifications.map((v) => v.toJson()).toList());
      }
      notifyListeners();
    } catch (err) {
      print("NotificationSettingModel.saveToLocal-$err");
    }
  }

  addNotification(AppNotification newNotification)async{
    notifications.insert(0,newNotification);
    await saveToLocal();
    notifyListeners();
  }

  removeNotification(AppNotification notification)async{
    notifications.remove(notification);
    await saveToLocal();
    if(notification.revision!=null){
      deleteRevision(notification.revision);
    }
    notifyListeners();
  }

  updateSeen(AppNotification notification)async{
    notification.seen = true;
    await saveToLocal();
    notifyListeners();
  }

  getNotificationFromServer()async{
    try{
      var res = await http.get(
          AppConst.getRevisionRequest,
          headers: {
            'Accept':'application/json',
            'Content-Type':'application/x-www-form-urlencoded',
            'Authorization':'Bearer '+GlobalData.token
          },
      );
      print("[NotificationModel.getNotificationFromServer] ${res.body}");
      if(res.statusCode==200){
        notifications.clear();
        for(var json in jsonDecode(res.body)){
         Revision revision = Revision.fromJson(json);
         AppNotification notification = AppNotification(
           title: "FACE PUNCH",
           body: "Hour Revision Request",
           date: DateTime.now().toString(),
           revision: revision,
           seen: false,
           type: "revision_request",
         );
         notifications.add(notification);
        }
        saveToLocal();
      }
    }catch(e){
      print("[NotificationModel.getNotificationFromServer] $e");
    }
  }

  Future<String> acceptRevision(Revision revision)async{
    try{
      var res = await http.post(
          AppConst.acceptRevision,
          headers: {
            'Accept':'application/json',
            'Content-Type':'application/x-www-form-urlencoded',
            'Authorization':'Bearer '+GlobalData.token
          },
          body: {
            'id':revision.id.toString()
          }
      );
      print("[NotificationModel.acceptRevision] ${res.body}");
      if(res.statusCode==200){
        revision.status = "accepted";
        saveToLocal();
        return null;
      }else{
        return jsonDecode(res.body)['message'];
      }
    }catch(e){
      print("[NotificationModel.acceptRevision] $e");
      return e.toString();
    }
  }

  Future<String> declineRevision(Revision revision)async{
    try{
      var res = await http.post(
          AppConst.declineRevision,
          headers: {
            'Accept':'application/json',
            'Content-Type':'application/x-www-form-urlencoded',
            'Authorization':'Bearer '+GlobalData.token
          },
          body: {
            'id':revision.id.toString()
          }
      );
      print("[NotificationModel.declineRevision] ${res.body}");
      if(res.statusCode==200){
        revision.status = "declined";
        saveToLocal();
        return null;
      }else{
        return jsonDecode(res.body)['message'];
      }
    }catch(e){
      print("[NotificationModel.declineRevision] $e");
      return e.toString();
    }
  }

  deleteRevision(Revision revision)async{
    try{
      var res = await http.post(
          AppConst.deleteRevision,
          headers: {
            'Accept':'application/json',
            'Content-Type':'application/x-www-form-urlencoded',
            'Authorization':'Bearer '+GlobalData.token
          },
          body: {
            'id':revision.id.toString()
          }
      );
      print("[NotificationModel.deleteRevision] ${res.body}");
    }catch(e){
      print("[NotificationModel.deleteRevision] $e");
    }
  }
}


class AppNotification {
  String body;
  String title;
  bool seen;
  String date;
  String type;
  Revision revision;

  AppNotification({
    this.body,
    this.title,
    this.seen,
    this.date,
    this.type,
    this.revision
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
      if(notification['revision']!=null){
        revision = Revision.fromJson(jsonDecode(notification['revision']));
      }
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
      if(json['revision']!=null){
        revision = Revision.fromJson(json['revision']);
      }
      seen = json['seen'];
    } catch (e) {
      print("AppNotification.fromLocalStorage--$e");
    }
  }


  Map<String, dynamic> toJson() => {
    'body': body,
    'title': title,
    'notify_type': type,
    'revision': revision.toJson(),
    'seen': seen,
    'date': date,
  };
}
