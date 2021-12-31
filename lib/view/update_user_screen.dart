import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app/shared/constants.dart';
import 'package:firebase_app/shared/functions.dart';
import 'package:firebase_app/shared/variables.dart';
import 'package:firebase_app/view/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path/path.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UpdateUserDataScreen extends StatefulWidget {
  const UpdateUserDataScreen({Key? key}) : super(key: key);

  @override
  _UpdateUserDataScreenState createState() => _UpdateUserDataScreenState();
}

class _UpdateUserDataScreenState extends State<UpdateUserDataScreen> {
  ImagePicker picker = ImagePicker();
  String? imageUrl;
  var updatedPhoto;
  bool photoIsUploading = false;

  TextEditingController editBioController = TextEditingController();
  TextEditingController editNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text('Update User Profile', style: bigTextStyle()),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: width * 0.1),
        child: Column(
          children: [
            Expanded(
                child: Container(
              child: FutureBuilder(
                builder: (context, AsyncSnapshot<dynamic> snapshot) {
                  if (snapshot.hasData) {
                    return ListView(
                      children: [
                        SizedBox(height: height * 0.05),
                        Center(
                          child: Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              CircleAvatar(
                                backgroundImage: snapshot.data['image'] == ""
                                    ? NetworkImage(
                                        'https://image.freepik.com/free-vector/person-avatar-design_24877-38137.jpg')
                                    : NetworkImage(
                                        snapshot.data['image'],
                                      ),
                                radius: 70,
                              ),
                              GestureDetector(
                                child: Icon(
                                  Icons.add,
                                  size: 30,
                                  color: Colors.black,
                                ),
                                onTap: () async {
                                  updatedPhoto = (await picker.pickImage(
                                      source: ImageSource.camera));
                                  setState(() {
                                    photoIsUploading = true;
                                  });

                                  String imageName =
                                      basename(updatedPhoto!.path);
                                  var refStorage = FirebaseStorage.instance
                                      .ref('posts')
                                      .child(imageName);

                                  await refStorage
                                      .putFile(File(updatedPhoto!.path));

                                  imageUrl = await refStorage.getDownloadURL();
                                  await FirebaseFirestore.instance
                                      .collection("users")
                                      .doc(FirebaseAuth
                                          .instance.currentUser!.uid)
                                      .update({
                                    'image': imageUrl,
                                  }).then((value) {
                                    print('update done');
                                    setState(() {
                                      photoIsUploading = false;
                                    });
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: height * 0.05),
                        if (photoIsUploading == true)
                          Center(
                              child: Text(
                            "Photo Is Uploading...",
                            style: mediumTextStyle(),
                          )),
                        SizedBox(height: height * 0.05),
                        TextFormField(
                          controller: editNameController,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.edit),
                            suffixIcon: IconButton(
                              icon: Icon(Icons.check),
                              color: Colors.green,
                              onPressed: () async {
                                await FirebaseFirestore.instance
                                    .collection("users")
                                    .doc(FirebaseAuth.instance.currentUser!.uid)
                                    .update({
                                  'name': editNameController.text.trim(),
                                }).then((value) {
                                  print('update name done');
                                  setState(() {
                                    editNameController.clear();
                                  });
                                });
                              },
                            ),
                            hintText: 'Edit Your Name',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        SizedBox(height: height * 0.05),
                        TextFormField(
                          controller: editBioController,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.edit),
                            suffixIcon: IconButton(
                              icon: Icon(Icons.check),
                              color: Colors.green,
                              onPressed: () async {
                                await FirebaseFirestore.instance
                                    .collection("users")
                                    .doc(FirebaseAuth.instance.currentUser!.uid)
                                    .update({
                                  'bio': editBioController.text.trim(),
                                }).then((value) {
                                  print('update bio done');
                                  setState(() {
                                    editBioController.clear();
                                  });
                                });
                              },
                            ),
                            hintText: 'Edit Your Bio',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        SizedBox(height: height * 0.05),
                        ElevatedButton(
                            onPressed: () async {
                              pref.clear();
                              await FirebaseAuth.instance
                                  .signOut()
                                  .then((value) {
                                print('sign out auth done');
                              });
                              await googleSignIn.signOut().then((value) {
                                print('sign out from google done');

                                navigateToPage(context, LoginScreen());
                              });
                            },
                            child: Text("Log Out"))
                      ],
                    );
                  }
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                },
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .get(),
              ),
            ))
          ],
        ),
      ),
    );
  }
}
