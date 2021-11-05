import 'dart:io';

import 'package:facepunch/lang/l10n.dart';
import 'package:facepunch/models/notification.dart';
import '../models/app_const.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_text_field/pin_code_text_field.dart';
import 'package:url_launcher/url_launcher.dart';

Future<bool> pinCodeCheckDialog(String pin, BuildContext context)async{
  bool result = false;
  bool hasError= false;
  await showDialog(
      context: context,
      builder:(_)=> StatefulBuilder(
          builder: (BuildContext _context,StateSetter setState){
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
              contentPadding: EdgeInsets.all(0),
              title: Text(S.of(context).enterPinCode,style: TextStyle(fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 20,),
                  PinCodeTextField(
                    autofocus: true,
                    hideCharacter: true,
                    highlight: true,
                    highlightColor: Colors.green,
                    defaultBorderColor: Colors.grey,
                    hasTextBorderColor: Colors.black87,
                    maxLength: 4,
                    maskCharacter: "*",
                    hasError: hasError,
                    onTextChanged: (text) {
                      setState(() {hasError = false;});
                    },
                    onDone: (text) {
                      if(pin == text){
                        result = true;
                        Navigator.pop(context);
                      }else{
                        setState(() {hasError = true;});
                        return false;
                      }
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
                  if(hasError)
                    Text(S.of(context).pinCodeNotCorrect,style: TextStyle(color: Colors.red),),
                  SizedBox(height: 20,),
                  ButtonTheme(
                    minWidth: MediaQuery.of(context).size.width*0.6,
                    height: 40,
                    splashColor: Color(primaryColor),
                    child: RaisedButton(
                      onPressed: ()=>Navigator.pop(context),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      color: Colors.black87,
                      child: Text(S.of(context).close,style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Colors.white),),
                    ),
                  ),
                  SizedBox(height: 10,),
                ],
              ),
            );
          }
      ),
    useRootNavigator: true,
    barrierDismissible: false,
    useSafeArea: true,
  );
  return result;
}

showNotificationDialog(AppNotification notification, BuildContext context){
  try{
    showDialog(
      context: context,
      builder:(_)=> StatefulBuilder(
          builder: (BuildContext _context,StateSetter setState){
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
              contentPadding: EdgeInsets.all(0),
              title: Text(notification.type.replaceAll('_', ' ').toUpperCase(),style: TextStyle(fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
              content: Container(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(notification.body,style: TextStyle(fontSize: 16),),
                  ],
                ),
              ),
              actions: [
                FlatButton(
                  onPressed: ()async{
                    Navigator.pop(_context);
                  },
                  child: Text(S.of(context).close,style: TextStyle(color: Colors.red),),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            );
          }
      ),
    );
  }catch(e){
    print("[showRevisionNotificationDialog] $e");
  }
}

Future<bool> showLocationPermissionDialog(BuildContext context)async{
  bool allow = true;
  await showDialog(
    context: context,
    builder:(_)=> AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
      contentPadding: EdgeInsets.all(0),
      content: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('This app collects location data to enable EmployeePunch even when the app is closed or not in use.',style: TextStyle(fontSize: 18),textAlign: TextAlign.center,),
            SizedBox(height: 8,),
            Text('This app tracks locations data of this phone when your employees punch with their face on this phone.',style: TextStyle(fontSize: 14),textAlign: TextAlign.center,),
          ],
        ),
      ),
      actions: [
        FlatButton(
          onPressed: ()async{
            Navigator.pop(context);
          },
          child: Text(S.of(context).close,style: TextStyle(color: Colors.red),),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ],
    ),
  );
  return allow;
}

showWelcomeDialog({String userName, bool isPunchIn, BuildContext context})async{
  await showDialog(
    context: context,
    builder: (_context){
      Future.delayed(Duration(seconds: 3)).whenComplete((){
        try{
          Navigator.of(_context).pop();
        }catch(e){
          print(e);
        }
      });
      return Align(
        alignment: Alignment.center,
        child: AnimatedContainer(
          height: MediaQuery.of(context).size.height*0.25,
          width: MediaQuery.of(context).size.width-80,
          duration: const Duration(milliseconds: 300),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Material(
              color: isPunchIn?Colors.green:Colors.red,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(isPunchIn?S.of(context).welcome:S.of(context).bye,style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("$userName",style: TextStyle(fontSize: 25),textAlign: TextAlign.center,),
                  ),
                ],
              ),
              type: MaterialType.card,
            ),
          ),
        ),
      );
    },
  );
}

Future<bool> confirmDeleting(BuildContext context, String message)async{
  bool allow = false;
  await showDialog(
    context: context,
    builder:(_)=> AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
      contentPadding: EdgeInsets.all(0),
      content: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message,textAlign: TextAlign.center,),
            SizedBox(height: 8,),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: ()async{
            Navigator.pop(context);
          },
          child: Text(S.of(context).close,style: TextStyle(color: Colors.green),),
        ),
        TextButton(
          onPressed: ()async{
            allow = true;
            Navigator.pop(context);
          },
          child: Text(S.of(context).delete, style: TextStyle(color: Colors.red),),
        ),
      ],
    ),
  );
  return allow;
}

Future<void> checkAppVersionDialog(BuildContext context, bool isForce)async{
  await showDialog(
    context: context,
    barrierDismissible: isForce,
    builder:(_)=> AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
      contentPadding: EdgeInsets.all(0),
      content: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(S.of(context).newVersionAvailable, textAlign: TextAlign.center,),
            SizedBox(height: 8,),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: ()async{
            if(Platform.isAndroid){
              launch('https://apps.apple.com/us/app/face-punch-vision/id1556243840');
            }else{
              launch('https://apps.apple.com/us/app/face-punch-vision/id1556243840');
            }
          },
          child: Text(S.of(context).update, style: TextStyle(color: Colors.green),),
        ),
        TextButton(
          onPressed: isForce?null:()async{
            Navigator.pop(context);
          },
          child: Text(S.of(context).close, style: TextStyle(color: isForce?Colors.grey:Colors.red),),
        ),
      ],
    ),
  );
}