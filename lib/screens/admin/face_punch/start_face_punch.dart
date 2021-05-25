import 'package:facepunch/lang/l10n.dart';
import 'face_punch.dart';
import '../../../models/app_const.dart';
import 'package:flutter/material.dart';

class StartFacePunch extends StatefulWidget {
  final Function showMessage;

  StartFacePunch({this.showMessage});

  @override
  _StartFacePunchState createState() => _StartFacePunchState();
}

class _StartFacePunchState extends State<StartFacePunch> {

  @override
  Widget build(BuildContext context) {
    double size = MediaQuery.of(context).size.width*0.7;
    return Container(
      width: size,
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Text(S.of(context).facePunch,style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
          SizedBox(height: 10,),
          Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset("assets/images/overlay.png",width: size,),
                  Image.asset("assets/images/person.png",width: size,),
                ],
              )
          ),
          SizedBox(height: 10,),
          ButtonTheme(
            minWidth: size,
            height: 40,
            splashColor: Color(primaryColor),
            child: RaisedButton(
              onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>FacePunchScreen()));
              },
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              color: Colors.black87,
              child: Text(S.of(context).startFacePunch.toUpperCase(),style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Colors.white),),
            ),
          ),
        ],
      ),
    );
  }

}