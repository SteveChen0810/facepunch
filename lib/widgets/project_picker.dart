import 'package:facepunch/lang/l10n.dart';
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
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      clipBehavior: Clip.hardEdge,
      margin: EdgeInsets.only(top: 4),
      child: DropdownButton<Project>(
        items: widget.projects.map((Project value) {
          return DropdownMenuItem<Project>(
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
        value: widget.projects.firstWhereOrNull((p) => p.id == widget.projectId),
        isExpanded: true,
        menuMaxHeight: MediaQuery.of(context).size.height*0.9,
        underline: SizedBox(),
        hint: Text(S.of(context).selectProject),
        onChanged: widget.onSelected,
      ),
    );
  }
}