import 'package:chapel_of_faith/screens/bottom_bar_screens/add_post_screen.dart';
import 'package:chapel_of_faith/screens/bottom_bar_screens/feed_screen.dart';
import 'package:chapel_of_faith/screens/bottom_bar_screens/profile_screen.dart';
import 'package:chapel_of_faith/screens/bottom_bar_screens/search_screen.dart';
import 'package:chapel_of_faith/variables/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ScreenLayout extends StatefulWidget {
  const ScreenLayout({Key? key}) : super(key: key);

  @override
  State<ScreenLayout> createState() => _ScreenLayoutState();
}

class _ScreenLayoutState extends State<ScreenLayout> {
  int _page = 0;
  late PageController pageController;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  void navigationTapped(int page) {
    pageController.jumpToPage(page);
  }

  void onPageChanged(int page) {
    setState(() {
      _page = page;
    });
  }

  List<Widget> screenList = [
    const FeedScreen(),
    const SearchScreen(),
    const AddPostScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: pageController,
        onPageChanged: onPageChanged,
        physics: const NeverScrollableScrollPhysics(),
        children: screenList,
      ),
      bottomNavigationBar: CupertinoTabBar(
        backgroundColor: backgroundColor,
        items: [
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.home, color: _page == 0 ? primaryColor : secondaryColor,), label: "", backgroundColor: primaryColor,),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.search, color: _page == 1 ? primaryColor : secondaryColor,), label: "", backgroundColor: primaryColor,),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.add_circled, color: _page == 2 ? primaryColor : secondaryColor,), label: "", backgroundColor: primaryColor,),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.person, color: _page == 3 ? primaryColor : secondaryColor,), label: "", backgroundColor: primaryColor,),
        ],
        onTap: navigationTapped,
      ),
    );
  }
}
