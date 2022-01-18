import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app/shared/constants.dart';
import 'package:firebase_app/shared/functions.dart';
import 'package:firebase_app/view/notifications_screen.dart';
import 'package:firebase_app/widgets/unicorn_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'comments_screen.dart';
import 'messenger.dart';

class HomePageScreen extends StatefulWidget {
  @override
  _HomePageScreenState createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backwardsCompatibility: false,
        backgroundColor: Colors.white,
        title: GradientText(
          text: "Instagram",
          gradient: LinearGradient(colors: [
            Colors.orange,
            Colors.pink,
          ]),
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'Lobster',
              fontSize: 32,
              color: Colors.black),
        ),
        actions: [
          IconButton(
              onPressed: () {
                navigateToPage(context, NotificationScreen());
              },
              icon: FaIcon(FontAwesomeIcons.bell)),
          IconButton(
              onPressed: () {
                navigateToPage(context, Messenger());
              },
              icon: FaIcon(
                FontAwesomeIcons.facebookMessenger,
                color: Colors.blue,
              )),
        ],
      ),
      body: StreamBuilder(
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData) {
            return Container(
              height: height,
              child: ListView.builder(
                itemCount: snapshot.data.docs.length,
                itemBuilder: (BuildContext context, index) {
                  int likeCount = snapshot.data.docs[index].data()['likeCount'];

                  return StreamBuilder(
                    builder: (BuildContext context,
                        AsyncSnapshot<dynamic> snapshot1) {
                      if (snapshot1.hasData) {
                        return StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection('users')
                              .doc(FirebaseAuth.instance.currentUser!.uid)
                              .collection('feeds')
                              .snapshots(),
                          builder: (context, AsyncSnapshot<dynamic> snapshot2) {
                            if (snapshot2.hasData)
                              return Column(
                                children: [
                                  ListTile(
                                    leading: CircleAvatar(
                                      backgroundImage: NetworkImage(
                                        snapshot1.data['image'],
                                      ),
                                      radius: 30,
                                    ),
                                    title: Text(snapshot1.data['name'],
                                        style: mediumTextStyle(fontSize: 20)),
                                    subtitle: Text(snapshot.data.docs[index]
                                        .data()['location']),
                                    trailing: PopupMenuButton(
                                        itemBuilder: (context) => [
                                              PopupMenuItem(
                                                child: Tooltip(
                                                  message: 'Delete Post',
                                                  child: GestureDetector(
                                                    child: Text("Delete Post"),
                                                    onTap: () async {
                                                      Navigator.pop(context);
                                                      await FirebaseFirestore
                                                          .instance
                                                          .collection('users')
                                                          .doc(FirebaseAuth
                                                              .instance
                                                              .currentUser!
                                                              .uid)
                                                          .collection('posts')
                                                          .doc(snapshot.data
                                                                  .docs[index]
                                                                  .data()[
                                                              'postUid'])
                                                          .delete()
                                                          .then((value) async {
                                                        if (snapshot2.data.docs
                                                                    .length >=
                                                                0 ||
                                                            snapshot2.data !=
                                                                null) {
                                                          for (int i = 0;
                                                              i <
                                                                  snapshot2
                                                                      .data
                                                                      .docs
                                                                      .length;
                                                              i++) {
                                                            if (snapshot2.data
                                                                            .docs[i]
                                                                            .data()[
                                                                        'postUid'] ==
                                                                    snapshot
                                                                            .data
                                                                            .docs[
                                                                                index]
                                                                            .data()[
                                                                        'postUid'] &&
                                                                snapshot2
                                                                        .data
                                                                        .docs
                                                                        .length >=
                                                                    0 &&
                                                                snapshot2.data
                                                                        .docs[i]
                                                                        .data()['postUid'] !=
                                                                    null) {
                                                              await FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      'users')
                                                                  .doc(FirebaseAuth
                                                                      .instance
                                                                      .currentUser!
                                                                      .uid)
                                                                  .collection(
                                                                      'feeds')
                                                                  .doc(snapshot2
                                                                          .data
                                                                          .docs[i]
                                                                          .data()[
                                                                      'feedUid'])
                                                                  .delete()
                                                                  .then((value) =>
                                                                      print(
                                                                          'feed deleted'));
                                                            }
                                                          }
                                                        }

                                                        print(
                                                            '${snapshot.data.docs[index].data()['postUid']} deleted');
                                                      });
                                                    },
                                                  ),
                                                ),
                                                value: 1,
                                              ),
                                            ]),
                                  ),
                                  GestureDetector(
                                    child: Image.network(
                                        snapshot.data.docs[index]
                                            .data()['postImage'],
                                        height: height * 0.5,
                                        width: width,
                                        fit: BoxFit.fill),
                                    onDoubleTap: () {
                                      String postUid = snapshot.data.docs[index]
                                          .data()['postUid'];

                                      if (snapshot.data.docs[index]
                                                  .data()['likes'][
                                              FirebaseAuth
                                                  .instance.currentUser!.uid] ==
                                          true) {
                                        setState(() {
                                          FirebaseFirestore.instance
                                              .collection('users')
                                              .doc(FirebaseAuth
                                                  .instance.currentUser!.uid)
                                              .collection('posts')
                                              .doc(postUid)
                                              .update({
                                            'likes': {
                                              '${FirebaseAuth.instance.currentUser!.uid}':
                                                  false,
                                            },
                                            'likeCount': (likeCount - 1)
                                          });
                                        });
                                      } else {
                                        setState(() {
                                          FirebaseFirestore.instance
                                              .collection('users')
                                              .doc(FirebaseAuth
                                                  .instance.currentUser!.uid)
                                              .collection('posts')
                                              .doc(postUid)
                                              .update({
                                            'likes': {
                                              '${FirebaseAuth.instance.currentUser!.uid}':
                                                  true,
                                            },
                                            'likeCount': (likeCount + 1)
                                          });
                                        });
                                      }
                                    },
                                  ),
                                  Align(
                                    child: snapshot.data.docs[index]
                                                .data()['likeCount'] ==
                                            0
                                        ? Text(
                                            "  Be first to like this post",
                                            style: mediumTextStyle(),
                                          )
                                        : Text(
                                            "  ${snapshot.data.docs[index].data()['likeCount']} Likes",
                                            style: mediumTextStyle(),
                                          ),
                                    alignment: Alignment.centerLeft,
                                  ),
                                  SizedBox(height: 5),
                                  Row(
                                    children: [
                                      Text(
                                        "  " +
                                            snapshot.data.docs[index]
                                                .data()['caption'],
                                        style: mediumTextStyle(),
                                      ),
                                      Text(
                                        '${getFormattedDate(snapshot.data.docs[index].data()['dateTime'])}  ',
                                        style: mediumTextStyle(),
                                      ),
                                    ],
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.baseline,
                                    textBaseline: TextBaseline.alphabetic,
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                          onPressed: () async {
                                            String postUid = snapshot
                                                .data.docs[index]
                                                .data()['postUid'];

                                            if (snapshot.data.docs[index]
                                                        .data()['likes'][
                                                    FirebaseAuth.instance
                                                        .currentUser!.uid] ==
                                                true) {
                                              setState(() {
                                                FirebaseFirestore.instance
                                                    .collection('users')
                                                    .doc(FirebaseAuth.instance
                                                        .currentUser!.uid)
                                                    .collection('posts')
                                                    .doc(postUid)
                                                    .update({
                                                  'likes': {
                                                    '${FirebaseAuth.instance.currentUser!.uid}':
                                                        false,
                                                  },
                                                  'likeCount': (likeCount - 1)
                                                });
                                              });
                                            } else {
                                              setState(() {
                                                FirebaseFirestore.instance
                                                    .collection('users')
                                                    .doc(FirebaseAuth.instance
                                                        .currentUser!.uid)
                                                    .collection('posts')
                                                    .doc(postUid)
                                                    .update({
                                                  'likes': {
                                                    '${FirebaseAuth.instance.currentUser!.uid}':
                                                        true,
                                                  },
                                                  'likeCount': (likeCount + 1)
                                                });
                                              });
                                            }
                                          },
                                          icon: snapshot.data.docs[index]
                                                          .data()['likes'][
                                                      FirebaseAuth.instance
                                                          .currentUser!.uid] ==
                                                  true
                                              ? FaIcon(
                                                  FontAwesomeIcons.solidHeart,
                                                  color: Colors.red,
                                                )
                                              : FaIcon(FontAwesomeIcons.heart)),
                                      IconButton(
                                          onPressed: () {
                                            navigateToPage(
                                                context,
                                                CommentScreen(
                                                  postImage: snapshot
                                                      .data.docs[index]
                                                      .data()['postImage'],
                                                  userUid:
                                                      snapshot1.data['userUid'],
                                                  name: snapshot1.data['name'],
                                                  photo:
                                                      snapshot1.data['image'],
                                                  postUid:
                                                      '${snapshot.data.docs[index].data()['postUid']}',
                                                ));
                                          },
                                          icon: FaIcon(
                                              FontAwesomeIcons.commentDots)),
                                      IconButton(
                                          onPressed: () {},
                                          icon: FaIcon(FontAwesomeIcons.share)),
                                    ],
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                  ),
                                ],
                              );
                            return Text("");
                          },
                        );
                      } else
                        return Center(child: CircularProgressIndicator());
                    },
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(FirebaseAuth.instance.currentUser!.uid)
                        .snapshots(),
                  );
                },
              ),
            );
          } else
            return Text("");
        },
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('posts')
            .orderBy('dateTime', descending: false)
            .snapshots(),
      ),
    );
  }
}
