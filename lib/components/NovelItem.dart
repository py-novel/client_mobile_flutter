import 'package:flutter/material.dart';

class NovelItem extends StatelessWidget {
  final String bookName;
  final String authorName;
  
  NovelItem({ this.bookName, this.authorName });

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 5.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Image(image: AssetImage("lib/images/cover.png"), fit: BoxFit.cover,),
            Align(
              alignment: Alignment(-0.6, -0.5),
              child: Text(
                bookName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 18.0, color: Colors.grey),
              ),
            ),
            Align(
              alignment: Alignment(0.2, 0.5),
              child: Text(
                authorName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 14.0, color: Colors.grey),
              ),
            ),
          ],
        ),
      );
  }
}