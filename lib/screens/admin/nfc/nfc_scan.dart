import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:collection/collection.dart';

import '/lang/l10n.dart';
import '/models/app_const.dart';
import '/models/harvest_model.dart';
import '/screens/admin/nfc/nfc_settings.dart';
import '/widgets/dialogs.dart';
import '/widgets/utils.dart';
import '/widgets/popover/cool_ui.dart';


class NFCScanPage extends StatefulWidget{

  @override
  _NFCScanPageState createState() => _NFCScanPageState();
}

class _NFCScanPageState extends State<NFCScanPage>{

  bool isBigNFCImage = true;
  DateTime selectedDate = DateTime.now();
  HTask? selectedTask;
  HTask? _deletingTask;
  List<Harvest> harvests = [];
  RefreshController _refreshController = RefreshController(initialRefresh: true);
  bool isLoading = false;
  List<HTask> tasks = [];

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
    NfcManager.instance.stopSession().catchError((e){
      Tools.consoleLog('[NFCScanPage.NfcManager.instance.stopSession]$e');
    });
    super.dispose();
  }

  showHarvestTaskDialog(HTask? task){
    List<HContainer> containers = context.read<HarvestModel>().containers;
    if(containers.isEmpty){
      Tools.showErrorMessage(context, S.of(context).addContainers);
      return null;
    }
    List<Field> fields = context.read<HarvestModel>().fields;
    if(fields.isEmpty){
      Tools.showErrorMessage(context, S.of(context).addFields);
      return null;
    }
    HContainer selectedContainer;
    Field selectedField;
    bool isUpdating = false;
    if(task == null){
      selectedContainer = containers[0];
      selectedField = fields[0];
    }else{
      selectedContainer = task.container!;
      selectedField = task.field!;
    }
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_context){
        return AlertDialog(
            title: Text(task==null?S.of(context).createNewTask:S.of(context).updateTask,textAlign: TextAlign.center,),
            contentPadding: EdgeInsets.all(8),
            insetPadding: EdgeInsets.zero,
            content:StatefulBuilder(
              builder: (_,setState)=>Container(
                width: MediaQuery.of(context).size.width-40,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(S.of(context).field),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black54),
                        borderRadius: BorderRadius.circular(4),
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
                        value: fields.firstWhereOrNull((f) => f.id == selectedField.id),
                        isExpanded: true,
                        isDense: true,
                        underline: SizedBox(),
                        onChanged: (f) {
                          setState((){
                            if(f != null){
                              selectedField = f;
                            }
                          });
                        },
                      ),
                    ),
                    SizedBox(height: 8,),
                    Text(S.of(context).container),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black54),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 8.0,vertical: 4),
                      clipBehavior: Clip.hardEdge,
                      child: DropdownButton<HContainer>(
                        items: containers.map((HContainer value) {
                          return new DropdownMenuItem<HContainer>(
                            value: value,
                            child: new Text('${value.name}',style: TextStyle(fontSize: 18),),
                          );
                        }).toList(),
                        isExpanded: true,
                        isDense: true,
                        underline: SizedBox(),
                        value: containers.firstWhereOrNull((c) =>c.id == selectedContainer.id),
                        onChanged: (c) {
                          setState((){
                            if(c != null){
                              selectedContainer = c;
                            }
                          });
                        },
                      ),
                    ),
                    SizedBox(height: 16,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          child: isUpdating
                              ?SizedBox( height: 20,width: 20, child: CircularProgressIndicator(strokeWidth: 2,))
                              :Text(S.of(context).save, style: TextStyle(color: Colors.green),),
                          onPressed: ()async{
                            if(!isUpdating){
                              if(task != null){
                                task!.field = selectedField;
                                task!.container = selectedContainer;
                              }else{
                                task = HTask(field: selectedField,container: selectedContainer, containerId: selectedContainer.id,fieldId: selectedField.id);
                              }
                              setState((){isUpdating = true;});
                              String? result = await context.read<HarvestModel>().createOrUpdateTask(task!);
                              setState((){isUpdating = false;});
                              if(result != null){
                                Tools.showErrorMessage(context, result);
                              }
                              Navigator.pop(_context);
                            }
                          },
                        ),
                        TextButton(
                          child: Text(S.of(context).close,style: TextStyle(color: Colors.red),),
                          onPressed: ()async{
                            if(!isUpdating)Navigator.pop(_context);
                          },
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

  _selectHarvestDate() async {
    final DateTime? picked = await showDatePicker(
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
      var result = await context.read<HarvestModel>().addHarvest(task: selectedTask!, date: selectedDate.toString(),nfc: nfc);
      setState(() {isLoading=false;});
      if(result != null){
        if(result is Harvest){
          harvests.insert(0, result);
          if(mounted)setState(() {});
        }else{
          Tools.showErrorMessage(context, result.toString());
        }
      }
      _startNfcRead();
    }catch(e){
      Tools.consoleLog('[_addHarvest]$e');
      Tools.showErrorMessage(context, e.toString());
      setState(() {isLoading=false;});
    }
  }

  _startNfcRead()async{
    if(isLoading) return;
    if(await NfcManager.instance.isAvailable()){
      NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          Tools.playSound();
          NfcManager.instance.stopSession();
          Tools.consoleLog('[NFC Scanned][${tag.data}]');
          String? nfc = Tools.getNFCIdentifier(tag.data);
          if(nfc != null){
            _addHarvest(nfc);
          }else{
            Tools.showErrorMessage(context, S.of(context).invalidNFC);
          }
        },
        alertMessage: 'NFC Scanned!',
        onError: (NfcError error)async{
          Tools.showErrorMessage(context, error.message);
        },
      ).catchError((e){
        Tools.consoleLog('[NFCScanPage._startNfcRead]$e');
      });
    }else{
      Tools.showErrorMessage(context, S.of(context).notAllowedNFC);
    }
  }

  _deleteHarvestTask(HTask task)async{
    if(await confirmDeleting(context, S.of(context).deleteTaskConfirm)){
      setState(() {
        _deletingTask = task;
      });
      String? result = await context.read<HarvestModel>().deleteTask(task);
      if(result != null){
        Tools.showErrorMessage(context, result);
      }
      if(mounted)setState(() {
        if(selectedTask == task) selectedTask = null;
        _deletingTask = null;
      });
    }
  }

  Widget _harvestTaskItem(HTask task){
    Widget child = Padding(
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
              Text('${task.field?.shortName()}',style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500),),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: FittedBox(child: Text('${task.field?.crop}',),),
              ),
              Text('${task.container?.shortName()}',style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500),),
            ],
          ),
        ),
      ),
    );
    if(_deletingTask != null && _deletingTask?.id == task.id){
      return Stack(
        alignment: Alignment.center,
        children: [
          child,
          CircularProgressIndicator(backgroundColor: Colors.red,),
        ],
      );
    }
    return CupertinoPopoverButton(
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
                showHarvestTaskDialog(task);
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
                _deleteHarvestTask(task);
                return true;
              },
            )
          ],
        );
      },
      onTap: (){
        return true;
      },
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    tasks = context.watch<HarvestModel>().tasks;

    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).harvestTracking),
        backgroundColor: Color(primaryColor),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: ()=>Navigator.push(context,MaterialPageRoute(builder: (context)=>NFCSettingPage())),
            child: Icon(Icons.settings,color: Colors.white,size: 30,),
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
                TextButton(
                  onPressed: (){
                    setState(() {
                      selectedDate = selectedDate.subtract(Duration(days: 1));
                    });
                    _refreshController.requestRefresh();
                  },
                  child: Icon(Icons.arrow_back_ios_outlined,color: Colors.black,size: 30,),
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
                TextButton(
                  onPressed: (){
                    setState(() {
                      selectedDate = selectedDate.add(Duration(days: 1));
                    });
                    _refreshController.requestRefresh();
                  },
                  child: Icon(Icons.arrow_forward_ios_outlined,color: Colors.black,size: 30,),
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
                            _harvestTaskItem(task)
                        ],
                        scrollDirection: Axis.horizontal,
                      ),
                    )
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: MaterialButton(
                    onPressed: (){showHarvestTaskDialog(null);},
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
                          Slidable(
                            endActionPane: ActionPane(
                              motion: ScrollMotion(),
                              extentRatio: 0.15,
                              children: [
                                SlidableAction(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  icon: Icons.delete,
                                  onPressed: (c)async{
                                    if(await confirmDeleting(context, S.of(context).deleteHarvestConfirm)){
                                      setState(() {harvests.remove(harvest);});
                                      context.read<HarvestModel>().deleteHarvest(harvest.id).then((message){
                                        if(mounted && message!=null && (message is String)){
                                          Tools.showErrorMessage(context, message);
                                        }
                                      });
                                    }
                                  },
                                )
                              ],
                            ),
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border(bottom: BorderSide(color: Colors.grey))
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                      flex: 1,
                                      child: Text('${harvest.user?.name}', style: TextStyle(fontWeight: FontWeight.w500),textAlign: TextAlign.center,)
                                  ),
                                  Expanded(
                                      flex: 1,
                                      child: Text('${harvest.field?.name}', style: TextStyle(fontWeight: FontWeight.w500),textAlign: TextAlign.center,)
                                  ),
                                  Expanded(
                                      flex: 1,
                                      child: Text('${harvest.container?.name}', style: TextStyle(fontWeight: FontWeight.w500),textAlign: TextAlign.center,)
                                  ),
                                  Expanded(
                                      flex: 1,
                                      child: Text('${harvest.quantity}', style: TextStyle(fontWeight: FontWeight.w500),textAlign: TextAlign.center,)
                                  ),
                                ],
                              ),
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