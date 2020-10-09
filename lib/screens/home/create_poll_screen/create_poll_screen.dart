import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rounded_date_picker/rounded_picker.dart';
import 'package:provider/provider.dart';
import 'package:tempo_official/R.Strings.dart';
import 'package:tempo_official/consts/assets.dart';
import 'package:tempo_official/consts/theme.dart';
import 'package:tempo_official/models/chat.dart';
import 'package:tempo_official/models/message.dart';
import 'package:tempo_official/models/pool.dart';
import 'package:tempo_official/providers/auth_provider.dart';
import 'package:tempo_official/services/date_helper.dart';

class CreatePollScreen extends StatelessWidget {
  final String chatId;

  const CreatePollScreen({Key key, this.chatId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListenableProvider<_CreatePollScreenProvider>(
      create: (_) => _CreatePollScreenProvider(),
      child: Consumer<_CreatePollScreenProvider>(builder: (context, state, child) {
        return Scaffold(
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
                TempoStrings.labelCreatePoll,
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              actions: [
                Row(children: [
                  InkWell(
                    onTap: state.formKey.currentState != null &&
                            state.formKey.currentState.validate() &&
                            DateTime.fromMillisecondsSinceEpoch(int.parse(state.poll.endsAt))
                                .isAfter(DateTime.now())
                        ? () {
                            AuthProvider authProvider =
                                Provider.of<AuthProvider>(context, listen: false);
                            var doc = authProvider.firestore
                                .collection('chats')
                                .document(chatId)
                                .collection('messages')
                                .document();
                            var msg = Message(
                              id: doc.documentID,
                              type: 'poll',
                              msgText: '',
                              sentBy: authProvider.user.email,
                              sentAt: DateTime.now().millisecondsSinceEpoch.toString(),
                              pool: state.poll,
                            );

                            doc.setData(msg.toJson(), merge: true).then((value) {
                              authProvider.firestore
                                  .collection('chats')
                                  .document(chatId)
                                  .updateData({'lastMessage': msg.toJson()}).then((value) {
                                Navigator.of(context).pop();
                              });
                            });
                          }
                        : () => null,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                        color: TempoTheme.retroOrange,
                      ),
                      width: 80.0,
                      height: 40.0,
                      child: Center(
                        child: Text('Finish',
                            style: TextStyle(
                                color: Colors.white, fontWeight: FontWeight.w500, fontSize: 18.0)),
                      ),
                    ),
                  )
                ]),
                SizedBox(
                  width: 16.0,
                ),
              ],
            ),
            body: SingleChildScrollView(
              child: Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  // TODO change background color
                  color: TempoTheme.backgroundColor,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 16.0),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.0), color: Colors.white),
                        child: Column(
                          children: [
                            Form(
                              key: state.formKey,
                              child: Column(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                                    child: _buildNameInput(context, state),
                                  ),
                                  SizedBox(height: 16.0),
                                  ListTile(
                                    leading: Icon(Icons.poll, color: TempoTheme.retroOrange),
                                    title: Text('Answer options:'),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 32),
                                    child: Column(
                                        children: state.poll.answers.map<Widget>((e) {
                                      var index = state.poll.answers.indexOf(e);
                                      return Container(
                                        width: MediaQuery.of(context).size.width * .8,
                                        height: 60.0,
                                        child: Row(
                                          children: [
                                            Text('${index + 1}.'),
                                            SizedBox(
                                              width: 8.0,
                                            ),
                                            Container(
                                                width: MediaQuery.of(context).size.width * .7,
                                                child: TextFormField(
                                                  controller: state.answerCtrls[index],
                                                  focusNode: state.answersNodes[index],
                                                  validator: (value) {
                                                    if (value.isEmpty) {
                                                      return 'Answer should not be empty';
                                                    }
                                                    return null;
                                                  },
                                                  onChanged: (value) {
                                                    state.poll.answers[index] =
                                                        state.poll.answers[index].copyWith(value: value);
                                                    state.poll = state.poll.copyWith();
                                                  },
                                                  decoration: InputDecoration(
                                                      suffixIcon: IconButton(
                                                        icon: Icon(Icons.close),
                                                        onPressed: () {
                                                          state.poll.answers.removeAt(index);
                                                          state.answerCtrls.removeAt(index);
                                                          state.answersNodes.removeAt(index);
                                                          state.notifyListeners();
                                                        },
                                                      ),
                                                      border: UnderlineInputBorder(
                                                          borderSide:
                                                              BorderSide(color: TempoTheme.grey2))),
                                                ))
                                          ],
                                        ),
                                      );
                                    }).toList()),
                                  ),
                                  FlatButton(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.add_circle,
                                          color: TempoTheme.retroOrange,
                                        ),
                                        SizedBox(
                                          width: 8.0,
                                        ),
                                        Text('Add an option')
                                      ],
                                    ),
                                    onPressed: () {
                                      state.answerCtrls.add(TextEditingController());
                                      state.answersNodes.add(FocusNode());
                                      state.poll = state.poll.copyWith(answers: [
                                        ...state.poll.answers,
                                        Answer(id: state.poll.answers.length)
                                      ]);
                                    },
                                  )
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                              child: Text(
                                'Poll ends at: ',
                                style: TextStyle(color: TempoTheme.grey2),
                              ),
                            ),
                            ListTile(
                                onTap: () {
                                  showRoundedDatePicker(
                                    context: context,
                                    initialDate: DateTime.fromMillisecondsSinceEpoch(
                                        int.parse(state.poll.endsAt)),
                                  ).then((value) {
                                    state.poll = state.poll
                                        .copyWith(endsAt: value.millisecondsSinceEpoch.toString());
                                  });
                                },
                                leading: Icon(Icons.calendar_today, color: TempoTheme.retroOrange),
                                title: Text(state.poll.endsAt != null
                                    ? DateHelper.formateDay(DateTime.fromMillisecondsSinceEpoch(
                                        int.parse(state.poll.endsAt)))
                                    : 'Select date')),
                            ListTile(
                                onTap: () {
                                  DateTime _date =
                                      DateTime.fromMillisecondsSinceEpoch(int.parse(state.poll.endsAt));
                                  DateTime _startOfDay =
                                      DateTime(_date.year, _date.month, _date.day, 0, 0, 0);
                                  showRoundedTimePicker(
                                          context: context, initialTime: TimeOfDay.fromDateTime(_date))
                                      .then((value) {
                                    state.poll = state.poll.copyWith(
                                        endsAt: _startOfDay
                                            .add(Duration(hours: value.hour, minutes: value.minute))
                                            .millisecondsSinceEpoch
                                            .toString());
                                  });
                                },
                                leading: Icon(
                                  Icons.timer,
                                  color: TempoTheme.retroOrange,
                                ),
                                title: Text(state.poll.endsAt != null
                                    ? DateHelper.parseTime(DateTime.fromMillisecondsSinceEpoch(
                                        int.parse(state.poll.endsAt)))
                                    : 'Select time')),
                          ],
                        ),
                      ),
                      Image(
                        image: TempoAssets.manRidingRocketComplete,
                        fit: BoxFit.cover,
                      )
                    ],
                  )),
            ));
      }),
    );
  }

  _buildNameInput(BuildContext context, _CreatePollScreenProvider state) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8.0)),
      child: Row(children: [
        InkWell(
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              width: 30.0,
              height: 30.0,
              child: Image(
                image: TempoAssets.pollIcon,
                color: TempoTheme.retroOrange,
              ),
            ),
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width - 120.0,
          child: TextFormField(
            validator: (value) {
              if (value.isEmpty) {
                return 'Question should not be empty';
              }
              return null;
            },
            controller: state.questionCtrl,
            style: TextStyle(color: Colors.black, fontSize: 20.0, fontWeight: FontWeight.bold),
            onChanged: (value) {
              state.poll = state.poll.copyWith(question: value);
            },
            decoration: InputDecoration(
                border: InputBorder.none,
                hintText: TempoStrings.labelAskQuestion,
                hintStyle: TextStyle(color: Colors.black, fontSize: 20.0, fontWeight: FontWeight.bold)),
          ),
        ),
      ]),
    );
  }
}

class _CreatePollScreenProvider extends ChangeNotifier {
  TextEditingController questionCtrl = TextEditingController();
  List<TextEditingController> answerCtrls = [TextEditingController(), TextEditingController()];
  List<FocusNode> answersNodes = [FocusNode(), FocusNode()];
  FocusNode questionNode = FocusNode();

  GlobalKey<FormState> formKey = GlobalKey();

  Pool _pool = Pool(
      answers: [Answer(id: 0), Answer(id: 1)],
      endsAt: DateTime.now().add(Duration(hours: 24)).millisecondsSinceEpoch.toString());
  Pool get poll => _pool;
  set poll(value) {
    _pool = value;
    notifyListeners();
  }
}
