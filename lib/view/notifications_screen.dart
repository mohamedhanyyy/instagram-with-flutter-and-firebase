import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app/shared/constants.dart';
import 'package:firebase_app/shared/functions.dart';
import 'package:firebase_app/view/show_post_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        elevation: 4,
        centerTitle: true,
        title: Text(
          'Activity feed',
          style: bigTextStyle(),
        ),
        backgroundColor: Colors.white,
      ),
      body: FutureBuilder(
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData) {
            return Container(
              height: height,
              width: width,
              child: ListView.builder(
                itemBuilder: (BuildContext context, int index) {
                  Timestamp timeStamp =
                      snapshot.data.docs[index].data()['dateTime'];

                  return Container(
                      width: 100,
                      height: 100,
                      child: snapshot.data.docs[index].data()['feedType'] ==
                              'like'
                          ? Dismissible(
                              background: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: Colors.red,
                                ),
                                child: Icon(
                                  Icons.restore_from_trash,
                                  color: Colors.black,
                                ),
                              ),
                              onDismissed: (val) async {
                                await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(FirebaseAuth.instance.currentUser!.uid)
                                    .collection('feeds')
                                    .doc(snapshot.data.docs[index]
                                        .data()['feedUid'])
                                    .delete()
                                    .then((value) {
                                  setState(() {});

                                  print('feed deleted');
                                });
                              },
                              key: Key('item ${snapshot}'),
                              child: ListTile(
                                onTap: () {
                                  navigateToPage(
                                      context,
                                      ShowPostScreen(
                                        userUid: FirebaseAuth
                                            .instance.currentUser!.uid,
                                        postUid: snapshot.data.docs[index]
                                            .data()['postUid'],
                                      ));
                                },
                                trailing: Image.network(snapshot
                                    .data.docs[index]
                                    .data()['postImage']),
                                subtitle: Text(
                                    getFormattedDate(timeStamp).toString()),
                                leading: CircleAvatar(
                                  radius: 30,
                                  backgroundImage: NetworkImage(snapshot
                                      .data.docs[index]
                                      .data()['image']),
                                ),
                                title: Text(
                                    '${snapshot.data.docs[index].data()['name']} liked your post'),
                              ))
                          : Dismissible(
                              background: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: Colors.red,
                                ),
                                child: Icon(
                                  Icons.restore_from_trash,
                                  color: Colors.black,
                                ),
                              ),
                              onDismissed: (val) async {
                                await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(FirebaseAuth.instance.currentUser!.uid)
                                    .collection('feeds')
                                    .doc(snapshot.data.docs[index]
                                        .data()['feedUid'])
                                    .delete()
                                    .then((value) {
                                  setState(() {});

                                  print('feed deleted');
                                });
                              },
                              key: Key('item ${snapshot}'),
                              child: ListTile(
                                onTap: () {
                                  navigateToPage(
                                      context,
                                      ShowPostScreen(
                                        userUid: FirebaseAuth
                                            .instance.currentUser!.uid,
                                        postUid: snapshot.data.docs[index]
                                            .data()['postUid'],
                                      ));
                                },
                                trailing: Image.network(snapshot
                                    .data.docs[index]
                                    .data()['postImage']),
                                subtitle: Text(getFormattedDate(timeStamp)),
                                leading: CircleAvatar(
                                  radius: 30,
                                  backgroundImage: NetworkImage(snapshot
                                      .data.docs[index]
                                      .data()['image']),
                                ),
                                title: Text(
                                    '${snapshot.data.docs[index].data()['name']} commented on your post ${snapshot.data.docs[index].data()['comment']}'),
                              )));
                },
                itemCount: snapshot.data.docs.length,
              ),
            );
          } else
            return Center(
                child: CircularProgressIndicator(
              backgroundColor: Colors.black,
            ));
        },
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('feeds').orderBy('dateTime',descending: true)
            .get(),
      ),
    );
  }
}
