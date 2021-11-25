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
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      clipBehavior: Clip.hardEdge,
      margin: EdgeInsets.only(top: 4),
      child: DropdownButton<ScheduleTask>(
        items: widget.tasks.map((ScheduleTask value) {
          return DropdownMenuItem<ScheduleTask>(
            value: value,
            child: Text('${value.name}'),
          );
        }).toList(),
        value: widget.tasks.firstWhereOrNull((t) => t.id == widget.taskId),
        isExpanded: true,
        isDense: true,
        underline: SizedBox(),
        onChanged: widget.onSelected,
      ),
    );
  }
}