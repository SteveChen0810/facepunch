import 'package:facepunch/widgets/TimeEditor.dart';
import 'package:facepunch/widgets/project_picker.dart';
import 'package:facepunch/widgets/task_picker.dart';
import 'package:facepunch/widgets/utils.dart';

import '/lang/l10n.dart';
import '/models/app_const.dart';
import '/models/revision_model.dart';
import '/models/user_model.dart';
import '/models/work_model.dart';
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
  WorkSchedule? _schedule;
  EmployeeCall? _call;
  List<Project> projects = [];
  List<ScheduleTask> tasks = [];
  User? user;

  @override
  void initState() {
    super.initState();
  }

  _selectScheduleDate() async {
    final DateTime? picked = await showDatePicker(
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
    String? result = await user!.getDailySchedule(selectedDate.toString());
    if(result == null){
      schedules = user.schedules;
      calls = user.calls;
    }else{
      Tools.showErrorMessage(context, result);
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
              Text(s.projectTitle(), style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),textAlign: TextAlign.center,),
              Text(s.taskTitle(), textAlign: TextAlign.center,),
              SizedBox(height: 12,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${s.shift?.toUpperCase()}',),
                  Text("${s.startTime()} ~ ${s.endTime()}",
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
    if(schedules.isEmpty || user == null || !user!.hasSchedule()) return SizedBox();
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
                  Text("${call.startTime()} ~ ${call.endTime()}",
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
              Center(
                child: Text(call.projectTitle(),
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
              Center(
                child: Text(call.taskTitle(),
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
    if(calls.isEmpty || user == null || !user!.hasCall()) return SizedBox();
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

  _showScheduleRevisionDialog(WorkSchedule s){
    final schedule = WorkSchedule.fromJson(s.toJson());
    String description = '';
    String? errorMessage;

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
                              ProjectPicker(
                                projects: projects,
                                projectId: schedule.projectId,
                                onSelected: (v) {
                                  _setState((){
                                    schedule.projectId = v?.id;
                                    schedule.projectName = v?.name;
                                  });
                                },
                              ),
                              SizedBox(height: 8,),
                              Text(S.of(context).task,style: TextStyle(fontSize: 12,fontWeight: FontWeight.w500),),
                              TaskPicker(
                                tasks: tasks,
                                taskId: schedule.taskId,
                                onSelected: (v) {
                                  _setState((){
                                    schedule.taskId = v?.id;
                                    schedule.taskName = v?.name;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      SizedBox(height: 16,),
                      TimeEditor(
                        label: S.of(context).startTime,
                        initTime: s.start,
                        onChanged: (v){
                          _setState(() { schedule.start = v; });
                        },
                      ),
                      SizedBox(height: 16,),
                      TimeEditor(
                        label: S.of(context).endTime,
                        initTime: s.end,
                        onChanged: (v){
                          _setState(() { schedule.end = v; });
                        },
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
                        if(schedule.start == null || schedule.end == null) return ;
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
              );
            }
        )
    );
  }

  _sendScheduleRevision(WorkSchedule newValue, WorkSchedule oldValue, String description)async{
    setState(() { _schedule = oldValue;});
    final result = await context.read<RevisionModel>().sendScheduleRevision(newSchedule: newValue, oldSchedule: oldValue, description: description);
    setState(() { _schedule = null;});
    if(result != null){
      Tools.showErrorMessage(context, result);
    }else{
      Tools.showSuccessMessage(context, S.of(context).revisionHasBeenSent);
    }
  }

  _showCallRevisionDialog(EmployeeCall c){
    final call = EmployeeCall.fromJson(c.toJson());
    String description = '';
    String? errorMessage;

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
                            ProjectPicker(
                              projects: projects,
                              projectId: call.projectId,
                              onSelected: (v) {
                                _setState((){
                                  call.projectId = v?.id;
                                  call.projectName = v?.name;
                                });
                              },
                            ),
                            SizedBox(height: 8,),
                            Text(S.of(context).task,style: TextStyle(fontSize: 12,fontWeight: FontWeight.w500),),
                            TaskPicker(
                              tasks: tasks,
                              taskId: call.taskId,
                              onSelected: (v) {
                                _setState((){
                                  call.taskId = v?.id;
                                  call.taskName = v?.name;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16,),
                      TimeEditor(
                        label: S.of(context).startTime,
                        initTime: c.start,
                        onChanged: (v){
                          _setState(() { call.start = v; });
                        },
                      ),
                      SizedBox(height: 16,),
                      TimeEditor(
                        label: S.of(context).endTime,
                        initTime: c.end,
                        onChanged: (v){
                          _setState(() { call.end = v; });
                        },
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
                                      call.priority = v as int?;
                                    });
                                  },
                                  value: 1,
                                  groupValue: call.priority,
                                ),
                                Text("1  "),
                                Radio(
                                  onChanged: (v){
                                    _setState((){
                                      call.priority = v as int?;
                                    });
                                  },
                                  value: 2,
                                  groupValue: call.priority,
                                ),
                                Text("2  "),
                                Radio(
                                  onChanged: (v){
                                    _setState((){
                                      call.priority = v as int?;
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
                      )
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                      onPressed: ()=>Navigator.of(_context).pop(),
                      child: Text(S.of(context).close, style: TextStyle(color: Colors.red),)
                  ),
                  TextButton(
                      onPressed: (){
                        if(call.start == null || call.end == null) return;
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
              );
            }
        )
    );
  }

  _sendCallRevision(EmployeeCall newValue, EmployeeCall oldValue, String description)async{
    setState(() { _call = oldValue;});
    final result = await context.read<RevisionModel>().sendCallRevision(newSchedule: newValue, oldSchedule: oldValue, description: description);
    setState(() { _call = null;});
    if(result != null){
      Tools.showErrorMessage(context, result);
    }else{
      Tools.showSuccessMessage(context, S.of(context).revisionHasBeenSent);
    }
  }

  @override
  Widget build(BuildContext context) {
    projects = context.watch<WorkModel>().projects;
    tasks = context.watch<WorkModel>().tasks;
    user = context.watch<UserModel>().user;
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
                TextButton(
                  onPressed: (){
                    setState(() {
                      selectedDate = selectedDate.subtract(Duration(days: 1));
                    });
                    _refreshController.requestRefresh();
                  },
                  child: Icon(Icons.arrow_back_ios_outlined,color: Colors.black,size: 30,),
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
                TextButton(
                  onPressed: (){
                    setState(() {
                      selectedDate = selectedDate.add(Duration(days: 1));
                    });
                    _refreshController.requestRefresh();
                  },
                  child: Icon(Icons.arrow_forward_ios_outlined,color: Colors.black,size: 30,),
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