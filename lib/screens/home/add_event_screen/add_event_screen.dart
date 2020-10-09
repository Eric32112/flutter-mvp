import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_duration_picker/flutter_duration_picker.dart';
import 'package:flutter_rounded_date_picker/rounded_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_map_location_picker/google_map_location_picker.dart';
import 'package:provider/provider.dart';
import 'package:tempo_official/R.Strings.dart';
import 'package:tempo_official/consts/api_keys.dart';
import 'package:tempo_official/consts/assets.dart';
import 'package:tempo_official/consts/events_conts.dart';
import 'package:tempo_official/consts/theme.dart';
import 'package:tempo_official/models/calendar.dart';
import 'package:tempo_official/models/event.dart';
import 'package:tempo_official/models/notification.dart';
import 'package:tempo_official/providers/auth_provider.dart';
import 'package:tempo_official/providers/planner_provider.dart';
import 'package:tempo_official/services/date_helper.dart';
import 'package:tempo_official/widgets/tempo_toggle_widget.dart';

class AddEventScreen extends StatelessWidget {
  final String eventType;
  final String calendarId;
  AddEventScreen({Key key, @required this.eventType, @required this.calendarId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListenableProvider<_AddEventScreenProvider>(
      create: (_) {
        _AddEventScreenProvider provider = _AddEventScreenProvider(eventType, calendarId);
        var timeZone = Provider.of<PlannerProvider>(context, listen: false).timeZone;
        provider.event = provider.event.copyWith(
            dateTime: DateTime.now().add(Duration(days: 1)).millisecondsSinceEpoch.toString(),
            calenderId: calendarId,
            type: eventType,
            startDate: DateTime.now().add(Duration(days: 1)).millisecondsSinceEpoch.toString(),
            endDate:
                DateTime.now().add(Duration(days: 1, minutes: 15)).millisecondsSinceEpoch.toString(),
            timeZone: timeZone,
            duration: Duration(minutes: 15).inMilliseconds.toString(),
            notification: EventNotification(
                description: '',
                time: DateTime.now().add(Duration(days: 1)).millisecondsSinceEpoch.toString(),
                message: 'You have task',
                value: '1_day'));
        return provider;
      },
      child: Consumer<_AddEventScreenProvider>(
        builder: (context, state, child) {
          PlannerProvider plannerProvider = Provider.of<PlannerProvider>(context);
          Calendar calendar;

          if (calendarId != null) {
            int indexOfCalendar =
                plannerProvider.calendars.indexWhere((element) => element.id == calendarId);
            calendar = plannerProvider.calendars[indexOfCalendar != -1 ? indexOfCalendar : 0];
          }
          print('SSSSSSSSSSSSSSSSSSSSSSSS ${eventType}');
          return Scaffold(
            body: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: [
                  SizedBox(height: 44.0),
                  _buildHeaderContainer(context, state),
                  _buildNameInput(context, state),
                  eventType == 'reminder'
                      ? _buildDateReminderDatePicker(context, state)
                      : SizedBox.shrink(),
                  eventType != 'task' ? _buildInfoRow(context, plannerProvider, calendar) : SizedBox(),
                  eventType == 'task'
                      ? _buildRow(
                          onTap: () async {
                            DateTime dateTime = await _buildDateTimePicker(context, state);
                            state.event = state.event
                                .copyWith(dateTime: dateTime.millisecondsSinceEpoch.toString());
                            updateNotificationTime(state, state.event.notification?.value ?? '1_day');
                          },
                          title: state.event.dateTime != null
                              ? DateHelper.formateDate(
                                  DateTime.fromMillisecondsSinceEpoch(int.parse(state.event.dateTime)))
                              : 'Due date and time',
                          data: {},
                          leading: Container(
                            width: 20.0,
                            height: 20.0,
                            child: Image(
                              image: TempoAssets.flagIcon,
                              fit: BoxFit.contain,
                            ),
                          ))
                      : SizedBox.shrink(),
                  eventType == 'task'
                      ? _buildRow(
                          onTap: () {
                            _buildDurationPicker(context, state);
                          },
                          title: state.event.duration != null
                              ? DateHelper.parseDuration(state.event.duration)
                              : 'Estimated Completion Time',
                          data: {},
                          leading: Container(
                            width: 20.0,
                            height: 20.0,
                            child: Image(
                              image: TempoAssets.stopWatchIcon,
                              fit: BoxFit.contain,
                            ),
                          ))
                      : SizedBox.shrink(),
                  eventType == 'task'
                      ? _buildRow(
                          onTap: () {
                            if (state.event.dateTime == null) {
                              BotToast.showText(text: '$eventType due date is required');
                            } else if (state.event.title == null) {
                              BotToast.showText(text: '$eventType title is required');
                            } else {
                              _buildEventNotificationPicker(context, state);
                            }
                          },
                          title: state.event.timeZone ?? 'Add notification',
                          data: {},
                          leading: Container(
                            width: 20.0,
                            height: 20.0,
                            child: Image(
                              image: TempoAssets.bellIcon,
                              fit: BoxFit.contain,
                            ),
                          ))
                      : SizedBox.shrink(),
                  eventType == 'reminder'
                      ? _buildRow(
                          onTap: () {
                            showModalBottomSheet(
                                context: context,
                                backgroundColor: Colors.transparent,
                                builder: (context) {
                                  return Container(
                                      height: 300.0,
                                      width: MediaQuery.of(context).size.width,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(20.0),
                                            topLeft: Radius.circular(20.0)),
                                      ),
                                      child: Column(
                                          children: EventConstants.reminderDurations.map((e) {
                                        String handledString = e.contains('_')
                                            ? e.replaceRange(e.indexOf('_'), e.indexOf('_') + 1,
                                                ' ' + e[e.indexOf('_') + 1].toUpperCase())
                                            : e.replaceRange(0, 1, e[0].toUpperCase());
                                        return ListTile(
                                          title: Text(handledString),
                                          onTap: () {
                                            if (e == 'custom') {
                                              _buildDurationPicker(context, state);
                                            } else {
                                              Duration duration = Duration(
                                                minutes: e.contains('_minute')
                                                    ? int.parse(e.replaceAll('_minute', ''))
                                                    : 0,
                                                hours: e.contains('_hour')
                                                    ? int.parse(e.replaceAll('_hour', ''))
                                                    : 24,
                                              );
                                              state.event = state.event.copyWith(
                                                  duration: duration.inMilliseconds.toString(),
                                                  endDate: DateHelper.parseFromMilliseconds(
                                                          state.event.startDate)
                                                      .add(duration)
                                                      .millisecondsSinceEpoch
                                                      .toString());
                                            }
                                            Navigator.of(context).pop();
                                          },
                                        );
                                      }).toList()));
                                });
                          },
                          leading: Container(
                              width: 20.0,
                              height: 20.0,
                              child: Image(image: TempoAssets.bellIcon, fit: BoxFit.contain)),
                          title: state.event.duration != null
                              ? DateHelper.getDisplayableDuration(state.event.duration)
                              : 'All-day')
                      : SizedBox.shrink(),
                  eventType == 'event' ? _buildEventDatesPicker(context, state) : SizedBox.shrink(),
                  eventType != 'task'
                      ? _buildRow(
                          title: state.event.timeZone ?? 'Choose your timezone',
                          onTap: () {},
                          leading: Container(
                            height: 20.0,
                            width: 20.0,
                            child: Image(image: TempoAssets.plantIcon, color: TempoTheme.retroOrange),
                          ))
                      : SizedBox.shrink(),
                  _buildRow(
                      onTap: () {},
                      title: state.event.repeat ?? 'Repeats weekly',
                      data: {},
                      leading: Container(
                        width: 20.0,
                        height: 20.0,
                        child: Image(
                          image: TempoAssets.repeatIcon,
                          fit: BoxFit.contain,
                        ),
                      )),
                  eventType == 'event'
                      ? _buildRow(
                          onTap: () {},
                          title: state.event.timeZone ?? 'Add People',
                          data: {},
                          leading: Container(
                            width: 20.0,
                            height: 20.0,
                            child: Image(image: TempoAssets.peopleIcon, fit: BoxFit.contain),
                          ))
                      : SizedBox.shrink(),
                  eventType == 'event'
                      ? _buildRow(
                          onTap: () {
                            showLocationPicker(context, ApiKeys.googleMapsApiKey);
                          },
                          title: state.event.location != null ? state.event.location : 'Add location',
                          data: {},
                          leading: Container(
                            width: 20.0,
                            height: 20.0,
                            child: Image(
                              image: TempoAssets.carbonLocationIcon,
                              fit: BoxFit.contain,
                            ),
                          ))
                      : SizedBox.shrink(),
                  eventType == 'event'
                      ? _buildRow(
                          onTap: () {},
                          title: state.event.notification?.value != null
                              ? state.event.notification.value.replaceAll('_', ' ') + ' before'
                              : 'Add Event Notification',
                          data: {},
                          leading: Container(
                            width: 20.0,
                            height: 20.0,
                            child: Image(
                              image: TempoAssets.bellIcon,
                              fit: BoxFit.contain,
                            ),
                          ))
                      : SizedBox.shrink(),
                  eventType == 'event'
                      ? _buildRow(
                          onTap: () {},
                          title: state.event.description ?? 'Add description',
                          data: {},
                          leading: Container(
                            width: 20.0,
                            height: 20.0,
                            child: Image(
                              image: TempoAssets.documentIcon,
                              fit: BoxFit.contain,
                            ),
                          ))
                      : SizedBox.shrink(),
                  eventType == 'event'
                      ? _buildRow(
                          onTap: () {},
                          title: state.event.attachments ?? 'Add attachment',
                          data: {},
                          leading: Container(
                            width: 20.0,
                            height: 20.0,
                            child: Image(
                              image: TempoAssets.attachmentIcon,
                              fit: BoxFit.contain,
                            ),
                          ))
                      : SizedBox.shrink(),
                  eventType == 'reminder'
                      ? _buildRow(
                          title: 'Default color',
                          leading: Container(
                              height: 20.0,
                              width: 20.0,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle, color: TempoTheme.reminderColor)))
                      : SizedBox.shrink(),
                  Expanded(
                    child: SizedBox.shrink(),
                  ),
                  eventType != 'event'
                      ? Image(
                          image: TempoAssets.manRidingRocketComplete,
                          fit: BoxFit.fitWidth,
                        )
                      : SizedBox.shrink(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderContainer(BuildContext context, _AddEventScreenProvider state) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      IconButton(
        icon: Icon(Icons.close),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
      Container(
        padding: EdgeInsets.symmetric(horizontal: 32.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            eventType != 'task'
                ? TempoToggle(
                    value: state.event.private,
                    valueChange: (value) {
                      state.event = state.event.copyWith(private: value);
                    },
                  )
                : SizedBox.shrink(),
            SizedBox(
              width: 8.0,
            ),
            eventType != 'task'
                ? Text(
                    state.event.private ?? true ? TempoStrings.labelPrivate : TempoStrings.labelPublic,
                    style: GoogleFonts.roboto().copyWith(
                        fontWeight: FontWeight.w500,
                        fontSize: 14.0,
                        height: 16 / 14.0,
                        color: Colors.black),
                  )
                : SizedBox.shrink(),
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
                      .addEvent(state.event.copyWith(
                    user: user,
                    userId: user.id,
                    calenderId: calendarId,
                    type: eventType,
                    title: state.nameController.text,
                  ))
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

  _buildNameInput(BuildContext context, _AddEventScreenProvider state) {
    return Row(children: [
      InkWell(
        onTap: () {
          if (!state.nameFocus.hasFocus) {
            FocusScope.of(context).requestFocus(state.nameFocus);
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: eventType != 'reminder' ? Image(image: TempoAssets.penIcon) : SizedBox.shrink(),
        ),
      ),
      Container(
        width: MediaQuery.of(context).size.width - 120.0,
        child: TextFormField(
          controller: state.nameController,
          focusNode: state.nameFocus,
          style: TextStyle(color: Colors.black, fontSize: 30.0, fontWeight: FontWeight.bold),
          onChanged: (value) {
            state.event = state.event.copyWith(title: value);
          },
          decoration: InputDecoration(
              border: InputBorder.none,
              hintText: eventType == 'event'
                  ? TempoStrings.labelEventName
                  : eventType == 'reminder'
                      ? TempoStrings.labelReminderName
                      : TempoStrings.labelTaskName,
              hintStyle: TextStyle(color: Colors.black, fontSize: 30.0, fontWeight: FontWeight.bold)),
        ),
      ),
    ]);
  }

  _buildInfoRow(BuildContext context, PlannerProvider plannerProvider, Calendar calendar) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      child: Row(
        children: [
          Row(
            children: [
              Container(
                  width: 20.0,
                  height: 20.0,
                  child: Image(
                    image: TempoAssets.flagIcon,
                    fit: BoxFit.fitWidth,
                  )),
              SizedBox(
                width: 8.0,
              ),
              Text(calendar?.name ?? ''),
            ],
          ),
          SizedBox(width: 64.0),
          Row(
            children: [
              Container(
                  width: 20.0,
                  height: 20.0,
                  child: Image(
                    image: TempoAssets.listIcon,
                    fit: BoxFit.fitWidth,
                  )),
              SizedBox(
                width: 8.0,
              ),
              Text(eventType.replaceRange(0, 1, eventType[0].toUpperCase()) ?? 'Event')
            ],
          )
        ],
      ),
    );
  }

  _buildRow({dynamic Function() onTap, String title, Map data, Widget leading}) {
    return InkWell(
      onTap: () {
        onTap();
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 18.0),
        child: Row(
          children: [
            leading,
            SizedBox(
              width: 16.0,
            ),
            Text(
              title,
              style: TextStyle(fontSize: 17.0, height: 20.0 / 17.0),
            )
          ],
        ),
      ),
    );
  }

  Future<DateTime> _buildDateTimePicker(BuildContext context, _AddEventScreenProvider provider) async {
    DateTime newDateTime = await showRoundedDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
      lastDate: DateTime(DateTime.now().year + 1),
      borderRadius: 16,
    );
    TimeOfDay time =
        await showRoundedTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(newDateTime));
    return newDateTime.add(Duration(hours: time.hour, minutes: time.minute));
  }

  _buildDurationPicker(BuildContext context, _AddEventScreenProvider provider) async {
    Duration resultingDuration = await showDurationPicker(
      context: context,
      initialTime: new Duration(minutes: 30),
    );
    provider.event = resultingDuration != null
        ? provider.event.copyWith(
            duration: resultingDuration.inMilliseconds.toString(),
            endDate: DateHelper.parseFromMilliseconds(provider.event.startDate)
                .add(resultingDuration)
                .millisecondsSinceEpoch
                .toString())
        : provider.event;
  }

  _buildEventNotificationPicker(BuildContext context, _AddEventScreenProvider provider) {
    List<String> options = EventConstants.notificationOptions;
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            height: 300.0,
            width: MediaQuery.of(context).size.width,
            child: ListView(
              children: options
                  .map((e) => ListTile(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        leading: Container(
                          width: 20.0,
                          height: 20.0,
                          child: Image(
                            image: TempoAssets.bellIcon,
                            fit: BoxFit.contain,
                          ),
                        ),
                        trailing: provider.event?.notification?.value != null
                            ? Icon(Icons.check, color: TempoTheme.retroOrange)
                            : null,
                        title: Text(e.replaceAll('_', ' ') + ' before'),
                      ))
                  .toList(),
            ),
          );
        });
  }

  updateNotificationTime(_AddEventScreenProvider provider, String value) {
    provider.event = provider.event.copyWith(
        notification: provider.event.notification.change(
            duration: DateHelper.parseDuration(value), dateTime: provider.event.dateTime, value: value));
  }

  String notificationTime(String e, String dateTime, String duration) {
    int durationInMilliseconds = int.parse(duration);
    int timeInMilSec = int.parse(dateTime);
    return ((timeInMilSec + durationInMilliseconds)).toString();
  }

  _buildDateReminderDatePicker(BuildContext context, _AddEventScreenProvider state) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.0),
      child: InkWell(
        onTap: () {
          _buildDateTimePicker(context, state).then((value) {
            if (value != null) {
              state.event = state.event.copyWith(dateTime: value.millisecondsSinceEpoch.toString());
            }
          });
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              DateHelper.formateDay(DateHelper.parseFromMilliseconds(state.event.dateTime)),
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600),
            ),
            Text(
              DateHelper.formatTime(DateHelper.parseFromMilliseconds(state.event.dateTime)),
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  _buildEventDatesPicker(BuildContext context, _AddEventScreenProvider state) {
    return Container(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: InkWell(
              onTap: () {
                _buildDateTimePicker(context, state).then((value) {
                  if (value != null) {
                    state.event =
                        state.event.copyWith(dateTime: value.millisecondsSinceEpoch.toString());
                  }
                });
              },
              child: Row(
                children: [
                  ImageIcon(TempoAssets.clockIcon, color: TempoTheme.retroOrange),
                  SizedBox(
                    width: 16.0,
                  ),
                  Text(
                    'All-Day',
                    style: TextStyle(fontSize: 17.0, height: 20.0 / 17.0),
                  )
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 32.0),
            child: InkWell(
              onTap: () {
                _buildDateTimePicker(context, state).then((value) {
                  state.event = state.event.copyWith(endDate: value.millisecondsSinceEpoch.toString());
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateHelper.formateDay(DateHelper.parseFromMilliseconds(state.event.endDate)),
                    style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.w400),
                  ),
                  Text(
                    DateHelper.formatTime(DateHelper.parseFromMilliseconds(state.event.endDate)),
                    style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 32.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateHelper.formateDay(DateHelper.parseFromMilliseconds(state.event.dateTime)),
                  style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.w400),
                ),
                Text(
                  DateHelper.formatTime(DateHelper.parseFromMilliseconds(state.event.endDate)),
                  style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.w400),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AddEventScreenProvider extends ChangeNotifier {
  final String eventType;
  final String calendarId;
  _AddEventScreenProvider(this.eventType, this.calendarId);

  TextEditingController nameController = TextEditingController();
  FocusNode nameFocus = FocusNode();

  Event _event = Event();
  Event get event => _event;
  set event(Event value) {
    _event = value;
    notifyListeners();
  }
}
