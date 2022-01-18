import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app/shared/constants.dart';
import 'package:firebase_app/shared/functions.dart';
import 'package:firebase_app/view/messages_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Messenger extends StatefulWidget {
  @override
  _MessengerState createState() => _MessengerState();
}

class _MessengerState extends State<Messenger> {
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Messenger",
          style: bigTextStyle(color: Colors.black),
        ),
      ),
      body: FutureBuilder(
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData)
            return Container(
              height: height,
              width: width,
              child: ListView.builder(
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return FutureBuilder(
                    builder: (BuildContext context,
                        AsyncSnapshot<dynamic> snapshot1) {
                      Timestamp timeStamp =
                          snapshot.data.docs[index].data()['dateTime'];
                      if (snapshot1.hasData)
                        {

                          if(snapshot.data.docs[index].data()['dateTime']!=null && snapshot.data.docs[index].data()['message']!=null && snapshot.data.docs[index].data()['sender']!=null && snapshot.data.docs[index].data()['userUid']!=null  )
                            {
                              return Container(
                                  width: width,
                                  child: ListTile(
                                    onTap: () {
                                      navigateToPage(
                                          context,
                                          MessageScreen(
                                              image: snapshot1.data['image'],
                                              name: snapshot1.data['name'],
                                              userUid: snapshot1.data['userUid'],
                                              bio: snapshot1.data['bio']));
                                    },
                                    leading: CircleAvatar(
                                      radius: 30,
                                      backgroundImage:
                                      NetworkImage(snapshot1.data['image']),
                                    ),
                                    title: Text(snapshot1.data['name']),
                                    subtitle: snapshot.data.docs[index]
                                        .data()['sender'] ==
                                        FirebaseAuth.instance.currentUser!.uid
                                        ? Text(
                                        "You : ${snapshot.data.docs[index].data()['message']}")
                                        : Text(
                                        "${snapshot1.data['name']} ${snapshot.data.docs[index].data()['message']}"),
                                    trailing:
                                    Text(getFormattedDate(timeStamp).toString()),
                                  ));
                            }
                          else
                            {
                              return Text("");
                            }
                        }
                      else
                        return Text("");
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
          else
            return Text("");
        },
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('messages')
            .orderBy('dateTime', descending: true)
            .get(),
      ),
    );
  }
}
