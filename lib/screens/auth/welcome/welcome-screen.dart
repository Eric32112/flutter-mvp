import 'package:flutter/material.dart';
import 'package:tempo_official/consts/assets.dart';
import 'package:tempo_official/widgets/tempo_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Column(children: [
              Image(image: TempoAssets.welcomeToText),
              Image(image: TempoAssets.tempoLogo),
              Image(
                image: TempoAssets.manRidingRocket,
              )
            ]),
          ),
          TempoButton(
            onPressed: () {},
            text: 'Next',
          )
        ],
      ),
    ));
  }
}
