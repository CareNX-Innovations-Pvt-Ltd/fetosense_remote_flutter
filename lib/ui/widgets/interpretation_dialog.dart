import 'package:fetosense_remote_flutter/core/model/test_model.dart';
import 'package:fetosense_remote_flutter/ui/shared/customRadioBtn.dart';
import 'package:flutter/material.dart';

/// A dialog widget for updating interpretations.
class InterpretationDialog extends StatefulWidget {
  /// The test data containing interpretation details.
  final Test? test;

  /// The initial value for the radio button.
  final String? value;

  /// Callback function to handle the updated interpretation.
  Function(String, String, bool)? callback;

  InterpretationDialog({super.key, required this.test, this.value, this.callback});

  @override
  State<StatefulWidget> createState() => _InterpretationDialog();
}

class _InterpretationDialog extends State<InterpretationDialog> {
  /// The selected value for the radio button.
  late String radioValue;

  /// The comments for the interpretation.
  late String comments;

  @override
  void initState() {
    radioValue = widget.value ?? '';
    comments = widget.test!.interpretationExtraComments ?? '';
  }

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

  /// Builds the content of the dialog.
  /// [context] is the build context.
  /// Returns a [Widget] representing the dialog content.
  Widget dialogContent(context) {
    return Wrap(children: <Widget>[
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10.0,
              offset: const Offset(0.0, 10.0),
            ),
          ],
        ),
        child: Column(children: <Widget>[
          Container(
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.fromLTRB(0, 16, 0, 8),
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                border: Border(bottom: BorderSide(color: Colors.grey)),
              ),
              child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 8, 0, 8),
                  child: Text("Update Interpretations",
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                          fontSize: 20)))),
          Padding(
              padding: EdgeInsets.all(16),
              child: CustomRadioBtn(
                buttonColor: Theme.of(context).canvasColor,
                buttonLables: [
                  "Normal",
                  "Abnormal",
                  "Atypical",
                ],
                buttonValues: [
                  "Normal",
                  "Abnormal",
                  "Atypical",
                ],
                enableAll: true,
                defaultValue: widget.value,
                radioButtonValue: (value) => _handleRadioClick(value),
                selectedColor: Colors.blue,
              )),
          Container(
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(8),
              child: TextFormField(
                maxLines: 4,
                keyboardType: TextInputType.text,
                autofocus: false,
                initialValue: comments,
                onChanged: (value) => comments = value.trim(),
                decoration: InputDecoration(hintText: 'Extra Comments'),
              )),
          Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                border: Border(top: BorderSide(color: Colors.grey)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Expanded(
                      // flex: 1,
                      child: MaterialButton(
                          child: Text('Cancel',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 18)),
                          //shape: OutlineInputBorder(),
                          onPressed: () {
                            widget.callback!(radioValue, comments, false);
                            Navigator.of(context).pop();
                          })),
                  Text("|",
                      style: TextStyle(color: Colors.black, fontSize: 24)),
                  Expanded(
                      // flex: 1,
                      child: MaterialButton(
                    child: Text('Update',
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w400,
                            fontSize: 18)),
                    //shape: OutlineInputBorder(),
                    onPressed: () {
                      widget.callback!(radioValue, comments, true);
                      Navigator.of(context).pop();
                    },
                  ))
                ],
              ))
        ]),

        /*CustomRadio<String, dynamic>(
            value: 'Green',
            groupValue: widget.radioValue,
            duration: Duration(milliseconds: 800),
            animsBuilder: (AnimationController controller) => [
              CurvedAnimation(
                parent: controller,
                curve: Curves.ease,
              ),
              ColorTween(begin: Colors.greenAccent.withAlpha(200), end: Colors.green).animate(controller),
            ],
            builder: customBuilder
        ),
        CustomRadio<String, dynamic>(
          value: 'Red',
          groupValue: widget.radioValue,
          duration: Duration(milliseconds: 800),
          animsBuilder: (AnimationController controller) => [
            CurvedAnimation(
              parent: controller,
              curve: Curves.ease,
            ),
            ColorTween(begin: Colors.redAccent.withAlpha(200), end: Colors.red).animate(controller),
          ],
          builder: customBuilder,
        ),*/

        /*CustomRadio<String, double>(
            value: 'First',
            groupValue: widget.radioValue,
            duration: Duration(milliseconds: 500),
            animsBuilder: (AnimationController controller) => [
              CurvedAnimation(
                  parent: controller,
                  curve: Curves.easeInOut
              )
            ],
            builder: (BuildContext context, List<double> animValues, Function updateState, String value) {
              final alpha = (animValues[0] * 255).toInt();
              return GestureDetector(
                  onTap: () {
                    setState(() {
                      widget.radioValue = value;
                    });
                  },
                  child: Container(
                      padding: EdgeInsets.all(32.0),
                      margin: EdgeInsets.all(12.0),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).primaryColor.withAlpha(alpha),
                          border: Border.all(
                            color: Theme.of(context).primaryColor.withAlpha(255 - alpha),
                            width: 4.0,
                          )
                      ),
                      child: Text(
                        value,
                        style: Theme.of(context).textTheme.bodyLarge.copyWith(fontSize: 24.0),
                      )
                  )
              );
            }
        )*/
      )
    ]);
  }

  /// Builds the content of the dialog.
  /// [context] is the build context.
  /// Returns a [Widget] representing the dialog content.
  void _handleRadioClick(String value) {
    if (radioValue == value) {
      return;
    } else {
      setState(() {
        radioValue = value;
      });
    }
  }
}
