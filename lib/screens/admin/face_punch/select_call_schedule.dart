import 'package:flutter/material.dart';

import '/lang/l10n.dart';
import '/models/app_const.dart';
import '/models/user_model.dart';
import '/models/work_model.dart';
import '/widgets/utils.dart';

class SelectCallScheduleScreen extends StatefulWidget{

  final List<WorkSchedule> schedules;
  final List<EmployeeCall> calls;
  final User employee;
  final Punch punch;
  SelectCallScheduleScreen({required this.schedules, required this.employee, required this.punch, required this.calls});

  @override
  _SelectCallScheduleScreenState createState() => _SelectCallScheduleScreenState();
}

class _SelectCallScheduleScreenState extends State<SelectCallScheduleScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isLoading = false;
  late List<WorkSchedule> schedules;
  late List<EmployeeCall> calls;
  late User employee;
  late Punch punch;
  WorkSchedule? selectedSchedule;
  EmployeeCall? selectedCall;

  @override
  void initState() {
    super.initState();
    schedules = widget.schedules;
    calls = widget.calls;
    employee = widget.employee;
    punch = widget.punch;
  }

  String _title(){
    if(schedules.isEmpty) return S.of(context).selectCall;
    if(calls.isEmpty) return S.of(context).selectSchedule;
    return S.of(context).selectCallSchedule;
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${S.of(context).project} : ', style: TextStyle(fontWeight: FontWeight.bold),),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    child: Text('${call.projectName}'),
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
                                    child: Text('${call.taskName}'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Text('${S.of(context).todo} : ', style: TextStyle(fontWeight: FontWeight.bold),),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: Text('${call.todo}'),
                        ),
                        Text('${S.of(context).note} : ', style: TextStyle(fontWeight: FontWeight.bold),),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: Text('${call.note}'),
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
                                Text('${schedule.shift?.toUpperCase()}', style: TextStyle(fontWeight: FontWeight.bold),),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${S.of(context).project} : ', style: TextStyle(fontWeight: FontWeight.bold),),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    child: Text('${schedule.projectName}'),
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
                                    child: Text('${schedule.taskName}'),
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
        margin: EdgeInsets.only(bottom: 20, left: 12, right: 12, top: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MaterialButton(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              color: Color(primaryColor),
              disabledColor: Colors.grey,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              minWidth: MediaQuery.of(context).size.width-40,
              height: 40,
              onPressed: (selectedSchedule==null && selectedCall == null)?null:()async{
                if(!isLoading){
                  setState(() { isLoading = true; });
                  String? message;
                  if(selectedCall != null){
                    message = await selectedCall!.startCall(employee.token);
                  }else{
                    message = await selectedSchedule!.startSchedule(employee.token);
                  }
                  setState(() { isLoading = false; });
                  if(message != null){
                    Tools.showErrorMessage(context, message);
                  }else{
                    Navigator.pop(context);
                  }
                }
              },
              child: isLoading?SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(backgroundColor: Colors.white,strokeWidth: 2,)
              ):Text(S.of(context).start.toUpperCase(), style: TextStyle(color: Colors.white, fontSize: 16),),
            ),
            SizedBox(height: 8,),
            if(punch.isOut())
              MaterialButton(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                color: Colors.red,
                disabledColor: Colors.grey,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                minWidth: MediaQuery.of(context).size.width-40,
                height: 40,
                onPressed: isLoading ? null : ()async{
                  Navigator.pop(context);
                },
                child: Text(S.of(context).punchOut.toUpperCase(), style: TextStyle(color: Colors.white, fontSize: 16),),
              ),
          ],
        ),
      ),
    );
  }
}