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
        elevation: 4,
        centerTitle: true,
        backgroundColor: Colors.white,
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
                                child: CircleAvatar(
                                  backgroundColor: Colors.grey[200],
                                  child: Icon(
                                    Icons.camera_alt_rounded,
                                    size: 25,
                                    color: Colors.black,
                                  ),
                                ),
                                onTap: () async {
                                  showModalBottomSheet<void>(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return Container(
                                          height: height * 0.3,
                                          child: Column(children: [

                                            Align(
                                              child: IconButton(
                                                icon: Icon(Icons.close),
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                              ),
                                              alignment: Alignment.topRight,
                                            ),
                                            ElevatedButton(onPressed: ()async{

                                              updatedPhoto = await picker.pickImage(
                                                  source: ImageSource.camera);
                                             if(updatedPhoto!=null)
                                               {
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
                                               }
                                             else
                                               Navigator.pop(context);


                                            }, child: Text("Upload from camera")),


                                            ElevatedButton(onPressed: ()async{
                                              Navigator.pop(context);
                                              updatedPhoto = await picker.pickImage(
                                                  source: ImageSource.gallery);
                                              if(updatedPhoto!=null)
                                              {
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
                                                })  ;
                                              }
                                              else
                                                Navigator.pop(context);


                                            }, child: Text("Upload from gallery")),

                                          ],),

                                        );
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
                        Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: width * 0.2),
                          child: ElevatedButton(
                              onPressed: () async {
                                pref.clear();
                                await FirebaseAuth.instance
                                    .signOut()
                                    .then((value) {
                                  print('sign out auth done');
                                });
                                await googleSignIn.signOut().then((value) {
                                  print('sign out from google done');
                                });
                                navigateToPageWithoutBack(
                                    context, LoginScreen());
                              },
                              child: Row(
                                children: [
                                  Text("Log Out"),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  Icon(Icons.logout)
                                ],
                                mainAxisAlignment: MainAxisAlignment.center,
                              )),
                        )
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
