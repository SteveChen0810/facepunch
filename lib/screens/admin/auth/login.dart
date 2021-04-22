import 'package:facepunch/screens/employee/employee_login.dart';

import '../../../models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'recovery_password.dart';

class AdminSignIn extends StatefulWidget{

  final Function onLogin;
  AdminSignIn({this.onLogin});

  @override
  _AdminSignInState createState() => _AdminSignInState();
}

class _AdminSignInState extends State<AdminSignIn> {


  TextEditingController _email = TextEditingController();
  TextEditingController _password = TextEditingController();
  String _emailError,_passwordError;
  bool isLoading = false;
  bool isRememberMe = false;


  bool loginValidator(){
    _emailError = null; _passwordError = null;
    if(_email.text.isEmpty){
      _emailError = "Your email is required.";
      return false;
    }
    if(!_email.text.contains("@") || !_email.text.contains(".")){
      _emailError = "Email is invalid.";
      return false;
    }
    if(_password.text.isEmpty){
      _passwordError = "Password is required.";
      return false;
    }
    return true;
  }

  loginWithEmail()async{
    try{
      if(!isLoading){
        if(loginValidator()){
          setState(() {isLoading = true;});
          String result = await context.read<UserModel>().adminLogin(
            email:_email.text,
            password:_password.text,
            isRememberMe: isRememberMe
          );
          setState(() {isLoading = false;});
          widget.onLogin(result);
        }else{
          setState(() {});
        }
      }
    }catch(e){
      print("[LoginWidget.loginWithEmail] $e");
      setState(() {isLoading = false;});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Text("Admin Sign In",style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold),)),
            SizedBox(height: 20,),
            Text("E-mail",style: TextStyle(fontSize: 18,fontWeight: FontWeight.w500),),
            TextField(
              decoration: InputDecoration(
                  border: UnderlineInputBorder(),
                  enabledBorder: UnderlineInputBorder(),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black87)),
                  hintText: "Enter your mail",
                  isDense: true,
                  suffixIconConstraints: BoxConstraints(maxHeight: 20),
                  suffixIcon: Icon(Icons.email,color: Colors.black87,),
                  errorText: _emailError
              ),
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              enabled: !isLoading,
            ),
            SizedBox(height: 8,),
            Text("Password",style: TextStyle(fontSize: 18,fontWeight: FontWeight.w500),),
            TextField(
              decoration: InputDecoration(
                  border: UnderlineInputBorder(),
                  enabledBorder: UnderlineInputBorder(),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black87)),
                  hintText: "Enter your password",
                  isDense: true,
                  suffixIconConstraints: BoxConstraints(maxHeight: 20),
                  suffixIcon: Icon(Icons.lock,color: Colors.black87,),
                  errorText: _passwordError
              ),
              controller: _password,
              enabled: !isLoading,
              enableSuggestions: false,
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
              autocorrect: false,
            ),
            Row(
              children: [
                Checkbox(
                  value: isRememberMe,
                  onChanged: (v){
                    if(!isLoading)setState(() {isRememberMe = !isRememberMe;});
                  },
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                InkWell(
                    onTap: (){
                      if(!isLoading)setState(() {isRememberMe = !isRememberMe;});
                    },
                    child: Text("Remember me")
                )
              ],
            ),
            Center(
              child: InkWell(
                  onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>RecoveryPasswordScreen())),
                  child: Text("Can't login?",style: TextStyle(fontSize: 18,fontWeight: FontWeight.w500,decoration: TextDecoration.underline,),)
              ),
            ),
            SizedBox(height: 10,),
            Center(
              child: ButtonTheme(
                minWidth: MediaQuery.of(context).size.width-40,
                padding: EdgeInsets.all(8),
                child: RaisedButton(
                  child: isLoading?SizedBox(
                      height: 28,
                      width: 28,
                      child: CircularProgressIndicator(backgroundColor: Colors.white,)
                  ):Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text("LOG IN",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color: Colors.white),),
                  ),
                  onPressed: loginWithEmail,
                  color: Colors.black87,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}