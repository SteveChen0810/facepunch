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
                      Text("About App",style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),)
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
                    Text("Profile",style: TextStyle(fontWeight: FontWeight.bold),),
                    TextField(
                      decoration: InputDecoration(
                        border: UnderlineInputBorder(),
                        enabledBorder: UnderlineInputBorder(),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black87)),
                        suffixIcon: Icon(Icons.person,color: Colors.black87,),
                        isDense: true,
                        labelText: "First Name",
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
                        labelText: "Last Name",
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
                        labelText: "E-mail Address",
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
                        labelText: "Password (PIN)",
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
                        labelText: "Employee#",
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
                        labelText: "Employee Function",
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
                        labelText: "Starting Date",
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
                        labelText: "Salary",
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
                        labelText: "Date of Birth",
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
                        labelText: "Language",
                        labelStyle: TextStyle(color: Colors.grey,fontSize: 18),
                        contentPadding: EdgeInsets.zero,
                      ),
                      readOnly: true,
                      maxLines: 1,
                      controller: TextEditingController(text: user.language),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20,bottom: 5),
                      child: Text("Address",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),
                    ),
                    TextField(
                      decoration: InputDecoration(
                        border: UnderlineInputBorder(),
                        enabledBorder: UnderlineInputBorder(),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black87)),
                        isDense: true,
                        labelText: "Street Address",
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
                        labelText: "Apt, Suite, Building, (optional)",
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
                            labelText: "Country",
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
                            labelText: "State",
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
                        labelText: "City",
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
                        labelText: "Postal Code",
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
                        labelText: "Phone Number (optional)",
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