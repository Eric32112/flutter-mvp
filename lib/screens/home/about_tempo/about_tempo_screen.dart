import 'package:flutter/material.dart';
import 'package:tempo_official/R.Strings.dart';
import 'package:tempo_official/consts/assets.dart';
import 'package:tempo_official/consts/theme.dart';

class AboutTempoScreen extends StatelessWidget {
  const AboutTempoScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // TODO:: fix the background color.
        backgroundColor: TempoTheme.backgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
            color: Colors.black.withOpacity(.54),
          ),
          shape: ContinuousRectangleBorder(
              borderRadius:
                  BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30))),
          title: Text(
            TempoStrings.labelAboutTempo,
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        body: Stack(children: [
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                Container(
                  height: 481.0,
                  margin: EdgeInsets.symmetric(horizontal: 12.0, vertical: 36.0),
                  padding: EdgeInsets.symmetric(vertical: 32.0, horizontal: 16.0),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.0),
                      boxShadow: [BoxShadow(blurRadius: 4.0, color: Colors.black.withOpacity(0.25))]),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ' Hey! First of all, thank you so much for using Tempo and being a part of this family we’ve created. Tempo was built on the idea of helping people clear up their cluttered schedule to make time for whatever YOU the user have really wanted to do, but never had the time for. It grew from that idea into a way of working with others to achieve those moments you’ve always wanted, to reach those goals that seemed impossible alone, to take control of the time that is so rightfully yours. Most importantly, it became the app that would be your friend, always there, ready to help.',
                        style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14.0, height: 16 / 14.0),
                      ),
                      SizedBox(
                        height: 32.0,
                      ),
                      Text(
                        ' You make us who we are and for that we are eternally grateful.',
                        style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14.0, height: 16 / 14.0),
                      ),
                      SizedBox(
                        height: 32.0,
                      ),
                      Text(
                        'Sincerely,',
                        style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14.0, height: 16 / 14.0),
                      ),
                      Text(
                        'Ryan and Ani',
                        style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14.0, height: 16 / 14.0),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
          Positioned(
            bottom: 0.0,
            right: 0.0,
            left: 0.0,
            child: Image(
              fit: BoxFit.fitWidth,
              image: TempoAssets.spacemanGoingUp,
            ),
          )
        ]));
  }
}
