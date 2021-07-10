import 'package:facepunch/lang/l10n.dart';
import 'package:facepunch/models/app_const.dart';
import 'package:facepunch/models/user_model.dart';
import 'package:facepunch/models/work_model.dart';
import 'package:facepunch/screens/admin/face_punch/select_task.dart';
import 'package:facepunch/widgets/dialogs.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SelectProject extends StatefulWidget{

  final User employee;
  final Punch punch;
  final List<Project> projects;
  final List<ScheduleTask> tasks;
  final double longitude;
  final double latitude;

  SelectProject({this.employee, this.punch, this.projects, this.tasks, this.longitude, this.latitude});

  @override
  _SelectProjectState createState() => _SelectProjectState();
}

class _SelectProjectState extends State<SelectProject> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isLoading = false;

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
        title: Text(S.of(context).selectProject),
        elevation: 0,
        backgroundColor: Color(primaryColor),
        centerTitle: true,
        leading: IconButton(
          onPressed: (){
            if(!isLoading)Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
        ),
      ),
      body: WillPopScope(
        onWillPop: ()async{
          return !isLoading;
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            color: Colors.white,
          ),
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              if(widget.punch!=null)
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(S.of(context).welcome,style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("${widget.employee.getFullName()}",style: TextStyle(fontSize: 25),textAlign: TextAlign.center,),
                  ),
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Wrap(
                    children: [
                      for(var project in widget.projects)
                        Container(
                          decoration: BoxDecoration(
                            color: Color(primaryColor)
                          ),
                          margin: EdgeInsets.all(8),
                          child: InkWell(
                            onTap: ()=>Navigator.pushReplacement(
                                context, MaterialPageRoute(builder: (context)=>SelectTask(
                              punch: widget.punch,
                              employee: widget.employee,
                              project: project,
                              tasks: widget.tasks,
                              latitude: widget.latitude,
                              longitude: widget.longitude
                            ))),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8,horizontal: 16),
                              child: Text(project.name,style: TextStyle(fontSize: 16,),),
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