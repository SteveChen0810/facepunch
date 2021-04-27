import 'dart:async';

import 'package:facepunch/lang/l10n.dart';
import 'package:facepunch/models/app_const.dart';
import 'package:facepunch/models/company_model.dart';
import 'package:facepunch/models/user_model.dart';
import 'package:facepunch/screens/about_page.dart';
import 'package:facepunch/widgets/address_picker/country_state_city_picker.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:provider/provider.dart';

class AdminSetting extends StatefulWidget {

  @override
  _AdminSettingState createState() => _AdminSettingState();
}

class _AdminSettingState extends State<AdminSetting> {

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController _email;
  TextEditingController _newPassword = TextEditingController();
  TextEditingController _oldPassword = TextEditingController();
  TextEditingController _fName;
  TextEditingController _lName;
  String _emailError,_passwordError,_fNameError,_lNameError;

  Company myCompany;
  TextEditingController _name;
  TextEditingController _address1;
  TextEditingController _address2;
  TextEditingController _postalCode;
  TextEditingController _phone;
  TextEditingController _website;
  String country, state, city;
  int plan;
  String _nameError, _addressError, _postalCodeError;

  bool isProfileUpdating = false;
  bool isCompanyUpdating = false;
  bool isRevisionNotificationUpdating = false;
  bool isPunchNotificationUpdating = false;

  final InAppPurchaseConnection _connection = InAppPurchaseConnection.instance;
  StreamSubscription<List<PurchaseDetails>> _subscription;
  List<ProductDetails> _products = [];
  ProductDetails selectedProduct;

