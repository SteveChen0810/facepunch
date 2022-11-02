import 'package:facepunch/providers/notification_provider.dart';
import 'package:facepunch/widgets/TimeEditor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:provider/provider.dart';
import 'package:loader_overlay/loader_overlay.dart';
import '/lang/l10n.dart';
import '/config/app_const.dart';
import '/models/revision_model.dart';
import '/widgets/calendar_strip/date-utils.dart';
import '/widgets/utils.dart';

class NotificationPage extends StatefulWidget {

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  RefreshController _refreshController = RefreshController(initialRefresh: true);


  void _onRefresh() async{
    await context.read<NotificationProvider>().getNotificationFromServer();
    _refreshController.refreshCompleted();
  }

  Widget _notificationItem(Revision revision){
    try{
      return Slidable(
        endActionPane: ActionPane(
          motion: ScrollMotion(),
          extentRatio: 0.2,
          children: [
            SlidableAction(
              onPressed: (_)async{
                context.loaderOverlay.show();
                String? result = await revision.delete();
                context.loaderOverlay.hide();
                if(result == null){
                  context.read<NotificationProvider>().removeRevision(revision);
                }else{
                  Tools.showErrorMessage(context, result);
                }
              },
              icon: Icons.delete,
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ]
        ),
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
                    Text('${revision.type?.toUpperCase()}', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),),
                  ],
                ),
                Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text('${revision.user?.getFullName()}',
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

  _showRevisionDialog(Revision revision){
    Widget content = SizedBox();
    try{
      if(revision.type == 'schedule'){
        if(revision.isChanged('start')){
          revision.correctStartTime = PunchDateUtils.toDateHourMinute(revision.newValue['start']);
        }
        if(revision.isChanged('end')){
          revision.correctEndTime = PunchDateUtils.toDateHourMinute(revision.newValue['end']);
        }
        content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(S.of(context).project, style: TextStyle(fontWeight: FontWeight.w500),),
            if(revision.isChanged('project_id'))
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("  ${S.of(context).incorrect}: "),
                      Expanded(child: Text(revision.projectTitle(isNewValue: false))),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("  ${S.of(context).correct}:    "),
                      Expanded(child: Text(revision.projectTitle(isNewValue: true))),
                    ],
                  ),
                ],
              ),
            if(!revision.isChanged('project_id'))
              Text('  ${revision.projectTitle(isNewValue: false)}'),
            Text(S.of(context).task, style: TextStyle(fontWeight: FontWeight.w500),),
            if(revision.isChanged('task_id'))
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("  ${S.of(context).incorrect}: "),
                      Expanded(child: Text(revision.taskTitle(isNewValue: false))),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("  ${S.of(context).correct}:    "),
                      Expanded(child: Text(revision.taskTitle(isNewValue: true))),
                    ],
                  ),
                ],
              ),
            if(!revision.isChanged('task_id'))
              Text("  ${revision.taskTitle(isNewValue: false)}"),
            if(revision.isChanged('start'))
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
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TimeEditor(
                      initTime: revision.newValue['start'],
                      isOptional: false,
                      label: S.of(context).correct,
                      onChanged: (v){
                        if(v != null){
                          revision.correctStartTime = PunchDateUtils.toDateHourMinute(v);
                        }else{
                          revision.correctStartTime = null;
                        }
                      },
                    ),
                  )
                ],
              ),
            if(!revision.isChanged('start'))
              Row(
                children: [
                  Text('${S.of(context).start} : ', style: TextStyle(fontWeight: FontWeight.w500),),
                  Expanded(child: Text(PunchDateUtils.getTimeString(revision.oldValue['start']))),
                ],
              ),
            if(revision.isChanged('end'))
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
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TimeEditor(
                      initTime: revision.newValue['end'],
                      isOptional: false,
                      label: S.of(context).correct,
                      onChanged: (v){
                        if(v != null){
                          revision.correctEndTime = PunchDateUtils.toDateHourMinute(v);
                        }else{
                          revision.correctEndTime = null;
                        }
                      },
                    ),
                  )
                ],
              ),
            if(!revision.isChanged('end'))
              Row(
                children: [
                  Text('${S.of(context).end} : ', style: TextStyle(fontWeight: FontWeight.w500),),
                  Expanded(child: Text(PunchDateUtils.getTimeString(revision.oldValue['end']))),
                ],
              ),
          ],
        );
      }
      if(revision.type == 'timebox'){
        if(revision.isChanged('start')){
          revision.correctStartTime = PunchDateUtils.toDateHourMinute(revision.newValue['start']);
        }
        if(revision.isChanged('end')){
          revision.correctEndTime = PunchDateUtils.toDateHourMinute(revision.newValue['end']);
        }
        content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if(revision.isChanged('start'))
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
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TimeEditor(
                      initTime: revision.newValue['start'],
                      isOptional: false,
                      label: S.of(context).correct,
                      onChanged: (v){
                        if(v != null){
                          revision.correctStartTime = PunchDateUtils.toDateHourMinute(v);
                        }else{
                          revision.correctStartTime = null;
                        }
                      },
                    ),
                  )
                ],
              ),
            if(!revision.isChanged('start'))
              Row(
                children: [
                  Text('${S.of(context).start} : ', style: TextStyle(fontWeight: FontWeight.w500),),
                  Expanded(child: Text(PunchDateUtils.getTimeString(revision.oldValue['start']))),
                ],
              ),
            if(revision.isChanged('end'))
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
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TimeEditor(
                      initTime: revision.newValue['end'],
                      isOptional: false,
                      label: S.of(context).correct,
                      onChanged: (v){
                        if(v != null){
                          revision.correctEndTime = PunchDateUtils.toDateHourMinute(v);
                        }else{
                          revision.correctEndTime = null;
                        }
                      },
                    ),
                  )
                ],
              ),
            if(!revision.isChanged('end'))
              Row(
                children: [
                  Text('${S.of(context).end} : ', style: TextStyle(fontWeight: FontWeight.w500),),
                  Expanded(child: Text(PunchDateUtils.getTimeString(revision.oldValue['end']))),
                ],
              ),
          ],
        );
      }
      if(revision.type == 'punch'){
        revision.correctPunchTime = PunchDateUtils.toDateHourMinute(revision.newValue);
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TimeEditor(
                initTime: revision.newValue,
                isOptional: false,
                label: S.of(context).correct,
                onChanged: (v){
                  if(v != null){
                    revision.correctPunchTime = PunchDateUtils.toDateHourMinute(v);
                  }else{
                    revision.correctPunchTime = null;
                  }
                },
              ),
            )
          ],
        );
      }
      if(revision.type == 'break'){
        revision.correctStartTime = PunchDateUtils.toDateHourMinute(revision.newValue['start']);
        revision.correctLength = revision.newValue['length'].toString();
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TimeEditor(
                initTime: revision.newValue['start'],
                isOptional: false,
                label: S.of(context).correct,
                onChanged: (v){
                  if(v != null){
                    revision.correctStartTime = PunchDateUtils.toDateHourMinute(v);
                  }else{
                    revision.correctStartTime = null;
                  }
                },
              ),
            ),
            Text(S.of(context).length, style: TextStyle(fontWeight: FontWeight.w500),),
            Row(
              children: [
                Text("  ${S.of(context).incorrect}: "),
                Expanded(child: Text('${revision.oldValue['length']} M')),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "${S.of(context).correct} (M)",
                    isDense: true
                ),
                keyboardType: TextInputType.number,
                onChanged: (v){
                  revision.correctLength = v;
                },
                controller: TextEditingController(text: '${revision.newValue['length']}'),
              ),
            ),
          ],
        );
      }
      if(revision.type == 'call'){
        content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(S.of(context).project, style: TextStyle(fontWeight: FontWeight.w500),),
            if(revision.isChanged('project_id'))
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("  ${S.of(context).incorrect}: "),
                      Expanded(child: Text(revision.projectTitle(isNewValue: false))),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("  ${S.of(context).correct}:    "),
                      Expanded(child: Text(revision.projectTitle(isNewValue: true))),
                    ],
                  ),
                ],
              ),
            if(!revision.isChanged('project_id'))
              Text('  ${revision.projectTitle(isNewValue: false)}'),
            Text(S.of(context).task, style: TextStyle(fontWeight: FontWeight.w500),),
            if(revision.isChanged('task_id'))
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("  ${S.of(context).incorrect}: "),
                      Expanded(child: Text(revision.taskTitle(isNewValue: false))),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("  ${S.of(context).correct}:    "),
                      Expanded(child: Text(revision.taskTitle(isNewValue: true))),
                    ],
                  ),
                ],
              ),
            if(!revision.isChanged('task_id'))
              Text("  ${revision.taskTitle(isNewValue: false)}"),
            if(revision.isChanged('priority'))
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
            if(!revision.isChanged('priority'))
              Row(
                children: [
                  Text('${S.of(context).priority} : ', style: TextStyle(fontWeight: FontWeight.w500),),
                  Expanded(child: Text('${revision.oldValue['priority']}')),
                ],
              ),
          ],
        );
      }
      if(revision.type == 'work'){
        if(revision.isChanged('start')){
          revision.correctStartTime = PunchDateUtils.toDateHourMinute(revision.newValue['start']);
        }
        if(revision.isChanged('end')){
          revision.correctEndTime = PunchDateUtils.toDateHourMinute(revision.newValue['end']);
        }
        content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(S.of(context).project, style: TextStyle(fontWeight: FontWeight.w500),),
            if(revision.isChanged('project_id'))
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("  ${S.of(context).incorrect}: "),
                      Expanded(child: Text(revision.projectTitle(isNewValue: false))),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("  ${S.of(context).correct}:    "),
                      Expanded(child: Text(revision.projectTitle(isNewValue: true))),
                    ],
                  ),
                ],
              ),
            if(!revision.isChanged('project_id'))
              Text('  ${revision.projectTitle(isNewValue: false)}'),
            Text(S.of(context).task, style: TextStyle(fontWeight: FontWeight.w500),),
            if(revision.isChanged('task_id'))
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("  ${S.of(context).incorrect}: "),
                      Expanded(child: Text(revision.taskTitle(isNewValue: false))),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("  ${S.of(context).correct}:    "),
                      Expanded(child: Text(revision.taskTitle(isNewValue: true))),
                    ],
                  ),
                ],
              ),
            if(!revision.isChanged('task_id'))
              Text("  ${revision.taskTitle(isNewValue: false)}"),
            if(revision.isChanged('start'))
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
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TimeEditor(
                      initTime: revision.newValue['start'],
                      isOptional: false,
                      label: S.of(context).correct,
                      onChanged: (v){
                        if(v != null){
                          revision.correctStartTime = PunchDateUtils.toDateHourMinute(v);
                        }else{
                          revision.correctStartTime = null;
                        }
                      },
                    ),
                  ),
                ],
              ),
            if(!revision.isChanged('start'))
              Row(
                children: [
                  Text('${S.of(context).start} : ', style: TextStyle(fontWeight: FontWeight.w500),),
                  Expanded(child: Text(PunchDateUtils.getTimeString(revision.oldValue['start']))),
                ],
              ),
            if(revision.isChanged('end'))
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
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TimeEditor(
                      initTime: revision.newValue['end'],
                      isOptional: false,
                      label: S.of(context).correct,
                      onChanged: (v){
                        if(v != null){
                          revision.correctEndTime = PunchDateUtils.toDateHourMinute(v);
                        }else{
                          revision.correctEndTime = null;
                        }
                      },
                    ),
                  ),
                ],
              ),
            if(!revision.isChanged('end'))
              Row(
                children: [
                  Text('${S.of(context).end} : ', style: TextStyle(fontWeight: FontWeight.w500),),
                  Expanded(child: Text(PunchDateUtils.getTimeString(revision.oldValue['end']))),
                ],
              ),
          ],
        );
      }
    }catch(e){
      Tools.consoleLog('[NotificationPage._showRevisionDialog]$e');
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
                  child: Text('${revision.description??''}'),
                ),
              ],
            ),
          ),
          actions: [
            if(revision.status == 'requested')
              TextButton(
                  onPressed: ()async{
                    Navigator.pop(context);
                    context.loaderOverlay.show();
                    String? result = await revision.accept();
                    context.loaderOverlay.hide();
                    if(result != null){
                      Tools.showErrorMessage(context, result);
                    }else{
                      setState(() {});
                    }
                  },
                  child: Text(S.of(context).accept, style: TextStyle(color: Color(primaryColor)),)
              ),
            if(revision.status == 'requested')
              TextButton(
                  onPressed: ()async{
                    Navigator.pop(context);
                    context.loaderOverlay.show();
                    String? result = await revision.decline();
                    context.loaderOverlay.hide();
                    if(result != null){
                      Tools.showErrorMessage(context, result);
                    }else{
                      setState(() {});
                    }
                  },
                  child: Text(S.of(context).decline, style: TextStyle(color: Colors.red),)
              ),
          ],
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Revision> revisions = context.watch<NotificationProvider>().revisions;
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