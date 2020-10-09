import 'package:bot_toast/bot_toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:tempo_official/consts/theme.dart';
import 'package:tempo_official/providers/auth_provider.dart';
import 'package:tempo_official/providers/planner_provider.dart';
import 'package:tempo_official/providers/social_provider.dart';
import 'package:tempo_official/screens/auth/login/login_screen.dart';
import 'package:tempo_official/screens/auth/setup_account_screen/setup_account_screen.dart';
import 'package:tempo_official/screens/home/home_screen.dart';
import 'package:tempo_official/screens/loading/loading_screen.dart';
import 'package:tempo_official/services/locator_service.dart';
import 'package:tempo_official/models/user.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_phoenix/flutter_phoenix.dart';

void main() {
  tz.initializeTimeZones();
  runApp(Phoenix(
    child: TempoApp(),
  ));
}

class TempoApp extends StatefulWidget {
  @override
  _TempoAppState createState() => _TempoAppState();
}

class _TempoAppState extends State<TempoApp> {
  List<SingleChildWidget> providers = [];
  @override
  void initState() {
    setupLocator();
    providers = [
      ListenableProvider(
        create: (_) => locator<AuthProvider>(),
      ),
      ListenableProvider(
        create: (_) => locator<PlannerProvider>(),
      ),
      ListenableProvider(
        create: (_) => locator<SocialProvider>(),
      )
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: providers,
        child: MaterialApp(
          title: 'Tempo',
          theme: TempoTheme.themeData,
          localizationsDelegates: const <LocalizationsDelegate<MaterialLocalizations>>[
            GlobalMaterialLocalizations.delegate
          ],
          supportedLocales: const <Locale>[
            const Locale('en', ''),
          ],
          builder: BotToastInit(),
          home: Consumer<AuthProvider>(builder: (context, authProvider, snapshot) {
            return StreamBuilder<FirebaseUser>(
                stream: authProvider.authChange(),
                builder: (context, snapshot) {
                  return snapshot.hasData && snapshot.data != null
                      ? Provider<FirebaseUser>(
                          create: (_) => snapshot.data,
                          child: FutureBuilder<User>(
                              future: authProvider.getUserData(
                                  snapshot.data.email, authProvider.user == null),
                              builder: (context, userDataSnapshot) {
                                if (userDataSnapshot.hasData && userDataSnapshot.data != null) {
                                  return Provider<User>(
                                    create: (_) =>
                                        userDataSnapshot.hasData ? userDataSnapshot.data : User(),
                                    child: Consumer<User>(
                                      builder: (context, user, child) {
                                        return StreamBuilder<QuerySnapshot>(
                                            stream: authProvider.firestore
                                                .collection('interests')
                                                .snapshots(),
                                            builder: (context, snapshot) {
                                              List<Interest> interests =
                                                  snapshot.hasData && snapshot.data != null
                                                      ? snapshot.data.documents
                                                          .map((e) => Interest.fromJson(e.data))
                                                          .toList()
                                                      : [];

                                              return user.interests != null && user.interests.length > 0
                                                  ? HomeScreen()
                                                  : SetupAccountScreen(
                                                      interestsSuggestions: interests,
                                                    );
                                            });
                                      },
                                    ),
                                  );
                                }
                                return LoadingScreen();
                              }),
                        )
                      : LoginScreen();
                });
          }),
        ));
  }
}
