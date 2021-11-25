import 'package:facepunch/models/work_model.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

class ProjectPicker extends StatefulWidget{
  final List<Project> projects;
  final int? projectId;
  final ValueChanged<Project?>? onSelected;

  ProjectPicker({required this.projects, this.projectId, this.onSelected });
  @override
  _ProjectPickerState createState() => _ProjectPickerState();
}

class _ProjectPickerState extends State<ProjectPicker> {


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
      child: DropdownButton<Project>(
        items: widget.projects.map((Project value) {
          return DropdownMenuItem<Project>(
            value: value,
            child: Text('${value.name}'),
          );
        }).toList(),
        value: widget.projects.firstWhereOrNull((p) => p.id == widget.projectId),
        isExpanded: true,
        isDense: true,
        underline: SizedBox(),
        onChanged: widget.onSelected,
      ),
    );
  }
}