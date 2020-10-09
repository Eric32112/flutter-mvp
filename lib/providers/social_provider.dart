import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:tempo_official/models/chat.dart';
import 'package:tempo_official/models/message.dart';

class SocialProvider extends ChangeNotifier {
  Firestore firestore = Firestore.instance;

  List<Chat> _chats;
  List<Chat> get chats => _chats;
  set chats(List<Chat> value) {
    _chats = value;
    Future.delayed(Duration(milliseconds: 50), () => notifyListeners());
  }

  ///
  ///
  ///
  ///
  Stream<List<Chat>> getChatRooms(String userId) {
    return firestore
        .collection('chats')
        .where('usersIds', arrayContains: userId)
        .snapshots()
        .map((event) => event.documents.map((e) => Chat.fromJson(e.data)).toList())
        .asBroadcastStream();
  }

  ///
  ///
  ///
  Future<Chat> createChat(Chat chat) async {
    DocumentReference reference = firestore.collection('chats').document();
    await reference.setData(chat.copyWith(id: reference.documentID).toJson(), merge: true);
    return chat.copyWith(id: reference.documentID);
  }

  Stream<List<Message>> getChatMessages(String id, {String searchValue}) {
    return searchValue != null && searchValue.isNotEmpty
        ? firestore
            .collection('chats')
            .document(id)
            .collection('messages')
            .where('msgText', isLessThanOrEqualTo: searchValue)
            .where('msgText', isEqualTo: searchValue)
            .orderBy('msgText', descending: true)
            .orderBy('sentAt', descending: true)
            .snapshots()
            .map((event) => event.documents.map((e) => Message.fromJson(e.data)).toList())
            .asBroadcastStream()
        : firestore
            .collection('chats')
            .document(id)
            .collection('messages')
            .orderBy('sentAt', descending: true)
            .snapshots()
            .map((event) => event.documents.map((e) => Message.fromJson(e.data)).toList())
            .asBroadcastStream();
  }

  Stream<List<Message>> getChatMedia(String id) {
    return firestore
        .collection('chats')
        .document(id)
        .collection('messages')
        .where('type', isEqualTo: 'image')
        .orderBy('sentAt', descending: true)
        .snapshots()
        .map((event) => event.documents.map((e) => Message.fromJson(e.data)).toList())
        .asBroadcastStream();
  }

  Stream<List<Message>> getChatFlyers(String id) {
    return firestore
        .collection('chats')
        .document(id)
        .collection('messages')
        .where('type', isEqualTo: 'flyer')
        .orderBy('sentAt', descending: true)
        .snapshots()
        .map((event) => event.documents.map((e) => Message.fromJson(e.data)).toList())
        .asBroadcastStream();
  }
}
