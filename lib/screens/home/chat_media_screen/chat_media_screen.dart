import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:tempo_official/models/chat.dart';
import 'package:tempo_official/models/message.dart';
import 'package:tempo_official/providers/social_provider.dart';
import 'package:tempo_official/services/date_helper.dart';

class ChatMediaScreen extends StatelessWidget {
  final Chat chat;
  const ChatMediaScreen({Key key, this.chat}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<SocialProvider>(builder: (context, socialProvider, child) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text('${chat.name} Media'),
          shape: ContinuousRectangleBorder(
              borderRadius:
                  BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30))),
        ),
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: StreamBuilder<List<Message>>(
              stream: socialProvider.getChatMedia(chat.id),
              builder: (context, AsyncSnapshot<List<Message>> asyncData) {
                Map<String, List<Message>> dates = {};

                if (asyncData.hasData && asyncData.data != null) {
                  asyncData.data.forEach((element) {
                    DateTime _date = DateTime.fromMillisecondsSinceEpoch(int.parse(element.sentAt));
                    DateTime _month = DateTime(_date.year, _date.month);
                    DateTime now = DateTime.now();
                    if (!dates.containsKey(_month.millisecondsSinceEpoch.toString())) {
                      dates.addAll({_month.millisecondsSinceEpoch.toString(): []});
                    }
                    dates[_month.millisecondsSinceEpoch.toString()].add(element);
                  });
                  return asyncData.data.isNotEmpty
                      ? ListView(
                          children: dates.keys.map((e) {
                            var messages = dates[e];
                            DateTime _date = DateTime.fromMillisecondsSinceEpoch(int.parse(e));
                            var isRecent =
                                _date.month == DateTime.now().month && _date.year == DateTime.now().year;
                            return Container(
                              child: Column(
                                children: [
                                  Container(
                                      height: 40.0,
                                      width: MediaQuery.of(context).size.width,
                                      decoration: BoxDecoration(color: Color(0xffE6E6E6)),
                                      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16.0),
                                      child: Text(isRecent ? 'Recent' : DateHelper.formateDay(_date),
                                          style:
                                              TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold))),
                                  Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: Wrap(
                                        children: messages
                                            .map(
                                              (e) => InkWell(
                                                onTap: () {
                                                  showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        return Container(
                                                            child: Container(
                                                          child: PhotoView(
                                                            imageProvider: CachedNetworkImageProvider(
                                                                e.attachmentsUrl.first),
                                                          ),
                                                        ));
                                                      });
                                                },
                                                child: Container(
                                                    height: 80.0,
                                                    width: 80.0,
                                                    padding: EdgeInsets.all(0.5),
                                                    decoration: BoxDecoration(
                                                        image: DecorationImage(
                                                            fit: BoxFit.cover,
                                                            image: CachedNetworkImageProvider(
                                                                e.attachmentsUrl.first)))),
                                              ),
                                            )
                                            .toList(),
                                      ))
                                ],
                              ),
                            );
                          }).toList(),
                        )
                      : Center(
                          child: Container(
                          height: 50.0,
                          width: 50.0,
                          child: Text('No Media Yet'),
                        ));
                }
                return Center(
                    child: Container(
                  height: 50.0,
                  width: 50.0,
                  child: CircularProgressIndicator(),
                ));
              }),
        ),
      );
    });
  }
}
