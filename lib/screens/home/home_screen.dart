import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tempo_official/R.Strings.dart';
import 'package:tempo_official/consts/assets.dart';
import 'package:tempo_official/consts/theme.dart';
import 'package:tempo_official/models/calendar.dart';
import 'package:tempo_official/models/chat.dart';
import 'package:tempo_official/models/event.dart';
import 'package:tempo_official/providers/auth_provider.dart';
import 'package:tempo_official/providers/planner_provider.dart';
import 'package:tempo_official/providers/social_provider.dart';
import 'package:tempo_official/screens/home/add_calendar_screen/add_calendar_screen.dart';
import 'package:tempo_official/screens/home/add_event_screen/add_event_screen.dart';
import 'package:tempo_official/screens/home/create_chat_screen/create_chat_screen.dart';
import 'package:tempo_official/screens/home/tabs/explore/explore_tab.dart';
import 'package:tempo_official/screens/home/tabs/planner/planner_tab.dart';
import 'package:tempo_official/screens/home/tabs/socail/social_tab.dart';
import 'package:tempo_official/screens/home/tabs/goals/goals_tab.dart';
import 'package:tempo_official/services/locator_service.dart';
import 'package:tempo_official/widgets/calendar_tile_widget.dart';
import 'package:collection/collection.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    HomeScreenProvider provider = locator<HomeScreenProvider>();
    return ChangeNotifierProvider<HomeScreenProvider>.value(
        value: provider,
        child: Consumer<HomeScreenProvider>(builder: (context, state, child) {
          AuthProvider authProvider = Provider.of<AuthProvider>(context);
          PlannerProvider plannerProvider = Provider.of<PlannerProvider>(context);
          return authProvider.user != null && authProvider.user.email != null
              ? StreamBuilder<List<Calendar>>(
                  stream: plannerProvider.getUserCalendars(authProvider.user.email),
                  builder: (context, AsyncSnapshot<List<Calendar>> snapshot) {
                    print(snapshot.data);
                    if (snapshot.hasData && snapshot.data != null) {
                      if (snapshot.data.length != plannerProvider.calendars.length ||
                          ListEquality().equals(snapshot.data, plannerProvider.calendars)) {
                        plannerProvider.calendars = snapshot.data;
                      }
                      if (plannerProvider.selectedCalendar == null) {
                        plannerProvider.selectedCalendar =
                            snapshot.data.isNotEmpty && snapshot.data.first != null
                                ? snapshot.data.first
                                : null;
                      }
                    }
                    return Scaffold(
                        key: state.scaffoldKey,
                        drawer: Drawer(
                          child: Container(
                            height: MediaQuery.of(context).size.height,
                            width: 319.0,
                            padding: EdgeInsets.symmetric(vertical: 32.0, horizontal: 0.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 116.0,
                                      child: Image(
                                        image: TempoAssets.tempoLogo,
                                      ),
                                    ),
                                    Text('Calendar',
                                        style: TextStyle(
                                            color: TempoTheme.grey2,
                                            fontSize: 39.0,
                                            fontWeight: FontWeight.w300))
                                  ],
                                ),
                                Container(
                                    height: MediaQuery.of(context).size.height - 200.0,
                                    child: ListView(
                                      children: plannerProvider.calendars
                                          .map((e) => CalendarTile(
                                                calendar: e,
                                              ))
                                          .toList(),
                                    )),
                                InkWell(
                                  onTap: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(builder: (context) => AddCalendarScreen()));
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                                    child: Row(children: [
                                      Icon(Icons.add_circle, color: TempoTheme.retroOrange),
                                      SizedBox(width: 16.0),
                                      Text(TempoStrings.labelAddCalendar),
                                    ]),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        bottomNavigationBar: BottomNavigationBar(
                          unselectedItemColor: Color(0xff16110D),
                          onTap: (index) {
                            state.activeTab = index;
                          },
                          type: BottomNavigationBarType.fixed,
                          currentIndex: state.activeTab,
                          items: [
                            BottomNavigationBarItem(
                                icon: Image(image: TempoAssets.plannerTabIconInactive),
                                title: Text(
                                  TempoStrings.navBarTextPlanner,
                                  style: GoogleFonts.roboto().copyWith(fontWeight: FontWeight.w200),
                                ),
                                activeIcon: Image(image: TempoAssets.plannerTabIconActive)),
                            BottomNavigationBarItem(
                                icon: Image(image: TempoAssets.socialTabIconInActive),
                                title: Text(
                                  TempoStrings.navBaTextSocial,
                                  style: GoogleFonts.roboto().copyWith(fontWeight: FontWeight.w200),
                                ),
                                activeIcon: Image(image: TempoAssets.socialTabIconActive)),
                            BottomNavigationBarItem(
                                icon: Image(image: TempoAssets.exploreTabIconInActive),
                                title: Text(
                                  TempoStrings.navBarTextExplore,
                                  style: GoogleFonts.roboto().copyWith(fontWeight: FontWeight.w200),
                                ),
                                activeIcon: Image(image: TempoAssets.exploreTabIconInActive)),
                            BottomNavigationBarItem(
                                icon: Image(image: TempoAssets.goalTabIconInActive),
                                title: Text(
                                  TempoStrings.navBarTextGoal,
                                  style: GoogleFonts.roboto().copyWith(fontWeight: FontWeight.w200),
                                ),
                                activeIcon: Image(image: TempoAssets.goalTabIconInActive)),
                          ],
                          // TODO::
                          backgroundColor: Color(0xffEFE6D4),
                        ),
                        floatingActionButton: state.activeTab == 0
                            ? buildSpeedDial(context, state)
                            : state.activeTab == 1
                                ? FloatingActionButton(
                                    onPressed: () {
                                      Navigator.of(context).push(MaterialPageRoute(
                                          builder: (context) => CreateChatScreen(isEdit: false)));
                                    },
                                    child: Container(
                                        height: 20.0,
                                        width: 20.0,
                                        child: Image(
                                            image: TempoAssets.chatBubblesIcon, fit: BoxFit.contain)))
                                : null,
                        body: Consumer<SocialProvider>(
                          builder: (context, socialProvider, child) => StreamBuilder<List<Chat>>(
                              stream: socialProvider.getChatRooms(authProvider.user.id),
                              builder: (context, snapshot) {
                                if (snapshot.data != null &&
                                    (socialProvider.chats == null ||
                                        ListEquality().equals(snapshot.data, socialProvider.chats))) {
                                  socialProvider.chats = snapshot.data;
                                }
                                return Builder(builder: (context) {
                                  switch (state.activeTab) {
                                    case 0:
                                      return PlannerTab();
                                      break;
                                    case 1:
                                      return SocialTab();
                                      break;
                                    case 2:
                                      return ExploreTab();
                                      break;
                                    case 3:
                                      return GoalsTab();
                                      break;
                                    default:
                                      return PlannerTab();
                                  }
                                });
                              }),
                        ));
                  })
              : Center(child: Container(height: 50.0, width: 50.0, child: CircularProgressIndicator()));
        }));
  }

  SpeedDial buildSpeedDial(BuildContext context, HomeScreenProvider state) {
    return SpeedDial(
      animatedIcon: AnimatedIcons.add_event,
      backgroundColor: TempoTheme.retroOrange,
      overlayColor: TempoTheme.retroOrange.withOpacity(0.9),
      animatedIconTheme: IconThemeData(size: 22.0),
      onOpen: () => print('OPENING DIAL'),
      onClose: () {},
      visible: state.activeTab == 0,
      curve: Curves.bounceIn,
      children: [
        SpeedDialChild(
          child: Icon(Icons.calendar_today),
          backgroundColor: TempoTheme.retroOrange,
          onTap: () {
            _addEvent(context, event: Event(type: 'event'));
          },
          labelWidget: Container(
            margin: EdgeInsets.only(right: 10),
            child: Text(
              TempoStrings.labelEvents,
              style: TextStyle(color: Colors.white, fontSize: 18.0),
            ),
          ),
        ),
        SpeedDialChild(
          child: Icon(Icons.check_box_outline_blank),
          backgroundColor: TempoTheme.retroOrange,
          onTap: () {
            _addEvent(context, event: Event(type: 'task'));
          },
          label: TempoStrings.labelTasks,
          labelWidget: Container(
            margin: EdgeInsets.only(right: 10),
            child: Text(
              TempoStrings.labelTasks,
              style: TextStyle(color: Colors.white, fontSize: 18.0),
            ),
          ),
        ),
        SpeedDialChild(
          child: Icon(Icons.info_outline, color: Colors.black),
          backgroundColor: TempoTheme.retroOrange,
          onTap: () {
            _addEvent(context, event: Event(type: 'reminder'));
          },
          labelWidget: Container(
            margin: EdgeInsets.only(right: 10),
            child: Text(
              TempoStrings.labelReminders,
              style: TextStyle(color: Colors.white, fontSize: 18.0),
            ),
          ),
        ),
      ],
    );
  }

  _addEvent(BuildContext context, {Event event}) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => AddEventScreen(
              eventType: event.type,
              calendarId:
                  Provider.of<PlannerProvider>(context, listen: false).selectedCalendar?.id ?? '',
            )));
  }
}

class HomeScreenProvider extends ChangeNotifier {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  int _activeTab = 0;
  int get activeTab => _activeTab;
  set activeTab(int value) {
    _activeTab = value;
    notifyListeners();
  }
}
