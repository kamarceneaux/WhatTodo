import 'package:flutter/material.dart';
import 'package:flutter_app/utils/forest_theme.dart';
import 'package:flutter_app/pages/tasks/bloc/task_bloc.dart';
import 'package:flutter_app/bloc/bloc_provider.dart';
import 'package:flutter_app/pages/tasks/models/tasks.dart';
import 'package:flutter_app/pages/tasks/row_task.dart';
import 'package:flutter_app/utils/app_util.dart';

class TasksPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final TaskBloc _tasksBloc = BlocProvider.of(context);
    return StreamBuilder<List<Tasks>>(
      stream: _tasksBloc.tasks,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return _buildTaskList(snapshot.data!);
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  Widget _buildTaskList(List<Tasks> list) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: list.length == 0
          ? MessageInCenterWidget("No Task Added")
          : Container(
              child: ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ClipRect(
                      child: Dismissible(
                          key: ValueKey("swipe_${list[index].id}_$index"),
                          onDismissed: (DismissDirection direction) {
                            var taskID = list[index].id!;
                            final TaskBloc _tasksBloc =
                                BlocProvider.of<TaskBloc>(context);
                            String message = "";
                            if (direction == DismissDirection.endToStart) {
                              _tasksBloc.updateStatus(
                                  taskID, TaskStatus.COMPLETE);
                              message =
                                  "Task completed. A new tree is growing!";
                            } else {
                              _tasksBloc.delete(taskID);
                              message = "Task deleted";
                            }
                            SnackBar snackbar =
                                SnackBar(content: Text(message));
                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackbar);
                          },
                          background: _SwipeBackground(
                            color: Forest.berry,
                            icon: Icons.delete_outline,
                            label: "Clear",
                            alignStart: true,
                          ),
                          secondaryBackground: _SwipeBackground(
                            color: Forest.moss,
                            icon: Icons.park,
                            label: "Plant",
                            alignStart: false,
                          ),
                          child: TaskRow(list[index])),
                    );
                  }),
            ),
    );
  }
}

class _SwipeBackground extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String label;
  final bool alignStart;

  const _SwipeBackground({
    required this.color,
    required this.icon,
    required this.label,
    required this.alignStart,
  });

  @override
  Widget build(BuildContext context) {
    final content = <Widget>[
      Icon(icon, color: Forest.parchment),
      const SizedBox(width: 8),
      Text(label,
          style: const TextStyle(
              color: Forest.parchment, fontWeight: FontWeight.w700)),
    ];
    return Container(
      margin: taskCardMargin,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(color: color, borderRadius: taskCardRadius),
      alignment: alignStart ? Alignment.centerLeft : Alignment.centerRight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: alignStart ? content : content.reversed.toList(),
      ),
    );
  }
}
