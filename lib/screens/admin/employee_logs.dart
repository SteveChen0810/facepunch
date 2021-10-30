import 'package:facepunch/lang/l10n.dart';
import 'package:facepunch/models/company_model.dart';
import 'package:facepunch/models/work_model.dart';
import 'package:facepunch/screens/admin/pdf_full_screen.dart';
import 'package:facepunch/widgets/calendar_strip/calendar_strip.dart';
import 'package:facepunch/widgets/calendar_strip/date-utils.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../models/app_const.dart';
import '../../models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';

class EmployeeLogs extends StatefulWidget {

  final User employee;
  final double longitude;
  final double latitude;

  EmployeeLogs({this.employee,this.longitude,this.latitude});

  @override
  _EmployeeLogsState createState() => _EmployeeLogsState();
}

class _EmployeeLogsState extends State<EmployeeLogs> {
  RefreshController _refreshController;
  Map<String, List<Punch>> selectedPunches = {};
  DateTime startDate = DateTime.parse("${DateTime.now().year}-01-01");
  DateTime endDate = DateTime.parse("${DateTime.now().year}-12-31");
  DateTime selectedDate = DateTime.now();
  User user;
  DateTime startOfWeek = PunchDateUtils.getStartOfCurrentWeek(DateTime.now());
  Completer<GoogleMapController> _mapController = Completer();
  CameraPosition _currentPosition ;
  Set<Marker> markers = {};
  Punch deletingPunch;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  CompanySettings settings;
  List<Project> projects;
  List<ScheduleTask> tasks;

  @override
  void initState() {
    super.initState();
    user = widget.employee;
    _currentPosition = CameraPosition(
      target: LatLng(widget.latitude??45.25034183122973, widget.longitude??-74.30415472179874),
      zoom: 18.0,
    );
    _refreshController = RefreshController(initialRefresh: true);
  }

  void _onRefresh() async{
    await context.read<UserModel>().getEmployeeTimeSheetData(startOfWeek, widget.employee);
    selectedPunches = user.getPunchesGroupOfWeek(startOfWeek);
    _refreshController.refreshCompleted();
    if(mounted)setState(() {});
  }

  onSelect(date) {
    List<Punch> punchesOfDate = user.getPunchesOfDate(date);
    selectedPunches = {'${date.toString()}':punchesOfDate};
    markers.clear();
    punchesOfDate.forEach((p) {
      if(p.latitude!=null && p.longitude!=null)
      markers.add(
          Marker(
            markerId: MarkerId("punch_marker_${p.id}"),
            position: LatLng(p.latitude, p.longitude),
            icon: BitmapDescriptor.defaultMarkerWithHue(p.punch=="Out"?BitmapDescriptor.hueRed:BitmapDescriptor.hueGreen),
            infoWindow: InfoWindow(title: "${PunchDateUtils.getTimeString(DateTime.parse(p.createdAt))}",
                snippet: "${PunchDateUtils.getDateString(DateTime.parse(p.createdAt))}",
            ),
          )
      );
    });
    setState(() { selectedDate = date;});
    if(punchesOfDate.isNotEmpty && punchesOfDate.last.latitude!=null && punchesOfDate.last.longitude!=null){
      goToPosition(LatLng(punchesOfDate.last.latitude, punchesOfDate.last.longitude));
    }
  }

  onWeekSelect(date) {
    selectedPunches = user.getPunchesGroupOfWeek(date);
    setState(() { startOfWeek = date;});
  }

