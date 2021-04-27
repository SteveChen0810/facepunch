import 'package:cached_network_image/cached_network_image.dart';
import 'package:facepunch/lang/l10n.dart';
import 'package:facepunch/models/app_const.dart';
import 'package:facepunch/models/user_model.dart';
import 'package:facepunch/widgets/calendar_strip/date-utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_date_pickers/flutter_date_pickers.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:provider/provider.dart';

class EmployeeDocument extends StatefulWidget {

  @override
  _EmployeeDocumentState createState() => _EmployeeDocumentState();
}

class _EmployeeDocumentState extends State<EmployeeDocument> {
  DateTime startDate = DateTime.parse("${DateTime.now().year}-01-01");
  DateTime endDate = DateTime.parse("${DateTime.now().year}-12-31");
  DateTime selectedDate;
  String pdfError = "";

  String pdfUrl(){
    final user = context.watch<UserModel>().user;
    DateTime pdfDate = selectedDate??PunchDateUtils.getStartOfCurrentWeek(DateTime.now());
    final pdfLink = "${user.firstName} ${user.lastName} (${pdfDate.toString().split(" ")[0]} ~ ${pdfDate.add(Duration(days: 6)).toString().split(" ")[0]}).pdf";
    print(pdfLink);
    return Uri.encodeFull('https://facepunch.app/punch-pdfs/${user.companyId}/$pdfLink');
  }

  String harvestReportImage(){
    final user = context.watch<UserModel>().user;
    final imageUrl = 'harvest-reports/${user.companyId}/Harvest_Report_${DateTime.now().toString().split(' ')[0]}.png';
    return Uri.encodeFull('https://facepunch.app/$imageUrl');
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Container(
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(4)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 3.0,
                  spreadRadius: 3.0,
                )
              ]
            ),
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top,left: 4,right: 4,bottom: 4),
            child: WeekPicker(
                selectedDate: selectedDate??DateTime.now(),
                onChanged: (v){
                  setState(() { selectedDate = v.start; pdfError=""; });
                },
                firstDate: startDate,
                lastDate: endDate,
                datePickerLayoutSettings: DatePickerLayoutSettings(
                  contentPadding: EdgeInsets.zero,
                  dayPickerRowHeight: 30,
                  monthPickerPortraitWidth: width,
                  maxDayPickerRowCount: 6,
                ),
                datePickerStyles: DatePickerRangeStyles(
                  selectedPeriodLastDecoration: BoxDecoration(
                    color: Color(primaryColor),
                    borderRadius: BorderRadius.horizontal(right: Radius.circular(20.0)),
                  ),
                  selectedPeriodStartDecoration: BoxDecoration(
                    color: Color(primaryColor),
                    borderRadius: BorderRadius.horizontal(left: Radius.circular(20.0)),
                  ),
                  selectedPeriodMiddleDecoration: BoxDecoration(color: Color(primaryColor)),
                  currentDateStyle: TextStyle(color: Colors.red, fontWeight: FontWeight.bold,fontSize: 18),
                  defaultDateTextStyle: TextStyle(fontSize: 16),
                )
            ),
          ),
          Expanded(
              child: Card(
                elevation: 8,
                child: SingleChildScrollView(
                  child: Container(
                    child: Column(
                      children: [
                        pdfError.isNotEmpty?
                        Container(
                          alignment: Alignment.center,
                          height: 200,
                          child: Text(S.of(context).pdfNotGenerated),
                        ):
                        SfPdfViewer.network(
                          pdfUrl(),
                          key: Key(pdfUrl()),
                          onDocumentLoadFailed: (v){
                              if(mounted)setState(() {pdfError = v.description;});
                          },
                        ),
                        CachedNetworkImage(
                          imageUrl: harvestReportImage(),
                          width: width,
                          placeholder: (_,__)=>Container(
                            alignment: Alignment.center,
                            height: 200,
                            child: CircularProgressIndicator(),
                          ),
                          errorWidget: (_,__,___)=>Container(
                            alignment: Alignment.center,
                            height: 200,
                            child: Text(S.of(context).harvestReportNotGenerated),
                          ),
                          fit: BoxFit.cover,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ),
        ],
      ),
    );
  }
}