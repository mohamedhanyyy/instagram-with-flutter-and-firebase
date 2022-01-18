import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_app/view/add_post_screen.dart';
import 'package:firebase_app/view/timeline_screen.dart';
import 'package:firebase_app/view/notifications_screen.dart';
import 'package:firebase_app/view/profile_screen.dart';
import 'package:firebase_app/view/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomeNavigationBar extends StatefulWidget {
  @override
  _HomeNavigationBarState createState() => _HomeNavigationBarState();
}

class _HomeNavigationBarState extends State<HomeNavigationBar> {
  List<Widget> pages = [
    HomePageScreen(),
    SearchScreen(),
    UploadPostScreen(),
    NotificationScreen(),
    ProfileScreen(),
  ];

  int _page = 0;
  GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: CurvedNavigationBar(

          key: _bottomNavigationKey,
          index: 0,
          height: 60.0,

          items: <Widget>[
            FaIcon(FontAwesomeIcons.home),
            FaIcon(FontAwesomeIcons.searchengin),
            FaIcon(FontAwesomeIcons.upload),
             FaIcon(FontAwesomeIcons.solidBell),
             FaIcon(FontAwesomeIcons.userAlt),
            ],
          color: Colors.white,
          backgroundColor: Colors.black,
          animationCurve: Curves.easeInOut,
          animationDuration: Duration(milliseconds: 600),
          onTap: (index) {
            setState(() {
              _page = index;
            });
          },
          letIndexChange: (index) => true,
        ),
        body: pages[_page]);
  }
}
