import 'package:facepunch/screens/employee/employee_document.dart';
import 'package:facepunch/screens/employee/employee_setting.dart';
import 'package:facepunch/screens/employee/employee_timesheet.dart';

import '../../models/app_const.dart';
import 'package:flutter/material.dart';
class EmployeeHomePage extends StatefulWidget {

  @override
  _EmployeeHomePageState createState() => _EmployeeHomePageState();
}

class _EmployeeHomePageState extends State<EmployeeHomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  PageController _pageController = PageController(initialPage: 0);
  int index = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: WillPopScope(
        onWillPop: ()async{
          return false;
        },
        child: PageView(
          children: [
            EmployeeTimeSheet(),
            EmployeeDocument(),
            EmployeeSetting()
          ],
          controller: _pageController,
          onPageChanged: (i){
            setState(() {index = i; });
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
              icon: Image.asset("assets/images/ic_calendar.png",height: 30,),
              activeIcon: Image.asset("assets/images/ic_calendar.png",height: 40,color: Color(primaryColor),),
              label: "Calender"
          ),
          BottomNavigationBarItem(
              icon: Image.asset("assets/images/ic_document.png",height: 30,),
              activeIcon: Image.asset("assets/images/ic_document.png",height: 40,color: Color(primaryColor),),
              label: "Document"
          ),
          BottomNavigationBarItem(
              icon: Image.asset("assets/images/ic_setting.png",height: 30,),
              activeIcon: Image.asset("assets/images/ic_setting.png",height: 40,color: Color(primaryColor),),
              label: "Setting"
          ),
        ],
        showSelectedLabels: false,
        showUnselectedLabels: false,
        currentIndex: index,
        elevation: 8,
        onTap: (i){
          _pageController.animateToPage(i, duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
          setState(() {
            index = i;
          });
        },
      ),
      backgroundColor: Color(0xFFf4f4f4),
    );
  }
}