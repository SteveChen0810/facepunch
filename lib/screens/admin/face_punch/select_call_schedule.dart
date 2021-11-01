import 'package:facepunch/lang/l10n.dart';
import 'package:facepunch/models/app_const.dart';
import 'package:facepunch/models/user_model.dart';
import 'package:facepunch/models/work_model.dart';
import 'package:flutter/material.dart';

class SelectCallScheduleScreen extends StatefulWidget{

  final List<WorkSchedule> schedules;
  final List<EmployeeCall> calls;
  final User employee;
  final Punch punch;
  SelectCallScheduleScreen({this.schedules, this.employee, this.punch, this.calls});

  @override
  _SelectCallScheduleScreenState createState() => _SelectCallScheduleScreenState();
}

class _SelectCallScheduleScreenState extends State<SelectCallScheduleScreen> {

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isLoading = false;
  List<WorkSchedule> schedules;
  List<EmployeeCall> calls;
  User employee;
  Punch punch;
  WorkSchedule selectedSchedule;
  EmployeeCall selectedCall;

  @override
  void initState() {
    super.initState();
    schedules = widget.schedules;
    calls = widget.calls;
    employee = widget.employee;
    punch = widget.punch;
  }

  _showMessage(String message){
    _scaffoldKey.currentState.hideCurrentSnackBar();
    _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text(message),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.red,
          action: SnackBarAction(onPressed: (){},label: S.of(context).close,textColor: Colors.white,),
        )
    );
  }

  String _title(){
    if(schedules.isEmpty) return S.of(context).selectCall;
    if(calls.isEmpty) return S.of(context).selectSchedule;
    return S.of(context).selectCallSchedule;
  }

  String _description(){
    if(punch.isIn()){
      if(schedules.isEmpty) return 'Select a call and press the button to work on the call.';
      if(calls.isEmpty) return 'Select a schedule and press the button to work on the schedule.';
      return 'Select a call or schedule and press the button to work on the schedule.';
    }
    if(schedules.isEmpty) return 'Do you want to work on next call or end today?';
    if(calls.isEmpty) return 'Do you want to work on next schedule or end today?';
    return 'Do you want to work on next call or schedule?';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(_title()),
        elevation: 0,
        backgroundColor: Color(primaryColor),
        centerTitle: true,
        leading: IconButton(
          onPressed: (){
            if(!isLoading) Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
        ),
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(_description(), textAlign: TextAlign.center,),
              for(var call in calls)
                Container(
                  margin: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: selectedCall==call?Color(primaryColor):Colors.green,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.all(8),
                  child: InkWell(
                    onTap: (){
                      setState(() {
                        selectedSchedule = null;
                        selectedCall = call;
                      });
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text('${S.of(context).start} : '),
                                Text(call.startTime(), style: TextStyle(fontWeight: FontWeight.bold),),
                              ],
                            ),
                            Row(
                              children: [
                                Text('${S.of(context).end} : '),
                                Text(call.endTime(), style: TextStyle(fontWeight: FontWeight.bold),),
                              ],
                            ),
                            Row(
                              children: [
                                Text('${S.of(context).priority} : '),
                                Text('${call.priority}', style: TextStyle(fontWeight: FontWeight.bold),),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${S.of(context).project} : ', style: TextStyle(fontWeight: FontWeight.bold),),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    child: Text(call.projectName),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${S.of(context).task} : ', style: TextStyle(fontWeight: FontWeight.bold),),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    child: Text(call.taskName),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Text('${S.of(context).todo} : ', style: TextStyle(fontWeight: FontWeight.bold),),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: Text(call.todo),
                        ),
                        Text('${S.of(context).note} : ', style: TextStyle(fontWeight: FontWeight.bold),),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: Text(call.note),
                        ),
                      ],
                    ),
                  ),
                ),
              for(var schedule in schedules)
                Container(
                  margin: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: selectedSchedule==schedule ? Color(primaryColor) : Color(int.parse('0xFF${schedule.color}')),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.all(8),
                  child: InkWell(
                    onTap: ()=>setState(() {
                      selectedCall = null;
                      selectedSchedule = schedule;
                    }),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text('${S.of(context).start} : '),
                                Text(schedule.startTime(), style: TextStyle(fontWeight: FontWeight.bold),),
                              ],
                            ),
                            Row(
                              children: [
                                Text('${S.of(context).end} : '),
                                Text(schedule.endTime(), style: TextStyle(fontWeight: FontWeight.bold),),
                              ],
                            ),
                            Row(
                              children: [
                                Text('${S.of(context).shift} : '),
                                Text(schedule.shift.toUpperCase(), style: TextStyle(fontWeight: FontWeight.bold),),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${S.of(context).project} : ', style: TextStyle(fontWeight: FontWeight.bold),),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    child: Text(schedule.projectName),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${S.of(context).task} : ', style: TextStyle(fontWeight: FontWeight.bold),),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    child: Text(schedule.taskName),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: 45,
        margin: EdgeInsets.only(bottom: 20, left: 12, right: 12, top: 8),
        child: MaterialButton(
          onPressed: (selectedSchedule==null && selectedCall == null)?null:()async{
            if(!isLoading){
              setState(() { isLoading = true; });
              String message;
              if(selectedCall != null){
                message = await selectedCall.startCall(employee.token);
              }else{
                message = await selectedSchedule.startSchedule(employee.token);
              }
              setState(() { isLoading = false; });
              if(message != null){
                _showMessage(message);
              }else{
                Navigator.pop(context);
              }
            }
          },
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          color: Color(primaryColor),
          disabledColor: Colors.grey,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          child: isLoading?SizedBox(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(backgroundColor: Colors.white,strokeWidth: 2,)
          ):Text(S.of(context).start.toUpperCase(), style: TextStyle(color: Colors.white, fontSize: 16),),
        ),
      ),
    );
  }
}