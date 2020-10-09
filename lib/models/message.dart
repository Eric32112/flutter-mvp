import 'package:tempo_official/models/flyer.dart';
import 'package:tempo_official/models/pool.dart';

class Message {
  Message(
      {this.id,
      this.seenBy,
      this.likedBy,
      this.type,
      this.msgText,
      this.attachmentsUrl,
      this.attachmentType,
      this.sentBy,
      this.isPinned,
      this.flyer,
      this.pool,
      this.sentAt});

  final String id;
  final List<String> seenBy;
  final List<String> likedBy;
  final String type;
  final String msgText;
  final List<String> attachmentsUrl;
  final String attachmentType;
  final String sentBy;
  final bool isPinned;
  final Flyer flyer;
  final Pool pool;
  final String sentAt;

  Message copyWith(
          {String id,
          List<String> seenBy,
          List<String> likedBy,
          String type,
          String msgText,
          List<String> attachmentsUrl,
          String attachmentType,
          String sentBy,
          bool isPinned,
          Flyer flyer,
          Pool pool,
          String sentAt}) =>
      Message(
          id: id ?? this.id,
          seenBy: seenBy ?? this.seenBy,
          likedBy: likedBy ?? this.likedBy,
          type: type ?? this.type,
          msgText: msgText ?? this.msgText,
          attachmentsUrl: attachmentsUrl ?? this.attachmentsUrl,
          attachmentType: attachmentType ?? this.attachmentType,
          sentBy: sentBy ?? this.sentBy,
          isPinned: isPinned ?? this.isPinned,
          flyer: flyer ?? this.flyer,
          pool: pool ?? this.pool,
          sentAt: sentAt ?? this.sentAt);

  factory Message.fromJson(Map<String, dynamic> json) => Message(
      id: json["id"] == null ? null : json["id"],
      seenBy: json["seenBy"] == null ? null : List<String>.from(json["seenBy"].map((x) => x)),
      likedBy: json["likedBy"] == null ? null : List<String>.from(json["likedBy"].map((x) => x)),
      type: json["type"] == null ? null : json["type"],
      msgText: json["msgText"] == null ? null : json["msgText"],
      attachmentsUrl: json["attachmentsUrl"] == null
          ? null
          : List<String>.from(json["attachmentsUrl"].map((x) => x)),
      attachmentType: json["attachmentType"] == null ? null : json["attachmentType"],
      sentBy: json["sentBy"] == null ? null : json["sentBy"],
      isPinned: json["isPinned"] == null ? false : json["isPinned"],
      flyer: json["flyer"] == null ? null : Flyer.fromJson(json["flyer"]),
      pool: json["pool"] == null ? null : Pool.fromJson(json["pool"]),
      sentAt: json['sentAt'] == null ? null : json['sentAt']);

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "seenBy": seenBy == null ? null : List<dynamic>.from(seenBy.map((x) => x)),
        "likedBy": likedBy == null ? null : List<dynamic>.from(likedBy.map((x) => x)),
        "type": type == null ? null : type,
        "msgText": msgText == null ? null : msgText,
        "attachmentsUrl": attachmentsUrl == null ? null : attachmentsUrl,
        "attachmentType": attachmentType == null ? null : attachmentType,
        "sentBy": sentBy == null ? null : sentBy,
        "isPinned": isPinned == null ? false : isPinned,
        "flyer": flyer == null ? null : flyer.toJson(),
        "pool": pool == null ? null : pool.toJson(),
        "sentAt": sentAt == null ? null : sentAt
      };

  //  String displayMsg(bool isOwner, String ownerEmail) {
  //    switch ('info') {
  //      case info:

  //        break;
  //      default:
  //    }
  //    return isOwner ? msgText.replaceAll(ownerEmail,'You')
  //  }
}

enum MessageType { info, text, image, file, pool, flyer }
