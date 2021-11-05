import 'dart:io';

import 'package:facepunch/lang/l10n.dart';
import 'package:facepunch/screens/home_page.dart';
import 'package:facepunch/widgets/dialogs.dart';
import '../models/company_model.dart';
import '../models/user_model.dart';
import '../screens/admin/admin_home.dart';
import '../screens/employee/employee_home.dart';
import '../models/app_const.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {


  @override
  void initState() {
    super.initState();
    _init();
  }

  _init()async{
    try{
      final appVersions = await context.read<UserModel>().getAppVersions();
      if(appVersions != null){
        if(appVersions[Platform.isAndroid?'android':'ios'] > AppConst.currentVersion){
          await checkAppVersionDialog(context, appVersions['force']);
        }
      }
      User user  = await context.read<UserModel>().getUserFromLocal();
      if(user==null){
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>HomePage()));
      }else{
        bool result = await context.read<CompanyModel>().getMyCompany(user.companyId);
        if(result){
          if(user.role=="admin"){
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>AdminHomePage()));
          }else{
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>EmployeeHomePage()));
          }
        }else{
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>HomePage()));
        }
      }
    }catch(e){
      print("[SplashScreen._init]$e");
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>HomePage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: WillPopScope(
        onWillPop: ()async{
          return false;
        },
        child: Container(
          child: Stack(
            children: [
              Positioned(
                top: height/4,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset("assets/images/logo.png",width: width/3,),
                    SizedBox(width: 10,),
                    Text("FACE\nPUNCH",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 50),)
                  ],
                ),
              ),
              Positioned(
                bottom: 25,
                left: 0,
                right: 0,
                child: Center(
                    child: Text(S.of(context).timeSheetSystemForEmployee,style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),)
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