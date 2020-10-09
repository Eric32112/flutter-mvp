import 'package:bot_toast/bot_toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tempo_official/R.Strings.dart';
import 'package:tempo_official/consts/assets.dart';
import 'package:tempo_official/consts/theme.dart';
import 'package:tempo_official/models/chat.dart';
import 'package:tempo_official/models/message.dart';
import 'package:tempo_official/providers/social_provider.dart';
import 'package:tempo_official/screens/home/create_flyer_screen/create_flyer_screen.dart';
import 'package:tempo_official/screens/home/create_poll_screen/create_poll_screen.dart';

class EditBillboardScreen extends StatelessWidget {
  final Chat chat;
  const EditBillboardScreen({Key key, this.chat}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListenableProvider<_EditBillBoardScreenProvider>(
      create: (_) => _EditBillBoardScreenProvider(),
      child: Consumer<_EditBillBoardScreenProvider>(
        builder: (context, state, child) {
          return Scaffold(
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
              title: Text(
                TempoStrings.labelEditBillboard,
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            body: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Stack(
                children: [
                  Container(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        children: [
                          Container(
                            height: MediaQuery.of(context).size.height * .22,
                            width: MediaQuery.of(context).size.width,
                            child: StreamBuilder<List<Message>>(
                              stream: Provider.of<SocialProvider>(context).getChatFlyers(chat.id),
                              builder: (context, asyncData) {
                                if (asyncData.hasData && asyncData.data != null) {
                                  return asyncData.data.isNotEmpty
                                      ? ListView(
                                          scrollDirection: Axis.horizontal,
                                          children: asyncData.data
                                              .map<Widget>((e) => _buildFlyer(context, e, state))
                                              .toList(),
                                        )
                                      : Center(
                                          child: Container(
                                          child: Text('No Flyers yet.'),
                                        ));
                                } else {
                                  return Center(
                                      child: Container(
                                    width: 50.0,
                                    height: 50.0,
                                    child: CircularProgressIndicator(),
                                  ));
                                }
                              },
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                                color: Colors.white, borderRadius: BorderRadius.circular(23.0)),
                            child: Column(
                              children: [
                                _buildItemTile(context, TempoStrings.labelCreateFlyer, Icons.photo_album,
                                    () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => CreateFlyerScreen(
                                            chatId: chat.id,
                                          )));
                                }),
                                Divider(),
                                _buildItemTile(context, TempoStrings.labelCreateGrpProject, Icons.group,
                                    () {
                                  BotToast.showText(text: 'Feature in development');
                                }),
                                Divider(),
                                _buildItemTile(context, TempoStrings.labelCreatePoll, Icons.poll, () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => CreatePollScreen(
                                            chatId: chat.id,
                                          )));
                                }),
                              ],
                            ),
                          ),
                        ],
                      )),
                  Positioned(
                    bottom: 0.0,
                    child: Container(
                      height: MediaQuery.of(context).size.height * .4,
                      child: Image(
                        image: TempoAssets.manSittingOnMoonHoldingStar,
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildItemTile(BuildContext context, String title, IconData icon, Function onTab) {
    return InkWell(
      onTap: () {
        onTab();
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              icon,
              color: Theme.of(context).primaryColor,
            ),
            SizedBox(width: 16.0),
            Text(
              title,
              style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.bold),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildFlyer(BuildContext context, Message e, _EditBillBoardScreenProvider state) {
    return FlyerCardWidget();
  }
}

class FlyerCardWidget extends StatelessWidget {
  final Message message;
  const FlyerCardWidget({
    @required this.message,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160.0,
      width: 120.0,
      margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: Stack(
        children: [
          Container(
            height: 150.0,
            width: 105.0,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.0),
                image: DecorationImage(
                    fit: BoxFit.cover,
                    image: message.flyer.imageUrl != null
                        ? CachedNetworkImageProvider(message.flyer.imageUrl)
                        : TempoAssets.defaultFlyer)),
          ),
          Positioned(
            right: 2.0,
            bottom: 2.0,
            child: InkWell(
              onTap: () {},
              child: Container(
                  height: 36.0,
                  width: 36.0,
                  child: Center(
                      child: Container(
                          height: 18.0, width: 18.0, child: Image(image: TempoAssets.cameraIcon))),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: TempoTheme.retroOrange,
                      border: Border.all(width: 2.0, color: Colors.white))),
            ),
          )
        ],
      ),
    );
  }
}

class _EditBillBoardScreenProvider extends ChangeNotifier {}
