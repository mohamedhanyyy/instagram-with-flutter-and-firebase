import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app/shared/constants.dart';
import 'package:firebase_app/shared/functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CommentScreen extends StatefulWidget {
  final String postUid;
  final String photo;
  final String name;
  final String userUid;
  final String postImage;

  CommentScreen(
      {required this.postUid,
      required this.photo,
      required this.name,
      required this.userUid,
      required this.postImage});

  @override
  _CommentScreenState createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  TextEditingController commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(
            color: Colors.black
          ),
          title: Text("Comments",style: bigTextStyle(),),
          centerTitle: true,

        ),
        body: ListView(
          children: [
            StreamBuilder(
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                if (snapshot.hasData) {
                  return Container(
                    height: height * 0.8,
                    width: width,
                    child: ListView.builder(
                      itemBuilder: (context, index) {
                        return FutureBuilder(
                          builder: (BuildContext context,
                              AsyncSnapshot<dynamic> snapshot1) {
                            Timestamp timeStamp =
                                snapshot.data.docs[index].data()['dateTime'];
                            if (snapshot1.hasData)
                              return ListTile(
                                  trailing: Text(getFormattedDate(timeStamp)),
                                  leading: CircleAvatar(
                                      backgroundImage: NetworkImage(
                                          '${snapshot1.data['image']}')),
                                  subtitle: Text(snapshot.data.docs[index]
                                      .data()['comment']),
                                  title: Text(snapshot1.data['name']));

                            return Text("Loading...");
                          },
                          future: FirebaseFirestore.instance
                              .collection('users')
                              .doc(snapshot.data.docs[index].data()['userUid'])
                              .get(),
                        );
                      },
                      itemCount: snapshot.data.docs.length,
                    ),
                  );
                }
                return Center(
                  child: Text("Loading..."),
                );
              },
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(widget.userUid)
                  .collection('posts')
                  .doc(widget.postUid)
                  .collection('comments')
                  .orderBy('dateTime', descending: false)
                  .snapshots(),
            ),
             TextField(
              controller: commentController,
              decoration: InputDecoration(
                  hintText: 'Write a Comment...',
                  suffixIcon: IconButton(
                    icon: Icon(
                      Icons.send,
                      color: Colors.black,
                    ),
                    onPressed: () async {
                      String commentUid = Timestamp.now().toString();

                    if(widget.userUid!=FirebaseAuth.instance.currentUser!.uid)
                      {
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(widget.userUid)
                            .collection('feeds')
                            .doc(commentUid)
                            .set({
                          'feedUid': commentUid.toString(),
                          'postUid': widget.postUid,
                          'feedType': 'comment',
                          'userUid': FirebaseAuth.instance.currentUser!.uid,
                          'dateTime': DateTime.now(),
                          'name': widget.name,
                          'image': widget.photo,
                          'postImage': widget.postImage,
                          'comment': '${commentController.text}',

                        })
                            .then((value) => print('feed added'))
                            .catchError((error) {
                          print(error);
                        });
                      }

                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(widget.userUid)
                          .collection('posts')
                          .doc(widget.postUid)
                          .collection('comments')
                          .doc(commentUid)
                          .set({
                        'comment': '${commentController.text}',
                        'dateTime': DateTime.now(),
                        'commentUid': commentUid,
                        'userUid': FirebaseAuth.instance.currentUser!.uid,
                        'postUid': widget.postUid,
                      }).then((value) {
                        print('comment done');
                        setState(() {
                          commentController.clear();
                        });
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(0),
                  )),
            ),
          ],
        ));
  }

}
