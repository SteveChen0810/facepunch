import 'package:facepunch/lang/l10n.dart';
import 'package:facepunch/models/app_const.dart';
import 'package:facepunch/models/user_model.dart';
import 'package:facepunch/screens/about_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EmployeeSetting extends StatefulWidget {

  @override
  _EmployeeSettingState createState() => _EmployeeSettingState();
}

class _EmployeeSettingState extends State<EmployeeSetting> {

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserModel>().user;
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top+20,
        left: 8,
        right: 8,
        bottom: 8
      ),
      color: Color(primaryColor),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Card(
              child: InkWell(
                onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>AboutPage())),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Icon(Icons.info,color: Colors.black87,size: 35,),
                      SizedBox(width: 8,),
                      Text(S.of(context).aboutApp,style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),)
                    ],
                  ),
                ),
              ),
            ),
            Card(
              child: Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(S.of(context).profile,style: TextStyle(fontWeight: FontWeight.bold),),
                    TextField(
                      decoration: InputDecoration(
                        border: UnderlineInputBorder(),
                        enabledBorder: UnderlineInputBorder(),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black87)),
                        suffixIcon: Icon(Icons.person,color: Colors.black87,),
                        isDense: true,
                        labelText: S.of(context).firstName,
                        labelStyle: TextStyle(color: Colors.grey,fontSize: 18),
                        suffixIconConstraints: BoxConstraints(maxHeight: 20),
                        contentPadding: EdgeInsets.zero,
                      ),
                      readOnly: true,
                      maxLines: 1,
                      controller: TextEditingController(text: user.firstName),
                    ),
                    SizedBox(height: 4,),
                    TextField(
                      decoration: InputDecoration(
                        border: UnderlineInputBorder(),
                        enabledBorder: UnderlineInputBorder(),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black87)),
                        suffixIcon: Icon(Icons.person,color: Colors.black87,),
                        isDense: true,
                        labelText: S.of(context).lastName,
                        labelStyle: TextStyle(color: Colors.grey,fontSize: 18),
                        suffixIconConstraints: BoxConstraints(maxHeight: 20),
                        contentPadding: EdgeInsets.zero,
                      ),
                      readOnly: true,
                      maxLines: 1,
                      controller: TextEditingController(text: user.lastName),
                    ),
                    SizedBox(height: 4,),
                    TextField(
                      decoration: InputDecoration(
                        border: UnderlineInputBorder(),
                        enabledBorder: UnderlineInputBorder(),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black87)),
                        suffixIcon: Icon(Icons.mail,color: Colors.black87,),
                        isDense: true,
                        labelText: S.of(context).email,
                        labelStyle: TextStyle(color: Colors.grey,fontSize: 18),
                        suffixIconConstraints: BoxConstraints(maxHeight: 20),
                        contentPadding: EdgeInsets.zero,
                      ),
                      maxLines: 1,
                      readOnly: true,
                      controller: TextEditingController(text: user.email),
                    ),
                    SizedBox(height: 30,),
                    TextField(
                      decoration: InputDecoration(
                        border: UnderlineInputBorder(),
                        enabledBorder: UnderlineInputBorder(),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black87)),
                        suffixIcon: Icon(Icons.lock,color: Colors.black87,),
                        isDense: true,
                        labelText: S.of(context).passwordPin,
                        labelStyle: TextStyle(color: Colors.grey,fontSize: 18),
                        suffixIconConstraints: BoxConstraints(maxHeight: 20),
                        contentPadding: EdgeInsets.zero,
                      ),
                      readOnly: true,
                      maxLines: 1,
                      controller: TextEditingController(text: user.pin),
                    ),
                    SizedBox(height: 4,),
                    TextField(
                      decoration: InputDecoration(
                        border: UnderlineInputBorder(),
                        enabledBorder: UnderlineInputBorder(),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black87)),
                        isDense: true,
                        labelText: "${S.of(context).employee}#",
                        labelStyle: TextStyle(color: Colors.grey,fontSize: 18),
                        contentPadding: EdgeInsets.zero,
                      ),
                      readOnly: true,
                      maxLines: 1,
                      controller: TextEditingController(text: user.employeeCode),
                    ),
                    SizedBox(height: 4,),
                    TextField(
                      decoration: InputDecoration(
                        border: UnderlineInputBorder(),
                        enabledBorder: UnderlineInputBorder(),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black87)),
                        isDense: true,
                        labelText: S.of(context).employeeFunction,
                        labelStyle: TextStyle(color: Colors.grey,fontSize: 18),
                        contentPadding: EdgeInsets.zero,
                      ),
                      readOnly: true,
                      maxLines: 1,
                      controller: TextEditingController(text: user.function),
                    ),
                    SizedBox(height: 4,),
                    TextField(
                      decoration: InputDecoration(
                        border: UnderlineInputBorder(),
                        enabledBorder: UnderlineInputBorder(),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black87)),
                        isDense: true,
                        labelText: S.of(context).startDate,
                        labelStyle: TextStyle(color: Colors.grey,fontSize: 18),
                        contentPadding: EdgeInsets.zero,
                      ),
                      readOnly: true,
                      maxLines: 1,
                      controller: TextEditingController(text: user.start),
                    ),
                    SizedBox(height: 4,),
                    TextField(
                      decoration: InputDecoration(
                        border: UnderlineInputBorder(),
                        enabledBorder: UnderlineInputBorder(),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black87)),
                        isDense: true,
                        labelText: S.of(context).salary,
                        labelStyle: TextStyle(color: Colors.grey,fontSize: 18),
                        contentPadding: EdgeInsets.zero,
                      ),
                      readOnly: true,
                      maxLines: 1,
                      controller: TextEditingController(text: "${user.salary} \$/h"),
                    ),
                    SizedBox(height: 4,),
                    TextField(
                      decoration: InputDecoration(
                        border: UnderlineInputBorder(),
                        enabledBorder: UnderlineInputBorder(),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black87)),
                        isDense: true,
                        labelText: S.of(context).birthday,
                        labelStyle: TextStyle(color: Colors.grey,fontSize: 18),
                        contentPadding: EdgeInsets.zero,
                      ),
                      readOnly: true,
                      maxLines: 1,
                      controller: TextEditingController(text: user.birthday),
                    ),
                    SizedBox(height: 4,),
                    TextField(
                      decoration: InputDecoration(
                        border: UnderlineInputBorder(),
                        enabledBorder: UnderlineInputBorder(),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black87)),
                        isDense: true,
                        labelText: S.of(context).language,
                        labelStyle: TextStyle(color: Colors.grey,fontSize: 18),
                        contentPadding: EdgeInsets.zero,
                      ),
                      readOnly: true,
                      maxLines: 1,
                      controller: TextEditingController(text: user.language),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20,bottom: 5),
                      child: Text(S.of(context).address,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),
                    ),
                    TextField(
                      decoration: InputDecoration(
                        border: UnderlineInputBorder(),
                        enabledBorder: UnderlineInputBorder(),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black87)),
                        isDense: true,
                        labelText: S.of(context).streetAddress,
                        labelStyle: TextStyle(color: Colors.grey,fontSize: 18),
                        contentPadding: EdgeInsets.zero,
                      ),
                      maxLines: 1,
                      readOnly: true,
                      controller: TextEditingController(text: user.address1),
                    ),
                    SizedBox(height: 4,),
                    TextField(
                      decoration: InputDecoration(
                        border: UnderlineInputBorder(),
                        enabledBorder: UnderlineInputBorder(),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black87)),
                        isDense: true,
                        labelText: S.of(context).aptSuiteBuilding,
                        labelStyle: TextStyle(color: Colors.grey,fontSize: 18),
                        contentPadding: EdgeInsets.zero,
                      ),
                      readOnly: true,
                      maxLines: 1,
                      controller: TextEditingController(text: user.address2??" "),
                    ),
                    SizedBox(height: 4,),
                    Row(
                      children: [
                        Flexible(child: TextField(
                          decoration: InputDecoration(
                            border: UnderlineInputBorder(),
                            enabledBorder: UnderlineInputBorder(),
                            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black87)),
                            isDense: true,
                            labelText: S.of(context).country,
                            labelStyle: TextStyle(color: Colors.grey,fontSize: 18),
                            contentPadding: EdgeInsets.zero,
                          ),
                          readOnly: true,
                          maxLines: 1,
                          controller: TextEditingController(text: user.country),
                        ),),
                        Flexible(child: TextField(
                          decoration: InputDecoration(
                            border: UnderlineInputBorder(),
                            enabledBorder: UnderlineInputBorder(),
                            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black87)),
                            isDense: true,
                            labelText: S.of(context).state,
                            labelStyle: TextStyle(color: Colors.grey,fontSize: 18),
                            contentPadding: EdgeInsets.zero,
                          ),
                          readOnly: true,
                          maxLines: 1,
                          controller: TextEditingController(text: user.state),
                        ),),
                      ],
                    ),
                    SizedBox(height: 4,),
                    TextField(
                      decoration: InputDecoration(
                        border: UnderlineInputBorder(),
                        enabledBorder: UnderlineInputBorder(),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black87)),
                        isDense: true,
                        labelText: S.of(context).city,
                        labelStyle: TextStyle(color: Colors.grey,fontSize: 18),
                        contentPadding: EdgeInsets.zero,
                      ),
                      readOnly: true,
                      maxLines: 1,
                      controller: TextEditingController(text: user.city),
                    ),
                    SizedBox(height: 4,),
                    TextField(
                      decoration: InputDecoration(
                        border: UnderlineInputBorder(),
                        enabledBorder: UnderlineInputBorder(),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black87)),
                        isDense: true,
                        labelText: S.of(context).postalCode,
                        labelStyle: TextStyle(color: Colors.grey,fontSize: 18),
                        contentPadding: EdgeInsets.zero,
                      ),
                      readOnly: true,
                      maxLines: 1,
                      controller: TextEditingController(text: user.postalCode),
                    ),
                    SizedBox(height: 4,),
                    TextField(
                      decoration: InputDecoration(
                        border: UnderlineInputBorder(),
                        enabledBorder: UnderlineInputBorder(),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black87)),
                        isDense: true,
                        labelText: S.of(context).phoneNumber,
                        labelStyle: TextStyle(color: Colors.grey,fontSize: 18),
                        contentPadding: EdgeInsets.zero,
                      ),
                      readOnly: true,
                      maxLines: 1,
                      controller: TextEditingController(text: user.phone??' '),
                    ),
                    SizedBox(height: 4,),
                    TextField(
                      decoration: InputDecoration(
                        border: UnderlineInputBorder(),
                        enabledBorder: UnderlineInputBorder(),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black87)),
                        isDense: true,
                        labelText: "NFC",
                        labelStyle: TextStyle(color: Colors.grey,fontSize: 18),
                        contentPadding: EdgeInsets.zero,
                      ),
                      readOnly: true,
                      maxLines: 1,
                      controller: TextEditingController(text: user.nfc??' '),
                    ),
                    SizedBox(height: 4,),
                    TextField(
                      decoration: InputDecoration(
                        border: UnderlineInputBorder(),
                        enabledBorder: UnderlineInputBorder(),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black87)),
                        isDense: true,
                        labelText: "WhatsApp",
                        labelStyle: TextStyle(color: Colors.grey,fontSize: 18),
                        contentPadding: EdgeInsets.zero,
                      ),
                      readOnly: true,
                      maxLines: 1,
                      controller: TextEditingController(text: user.whatsApp??' '),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}