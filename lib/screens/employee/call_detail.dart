import 'package:facepunch/lang/l10n.dart';
import 'package:facepunch/models/app_const.dart';
import 'package:facepunch/models/work_model.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '/widgets/utils.dart';

class CallDetailScreen extends StatefulWidget {

  final int callId;
  CallDetailScreen(this.callId);

  @override
  _CallDetailScreenState createState() => _CallDetailScreenState();
}

class _CallDetailScreenState extends State<CallDetailScreen> {
  EmployeeCall? call;

  @override
  void initState() {
    super.initState();
    _getCallFromServer();
  }

  _getCallFromServer()async{
    try{
      var result = await context.read<WorkModel>().getCall(widget.callId);
      if(!mounted)return;
      if(result is EmployeeCall){
        setState(() {
          call = result;
        });
      }else{
        Tools.showErrorMessage(context, '$result');
      }
    }catch(e){
      Tools.consoleLog('[CallDetailScreen._getCallFromServer.err]$e');
    }
  }

  Widget _body(){
    if(call == null){
      return Center(
        child: CircularProgressIndicator(color: Colors.green,),
      );
    }
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(S.of(context).project,style: TextStyle(fontWeight: FontWeight.bold),),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(call!.projectTitle()),
          ),
          Text(S.of(context).task,style: TextStyle(fontWeight: FontWeight.bold),),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(call!.taskTitle()),
          ),
          Text(S.of(context).date,style: TextStyle(fontWeight: FontWeight.bold),),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('${call!.date}'),
          ),
          if(call!.hasTime())
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(S.of(context).start,style: TextStyle(fontWeight: FontWeight.bold),),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('${call!.startTime()}'),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(S.of(context).end,style: TextStyle(fontWeight: FontWeight.bold),),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('${call!.endTime()}'),
                    ),
                  ],
                )
              ],
            ),
          Text(S.of(context).priority,style: TextStyle(fontWeight: FontWeight.bold),),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('${call!.priority}'),
          ),
          Text(S.of(context).todo,style: TextStyle(fontWeight: FontWeight.bold),),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('${call!.todo}'),
          ),
          Text(S.of(context).note,style: TextStyle(fontWeight: FontWeight.bold),),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('${call!.note}'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).callDetail),
        backgroundColor: Color(primaryColor),
        centerTitle: true,
      ),
      body: _body(),
    );
  }

}