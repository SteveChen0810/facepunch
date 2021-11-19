import 'package:facepunch/models/notification.dart';
import 'package:facepunch/models/work_model.dart';
import 'package:facepunch/screens/employee/employee_dispatch.dart';
import 'package:facepunch/widgets/dialogs.dart';
import 'package:facepunch/widgets/utils.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../lang/l10n.dart';
import '../../models/company_model.dart';
import '../../models/user_model.dart';
import '../admin/nfc/nfc_scan.dart';
import 'employee_document.dart';
import 'employee_notification.dart';
import 'employee_timesheet.dart';
import '../../models/app_const.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'employee_schedule.dart';

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
    initFireBaseNotification();
    _fetchData();
  }

  initFireBaseNotification(){
    final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        _onMessage(message);
      },
      onLaunch: (Map<String, dynamic> message) async {
        _onMessage(message);
      },
      onResume: (Map<String, dynamic> message) async {
        _onMessage(message);
      },
    );
    _firebaseMessaging.requestNotificationPermissions(IosNotificationSettings(sound: true, badge: true, alert: true));
  }

  _onMessage(message){
    Tools.playSound();
    AppNotification newNotification = AppNotification.fromJsonFirebase(message);
    showNotificationDialog(newNotification,context,);
  }

  _fetchData()async{
    await context.read<WorkModel>().getProjectsAndTasks();
    final user = context.read<UserModel>().user;
    if(user.canManageDispatch()){
      await context.read<CompanyModel>().getCompanyUsers();
    }
    await context.read<UserModel>().getYearTotalHours();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserModel>().user;
    if(user==null)return Container();
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
            if(user.canNTCTracking)
              NFCScanPage(),
            if(user.hasSchedule())
              EmployeeSchedule(),
            if(user.canManageDispatch())
              EmployeeDispatch(),
            EmployeeNotification()
          ],
          controller: _pageController,
          physics: NeverScrollableScrollPhysics(),
          onPageChanged: (i){
            setState(() {index = i; });
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
              icon: Image.asset("assets/images/ic_calendar.png",width: 30,),
              activeIcon: Image.asset("assets/images/ic_calendar.png",width: 30,color: Color(primaryColor),),
              label: S.of(context).calender
          ),
          BottomNavigationBarItem(
              icon: Image.asset("assets/images/ic_document.png",width: 30,),
              activeIcon: Image.asset("assets/images/ic_document.png",width: 30,color: Color(primaryColor),),
              label: S.of(context).document
          ),
          if(user.canNTCTracking)
            BottomNavigationBarItem(
                icon: Image.asset("assets/images/nfc.png",width: 30,color: Colors.black,),
                activeIcon: Image.asset("assets/images/nfc.png",width: 30,color: Color(primaryColor),),
                label: S.of(context).nfc
            ),
          if(user.hasSchedule())
            BottomNavigationBarItem(
                icon: Image.asset("assets/images/ic_schedule.png",width: 30,color: Colors.black,),
                activeIcon: Image.asset("assets/images/ic_schedule.png",width: 30,color: Color(primaryColor),),
                label: S.of(context).schedule
            ),
          if(user.canManageDispatch())
            BottomNavigationBarItem(
                icon: Image.asset("assets/images/ic_dispatch.png",width: 30,color: Colors.black,),
                activeIcon: Image.asset("assets/images/ic_dispatch.png",width: 30,color: Color(primaryColor),),
                label: S.of(context).dispatch
            ),
          BottomNavigationBarItem(
              icon: Image.asset("assets/images/ic_revision.png", width: 30,color: Colors.black,),
              activeIcon: Image.asset("assets/images/ic_revision.png", width: 30,color: Color(primaryColor),),
              label: S.of(context).nfc
          ),
        ],
        showSelectedLabels: false,
        showUnselectedLabels: false,
        currentIndex: index,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
        onTap: (i){
          _pageController.jumpToPage(i);
          setState(() {index = i;});
        },
      ),
      backgroundColor: Color(0xFFf4f4f4),
      resizeToAvoidBottomInset: true,
      resizeToAvoidBottomPadding: true,
    );
  }
}