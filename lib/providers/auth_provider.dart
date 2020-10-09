import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tempo_official/models/user.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';

class AuthProvider extends ChangeNotifier {
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  Firestore firestore = Firestore.instance;
  ImagePicker imagePicker = ImagePicker();
  FirebaseStorage storage = FirebaseStorage();
  User _user;
  User get user => _user;
  set user(User value) {
    _user = value;
    notifyListeners();
  }

  ///
  ///
  ///
  Stream<FirebaseUser> authChange() {
    return firebaseAuth.onAuthStateChanged.asBroadcastStream();
  }

  ///
  ///
  ///
  Future<User> getUserData(String email, bool refresh) async {
    if (email != null) {
      DocumentSnapshot userDoc = await this.firestore.collection('users').document(email).get();
      if (userDoc != null) {
        User _userData = User.fromJson(userDoc.data);
        if (refresh) {
          user = _userData;
        }
        return _userData;
      }
      return null;
    }
    return null;
  }

  ///
  ///
  Future<FirebaseUser> createAccount(
      {@required String email, @required String password, @required String userName}) async {
    try {
      AuthResult result =
          await this.firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);

      if (result.user != null) {
        DocumentReference _userDocument = firestore.collection('users').document(email);
        User user = User.fromJson({
          'email': email,
          'userName': userName,
          'id': _userDocument.documentID,
          'avatar': null,
          'queryTerms': returnQueryTerms(User(email: email, fullName: userName))
        });
        await _userDocument.setData(user.toJson(), merge: true);
        getUserData(email, true);
        notifyListeners();
        return result.user;
      }
    } on PlatformException catch (e) {
      debugPrint('');
      BotToast.showText(text: e.message);
      rethrow;
    }
  }

  ///
  ///
  ///
  Future<FirebaseUser> login({@required email, @required password}) async {
    try {
      AuthResult result =
          await this.firebaseAuth.signInWithEmailAndPassword(email: email, password: password);

      if (result.user != null) {
        return result.user;
      }
    } catch (e) {
      debugPrint('');
      throw e;
    }
  }

  ///
  ///
  Future<void> logout(BuildContext context) async {
    await firebaseAuth.signOut();
    Phoenix.rebirth(context);
    user = null;
    notifyListeners();
    return user;
  }

  Future pickUserAvatar() async {
    PickedFile avatar = await imagePicker.getImage(source: ImageSource.gallery);
    String avatarUrl =
        await uploadFile(File(avatar.path), storage.ref().child('avatars').child(this.user.email));
    FirebaseUser user = await this.firebaseAuth.currentUser();
    await user.updateProfile(UserUpdateInfo()..photoUrl = avatarUrl);
    this.user = this.user.copyWith(avatar: avatarUrl);
    await updateUserData(this.user);
    return;
  }

  Future<String> uploadFile(File file, StorageReference saveTo) async {
    StorageUploadTask task = saveTo.putFile(file);
    StorageReference reference = (await task.onComplete).ref;
    return await reference.getDownloadURL();
  }

  Future<void> updateUserData(User user) async {
    print('VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV ${user.email}');
    return await firestore.collection('users').document(user.email).updateData(user.toJson());
  }

  Stream<List<DocumentSnapshot>> getUsers({String userQuery}) {
    if (userQuery != null) {
      return firestore
          .collection('users')
          .where('queryResults', arrayContains: userQuery)
          .snapshots()
          .asBroadcastStream()
          .map((event) => event.documents);
    }
    return firestore.collection('users').snapshots().asBroadcastStream().map((event) => event.documents);
  }

  List<String> returnQueryTerms(User user) {
    List<String> list = [];
    user.fullName.split('').reduce((prev, next) {
      list.add((prev ?? '') + (prev ?? '' + next ?? ''));
      return next;
    });
    user.email.split('').reduce((prev, next) {
      list.add((prev ?? '') + (prev ?? '' + next ?? ''));
      return next;
    });
    return list;
  }
}
