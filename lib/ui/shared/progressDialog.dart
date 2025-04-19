import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// [ProgressDialog] is a StatelessWidget that displays a circular progress indicator inside a dialog.
class ProgressDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: dialogContent(context),
    );
  }


  /// Builds the content of the dialog
  /// [context] is the BuildContext in which the widget is built
  dialogContent(context) {
    return Wrap(children: <Widget>[
      new Center(
          child: Container(
              width: 80,
              height: 80,
              padding: EdgeInsets.all(5),
              child: CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 20,
                  child: CircularProgressIndicator(
                      valueColor:
                          new AlwaysStoppedAnimation<Color>(Colors.black)))))
    ]);
  }
}
