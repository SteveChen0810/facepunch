import 'package:facepunch/models/app_const.dart';
import 'package:facepunch/models/company_model.dart';
import 'package:facepunch/models/user_model.dart';
import 'package:facepunch/screens/employee/employee_login.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'admin/admin_home.dart';
import 'admin/auth/login.dart';
import 'admin/auth/register.dart';
import 'admin/company_register/fill_company_info.dart';
import 'admin/face_punch/start_face_punch.dart';
import 'employee/employee_home.dart';

class HomePage extends StatefulWidget{

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>{

  static const SIGN_UP =0;
  static const EMPLOYEE_SIGN_IN =1;
  static const FACE_PUNCH =2;
  static const ADMIN_SIGN_IN =3;

  PageController _pageController = PageController(initialPage: FACE_PUNCH,keepPage: false);
  int _pageIndex = FACE_PUNCH;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  List<Widget> buildBottomBar(){
    double width = MediaQuery.of(context).size.width/3-4;
    double borderRadius = 16.0;
    double iconSize = 18.0;
    TextStyle _style = TextStyle(fontWeight: FontWeight.bold,fontSize: 16);
    final shadow = BoxShadow(
      color: Colors.black.withOpacity(0.1),
      spreadRadius: 2,
      blurRadius: 2,
      offset: Offset(0, 2),
    );
    Widget signUp = Container(
      width: width,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(borderRadius)),
          color: Color(0xFFbfbfbf),
          boxShadow: [shadow]
      ),
      clipBehavior: Clip.hardEdge,
      padding: EdgeInsets.all(4.0),
      margin: EdgeInsets.all(2),
      child: InkWell(
        onTap: (){
          setState(() {
            _pageIndex = SIGN_UP;
          });
          _pageController.jumpToPage(SIGN_UP);
        },
        child: Column(
          children: [
            Icon(Icons.keyboard_arrow_up,size: iconSize),
            Text("SignUp",style: _style,textAlign: TextAlign.center,)
          ],
        ),
      ),
    );
    Widget facePunch = Container(
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(borderRadius)),
        color: Color(primaryColor),
        boxShadow: [shadow]
      ),
      padding: EdgeInsets.all(4.0),
      margin: EdgeInsets.all(2),
      child: InkWell(
        onTap: (){
          setState(() {
            _pageIndex = FACE_PUNCH;
          });
          _pageController.jumpToPage(FACE_PUNCH);
        },
        child: Column(
          children: [
            Icon(Icons.keyboard_arrow_up,size: iconSize,),
            Text("Face\nPunch",style: _style,textAlign: TextAlign.center,)
          ],
        ),
      ),
    );
    Widget employeeSignIn = Container(
      width: width,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(borderRadius)),
          color: Color(0xFFbfbfbf),
          boxShadow: [shadow]
      ),
      padding: EdgeInsets.all(4.0),
      margin: EdgeInsets.all(2),
      child: InkWell(
        onTap: (){
          setState(() {
            _pageIndex = EMPLOYEE_SIGN_IN;
          });
          _pageController.jumpToPage(EMPLOYEE_SIGN_IN);
        },
        child: Column(
          children: [
            Icon(Icons.keyboard_arrow_up,size: iconSize,),
            Text("Employee\nSignIn",style: _style,textAlign: TextAlign.center,)
          ],
        ),
      ),
    );
    Widget adminSignIn = Container(
      width: width,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(borderRadius)),
          color: Color(0xFFbfbfbf),
          boxShadow: [shadow]
      ),
      padding: EdgeInsets.all(4.0),
      margin: EdgeInsets.all(2),
      child: InkWell(
        onTap: (){
          setState(() {
            _pageIndex = ADMIN_SIGN_IN;
          });
          _pageController.jumpToPage(ADMIN_SIGN_IN);
        },
        child: Column(
          children: [
            Icon(Icons.keyboard_arrow_up,size: iconSize,),
            Text("Admin\nSignIn",style: _style,textAlign: TextAlign.center,)
          ],
        ),
      ),
    );
    List<Widget> tabs = [signUp,employeeSignIn,facePunch,adminSignIn];
    tabs.removeAt(_pageIndex);
    return tabs;
  }

  onLogin(String result){
    if(result==null){
      User user = context.read<UserModel>().user;
      if(user.companyId==null){
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>FillCompanyInfo()));
      }else{
        context.read<CompanyModel>().getMyCompany(user.companyId);
        if(user.role=="admin"){
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>AdminHomePage()));
        }else{
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>EmployeeHomePage()));
        }
      }
    }else{
      _showMessage(result);
    }
  }

  _showMessage(String message){
    _scaffoldKey.currentState.hideCurrentSnackBar();
    _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text(message),
          duration: Duration(seconds: 2),
          action: SnackBarAction(onPressed: (){},label: 'Close',textColor: Colors.white,),
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isShowKeyBoard = MediaQuery.of(context).viewInsets.bottom != 0;
    double imageSize = isShowKeyBoard?50:120;
    double bottomBarHeight = 70;
    double width = MediaQuery.of(context).size.width;
    double borderRadius = 16.0;
    double iconSize = 18.0;
    TextStyle _style = TextStyle(fontWeight: FontWeight.bold,fontSize: 16);
    final shadow = BoxShadow(
      color: Colors.black.withOpacity(0.3),
      spreadRadius: 1,
      blurRadius: 1,
      offset: Offset(0, 0),
    );
    return Scaffold(
      key: _scaffoldKey,
      body: WillPopScope(
        onWillPop: ()async{
          return false;
        },
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Image.asset(
                      "assets/images/logo.png",
                      width: imageSize,
                      height: imageSize,
                    ),
                  ),
                ),
              ),
              if(!isShowKeyBoard)
                Column(
                  children: [
                    Text("Welcome to FACE PUNCH",style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold),),
                    SizedBox(height: 4,),
                    Text("THE BEST EMPLOYEE CLOCKING SYSTEM",style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
                    SizedBox(height: 4,),
                  ],
                ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(top:  Radius.circular(20)),
                  color: Colors.white
                ),
                height: MediaQuery.of(context).size.height*0.6-bottomBarHeight,
                child: PageView(
                  children: [
                    RegisterWidget(onLogin: onLogin,),
                    EmployeeLogin(showMessage: _showMessage,),
                    StartFacePunch(showMessage: _showMessage,),
                    AdminSignIn(onLogin: onLogin,),
                  ],
                  controller: _pageController,
                  clipBehavior: Clip.hardEdge,
                  physics: NeverScrollableScrollPhysics(),
                  allowImplicitScrolling: true,
                  pageSnapping: true,
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: bottomBarHeight+50,
        color: Colors.white,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              width: width,
              height: bottomBarHeight+50,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(borderRadius)),
                  color: _pageIndex==SIGN_UP?Colors.white:Color(0xFFbfbfbf),
                  boxShadow: [shadow]
              ),
              clipBehavior: Clip.hardEdge,
              margin: EdgeInsets.all(2),
              child: InkWell(
                onTap: (){
                  setState(() {
                    _pageIndex = SIGN_UP;
                  });
                  _pageController.jumpToPage(SIGN_UP);
                },
                child: Column(
                  children: [
                    Icon(Icons.keyboard_arrow_up,size: iconSize),
                    Text("Sign Up",style: _style,textAlign: TextAlign.center,)
                  ],
                ),
              ),
            ),
            Row(
              children: [
                Container(
                  width: width/3-4,
                  height: bottomBarHeight,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(borderRadius)),
                      color: _pageIndex == EMPLOYEE_SIGN_IN?Colors.white:Color(0xFFbfbfbf),
                      boxShadow: [shadow]
                  ),
                  padding: EdgeInsets.all(4.0),
                  margin: EdgeInsets.all(2),
                  child: InkWell(
                    onTap: (){
                      setState(() {
                        _pageIndex = EMPLOYEE_SIGN_IN;
                      });
                      _pageController.jumpToPage(EMPLOYEE_SIGN_IN);
                    },
                    child: Column(
                      children: [
                        Icon(Icons.keyboard_arrow_up,size: iconSize,),
                        Text("Employee\nSign In",style: _style,textAlign: TextAlign.center,)
                      ],
                    ),
                  ),
                ),
                Container(
                  width: width/3-4,
                  height: bottomBarHeight,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(borderRadius)),
                      color: Color(primaryColor),
                      boxShadow: [
                        shadow,
                        if(_pageIndex == FACE_PUNCH)
                          BoxShadow(
                            color: Colors.white,
                            spreadRadius: 1,
                            blurRadius: 1,
                            offset: Offset(0, -1),
                          ),
                      ]
                  ),
                  padding: EdgeInsets.all(4.0),
                  margin: EdgeInsets.all(2),
                  child: InkWell(
                    onTap: (){
                      setState(() {
                        _pageIndex = FACE_PUNCH;
                      });
                      _pageController.jumpToPage(FACE_PUNCH);
                    },
                    child: Column(
                      children: [
                        Icon(Icons.keyboard_arrow_up,size: iconSize,),
                        Text("Face\nPunch",style: _style,textAlign: TextAlign.center,)
                      ],
                    ),
                  ),
                ),
                Container(
                  width: width/3-4,
                  height: bottomBarHeight,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(borderRadius)),
                      color: _pageIndex == ADMIN_SIGN_IN?Colors.white:Color(0xFFbfbfbf),
                      boxShadow: [shadow]
                  ),
                  padding: EdgeInsets.all(4.0),
                  margin: EdgeInsets.all(2),
                  child: InkWell(
                    onTap: (){
                      setState(() {
                        _pageIndex = ADMIN_SIGN_IN;
                      });
                      _pageController.jumpToPage(ADMIN_SIGN_IN);
                    },
                    child: Column(
                      children: [
                        Icon(Icons.keyboard_arrow_up,size: iconSize,),
                        Text("Admin\nSign In",style: _style,textAlign: TextAlign.center,)
                      ],
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
      backgroundColor: Color(primaryColor),
    );
  }
}