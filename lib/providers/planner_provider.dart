import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:tempo_official/models/event.dart';
import 'package:tempo_official/models/calendar.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';

class PlannerProvider extends ChangeNotifier {
  PlannerProvider() {
    getTimeZoneLocation();
  }
  Firestore firestore = Firestore.instance;
  List<Calendar> _calendars = [];
  List<Calendar> get calendars => _calendars;
  String timeZone;
  set calendars(List<Calendar> value) {
    _calendars = value;
    Future.delayed(Duration(milliseconds: 50), () {
      notifyListeners();
    });
  }

  Calendar _selectedCalendar;
  Calendar get selectedCalendar => _selectedCalendar;
  set selectedCalendar(Calendar value) {
    _selectedCalendar = value;
    Future.delayed(Duration(milliseconds: 50), () => notifyListeners());
  }

  Future<void> addCalendar(Calendar calendar) async {
    DocumentReference doc = firestore.collection('calendars').document();
    return await doc.setData(calendar.copyWith(id: doc.documentID).toJson(), merge: true);
  }

  Stream<List<Calendar>> getUserCalendars(String email) {
    return firestore
        .collection('calendars')
        .where('userId', isEqualTo: email)
        .snapshots()
        .asBroadcastStream()
        .map<List<Calendar>>((event) {
      return event.documents.map<Calendar>((e) {
        print(' EEEEEEEEEEEEEEEEEEEEEEEEEEE ${e.data}');
        return Calendar.fromJson(e.data);
      }).toList();
    });
  }

  Future<void> addEvent(Event event) async {
    DocumentReference doc = firestore.collection('events').document();
    return await doc.setData(event.copyWith(id: doc.documentID).toJson(), merge: true);
  }

  Future<String> getTimeZoneLocation() async {
    var tmz = await FlutterNativeTimezone.getLocalTimezone();
    this.timeZone = tmz;
    notifyListeners();
    return tmz;
  }
}
