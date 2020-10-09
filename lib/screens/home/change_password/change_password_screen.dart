import 'package:bot_toast/bot_toast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tempo_official/R.Strings.dart';
import 'package:tempo_official/consts/assets.dart';
import 'package:tempo_official/consts/theme.dart';
import 'package:tempo_official/providers/auth_provider.dart';

class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListenableProvider<_ChangePasswordScreenProvider>(
      create: (_) => _ChangePasswordScreenProvider(),
      child: Consumer<_ChangePasswordScreenProvider>(builder: (context, state, child) {
        return Scaffold(
          // TODO fix background color
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
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30))),
            title: Text(
              TempoStrings.labelChangePW,
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          body: Stack(children: [
            Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
              child: Column(
                children: [
                  _buildInput(context,
                      hint: TempoStrings.hintTextEnterCurrentPw,
                      ctrl: state.currentPasswordController,
                      node: state.currentPasswordNode),
                  SizedBox(
                    height: 16.0,
                  ),
                  _buildInput(context,
                      hint: TempoStrings.hintTextEnterNewPw,
                      ctrl: state.newPasswordController,
                      node: state.newPasswordNode),
                  SizedBox(
                    height: 16.0,
                  ),
                  _buildInput(context,
                      hint: TempoStrings.hintTextConfirmNewPw,
                      ctrl: state.newPasswordConfirmationController,
                      node: state.newPasswordConfirmationNode),
                ],
              ),
            ),
            Positioned(
              bottom: 0.0,
              right: 0.0,
              left: 0.0,
              height: 86.0,
              child: FlatButton(
                color: TempoTheme.retroOrange,
                textColor: Colors.white,
                child: Text(TempoStrings.labelSave.toUpperCase(),
                    style: TextStyle(
                      height: 34 / 29.0,
                      fontWeight: FontWeight.w500,
                      fontSize: 29.0,
                    )),
                onPressed: () async {
                  if (state.newPasswordIsValid) {
                    AuthProvider provider = Provider.of<AuthProvider>(context, listen: false);
                    provider
                        .login(
                            email: provider.user.email, password: state.currentPasswordController.text)
                        .then((value) {
                      FirebaseUser user = value;
                      user.updatePassword(state.newPasswordController.text).then((value) {
                        BotToast.showText(text: 'Password changed successfully');
                      }).catchError((error) {
                        BotToast.showText(text: 'can\'t update password');
                      });
                    }).then((value) {
                      BotToast.showText(text: 'You entered an invalid password');
                    });
                  } else {
                    BotToast.showText(text: 'Password and confirmation don\'t match');
                  }
                },
              ),
            ),
            Positioned(
              bottom: 75.0,
              left: 0.0,
              right: 0.0,
              child: Image(
                image: TempoAssets.planetAndRocket,
                fit: BoxFit.fitWidth,
              ),
            ),
          ]),
        );
      }),
    );
  }

  _buildInput(BuildContext context, {String hint, TextEditingController ctrl, FocusNode node}) {
    return Container(
      height: 52.0,
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(horizontal: 24.0),
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(blurRadius: 4.0, offset: Offset(0.0, 4.0), color: Colors.black.withOpacity(0.25)),
      ], borderRadius: BorderRadius.circular(45.0), color: Colors.white),
      child: TextFormField(
        controller: ctrl,
        focusNode: node,
        decoration: InputDecoration(
            border: InputBorder.none, hintText: hint, hintStyle: TextStyle(fontSize: 18.0)),
      ),
    );
  }
}

class _ChangePasswordScreenProvider extends ChangeNotifier {
  TextEditingController currentPasswordController = TextEditingController();
  FocusNode currentPasswordNode = FocusNode();

  TextEditingController newPasswordController = TextEditingController();
  FocusNode newPasswordNode = FocusNode();

  TextEditingController newPasswordConfirmationController = TextEditingController();
  FocusNode newPasswordConfirmationNode = FocusNode();

  bool get newPasswordIsValid => newPasswordController.text == newPasswordConfirmationController.text;
}
