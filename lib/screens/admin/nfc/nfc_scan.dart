import 'package:facepunch/lang/l10n.dart';
import 'package:facepunch/models/app_const.dart';
import 'package:facepunch/models/harvest_model.dart';
import 'package:facepunch/screens/admin/nfc/nfc_settings.dart';
import 'package:facepunch/widgets/popover/cool_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nfc_reader/flutter_nfc_reader.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class NFCScanPage extends StatefulWidget{

  @override
  _NFCScanPageState createState() => _NFCScanPageState();
}

class _NFCScanPageState extends State<NFCScanPage>{
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isBigNFCImage = true;
  DateTime selectedDate = DateTime.now();
  HTask selectedTask;
  List<Harvest> harvests = [];
  RefreshController _refreshController = RefreshController(initialRefresh: true);
  bool isLoading = false;

  void _onRefresh() async{
    harvests = await context.read<HarvestModel>().getHarvestsOfDate(selectedDate.toString());
    _refreshController.refreshCompleted();
    if(mounted)setState(() {});
  }

  @override
  void initState() {

    super.initState();
  }

  @override
  void dispose() {
    FlutterNfcReader.stop().catchError(print);
    super.dispose();
  }

  showHarvestTaskDialog({HTask task}){
    List<HContainer> containers = context.read<HarvestModel>().containers;
    if(containers.isEmpty){
      showMessage(S.of(context).addContainers);
      return null;
    }
    List<Field> fields = context.read<HarvestModel>().fields;
    if(fields.isEmpty){
      showMessage(S.of(context).addFields);
      return null;
    }
    HContainer selectedContainer;
    Field selectedField;
    bool isUpdating = false;
    if(task==null){
      selectedContainer = containers[0];
      selectedField = fields[0];
    }else{
      selectedContainer = task.container;
      selectedField = task.field;
    }
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_context){
        return AlertDialog(
            title: Text(task==null?S.of(context).createNewTask:S.of(context).updateTask,textAlign: TextAlign.center,),
            content:StatefulBuilder(
              builder: (_,setState)=>Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(S.of(context).field),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black54),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 8.0,vertical: 4),
                      clipBehavior: Clip.hardEdge,
                      child: DropdownButton<Field>(
                        items: fields.map((Field value) {
                          return DropdownMenuItem<Field>(
                            value: value,
                            child: Text('${value.name}, ${value.crop} , ${value.cropVariety}',style: TextStyle(fontSize: 18),),
                          );
                        }).toList(),
                        value: fields.firstWhere((f) => f.id == selectedField.id,orElse: ()=>null),
                        isExpanded: true,
                        isDense: true,
                        underline: SizedBox(),
                        onChanged: (f) {
                          setState((){
                            selectedField = f;
                          });
                        },
                      ),
                    ),
                    SizedBox(height: 8,),
                    Text(S.of(context).container),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black54),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 8.0,vertical: 4),
                      clipBehavior: Clip.hardEdge,
                      child: DropdownButton<HContainer>(
                        items: containers.map((HContainer value) {
                          return new DropdownMenuItem<HContainer>(
                            value: value,
                            child: new Text(value.name,style: TextStyle(fontSize: 18),),
                          );
                        }).toList(),
                        isExpanded: true,
                        isDense: true,
                        underline: SizedBox(),
                        value: containers.firstWhere((c) =>c.id == selectedContainer.id,orElse: ()=>null),
                        onChanged: (c) {
                          setState((){
                            selectedContainer = c;
                          });
                        },
                      ),
                    ),
                    SizedBox(height: 16,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        RaisedButton(
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: isUpdating
                                ?SizedBox( height: 14,width: 14,child: CircularProgressIndicator(backgroundColor: Colors.white,))
                                :Text(S.of(context).save.toUpperCase(),style: TextStyle(color: Colors.white),),
                          ),
                          color: Color(primaryColor),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          onPressed: ()async{
                            if(!isUpdating){
                              if(task!=null){
                                task.field = selectedField;
                                task.container = selectedContainer;
                              }else{
                                task = HTask(field: selectedField,container: selectedContainer, containerId: selectedContainer.id,fieldId: selectedField.id);
                              }
                              setState((){isUpdating = true;});
                              String result = await context.read<HarvestModel>().createOrUpdateTask(task);
                              setState((){isUpdating = false;});
                              if(result!=null){
                                showMessage(result);
                              }
                              Navigator.pop(_context);
                            }
                          },
                        ),
                        RaisedButton(
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Text(S.of(context).close.toUpperCase(),style: TextStyle(color: Colors.white),),
                          ),
                          onPressed: ()async{
                            if(!isUpdating)Navigator.pop(_context);
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

  confirmDeleteTaskDialog(HTask task){
    bool isDeleting = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_context){
        return AlertDialog(
            title: Text(S.of(context).deleteTaskConfirm,textAlign: TextAlign.center,),
            content:StatefulBuilder(
              builder: (_,setState)=>Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        RaisedButton(
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: isDeleting?SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(),
                            ):Text(S.of(context).delete,style: TextStyle(color: Colors.white),),
                          ),
                          color: Color(primaryColor),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          onPressed: ()async{
                            if(!isDeleting){
                              setState((){isDeleting = true;});
                              String result = await context.read<HarvestModel>().deleteTask(task);
                              setState((){isDeleting = true;});
                              Navigator.pop(_context);
                              if(result!=null)showMessage(result);
                            }
                          },
                        ),
                        RaisedButton(
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Text(S.of(context).close.toUpperCase(),style: TextStyle(color: Colors.white),),
                          ),
                          onPressed: ()async{
                            if(!isDeleting)Navigator.pop(_context);
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

  _selectHarvestDate() async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        initialDatePickerMode: DatePickerMode.day,
        firstDate: DateTime(1970),
        lastDate: DateTime(2101));
    if (picked != null){
      setState(() {selectedDate = picked;});
      _refreshController.requestRefresh();
    }
  }

  _addHarvest(String nfc)async{
    try{
      if(!mounted)return;
      setState(() {isLoading=true;});
      var result = await context.read<HarvestModel>().addHarvest(task: selectedTask, date: selectedDate.toString(),nfc: nfc);
      setState(() {isLoading=false;});
      if(result!=null){
        if(result is Harvest){
          harvests.add(result);
          if(mounted)setState(() {});
        }else{
          showMessage(result.toString());
        }
      }
      _startNfcRead();
    }catch(e){
      print('[_addHarvest]$e');
      showMessage(e.toString());
      setState(() {isLoading=false;});
    }
  }

  _startNfcRead()async{
    if(isLoading)return;
    // await FlutterNfcReader.stop();
    FlutterNfcReader.read().then((NfcData data)async{
      if(data!=null){
        print([data.id,data.content]);
        if(data.id!=null && data.id.isNotEmpty){
          _addHarvest(data.id);
        }else if(data.content!=null && data.content.isNotEmpty){
          _addHarvest(data.content);
        }
      }
    }).catchError((e){
      showMessage(e.message);
    });
  }


  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    List<HTask> tasks = context.watch<HarvestModel>().tasks;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(S.of(context).harvestTracking),
        backgroundColor: Color(primaryColor),
        centerTitle: true,
        actions: [
          FlatButton(
            onPressed: ()=>Navigator.push(context,MaterialPageRoute(builder: (context)=>NFCSettingPage())),
            shape: CircleBorder(),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            child: Icon(Icons.settings,color: Colors.white,size: 30,),
            minWidth: 0,
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FlatButton(
                  onPressed: (){
                    setState(() {
                      selectedDate = selectedDate.subtract(Duration(days: 1));
                    });
                    _refreshController.requestRefresh();
                  },
                  shape: CircleBorder(),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  child: Icon(Icons.arrow_back_ios_outlined,color: Colors.black,size: 30,),
                  padding: EdgeInsets.all(4),
                  minWidth: 0,
                ),
                SizedBox(width: 10,),
                MaterialButton(
                  onPressed: _selectHarvestDate,
                  padding: EdgeInsets.symmetric(vertical: 4,horizontal: 32),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0),side: BorderSide(color: Colors.black)),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  child: Text(selectedDate.toString().split(' ')[0],style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500),),
                ),
                SizedBox(width: 10,),
                FlatButton(
                  onPressed: (){
                    setState(() {
                      selectedDate = selectedDate.add(Duration(days: 1));
                    });
                    _refreshController.requestRefresh();
                  },
                  shape: CircleBorder(),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  child: Icon(Icons.arrow_forward_ios_outlined,color: Colors.black,size: 30,),
                  padding: EdgeInsets.all(4),
                  minWidth: 0,
                ),
              ],
            ),
          ),
          Card(
            shape: RoundedRectangleBorder(side: BorderSide(color: Color(primaryColor)),borderRadius: BorderRadius.circular(50)),
            elevation: 8,
            clipBehavior: Clip.hardEdge,
            child: Row(
              children: [
                Expanded(
                    child: Container(
                      height: 70,
                      child: ListView(
                        children: [
                          for(var task in tasks)
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
                                            Text(S.of(context).editContainer, style: TextStyle(color: Colors.black87),),
                                            Icon(Icons.edit, color: Colors.black87,),
                                          ],
                                        ),
                                      ),
                                      onTap: (){
                                        Navigator.pop(_context);
                                        showHarvestTaskDialog(task: task);
                                        return true;
                                      },
                                    ),
                                    CupertinoPopoverMenuItem(
                                      child: Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(S.of(context).delete, style: TextStyle(color: Colors.red),),
                                            Icon(Icons.delete, color: Colors.red,),
                                          ],
                                        ),
                                      ),
                                      onTap: (){
                                        Navigator.pop(_context);
                                        confirmDeleteTaskDialog(task);
                                        return true;
                                      },
                                    )
                                  ],
                                );
                              },
                              onTap: (){
                                return true;
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: MaterialButton(
                                  onPressed: (){
                                    setState(() {selectedTask = task;});
                                    _startNfcRead();
                                  },
                                  minWidth: 0,
                                  shape: CircleBorder(),
                                  color: selectedTask==task?Color(primaryColor):Colors.white,
                                  clipBehavior: Clip.antiAlias,
                                  padding: EdgeInsets.zero,
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  child: AspectRatio(
                                    aspectRatio: 1.0,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(task.field.name[0].toUpperCase(),style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500),),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 2),
                                          child: FittedBox(child: Text(task.field.crop,),),
                                        ),
                                        Text(task.container.name[0].toUpperCase(),style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500),),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                        scrollDirection: Axis.horizontal,
                      ),
                    )
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: MaterialButton(
                    onPressed: (){showHarvestTaskDialog();},
                    height: 70,
                    minWidth: 0,
                    shape: CircleBorder(),
                    color: Color(primaryColor),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    child: Icon(Icons.add),
                  ),
                )
              ],
            ),
          ),
          Container(
            height: isBigNFCImage?width-200:120,
            child: isLoading?CircularProgressIndicator():Image.asset('assets/images/nfc.png',color: Color(primaryColor),),
            alignment: Alignment.center,
          ),
          InkWell(
            onTap: (){setState(() {isBigNFCImage=!isBigNFCImage;});},
            child: Icon(isBigNFCImage?Icons.keyboard_arrow_up_outlined:Icons.keyboard_arrow_down_outlined),
          ),
          Expanded(
            child: Column(
              children: [
                Container(
                  color: Color(primaryColor),
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                          child: Text(S.of(context).employee,style: TextStyle(fontWeight: FontWeight.w500),textAlign: TextAlign.center,)
                      ),
                      Expanded(
                          flex: 1,
                          child: Text(S.of(context).field,style: TextStyle(fontWeight: FontWeight.w500),textAlign: TextAlign.center,)
                      ),
                      Expanded(
                          flex: 1,
                          child: Text(S.of(context).container,style: TextStyle(fontWeight: FontWeight.w500),textAlign: TextAlign.center,)
                      ),
                      Expanded(
                          flex: 1,
                          child: Text(S.of(context).quantity,style: TextStyle(fontWeight: FontWeight.w500),textAlign: TextAlign.center,)
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SmartRefresher(
                    enablePullDown: true,
                    enablePullUp: false,
                    header: WaterDropMaterialHeader(backgroundColor: Color(primaryColor)),
                    controller: _refreshController,
                    onRefresh: _onRefresh,
                    child: ListView(
                      children: [
                        for(var harvest in harvests)
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.5),
                                  spreadRadius: 1,
                                  blurRadius: 1,
                                  offset: Offset(0, 1),
                                )
                              ]
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                    flex: 1,
                                    child: Text(harvest.user.name,style: TextStyle(fontWeight: FontWeight.w500),textAlign: TextAlign.center,)
                                ),
                                Expanded(
                                    flex: 1,
                                    child: Text(harvest.field.name,style: TextStyle(fontWeight: FontWeight.w500),textAlign: TextAlign.center,)
                                ),
                                Expanded(
                                    flex: 1,
                                    child: Text(harvest.container.name,style: TextStyle(fontWeight: FontWeight.w500),textAlign: TextAlign.center,)
                                ),
                                Expanded(
                                    flex: 1,
                                    child: Text(harvest.quantity.toString(),style: TextStyle(fontWeight: FontWeight.w500),textAlign: TextAlign.center,)
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

}