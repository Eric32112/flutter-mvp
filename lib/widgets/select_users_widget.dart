import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tempo_official/consts/assets.dart';
import 'package:tempo_official/models/user.dart';
import 'package:tempo_official/providers/auth_provider.dart';

class SelectUsersWidget extends StatelessWidget {
  final Function(List<User>) onUserSelect;
  final List<User> selectedUsers;
  SelectUsersWidget({this.onUserSelect, this.selectedUsers});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        margin: EdgeInsets.all(16.0),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10.0)),
        child: StreamBuilder<List<DocumentSnapshot>>(
          stream: Provider.of<AuthProvider>(context, listen: false).getUsers(),
          builder: (BuildContext context, AsyncSnapshot<List<DocumentSnapshot>> asyncSnapshot) {
            if (asyncSnapshot.hasData && asyncSnapshot.data != null) {
              return ListView(
                children: asyncSnapshot.data
                    .map((DocumentSnapshot userDoc) => Column(children: [
                          ListTile(
                            onTap: () {
                              this.onUserSelect([...this.selectedUsers, User.fromJson(userDoc.data)]);
                            },
                            title: Text(userDoc.data['fullName'] ?? ''),
                            subtitle: Text(userDoc.data['status'] ?? ''),
                            trailing: selectedUsers.contains(User.fromJson(userDoc.data))
                                ? Icon(Icons.check_circle, color: Theme.of(context).primaryColor)
                                : SizedBox.shrink(),
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(100.0),
                              child: Container(
                                height: 50.0,
                                width: 50.0,
                                decoration: BoxDecoration(shape: BoxShape.circle),
                                child: Image(
                                  fit: BoxFit.cover,
                                  image: userDoc.data['avatar'] != null
                                      ? CachedNetworkImageProvider(
                                          userDoc.data['avatar'],
                                        )
                                      : TempoAssets.defaultAvatar,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32.0),
                            child: Divider(
                              color: Color(0xffCDC9C9),
                            ),
                          )
                        ]))
                    .toList(),
              );
            } else {
              return Container(
                height: MediaQuery.of(context).size.height - 32.0,
                width: MediaQuery.of(context).size.width - 32.0,
                child: Center(
                  child: Container(
                    height: 50.0,
                    width: 50.0,
                    child: CircularProgressIndicator(),
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
