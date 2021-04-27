import 'package:facepunch/lang/l10n.dart';
import 'package:facepunch/models/app_const.dart';
import 'package:facepunch/models/company_model.dart';
import 'package:facepunch/models/harvest_model.dart';
import 'package:facepunch/widgets/popover/cool_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';

class NFCSettingPage extends StatefulWidget{

  @override
  _NFCSettingPageState createState() => _NFCSettingPageState();
}

class _NFCSettingPageState extends State<NFCSettingPage>{
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController _lowValue = TextEditingController(text: '2.5');
  TextEditingController _highValue = TextEditingController(text: '3.0');
  TimeOfDay _reportTime = TimeOfDay.now();
  DateTime _lastUpdated = DateTime.now();

  bool isLoading = false;
  Color lowColor = Colors.red;
  Color mediumColor = Colors.yellow;
  Color highColor = Colors.green;
  CompanySettings companySettings;

  @override
  void initState() {
    companySettings = context.read<CompanyModel>().myCompanySettings;
    if(companySettings!=null){
      if(companySettings.lowValue!=null)_lowValue = TextEditingController(text: companySettings.lowValue);
      if(companySettings.highValue!=null)_highValue = TextEditingController(text: companySettings.highValue);
      if(companySettings.lowColor!=null)lowColor = Color(int.parse('0x${companySettings.lowColor}'));
      if(companySettings.mediumColor!=null)mediumColor = Color(int.parse('0x${companySettings.mediumColor}'));
      if(companySettings.highColor!=null)highColor = Color(int.parse('0x${companySettings.highColor}'));
      if(companySettings.reportTime!=null)_reportTime = TimeOfDay.fromDateTime(DateTime.parse(companySettings.reportTime));
      if(companySettings.lastUpdated!=null)_lastUpdated = DateTime.parse(companySettings.lastUpdated);
    }
    super.initState();
  }

