import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tempo_official/consts/assets.dart';
import 'package:tempo_official/consts/theme.dart';
import 'package:tempo_official/providers/auth_provider.dart';
import 'package:tempo_official/screens/auth/signup/signup_screen.dart';
import 'package:tempo_official/screens/home/home_screen.dart';
import 'package:tempo_official/widgets/tempo_button.dart';
import 'package:tempo_official/widgets/tempo_text_input.dart';
import 'package:tempo_official/widgets/transparent_screen.dart';
import 'package:validators/validators.dart';
import '../../../R.Strings.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TransparentBackground(
        backgroundImage: TempoAssets.rocketManLeft,
        child: SafeArea(
          child: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: ChangeNotifierProvider<_LoginScreenViewModel>(
                create: (_) => _LoginScreenViewModel(),
                child: Consumer<_LoginScreenViewModel>(
                  builder: (context, state, child) => state.busy
                      ? Center(
                          child: Container(
                            height: 50.0,
                            width: 50.0,
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : Column(children: [
                          Image(
                            image: TempoAssets.tempoLogo,
                          ),
                          SizedBox(
                            height: 95.0,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32.0),
                            child: Form(
                              key: state.formKey,
                              child: Column(
                                children: [
                                  TempoTextInput(
                                    hint: TempoStrings.labelEmail,
                                    controller: state.emailCtrl,
                                    inputAction: TextInputAction.next,
                                    inputType: TextInputType.emailAddress,
                                    node: state.emailNode,
                                    validator: (value) {
                                      if (isEmail(value)) {
                                        return null;
                                      }
                                      return 'Valid E-mail address is required';
                                    },
                                    onEditingComplete: () =>
                                        FocusScope.of(context).requestFocus(state.passwordNode),
                                    // onSubmit: (value) => FocusScope.of(context).requestFocus(state.passwordNode),
                                  ),
                                  SizedBox(
                                    height: 16.0,
                                  ),
                                  TempoTextInput(
                                    hint: 'Password',
                                    controller: state.passwordCtrl,
                                    inputAction: TextInputAction.next,
                                    node: state.passwordNode,
                                    obscureText: true,
                                    validator: (value) {
                                      if (value.isNotEmpty && value.length > 6) {
                                        return null;
                                      }
                                      return 'Password should be 6 or more digits';
                                    },
                                    onEditingComplete: () =>
                                        FocusScope.of(context).requestFocus(state.passwordNode),
                                  ),
                                  SizedBox(
                                    height: 16.0,
                                  ),
                                  TempoButton(
                                    // TODO:: add login logic
                                    onPressed: state.formKey.currentState != null &&
                                            state.formKey.currentState.validate()
                                        ? () {
                                            state.busy = true;
                                            Provider.of<AuthProvider>(context, listen: false)
                                                .login(
                                                    email: state.emailCtrl.text,
                                                    password: state.passwordCtrl.text)
                                                .then((value) {
                                              Navigator.of(context).pushReplacement(
                                                  MaterialPageRoute(builder: (context) => HomeScreen()));
                                            });
                                          }
                                        : () => null,
                                    text: 'Log in',
                                  ),
                                  SizedBox(
                                    height: 16.0,
                                  ),
                                  FlatButton(
                                    child: Text(
                                      'Forgot password?',
                                      style: GoogleFonts.roboto()
                                          .copyWith(color: TempoTheme.linkColor, fontSize: 18.0),
                                    ),
                                    // TODO:: navigate to forget password screen
                                    onPressed: () {},
                                  )
                                ],
                              ),
                            ),
                          ),
                          Container(
                            height: 40.0,
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(color: Colors.white),
                            child: Center(
                              child: FlatButton(
                                onPressed: () {
                                  Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(builder: (context) => SignupScreen()));
                                },
                                child: RichText(
                                    text: TextSpan(style: GoogleFonts.roboto(), children: [
                                  TextSpan(
                                      text: ' Don’t have an account?',
                                      style: GoogleFonts.roboto()
                                          .copyWith(fontSize: 18.0, color: Colors.black)),
                                  TextSpan(
                                      text: ' Sign up!',
                                      style: GoogleFonts.roboto()
                                          .copyWith(fontSize: 18.0, color: TempoTheme.linkColor)),
                                ])),
                              ),
                            ),
                          )
                        ]),
                ),
              )),
        ),
      ),
    );
  }
}

class _LoginScreenViewModel extends ChangeNotifier {
  GlobalKey<FormState> formKey = GlobalKey();
  TextEditingController emailCtrl = TextEditingController();
  FocusNode emailNode = FocusNode();

  TextEditingController passwordCtrl = TextEditingController();
  FocusNode passwordNode = FocusNode();

  bool _busy = false;
  bool get busy => _busy;
  set busy(bool value) {
    _busy = value;
    notifyListeners();
  }
}
