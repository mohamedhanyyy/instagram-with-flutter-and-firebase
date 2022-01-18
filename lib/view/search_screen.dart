import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app/shared/constants.dart';
import 'package:firebase_app/shared/functions.dart';
import 'package:firebase_app/view/search_user_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: width * 0.1),
        child: ListView(
          children: [
            SizedBox(height: height * 0.07),
            TextFormField(

              decoration: InputDecoration(
                focusedBorder:
                outlineBorder(),
                  prefixIcon: Icon(Icons.search,color: Colors.black,),
                  suffixIcon: IconButton(
                      icon: Icon(Icons.clear,color: Colors.black,),
                      onPressed: () {
                        setState(() {
                          controller.clear();
                        });
                      }),
                  hintText: 'Search for user..',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15))),
              controller: controller,
              onFieldSubmitted: (value) {
                setState(() {
                  controller.text = value;
                });
              },
            ),
            FutureBuilder(
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                if (snapshot.hasData ) {

                  if( snapshot.data.docs.length>0)
                  return Container(
                      height: height * 0.7,
                      child: ListView.builder(
                        itemBuilder: (context, index) {
                          print(FirebaseFirestore.instance
                              .collection('users')
                              .doc());
                          if(snapshot.data.docs[index].data()['userUid']!=FirebaseAuth.instance.currentUser!.uid)
                          return ListTile(
                            onTap: () {
                              navigateToPage(
                                context,
                                SearchUserScreen(
                                    image: snapshot.data.docs[index]
                                        .data()['image'],
                                    name: snapshot.data.docs[index]
                                        .data()['name'],
                                    userUid: snapshot.data.docs[index]
                                        .data()['userUid'],
                                    bio: snapshot.data.docs[index]
                                        .data()['bio']),
                              );

                             },
                            title:
                                Text(snapshot.data.docs[index].data()['name']),
                            leading:
                                snapshot.data.docs[index].data()['image'] == ""
                                    ? Icon(Icons.person)
                                    : CircleAvatar(
                                        backgroundImage: NetworkImage(snapshot
                                            .data.docs[index]
                                            .data()['image']),
                                      ),
                          );
                          else
                            return Text('');
                        },
                        itemCount: snapshot.data.docs.length,
                      ));


                  else if( snapshot.data.docs.length==0 && controller.text.isNotEmpty)
                    return
                      Padding(
                        padding: EdgeInsets.only(top: height*0.2),
                        child: Align(child:Text("No result found !"
                            "",style: bigTextStyle(),),alignment: Alignment.center,),
                      );

                }
                return Text("");
              },
              future: FirebaseFirestore.instance
                  .collection('users')
                  .where(
                    'name',
                    isEqualTo: controller.text,

                  )

                  .get(),
            )
          ],
        ),
      ),
    );
  }
}
