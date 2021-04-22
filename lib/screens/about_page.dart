import 'package:facepunch/models/app_const.dart';
import 'package:flutter/material.dart';

class AboutPage extends StatefulWidget {

  @override
  _AboutScreenState createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("About APP"),
        centerTitle: true,
        backgroundColor: Color(primaryColor),
      ),
      body: Container(
        alignment: Alignment.center,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20,),
            Text("App Version: 1.0.0",style: TextStyle(color: Colors.white,fontSize: 20,fontWeight: FontWeight.bold),),
            Text("-First Version of APP",style: TextStyle(color: Colors.white,fontSize: 16),),
            SizedBox(height: 20,),
            Text("Created By Philippe Vernier & Li Qiang",style: TextStyle(color: Colors.white,fontSize: 18,fontWeight: FontWeight.bold),),
            SizedBox(height: 20,),
          ],
        ),
      ),
      backgroundColor: Color(primaryColor),
    );
  }
}