import 'package:flutter/material.dart';
import 'package:flutter_app/bloc/bloc_provider.dart';
import 'package:flutter_app/pages/tasks/bloc/task_bloc.dart';
import 'package:flutter_app/pages/labels/label_db.dart';
import 'package:flutter_app/pages/projects/project_db.dart';
import 'package:flutter_app/pages/projects/project.dart';
import 'package:flutter_app/pages/about/about_us.dart';
import 'package:flutter_app/pages/home/home_bloc.dart';
import 'package:flutter_app/pages/labels/label_bloc.dart';
import 'package:flutter_app/pages/labels/label_widget.dart';
import 'package:flutter_app/pages/projects/project_bloc.dart';
import 'package:flutter_app/pages/projects/project_widget.dart';
import 'package:flutter_app/utils/keys.dart';
import 'package:flutter_app/utils/extension.dart';
import 'package:flutter_app/utils/forest_theme.dart';

class SideDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    HomeBloc homeBloc = BlocProvider.of(context);
    return Drawer(
      child: ListView(
        padding: EdgeInsets.all(0.0),
        children: <Widget>[
          Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(painter: _TreeLinePainter()),
              ),
              // No bottom margin or divider line: the painted tree line is
              // the header's bottom edge.
              DividerTheme(
                data: DividerThemeData(color: Colors.transparent),
                child: UserAccountsDrawerHeader(
                  margin: EdgeInsets.zero,
                  decoration: BoxDecoration(color: Colors.transparent),
                  accountName: Text("Kameron Arceneaux",
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  accountEmail: Text("burhanrashid5253@gmail.com"),
                  otherAccountsPictures: <Widget>[
                    IconButton(
                        icon: Icon(
                          Icons.info_outline,
                          color: Forest.parchment,
                          size: 30.0,
                        ),
                        onPressed: () async {
                          await context.adaptiveNavigate(
                              SCREEN.ABOUT, AboutUsScreen());
                        })
                  ],
                  currentAccountPicture: CircleAvatar(
                    backgroundColor: Forest.sage,
                    backgroundImage: AssetImage("assets/profile_pic.jpg"),
                  ),
                ),
              ),
            ],
          ),
          ListTile(
              leading: Icon(Icons.cabin_outlined),
              title: Text(
                "Inbox",
                key: ValueKey(SideDrawerKeys.INBOX),
              ),
              onTap: () {
                var project = Project.getInbox();
                homeBloc.applyFilter(
                    project.name, Filter.byProject(project.id!));
                context.safePop();
              }),
          ListTile(
              onTap: () {
                homeBloc.applyFilter("Today", Filter.byToday());
                context.safePop();
              },
              leading: Icon(Icons.wb_sunny_outlined),
              title: Text(
                "Today",
                key: ValueKey(SideDrawerKeys.TODAY),
              )),
          ListTile(
            onTap: () {
              homeBloc.applyFilter("Next 7 Days", Filter.byNextWeek());
              context.safePop();
            },
            leading: Icon(Icons.landscape_outlined),
            title: Text(
              "Next 7 Days",
              key: ValueKey(SideDrawerKeys.NEXT_7_DAYS),
            ),
          ),
          BlocProvider(
            bloc: ProjectBloc(ProjectDB.get()),
            child: ProjectPage(),
          ),
          BlocProvider(
            bloc: LabelBloc(LabelDB.get()),
            child: LabelPage(),
          )
        ],
      ),
    );
  }
}

/// Dusk-coloured header background with a row of pine silhouettes.
class _TreeLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Forest.fern, Forest.pine],
        ).createShader(rect),
    );

    void pines(double baseY, double minH, double maxH, double step,
        double offset, Color color) {
      final paint = Paint()..color = color;
      var i = 0;
      for (double x = offset; x < size.width + step; x += step, i++) {
        // Cheap deterministic variation in height.
        final t = ((i * 37) % 11) / 10.0;
        final h = minH + (maxH - minH) * t;
        final w = h * 0.5;
        canvas.drawPath(
          Path()
            ..moveTo(x - w / 2, baseY)
            ..lineTo(x + w / 2, baseY)
            ..lineTo(x, baseY - h)
            ..close(),
          paint,
        );
      }
    }

    pines(size.height, 26, 54, 22, 6, Forest.moss.withValues(alpha: 0.35));
    pines(size.height, 20, 40, 17, 0, Forest.pine);
    // Solid strip so the bases of the front row form one continuous edge.
    canvas.drawRect(Rect.fromLTWH(0, size.height - 3, size.width, 3),
        Paint()..color = Forest.pine);
  }

  @override
  bool shouldRepaint(_TreeLinePainter oldDelegate) => false;
}
