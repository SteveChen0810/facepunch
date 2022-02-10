import 'package:facepunch/screens/admin/employee_list.dart';

import '/lang/l10n.dart';
import '/models/app_const.dart';
import '/models/company_model.dart';
import '/models/harvest_model.dart';
import '/models/notification.dart';
import '/models/user_model.dart';
import '/models/work_model.dart';
import 'package:flutter/material.dart';
import '/widgets/utils.dart';
import 'package:provider/provider.dart';

import 'admin/create_edit_employee.dart';
import 'admin/nfc/harvest_report.dart';
import 'admin/nfc/nfc_scan.dart';
import 'admin/notification_page.dart';
import 'admin/settings/admin_settings.dart';
import 'employee/employee_daily_tasks.dart';
import 'employee/employee_dispatch.dart';
import 'employee/employee_document.dart';
import 'employee/employee_revisions.dart';
import 'employee/employee_timesheet.dart';


class NavigationPage extends StatefulWidget {

  @override
  _NavigationPageState createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  PageController _pageController = PageController(initialPage: 0);
  int index = 0;
  CompanySettings? settings;

  @override
  void initState() {
    super.initState();
    Tools.setupFirebaseNotification(_onMessage);
    _fetchCompanyData();
  }

  _fetchCompanyData()async{
    await context.read<WorkModel>().getProjectsAndTasks();
    await context.read<HarvestModel>().getHarvestData();
  }

  _onMessage(message){
    try{
      if(mounted){
        AppNotification newNotification = AppNotification.fromJsonFirebase(message.data);
        Tools.playSound();
        VoidCallback? onOpen;
        switch (newNotification.type){
          case 'revision_request':
            onOpen = (){
              Navigator.pop(context);
              _pageController.jumpToPage(1);
            };
            break;
        }
        Tools.showNotificationDialog(newNotification, context, onOpen);
      }
    }catch(e){
      Tools.consoleLog('[AdminHome._onMessage]$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    User? user = context.watch<UserModel>().user;
    settings = context.watch<CompanyModel>().myCompanySettings;
    if(user == null || settings == null) return Container();

    return Scaffold(
      body: WillPopScope(
        onWillPop: ()async{
          return false;
        },
        child: PageView(
          children: [
            if(user.canAccessPage('EmployeeList', settings!))
              EmployeeList(),
            if(user.canAccessPage('NotificationPage', settings!))
              NotificationPage(),
            if(user.canAccessPage('CreateEditEmployee', settings!))
              CreateEditEmployee(pageController: _pageController,),
            if(user.canAccessPage('NFCScanPage', settings!))
              NFCScanPage(),
            if(user.canAccessPage('HarvestReportScreen', settings!))
              HarvestReportScreen(),
            if(user.canAccessPage('AdminSetting', settings!))
              AdminSetting(),
            if(user.canAccessPage('EmployeeTimeSheet', settings!))
              EmployeeTimeSheet(),
            if(user.canAccessPage('EmployeeDocument', settings!))
              EmployeeDocument(),
            if(user.canAccessPage('EmployeeDailyTasks', settings!))
              EmployeeDailyTasks(),
            if(user.canAccessPage('EmployeeDispatch', settings!))
              EmployeeDispatch(),
            if(user.canAccessPage('EmployeeRevisions', settings!))
              EmployeeRevisions(),
          ],
          controller: _pageController,
          physics: NeverScrollableScrollPhysics(),
          onPageChanged: (i){
            setState(() { index = i; });
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          if(user.canAccessPage('EmployeeList', settings!))
            BottomNavigationBarItem(
                icon: Image.asset('assets/images/ic_dashboard.png', color: Colors.grey, width: 30, height: 30,),
                activeIcon: Image.asset('assets/images/ic_dashboard.png', color: Color(primaryColor), width: 30, height: 30,),
                label: S.of(context).calender
            ),
          if(user.canAccessPage('NotificationPage', settings!))
            BottomNavigationBarItem(
                icon: Icon(Icons.notifications),
                activeIcon: Icon(Icons.notifications, color: Color(primaryColor),),
                label: S.of(context).notifications
            ),
          if(user.canAccessPage('CreateEditEmployee', settings!))
            BottomNavigationBarItem(
                icon: Icon(Icons.person_add),
                activeIcon: Icon(Icons.person_add, color: Color(primaryColor),),
                label: S.of(context).employee
            ),
          if(user.canAccessPage('NFCScanPage', settings!))
            BottomNavigationBarItem(
                icon: Image.asset('assets/images/nfc.png', color: Colors.grey, width: 30, height: 30,),
                activeIcon: Image.asset('assets/images/nfc.png', color: Color(primaryColor), width: 30, height: 30,),
                label: S.of(context).nfc
            ),
          if(user.canAccessPage('HarvestReportScreen', settings!))
            BottomNavigationBarItem(
                icon: Image.asset('assets/images/ic_harvest.png', color: Colors.grey, width: 30, height: 30,),
                activeIcon: Image.asset('assets/images/ic_harvest.png', color: Color(primaryColor),width: 30, height: 30,),
                label: S.of(context).harvestReport
            ),
          if(user.canAccessPage('AdminSetting', settings!))
            BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                activeIcon: Icon(Icons.settings, color: Color(primaryColor),),
                label: S.of(context).setting
            ),
          if(user.canAccessPage('EmployeeTimeSheet', settings!))
            BottomNavigationBarItem(
                icon: Image.asset("assets/images/ic_calendar.png",width: 30,),
                activeIcon: Image.asset("assets/images/ic_calendar.png",width: 30,color: Color(primaryColor),),
                label: S.of(context).calender
            ),
          if(user.canAccessPage('EmployeeDocument', settings!))
            BottomNavigationBarItem(
                icon: Image.asset("assets/images/ic_document.png",width: 30,),
                activeIcon: Image.asset("assets/images/ic_document.png",width: 30,color: Color(primaryColor),),
                label: S.of(context).document
            ),
          if(user.canAccessPage('EmployeeDailyTasks', settings!))
            BottomNavigationBarItem(
                icon: Image.asset("assets/images/ic_schedule.png",width: 30,color: Colors.black,),
                activeIcon: Image.asset("assets/images/ic_schedule.png",width: 30,color: Color(primaryColor),),
                label: S.of(context).schedule
            ),
          if(user.canAccessPage('EmployeeDispatch', settings!))
            BottomNavigationBarItem(
                icon: Image.asset("assets/images/ic_dispatch.png",width: 30,color: Colors.black,),
                activeIcon: Image.asset("assets/images/ic_dispatch.png",width: 30,color: Color(primaryColor),),
                label: S.of(context).dispatch
            ),
          if(user.canAccessPage('EmployeeRevisions', settings!))
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