import 'dart:typed_data';

import 'package:chapel_of_faith/auth/auth_methods.dart';
import 'package:chapel_of_faith/screens/auth/login_screen.dart';
import 'package:chapel_of_faith/variables/colors.dart';
import 'package:chapel_of_faith/variables/variables_utils.dart';
import 'package:chapel_of_faith/widgets/loading_screen.dart';
import 'package:chapel_of_faith/widgets/text_input_field.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../screen_layout.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController bio = TextEditingController();
  final TextEditingController username = TextEditingController();
  Uint8List? image;
  bool _isLoading = false;

  @override
  void dispose() {
    super.dispose();
    email.dispose();
    password.dispose();
    bio.dispose();
    username.dispose();
  }

  void selectImage() async {
    Uint8List _image = await pickImage(
      ImageSource.gallery,
    );
    setState(() {
      image = _image;
    });
  }

  void registerUser() async {
    setState(() {
      _isLoading = true;
    });
    String res = await AuthMethods().registerUser(
      email: email.text,
      password: password.text,
      username: username.text,
      bio: bio.text,
      file: image!,
    );
    setState(() {
      _isLoading = false;
    });

    if (res != "success") {
      showSnackBar(res, context);
    } else {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const ScreenLayout()));
    }
  }

  void navigateToLogIn() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                flex: 2,
                child: Container(),
              ),

              Image.asset(
                "assets/chapel_logo.jpg",
                color: primaryColor,
                height: 80,
              ),

              const SizedBox(
                height: 54,
              ),

              // the profile picture widget

              Stack(
                children: [
                  image != null
                      ? CircleAvatar(
                          radius: 64,
                          backgroundImage: MemoryImage(image!),
                        )
                      : const CircleAvatar(
                          radius: 64,
                          backgroundImage:
                              AssetImage("assets/default_profile.jpg"),
                        ),
                  Positioned(
                    left: 80,
                    bottom: -10,
                    child: IconButton(
                      onPressed: selectImage,
                      icon: const Icon(Icons.add_a_photo),
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 30,
              ),

              TextFieldInput(
                textEditingController: username,
                hintText: "Create a Username",
                textInputType: TextInputType.text,
              ),

              const SizedBox(
                height: 30,
              ),

              TextFieldInput(
                textEditingController: email,
                hintText: "Enter your email",
                textInputType: TextInputType.emailAddress,
              ),

              const SizedBox(
                height: 30,
              ),

              TextFieldInput(
                textEditingController: password,
                hintText: "Create your password",
                textInputType: TextInputType.text,
              ),

              const SizedBox(
                height: 30,
              ),

              TextFieldInput(
                textEditingController: bio,
                hintText: "Describe yourself",
                textInputType: TextInputType.text,
              ),

              const SizedBox(
                height: 30,
              ),

              InkWell(
                onTap: registerUser,
                child: Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: const ShapeDecoration(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                      ),
                      color: buttonColor),
                  child: _isLoading
                      ? const LoadingScreen()
                      : const Text(
                          "Sign Up",
                        ),
                ),
              ),

              const SizedBox(
                height: 15,
              ),

              Flexible(
                flex: 2,
                child: Container(),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: const Text(
                      "Do you have an account?",
                    ),
                  ),
                  GestureDetector(
                    onTap: navigateToLogIn,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: const Text(
                        "Log In",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
