import 'package:flutter/material.dart';
import '/lang/l10n.dart';
import '/models/app_const.dart';
import '/models/user_model.dart';
import '/models/work_model.dart';
import '/widgets/utils.dart';
import '/widgets/project_picker.dart';
import '/widgets/task_picker.dart';
import 'package:loader_overlay/loader_overlay.dart';

class SelectTaskScreen extends StatefulWidget{

  final FacePunchData facePunchData;
  SelectTaskScreen(this.facePunchData);

  @override
  _SelectTaskScreenState createState() => _SelectTaskScreenState();
}

class _SelectTaskScreenState extends State<SelectTaskScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<WorkSchedule> schedules = [];
  List<EmployeeCall> calls = [];
  List<Project> projects = [];
  List<ScheduleTask> tasks = [];
  late User employee;
  late Punch punch;
  WorkSchedule? selectedSchedule;
  EmployeeCall? selectedCall;
  Project? selectedProject;
  ScheduleTask? selectedTask;

  @override
  void initState() {
    super.initState();
    schedules = widget.facePunchData.schedules;
    calls = widget.facePunchData.calls;
    projects = widget.facePunchData.projects;
    tasks = widget.facePunchData.tasks;
    employee = widget.facePunchData.employee;
    punch = widget.facePunchData.punch;
  }

  bool canStartWork(){
    return selectedSchedule != null || selectedCall != null || (selectedTask != null && selectedProject != null);
  }

  String startButtonTitle(){
    if(selectedSchedule != null && selectedSchedule!.status == "pending"){
      return S.of(context).resume.toUpperCase();
    }
    return S.of(context).start.toUpperCase();
  }

  Future<void> startWork()async{
    try{
      context.loaderOverlay.show();
      String? message;
      if(selectedCall != null){
        message = await selectedCall!.startCall(employee.token);
      }else if(selectedSchedule != null){
        message = await selectedSchedule!.startSchedule(employee.token);
      }else if(selectedProject != null && selectedTask != null){
        message = await employee.startShopTracking(selectedProject!.id, selectedTask!.id);
      }
      context.loaderOverlay.hide();
      if(message != null){
        Tools.showErrorMessage(context, message);
      }else{
        Navigator.pop(context);
      }
    }catch(e){
      context.loaderOverlay.hide();
      Tools.consoleLog('[SelectTaskScreen.startWork]$e');
      Tools.showErrorMessage(context, S.of(context).somethingWentWrong);
    }
  }

  Future<void> startManualBreak()async{
    try{
      context.loaderOverlay.show();
      String? message = await employee.startManualBreak();
      context.loaderOverlay.hide();
      if(message != null){
        Tools.showErrorMessage(context, message);
      }else{
        Navigator.pop(context);
      }
    }catch(e){
      context.loaderOverlay.hide();
      Tools.consoleLog('[SelectTaskScreen.startManualBreak]$e');
      Tools.showErrorMessage(context, S.of(context).somethingWentWrong);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(S.of(context).selectTask),
        elevation: 0,
        backgroundColor: Color(primaryColor),
        centerTitle: true,
        automaticallyImplyLeading: !employee.checkType('call_shop_tracking'),
      ),
      body: WillPopScope(
        onWillPop: ()async{
          return !employee.checkType('call_shop_tracking');
        },
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
                        selectedProject = null;
                        selectedTask = null;
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
                                    child: Text(call.projectTitle()),
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
                                    child: Text(call.taskTitle()),
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
                                    child: Text(schedule.projectTitle()),
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
                                    child: Text(schedule.taskTitle()),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              if(employee.hasTracking())
                Container(
                  margin: EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(S.of(context).project),
                      ProjectPicker(
                        projects: projects,
                        projectId: selectedProject?.id,
                        onSelected: (v){
                          setState(() {
                            selectedCall = null;
                            selectedProject = v;
                          });
                        },
                      ),
                      SizedBox(height: 20,),
                      Text(S.of(context).task),
                      TaskPicker(
                        tasks: tasks,
                        taskId: selectedTask?.id,
                        onSelected: (v){
                          setState(() {
                            selectedCall = null;
                            selectedTask = v;
                          });
                        },
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        margin: EdgeInsets.only(bottom: 20, left: 12, right: 12, top: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if(punch.isOut() && employee.isManualBreak())
              MaterialButton(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                color: Colors.orange,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                minWidth: MediaQuery.of(context).size.width-40,
                height: 40,
                onPressed: startManualBreak,
                child: Text(S.of(context).manualBreak.toUpperCase(), style: TextStyle(color: Colors.white, fontSize: 16),),
              ),
            SizedBox(height: 8,),
            MaterialButton(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              color: Color(primaryColor),
              disabledColor: Colors.grey,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              minWidth: MediaQuery.of(context).size.width-40,
              height: 40,
              onPressed: canStartWork()?startWork:null,
              child: Text(startButtonTitle(), style: TextStyle(color: Colors.white, fontSize: 16),),
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
                onPressed: (){
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