import 'package:cached_network_image/cached_network_image.dart';
import 'package:facepunch/models/harvest_model.dart';
import 'package:facepunch/models/notification.dart';
import 'package:facepunch/screens/admin/employee_logs.dart';
import 'package:facepunch/screens/admin/settings/admin_settings.dart';
import 'package:facepunch/screens/admin/settings/notification_page.dart';
import 'package:facepunch/widgets/calendar_strip/date-utils.dart';
import 'package:facepunch/widgets/dialogs.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:geolocator/geolocator.dart';
import '../../models/company_model.dart';
import '../../widgets/popover/cool_ui.dart';
import '../home_page.dart';
import 'create_edit_employee.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../models/app_const.dart';
import '../../models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'nfc/nfc_scan.dart';

class AdminHomePage extends StatefulWidget {

  @override
  _AdminHomePageState createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  RefreshController _refreshController = RefreshController(initialRefresh: true);
  Position currentPosition;

  void _onRefresh() async{
    await context.read<CompanyModel>().getCompanyUsers();
    _refreshController.refreshCompleted();
  }

  @override
  void initState() {
    super.initState();
    initFireBaseNotification();
    _determinePosition();
    Future.delayed(Duration(milliseconds: 500)).whenComplete((){_fetchCompanyData();});
  }

  _fetchCompanyData()async{
    await context.read<HarvestModel>().getTasksFromLocal();
    await context.read<HarvestModel>().getFields();
    await context.read<HarvestModel>().getContainers();
    await context.read<CompanyModel>().getCompanySettings();
  }

