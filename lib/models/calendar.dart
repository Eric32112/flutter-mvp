import 'dart:convert';

import 'package:tempo_official/models/event.dart';
import 'package:tempo_official/models/user.dart';

Calendar calendarFromJson(String str) => Calendar.fromJson(json.decode(str));

String calendarToJson(Calendar data) => json.encode(data.toJson());

class Calendar {
  Calendar({
    this.id,
    this.userId,
    this.user,
    this.sharedWith,
    this.name,
    this.private,
    this.enableEvents,
    this.enableTasks,
    this.enableReminders,
    this.enableRecommendedEvents,
    this.enableRecommendedTasks,
    this.enabled,
    this.shareableLink,
    this.events,
  });

  final String id;
  final String userId;
  final User user;
  final List<String> sharedWith;
  final String name;
  final bool private;
  final bool enableEvents;
  final bool enableTasks;
  final bool enableReminders;
  final bool enableRecommendedEvents;
  final bool enableRecommendedTasks;
  final bool enabled;
  final String shareableLink;
  final List<Event> events;

  Calendar copyWith({
    String id,
    String userId,
    User user,
    List<String> sharedWith,
    String name,
    bool private,
    bool enableEvents,
    bool enableTasks,
    bool enableReminders,
    bool enableRecommendedEvents,
    bool enableRecommendedTasks,
    bool enabled,
    String shareableLink,
    List<Event> events,
  }) =>
      Calendar(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        user: user ?? this.user,
        sharedWith: sharedWith ?? this.sharedWith,
        name: name ?? this.name,
        private: private ?? this.private,
        enableEvents: enableEvents ?? this.enableEvents,
        enableTasks: enableTasks ?? this.enableTasks,
        enableReminders: enableReminders ?? this.enableReminders,
        enableRecommendedEvents: enableRecommendedEvents ?? this.enableRecommendedEvents,
        enableRecommendedTasks: enableRecommendedTasks ?? this.enableRecommendedTasks,
        enabled: enabled ?? this.enabled,
        shareableLink: shareableLink ?? this.shareableLink,
        events: events ?? this.events,
      );

  factory Calendar.fromJson(Map<String, dynamic> json) => Calendar(
        id: json["id"] == null ? null : json["id"],
        userId: json["userId"] == null ? null : json["userId"],
        user: json["user"] == null ? null : User.fromJson(json["user"]),
        sharedWith:
            json["sharedWith"] == null ? null : List<String>.from(json["sharedWith"].map((x) => x)),
        name: json["name"] == null ? null : json["name"],
        private: json["private"] == null ? null : json["private"],
        enableEvents: json["enableEvents"] == null ? null : json["enableEvents"],
        enableTasks: json["enableTasks"] == null ? null : json["enableTasks"],
        enableReminders: json["enableReminders"] == null ? null : json["enableReminders"],
        enableRecommendedEvents:
            json["enableRecommendedEvents"] == null ? null : json["enableRecommendedEvents"],
        enableRecommendedTasks:
            json["enableRecommendedTasks"] == null ? null : json["enableRecommendedTasks"],
        enabled: json["enabled"] == null ? null : json["enabled"],
        shareableLink: json["shareableLink"] == null ? null : json["shareableLink"],
        events: json["events"] == null
            ? null
            : List<Event>.from(json["events"].map((x) => Event.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "userId": userId == null ? null : userId,
        "user": user == null ? null : user.toJson(),
        "sharedWith": sharedWith == null ? null : List<dynamic>.from(sharedWith.map((x) => x)),
        "name": name == null ? null : name,
        "private": private == null ? null : private,
        "enableEvents": enableEvents == null ? null : enableEvents,
        "enableTasks": enableTasks == null ? null : enableTasks,
        "enableReminders": enableReminders == null ? null : enableReminders,
        "enableRecommendedEvents": enableRecommendedEvents == null ? null : enableRecommendedEvents,
        "enableRecommendedTasks": enableRecommendedTasks == null ? null : enableRecommendedTasks,
        "enabled": enabled == null ? null : enabled,
        "shareableLink": shareableLink == null ? null : shareableLink,
        "events": events == null ? null : List<dynamic>.from(events.map((x) => x.toJson())),
      };
}
