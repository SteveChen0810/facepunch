import 'package:facepunch/lang/l10n.dart';
import 'package:facepunch/models/app_const.dart';
import 'package:facepunch/models/user_model.dart';
import 'package:facepunch/models/work_model.dart';
import 'package:facepunch/screens/admin/face_punch/work_resume.dart';
import 'package:facepunch/widgets/dialogs.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SelectTask extends StatefulWidget{

  final Punch punch;
  final Project project;
  final List<ScheduleTask> tasks;
  final User employee;
  final double longitude;
  final double latitude;

  SelectTask({this.employee, this.punch, this.project, this.tasks, this.longitude, this.latitude});

  @override
  _SelectTaskState createState() => _SelectTaskState();
}

class _SelectTaskState extends State<SelectTask> {

  ScheduleTask selectedTask ;
  bool isLoading = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  showMessage(String message){
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
        title: Text(S.of(context).selectTask),
        elevation: 0,
        backgroundColor: Color(primaryColor),
        centerTitle: true,
        leading: IconButton(
          onPressed: (){
            if(selectedTask==null && !isLoading){
              Navigator.pop(context);
            }
          },
          icon: Icon(Icons.arrow_back),
        ),
      ),
      body: WillPopScope(
        onWillPop: ()async{
          return selectedTask==null && !isLoading;
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            color: Colors.white,
          ),
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Wrap(
                    children: [
                      for(var task in widget.tasks)
                        selectedTask==task
                            ?Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(),
                            )
                            :Container(
                                decoration: BoxDecoration(
                                    color: Color(primaryColor)
                                ),
                                margin: EdgeInsets.all(8),
                                child: InkWell(
                                    onTap: ()async{
                                      if(selectedTask==null){
                                        try{
                                          setState(() {selectedTask = task;});
                                          final result = await context.read<UserModel>().startWork(
                                              employee: widget.employee,
                                              taskId: task.id,
                                            projectId: widget.project.id
                                          );
                                          if(result==null){
                                            Navigator.pushReplacement(context,
                                                MaterialPageRoute(
                                                    builder: (context)=>WorkResume(
                                                      project: widget.project,
                                                      employee: widget.employee,
                                                      punch: widget.punch,
                                                      task: task,
                                                    )
                                                )
                                            );
                                          }else{
                                            throw(result);
                                          }
                                        }catch(e){
                                          showMessage(e.toString());
                                          setState(() {selectedTask = null;});
                                        }
                                      }
                                    },
                                    child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 8,horizontal: 16),
                                        child: Text(task.name,style: TextStyle(fontSize: 16,),),
                                    )
                                )
                            )
                    ],
                  ),
                ),
              ),
              MaterialButton(
                onPressed: widget.punch==null?()async{
                  try{
                    setState(() {isLoading = true;});
                    final punch = await context.read<UserModel>().punchOut(
                        employee: widget.employee,
                        longitude: widget.longitude,
                        latitude: widget.latitude
                    );
                    setState(() {isLoading = false;});
                    if(punch!=null){
                      if(punch is Punch){
                        await showWelcomeDialog(isPunchIn: false,userName: widget.employee.getFullName(),context: context);
                        Navigator.pop(context);
                      }else if(punch is String){
                        showMessage(punch);
                      }
                    }
                  }catch(e){
                    showMessage(e.toString());
                    setState(() {isLoading = false;});
                  }
                }:null,
                child: isLoading?CircularProgressIndicator():Text(S.of(context).punchOut.toUpperCase(),style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700),),
                color: Colors.black,
                height: 50,
                minWidth: MediaQuery.of(context).size.width-40,
                disabledColor: Colors.black54,
                disabledTextColor: Colors.white,
                textColor: Colors.red,
              ),
              SizedBox(height: 20,),
            ],
          ),
        ),
      ),
      backgroundColor: Color(primaryColor),
    );
  }
}