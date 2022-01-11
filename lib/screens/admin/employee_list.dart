import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';

import '/lang/l10n.dart';
import '/models/notification.dart';
import '/models/revision_model.dart';
import '/models/app_const.dart';
import '/models/user_model.dart';
import '/models/company_model.dart';
import '/screens/admin/employee_logs.dart';
import '/screens/admin/settings/admin_settings.dart';
import '/screens/admin/settings/notification_page.dart';
import '/screens/bug_report_page.dart';
import '../home_page.dart';
import '/widgets/autocomplete_textfield.dart';
import '/widgets/calendar_strip/date-utils.dart';
import '/widgets/utils.dart';
import '/widgets/popover/cool_ui.dart';
import 'nfc/harvest_report.dart';
import 'nfc/nfc_scan.dart';
import 'create_edit_employee.dart';

class EmployeeList extends StatefulWidget {

  @override
  _EmployeeListState createState() => _EmployeeListState();
}

class _EmployeeListState extends State<EmployeeList> {

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  RefreshController _refreshController = RefreshController(initialRefresh: true);
  Position? currentPosition;
  int? loadingUser = 0;
  User? selectedUser;
  GlobalKey<AutoCompleteTextFieldState<String>> _searchKey = GlobalKey<AutoCompleteTextFieldState<String>>();
  CompanySettings? settings;

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  _determinePosition() async {
    Tools.checkLocationPermission().then((v){
      if(v){
        Geolocator.getCurrentPosition()
            .then((value){currentPosition = value;})
            .catchError((e){
          Tools.consoleLog('[FacePunchScreen.getCurrentPosition]$e');
        });
      }else{
        Tools.showErrorMessage(context, S.of(context).locationPermissionDenied);
      }
    });
  }

  void _onRefresh() async{
    await context.read<CompanyModel>().getCompanyUsers();
    _refreshController.refreshCompleted();
  }

  Widget _userItem(User user){
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
                  if(user.id != null){
                    _deleteEmployee(user.id!);
                  }
                  return true;
                },
              )
          ],
        );
      },
      onTap: (){
        _showEmployeeLog(user);
        return true;
      },
      child: Container(
        margin: EdgeInsets.all(3),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                  border: Border.all(color: selectedUser?.id==user.id?Colors.red:Colors.transparent,width: 2),
                  shape: BoxShape.circle
              ),
              child: ClipOval(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    user.userAvatarImage(),
                    if(user.lastPunch != null)
                      Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                              color: Colors.black.withOpacity(0.5),
                              padding: EdgeInsets.only(bottom: 3),
                              child: Text("${PunchDateUtils.getTimeString(DateTime.parse(user.lastPunch!.createdAt!))}",
                                style: TextStyle(color: Colors.white,),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                              )
                          )
                      ),
                    if(user.id == loadingUser)
                      Center(child: CircularProgressIndicator(color: Colors.green,)),
                  ],
                ),
              ),
            ),
            if(user.hasCode())
              Text('${user.employeeCode}',
                style: TextStyle(fontSize: 10),
                maxLines: 1,
                textAlign: TextAlign.center,
              ),
            Expanded(
              child: Text('${user.getFullName()}',
                style: TextStyle(fontSize: 12), maxLines: 1, textAlign: TextAlign.center,),
            ),
          ],
        ),
      ),
    );
  }

  _deleteEmployee(int userId)async{
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

  _showEmployeeLog(User user)async{
    Navigator.push(context, MaterialPageRoute(builder: (context)=>EmployeeLogs(employee: user, latitude: currentPosition?.latitude, longitude: currentPosition?.longitude,)));
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
    User? user = context.watch<UserModel>().user;

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
      body: Container(
        padding: EdgeInsets.only(left: 8,right: 8,bottom: 16),
        child: Column(
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
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
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5, childAspectRatio: 0.7,),
                              delegate: SliverChildListDelegate(
                                  [
                                    for(User user in inUsers)
                                      _userItem(user),
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
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5, childAspectRatio: 0.7,),
                              delegate: SliverChildListDelegate(
                                  [
                                    for(User user in outUsers)
                                      _userItem(user),
                                  ]
                              ),
                            ),
                          ],

                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Color(primaryColor),
      resizeToAvoidBottomInset: false,
    );
  }
}