import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tempo_official/R.Strings.dart';
import 'package:tempo_official/consts/assets.dart';
import 'package:tempo_official/consts/theme.dart';
import 'package:tempo_official/models/chat.dart';
import 'package:tempo_official/models/message.dart';
import 'package:tempo_official/models/user.dart';

import 'package:tempo_official/providers/auth_provider.dart';

import 'package:tempo_official/screens/home/add_users_screen/add_users_screen.dart';
import 'package:tempo_official/screens/home/chat_screen/chat_screen.dart';

class CreateChatScreen extends StatelessWidget {
  final Chat chat;
  final bool isEdit;
  const CreateChatScreen({Key key, this.chat, this.isEdit}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListenableProvider<_CreateChatScreenProvider>(
      create: (_) {
        var state = _CreateChatScreenProvider();
        if (chat != null) {
          state.chat = chat;
          state.chatNameController.text = chat.name;
        }
        return state;
      },
      child: Consumer<_CreateChatScreenProvider>(builder: (context, state, snapshot) {
        return Scaffold(
          // TODO:: Change background color
          backgroundColor: TempoTheme.backgroundColor,
          appBar: AppBar(
            backgroundColor: Colors.white,
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.of(context).pop();
              },
              color: Colors.black.withOpacity(.54),
            ),
            shape: ContinuousRectangleBorder(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30))),
            title: Text(
              isEdit ? TempoStrings.labelEditGrp : TempoStrings.labelNewGroup,
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            actions: [
              Row(children: [
                InkWell(
                  onTap: () {
                    // TODO::
                    // Provider.of<SocialProvider>(context, listen: false)
                    //     .createChat(state.chat)
                    //     .then((value) => {
                    //           Navigator.of(
                    //             context,
                    //           ).pushReplacement(
                    //               MaterialPageRoute(builder: (context) => ChatScreen(chat: value)))
                    //         });

                    _createChat(context, null, state);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                      color: TempoTheme.retroOrange,
                    ),
                    width: 80.0,
                    height: 40.0,
                    child: Center(
                      child: Text('Finish',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w500, fontSize: 18.0)),
                    ),
                  ),
                )
              ]),
              SizedBox(
                width: 16.0,
              ),
            ],
          ),
          body: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            margin: EdgeInsets.only(top: 32.0, left: 16, right: 16),
            child: Column(children: [
              _buildChatAvatar(context, state),
              SizedBox(
                height: 16.0,
              ),
              _buildNameInput(context, state),
              _buildUsersList(context, state),
            ]),
          ),
        );
      }),
    );
  }

  void _createChat(BuildContext context, List<User> users, _CreateChatScreenProvider state) {
    AuthProvider authProvider = Provider.of<AuthProvider>(context, listen: false);
    var doc = authProvider.firestore.collection('chats').document(isEdit ? this.chat.id : null);
    var msg = Message(
      type: 'action',
      msgText: isEdit && users == null
          ? '${authProvider.user.email} has edited the profile info'
          : '${authProvider.user.email} add you',
      sentBy: authProvider.user.email,
      sentAt: DateTime.now().millisecondsSinceEpoch.toString(),
    );
    if (isEdit && users == null) {
      doc.setData(chat.toJson(), merge: true).then((value) {});
    } else if (isEdit && users != null && users.length == 2) {
      doc = authProvider.firestore
          .collection('chats')
          .document('${authProvider.user.id}_${users.last.email}');
      Chat chat = state.chat.copyWith(
          id: doc.documentID,
          lastMessage: msg,
          users: users,
          adminsIds: users.map((e) => e.email).toList(),
          usersIds: users.map((e) => e.email).toList(),
          name: 'private conversation');
      doc.setData(chat.toJson(), merge: true).then((value) {
        doc.collection('messages').add(msg.toJson()).then((value) {
          Navigator.of(context).pop();
          Navigator.of(
            context,
          ).pushReplacement(MaterialPageRoute(builder: (context) => ChatScreen(chat: chat)));
        });
      });
    } else {
      Chat chat = state.chat.copyWith(
        id: doc.documentID,
        lastMessage: msg,
        adminsIds: [authProvider.user.email],
      );
      doc.setData(chat.toJson(), merge: true).then((value) {
        doc.collection('messages').add(msg.toJson()).then((value) {
          Navigator.of(
            context,
          ).pushReplacement(MaterialPageRoute(builder: (context) => ChatScreen(chat: chat)));
        });
      });
    }
  }

  Widget _buildChatAvatar(BuildContext context, _CreateChatScreenProvider state) {
    return Container(
      height: 160.0,
      width: MediaQuery.of(context).size.width,
      child: Center(
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(80.0),
              child: Container(
                height: 145.0,
                width: 160.0,
                decoration: BoxDecoration(color: Colors.white),
                child: Image(
                  fit: BoxFit.contain,
                  image: state.chat.imageUrl != null
                      ? CachedNetworkImageProvider(
                          state.chat.imageUrl,
                        )
                      : TempoAssets.colonyIcon,
                ),
              ),
            ),
            Positioned(
              bottom: 5.0,
              right: 5.0,
              child: InkWell(
                onTap: () async {
                  // TODO add chat avatar logic
                },
                child: Container(
                  width: 36.0,
                  height: 36.0,
                  padding: EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                      color: TempoTheme.retroOrange,
                      shape: BoxShape.circle,
                      border: Border.all(width: 2.0, color: Colors.white)),
                  child: Image(
                    image: TempoAssets.cameraIcon,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  _buildNameInput(BuildContext context, _CreateChatScreenProvider state) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8.0)),
      child: Row(children: [
        InkWell(
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Image(image: TempoAssets.penIcon),
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width - 120.0,
          child: TextFormField(
            controller: state.chatNameController,
            style: TextStyle(color: Colors.black, fontSize: 20.0, fontWeight: FontWeight.bold),
            onChanged: (value) {
              state.chat = state.chat.copyWith(name: value);
            },
            decoration: InputDecoration(
                border: InputBorder.none,
                hintText: TempoStrings.labelNewGroup,
                hintStyle: TextStyle(color: Colors.black, fontSize: 20.0, fontWeight: FontWeight.bold)),
          ),
        ),
      ]),
    );
  }

  _buildUsersList(BuildContext context, _CreateChatScreenProvider state) {
    AuthProvider auth = Provider.of<AuthProvider>(context, listen: false);
    return Container(
      height: MediaQuery.of(context).size.height * .5,
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.symmetric(vertical: 16.0),
      padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20.0), color: Colors.white),
      child: state.chat?.users != null
          ? ListView(
              children:
                  state.chat.users.map<Widget>((e) => _buildUserTile(context, auth, e, state)).toList())
          : Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: FlatButton(
                  color: TempoTheme.primaryBtnColor,
                  child: Text(TempoStrings.labelAddUsers,
                      style:
                          TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500, color: Colors.white)),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => AddUsersScreen(
                          users: chat.users ?? [],
                          onSelected: (users) {
                            state.chat = state.chat
                                .copyWith(users: users, usersIds: users.map((e) => e.id).toList());
                          },
                          title: TempoStrings.labelCreateGrp,
                          subTitle: TempoStrings.labelAddUsers),
                    ));
                  },
                ),
              ),
            ),
    );
  }

  InkWell _buildUserTile(
      BuildContext context, AuthProvider auth, User e, _CreateChatScreenProvider state) {
    return InkWell(
      onLongPress: () {
        if (isEdit) {}
        showDialog(
          context: context,
          builder: (context) {
            return Container(
                margin: EdgeInsets.symmetric(
                    vertical: isEdit && chat.adminsIds.contains(auth.user.email)
                        ? MediaQuery.of(context).size.height * 0.39
                        : MediaQuery.of(context).size.height * 0.45,
                    horizontal: 50.0),
                child: Container(
                  decoration: BoxDecoration(
                      color: TempoTheme.retroOrange,
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(20.0),
                          bottomRight: Radius.circular(20.0),
                          topRight: Radius.circular(20.0))),
                  child: Material(
                    color: Colors.transparent,
                    child: Column(children: [
                      e.email != auth.user.email
                          ? InkWell(
                              onTap: () {
                                _createChat(context, [auth.user, e], state);
                              },
                              child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
                                  child: Text('Message ${e.fullName ?? e.email}',
                                      style:
                                          TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                            )
                          : SizedBox.shrink(),
                      chat.adminsIds.contains(auth.user.email) && !chat.adminsIds.contains(e.email)
                          ? InkWell(
                              onTap: () {
                                state.chat.copyWith(adminsIds: [...state.chat.adminsIds, e.email]);
                                _createChat(context, null, state);
                                Navigator.of(context).pop();
                              },
                              child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
                                  child: Text('Make ${e.fullName ?? e.email} an Admin',
                                      style:
                                          TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                            )
                          : SizedBox.shrink(),
                      chat.adminsIds.contains(auth.user.email)
                          ? InkWell(
                              onTap: () {
                                List<User> users = state.chat.users;
                                state.chat.copyWith(
                                    users: users, usersIds: users.map((e) => e.email).toList());
                                _createChat(context, null, state);
                                Navigator.of(context).pop();
                              },
                              child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
                                  child: Text('Kick ${e.fullName ?? e.email}',
                                      style:
                                          TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                            )
                          : SizedBox.shrink(),
                    ]),
                  ),
                ));
          },
        );
      },
      child: Container(
          height: 50.0,
          margin: EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                  height: 50.0,
                  width: 50.0,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[200],
                      image: DecorationImage(
                          image: e.avatar != null
                              ? CachedNetworkImageProvider(e.avatar)
                              : TempoAssets.defaultAvatar))),
              SizedBox(
                width: 8.0,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    e.fullName ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    e.status ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w500, color: Colors.grey),
                  ),
                ],
              ),
              Expanded(
                child: SizedBox.shrink(),
              ),
              e.email != auth.user.email
                  ? IconButton(
                      icon: Icon(Icons.chat_bubble_outline, color: Colors.grey),
                      onPressed: () {
                        _createChat(context, [auth.user, e], state);
                      },
                    )
                  : SizedBox.shrink(),
              chat.adminsIds != null && chat.adminsIds.contains(e.email)
                  ? Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 2.0,
                        horizontal: 4.0,
                      ),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4.0), color: TempoTheme.retroOrange))
                  : SizedBox.shrink()
            ],
          )),
    );
  }
}

class _CreateChatScreenProvider extends ChangeNotifier {
  TextEditingController chatNameController = TextEditingController();
  File _chatImage;
  File get chatImage => _chatImage;
  set chatImage(File img) {
    _chatImage = img;
    notifyListeners();
  }

  Chat _chat = Chat();
  Chat get chat => _chat;
  set chat(Chat value) {
    _chat = value;
    notifyListeners();
  }
}
