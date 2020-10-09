import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tempo_official/consts/assets.dart';
import 'package:tempo_official/consts/theme.dart';
import 'package:tempo_official/providers/auth_provider.dart';
import 'package:tempo_official/screens/home/home_screen.dart';
import 'package:tempo_official/widgets/tempo_button.dart';
import 'package:tempo_official/widgets/tempo_text_input.dart';
import 'package:tempo_official/widgets/transparent_screen.dart';
import 'package:validators/validators.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TransparentBackground(
        backgroundImage: TempoAssets.manHoldingFlag,
        left: -30.0,
        bottom: 0,
        child: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: ChangeNotifierProvider<_SignupScreenViewModel>(
              create: (_) => _SignupScreenViewModel(),
              child: Consumer<_SignupScreenViewModel>(
                builder: (context, state, child) => SingleChildScrollView(
                  child: state.busy
                      ? Center(
                          child: Container(
                            height: 50.0,
                            width: 50.0,
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : Column(children: [
                          SafeArea(
                            child: Image(
                              image: TempoAssets.tempoLogo,
                            ),
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
                                    hint: 'Full name',
                                    controller: state.fullNameCtrl,
                                    inputAction: TextInputAction.next,
                                    inputType: TextInputType.text,
                                    node: state.fullNameNode,
                                    validator: (String value) {
                                      if (value.isNotEmpty && value.replaceAll(' ', '').length >= 2) {
                                        return null;
                                      }
                                      return 'Full name is required and should have two words';
                                    },
                                    onEditingComplete: () =>
                                        FocusScope.of(context).requestFocus(state.emailNode),
                                    // onSubmit: (value) => FocusScope.of(context).requestFocus(state.passwordNode),
                                  ),
                                  SizedBox(
                                    height: 16.0,
                                  ),
                                  TempoTextInput(
                                    hint: 'Email',
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
                                    inputType: TextInputType.text,
                                    node: state.passwordNode,
                                    obscureText: true,
                                    validator: (value) {
                                      if (value.isNotEmpty && value.length > 6) {
                                        return null;
                                      }
                                      return 'Password should be 6 or more digits';
                                    },
                                    onEditingComplete: () =>
                                        FocusScope.of(context).requestFocus(state.retypePasswordNode),
                                    // onSubmit: (value) => FocusScope.of(context).requestFocus(state.passwordNode),
                                  ),
                                  SizedBox(
                                    height: 16.0,
                                  ),
                                  TempoTextInput(
                                    hint: 'Confirm password',
                                    controller: state.retypePasswordCtrl,
                                    inputAction: TextInputAction.done,
                                    node: state.retypePasswordNode,
                                    validator: (value) {
                                      if (state.passwordCtrl.text == value) {
                                        return null;
                                      }
                                      return 'Password and conformation should match';
                                    },
                                    obscureText: true,
                                  ),
                                  SizedBox(
                                    height: 16.0,
                                  ),
                                  TempoButton(
                                    onPressed: () {
                                      _createAccount(context, state);
                                    },
                                    text: 'Create Account',
                                  ),
                                  SizedBox(
                                    height: 16.0,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 60.0,
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            child: Center(
                              child: FlatButton(
                                onPressed: () {
                                  Navigator.of(context)
                                      .push(MaterialPageRoute(builder: (context) => SignupScreen()));
                                },
                                child: RichText(
                                    textAlign: TextAlign.center,
                                    text: TextSpan(style: GoogleFonts.roboto(), children: [
                                      TextSpan(
                                          text: ' By signing up, you agree to our',
                                          style: GoogleFonts.roboto()
                                              .copyWith(fontSize: 18.0, color: Color(0xffC0B9B9))),
                                      TextSpan(
                                          text: '\n Terms & Privacy Policy.',
                                          style: GoogleFonts.roboto().copyWith(
                                              fontSize: 18.0,
                                              color: Colors.grey[600],
                                              fontWeight: FontWeight.bold)),
                                    ])),
                              ),
                            ),
                          )
                        ]),
                ),
              ),
            )),
      ),
    );
  }

  void _createAccount(BuildContext context, _SignupScreenViewModel state) {
    state.busy = true;
    Provider.of<AuthProvider>(context, listen: false)
        .createAccount(
            email: state.emailCtrl.text,
            password: state.passwordCtrl.text,
            userName: state.fullNameCtrl.text)
        .then((value) {
      state.busy = false;
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomeScreen()));
    }).catchError((e) {
      BotToast.showText(text: '${e.message}');
      state.busy = false;
    });
  }
}

class _SignupScreenViewModel extends ChangeNotifier {
  GlobalKey<FormState> formKey = GlobalKey();
  TextEditingController fullNameCtrl = TextEditingController();
  FocusNode fullNameNode = FocusNode();

  TextEditingController emailCtrl = TextEditingController();
  FocusNode emailNode = FocusNode();

  TextEditingController passwordCtrl = TextEditingController();
  FocusNode passwordNode = FocusNode();

  TextEditingController retypePasswordCtrl = TextEditingController();
  FocusNode retypePasswordNode = FocusNode();

  bool _busy = false;
  bool get busy => _busy;
  set busy(value) {
    _busy = value;
    notifyListeners();
  }
}
