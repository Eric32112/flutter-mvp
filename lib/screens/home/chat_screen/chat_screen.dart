import 'dart:io';
import 'package:bot_toast/bot_toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_emoji_keyboard/flutter_emoji_keyboard.dart';
import 'package:group_radio_button/group_radio_button.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:tempo_official/R.Strings.dart';
import 'package:tempo_official/consts/assets.dart';
import 'package:tempo_official/consts/theme.dart';
import 'package:tempo_official/models/chat.dart';
import 'package:tempo_official/models/message.dart';
import 'package:tempo_official/models/mute.dart';
import 'package:tempo_official/models/user.dart';
import 'package:tempo_official/providers/auth_provider.dart';
import 'package:tempo_official/providers/social_provider.dart';
import 'package:tempo_official/screens/home/chat_media_screen/chat_media_screen.dart';
import 'package:tempo_official/screens/home/create_chat_screen/create_chat_screen.dart';
import 'package:tempo_official/screens/home/edit_billboard_screen/edit_billboard_screen.dart';
import 'package:tempo_official/screens/home/group_chat_users/group_chat_users.dart';
import 'package:tempo_official/services/locator_service.dart';
import 'package:tempo_official/services/file_picker.dart';
import 'package:tempo_official/screens/home/create_poll_screen/create_poll_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tempo_official/widgets/message_widget.dart';

