import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app/shared/constants.dart';
import 'package:firebase_app/shared/functions.dart';
import 'package:firebase_app/view/search_user_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MessageScreen extends StatefulWidget {
  final String image;
  final String name;
  final String userUid;
  final String bio;

  const MessageScreen(
      {Key? key,
      required this.image,
      required this.name,
      required this.userUid,
      required this.bio})
      : super(key: key);

  @override
  _MessageScreenState createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  TextEditingController messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.black),
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(widget.image),
                radius: 17,
              ),
              SizedBox(
                width: 10,
              ),
              Text(
                widget.name,
                style: bigTextStyle(),
              ),
            ],
          ),
          centerTitle: true,
          actions: [
            PopupMenuButton(
                itemBuilder: (context) => [
                      PopupMenuItem(
                          child: GestureDetector(
                        child: Text("View Profile"),
                        onTap: () {
                          navigateToPage(
                            context,
                            SearchUserScreen(
                                image: widget.image,
                                name: widget.name,
                                userUid: widget.userUid,
                                bio: widget.bio),
                          );
                        },
                      )),
                    ])
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                builder:
                    (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                  if (snapshot.hasData) {
                    return Container(
                        width: width,
                        child: ListView.builder(
                            reverse: true,
                            itemCount: snapshot.data.docs.length,
                            itemBuilder: (BuildContext context, int index) {
                              return snapshot.data.docs[index]
                                          .data()['sender'] ==
                                      FirebaseAuth.instance.currentUser!.uid
                                  ? Align(
                                      alignment: Alignment.topLeft,
                                      child: GestureDetector(
                                          child: Card(
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(15)),
                                            child: Text(
                                              '  ${snapshot.data.docs[index].data()['message']}  ',
                                              style: bigTextStyle(),
                                            ),
                                            color: Colors.blue,
                                          ),
                                          onLongPress: () async {
                                            showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    AlertDialog(
                                                        backgroundColor:
                                                            Colors.white,
                                                        title: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Text(
                                                              "Delete message",
                                                              style:
                                                                  mediumTextStyle(),
                                                            ),
                                                            GestureDetector(
                                                              onTap: () {
                                                                Navigator.pop(
                                                                    context);
                                                              },
                                                              child: Icon(
                                                                Icons.close,
                                                                size: 30,
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(15),
                                                        ),
                                                        elevation: 4,
                                                        content: Container(
                                                            height:
                                                                height * 0.1,
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              children: [
                                                                InkWell(
                                                                    child: Text(
                                                                        "Delete for me"),
                                                                    onTap:
                                                                        () async {
                                                                      Navigator.pop(
                                                                          context);

                                                                      await FirebaseFirestore
                                                                          .instance
                                                                          .collection(
                                                                              'users')
                                                                          .doc(FirebaseAuth
                                                                              .instance
                                                                              .currentUser!
                                                                              .uid)
                                                                          .collection(
                                                                              'messages')
                                                                          .doc(widget
                                                                              .userUid)
                                                                          .collection(
                                                                              'messages')
                                                                          .doc(snapshot
                                                                              .data
                                                                              .docs[
                                                                                  index]
                                                                              .data()[
                                                                                  'messageUid']
                                                                              .toString())
                                                                          .update({
                                                                        'message':
                                                                            'Deleted message'
                                                                      });
                                                                    }),
                                                                SizedBox(
                                                                    height: 15),
                                                                InkWell(
                                                                  child: Text(
                                                                      "Delete for every one"),
                                                                  onTap:
                                                                      () async {
                                                                    Navigator.pop(
                                                                        context);
                                                                    await FirebaseFirestore
                                                                        .instance
                                                                        .collection(
                                                                            'users')
                                                                        .doc(widget
                                                                            .userUid)
                                                                        .collection(
                                                                            'messages')
                                                                        .doc(FirebaseAuth
                                                                            .instance
                                                                            .currentUser!
                                                                            .uid)
                                                                        .collection(
                                                                            'messages')
                                                                        .doc(snapshot
                                                                            .data
                                                                            .docs[
                                                                                index]
                                                                            .data()[
                                                                                'messageUid']
                                                                            .toString())
                                                                        .update({
                                                                      'message':
                                                                          'Deleted message'
                                                                    }).then((value) =>
                                                                            print('message Deleted for me'));

                                                                    await FirebaseFirestore
                                                                        .instance
                                                                        .collection(
                                                                            'users')
                                                                        .doc(FirebaseAuth
                                                                            .instance
                                                                            .currentUser!
                                                                            .uid)
                                                                        .collection(
                                                                            'messages')
                                                                        .doc(widget
                                                                            .userUid)
                                                                        .collection(
                                                                            'messages')
                                                                        .doc(snapshot
                                                                            .data
                                                                            .docs[
                                                                                index]
                                                                            .data()[
                                                                                'messageUid']
                                                                            .toString())
                                                                        .update({
                                                                      'message':
                                                                          'Deleted message'
                                                                    }).then((value) {
                                                                      print(
                                                                          'message Deleted for me');
                                                                    });
                                                                  },
                                                                ),
                                                              ],
                                                            ))));
                                          }))
                                  : Align(
                                      alignment: Alignment.topRight,
                                      child: Card(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(15)),
                                        child: Text(
                                          '  ${snapshot.data.docs[index].data()['message']}  ',
                                          style: bigTextStyle(),
                                        ),
                                        color: Colors.grey,
                                      ),
                                    );
                            }));
                  }
                  return Center(
                    child: Text("Loading..."),
                  );
                },
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .collection('messages')
                    .doc(widget.userUid)
                    .collection('messages')
                    .orderBy('dateTime', descending: true)
                    .snapshots(),
              ),
            ),
            TextField(
              controller: messageController,
              style: mediumTextStyle(),
              decoration: InputDecoration(
                  hintText: 'Write a Message...',
                  labelText: 'Message',
                  suffixIcon: IconButton(
                    icon: Icon(
                      Icons.send,
                      color: Colors.black,
                    ),
                    onPressed: () async {
                      if (messageController.text.isNotEmpty) {
                        String data = messageController.text;
                        Timestamp messageUid = Timestamp.now();

                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(FirebaseAuth.instance.currentUser!.uid)
                            .collection('messages')
                            .doc(widget.userUid)
                            .set({
                          'dateTime': DateTime.now(),
                          'userUid': widget.userUid,
                          'message': messageController.text,
                          'sender': FirebaseAuth.instance.currentUser!.uid,
                        });
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(widget.userUid)
                            .collection('messages')
                            .doc(FirebaseAuth.instance.currentUser!.uid)
                            .set({
                          'dateTime': messageUid,
                          'userUid': FirebaseAuth.instance.currentUser!.uid,
                          'sender': FirebaseAuth.instance.currentUser!.uid,
                          'message': data,
                        });
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(FirebaseAuth.instance.currentUser!.uid)
                            .collection('messages')
                            .doc(widget.userUid)
                            .collection('messages')
                            .doc(messageUid.toString())
                            .set({
                          'message': data,
                          'dateTime': DateTime.now(),
                          'sender': FirebaseAuth.instance.currentUser!.uid,
                          'isText': true,
                          'messageTo': widget.userUid,
                          'messageUid': messageUid,
                        }).then((value) {
                          setState(() {
                            messageController.clear();
                          });
                        });

                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(widget.userUid)
                            .collection('messages')
                            .doc(FirebaseAuth.instance.currentUser!.uid)
                            .collection('messages')
                            .doc(messageUid.toString())
                            .set({
                          'message': data,
                          'dateTime': DateTime.now(),
                          'sender': FirebaseAuth.instance.currentUser!.uid,
                          'isText': true,
                          'messageTo': widget.userUid,
                          'messageUid': messageUid,
                        }).then((value) {
                          setState(() {
                            messageController.clear();
                          });
                        });
                      }
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(0),
                  )),
            )
          ],
        ));
  }
}
