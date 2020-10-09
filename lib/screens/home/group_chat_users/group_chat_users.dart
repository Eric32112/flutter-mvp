import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tempo_official/consts/assets.dart';
import 'package:tempo_official/models/chat.dart';

class GroupChatUsers extends StatelessWidget {
  final Chat chat;
  const GroupChatUsers({Key key, this.chat}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [Expanded(child: _buildUsersList())],
        ),
      ),
    );
  }

  ListView _buildUsersList() {
    return ListView(
        children: chat.users.map((e) {
      return Container(
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
              )
            ],
          ));
    }).toList());
  }
}
