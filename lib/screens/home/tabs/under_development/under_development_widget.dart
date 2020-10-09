import 'package:flutter/material.dart';

class UnderDevelopmentWidget extends StatelessWidget {
  const UnderDevelopmentWidget({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Center(
        child: Text('This tab is under development'),
      ),
    );
  }
}
