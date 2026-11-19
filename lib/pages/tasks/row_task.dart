import 'package:flutter/material.dart';
import 'package:flutter_app/pages/tasks/models/tasks.dart';
import 'package:flutter_app/utils/color_utils.dart';
import 'package:flutter_app/utils/date_util.dart';
import 'package:flutter_app/utils/app_constant.dart';
import 'package:flutter_app/utils/forest_theme.dart';

/// Rounded "card" a task row sits on; also used for the swipe backgrounds so
/// they line up with the card.
const EdgeInsets taskCardMargin =
    EdgeInsets.symmetric(horizontal: 12, vertical: 5);
const BorderRadius taskCardRadius = BorderRadius.all(Radius.circular(14));

class TaskRow extends StatelessWidget {
  final Tasks tasks;
  static final dateLabel = "Date";
  final List<String> labelNames = [];

  TaskRow(this.tasks);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        //TODO to click something
      },
      child: Padding(
        padding: taskCardMargin,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Forest.card,
            borderRadius: taskCardRadius,
            border: Border.all(color: Forest.sage.withValues(alpha: 0.45)),
            boxShadow: [
              BoxShadow(
                color: Forest.pine.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: taskCardRadius,
            child: Container(
              key: ValueKey("taskPriority_${tasks.id}"),
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    width: 5.0,
                    color: priorityColor[tasks.priority.index],
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    PADDING_SMALL, 10, PADDING_MEDIUM, 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(
                          left: PADDING_VERY_SMALL, top: 1, right: 6),
                      child: Icon(
                        Icons.eco_outlined,
                        size: 18,
                        color: priorityColor[tasks.priority.index],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(
                                bottom: PADDING_VERY_SMALL),
                            child: Text(tasks.title,
                                key: ValueKey("taskTitle_${tasks.id}"),
                                style: TextStyle(
                                    color: Forest.ink,
                                    fontSize: FONT_SIZE_TITLE,
                                    fontWeight: FontWeight.w700)),
                          ),
                          getLabels(tasks.labelList),
                          Row(
                            children: <Widget>[
                              Icon(Icons.wb_sunny_outlined,
                                  size: 13, color: Forest.muted),
                              SizedBox(width: 4),
                              Text(
                                getFormattedDate(tasks.dueDate),
                                style: TextStyle(
                                    color: Forest.muted,
                                    fontSize: FONT_SIZE_DATE),
                                key: ValueKey("taskDueDate_${tasks.id}"),
                              ),
                              Spacer(),
                              _ProjectTag(
                                taskId: tasks.id,
                                name: tasks.projectName!,
                                color: Color(tasks.projectColor!),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget getLabels(List<String> labelList) {
    if (labelList.isEmpty) {
      return Container();
    } else {
      return Padding(
        padding: const EdgeInsets.only(bottom: PADDING_VERY_SMALL),
        child: Text(tasks.labelList.join("  "),
            key: ValueKey("taskLabels_${tasks.id}"),
            style: TextStyle(color: Forest.moss, fontSize: FONT_SIZE_LABEL)),
      );
    }
  }
}

class _ProjectTag extends StatelessWidget {
  final int? taskId;
  final String name;
  final Color color;

  const _ProjectTag(
      {required this.taskId, required this.name, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Forest.mist.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(name,
              key: ValueKey("taskProjectName_$taskId"),
              style: TextStyle(
                  color: Forest.muted,
                  fontSize: FONT_SIZE_LABEL - 1,
                  fontWeight: FontWeight.w500)),
          Container(
            margin: const EdgeInsets.only(left: 6.0),
            width: 8.0,
            height: 8.0,
            child: CircleAvatar(backgroundColor: color),
          ),
        ],
      ),
    );
  }
}
