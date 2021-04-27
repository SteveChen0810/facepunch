import 'package:facepunch/lang/l10n.dart';
import 'package:facepunch/screens/home_page.dart';

import '../models/company_model.dart';
import '../models/user_model.dart';
import '../screens/admin/admin_home.dart';
import '../screens/employee/employee_home.dart';
import '../models/app_const.dart';
import 'package:flutter/material.dart';
import 'admin/company_register/fill_company_info.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {


  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 500)).whenComplete(()async{
      User user  = await context.read<UserModel>().getUserFromLocal();
      await context.read<CompanyModel>().getCompanies();
      if(user==null){
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>HomePage()));
      }else{
        if(user.role=="admin"){
          if(user.companyId==null){
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>FillCompanyInfo()));
          }else{
            context.read<CompanyModel>().getMyCompany(user.companyId);
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>AdminHomePage()));
          }
        }else{
          context.read<CompanyModel>().getMyCompany(user.companyId);
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>EmployeeHomePage()));
        }
      }
    });
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