import 'package:facepunch/models/app_const.dart';

import '../../../models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class RecoveryPasswordScreen extends StatefulWidget{

  @override
  _RecoveryPasswordScreenState createState() => _RecoveryPasswordScreenState();
}

class _RecoveryPasswordScreenState extends State<RecoveryPasswordScreen> {


  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController controller = TextEditingController(text: "");
  bool isLoading = false;

  recoveryPassword()async{
    try{
      FocusScope.of(context).requestFocus(FocusNode());
      if(controller.text.contains("@") & controller.text.contains(".")){
        setState(() { isLoading = true;});
        String result = await context.read<UserModel>().recoverPassword(controller.text);
        setState(() { isLoading = false;});
        if(result!=null){showMessage(result);}
      }else{
        showMessage("Email is invalid.");
      }
    }catch(e){
      print("[RecoveryPasswordScreen.recoveryPassword]");
    }
  }

  showMessage(String message){
    _scaffoldKey.currentState.hideCurrentSnackBar();
    _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          action: SnackBarAction(onPressed: (){},label: 'Close',textColor: Colors.white,),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("FACE PUNCH",style: TextStyle(color: Colors.black87,fontSize: 30,fontWeight: FontWeight.bold),),
        backgroundColor: Color(primaryColor),
        elevation: 0,
      ),
      body: Container(
          decoration: BoxDecoration(
              border: Border.all(
                color: Colors.black87,
              ),
              borderRadius: BorderRadius.all(Radius.circular(20))
          ),
          width: MediaQuery.of(context).size.width,
          margin: EdgeInsets.all(8),
          padding: EdgeInsets.all(8),
          child: Column(
            children: [
              if(MediaQuery.of(context).viewInsets.bottom == 0)
                SizedBox(height: 20,),
              Image.asset(
                "assets/images/logo.png",
                width: 150,
                height: 150,
              ),
              if(MediaQuery.of(context).viewInsets.bottom == 0)
                Column(
                  children: [
                    SizedBox(height: 20,),
                    Text(
                      "Enter your email address.",
                      style: TextStyle(color: Colors.black87,fontSize: 20),
                    ),
                    SizedBox(height: 20,),
                    Text(
                      "We will send new password to your email.",
                      style: TextStyle(color: Colors.black87,fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20,),
                  ],
                ),
              SizedBox(height: 8,),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                    isDense: true,
                    contentPadding: EdgeInsets.all(8),
                  ),
                  style: TextStyle(color: Colors.black,fontSize: 20),
                  keyboardType: TextInputType.emailAddress,
                  controller: controller,
                ),
              ),
              SizedBox(height: 20,),
              ButtonTheme(
                minWidth: MediaQuery.of(context).size.width-60,
                padding: EdgeInsets.all(8),
                child: RaisedButton(
                  child: isLoading?SizedBox(
                      height: 28,
                      width: 28,
                      child: CircularProgressIndicator(backgroundColor: Colors.white,)
                  ):Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text("DONE",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color: Colors.white),),
                  ),
                  onPressed: recoveryPassword,
                  color: Colors.red,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
              ),
              SizedBox(height: 10,),
            ],
          )
      ),
      backgroundColor: Color(primaryColor),
    );
  }
}