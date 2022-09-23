import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatfew/Widgets/ProgressWidgets.dart';
import 'package:chatfew/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:firebase_auth/firebase_auth.dart';
import 'package:chatfew/Models/user.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'AccountSettingsPage.dart';
import 'ChattingPage.dart';

class HomeScreen extends StatefulWidget {
  final String currentUserId;

  HomeScreen({required this.currentUserId});
  @override
  State createState() => HomeScreenState(currentUserId: currentUserId);
}

class HomeScreenState extends State<HomeScreen> {
  HomeScreenState({required this.currentUserId});
  TextEditingController searchTextEditingController = TextEditingController();
  var futureSearchResults;
  static List<Widget> _widgetOptions = [];
  int _selectedIndex = 0;
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  final String currentUserId;

  homePageHeader() {
    return AppBar(
      //automaticallyImplyLeading: false,
      centerTitle: true,
      actions: <Widget>[
        IconButton(
          icon: Icon(
            Icons.settings,
            size: 30.0,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => Setting()));
          },
        )
      ],
      backgroundColor: Colors.lightBlue,
      title: Container(
        margin: new EdgeInsets.only(bottom: 1.0),
        child: TextFormField(
          style: TextStyle(fontSize: 18.0, color: Colors.white),
          controller: searchTextEditingController,
          decoration: InputDecoration(
              hintText: "Search here....",
              hintStyle: TextStyle(color: Colors.white),
              enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey)),
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white)),
              filled: true,
              prefixIcon: Icon(
                Icons.person_pin,
                color: Colors.white,
                size: 30.0,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  Icons.clear,
                  color: Colors.white,
                ),
                onPressed: emptyTextFormField,
              )),
          onFieldSubmitted: controlSearching,
        ),
      ),
    );
  }

  controlSearching(String userName) {
    Future<QuerySnapshot> allFoundUsers = FirebaseFirestore.instance
        .collection("users")
        .where("nickname", isGreaterThanOrEqualTo: userName)
        .get();
    setState(() {
      futureSearchResults = allFoundUsers;
    });
  }

  emptyTextFormField() {
    searchTextEditingController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: homePageHeader(),
      body: futureSearchResults == null
          ? displayNoSearchResultScreen()
          : displayUserFoundScreen()

    );

    /*ElevatedButton.icon(
      onPressed: logoutUser,
      icon: Icon(Icons.close),
      label: Text("Sign Out"),
    );*/
  }

  displayUserFoundScreen() {
    return FutureBuilder(
        future: futureSearchResults,
        builder: (context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }
          List<UserResult> searchUserResult = [];
          snapshot.data.docs.forEach((document) {
            User eachUser = User.fromDocument(document);
            print(eachUser.toString());
            UserResult userResult = UserResult(eachUser);

            if (currentUserId != document['id']) {
              searchUserResult.add(userResult);
            }
          });
          return ListView(
            children: searchUserResult,
          );
        });
  }

  displayNoSearchResultScreen() {
    final Orientation orientation = MediaQuery.of(context).orientation;

    return Container(
      alignment: Alignment.bottomCenter,
      child: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          /*BottomNavigationBarItem(
              icon: Image.asset(
                'assets/icons/Chat-Icon-3D.png',
                height: 20,
              ),
              label: 'Chat',
              backgroundColor: Colors.blueAccent,
            ),*/
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
            backgroundColor: Colors.blueGrey,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'User',
            backgroundColor: Colors.indigoAccent,
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Color.fromRGBO(11, 74, 153, 1),
        onTap: _onItemTapped,

      ),
       //child: _widgetOptions[_selectedIndex],
    );
  }
}

class UserResult extends StatelessWidget {
  final User eachUser;
  UserResult(this.eachUser);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(4.0),
      child: Container(
        color: Colors.white,
        child: Column(
          children: <Widget>[
            GestureDetector(
              onTap: () => sendUserToChatPage(context),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.black,
                  backgroundImage:
                      CachedNetworkImageProvider(eachUser.photoUrl),
                ),
                title: Text(
                  eachUser.nickname,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  "Joined:" +
                      DateFormat("dd MMMM, yyyy - hh:mm:aa").format(
                          DateTime.fromMillisecondsSinceEpoch(
                              int.parse(eachUser.createdAt))),
                  style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14.0,
                      fontStyle: FontStyle.italic),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  sendUserToChatPage(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Chat(
                receiverId: eachUser.id,
                receiverAvatar: eachUser.photoUrl,
                receiverName: eachUser.nickname)));
  }
}