  dateTileBuilder(date, selectedDate, rowIndex, dayName, isDateMarked, isDateOutOfRange) {
    bool isSelectedDate = date.compareTo(selectedDate) == 0;
    Color fontColor = isDateOutOfRange ? Colors.black26 : Colors.black87;
    TextStyle normalStyle = TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: fontColor);
    TextStyle dayNameStyle = TextStyle(fontSize: 12, color: fontColor);
    List<Widget> _children = [
      Text(dayName, style: dayNameStyle),
      Container(
          decoration: BoxDecoration(
              color: !isSelectedDate ? Colors.transparent : Color(primaryColor),
              shape: BoxShape.circle
          ),
          alignment: Alignment.center,
          padding: EdgeInsets.all(6),
          margin: EdgeInsets.symmetric(vertical: 4),
          child: Text(date.day.toString(), style: normalStyle, maxLines: 1,)
      ),
      Text("${user.getHoursOfDate(date).toStringAsFixed(2)}",style: TextStyle(fontSize: 12),),
    ];
    return AnimatedContainer(
      duration: Duration(milliseconds: 150),
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: _children,
      ),
    );
  }

  Widget monthNameWidget(String weekNumber, String monthName){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(monthName,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),
          SizedBox(height: 4,),
          Text(weekNumber)
        ],
      ),
    );
  }

  String workName(WorkHistory w){
    return '${w.projectName??''} - ${w.taskName??''}: ${(w.workHour().toStringAsFixed(2))} h';
  }

  List<Widget> employeeLogs(){
    TextStyle logStyle = TextStyle(fontSize: 14);
    List<Widget> logs = [];
    selectedPunches.forEach((key, punches) {
      if(punches.isNotEmpty){
        List<Widget> log = [];
        for(int i=0; i<punches.length; i++){
          log.add(
              (deletingPunch!=null && punches[i].id==deletingPunch.id)
                  ?Center(
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: SizedBox(width: 20,height: 20,child: CircularProgressIndicator(backgroundColor: Color(primaryColor),)),
                  )
              )
                  :Slidable(
                    actionPane: SlidableDrawerActionPane(),
                    actionExtentRatio: 0.2,
                    child: Container(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        width: MediaQuery.of(context).size.width,
                        child: Text(punches[i].punch=="Lunch"?"Lunch Break from ${PunchDateUtils.getTimeString(DateTime.parse(punches[i].createdAt))} to ${PunchDateUtils.getTimeString(DateTime.parse(punches[i].updatedAt))}":"Punch ${punches[i].punch} at ${PunchDateUtils.getTimeString(DateTime.parse(punches[i].createdAt))}",style: logStyle,)
                    ),
                    secondaryActions: <Widget>[
                      if(punches[i].latitude !=null && punches[i].longitude!=null && settings.hasGeolocationPunch)
                        IconSlideAction(
                          caption: S.of(context).pin,
                          color: Colors.green,
                          iconWidget: Icon(Icons.pin_drop,color: Colors.white,size: 20,),
                          foregroundColor: Colors.white,
                          onTap: (){
                            goToPosition(LatLng(punches[i].latitude, punches[i].longitude));
                          },
                        ),
                      IconSlideAction(
                        caption: S.of(context).edit,
                        color: Colors.orange,
                        iconWidget: Icon(Icons.edit,color: Colors.white,size: 20,),
                        foregroundColor: Colors.white,
                        onTap: ()async{
                          String changedTime = await showEditPunchDialog(punches[i]);
                          if(punches[i].punch=="Lunch"){
                            punches[i].updatedAt = changedTime;
                          }else{
                            punches[i].createdAt = changedTime;
                          }
                          if(mounted)setState(() {});
                        },
                      ),
                      IconSlideAction(
                        caption: S.of(context).delete,
                        color: Colors.red,
                        foregroundColor: Colors.white,
                        iconWidget: Icon(Icons.delete,color: Colors.white,size: 20,),
                        onTap: ()async{
                          setState(() { deletingPunch = punches[i];});
                          String result = await user.deletePunch(punches[i].id);
                          if(result==null){
                            user.punches.remove(punches[i]);
                            punches.remove(punches[i]);
                          }else{
                            showMessage(result);
                          }
                          setState(() { deletingPunch = null;});
                        },
                      ),
                    ],
                  )
          );
          final works = user.worksOfPunch(punches[i]);
          works.forEach((work) {
            log.add(Slidable(
              actionPane: SlidableDrawerActionPane(),
              actionExtentRatio: 0.2,
              child: Container(
                  padding: EdgeInsets.symmetric(vertical: 6,horizontal: 6),
                  width: MediaQuery.of(context).size.width,
                  child: Text(
                    workName(work),
                    style: TextStyle(fontStyle: FontStyle.italic),
                  )
              ),
              secondaryActions: [
                IconSlideAction(
                  caption: S.of(context).edit,
                  color: Colors.orange,
                  iconWidget: Icon(Icons.edit,color: Colors.white,size: 20,),
                  foregroundColor: Colors.white,
                  onTap: ()async{
                    final w = await showEditWorkDialog(WorkHistory.fromJson(work.toJson()));
                    setState(() {
                      if(w != null){
                        user.works.removeWhere((ww) => ww.id==w.id);
                        user.works.add(w);
                      }
                    });
                  },
                ),
                IconSlideAction(
                  caption: S.of(context).delete,
                  color: Colors.red,
                  foregroundColor: Colors.white,
                  iconWidget: Icon(Icons.delete,color: Colors.white,size: 20,),
                  onTap: ()async{
                    String result = await user.deleteWork(work.id);
                    setState(() {
                      if(result==null){
                        user.works.removeWhere((w) => w.id==work.id);
                      }else{
                        showMessage(result);
                      }
                    });
                  },
                ),
              ],
            ));
          });
        }
        if(punches.length>1){
          log.add(
              Text(
                "Total ${user.getHoursOfDate(DateTime.parse(key)).toStringAsFixed(1)} Hours - ${user.getBreakTime(DateTime.parse(key)).toStringAsFixed(1)} Hours for Lunch = ${(user.getHoursOfDate(DateTime.parse(key))- user.getBreakTime(DateTime.parse(key))).toStringAsFixed(1)} Hours",
                style: TextStyle(color: Color(primaryColor),fontWeight: FontWeight.bold,fontSize: 16),
              )
          );
        }
        logs.add(
            Container(
              decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.grey,)),
              ),
              padding: EdgeInsets.all(2),
              child: Row(
                children: [
                  Expanded(
                      flex: 1,
                      child: Text("${PunchDateUtils.getDateString(DateTime.parse(key))}",style: TextStyle(fontWeight: FontWeight.bold),)
                  ),
                  Expanded(
                      flex: 3,
                      child: Container(
                        child: ClipRect(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: log.reversed.toList(),
                          ),
                        ),
                      )
                  ),
                ],
              ),
            )
        );
      }
    });
    return logs.reversed.toList();
  }

  Future<String> showEditPunchDialog(Punch punch)async{
    String correctTime = punch.punch=="Lunch"?punch.updatedAt:punch.createdAt;
    bool _isSending = false;
    await showDialog(
        context: context,
        builder:(_)=> WillPopScope(
          onWillPop: ()async{
            return !_isSending;
          },
          child: AlertDialog(
            insetPadding: EdgeInsets.zero,
            contentPadding: EdgeInsets.zero,
            content: StatefulBuilder(
                builder: (BuildContext _context, StateSetter _setState){
                  return Container(
                    width: MediaQuery.of(context).size.width-50,
                    padding: EdgeInsets.all(8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(S.of(context).editEmployeePunch, style: TextStyle(color: Colors.black87,fontWeight: FontWeight.bold,fontSize: 18),),
                        SizedBox(height: 8,),
                        Text("${PunchDateUtils.getDateString(DateTime.parse(punch.createdAt))}", style: TextStyle(color: Colors.black87,fontWeight: FontWeight.bold,fontSize: 14),),
                        SizedBox(height: 8,),
                        Row(
                          children: [
                            Text(punch.punch=="Lunch"?"${S.of(context).incorrectLunchTime}: ":"${S.of(context).incorrectPunchTime}: "),
                            Text("${PunchDateUtils.getTimeString(DateTime.parse(punch.punch=="Lunch"?punch.updatedAt:punch.createdAt))}",style: TextStyle(fontWeight: FontWeight.bold),),
                          ],
                        ),
                        SizedBox(height: 8,),
                        Row(
                          children: [
                            Text(punch.punch=="Lunch"?"${S.of(context).correctLunchTime}: ":"${S.of(context).correctPunchTime}: "),
                            Text("${PunchDateUtils.getTimeString(DateTime.parse(correctTime))}",style: TextStyle(fontWeight: FontWeight.bold),),
                            FlatButton(
                                onPressed: ()async{
                                  DateTime pickedTime = await _selectTime(correctTime);
                                  if(pickedTime!=null){
                                    _setState(() { correctTime = pickedTime.toString();});
                                  }
                                },
                                shape: CircleBorder(),
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Icon(Icons.edit,color: Color(primaryColor),),
                                )
                            ),
                          ],
                        ),
                        SizedBox(height: 8,),
                        MaterialButton(
                          onPressed: ()async{
                            if(!_isSending){
                              _setState(() { _isSending=true; });
                              String result = await user.editPunch(punch.id, correctTime);
                              if(result==null){
                                if(punch.punch=="Lunch"){
                                  punch.updatedAt = correctTime;
                                }else{
                                  punch.createdAt = correctTime;
                                }
                              }else{
                                showMessage(result);
                              }
                              Navigator.pop(_context);
                            }
                          },
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          color: Colors.black87,
                          height: 40,
                          minWidth: MediaQuery.of(context).size.width*0.6,
                          child: _isSending?SizedBox(height: 25,width: 25,child: CircularProgressIndicator()):Text("Submit",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Colors.white),),
                        ),
                      ],
                    ),
                  );
                }
            ),
          ),
        )
    );
    return punch.createdAt;
  }

  Future<WorkHistory> showEditWorkDialog(WorkHistory work)async{
    bool _isSending = false;
    bool isSuccess = false;
    await showDialog(
        context: context,
        builder:(_)=> WillPopScope(
          onWillPop: ()async{
            return !_isSending;
          },
          child: AlertDialog(
            contentPadding: EdgeInsets.zero,
            insetPadding: EdgeInsets.zero,
            content: StatefulBuilder(
                builder: (BuildContext _context, StateSetter _setState){
                  return Container(
                    width: MediaQuery.of(context).size.width-50,
                    padding: EdgeInsets.all(8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(child: Text(S.of(context).editWorkHistory,style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500),)),
                        SizedBox(height: 8,),
                        Text(S.of(context).project,style: TextStyle(fontSize: 12),),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black54),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 16.0,vertical: 4),
                          clipBehavior: Clip.hardEdge,
                          margin: EdgeInsets.only(top: 4),
                          child: DropdownButton<Project>(
                            items: projects.map((Project value) {
                              return DropdownMenuItem<Project>(
                                value: value,
                                child: Text(value.name),
                              );
                            }).toList(),
                            value: projects.firstWhere((p) => p.id==work.projectId,orElse: ()=>null),
                            isExpanded: true,
                            isDense: true,
                            underline: SizedBox(),
                            onChanged: (v) {
                              _setState((){ work.projectId = v.id; work.projectName = v.name; });
                            },
                          ),
                        ),
                        SizedBox(height: 8,),
                        Text(S.of(context).activity,style: TextStyle(fontSize: 12),),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black54),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 16.0,vertical: 4),
                          clipBehavior: Clip.hardEdge,
                          margin: EdgeInsets.only(top: 4),
                          child: DropdownButton<ScheduleTask>(
                            items:tasks.map((ScheduleTask value) {
                              return DropdownMenuItem<ScheduleTask>(
                                value: value,
                                child: Text(value.name),
                              );
                            }).toList(),
                            value: tasks.firstWhere((t) => t.id==work.taskId,orElse: ()=>null),
                            isExpanded: true,
                            isDense: true,
                            underline: SizedBox(),
                            onChanged: (v) {
                              _setState((){work.taskId = v.id; work.taskName = v.name;});
                            },
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(S.of(context).startTime+' : ',style: TextStyle(fontSize: 12),),
                            Text("${PunchDateUtils.getTimeString(DateTime.parse(work.getStartTime().toString()))}"),
                            FlatButton(
                                onPressed: ()async{
                                  DateTime pickedTime = await _selectTime(work.getStartTime().toString());
                                  if(pickedTime!=null){
                                    _setState(() { work.start = pickedTime.toString().split(' ')[1];});
                                  }
                                },
                                shape: CircleBorder(),
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                padding: EdgeInsets.all(4),
                                minWidth: 0,
                                child: Icon(Icons.edit,color: Color(primaryColor))
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(S.of(context).endTime+' : ',style: TextStyle(fontSize: 12),),
                            Text("${PunchDateUtils.getTimeString(DateTime.parse(work.getEndTime().toString()))}"),
                            FlatButton(
                                onPressed: ()async{
                                  DateTime pickedTime = await _selectTime(work.getEndTime().toString());
                                  if(pickedTime!=null){
                                    _setState(() { work.end = pickedTime.toString().split(' ')[1];});
                                  }
                                },
                                shape: CircleBorder(),
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                padding: EdgeInsets.all(4),
                                minWidth: 0,
                                child: Icon(Icons.edit,color: Color(primaryColor))
                            ),
                          ],
                        ),
                        SizedBox(height: 20,),
                        Center(
                          child: MaterialButton(
                            onPressed: ()async{
                              if(!_isSending){
                                _setState(() { _isSending=true; });
                                String result = await user.editWork(work);
                                if(result!=null){
                                  showMessage(result);
                                }else{
                                  isSuccess = true;
                                }
                                Navigator.pop(_context);
                              }
                            },
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            color: Colors.black87,
                            height: 40,
                            minWidth: MediaQuery.of(context).size.width*0.6,
                            child: _isSending
                                ?SizedBox(height: 25,width: 25,child: CircularProgressIndicator())
                                :Text(S.of(context).submit.toUpperCase(),style: TextStyle(fontSize: 20,color: Colors.white),),
                          ),
                        )
                      ],
                    ),
                  );
                }
            ),
          ),
        )
    );
    return isSuccess?work:null;
  }

  Future<DateTime> _selectTime(String createdAt)async{
    DateTime createdDate = DateTime.parse(createdAt);
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: createdDate.hour,minute: createdDate.minute),
    );
    if(picked!=null){
      return DateTime(createdDate.year,createdDate.month,createdDate.day,picked.hour,picked.minute,createdDate.second);
    }
    return null;
  }

  Future<void> goToPosition(LatLng position) async {
    final GoogleMapController controller = await _mapController.future;
    CameraPosition _cPosition = CameraPosition(target: position,zoom: 18.0);
    controller.animateCamera(CameraUpdate.newCameraPosition(_cPosition));
  }

  showMessage(String message){
    _scaffoldKey.currentState.hideCurrentSnackBar();
    _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text(message),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.red,
          action: SnackBarAction(onPressed: (){},label: S.of(context).close,textColor: Colors.white,),
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    settings = context.watch<CompanyModel>().myCompanySettings;
    projects = context.watch<WorkModel>().projects;
    tasks = context.watch<WorkModel>().tasks;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: InkWell(
          onTap: (){
            if(deletingPunch==null)Navigator.of(context).pop();
          },
          child: Icon(Icons.arrow_back),
        ),
        title: Text(S.of(context).dailyLogs),
        centerTitle: true,
        backgroundColor: Color(primaryColor),
      ),
      body: WillPopScope(
        onWillPop: ()async{
          return deletingPunch==null;
        },
        child: Container(
          margin: EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white
          ),
          clipBehavior: Clip.hardEdge,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text("${user.getFullName()}",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
                  )
              ),
              CalendarStrip(
                startDate: startDate,
                endDate: endDate,
                onDateSelected: onSelect,
                onWeekSelected: onWeekSelect,
                dateTileBuilder: dateTileBuilder,
                iconColor: Colors.black87,
                markedDates: [],
                monthNameWidget: monthNameWidget,
                leftIcon: Icon(Icons.chevron_left),
                rightIcon: Icon(Icons.chevron_right),
                addSwipeGesture: true,
                weekStartsOnSunday: true,
                selectedDate: selectedDate,
              ),
              Container(
                padding: EdgeInsets.all(8),
                child: Row(
                  children: [
                    Text("${S.of(context).totalHours}:\n ${PunchDateUtils.convertHoursToString(user.getTotalHoursOfWeek(startOfWeek))}H",style: TextStyle(fontWeight: FontWeight.bold),),
                    SizedBox(width: 100,),
                    FlatButton(
                      onPressed: ()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>PDFFullScreen(url: user.pdfUrl(startOfWeek),))),
                      shape: CircleBorder(),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        child: Column(
                          children: [
                            Image.asset("assets/images/ic_document.png",width: 30,height: 30,),
                            Text(S.of(context).timeSheet,style: TextStyle(fontSize: 10),)
                          ],
                        ),
                    )
                  ],
                )
              ),
              Expanded(
                child: Container(
                  width: width,
                  padding: EdgeInsets.all(4),
                  margin: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.black87)
                  ),
                  child: SmartRefresher(
                    enablePullDown: true,
                    enablePullUp: false,
                    header: WaterDropMaterialHeader(backgroundColor: Color(primaryColor),distance: 40,),
                    controller: _refreshController,
                    onRefresh: _onRefresh,
                    child: ListView(
                      padding: EdgeInsets.symmetric(vertical: 2),
                      children: employeeLogs(),
                    ),
                  ),
                ),
              ),
              if(settings.hasGeolocationPunch)
                Expanded(
                child: Stack(
                  children: [
                    GoogleMap(
                      mapType: MapType.hybrid,
                      initialCameraPosition: _currentPosition,
                      onMapCreated: (GoogleMapController controller) {
                        _mapController.complete(controller);
                      },
                      buildingsEnabled: false,
                      compassEnabled: false,
                      indoorViewEnabled: false,
                      liteModeEnabled: false,
                      mapToolbarEnabled: false,
                      myLocationEnabled: false,
                      myLocationButtonEnabled: false,
                      markers: markers,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.green,
                            ),
                            width: 55,
                            height: 25,
                            alignment: Alignment.center,
                            child: Text(S.of(context).iN,style: TextStyle(color: Colors.white,fontSize: 18,fontWeight: FontWeight.bold),),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.red,
                            ),
                            width: 55,
                            height: 25,
                            alignment: Alignment.center,
                            child: Text(S.of(context).out,style: TextStyle(color: Colors.white,fontSize: 18,fontWeight: FontWeight.bold),),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      backgroundColor: Color(primaryColor),
    );
  }

}