import 'package:facepunch/lang/l10n.dart';

import '../../../models/app_const.dart';
import '../../../models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_text_field/pin_code_text_field.dart';
import 'package:provider/provider.dart';

class EmailVerifyWidget extends StatefulWidget {
  final Function showMessage;
  final Function next;
  final bool hideWelcome;
  EmailVerifyWidget({this.showMessage,this.next,this.hideWelcome, Key key}):super(key: key);

  @override
  _EmailVerifyState createState() => _EmailVerifyState();
}

class _EmailVerifyState extends State<EmailVerifyWidget> {

  TextEditingController _pinController = TextEditingController(text: "");
  bool hasError = false;
  bool isLoading = false;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  verifyEmailWithNumber()async{
    try{
      if(!isLoading){
        if(_pinController.text.length==6){
          setState(() {isLoading = true;});
          String result = await context.read<UserModel>().verifyEmailAddress(_pinController.text);
          setState(() {isLoading = false;});
          if(result!=null){
            widget.showMessage(result);
          }else{
            widget.next();
          }
        }else{
          widget.showMessage(S.of(context).theNumberMustBe6Digits);
        }
      }
    }catch(e){
      print("[EmailVerifyScreen.verifyEmailWithNumber] $e");
    }
  }

  sendVerifyAgain()async{
    try{
      if(!isLoading){
        setState(() {isLoading = true;});
        String result = await context.read<UserModel>().sendVerifyEmailAgain();
        setState(() {isLoading = false;});
        if(result!=null){
          widget.showMessage(result);
        }
      }
    }catch(e){
      print("[EmailVerifyScreen.verifyEmailWithNumber] $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 30,),
        Image.asset(
          "assets/images/logo.png",
          width: 100,
          height: 100,
        ),
        if(widget.hideWelcome)
          Column(
            children: [
              SizedBox(height: 20,),
              Text(
                S.of(context).thankYouForRegisteringWithUs,
                style: TextStyle(color: Colors.black87,fontSize: 20,fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20,),
              Text(
                S.of(context).pleaseEnterThe6DigitsConfirmationNumberSentToYouByEmail,
                style: TextStyle(color: Colors.black87,fontSize: 20,fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20,),
            ],
          ),
        SizedBox(height: 10,),
        PinCodeTextField(
          autofocus: true,
          controller: _pinController,
          hideCharacter: false,
          highlight: true,
          highlightColor: Colors.green,
          defaultBorderColor: Colors.grey,
          hasTextBorderColor: Colors.black87,
          maxLength: 6,
          hasError: hasError,
          onTextChanged: (text) {
            setState(() {hasError = false;});
          },
          onDone: (text) {
            verifyEmailWithNumber();
          },
          pinBoxWidth: 40,
          pinBoxHeight: 50,
          hasUnderline: true,
          wrapAlignment: WrapAlignment.spaceAround,
          pinBoxDecoration: ProvidedPinBoxDecoration.defaultPinBoxDecoration,
          pinTextStyle: TextStyle(fontSize: 22.0,color: Colors.black87),
          pinTextAnimatedSwitcherTransition: ProvidedPinBoxTextAnimation.scalingTransition,
          pinTextAnimatedSwitcherDuration: Duration(milliseconds: 200),
          keyboardType: TextInputType.number,
        ),
        SizedBox(height: 20,),
        ButtonTheme(
          minWidth: MediaQuery.of(context).size.width-60,
          padding: EdgeInsets.all(8),
          splashColor: Color(primaryColor),
          child: RaisedButton(
            child: isLoading?SizedBox(
                height: 28,
                width: 28,
                child: CircularProgressIndicator(backgroundColor: Colors.white,)
            ):Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text(S.of(context).next,style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color: Colors.white),),
            ),
            onPressed: verifyEmailWithNumber,
            color: Colors.black87,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
        ),
        SizedBox(height: 20,),
        InkWell(
          onTap: sendVerifyAgain,
          child: Text(S.of(context).didNotGetAVerificationCode, style: TextStyle(color: Colors.red,decoration: TextDecoration.underline),),
        )
      ],
    );
  }
}