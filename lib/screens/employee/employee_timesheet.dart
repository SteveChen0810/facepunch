import 'package:cached_network_image/cached_network_image.dart';
import 'package:facepunch/lang/l10n.dart';
import 'package:facepunch/models/app_const.dart';
import 'package:facepunch/models/revision_model.dart';
import 'package:facepunch/models/user_model.dart';
import 'package:facepunch/models/work_model.dart';
import 'package:facepunch/screens/home_page.dart';
import 'package:facepunch/widgets/calendar_strip/calendar_strip.dart';
import 'package:facepunch/widgets/calendar_strip/date-utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class EmployeeTimeSheet extends StatefulWidget {

  @override
  _EmployeeTimeSheetState createState() => _EmployeeTimeSheetState();
}

class _EmployeeTimeSheetState extends State<EmployeeTimeSheet> {
  DateTime startDate = DateTime.parse("${DateTime.now().year}-01-01");
  DateTime endDate = DateTime.parse("${DateTime.now().year}-12-31");
  DateTime selectedDate = DateTime.now();
  User user;
  DateTime startOfWeek = PunchDateUtils.getStartOfCurrentWeek(DateTime.now());
  Map<String, List<Punch>> selectedPunches = {};
  RefreshController _refreshController;
  List<Project> projects;
  List<ScheduleTask> tasks;

  @override
  void initState() {
    super.initState();
    user = context.read<UserModel>().user;
    if(user.punches==null || user.punches.isEmpty){
      _refreshController = RefreshController(initialRefresh: true);
    }else{
      _refreshController = RefreshController(initialRefresh: false);
      selectedPunches = user.getPunchesGroupOfWeek(startOfWeek);
    }
  }

  onSelect(date) {
    List<Punch> punchesOfDate = user.getPunchesOfDate(date);
    selectedPunches = {'${date.toString()}':punchesOfDate};
    setState(() { selectedDate = date;});
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


  String punchName(Punch p){
    if(p.punch=='Lunch'){
      return "${S.of(context).lunchBreakFrom} ${PunchDateUtils.getTimeString(DateTime.parse(p.createdAt))} ${S.of(context).to} ${PunchDateUtils.getTimeString(DateTime.parse(p.updatedAt))}";
    }
    return "${S.of(context).punch} ${p.punch} ${S.of(context).at} ${PunchDateUtils.getTimeString(DateTime.parse(p.createdAt))}";
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
              InkWell(
                onTap: (){
                  showPunchRevisionDialog(punches[i]);
                },
                child: Container(
                    padding: EdgeInsets.symmetric(vertical: 6),
                    width: MediaQuery.of(context).size.width,
                    child: Text(
                      punchName(punches[i]),
                      style: logStyle,
                    )
                ),
              )
          );
          if(punches[i].punch=='In'){
            final works = user.worksOfPunch(punches[i], (i+1)>=punches.length?null:punches[i+1]);
            works.forEach((work) {
              log.add(InkWell(
                onTap: ()=>showWorkRevisionDialog(work),
                child: Container(
                    padding: EdgeInsets.symmetric(vertical: 6,horizontal: 6),
                    width: MediaQuery.of(context).size.width,
                    child: Text(
                      workName(work),
                      style: TextStyle(fontStyle: FontStyle.italic),
                    )
                ),
              ));
            });
          }
        }
        if(punches.length>1){
          log.add(
              Text(
                "${S.of(context).total} ${user.getHoursOfDate(DateTime.parse(key)).toStringAsFixed(1)} ${S.of(context).hours} - ${user.getLunchBreakTime(DateTime.parse(key)).toStringAsFixed(1)} ${S.of(context).hoursForLunch} = ${(user.getHoursOfDate(DateTime.parse(key))- user.getLunchBreakTime(DateTime.parse(key))).toStringAsFixed(1)} ${S.of(context).hours}",
                style: TextStyle(color: Color(primaryColor),fontWeight: FontWeight.bold,fontSize: 16),
              )
          );
        }
        logs.add(
            Container(
              decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.grey,))
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: log.reversed.toList(),
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

