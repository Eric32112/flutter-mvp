import 'package:bot_toast/bot_toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tempo_official/consts/assets.dart';
import 'package:tempo_official/consts/theme.dart';
import 'package:tempo_official/models/message.dart';
import 'package:tempo_official/models/pool.dart';
import 'package:tempo_official/models/user.dart';
import 'package:tempo_official/providers/auth_provider.dart';
import 'package:tempo_official/services/date_helper.dart';

class MessageWidget extends StatelessWidget {
  final Message message;
  final String chatId;
  final User user;
  const MessageWidget({Key key, @required this.message, @required this.chatId, @required this.user})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    AuthProvider authProvider = Provider.of<AuthProvider>(context, listen: false);
    bool isMine = message.sentBy == authProvider.user.id;
    List<Widget> messageItems = [
      Container(
        height: 50,
        width: 50,
        margin: EdgeInsets.symmetric(vertical: 16.0),
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
                fit: BoxFit.cover,
                image: isMine
                    ? authProvider.user.avatar != null
                        ? CachedNetworkImageProvider(authProvider.user.avatar)
                        : TempoAssets.defaultAvatar
                    : user?.avatar != null && user.avatar.isNotEmpty
                        ? CachedNetworkImageProvider(user.avatar)
                        : TempoAssets.defaultAvatar)),
      ),
      SizedBox(
        width: 12.0,
      ),
      Stack(
        children: [
          Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: _buildMsgContainer(context, authProvider, isMine)),
          message.likedBy != null && message.likedBy.contains(authProvider.user.email)
              ? Positioned(
                  left: isMine ? 10.0 : null,
                  right: isMine ? null : 10.0,
                  bottom: 0.0,
                  child: ImageIcon(
                    TempoAssets.heartIcon,
                    color: Color(0xffEB5757),
                    size: 18.0,
                  ))
              : SizedBox.shrink()
        ],
      )
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 0.0),
      child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: isMine ? messageItems.reversed.toList() : messageItems),
    );
  }

  Widget _buildMsgContainer(BuildContext context, AuthProvider authProvider, bool isMine) {
    return InkWell(
      onLongPress: () {
        _likeMessage(Provider.of<AuthProvider>(context, listen: false), chatId, message);
      },
      child: Container(
        padding: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
            color: TempoTheme.retroOrange,
            boxShadow: [
              BoxShadow(blurRadius: 4.0, offset: Offset(0.0, 4), color: Colors.black.withOpacity(0.25))
            ],
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
              topLeft: isMine ? Radius.circular(20.0) : Radius.circular(0.0),
              bottomRight: isMine ? Radius.circular(0.0) : Radius.circular(20.0),
            )),
        child: Column(
          crossAxisAlignment: isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  isMine ? user.fullName ?? '' : '',
                  style: TextStyle(color: Colors.white, fontSize: 9.0),
                )
              ],
            ),
            SizedBox(
              height: 8.0,
            ),
            message.type != 'text'
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(5.0),
                    child: Container(
                        width: 219,
                        height: message.type == 'image' ? 128.0 : null,
                        decoration: BoxDecoration(color: Colors.white),
                        child: Builder(
                          builder: (context) {
                            switch (message.type) {
                              case 'text':
                                return SizedBox.shrink();
                              case 'poll':
                                return Container(
                                  margin: EdgeInsets.symmetric(vertical: 8.0),
                                  child: Column(
                                    children: [
                                      Text(
                                        message.pool.question ?? '',
                                        style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.w600),
                                      ),
                                      Divider(
                                        color: Color(0xffCDC9C9),
                                      ),
                                      ...message.pool.answers
                                          .map((e) => _buildPollTile(
                                                context,
                                                Provider.of<AuthProvider>(context, listen: false),
                                                chatId,
                                                e,
                                                message,
                                              ))
                                          .toList()
                                    ],
                                  ),
                                );
                                break;
                              case 'image':
                                return message.attachmentsUrl.length == 1
                                    ? CachedNetworkImage(
                                        imageUrl: message.attachmentsUrl.first,
                                        fit: BoxFit.cover,
                                        errorWidget: (context, va, error) => Container(
                                          width: 219,
                                          height: 128,
                                          child: Center(
                                            child: Icon(Icons.error_outline),
                                          ),
                                        ),
                                        placeholder: (context, error) => Container(
                                          width: 219,
                                          height: 128,
                                          child: Center(
                                              child: Container(
                                                  height: 30.0,
                                                  width: 30.0,
                                                  child: CircularProgressIndicator())),
                                        ),
                                      )
                                    : Flex(
                                        direction: Axis.horizontal,
                                        children:
                                            message.attachmentsUrl.map((e) => Container()).toList(),
                                      );
                              default:
                                return Container(
                                  child: Text(message.type),
                                );
                            }
                          },
                        )),
                  )
                : SizedBox.shrink(),
            Text(
              message.msgText ?? '',
              style: TextStyle(color: Colors.white, fontSize: 12.0),
            ),
            SizedBox(
              height: 8.0,
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Text(
                    DateHelper.parseTime(DateTime.fromMillisecondsSinceEpoch(int.parse(message.sentAt))),
                    style: TextStyle(color: Color(0xffF2F2F2), fontSize: 9))
              ],
            )
          ],
        ),
      ),
    );
  }

  void _likeMessage(AuthProvider authProvider, String chatId, Message message) {
    if (message.likedBy != null && message.likedBy.contains(authProvider.user.email)) {
      message.likedBy.removeWhere((element) => element == authProvider.user.email);
    } else {
      message = message.copyWith(
          likedBy: message.likedBy != null
              ? [...message.likedBy, authProvider.user.email]
              : [authProvider.user.email]);
    }
    authProvider.firestore
        .collection('chats')
        .document(chatId)
        .collection('messages')
        .document(message.id)
        .updateData(message.toJson())
        .then((value) {
      BotToast.showText(
          text: 'You liked ${user.email == message.sentBy ? 'Your own' : user.fullName} message');
    });
  }

  _buildPollTile(
      BuildContext context, AuthProvider authProvider, String chatId, Answer e, Message message) {
    var shouldUpdate =
        DateTime.fromMillisecondsSinceEpoch(int.parse(message.pool.endsAt)).isAfter(DateTime.now());

    return Column(
      children: [
        ListTile(
          onTap: () {
            var alreadySelected = e.selectedBy.contains(authProvider.user.email);
            print('Should update $shouldUpdate');
            if (shouldUpdate) {
              Pool pool = message.pool.copyWith(answers: message.pool.answers);

              List<Answer> answers = pool.answers.map((element) {
                Answer _answer = element;
                if (element.id == e.id) {
                  if (!alreadySelected) {
                    return _answer
                        .copyWith(selectedBy: [..._answer.selectedBy, authProvider.user.email]);
                  }
                } else {
                  if (element.selectedBy.contains(authProvider.user.email)) {
                    int indexOfEmail = element.selectedBy.indexOf(authProvider.user.email);
                    _answer.selectedBy.removeAt(indexOfEmail);
                  }
                  return _answer;
                }
              }).toList();
              pool = pool.copyWith(answers: answers);

              authProvider.firestore
                  .collection('chats')
                  .document(chatId)
                  .collection('messages')
                  .document(message.id)
                  .updateData({'pool': pool.toJson()});
            }
          },
          leading: Container(
            width: 15.0,
            height: 15.0,
            decoration: BoxDecoration(
                shape: BoxShape.circle, border: Border.all(width: 2.0, color: TempoTheme.retroOrange)),
            child: e.selectedBy.contains(authProvider.user.email)
                ? Center(
                    child: Container(
                      height: 8.0,
                      width: 8.0,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: TempoTheme.retroOrange),
                    ),
                  )
                : SizedBox.shrink(),
          ),
          title: Text(e.value ?? '', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        ),
        shouldUpdate
            ? _buildProgressBar(e.selectedBy.length / message.pool.vattedUsers.length)
            : SizedBox.shrink(),
        Divider(),
      ],
    );
  }

  _buildProgressBar(double percent) {
    return Stack(
      children: [
        Container(
            height: 4.0,
            width: 164.0,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2.0),
                color: TempoTheme.retroOrange.withOpacity(0.5))),
        Positioned(
            left: 0,
            right: 164 * percent,
            top: 0,
            bottom: 0,
            child: Container(
              width: 164 * percent,
              height: 4.0,
              decoration:
                  BoxDecoration(color: TempoTheme.retroOrange, borderRadius: BorderRadius.circular(2.0)),
            ))
      ],
    );
  }
}
