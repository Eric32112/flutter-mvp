import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tempo_official/R.Strings.dart';
import 'package:tempo_official/consts/assets.dart';
import 'package:tempo_official/consts/theme.dart';
import 'package:tempo_official/models/user.dart';
import 'package:tempo_official/providers/auth_provider.dart';
import 'package:tempo_official/screens/home/about_tempo/about_tempo_screen.dart';
import 'package:tempo_official/screens/home/change_password/change_password_screen.dart';
import 'package:tempo_official/screens/home/edit_profile/edit_profile_screen.dart';
import 'package:tempo_official/widgets/transparent_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // TODO:: fix the background color.
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
              borderRadius:
                  BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30))),
          title: Text(
            TempoStrings.labelSettings,
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        body: Stack(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Column(
                children: [
                  SizedBox(
                    height: 12,
                  ),
                  Container(
                    decoration: BoxDecoration(color: Colors.white),
                    padding: EdgeInsets.only(bottom: 130.0),
                    child: Column(
                      children: [
                        _buildUserTile(),
                        Divider(
                          color: TempoTheme.dividerColor,
                        ),
                        _buildTile(
                            text: TempoStrings.labelChangePW,
                            onTab: () {
                              Navigator.of(context)
                                  .push(MaterialPageRoute(builder: (context) => ChangePasswordScreen()));
                            },
                            icon: TempoAssets.lockIcon),
                        Divider(
                          color: TempoTheme.dividerColor,
                        ),
                        _buildTile(
                            text: TempoStrings.labelNotifications,
                            onTab: () {},
                            icon: TempoAssets.notificationIcon),
                        Divider(
                          color: TempoTheme.dividerColor,
                        ),
                        _buildTile(
                            text: TempoStrings.labelLogout,
                            onTab: () {
                              Provider.of<AuthProvider>(context, listen: false)
                                  .logout(context)
                                  .then((value) {
                                Navigator.of(context).popUntil((route) => route.isFirst);
                              });
                            },
                            icon: TempoAssets.logoutIcon),
                        Divider(
                          color: TempoTheme.dividerColor,
                        ),
                        _buildTile(
                            text: TempoStrings.labelAboutTempo,
                            onTab: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => AboutTempoScreen(),
                              ));
                            },
                            icon: TempoAssets.helpQuestionMarkIcon),
                        Divider(
                          color: TempoTheme.dividerColor,
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            Positioned(
              bottom: 0.0,
              right: 0.0,
              child: Image(
                image: TempoAssets.rocketManLeftFilled,
              ),
            )
          ],
        ));
  }

  _buildUserTile() {
    return Consumer<AuthProvider>(
        builder: (context, authProvider, child) => InkWell(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => EditProfileScreen()));
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(100.0),
                      child: Container(
                        height: 86.0,
                        width: 100.0,
                        decoration: BoxDecoration(shape: BoxShape.circle),
                        child: Image(
                          fit: BoxFit.cover,
                          image: authProvider.user.avatar != null
                              ? CachedNetworkImageProvider(
                                  authProvider.user.avatar,
                                )
                              : TempoAssets.defaultAvatar,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 16.0,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          authProvider.user?.fullName ?? 'Full name',
                          style: TextStyle(
                              fontSize: 18.0, fontWeight: FontWeight.w500, color: Colors.black),
                        ),
                        Text(
                          authProvider.user?.status ?? 'Status',
                          style: TextStyle(
                              fontSize: 16.0, fontWeight: FontWeight.w500, color: TempoTheme.grey2),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ));
  }

  _buildTile({String text, Null Function() onTab, AssetImage icon}) {
    return InkWell(
      onTap: () {
        onTab();
      },
      child: Container(
        height: 64.0,
        padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
        child: Row(
          children: [
            Image(
              image: icon,
            ),
            SizedBox(
              width: 16.0,
            ),
            Text(
              text,
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}
