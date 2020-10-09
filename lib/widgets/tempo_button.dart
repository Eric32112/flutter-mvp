import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tempo_official/consts/theme.dart';

class TempoButton extends StatelessWidget {
  final onPressed;
  final String text;
  final double width;
  const TempoButton({Key key, @required this.onPressed, @required this.text, this.width})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15.0),
      child: Container(
        height: 35.0,
        width: width ?? MediaQuery.of(context).size.width,
        child: FlatButton(
            color: TempoTheme.primaryBtnColor,
            onPressed: onPressed,
            child: Text(text ?? '',
                style: GoogleFonts.roboto().copyWith(color: Colors.white, fontSize: 18.0))),
      ),
    );
  }
}
