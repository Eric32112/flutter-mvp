import 'package:flutter/material.dart';
import 'package:tempo_official/screens/home/tabs/under_development/under_development_widget.dart';

class GoalsTab extends StatelessWidget {
  const GoalsTab({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: UnderDevelopmentWidget(),
    );
  }
}
