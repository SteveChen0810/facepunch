import 'package:facepunch/lang/l10n.dart';
import 'package:facepunch/models/app_const.dart';
import 'package:facepunch/models/revision_model.dart';
import 'package:facepunch/models/user_model.dart';
import 'package:facepunch/widgets/calendar_strip/date-utils.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:provider/provider.dart';

class EmployeeNotification extends StatefulWidget {

  @override
  _EmployeeNotificationState createState() => _EmployeeNotificationState();
}

class _EmployeeNotificationState extends State<EmployeeNotification> {

  RefreshController _refreshController = RefreshController(initialRefresh: true);
  List<Revision> revisions = [];
  Revision _revision;

  _onRefresh()async{
    final user = context.read<UserModel>().user;
    String result = await user.getRevisionNotifications();
    if(result==null){
      revisions = user.revisions;
    }else{
      _showMessage(result);
    }
    _refreshController.refreshCompleted();
    if(mounted)setState(() {_revision = null;});
  }

  _showMessage(String message){
    Scaffold.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _revisionItem(Revision revision){
    try{
      if(!revision.isValid())return SizedBox();
      Widget content = Text("Something went wrong.[${revision.id}]");
      if(revision.type == "schedule"){
        content = InkWell(
          onTap: (){
            if(_revision != null) return;
            _showRevisionDialog(revision);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(revision.createdAt),
                  Text(revision.type.toUpperCase())
                ],
              ),
              Text(S.of(context).project, style: TextStyle(fontWeight: FontWeight.bold),),
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
              Text(S.of(context).task, style: TextStyle(fontWeight: FontWeight.bold),),
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
                    Text(S.of(context).start, style: TextStyle(fontWeight: FontWeight.bold),),
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
                    Text(S.of(context).end, style: TextStyle(fontWeight: FontWeight.bold),),
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
          ),
        );
      }
      if(revision == _revision){
        content = Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircularProgressIndicator(strokeWidth: 2,),
          )
        );
      }
      return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey,
              )
            ]
          ),
          padding: EdgeInsets.all(8),
          margin: EdgeInsets.symmetric(vertical: 2,horizontal: 8),
          width: double.infinity,
          child: content
      );
    }catch(e){
      return Container(
        decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(8)
        ),
        padding: EdgeInsets.all(8),
        margin: EdgeInsets.symmetric(vertical: 2, horizontal: 8),
        width: double.infinity,
        child: Text(e.toString())
      );
    }
  }

  _showRevisionDialog(Revision revision){
    String description = '';
    String errorMessage;
    showDialog(
        context: context,
        builder:(_)=> AlertDialog(
          contentPadding: EdgeInsets.zero,
          insetPadding: EdgeInsets.zero,
          content: StatefulBuilder(
              builder: (BuildContext _context, StateSetter _setState){
                return Container(
                  width: MediaQuery.of(context).size.width-50,
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                          child: Text(
                            "${S.of(context).hourRevisionRequest}",
                            style: TextStyle(color: Colors.black87,fontWeight: FontWeight.bold,fontSize: 18),
                          )
                      ),
                      TextField(
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            isDense: true,
                            labelText: S.of(context).description,
                            alignLabelWithHint: true,
                            errorText: errorMessage
                        ),
                        minLines: 3,
                        maxLines: null,
                        onChanged: (v){
                          _setState(() {description = v;});
                        },
                      ),
                      SizedBox(height: 8,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                              onPressed: (){
                                Navigator.of(_context).pop();
                              },
                              child: Text(S.of(context).close, style: TextStyle(color: Colors.red),)
                          ),
                          TextButton(
                              onPressed: (){
                                if(description.isNotEmpty){
                                  setState(() {_revision = revision;});
                                  Navigator.of(_context).pop();
                                  _addDescription(revision, description);
                                }else{
                                  _setState(() { errorMessage = S.of(context).youMustWriteDescription; });
                                }
                              },
                              child: Text(S.of(context).submit, style: TextStyle(color: Colors.green),)
                          ),
                        ],
                      )
                    ],
                  ),
                );
              }
          ),
        )
    );
  }


  _addDescription(Revision revision, description)async{
    String result = await revision.addDescription(description);
    if(result != null){
      _showMessage(result);
    }
    if(mounted) setState(() {
      _revision = null;
      _refreshController.requestRefresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top,
            ),
            height: kToolbarHeight+MediaQuery.of(context).padding.top,
            alignment: Alignment.center,
            color: Color(primaryColor),
            child: Text(S.of(context).notifications, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.white),),
          ),
          Expanded(
            child: SmartRefresher(
              enablePullDown: true,
              enablePullUp: false,
              header: WaterDropMaterialHeader(backgroundColor: Color(primaryColor),distance: 40,),
              controller: _refreshController,
              onRefresh: _onRefresh,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    for(Revision revision in revisions)
                      _revisionItem(revision),
                    if(revisions.isEmpty)
                      Container(
                          height: MediaQuery.of(context).size.height * 0.5,
                          alignment: Alignment.center,
                          child: Text(S.of(context).empty, style: TextStyle(fontSize: 20),)
                      )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}