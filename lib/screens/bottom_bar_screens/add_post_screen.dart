import 'dart:typed_data';

import 'package:chapel_of_faith/auth/firestore_methods.dart';
import 'package:chapel_of_faith/providers/provider.dart';
import 'package:chapel_of_faith/variables/colors.dart';
import 'package:chapel_of_faith/variables/variables_utils.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../models/user_model.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({Key? key}) : super(key: key);

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  Uint8List? _file;
  final TextEditingController _description = TextEditingController();
  bool _isLoading = false;

  void clearImage() {
    setState(() {
      _file = null;
    });
  }

  void postImage(String uid, String username, String profileImage) async {
    setState(() {
      _isLoading = true;
    });
    try {
      String res = await FirestoreMethods()
          .uploadPost(_description.text, _file!, uid, username, profileImage);

      if (res == "success") {
        setState(() {
          _isLoading = false;
        });
        showSnackBar(
          "Posted!",
          context,
        );
        clearImage();
      } else {
        setState(() {
          _isLoading = false;
        });
        showSnackBar(
          res,
          context,
        );
      }
    } catch (e) {
      showSnackBar(
        e.toString(),
        context,
      );
    }
  }

  selectImage(BuildContext context) async {
    showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: const Text("Create a post"),
            children: [
              SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text(
                  "Take a Photo",
                ),
                onPressed: () async {
                  Navigator.of(context).pop();
                  Uint8List file = await pickImage(
                    ImageSource.camera,
                  );
                  setState(() {
                    _file = file;
                  });
                },
              ),
              SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text(
                  "Choose a Photo",
                ),
                onPressed: () async {
                  Navigator.of(context).pop();
                  Uint8List file = await pickImage(
                    ImageSource.gallery,
                  );
                  setState(() {
                    _file = file;
                  });
                },
              ),
              SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text(
                  "Cancel",
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  @override
  void dispose() {
    super.dispose();
    _description.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    return _file == null
        ? Center(
            child: IconButton(
              onPressed: () => selectImage(context),
              icon: const Icon(
                Icons.upload,
              ),
            ),
          )
        : Scaffold(
            appBar: AppBar(
              backgroundColor: backgroundColor,
              leading: IconButton(
                onPressed: clearImage,
                icon: const Icon(
                  Icons.arrow_back,
                ),
              ),
              title: const Text(
                "Post to",
              ),
              centerTitle: false,
              actions: [
                TextButton(
                  onPressed: () => postImage(
                    userProvider.getUser.uid,
                    userProvider.getUser.username,
                    userProvider.getUser.photoUrl,
                  ),
                  child: const Text(
                    "Post",
                    style: TextStyle(
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            body: Column(
              children: [
                _isLoading
                    ? const LinearProgressIndicator()
                    : const Padding(
                        padding: EdgeInsets.only(
                          top: 0,
                        ),
                      ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(userProvider.getUser.photoUrl),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.45,
                      child: TextField(
                        controller: _description,
                        decoration: const InputDecoration(
                          hintText: "Write a caption for your post...",
                          border: InputBorder.none,
                        ),
                        maxLines: 8,
                      ),
                    ),
                    SizedBox(
                      height: 45,
                      width: 45,
                      child: AspectRatio(
                        aspectRatio: 487 / 451,
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: MemoryImage(
                                _file!,
                              ),
                              fit: BoxFit.fill,
                              alignment: FractionalOffset.topCenter,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Divider(),
                  ],
                )
              ],
            ),
          );
  }
}
