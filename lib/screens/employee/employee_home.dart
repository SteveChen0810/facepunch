import 'package:audioplayers/audio_cache.dart';
import 'package:facepunch/models/notification.dart';
import 'package:facepunch/models/work_model.dart';
import 'package:facepunch/screens/employee/employee_dispatch.dart';
import 'package:facepunch/widgets/dialogs.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../lang/l10n.dart';
import '../../models/company_model.dart';
import '../../models/user_model.dart';
import '../admin/nfc/nfc_scan.dart';
import 'employee_document.dart';
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
  final AudioCache player = AudioCache();

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
    AppNotification newNotification = AppNotification.fromJsonFirebase(message);
    player.play('sound/sound.mp3').catchError(print);
    showNotificationDialog(newNotification,context,);
  }

  _fetchData()async{
    final user = context.read<UserModel>().user;
    if(['sub_admin','manager'].contains(user.role)){
      await context.read<CompanyModel>().getCompanyUsers();
    }
    await context.read<WorkModel>().getProjectsAndTasks();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<CompanyModel>().myCompanySettings;
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
            if(settings.hasTimeSheetSchedule)
              EmployeeSchedule(),
            if(['sub_admin','manager'].contains(user.role))
              EmployeeDispatch()
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
          if(settings.hasTimeSheetSchedule)
            BottomNavigationBarItem(
                icon: Image.asset("assets/images/ic_schedule.png",width: 30,color: Colors.black,),
                activeIcon: Image.asset("assets/images/ic_schedule.png",width: 30,color: Color(primaryColor),),
                label: S.of(context).nfc
            ),
          if(['sub_admin','manager'].contains(user.role))
            BottomNavigationBarItem(
                icon: Image.asset("assets/images/dispatch.png",width: 30,color: Colors.black,),
                activeIcon: Image.asset("assets/images/dispatch.png",width: 30,color: Color(primaryColor),),
                label: S.of(context).nfc
            ),
        ],
        showSelectedLabels: false,
        showUnselectedLabels: false,
        currentIndex: index,
        elevation: 8,
        onTap: (i){
          _pageController.jumpToPage(i);
          setState(() {index = i;});
        },
      ),
      backgroundColor: Color(0xFFf4f4f4),
    );
  }
}