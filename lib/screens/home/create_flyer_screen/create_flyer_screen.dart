import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_duration_picker/flutter_duration_picker.dart';
import 'package:flutter_rounded_date_picker/rounded_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_editor_pro/image_editor_pro.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:tempo_official/R.Strings.dart';
import 'package:tempo_official/consts/api_keys.dart';
import 'package:tempo_official/consts/assets.dart';
import 'package:tempo_official/consts/theme.dart';
import 'package:tempo_official/models/flyer.dart';
import 'package:tempo_official/models/message.dart';
import 'package:tempo_official/providers/auth_provider.dart';
import 'package:tempo_official/services/date_helper.dart';
import 'package:google_map_location_picker/google_map_location_picker.dart';

class CreateFlyerScreen extends StatelessWidget {
  final String chatId;
  const CreateFlyerScreen({Key key, this.chatId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListenableProvider(
        create: (_) => _CreateFlyerScreenProvider(),
        child: Consumer<_CreateFlyerScreenProvider>(
          builder: (context, state, child) {
            return Scaffold(
                backgroundColor: TempoTheme.backgroundColor,
                appBar: _buildAppBar(context, state),
                body: SingleChildScrollView(
                  child: Container(
                      child: Stack(children: [
                    Container(
                        height: MediaQuery.of(context).size.height * .89,
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                          children: [
                            Container(
                                height: MediaQuery.of(context).size.height * .72,
                                width: MediaQuery.of(context).size.width,
                                margin: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                    color: Colors.white, borderRadius: BorderRadius.circular(20.0)),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                                  child: state.busy
                                      ? Column(
                                          children: [
                                            Container(
                                                child: CircularProgressIndicator(),
                                                width: 50.0,
                                                height: 50.0)
                                          ],
                                        )
                                      : Column(children: [
                                          _buildFlyerMedia(context, state),
                                          _buildInputTile(
                                            context: context,
                                            state: state,
                                            hint: TempoStrings.labelEventName,
                                            valueListenable: state.locationCtrl,
                                            node: state.nameNode,
                                            prefix: ImageIcon(TempoAssets.localActivityIcon,
                                                color: TempoTheme.retroOrange),
                                            suffix: ImageIcon(TempoAssets.penIcon,
                                                color: TempoTheme.retroOrange),
                                          ),
                                          _buildLookLikeInput(
                                            context: context,
                                            state: state,
                                            hint: TempoStrings.labelChooseLoc,
                                            onTab: () {
                                              showLocationPicker(context, ApiKeys.googleMapsApiKey)
                                                  .then((value) {
                                                print(value);
                                                state.flyer = state.flyer.copyWith(
                                                    location: Position(
                                                        longitude: value.latLng.longitude,
                                                        latitude: value.latLng.latitude),
                                                    googleMapsObject: value.address);
                                              });
                                            },
                                            value: state.flyer.googleMapsObject ??
                                                    state.flyer.location != null
                                                ? 'Unknown address of location lat: ${state.flyer.location.latitude} lng: ${state.flyer.location.longitude}'
                                                : 'choose a location',
                                            node: state.locationNode,
                                            prefix: Icon(Icons.place, color: TempoTheme.retroOrange),
                                            suffix: ImageIcon(TempoAssets.penIcon,
                                                color: TempoTheme.retroOrange),
                                          ),
                                          _buildLookLikeInput(
                                            context: context,
                                            state: state,
                                            hint: TempoStrings.labelDate,
                                            value: DateHelper.formateDay(
                                                DateTime.fromMillisecondsSinceEpoch(
                                                    int.parse(state.flyer.date))),
                                            onTab: () {
                                              showRoundedDatePicker(
                                                      context: context,
                                                      initialDate: DateTime.fromMillisecondsSinceEpoch(
                                                          int.parse(state.flyer.date)))
                                                  .then((value) {
                                                if (value != null) {
                                                  state.flyer = state.flyer.copyWith(
                                                      date: value.millisecondsSinceEpoch.toString());
                                                }
                                              });
                                            },
                                            node: state.nameNode,
                                            prefix:
                                                Icon(Icons.date_range, color: TempoTheme.retroOrange),
                                            suffix: ImageIcon(TempoAssets.chevronDown,
                                                color: TempoTheme.retroOrange),
                                          ),
                                          _buildLookLikeInput(
                                            context: context,
                                            state: state,
                                            hint: TempoStrings.labelTime,
                                            onTab: () {
                                              showRoundedTimePicker(
                                                      context: context, initialTime: TimeOfDay.now())
                                                  .then((firstValue) {
                                                if (firstValue != null) {
                                                  showRoundedTimePicker(
                                                          context: context, initialTime: firstValue)
                                                      .then((value) {
                                                    DateTime date = DateTime.fromMillisecondsSinceEpoch(
                                                        int.parse(state.flyer.date));
                                                    state.flyer = state.flyer.copyWith(
                                                        date: DateTime(date.year, date.month, date.day)
                                                            .add(Duration(
                                                                hours: firstValue.hour,
                                                                minutes: firstValue.minute))
                                                            .millisecondsSinceEpoch
                                                            .toString(),
                                                        endDate:
                                                            DateTime(date.year, date.month, date.day)
                                                                .add(Duration(
                                                                    hours: value.hour,
                                                                    minutes: value.minute))
                                                                .millisecondsSinceEpoch
                                                                .toString());
                                                  });
                                                }
                                              });
                                            },
                                            value: DateHelper.formateStartAndEndTime(
                                                DateTime.fromMillisecondsSinceEpoch(
                                                    int.parse(state.flyer.date)),
                                                DateTime.fromMillisecondsSinceEpoch(
                                                    int.parse(state.flyer.endDate))),
                                            node: state.nameNode,
                                            prefix: Icon(Icons.timer, color: TempoTheme.retroOrange),
                                            suffix: ImageIcon(TempoAssets.chevronDown,
                                                color: TempoTheme.retroOrange),
                                          ),
                                          _buildLookLikeInput(
                                            context: context,
                                            state: state,
                                            onTab: () {
                                              showModalBottomSheet(
                                                  context: context,
                                                  backgroundColor: Colors.transparent,
                                                  builder: (context) {
                                                    return Container(
                                                        height: MediaQuery.of(context).size.height * .4,
                                                        width: MediaQuery.of(context).size.width,
                                                        decoration: BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius: BorderRadius.only(
                                                                topLeft: Radius.circular(20.0),
                                                                topRight: Radius.circular(20.0))),
                                                        child: Column(
                                                            children: state.tillEndOption
                                                                .map((e) => ListTile(
                                                                      onTap: () {
                                                                        Navigator.of(context).pop();
                                                                        if (state.tillEndOption.last ==
                                                                            e) {
                                                                          showRoundedDatePicker(
                                                                                  context: context,
                                                                                  initialDate:
                                                                                      DateTime.now().add(
                                                                                          Duration(
                                                                                              days: 1)))
                                                                              .then((date) {
                                                                            showRoundedTimePicker(
                                                                                    context: context,
                                                                                    initialTime: TimeOfDay
                                                                                        .fromDateTime(
                                                                                            date))
                                                                                .then((time) {
                                                                              state.flyer = state.flyer.copyWith(
                                                                                  liveTill: date
                                                                                      .add(Duration(
                                                                                          hours:
                                                                                              time.hour,
                                                                                          minutes: time
                                                                                              .minute))
                                                                                      .millisecondsSinceEpoch
                                                                                      .toString());
                                                                            });
                                                                          });
                                                                        } else {
                                                                          state.flyer = state.flyer
                                                                              .copyWith(liveTill: e);
                                                                        }
                                                                      },
                                                                      title: Text(
                                                                          e
                                                                              .replaceAll(
                                                                                '_',
                                                                                ' ',
                                                                              )
                                                                              .replaceRange(0, 1,
                                                                                  e[0].toUpperCase()),
                                                                          style:
                                                                              TextStyle(fontSize: 18.0)),
                                                                    ))
                                                                .toList()));
                                                  });
                                            },
                                            hint: TempoStrings.labelFlyerEndDate,
                                            value: state.flyer.liveTill == null
                                                ? state.tillEndOption.first.replaceAll('_', ' ')
                                                : state.flyer.liveTill.contains('_')
                                                    ? state.flyer.liveTill.replaceAll('_', ' ')
                                                    : DateHelper.formateDate(
                                                        DateTime.fromMillisecondsSinceEpoch(
                                                            int.parse(state.flyer.liveTill))),
                                            node: state.nameNode,
                                            prefix: Icon(Icons.error, color: TempoTheme.retroOrange),
                                            suffix: ImageIcon(TempoAssets.chevronDown,
                                                color: TempoTheme.retroOrange),
                                          ),
                                        ]),
                                )),
                          ],
                        )),
                    Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Image(image: TempoAssets.manRidingRocketComplete, fit: BoxFit.cover)),
                  ])),
                ));
          },
        ));
  }

  Widget _buildFlyerMedia(BuildContext context, _CreateFlyerScreenProvider state) {
    return Container(
      height: 160.0,
      width: 120.0,
      child: Stack(
        children: [
          Container(
            height: 150.0,
            width: 105.0,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.0),
                image: DecorationImage(
                    fit: BoxFit.cover,
                    image: state.flyerImage != null
                        ? FileImage(state.flyerImage)
                        : TempoAssets.defaultFlyer)),
          ),
          Positioned(
            right: 2.0,
            bottom: 2.0,
            child: InkWell(
              onTap: () {
                final getEditImage = Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return ImageEditorPro(
                    appBarColor: Colors.blue,
                    bottomBarColor: Colors.blue,
                  );
                })).then((getEditImage) {
                  if (getEditImage != null) {
                    state.flyerImage = getEditImage;
                  }
                }).catchError((er) {
                  print(er);
                });
              },
              child: Container(
                  height: 36.0,
                  width: 36.0,
                  child: Center(
                      child: Container(
                          height: 18.0, width: 18.0, child: Image(image: TempoAssets.cameraIcon))),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: TempoTheme.retroOrange,
                      border: Border.all(width: 2.0, color: Colors.white))),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, _CreateFlyerScreenProvider state) {
    return AppBar(
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
        TempoStrings.labelCreateFlyer,
        style: TextStyle(fontWeight: FontWeight.w500),
      ),
      actions: [
        Row(children: [
          InkWell(
            onTap: () async {
              var canGoNext = DateTime.fromMillisecondsSinceEpoch(int.parse(state.flyer.endDate))
                  .isAfter(DateTime.now());
              print('DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD $canGoNext');
              if (!canGoNext) {
                return null;
              }
              state.busy = true;
              AuthProvider authProvider = Provider.of<AuthProvider>(context, listen: false);
              var doc = authProvider.firestore
                  .collection('chats')
                  .document(chatId)
                  .collection('messages')
                  .document();
              var imagePath;
              if (state.flyerImage != null) {
                imagePath = await authProvider.uploadFile(
                    state.flyerImage,
                    authProvider.storage
                        .ref()
                        .child('chats')
                        .child(chatId)
                        .child(doc.documentID)
                        .child('flyer_img'));
              }

              var msg = Message(
                id: doc.documentID,
                type: 'flyer',
                msgText: '${authProvider.user.email} added a Flyer',
                sentBy: authProvider.user.email,
                sentAt: DateTime.now().millisecondsSinceEpoch.toString(),
                flyer: state.flyer.copyWith(imageUrl: imagePath),
              );

              doc.setData(msg.toJson(), merge: true).then((value) {
                authProvider.firestore
                    .collection('chats')
                    .document(chatId)
                    .updateData({'lastMessage': msg.toJson()}).then((value) {
                  BotToast.showText(text: 'Added Flyer ');

                  Navigator.of(context).pop();
                });
              });
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                color: TempoTheme.retroOrange,
              ),
              width: 80.0,
              height: 40.0,
              child: Center(
                child: Text('Finish',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 18.0)),
              ),
            ),
          )
        ]),
        SizedBox(
          width: 16.0,
        ),
      ],
    );
  }

  Widget _buildInputTile(
      {context,
      _CreateFlyerScreenProvider state,
      TextEditingController valueListenable,
      FocusNode node,
      String hint,
      Widget prefix,
      bool enabled,
      Widget suffix}) {
    return ValueListenableBuilder(
        valueListenable: valueListenable,
        builder: (context, value, child) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {},
                icon: prefix,
              ),
              Container(
                  width: MediaQuery.of(context).size.width * .55,
                  height: 80.0,
                  padding: EdgeInsets.all(8),
                  child: TextFormField(
                      controller: valueListenable,
                      focusNode: node,
                      enabled: enabled ?? true,
                      autovalidate: true,
                      validator: (value) {
                        return value.isNotEmpty ? null : 'Flyer Event name should not be empty';
                      },
                      style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        hintText: hint,
                        labelText: hint,
                        border: InputBorder.none,
                      ))),
              IconButton(
                icon: suffix,
                onPressed: () {
                  FocusScope.of(context).requestFocus(node);
                },
              )
            ],
          );
        });
  }

  Widget _buildLookLikeInput(
      {context,
      _CreateFlyerScreenProvider state,
      String value,
      FocusNode node,
      String hint,
      Widget prefix,
      bool enabled,
      Widget suffix,
      Function onTab}) {
    return InkWell(
      onTap: () {
        onTab();
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            onPressed: () {},
            icon: prefix,
          ),
          Container(
              width: MediaQuery.of(context).size.width * .55,
              height: 80.0,
              padding: EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(hint,
                      maxLines: 1,
                      style: TextStyle(
                          fontSize: 12.0, fontWeight: FontWeight.bold, color: TempoTheme.retroOrange)),
                  SizedBox(height: 4.0),
                  Text(value,
                      maxLines: 1, style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold)),
                ],
              )),
          IconButton(
            iconSize: 16.0,
            icon: suffix,
            onPressed: () {
              onTab();
            },
          )
        ],
      ),
    );
  }
}

class _CreateFlyerScreenProvider extends ChangeNotifier {
  TextEditingController nameCtrl = TextEditingController();
  FocusNode nameNode = FocusNode();
  TextEditingController locationCtrl = TextEditingController();
  FocusNode locationNode = FocusNode();
  List<String> tillEndOption = ['until_removed', '1_month', '1_week', '1_day', 'custom'];
  GlobalKey<FormState> formKey = GlobalKey();

  File _flyerImage;
  File get flyerImage => _flyerImage;
  set flyerImage(File value) {
    _flyerImage = value;
    notifyListeners();
  }

  Flyer _flyer = Flyer(
      date: DateTime.now().millisecondsSinceEpoch.toString(),
      endDate: DateTime.now().add(Duration(hours: 2)).millisecondsSinceEpoch.toString(),
      liveTill: 'until_removed');
  Flyer get flyer => _flyer;
  set flyer(Flyer value) {
    _flyer = value;
    notifyListeners();
  }

  bool _busy = false;
  bool get busy => _busy;
  set busy(value) {
    _busy = value;
    notifyListeners();
  }
}
