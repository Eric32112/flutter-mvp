import 'dart:convert';

import 'package:tempo_official/models/message.dart';
import 'package:tempo_official/models/mute.dart';
import 'package:tempo_official/models/user.dart';

Chat chatFromJson(String str) => Chat.fromJson(json.decode(str));

String chatToJson(Chat data) => json.encode(data.toJson());

class Chat {
  Chat(
      {this.id,
      this.users,
      this.name,
      this.imageUrl,
      this.membersCount,
      this.usersIds,
      this.messages,
      this.adminsIds,
      this.mutedUsersIds,
      this.mutes,
      this.lastMessage});

  final String id;
  final List<User> users;
  final String name;
  final String imageUrl;
  final int membersCount;
  final List<String> usersIds;
  final List<String> adminsIds;
  final List<Message> messages;
  final Message lastMessage;
  final List<String> mutedUsersIds;
  final List<Mute> mutes;

  Chat copyWith(
          {String id,
          List<User> users,
          String name,
          String imageUrl,
          List<String> adminsIds,
          int membersCount,
          List<String> usersIds,
          List<Message> messages,
          Message lastMessage,
          List<String> mutedUsersIds,
          List<Mute> mutes}) =>
      Chat(
          id: id ?? this.id,
          users: users ?? this.users,
          name: name ?? this.name,
          imageUrl: imageUrl ?? this.imageUrl,
          membersCount: membersCount ?? this.membersCount,
          usersIds: usersIds ?? this.usersIds,
          messages: messages ?? this.messages,
          lastMessage: lastMessage ?? this.lastMessage,
          adminsIds: adminsIds ?? this.adminsIds,
          mutedUsersIds: mutedUsersIds ?? this.mutedUsersIds,
          mutes: mutes ?? this.mutes);

  factory Chat.fromJson(Map<String, dynamic> json) => Chat(
        id: json["id"] == null ? null : json["id"],
        users: json["users"] == null ? [] : List<User>.from(json["users"].map((x) => User.fromJson(x))),
        name: json["name"] == null ? null : json["name"],
        imageUrl: json["imageUrl"] == null ? null : json["imageUrl"],
        membersCount: json["membersCount"] == null ? null : json["membersCount"],
        usersIds: json["usersIds"] == null ? [] : List<String>.from(json["usersIds"].map((x) => x)),
        adminsIds: json["adminsIds"] == null ? [] : List<String>.from(json["adminsIds"].map((x) => x)),
        messages: json["messages"] == null
            ? []
            : List<Message>.from(json["messages"].map((x) => Message.fromJson(x))),
        mutes: json["mutes"] == null ? [] : List<Mute>.from(json["mutes"].map((x) => Mute.fromJson(x))),
        mutedUsersIds:
            json["mutedUsersIds"] == null ? [] : List<String>.from(json["mutedUsersIds"].map((x) => x)),
        lastMessage: json['lastMessage'] == null ? null : Message.fromJson(json['lastMessage']),
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "users": users == null ? null : List<dynamic>.from(users.map((x) => x.toJson())),
        "name": name == null ? null : name,
        "imageUrl": imageUrl == null ? null : imageUrl,
        "membersCount": membersCount == null ? null : membersCount,
        "usersIds": usersIds == null ? [] : List<dynamic>.from(usersIds.map((x) => x)),
        "messages": messages == null ? [] : List<dynamic>.from(messages.map((x) => x.toJson())),
        "lastMessage": lastMessage == null ? null : lastMessage.toJson(),
        "adminsIds": adminsIds == null ? [] : List<dynamic>.from(adminsIds.map((x) => x)),
        "mutedUsersIds": mutedUsersIds == null ? [] : List<dynamic>.from(mutedUsersIds.map((e) => e)),
        "mutes": mutes == null ? [] : List<dynamic>.from(mutes.map((e) => e.toJson()))
      };
}
