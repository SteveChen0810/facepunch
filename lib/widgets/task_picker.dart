import 'package:facepunch/lang/l10n.dart';
import 'package:facepunch/models/work_model.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

class TaskPicker extends StatefulWidget{
  final List<ScheduleTask> tasks;
  final int? taskId;
  final ValueChanged<ScheduleTask?>? onSelected;

  TaskPicker({required this.tasks, this.taskId, this.onSelected });

  @override
  _TaskPickerState createState() => _TaskPickerState();
}

class _TaskPickerState extends State<TaskPicker> {


  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black54),
        borderRadius: BorderRadius.circular(5),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.0,),
      clipBehavior: Clip.hardEdge,
      margin: EdgeInsets.only(top: 4),
      child: DropdownButton<ScheduleTask>(
        items: widget.tasks.map((ScheduleTask value) {
          return DropdownMenuItem<ScheduleTask>(
            value: value,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${value.name}', maxLines: 1, overflow: TextOverflow.ellipsis,),
                if(value.hasCode())
                  Text('${value.code}', style: TextStyle(fontSize: 10),),
              ],
            ),
          );
        }).toList(),
        value: widget.tasks.firstWhereOrNull((t) => t.id == widget.taskId),
        isExpanded: true,
        hint: Text(S.of(context).selectTask),
        menuMaxHeight: MediaQuery.of(context).size.height*0.9,
        underline: SizedBox(),
        onChanged: widget.onSelected,
      ),
    );
  }
}