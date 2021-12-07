import '/models/app_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/lang/l10n.dart';
import '/models/app_const.dart';
import '/models/company_model.dart';
import '/models/user_model.dart';
import '/screens/employee/employee_login.dart';
import 'admin/admin_home.dart';
import 'admin/auth/login.dart';
import 'admin/face_punch/start_face_punch.dart';
import 'employee/employee_home.dart';
import '/widgets/utils.dart';

class HomePage extends StatefulWidget{

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin<HomePage>{

  static const EMPLOYEE_SIGN_IN =0;
  static const FACE_PUNCH =1;
  static const ADMIN_SIGN_IN =2;

  late TabController _tabController;
  int _pageIndex = FACE_PUNCH;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this, initialIndex: FACE_PUNCH);
    super.initState();
  }

  onLogin(String? result)async{
    if(result == null){
      User user = context.read<UserModel>().user!;
      await context.read<CompanyModel>().getMyCompany(user.companyId);
      if(user.isAdmin()){
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>AdminHomePage()));
      }else{
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>EmployeeHomePage()));
      }
    }else{
      Tools.showErrorMessage(context, result);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isShowKeyBoard = MediaQuery.of(context).viewInsets.bottom != 0;
    double imageSize = isShowKeyBoard?50:120;
    double width = MediaQuery.of(context).size.width;
    double borderRadius = 16.0;
    double iconSize = 16.0;
    TextStyle _style = TextStyle(fontWeight: FontWeight.w500, fontSize: 16);
    final shadow = BoxShadow(
      color: Colors.black.withOpacity(0.3),
      spreadRadius: 1,
      blurRadius: 1,
      offset: Offset(0, 0),
    );
    String lang = context.watch<UserModel>().locale;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          PopupMenuButton(
            itemBuilder: (_)=><PopupMenuItem<String>>[
              PopupMenuItem<String>(
                  child: Text('English'),
                  value: 'en'
              ),
              PopupMenuItem<String>(
                  child: Text('Spanish'),
                  value: 'es'
              ),
              PopupMenuItem<String>(
                  child: Text('French'),
                  value: 'fr'
              ),
            ],
            padding: EdgeInsets.zero,
            onSelected: (l){
              context.read<UserModel>().changeAppLanguage(l.toString());
            },
            child: Container(
              child: Text(lang.toUpperCase(),style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black87),),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              padding: EdgeInsets.all(8),
              margin: EdgeInsets.only(right: 8),
            ),
          ),
        ],
      ),
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
                  child: GestureDetector(
                    onLongPress: (){
                      context.read<AppModel>().switchDebug();
                    },
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
              ),
              if(!isShowKeyBoard)
                Column(
                  children: [
                    Text("Welcome to Facepunch",style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold),),
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
                height: MediaQuery.of(context).size.height*0.6-kBottomNavigationBarHeight,
                child: TabBarView(
                  children: [
                    EmployeeLogin(),
                    StartFacePunch(),
                    AdminSignIn(onLogin),
                  ],
                  controller: _tabController,
                  physics: NeverScrollableScrollPhysics(),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: kBottomNavigationBarHeight+10,
        color: Colors.white,
        alignment: Alignment.topCenter,
        child: TabBar(
          controller: _tabController,
          onTap: (i){
            setState(() { _pageIndex = i;});
          },
          indicatorPadding: EdgeInsets.zero,
          labelPadding: EdgeInsets.zero,
          tabs: [
            Container(
              width: width/3-4,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(borderRadius)),
                  color: _pageIndex == EMPLOYEE_SIGN_IN?Color(primaryColor):Colors.white.withOpacity(0.8),
                  boxShadow: [shadow]
              ),
              child: Column(
                children: [
                  Icon(Icons.keyboard_arrow_up,size: iconSize,),
                  Text(S.of(context).employeeSignIn.replaceFirst(' ', '\n'),style: _style,textAlign: TextAlign.center,)
                ],
              ),
            ),
            Container(
              width: width/3-4,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(borderRadius)),
                  color: _pageIndex == FACE_PUNCH?Color(primaryColor):Colors.white.withOpacity(0.8),
                  boxShadow: [
                    shadow,
                  ]
              ),
              child: Column(
                children: [
                  Icon(Icons.keyboard_arrow_up, size: iconSize,),
                  Text("Face\nPunch", style: _style, textAlign: TextAlign.center,)
                ],
              ),
            ),
            Container(
              width: width/3-4,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(borderRadius)),
                  color: _pageIndex == ADMIN_SIGN_IN?Color(primaryColor):Colors.white.withOpacity(0.8),
                  boxShadow: [shadow]
              ),
              child: Column(
                children: [
                  Icon(Icons.keyboard_arrow_up,size: iconSize,),
                  Text(S.of(context).adminSignIn.replaceFirst(' ', '\n'),style: _style,textAlign: TextAlign.center,)
                ],
              ),
            )
          ],
        ),
      ),
      backgroundColor: Color(primaryColor),
      extendBodyBehindAppBar: true,
    );
  }
}