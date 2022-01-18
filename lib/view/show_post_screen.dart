import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app/shared/constants.dart';
import 'package:firebase_app/shared/functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import 'comments_screen.dart';

class ShowPostScreen extends StatefulWidget {
  final String postUid;
  final String userUid;

  ShowPostScreen({required this.postUid, required this.userUid});

  @override
  _ShowPostScreenState createState() => _ShowPostScreenState();
}

class _ShowPostScreenState extends State<ShowPostScreen> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        centerTitle: true,
        elevation: 0,
        title: Text(
          'Post Details',
          style: bigTextStyle(),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: width * 0.02),
        child: FutureBuilder(
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.hasData)
              return ListView(
                children: [
                  SizedBox(
                    height: height * 0.03,
                  ),
                  Text(
                    snapshot.data['location'],
                    style: mediumTextStyle(color: Colors.grey),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    width: width,
                    height: height * 0.5  ,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: NetworkImage(snapshot.data['postImage']),
                            fit: BoxFit.fill)),
                  ),
                  Align(
                    child: snapshot.data['likeCount'] == 0
                        ? Text(
                      "Be first one to like this post",
                      style: mediumTextStyle(),
                    )
                        : Text(
                      "${snapshot.data['likeCount']}  Likes",
                      style: mediumTextStyle(),
                    ),
                    alignment: Alignment.centerLeft,
                  ),
                  SizedBox(height: 10,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        snapshot.data['caption'],
                        style: mediumTextStyle(),
                      ),
                      Text(getFormattedDate(snapshot.data['dateTime']))
                    ],
                  ),


                  FutureBuilder(
                    builder: (BuildContext context,
                        AsyncSnapshot<dynamic> snapshot1) {
                      int likeCount = snapshot.data['likeCount'];
                      print(likeCount);

                      if (snapshot1.hasData)
                        return Row(
                          children: [
                            IconButton(
                                onPressed: () async {
                                  Timestamp feedUid = Timestamp.now();

                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(widget.userUid)
                                      .collection('feeds')
                                      .doc(feedUid.toString())
                                      .set({
                                        'feedUid': feedUid.toString(),
                                        'postUid': snapshot.data['postUid'],
                                        'feedType': 'like',
                                        'userUid': FirebaseAuth
                                            .instance.currentUser!.uid,
                                        'dateTime': DateTime.now(),
                                        'name': snapshot1.data['name'],
                                        'image': snapshot1.data['image'],
                                        'postImage': snapshot.data['postImage']
                                      })
                                      .then((value) => print('feed added'))
                                      .catchError((error) {
                                        print(error);
                                      });

                                  if (snapshot.data['likes'][FirebaseAuth
                                          .instance.currentUser!.uid] ==
                                      true) {
                                    setState(() {
                                      FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(widget.userUid)
                                          .collection('posts')
                                          .doc(widget.postUid)
                                          .update({
                                        'likes': {
                                          '${FirebaseAuth.instance.currentUser!.uid}':
                                              false,
                                        },
                                        'likeCount': (likeCount - 1),
                                      });
                                    });
                                  } else {
                                    setState(() {
                                      FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(widget.userUid)
                                          .collection('posts')
                                          .doc(widget.postUid)
                                          .update({
                                        'likes': {
                                          '${FirebaseAuth.instance.currentUser!.uid}':
                                              true,
                                        },
                                        'likeCount': (likeCount + 1),
                                      });
                                    });
                                  }
                                },
                                icon: snapshot.data['likes'][FirebaseAuth
                                            .instance.currentUser!.uid] ==
                                        true
                                    ? Icon(Icons.favorite, color: Colors.red)
                                    : Icon(Icons.favorite_border)),
                            IconButton(
                                onPressed: () {
                                  navigateToPage(
                                      context,
                                      CommentScreen(
                                        postImage: snapshot.data['postImage'],
                                        userUid: widget.userUid,
                                        name: snapshot1.data['name'],
                                        photo: snapshot1.data['image'],
                                        postUid: widget.postUid,
                                      ));
                                },
                                icon:FaIcon(FontAwesomeIcons.commentDots)),
                            IconButton(
                                onPressed: () {}, icon: FaIcon(FontAwesomeIcons.share)),
                          ],
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        );
                      else
                        return Center(child: Text("Loading"));
                    },
                    future: FirebaseFirestore.instance
                        .collection('users')
                        .doc(FirebaseAuth.instance.currentUser!.uid)
                        .get(),
                  ),
                ],
              );
            else
              return Center(child: CircularProgressIndicator());
          },
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(widget.userUid)
              .collection('posts')
              .doc(widget.postUid)
              .get(),
        ),
      ),
    );
  }
}
