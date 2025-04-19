import 'package:flutter/material.dart';

class CustomRadioBtn extends StatefulWidget {
  CustomRadioBtn(
      {required this.buttonLables,
      required this.buttonValues,
      this.radioButtonValue,
      required this.buttonColor,
      required this.selectedColor,
      this.defaultValue,
      this.hight = 35,
      this.width = 100,
      this.horizontal = false,
      this.enableShape = false,
      this.elevation = 4,
      this.customShape,
      this.enableAll})
      : assert(buttonLables.length == buttonValues.length),
        assert(buttonColor != null),
        assert(selectedColor != null);

  /// Whether the radio buttons are arranged horizontally
  final bool horizontal;

  /// List of values corresponding to the radio buttons
  final List buttonValues;

  /// Height of the radio buttons
  final double hight;

  /// Width of the radio buttons
  final double width;

  /// The labels of the radio buttons
  final List<String> buttonLables;

  /// The function which will be called when the radio button is selected
  final Function(dynamic)? radioButtonValue;

  /// Color of the selected radio button
  final Color selectedColor;

  /// Default selected value
  final String? defaultValue;

  /// Color of the radio buttons
  final Color buttonColor;

  /// Custom shape for the radio buttons
  final ShapeBorder? customShape;

  /// Whether to enable custom shape for the radio buttons
  final bool enableShape;

  /// Elevation of the radio buttons
  final double elevation;

  /// Whether to enable all radio buttons
  final bool? enableAll;


  _CustomRadioButtonState createState() => _CustomRadioButtonState();
}

class _CustomRadioButtonState extends State<CustomRadioBtn> {
  /// Index of the currently selected radio button
  int currentSelected = 0;

  /// Label of the currently selected radio button
  static String? currentSelectedLabel;


  @override
  void initState() {
    super.initState();

    currentSelectedLabel = widget.defaultValue ?? "";
  }


  /// Builds the radio buttons in a column layout
  List<Widget> buildButtonsColumn() {
    List<Widget> buttons = [];
    for (int index = 0; index < widget.buttonLables.length; index++) {
      var button = Expanded(
        // flex: 1,
        child: Card(
          color: currentSelectedLabel == widget.buttonLables[index]
              ? widget.selectedColor
              : widget.buttonColor,
          elevation: widget.elevation,
          shape: widget.enableShape
              ? widget.customShape == null
                  ? RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                    )
                  : widget.customShape
              : null,
          child: Container(
            height: widget.hight,
            child: MaterialButton(
              shape: widget.enableShape
                  ? widget.customShape == null
                      ? OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context).primaryColor, width: 1),
                          borderRadius: BorderRadius.all(Radius.circular(2)),
                        )
                      : widget.customShape
                  : OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Theme.of(context).primaryColor, width: 1),
                      borderRadius: BorderRadius.zero,
                    ),
              onPressed: widget.enableAll!
                  ? () {
                      widget.radioButtonValue!(widget.buttonValues[index]);
                      setState(() {
                        currentSelected = index;
                        currentSelectedLabel = widget.buttonLables[index];
                      });
                    }
                  : () {},

              child: Text(
                widget.buttonLables[index],
                style: TextStyle(
                  color: currentSelectedLabel == widget.buttonLables[index]
                      ? Colors.white
                      : Theme.of(context).textTheme.bodyLarge!.color,
                  fontSize: 10,
                ),
              ),
            ),
          ),
        ),
      );
      buttons.add(button);
    }
    return buttons;
  }


  /// Builds the radio buttons in a row layout
  List<Widget> buildButtonsRow() {
    List<Widget> buttons = [];
    for (int index = 0; index < widget.buttonLables.length; index++) {
      var button = Expanded(
        // flex: 1,
        child: Card(
          color: currentSelectedLabel == widget.buttonLables[index]
              ? widget.selectedColor
              : widget.buttonColor,
          elevation: widget.elevation,
          shape: widget.enableShape
              ? widget.customShape == null
                  ? RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                    )
                  : widget.customShape
              : null,
          child: Container(
            height: widget.hight,
            // width: 200,
            constraints: BoxConstraints(maxWidth: 200),
            child: MaterialButton(
              shape: widget.enableShape
                  ? widget.customShape == null
                      ? OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context).primaryColor, width: 1),
                          borderRadius: BorderRadius.all(Radius.circular(2)),
                        )
                      : widget.customShape
                  : OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Theme.of(context).primaryColor, width: 1),
                      borderRadius: BorderRadius.zero,
                    ),
              onPressed: widget.enableAll!? () {
                widget.radioButtonValue!(widget.buttonValues[index]);
                setState(() {
                  currentSelected = index;
                  currentSelectedLabel = widget.buttonLables[index];
                });
              } : () {

                widget.radioButtonValue!(widget.buttonValues[currentSelected]);
              },
              child: Text(
                widget.buttonLables[index],
                style: TextStyle(
                  color: currentSelectedLabel == widget.buttonLables[index]
                      ? Colors.white
                      : Theme.of(context).textTheme.bodyLarge!.color,
                  fontSize: 10,
                ),
              ),
            ),
          ),
        ),
      );
      buttons.add(button);
    }
    return buttons;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.horizontal
          ? widget.hight * (widget.buttonLables.length + 0.5)
          : null,
      child: Center(
        child: widget.horizontal
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: buildButtonsColumn(),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: buildButtonsRow(),
              ),
      ),
    );

    // return Container(
    //   height: 50,
    //   child: ListView.builder(
    //     itemCount: widget.buttonLables.length,
    //     scrollDirection: Axis.horizontal,
    //     itemBuilder: (context, index) => Card(
    //       color: index == currentSelected
    //           ? widget.selectedColor
    //           : widget.buttonColor,
    //       elevation: 10,
    //       shape: kRoundedButtonShape,
    //       child: Container(
    //         height: 40,
    //         // width: 200,
    //         constraints: BoxConstraints(maxWidth: 250),
    //         child: MaterialButton(
    //           // minWidth: 300,
    //           // elevation: 10,
    //           shape: kRoundedButtonShape,
    //           onPressed: () {
    //             widget.radioButtonValue(widget.buttonValues[index]);
    //             setState(() {
    //               currentSelected = index;
    //             });
    //           },
    //           child: Text(
    //             widget.buttonLables[index],
    //             style: TextStyle(
    //               color: index == currentSelected
    //                   ? Colors.white
    //                   : Theme.of(context).textTheme.bodyLarge.color,
    //               fontSize: 15,
    //             ),
    //           ),
    //         ),
    //       ),
    //     ),
    //   ),
    // );
  }
}
