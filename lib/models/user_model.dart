import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String email;
  final String uid;
  final String photoUrl;
  final String username;
  final String bio;
  final List followers;
  final List following;

  const User({
    required this.email,
    required this.uid,
    required this.photoUrl,
    required this.username,
    required this.bio,
    required this.followers,
    required this.following,
  });

  // adding functions to user so we can easily access from firebase

  // this would convert the User class to an object file
  Map<String, dynamic> toJson() => {
    "username": username,
    "uid": uid,
    "photoUrl": photoUrl,
    "email": email,
    "bio": bio,
    "followers": followers,
    "following": following
  };

  // create a function that takes a document snapshot and return a data model
  static User fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return User(
        username: snapshot["username"],
        uid: snapshot["uid"],
        email: snapshot["email"],
        photoUrl: snapshot["photoUrl"],
        bio: snapshot["bio"],
        followers: snapshot["followers"],
        following: snapshot["following"]);
  }
}