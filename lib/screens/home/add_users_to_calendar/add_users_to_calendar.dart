import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tempo_official/R.Strings.dart';
import 'package:tempo_official/consts/assets.dart';
import 'package:tempo_official/providers/auth_provider.dart';

class AddUsersToCalendarScreen extends StatelessWidget {
  final String calendarId;
  AddUsersToCalendarScreen({this.calendarId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            borderRadius:
                BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30))),
        title: Text(
          TempoStrings.labelShareCalendar,
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {},
          )
        ],
      ),
      backgroundColor: Color(0xffEFE6D4),
      body: Container(
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
                            onTap: () {},
                            title: Text(userDoc.data['fullName']),
                            subtitle: Text(userDoc.data['status']),
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