class ChatScreen extends StatelessWidget {
  final Chat chat;
  const ChatScreen({Key key, final this.chat}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<SocialProvider>(builder: (context, provider, child) {
      return ListenableProvider<_ChatScreenProvider>(
          create: (context) => _ChatScreenProvider(),
          child: Consumer<_ChatScreenProvider>(
            builder: (context, state, child) {
              int indexOfOtherUser = chat.users.indexWhere((element) =>
                  element.email != Provider.of<AuthProvider>(context, listen: false).user.email);

              return WillPopScope(
                onWillPop: () {
                  if (state.showAttachmentContainer) {
                    state.showAttachmentContainer = false;
                    return Future.delayed(
                        Duration(
                          milliseconds: 20,
                        ),
                        () => false);
                  } else if (state.showEmojiPicker) {
                    state.showEmojiPicker = false;
                    return Future.delayed(
                        Duration(
                          milliseconds: 20,
                        ),
                        () => false);
                  } else {
                    return Future.delayed(
                        Duration(
                          milliseconds: 20,
                        ),
                        () => true);
                  }
                },
                child: Scaffold(
                  // TODO:: change background
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
                    title: state.isSearch
                        ? _buildSearchInput(context, state)
                        : Row(
                            children: [
                              CircleAvatar(
                                backgroundImage: chat.imageUrl != null && chat.imageUrl.isNotEmpty
                                    ? CachedNetworkImageProvider(chat.imageUrl)
                                    : TempoAssets.defaultAvatar,
                              ),
                              SizedBox(
                                width: 8.0,
                              ),
                              Text(
                                chat.name == 'private conversation' && indexOfOtherUser != -1
                                    ? chat.users[indexOfOtherUser].fullName
                                    : chat.name,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontWeight: FontWeight.w500),
                              )
                            ],
                          ),
                    actions: state.isSearch
                        ? []
                        : [
                            IconButton(
                              icon: Icon(Icons.group),
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => CreateChatScreen(chat: chat, isEdit: true),
                                ));
                              },
                            ),
                            _buildOptionsMenu(context, state),
                          ],
                  ),

                  body: Container(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      children: [
                        ValueListenableBuilder<TextEditingValue>(
                            valueListenable: state.searchController,
                            builder: (context, searchValue, child) {
                              return Expanded(
                                  child: StreamBuilder<List<Message>>(
                                stream: provider.getChatMessages(chat.id, searchValue: searchValue.text),
                                builder: (context, asyncSnapshot) {
                                  if (asyncSnapshot.hasData && asyncSnapshot.data != null) {
                                    List<Message> messages = asyncSnapshot.data
                                        .where((element) => element.type != 'flyer')
                                        .toList();
                                    List<Message> flyers = asyncSnapshot.data
                                        .where((element) => element.type == 'flyer')
                                        .toList();
                                    return Container(
                                        child: Column(children: [
                                      flyers.isNotEmpty
                                          ? Container(
                                              height: 180.0,
                                              width: MediaQuery.of(context).size.width,
                                              child: ListView(
                                                scrollDirection: Axis.horizontal,
                                                children: flyers
                                                    .map<Widget>((e) => FlyerCardWidget(
                                                          message: e,
                                                        ))
                                                    .toList(),
                                              ),
                                            )
                                          : SizedBox.shrink(),
                                      Expanded(
                                        child: ListView.builder(
                                            scrollDirection: Axis.vertical,
                                            controller: state.scrollController,
                                            itemCount: messages.length,
                                            reverse: true,
                                            itemBuilder: (context, index) {
                                              return MessageWidget(
                                                chatId: chat.id,
                                                user: chat.users.firstWhere(
                                                    (element) => element.id == messages[index].sentBy),
                                                message: messages[index],
                                              );
                                            }),
                                      )
                                    ]));
                                  } else {
                                    return Center(
                                        child: Container(
                                      height: 50.0,
                                      width: 50.0,
                                      child: CircularProgressIndicator(),
                                    ));
                                  }
                                },
                              ));
                            }),
                        AnimatedContainer(
                          height: state.showAttachmentContainer ? 130.0 : 0.0,
                          width: state.showAttachmentContainer ? MediaQuery.of(context).size.width : 0.0,
                          decoration: BoxDecoration(
                              borderRadius: state.showAttachmentContainer
                                  ? BorderRadius.circular(0.0)
                                  : BorderRadius.circular(130.0)),
                          duration: Duration(milliseconds: 500),
                          child: state.showAttachmentContainer
                              ? _buildAttachmentPicker(context, state)
                              : SizedBox.shrink(),
                        ),
                        state.isSearch ? SizedBox.shrink() : _buildBottomInput(context, state, provider),
                        AnimatedContainer(
                            height: state.showEmojiPicker ? 300.0 : 0.0,
                            width: state.showEmojiPicker ? MediaQuery.of(context).size.width : 0.0,
                            decoration: BoxDecoration(
                                borderRadius: state.showEmojiPicker
                                    ? BorderRadius.circular(0.0)
                                    : BorderRadius.circular(300.0)),
                            duration: Duration(milliseconds: 500),
                            child: state.showEmojiPicker
                                ? _buildEmojiPicker(context, state)
                                : SizedBox.shrink()),
                      ],
                    ),
                  ),
                ),
              );
            },
          ));
    });
  }

  PopupMenuButton<String> _buildOptionsMenu(BuildContext context, _ChatScreenProvider state) {
    return PopupMenuButton(
      onSelected: (value) {
        print(value);
        switch (value.toString().toLowerCase()) {
          case 'edit group':
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => CreateChatScreen(chat: chat, isEdit: true)));
            break;
          case 'edit billboard':
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => EditBillboardScreen(chat: chat)));
            break;
          case 'mute':
            showMuteAlert(context).then((Mute value) {
              // print('DDDDDDDDDDDDDDDDDD ${value.toJson()}');
              if (value != null) {
                //
              } else {}
            });
            break;
          case 'search':
            state.isSearch = true;
            break;
          case 'media':
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => ChatMediaScreen(chat: chat)));
            break;
          case 'exit group':
            showDialog(
                context: context,
                builder: (context) {
                  return Container(
                      margin: EdgeInsets.symmetric(vertical: 200.0, horizontal: 16.0),
                      child: Material(
                          color: Colors.transparent,
                          child: AlertDialog(
                            title: Text(TempoStrings.labelExitGrp, style: TextStyle(fontSize: 18.0)),
                            actions: [
                              FlatButton(
                                child: Text("Yes"),
                                onPressed: () async {
                                  AuthProvider auth = Provider.of<AuthProvider>(context, listen: false);
                                  List<String> ids = chat.usersIds;
                                  List<User> users = chat.users;
                                  ids.removeWhere((e) => e == auth.user.id);
                                  users.removeWhere((e) => e.id == auth.user.id);
                                  auth.firestore
                                      .collection('chats')
                                      .document(chat.id)
                                      .updateData(chat.copyWith(usersIds: ids, users: users).toJson())
                                      .then((value) {
                                    Navigator.of(context).popUntil((route) => route.isFirst);
                                  });
                                },
                              ),
                              FlatButton(
                                child: Text("Now"),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  return null;
                                },
                              )
                            ],
                          )));
                });
            break;

          default:
        }
      },
      itemBuilder: (context) {
        List<String> items = [
          // TODO add edit group profile
          TempoStrings.labelEditGrp,
          TempoStrings.labelEditBillboard,
          TempoStrings.labelMute,
          TempoStrings.hintTextSearch,
          TempoStrings.labelMedia,
          TempoStrings.labelExitGrp
        ];
// TODO:: remove that comment
        // if (!chat.adminsIds.contains(Provider.of<AuthProvider>(context, listen: false).user.email)) {
        //   items.removeRange(0, 2);
        // }
        return items.map((e) => PopupMenuItem(child: Text(e), value: e)).toList();
      },
    );
  }

  Future<Mute> showMuteAlert(BuildContext context) async {
    // set up the AlertDialog

    // show the dialog
    return await showDialog<Mute>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        var auth = Provider.of<AuthProvider>(context, listen: false);
        return Provider<Mute>(
          create: (context) => Mute(chatId: chat.id, userId: auth.user.id),
          child: Consumer<Mute>(builder: (context, state, snapshot) {
            List<String> muteValues = [
              '1_hour',
              '8_hours',
              '1_day',
              '1_week',
              '1_year',
              'till_i_turn_it_back'
            ];

            return Container(
                margin: EdgeInsets.symmetric(vertical: 200.0, horizontal: 16.0),
                child: Material(
                    color: Colors.transparent,
                    child: AlertDialog(
                      title: Text("Mute notification for"),
                      content: RadioGroup.builder(
                          groupValue: state.mutedFor,
                          onChanged: (String val) {
                            print(val);
                            DateTime muteOn;
                            if (val == muteValues[0]) {
                              muteOn = DateTime.now().add(Duration(hours: 1));
                            } else if (val == muteValues[1]) {
                              muteOn = DateTime.now().add(Duration(hours: 8));
                            } else if (val == muteValues[2]) {
                              muteOn = DateTime.now().add(Duration(days: 1));
                            } else if (val == muteValues[3]) {
                              muteOn = DateTime.now().add(Duration(days: 7));
                            } else if (val == muteValues[4]) {
                              muteOn = DateTime.now().add(Duration(days: 365));
                            }
                            state = state.copyWith(
                                mutedFor: val,
                                mutedOn: DateTime.now().millisecondsSinceEpoch.toString(),
                                unMuteOn: muteOn?.millisecondsSinceEpoch?.toString() ?? null);
                          },
                          items: muteValues,
                          itemBuilder: (item) => RadioButtonBuilder(
                                item.toString().replaceAll('_', ' '),
                              )),
                      actions: [
                        FlatButton(
                          child: Text("OK"),
                          onPressed: () async {
                            List<String> mutedIds = chat.mutedUsersIds ?? [];
                            mutedIds.add(auth.user.email);
                            mutedIds.toSet().toList();
                            List<Mute> mutes = chat.mutes ?? [];
                            int indexOfMute =
                                mutes.indexWhere((element) => element.userId == auth.user.id);
                            if (indexOfMute == -1) {
                              mutes.add(state);
                            } else {
                              mutes.removeAt(indexOfMute);
                              mutes.add(state);
                            }
                            await auth.firestore.collection('chats').document(chat.id).updateData(chat
                                .copyWith(
                                  mutedUsersIds: mutedIds,
                                )
                                .toJson());
                            BotToast.showText(
                                text: 'Muted notification for ${state.mutedFor.replaceAll('_', ' ')}');
                            Navigator.of(context).pop();
                            return state;
                          },
                        ),
                        FlatButton(
                          child: Text("Cancel"),
                          onPressed: () {
                            Navigator.of(context).pop();
                            return null;
                          },
                        )
                      ],
                    )));
          }),
        );
      },
    );
  }

  _buildBottomInput(BuildContext context, _ChatScreenProvider state, SocialProvider socialProvider) {
    return ValueListenableBuilder(
      valueListenable: state.msgController,
      builder: (BuildContext context, dynamic value, Widget child) {
        return Stack(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: 50.0,
              margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(20.0), color: Colors.white),
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 32.0),
                child: TextFormField(
                  controller: state.msgController,
                  focusNode: state.msgNode,
                  onChanged: (value) {
                    state.msg = state.msg.copyWith(msgText: value);
                  },
                  decoration: InputDecoration(border: InputBorder.none),
                ),
              ),
            ),
            Positioned(
                left: 8,
                top: 8,
                child: IconButton(
                    onPressed: () {
                      FocusScope.of(context).requestFocus(FocusNode());
                      state.showEmojiPicker = !state.showEmojiPicker;
                    },
                    icon: ImageIcon(
                      TempoAssets.happyFaceIcon,
                      color: TempoTheme.retroOrange,
                    ))),
            Positioned(
                right: 8,
                top: 8,
                child: IconButton(
                    onPressed: () {
                      if (value.text.isNotEmpty) {
                        _sendMessage(state, chat, socialProvider, context);
                      } else {
                        FocusScope.of(context).requestFocus(FocusNode());
                        state.showAttachmentContainer = !state.showAttachmentContainer;
                      }
                    },
                    icon: ImageIcon(
                      value.text.isNotEmpty ? TempoAssets.sendIcon : TempoAssets.chatAttachmentIcon,
                    ))),
          ],
        );
      },
    );
  }

  _buildEmojiPicker(BuildContext context, _ChatScreenProvider state) {
    return Container(
      height: 300,
      width: MediaQuery.of(context).size.width,
      child: EmojiKeyboard(
        onEmojiSelected: (emoji) {
          state.msgController.text = state.msgController.text + emoji.text;
        },
      ),
    );
  }

  _buildAttachmentPicker(BuildContext context, _ChatScreenProvider state) {
    return Container(
        height: 130,
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.symmetric(horizontal: 8.0),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12.0), color: Colors.white),
        child: Column(children: [
          ListTile(
            leading: Icon(Icons.perm_media),
            title: Text(TempoStrings.labelMedia),
            onTap: () {
              locator<FilePickerService>().pickImage(source: ImageSource.gallery).then((value) {
                state.messageFiles = [value];
                showCupertinoModalPopup(
                    context: context,
                    builder: (context) {
                      return buildImageEditLayer(context, value, state);
                    });
              });
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Divider(),
          ),
          ListTile(
            leading: Icon(Icons.poll),
            title: Text(TempoStrings.labelCreatePoll),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => CreatePollScreen(
                        chatId: chat.id,
                      )));
            },
          )
        ]));
  }

  Widget buildImageEditLayer(BuildContext context, File value, _ChatScreenProvider state) {
    return Material(
      child: Builder(
          builder: (context) => SingleChildScrollView(
                child: SingleChildScrollView(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.8),
                        image: DecorationImage(image: FileImage(value), fit: BoxFit.contain)),
                    child: Column(
                      children: [
                        Container(
                          height: 60.0,
                          width: MediaQuery.of(context).size.width,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                  icon: Icon(
                                    Icons.arrow_back,
                                    color: Colors.white,
                                  ),
                                  onPressed: () => Navigator.of(context).pop()),
                              Container(
                                width: MediaQuery.of(context).size.width * .4,
                                child: Row(children: [
                                  IconButton(
                                      icon: ImageIcon(
                                        TempoAssets.addStickersIcon,
                                        color: Colors.white,
                                      ),
                                      onPressed: () => Navigator.of(context).pop()),
                                  IconButton(
                                      icon: ImageIcon(
                                        TempoAssets.cropRotateIcon,
                                        color: Colors.white,
                                      ),
                                      onPressed: () => Navigator.of(context).pop()),
                                  IconButton(
                                      icon: ImageIcon(
                                        TempoAssets.doddleIcon,
                                        color: Colors.white,
                                      ),
                                      onPressed: () => Navigator.of(context).pop())
                                ]),
                              )
                            ],
                          ),
                        ),
                        Expanded(
                          child: SizedBox.shrink(),
                        ),
                        ValueListenableBuilder(
                          valueListenable: state.msgController,
                          builder: (BuildContext context, dynamic value, Widget child) {
                            return Stack(
                              children: [
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: 50.0,
                                  margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20.0),
                                      color: Colors.black.withOpacity(0.5)),
                                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 32.0),
                                    child: TextFormField(
                                      style: TextStyle(color: Colors.white),
                                      controller: state.msgController,
                                      focusNode: state.msgNode,
                                      decoration: InputDecoration(
                                          border: InputBorder.none,
                                          hintText: TempoStrings.labelAddCaption,
                                          hintStyle: TextStyle(color: Color(0xffD3D7C6))),
                                    ),
                                  ),
                                ),
                                Positioned(
                                    left: 8,
                                    top: 8,
                                    child: IconButton(
                                        onPressed: () {
                                          FocusScope.of(context).requestFocus(FocusNode());
                                          state.showEmojiPicker = !state.showEmojiPicker;
                                        },
                                        icon: ImageIcon(
                                          TempoAssets.addImagesIcon,
                                          color: Colors.white,
                                        ))),
                                Positioned(
                                    right: 8,
                                    top: 8,
                                    child: IconButton(
                                        onPressed: () {
                                          if (value.text.isNotEmpty) {
                                            _sendMessage(
                                                    state,
                                                    chat,
                                                    Provider.of<SocialProvider>(context, listen: false),
                                                    context)
                                                .then((value) {
                                              Navigator.of(context).pop();
                                            });
                                          } else {
                                            FocusScope.of(context).requestFocus(FocusNode());
                                            state.showAttachmentContainer =
                                                !state.showAttachmentContainer;
                                          }
                                        },
                                        icon: ImageIcon(
                                          TempoAssets.sendIcon,
                                          color: Colors.white,
                                        ))),
                              ],
                            );
                          },
                        )
                      ],
                    ),
                  ),
                ),
              )),
    );
  }

  Future<void> _sendMessage(
      _ChatScreenProvider state, Chat chat, SocialProvider socialProvider, BuildContext context) async {
    AuthProvider authProvider = Provider.of<AuthProvider>(context, listen: false);
    DocumentReference chatDoc = authProvider.firestore.collection('chats').document(chat.id);
    DocumentReference messageDoc = chatDoc.collection('messages').document();
    Message _message = state.msg.copyWith(
        msgText: state.msgController.text,
        id: messageDoc.documentID,
        sentAt: DateTime.now().millisecondsSinceEpoch.toString(),
        sentBy: authProvider.user.id);
    state.msg = Message();
    state.msgController.clear();
    state.scrollController
        .animateTo(0.0, duration: Duration(milliseconds: 200), curve: Curves.bounceInOut);
    if (state.messageFiles.isNotEmpty) {
      _message = _message.copyWith(
          type: state.messageFiles.length > 1 ? 'images_${state.messageFiles.length}' : 'image',
          attachmentType: 'images',
          attachmentsUrl: []);
    } else {
      _message = _message.copyWith(type: 'text');
    }
    await messageDoc.setData(_message.toJson(), merge: true);
    await chatDoc.updateData(chat.copyWith(lastMessage: _message).toJson());
    if (state.messageFiles.isNotEmpty) {
      state.messageFiles.forEach((element) async {
        int index = state.messageFiles.indexOf(element);
        String url = await authProvider.uploadFile(
            element,
            authProvider.storage
                .ref()
                .child('chats')
                .child(chatDoc.documentID)
                .child(messageDoc.documentID)
                .child(index.toString()));
        await messageDoc.updateData({
          'attachmentsUrl': [..._message.attachmentsUrl, url]
        });
      });
    }
    return;
  }

  _buildSearchInput(BuildContext context, _ChatScreenProvider state) {
    return ValueListenableBuilder<TextEditingValue>(
        valueListenable: state.searchController,
        builder: (context, textValue, child) {
          return Container(
              width: MediaQuery.of(context).size.width - 35.0,
              height: 60.0,
              child: Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: TextFormField(
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500, height: 1.2),
                  controller: state.searchController,
                  focusNode: state.searchNode,
                  decoration: InputDecoration(
                      hintText: 'Search',
                      border: textValue.text.isEmpty ? null : InputBorder.none,
                      suffix: IconButton(
                        padding: EdgeInsets.all(0.0),
                        icon: Icon(state.isSearch ? Icons.close : Icons.search),
                        onPressed: () {
                          state.isSearch = !state.isSearch;
                        },
                      )),
                ),
              ));
        });
  }
}

