import 'package:facepunch/lang/l10n.dart';
import 'package:facepunch/models/app_const.dart';
import 'package:facepunch/models/user_model.dart';
import 'package:facepunch/models/work_model.dart';
import 'package:facepunch/widgets/calendar_strip/date-utils.dart';
import 'package:flutter/material.dart';

class WorkResume extends StatefulWidget{

  final Punch punch;
  final Project project;
  final User employee;
  final ScheduleTask task;

  WorkResume({this.employee,this.punch,this.project,this.task});

  @override
  _WorkResumeState createState() => _WorkResumeState();
}

class _WorkResumeState extends State<WorkResume> {


  @override
  void initState() {
    Future.delayed(Duration(seconds: 5)).whenComplete((){
      if(mounted)Navigator.pop(context);
    });
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(S.of(context).youAreNowWorkingOn.toUpperCase(),
              style: TextStyle(color: Colors.white,fontSize: 30, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            Column(
              children: [
                Text('${widget.project.companyName}',
                  style: TextStyle(color: Colors.white,fontSize: 25),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10,),
                Text('${S.of(context).project}: ${widget.project.name}',
                  style: TextStyle(color: Colors.white,fontSize: 25),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10,),
                Text('${S.of(context).activity}: ${widget.task.name}',
                  style: TextStyle(color: Colors.white,fontSize: 25),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            Column(
              children: [
                Text('${S.of(context).startTime.toUpperCase()}',
                  style: TextStyle(color: Colors.white,fontSize: 25,fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                Text('${PunchDateUtils.getTimeString(DateTime.now())}',
                  style: TextStyle(color: Colors.white,fontSize: 50,fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ],
        ),
      ),
      backgroundColor: Color(primaryColor),
    );
  }
}