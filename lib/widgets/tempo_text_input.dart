import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tempo_official/consts/theme.dart';

class TempoTextInput extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode node;
  final String hint;
  final Function(String) onSubmit;
  final Function(String) validator;

  final Function onEditingComplete;
  final TextInputAction inputAction;
  final TextInputType inputType;
  final bool obscureText;

  const TempoTextInput(
      {Key key,
      this.controller,
      this.hint,
      this.inputAction,
      this.inputType,
      this.validator,
      this.node,
      this.obscureText = false,
      this.onSubmit,
      this.onEditingComplete})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: EdgeInsets.symmetric(vertical: 0, horizontal: 16.0),
      decoration: BoxDecoration(
          color: TempoTheme.inputColor,
          borderRadius: BorderRadius.circular(15.0),
          boxShadow: [
            BoxShadow(offset: Offset(0, 4), blurRadius: 4, color: Color.fromRGBO(0, 0, 0, 0.25))
          ]),
      child: TextFormField(
        onFieldSubmitted: onSubmit,
        onEditingComplete: onEditingComplete,
        controller: controller,
        obscureText: obscureText,
        focusNode: node,
        validator: (value) => validator(value),
        autovalidate: true,
        decoration: InputDecoration(
            contentPadding: EdgeInsets.only(top: 0.0, bottom: 8.0),
            border: InputBorder.none,
            fillColor: TempoTheme.inputColor,
            hintText: hint,
            hintStyle: GoogleFonts.roboto().copyWith(color: Colors.white)),
      ),
    );
  }
}
