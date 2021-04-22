import '../../../models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RegisterWidget extends StatefulWidget{
  final Function onLogin;
  RegisterWidget({this.onLogin});

  @override
  _RegisterWidgetState createState() => _RegisterWidgetState();
}

class _RegisterWidgetState extends State<RegisterWidget> {

  TextEditingController _email = TextEditingController();
  TextEditingController _password = TextEditingController();
  TextEditingController _fName = TextEditingController();
  TextEditingController _lName = TextEditingController();
  String _emailError,_passwordError,_fNameError,_lNameError;
  bool isLoading = false;

  bool registerValidator(){
    _emailError = null; _passwordError = null; _fNameError=null;_lNameError=null;
    if(_fName.text.isEmpty){
      _fNameError = "First Name is required.";
      return false;
    }
    if(_lName.text.isEmpty){
      _lNameError = "Last Name is required.";
      return false;
    }
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

  registerWithEmail()async{
    try{
      if(!isLoading){
        if(registerValidator()){
          setState(() {isLoading = true;});
          String result = await context.read<UserModel>().adminRegister(_email.text, _password.text,_fName.text,_lName.text);
          setState(() {isLoading = false;});
          widget.onLogin(result);
        }else{
          setState(() {});
        }
      }
    }catch(e){
      print("[LoginWidget.registerWithEmail] $e");
      setState(() {isLoading = false;});
    }
  }

  String firstToUpper(String v){
    if(v.isNotEmpty){
      return v[0].toUpperCase()+v.substring(1);
    }
    return v;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 16,right: 16,top: 16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Text("Sign up",style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold),)),
            SizedBox(height: 20,),
            Text("First name",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
            TextField(
              decoration: InputDecoration(
                  border: UnderlineInputBorder(),
                  enabledBorder: UnderlineInputBorder(),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black87)),
                  hintText: "Enter your first name",
                  suffixIcon: Icon(Icons.person,color: Colors.black87,),
                  isDense: true,
                  suffixIconConstraints: BoxConstraints(maxHeight: 20),
                  errorText: _fNameError
              ),
              enabled: !isLoading,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.name,
              maxLines: 1,
              controller: _fName,
              onChanged: (v){
                _fName.value = _fName.value.copyWith(text: firstToUpper(v));
              },
            ),
            SizedBox(height: 12,),
            Text("Last name",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
            TextField(
              decoration: InputDecoration(
                  border: UnderlineInputBorder(),
                  enabledBorder: UnderlineInputBorder(),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black87)),
                  hintText: "Enter your last name",
                  suffixIcon: Icon(Icons.person,color: Colors.black87,),
                  isDense: true,
                  suffixIconConstraints: BoxConstraints(maxHeight: 20),
                  errorText: _lNameError
              ),
              enabled: !isLoading,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.name,
              maxLines: 1,
              controller: _lName,
              onChanged: (v){
                _lName.value = _lName.value.copyWith(text: firstToUpper(v));
              },
            ),
            SizedBox(height: 12,),
            Text("E-mail",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
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
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              enabled: !isLoading,
              controller: _email,
            ),
            SizedBox(height: 12,),
            Text("Password",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
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
              enabled: !isLoading,
              textInputAction: TextInputAction.done,
              controller: _password,
              keyboardType: TextInputType.number,
              maxLength: 4,
              enableSuggestions: false,
              obscureText: true,
              autocorrect: false,
            ),
            SizedBox(height: 12,),
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
                    child: Text("REGISTER",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color: Colors.white),),
                  ),
                  onPressed: registerWithEmail,
                  color: Colors.black87,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}