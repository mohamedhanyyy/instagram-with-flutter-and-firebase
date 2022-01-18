import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app/shared/constants.dart';
import 'package:firebase_app/widgets/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';

class UploadPostScreen extends StatefulWidget {
  @override
  _UploadPostScreenState createState() => _UploadPostScreenState();
}

class _UploadPostScreenState extends State<UploadPostScreen> {
  TextEditingController postController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  var imageUrl;
  var uploadPostImageFile;
  ImagePicker uploadPostImagePicker = ImagePicker();

  String? userUid = FirebaseAuth.instance.currentUser!.uid;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getUserLocation();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return uploadPostImageFile == null
        ? Scaffold(
            body: Column(
            children: [
              Image.asset(
                'assets/images/cam1.jpg',
                fit: BoxFit.fill,
                width: width,
                height: height * 0.7,
              ),
              Center(
                  child: ElevatedButton(
                onPressed: () async {
                  showModalBottomSheet<void>(
                    context: context,
                    builder: (BuildContext context) {
                      return Container(
                        height: height * 0.3,
                        child: Center(
                          child: Column(
                            children: <Widget>[
                              Align(
                                child: IconButton(
                                  icon: Icon(Icons.close),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                                alignment: Alignment.topRight,
                              ),
                              ElevatedButton(
                                  onPressed: () async {
                                    final XFile? pickedImage =
                                        await uploadPostImagePicker.pickImage(
                                            source: ImageSource.camera);

                                    if (pickedImage != null) {
                                      setState(() {
                                        uploadPostImageFile =
                                            File(pickedImage.path);
                                      });
                                    }
                                    print(uploadPostImageFile);
                                    Navigator.pop(context);
                                  },
                                  child: Text('Upload from camera')),
                              ElevatedButton(
                                  onPressed: () async {
                                    final XFile? pickedImage =
                                        await uploadPostImagePicker.pickImage(
                                            source: ImageSource.gallery);
                                    if (pickedImage != null) {
                                      setState(() {
                                        uploadPostImageFile =
                                            File(pickedImage.path);
                                      });
                                      print(uploadPostImageFile);
                                    }
                                    Navigator.pop(context);
                                  },
                                  child: Text('Upload from gallery')),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                child: Text('Pick Image To Post'),
              )),
            ],
          ))
        : Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 5,
              actions: [
                Center(
                  child: GestureDetector(
                    child: Text(
                      'Post',
                      style: bigTextStyle(),
                    ),
                    onTap: () async {
                      setState(() {
                        isLoading = true;
                      });
                      String imageName = basename(uploadPostImageFile!.path);
                      var refStorage = FirebaseStorage.instance
                          .ref('posts')
                          .child(imageName);

                      await refStorage.putFile(File(uploadPostImageFile!.path));

                      imageUrl = await refStorage.getDownloadURL();

                      uploadPostToFirebase(context);
                    },
                  ),
                ),
                SizedBox(width: 15)
              ],
            ),
            body: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.03,
              ),
              child: ListView(
                children: [
                  SizedBox(
                    height: height * 0.03,
                  ),
                  Container(
                    width: width,
                    height: height * 0.47,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          image: FileImage(uploadPostImageFile!),
                          fit: BoxFit.cover),
                    ),
                  ),
                  SizedBox(
                    height: height * 0.02,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FutureBuilder(
                        builder: (context, AsyncSnapshot<dynamic> snapshot) {
                          if (snapshot.hasData) {
                            return CircleAvatar(
                              backgroundColor: Colors.black26,
                              radius: 20,
                              backgroundImage: NetworkImage(
                                snapshot.data['image'],
                              ),
                            );
                          } else
                            return Text('');
                        },
                        future: FirebaseFirestore.instance
                            .collection('users')
                            .doc(FirebaseAuth.instance.currentUser!.uid)
                            .get(),
                      ),
                      SizedBox(
                        width: width * 0.05,
                      ),
                      Expanded(
                          child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Write a Caption..',
                        ),
                        controller: postController,
                      ))
                    ],
                  ),
                  SizedBox(
                    height: height * 0.05,
                  ),
                  Row(
                    children: [
                      CircleAvatar(
                        child: Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 40,
                        ),
                        backgroundColor: Colors.grey[50],
                      ),
                      SizedBox(
                        width: width * 0.05,
                      ),
                      Expanded(
                          child: TextField(
                        decoration: InputDecoration(),
                        controller: locationController,
                      ))
                    ],
                  ),
                  SizedBox(
                    height: height * 0.05,
                  ),
                  if (isLoading == true)
                    Center(
                      child: CircularProgressIndicator(),
                    ),
                  SizedBox(
                    height: height * 0.05,
                  ),
                ],
              ),
            ),
          );
  }

  Future<void> uploadPostToFirebase(context) async {
    {
      String timeStamp = Timestamp.now().toString();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userUid)
          .collection('posts')
          .doc(timeStamp)
          .set({
        'postImage': imageUrl,
        'likeCount': 0,
        'caption': postController.text,
        'location': locationController.text,
        'dateTime': Timestamp.now(),
        'postUid': timeStamp,
        'uid': userUid,
        'likes': {},
      }).then((value) {
        CommonWidget.makeSnackBar(
          title: 'Uploaded successfully',
          message: 'Thanks for Uploading Post.', context: context,
        );
        setState(() {
          isLoading = false;
          uploadPostImageFile = null;
          postController.clear();

          print('Upload post done');
        });
      });
    }
  }

  Future<void> getUserLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    List<Placemark> placeMarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);

    Placemark placeMark = placeMarks[0];

    // print(placeMark);

    String fullAddress = '${placeMark.locality}, ${placeMark.country}';

    locationController.text = fullAddress;
  }
}
