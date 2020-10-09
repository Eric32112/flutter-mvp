import 'package:flutter/material.dart';

class TransparentBackground extends StatelessWidget {
  final Widget child;
  final AssetImage backgroundImage;
  final double left;
  final double right;
  final double top;
  final double bottom;
  const TransparentBackground(
      {Key key, this.child, this.backgroundImage, this.bottom, this.left, this.right, this.top})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Stack(
        children: [
          Positioned(
            right: right ?? 0.0,
            bottom: bottom ?? 46.0,
            top: top,
            left: left,
            child: Image(image: backgroundImage),
          ),
          child
        ],
      ),
      decoration: BoxDecoration(color: Color(0xffEFE6D4)),
    );
  }
}
