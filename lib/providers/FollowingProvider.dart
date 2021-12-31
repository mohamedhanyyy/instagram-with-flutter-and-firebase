import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app/shared/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

class FollowingProvider with ChangeNotifier {
  bool isFollowing = false;

  int followersCount = 0;
  int followingCount = 0;

  getFollowersCount(userUid) {

    FirebaseFirestore.instance
        .collection('users')
        .doc(userUid)
        .collection('followers')
        .get()
        .then((value) {
      followersCount = value.docs.length;
      print(followersCount);
      notifyListeners();
    });
  }
  getFollowingCount(userUid) {

    FirebaseFirestore.instance
        .collection('users')
        .doc(userUid)
        .collection('following')
        .get()
        .then((value) {
      followingCount = value.docs.length;
      print(followingCount);
      notifyListeners();
    });
  }

  void ifInTheFollowing(userUid) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('following')
        .where('userUid', isEqualTo: userUid)
        .get()
        .then((snapshot) {
      snapshot.docs.forEach((element) {
        if (element.data().isNotEmpty) isFollowing = true;
        print(isFollowing);
      });
    });
    notifyListeners();
  }

  void changeButton(following) {
    isFollowing = following;
    notifyListeners();
  }
}
