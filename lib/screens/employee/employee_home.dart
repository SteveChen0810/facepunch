import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/models/notification.dart';
import '/models/work_model.dart';
import '/models/app_const.dart';
import '/models/company_model.dart';
import '/models/user_model.dart';
import '/models/harvest_model.dart';
import '/widgets/utils.dart';
import '/lang/l10n.dart';
import '../admin/nfc/nfc_scan.dart';
import 'call_detail.dart';
import 'employee_document.dart';
import 'employee_timesheet.dart';
import 'employee_dispatch.dart';
import 'employee_daily_tasks.dart';
import 'employee_revisions.dart';

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
    Tools.setupFirebaseNotification(_onMessage);
    _fetchData();
  }

  _onMessage(message){
    try{
      if(mounted){
        AppNotification notification = AppNotification.fromJsonFirebase(message.data);
        Tools.playSound();
        VoidCallback? onOpen;
        if(notification.hasCall()){
          onOpen = (){
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (c)=>CallDetailScreen(notification.callId!)));
          };
        }
        Tools.showNotificationDialog(notification, context, onOpen);
      }
    }catch(e){
      Tools.consoleLog('[EmployeeHome._onMessage]$e');
    }
  }

  _fetchData()async{
    await context.read<WorkModel>().getProjectsAndTasks();
    final user = context.read<UserModel>().user;
    if(user?.canManageDispatch()??false){
      await context.read<CompanyModel>().getCompanyUsers();
    }
    await context.read<UserModel>().getYearTotalHours();
    await context.read<HarvestModel>().getHarvestData();
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
            if(user.hasNTCTracking())
              NFCScanPage(),
            EmployeeDailyTasks(),
            if(user.canManageDispatch())
              EmployeeDispatch(),
            EmployeeRevisions()
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
          if(user.hasNTCTracking())
            BottomNavigationBarItem(
                icon: Image.asset("assets/images/nfc.png",width: 30,color: Colors.black,),
                activeIcon: Image.asset("assets/images/nfc.png",width: 30,color: Color(primaryColor),),
                label: S.of(context).nfc
            ),
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
    );
  }
}