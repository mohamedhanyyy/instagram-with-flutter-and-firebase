import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
 import 'package:google_sign_in/google_sign_in.dart';


void navigateToPage(BuildContext context, Widget screen) {
  Navigator.of(context)
      .push(MaterialPageRoute(builder: (BuildContext context) => screen));
}

void navigateToPageWithoutBack(BuildContext context, Widget screen) {
  Navigator.pushReplacement(
      context, MaterialPageRoute(
          builder: (BuildContext context) => screen));

}

BuildContext? context;

Future<UserCredential> signInWithGoogle() async {
  final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

  final GoogleSignInAuthentication? googleAuth =
      await googleUser?.authentication;

  final credential = GoogleAuthProvider.credential(
    accessToken: googleAuth?.accessToken,
    idToken: googleAuth?.idToken,
  );

  return await FirebaseAuth.instance.signInWithCredential(credential);
}

String getFormattedDate(Timestamp timeStamp) {
  DateTime myDateTime = timeStamp.toDate();

  DateTime now = DateTime.now();

  Duration time = now.difference(myDateTime);
  int seconds = time.inSeconds;
  int minutes = time.inMinutes;
  int hours = time.inHours;
  int days = time.inDays;

  String showTime = "";

  if (seconds == 0 && minutes == 0 && hours == 0 && days == 0)
    showTime = "just now";
  else if (minutes < 1 && hours == 0)
    showTime = "$seconds sec";
  else if (minutes >= 1 && hours < 1)
    showTime = "$minutes min";
  else if (minutes >= 60 && hours <= 24)
    showTime = "$hours h";
  else if (hours > 24 && days < 7)
    showTime = "$days days";
  else
    showTime = "${(days / 7).floor()} weeks";

  return showTime;
}
