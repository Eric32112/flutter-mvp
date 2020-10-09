import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tempo_official/R.Strings.dart';
import 'package:tempo_official/consts/assets.dart';
import 'package:tempo_official/consts/theme.dart';
import 'package:tempo_official/models/calendar.dart';
import 'package:tempo_official/models/event.dart';
import 'package:tempo_official/models/user.dart';
import 'package:tempo_official/providers/auth_provider.dart';
import 'package:tempo_official/providers/planner_provider.dart';
import 'package:tempo_official/screens/home/add_users_to_calendar/add_users_to_calendar.dart';
import 'package:tempo_official/widgets/tempo_toggle_widget.dart';

class CalendarTile extends StatelessWidget {
  final Calendar calendar;
  const CalendarTile({Key key, this.calendar}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Calendar calendar;
    PlannerProvider provider = Provider.of<PlannerProvider>(context);
    int indexOfCalendar = provider.calendars.indexWhere((element) => element.id == this.calendar.id);
    if (indexOfCalendar != -1) {
      calendar = provider.calendars[indexOfCalendar];
    } else {
      calendar = this.calendar;
    }
    bool isMine = calendar.userId == Provider.of<AuthProvider>(context, listen: false).user.id;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
      child: Column(children: [
        Row(
          children: [
            // move to it's own widget.
            ClipRRect(
              borderRadius: BorderRadius.circular(100.0),
              child: Container(
                height: 40.0,
                width: 40.0,
                decoration: BoxDecoration(shape: BoxShape.circle),
                child: Image(
                  fit: BoxFit.cover,
                  image: calendar.user.avatar != null
                      ? CachedNetworkImageProvider(
                          calendar.user.avatar,
                        )
                      : TempoAssets.defaultAvatar,
                ),
              ),
            ),
            SizedBox(
              width: 16.0,
            ),
            Text(calendar.name ?? ''),
            SizedBox(
              width: 32.0,
            ),
            isMine
                ? TempoToggle(
                    value: calendar.enabled,
                    valueChange: (value) {
                      // TODO::
                    })
                : Checkbox(
                    value: calendar.enabled ?? true,
                    onChanged: (bool value) {
                      calendar = calendar.copyWith(enabled: !value);
                    },
                  ),
            SizedBox(
              width: 0.0,
            ),
            IconButton(
              icon: isMine
                  ? Icon(Icons.share)
                  : Icon(
                      Icons.remove_circle,
                      color: TempoTheme.retroOrange,
                    ),
              onPressed: () {
                if (isMine) {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => AddUsersToCalendarScreen(calendarId: calendar.id)));
                }
              },
            )
          ],
        ),
        calendar.userId == Provider.of<AuthProvider>(context, listen: false).user.id
            ? Column(
                children: [
                  _buildToggleTile(
                      value: calendar.enableEvents,
                      color: TempoTheme.eventsColor,
                      title: TempoStrings.labelEvents,
                      onChange: (value) {
                        calendar = calendar.copyWith(enableEvents: value);
                      }),
                  _buildToggleTile(
                      value: calendar.enableReminders,
                      color: TempoTheme.reminderColor,
                      title: TempoStrings.labelReminders,
                      onChange: (value) {
                        calendar = calendar.copyWith(enableReminders: value);
                      }),
                  _buildToggleTile(
                      value: calendar.enableTasks,
                      color: TempoTheme.tasksColor,
                      title: TempoStrings.labelTasks,
                      onChange: (value) {
                        calendar = calendar.copyWith(enableEvents: value);
                      }),
                  _buildToggleTile(
                      value: calendar.enableRecommendedEvents,
                      color: TempoTheme.recommendedEventsColor,
                      title: TempoStrings.labelRecEvents,
                      onChange: (value) {
                        calendar = calendar.copyWith(enableEvents: value);
                      }),
                  _buildToggleTile(
                      value: calendar.enableRecommendedTasks,
                      color: TempoTheme.recommendedTasksColor,
                      title: TempoStrings.labelRecTasks,
                      onChange: (value) {
                        calendar = calendar.copyWith(enableEvents: value);
                      }),
                ],
              )
            : SizedBox.shrink()
      ]),
    );
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
