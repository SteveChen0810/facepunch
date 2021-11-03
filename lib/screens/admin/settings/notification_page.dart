import 'package:facepunch/lang/l10n.dart';
import 'package:facepunch/models/app_const.dart';
import 'package:facepunch/models/notification.dart';
import 'package:facepunch/models/revision_model.dart';
import 'package:facepunch/widgets/calendar_strip/date-utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:provider/provider.dart';

class NotificationPage extends StatefulWidget {

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  RefreshController _refreshController = RefreshController(initialRefresh: true);
  Revision _revision;

  void _onRefresh() async{
    await context.read<NotificationModel>().getNotificationFromServer();
    _refreshController.refreshCompleted();
  }

  Widget _notificationItem(Revision revision){
    try{
      if(!revision.isValid()) return SizedBox();
      if(revision == _revision){
        return Container(
            decoration: BoxDecoration(
                border: Border.symmetric(horizontal: BorderSide(color: Colors.grey, width: 0.5),),
            ),
            padding: EdgeInsets.all(16),
            width: double.infinity,
            alignment: Alignment.center,
            child: CircularProgressIndicator()
        );
      }
      return Slidable(
        actionPane: SlidableDrawerActionPane(),
        actionExtentRatio: 0.15,
        secondaryActions: <Widget>[
          IconSlideAction(
            caption: S.of(context).delete,
            color: Colors.red,
            icon: Icons.delete,
            onTap: ()async{
              setState(() { _revision = revision;});
              String result = await revision.delete();
              setState(() { _revision = null;});
              if(result == null){
                context.read<NotificationModel>().removeRevision(revision);
              }else{
                _showMessage(result);
              }
            },
          ),
        ],
        child: InkWell(
          onTap: ()=>_showRevisionDialog(revision),
          child: Container(
            decoration: BoxDecoration(
              border: Border.symmetric(horizontal: BorderSide(color: Colors.grey, width: 0.5),)
            ),
            padding: EdgeInsets.all(8),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(PunchDateUtils.toDateTime(revision.createdAt)),
                    SizedBox(height: 8,),
                    Text('${revision.type.toUpperCase()}', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),),
                  ],
                ),
                Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text('${revision.user.getFullName()}',
                        style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    )
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: revision.statusColor(),
                    borderRadius: BorderRadius.circular(20)
                  ),
                  child: Text('${revision.status?.toUpperCase()}', style: TextStyle(color: Colors.white),)
                )
              ],
            ),
          ),
        ),
      );
    }catch(e){
      return Container(
          decoration: BoxDecoration(
            border: Border.symmetric(horizontal: BorderSide(color: Colors.grey, width: 0.5),),
            color: Colors.red
          ),
          padding: EdgeInsets.all(8),
          width: double.infinity,
          child: Text(e.toString())
      );
    }
  }

  _showMessage(String message){
    _scaffoldKey.currentState.hideCurrentSnackBar();
    _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
          action: SnackBarAction(onPressed: (){},label: S.of(context).close,textColor: Colors.white,),
        )
    );
  }

  _showRevisionDialog(Revision revision){
    Widget content = SizedBox();
    try{
      if(revision.type == 'schedule'){
        content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(S.of(context).project, style: TextStyle(fontWeight: FontWeight.w500),),
            if(revision.newValue['project_id'] != revision.oldValue['project_id'])
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text("  ${S.of(context).incorrect}: "),
                      Expanded(child: Text(revision.oldValue['project_name'])),
                    ],
                  ),
                  Row(
                    children: [
                      Text("  ${S.of(context).correct}:    "),
                      Expanded(child: Text(revision.newValue['project_name'])),
                    ],
                  ),
                ],
              ),
            if(revision.newValue['project_id'] == revision.oldValue['project_id'])
              Text('  ${revision.oldValue['project_name']}'),
            Text(S.of(context).task, style: TextStyle(fontWeight: FontWeight.w500),),
            if(revision.newValue['task_id'] != revision.oldValue['task_id'])
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text("  ${S.of(context).incorrect}: "),
                      Expanded(child: Text(revision.oldValue['task_name'])),
                    ],
                  ),
                  Row(
                    children: [
                      Text("  ${S.of(context).correct}:    "),
                      Expanded(child: Text(revision.newValue['task_name'])),
                    ],
                  ),
                ],
              ),
            if(revision.newValue['task_id'] == revision.oldValue['task_id'])
              Text("  ${revision.oldValue['task_name']}"),
            if(revision.newValue['start'] != revision.oldValue['start'])
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(S.of(context).start, style: TextStyle(fontWeight: FontWeight.w500),),
                  Row(
                    children: [
                      Text("  ${S.of(context).incorrect}: "),
                      Expanded(child: Text(PunchDateUtils.getTimeString(revision.oldValue['start']))),
                    ],
                  ),
                  Row(
                    children: [
                      Text("  ${S.of(context).correct}:    "),
                      Expanded(child: Text(PunchDateUtils.getTimeString(revision.newValue['start']))),
                    ],
                  ),
                ],
              ),
            if(revision.newValue['end'] != revision.oldValue['end'])
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(S.of(context).end, style: TextStyle(fontWeight: FontWeight.w500),),
                  Row(
                    children: [
                      Text("  ${S.of(context).incorrect}: "),
                      Expanded(child: Text(PunchDateUtils.getTimeString(revision.oldValue['end']))),
                    ],
                  ),
                  Row(
                    children: [
                      Text("  ${S.of(context).correct}:    "),
                      Expanded(child: Text(PunchDateUtils.getTimeString(revision.newValue['end']))),
                    ],
                  ),
                ],
              ),
          ],
        );
      }
      if(revision.type == 'punch'){
        content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(S.of(context).punch, style: TextStyle(fontWeight: FontWeight.w500),),
            Row(
              children: [
                Text("  ${S.of(context).incorrect}: "),
                Expanded(child: Text(PunchDateUtils.getTimeString(revision.oldValue))),
              ],
            ),
            Row(
              children: [
                Text("  ${S.of(context).correct}:    "),
                Expanded(child: Text(PunchDateUtils.getTimeString(revision.newValue))),
              ],
            ),
          ],
        );
      }
      if(revision.type == 'break'){
        content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(S.of(context).breakTime, style: TextStyle(fontWeight: FontWeight.w500),),
            Row(
              children: [
                Text("  ${S.of(context).incorrect}: "),
                Expanded(child: Text(PunchDateUtils.getTimeString(revision.oldValue['start']))),
              ],
            ),
            Row(
              children: [
                Text("  ${S.of(context).correct}:    "),
                Expanded(child: Text(PunchDateUtils.getTimeString(revision.newValue['start']))),
              ],
            ),
            Text(S.of(context).length, style: TextStyle(fontWeight: FontWeight.w500),),
            Row(
              children: [
                Text("  ${S.of(context).incorrect}: "),
                Expanded(child: Text('${revision.oldValue['length']} M')),
              ],
            ),
            Row(
              children: [
                Text("  ${S.of(context).correct}:    "),
                Expanded(child: Text('${revision.newValue['length']} M')),
              ],
            ),
          ],
        );
      }
      if(revision.type == 'call'){
        content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(S.of(context).project, style: TextStyle(fontWeight: FontWeight.w500),),
            if(revision.newValue['project_id'] != revision.oldValue['project_id'])
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text("  ${S.of(context).incorrect}: "),
                      Expanded(child: Text(revision.oldValue['project_name'])),
                    ],
                  ),
                  Row(
                    children: [
                      Text("  ${S.of(context).correct}:    "),
                      Expanded(child: Text(revision.newValue['project_name'])),
                    ],
                  ),
                ],
              ),
            if(revision.newValue['project_id'] == revision.oldValue['project_id'])
              Text('  ${revision.oldValue['project_name']}'),
            Text(S.of(context).task, style: TextStyle(fontWeight: FontWeight.w500),),
            if(revision.newValue['task_id'] != revision.oldValue['task_id'])
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text("  ${S.of(context).incorrect}: "),
                      Expanded(child: Text(revision.oldValue['task_name'])),
                    ],
                  ),
                  Row(
                    children: [
                      Text("  ${S.of(context).correct}:    "),
                      Expanded(child: Text(revision.newValue['task_name'])),
                    ],
                  ),
                ],
              ),
            if(revision.newValue['task_id'] == revision.oldValue['task_id'])
              Text("  ${revision.oldValue['task_name']}"),
            if(revision.newValue['priority'] != revision.oldValue['priority'])
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(S.of(context).priority, style: TextStyle(fontWeight: FontWeight.w500),),
                  Row(
                    children: [
                      Text("  ${S.of(context).incorrect}: "),
                      Expanded(child: Text('${revision.oldValue['priority']}')),
                    ],
                  ),
                  Row(
                    children: [
                      Text("  ${S.of(context).correct}:    "),
                      Expanded(child: Text('${revision.newValue['priority']}')),
                    ],
                  ),
                ],
              ),
            if(revision.newValue['start'] != revision.oldValue['start'])
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(S.of(context).start, style: TextStyle(fontWeight: FontWeight.w500),),
                  Row(
                    children: [
                      Text("  ${S.of(context).incorrect}: "),
                      Expanded(child: Text(PunchDateUtils.getTimeString(revision.oldValue['start']))),
                    ],
                  ),
                  Row(
                    children: [
                      Text("  ${S.of(context).correct}:    "),
                      Expanded(child: Text(PunchDateUtils.getTimeString(revision.newValue['start']))),
                    ],
                  ),
                ],
              ),
            if(revision.newValue['end'] != revision.oldValue['end'])
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(S.of(context).end, style: TextStyle(fontWeight: FontWeight.w500),),
                  Row(
                    children: [
                      Text("  ${S.of(context).incorrect}: "),
                      Expanded(child: Text(PunchDateUtils.getTimeString(revision.oldValue['end']))),
                    ],
                  ),
                  Row(
                    children: [
                      Text("  ${S.of(context).correct}:    "),
                      Expanded(child: Text(PunchDateUtils.getTimeString(revision.newValue['end']))),
                    ],
                  ),
                ],
              ),
          ],
        );
      }
      if(revision.type == 'work'){
        content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(S.of(context).project, style: TextStyle(fontWeight: FontWeight.w500),),
            if(revision.newValue['project_id'] != revision.oldValue['project_id'])
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text("  ${S.of(context).incorrect}: "),
                      Expanded(child: Text(revision.oldValue['project_name'])),
                    ],
                  ),
                  Row(
                    children: [
                      Text("  ${S.of(context).correct}:    "),
                      Expanded(child: Text(revision.newValue['project_name'])),
                    ],
                  ),
                ],
              ),
            if(revision.newValue['project_id'] == revision.oldValue['project_id'])
              Text('  ${revision.oldValue['project_name']}'),
            Text(S.of(context).task, style: TextStyle(fontWeight: FontWeight.w500),),
            if(revision.newValue['task_id'] != revision.oldValue['task_id'])
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text("  ${S.of(context).incorrect}: "),
                      Expanded(child: Text(revision.oldValue['task_name'])),
                    ],
                  ),
                  Row(
                    children: [
                      Text("  ${S.of(context).correct}:    "),
                      Expanded(child: Text(revision.newValue['task_name'])),
                    ],
                  ),
                ],
              ),
            if(revision.newValue['task_id'] == revision.oldValue['task_id'])
              Text("  ${revision.oldValue['task_name']}"),
            if(revision.newValue['start'] != revision.oldValue['start'])
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(S.of(context).start, style: TextStyle(fontWeight: FontWeight.w500),),
                  Row(
                    children: [
                      Text("  ${S.of(context).incorrect}: "),
                      Expanded(child: Text(PunchDateUtils.getTimeString(revision.oldValue['start']))),
                    ],
                  ),
                  Row(
                    children: [
                      Text("  ${S.of(context).correct}:    "),
                      Expanded(child: Text(PunchDateUtils.getTimeString(revision.newValue['start']))),
                    ],
                  ),
                ],
              ),
            if(revision.newValue['end'] != revision.oldValue['end'])
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(S.of(context).end, style: TextStyle(fontWeight: FontWeight.w500),),
                  Row(
                    children: [
                      Text("  ${S.of(context).incorrect}: "),
                      Expanded(child: Text(PunchDateUtils.getTimeString(revision.oldValue['end']))),
                    ],
                  ),
                  Row(
                    children: [
                      Text("  ${S.of(context).correct}:    "),
                      Expanded(child: Text(PunchDateUtils.getTimeString(revision.newValue['end']))),
                    ],
                  ),
                ],
              ),
          ],
        );
      }
    }catch(e){
      print('[NotificationPage._showRevisionDialog]$e');
      content = Text(e.toString(), style: TextStyle(color: Colors.red),);
    }

    showDialog(
        context: context,
        builder:(_)=> AlertDialog(
          contentPadding: EdgeInsets.zero,
          insetPadding: EdgeInsets.zero,
          content: Container(
            width: MediaQuery.of(context).size.width-50,
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                    child: Text(
                      "${S.of(context).hourRevisionRequest}",
                      style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18),
                    )
                ),
                content,
                Text(S.of(context).description, style: TextStyle(fontWeight: FontWeight.w500),),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                  child: Text('${revision.description}'),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if(revision.status == 'requested')
                      TextButton(
                          onPressed: ()async{
                            Navigator.pop(context);
                            setState(() { _revision = revision; });
                            String result = await revision.accept();
                            setState(() { _revision = null; });
                            if(result != null){
                              _showMessage(result);
                            }
                          },
                          child: Text(S.of(context).accept, style: TextStyle(color: Colors.green),)
                      ),
                    if(revision.status == 'requested')
                      TextButton(
                          onPressed: ()async{
                            Navigator.pop(context);
                            setState(() { _revision = revision; });
                            String result = await revision.decline();
                            setState(() { _revision = null; });
                            if(result != null){
                              _showMessage(result);
                            }
                          },
                          child: Text(S.of(context).decline, style: TextStyle(color: Colors.orange),)
                      ),
                    TextButton(
                        onPressed: ()async{
                          Navigator.pop(context);
                          setState(() { _revision = revision; });
                          String result = await revision.delete();
                          setState(() { _revision = null; });
                          context.read<NotificationModel>().removeRevision(revision);
                          if(result != null){
                            _showMessage(result);
                          }
                        },
                        child: Text(S.of(context).delete, style: TextStyle(color: Colors.red),)
                    ),
                  ],
                )
              ],
            ),
          ),
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Revision> revisions = context.watch<NotificationModel>().revisions;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(S.of(context).notifications, style: TextStyle(color: Colors.white),),
        backgroundColor: Color(primaryColor),
        centerTitle: true,
      ),
      body: SmartRefresher(
        enablePullDown: true,
        enablePullUp: false,
        header: WaterDropMaterialHeader(backgroundColor: Color(primaryColor),distance: 60,),
        controller: _refreshController,
        onRefresh: _onRefresh,
        child: ListView(
          children: [
            for(Revision revision in revisions)
              _notificationItem(revision),
          ],
        ),
      ),
    );
  }
}