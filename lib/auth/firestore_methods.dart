import 'dart:typed_data';

import 'package:chapel_of_faith/auth/auth_methods.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/post_model.dart';

class FirestoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // a function to help us to upload a post
  Future<String> uploadPost(String description, Uint8List file, String uid,
      String username, String profileImage) async {
    String res = "some error occured";
    try {
      String photoUrl =
          await StorageMethod().uploadImageToStorage("posts", file, true);

      String postId = const Uuid().v1();

      // function to create a post

      Post post = Post(
        description: description,
        uid: uid,
        postId: postId,
        username: username,
        datePublished: DateTime.now(),
        postUrl: photoUrl,
        profileImage: profileImage,
        likes: [],
      );
      _firestore.collection("post").doc(postId).set(post.toJson());
      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  // function to like a post

  Future<void> likePost(String postId, String uid, List likes) async {
    try {
      if (likes.contains(uid)) {
        await _firestore.collection("post").doc(postId).update({
          "likes": FieldValue.arrayRemove([uid]),
        });
      } else {
        await _firestore.collection("post").doc(postId).update({
          "likes": FieldValue.arrayUnion([uid]),
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print(
          e.toString(),
        );
      }
    }
  }

  // function to post a comment
  Future<void> postComment(String postId, String text, String uid, String name,
      String profilePic, List likes) async {
    try {
      if (text.isNotEmpty) {
        String commentId = const Uuid().v1();
        await _firestore
            .collection("post")
            .doc(postId)
            .collection("comments")
            .doc(commentId)
            .set({
          "profilePic": profilePic,
          "name": name,
          "uid": uid,
          "text": text,
          "commentId": commentId,
          "datePublished": DateTime.now(),
          "likes": []
        });
      } else {
        print("Text is empty");
      }
    } catch (e) {
      print(
        e.toString(),
      );
    }
  }

  // function to like a comment
  Future<void> likeComment(
      String postId, String uid, List likes, String commentId) async {
    try {
      if (likes.contains(uid)) {
        await _firestore
            .collection("post")
            .doc(postId)
            .collection("comments")
            .doc(commentId)
            .update({
          "likes": FieldValue.arrayRemove([uid]),
        });
      } else {
        await _firestore
            .collection("post")
            .doc(postId)
            .collection("comments")
            .doc(commentId)
            .update({
          "likes": FieldValue.arrayUnion([uid]),
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print(
          e.toString(),
        );
      }
    }
  }

  // function to delete a post
  Future<void> deletePost(String postId) async {
    try {
      await _firestore.collection("post").doc(postId).delete();
    } catch (err) {
      print(
        err.toString(),
      );
    }
  }

  // function to follow a user
  Future<void> followUser(String uid, String followId) async {
    try {
      DocumentSnapshot snapshot =
          await _firestore.collection("users").doc(uid).get();

      List following = (snapshot.data()! as dynamic)["following"];

      // check if user is already following someone
      if (following.contains(followId)) {
        await _firestore.collection("users").doc(followId).update({
          "followers": FieldValue.arrayRemove([uid])
        });

        await _firestore.collection("users").doc(followId).update({
          "following": FieldValue.arrayRemove([followId])
        });
      } // check if user is not following the other account
      else {
        await _firestore.collection("users").doc(followId).update({
          "followers": FieldValue.arrayUnion([uid])
        });

        await _firestore.collection("users").doc(followId).update({
          "following": FieldValue.arrayUnion([followId])
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }
}
