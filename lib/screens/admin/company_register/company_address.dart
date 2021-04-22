import '../../../models/app_const.dart';
import '../../../models/company_model.dart';
import '../../../widgets/address_picker/country_state_city_picker.dart';
import '../../../models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CompanyAddressWidget extends StatefulWidget {
  final Function showMessage;
  final Function next;
  CompanyAddressWidget({this.showMessage,this.next, Key key}):super(key: key);

  @override
  _CompanyAddressState createState() => _CompanyAddressState();
}

class _CompanyAddressState extends State<CompanyAddressWidget> {

  TextEditingController _name = TextEditingController();
  TextEditingController _address1 = TextEditingController();
  TextEditingController _address2 = TextEditingController();
  TextEditingController _postalCode = TextEditingController();
  TextEditingController _phone = TextEditingController();
  TextEditingController _website = TextEditingController();
  String country, state, city;
  String _nameError, _addressError, _postalCodeError;


  bool validator(){
    _nameError = null; _addressError = null; _postalCodeError = null;
    if(_name.text.isEmpty){
      setState(() {_nameError = "Company name is required.";});
      return false;
    }
    if(_address1.text.isEmpty){
      setState(() {_addressError = "Company address is required.";});
      return false;
    }
    if(country==null){
      widget.showMessage("Country is required.");
      return false;
    }
    if(state==null){
      widget.showMessage("State is required.");
      return false;
    }
    if(city==null){
      widget.showMessage("City is required.");
      return false;
    }
    if(_postalCode.text.isEmpty){
      setState(() {_postalCodeError = "Postal Code is required.";});
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 20,left: 20,right: 20,bottom: 10),
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 10,),
            Image.asset(
              "assets/images/logo.png",
              width: 100,
              height: 100,
            ),
            SizedBox(height: 10,),
            Text(
              "Please enter your Company information",
              style: TextStyle(color: Colors.black87,fontSize: 20,fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10,),
            TextField(
              decoration: InputDecoration(
                  border: UnderlineInputBorder(),
                  enabledBorder: UnderlineInputBorder(),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black87)),
                  hintText: "Company Name",
                  isDense: true,
                  errorText: _nameError,
                alignLabelWithHint: true,
              ),
              controller: _name,
              keyboardType: TextInputType.text,
              textAlign: TextAlign.center,
              textCapitalization: TextCapitalization.words,
              style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10,),
            TextField(
              decoration: InputDecoration(
                border: UnderlineInputBorder(),
                enabledBorder: UnderlineInputBorder(),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black)),
                hintText: "Street Address",
                isDense: true,
                errorText: _addressError,
                alignLabelWithHint: true,
              ),
              controller: _address1,
              keyboardType: TextInputType.streetAddress,
              textCapitalization: TextCapitalization.words,
            ),
            TextField(
              decoration: InputDecoration(
                border: UnderlineInputBorder(),
                enabledBorder: UnderlineInputBorder(),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black)),
                hintText: "Apt, Suite, Building (optional)",
                errorText: null,
                isDense: true,
              ),
              controller: _address2,
              keyboardType: TextInputType.streetAddress,
              textCapitalization: TextCapitalization.words,
            ),
            SelectState(
              onCountryChanged: (value) {
                FocusScope.of(context).requestFocus(FocusNode());
                country = value;
                print(value);
              },
              onStateChanged:(value) {
                FocusScope.of(context).requestFocus(FocusNode());
                state = value;
              },
              onCityChanged:(value) {
                FocusScope.of(context).requestFocus(FocusNode());
                city = value;
              },
            ),
            TextField(
              decoration: InputDecoration(
                border: UnderlineInputBorder(),
                enabledBorder: UnderlineInputBorder(),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black)),
                hintText: "Postal Code",
                errorText: _postalCodeError,
                isDense: true,
              ),
              controller: _postalCode,
              keyboardType: TextInputType.text,
              textCapitalization: TextCapitalization.words,
              onChanged: (v){
                _postalCode.value = _postalCode.value.copyWith(text: v.toUpperCase());
              },
            ),
            TextField(
              decoration: InputDecoration(
                border: UnderlineInputBorder(),
                enabledBorder: UnderlineInputBorder(),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black)),
                hintText: "Phone Number (optional)",
                isDense: true,
              ),
              controller: _phone,
              keyboardType: TextInputType.phone,
              textCapitalization: TextCapitalization.words,
            ),
            TextField(
              decoration: InputDecoration(
                border: UnderlineInputBorder(),
                enabledBorder: UnderlineInputBorder(),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black)),
                hintText: "Website (optional)",
                isDense: true,
              ),
              controller: _website,
              keyboardType: TextInputType.url,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.done,
            ),
            SizedBox(height: 20,),
            ButtonTheme(
              minWidth: MediaQuery.of(context).size.width-60,
              padding: EdgeInsets.all(8),
              splashColor: Color(primaryColor),
              child: RaisedButton(
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text("Next",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color: Colors.white),),
                ),
                onPressed: (){
                  FocusScope.of(context).requestFocus(FocusNode());
                  if(validator()){
                    context.read<CompanyModel>().setAddressMyCompany(
                      name: _name.text,
                      address1: _address1.text,
                      address2: _address2.text,
                      adminId: context.read<UserModel>().user.id,
                      city: city,
                      country: country,
                      phone: _phone.text,
                      postalCode: _postalCode.text,
                      state: state,
                      website: _website.text,
                      pin: context.read<UserModel>().user.pin,
                    );
                    FocusScope.of(context).requestFocus(FocusNode());
                    Future.delayed(Duration(milliseconds: 200)).whenComplete(() => widget.next());
                  }
               },
                color: Colors.black87,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
            ),
            SizedBox(height: 10,),
          ],
        ),
      ),
    );
  }
}