  @override
  void initState() {
    super.initState();
    User user = context.read<UserModel>().user;
    _email = TextEditingController(text: user.email);
    _fName = TextEditingController(text: user.firstName);
    _lName = TextEditingController(text: user.lastName);

    myCompany = context.read<CompanyModel>().myCompany;
    _name = TextEditingController(text: myCompany.name);
    _address1 = TextEditingController(text: myCompany.address1);
    _address2 = TextEditingController(text: myCompany.address2);
    _postalCode = TextEditingController(text: myCompany.postalCode);
    _phone = TextEditingController(text: myCompany.phone);
    _website = TextEditingController(text: myCompany.website);
    country = myCompany.country;
    state = myCompany.state;
    city = myCompany.city;
    plan = myCompany.plan;

    Stream purchaseUpdated = InAppPurchaseConnection.instance.purchaseUpdatedStream;
    _subscription = purchaseUpdated.listen((purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription.cancel();
    }, onError: (error) {
      showMessage(error.toString());
      print('InAppPurchaseConnection.Error $error');
    });
    initStoreInfo();

  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
      if(purchaseDetails.status == PurchaseStatus.error){
        print(purchaseDetails.error.message);
        showMessage(purchaseDetails.error.message);
      }
      if(purchaseDetails.status == PurchaseStatus.purchased){
        updateCompany();
      }
    });
  }

  Future<void> initStoreInfo() async {
    final bool isAvailable = await _connection.isAvailable();
    if(!mounted)return;
    if (!isAvailable) {
      setState(() {_products = [];});
      return;
    }

    ProductDetailsResponse productDetailResponse = await _connection.queryProductDetails(subscriptionPlans.toSet());
    if(!mounted)return;
    if (productDetailResponse.error != null) {
      setState(() {
        showMessage(productDetailResponse.error.message);
        _products = productDetailResponse.productDetails;
      });
      return;
    }

    if (productDetailResponse.productDetails.isEmpty) {
      setState(() {_products = productDetailResponse.productDetails;});
      return;
    }

    final QueryPurchaseDetailsResponse purchaseResponse = await _connection.queryPastPurchases();
    if (purchaseResponse.error != null) {
      showMessage(purchaseResponse.error.message);
    }
    final List<PurchaseDetails> verifiedPurchases = [];
    for (PurchaseDetails purchase in purchaseResponse.pastPurchases) {
      verifiedPurchases.add(purchase);
    }
    setState(() {_products = productDetailResponse.productDetails;});
  }

  Widget companyPlanWidgets(){
    List<Widget> plans = [];
    _products.forEach((p) {
      plans.add(
          CheckboxListTile(
            value: plan==subscriptionPlans.indexOf(p.id),
            onChanged: (v){
              setState(() {
                selectedProduct=p;
                plan = subscriptionPlans.indexOf(p.id);
              });
            },
            title: Text("${p.title}",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
            controlAffinity: ListTileControlAffinity.leading,
            secondary: Text("${p.price}/mth",style: TextStyle(color: Color(primaryColor,),fontSize: 18,fontWeight: FontWeight.bold),),
            contentPadding: EdgeInsets.symmetric(horizontal: 30),
          )
      );
    });
    return Column(
      children: plans,
    );
  }

  bool profileValidator(){
    _emailError = null; _passwordError = null; _fNameError=null;_lNameError=null;
    if(_fName.text.isEmpty){
      _fNameError = S.of(context).firstNameIsRequired;
      return false;
    }
    if(_lName.text.isEmpty){
      _lNameError = S.of(context).lastNameIsRequired;
      return false;
    }
    if(_email.text.isEmpty){
      _emailError = S.of(context).yourEmailIsRequired;
      return false;
    }
    if(!_email.text.contains("@") || !_email.text.contains(".")){
      _emailError = S.of(context).emailIsInvalid;
      return false;
    }
    if(_oldPassword.text.isEmpty && _newPassword.text.isNotEmpty){
      _passwordError = S.of(context).passwordIsRequired;
      return false;
    }
    return true;
  }
  bool companyValidator(){
    _nameError = null; _addressError = null; _postalCodeError = null;
    if(_name.text.isEmpty){
      setState(() {_nameError = S.of(context).companyNameIsRequired;});
      return false;
    }
    if(_address1.text.isEmpty){
      setState(() {_addressError = S.of(context).companyAddressIsRequired;});
      return false;
    }
    if(country==null){
      showMessage(S.of(context).countryIsRequired);
      return false;
    }
    if(state==null){
      showMessage(S.of(context).stateIsRequired);
      return false;
    }
    if(city==null){
      showMessage(S.of(context).cityIsRequired);
      return false;
    }
    if(_postalCode.text.isEmpty){
      setState(() {_postalCodeError = S.of(context).postalCodeIsRequired;});
      return false;
    }
    return true;
  }

  String firstToUpper(String v){
    if(v.isNotEmpty){
      return v[0].toUpperCase()+v.substring(1);
    }
    return v;
  }

  updateUser()async{
    try{
      if(isProfileUpdating)return;
      if(profileValidator()){
        setState(() {isProfileUpdating = true;});
        String result = await context.read<UserModel>().updateAdmin(
            email: _email.text,
            fName: _fName.text,
            lName: _lName.text,
            newPassword: _newPassword.text,
            oldPassword: _oldPassword.text
        );
        setState(() {isProfileUpdating = false;});
        if(result!=null){
          showMessage(result);
        }
      }else{
        setState(() {});
      }
    }catch(e){
      print("[SettingScreen.updateUser] $e");
    }
  }

  updateCompany()async{
    try{
      if(isCompanyUpdating)return;
      setState(() {isCompanyUpdating = true;});
      String result = await context.read<CompanyModel>().updateCompany(
          name: _name.text,
          phone: _phone.text,
          postalCode: _postalCode.text,
          city: city,
          state: state,
          country: country,
          address2: _address2.text,
          address1: _address1.text,
          plan: plan,
          website: _website.text
      );
      setState(() {
        isCompanyUpdating = false;
      });
      if(result!=null){
        showMessage(result);
      }
    }catch(e){
      print("[SettingScreen.updateUser] $e");
    }
  }

  showMessage(String message){
    _scaffoldKey.currentState.hideCurrentSnackBar();
    _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
          action: SnackBarAction(onPressed: (){},label: S.of(context).close,textColor: Colors.white,),
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    User user = context.watch<UserModel>().user;
    CompanySettings companySettings = context.watch<CompanyModel>().myCompanySettings;

    if(user==null)return Container();
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Settings",style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold),),
        leading: GestureDetector(
          child: Icon(Icons.navigate_before),
          onTap: (){
            if(!(isCompanyUpdating || isProfileUpdating || isRevisionNotificationUpdating || isPunchNotificationUpdating)) Navigator.pop(context);
          },
        ),
        backgroundColor: Color(primaryColor),
      ),
      body: WillPopScope(
        onWillPop: ()async{
          return !(isCompanyUpdating || isProfileUpdating || isRevisionNotificationUpdating || isPunchNotificationUpdating);
        },
        child: Container(
          padding: EdgeInsets.all(8),
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
                          SizedBox(width: 20,),
                          Text(S.of(context).aboutApp,style: TextStyle(color: Colors.black87,fontSize: 18,fontWeight: FontWeight.bold),)
                        ],
                      ),
                    ),
                  ),
                ),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(S.of(context).profile,style: TextStyle(color: Colors.red,fontSize: 18,fontWeight: FontWeight.bold),),
                        SizedBox(height: 8,),
                        TextField(
                          decoration: InputDecoration(
                              border: UnderlineInputBorder(),
                              enabledBorder: UnderlineInputBorder(),
                              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black87)),
                              labelText: S.of(context).firstName,
                              labelStyle: TextStyle(color: Colors.grey),
                              suffixIcon: Icon(Icons.person_outline,color: Colors.black87,size: 30,),
                              suffixIconConstraints: BoxConstraints(minHeight: 25,maxHeight: 25),
                              isDense: true,
                              errorText: _fNameError
                          ),
                          keyboardType: TextInputType.name,
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.next,
                          maxLines: 1,
                          enabled: !isProfileUpdating,
                          controller: _fName,
                          onChanged: (v){
                            _fName.value = _fName.value.copyWith(text: firstToUpper(v));
                          },
                        ),
                        TextField(
                          decoration: InputDecoration(
                              border: UnderlineInputBorder(),
                              enabledBorder: UnderlineInputBorder(),
                              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black87)),
                              labelText: S.of(context).lastName,
                              labelStyle: TextStyle(color: Colors.grey),
                              suffixIcon: Icon(Icons.person_outline,color: Colors.black87,size: 30,),
                              suffixIconConstraints: BoxConstraints(minHeight: 25,maxHeight: 25),
                              isDense: true,
                              errorText: _lNameError
                          ),
                          keyboardType: TextInputType.name,
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.next,
                          maxLines: 1,
                          enabled: !isProfileUpdating,
                          controller: _lName,
                          onChanged: (v){
                            _lName.value = _lName.value.copyWith(text: firstToUpper(v));
                          },
                        ),
                        TextField(
                          decoration: InputDecoration(
                              border: UnderlineInputBorder(),
                              enabledBorder: UnderlineInputBorder(),
                              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black87)),
                              labelText: S.of(context).email,
                              labelStyle: TextStyle(color: Colors.grey),
                              suffixIcon: Icon(Icons.email_outlined,color: Colors.black87,size: 30,),
                              suffixIconConstraints: BoxConstraints(minHeight: 30,maxHeight: 30),
                              isDense: true,
                              errorText: _emailError
                          ),
                          keyboardType: TextInputType.emailAddress,
                          enabled: !isProfileUpdating,
                          controller: _email,
                        ),
                        TextField(
                          decoration: InputDecoration(
                              border: UnderlineInputBorder(),
                              enabledBorder: UnderlineInputBorder(),
                              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black87)),
                              labelText: S.of(context).oldPassword,
                              labelStyle: TextStyle(color: Colors.grey),
                              suffixIcon: Icon(Icons.lock_outline,color: Colors.black87,size: 30,),
                              suffixIconConstraints: BoxConstraints(minHeight: 30,maxHeight: 30),
                              isDense: true,
                              errorText: _passwordError
                          ),
                          keyboardType: TextInputType.number,
                          maxLength: 4,
                          enabled: !isProfileUpdating,
                          controller: _oldPassword,
                          enableSuggestions: false,
                          obscureText: true,
                          autocorrect: false,
                        ),
                        TextField(
                          decoration: InputDecoration(
                            border: UnderlineInputBorder(),
                            enabledBorder: UnderlineInputBorder(),
                            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black87)),
                            labelText: S.of(context).newPassword,
                            labelStyle: TextStyle(color: Colors.grey),
                            suffixIcon: Icon(Icons.lock_outline,color: Colors.black87,size: 30,),
                            suffixIconConstraints: BoxConstraints(minHeight: 30,maxHeight: 30),
                            isDense: true,
                          ),
                          keyboardType: TextInputType.number,
                          maxLength: 4,
                          enabled: !isProfileUpdating,
                          controller: _newPassword,
                          enableSuggestions: false,
                          obscureText: true,
                          autocorrect: false,
                        ),
                        SizedBox(height: 8,),
                        Center(
                          child: ButtonTheme(
                            minWidth: MediaQuery.of(context).size.width/2,
                            padding: EdgeInsets.all(8),
                            child: RaisedButton(
                              child: isProfileUpdating?SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(backgroundColor: Colors.white,)
                              ):Text(S.of(context).save.toUpperCase(),style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color: Colors.white),),
                              onPressed: updateUser,
                              color: Colors.red,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(S.of(context).company,style: TextStyle(color: Colors.red,fontSize: 18,fontWeight: FontWeight.bold),),
                        SizedBox(height: 8,),
                        TextField(
                          decoration: InputDecoration(
                            border: UnderlineInputBorder(),
                            enabledBorder: UnderlineInputBorder(),
                            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black87)),
                            labelText: S.of(context).companyName,
                            labelStyle: TextStyle(color: Colors.grey),
                            isDense: true,
                            errorText: _nameError,
                          ),
                          controller: _name,
                          keyboardType: TextInputType.text,
                          textCapitalization: TextCapitalization.words,
                          onChanged: (v){
                            _name.value = _name.value.copyWith(text: firstToUpper(v));
                          },
                        ),
                        SizedBox(height: 10,),
                        TextField(
                          decoration: InputDecoration(
                            border: UnderlineInputBorder(),
                            enabledBorder: UnderlineInputBorder(),
                            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black)),
                            labelText: S.of(context).streetAddress,
                            labelStyle: TextStyle(color: Colors.grey),
                            isDense: true,
                            errorText: _addressError,
                          ),
                          controller: _address1,
                          keyboardType: TextInputType.streetAddress,
                          textCapitalization: TextCapitalization.words,
                          onChanged: (v){
                            _address1.value = _address1.value.copyWith(text: firstToUpper(v));
                          },
                        ),
                        TextField(
                          decoration: InputDecoration(
                            border: UnderlineInputBorder(),
                            enabledBorder: UnderlineInputBorder(),
                            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black)),
                            labelText: S.of(context).aptSuiteBuilding,
                            labelStyle: TextStyle(color: Colors.grey),
                            errorText: null,
                            isDense: true,
                          ),
                          controller: _address2,
                          keyboardType: TextInputType.streetAddress,
                          textCapitalization: TextCapitalization.words,
                          onChanged: (v){
                            _address1.value = _address1.value.copyWith(text: firstToUpper(v));
                          },
                        ),
                        SelectState(
                          initCountry: country,
                          initCity: city,
                          initState: state,
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
                            labelText: S.of(context).postalCode,
                            labelStyle: TextStyle(color: Colors.grey),
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
                            labelText: S.of(context).phoneNumber,
                            labelStyle: TextStyle(color: Colors.grey),
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
                            labelText: S.of(context).website,
                            labelStyle: TextStyle(color: Colors.grey),
                            isDense: true,
                          ),
                          controller: _website,
                          keyboardType: TextInputType.url,
                          textInputAction: TextInputAction.done,
                        ),
                        SizedBox(height: 20,),
                        Text(S.of(context).companyPlan,style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                        CheckboxListTile(
                          value: plan==0,
                          onChanged: (v){
                            setState(() { plan = 0; selectedProduct=null;});
                          },
                          title: Text("${companyPlans[0].minRange} ~ ${companyPlans[0].maxRange} ${S.of(context).employees} ",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                          controlAffinity: ListTileControlAffinity.leading,
                          secondary: Text(S.of(context).free,style: TextStyle(color: Color(primaryColor,),fontSize: 18,fontWeight: FontWeight.bold),),
                          contentPadding: EdgeInsets.symmetric(horizontal: 30),
                        ),
                        companyPlanWidgets(),
                        Center(
                          child: ButtonTheme(
                            minWidth: MediaQuery.of(context).size.width/2,
                            padding: EdgeInsets.all(8),
                            child: RaisedButton(
                              child: isCompanyUpdating?SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(backgroundColor: Colors.white,)
                              ):Text(S.of(context).save,style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color: Colors.white),),
                              onPressed: (){
                                if(profileValidator()){
                                  if(myCompany.plan!=plan){
                                    final user = Provider.of<UserModel>(context,listen: false).user;
                                    PurchaseParam purchaseParam = PurchaseParam(
                                        productDetails: selectedProduct,
                                        applicationUserName: user.firstName+" "+user.lastName,
                                        sandboxTesting: true);
                                    _connection.buyNonConsumable(purchaseParam: purchaseParam);
                                    return null;
                                  }else{
                                    updateCompany();
                                  }
                                }else{
                                 setState(() {});
                                }
                              },
                              color: Colors.red,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Card(
                  child: Column(
                    children: [
                      SwitchListTile(
                        value: companySettings.receiveRevisionNotification,
                        onChanged: isRevisionNotificationUpdating?null:(v)async{
                          setState(() {isRevisionNotificationUpdating = true;});
                          companySettings.receiveRevisionNotification = v;
                          String result = await context.read<CompanyModel>().updateCompanySetting(companySettings);
                          if(result!=null)showMessage(result);
                          setState(() {isRevisionNotificationUpdating = false;});
                        },
                        dense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
                        title: Row(
                          children: [
                            Text(S.of(context).receiveRevisionNotification,style: TextStyle(color: Colors.black87,fontSize: 16,),),
                            SizedBox(width: 10,),
                            if(isRevisionNotificationUpdating)
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(),
                              )
                          ],
                        ),
                      ),
                      SwitchListTile(
                        value: companySettings.receivePunchNotification,
                        onChanged: isPunchNotificationUpdating?null:(v)async{
                          setState(() {isPunchNotificationUpdating = true;});
                          companySettings.receivePunchNotification = v;
                          String result = await context.read<CompanyModel>().updateCompanySetting(companySettings);
                          if(result!=null)showMessage(result);
                          setState(() {isPunchNotificationUpdating = false;});
                        },
                        dense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
                        title: Row(
                          children: [
                            Text(S.of(context).receivePunchNotification,style: TextStyle(color: Colors.black87,fontSize: 16,),),
                            SizedBox(width: 10,),
                            if(isPunchNotificationUpdating)
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(),
                              )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20,)
              ],
            ),
          ),
        ),
      ),
      backgroundColor: Color(primaryColor),
    );
  }
}