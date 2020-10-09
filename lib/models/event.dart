import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:tempo_official/models/notification.dart';
import 'package:tempo_official/models/user.dart';
// To parse this JSON data, do
//
//     final calendar = calendarFromJson(jsonString);

class Event {
  Event(
      {this.id,
      this.calenderId,
      this.userId,
      this.user,
      this.repeat,
      this.private,
      this.startDate,
      this.endDate,
      this.dateTime,
      this.title,
      this.description,
      this.type,
      this.location,
      this.duration,
      this.timeZone,
      this.notification,
      this.defaultColor,
      this.attachments,
      this.sharedWith,
      this.googleLocationObject});
  final String id;
  final String calenderId;
  final String userId;
  final User user;
  final String repeat;
  final bool private;
  final String startDate;
  final String endDate;
  final String dateTime;
  final String title;
  final String description;
  final String type;
  final Position location;
  final String duration;
  final String timeZone;
  final EventNotification notification;
  final String defaultColor;
  final List<Attachment> attachments;
  final List<String> sharedWith;
  final dynamic googleLocationObject;
  Event copyWith(
          {String id,
          String calenderId,
          String userId,
          User user,
          String repeat,
          bool private,
          String startDate,
          String endDate,
          String dateTime,
          String title,
          String description,
          String type,
          Position location,
          String duration,
          String timeZone,
          EventNotification notification,
          String defaultColor,
          List<Attachment> attachments,
          List<String> sharedWith,
          dynamic googleLocationObject}) =>
      Event(
          id: id ?? this.id,
          calenderId: calenderId ?? this.calenderId,
          userId: userId ?? this.userId,
          user: user ?? this.user,
          repeat: repeat ?? this.repeat,
          private: private ?? this.private,
          startDate: startDate ?? this.startDate,
          endDate: endDate ?? this.endDate,
          dateTime: dateTime ?? this.dateTime,
          title: title ?? this.title,
          description: description ?? this.description,
          type: type ?? this.type,
          location: location ?? this.location,
          duration: duration ?? this.duration,
          timeZone: timeZone ?? this.timeZone,
          notification: notification ?? this.notification,
          defaultColor: defaultColor ?? this.defaultColor,
          attachments: attachments ?? this.attachments,
          sharedWith: sharedWith ?? this.sharedWith,
          googleLocationObject: googleLocationObject ?? this.googleLocationObject);

  factory Event.fromJson(Map<String, dynamic> json) => Event(
      id: json['id'],
      calenderId: json["calenderId"] == null ? null : json["calenderId"],
      userId: json["userId"] == null ? null : json["userId"],
      user: json["user"] == null ? null : User.fromJson(json["user"]),
      repeat: json["repeat"] == null ? null : json["repeat"],
      private: json["private"] == null ? null : json["private"],
      startDate: json["startDate"] == null ? null : json["startDate"],
      endDate: json["endDate"] == null ? null : json["endDate"],
      dateTime: json["dateTime"] == null ? null : json["dateTime"],
      title: json["title"] == null ? null : json["title"],
      description: json["description"] == null ? null : json["description"],
      type: json["type"] == null ? null : json["type"],
      location: json["location"] == null ? null : Position.fromMap(json["location"]),
      duration: json["duration"] == null ? null : json["duration"],
      timeZone: json["timeZone"] == null ? null : json["timeZone"],
      notification:
          json["notification"] == null ? null : EventNotification.fromJson(json["notification"]),
      defaultColor: json["defaultColor"] == null ? null : json["defaultColor"],
      attachments: json["attachments"] == null
          ? null
          : List<Attachment>.from(json["attachments"].map((x) => Attachment.fromJson(x))),
      sharedWith:
          json["sharedWith"] == null ? null : List<String>.from(json["sharedWith"].map((x) => x)),
      googleLocationObject: json['googleLocationObject']);

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "calenderId": calenderId == null ? null : calenderId,
        "userId": userId == null ? null : userId,
        "user": user == null ? null : user.toJson(),
        "repeat": repeat == null ? null : repeat,
        "private": private == null ? null : private,
        "startDate": startDate == null ? null : startDate,
        "endDate": endDate == null ? null : endDate,
        "dateTime": dateTime == null ? null : dateTime,
        "title": title == null ? null : title,
        "description": description == null ? null : description,
        "type": type == null ? null : type,
        "location": location == null ? null : location.toJson(),
        "duration": duration == null ? null : duration,
        "timeZone": timeZone == null ? null : timeZone,
        "notification": notification == null ? null : notification.toJson(),
        "defaultColor": defaultColor == null ? null : defaultColor,
        "attachments":
            attachments == null ? null : List<dynamic>.from(attachments.map((x) => x.toJson())),
        "sharedWith": sharedWith == null ? null : List<dynamic>.from(sharedWith.map((x) => x)),
        'googleLocationObject': googleLocationObject
      };
}

class Attachment {
  Attachment({
    this.type,
    this.url,
  });

  final String type;
  final String url;

  Attachment copyWith({
    String type,
    String url,
  }) =>
      Attachment(
        type: type ?? this.type,
        url: url ?? this.url,
      );

  factory Attachment.fromJson(Map<String, dynamic> json) => Attachment(
        type: json["type"] == null ? null : json["type"],
        url: json["url"] == null ? null : json["url"],
      );

  Map<String, dynamic> toJson() => {
        "type": type == null ? null : type,
        "url": url == null ? null : url,
      };
}
