import '/widgets/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/models/app_const.dart';
import '/models/user_model.dart';
import '/models/work_model.dart';
import '/lang/l10n.dart';

class SelectProjectTask extends StatefulWidget {

  final User employee;
  final List<Project> projects;
  final List<ScheduleTask> tasks;
  final Punch punch;
  SelectProjectTask({required this.employee, required this.projects, required this.tasks, required this.punch});

  @override
  _SelectProjectTaskState createState() => _SelectProjectTaskState();
}

class _SelectProjectTaskState extends State<SelectProjectTask> {
  bool isLoading = false;
  late List<Project> projects;
  late List<ScheduleTask> tasks;
  late User employee;
  late Punch punch;
  Project? selectedProject;
  ScheduleTask? selectedTask;

  @override
  void initState() {
    super.initState();
    employee = widget.employee;
    projects = widget.projects;
    tasks = widget.tasks;
    punch = widget.punch;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  borderRadius: BorderRadius.circular(5),
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
                          Text('${value.name}', maxLines: 1, overflow: TextOverflow.ellipsis,),
                          if(value.code != null && value.code!.isNotEmpty)
                            Text('${value.code}', style: TextStyle(fontSize: 10),),
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
                  borderRadius: BorderRadius.circular(5),
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
                          Text('${value.name}', maxLines: 1, overflow: TextOverflow.ellipsis,),
                          if(value.code != null && value.code!.isNotEmpty)
                            Text('${value.code}', style: TextStyle(fontSize: 10),),
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
        margin: EdgeInsets.only(bottom: 20, top: 8),
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
              onPressed: (selectedTask==null && selectedProject==null)?null:()async{
                if(!isLoading){
                  setState(() {isLoading = true;});
                  String? message = await context.read<WorkModel>().startShopTracking(employee.token, selectedProject!.id, selectedTask!.id);
                  setState(() {isLoading = false;});
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
              ):Text(S.of(context).startWorking, style: TextStyle(color: Colors.white, fontSize: 16),),
            ),
            SizedBox(height: 10,),
            if(punch.isOut())
              MaterialButton(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                color: Colors.red,
                disabledColor: Colors.grey,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                minWidth: MediaQuery.of(context).size.width-40,
                height: 40,
                onPressed: isLoading ? null : ()=>Navigator.pop(context),
                child: Text(S.of(context).punchOut.toUpperCase(), style: TextStyle(color: Colors.white, fontSize: 16),),
              ),
          ],
        ),
      ),
    );
  }
}