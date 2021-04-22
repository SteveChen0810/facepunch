import 'package:facepunch/models/app_const.dart';
import 'package:facepunch/models/notification.dart';
import 'package:facepunch/widgets/calendar_strip/date-utils.dart';
import 'package:facepunch/widgets/dialogs.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class NotificationPage extends StatefulWidget {

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  RefreshController _refreshController = RefreshController(initialRefresh: false);

  void _onRefresh() async{
    await context.read<NotificationModel>().getNotificationFromServer();
    _refreshController.refreshCompleted();
  }

  Widget _notificationItem(AppNotification notification){
    try{
      DateTime date = DateTime.parse(notification.revision.createdAt);
      return Card(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Slidable(
            actionPane: SlidableDrawerActionPane(),
            actionExtentRatio: 0.15,
            secondaryActions: <Widget>[
              IconSlideAction(
                caption: 'Delete',
                color: Colors.red,
                icon: Icons.delete,
                onTap: (){
                  context.read<NotificationModel>().removeNotification(notification);
                },
              ),
            ],
            child: ListTile(
              title: Text(
                "${notification.revision.user.firstName} ${notification.revision.user.lastName}",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: Text("${notification.revision.status.toUpperCase()}"),
              leading: Icon(Icons.notifications_on_rounded,color: notification.seen?Colors.grey:Colors.red,),
              subtitle: Text("${PunchDateUtils.getDateString(date)} ${PunchDateUtils.getTimeString(date)}",style: TextStyle(fontSize: 12),),
              visualDensity: VisualDensity.compact,
              onTap: (){
                if(!notification.seen)context.read<NotificationModel>().updateSeen(notification);
                showRevisionNotificationDialog(notification, context, showMessage);
              },
            ),
          ),
        ),
      );
    }catch(e){
      print("[NotificationPage._notificationItem] $e");
      return SizedBox();
    }
  }

  showMessage(String message){
    _scaffoldKey.currentState.hideCurrentSnackBar();
    _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
          action: SnackBarAction(onPressed: (){},label: 'Close',textColor: Colors.white,),
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    List<AppNotification> notifications  = context.watch<NotificationModel>().notifications;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Notifications"),
        backgroundColor: Color(primaryColor),
      ),
      body: Container(
        margin: EdgeInsets.all(8),
        child: SmartRefresher(
          enablePullDown: true,
          enablePullUp: false,
          header: WaterDropMaterialHeader(backgroundColor: Color(primaryColor),distance: 60,),
          controller: _refreshController,
          onRefresh: _onRefresh,
          child: ListView(
            children: [
              for(AppNotification notification in notifications)
                _notificationItem(notification),
            ],
          ),
        ),
      ),
      backgroundColor: Color(primaryColor),
    );
  }
}