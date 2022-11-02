import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:provider/provider.dart';
import 'package:loader_overlay/loader_overlay.dart';

import '/lang/l10n.dart';
import '/config/app_const.dart';
import '/models/revision_model.dart';
import '/widgets/calendar_strip/date-utils.dart';
import '/widgets/utils.dart';
import '/widgets/TimeEditor.dart';
import '/providers/user_provider.dart';

class EmployeeRevisions extends StatefulWidget {

  @override
  _EmployeeRevisionState createState() => _EmployeeRevisionState();
}

class _EmployeeRevisionState extends State<EmployeeRevisions> {

  RefreshController _refreshController = RefreshController(initialRefresh: true);
  List<Revision> revisions = [];

  _onRefresh()async{
    final user = context.read<UserProvider>().user;
    String? result = await user!.getRevisionNotifications();
    if(result == null){
      revisions = user.revisions;
    }else{
      Tools.showErrorMessage(context, result);
    }
    _refreshController.refreshCompleted();
    if(mounted)setState(() {});
  }


  Widget _revisionItem(Revision revision){
    try{
      if(!revision.isValid())return SizedBox();
      Widget content = Text("Something went wrong.[${revision.id}]");
      if(revision.type == "schedule"){
        content = InkWell(
          onTap: (){
            _showRevisionDialog(revision);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${revision.type?.toUpperCase()}'),
                  Text('${revision.getTime()}', style: TextStyle(fontWeight: FontWeight.w500),),
                  revision.statusWidget(context),
                ],
              ),
              Text(S.of(context).project, style: TextStyle(fontWeight: FontWeight.bold),),
              if(revision.isChanged('project_id'))
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text("  ${S.of(context).incorrect}: "),
                        Expanded(child: Text(revision.projectTitle(isNewValue: false))),
                      ],
                    ),
                    Row(
                      children: [
                        Text("  ${S.of(context).correct}: "),
                        Expanded(child: Text(revision.projectTitle(isNewValue: true))),
                      ],
                    ),
                  ],
                ),
              if(!revision.isChanged('project_id'))
                Text('  ${revision.projectTitle(isNewValue: false)}'),
              Text(S.of(context).task, style: TextStyle(fontWeight: FontWeight.bold),),
              if(revision.isChanged('task_id'))
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text("  ${S.of(context).incorrect}: "),
                        Expanded(child: Text(revision.taskTitle(isNewValue: false))),
                      ],
                    ),
                    Row(
                      children: [
                        Text("  ${S.of(context).correct}: "),
                        Expanded(child: Text(revision.taskTitle(isNewValue: true))),
                      ],
                    ),
                  ],
                ),
              if(!revision.isChanged('task_id'))
                Text("  ${revision.taskTitle(isNewValue: false)}"),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if(revision.isChanged('start'))
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(S.of(context).start, style: TextStyle(fontWeight: FontWeight.bold),),
                        Row(
                          children: [
                            SizedBox(width: 10,),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("${S.of(context).incorrect}: "),
                                Text("${S.of(context).correct}: "),
                              ],
                            ),
                            Column(
                              children: [
                                Text(PunchDateUtils.getTimeString(revision.oldValue['start'])),
                                Text(PunchDateUtils.getTimeString(revision.newValue['start'])),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  if(revision.isChanged('end'))
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(S.of(context).end, style: TextStyle(fontWeight: FontWeight.bold),),
                        Row(
                          children: [
                            SizedBox(width: 10,),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("${S.of(context).incorrect}: "),
                                Text("${S.of(context).correct}: "),
                              ],
                            ),
                            Column(
                              children: [
                                Text(PunchDateUtils.getTimeString(revision.oldValue['end'])),
                                Text(PunchDateUtils.getTimeString(revision.newValue['end'])),
                              ],
                            )
                          ],
                        ),
                      ],
                    ),
                ],
              ),
              if(!revision.hasDescription())
               Text('*${S.of(context).tapToSubmitDescription}*', style: TextStyle(color: Colors.red),)
            ],
          ),
        );
      }else if(revision.type == "timebox"){
        content = InkWell(
          onTap: (){
            _showRevisionDialog(revision);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${revision.type?.toUpperCase()}'),
                  Text('${revision.getTime()}', style: TextStyle(fontWeight: FontWeight.w500),),
                  revision.statusWidget(context),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if(revision.isChanged('start'))
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(S.of(context).start, style: TextStyle(fontWeight: FontWeight.bold),),
                        Row(
                          children: [
                            SizedBox(width: 10,),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("${S.of(context).incorrect}: "),
                                Text("${S.of(context).correct}: "),
                              ],
                            ),
                            Column(
                              children: [
                                Text(PunchDateUtils.getTimeString(revision.oldValue['start'])),
                                Text(PunchDateUtils.getTimeString(revision.newValue['start'])),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  if(revision.isChanged('end'))
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(S.of(context).end, style: TextStyle(fontWeight: FontWeight.bold),),
                        Row(
                          children: [
                            SizedBox(width: 10,),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("${S.of(context).incorrect}: "),
                                Text("${S.of(context).correct}: "),
                              ],
                            ),
                            Column(
                              children: [
                                Text(PunchDateUtils.getTimeString(revision.oldValue['end'])),
                                Text(PunchDateUtils.getTimeString(revision.newValue['end'])),
                              ],
                            )
                          ],
                        ),
                      ],
                    ),
                ],
              ),
              if(!revision.hasDescription())
                Text('*${S.of(context).tapToSubmitDescription}*', style: TextStyle(color: Colors.red),)
            ],
          ),
        );
      }else if(revision.type == 'punch'){
        content = Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${revision.type?.toUpperCase()}'),
                Text('${revision.getTime()}', style: TextStyle(fontWeight: FontWeight.w500),),
                revision.statusWidget(context),
              ],
            ),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${S.of(context).incorrectPunchTime}: '),
                    Text('${S.of(context).correctPunchTime}: '),
                  ],
                ),
                Column(
                  children: [
                    Text(PunchDateUtils.getTimeString(revision.oldValue)),
                    Text(PunchDateUtils.getTimeString(revision.newValue)),
                  ],
                ),
              ],
            )
          ],
        );
      }else if(revision.type == 'work'){
        content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${revision.type?.toUpperCase()}'),
                Text('${revision.getTime()}', style: TextStyle(fontWeight: FontWeight.w500),),
                revision.statusWidget(context),
              ],
            ),
            Text(S.of(context).project, style: TextStyle(fontWeight: FontWeight.bold),),
            if(revision.isChanged('project_id'))
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text("  ${S.of(context).incorrect}: "),
                      Expanded(child: Text(revision.projectTitle(isNewValue: false))),
                    ],
                  ),
                  Row(
                    children: [
                      Text("  ${S.of(context).correct}: "),
                      Expanded(child: Text(revision.projectTitle(isNewValue: true))),
                    ],
                  ),
                ],
              ),
            if(!revision.isChanged('project_id'))
              Text('  ${revision.projectTitle(isNewValue: false)}'),
            Text(S.of(context).task, style: TextStyle(fontWeight: FontWeight.bold),),
            if(revision.isChanged('task_id'))
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text("  ${S.of(context).incorrect}: "),
                      Expanded(child: Text(revision.taskTitle(isNewValue: false))),
                    ],
                  ),
                  Row(
                    children: [
                      Text("  ${S.of(context).correct}: "),
                      Expanded(child: Text(revision.taskTitle(isNewValue: true))),
                    ],
                  ),
                ],
              ),
            if(!revision.isChanged('task_id'))
              Text("  ${revision.taskTitle(isNewValue: false)}"),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if(revision.isChanged('start'))
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(S.of(context).start, style: TextStyle(fontWeight: FontWeight.bold),),
                      Row(
                        children: [
                          SizedBox(width: 10,),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("${S.of(context).incorrect}: "),
                              Text("${S.of(context).correct}: "),
                            ],
                          ),
                          Column(
                            children: [
                              Text(PunchDateUtils.getTimeString(revision.oldValue['start'])),
                              Text(PunchDateUtils.getTimeString(revision.newValue['start'])),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                if(revision.isChanged('end'))
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(S.of(context).end, style: TextStyle(fontWeight: FontWeight.bold),),
                      Row(
                        children: [
                          SizedBox(width: 10,),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("${S.of(context).incorrect}: "),
                              Text("${S.of(context).correct}: "),
                            ],
                          ),
                          Column(
                            children: [
                              Text(PunchDateUtils.getTimeString(revision.oldValue['end'])),
                              Text(PunchDateUtils.getTimeString(revision.newValue['end'])),
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
              ],
            ),
          ],
        );
      }else if(revision.type == 'call'){
        content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${revision.type?.toUpperCase()}'),
                Text('${revision.getTime()}', style: TextStyle(fontWeight: FontWeight.w500),),
                revision.statusWidget(context),
              ],
            ),
            Text(S.of(context).project, style: TextStyle(fontWeight: FontWeight.bold),),
            if(revision.isChanged('project_id'))
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text("  ${S.of(context).incorrect}: "),
                      Expanded(child: Text(revision.projectTitle(isNewValue: false))),
                    ],
                  ),
                  Row(
                    children: [
                      Text("  ${S.of(context).correct}:    "),
                      Expanded(child: Text(revision.projectTitle(isNewValue: true))),
                    ],
                  ),
                ],
              ),
            if(!revision.isChanged('project_id'))
              Text('  ${revision.projectTitle(isNewValue: false)}'),
            Text(S.of(context).task, style: TextStyle(fontWeight: FontWeight.bold),),
            if(revision.isChanged('task_id'))
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text("  ${S.of(context).incorrect}: "),
                      Expanded(child: Text(revision.taskTitle(isNewValue: false))),
                    ],
                  ),
                  Row(
                    children: [
                      Text("  ${S.of(context).correct}: "),
                      Expanded(child: Text(revision.taskTitle(isNewValue: true)))
                    ],
                  ),
                ],
              ),
            if(!revision.isChanged('task_id'))
              Text("  ${revision.taskTitle(isNewValue: false)}"),
            Text(S.of(context).priority, style: TextStyle(fontWeight: FontWeight.bold),),
            if(revision.isChanged('priority'))
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 10,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("${S.of(context).incorrect}: "),
                      Text("${S.of(context).correct}:"),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${revision.oldValue['priority']}'),
                      Text('${revision.newValue['priority']}')
                    ],
                  ),
                ],
              ),
            if(!revision.isChanged('priority'))
              Text("  ${revision.oldValue['priority']}"),
          ],
        );
      }else if(revision.type == 'break'){
        content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${revision.type?.toUpperCase()}'),
                Text('${revision.getTime()}', style: TextStyle(fontWeight: FontWeight.w500),),
                revision.statusWidget(context),
              ],
            ),
            Text('${revision.oldValue['title']}', style: TextStyle(fontWeight: FontWeight.bold),),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(S.of(context).length, style: TextStyle(fontWeight: FontWeight.bold),),
                    if(revision.isChanged('length'))
                      Row(
                        children: [
                          SizedBox(width: 10,),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${S.of(context).incorrect}: '),
                              Text('${S.of(context).correct}: '),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${revision.oldValue['length']}M'),
                              Text('${revision.newValue['length']}M'),
                            ],
                          ),
                        ],
                      ),
                    if(!revision.isChanged('length'))
                      Text('  ${revision.oldValue['length']}M'),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(S.of(context).start, style: TextStyle(fontWeight: FontWeight.bold),),
                    if(revision.isChanged('start'))
                      Row(
                        children: [
                          SizedBox(width: 10,),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${S.of(context).incorrect}: '),
                              Text('${S.of(context).correct}: '),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${PunchDateUtils.getTimeString(revision.oldValue['start'])}'),
                              Text('${PunchDateUtils.getTimeString(revision.newValue['start'])}'),
                            ],
                          ),
                        ],
                      ),
                    if(!revision.isChanged('start'))
                      Text('${revision.oldValue['start']}'),
                  ],
                ),
              ],
            )
          ],
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
    String? errorMessage;
    if(revision.isChanged('start')){
      revision.correctStartTime = PunchDateUtils.toDateHourMinute(revision.newValue['start']);
    }
    if(revision.isChanged('end')){
      revision.correctEndTime = PunchDateUtils.toDateHourMinute(revision.newValue['end']);
    }
    showDialog(
        context: context,
        builder:(_)=> StatefulBuilder(
            builder: (BuildContext _context, StateSetter _setState){
              return AlertDialog(
                contentPadding: EdgeInsets.zero,
                insetPadding: EdgeInsets.zero,
                scrollable: true,
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
                            style: TextStyle(color: Colors.black87,fontWeight: FontWeight.bold,fontSize: 18),
                          )
                      ),
                      SizedBox(height: 8,),
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
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                      onPressed: (){
                        Navigator.of(_context).pop();
                      },
                      child: Text(S.of(context).close, style: TextStyle(color: Colors.red),)
                  ),
                  TextButton(
                      onPressed: (){
                        if(description.isNotEmpty){
                          Navigator.of(_context).pop();
                          _addDescription(revision, description);
                        }else{
                          _setState(() { errorMessage = S.of(context).youMustWriteDescription; });
                        }
                      },
                      child: Text(S.of(context).submit, style: TextStyle(color: Color(primaryColor)),)
                  ),
                ],
              );
            }
        )
    );
  }

  _addDescription(Revision revision, description)async{
    context.loaderOverlay.show();
    String? result = await revision.update(description);
    context.loaderOverlay.hide();
    if(result != null){
      Tools.showErrorMessage(context, result);
    }
    if(mounted) setState(() {
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
            child: Text(S.of(context).revisions, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.white),),
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