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
    setState(() { startOfWeek = date;});
    _refreshController.requestRefresh();
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(monthName, style: TextStyle(fontWeight: FontWeight.bold,),),
          Text(weekNumber, style: TextStyle(fontWeight: FontWeight.bold,),)
        ],
      ),
    );
  }


  List<Widget> employeeLogs(){
    TextStyle logStyle = TextStyle(fontSize: 14);
    List<Widget> logs = [];
    selectedPunches.forEach((date, punches) {
      if(punches.isNotEmpty){
        List<Widget> punchDetail = [];
        for(var punchIn in punches){
          punchDetail.add(
              InkWell(
                onTap: (){
                  _showPunchRevisionDialog(punchIn);
                },
                child: Container(
                    padding: EdgeInsets.symmetric(vertical: 6),
                    width: MediaQuery.of(context).size.width,
                    child: Text(
                      punchIn.title(context),
                      style: logStyle,
                    )
                ),
              )
          );
          final works = user.worksOfPunch(punchIn);
          works.forEach((work) {
            punchDetail.add(InkWell(
              onTap: ()=>showWorkRevisionDialog(work),
              child: Container(
                  padding: EdgeInsets.symmetric(vertical: 6,horizontal: 6),
                  width: MediaQuery.of(context).size.width,
                  child: Text(
                    work.title(),
                    style: TextStyle(fontStyle: FontStyle.italic),
                  )
              ),
            ));
          });
          final breaks = user.breaksOfPunch(punchIn);
          breaks.forEach((b) {
            punchDetail.add(InkWell(
              onTap: (){_showBreakRevisionDialog(b);},
              child: Container(
                  padding: EdgeInsets.symmetric(vertical: 6,horizontal: 6),
                  width: MediaQuery.of(context).size.width,
                  child: Text(
                    b.getTitle(context),
                    style: TextStyle(fontStyle: FontStyle.italic),
                  )
              ),
            ));
          });

          Punch punchOut = user.getPunchOut(punchIn);
          if(punchOut != null){
            punchDetail.add(
                InkWell(
                  onTap: (){
                    _showPunchRevisionDialog(punchOut);
                  },
                  child: Container(
                      padding: EdgeInsets.symmetric(vertical: 6),
                      width: MediaQuery.of(context).size.width,
                      child: Text(
                        punchOut.title(context),
                        style: logStyle,
                      )
                  ),
                )
            );
          }
        }

        punchDetail.add(
            Text(
              "${S.of(context).total}: ${user.getHoursOfDate(DateTime.parse(date)).toStringAsFixed(2)} - ${user.getBreakTime(DateTime.parse(date)).toStringAsFixed(2)} (${S.of(context).breaks}) = ${(user.getHoursOfDate(DateTime.parse(date))- user.getBreakTime(DateTime.parse(date))).toStringAsFixed(2)} h",
              style: TextStyle(color: Color(primaryColor),fontWeight: FontWeight.bold,fontSize: 16),
            )
        );
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
                      child: Text("${PunchDateUtils.getDateString(DateTime.parse(date))}",style: TextStyle(fontWeight: FontWeight.bold),)
                  ),
                  Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: punchDetail.reversed.toList(),
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

  _showPunchRevisionDialog(Punch punch){
    String correctTime = punch.createdAt;
    String description = '';
    String errorMessage;
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
                          Text("${S.of(context).correctPunchTime}: "),
                          Text("${PunchDateUtils.getTimeString(DateTime.parse(correctTime))}",style: TextStyle(fontWeight: FontWeight.bold),),
                          FlatButton(
                              onPressed: ()async{
                                FocusScope.of(context).requestFocus(FocusNode());
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
                      TextField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          isDense: true,
                          labelText: S.of(context).description,
                          alignLabelWithHint: true,
                          errorText: errorMessage
                        ),
                        minLines: 3,
                        maxLines: null,
                        onChanged: (v){
                          _setState(() {description = v;});
                        },
                      ),
                      SizedBox(height: 8,),
                      MaterialButton(
                        onPressed: ()async{
                          if(!_isSending){
                            if(description.isNotEmpty){
                              _setState(() { _isSending=true; });
                              await _sendPunchRevisionRequest(punch.id, correctTime, punch.createdAt, description);
                              Navigator.pop(_context);
                            }else{
                              _setState(() {
                                errorMessage = S.of(context).youMustWriteDescription;
                              });
                            }
                          }
                        },
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        color: Colors.black87,
                        minWidth: MediaQuery.of(context).size.width*0.6,
                        height: 40,
                        splashColor: Color(primaryColor),
                        child: _isSending
                            ?SizedBox(height: 25,width: 25,child: CircularProgressIndicator(strokeWidth: 2,))
                            :Text(S.of(context).submit,style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Colors.white),),
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

  _showBreakRevisionDialog(EmployeeBreak employeeBreak){
    EmployeeBreak newBreak = EmployeeBreak.fromJson(employeeBreak.toJson());
    String description = '';
    String errorMessage;
    bool _isSending = false;
    TextEditingController _length = TextEditingController(text: newBreak.length.toString());
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
                            Text("${S.of(context).correctBreakTime}: "),
                            Text("${PunchDateUtils.getTimeString(DateTime.parse(newBreak.start))}",style: TextStyle(fontWeight: FontWeight.bold),),
                            FlatButton(
                                onPressed: ()async{
                                  FocusScope.of(context).requestFocus(FocusNode());
                                  DateTime pickedTime = await _selectTime(newBreak.start);
                                  if(pickedTime!=null){
                                    _setState(() { newBreak.start = pickedTime.toString();});
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
                        TextField(
                          key: Key('break_length_input_${newBreak.id}'),
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              isDense: true,
                              labelText: "${S.of(context).length} (m)",
                              alignLabelWithHint: true
                          ),
                          keyboardType: TextInputType.number,
                          controller: _length,
                          onChanged: (v){
                            _setState(() {
                              try{
                                newBreak.length = int.parse(v);
                                errorMessage = null;
                              }catch(e){
                                errorMessage = S.of(context).invalidBreakLength;
                                newBreak.length = 0;
                              }
                            });
                          },
                        ),
                        SizedBox(height: 8,),
                        TextField(
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              isDense: true,
                              labelText: S.of(context).description,
                              alignLabelWithHint: true,
                              errorText: errorMessage
                          ),
                          minLines: 3,
                          maxLines: null,
                          onChanged: (v){
                            _setState(() { description = v;});
                          },
                        ),
                        SizedBox(height: 8,),
                        MaterialButton(
                          onPressed: ()async{
                            if(!_isSending){
                              if(description.isEmpty){
                                _setState(() {
                                  errorMessage = S.of(context).youMustWriteDescription;
                                });
                                return;
                              }
                              if(newBreak.length == 0){
                                _setState(() {
                                  errorMessage = S.of(context).breakLengthCanNotBeZero;
                                });
                                return;
                              }
                              _setState(() { _isSending=true; });
                              await _sendBreakRevisionRequest(
                                  oldBreak: employeeBreak,
                                  newBreak: newBreak,
                                  description: description
                              );
                              Navigator.pop(_context);
                            }
                          },
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          color: Colors.black87,
                          minWidth: MediaQuery.of(context).size.width*0.6,
                          height: 40,
                          splashColor: Color(primaryColor),
                          child: _isSending
                              ?SizedBox(height: 25,width: 25,child: CircularProgressIndicator(strokeWidth: 2,))
                              :Text(S.of(context).submit,style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Colors.white),),
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
    WorkHistory newWork = WorkHistory.fromJson(work.toJson());
    String description = '';
    String errorMessage;

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
                            value: projects.firstWhere((p) => p.id == newWork.projectId, orElse: ()=>null),
                            isExpanded: true,
                            isDense: true,
                            underline: SizedBox(),
                            onChanged: (v) {
                              _setState((){
                                newWork.projectId = v.id;
                              });
                            },
                          ),
                        ),
                        SizedBox(height: 6,),
                        Text(S.of(context).task, style: TextStyle(fontSize: 12),),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black54),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 16.0,vertical: 4),
                          clipBehavior: Clip.hardEdge,
                          margin: EdgeInsets.only(top: 4),
                          child: DropdownButton<ScheduleTask>(
                            items: tasks.map((ScheduleTask value) {
                              return DropdownMenuItem<ScheduleTask>(
                                value: value,
                                child: Text(value.name,style: TextStyle(fontSize: 18),),
                              );
                            }).toList(),
                            value: tasks.firstWhere((t) => t.id == newWork.taskId, orElse: ()=>null),
                            isExpanded: true,
                            isDense: true,
                            underline: SizedBox(),
                            onChanged: (v) {
                              _setState((){newWork.taskId = v.id;});
                            },
                          ),
                        ),
                        SizedBox(height: 6,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(S.of(context).startTime+' : ',style: TextStyle(fontSize: 12),),
                            Text("${PunchDateUtils.getTimeString(DateTime.parse(newWork.start))}"),
                            FlatButton(
                                onPressed: ()async{
                                  DateTime pickedTime = await _selectTime(newWork.start);
                                  if(pickedTime!=null){
                                    _setState(() { newWork.start = pickedTime.toString();});
                                  }
                                },
                                shape: CircleBorder(),
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                padding: EdgeInsets.zero,
                                child: Icon(Icons.edit,color: Color(primaryColor))
                            ),
                          ],
                        ),
                        SizedBox(height: 6,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(S.of(context).endTime+' : ',style: TextStyle(fontSize: 12),),
                            Text("${PunchDateUtils.getTimeString(DateTime.parse(newWork.end))}"),
                            FlatButton(
                                onPressed: ()async{
                                  DateTime pickedTime = await _selectTime(newWork.end);
                                  if(pickedTime!=null){
                                    _setState(() { newWork.end = pickedTime.toString();});
                                  }
                                },
                                shape: CircleBorder(),
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                padding: EdgeInsets.zero,
                                child: Icon(Icons.edit,color: Color(primaryColor))
                            ),
                          ],
                        ),
                        SizedBox(height: 8,),
                        TextField(
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              isDense: true,
                              labelText: S.of(context).description,
                              alignLabelWithHint: true,
                              errorText: errorMessage
                          ),
                          minLines: 3,
                          maxLines: null,
                          onChanged: (v){
                            _setState(() {description = v;});
                          },
                        ),
                        SizedBox(height: 20,),
                        Center(
                          child: MaterialButton(
                            onPressed: ()async{
                              if(!_isSending){
                                if(newWork.projectId == null){
                                  _setState(() { errorMessage = S.of(context).selectProject;});
                                  return null;
                                }
                                if(newWork.taskId == null){
                                  _setState(() { errorMessage = S.of(context).selectTask;});
                                  return null;
                                }
                                if(description.isNotEmpty){
                                  _setState(() { _isSending=true; });
                                  await sendWorkRevisionRequest(work, newWork, description);
                                  Navigator.pop(_context);
                                }else{
                                  _setState(() { errorMessage = S.of(context).youMustWriteDescription; });
                                }
                              }
                            },
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            color: Colors.black87,
                            height: 40,
                            minWidth: MediaQuery.of(context).size.width*0.6,
                            child: _isSending
                                ?SizedBox(height: 25,width: 25,child: CircularProgressIndicator(strokeWidth: 2,))
                                :Text(S.of(context).submit,style: TextStyle(fontSize: 20,color: Colors.white),),
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

  _sendPunchRevisionRequest(int punchId, String newValue, String oldValue, String description)async{
    String result = await context.read<RevisionModel>().sendPunchRevisionRequest(
        punchId: punchId,
        newValue: newValue,
        oldValue:oldValue,
        description: description
    );
    _showMessage(result);
  }

  _sendBreakRevisionRequest({EmployeeBreak oldBreak, EmployeeBreak newBreak, String description})async{
    String result = await context.read<RevisionModel>().sendBreakRevisionRequest(
        oldBreak: oldBreak,
        newBreak:newBreak,
        description: description
    );
    _showMessage(result);
  }

  sendWorkRevisionRequest(WorkHistory oldWork, WorkHistory newWork, String description)async{
    String result = await context.read<RevisionModel>().sendWorkRevisionRequest(
        newWork: newWork,
        oldWork: oldWork,
        description: description
    );
    _showMessage(result);
  }

  _showMessage(String message){
    Scaffold.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _onRefresh() async{
    try{
      await context.read<UserModel>().getUserTimeSheetData(startOfWeek);
      selectedPunches = user.getPunchesGroupOfWeek(startOfWeek);
      _refreshController.refreshCompleted();
      if(mounted)setState(() {});
    }catch(e){
      print('[EmployeeTimeSheet._onRefresh]$e');
    }
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
                            Text("${PunchDateUtils.convertHoursToString(user.getTotalHoursOfLastWeek())}H",
                              style: TextStyle(fontSize: 12),
                            ),
                            Text("${S.of(context).week} ${PunchDateUtils.calculateCurrentWeekNumber(DateTime.now().subtract(Duration(days: 7)))}",
                                style: TextStyle(fontSize: 12)
                            ),
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
                            Text("${currentPunch.createdAt.substring(11,16)}",style: TextStyle(fontSize: 12)),
                            Text("${currentPunch.punch} ${S.of(context).time}",style: TextStyle(fontSize: 12)),
                          ],
                        ):Text(S.of(context).noPunch,style: TextStyle(fontSize: 12)),
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
                            Text("${PunchDateUtils.convertHoursToString(context.watch<UserModel>().yearTotalHours)}H", style: TextStyle(fontSize: 12)),
                            Text(S.of(context).total,style: TextStyle(fontSize: 12)),
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
                      Text("${user.getFullName()}",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20,color: Colors.white),),
                      IconButton(
                          icon: Icon(Icons.logout),
                          splashColor: Colors.white,
                          padding: EdgeInsets.zero,
                          iconSize: 25,
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
                  Text("${S.of(context).totalHours}: ${PunchDateUtils.convertHoursToString(user.getTotalHoursOfWeek(startOfWeek))}H",
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
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