  showFieldDialog({Field field}){
    TextEditingController _fieldName = TextEditingController(text: field?.name);
    TextEditingController _fieldCrop = TextEditingController(text: field?.crop);
    TextEditingController _fieldCropVariety = TextEditingController(text: field?.cropVariety);
    bool isSavingField = false;
    String _fieldNameError, _fieldCropError,_fieldVarietyError;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_context){
        return AlertDialog(
          title: Text(field==null?S.of(context).createNewField:S.of(context).updateField,textAlign: TextAlign.center,),
          content:StatefulBuilder(
            builder: (_,setState)=>Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _fieldName,
                    textCapitalization: TextCapitalization.words,
                    onChanged: (v){
                      _fieldName.value = _fieldName.value.copyWith(text: firstToUpper(v));
                    },
                    decoration: InputDecoration(
                      labelText: S.of(context).fieldName,
                      labelStyle: TextStyle(color: Colors.black54),
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      errorText: _fieldNameError
                    ),
                  ),
                  SizedBox(height: 8,),
                  TextField(
                    controller: _fieldCrop,
                    textCapitalization: TextCapitalization.words,
                    onChanged: (v){
                      _fieldCrop.value = _fieldCrop.value.copyWith(text: firstToUpper(v));
                    },
                    decoration: InputDecoration(
                      labelText: S.of(context).fieldCrop,
                      labelStyle: TextStyle(color: Colors.black54),
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      errorText: _fieldCropError
                    ),
                  ),
                  SizedBox(height: 8,),
                  TextField(
                    controller: _fieldCropVariety,
                    textCapitalization: TextCapitalization.words,
                    onChanged: (v){
                      _fieldCropVariety.value = _fieldCropVariety.value.copyWith(text: firstToUpper(v));
                    },
                    decoration: InputDecoration(
                      labelText: S.of(context).fieldCropVariety,
                      labelStyle: TextStyle(color: Colors.black54),
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      errorText: _fieldVarietyError
                    ),
                  ),
                  SizedBox(height: 16,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RaisedButton(
                        child: isSavingField
                        ?SizedBox(
                          height: 28,
                          width: 28,
                          child: CircularProgressIndicator(backgroundColor: Colors.white,),
                        ):Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text(S.of(context).save.toUpperCase(),style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color: Colors.white),),
                        ),
                        color: Color(primaryColor),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        onPressed: ()async{
                          try{
                            _fieldVarietyError = null; _fieldCropError = null; _fieldNameError = null;
                            if(_fieldName.text.isEmpty){
                              setState((){_fieldNameError=S.of(context).fieldNameIsRequired;});
                              return;
                            }
                            if(_fieldCrop.text.isEmpty){
                              setState((){_fieldCropError=S.of(context).cropIsRequired;});
                              return;
                            }
                            if(_fieldCropVariety.text.isEmpty){
                              setState((){_fieldVarietyError=S.of(context).varietyIsRequired;});
                              return;
                            }
                            setState((){isSavingField=true;});
                            if(field!=null){
                              field.name = _fieldName.text;
                              field.crop = _fieldCrop.text;
                              field.cropVariety = _fieldCropVariety.text;
                            }else{
                              field = Field(name: _fieldName.text,crop: _fieldCrop.text,cropVariety: _fieldCropVariety.text);
                            }
                            String result = await context.read<HarvestModel>().createOrUpdateField(field);
                            if(result!=null){
                              _fieldVarietyError = result;
                            }else{
                              Navigator.pop(_context);
                            }
                            setState((){isSavingField=false;});
                          }catch(e){
                            Navigator.pop(_context);
                          }
                        },
                      ),
                      RaisedButton(
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text(S.of(context).close.toUpperCase(),style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color: Colors.white),),
                        ),
                        onPressed: ()async{
                          Navigator.pop(_context);
                        },
                        color: Colors.red,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                    ],
                  )
                ],
              ),
            ),
          )
        );
      },
    );
  }

  confirmDeleteFieldDialog(Field field){
    bool isDeletingField = false;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_context){
        return AlertDialog(
            title: Text(S.of(context).deleteFieldConfirm,textAlign: TextAlign.center,),
            content:StatefulBuilder(
              builder: (_,setState)=>Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        RaisedButton(
                          child: isDeletingField
                              ?SizedBox(
                            height: 28,
                            width: 28,
                            child: CircularProgressIndicator(backgroundColor: Colors.white,),
                          ):Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Text(S.of(context).delete,style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color: Colors.white),),
                          ),
                          color: Color(primaryColor),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          onPressed: ()async{
                            setState((){isDeletingField = true;});
                            String result = await context.read<HarvestModel>().deleteField(field);
                            setState((){isDeletingField = false;});
                            Navigator.pop(_context);
                            if(result!=null)showMessage(result);
                          },
                        ),
                        RaisedButton(
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Text(S.of(context).close.toUpperCase(),style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold, color: Colors.white),),
                          ),
                          onPressed: ()async{
                            Navigator.pop(_context);
                          },
                          color: Colors.red,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            )
        );
      },
    );
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

  showContainerDialog({HContainer container}){
    TextEditingController _containerName = TextEditingController(text: container?.name);
    bool isSavingContainer = false;
    String _containerNameError;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_context){
        return AlertDialog(
            title: Text(container==null?S.of(context).createNewContainer:S.of(context).updateContainer,textAlign: TextAlign.center,),
            content:StatefulBuilder(
              builder: (_,setState)=>Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _containerName,
                      textCapitalization: TextCapitalization.words,
                      onChanged: (v){
                        _containerName.value = _containerName.value.copyWith(text: firstToUpper(v));
                      },
                      decoration: InputDecoration(
                          labelText: S.of(context).containerName,
                          labelStyle: TextStyle(color: Colors.black54),
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          errorText: _containerNameError
                      ),
                    ),
                    SizedBox(height: 16,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        RaisedButton(
                          child: isSavingContainer
                          ?SizedBox(
                            height: 28,
                            width: 28,
                            child: CircularProgressIndicator(backgroundColor: Colors.white,),
                          ):Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Text(S.of(context).save.toUpperCase(),style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color: Colors.white),),
                          ),
                          color: Color(primaryColor),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          onPressed: ()async{
                            try{
                              _containerNameError = null;
                              if(_containerName.text.isEmpty){
                                setState((){_containerNameError=S.of(context).nameIsRequired;});
                                return;
                              }
                              setState((){isSavingContainer=true;});
                              if(container!=null){
                                container.name = _containerName.text;
                              }else{
                                container = HContainer(name: _containerName.text);
                              }
                              String result = await context.read<HarvestModel>().createOrUpdateContainer(container);
                              if(result!=null){
                                _containerNameError = result;
                              }else{
                                Navigator.pop(_context);
                              }
                              setState((){isSavingContainer=false;});
                            }catch(e){
                              Navigator.pop(_context);
                            }
                          },
                        ),
                        RaisedButton(
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Text(S.of(context).close.toUpperCase(),style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color: Colors.white),),
                          ),
                          onPressed: ()async{
                            Navigator.pop(_context);
                          },
                          color: Colors.red,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            )
        );
      },
    );
  }

  confirmDeleteContainerDialog(HContainer container){
    bool isDeletingContainer = false;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_context){
        return AlertDialog(
            title: Text(S.of(context).deleteContainerConfirm,textAlign: TextAlign.center,),
            content:StatefulBuilder(
              builder: (_,setState)=>Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        RaisedButton(
                          child: isDeletingContainer
                              ?SizedBox(
                            height: 28,
                            width: 28,
                            child: CircularProgressIndicator(backgroundColor: Colors.white,),
                          ):Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Text(S.of(context).delete,style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color: Colors.white),),
                          ),
                          color: Color(primaryColor),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          onPressed: ()async{
                            setState((){isDeletingContainer = true;});
                            String result = await context.read<HarvestModel>().deleteContainer(container);
                            setState((){isDeletingContainer = false;});
                            Navigator.pop(_context);
                            if(result!=null)showMessage(result);
                          },
                        ),
                        RaisedButton(
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Text(S.of(context).close.toUpperCase(),style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold, color: Colors.white),),
                          ),
                          onPressed: ()async{
                            Navigator.pop(_context);
                          },
                          color: Colors.red,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            )
        );
      },
    );
  }

  Future<Color> showColorPicker(Color color)async{
    Color pickedColor = Color(color.value);
    await showDialog(
      context: context,
      child: AlertDialog(
        title: Text(S.of(context).chooseColor),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: pickedColor,
            onColorChanged: (c){pickedColor = c;},
            pickerAreaHeightPercent: 0.8,
          ),
        ),
        actions: <Widget>[
          FlatButton(
            child: Text(S.of(context).ok),
            onPressed: () {
              color = pickedColor;
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
    return color;
  }

  changeReportTime()async{
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: _reportTime,
    );
    if(picked!=null){
      setState(() {
        _reportTime = picked;
      });
    }
  }

  bool validator(){
    if(_lowValue.text.isEmpty){
      showMessage(S.of(context).lowValueIsEmpty);
      return false;
    }
    if(double.tryParse(_lowValue.text)==null){
      showMessage(S.of(context).lowValueShouldBeNumber);
      return false;
    }
    if(_highValue.text.isEmpty){
      showMessage(S.of(context).highValueIsEmpty);
      return false;
    }
    if(double.tryParse(_highValue.text)==null){
      showMessage(S.of(context).highValueShouldBeNumber);
      return false;
    }
    if(double.tryParse(_highValue.text)<double.tryParse(_lowValue.text)){
      showMessage(S.of(context).highValueShouldBeBigger);
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

  @override
  Widget build(BuildContext context) {
    List<Field> fields = context.watch<HarvestModel>().fields;
    List<HContainer> containers = context.watch<HarvestModel>().containers;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(S.of(context).nfcSettings),
        backgroundColor: Color(primaryColor),
      ),
      body: Container(
        padding: EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(S.of(context).fields,style: TextStyle(fontWeight: FontWeight.w500,fontSize: 16),),
              Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    for(var field in fields)
                      CupertinoPopoverButton(
                        popoverBoxShadow: [
                          BoxShadow(color: Colors.black54,blurRadius: 5.0)
                        ],
                        popoverWidth: 180,
                        popoverBuild: (_context){
                          return CupertinoPopoverMenuList(
                            children: <Widget>[
                              CupertinoPopoverMenuItem(
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(S.of(context).editField,style: TextStyle(color: Colors.black87),),
                                      Icon(Icons.edit,color: Colors.black87,),
                                    ],
                                  ),
                                ),
                                onTap: (){
                                  Navigator.pop(_context);
                                  showFieldDialog(field: field);
                                  return true;
                                },
                              ),
                              CupertinoPopoverMenuItem(
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(S.of(context).delete,style: TextStyle(color: Colors.red),),
                                      Icon(Icons.delete,color: Colors.red,),
                                    ],
                                  ),
                                ),
                                onTap: (){
                                  Navigator.pop(_context);
                                  confirmDeleteFieldDialog(field);
                                  return true;
                                },
                              )
                            ],
                          );
                        },
                        onTap: (){
                          return true;
                        },
                        child: Container(
                          height: 70,
                          width: 70,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(primaryColor),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  spreadRadius: 1,
                                  blurRadius: 1,
                                  
                                )
                              ]
                          ),
                          clipBehavior: Clip.hardEdge,
                          padding: EdgeInsets.all(2),
                          margin: EdgeInsets.all(2),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(field.name[0].toUpperCase(),style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                              FittedBox(
                                  child: Text(field.crop, style: TextStyle(fontSize: 12),)
                              ),
                              FittedBox(
                                  child: Text(field.cropVariety, style: TextStyle(fontSize: 12),)
                              )
                            ],
                          ),
                        ),
                      ),
                    Container(
                      height: 70,
                      width: 70,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(primaryColor),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              spreadRadius: 1,
                              blurRadius: 1,
                              
                            )
                          ]
                      ),
                      clipBehavior: Clip.hardEdge,
                      padding: EdgeInsets.all(2),
                      margin: EdgeInsets.all(2),
                      child: InkWell(
                        onTap: (){showFieldDialog();},
                          borderRadius: BorderRadius.circular(30),
                          child: Icon(Icons.add,size: 30,)
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8,),
              Text(S.of(context).containers,style: TextStyle(fontWeight: FontWeight.w500,fontSize: 16),),
              Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    for(var container in containers)
                      CupertinoPopoverButton(
                        popoverBoxShadow: [
                          BoxShadow(color: Colors.black54,blurRadius: 5.0)
                        ],
                        popoverWidth: 180,
                        popoverBuild: (_context){
                          return CupertinoPopoverMenuList(
                            children: <Widget>[
                              CupertinoPopoverMenuItem(
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(S.of(context).editContainer,style: TextStyle(color: Colors.black87),),
                                      Icon(Icons.edit,color: Colors.black87,),
                                    ],
                                  ),
                                ),
                                onTap: (){
                                  Navigator.pop(_context);
                                  showContainerDialog(container: container);
                                  return true;
                                },
                              ),
                              CupertinoPopoverMenuItem(
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(S.of(context).delete,style: TextStyle(color: Colors.red),),
                                      Icon(Icons.delete,color: Colors.red,),
                                    ],
                                  ),
                                ),
                                onTap: (){
                                  Navigator.pop(_context);
                                  confirmDeleteContainerDialog(container);
                                  return true;
                                },
                              )
                            ],
                          );
                        },
                        onTap: (){
                          return true;
                        },
                        child: Container(
                          height: 70,
                          width: 70,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(primaryColor),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  spreadRadius: 1,
                                  blurRadius: 1,
                                  
                                )
                              ]
                          ),
                          clipBehavior: Clip.hardEdge,
                          padding: EdgeInsets.all(2),
                          margin: EdgeInsets.all(2),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(container.name[0].toUpperCase(),style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                              FittedBox(
                                  child: Text('${container.name}',style: TextStyle(fontSize: 12),)
                              ),
                              SizedBox(height: 12,),
                            ],
                          ),
                        ),
                      ),
                    Container(
                      height: 70,
                      width: 70,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(primaryColor),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              spreadRadius: 1,
                              blurRadius: 1,
                              
                            )
                          ]
                      ),
                      clipBehavior: Clip.hardEdge,
                      padding: EdgeInsets.all(2),
                      margin: EdgeInsets.all(2),
                      child: InkWell(
                          onTap: (){showContainerDialog();},
                          borderRadius: BorderRadius.circular(30),
                          child: Icon(Icons.add,size: 30,)
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8,),
              Text(S.of(context).containerHour,style: TextStyle(fontWeight: FontWeight.w500,fontSize: 16),),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 30,vertical: 4),
                padding: EdgeInsets.zero,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      spreadRadius: 1,
                      blurRadius: 1,
                    )
                  ]
                ),
                height: 40,
                clipBehavior: Clip.hardEdge,
                child: Row(
                  children: [
                    Flexible(
                        child: InkWell(
                          onTap: ()async{
                            highColor = await showColorPicker(highColor);
                            setState(() {});
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                color: highColor,
                            ),
                            child: Text(S.of(context).highDefault),
                            alignment: Alignment.center,
                          ),
                        )
                    ),
                    Flexible(
                        child: TextField(
                          controller: _highValue,
                          keyboardType: TextInputType.number,
                          maxLines: 1,
                          decoration: InputDecoration(
                            isDense: true,
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 20),
                            suffixText: '+',
                            suffixStyle: TextStyle(fontSize: 18),
                          ),
                          textAlign: TextAlign.center,
                          onChanged: (v){
                            setState(() {});
                          },
                          style: TextStyle(fontSize: 18),
                        )
                    )
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 30,vertical: 4),
                padding: EdgeInsets.zero,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        spreadRadius: 1,
                        blurRadius: 1,
                      )
                    ]
                ),
                height: 40,
                clipBehavior: Clip.hardEdge,
                child: Row(
                  children: [
                    Flexible(
                        child: InkWell(
                          onTap: ()async{
                            mediumColor = await showColorPicker(mediumColor);
                            setState(() {});
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: mediumColor,
                            ),
                            child: Text(S.of(context).mediumDefault),
                            alignment: Alignment.center,
                          ),
                        )
                    ),
                    Flexible(
                        child: Center(
                            child: Text(
                              "${_lowValue.text} to ${_highValue.text}",
                              style: TextStyle(fontSize: 18),
                              textAlign: TextAlign.center,
                            )
                        )
                    )
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 30,vertical: 4),
                padding: EdgeInsets.zero,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        spreadRadius: 1,
                        blurRadius: 1,
                      )
                    ]
                ),
                height: 40,
                clipBehavior: Clip.hardEdge,
                child: Row(
                  children: [
                    Flexible(
                        child: InkWell(
                          onTap: ()async{
                            lowColor = await showColorPicker(lowColor);
                            setState(() {});
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: lowColor,
                            ),
                            child: Text(S.of(context).lowDefault),
                            alignment: Alignment.center,
                          ),
                        )
                    ),
                    Flexible(
                        child: TextField(
                          controller: _lowValue,
                          keyboardType: TextInputType.number,
                          maxLines: 1,
                          decoration: InputDecoration(
                            isDense: true,
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 20),
                            suffixText: '-',
                            suffixStyle: TextStyle(fontSize: 18),
                          ),
                          textAlign: TextAlign.center,
                          onChanged: (v){
                            setState(() {});
                          },
                          style: TextStyle(fontSize: 18),
                        )
                    )
                  ],
                ),
              ),
              SizedBox(height: 8,),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text('${S.of(context).reportTime}:\n${_reportTime==null?'':_reportTime.format(context)}',style: TextStyle(fontWeight: FontWeight.w500,fontSize: 16),),
                        SizedBox(width: 8,),
                        InkWell(
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Icon(Icons.edit,color: Colors.red,),
                          ),
                          borderRadius: BorderRadius.circular(30),
                          onTap: changeReportTime,
                        )
                      ],
                    ),
                    Text('${S.of(context).lastUpdated}: ${_lastUpdated==null?'':_lastUpdated.toString().split(' ')[0]}',style: TextStyle(fontWeight: FontWeight.w500,fontSize: 16),),
                  ],
                ),
              ),
              SizedBox(height: 8,),
              Center(
                child: ButtonTheme(
                  minWidth: MediaQuery.of(context).size.width-60,
                  padding: EdgeInsets.all(8),
                  splashColor: Color(primaryColor),
                  child: RaisedButton(
                    child: isLoading
                        ?SizedBox(
                      height: 28,
                      width: 28,
                      child: CircularProgressIndicator(),
                    )
                        :Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(S.of(context).save,style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color: Colors.white),),
                    ),
                    onPressed: ()async{
                      try{
                        if(validator()){
                          final now = DateTime.now();
                          companySettings.reportTime = DateTime(now.year, now.month, now.day, _reportTime.hour, _reportTime.minute).toString();
                          companySettings.lastUpdated = now.toString().split(' ')[0];
                          companySettings.highColor = highColor.value.toRadixString(16);
                          companySettings.mediumColor = mediumColor.value.toRadixString(16);
                          companySettings.lowColor = lowColor.value.toRadixString(16);
                          companySettings.highValue = _highValue.text;
                          companySettings.lowValue = _lowValue.text;
                          setState(() {isLoading=true;});
                          String result = await context.read<CompanyModel>().updateCompanySetting(companySettings);
                          setState(() {isLoading=false;});
                          if(result!=null)showMessage(result);
                        }
                      }catch(e){
                        print('[NFCSettingPage.onSave] $e');
                        showMessage(e.toString());
                      }
                    },
                    color: Colors.black87,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}