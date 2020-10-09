import 'package:bot_toast/bot_toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tempo_official/R.Strings.dart';
import 'package:tempo_official/consts/assets.dart';
import 'package:tempo_official/consts/theme.dart';
import 'package:tempo_official/providers/auth_provider.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListenableProvider<_EditProfileScreenProvider>(
      create: (_) {
        _EditProfileScreenProvider provider = _EditProfileScreenProvider();
        AuthProvider authProvider = Provider.of<AuthProvider>(context, listen: true);

        provider.emailCtrl.text = authProvider.user.email ?? '';
        provider.statusCtrl.text = authProvider.user.status ?? '';
        provider.nameCtrl.text = authProvider.user.fullName ?? '';
        return provider;
      },
      child: Scaffold(
        // TODO:: fix background color
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
            TempoStrings.labeProfile,
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
        ),

        body: Consumer<_EditProfileScreenProvider>(builder: (context, state, child) {
          AuthProvider provider = Provider.of<AuthProvider>(context, listen: false);

          return SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height - 80.0,
              child: Stack(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          height: 12,
                        ),
                        Container(
                          decoration: BoxDecoration(color: Colors.white),
                          padding: EdgeInsets.only(bottom: 130.0),
                          child: Column(
                            children: [
                              _buildUserAvatar(context, provider, state),
                              Divider(
                                color: TempoTheme.dividerColor,
                              ),
                              _buildInputTile(context,
                                  label: TempoStrings.labelName,
                                  onTab: () {},
                                  ctrl: state.nameCtrl,
                                  node: state.nameNode,
                                  suffix: TempoAssets.penIcon,
                                  leading: TempoAssets.avatarPathIcon),
                              Divider(
                                color: TempoTheme.dividerColor,
                              ),
                              _buildInputTile(context,
                                  label: TempoStrings.labelName,
                                  onTab: () {},
                                  ctrl: state.statusCtrl,
                                  node: state.statusNode,
                                  suffix: TempoAssets.penIcon,
                                  leading: TempoAssets.colorPaletteIcon),
                              Divider(
                                color: TempoTheme.dividerColor,
                              ),
                              _buildInputTile(
                                context,
                                label: TempoStrings.labelEmail,
                                onTab: () {},
                                ctrl: state.emailCtrl,
                                node: state.emailNode,
                                leading: TempoAssets.mailIcon,
                              ),
                              Divider(
                                color: TempoTheme.dividerColor,
                              ),
                            ],
                          ),
                        ),
                        Image(
                          image: TempoAssets.manRidingRocketComplete,
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 0.0,
                    left: 0.0,
                    right: 0.0,
                    child: Container(
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12.0), boxShadow: [
                        BoxShadow(
                            blurRadius: 4.0,
                            offset: Offset(0, -1.0),
                            color: Colors.black.withOpacity(0.25))
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildUserAvatar(
      BuildContext context, AuthProvider provider, _EditProfileScreenProvider state) {
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
                child: state.isUploadingImage
                    ? Center(
                        child: Container(height: 50.0, width: 50.0, child: CircularProgressIndicator()))
                    : Image(
                        fit: BoxFit.cover,
                        image: provider.user.avatar != null
                            ? CachedNetworkImageProvider(
                                provider.user.avatar,
                              )
                            : TempoAssets.defaultAvatar,
                      ),
              ),
            ),
            Positioned(
              bottom: 5.0,
              right: 5.0,
              child: InkWell(
                onTap: () {
                  BotToast.showText(text: 'updating profile picture');
                  state.isUploadingImage = true;
                  provider.pickUserAvatar().then((value) {
                    state.isUploadingImage = false;
                    BotToast.showText(text: 'Profile picture uploaded!');
                  }).catchError(() {
                    BotToast.showText(text: 'Error uploading profile picture');
                  });
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

  _buildInputTile(context,
      {String label,
      Null Function() onTab,
      TextEditingController ctrl,
      FocusNode node,
      AssetImage leading,
      AssetImage suffix}) {
    return Row(children: [
      Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 8.0),
        child: Image(image: leading),
      ),
      Container(
        height: 52.0,
        width: MediaQuery.of(context).size.width - 50.0,
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: TextFormField(
            controller: ctrl,
            enabled: false,
            focusNode: node,
            decoration: InputDecoration(
                suffixIcon: suffix != null
                    ? InkWell(
                        onTap: () {},
                        child: Image(
                          image: suffix,
                        ),
                      )
                    : null,
                labelText: label,
                border: InputBorder.none,
                labelStyle: TextStyle(color: TempoTheme.grey2))),
      )
    ]);
  }
}

class _EditProfileScreenProvider extends ChangeNotifier {
  TextEditingController emailCtrl = TextEditingController();
  FocusNode emailNode = FocusNode();
  TextEditingController nameCtrl = TextEditingController();
  FocusNode nameNode = FocusNode();
  TextEditingController statusCtrl = TextEditingController();
  FocusNode statusNode = FocusNode();

  bool _isUploadingImage = false;
  bool get isUploadingImage => _isUploadingImage;
  set isUploadingImage(bool value) {
    _isUploadingImage = value;
    notifyListeners();
  }
}
