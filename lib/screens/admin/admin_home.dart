import 'package:cached_network_image/cached_network_image.dart';
import 'package:facepunch/screens/bug_report_page.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';

import '/lang/l10n.dart';
import '/models/harvest_model.dart';
import '/models/notification.dart';
import '/models/revision_model.dart';
import '/models/work_model.dart';
import '/models/app_const.dart';
import '/models/user_model.dart';
import '/models/company_model.dart';
import '/screens/admin/employee_logs.dart';
import '/screens/admin/settings/admin_settings.dart';
import '/screens/admin/settings/notification_page.dart';
import '../home_page.dart';

import '/widgets/autocomplete_textfield.dart';
import '/widgets/calendar_strip/date-utils.dart';
import '/widgets/dialogs.dart';
import '/widgets/utils.dart';
import '/widgets/popover/cool_ui.dart';
import 'nfc/harvest_report.dart';
import 'nfc/nfc_scan.dart';
import 'create_edit_employee.dart';

class AdminHomePage extends StatefulWidget {

  @override
  _AdminHomePageState createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  RefreshController _refreshController = RefreshController(initialRefresh: true);
  Position? currentPosition;
  int? loadingUser = 0;
  User? selectedUser;
  GlobalKey<AutoCompleteTextFieldState<String>> _searchKey = GlobalKey<AutoCompleteTextFieldState<String>>();
  CompanySettings? settings;

  void _onRefresh() async{
    await context.read<CompanyModel>().getCompanyUsers();
    _refreshController.refreshCompleted();
  }

  @override
  void initState() {
    super.initState();
    initFireBaseNotification();
    _determinePosition();
    _fetchCompanyData();
  }

  _fetchCompanyData()async{
    await context.read<WorkModel>().getProjectsAndTasks();
    await context.read<HarvestModel>().getHarvestData();
    await context.read<NotificationModel>().getNotificationFromServer();
  }

