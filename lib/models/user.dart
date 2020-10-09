// To parse this JSON data, do
//
//     final user = userFromJson(jsonString);

import 'dart:convert';

User userFromJson(String str) => User.fromJson(json.decode(str));

String userToJson(User data) => json.encode(data.toJson());

class User {
  User({
    this.fullName,
    this.email,
    this.status,
    this.id,
    this.phoneNumber,
    this.avatar,
    this.interests,
  });

  final String fullName;
  final String email;
  final String status;
  final String id;
  final String phoneNumber;
  final String avatar;
  final List<Interest> interests;

  User copyWith({
    String fullName,
    String email,
    String status,
    String id,
    String phoneNumber,
    String avatar,
    List<Interest> interests,
  }) =>
      User(
        fullName: fullName ?? this.fullName,
        email: email ?? this.email,
        status: status ?? this.status,
        id: id ?? this.id,
        phoneNumber: phoneNumber ?? this.phoneNumber,
        avatar: avatar ?? this.avatar,
        interests: interests ?? this.interests,
      );

  factory User.fromJson(Map<String, dynamic> json) => User(
        fullName: json["fullName"] == null ? null : json["fullName"],
        email: json["email"] == null ? null : json["email"],
        status: json["status"] == null ? null : json["status"],
        id: json["id"] == null ? null : json["id"],
        phoneNumber: json["phoneNumber"] == null ? null : json["phoneNumber"],
        avatar: json["avatar"] == null ? null : json["avatar"],
        interests: json["interests"] == null
            ? null
            : List<Interest>.from(json["interests"].map((x) => Interest.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "fullName": fullName == null ? null : fullName,
        "email": email == null ? null : email,
        "status": status == null ? null : status,
        "id": id == null ? null : id,
        "phoneNumber": phoneNumber == null ? null : phoneNumber,
        "avatar": avatar == null ? null : avatar,
        "interests": interests == null ? null : List<dynamic>.from(interests.map((x) => x.toJson())),
      };
}

class Interest {
  Interest({
    this.id,
    this.label,
  });

  final String id;
  final String label;

  Interest copyWith({
    String id,
    String label,
  }) =>
      Interest(
        id: id ?? this.id,
        label: label ?? this.label,
      );

  factory Interest.fromJson(Map<String, dynamic> json) => Interest(
        id: json["id"] == null ? null : json["id"],
        label: json["label"] == null ? null : json["label"],
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "label": label == null ? null : label,
      };
}
