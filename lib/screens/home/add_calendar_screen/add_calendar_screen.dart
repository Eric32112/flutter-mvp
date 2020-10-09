import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tempo_official/R.Strings.dart';
import 'package:tempo_official/consts/assets.dart';
import 'package:tempo_official/consts/theme.dart';
import 'package:tempo_official/models/calendar.dart';
import 'package:tempo_official/models/event.dart';
import 'package:tempo_official/providers/auth_provider.dart';
import 'package:tempo_official/providers/planner_provider.dart';
import 'package:tempo_official/widgets/tempo_toggle_widget.dart';

class AddCalendarScreen extends StatelessWidget {
  const AddCalendarScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListenableProvider<_AddCalendarScreenProvider>(
      create: (_) => _AddCalendarScreenProvider(),
      child: Consumer<_AddCalendarScreenProvider>(builder: (context, state, child) {
        return Scaffold(
          body: SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 32.0, vertical: 64.0),
                    height: MediaQuery.of(context).size.height * .6,
                    child: Column(
                      children: [
                        _buildHeaderContainer(context, state),
                        _buildNameInput(context, state),
                        _buildToggleTile(
                            value: state.calendar.enableEvents,
                            color: TempoTheme.eventsColor,
                            title: TempoStrings.labelEvents,
                            onChange: (value) {
                              state.calendar = state.calendar.copyWith(enableEvents: value);
                            }),
                        _buildToggleTile(
                            value: state.calendar.enableReminders,
                            color: TempoTheme.reminderColor,
                            title: TempoStrings.labelReminders,
                            onChange: (value) {
                              state.calendar = state.calendar.copyWith(enableReminders: value);
                            }),
                        _buildToggleTile(
                            value: state.calendar.enableTasks,
                            color: TempoTheme.tasksColor,
                            title: TempoStrings.labelTasks,
                            onChange: (value) {
                              state.calendar = state.calendar.copyWith(enableEvents: value);
                            }),
                        _buildToggleTile(
                            value: state.calendar.enableRecommendedEvents,
                            color: TempoTheme.recommendedEventsColor,
                            title: TempoStrings.labelRecEvents,
                            onChange: (value) {
                              state.calendar = state.calendar.copyWith(enableEvents: value);
                            }),
                        _buildToggleTile(
                            value: state.calendar.enableRecommendedTasks,
                            color: TempoTheme.recommendedTasksColor,
                            title: TempoStrings.labelRecTasks,
                            onChange: (value) {
                              state.calendar = state.calendar.copyWith(enableEvents: value);
                            }),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Image(
                      fit: BoxFit.cover,
                      image: TempoAssets.manRidingRocketComplete,
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildHeaderContainer(BuildContext context, _AddCalendarScreenProvider state) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      IconButton(
        icon: Icon(Icons.close),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
      Container(
        width: 200.0,
        child: Row(
          children: [
            TempoToggle(
              value: state.calendar.private,
              valueChange: (value) {
                state.calendar = state.calendar.copyWith(private: value);
              },
            ),
            SizedBox(
              width: 8.0,
            ),
            Text(
              state.calendar.private ?? true ? TempoStrings.labelPrivate : TempoStrings.labelPublic,
              style: GoogleFonts.roboto().copyWith(
                  fontWeight: FontWeight.w500, fontSize: 14.0, height: 16 / 14.0, color: Colors.black),
            ),
            SizedBox(
              width: 20.0,
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(4.0),
              child: RaisedButton(
                elevation: 0,
                color: Color(0xffF38D54),
                textColor: Colors.white,
                onPressed: () {
                  var user = Provider.of<AuthProvider>(context, listen: false).user;
                  Provider.of<PlannerProvider>(context, listen: false)
                      .addCalendar(state.calendar.copyWith(user: user, userId: user.id))
                      .then((value) {
                    Navigator.of(context).pop();
                  });
                },
                child: Text(TempoStrings.labelSave),
              ),
            )
          ],
        ),
      )
    ]);
  }

  _buildNameInput(BuildContext context, _AddCalendarScreenProvider state) {
    return Row(children: [
      InkWell(
        onTap: () {
          if (!state.nameFocus.hasFocus) {
            FocusScope.of(context).requestFocus(state.nameFocus);
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Image(image: TempoAssets.penIcon),
        ),
      ),
      Container(
        width: MediaQuery.of(context).size.width - 120.0,
        child: TextFormField(
          controller: state.nameController,
          focusNode: state.nameFocus,
          style: TextStyle(color: Colors.black, fontSize: 30.0, fontWeight: FontWeight.bold),
          onChanged: (value) {
            state.calendar = state.calendar.copyWith(name: value);
          },
          decoration: InputDecoration(
              border: InputBorder.none,
              hintText: TempoStrings.labelCalendarName,
              hintStyle: TextStyle(color: Colors.black, fontSize: 30.0, fontWeight: FontWeight.bold)),
        ),
      ),
    ]);
  }

  _buildToggleTile({bool value, Color color, String title, Function(bool value) onChange}) {
    return ListTile(
      title: Text(title),
      leading: Checkbox(
        value: value,
        activeColor: color,
        onChanged: (_value) {
          onChange(!_value);
        },
      ),
    );
  }
}

class _AddCalendarScreenProvider extends ChangeNotifier {
  TextEditingController nameController = TextEditingController();
  FocusNode nameFocus = FocusNode();
  Calendar _calendar = Calendar(
      name: '',
      private: false,
      enableEvents: true,
      enableRecommendedEvents: true,
      enableRecommendedTasks: true,
      enableReminders: true,
      enableTasks: true,
      enabled: true,
      events: []);
  Calendar get calendar => _calendar;

  set calendar(Calendar value) {
    _calendar = value;
    notifyListeners();
  }
}