class _ChatScreenProvider extends ChangeNotifier {
  TextEditingController msgController = TextEditingController();
  FocusNode msgNode = FocusNode();
  TextEditingController searchController = TextEditingController();
  FocusNode searchNode = FocusNode();
  ScrollController scrollController = ScrollController();
  Message _msg = Message();
  Message get msg => _msg;
  set msg(Message value) {
    _msg = value;
    notifyListeners();
  }

  List<File> _messageFiles = [];
  List<File> get messageFiles => _messageFiles;
  set messageFiles(value) {
    _messageFiles = value;
    notifyListeners();
  }

  bool _showAttachmentContainer = false;
  bool get showAttachmentContainer => _showAttachmentContainer;
  set showAttachmentContainer(bool value) {
    _showAttachmentContainer = value;
    notifyListeners();
  }

  bool _busy = false;
  bool get busy => _busy;
  set busy(bool value) {
    _busy = value;
    notifyListeners();
  }

  bool _search = false;
  bool get isSearch => _search;
  set isSearch(bool value) {
    _search = value;
    notifyListeners();
  }

  bool _showEmojiPicker = false;
  bool get showEmojiPicker => _showEmojiPicker;
  set showEmojiPicker(value) {
    _showEmojiPicker = value;
    notifyListeners();
  }
}
