import 'package:facepunch/lang/l10n.dart';
import 'package:facepunch/models/app_const.dart';
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
  RefreshController _refreshController = RefreshController(initialRefresh: true);
  WorkSchedule _schedule;
  List<Project> projects = [];
  List<ScheduleTask> tasks = [];

  List<Color> colors = [
    Colors.blue,
    Colors.green,
    Colors.teal,
    Colors.amber,
    Colors.brown,
    Colors.cyan,
    Colors.indigo,
    Colors.orange,
    Colors.pink,
    Colors.purple,
    Colors.teal,
  ];


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
    schedules = await user.getDailySchedule(selectedDate.toString());
    _refreshController.refreshCompleted();
    if(mounted)setState(() {
      _schedule = null;
    });
  }

  Widget _scheduleItem(WorkSchedule s){
    try{
      if(s==_schedule){
        return Container(
          height: 70,
          alignment: Alignment.center,
          color: Colors.red,
          child: CircularProgressIndicator(),
        );
      }
      if(s.type=='call'){
        return InkWell(
          onTap: ()async{
            if(_schedule!=null)return;
            _showRevisionDialog(s);
          },
          child: Container(
            decoration: BoxDecoration(
                color: colors[s.id%11],
                border: Border.all(color: Colors.red, width: 2,style: s.isStarted()?BorderStyle.solid:BorderStyle.none)
            ),
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.all(4),
            child: Column(
              children: [
                Text(s.projectName??'',style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16), textAlign: TextAlign.center,),
                Text(s.taskName??'', textAlign: TextAlign.center,),
                SizedBox(height: 12,),
                Row(
                  children: [
                    Expanded(
                        child: Text(
                          s.isEnded()
                              ?S.of(context).pressToAskRevision
                              :s.isStarted()
                                ?S.of(context).pressToEnd
                                :S.of(context).pressToStart,
                          style: TextStyle(color: Colors.white),
                        )
                    ),
                    Text("${S.of(context).start}:".toUpperCase(),style: TextStyle(fontWeight: FontWeight.w500),),
                    Text(PunchDateUtils.get12TimeString(s.start)),
                    SizedBox(width: 8,),
                    Text("${S.of(context).end}:".toUpperCase(),style: TextStyle(fontWeight: FontWeight.w500),),
                    Text(PunchDateUtils.get12TimeString(s.end)),
                  ],
                )
              ],
            ),
          ),
        );
      }
      return InkWell(
        onTap: (){
          if(_schedule!=null)return;
          _showRevisionDialog(s);
        },
        child: Container(
          decoration: BoxDecoration(
            color: colors[s.id%11],
          ),
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.all(4),
          child: Column(
            children: [
              Text(s.projectName??'',style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),textAlign: TextAlign.center,),
              Text(s.taskName??'',textAlign: TextAlign.center,),
              SizedBox(height: 12,),
              Row(
                children: [
                  Expanded(
                      child: Text(
                        S.of(context).pressToAskRevision,
                        style: TextStyle(color: Colors.white),
                      )
                  ),
                  Text(PunchDateUtils.get12TimeString(s.start),style: TextStyle(fontWeight: FontWeight.bold),),
                  Text(' ~ '),
                  Text(PunchDateUtils.get12TimeString(s.end),style: TextStyle(fontWeight: FontWeight.bold),),
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
    if(schedules.isEmpty){
      return Container(
        height: MediaQuery.of(context).size.height*0.5,
        alignment: Alignment.center,
        child: Text(S.of(context).empty, style: TextStyle(fontSize: 20),)
      );
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          for(var s in schedules)
            _scheduleItem(s),
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

  _showRevisionDialog(WorkSchedule s){
    final schedule = WorkSchedule.fromJson(s.toJson());
    showDialog(
        context: context,
        builder:(_)=> AlertDialog(
          contentPadding: EdgeInsets.zero,
          insetPadding: EdgeInsets.zero,
          content: StatefulBuilder(
              builder: (BuildContext _context, StateSetter _setState){
                return Container(
                  width: MediaQuery.of(context).size.width-50,
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                          child: Text(
                            "${schedule.type=='call'?S.of(context).call:S.of(context).shop} ${S.of(context).schedule}",
                            style: TextStyle(color: Colors.black87,fontWeight: FontWeight.bold,fontSize: 18),
                          )
                      ),
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
                            _setState((){ schedule.projectId = v.id; schedule.projectName = v.name; });
                          },
                        ),
                      ),
                      SizedBox(height: 8,),
                      Text(S.of(context).activity,style: TextStyle(fontSize: 12,fontWeight: FontWeight.w500),),
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
                            _setState((){schedule.taskId = v.id; schedule.taskName = v.name;});
                          },
                        ),
                      ),
                      if(schedule.type=='call')
                        Text(S.of(context).priority,style: TextStyle(fontSize: 12,fontWeight: FontWeight.w500),),
                      if(schedule.type=='call')
                        Row(
                          children: [
                            Radio(
                                value: 1,
                                groupValue: schedule.priority,
                                onChanged: (v){
                                  _setState((){schedule.priority = v;});
                                }
                            ),
                            Text('1'),
                            SizedBox(width: 12,),
                            Radio(
                                value: 2,
                                groupValue: schedule.priority,
                                onChanged: (v){
                                  _setState((){schedule.priority = v;});
                                }
                            ),
                            Text('2'),
                            SizedBox(width: 12,),
                            Radio(
                                value: 3,
                                groupValue: schedule.priority,
                                onChanged: (v){
                                  _setState((){schedule.priority = v;});
                                }
                            ),
                            Text('3'),
                          ],
                        ),
                      if(schedule.start!=null && schedule.start.isNotEmpty)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(S.of(context).startTime+' : ',style: TextStyle(fontSize: 12,fontWeight: FontWeight.w500),),
                            Text("${PunchDateUtils.get12TimeString(schedule.start)}"),
                            FlatButton(
                                onPressed: ()async{
                                  DateTime pickedTime = await _selectTime(schedule.getStartTime().toString());
                                  if(pickedTime!=null){
                                    _setState(() { schedule.start = pickedTime.toString().substring(11, 19);});
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
                      if(schedule.end!=null && schedule.end.isNotEmpty)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(S.of(context).endTime+' : ',style: TextStyle(fontSize: 12,fontWeight: FontWeight.w500),),
                            Text("${PunchDateUtils.get12TimeString(schedule.end)}"),
                            FlatButton(
                                onPressed: ()async{
                                  DateTime pickedTime = await _selectTime(schedule.getEndTime().toString());
                                  if(pickedTime!=null){
                                    _setState(() { schedule.end = pickedTime.toString().substring(11, 19);});
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
                      Text(S.of(context).todo,style: TextStyle(fontSize: 12,fontWeight: FontWeight.w500),),
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(schedule.todo??'',style: TextStyle(fontSize: 12,),),
                      ),
                      Text(S.of(context).notes,style: TextStyle(fontSize: 12,fontWeight: FontWeight.w500),),
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(schedule.note??'',style: TextStyle(fontSize: 12,),),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                              onPressed: (){
                                Navigator.of(_context).pop();
                              },
                              child: Text(S.of(context).close, style: TextStyle(color: Colors.red),)
                          ),
                          if(s.type=='call' && !s.isStarted() && !s.isEnded())
                            TextButton(
                                onPressed: ()async{
                                  Navigator.of(_context).pop();
                                  setState(() {_schedule = s;});
                                  await s.startSchedule();
                                  _refreshController.requestRefresh();
                                },
                                child: Text(S.of(context).start, style: TextStyle(color: Colors.blue),)
                            ),
                          if(s.type=='call' && s.isStarted() && !s.isEnded())
                            TextButton(
                                onPressed: ()async{
                                  Navigator.of(_context).pop();
                                  setState(() {_schedule = s;});
                                  await s.endSchedule();
                                  _refreshController.requestRefresh();
                                },
                                child: Text(S.of(context).end, style: TextStyle(color: Colors.blue),)
                            ),
                          TextButton(
                              onPressed: (){
                                Navigator.of(_context).pop();
                                _sendRevision(schedule,s);
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

  _sendRevision(WorkSchedule newValue, WorkSchedule oldValue)async{
    try{
      setState(() { _schedule = oldValue;});
      await context.read<WorkModel>().submitRevision(newSchedule: newValue,oldSchedule: oldValue);
      setState(() { _schedule = null;});
    }catch(e){
      print('[_sendRevision]$e');
    }
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
            child: Text(S.of(context).dailySchedule,style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),),
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
                child: _scheduleLine(),
              ),
            ),
          )
        ],
      ),
    );
  }
}