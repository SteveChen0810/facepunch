import 'package:flutter/material.dart';
import 'package:facepunch/models/app_const.dart';
import 'package:facepunch/models/user_model.dart';
import 'package:facepunch/models/work_model.dart';
import 'package:facepunch/lang/l10n.dart';
import 'package:provider/provider.dart';

class SelectProjectTask extends StatefulWidget {

  final User employee;
  final List<Project> projects;
  final List<ScheduleTask> tasks;
  final Punch punch;
  SelectProjectTask({this.employee, this.projects, this.tasks, this.punch});

  @override
  _SelectProjectTaskState createState() => _SelectProjectTaskState();
}

class _SelectProjectTaskState extends State<SelectProjectTask> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isLoading = false;
  List<Project> projects;
  List<ScheduleTask> tasks;
  User employee;
  Punch punch;
  Project selectedProject;
  ScheduleTask selectedTask;

  @override
  void initState() {
    super.initState();
    employee = widget.employee;
    projects = widget.projects;
    tasks = widget.tasks;
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
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(S.of(context).project),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black54),
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
                margin: EdgeInsets.symmetric(vertical: 8),
                clipBehavior: Clip.antiAlias,
                child: DropdownButton<Project>(
                  items: projects.map((Project value) {
                    return DropdownMenuItem<Project>(
                      value: value,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(value.name, maxLines: 1, overflow: TextOverflow.ellipsis,),
                          if(value.code != null && value.code.isNotEmpty)
                            Text(value.code, style: TextStyle(fontSize: 10),),
                        ],
                      ),
                    );
                  }).toList(),
                  value: selectedProject,
                  isExpanded: true,
                  isDense: false,
                  underline: SizedBox(),
                  hint: Text(S.of(context).selectProject),
                  onChanged: (v) {
                    setState(() {
                      selectedProject = v;
                    });
                  },
                ),
              ),
              Text(S.of(context).task),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black54),
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
                margin: EdgeInsets.symmetric(vertical: 8),
                clipBehavior: Clip.antiAlias,
                child: DropdownButton<ScheduleTask>(
                  items: tasks.map((ScheduleTask value) {
                    return DropdownMenuItem<ScheduleTask>(
                      value: value,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(value.name, maxLines: 1, overflow: TextOverflow.ellipsis,),
                          if(value.code != null && value.code.isNotEmpty)
                            Text(value.code, style: TextStyle(fontSize: 10),),
                        ],
                      ),
                    );
                  }).toList(),
                  value: selectedTask,
                  isExpanded: true,
                  isDense: false,
                  underline: SizedBox(),
                  hint: Text(S.of(context).selectTask),
                  onChanged: (v) {
                    setState(() {
                      selectedTask = v;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: 40,
        margin: EdgeInsets.only(bottom: 20, left: 12, right: 12, top: 8),
        child: MaterialButton(
          onPressed: (selectedTask==null && selectedProject==null)?null:()async{
            if(!isLoading){
              setState(() {isLoading = true;});
              String message = await context.read<WorkModel>().startShopTracking(
                token: employee.token,
                projectId: selectedProject.id,
                taskId: selectedTask.id
              );
              setState(() {isLoading = false;});
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
          ):Text(S.of(context).startWorking, style: TextStyle(color: Colors.white, fontSize: 16),),
        ),
      ),
    );
  }
}