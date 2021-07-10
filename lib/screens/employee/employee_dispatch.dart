import 'package:facepunch/lang/l10n.dart';
import 'package:facepunch/models/app_const.dart';
import 'package:flutter/material.dart';

class EmployeeDispatch extends StatefulWidget{

  @override
  _EmployeeDispatchState createState() => _EmployeeDispatchState();
}

class _EmployeeDispatchState extends State<EmployeeDispatch> {


  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top,
            ),
            height: kToolbarHeight+MediaQuery.of(context).padding.top,
            alignment: Alignment.center,
            color: Color(primaryColor),
            child: Text(S.of(context).dispatch,style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),),
          ),
        ],
      ),
    );
  }
}