  Widget userItem(User user, double width){
    return CupertinoPopoverButton(
      popoverBoxShadow: [
        BoxShadow(color: Colors.black54,blurRadius: 5.0)
      ],
      popoverWidth: 180,
      popoverBuild: (_context){
        return CupertinoPopoverMenuList(
          children: <Widget>[
            CupertinoPopoverMenuItem(
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Edit Employee",style: TextStyle(color: Colors.black87),),
                    Icon(Icons.edit,color: Colors.black87,),
                  ],
                ),
              ),
              onTap: (){
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>CreateEditEmployee(employee: user,)));
                return true;
              },
            ),
            CupertinoPopoverMenuItem(
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Delete Employee",style: TextStyle(color: Colors.red),),
                    Icon(Icons.delete,color: Colors.red,),
                  ],
                ),
              ),
              onTap: (){
                deleteEmployee(user.id);
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
        padding: EdgeInsets.all(4),
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
              if(user.lastPunch!=null)
              Positioned(
                  bottom: 0,
                  child: Container(
                      width: width/5,
                      color: Colors.black.withOpacity(0.5),
                      alignment: Alignment.topCenter,
                      padding: EdgeInsets.only(bottom: 3),
                      child: Text("${PunchDateUtils.getTimeString(DateTime.parse(user.lastPunch.createdAt))}",style: TextStyle(color: Colors.white,),)
                  )
              )
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
            title: Text("Are you sure you want to delete this field?",textAlign: TextAlign.center,),
            content:StatefulBuilder(
              builder: (_,setState)=>Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        RaisedButton(
                          child: isDeletingField?SizedBox(
                            height: 28,
                            width: 28,
                            child: CircularProgressIndicator(backgroundColor: Colors.white,),
                          ):Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Text("Delete",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color: Colors.white),),
                          ),
                          color: Color(primaryColor),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          onPressed: ()async{
                            setState((){isDeletingField = true;});
                            String result = await context.read<CompanyModel>().deleteEmployee(userId);
                            setState((){isDeletingField = false;});
                            Navigator.pop(_context);
                            if(result!=null)showMessage(result);
                          },
                        ),
                        RaisedButton(
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Text("CLOSE",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold, color: Colors.white),),
                          ),
                          onPressed: ()async{
                            Navigator.pop(_context);
                          },
                          color: Colors.red,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
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

  showMessage(String message){
    _scaffoldKey.currentState.hideCurrentSnackBar();
    _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
          action: SnackBarAction(onPressed: (){},label: 'Close',textColor: Colors.white,),
        )
    );
  }

  showEmployeeLog(User user)async{
    Navigator.push(context, MaterialPageRoute(builder: (context)=>EmployeeLogs(employee: user,latitude: currentPosition?.latitude,longitude: currentPosition?.longitude,)));
  }

  _determinePosition() async {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      showMessage("Location permissions are permanently denied, we cannot request permissions.");
    }
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse && permission != LocationPermission.always) {
        showMessage("Location permissions are denied (actual value: $permission).");
        return null;
      }
    }
    currentPosition =  await Geolocator.getCurrentPosition();
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
    context.read<NotificationModel>().addNotification(newNotification);
    FlutterRingtonePlayer.play(
      android: AndroidSounds.notification,
      ios: IosSounds.glass,
      looping: false,
      volume: 1,
      asAlarm: false,
    ).catchError(print);
    if(newNotification.revision!=null){
      showRevisionNotificationDialog(newNotification,context,showMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    List<User> inUsers = context.watch<CompanyModel>().users.where((u) => (u.lastPunch!=null && u.lastPunch.punch=="In")).toList();
    List<User> outUsers = context.watch<CompanyModel>().users.where((u) => (u.lastPunch==null || u.lastPunch.punch=="Out")).toList();
    List<AppNotification> notifications  = context.watch<NotificationModel>().notifications.where((n) =>!n.seen).toList();
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("IN/OUT",style: TextStyle(color: Colors.black87,fontWeight: FontWeight.bold,fontSize: 30),),
        elevation: 0,
        backgroundColor: Color(primaryColor),
        actions: [
          IconButton(
              icon: Icon(Icons.logout),
              color: Colors.black87,
              iconSize: 35,
              onPressed: ()async{
                await context.read<UserModel>().logOut();
                await Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>HomePage()));
              }
          )
        ],
      ),
      body: WillPopScope(
        onWillPop: ()async{
          return false;
        },
        child: Container(
          padding: EdgeInsets.all(8),
          child: Column(
            children: [
              Expanded(
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Container(
                    padding: EdgeInsets.all(4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text("${DateTime.now().toString().split(" ").first}",style: TextStyle(fontWeight: FontWeight.bold),),
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
                                        child: Text("Employee Log In",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
                                      )
                                    ]
                                  ),
                                ),
                                if(inUsers.isEmpty)
                                  SliverList(
                                    delegate: SliverChildListDelegate(
                                        [
                                          Center(child: Text("Empty")),
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
                                          child: Text("Employee Log Out",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
                                        )
                                      ]
                                  ),
                                ),
                                if(outUsers.isEmpty)
                                  SliverList(
                                    delegate: SliverChildListDelegate(
                                        [
                                          Center(child: Text("Empty")),
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
                            FlatButton(
                                onPressed: ()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>NotificationPage())),
                                shape: CircleBorder(),
                                child: Stack(
                                  children: [
                                    Icon(Icons.notifications,color: Color(primaryColor),size: 40,),
                                    Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.red
                                      ),
                                      padding: EdgeInsets.all(4),
                                      child: Text("${notifications.length}",style: TextStyle(color: Colors.white),),
                                    )
                                  ],
                                )
                            ),
                            FlatButton(
                              onPressed: ()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>NFCScanPage())),
                              shape: CircleBorder(),
                              child: Image.asset('assets/images/nfc.png',color: Color(primaryColor),height: 40,),
                            ),
                            FlatButton(
                                onPressed: ()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>AdminSetting())),
                                shape: CircleBorder(),
                                child: Icon(Icons.settings,color: Color(primaryColor),size: 40,),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 8,),
              Container(
                width: width,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(40),
                ),
                padding: EdgeInsets.symmetric(vertical: 5,horizontal: 10),
                child: RaisedButton(
                  onPressed: ()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>CreateEditEmployee())),
                  child: Text("Create New Employee",style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,color: Colors.white),),
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
    );
  }

}