import 'package:facepunch/models/notification.dart';
import '../models/app_const.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_text_field/pin_code_text_field.dart';
import 'calendar_strip/date-utils.dart';
import 'package:provider/provider.dart';

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
              title: Text("Please Enter PIN Code.",style: TextStyle(fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
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
                    Text("PIN Code is not correct.",style: TextStyle(color: Colors.red),),
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
                      child: Text("CLOSE",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Colors.white),),
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


showRevisionNotificationDialog(AppNotification notification, BuildContext context, Function showMessage){
  try{
    bool dismissible = true;
    showDialog(
      context: context,
      builder:(_)=> StatefulBuilder(
        builder: (BuildContext _context,StateSetter setState){
          return WillPopScope(
            onWillPop: ()async{
              return dismissible;
            },
            child: AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
              contentPadding: EdgeInsets.all(0),
              title: Text("Hour Revision Request",style: TextStyle(fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
              content: Container(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("${PunchDateUtils.getDateString(DateTime.parse(notification.revision.createdAt))}",style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                    SizedBox(height: 8,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Employee Name"),
                        SizedBox(width: 8,),
                        Flexible(
                            child: Text("${notification.revision.user.firstName} ${notification.revision.user.lastName}")
                        ),
                      ],
                    ),
                    SizedBox(height: 8,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Incorrect Punch ${notification.revision.punch.punch} Time"),
                        Text("${PunchDateUtils.getTimeString(DateTime.parse(notification.revision.oldValue))}"),
                      ],
                    ),
                    SizedBox(height: 8,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Correct Punch ${notification.revision.punch.punch} Time"),
                        Text("${PunchDateUtils.getTimeString(DateTime.parse(notification.revision.newValue))}"),
                      ],
                    ),
                    SizedBox(height: 8,),
                    dismissible?Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        FlatButton(
                          onPressed: ()async{
                            setState((){dismissible=false;});
                            String result = await context.read<NotificationModel>().acceptRevision(notification.revision);
                            if(result!=null)showMessage(result);
                            Navigator.pop(_context);
                          },
                          child: Text("Accept",style: TextStyle(color: Color(primaryColor)),),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        FlatButton(
                          onPressed: ()async{
                            setState((){dismissible=false;});
                            String result = await context.read<NotificationModel>().declineRevision(notification.revision);
                            if(result!=null)showMessage(result);
                            Navigator.pop(_context);
                          },
                          child: Text("Decline",style: TextStyle(color: Colors.red),),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ],
                    ):Center(child: CircularProgressIndicator(backgroundColor: Color(primaryColor),))
                  ],
                ),
              ),
            ),
          );
        }
      ),
    );
  }catch(e){
    print("[showRevisionNotificationDialog] $e");
  }
}