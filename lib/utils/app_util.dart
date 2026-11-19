import 'package:flutter/material.dart';
import 'package:flutter_app/utils/forest_theme.dart';
import 'package:flutter_app/utils/app_constant.dart';
import 'package:flutter_app/utils/keys.dart';
import 'package:url_launcher/url_launcher.dart';

showSnackbar(context, String message, {MaterialColor? materialColor}) {
  if (message.isEmpty) return;
  // Find the Scaffold in the Widget tree and use it to show a SnackBar
  ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: materialColor));
}

launchURL(String url) async {
  if (url.isEmpty) return;
  if (await canLaunchUrl(Uri.parse(url))) {
    await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
  } else {
    throw 'Could not launch $url';
  }
}

class MessageInCenterWidget extends StatelessWidget {
  final String _message;

  MessageInCenterWidget(this._message);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.forest_outlined, size: 56, color: Forest.sage),
          SizedBox(height: PADDING_SMALL),
          Text(_message,
              key: ValueKey(HomePageKeys.MESSAGE_IN_CENTER),
              style: TextStyle(
                  fontSize: FONT_MEDIUM,
                  color: Forest.muted,
                  fontWeight: FontWeight.w600)),
          SizedBox(height: PADDING_VERY_SMALL),
          Text("A quiet clearing. Tap + to plant something.",
              style: TextStyle(fontSize: 13, color: Forest.muted)),
        ],
      ),
    );
  }
}
