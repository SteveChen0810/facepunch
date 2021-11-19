import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:facepunch/lang/l10n.dart';
import 'package:facepunch/widgets/calendar_strip/date-utils.dart';
import 'package:image_cropper/image_cropper.dart';
import '../../models/company_model.dart';
import '../../widgets/address_picker/country_state_city_picker.dart';
import '../../models/user_model.dart';
import '../../models/app_const.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter_nfc_reader/flutter_nfc_reader.dart';

class CreateEditEmployee extends StatefulWidget {
  final User employee;
  CreateEditEmployee({this.employee});
  @override
  _CreateEditEmployeeState createState() => _CreateEditEmployeeState();
}

class _CreateEditEmployeeState extends State<CreateEditEmployee> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _picker = ImagePicker();
  File _photoFile;
  TextEditingController _fName = TextEditingController();
  TextEditingController _lName = TextEditingController();
  TextEditingController _email = TextEditingController();
  TextEditingController _password = TextEditingController();
  TextEditingController _address1 = TextEditingController();
  TextEditingController _address2 = TextEditingController();
  TextEditingController _postal = TextEditingController();
  TextEditingController _phone = TextEditingController();
  TextEditingController _employeeCode = TextEditingController();
  TextEditingController _salary = TextEditingController();
  TextEditingController _nfc = TextEditingController();


  String _fNameError,_lNameError,_emailError,_passwordError,_addressError,
      _postalError, _codeError, _salaryError, _startDateError,_birthDayError;
  String country,state,city, language;
  DateTime _startDate;
  DateTime _birthDay;
  bool isLoading = false;



  @override
  void initState() {
    super.initState();
    if(widget.employee!=null){
      try{
        _fName = TextEditingController(text: widget.employee.firstName);
        _lName = TextEditingController(text: widget.employee.lastName);
        _email = TextEditingController(text: widget.employee.email);
        _password = TextEditingController(text: widget.employee.pin);
        _address1 = TextEditingController(text: widget.employee.address1);
        _address2 = TextEditingController(text: widget.employee.address2);
        _postal = TextEditingController(text: widget.employee.postalCode);
        _phone = TextEditingController(text: widget.employee.phone);
        _employeeCode = TextEditingController(text: widget.employee.employeeCode);
        _salary = TextEditingController(text: widget.employee.salary);
        _nfc = TextEditingController(text: widget.employee.nfc);
        country = widget.employee.country;
        state = widget.employee.state;
        city = widget.employee.city;
        language = widget.employee.language;
        if(widget.employee.start!=null)_startDate = DateTime.parse(widget.employee.start);
        if(widget.employee.birthday!=null)_birthDay = DateTime.parse(widget.employee.birthday);
      }catch(e){
       print("[CreateEditEmployee.initState] $e");
      }
    }
  }

  _pickUserPhoto(ImageSource source)async{
    PickedFile image = await _picker.getImage(source: source,maxHeight: 800,maxWidth: 800);
    if(image!=null){
      File _cropFile = await ImageCropper.cropImage(
          sourcePath: image.path,
          aspectRatioPresets: [
            CropAspectRatioPreset.square,
          ],
          androidUiSettings: AndroidUiSettings(
              toolbarTitle: S.of(context).photoCropper,
              toolbarColor: Color(primaryColor),
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.square,
              hideBottomControls: true,
              lockAspectRatio: true
          ),
          iosUiSettings: IOSUiSettings(
            title: S.of(context).photoCropper,
            minimumAspectRatio: 1.0,
            hidesNavigationBar: true,
            aspectRatioLockEnabled: true,
            aspectRatioPickerButtonHidden: true,
          )
      );
      if(_cropFile!=null){
        setState(() {_photoFile = _cropFile;});
        return null;
      }
    }
    setState(() {_photoFile = null;});
  }

  Widget getAvatarWidget(){
    Widget image;
    if(_photoFile!=null){
      image = Image.file(_photoFile,width: 120,height: 120,fit: BoxFit.cover,);
    }else if(widget.employee!=null){
      image = CachedNetworkImage(
        imageUrl: "${AppConst.domainURL}images/user_avatars/${widget.employee.avatar}",
        height: 120,
        width: 120,
        alignment: Alignment.center,
        placeholder: (_,__)=>Image.asset("assets/images/person.png",width: 100,height: 100,),
        errorWidget: (_,__,___)=>Image.asset("assets/images/person.png",width: 100,height: 100,),
        fit: BoxFit.cover,
      );
    }else{
      image = Container(
        color: Colors.green,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Image.asset("assets/images/person.png",width: 100,height: 100,),
          )
      );
    }
    return ClipOval(
      child: image,
    );
  }

  String firstToUpper(String v){
    if(v.isNotEmpty){
      return v[0].toUpperCase()+v.substring(1);
    }
    return v;
  }

  _selectStartDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: _startDate==null?DateTime.now():_startDate,
        initialDatePickerMode: DatePickerMode.day,
        firstDate: DateTime(1970),
        lastDate: DateTime(2101));
    if (picked != null)
      setState(() {_startDate = picked;});
  }

  _selectBirthDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: _birthDay==null?DateTime.now():_birthDay,
        initialDatePickerMode: DatePickerMode.day,
        firstDate: DateTime(1970),
        lastDate: DateTime(2101));
    if (picked != null)
      setState(() {_birthDay = picked;});
  }

  showMessage(String message){
    _scaffoldKey.currentState.hideCurrentSnackBar();
    _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: message.toLowerCase().contains("success")?Colors.green:Colors.red,
          duration: Duration(seconds: 2),
          action: SnackBarAction(onPressed: (){},label: S.of(context).close,textColor: Colors.white,),
        )
    );
  }

  bool validator(){
    _fNameError=null;_lNameError=null;_emailError=null;_passwordError=null;_addressError=null;
    _postalError=null;_codeError=null;_salaryError=null;_startDateError=null;_birthDayError=null;
    if(_fName.text.isEmpty){
      _fNameError = S.of(context).firstNameIsRequired;
      return false;
    }
    if(_lName.text.isEmpty){
      _lNameError = S.of(context).lastNameIsRequired;
      return false;
    }
    if(_email.text.isNotEmpty && (!_email.text.contains(".") || !_email.text.contains("@"))){
      _emailError = S.of(context).emailIsInvalid;
      return false;
    }
    if(_password.text.isEmpty){
      _passwordError = S.of(context).passwordIsRequired;
      return false;
    }
    return true;
  }

  createEditEmployee()async{
    try{
      User user = User(
        id: widget.employee?.id,
        name: '${_fName.text} ${_lName.text}'.toLowerCase(),
        avatar: widget.employee?.avatar,
        firstName: _fName.text,
        lastName: _lName.text,
        email: _email.text,
        pin: _password.text,
        address1: _address1.text,
        address2: _address2.text,
        country: country,
        state: state,
        city: city,
        postalCode: _postal.text,
        phone: _phone.text,
        employeeCode: _employeeCode.text,
        start: _startDate!=null?_startDate.toString().split(" ").first:null,
        salary: _salary.text,
        birthday: _startDate!=null?_birthDay.toString().split(" ").first:null,
        nfc: _nfc.text,
        language: language,
        role: "employee",
        canNTCTracking: widget.employee?.canNTCTracking,
        companyId: widget.employee?.companyId,
        createdAt: widget.employee?.createdAt,
        emailVerifiedAt: widget.employee?.emailVerifiedAt,
        emailVerifyNumber: widget.employee?.emailVerifyNumber,
        firebaseToken: widget.employee?.firebaseToken,
        sendScheduleNotification: widget.employee?.sendScheduleNotification,
        token: widget.employee?.token,
        lastPunch: widget.employee?.lastPunch,
        type: widget.employee?.type??'shop_daily',
        updatedAt: widget.employee?.updatedAt,
        active: widget.employee?.active??true,
        hasAutoBreak: widget.employee?.hasAutoBreak??true,
        projects: widget.employee?.projects??[]
      );
      String base64Image;
      if(_photoFile!=null){
        base64Image = base64Encode(_photoFile.readAsBytesSync());
      }
      String result = await context.read<CompanyModel>().createEditEmployee(user, base64Image);
      if(result==null){
        showMessage(S.of(context).success);
        Future.delayed(Duration(seconds: 1)).whenComplete((){
          Navigator.pop(context);
        });
      }else{
        showMessage(result);
      }
    }catch(e){
      print("[createEditEmployee] $e");
      showMessage(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<CompanyModel>().myCompanySettings;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(widget.employee==null?S.of(context).createNewEmployee:S.of(context).editEmployee,style: TextStyle(color: Colors.black87,fontSize: 25,fontWeight: FontWeight.bold),),
        leading: IconButton(
          icon: Icon(Icons.arrow_back,color: Colors.black87,size: 35,),
          onPressed: ()=>Navigator.pop(context),
        ),
        backgroundColor: Color(primaryColor),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(20),
          ),
          width: MediaQuery.of(context).size.width,
          margin: EdgeInsets.all(8),
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Stack(
                  alignment: Alignment.center,
                    children: [
                      getAvatarWidget(),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: ButtonTheme(
                          height: 0,
                          minWidth: 50,
                          splashColor: Color(primaryColor),
                          child: RaisedButton(
                              child: Icon(Icons.camera_enhance,),
                              color: Colors.white,
                              shape: CircleBorder(),
                              padding: EdgeInsets.all(4),
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              onPressed: (){
                                FocusScope.of(context).requestFocus(FocusNode());
                                showModalBottomSheet(
                                    context: context,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(8))),
                                    clipBehavior: Clip.hardEdge,
                                    builder: (c){
                                      return Container(
                                        height: 104,
                                        padding: EdgeInsets.symmetric(vertical: 4),
                                        child: Column(
                                          children: [
                                            ListTile(
                                              dense: true,
                                              leading: Icon(Icons.camera_alt_outlined),
                                              title: Text(S.of(context).camera),
                                              onTap: (){
                                                Navigator.pop(c);
                                                _pickUserPhoto(ImageSource.camera);
                                              },
                                            ),
                                            ListTile(
                                              dense: true,
                                              leading: Icon(Icons.photo_library),
                                              title: Text(S.of(context).gallery),
                                              onTap: (){
                                                Navigator.pop(c);
                                                _pickUserPhoto(ImageSource.gallery);
                                              },
                                            )
                                          ],
                                        ),
                                      );
                                    },
                                );
                              }
                          ),
                        ),
                      ),
                    ],
                ),
              ),
              SizedBox(height: 10,),
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
                    errorText: _fNameError
                ),
                enabled: !isLoading && settings.useOwnData,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.name,
                maxLines: 1,
                controller: _fName,
                onChanged: (v){
                  _fName.value = _fName.value.copyWith(text: firstToUpper(v));
                },
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
                    errorText: _lNameError
                ),
                enabled: !isLoading && settings.useOwnData,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.name,
                maxLines: 1,
                controller: _lName,
                onChanged: (v){
                  _lName.value = _lName.value.copyWith(text: firstToUpper(v));
                },
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
                    errorText: _emailError
                ),
                enabled: !isLoading && settings.useOwnData,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                maxLines: 1,
                controller: _email,
              ),
              SizedBox(height: 4,),
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
                    errorText: _passwordError
                ),
                enabled: !isLoading && settings.useOwnData,
                keyboardType: TextInputType.number,
                maxLength: 4,
                textInputAction: TextInputAction.next,
                maxLines: 1,
                controller: _password,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20,bottom: 5),
                child: Text(S.of(context).address,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18,color: Colors.grey),),
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
                    errorText: _addressError
                ),
                enabled: !isLoading && settings.useOwnData,
                keyboardType: TextInputType.streetAddress,
                textInputAction: TextInputAction.next,
                maxLines: 1,
                controller: _address1,
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
                enabled: !isLoading && settings.useOwnData,
                keyboardType: TextInputType.streetAddress,
                textInputAction: TextInputAction.next,
                maxLines: 1,
                controller: _address2,
              ),
              SizedBox(height: 4,),
              SelectState(
                initCity: city,
                initState: state,
                initCountry: country,
                readOnly: !settings.useOwnData,
                onCountryChanged: (value) {
                  FocusScope.of(context).requestFocus(FocusNode());
                  country = value;
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
                  errorText: _postalError
                ),
                enabled: !isLoading && settings.useOwnData,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                maxLines: 1,
                controller: _postal,
                onChanged: (v){
                  _postal.value = _postal.value.copyWith(text: v.toUpperCase());
                },
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
                enabled: !isLoading && settings.useOwnData,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                maxLines: 1,
                controller: _phone,
              ),
              SizedBox(height: 20,),
              TextField(
                decoration: InputDecoration(
                  border: UnderlineInputBorder(),
                  enabledBorder: UnderlineInputBorder(),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black87)),
                  isDense: true,
                  labelText: "${S.of(context).employee}#",
                  labelStyle: TextStyle(color: Colors.grey,fontSize: 18),
                  contentPadding: EdgeInsets.zero,
                  errorText: _codeError
                ),
                enabled: !isLoading && settings.useOwnData,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                maxLines: 1,
                controller: _employeeCode,
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
                    errorText: _startDateError
                ),
                enabled: !isLoading && settings.useOwnData,
                readOnly: true,
                onTap: (){
                  _selectStartDate(context);
                },
                maxLines: 1,
                controller: TextEditingController(text: "${_startDate!=null?PunchDateUtils.inputDateString(_startDate):""}"),
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
                    suffixIconConstraints: BoxConstraints(maxHeight: 20),
                    suffixIcon: Text("\$/h",style: TextStyle(fontSize: 18),),
                    contentPadding: EdgeInsets.zero,
                    errorText: _salaryError
                ),
                enabled: !isLoading && settings.useOwnData,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                maxLines: 1,
                controller: _salary,
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
                    errorText: _birthDayError
                ),
                enabled: !isLoading && settings.useOwnData,
                readOnly: true,
                onTap: (){
                  _selectBirthDate(context);
                },
                maxLines: 1,
                controller: TextEditingController(text: "${_birthDay!=null?PunchDateUtils.inputDateString(_birthDay):""}"),
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
                enabled: !isLoading,
                onTap: (){
                  FlutterNfcReader.read().then((NfcData data)async{
                    if(data!=null){
                      if(data.id!=null && data.id.isNotEmpty){
                        _nfc.text = data.id;
                      }else{
                        _nfc.text = data.content;
                      }
                    }
                  }).catchError((e){
                    showMessage(e.toString());
                  });
                },
                maxLines: 1,
                controller: _nfc,
              ),
              SizedBox(height: 4,),
              DropdownButton<String>(
                items: ['English','Spanish','French'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2,horizontal: 8),
                      child: Text(value),
                    ),
                  );
                }).toList(),
                underline: Container(color: Colors.black87,width: double.infinity,height: 1,),
                style: TextStyle(fontSize: 20, color: Colors.black87),
                hint: Text(S.of(context).chooseLanguage),
                isExpanded: true,
                onChanged: !settings.useOwnData? null :(v) {
                  setState(() { language = v; });
                  FocusScope.of(context).requestFocus(FocusNode());
                },
                value: language,
                disabledHint: Text('$language'),
              ),
              MaterialButton(
                minWidth: MediaQuery.of(context).size.width,
                height: 40,
                color: Colors.black87,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                child: isLoading
                    ?SizedBox( height: 28, width: 28, child: CircularProgressIndicator(strokeWidth: 2,),)
                    :Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(S.of(context).save.toUpperCase(),style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color: Colors.white),),
                    ),
                onPressed: ()async{
                  FocusScope.of(context).requestFocus(FocusNode());
                  bool valid = validator();
                  setState(() {});
                  if(valid){
                    setState(() {isLoading = true;});
                    await createEditEmployee();
                    setState(() {isLoading = false;});
                  }
                },
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Color(primaryColor),
    );
  }
}