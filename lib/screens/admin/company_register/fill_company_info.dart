import 'package:carousel_slider/carousel_slider.dart';
import 'package:facepunch/lang/l10n.dart';
import '../../admin/admin_home.dart';
import '../../../models/app_const.dart';
import '../../../models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'company_address.dart';
import 'email_verify.dart';
import 'company_plan.dart';

class FillCompanyInfo extends StatefulWidget {

  @override
  _FillCompanyInfoState createState() => _FillCompanyInfoState();
}

class _FillCompanyInfoState extends State<FillCompanyInfo> {

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final CarouselController _carouselController = CarouselController();
  int index = 0;
  User user;
  bool hasError = false;
  bool isLoading = false;


  @override
  void initState() {
    super.initState();
    user = context.read<UserModel>().user;
    index = user.emailVerifyNumber==null?1:0;
  }


  showMessage(String message){
    _scaffoldKey.currentState.hideCurrentSnackBar();
    _scaffoldKey.currentState.showSnackBar(
        SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
            action: SnackBarAction(onPressed: (){},label: S.of(context).close,textColor: Colors.white,),
        )
    );
  }

  nextPage(){
    _carouselController.nextPage(curve: Curves.easeInOut,duration: Duration(milliseconds: 500));
  }

  goToHome(){
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>AdminHomePage()));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: ()async{
          _carouselController.previousPage();
          return false;
        },
      child: Scaffold(
        key: _scaffoldKey,
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey,),
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  color: Colors.white
              ),
              margin: EdgeInsets.only(top: 80,left: 8,right: 8,bottom: 8),
              child: CarouselSlider(
                  carouselController: _carouselController,
                  items: [
                    EmailVerifyWidget(next: nextPage,showMessage: showMessage,hideWelcome: MediaQuery.of(context).viewInsets.bottom==0,),
                    CompanyAddressWidget(next: nextPage,showMessage: showMessage),
                    CompanyPlanWidget(next: nextPage,showMessage: showMessage,done: goToHome,),
                  ],
                  options: CarouselOptions(
                      height: MediaQuery.of(context).size.height,
                      viewportFraction: 1,
                      initialPage: user.emailVerifyNumber==null?1:0,
                      reverse: false,
                      autoPlay: false,
                      autoPlayInterval: Duration(seconds: 3),
                      autoPlayAnimationDuration: Duration(milliseconds: 800),
                      autoPlayCurve: Curves.fastOutSlowIn,
                      enlargeCenterPage: true,
                      pageSnapping: true,
                      enableInfiniteScroll: false,
                      onPageChanged: (i,r){
                        setState(() {index = i;});
                      },
                      disableCenter: false,
                      scrollDirection: Axis.horizontal,
                      scrollPhysics: NeverScrollableScrollPhysics()
                  )
              ),
            ),
            Container(
              height: 100,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(S.of(context).registration,style: TextStyle(color: Colors.black87, fontSize: 30, fontWeight: FontWeight.bold),),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for(int i=0;i<3;i++)
                          Container(
                            height: 5,
                            width: 50,
                            margin: EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.black87),
                                color: index==i?Colors.black87:Colors.white
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Color(primaryColor),
      ),
    );
  }
}