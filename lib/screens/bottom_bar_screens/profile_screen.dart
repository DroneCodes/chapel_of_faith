import 'package:chapel_of_faith/variables/variables_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../auth/auth_methods.dart';
import '../../auth/firestore_methods.dart';
import '../../variables/colors.dart';
import '../../widgets/follow_button.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String uid;

  const ProfileScreen({Key? key, required this.uid}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  var userData = {};

  // the number of posts the user has posted
  int postLen = 0;
  int followers = 0;
  int following = 0;

  // to check if you are following user or not
  bool isFollowing = false;
  bool isLoading = false;

  // create an init state to get the user data form fireStore
  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    setState(() {
      isLoading = true;
    });
    try {
      // getting user info
      var userSnap = await FirebaseFirestore.instance
          .collection("users")
          .doc(widget.uid)
          .get();
      // getting user post length
      var postSnap = await FirebaseFirestore.instance
          .collection("posts")
          .where(
            "uid",
            isEqualTo: FirebaseAuth.instance.currentUser!.uid,
          )
          .get();

      postLen = postSnap.docs.length;
      followers = userSnap.data()!["followers"].length;
      following = userSnap.data()!["following"].length;

      isFollowing = userSnap.data()!["followers"].contains(
            FirebaseAuth.instance.currentUser!.uid,
          );
      userData = userSnap.data()!;

      setState(() {});
    } catch (e) {
      showSnackBar(
        e.toString(),
        context,
      );
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(
      child: CircularProgressIndicator(),
    )
        : Scaffold(
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: Text(userData["username"]),
        centerTitle: false,
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.grey,
                      backgroundImage: NetworkImage(
                        userData["photoUrl"],
                      ),
                      radius: 40,
                    ),

                    // showing the statistics of the user

                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment:
                            MainAxisAlignment.spaceEvenly,
                            children: [
                              buildStatColumn(postLen, "posts"),
                              buildStatColumn(followers, "followers"),
                              buildStatColumn(following, "following")
                            ],
                          ),
                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceEvenly,
                            children: [
                              FirebaseAuth.instance.currentUser!.uid ==
                                  widget.uid
                                  ? FollowButton(
                                text: "Sign Out",
                                backgroundColor:
                                backgroundColor,
                                textColor: primaryColor,
                                borderColor: Colors.grey,
                                press: () async {
                                  await AuthMethods().signOut();
                                  Navigator.of(context)
                                      .pushReplacement(
                                    MaterialPageRoute(
                                        builder: (context) =>
                                        const LoginScreen()),
                                  );
                                },
                              )
                                  : isFollowing
                                  ? FollowButton(
                                text: "Unfollow",
                                backgroundColor: Colors.white,
                                textColor: Colors.black,
                                borderColor: Colors.grey,
                                press: () async {
                                  await FirestoreMethods()
                                      .followUser(
                                    FirebaseAuth.instance
                                        .currentUser!.uid,
                                    userData["uid"],
                                  );
                                  setState(() {
                                    isFollowing = false;
                                    followers--;
                                  });
                                },
                              )
                                  : FollowButton(
                                text: "Follow",
                                backgroundColor: primaryColor,
                                textColor: Colors.white,
                                borderColor: Colors.blue,
                                press: () async {
                                  await FirestoreMethods()
                                      .followUser(
                                    FirebaseAuth.instance
                                        .currentUser!.uid,
                                    userData["uid"],
                                  );
                                  setState(() {
                                    isFollowing = true;
                                    followers++;
                                  });
                                },
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    userData["username"],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    userData["bio"],
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          FutureBuilder(
            future: FirebaseFirestore.instance
                .collection("post")
                .where("uid", isEqualTo: widget.uid)
                .get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              return GridView.builder(
                itemCount: (snapshot.data! as dynamic).docs.length,
                shrinkWrap: true,
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 1.5,
                  childAspectRatio: 1,
                ),
                itemBuilder: (context, index) {
                  DocumentSnapshot snap =
                  (snapshot.data! as dynamic).docs[index];

                  return Container(
                    child: Image(
                      image: NetworkImage(
                        snap["postUrl"],
                      ),
                      fit: BoxFit.cover,
                    ),
                  );
                },
              );
            },
          )
        ],
      ),
    );
  }

  // a function for the stats of user

  Column buildStatColumn(int num, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          num.toString(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 4),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }
}
