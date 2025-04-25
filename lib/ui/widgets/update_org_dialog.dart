import 'package:flutter/material.dart';

/// A dialog widget for updating organization details.
class UpdateOrgDialog extends StatelessWidget {
  /// The value entered in the text field.
  late final String value;

  /// Callback function to handle the updated organization code.
  final Function(String) callback;

  UpdateOrgDialog({required this.callback});

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
  dialogContent(context) {
    return Wrap(
      children: <Widget>[
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
          child: Column(
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width,
                margin: EdgeInsets.fromLTRB(0, 16, 0, 8),
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  border: Border(
                    bottom: BorderSide(color: Colors.grey),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 8, 0, 8),
                  child: Text(
                    "Update Organization",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                    ),
                  ),
                ),
              ),
              Padding(
                  padding: EdgeInsets.all(16),
                  child: TextField(
                    maxLines: 1,
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.characters,
                    autofocus: false,
                    onChanged: (value) => this.value = value.trim(),
                    decoration: InputDecoration(hintText: 'Code'),
                  )),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  border: Border(
                    top: BorderSide(color: Colors.grey),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Expanded(
                      // flex: 1,
                      child: MaterialButton(
                          child: Text('Cancel',
                              style:
                                  TextStyle(color: Colors.black, fontSize: 20)),
                          //shape: OutlineInputBorder(),
                          onPressed: () {
                            callback("");
                            Navigator.of(context).pop();
                          }),
                    ),
                    Text(
                      "|",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 24,
                      ),
                    ),
                    Expanded(
                      // flex: 1,
                      child: MaterialButton(
                        child: Text('Update',
                            style:
                                TextStyle(color: Colors.black, fontSize: 20)),
                        //shape: OutlineInputBorder(),
                        onPressed: () {
                          callback(value);
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