  Widget userItem(User user, double width){
    return CupertinoPopoverButton(
      popoverBoxShadow: [
        BoxShadow(color: Colors.black54,blurRadius: 5.0)
      ],
      popoverWidth: 200,
      popoverBuild: (_context){
        return CupertinoPopoverMenuList(
          children: <Widget>[
            CupertinoPopoverMenuItem(
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(user.isPunchIn()?S.of(context).punchOut:S.of(context).punchIn,style: TextStyle(color: Colors.black87),),
                    Icon(user.isPunchIn()?Icons.logout:Icons.login,color: Colors.black87,),
                  ],
                ),
              ),
              onTap: (){
                Navigator.of(_context).pop();
                _manualPunch(user);
                return true;
              },
            ),
            CupertinoPopoverMenuItem(
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(S.of(context).editEmployee,style: TextStyle(color: Colors.black87),),
                    Icon(Icons.edit,color: Colors.black87,),
                  ],
                ),
              ),
              onTap: (){
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>CreateEditEmployee(employee: user,)));
                return true;
              },
            ),
            if(settings!.useOwnData??false)
              CupertinoPopoverMenuItem(
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(S.of(context).deleteEmployee,style: TextStyle(color: Colors.red),),
                      Icon(Icons.delete,color: Colors.red,),
                    ],
                  ),
                ),
                onTap: (){
                  if(user.id != null)deleteEmployee(user.id!);
                  return true;
                },
              )
          ],
        );
      },
      onTap: (){
        showEmployeeLog(user);
        return true;
      },
      child: Container(
        alignment: Alignment.center,
        margin: EdgeInsets.all(3),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: selectedUser?.id==user.id?Colors.red:Colors.transparent,width: 2)
        ),
        child: ClipOval(
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              CachedNetworkImage(
                imageUrl: "${AppConst.domainURL}images/user_avatars/${user.avatar}",
                height: width/5,
                width: width/5,
                alignment: Alignment.center,
                placeholder: (_,__)=>Image.asset("assets/images/person.png"),
                errorWidget: (_,__,___)=>Image.asset("assets/images/person.png"),
                fit: BoxFit.cover,
              ),
              if(user.lastPunch != null)
                Positioned(
                    bottom: 0,
                    child: Container(
                        width: width/5,
                        color: Colors.black.withOpacity(0.5),
                        alignment: Alignment.topCenter,
                        padding: EdgeInsets.only(bottom: 3),
                        child: Text("${PunchDateUtils.getTimeString(DateTime.parse(user.lastPunch!.createdAt!))}",
                          style: TextStyle(color: Colors.white,),
                        )
                    )
                ),
              if(user.id==loadingUser)
                Center(child: CircularProgressIndicator()),
            ],
          ),
        ),
      ),
    );
  }


  deleteEmployee(int userId)async{
    bool isDeletingField = false;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_context){
        return AlertDialog(
            title: Text(S.of(context).deleteEmployeeConfirm,textAlign: TextAlign.center,),
            content:StatefulBuilder(
              builder: (_,setState)=>Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          child: isDeletingField?SizedBox(
                            height: 28,
                            width: 28,
                            child: CircularProgressIndicator(backgroundColor: Colors.white,),
                          ):Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Text(S.of(context).delete,style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color: Colors.white),),
                          ),
                          onPressed: ()async{
                            setState((){isDeletingField = true;});
                            String? result = await context.read<CompanyModel>().deleteEmployee(userId);
                            setState((){isDeletingField = false;});
                            Navigator.pop(_context);
                            if(result != null)Tools.showErrorMessage(context, result);
                          },
                        ),
                        TextButton(
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Text(S.of(context).close.toUpperCase(),style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold, color: Colors.white),),
                          ),
                          onPressed: ()async{
                            Navigator.pop(_context);
                          },
                        ),
                      ],
                    )
                  ],
                ),
              ),
            )
        );
      },
    );
  }

  showEmployeeLog(User user)async{
    Navigator.push(context, MaterialPageRoute(builder: (context)=>EmployeeLogs(employee: user, latitude: currentPosition?.latitude, longitude: currentPosition?.longitude,)));
  }

  _determinePosition() async {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      Tools.showErrorMessage(context, S.of(context).locationPermissionDenied);
    }
    if (permission == LocationPermission.denied) {
      await showLocationPermissionDialog(context);
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse && permission != LocationPermission.always) {
        Tools.showErrorMessage(context, S.of(context).locationPermissionDenied);
        return null;
      }
    }
    currentPosition =  await Geolocator.getCurrentPosition();
  }

  initFireBaseNotification(){
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _onMessage(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _onMessage(message);
    });
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message){
          if(message != null)_onMessage(message);
    });
    FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  _onMessage(RemoteMessage message){
    try{
      if(mounted){
        AppNotification newNotification = AppNotification.fromJsonFirebase(message.data);
        Tools.playSound();
        showNotificationDialog(newNotification, context,);
      }
    }catch(e){
      Tools.consoleLog('[AdminHome._onMessage]$e');
    }
  }

  _manualPunch(User user)async{
    try{
      final TimeOfDay? picked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(DateTime.now()),
        initialEntryMode: TimePickerEntryMode.input,
        helpText: 'Confirm Punch Time'
      );
      if(picked==null)return;
      DateTime now = DateTime.now();
      setState(() { loadingUser = user.id; });
      String? result = await context.read<CompanyModel>().punchByAdmin(
          userId: user.id,
          action: user.isPunchIn()?'Out':'In',
          latitude: currentPosition?.latitude,
          longitude: currentPosition?.longitude,
          punchTime: DateTime(now.year, now.month, now.day, picked.hour, picked.minute, 0, 0).toString()
      );
      setState(() { loadingUser=0; });
      if(result != null)Tools.showErrorMessage(context, result);
    }catch(e){
      Tools.consoleLog('[_manualPunch]$e');
      setState(() {loadingUser=0;});
    }
  }


  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    List<User> inUsers = context.watch<CompanyModel>().users.where((u) => u.isPunchIn()).toList();
    List<User> outUsers = context.watch<CompanyModel>().users.where((u) => !u.isPunchIn()).toList();
    List<Revision> revisions  = context.watch<NotificationModel>().revisions.where((r) => r.status == 'requested').toList();
    settings = context.watch<CompanyModel>().myCompanySettings;
    List<User> users = context.watch<CompanyModel>().users;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(S.of(context).inOut,style: TextStyle(color: Colors.black87,fontWeight: FontWeight.bold,fontSize: 30),),
        elevation: 0,
        backgroundColor: Color(primaryColor),
        actions: [
          IconButton(
              icon: Icon(Icons.bug_report),
              color: Colors.white,
              iconSize: 35,
              onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>BugReportPage()));
              }
          ),
          IconButton(
              icon: Icon(Icons.logout),
              color: Colors.white,
              iconSize: 35,
              onPressed: ()async{
                await context.read<UserModel>().logOut();
                await Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>HomePage()));
              }
          ),
        ],
      ),
      body: WillPopScope(
        onWillPop: ()async{
          return false;
        },
        child: Container(
          padding: EdgeInsets.only(left: 8,right: 8,bottom: 16),
          child: Column(
            children: [
              Expanded(
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: Container(
                    padding: EdgeInsets.all(4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if(users.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 4),
                            child: SimpleAutoCompleteTextField(
                              key: _searchKey,
                              suggestions: users.map((e) => e.getFullName()).toList(),
                              suggestionsAmount: 10,
                              submitOnSuggestionTap: true,
                              clearOnSubmit: false,
                              textSubmitted: (v)async{
                                setState(() {
                                  selectedUser = users.firstWhereOrNull((u) => u.getFullName()==v);
                                });
                              },
                              minLength: 1,
                              keyboardType: TextInputType.name,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(borderRadius: const BorderRadius.all(Radius.circular(5)),),
                                contentPadding: EdgeInsets.symmetric(horizontal: 15,vertical: 8),
                                isDense: true,
                                hintText: S.of(context).searchEmployee
                              ),
                              autoFocus: false,
                            ),
                          ),
                        Expanded(
                          child: SmartRefresher(
                            enablePullDown: true,
                            enablePullUp: false,
                            header: WaterDropMaterialHeader(backgroundColor: Color(primaryColor),distance: 60,),
                            controller: _refreshController,
                            onRefresh: _onRefresh,
                            child: CustomScrollView(
                              slivers: [
                                SliverList(
                                  delegate: SliverChildListDelegate(
                                    [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(S.of(context).employeeLogIn,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
                                      )
                                    ]
                                  ),
                                ),
                                if(inUsers.isEmpty)
                                  SliverList(
                                    delegate: SliverChildListDelegate(
                                        [
                                          Center(child: Text(S.of(context).empty)),
                                        ]
                                    ),
                                  ),
                                SliverGrid(
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5,childAspectRatio: 1,),
                                  delegate: SliverChildListDelegate(
                                    [
                                      for(User user in inUsers)
                                        userItem(user,width),
                                    ]
                                  ),
                                ),
                                SliverList(
                                  delegate: SliverChildListDelegate(
                                      [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(S.of(context).employeeLogOut,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
                                        )
                                      ]
                                  ),
                                ),
                                if(outUsers.isEmpty)
                                  SliverList(
                                    delegate: SliverChildListDelegate(
                                        [
                                          Center(child: Text(S.of(context).empty)),
                                        ]
                                    ),
                                  ),
                                SliverGrid(
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5,childAspectRatio: 1,),
                                  delegate: SliverChildListDelegate(
                                      [
                                        for(User user in outUsers)
                                          userItem(user,width),
                                      ]
                                  ),
                                ),
                              ],

                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            TextButton(
                                onPressed: ()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>NotificationPage())),
                                child: Stack(
                                  children: [
                                    Icon(Icons.notifications,color: Color(primaryColor),size: 35,),
                                    Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.red
                                      ),
                                      padding: EdgeInsets.all(4),
                                      child: Text("${revisions.length}", style: TextStyle(color: Colors.white),),
                                    )
                                  ],
                                )
                            ),
                            if(settings!.hasNFCHarvest??false)
                              TextButton(
                                onPressed: ()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>NFCScanPage())),
                                child: Image.asset('assets/images/nfc.png',color: Color(primaryColor),height: 40,),
                              ),
                            if(settings!.hasNFCReport??false)
                              TextButton(
                                onPressed: ()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>HarvestReportScreen())),
                                child: Image.asset('assets/images/ic_harvest.png', color: Color(primaryColor),width: 30, height: 30,),
                              ),
                            TextButton(
                                onPressed: ()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>AdminSetting())),
                                child: Icon(Icons.settings,color: Color(primaryColor),size: 35,),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
              if(settings!.useOwnData??false)
                Container(
                  width: width,
                  margin: EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(40),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 5,horizontal: 10),
                  child: MaterialButton(
                    onPressed: ()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>CreateEditEmployee())),
                    child: Text(S.of(context).createNewEmployee,style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,color: Colors.white),),
                    padding: EdgeInsets.all(10),
                    color: Colors.black87,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                )
            ],
          ),
        ),
      ),
      backgroundColor: Color(primaryColor),
      resizeToAvoidBottomInset: false,
    );
  }

}