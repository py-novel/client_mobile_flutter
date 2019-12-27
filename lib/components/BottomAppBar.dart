import 'package:flutter/material.dart';
import '../utils/color.dart';

class MyBottomAppBar extends StatelessWidget {
  final int currentIndex;
  MyBottomAppBar({this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: MyColor.bgColor,
      elevation: 0,
      selectedItemColor: MyColor.linkColor,
      items: [
        BottomNavigationBarItem(
          icon: Image(
            image: AssetImage('lib/images/book-shelf.png'),
            width: 28,
            height: 28,
          ),
          activeIcon: Image(
            image: AssetImage('lib/images/book-shelf-selected.png'),
            width: 28,
            height: 28,
          ),
          title: Text('书架'),
        ),
        BottomNavigationBarItem(
          icon: Image(
            image: AssetImage('lib/images/book-shop.png'),
            width: 28,
            height: 28,
          ),
          activeIcon: Image(
            image: AssetImage('lib/images/book-shop-selected.png'),
            width: 28,
            height: 28,
          ),
          title: Text('书屋'),
        )
      ],
      currentIndex: currentIndex,
      onTap: (int index) {
        if (index == currentIndex) return;

        String routerName = '/shelf';
        if (index == 1) routerName = '/classify';
        Navigator.pushNamedAndRemoveUntil(
            context, routerName, (Route<dynamic> route) => false);
      },
    );
  }
}
