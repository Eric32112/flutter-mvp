// To parse this JSON data, do
//
//     final mute = muteFromJson(jsonString);

import 'dart:convert';

Mute muteFromJson(String str) => Mute.fromJson(json.decode(str));

String muteToJson(Mute data) => json.encode(data.toJson());

class Mute {
  Mute({
    this.userId,
    this.mutedFor,
    this.unMuteOn,
    this.mutedOn,
    this.chatId,
  });

  final String userId;
  final String mutedFor;
  final String unMuteOn;
  final String mutedOn;
  final String chatId;

  Mute copyWith({
    String userId,
    String mutedFor,
    String unMuteOn,
    String mutedOn,
    String chatId,
  }) =>
      Mute(
        userId: userId ?? this.userId,
        mutedFor: mutedFor ?? this.mutedFor,
        unMuteOn: unMuteOn ?? this.unMuteOn,
        mutedOn: mutedOn ?? this.mutedOn,
        chatId: chatId ?? this.chatId,
      );

  factory Mute.fromJson(Map<String, dynamic> json) => Mute(
        userId: json["userId"] == null ? null : json["userId"],
        mutedFor: json["mutedFor"] == null ? null : json["mutedFor"],
        unMuteOn: json["unMuteOn"] == null ? null : json["unMuteOn"],
        mutedOn: json["mutedOn"] == null ? null : json["mutedOn"],
        chatId: json["chatId"] == null ? null : json["chatId"],
      );

  Map<String, dynamic> toJson() => {
        "userId": userId == null ? null : userId,
        "mutedFor": mutedFor == null ? null : mutedFor,
        "unMuteOn": unMuteOn == null ? null : unMuteOn,
        "mutedOn": mutedOn == null ? null : mutedOn,
        "chatId": chatId == null ? null : chatId,
      };
}
