import 'package:facepunch/lang/l10n.dart';
import 'package:facepunch/models/app_const.dart';
import 'package:facepunch/models/user_model.dart';
import 'package:facepunch/models/work_model.dart';
import 'package:flutter/material.dart';

class SelectScheduleScreen extends StatefulWidget{

  final List<WorkSchedule> schedules;
  final User employee;
  final Punch punch;
  SelectScheduleScreen({this.schedules, this.employee, this.punch});

  @override
  _SelectScheduleScreenState createState() => _SelectScheduleScreenState();
}

class _SelectScheduleScreenState extends State<SelectScheduleScreen> {

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isLoading = false;
  List<WorkSchedule> schedules;
  User employee;
  Punch punch;
  WorkSchedule selectedSchedule;
  TextEditingController _description = TextEditingController();

  @override
  void initState() {
    super.initState();
    schedules = widget.schedules;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(S.of(context).selectSchedule),
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
              if(punch.isOut())
                Text('Do you want to work on next schedule or end today?'),
              if(punch.isIn())
                Text('Select a schedule and Press the button to work on a schedule.'),
              for(var schedule in schedules)
                Container(
                  margin: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: selectedSchedule==schedule?Color(primaryColor):Color(int.parse('0xFF${schedule.color}')),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.all(8),
                  child: InkWell(
                    onTap: ()=>setState(() { selectedSchedule = schedule; }),
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
        height: 40,
        margin: EdgeInsets.only(bottom: 20, left: 12, right: 12, top: 8),
        child: MaterialButton(
          onPressed: selectedSchedule==null?null:()async{
            if(!isLoading){
              setState(() { isLoading = true; });
              String message = await selectedSchedule.startSchedule(employee.token);
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
          ):Text(S.of(context).startSchedule, style: TextStyle(color: Colors.white, fontSize: 16),),
        ),
      ),
    );
  }
}