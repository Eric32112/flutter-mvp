import 'package:bot_toast/bot_toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tempo_official/R.Strings.dart';
import 'package:tempo_official/consts/assets.dart';
import 'package:tempo_official/consts/theme.dart';
import 'package:tempo_official/providers/auth_provider.dart';
import 'package:tempo_official/screens/home/home_screen.dart';
import 'package:tempo_official/widgets/tempo_button.dart';
import 'package:tempo_official/widgets/transparent_screen.dart';
import 'package:tempo_official/models/user.dart';

class SetupAccountScreen extends StatelessWidget {
  final List<Interest> interestsSuggestions;
  const SetupAccountScreen({Key key, @required this.interestsSuggestions}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListenableProvider<_SetupAccountScreenModel>(
      create: (_) {
        var model = _SetupAccountScreenModel();
        model.interests = Provider.of<User>(context, listen: false).interests ?? [];
        return model;
      },
      child: Scaffold(
        body: TransparentBackground(
          backgroundImage: TempoAssets.manSittingMoon,
          child: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.all(10.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Image(
                    image: TempoAssets.tempoLogo,
                  ),
                  SizedBox(
                    height: 42.0,
                  ),
                  _buildInterestsContainer(context),
                  SizedBox(
                    height: 18.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FlatButton(
                        child: Text(
                          'Skip',
                          style: TextStyle(
                              color: Colors.white, fontSize: 18.0, fontWeight: FontWeight.w500),
                        ),
                        onPressed: () {
                          Navigator.of(context)
                              .pushReplacement(MaterialPageRoute(builder: (context) => HomeScreen()));
                        },
                      ),
                      Consumer<_SetupAccountScreenModel>(builder: (context, state, child) {
                        return TempoButton(
                          onPressed: () {
                            AuthProvider authProvider =
                                Provider.of<AuthProvider>(context, listen: false);
                            User user = Provider.of<User>(context, listen: false);
                            authProvider.firestore
                                .collection('users')
                                .document(Provider.of<FirebaseUser>(context, listen: false).email)
                                .updateData(user.copyWith(interests: state.interests).toJson())
                                .then((value) {
                              Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(builder: (context) => HomeScreen()));
                            }).catchError((e) {
                              BotToast.showText(text: 'Failed to update user data');
                            });
                          },
                          text: 'Next',
                          width: 80.0,
                        );
                      })
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInterestsContainer(BuildContext context) {
    return Consumer<_SetupAccountScreenModel>(builder: (context, state, model) {
      return ValueListenableBuilder<TextEditingValue>(
          valueListenable: state.searchController,
          builder: (context, searchValue, child) {
            var showDropdown = state.searching && searchValue.text.isNotEmpty;
            var dropdownItems = interestsSuggestions
                .where((element) => element.label.contains(state.searchController.text))
                .toList();
            return Container(
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.0),
                  color: showDropdown ? Colors.transparent : Colors.white),
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Let’s get to know you better. What are some of your interests?',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.roboto(
                        fontSize: 18.0,
                        color: showDropdown ? Colors.white : Color(0xff16110D),
                        fontWeight: FontWeight.w500),
                  ),
                  SizedBox(
                    height: 16.0,
                  ),
                  Container(
                    width: 315.0,
                    height: 40.0,
                    decoration: BoxDecoration(
                        borderRadius: showDropdown
                            ? BorderRadius.only(
                                topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0))
                            : BorderRadius.circular(10.0),
                        border: Border.all(
                            width: 1.0, color: showDropdown ? Colors.transparent : Colors.black),
                        color: showDropdown ? Colors.white : Colors.transparent),
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: TextFormField(
                      decoration: InputDecoration(
                          hintText: TempoStrings.hintTextSignUpInterests, border: InputBorder.none),
                      focusNode: state.searchFocusNode,
                      controller: state.searchController,
                      onChanged: (searchTerm) {},
                    ),
                  ),
                  showDropdown
                      ? Container(
                          width: 315.0,
                          padding: EdgeInsets.only(left: 8.0, right: 8.0, top: 16.0),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                  bottomRight: Radius.circular(10), bottomLeft: Radius.circular(10.0))),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: dropdownItems.map<Widget>((e) {
                              var indexOf = dropdownItems.indexOf(e);
                              return InkWell(
                                onTap: () {
                                  List<Interest> newList = state.interests;
                                  if (state.interests.indexWhere((element) => element.id == e.id) ==
                                      -1) {
                                    newList.add(e);
                                    state.interests = newList;
                                    state.searchController.clear();
                                  }
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
                                  child: Text(e.label),
                                  decoration: BoxDecoration(
                                      border: indexOf == dropdownItems.length - 1
                                          ? null
                                          : Border(
                                              bottom: BorderSide(color: Color(0xffC1C1C1), width: 1.5))),
                                ),
                              );
                            }).toList(),
                          ),
                        )
                      : SizedBox.shrink(),
                  SizedBox(
                    height: 16.0,
                  ),
                  Text(
                    TempoStrings.orSelectFromSomeOfThese,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.roboto(
                        fontSize: 18.0, color: Color(0xff16110D), fontWeight: FontWeight.w500),
                  ),
                  SizedBox(
                    height: 16.0,
                  ),
                  _buildSuggestedInterests(context, state),
                  SizedBox(
                    height: 16.0,
                  ),
                  _buildSelectedInterestsContainer(context, state)
                ],
              ),
            );
          });
    });
  }

  Widget _buildSuggestedInterests(BuildContext context, _SetupAccountScreenModel state) {
    return ValueListenableBuilder<TextEditingValue>(
        valueListenable: state.searchController,
        builder: (context, value, child) {
          return Wrap(
            alignment: WrapAlignment.center,
            spacing: 8.0,
            runSpacing: 8.0,
            children: interestsSuggestions
                .map((e) => _buildTile(
                    interest: e,
                    onPressed: () {
                      var interest = e;
                      if (state.interests.indexWhere((e) => interest.id == e.id) == -1) {
                        state.interests = [...state.interests, interest];
                      }
                    }))
                .toList(),
          );
        });
  }

  Widget _buildTile({@required Interest interest, @required Function onPressed}) {
    return InkWell(
      onTap: () {
        onPressed();
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Text(
          '#' + interest?.label ?? '',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.0,
            fontWeight: FontWeight.w500,
          ),
        ),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
            color: TempoTheme.primaryBtnColor,
            boxShadow: [
              BoxShadow(offset: Offset(0, 4.0), blurRadius: 4.0, color: Color.fromRGBO(0, 0, 0, 0.25))
            ]),
      ),
    );
  }

  Widget _buildSelectedInterestsContainer(BuildContext context, _SetupAccountScreenModel state) {
    return Container(
        height: 180.0,
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16.0), color: Color(0xffF3D6BC)),
        child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 8.0,
            runSpacing: 8.0,
            children: state.interests
                .map((e) => _buildTile(
                    interest: e,
                    onPressed: () {
                      List<Interest> newList = state.interests;
                      newList.removeWhere((element) => element.id == e.id);
                      state.interests = newList;
                    }))
                .toList()));
  }
}

class _SetupAccountScreenModel extends ChangeNotifier {
  TextEditingController searchController = TextEditingController();

  FocusNode searchFocusNode = FocusNode();
  _SetupAccountScreenModel() {
    searchFocusNode.addListener(() {
      searching = searchFocusNode.hasFocus;
    });
  }

  List<Interest> _interests = [];
  List<Interest> get interests => _interests;
  set interests(List<Interest> value) {
    _interests = value;
    notifyListeners();
  }

  bool _searching = false;
  bool get searching => _searching;
  set searching(bool value) {
    _searching = value;
    notifyListeners();
  }
}
