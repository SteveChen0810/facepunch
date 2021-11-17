import 'package:facepunch/lang/l10n.dart';
import 'package:facepunch/models/app_const.dart';
import 'package:facepunch/models/revision_model.dart';
import 'package:facepunch/models/user_model.dart';
import 'package:facepunch/models/work_model.dart';
import 'package:facepunch/widgets/calendar_strip/date-utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class EmployeeSchedule extends StatefulWidget {

  @override
  _EmployeeScheduleState createState() => _EmployeeScheduleState();
}

class _EmployeeScheduleState extends State<EmployeeSchedule> {
  DateTime selectedDate = DateTime.now();
  List<WorkSchedule> schedules = [];
  List<EmployeeCall> calls = [];
  RefreshController _refreshController = RefreshController(initialRefresh: true);
  WorkSchedule _schedule;
  EmployeeCall _call;
  List<Project> projects = [];
  List<ScheduleTask> tasks = [];

  @override
  void initState() {
    super.initState();
  }

  _selectScheduleDate() async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        initialDatePickerMode: DatePickerMode.day,
        firstDate: DateTime(1970),
        lastDate: DateTime(2101));
    if (picked != null){
      setState(() {selectedDate = picked;});
      _refreshController.requestRefresh();
    }
  }

  _onRefresh()async{
    final user = context.read<UserModel>().user;
    String result = await user.getDailySchedule(selectedDate.toString());
    if(result==null){
      schedules = user.schedules;
      calls = user.calls;
    }else{
      _showMessage(result);
    }
    _refreshController.refreshCompleted();
    if(mounted)setState(() { _schedule = null; _call = null; });
  }

  Widget _scheduleItem(WorkSchedule s){
    try{
      if(s ==_schedule){
        return Container(
          height: 70,
          alignment: Alignment.center,
          color: Colors.red,
          child: CircularProgressIndicator(strokeWidth: 2,),
        );
      }
      return InkWell(
        onTap: (){
          if(_schedule!=null)return;
          _showScheduleRevisionDialog(s);
        },
        child: Container(
          decoration: BoxDecoration(
            color: Color(int.parse('0xFF${s.color}')),
          ),
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.all(4),
          child: Column(
            children: [
              Text(s.projectName??'',style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),textAlign: TextAlign.center,),
              Text(s.taskName??'',textAlign: TextAlign.center,),
              SizedBox(height: 12,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text( s.shift.toUpperCase(),),
                  Text("${PunchDateUtils.get12TimeString(s.start)} ~ ${PunchDateUtils.get12TimeString(s.end)}",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              )
            ],
          ),
        ),
      );
    }catch(e){
      return Container(
        color: Colors.red,
        height: 30,
        child: Text(e.toString()),
      );
    }
  }

  Widget _scheduleLine(){
    if(schedules.isEmpty) return SizedBox();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 4),
            child: Text(S.of(context).schedules,style: TextStyle(fontWeight: FontWeight.w500),),
          ),
          for(var s in schedules)
            _scheduleItem(s),
        ],
      ),
    );
  }


  Widget _callItem(EmployeeCall call){
    try{
      if(call == _call){
        return Container(
          height: 70,
          alignment: Alignment.center,
          color: Colors.red,
          child: CircularProgressIndicator(strokeWidth: 2,),
        );
      }
      return InkWell(
        onTap: (){
          if(_call != null)return;
          _showCallRevisionDialog(call);
        },
        child: Container(
          decoration: BoxDecoration(
            color: call.color(),
          ),
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.all(4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${call.priority}",
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  Text("${PunchDateUtils.get12TimeString(call.start)} ~ ${PunchDateUtils.get12TimeString(call.end)}",
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
              Center(
                child: Text(call.projectName??'',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
              Center(
                child: Text(call.taskName??'',
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
              Text(S.of(context).todo, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(call.todo??'', style: TextStyle(color: Colors.white),),
              ),
              Text(S.of(context).note, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(call.note??'', style: TextStyle(color: Colors.white),),
              )
            ],
          ),
        ),
      );
    }catch(e){
      return Container(
        color: Colors.red,
        height: 30,
        child: Text(e.toString()),
      );
    }
  }

  Widget _callLine(){
    if(calls.isEmpty) return SizedBox();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 4),
            child: Text(S.of(context).calls,style: TextStyle(fontWeight: FontWeight.w500),),
          ),
          for(var c in calls)
            _callItem(c),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  Future<DateTime> _selectTime(String createdAt)async{
    DateTime createdDate = DateTime.parse(createdAt);
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: createdDate.hour,minute: createdDate.minute),
    );
    if(picked!=null){
      return DateTime(createdDate.year,createdDate.month,createdDate.day,picked.hour,picked.minute,createdDate.second);
    }
    return null;
  }

  _showScheduleRevisionDialog(WorkSchedule s){
    final schedule = WorkSchedule.fromJson(s.toJson());
    String description = '';
    String errorMessage;

    showDialog(
        context: context,
        builder:(_)=> AlertDialog(
          contentPadding: EdgeInsets.zero,
          insetPadding: EdgeInsets.zero,
          scrollable: true,
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
                            "${S.of(context).scheduleRevision}",
                            style: TextStyle(color: Colors.black87,fontWeight: FontWeight.bold,fontSize: 18),
                          )
                      ),
                      if(schedule.noAvailable == null)
                        Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 8,),
                              Text(S.of(context).project,style: TextStyle(fontSize: 12,fontWeight: FontWeight.w500),),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black54),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 16.0,vertical: 4),
                                clipBehavior: Clip.hardEdge,
                                margin: EdgeInsets.only(top: 4),
                                child: DropdownButton<Project>(
                                  items: projects.map((Project value) {
                                    return DropdownMenuItem<Project>(
                                      value: value,
                                      child: Text(
                                        value.name,
                                        style: TextStyle(fontSize: 12),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  }).toList(),
                                  value: projects.firstWhere((p) => p.id==schedule.projectId,orElse: ()=>null),
                                  isExpanded: true,
                                  isDense: true,
                                  underline: SizedBox(),
                                  onChanged: (v) {
                                    _setState((){
                                      schedule.projectId = v.id;
                                      schedule.projectName = v.name;
                                    });
                                  },
                                ),
                              ),
                              SizedBox(height: 8,),
                              Text(S.of(context).task,style: TextStyle(fontSize: 12,fontWeight: FontWeight.w500),),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black54),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 16.0,vertical: 4),
                                clipBehavior: Clip.hardEdge,
                                margin: EdgeInsets.only(top: 4),
                                child: DropdownButton<ScheduleTask>(
                                  items:tasks.map((ScheduleTask value) {
                                    return DropdownMenuItem<ScheduleTask>(
                                      value: value,
                                      child: Text(
                                        value.name,
                                        style: TextStyle(fontSize: 12),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  }).toList(),
                                  value: tasks.firstWhere((t) => t.id==schedule.taskId,orElse: ()=>null),
                                  isExpanded: true,
                                  isDense: true,
                                  underline: SizedBox(),
                                  onChanged: (v) {
                                    _setState((){
                                      schedule.taskId = v.id;
                                      schedule.taskName = v.name;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      SizedBox(height: 8,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(S.of(context).startTime+' : ',style: TextStyle(fontSize: 12,fontWeight: FontWeight.w500),),
                          Text("${PunchDateUtils.get12TimeString(schedule.start)}"),
                          FlatButton(
                              onPressed: ()async{
                                DateTime pickedTime = await _selectTime(schedule.start);
                                if(pickedTime!=null){
                                  _setState(() { schedule.start = pickedTime.toString();});
                                }
                              },
                              shape: CircleBorder(),
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              padding: EdgeInsets.all(8),
                              minWidth: 0,
                              child: Icon(Icons.edit,color: Color(primaryColor))
                          ),
                        ],
                      ),
                      SizedBox(height: 8,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(S.of(context).endTime+' : ',style: TextStyle(fontSize: 12,fontWeight: FontWeight.w500),),
                          Text("${PunchDateUtils.get12TimeString(schedule.end)}"),
                          FlatButton(
                              onPressed: ()async{
                                DateTime pickedTime = await _selectTime(schedule.end);
                                if(pickedTime!=null){
                                  _setState(() { schedule.end = pickedTime.toString();});
                                }
                              },
                              shape: CircleBorder(),
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              padding: EdgeInsets.all(8),
                              minWidth: 0,
                              child: Icon(Icons.edit,color: Color(primaryColor))
                          ),
                        ],
                      ),
                      SizedBox(height: 8,),
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
                                if(schedule.projectId == null){
                                  _setState(() { errorMessage = S.of(context).selectProject;});
                                  return ;
                                }
                                if(schedule.taskId == null){
                                  _setState(() { errorMessage = S.of(context).selectTask;});
                                  return ;
                                }
                                if(description.isNotEmpty){
                                  Navigator.of(_context).pop();
                                  _sendScheduleRevision(schedule, s, description);
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

  _sendScheduleRevision(WorkSchedule newValue, WorkSchedule oldValue, String description)async{
    setState(() { _schedule = oldValue;});
    final result = await context.read<RevisionModel>().sendScheduleRevision(newSchedule: newValue, oldSchedule: oldValue, description: description);
    setState(() { _schedule = null;});
    if(result != null) _showMessage(result);
  }

  _showCallRevisionDialog(EmployeeCall c){
    final call = EmployeeCall.fromJson(c.toJson());
    String description = '';
    String errorMessage;

    showDialog(
        context: context,
        builder:(_)=> AlertDialog(
          contentPadding: EdgeInsets.zero,
          insetPadding: EdgeInsets.zero,
          scrollable: true,
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
                            "${S.of(context).callRevision}",
                            style: TextStyle(color: Colors.black87,fontWeight: FontWeight.bold,fontSize: 18),
                          )
                      ),
                      Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 8,),
                            Text(S.of(context).project,style: TextStyle(fontSize: 12,fontWeight: FontWeight.w500),),
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black54),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 16.0,vertical: 4),
                              clipBehavior: Clip.hardEdge,
                              margin: EdgeInsets.only(top: 4),
                              child: DropdownButton<Project>(
                                items: projects.map((Project value) {
                                  return DropdownMenuItem<Project>(
                                    value: value,
                                    child: Text(
                                      value.name,
                                      style: TextStyle(fontSize: 12),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                }).toList(),
                                value: projects.firstWhere((p) => p.id==call.projectId,orElse: ()=>null),
                                isExpanded: true,
                                isDense: true,
                                underline: SizedBox(),
                                onChanged: (v) {
                                  _setState((){
                                    call.projectId = v.id;
                                    call.projectName = v.name;
                                  });
                                },
                              ),
                            ),
                            SizedBox(height: 8,),
                            Text(S.of(context).task,style: TextStyle(fontSize: 12,fontWeight: FontWeight.w500),),
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black54),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 16.0,vertical: 4),
                              clipBehavior: Clip.hardEdge,
                              margin: EdgeInsets.only(top: 4),
                              child: DropdownButton<ScheduleTask>(
                                items:tasks.map((ScheduleTask value) {
                                  return DropdownMenuItem<ScheduleTask>(
                                    value: value,
                                    child: Text(
                                      value.name,
                                      style: TextStyle(fontSize: 12),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                }).toList(),
                                value: tasks.firstWhere((t) => t.id==call.taskId,orElse: ()=>null),
                                isExpanded: true,
                                isDense: true,
                                underline: SizedBox(),
                                onChanged: (v) {
                                  _setState((){
                                    call.taskId = v.id;
                                    call.taskName = v.name;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 8,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(S.of(context).startTime+' : ',style: TextStyle(fontSize: 12,fontWeight: FontWeight.w500),),
                          Text("${PunchDateUtils.get12TimeString(call.start)}"),
                          FlatButton(
                              onPressed: ()async{
                                DateTime pickedTime = await _selectTime(call.start);
                                if(pickedTime!=null){
                                  _setState(() { call.start = pickedTime.toString();});
                                }
                              },
                              shape: CircleBorder(),
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              padding: EdgeInsets.all(8),
                              minWidth: 0,
                              child: Icon(Icons.edit,color: Color(primaryColor))
                          ),
                        ],
                      ),
                      SizedBox(height: 8,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(S.of(context).endTime+' : ',style: TextStyle(fontSize: 12,fontWeight: FontWeight.w500),),
                          Text("${PunchDateUtils.get12TimeString(call.end)}"),
                          FlatButton(
                              onPressed: ()async{
                                DateTime pickedTime = await _selectTime(call.end);
                                if(pickedTime!=null){
                                  _setState(() { call.end = pickedTime.toString();});
                                }
                              },
                              shape: CircleBorder(),
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              padding: EdgeInsets.all(8),
                              minWidth: 0,
                              child: Icon(Icons.edit,color: Color(primaryColor))
                          ),
                        ],
                      ),
                      SizedBox(height: 8,),
                      Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(S.of(context).priority, style: TextStyle(fontSize: 12,fontWeight: FontWeight.w500),),
                            Row(
                              children: [
                                Radio(
                                  onChanged: (v){
                                    _setState((){
                                      call.priority = v;
                                    });
                                  },
                                  value: 1,
                                  groupValue: call.priority,
                                ),
                                Text("1  "),
                                Radio(
                                  onChanged: (v){
                                    _setState((){
                                      call.priority = v;
                                    });
                                  },
                                  value: 2,
                                  groupValue: call.priority,
                                ),
                                Text("2  "),
                                Radio(
                                  onChanged: (v){
                                    _setState((){
                                      call.priority = v;
                                    });
                                  },
                                  value: 3,
                                  groupValue: call.priority,
                                ),
                                Text("3"),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 8,),
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
                                if(call.projectId == null){
                                  _setState(() { errorMessage = S.of(context).selectProject;});
                                  return ;
                                }
                                if(call.taskId == null){
                                  _setState(() { errorMessage = S.of(context).selectTask;});
                                  return ;
                                }
                                if(call.priority == null){
                                  _setState(() { errorMessage = S.of(context).selectPriority;});
                                  return ;
                                }
                                if(description.isNotEmpty){
                                  Navigator.of(_context).pop();
                                  _sendCallRevision(call, c, description);
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

  _sendCallRevision(EmployeeCall newValue, EmployeeCall oldValue, String description)async{
    setState(() { _call = oldValue;});
    final result = await context.read<RevisionModel>().sendCallRevision(newSchedule: newValue, oldSchedule: oldValue, description: description);
    setState(() { _call = null;});
    if(result != null) _showMessage(result);
  }

  _showMessage(String message){
    Scaffold.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    projects = context.watch<WorkModel>().projects;
    tasks = context.watch<WorkModel>().tasks;
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
            child: Text(S.of(context).dailyTasks,style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.white),),
          ),
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FlatButton(
                  onPressed: (){
                    setState(() {
                      selectedDate = selectedDate.subtract(Duration(days: 1));
                    });
                    _refreshController.requestRefresh();
                  },
                  shape: CircleBorder(),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  child: Icon(Icons.arrow_back_ios_outlined,color: Colors.black,size: 30,),
                  padding: EdgeInsets.all(4),
                  minWidth: 0,
                ),
                SizedBox(width: 10,),
                MaterialButton(
                  onPressed: _selectScheduleDate,
                  padding: EdgeInsets.symmetric(vertical: 4,horizontal: 32),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0),side: BorderSide(color: Colors.black)),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  child: Text(selectedDate.toString().split(' ')[0],style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500),),
                ),
                SizedBox(width: 10,),
                FlatButton(
                  onPressed: (){
                    setState(() {
                      selectedDate = selectedDate.add(Duration(days: 1));
                    });
                    _refreshController.requestRefresh();
                  },
                  shape: CircleBorder(),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  child: Icon(Icons.arrow_forward_ios_outlined,color: Colors.black,size: 30,),
                  padding: EdgeInsets.all(4),
                  minWidth: 0,
                ),
              ],
            ),
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
                    _scheduleLine(),
                    _callLine(),
                    if(schedules.isEmpty && calls.isEmpty)
                      Container(
                          height: MediaQuery.of(context).size.height*0.5,
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