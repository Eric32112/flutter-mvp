import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tempo_official/consts/assets.dart';
import 'package:tempo_official/models/user.dart';
import 'package:tempo_official/providers/auth_provider.dart';
import 'package:tempo_official/screens/home/create_chat_screen/create_chat_screen.dart';

class AddUsersScreen extends StatelessWidget {
  final String title;
  final String subTitle;
  final List<User> users;
  final Null Function(List<User>) onSelected;
  const AddUsersScreen({
    Key key,
    this.title,
    this.subTitle,
    this.users,
    this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListenableProvider<AddUsersScreenProvider>(
      create: (_) {
        AddUsersScreenProvider state = AddUsersScreenProvider();
        state.selectedUsers = this.users ?? [];
        return state;
      },
      dispose: (context, state) {
        state.searchController.text = '';
        state.isSearching = false;
        onSelected(state.selectedUsers);
      },
      child: Consumer<AddUsersScreenProvider>(
        builder: (context, state, child) {
          return Scaffold(
            body: Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Stack(
                  children: [
                    buildUsersList(context, state),
                    Positioned(top: 00.0, left: 0, right: 0, child: _buildHeader(context, state)),
                  ],
                )),
            floatingActionButton: FloatingActionButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Icon(Icons.check)),
          );
        },
      ),
    );
  }

  Widget buildUsersList(
    BuildContext context,
    AddUsersScreenProvider state,
  ) {
    CollectionReference collectionReference =
        Provider.of<AuthProvider>(context, listen: false).firestore.collection('users');
    return FutureBuilder<QuerySnapshot>(
      future: collectionReference.limit(200).getDocuments(),
      builder: (context, asyncSnapshot) {
        if (asyncSnapshot.hasData && asyncSnapshot.data != null) {
          return Container(
            height: MediaQuery.of(context).size.height,
            child: ListView(
              children: asyncSnapshot.data.documents
                  .map((DocumentSnapshot userDoc) => _buildUserTile(context, state, userDoc))
                  .toList(),
            ),
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
    );
  }

  Widget _buildUserTile(
    BuildContext context,
    AddUsersScreenProvider state,
    DocumentSnapshot userDoc,
  ) {
    print('user ${state.selectedUsers.map((e) => e.toJson()).toList()}');
    return Column(children: [
      ListTile(
        onTap: () {
          state.searchController.clear();
          FocusScope.of(context).requestFocus(FocusNode());
          if (state.selectedUsers.indexWhere((element) => element.id == userDoc.documentID) == -1) {
            state.selectedUsers = [...state.selectedUsers, User.fromJson(userDoc.data)];
          }
        },
        title: Text(userDoc.data['fullName'] ?? ''),
        subtitle: Text(userDoc.data['status'] ?? ''),
        trailing: state.selectedUsers.indexWhere((e) => e.id == userDoc.documentID) != -1
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
    ]);
  }

  Widget _buildHeader(BuildContext context, AddUsersScreenProvider state) {
    return ValueListenableBuilder<TextEditingValue>(
        valueListenable: state.searchController,
        builder: (context, textValue, child) {
          return SafeArea(
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                        blurRadius: 4.0, offset: Offset(0, 4), color: Colors.black.withOpacity(0.25))
                  ],
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20.0), bottomRight: Radius.circular(20.0))),
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Column(
                children: [
                  Container(
                    height: 50.0,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        !state.isSearching ? BackButton() : SizedBox.shrink(),
                        !state.isSearching
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(title, style: TextStyle(color: Colors.black, fontSize: 18.0)),
                                  subTitle != null
                                      ? SizedBox(
                                          height: 8.0,
                                        )
                                      : SizedBox.shrink(),
                                  subTitle != null
                                      ? Text(subTitle,
                                          style: TextStyle(color: Colors.black, fontSize: 14.0))
                                      : SizedBox.shrink()
                                ],
                              )
                            : SizedBox.shrink(),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              state.isSearching
                                  ? Container(
                                      width: MediaQuery.of(context).size.width - 35.0,
                                      decoration: BoxDecoration(
                                          border: textValue.text.isEmpty
                                              ? Border.all(width: 1.0, color: Colors.black)
                                              : null),
                                      child: Padding(
                                        padding: const EdgeInsets.only(top: 16.0),
                                        child: TextFormField(
                                          style: TextStyle(
                                              fontSize: 18.0, fontWeight: FontWeight.w500, height: 1.2),
                                          controller: state.searchController,
                                          focusNode: state.searchNode,
                                          decoration: InputDecoration(
                                              hintText: 'Search Users',
                                              border: textValue.text.isEmpty ? null : InputBorder.none,
                                              prefix: textValue.text.isEmpty
                                                  ? IconButton(
                                                      padding: EdgeInsets.all(0.0),
                                                      icon: Icon(Icons.search),
                                                      onPressed: () {
                                                        state.isSearching = !state.isSearching;
                                                      },
                                                    )
                                                  : null,
                                              suffix: IconButton(
                                                padding: EdgeInsets.all(0.0),
                                                icon:
                                                    Icon(state.isSearching ? Icons.close : Icons.search),
                                                onPressed: () {
                                                  state.isSearching = !state.isSearching;
                                                },
                                              )),
                                        ),
                                      ))
                                  : SizedBox.shrink(),
                              !state.isSearching
                                  ? IconButton(
                                      icon: Icon(state.isSearching ? Icons.close : Icons.search),
                                      onPressed: () {
                                        state.isSearching = !state.isSearching;
                                        if (state.searchNode.hasFocus) {
                                          FocusScope.of(context).requestFocus(FocusNode());
                                        } else {
                                          FocusScope.of(context).requestFocus(state.searchNode);
                                        }
                                      },
                                    )
                                  : SizedBox()
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  textValue.text.isNotEmpty
                      ? FutureBuilder<QuerySnapshot>(
                          future: Provider.of<AuthProvider>(context)
                              .firestore
                              .collection('users')
                              .where('id', isLessThanOrEqualTo: textValue.text)
                              .getDocuments(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData && snapshot.data != null) {
                              return Container(
                                  height: snapshot.data.documents.length * 50.0,
                                  constraints: BoxConstraints(
                                      maxHeight: MediaQuery.of(context).size.height - 50.0),
                                  width: MediaQuery.of(context).size.width - 60.0,
                                  child: snapshot.hasData &&
                                          snapshot.data != null &&
                                          snapshot.data.documents.isNotEmpty
                                      ? ListView.builder(
                                          itemCount: snapshot.data.documents.length,
                                          itemBuilder: (context, index) => _buildUserTile(
                                              context, state, snapshot.data.documents[index]))
                                      : SizedBox.shrink());
                            }
                            return SizedBox.shrink();
                          },
                        )
                      : SizedBox.shrink()
                ],
              ),
            ),
          );
        });
  }
}

class AddUsersScreenProvider extends ChangeNotifier {
  TextEditingController searchController = TextEditingController();
  FocusNode searchNode = FocusNode();

  bool _isSearching = false;
  bool get isSearching => _isSearching;
  set isSearching(bool value) {
    _isSearching = value;

    notifyListeners();
  }

  List<User> _selectedUsers = [];
  List<User> get selectedUsers => _selectedUsers;
  set selectedUsers(List<User> value) {
    _selectedUsers = value;
    notifyListeners();
  }
}
