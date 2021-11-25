import 'package:facepunch/widgets/calendar_strip/date-utils.dart';
import 'package:facepunch/widgets/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TimeEditorFiled extends StatefulWidget{
  final String? initTime;
  final String? label;
  final ValueChanged<String?>? onChanged;
  TimeEditorFiled({this.initTime, this.label, this.onChanged});
  @override
  _TimeEditorFiledState createState() => _TimeEditorFiledState();
}

class _TimeEditorFiledState extends State<TimeEditorFiled> {

  late TextEditingController _controller;
  String? errorMessage;

  @override
  void initState() {
    String initTime = '00:00';
    if(widget.initTime != null && DateTime.tryParse(widget.initTime!) != null){
      initTime = PunchDateUtils.getTimeString(widget.initTime!);
    }
    _controller = TextEditingController(text: initTime);
    super.initState();
  }

  String? validate(String time){
    try{
      String error = 'Invalid Time';
      if(time.length < 5 || !time.contains(':')){
        return error;
      }
      int hour = int.parse(time.split(':')[0]);
      int minute = int.parse(time.split(':')[1]);
      if(hour >= 24 || minute >= 60){
        return error;
      }
      DateTime initTime = DateTime.now();
      if(widget.initTime != null && DateTime.tryParse(widget.initTime!) != null){
        initTime = DateTime.parse(widget.initTime!);
      }
      DateTime? newTime = DateTime.tryParse('${initTime.toString().split(' ')[0]} $time:00');
      if(newTime == null){
        return error;
      }
      if(widget.onChanged != null){
        widget.onChanged!(newTime.toString());
      }
      return null;
    }catch(e){
      Tools.consoleLog('[TimeEditorFiled.validate.err]$e');
      return e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: widget.label,
        errorText: errorMessage,
        isDense: true
      ),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(4),
        TimeInputFormatter()
      ],
      keyboardType: TextInputType.numberWithOptions(decimal: false),
      controller: _controller,
      onChanged: (v){
        errorMessage = validate(v);
        if(errorMessage != null && widget.onChanged != null){
          widget.onChanged!(null);
        }
        setState(() {});
      },
    );
  }
}

class TimeInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var newText = newValue.text;

    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    var buffer = new StringBuffer();
    for (int i = 0; i < newText.length; i++) {
      buffer.write(newText[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 2 == 0 && nonZeroIndex != newText.length) {
        buffer.write(':');
      }
    }

    var string = buffer.toString();
    return newValue.copyWith(
        text: string,
        selection: new TextSelection.collapsed(offset: string.length));
  }
}
