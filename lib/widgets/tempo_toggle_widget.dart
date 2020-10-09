import 'package:flutter/material.dart';
import 'package:tempo_official/consts/theme.dart';

class TempoToggle extends StatefulWidget {
  const TempoToggle({
    Key key,
    @required this.value,
    this.valueChange,
  }) : super(key: key);

  final bool value;
  final Function(bool) valueChange;

  @override
  _TempoToggleState createState() => _TempoToggleState();
}

class _TempoToggleState extends State<TempoToggle> {
  bool _value;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        _value = !_value;
        widget.valueChange(_value);
      },
      child: Container(
        width: 24.0,
        height: 14.0,
        decoration: BoxDecoration(
            border: Border.all(width: 2.0, color: TempoTheme.retroOrange ?? TempoTheme.primaryBtnColor),
            borderRadius: BorderRadius.circular(14.0)),
        padding: EdgeInsets.symmetric(vertical: 1.0, horizontal: 2.0),
        child: Row(
          mainAxisAlignment: widget.value ?? true ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            Container(
                height: 8.0,
                width: 8.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      width: 2.0, color: TempoTheme.retroOrange ?? TempoTheme.primaryBtnColor),
                ))
          ],
        ),
      ),
    );
  }
}