  showPunchRevisionDialog(Punch punch){
    String correctTime = punch.punch=="Lunch"?punch.updatedAt:punch.createdAt;
    bool _isSending = false;
    showDialog(
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
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(S.of(context).hourRevisionRequest, style: TextStyle(color: Colors.black87,fontWeight: FontWeight.bold,fontSize: 18),),
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
                            await sendPunchRevisionRequest(punch.id, correctTime, punch.punch=="Lunch"?punch.updatedAt:punch.createdAt);
                            Navigator.pop(_context);
                          }
                        },
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        color: Colors.black87,
                        minWidth: MediaQuery.of(context).size.width*0.6,
                        height: 40,
                        splashColor: Color(primaryColor),
                        child: _isSending?SizedBox(height: 25,width: 25,child: CircularProgressIndicator()):Text(S.of(context).submit,style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Colors.white),),
                      ),
                    ],
                  ),
                );
              }
          ),
        ),
      )
    );
  }

  showWorkRevisionDialog(WorkHistory work){
    bool _isSending = false;
    Project project;
    ScheduleTask task;
    projects.forEach((p) {
      if(p.id==work.projectId){
        project = p;
      }
    });
    tasks.forEach((t) {
      if(t.id==work.taskId){
        task = t;
      }
    });
    String startTime = work.getStartTime().toString();
    String endTime = work.getEndTime().toString();
    showDialog(
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
                        Center(child: Text(S.of(context).hourRevisionRequest,style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500),)),
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
                                child: Text(value.name,style: TextStyle(fontSize: 18),),
                              );
                            }).toList(),
                            value: project,
                            isExpanded: true,
                            isDense: true,
                            underline: SizedBox(),
                            onChanged: (v) {
                              _setState((){
                                project = v;
                              });
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
                                child: Text(value.name,style: TextStyle(fontSize: 18),),
                              );
                            }).toList(),
                            value: task,
                            isExpanded: true,
                            isDense: true,
                            underline: SizedBox(),
                            onChanged: (v) {
                              _setState((){task = v;});
                            },
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(S.of(context).startTime+' : ',style: TextStyle(fontSize: 12),),
                            Text("${PunchDateUtils.getTimeString(DateTime.parse(startTime))}"),
                            FlatButton(
                                onPressed: ()async{
                                  DateTime pickedTime = await _selectTime(startTime);
                                  if(pickedTime!=null){
                                    _setState(() { startTime = pickedTime.toString();});
                                  }
                                },
                                shape: CircleBorder(),
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                padding: EdgeInsets.zero,
                                child: Icon(Icons.edit,color: Color(primaryColor))
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(S.of(context).endTime+' : ',style: TextStyle(fontSize: 12),),
                            Text("${PunchDateUtils.getTimeString(DateTime.parse(endTime))}"),
                            FlatButton(
                                onPressed: ()async{
                                  DateTime pickedTime = await _selectTime(endTime);
                                  if(pickedTime!=null){
                                    _setState(() { endTime = pickedTime.toString();});
                                  }
                                },
                                shape: CircleBorder(),
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                padding: EdgeInsets.zero,
                                child: Icon(Icons.edit,color: Color(primaryColor))
                            ),
                          ],
                        ),
                        SizedBox(height: 20,),
                        Center(
                          child: MaterialButton(
                            onPressed: task==null?null:()async{
                              if(!_isSending){
                                _setState(() { _isSending=true; });
                                await sendWorkRevisionRequest(work, WorkHistory(
                                    userId: work.userId,
                                    taskId: task?.id,
                                    projectId: project.id,
                                    end: PunchDateUtils.getTimeSecondString(DateTime.parse(endTime)),
                                    start: PunchDateUtils.getTimeSecondString(DateTime.parse(startTime)),
                                    projectName: project.name,
                                    taskName: task.name
                                  )
                                );
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

  sendPunchRevisionRequest(int punchId, String newValue, String oldValue)async{
    String result = await context.read<RevisionModel>().sendPunchRevisionRequest(punchId: punchId,newValue: newValue, oldValue:oldValue);
    Scaffold.of(context).showSnackBar(SnackBar(content: Text(result)));
  }

  sendWorkRevisionRequest(WorkHistory oldWork, WorkHistory newWork)async{
    String result = await context.read<RevisionModel>().sendWorkRevisionRequest(newWork: newWork, oldWork: oldWork);
    Scaffold.of(context).showSnackBar(SnackBar(content: Text(result)));
  }

  void _onRefresh() async{
    await context.read<UserModel>().getUserPunches();
    await context.read<UserModel>().getUserWorkHistory();
    selectedPunches = user.getPunchesGroupOfWeek(startOfWeek);
    _refreshController.refreshCompleted();
    if(mounted)setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    Punch currentPunch = user.getTodayPunch();
    projects = context.watch<WorkModel>().projects;
    tasks = context.watch<WorkModel>().tasks;

    return Container(
      child: Column(
        children: [
          Container(
            width: width,
            height: height*0.4,
            child: Stack(
              children: [
                Positioned(
                  bottom: 40,
                  left: -width/2,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(blurRadius: 5, color: Colors.grey, spreadRadius: 3)],
                    ),
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: width,
                    ),
                  ),
                ),
                ClipOval(
                  clipper: TopBackgroundClipper(width: width, height: -(width-height*0.4+150)),
                  child: Container(
                    width: width,
                    height: height*0.4,
                    decoration: BoxDecoration(
                        color: Color(primaryColor),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 85,
                    child: Center(
                      child: ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: "${AppConst.domainURL}images/user_avatars/${user.avatar}",
                          height: 150,
                          width: 150,
                          alignment: Alignment.center,
                          placeholder: (_,__)=>Container(
                            color: Colors.white,
                              child: Image.asset("assets/images/person.png",width: 150,height: 150,)
                          ),
                          errorWidget: (_,__,___)=>Container(
                              color: Colors.white,
                              child: Image.asset("assets/images/person.png",width: 150,height: 150,)
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 5,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey,
                          border: Border.all(color: Colors.white,width: 2)
                        ),
                        alignment: Alignment.center,
                        height: 70,
                        width: 70,
                        margin: EdgeInsets.only(bottom: 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("${PunchDateUtils.convertHoursToString(user.getTotalHoursOfLastWeek())}H"),
                            Text("${S.of(context).week} ${PunchDateUtils.calculateCurrentWeekNumber(DateTime.now().subtract(Duration(days: 7)))}"),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(primaryColor),
                          border: Border.all(color: Colors.white,width: 2)
                        ),
                        alignment: Alignment.center,
                        height: 70,
                        width: 70,
                        child: currentPunch!=null?Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("${currentPunch.createdAt.substring(11,16)}"),
                            Text("${currentPunch.punch} ${S.of(context).time}"),
                          ],
                        ):Text(S.of(context).noPunch),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey,
                          border: Border.all(color: Colors.white,width: 2)
                        ),
                        alignment: Alignment.center,
                        height: 70,
                        width: 70,
                        margin: EdgeInsets.only(bottom: 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("${PunchDateUtils.convertHoursToString(user.getTotalHoursOfYear())}H"),
                            Text(S.of(context).total),
                          ],
                        ),
                      ),
                    ],
                  )
                ),
                Positioned(
                  top: MediaQuery.of(context).padding.top+10,
                  left: 20,
                  right: 10,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("${user.getFullName()}",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 30,color: Colors.white),),
                          Text("${user.function??''}",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18,color: Colors.white),),
                        ],
                      ),
                      IconButton(
                          icon: Icon(Icons.logout),
                          splashColor: Colors.white,
                          padding: EdgeInsets.zero,
                          iconSize: 35,
                          onPressed: ()async{
                            await context.read<UserModel>().logOut();
                            await Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>HomePage()));
                          }
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          Card(
            child: Container(
              width: width,
              padding: EdgeInsets.all(4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: [
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
                  Text("${S.of(context).totalHours}: ${PunchDateUtils.convertHoursToString(user.getTotalHoursOfWeek(startOfWeek))}H",style: TextStyle(fontWeight: FontWeight.bold),),
                ],
              ),
            ),
          ),
          Expanded(
            child: Card(
              child: Container(
                width: width,
                padding: EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(S.of(context).logs),
                    Expanded(
                        child: SmartRefresher(
                          enablePullDown: true,
                          enablePullUp: false,
                          header: WaterDropMaterialHeader(backgroundColor: Color(primaryColor),distance: 20,),
                          controller: _refreshController,
                          onRefresh: _onRefresh,
                          child: ListView(
                            padding: EdgeInsets.symmetric(vertical: 2),
                            children: employeeLogs(),
                          ),
                        )
                    ),
                    Center(child: Text("*${S.of(context).askRevision}*",style: TextStyle(color: Colors.red),)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

}

class TopBackgroundClipper extends CustomClipper<Rect> {
  final double width;
  final double height;
  TopBackgroundClipper({this.width,this.height});
  @override
  getClip(Size size) {
    var path = Rect.fromCircle(center: Offset(width/2,height) ,radius: width);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper oldClipper) {
    return true;
  }

}