import 'package:cached_network_image/cached_network_image.dart';
import 'package:facepunch/lang/l10n.dart';
import 'package:facepunch/models/app_const.dart';
import 'package:facepunch/models/revision_model.dart';
import 'package:facepunch/models/user_model.dart';
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
    TextStyle normalStyle = TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: fontColor);
    TextStyle selectedStyle = TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.black87);
    TextStyle dayNameStyle = TextStyle(fontSize: 14.5, color: fontColor);
    List<Widget> _children = [
      Text(dayName, style: dayNameStyle),
      Container(
          decoration: BoxDecoration(
            color: !isSelectedDate ? Colors.transparent : Color(primaryColor),
            shape: BoxShape.circle
          ),
          padding: EdgeInsets.all(8),
          child: Text(date.day.toString(), style: !isSelectedDate ? normalStyle : selectedStyle,maxLines: 1,)
      ),
      Text("${user.getHoursOfDate(date).toInt()}"),
    ];
    return AnimatedContainer(
      duration: Duration(milliseconds: 150),
      alignment: Alignment.center,
      padding: EdgeInsets.all(5),
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

  List<Widget> employeeLogs(){
    TextStyle logStyle = TextStyle(fontSize: 14);
    List<Widget> logs = [];
    selectedPunches.forEach((key, punches) {
      if(punches.isNotEmpty){
        List<Widget> log = [];
        punches.forEach((p) {
          log.add(
              InkWell(
                onTap: (){
                  showRevisionDialog(p);
                },
                child: Container(
                    padding: EdgeInsets.symmetric(vertical: 6),
                    width: MediaQuery.of(context).size.width,
                    child: Text(p.punch=="Lunch"?"${S.of(context).lunchBreakFrom} ${PunchDateUtils.getTimeString(DateTime.parse(p.createdAt))} ${S.of(context).to} ${PunchDateUtils.getTimeString(DateTime.parse(p.updatedAt))}":"${S.of(context).punch} ${p.punch} ${S.of(context).at} ${PunchDateUtils.getTimeString(DateTime.parse(p.createdAt))}",style: logStyle,)
                ),
              )
          );
        });
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

  showRevisionDialog(Punch punch){
    String correctTime = punch.punch=="Lunch"?punch.updatedAt:punch.createdAt;
    bool _isSending = false;
    showDialog(
      context: context,
      builder:(_)=> WillPopScope(
        onWillPop: ()async{
          return !_isSending;
        },
        child: StatefulBuilder(
            builder: (BuildContext _context, StateSetter _setState){
              return Align(
                alignment: Alignment.center,
                child: Container(
                  height: MediaQuery.of(context).size.height*0.3,
                  width: MediaQuery.of(context).size.width-50,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Material(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(S.of(context).hourRevisionRequest, style: TextStyle(color: Colors.black87,fontWeight: FontWeight.bold,fontSize: 18),),
                            Row(
                              children: [
                                Text(punch.punch=="Lunch"?"${S.of(context).incorrectLunchTime}: ":"${S.of(context).incorrectPunchTime}: "),
                                Text("${PunchDateUtils.getTimeString(DateTime.parse(punch.punch=="Lunch"?punch.updatedAt:punch.createdAt))}",style: TextStyle(fontWeight: FontWeight.bold),),
                              ],
                            ),
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
                            ButtonTheme(
                              minWidth: MediaQuery.of(context).size.width*0.6,
                              height: 40,
                              splashColor: Color(primaryColor),
                              child: RaisedButton(
                                onPressed: ()async{
                                  if(!_isSending){
                                    _setState(() { _isSending=true; });
                                    await sendTimeRevisionRequest(punch.id, correctTime, punch.punch=="Lunch"?punch.updatedAt:punch.createdAt);
                                    Navigator.pop(_context);
                                  }
                                },
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                color: Colors.black87,
                                child: _isSending?SizedBox(height: 25,width: 25,child: CircularProgressIndicator()):Text(S.of(context).submit,style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Colors.white),),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }
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

  sendTimeRevisionRequest(int punchId, String newValue, String oldValue)async{
    String result = await context.read<RevisionModel>().sendTimeRevisionRequest(punchId: punchId,newValue: newValue, oldValue:oldValue);
    Scaffold.of(context).showSnackBar(SnackBar(content: Text(result)));
  }

  void _onRefresh() async{
    await context.read<UserModel>().getUserPunches();
    selectedPunches = user.getPunchesGroupOfWeek(startOfWeek);
    _refreshController.refreshCompleted();
    if(mounted)setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    Punch currentPunch = user.getTodayPunch();
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
                          Text("${user.firstName} ${user.lastName}",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 30,color: Colors.white),),
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
              padding: EdgeInsets.all(8),
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
                          header: WaterDropMaterialHeader(backgroundColor: Color(primaryColor),distance: 40,),
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