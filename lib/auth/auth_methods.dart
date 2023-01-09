import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chapel_of_faith/models/user_model.dart' as model;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  // create a function to get the user details

  Future<model.User> getUserDetails() async {
    User currentUser = _auth.currentUser!;

    DocumentSnapshot snap = await firebaseFirestore.collection("users").doc(currentUser.uid).get();

    return model.User.fromSnap(snap);

  }

  // create a function to signup user
  Future<String> signUpUser({required String email,
    required String password,
    required String username,
    required String bio,
    required Uint8List file}) async {
    String res = "Some error occured";
    try {
      if (email.isNotEmpty ||
          password.isNotEmpty ||
          username.isNotEmpty ||
          bio.isNotEmpty) {
        // register user
        UserCredential cred = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);

        String photoUrl = await StorageMethod()
            .uploadImageToStorage("profilePics", file, false);

        // create a User Model

        model.User user = model.User(
            username: username,
            uid: cred.user!.uid,
            email: email,
            bio: bio,
            followers: [],
            following: [],
            photoUrl: photoUrl
        );
        // add user to database
        await firebaseFirestore.collection("users").doc(cred.user!.uid).set(user.toJson());

        res = "success";
      }
      // for errors during signing in
    } on FirebaseAuthException catch (err) {
      if (err.code == "invalid-email") {
        res = "The email is badly formatted.";
      } else if (err.code == "weak-password") {
        res = "The password should be at least 6 characters";
      }
    }

    catch (err) {
      res = err.toString();
    }
    return res;
  }

  // to log in user

  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    String res = "some error occured";

    try {
      if(email.isNotEmpty || password.isNotEmpty) {
        await _auth.signInWithEmailAndPassword(email: email, password: password);
        res = "success";
      } else {
        res = "Please enter all the fields";
      }
    } catch(err) {
      res = err.toString();
    }
    return res;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

}

class StorageMethod {
  final FirebaseStorage storage = FirebaseStorage.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  // adding image to firebase storage
  Future<String> uploadImageToStorage(String childName, Uint8List file, bool isPost) async{

    Reference ref = storage.ref().child(childName).child(auth.currentUser!.uid);

    // to check if a user is posting or not

    if(isPost) {
      String id = const Uuid().v1();
      ref = ref.child(id);
    }

    UploadTask uploadTask = ref.putData(file);

    TaskSnapshot snap = await uploadTask;
    String downloadUrl = await snap.ref.getDownloadURL();
    return downloadUrl;
  }
}