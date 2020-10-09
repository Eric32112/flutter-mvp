import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tempo_official/R.Strings.dart';
import 'package:tempo_official/consts/assets.dart';
import 'package:tempo_official/consts/theme.dart';
import 'package:tempo_official/models/chat.dart';
import 'package:tempo_official/models/user.dart';
import 'package:tempo_official/providers/auth_provider.dart';
import 'package:tempo_official/providers/social_provider.dart';
import 'package:tempo_official/screens/home/chat_screen/chat_screen.dart';

class SocialTab extends StatelessWidget {
  const SocialTab({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SocialProvider provider = Provider.of<SocialProvider>(context);
    AuthProvider auth = Provider.of<AuthProvider>(context, listen: false);
    return ListenableProvider<_SocialTabProvider>(
      create: (_) => _SocialTabProvider(),
      child: Consumer<_SocialTabProvider>(
        builder: (context, state, child) {
          if (provider.chats != null) {
            provider.chats.sort((a, b) {
              var aLastMsgAt = DateTime.fromMillisecondsSinceEpoch(int.parse(a.lastMessage?.sentAt));
              var bLastMsgAt = DateTime.fromMillisecondsSinceEpoch(int.parse(b.lastMessage?.sentAt));
              return aLastMsgAt.isAfter(bLastMsgAt) ? -1 : 1;
            });
          }

          return SafeArea(
            child: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              // TODO:: change background color
              color: TempoTheme.backgroundColor,
              child: Column(
                children: [
                  _buildHeader(context, state),
                  provider.chats != null && provider.chats.isNotEmpty
                      ? Container(
                          height: MediaQuery.of(context).size.height * .77,
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                          decoration: BoxDecoration(
                              color: Colors.white, borderRadius: BorderRadius.circular(20.0)),
                          child: ListView(
                            children: provider.chats
                                .map<Widget>((e) => _buildChatTile(context, auth.user, state, e))
                                .toList(),
                          ),
                        )
                      : SizedBox.shrink()
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Container _buildHeader(BuildContext context, _SocialTabProvider state) {
    return Container(
        height: 60.0,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            borderRadius:
                BorderRadius.only(bottomLeft: Radius.circular(20.0), bottomRight: Radius.circular(20.0)),
            color: Colors.white,
            boxShadow: [
              BoxShadow(blurRadius: 4.0, offset: Offset(0, 4), color: Colors.black.withOpacity(0.25))
            ]),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
                width: MediaQuery.of(context).size.width - 60.0,
                height: 40.0,
                child: TextFormField(
                  controller: state.searchController,
                  decoration: InputDecoration(border: InputBorder.none),
                )),
            IconButton(
              icon: Icon(state.isSearching ? Icons.close : Icons.search),
              onPressed: () {
                state.isSearching = !state.isSearching;
              },
            )
          ],
        ));
  }

  _buildChatTile(BuildContext context, User user, _SocialTabProvider state, Chat e) {
    int indexOfOtherUser = e.users.indexWhere((element) => element.email != user.email);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16.0),
      child: Column(
        children: [
          ListTile(
            onTap: () {
              print('Chat screen');
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => ChatScreen(
                        chat: e,
                      )));
            },
            leading: CircleAvatar(
              backgroundImage: e.imageUrl != null
                  ? CachedNetworkImageProvider(e.imageUrl)
                  : TempoAssets.defaultAvatar,
            ),
            title: Text(
              e.name == 'private conversation' && e.users.length == 2 && indexOfOtherUser != -1
                  ? e.users[indexOfOtherUser].fullName ?? ''
                  : e.name,
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              e.lastMessage?.msgText ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing:
                e.mutedUsersIds.contains(user.email) ? Icon(Icons.notifications_off) : SizedBox.shrink(),
          ),
          Divider()
        ],
      ),
    );
  }
}

class _SocialTabProvider extends ChangeNotifier {
  TextEditingController searchController = TextEditingController();

  bool _isSearching = false;
  bool get isSearching => _isSearching;
  set isSearching(bool value) {
    _isSearching = value;
    notifyListeners();
  }
}
