import 'dart:convert';
import 'package:localstorage/localstorage.dart';

import 'base_model.dart';
import 'revision_model.dart';
import 'app_const.dart';
import '/widgets/utils.dart';

class NotificationModel extends BaseProvider {
  final LocalStorage storage = LocalStorage('notifications');
  List<Revision> revisions = [];


  Future<void> getNotificationFromServer()async{
    try{
      var res = await sendGetRequest(
          AppConst.getRevisionRequest,
          GlobalData.token
      );
      Tools.consoleLog("[NotificationModel.getNotificationFromServer.res] ${res.body}");
      final body = jsonDecode(res.body);
      if(res.statusCode==200){
        revisions.clear();
        for(var json in body){
          revisions.add(Revision.fromJson(json));
        }
        notifyListeners();
      }
    }catch(e){
      Tools.consoleLog("[NotificationModel.getNotificationFromServer.res] $e");
    }
  }

  removeRevision(Revision revision){
    revisions.remove(revision);
    notifyListeners();
  }
}

class AppNotification {
  String? body;
  String? title;
  bool? seen;
  String? date;
  String? type;

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
      Tools.consoleLog("[AppNotification.fromJsonFirebase.res] $notification");
      body = notification['body'];
      title = notification['title'];
      type = notification['notify_type'];
      seen = false;
      date = DateTime.now().toString();
    } catch (e) {
      Tools.consoleLog("[AppNotification.fromJsonFirebase.err]$e");
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
      Tools.consoleLog("[AppNotification.fromLocalStorage.err]$e");
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
