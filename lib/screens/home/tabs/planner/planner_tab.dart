import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:tempo_official/consts/assets.dart';
import 'package:tempo_official/consts/theme.dart';
import 'package:tempo_official/models/event.dart';
import 'package:tempo_official/providers/planner_provider.dart';
import 'package:tempo_official/screens/home/home_screen.dart';
import 'package:tempo_official/screens/home/settings/settings_screen.dart';

import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:tempo_official/services/date_helper.dart';
import 'package:tempo_official/services/locator_service.dart';
import 'package:timezone/timezone.dart';

import 'package:sliver_calendar/sliver_calendar.dart';

class PlannerTab extends StatelessWidget {
  const PlannerTab({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListenableProvider<PlannerTabProvider>(
        create: (_) => locator<PlannerTabProvider>(),
        child: Consumer<PlannerTabProvider>(builder: (context, state, snapshot) {
          PlannerProvider plannerProvider = Provider.of<PlannerProvider>(context);
          print('SDDDDDDDDDDDDDDDDDDDDDDDDDDDDD ${plannerProvider.selectedCalendar.id}');
          return Container(
            child: Column(
              children: [
                AppBar(
                  // shape: ContinuousRectangleBorder(
                  //     borderRadius: BorderRadius.only(
                  //         bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30))),

                  backgroundColor: Colors.white,
                  leading: IconButton(
                      icon: Icon(Icons.menu),
                      onPressed: () {
                        HomeScreenProvider homeScreenProvider =
                            Provider.of<HomeScreenProvider>(context, listen: false);
                        if (homeScreenProvider.scaffoldKey.currentState.isDrawerOpen) {
                          homeScreenProvider.scaffoldKey.currentState.openDrawer();
                        } else {
                          homeScreenProvider.scaffoldKey.currentState.openDrawer();
                        }
                      }),
                  actions: [
                    IconButton(
                      icon: Icon(Icons.settings),
                      onPressed: () {
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (context) => SettingsScreen()));
                      },
                      // TODO::
                      color: Color(0xff2E3A59),
                    )
                  ],
                ),
                Container(
                  height: MediaQuery.of(context).size.height - 150.0,
                  width: MediaQuery.of(context).size.width,
                  child: StreamBuilder<QuerySnapshot>(
                      stream: plannerProvider.firestore
                          .collection('events')
                          .where('calenderId', isEqualTo: plannerProvider.selectedCalendar.id)
                          .snapshots(),
                      builder: (context, snapshot) {
                        return _buildCalenderView(
                            state,
                            snapshot.data != null
                                ? snapshot.data.documents
                                    .map((data) => Event.fromJson(data.data))
                                    .toList()
                                : []);
                      }),
                )
              ],
            ),
          );
        }));
  }

  _buildCalenderView(PlannerTabProvider state, List<Event> events) {
    if (state.tmz != null) {
      TZDateTime nowTime = new TZDateTime.now(state.loc);
      return CalendarWidget(
        // bannerHeader: TempoAssets.defaultCalendarImage,
        // header: SizedBox.shrink(),

        monthHeader: TempoAssets.defaultCalendarImage,
        getEvents: (date, _data) => events
            .where((element) => element.startDate != null)
            .toList()
            .map((e) => CalendarEvent(
                index: events.indexOf(e),
                instantEnd: TZDateTime.fromMillisecondsSinceEpoch(
                    state.loc,
                    e.endDate != null
                        ? int.parse(e.endDate)
                        : e.duration != null
                            ? DateHelper.parseFromMilliseconds(e.startDate)
                                .add(Duration(milliseconds: int.parse(e.duration)))
                            : DateHelper.parseFromMilliseconds(e.startDate).add(Duration(minutes: 30))),
                instant: TZDateTime.fromMillisecondsSinceEpoch(state.loc, int.parse(e.startDate))))
            .toList(),
        buildItem: (context, calendarEvent) {
          Event event = events[calendarEvent.index];
          return EventTile(event: event);
        },
        initialDate: nowTime,
      );
    }
    return Container(
      child: Center(
        child: Container(
          height: 50.0,
          width: 50.0,
          child: CircularProgressIndicator(),
        ),
      ),
    );
    // return TableCalendar(
    //   calendarController: state.calendarController,
    //   initialSelectedDay: DateTime.now(),
    //   calendarStyle: CalendarStyle(),
    //   headerStyle: HeaderStyle(centerHeaderTitle: true, formatButtonVisible: false),
    //   availableGestures: AvailableGestures.horizontalSwipe,
    //   builders: CalendarBuilders(dayBuilder: (context, date, child) {
    //     return Container(
    //       child: Center(child: Text(date.day.toString())),
    //     );
    //   }),
    // );
  }
}

class EventTile extends StatelessWidget {
  final Event event;
  const EventTile({Key key, this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(offset: Offset(0, 4), blurRadius: 4.0, color: Colors.black.withOpacity(.025))
        ],
        color: event.type == 'task'
            ? TempoTheme.tasksColor
            : event.type == 'event'
                ? TempoTheme.eventsColor
                : event.type == 'reminder' ? TempoTheme.reminderColor : TempoTheme.retroOrange,
      ),
      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(event.title,
          style: TextStyle(
              color: Colors.white, fontSize: 18.0, height: 21 / 18, fontWeight: FontWeight.bold)),
    );
  }
}

class PlannerTabProvider extends ChangeNotifier {
  CalendarController calendarController = CalendarController();
  String _tmz;
  String get tmz => _tmz;
  set tmz(String value) {
    _tmz = value;
    notifyListeners();
  }

  Location _loc;
  Location get loc => _loc;
  set loc(Location value) {
    _loc = value;
    notifyListeners();
  }

  PlannerTabProvider() {
    setTimeZone();
  }

  Future<void> setTimeZone() async {
    tmz = await FlutterNativeTimezone.getLocalTimezone();
    loc = getLocation(tmz);
    Future.delayed(Duration(milliseconds: 100), () => notifyListeners());
  }
}
