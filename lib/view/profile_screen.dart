import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app/shared/constants.dart';
import 'package:firebase_app/shared/functions.dart';
import 'package:firebase_app/view/comments_screen.dart';
import 'package:firebase_app/view/show_post_screen.dart';
import 'package:firebase_app/view/update_user_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../providers/FollowingProvider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool toggleGridOrList = false;
  bool showHeart = false;

  @override
  Widget build(BuildContext context) {
    Provider.of<FollowingProvider>(context, listen: false).getFollowersCount(FirebaseAuth.instance.currentUser!.uid);
    Provider.of<FollowingProvider>(context, listen: false).getFollowingCount(FirebaseAuth.instance.currentUser!.uid);

    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: customAppBar(),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: width * 0.03),
        child: ListView(
          children: [
            SizedBox(height: 5),
            buildRowUserData(width, height, context),
            buildUserBio(),
            SizedBox(height: 5),
            buildToggle(),
            SizedBox(height: 5),
            if (toggleGridOrList == true) buildGridViewData(height),
            if (toggleGridOrList == false)
              StreamBuilder(
                builder:
                    (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                  if (snapshot.hasData) {
                    return Container(
                      /// TODO : ERROR HERE
                      height: height * 0.57,
                      child: ListView.builder(
                        itemCount: snapshot.data.docs.length,
                        itemBuilder: (BuildContext context, index) {
                          int likeCount =
                              snapshot.data.docs[index].data()['likeCount'];

                          return StreamBuilder(
                            builder: (BuildContext context,
                                AsyncSnapshot<dynamic> snapshot1) {
                              if (snapshot1.hasData) {
                                return StreamBuilder(
                                  stream: FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(FirebaseAuth
                                          .instance.currentUser!.uid)
                                      .collection('feeds')
                                      .snapshots(),
                                  builder: (context,
                                      AsyncSnapshot<dynamic> snapshot2) {
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
                                                style: mediumTextStyle(
                                                    fontSize: 20)),
                                            subtitle: Text(snapshot
                                                .data.docs[index]
                                                .data()['location']),
                                            trailing: PopupMenuButton(
                                                itemBuilder: (context) => [
                                                      PopupMenuItem(
                                                        child: Tooltip(
                                                          message:
                                                              'Delete Post',
                                                          child:
                                                              GestureDetector(
                                                            child: Text(
                                                                "Delete Post"),
                                                            onTap: () async {

                                                              await FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      'users')
                                                                  .doc(FirebaseAuth
                                                                      .instance
                                                                      .currentUser!
                                                                      .uid)
                                                                  .collection(
                                                                      'posts')
                                                                  .doc(snapshot
                                                                          .data
                                                                          .docs[
                                                                              index]
                                                                          .data()[
                                                                      'postUid'])
                                                                  .delete()
                                                                  .then(
                                                                      (value) async {
                                                                        Navigator.pop(context);

                                                                        if (snapshot2
                                                                            .data
                                                                            .docs
                                                                            .length >=
                                                                        0 ||
                                                                    snapshot2
                                                                            .data !=
                                                                        null) {
                                                                  for (int i =
                                                                          0;
                                                                      i <
                                                                          snapshot2
                                                                              .data
                                                                              .docs
                                                                              .length;
                                                                      i++) {
                                                                    if (snapshot2.data.docs[i].data()['postUid'] ==
                                                                            snapshot.data.docs[index].data()[
                                                                                'postUid'] &&
                                                                        snapshot2.data.docs.length >=
                                                                            0 &&
                                                                        snapshot2.data.docs[i].data()['postUid'] !=
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
                                                                              .data()['feedUid'])
                                                                          .delete()
                                                                          .then((value) => print('feed deleted'));
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
                                            child: Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                Image.network(
                                                    snapshot.data.docs[index]
                                                        .data()['postImage'],
                                                    height: height * 0.5,
                                                    width: width,
                                                    fit: BoxFit.fill),
                                                if (showHeart == true)
                                                  Icon(
                                                    Icons.favorite,
                                                    color: Colors.red,
                                                    size: 70,
                                                  ),
                                              ],
                                            ),
                                            onDoubleTap: () {
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
                                          ),
                                          Align(
                                            child: snapshot.data.docs[index]
                                                        .data()['likeCount'] ==
                                                    0
                                                ? Text(
                                                    "Be first to like this post",
                                                    style: mediumTextStyle(),
                                                  )
                                                : Text(
                                                    "${snapshot.data.docs[index].data()['likeCount']} Likes",
                                                    style: mediumTextStyle(),
                                                  ),
                                            alignment: Alignment.centerLeft,
                                          ),
                                          SizedBox(height: 5),
                                          Row(
                                            children: [
                                              Text(
                                                snapshot.data.docs[index]
                                                    .data()['caption'],
                                                style: mediumTextStyle(),
                                              ),
                                              Text(
                                                getFormattedDate(snapshot
                                                    .data.docs[index]
                                                    .data()['dateTime']),
                                                style: mediumTextStyle(),
                                              ),
                                            ],
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.baseline,
                                            textBaseline:
                                                TextBaseline.alphabetic,
                                          ),
                                          Row(
                                            children: [
                                              IconButton(
                                                  onPressed: () async {
                                                    String postUid = snapshot
                                                        .data.docs[index]
                                                        .data()['postUid'];

                                                    if (snapshot.data
                                                                .docs[index]
                                                                .data()['likes']
                                                            [FirebaseAuth
                                                                .instance
                                                                .currentUser!
                                                                .uid] ==
                                                        true) {
                                                      setState(() {
                                                        FirebaseFirestore
                                                            .instance
                                                            .collection('users')
                                                            .doc(FirebaseAuth
                                                                .instance
                                                                .currentUser!
                                                                .uid)
                                                            .collection('posts')
                                                            .doc(postUid)
                                                            .update({
                                                          'likes': {
                                                            '${FirebaseAuth.instance.currentUser!.uid}':
                                                                false,
                                                          },
                                                          'likeCount':
                                                              (likeCount - 1)
                                                        });
                                                      });
                                                    } else {
                                                      setState(() {
                                                        FirebaseFirestore
                                                            .instance
                                                            .collection('users')
                                                            .doc(FirebaseAuth
                                                                .instance
                                                                .currentUser!
                                                                .uid)
                                                            .collection('posts')
                                                            .doc(postUid)
                                                            .update({
                                                          'likes': {
                                                            '${FirebaseAuth.instance.currentUser!.uid}':
                                                                true,
                                                          },
                                                          'likeCount':
                                                              (likeCount + 1)
                                                        });
                                                        showHeart = true;
                                                      });
                                                      setState(() {
                                                        Timer(
                                                            Duration(
                                                                milliseconds:
                                                                    300), () {
                                                          setState(() {
                                                            showHeart = false;
                                                          });
                                                        });
                                                      });
                                                    }
                                                  },
                                                  icon: snapshot.data.docs[index]
                                                                      .data()[
                                                                  'likes'][
                                                              FirebaseAuth
                                                                  .instance
                                                                  .currentUser!
                                                                  .uid] ==
                                                          true
                                                      ? Icon(Icons.favorite,
                                                          color: Colors.red)
                                                      : Icon(Icons
                                                          .favorite_border)),
                                              IconButton(
                                                  onPressed: () {
                                                    navigateToPage(
                                                        context,
                                                        CommentScreen(
                                                          postImage: snapshot
                                                                  .data
                                                                  .docs[index]
                                                                  .data()[
                                                              'postImage'],
                                                          userUid: snapshot1
                                                              .data['userUid'],
                                                          name: snapshot1
                                                              .data['name'],
                                                          photo: snapshot1
                                                              .data['image'],
                                                          postUid:
                                                              '${snapshot.data.docs[index].data()['postUid']}',
                                                        ));
                                                  },
                                                  icon: FaIcon(FontAwesomeIcons
                                                      .commentDots)),
                                              IconButton(
                                                  onPressed: () {},
                                                  icon: FaIcon(
                                                      FontAwesomeIcons.share)),
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
                                return Center(
                                    child: CircularProgressIndicator());
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
              )
          ],
        ),
      ),
    );
  }

  StreamBuilder deleteFeed(AsyncSnapshot<dynamic> snapshot, int index) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('feeds')
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot2)   {
        if (snapshot2.hasData && snapshot2.data.docs.length > 0) {
          for (int i = 0; i < snapshot2.data.docs.length; i++) {
            print(snapshot2.data.docs.length.toString());
            if (snapshot2.data.docs[i].data()['postUid'] ==
                snapshot.data.docs[index].data()['postUid']) print(true);
              FirebaseFirestore.instance
                .collection('users')
                .doc(FirebaseAuth.instance.currentUser!.uid)
                .collection('feeds')
                .doc(snapshot2.data.docs[i])
                .delete()
                .then((value) => print('deleted'));
          }
          return Text("");
        }
        return Text("");
      },
    );
  }

  FutureBuilder<QuerySnapshot<Map<String, dynamic>>> buildGridViewData(
      double height) {
    return FutureBuilder(
      builder: (context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          return Container(
            height: height * 0.5,
            child: GridView.builder(
                itemCount: snapshot.data.docs.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 5,
                    crossAxisSpacing: 5,
                    childAspectRatio: 1),
                itemBuilder: (context, index) {
                  return GestureDetector(
                    child: Image.network(
                      snapshot.data.docs[index].data()['postImage'],
                      fit: BoxFit.fill,
                    ),
                    onTap: () {
                      navigateToPage(
                          context,
                          ShowPostScreen(
                            userUid: snapshot.data.docs[index].data()['uid'],
                            postUid:
                                snapshot.data.docs[index].data()['postUid'],
                          ));
                    },
                  );
                }),
          );
        } else
          return Center(child: Text(""));
      },
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('posts')
          .get(),
    );
  }

  Row buildToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        buildViewIcon(
          icon: Icon(Icons.list),
          value: true,
        ),
        buildViewIcon(
          icon: Icon(Icons.border_all_outlined),
          value: false,
        ),
      ],
    );
  }

  StreamBuilder<DocumentSnapshot<Map<String, dynamic>>> buildUserBio() {
    return StreamBuilder(
      builder: (context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                snapshot.data['name'],
                style: bigTextStyle(),
              ),
              SizedBox(height: 10),
              Text(snapshot.data['bio'], style: mediumTextStyle()),
            ],
          );
        } else
          return Text("Loading");
      },
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .snapshots(),
    );
  }

  Row buildRowUserData(double width, double height, BuildContext context) {
    return Row(
      children: [
        StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .snapshots(),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.hasData) {
              return Container(
                width: 90,
                height: 90,
                child: Center(
                  child: CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(
                      snapshot.data['image'],
                    ),
                  ),
                ),
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient:
                        LinearGradient(colors: [Colors.red, Colors.orange])),
              );
            }
            return Text('Loading...');
          },
        ),
        Column(
          children: [
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .collection('posts')
                  .snapshots(),
              builder: (context, AsyncSnapshot<dynamic> snapshot) {
                if (snapshot.hasData)
                  return Container(
                    width: width * 0.7,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(
                          width: width * 0.03,
                        ),
                        Column(
                          children: [
                            Text("${snapshot.data!.docs.length}",
                                style: mediumTextStyle()),
                            Text(
                              'Posts',
                              style: mediumTextStyle(),
                            ),
                          ],
                        ),
                        SizedBox(
                          width: width * 0.03,
                        ),
                        Column(
                          children: [
                            Text(
                              Provider.of<FollowingProvider>(context)
                                  .followersCount
                                  .toString(),
                              style: mediumTextStyle(),
                            ),
                            Text(
                              'Followers',
                              style: mediumTextStyle(),
                            ),
                          ],
                        ),
                        SizedBox(
                          width: width * 0.03,
                        ),
                        Column(
                          children: [
                            Text(
                              Provider.of<FollowingProvider>(context)
                                  .followingCount
                                  .toString(),
                              style: mediumTextStyle(),
                            ),
                            Text(
                              'Following',
                              style: mediumTextStyle(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                return Center(child: CircularProgressIndicator());
              },
            ),
            SizedBox(height: 5),
            InkWell(
              child: Card(
                color: Colors.blue,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: Row(
                  children: [
                    SizedBox(
                      width: 14,
                    ),
                    FaIcon(FontAwesomeIcons.userEdit),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      'Edit Profile Page',
                      style: bigTextStyle(),
                    ),
                    SizedBox(
                      width: 14,
                    ),
                  ],
                ),
              ),
              onTap: () {
                navigateToPage(context, UpdateUserDataScreen());
              },
            )
          ],
        )
      ],
    );
  }

  AppBar customAppBar() {
    return AppBar(
      title: Text(
        "Profile Page",
        style: hugeTextStyle(),
      ),
      centerTitle: true,
      elevation: 4,
      backgroundColor: Colors.grey[50],
    );
  }

  IconButton buildViewIcon({required bool value, required Icon icon}) {
    return IconButton(
      icon: (icon),
      color: this.toggleGridOrList != value ? Colors.blue : Colors.black,
      onPressed: () {
        setState(() {
          if (value == true) {
            toggleGridOrList = false;
            print(value);
          } else if (value == false) {
            toggleGridOrList = true;
            print(value);
          }
        });
      },
    );
  }
}
