import 'package:facepunch/lang/l10n.dart';
import 'package:facepunch/models/app_const.dart';
import 'package:facepunch/models/user_model.dart';
import 'package:facepunch/models/work_model.dart';
import 'package:flutter/material.dart';

class SelectCallScreen extends StatefulWidget{

  final List<EmployeeCall> calls;
  final User employee;
  final Punch punch;
  SelectCallScreen({this.calls, this.employee, this.punch});

  @override
  _SelectCallScreenState createState() => _SelectCallScreenState();
}

class _SelectCallScreenState extends State<SelectCallScreen> {

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isLoading = false;
  List<EmployeeCall> calls;
  User employee;
  Punch punch;
  EmployeeCall selectedCall;

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(S.of(context).selectCall),
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
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            children: [
              if(punch.isOut())
                Text('Do you want to work on next call or end today?'),
              if(punch.isIn())
                Text('Select a call and Press the button to work on a call.'),
              for(var call in calls)
                Container(
                  margin: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: selectedCall==call?Color(primaryColor):Colors.green,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.all(8),
                  child: InkWell(
                    onTap: ()=>setState(() { selectedCall = call; }),
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
                )
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: 40,
        margin: EdgeInsets.only(bottom: 20, left: 12, right: 12, top: 8),
        child: MaterialButton(
          onPressed: selectedCall==null?null:()async{
            if(!isLoading){
              setState(() { isLoading = true; });
              String message = await selectedCall.startCall(employee.token);
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
          ):Text(S.of(context).startCall, style: TextStyle(color: Colors.white, fontSize: 16),),
        ),
      ),
    );
  }
}