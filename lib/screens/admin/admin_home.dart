import 'package:facepunch/lang/l10n.dart';
import 'package:facepunch/models/app_const.dart';
import 'package:facepunch/models/harvest_model.dart';
import 'package:facepunch/models/notification.dart';
import 'package:facepunch/models/work_model.dart';
import 'package:facepunch/screens/admin/employee_list.dart';
import 'package:flutter/material.dart';
import '/widgets/utils.dart';
import 'package:provider/provider.dart';

import 'create_edit_employee.dart';
import 'nfc/harvest_report.dart';
import 'nfc/nfc_scan.dart';
import 'settings/admin_settings.dart';
import 'settings/notification_page.dart';

class AdminHomePage extends StatefulWidget {

  @override
  _AdminHomePageState createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  PageController _pageController = PageController(initialPage: 0);
  int index = 0;

  @override
  void initState() {
    super.initState();
    Tools.setupFirebaseNotification(_onMessage);
    _fetchCompanyData();
  }

  _fetchCompanyData()async{
    await context.read<WorkModel>().getProjectsAndTasks();
    await context.read<HarvestModel>().getHarvestData();
    await context.read<NotificationModel>().getNotificationFromServer();
  }

  _onMessage(message){
    try{
      if(mounted){
        AppNotification newNotification = AppNotification.fromJsonFirebase(message.data);
        Tools.playSound();
        Tools.showNotificationDialog(newNotification, context);
      }
    }catch(e){
      Tools.consoleLog('[AdminHome._onMessage]$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        onWillPop: ()async{
          return false;
        },
        child: PageView(
          children: [
            EmployeeList(),
            CreateEditEmployee(),
            NotificationPage(),
            NFCScanPage(),
            HarvestReportScreen(),
            AdminSetting(),
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
          BottomNavigationBarItem(
              icon: Image.asset('assets/images/ic_dashboard.png', color: Colors.grey, width: 30, height: 30,),
              activeIcon: Image.asset('assets/images/ic_dashboard.png', color: Color(primaryColor), width: 30, height: 30,),
              label: S.of(context).calender
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_add),
              activeIcon: Icon(Icons.person_add, color: Color(primaryColor),),
              label: S.of(context).employee
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications),
              activeIcon: Icon(Icons.notifications, color: Color(primaryColor),),
              label: S.of(context).notifications
          ),
          BottomNavigationBarItem(
              icon: Image.asset('assets/images/nfc.png', color: Colors.grey, width: 30, height: 30,),
              activeIcon: Image.asset('assets/images/nfc.png', color: Color(primaryColor), width: 30, height: 30,),
              label: S.of(context).nfc
          ),
          BottomNavigationBarItem(
              icon: Image.asset('assets/images/ic_harvest.png', color: Colors.grey, width: 30, height: 30,),
              activeIcon: Image.asset('assets/images/ic_harvest.png', color: Color(primaryColor),width: 30, height: 30,),
              label: S.of(context).harvestReport
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              activeIcon: Icon(Icons.settings, color: Color(primaryColor),),
              label: S.of(context).setting
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