import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app/providers/FollowingProvider.dart';
import 'package:firebase_app/shared/constants.dart';
import 'package:firebase_app/shared/functions.dart';
import 'package:firebase_app/view/show_post_screen.dart';
import 'package:firebase_app/widgets/unicorn_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'comments_screen.dart';
import 'messages_screen.dart';

class SearchUserScreen extends StatefulWidget {
  final String image;
  final String name;
  final String userUid;
  final String bio;

  SearchUserScreen(
      {required this.image,
      required this.name,
      required this.userUid,
      required this.bio});

  @override
  _SearchUserScreenState createState() => _SearchUserScreenState();
}

class _SearchUserScreenState extends State<SearchUserScreen> {
  bool inTheFollowing = false;

  bool toggleListOrGrid = false;

  @override
  void initState() {
    //TODO: implement initState
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      Provider.of<FollowingProvider>(context!, listen: false)
          .ifInTheFollowing(widget.userUid);
    });
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    Provider.of<FollowingProvider>(context, listen: false)
        .getFollowersCount(widget.userUid);
    Provider.of<FollowingProvider>(context, listen: false)
        .getFollowingCount(widget.userUid);

    return Scaffold(
      appBar: customAppBar(context),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: width * 0.03),
        child: ListView(
          children: [
            SizedBox(height: height * 0.02),
            buildRowUserData(width, height, context),
            buildUserBio(),
            SizedBox(height: 5),
            buildToggle(),
            SizedBox(height: 5),
            if (toggleListOrGrid == true) buildGridViewData(height),
            if (toggleListOrGrid == false)
              FutureBuilder(
                builder:
                    (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                  if (snapshot.hasData) {
                    return Container(
                      height: height * 0.5,
                      child: ListView.builder(
                        itemCount: snapshot.data.docs.length,
                        itemBuilder: (BuildContext context, index) {
                          return FutureBuilder(
                            builder: (BuildContext context,
                                AsyncSnapshot<dynamic> snapshot1) {
                              if (snapshot1.hasData)
                                return Column(
                                  children: [
                                    ListTile(
                                      leading: CircleAvatar(
                                        backgroundImage: NetworkImage(
                                          widget.image,
                                        ),
                                        radius: 30,
                                      ),
                                      title: Text(widget.name,
                                          style: mediumTextStyle(fontSize: 20)),
                                      subtitle: Text(snapshot.data.docs[index]
                                          .data()['location']),
                                    ),
                                    Image.network(
                                        snapshot.data.docs[index]
                                            .data()['postImage'],
                                        height: height * 0.4,
                                        width: width,
                                        fit: BoxFit.fill),
                                    Align(
                                      child: snapshot.data.docs[index]
                                                  .data()['likeCount'] ==
                                              0
                                          ? Text(
                                              "Be first one To like this post",
                                              style: mediumTextStyle(),
                                            )
                                          : Text(
                                              "${snapshot.data.docs[index].data()['likeCount']}  Likes",
                                              style: mediumTextStyle(),
                                            ),
                                      alignment: Alignment.centerLeft,
                                    ),
                                    SizedBox(height: 5),
                                    Align(
                                      child: Text(
                                        snapshot.data.docs[index]
                                            .data()['caption'],
                                        style: mediumTextStyle(),
                                      ),
                                      alignment: Alignment.centerLeft,
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                            onPressed: () async {
                                              Timestamp feedUid =
                                                  Timestamp.now();

                                              int likeCount = snapshot
                                                  .data.docs[index]
                                                  .data()['likeCount'];
                                              print(likeCount);

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
                                                      .doc(widget.userUid)
                                                      .collection('posts')
                                                      .doc(postUid)
                                                      .update({
                                                    'likes': {
                                                      '${FirebaseAuth.instance.currentUser!.uid}':
                                                          false,
                                                    },
                                                    'likeCount':
                                                        (likeCount - 1),
                                                  });
                                                });
                                              } else {
                                                await FirebaseFirestore.instance
                                                    .collection('users')
                                                    .doc(widget.userUid)
                                                    .collection('feeds')
                                                    .doc(feedUid.toString())
                                                    .set({
                                                      'feedUid':
                                                          feedUid.toString(),
                                                      'postUid': snapshot
                                                          .data.docs[index]
                                                          .data()['postUid'],
                                                      'feedType': 'like',
                                                      'userUid': FirebaseAuth
                                                          .instance
                                                          .currentUser!
                                                          .uid,
                                                      'dateTime':
                                                          DateTime.now(),
                                                      'name': snapshot1
                                                          .data['name'],
                                                      'image': snapshot1
                                                          .data['image'],
                                                      'postImage':
                                                          "${snapshot.data.docs[index].data()['postImage']}"
                                                    })
                                                    .then((value) =>
                                                        print('feed added'))
                                                    .catchError((error) {
                                                      print(error);
                                                    });

                                                await FirebaseFirestore.instance
                                                    .collection('users')
                                                    .doc(widget.userUid)
                                                    .collection('posts')
                                                    .doc(postUid)
                                                    .update({
                                                  'likes': {
                                                    '${FirebaseAuth.instance.currentUser!.uid}':
                                                        true,
                                                  },
                                                  'likeCount': (likeCount + 1),
                                                }).then((value) {
                                                  setState(() {});
                                                });
                                              }
                                            },
                                            icon: snapshot.data.docs[index]
                                                            .data()['likes'][
                                                        FirebaseAuth
                                                            .instance
                                                            .currentUser!
                                                            .uid] ==
                                                    true
                                                ? FaIcon(
                                                    FontAwesomeIcons.solidHeart,
                                                    color: Colors.red)
                                                : FaIcon(
                                                    FontAwesomeIcons.heart)),
                                        IconButton(
                                            onPressed: () {
                                              navigateToPage(
                                                  context,
                                                  CommentScreen(
                                                    postImage: snapshot
                                                        .data.docs[index]
                                                        .data()['postImage'],
                                                    userUid: widget.userUid,
                                                    name:
                                                        snapshot1.data['name'],
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
                                            icon:
                                                FaIcon(FontAwesomeIcons.share)),
                                      ],
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                    ),
                                  ],
                                );
                              else
                                return Center(
                                    child: CircularProgressIndicator());
                            },
                            future: FirebaseFirestore.instance
                                .collection('users')
                                .doc(FirebaseAuth.instance.currentUser!.uid)
                                .get(),
                          );
                        },
                      ),
                    );
                  } else
                    return Center(child: CircularProgressIndicator());
                },
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(widget.userUid)
                    .collection('posts')
                    .get(),
              )
          ],
        ),
      ),
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
          return Center(child: CircularProgressIndicator());
      },
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userUid)
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

  FutureBuilder<DocumentSnapshot<Map<String, dynamic>>> buildUserBio() {
    return FutureBuilder(
      builder: (context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.name,
                style: bigTextStyle(),
              ),
              SizedBox(height: 10),
              Text(widget.bio, style: mediumTextStyle()),
            ],
          );
        } else
          return Text("Loading");
      },
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userUid)
          .get(),
    );
  }

  Row buildRowUserData(double width, double height, BuildContext context) {
    return Row(
      children: [
        FutureBuilder(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(widget.userUid)
              .get(),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.hasData) {
              return ClipOval(
                clipBehavior: Clip.antiAlias,
                child: Container(
                  child: Padding(
                    padding: EdgeInsets.all(3.0), //width of the border
                    child: ClipOval(
                      clipBehavior: Clip.antiAlias,
                      child: Container(
                        width: 80.0,
                        height: 80.0,
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(
                            widget.image,
                          ),
                          radius: 10,
                        ),
                        decoration: kInnerDecoration,
                      ),
                    ),
                  ),
                  decoration: kGradientBoxDecoration,
                ),
              );
            }
            return Text('Loading...');
          },
        ),
        Column(
          children: [
            FutureBuilder(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(widget.userUid)
                  .collection('posts')
                  .get(),
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
            SizedBox(height: height * 0.03),
            InkWell(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.blue,
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 14,
                    ),
                    StreamBuilder(
                      builder: (context, AsyncSnapshot<dynamic> snapshot1) {
                        if (snapshot1.hasData) {
                          return InkWell(
                              child: Provider.of<FollowingProvider>(context)
                                          .isFollowing ==
                                      true
                                  ? Text(
                                      'Unfollow',
                                      style: bigTextStyle(
                                          color: Provider.of<FollowingProvider>(
                                                          context)
                                                      .isFollowing ==
                                                  false
                                              ? Colors.black
                                              : Colors.white),
                                    )
                                  : Text(
                                      'Follow',
                                      style: bigTextStyle(),
                                    ),
                              onTap: () async {
                                if (Provider.of<FollowingProvider>(context,
                                        listen: false)
                                    .isFollowing) {
                                  Provider.of<FollowingProvider>(context,
                                          listen: false)
                                      .changeButton(false);

                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(FirebaseAuth
                                          .instance.currentUser!.uid)
                                      .collection('following')
                                      .doc(widget.userUid)
                                      .delete()
                                      .then((value) =>
                                          print("removed from following"));

                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(widget.userUid)
                                      .collection('followers')
                                      .doc(FirebaseAuth
                                          .instance.currentUser!.uid)
                                      .delete()
                                      .then((value) {
                                    print("removed from followers");
                                    setState(() {
                                      inTheFollowing = false;
                                    });
                                  });
                                } else {
                                  // TODO We will follow
                                  Provider.of<FollowingProvider>(context,
                                          listen: false)
                                      .changeButton(true);

                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(FirebaseAuth
                                          .instance.currentUser!.uid)
                                      .collection('following')
                                      .doc(widget.userUid)
                                      .set({
                                    'userUid':
                                        FirebaseAuth.instance.currentUser!.uid,
                                    'following': true,
                                  }).then((value) =>
                                          print("added to following"));

                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(widget.userUid)
                                      .collection('followers')
                                      .doc(FirebaseAuth
                                          .instance.currentUser!.uid)
                                      .set({
                                    'userUid':
                                        FirebaseAuth.instance.currentUser!.uid,
                                    'follower': true,
                                  }).then((value) {
                                    print("added to followers");
                                    setState(() {
                                      inTheFollowing = true;
                                    });
                                  });
                                }
                              });
                        } else
                          return Text('Loading');
                      },
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .collection('following')
                          .snapshots(),
                    ),
                    SizedBox(
                      width: 14,
                    ),
                  ],
                ),
              ),
            )
          ],
        )
      ],
    );
  }

  AppBar customAppBar(context) {
    return AppBar(
      iconTheme: IconThemeData(color: Colors.black),
      title: Text(
        "${widget.name}",
        style: hugeTextStyle(),
      ),
      centerTitle: true,
      elevation: 4,
      backgroundColor: Colors.grey[50],
      actions: [
        IconButton(
            onPressed: () {
              navigateToPage(
                  context,
                  MessageScreen(
                      image: widget.image,
                      name: widget.name,
                      userUid: widget.userUid,
                      bio: widget.bio));
            },
            icon: FaIcon(
              FontAwesomeIcons.facebookMessenger,
              color: Colors.blue,
            ))
      ],
    );
  }

  IconButton buildViewIcon({required bool value, required Icon icon}) {
    return IconButton(
      icon: (icon),
      color: this.toggleListOrGrid != value ? Colors.blue : Colors.black,
      onPressed: () {
        setState(() {
          if (value == true) {
            toggleListOrGrid = false;
            print(value);
          } else if (value == false) {
            toggleListOrGrid = true;
            print(value);
          }
        });
      },
    );
  }
}
